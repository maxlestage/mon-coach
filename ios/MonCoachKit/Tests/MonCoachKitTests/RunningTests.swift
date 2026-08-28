import Foundation
import Testing
@testable import MonCoachKit

/// Fabrique des traces GPS dont on connaît la vérité terrain, pour pouvoir
/// vérifier ce que l'analyse en tire au lieu de la croire sur parole.
enum TraceFactory {
    /// Degrés de latitude par mètre, sur le rayon exact utilisé par haversine.
    static let degreesPerMeter = 180 / (.pi * TraceMath.earthRadiusMeters)

    /// Une ligne droite plein nord, un point par seconde.
    static func straightNorth(
        meters: Double,
        speed: Double,
        from origin: (lat: Double, lon: Double) = (48.8566, 2.3522),
        startingAt start: Date = Date(timeIntervalSince1970: 1_780_000_000),
        altitudes: (Double) -> Double = { _ in 0 },
        accuracy: Double = 5
    ) -> [GPSPoint] {
        let seconds = Int((meters / speed).rounded())
        return (0...seconds).map { step in
            let travelled = Double(step) * speed
            return GPSPoint(
                timestamp: start.addingTimeInterval(Double(step)),
                latitude: origin.lat + travelled * degreesPerMeter,
                longitude: origin.lon,
                altitude: altitudes(travelled),
                horizontalAccuracy: accuracy,
                verticalAccuracy: 5
            )
        }
    }
}

@Suite("Géodésie et allure")
struct RunMathTests {

    @Test("Haversine retrouve la distance d'un degré de latitude")
    func oneDegreeOfLatitude() {
        let d = TraceMath.distance(latitude1: 0, longitude1: 0, latitude2: 1, longitude2: 0)
        // Un degré de méridien sur une sphère de 6 371 008,8 m : R × π/180.
        #expect(abs(d - 111_195.08) < 0.5)
    }

    @Test("Haversine tombe juste sur une distance connue")
    func parisLyon() {
        // Paris (48,8566 / 2,3522) → Lyon (45,7640 / 4,8357) : ~392 km.
        let d = TraceMath.distance(latitude1: 48.8566, longitude1: 2.3522, latitude2: 45.7640, longitude2: 4.8357)
        #expect(abs(d - 392_000) < 3_000)
    }

    @Test("Deux points identiques sont à distance nulle")
    func zeroDistance() {
        let p = GPSPoint(timestamp: Date(), latitude: 48.8, longitude: 2.3)
        #expect(TraceMath.distance(from: p, to: p) == 0)
    }

    @Test("Allure et vitesse sont réciproques")
    func paceRoundTrip() {
        let pace = TraceMath.pace(meters: 5_000, seconds: 1_500)   // 5:00/km
        #expect(abs(pace - 300) < 0.001)
        #expect(abs(TraceMath.speed(fromPaceSecondsPerKm: pace) - 10.0 / 3) < 0.001)
    }

    @Test("Une distance nulle ne produit pas une allure infinie")
    func noDivisionByZero() {
        #expect(TraceMath.pace(meters: 0, seconds: 600) == 0)
        #expect(TraceMath.speed(fromPaceSecondsPerKm: 0) == 0)
    }

    @Test("Le bruit d'altitude ne fabrique pas de dénivelé")
    func flatNoiseProducesNoGain() {
        // ±0,6 m de bruit sur 300 points : un cumul naïf donnerait ~180 m.
        let noisy = (0..<300).map { index in Double(index % 2) * 1.2 - 0.6 }
        let smoothed = TraceMath.movingAverage(noisy, window: 5)
        #expect(TraceMath.elevationGain(smoothedAltitudes: smoothed, threshold: 1) == 0)
    }

    @Test("Une vraie montée est comptée")
    func realClimbIsCounted() {
        let climb = (0..<100).map { Double($0) * 0.5 }   // 0 → 49,5 m
        let gain = TraceMath.elevationGain(smoothedAltitudes: climb, threshold: 1)
        #expect(abs(gain - 49.5) < 1.5)
    }

