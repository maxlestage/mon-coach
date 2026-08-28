import Foundation
import Testing
@testable import MonCoachKit

/// Fabrique une trace rectiligne à partir de tronçons (distance, allure),
/// échantillonnée tous les `stepMeters`.
///
/// L'échantillonnage est un paramètre parce que c'est exactement ce que la
/// recherche de records ne doit pas voir : le même parcours mesuré tous les
/// 5 m ou tous les 40 m doit donner le même chrono.
private func paced(
    _ segments: [(meters: Double, paceSecondsPerKm: Double)],
    stepMeters: Double = 10,
    start: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> [GPSPoint] {
    let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
    var points: [GPSPoint] = []
    var distance = 0.0
    var seconds = 0.0
    points.append(
        GPSPoint(timestamp: start, latitude: 48.85, longitude: 2.35,
                 altitude: 100, horizontalAccuracy: 5, verticalAccuracy: 5)
    )
    for segment in segments {
        var covered = 0.0
        while covered < segment.meters {
            let step = min(stepMeters, segment.meters - covered)
            covered += step
            distance += step
            seconds += step / 1_000 * segment.paceSecondsPerKm
            points.append(
                GPSPoint(
                    timestamp: start.addingTimeInterval(seconds),
                    latitude: 48.85,
                    longitude: 2.35 + distance / metersPerDegree,
                    altitude: 100,
                    horizontalAccuracy: 5,
                    verticalAccuracy: 5
                )
            )
        }
    }
    return points
}

private func activity(
    _ points: [GPSPoint],
    sport: Sport = .run,
    type: RunType = .easy,
    at date: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> ActivityLog {
    var log = TraceAnalysis.summarise(rawPoints: points, sport: sport, type: type)
    log.startedAt = date
    return log
}

@Suite("Records personnels")
struct BestEffortsTests {

    @Test("Le meilleur kilomètre est trouvé au milieu d'une sortie")
    func fastestKilometreIsFoundInside() throws {
        // 3 km à 4:00, 1 km à 3:00, 3 km à 4:00.
        let points = paced([(3_000, 240), (1_000, 180), (3_000, 240)])
        let trace = TraceAnalysis.clean(points)

        let best = try #require(BestEfforts.fastest(1_000, in: trace))
        #expect(abs(best.duration - 180) < 1.0, "le kilomètre rapide doit sortir à 3:00")
        #expect(abs(best.startMeters - 3_000) < 20, "et il commence au bon endroit")
    }

    @Test("Le chrono ne dépend pas de la densité des points")
    func samplingDoesNotChangeTheRecord() throws {
        // Sans interpolation aux bords, une trace échantillonnée tous les
        // 40 m mesurerait le « kilomètre » sur 1 040 m et perdrait dix
        // secondes : le record dépendrait du GPS, pas des jambes.
        let fine = TraceAnalysis.clean(paced([(2_000, 240)], stepMeters: 5))
        let coarse = TraceAnalysis.clean(paced([(2_000, 240)], stepMeters: 40))

        let a = try #require(BestEfforts.fastest(1_000, in: fine))
        let b = try #require(BestEfforts.fastest(1_000, in: coarse))

        #expect(abs(a.duration - 240) < 0.5)
        #expect(abs(b.duration - 240) < 0.5, "l'échantillonnage grossier ne doit rien changer")
        #expect(abs(a.duration - b.duration) < 0.5)
    }

    @Test("Une distance plus longue que la sortie n'a pas de record")
    func tooShortHasNoRecord() {
        let trace = TraceAnalysis.clean(paced([(3_000, 240)]))
        #expect(BestEfforts.fastest(5_000, in: trace) == nil)
        #expect(BestEfforts.fastest(1_000, in: trace) != nil)
    }

    @Test("Le meilleur 5 km profite du kilomètre rapide qu'il contient")
    func longerEffortsIncludeTheFastSection() throws {
        let points = paced([(3_000, 240), (1_000, 180), (3_000, 240)])
        let trace = TraceAnalysis.clean(points)

        let best = try #require(BestEfforts.fastest(5_000, in: trace))
        #expect(best.duration < 5 * 240, "il doit contenir le tronçon rapide")
        #expect(best.duration > 4 * 240 + 180 - 5, "mais pas plus d'un kilomètre rapide")
    }

    @Test("Le premier effort est annoncé comme un premier, pas comme un record")
    func firstEffortIsNotCalledARecord() throws {
        let run = activity(paced([(6_000, 240)]))
        let ranks = BestEfforts.ranks(for: run, against: [])

        let fiveK = try #require(ranks.first { $0.effort.distance == .fiveKilometres })
        #expect(fiveK.rank == 1)
        #expect(fiveK.previousBest == nil)
        #expect(fiveK.headline.fr.hasPrefix("Premier"))
        #expect(fiveK.headline.en.hasPrefix("First"))
    }

    @Test("Un effort plus lent qu'un précédent est classé deuxième")
    func slowerEffortRanksSecond() throws {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let fast = activity(paced([(6_000, 240)]), at: day)
        let slow = activity(paced([(6_000, 260)]), at: day.addingTimeInterval(86_400))

        let ranks = BestEfforts.ranks(for: slow, against: [fast, slow])
        let fiveK = try #require(ranks.first { $0.effort.distance == .fiveKilometres })

        #expect(fiveK.rank == 2)
        #expect(fiveK.isRecord == false)
        #expect(fiveK.headline.fr.hasPrefix("2e meilleur"))
        let previous = try #require(fiveK.previousBest)
        #expect(previous < fiveK.effort.duration)
    }

    @Test("Une activité ne se bat jamais contre elle-même")
    func anActivityIsNotItsOwnRival() throws {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let run = activity(paced([(6_000, 240)]), at: day)

        // L'historique la contient déjà : c'est le cas réel, puisqu'on
        // enregistre avant d'analyser. Elle doit rester un record.
        let ranks = BestEfforts.ranks(for: run, against: [run])
        let fiveK = try #require(ranks.first { $0.effort.distance == .fiveKilometres })
        #expect(fiveK.rank == 1)
        #expect(fiveK.previousBest == nil)
    }

    @Test("Le vélo n'a pas de record de distance")
    func ridesHaveNoDistanceRecords() {
        let ride = activity(paced([(20_000, 120)]), sport: .ride)
        #expect(BestEfforts.efforts(in: ride).isEmpty)
        #expect(BestEfforts.ranks(for: ride, against: []).isEmpty)
    }

    @Test("Les distinctions mises en avant restent lisibles")
    func highlightsStayReadable() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let history = (0..<10).map { index in
            activity(paced([(6_000, 240 + Double(index))]), at: day.addingTimeInterval(Double(index) * 86_400))
        }
        // Une sortie franchement plus lente que les dix précédentes.
        let slow = activity(paced([(6_000, 300)]), at: day.addingTimeInterval(1_000_000))
        #expect(BestEfforts.highlights(for: slow, against: history).isEmpty,
                "une mauvaise sortie n'annonce rien du tout")

        let fast = activity(paced([(6_000, 200)]), at: day.addingTimeInterval(2_000_000))
        let highlights = BestEfforts.highlights(for: fast, against: history)
        #expect(highlights.count <= 3)
        #expect(highlights.allSatisfy { $0.rank <= 3 })
        // La plus longue distance en tête : un record sur 5 km vaut mieux
        // qu'un record sur 400 m glané dedans.
        let distances = highlights.map(\.effort.distance.meters)
        #expect(distances == distances.sorted(by: >))
    }

    @Test("Les efforts sont calculés une fois et rangés dans l'activité")
    func effortsAreStoredNotRecomputed() throws {
        let run = activity(paced([(6_000, 240)]))
        let stored = try #require(run.bestEfforts)
        #expect(!stored.isEmpty, "une sortie de 6 km contient au moins un 5 km")

        // Une activité sans efforts calculés (fichier d'une version
        // antérieure) doit encore savoir les retrouver.
        var legacy = run
        legacy.bestEfforts = nil
        #expect(BestEfforts.efforts(in: legacy).count == stored.count)

        // Et une sortie vélo garde un tableau vide, pas un nil : sans cette
        // distinction on la recalculerait indéfiniment pour rien.
        let ride = activity(paced([(20_000, 120)]), sport: .ride)
        #expect(ride.bestEfforts == [])
    }

    @Test("Les efforts rangés survivent à un aller-retour sur le disque")
    func storedEffortsRoundTrip() throws {
        let run = activity(paced([(6_000, 240)]))
        let data = try StateStorage.encoder.encode(run)
        let back = try StateStorage.decoder.decode(ActivityLog.self, from: data)
        #expect(back.bestEfforts == run.bestEfforts)
    }

    @Test("Les records de l'athlète sont les meilleurs de tout l'historique")
    func recordsSpanTheWholeHistory() throws {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let long = activity(paced([(12_000, 250)]), at: day)
        let short = activity(paced([(3_000, 200)]), at: day.addingTimeInterval(86_400))

        let records = BestEfforts.records(in: [long, short])
        let oneK = try #require(records.first { $0.distance == .oneKilometre })
        let tenK = try #require(records.first { $0.distance == .tenKilometres })

        #expect(oneK.activityID == short.id, "le meilleur kilomètre vient de la sortie rapide")
        #expect(tenK.activityID == long.id, "le 10 km ne peut venir que de la longue")
        #expect(!records.contains { $0.distance == .marathon })
    }
}
