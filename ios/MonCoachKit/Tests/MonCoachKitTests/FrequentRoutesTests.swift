import Foundation
import Testing
@testable import MonCoachKit

@Suite("Trajets les plus pris")
struct FrequentRoutesTests {

    /// Une trace qui part d'un point et suit un cap, avec le bruit GPS
    /// qu'on a réellement en ville : quelques dizaines de mètres.
    private func trace(
        startLatitude: Double = 48.85,
        startLongitude: Double = 2.35,
        bearingEast: Bool = true,
        kilometres: Double = 5,
        jitterMeters: Double = 0,
        seed: Int = 0
    ) -> [GPSPoint] {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let steps = Int(kilometres * 100)
        var points: [GPSPoint] = []
        var wobble = Double(seed)
        for index in 0..<steps {
            // Dix mètres par pas.
            let advance = Double(index) * 10
            wobble = (wobble * 9_301 + 49_297).truncatingRemainder(dividingBy: 233_280)
            let noise = jitterMeters * (wobble / 233_280 - 0.5) * 2
            let latitudeOffset = (bearingEast ? 0 : advance) / 111_320
            let longitudeOffset = (bearingEast ? advance : 0) / (111_320 * cos(startLatitude * .pi / 180))
            points.append(
                GPSPoint(
                    timestamp: start.addingTimeInterval(Double(index) * 5),
                    latitude: startLatitude + latitudeOffset + noise / 111_320,
                    longitude: startLongitude + longitudeOffset,
                    altitude: 30
                )
            )
        }
        return points
    }

    private func activity(
        _ points: [GPSPoint],
        daysAgo: Int,
        sport: Sport = .run,
        minutes: Double = 25
    ) -> ActivityLog {
        ActivityLog(
            startedAt: Date(timeIntervalSince1970: 1_780_000_000 - Double(daysAgo) * 86_400),
            sport: sport,
            type: .easy,
            points: points,
            meters: 5_000,
            duration: minutes * 60,
            elevationGain: 20
        )
    }

    @Test("Le même tour refait trois fois devient un trajet")
    func repeatedRouteIsFound() {
        // Trois fois le même parcours, avec le bruit GPS d'un jour à
        // l'autre : ce n'est pas trois parcours différents.
        let logs = (0..<3).map { index in
            activity(trace(jitterMeters: 25, seed: index * 7 + 1), daysAgo: index * 3)
        }
        let routes = FrequentRoutes.find(in: logs)
        #expect(routes.count == 1, "\(routes.count) trajets pour un seul tour refait")
        #expect(routes.first?.timesDone == 3)
        #expect(routes.first?.activityIDs.count == 3)
        #expect(routes.first?.points.isEmpty == false, "un trajet doit pouvoir se dessiner")
    }

    @Test("Deux fois ne fait pas une habitude")
    func twiceIsNotAHabit() {
        let logs = (0..<2).map { index in
            activity(trace(jitterMeters: 20, seed: index + 1), daysAgo: index)
        }
        #expect(FrequentRoutes.find(in: logs).isEmpty)
    }

    @Test("Deux parcours différents restent deux trajets")
    func differentRoutesStayApart() {
        var logs = (0..<3).map { index in
            activity(trace(bearingEast: true, jitterMeters: 15, seed: index), daysAgo: index * 2)
        }
        logs += (0..<3).map { index in
            activity(trace(bearingEast: false, jitterMeters: 15, seed: index + 40), daysAgo: index * 2 + 1)
        }
        let routes = FrequentRoutes.find(in: logs)
        #expect(routes.count == 2, "un tour vers l'est et un vers le nord ne sont pas le même")
        #expect(routes.allSatisfy { $0.timesDone == 3 })
    }