    @Test("Une descente ne compte pas comme du dénivelé positif")
    func descentIsNotGain() {
        let descent = (0..<100).map { 100 - Double($0) * 0.5 }
        #expect(TraceMath.elevationGain(smoothedAltitudes: descent, threshold: 1) == 0)
    }

    @Test("La dépense énergétique suit l'ordre de grandeur connu")
    func energy() {
        // 10 km à plat pour 70 kg : ~725 kcal.
        let flat = TraceMath.energyKcal(meters: 10_000, elevationGain: 0, weightKg: 70)
        #expect(abs(flat - 725) < 5)
        // 500 m de D+ ajoutent ~328 kcal.
        let hilly = TraceMath.energyKcal(meters: 10_000, elevationGain: 500, weightKg: 70)
        #expect(hilly > flat)
        #expect(abs(hilly - flat - 328) < 5)
    }

    @Test("Riegel prédit le semi à partir du 10 km")
    func riegel() {
        // 10 km en 40:00 → semi ≈ 40 × 2,1097^1,06 ≈ 88,6 min.
        let half = TraceMath.predictedTime(fromDistance: 10_000, time: 2_400, toDistance: 21_097.5)
        let minutes = (half ?? 0) / 60
        #expect(abs(minutes - 88.6) < 1.0)
    }

    @Test("L'allure de seuil et la prédiction sont cohérentes entre elles")
    func thresholdRoundTrip() {
        // Une performance quelconque donne un seuil ; ce seuil doit
        // reprédire la même performance.
        let threshold = TraceMath.thresholdPace(fromDistance: 10_000, time: 2_400)
        let back = TraceMath.predictedRaceTime(thresholdPaceSecondsPerKm: threshold ?? 0, distanceMeters: 10_000)
        #expect(abs((back ?? 0) - 2_400) < 1)
    }

    @Test("Une performance trop courte ne donne pas de seuil")
    func thresholdNeedsDistance() {
        #expect(TraceMath.thresholdPace(fromDistance: 400, time: 60) == nil)
    }
}

@Suite("Analyse d'une trace GPS")
struct RunAnalysisTests {

    @Test("Une trace propre est mesurée au mètre près")
    func cleanTraceIsAccurate() {
        let points = TraceFactory.straightNorth(meters: 3_000, speed: 10.0 / 3)
        let trace = TraceAnalysis.clean(points)
        #expect(abs(trace.meters - 3_000) < 5)
        #expect(abs(trace.movingDuration - 900) < 1.5)
        #expect(abs(trace.paceSecondsPerKm - 300) < 1)
        #expect(trace.elevationGain == 0)
        #expect(trace.retention == 1)
    }

    @Test("Les points imprécis sont écartés et comptés")
    func inaccuratePointsRejected() {
        var points = TraceFactory.straightNorth(meters: 1_000, speed: 10.0 / 3)
        points[10].horizontalAccuracy = 80
        points[11].horizontalAccuracy = -1      // « pas de fix », pas « parfait »
        let trace = TraceAnalysis.clean(points)
        #expect(trace.rejectedForAccuracy == 2)
        #expect(trace.samples.count == points.count - 2)
        // La distance reste juste : le segment enjambe simplement les trous.
        #expect(abs(trace.meters - 1_000) < 5)
    }

    @Test("Un saut impossible est écarté sans casser la suite de la trace")
    func teleportRejected() {
        var points = TraceFactory.straightNorth(meters: 1_000, speed: 10.0 / 3)
        points[50].latitude += 0.5   // ~55 km d'un coup
        let trace = TraceAnalysis.clean(points)
        #expect(trace.rejectedForSpeed == 1)
        #expect(abs(trace.meters - 1_000) < 5)
    }

