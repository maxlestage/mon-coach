import Foundation

/// Une semaine de course prescrite.
public struct RunningWeek: Sendable, Equatable {
    /// Numéro de la semaine dans le bloc, à partir de 1.
    public var index: Int
    public var runs: [PlannedRun]
    /// Volume visé sur la semaine, en mètres.
    public var targetMeters: Double
    /// Vrai pour une semaine d'assimilation : volume réduit, intensité gardée.
    public var isRecoveryWeek: Bool
    public var focus: LocalizedText

    public var runCount: Int { runs.count }
}

/// Un bloc de préparation complet.
public struct RunningBlock: Sendable, Equatable {
    public var goal: RunningGoal
    public var weeks: [RunningWeek]
    public var notes: [LocalizedText]
    /// Allure de seuil retenue pour dériver les allures cibles, en s/km.
    public var thresholdPaceSecondsPerKm: Double
    /// Vrai quand cette allure est une estimation faute de course de référence.
    public var thresholdIsEstimated: Bool
}

/// Construit un plan de course qui tient compte de la musculation déjà prévue.
///
/// Deux principes gouvernent tout ce fichier. Le premier : on ne progresse
/// pas en volume et en intensité la même semaine. Le second : la charge
/// hebdomadaire ne monte jamais de plus de 10 %, et une semaine sur quatre
/// redescend — c'est la règle qui évite les périostites et les tendinopathies
/// d'Achille, les deux blessures qui arrêtent les coureurs qui débutent.
public enum RunPlanner {

    /// Allure de seuil par défaut, faute de mieux, en secondes par kilomètre.
    ///
    /// Dérivée du niveau et du sexe, à l'aide des distributions publiées des
    /// temps de course populaire. C'est un point de départ, pas un verdict :
    /// la première sortie tempo la corrige.
    public static func estimatedThresholdPace(profile: UserProfile, running: RunningProfile) -> Double {
        if let known = running.thresholdPaceSecondsPerKm, known > 0 { return known }

        // Base : un coureur occasionnel tient environ 5:45/km au seuil.
        var pace: Double = 345
        switch profile.experience {
        case .beginner: pace = 390      // 6:30/km
        case .intermediate: pace = 330  // 5:30/km
        case .advanced: pace = 285      // 4:45/km
        }
        if profile.sex == .female { pace *= 1.10 }

        // Le volume déjà encaissé en dit plus que l'ancienneté déclarée.
        if running.currentWeeklyMeters >= 40_000 { pace *= 0.92 }
        else if running.currentWeeklyMeters >= 25_000 { pace *= 0.96 }
        else if running.currentWeeklyMeters < 10_000 { pace *= 1.06 }

        // L'âge, à partir de 35 ans, avec le facteur classique de ~0,7 %/an.
        let age = Double(profile.age())
        if age > 35 { pace *= 1 + (age - 35) * 0.007 }

        return (pace / 5).rounded() * 5
    }

    /// Fourchette d'allure à afficher pour un type de sortie.
    public static func paceRange(for type: RunType, thresholdPaceSecondsPerKm threshold: Double) -> ClosedRange<Double> {
        let factors = type.paceFactor
        let low = (threshold * factors.lowerBound / 5).rounded() * 5
        let high = (threshold * factors.upperBound / 5).rounded() * 5
        return low...max(low, high)
    }

    /// Le volume de la première semaine, en mètres.
    ///
    /// On repart du kilométrage réel, jamais de l'objectif : la fracture de
    /// fatigue naît toujours de l'écart entre ce que le coureur fait et ce
    /// qu'il pense pouvoir faire.
    static func startingWeeklyMeters(running: RunningProfile) -> Double {
        let declared = running.currentWeeklyMeters
        guard declared > 0 else {
            // Vrai débutant : 3 sorties de 3 km, alternance course-marche.
            return 9_000
        }
        return max(6_000, declared)
    }