    @Test("Une sortie deux fois plus longue n'est pas le même trajet")
    func lengthMattersEvenWhenContained() {
        // Le petit parcours est entièrement contenu dans le grand : sans
        // condition de longueur, ils seraient confondus et la boucle de
        // dix kilomètres compterait les jours où l'on n'en a fait que cinq.
        var logs = (0..<3).map { index in
            activity(trace(kilometres: 5, jitterMeters: 10, seed: index), daysAgo: index * 2)
        }
        logs += (0..<3).map { index in
            activity(trace(kilometres: 12, jitterMeters: 10, seed: index + 20), daysAgo: index * 2 + 1)
        }
        let routes = FrequentRoutes.find(in: logs)
        #expect(routes.count == 2)
    }

    @Test("Un vélo et une course sur la même route sont deux trajets")
    func sportSeparatesRoutes() {
        var logs = (0..<3).map { index in
            activity(trace(jitterMeters: 10, seed: index), daysAgo: index * 2, sport: .run)
        }
        logs += (0..<3).map { index in
            activity(trace(jitterMeters: 10, seed: index), daysAgo: index * 2 + 1, sport: .ride)
        }
        let routes = FrequentRoutes.find(in: logs)
        #expect(routes.count == 2, "les allures et les records n'y sont pas comparables")
        #expect(Set(routes.map(\.sport)) == [.run, .ride])
    }

    @Test("Le trajet retient le meilleur temps et le dernier")
    func timesAreTracked() throws {
        let logs = [
            activity(trace(jitterMeters: 10, seed: 1), daysAgo: 10, minutes: 30),
            activity(trace(jitterMeters: 10, seed: 2), daysAgo: 5, minutes: 24),
            activity(trace(jitterMeters: 10, seed: 3), daysAgo: 1, minutes: 26),
        ]
        let route = try #require(FrequentRoutes.find(in: logs).first)
        #expect(route.bestSeconds == 1_440)
        #expect(route.lastSeconds == 1_560)
        #expect(!route.lastWasBest)
        #expect(route.activityIDs.first == logs[2].id, "la plus récente en tête")
    }

    @Test("Les sorties sans trace ne fabriquent pas de trajet")
    func untracedActivitiesAreIgnored() {
        let indoor = (0..<4).map { index in
            ActivityLog(
                startedAt: Date(timeIntervalSince1970: 1_780_000_000 - Double(index) * 86_400),
                sport: .rowingMachine, type: .easy, points: [],
                meters: 0, duration: 1_800, elevationGain: 0
            )
        }
        #expect(FrequentRoutes.find(in: indoor).isEmpty)
    }

    @Test("Une coordonnée aberrante ne fait pas tomber la reconnaissance")
    func garbageCoordinatesAreSurvivable() {
        // Ces valeurs existent dans des GPX réels, écrits par des appareils
        // en panne de fix. Un dépassement d'entier arrêterait l'application.
        var poisoned = trace(jitterMeters: 5, seed: 3)
        poisoned.append(GPSPoint(timestamp: Date(), latitude: .nan, longitude: .infinity))
        poisoned.append(
            GPSPoint(
                timestamp: Date(),
                latitude: .greatestFiniteMagnitude,
                longitude: -.greatestFiniteMagnitude
            )
        )
        let logs = (0..<3).map { index in
            activity(index == 0 ? poisoned : trace(jitterMeters: 5, seed: index), daysAgo: index * 2)
        }
        let routes = FrequentRoutes.find(in: logs)
        #expect(routes.count >= 1)
    }

    @Test("Le nom proposé dit la vérité, et rien de plus")
    func suggestedNameStaysHonest() {
        let logs = (0..<3).map { index in
            activity(trace(jitterMeters: 10, seed: index), daysAgo: index * 2)
        }
        let route = FrequentRoutes.find(in: logs).first!
        let name = FrequentRoutes.suggestedName(for: route, language: .french)
        #expect(name.contains("5"), "la distance doit y être : \(name)")
        #expect(name.contains("km"))
        // Une trace en ligne droite n'est pas une boucle.
        #expect(!FrequentRoutes.isLoop(route.points))
        #expect(!FrequentRoutes.suggestedName(for: route, language: .english).isEmpty)
        #expect(!FrequentRoutes.suggestedName(for: route, language: .spanish).isEmpty)
    }
}