    @Test("Un arrêt ne compte ni en distance ni en temps de mouvement")
    func pauseIsExcluded() {
        let start = Date(timeIntervalSince1970: 1_780_000_000)
        var points = TraceFactory.straightNorth(meters: 1_000, speed: 10.0 / 3, startingAt: start)
        let last = points[points.count - 1]
        // Cinq minutes immobile, avec le tremblement habituel du GPS.
        for step in 1...300 {
            points.append(
                GPSPoint(
                    timestamp: last.timestamp.addingTimeInterval(Double(step)),
                    latitude: last.latitude + Double(step % 2) * 0.0000015,
                    longitude: last.longitude,
                    altitude: 0
                )
            )
        }
        let trace = TraceAnalysis.clean(points)
        #expect(abs(trace.meters - 1_000) < 5)
        #expect(abs(trace.movingDuration - 300) < 2)
        #expect(trace.elapsedDuration > 590)   // le temps réel, lui, a bien passé
    }

    @Test("Les points désordonnés sont écartés")
    func outOfOrderRejected() {
        var points = TraceFactory.straightNorth(meters: 300, speed: 10.0 / 3)
        points.append(points[5])   // un doublon, donc un temps qui n'avance pas
        let trace = TraceAnalysis.clean(points)
        #expect(trace.rejectedForOrder == 1)
    }

    @Test("Une trace trop courte ne fait pas planter l'analyse")
    func degenerateTraces() {
        #expect(TraceAnalysis.clean([]).isEmpty)
        let single = [GPSPoint(timestamp: Date(), latitude: 48.85, longitude: 2.35)]
        let trace = TraceAnalysis.clean(single)
        #expect(trace.isEmpty)
        #expect(trace.meters == 0)
        #expect(TraceAnalysis.splits(of: trace).isEmpty)
    }

    @Test("Les kilomètres sont découpés au bon endroit")
    func splitsAreCorrect() {
        let points = TraceFactory.straightNorth(meters: 3_500, speed: 10.0 / 3)
        let trace = TraceAnalysis.clean(points)
        let splits = TraceAnalysis.splits(of: trace)
        #expect(splits.count == 4)
        for split in splits.prefix(3) {
            #expect(abs(split.meters - 1_000) < 0.001)
            #expect(abs(split.duration - 300) < 1)
            #expect(abs(split.paceSecondsPerKm - 300) < 1)
        }
        // Le reliquat est conservé tel quel, incomplet mais juste.
        #expect(abs(splits[3].meters - 500) < 5)
        #expect(abs(splits[3].paceSecondsPerKm - 300) < 2)
        #expect(splits.map(\.index) == [1, 2, 3, 4])
    }

    @Test("La somme des segments redonne la distance totale")
    func splitsSumToTotal() {
        let points = TraceFactory.straightNorth(meters: 7_300, speed: 3.1)
        let trace = TraceAnalysis.clean(points)
        let splits = TraceAnalysis.splits(of: trace)
        let sum = splits.reduce(0) { $0 + $1.meters }
        #expect(abs(sum - trace.meters) < 1)
        let seconds = splits.reduce(0) { $0 + $1.duration }
        #expect(abs(seconds - trace.movingDuration) < 1)
    }

    @Test("Une allure qui change se lit dans les segments")
    func splitsSeeAPaceChange() {
        let start = Date(timeIntervalSince1970: 1_780_000_000)
        var points = TraceFactory.straightNorth(meters: 1_000, speed: 10.0 / 3, startingAt: start)
        let junction = points[points.count - 1]
        // Deuxième kilomètre couru à 4:00/km au lieu de 5:00.
        let fast = TraceFactory.straightNorth(
            meters: 1_000,
            speed: 1_000 / 240,
            from: (junction.latitude, junction.longitude),
            startingAt: junction.timestamp.addingTimeInterval(1)
        )
        points.append(contentsOf: fast.dropFirst(0))
        let splits = TraceAnalysis.splits(of: TraceAnalysis.clean(points))
        #expect(splits.count >= 2)
        #expect(abs(splits[0].paceSecondsPerKm - 300) < 3)
        #expect(abs(splits[1].paceSecondsPerKm - 240) < 6)
    }