    /// Construit un bloc de préparation.
    ///
    /// - Parameters:
    ///   - strengthDays: les jours de la semaine (0 = lundi) déjà occupés par
    ///     une séance de musculation. Le plan évite d'y poser une séance dure.
    public static func block(
        profile: UserProfile,
        running: RunningProfile,
        weekCount: Int = 8,
        strengthDays: Set<Int> = [],
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> RunningBlock {
        let threshold = estimatedThresholdPace(profile: profile, running: running)
        let isEstimated = running.thresholdPaceSecondsPerKm == nil

        // Si une date de course est connue, le bloc s'arrête dessus.
        var weeks = max(3, weekCount)
        if let raceDate = running.raceDate {
            let days = calendar.dateComponents([.day], from: today, to: raceDate).day ?? 0
            if days > 0 {
                weeks = max(3, min(24, Int((Double(days) / 7).rounded(.down))))
            }
        }

        let start = startingWeeklyMeters(running: running)
        let peak = peakWeeklyMeters(running: running, start: start)

        var built: [RunningWeek] = []
        for index in 1...weeks {
            let recovery = index % 4 == 0 && index != weeks
            let taper = running.raceDate != nil && index == weeks
            let volume = weeklyMeters(
                week: index,
                total: weeks,
                start: start,
                peak: peak,
                isRecoveryWeek: recovery,
                isTaper: taper
            )
            built.append(
                week(
                    index: index,
                    total: weeks,
                    targetMeters: volume,
                    isRecoveryWeek: recovery,
                    isTaper: taper,
                    running: running,
                    threshold: threshold,
                    strengthDays: strengthDays
                )
            )
        }

        return RunningBlock(
            goal: running.goal,
            weeks: built,
            notes: blockNotes(
                profile: profile,
                running: running,
                threshold: threshold,
                isEstimated: isEstimated,
                strengthDays: strengthDays
            ),
            thresholdPaceSecondsPerKm: threshold,
            thresholdIsEstimated: isEstimated
        )
    }

    /// Le volume de pointe visé en fin de bloc.
    static func peakWeeklyMeters(running: RunningProfile, start: Double) -> Double {
        // Le pic doit permettre de placer la sortie longue de l'objectif, qui
        // ne doit jamais dépasser ~35 % du volume de la semaine.
        let fromLongRun = running.goal.peakLongRunMeters / 0.35
        // …et il ne doit pas dépasser 1,6 fois le point de départ sur un bloc :
        // au-delà, on promet une progression que le tendon ne suivra pas.
        return min(fromLongRun, start * 1.6)
    }

    /// Volume d'une semaine donnée, en mètres.
    static func weeklyMeters(
        week: Int,
        total: Int,
        start: Double,
        peak: Double,
        isRecoveryWeek: Bool,
        isTaper: Bool
    ) -> Double {
        guard total > 1 else { return start }
        // Montée linéaire du départ au pic sur les semaines de charge.
        let progress = Double(week - 1) / Double(max(1, total - 1))
        var meters = start + (peak - start) * progress
        if isRecoveryWeek { meters *= 0.75 }
        if isTaper { meters *= 0.55 }
        // Arrondi au demi-kilomètre : personne ne court 17 843 m.
        return (meters / 500).rounded() * 500
    }

    /// Compose les sorties d'une semaine.
    static func week(
        index: Int,
        total: Int,
        targetMeters: Double,
        isRecoveryWeek: Bool,
        isTaper: Bool,
        running: RunningProfile,
        threshold: Double,
        strengthDays: Set<Int>
    ) -> RunningWeek {
        let days = runDays(count: running.runsPerWeek, strengthDays: strengthDays)
        let types = weekTypes(
            runsPerWeek: running.runsPerWeek,
            weekIndex: index,
            total: total,
            goal: running.goal,
            isRecoveryWeek: isRecoveryWeek,
            isTaper: isTaper
        )

        // La sortie longue prend une part du volume qui grandit avec le bloc,
        // plafonnée pour ne pas vider les autres sorties de leur substance.
        let longShare = min(0.35, 0.25 + Double(index) * 0.01)
        let longMeters = min(
            running.goal.peakLongRunMeters,
            ((targetMeters * longShare) / 500).rounded() * 500
        )
        let hasLong = types.contains(.long)
        let remaining = max(0, targetMeters - (hasLong ? longMeters : 0))
        let otherCount = max(1, types.count - (hasLong ? 1 : 0))

        var runs: [PlannedRun] = []
        for (offset, type) in types.enumerated() {
            let day = offset < days.count ? days[offset] : offset
            switch type {
            case .long:
                runs.append(
                    PlannedRun(
                        dayIndex: day,
                        type: .long,
                        targetMeters: longMeters,
                        paceRangeSecondsPerKm: paceRange(for: .long, thresholdPaceSecondsPerKm: threshold),
                        note: longRunNote(meters: longMeters)
                    )
                )
            case .intervals:
                let session = intervalSession(goal: running.goal, weekIndex: index, threshold: threshold)
                runs.append(
                    PlannedRun(
                        dayIndex: day,
                        type: .intervals,
                        targetMeters: (remaining / Double(otherCount) / 500).rounded() * 500,
                        paceRangeSecondsPerKm: paceRange(for: .intervals, thresholdPaceSecondsPerKm: threshold),
                        intervals: [session],
                        note: intervalNote(session: session)
                    )
                )
            case .tempo:
                let tempoMeters = ((remaining / Double(otherCount)) / 500).rounded() * 500
                runs.append(
                    PlannedRun(
                        dayIndex: day,
                        type: .tempo,
                        targetMeters: tempoMeters,
                        paceRangeSecondsPerKm: paceRange(for: .tempo, thresholdPaceSecondsPerKm: threshold),
                        note: tempoNote(totalMeters: tempoMeters)
                    )
                )
            case .easy, .recovery, .race:
                runs.append(
                    PlannedRun(
                        dayIndex: day,
                        type: type,
                        targetMeters: ((remaining / Double(otherCount)) / 500).rounded() * 500,
                        paceRangeSecondsPerKm: paceRange(for: type, thresholdPaceSecondsPerKm: threshold),
                        note: easyNote(type: type)
                    )
                )
            }
        }

        return RunningWeek(
            index: index,
            runs: runs.sorted { $0.dayIndex < $1.dayIndex },
            targetMeters: targetMeters,
            isRecoveryWeek: isRecoveryWeek,
            focus: weekFocus(index: index, total: total, isRecoveryWeek: isRecoveryWeek, isTaper: isTaper)
        )
    }

    /// Répartit les sorties dans la semaine.
    ///
    /// On étale d'abord, on évite ensuite les jours de musculation pour les
    /// sorties dures, et on ne colle jamais deux sorties bout à bout tant
    /// qu'il reste un jour libre.
    static func runDays(count: Int, strengthDays: Set<Int>) -> [Int] {
        let runs = count.clamped(to: 1...6)
        let preferred: [[Int]] = [
            [2],
            [1, 4],
            [1, 3, 5],
            [1, 3, 5, 6],
            [0, 1, 3, 5, 6],
            [0, 1, 2, 4, 5, 6],
        ]
        var days = preferred[runs - 1]
        // Décale une sortie posée sur un jour de musculation vers le premier
        // jour libre, quand il en reste un.
        if !strengthDays.isEmpty && runs < 6 {
            for position in days.indices where strengthDays.contains(days[position]) {
                let taken = Set(days)
                if let free = (0..<7).first(where: { !taken.contains($0) && !strengthDays.contains($0) }) {
                    days[position] = free
                }
            }
        }
        return days.sorted()
    }

    /// Le menu d'une semaine, dans l'ordre où les sorties seront posées.
    static func weekTypes(
        runsPerWeek: Int,
        weekIndex: Int,
        total: Int,
        goal: RunningGoal,
        isRecoveryWeek: Bool,
        isTaper: Bool
    ) -> [RunType] {
        let runs = runsPerWeek.clamped(to: 1...6)

        if isTaper {
            // Dernière semaine avant la course : on garde du rythme, on enlève
            // la fatigue. Une seule séance vive, très courte.
            return Array(repeating: RunType.easy, count: max(1, runs - 1)) + [.race]
        }

        // Les trois premières semaines n'ont pas d'intensité : le tissu
        // conjonctif s'adapte plus lentement que le cœur, et c'est lui qui casse.
        let allowsIntensity = weekIndex >= 3 && !isRecoveryWeek

        switch runs {
        case 1:
            return [.long]
        case 2:
            return allowsIntensity ? [.tempo, .long] : [.easy, .long]
        case 3:
            return allowsIntensity ? [.easy, .tempo, .long] : [.easy, .easy, .long]
        case 4:
            if !allowsIntensity { return [.easy, .easy, .easy, .long] }
            return goal == .marathon || goal == .halfMarathon
                ? [.easy, .tempo, .easy, .long]
                : [.easy, .intervals, .easy, .long]
        case 5:
            if !allowsIntensity { return [.recovery, .easy, .easy, .easy, .long] }
            return [.recovery, .intervals, .easy, .tempo, .long]
        default:
            if !allowsIntensity { return [.recovery, .easy, .easy, .easy, .easy, .long] }
            return [.recovery, .intervals, .easy, .tempo, .easy, .long]
        }
    }

    /// Construit la séance de fractionné de la semaine.
    static func intervalSession(goal: RunningGoal, weekIndex: Int, threshold: Double) -> RunInterval {
        // Distance de répétition selon l'objectif : plus la course est longue,
        // plus les répétitions le sont aussi.
        let repMeters: Double = switch goal {
        case .firstFiveK: 400
        case .tenK: 600
        case .halfMarathon: 1_000
        case .marathon: 1_200
        case .endurance: 400
        }
        // Le volume de la séance monte de semaine en semaine, puis se stabilise.
        let baseVolume: Double = switch goal {
        case .firstFiveK: 2_000
        case .tenK: 3_000
        case .halfMarathon: 4_000
        case .marathon: 5_000
        case .endurance: 2_000
        }
        let volume = min(baseVolume * 1.5, baseVolume + Double(weekIndex - 3) * 400)
        let repetitions = max(3, Int((volume / repMeters).rounded()))
        // Récupération : proportionnelle à l'effort, plus longue sur le court.
        let effortSeconds = repMeters / 1_000 * threshold * 0.92
        let recovery = repMeters <= 500 ? effortSeconds : effortSeconds * 0.6
        return RunInterval(
            repetitions: repetitions,
            meters: repMeters,
            recoverySeconds: (recovery / 5).rounded() * 5,
            paceSecondsPerKm: (threshold * 0.92 / 5).rounded() * 5
        )
    }

    // MARK: - Textes

    static func longRunNote(meters: Double) -> LocalizedText {
        let km = Format.number(meters / 1_000, decimals: meters < 10_000 ? 1 : 0, language: .french)
        let kmEN = Format.number(meters / 1_000, decimals: meters < 10_000 ? 1 : 0, language: .english)
        return LocalizedText(
            fr: "\(km) km à allure de conversation. Si tu ne peux pas parler, tu cours trop vite : ralentis, le bénéfice est dans la durée.",
            en: "\(kmEN) km at conversational pace. If you cannot talk, you are running too fast — slow down, the benefit is in the time on feet.",
            es: "\(km) km a ritmo de conversación. Si no puedes hablar, vas demasiado rápido: baja el ritmo, el beneficio está en el tiempo."
        )
    }

    static func tempoNote(totalMeters: Double) -> LocalizedText {
        LocalizedText(
            fr: "15 min d'échauffement, puis 20 min au seuil : soutenu, mais tenable jusqu'au bout. Retour au calme 10 min.",
            en: "15 min warm-up, then 20 min at threshold: hard, but holdable to the end. 10 min cool-down.",
            es: "15 min de calentamiento, luego 20 min en umbral: exigente pero sostenible hasta el final. 10 min de vuelta a la calma."
        )
    }

    static func intervalNote(session: RunInterval) -> LocalizedText {
        let reps = session.repetitions
        let meters = Int(session.meters)
        let recovery = Int(session.recoverySeconds)
        return LocalizedText(
            fr: "\(reps) × \(meters) m, \(recovery) s de récupération en trottinant. Les répétitions doivent toutes se ressembler : si la dernière s'effondre, la séance était trop ambitieuse.",
            en: "\(reps) × \(meters) m with \(recovery) s of jogged recovery. Every repetition should look the same: if the last one falls apart, the session was too ambitious.",
            es: "\(reps) × \(meters) m con \(recovery) s de recuperación trotando. Todas las series deben parecerse: si la última se desmorona, la sesión era demasiado ambiciosa."
        )
    }

    static func easyNote(type: RunType) -> LocalizedText {
        switch type {
        case .recovery:
            LocalizedText(
                fr: "Très lent, volontairement. Cette sortie n'a aucune valeur si elle fatigue.",
                en: "Deliberately very slow. This run has no value at all if it leaves you tired.",
                es: "Muy lento, a propósito. Este rodaje no vale nada si te deja cansado."
            )
        case .race:
            LocalizedText(
                fr: "Jour de course. Pars plus lentement que ce que tes jambes fraîches réclament.",
                en: "Race day. Start slower than your fresh legs are asking for.",
                es: "Día de carrera. Sal más lento de lo que te piden las piernas frescas."
            )
        default:
            LocalizedText(
                fr: "Allure facile, respiration par le nez possible. C'est la sortie qui construit tout le reste.",
                en: "Easy pace, nose breathing still possible. This is the run everything else is built on.",
                es: "Ritmo fácil, con la respiración nasal aún posible. Es el rodaje sobre el que se construye todo lo demás."
            )
        }
    }

    static func weekFocus(index: Int, total: Int, isRecoveryWeek: Bool, isTaper: Bool) -> LocalizedText {
        if isTaper {
            return LocalizedText(
                fr: "Affûtage : le volume tombe, la fraîcheur monte. Aucune séance ne peut plus t'améliorer, mais une séance de trop peut te coûter la course.",
                en: "Taper: volume drops, freshness climbs. No session can make you fitter now, but one session too many can cost you the race.",
                es: "Puesta a punto: baja el volumen, sube la frescura. Ninguna sesión puede mejorarte ya, pero una de más puede costarte la carrera."
            )
        }
        if isRecoveryWeek {
            return LocalizedText(
                fr: "Semaine d'assimilation : moins de volume, même allure. C'est pendant cette semaine que les trois précédentes deviennent de la forme.",
                en: "Absorption week: less volume, same paces. This is the week where the previous three turn into fitness.",
                es: "Semana de asimilación: menos volumen, mismos ritmos. Es la semana en la que las tres anteriores se convierten en forma."
            )
        }
        if index <= 2 {
            return LocalizedText(
                fr: "Mise en route : que du facile. Les tendons s'adaptent plus lentement que le souffle.",
                en: "Getting rolling: easy only. Tendons adapt more slowly than your breathing does.",
                es: "Puesta en marcha: solo suave. Los tendones se adaptan más despacio que la respiración."
            )
        }
        if index >= total - 1 {
            return LocalizedText(
                fr: "Fin de bloc : la spécificité prime. Les allures se rapprochent de celles de l'objectif.",
                en: "End of block: specificity rules. Paces move towards the ones your goal demands.",
                es: "Final del bloque: manda la especificidad. Los ritmos se acercan a los del objetivo."
            )
        }
        return LocalizedText(
            fr: "Semaine de charge : le volume monte d'environ 10 %, pas davantage.",
            en: "Loading week: volume climbs by about 10 %, and no more.",
            es: "Semana de carga: el volumen sube alrededor de un 10 %, no más."
        )
    }

    static func blockNotes(
        profile: UserProfile,
        running: RunningProfile,
        threshold: Double,
        isEstimated: Bool,
        strengthDays: Set<Int>
    ) -> [LocalizedText] {
        var notes: [LocalizedText] = []
        let pace = Format.pace(secondsPerKm: threshold, unit: profile.unit)

        if isEstimated {
            notes.append(
                LocalizedText(
                    fr: "Allure de seuil estimée à \(pace) à partir de ton profil. Elle se corrigera toute seule après ta première sortie tempo ou ton premier test chronométré.",
                    en: "Threshold pace estimated at \(pace) from your profile. It will correct itself after your first tempo run or timed test.",
                    es: "Ritmo de umbral estimado en \(pace) a partir de tu perfil. Se corregirá solo tras tu primer tempo o test cronometrado."
                )
            )
        }

        if !strengthDays.isEmpty {
            notes.append(
                LocalizedText(
                    fr: "Les sorties dures ont été écartées de tes jours de musculation. Quand les deux tombent le même jour, cours en premier et laisse au moins six heures entre les deux.",
                    en: "Hard runs were kept off your lifting days. When both land on the same day, run first and leave at least six hours between them.",
                    es: "Las sesiones duras se han separado de tus días de fuerza. Si coinciden, corre primero y deja al menos seis horas entre ambas."
                )
            )
        }

        if running.goal == .firstFiveK && running.currentWeeklyMeters < 6_000 {
            notes.append(
                LocalizedText(
                    fr: "Tu démarres : alterne 2 min de course et 1 min de marche pendant les trois premières semaines. La marche n'est pas un échec, c'est ce qui rend la semaine suivante possible.",
                    en: "You are starting out: alternate 2 min running and 1 min walking for the first three weeks. Walking is not failure — it is what makes next week possible.",
                    es: "Estás empezando: alterna 2 min corriendo y 1 min caminando durante las tres primeras semanas. Caminar no es fracasar, es lo que hace posible la semana siguiente."
                )
            )
        }

        if let raceDate = running.raceDate, let target = running.goal.raceDistanceMeters {
            let weeks = max(0, Int((raceDate.timeIntervalSinceNow / 604_800).rounded(.down)))
            let predicted = RunMath.predictedRaceTime(thresholdPaceSecondsPerKm: threshold, distanceMeters: target)
            let time = predicted.map(Format.stopwatch(seconds:)) ?? "—"
            notes.append(
                LocalizedText(
                    fr: "\(weeks) semaines avant la course. Sur ton allure de seuil actuelle, le modèle de Riegel table sur \(time) — une projection, pas une promesse : elle ne connaît ni le vent, ni le dénivelé, ni ton sommeil de la veille.",
                    en: "\(weeks) weeks to race day. At your current threshold pace, Riegel's model projects \(time) — a projection, not a promise: it knows nothing about wind, elevation, or how you slept the night before.",
                    es: "\(weeks) semanas hasta la carrera. Con tu ritmo de umbral actual, el modelo de Riegel proyecta \(time): una proyección, no una promesa, porque no sabe nada del viento, del desnivel ni de cómo dormiste la víspera."
                )
            )
        }

        notes.append(
            LocalizedText(
                fr: "Une douleur qui modifie ta foulée arrête la sortie. Une gêne qui disparaît à l'échauffement ne l'arrête pas. C'est la seule règle de blessure qui vaille sans examen.",
                en: "Pain that changes your gait ends the run. Discomfort that fades during the warm-up does not. Without a scan, that is the only injury rule worth having.",
                es: "Un dolor que cambia tu zancada termina el rodaje. Una molestia que desaparece al calentar, no. Sin una prueba médica, es la única regla de lesiones que sirve."
            )
        )
        return notes
    }
}