    @Test("Le dénivelé est réparti sur les bons kilomètres")
    func elevationLandsOnTheRightSplit() {
        // Plat sur 1 km, puis 40 m de montée régulière sur le deuxième.
        let points = TraceFactory.straightNorth(
            meters: 2_000,
            speed: 10.0 / 3,
            altitudes: { travelled in travelled <= 1_000 ? 0 : (travelled - 1_000) * 0.04 }
        )
        let trace = TraceAnalysis.clean(points)
        let splits = TraceAnalysis.splits(of: trace)
        #expect(splits.count == 2)
        #expect(splits[0].elevationGain < 2)
        #expect(abs(splits[1].elevationGain - 40) < 3)
        #expect(abs(trace.elevationGain - 40) < 3)
    }

    @Test("Le résumé d'une sortie conserve la trace brute")
    func summaryKeepsRawTrace() {
        var points = TraceFactory.straightNorth(meters: 2_000, speed: 10.0 / 3)
        points[3].horizontalAccuracy = 90
        let log = TraceAnalysis.summarise(rawPoints: points, type: .easy, perceivedEffort: 5)
        #expect(log.points.count == points.count)   // rien n'est perdu
        #expect(abs(log.meters - 2_000) < 5)
        #expect(log.splits.count == 2)
        #expect(log.perceivedEffort == 5)
        #expect(abs(log.kilometers - 2) < 0.01)
    }
}

/// Un profil de coureur paramétrable, pour ne pas répéter six champs par test.
fileprivate func runner(
    goal: RunningGoal = .tenK,
    runsPerWeek: Int = 4,
    weeklyMeters: Double = 25_000,
    threshold: Double? = nil,
    raceDate: Date? = nil
) -> RunningProfile {
    RunningProfile(
        goal: goal,
        runsPerWeek: runsPerWeek,
        currentWeeklyMeters: weeklyMeters,
        raceDate: raceDate,
        thresholdPaceSecondsPerKm: threshold
    )
}

@Suite("Plan de course")
struct RunPlannerTests {

    @Test("Le nombre de sorties par semaine est borné à la construction")
    func runsPerWeekIsClamped() {
        #expect(RunningProfile(runsPerWeek: 0).runsPerWeek == 1)
        #expect(RunningProfile(runsPerWeek: 12).runsPerWeek == 6)
        #expect(RunningProfile(currentWeeklyMeters: -5).currentWeeklyMeters == 0)
    }

    @Test("Le volume ne monte jamais de plus de 10 % d'une semaine de charge à la suivante")
    func volumeRampIsSafe() {
        // La règle des 10 % porte sur la tendance des semaines de charge. Le
        // rebond après une semaine d'assimilation n'est pas une progression :
        // c'est un retour sur la marche qu'on avait déjà montée. On compare
        // donc chaque semaine à la dernière semaine de charge, pas à celle
        // qui la précède dans le calendrier.
        for goal in RunningGoal.allCases {
            let block = RunPlanner.block(
                profile: Fixtures.intermediate(),
                running: runner(goal: goal, weeklyMeters: 30_000),
                weekCount: 12
            )
            var lastLoading: Double?
            for week in block.weeks {
                if let previous = lastLoading, week.targetMeters > previous {
                    let ramp = week.targetMeters / previous
                    #expect(ramp <= 1.11, Comment(rawValue: "\(goal) semaine \(week.index) : +\(Int((ramp - 1) * 100)) %"))
                }
                if !week.isRecoveryWeek { lastLoading = week.targetMeters }
            }
        }
    }

    @Test("Une semaine d'assimilation retire du volume sans casser la progression")
    func recoveryWeekIsARealStepBack() {
        let block = RunPlanner.block(
            profile: Fixtures.intermediate(),
            running: runner(goal: .halfMarathon, weeklyMeters: 30_000),
            weekCount: 12
        )
        for week in block.weeks where week.isRecoveryWeek {
            let before = block.weeks[week.index - 2]
            // Assez léger pour servir à quelque chose…
            #expect(week.targetMeters <= before.targetMeters * 0.85)
            // …mais pas au point de perdre l'adaptation acquise.
            #expect(week.targetMeters >= before.targetMeters * 0.6)
        }
    }

    @Test("Le volume ne dépasse jamais le pic annoncé")
    func neverExceedsPeak() {
        let running = runner(goal: .marathon, weeklyMeters: 40_000)
        let block = RunPlanner.block(profile: Fixtures.intermediate(), running: running, weekCount: 16)
        let peak = RunPlanner.peakWeeklyMeters(
            running: running,
            start: RunPlanner.startingWeeklyMeters(running: running)
        )
        for week in block.weeks {
            #expect(week.targetMeters <= peak + 500)
        }
    }

    @Test("Une semaine sur quatre redescend")
    func recoveryWeeksExist() {
        let block = RunPlanner.block(profile: Fixtures.intermediate(), running: runner(), weekCount: 12)
        let recovery = block.weeks.filter(\.isRecoveryWeek)
        #expect(recovery.count == 2)
        for week in recovery {
            let previous = block.weeks[week.index - 2]
            #expect(week.targetMeters < previous.targetMeters)
        }
    }

    @Test("Le bloc part du kilométrage réel, pas de l'objectif")
    func startsFromCurrentVolume() {
        let block = RunPlanner.block(
            profile: Fixtures.intermediate(),
            running: runner(goal: .marathon, weeklyMeters: 20_000),
            weekCount: 10
        )
        // Un marathon sur 20 km/semaine ne commence pas à 60 km.
        #expect(block.weeks[0].targetMeters <= 21_000)
        #expect(block.weeks[0].targetMeters >= 19_000)
    }

    @Test("La sortie longue ne dévore pas la semaine")
    func longRunShareIsBounded() {
        for goal in RunningGoal.allCases {
            let block = RunPlanner.block(
                profile: Fixtures.intermediate(),
                running: runner(goal: goal, weeklyMeters: 30_000),
                weekCount: 10
            )
            for week in block.weeks {
                guard let long = week.runs.first(where: { $0.type == .long }),
                      let meters = long.targetMeters, week.targetMeters > 0 else { continue }
                #expect(meters / week.targetMeters <= 0.40, "\(goal) semaine \(week.index)")
            }
        }
    }

    @Test("Les deux premières semaines n'ont aucune intensité")
    func noIntensityAtTheStart() {
        let block = RunPlanner.block(profile: Fixtures.intermediate(), running: runner(), weekCount: 10)
        for week in block.weeks.prefix(2) {
            #expect(!week.runs.contains { $0.type == .intervals || $0.type == .tempo })
        }
    }

    @Test("Chaque semaine contient bien le nombre de sorties demandé")
    func runCountMatches() {
        for count in 1...6 {
            let block = RunPlanner.block(
                profile: Fixtures.intermediate(),
                running: runner(runsPerWeek: count),
                weekCount: 6
            )
            for week in block.weeks {
                #expect(week.runCount == count, "\(count) sorties, semaine \(week.index)")
            }
        }
    }

    @Test("Deux sorties ne tombent jamais le même jour")
    func daysAreDistinct() {
        for count in 1...6 {
            let days = RunPlanner.runDays(count: count, strengthDays: [])
            #expect(Set(days).count == days.count)
            #expect(days.allSatisfy { (0..<7).contains($0) })
        }
    }

    @Test("Les sorties évitent les jours de musculation quand c'est possible")
    func avoidsStrengthDays() {
        // Trois sorties, trois jours de musculation : il reste quatre jours libres.
        let days = RunPlanner.runDays(count: 3, strengthDays: [1, 3, 5])
        #expect(days.allSatisfy { ![1, 3, 5].contains($0) })
        #expect(Set(days).count == 3)
    }

    @Test("Six sorties par semaine cohabitent avec la musculation sans se dédoubler")
    func sixRunsStillFit() {
        let days = RunPlanner.runDays(count: 6, strengthDays: [1, 3, 5])
        #expect(Set(days).count == 6)
    }

    @Test("Une date de course fixe la longueur du bloc et déclenche l'affûtage")
    func raceDateDrivesTheBlock() {
        let race = Fixtures.start.addingTimeInterval(70 * 86_400)   // dix semaines
        let block = RunPlanner.block(
            profile: Fixtures.intermediate(),
            running: runner(goal: .tenK, raceDate: race),
            weekCount: 20,
            today: Fixtures.start,
            calendar: Fixtures.calendar
        )
        #expect(block.weeks.count == 10)
        let last = block.weeks[block.weeks.count - 1]
        #expect(last.runs.contains { $0.type == .race })
        #expect(last.targetMeters < block.weeks[block.weeks.count - 2].targetMeters)
    }

    @Test("Les allures cibles s'ordonnent comme l'effort")
    func paceRangesAreOrdered() {
        let threshold = 300.0
        let easy = RunPlanner.paceRange(for: .easy, thresholdPaceSecondsPerKm: threshold)
        let tempo = RunPlanner.paceRange(for: .tempo, thresholdPaceSecondsPerKm: threshold)
        let intervals = RunPlanner.paceRange(for: .intervals, thresholdPaceSecondsPerKm: threshold)
        let recovery = RunPlanner.paceRange(for: .recovery, thresholdPaceSecondsPerKm: threshold)
        // Plus l'allure est rapide, plus le nombre de secondes est petit.
        #expect(intervals.upperBound < tempo.lowerBound)
        #expect(tempo.upperBound < easy.lowerBound)
        #expect(easy.upperBound <= recovery.upperBound)
        #expect(recovery.lowerBound > tempo.upperBound)
    }

    @Test("Le seuil connu est repris tel quel, sinon il est estimé")
    func thresholdSource() {
        let profile = Fixtures.intermediate()
        let known = RunPlanner.estimatedThresholdPace(profile: profile, running: runner(threshold: 268))
        #expect(known == 268)

        let estimated = RunPlanner.estimatedThresholdPace(profile: profile, running: runner())
        #expect(estimated > 200 && estimated < 500)

        let block = RunPlanner.block(profile: profile, running: runner(), weekCount: 6)
        #expect(block.thresholdIsEstimated)
    }

    @Test("Un débutant se voit prescrire une allure plus lente qu'un confirmé")
    func experienceMovesThePace() {
        let novice = RunPlanner.estimatedThresholdPace(
            profile: Fixtures.beginner(),
            running: runner(weeklyMeters: 8_000)
        )
        let seasoned = RunPlanner.estimatedThresholdPace(
            profile: Fixtures.advanced(),
            running: runner(weeklyMeters: 45_000)
        )
        #expect(novice > seasoned)
    }

    @Test("Le fractionné reste structuré et réaliste")
    func intervalSessionsAreSane() {
        let block = RunPlanner.block(
            profile: Fixtures.intermediate(),
            running: runner(goal: .tenK, runsPerWeek: 5),
            weekCount: 10
        )
        let sessions = block.weeks.flatMap(\.runs).filter { $0.type == .intervals }
        #expect(!sessions.isEmpty)
        for run in sessions {
            guard let interval = run.intervals.first else {
                Issue.record("un fractionné sans structure de répétitions")
                continue
            }
            #expect(interval.repetitions >= 3 && interval.repetitions <= 20)
            #expect(interval.meters >= 200 && interval.meters <= 2_000)
            #expect(interval.recoverySeconds > 0)
            #expect(interval.paceSecondsPerKm > 0)
        }
    }

    @Test("Chaque texte du plan existe dans les trois langues")
    func everyTextIsTranslated() {
        let block = RunPlanner.block(
            profile: Fixtures.intermediate(),
            running: runner(goal: .marathon, runsPerWeek: 5, raceDate: Fixtures.start.addingTimeInterval(120 * 86_400)),
            weekCount: 16,
            strengthDays: [1, 4],
            today: Fixtures.start,
            calendar: Fixtures.calendar
        )
        for note in block.notes { #expect(note.isComplete, Comment(rawValue: "note de bloc incomplète : " + note.fr)) }
        for week in block.weeks {
            #expect(week.focus.isComplete)
            for run in week.runs {
                #expect(run.note.isComplete, Comment(rawValue: "consigne incomplète : " + run.note.fr))
                #expect(run.type.label.isComplete)
                #expect(run.type.purpose.isComplete)
            }
        }
        for goal in RunningGoal.allCases { #expect(goal.label.isComplete) }
    }
}

@Suite("Langues")
struct LanguageTests {

    @Test("La langue du système est reconnue, région comprise")
    func matching() {
        #expect(Language.best(matching: ["fr-CA", "en-US"]) == .french)
        #expect(Language.best(matching: ["es-419"]) == .spanish)
        #expect(Language.best(matching: ["en_GB"]) == .english)
    }

    @Test("Une langue inconnue laisse la place à la suivante")
    func skipsUnknownLanguages() {
        #expect(Language.best(matching: ["de-DE", "it", "es-ES"]) == .spanish)
        #expect(Language.best(matching: ["ja", "ko"]) == .fallback)
        #expect(Language.best(matching: []) == .fallback)
    }

    @Test("Un texte incomplet est détecté")
    func completeness() {
        #expect(LocalizedText(fr: "a", en: "b", es: "c").isComplete)
        #expect(!LocalizedText(fr: "a", en: "  ", es: "c").isComplete)
        #expect(LocalizedText.constant("VO2max").isComplete)
    }

    @Test("Le texte est rendu dans la langue demandée")
    func rendering() {
        let text = LocalizedText(fr: "Séance", en: "Session", es: "Sesión")
        #expect(text(.french) == "Séance")
        #expect(text[.english] == "Session")
        #expect([text].rendered(in: .spanish) == ["Sesión"])
    }

    @Test("Les nombres suivent la langue")
    func numberFormatting() {
        #expect(Format.number(12.5, decimals: 1, language: .french) == "12,5")
        #expect(Format.number(12.5, decimals: 1, language: .english) == "12.5")
        #expect(Format.number(12.5, decimals: 1, language: .spanish) == "12,5")
    }

    @Test("Allure, chrono et distance se lisent comme les coureurs les lisent")
    func runningFormats() {
        #expect(Format.pace(secondsPerKm: 300, unit: .metric) == "5:00 /km")
        #expect(Format.pace(secondsPerKm: 0, unit: .metric) == "—")
        #expect(Format.stopwatch(seconds: 2_892) == "48:12")
        #expect(Format.stopwatch(seconds: 4_060) == "1:07:40")
        #expect(Format.distance(meters: 21_097.5, unit: .metric, language: .english) == "21.1 km")
    }
}

@Suite("La course dans le programme")
struct RunningIntegrationTests {

    static func profile() -> UserProfile {
        var profile = Fixtures.intermediate(daysPerWeek: 4)
        profile.running = RunningProfile(goal: .tenK, runsPerWeek: 3, currentWeeklyMeters: 24_000)
        return profile
    }

    @Test("Un athlète qui ne court pas n'a pas de plan de course")
    func noRunningNoBlock() {
        let program = CoachEngine.buildProgram(for: Fixtures.intermediate(), startingOn: Fixtures.start)
        #expect(program.runningBlock == nil)
        let briefing = CoachEngine.briefing(
            for: program,
            history: .empty,
            on: Fixtures.start,
            calendar: Fixtures.calendar
        )
        #expect(briefing.plannedRun == nil)
    }

    @Test("Le plan de course couvre exactement le bloc de musculation")
    func blockLengthsMatch() {
        let program = CoachEngine.buildProgram(for: Self.profile(), startingOn: Fixtures.start)
        let block = program.runningBlock
        #expect(block != nil)
        #expect(block?.weeks.count == program.plan.weeks.count)
    }

    @Test("Le briefing du jour propose la sortie prévue, et n'en invente pas les autres jours")
    func briefingCarriesTheRun() {
        let program = CoachEngine.buildProgram(for: Self.profile(), startingOn: Fixtures.start)
        guard let firstWeek = program.runningBlock?.weeks.first else {
            Issue.record("pas de plan de course")
            return
        }
        for run in firstWeek.runs {
            let day = Fixtures.calendar.date(byAdding: .day, value: run.dayIndex, to: Fixtures.start)!
            let briefing = CoachEngine.briefing(
                for: program,
                history: .empty,
                on: day,
                calendar: Fixtures.calendar
            )
            #expect(briefing.plannedRun?.id == run.id, Comment(rawValue: "jour \(run.dayIndex)"))
        }
        let free = (0..<7).first { day in !firstWeek.runs.contains { $0.dayIndex == day } }
        if let free {
            let day = Fixtures.calendar.date(byAdding: .day, value: free, to: Fixtures.start)!
            let briefing = CoachEngine.briefing(
                for: program,
                history: .empty,
                on: day,
                calendar: Fixtures.calendar
            )
            #expect(briefing.plannedRun == nil)
        }
    }

    @Test("Une sortie enregistrée apparaît dans le briefing du jour")
    func recordedRunShowsUp() {
        let program = CoachEngine.buildProgram(for: Self.profile(), startingOn: Fixtures.start)
        let log = ActivityLog(
            startedAt: Fixtures.start.addingTimeInterval(3_600),
            type: .easy,
            meters: 6_000,
            duration: 1_920,
            elevationGain: 12
        )
        let briefing = CoachEngine.briefing(
            for: program,
            history: TrainingHistory(activities: [log]),
            on: Fixtures.start,
            calendar: Fixtures.calendar
        )
        #expect(briefing.recordedRun?.id == log.id)
    }

    @Test("Le kilométrage de la semaine se calcule sur sept jours glissants")
    func weeklyMeters() {
        let history = TrainingHistory(activities: [
            ActivityLog(startedAt: Fixtures.start, type: .easy, meters: 5_000, duration: 1_500, elevationGain: 0),
            ActivityLog(startedAt: Fixtures.start.addingTimeInterval(3 * 86_400), type: .long, meters: 12_000, duration: 3_900, elevationGain: 0),
            ActivityLog(startedAt: Fixtures.start.addingTimeInterval(-10 * 86_400), type: .easy, meters: 8_000, duration: 2_400, elevationGain: 0),
        ])
        let total = history.weeklyRunMeters(
            endingOn: Fixtures.start.addingTimeInterval(3 * 86_400),
            calendar: Fixtures.calendar
        )
        #expect(abs(total - 17_000) < 1)   // la sortie d'il y a dix jours est hors fenêtre
    }

    @Test("Seules les sorties rapides servent à estimer le seuil")
    func onlyHardRunsMoveTheThreshold() {
        // Un footing très lent ne doit pas faire croire au coach qu'on a ralenti.
        let easy = ActivityLog(startedAt: Fixtures.start, type: .easy, meters: 10_000, duration: 4_200, elevationGain: 0)
        let tempo = ActivityLog(startedAt: Fixtures.start, type: .tempo, meters: 5_000, duration: 1_200, elevationGain: 0)
        #expect(TrainingHistory(activities: [easy]).demonstratedThresholdPace() == nil)

        let both = TrainingHistory(activities: [easy, tempo]).demonstratedThresholdPace()
        let fromTempo = TrainingHistory(activities: [tempo]).demonstratedThresholdPace()
        #expect(both == fromTempo)
    }

    @Test("Une sortie trop courte ne sert pas de référence")
    func shortRunsAreIgnored() {
        let sprint = ActivityLog(startedAt: Fixtures.start, type: .intervals, meters: 800, duration: 150, elevationGain: 0)
        #expect(TrainingHistory(activities: [sprint]).demonstratedThresholdPace() == nil)
    }
}
