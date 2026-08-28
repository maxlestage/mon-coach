import Foundation
import Testing
@testable import MonCoachKit

// Un repère métrique local : x vers l'est, y vers le nord, en mètres depuis
// un point de Paris. Raisonner en mètres rend les cas de test lisibles —
// « la route parallèle est à 150 m » plutôt que « à 0,00135 degré ».
private let originLatitude = 48.85
private let originLongitude = 2.35
private let metersPerDegreeLatitude = 111_320.0
private let metersPerDegreeLongitude = 111_320.0 * cos(48.85 * .pi / 180)

private func coordinate(x: Double, y: Double) -> (latitude: Double, longitude: Double) {
    (originLatitude + y / metersPerDegreeLatitude, originLongitude + x / metersPerDegreeLongitude)
}

/// Parcourt une ligne brisée à vitesse constante, un point tous les `step`.
private func path(
    _ waypoints: [(x: Double, y: Double)],
    speed: Double = 3.0,
    step: Double = 10,
    climbPerMeter: Double = 0,
    start: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> [GPSPoint] {
    var points: [GPSPoint] = []
    var travelled = 0.0

    func emit(x: Double, y: Double) {
        let position = coordinate(x: x, y: y)
        points.append(
            GPSPoint(
                timestamp: start.addingTimeInterval(travelled / speed),
                latitude: position.latitude,
                longitude: position.longitude,
                altitude: 100 + travelled * climbPerMeter,
                horizontalAccuracy: 5,
                verticalAccuracy: 5
            )
        )
    }

    emit(x: waypoints[0].x, y: waypoints[0].y)
    for index in 1..<waypoints.count {
        let from = waypoints[index - 1]
        let to = waypoints[index]
        let length = ((to.x - from.x) * (to.x - from.x) + (to.y - from.y) * (to.y - from.y)).squareRoot()
        var covered = 0.0
        while covered < length {
            covered = min(length, covered + step)
            travelled += min(step, length - (covered - step))
            let ratio = covered / length
            emit(x: from.x + (to.x - from.x) * ratio, y: from.y + (to.y - from.y) * ratio)
        }
    }
    return points
}

private func activity(
    _ points: [GPSPoint],
    sport: Sport = .run,
    at date: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> ActivityLog {
    var log = TraceAnalysis.summarise(rawPoints: points, sport: sport, type: .easy)
    log.startedAt = date
    return log
}

@Suite("Segments personnels")
struct SegmentTests {

    /// Une route droite de 2 km vers l'est, et le segment qui en couvre le
    /// deuxième kilomètre.
    private func straightRoadSegment() throws -> (segment: Segment, source: ActivityLog) {
        let source = activity(path([(0, 0), (2_000, 0)]))
        let segment = try #require(
            SegmentMatching.carve(from: source, name: "Ligne droite", startMeters: 1_000, endMeters: 2_000)
        )
        return (segment, source)
    }

    @Test("Un segment se découpe et garde sa longueur")
    func carvingKeepsLength() throws {
        let (segment, source) = try straightRoadSegment()
        #expect(abs(segment.meters - 1_000) < 30)
        #expect(segment.sport == .run)
        #expect(segment.sourceActivityID == source.id)
        #expect(segment.points.count > 50)
    }

    @Test("Un segment trop court est refusé")
    func tinySegmentsAreRefused() {
        let source = activity(path([(0, 0), (2_000, 0)]))
        #expect(SegmentMatching.carve(from: source, name: "Trente mètres",
                                      startMeters: 100, endMeters: 130) == nil)
    }

    @Test("Le même parcours, un autre jour, est reconnu et chronométré")
    func sameRoadIsRecognised() throws {
        let (segment, _) = try straightRoadSegment()
        // Le lendemain, la même route mais plus vite : 4 m/s au lieu de 3.
        let later = activity(path([(0, 0), (2_000, 0)], speed: 4))

        let efforts = SegmentMatching.efforts(of: segment, in: later)
        #expect(efforts.count == 1)
        let effort = try #require(efforts.first)
        // 1 000 m à 4 m/s : 250 s.
        #expect(abs(effort.duration - 250) < 8, "le chrono doit tenir à quelques secondes")
        #expect(abs(effort.startMeters - 1_000) < 40)
    }

    @Test("Le sens compte : descendre la côte ne valide pas le segment qui la monte")
    func oppositeDirectionIsNotAMatch() throws {
        let (segment, _) = try straightRoadSegment()
        // Exactement la même route, parcourue en sens inverse.
        let backwards = activity(path([(2_000, 0), (0, 0)]))

        #expect(SegmentMatching.efforts(of: segment, in: backwards).isEmpty)
    }

    @Test("Une route parallèle n'est pas le même segment")
    func parallelRoadIsNotAMatch() throws {
        let (segment, _) = try straightRoadSegment()
        // Cent cinquante mètres au nord : le trottoir d'en face, non ; une
        // autre rue, oui. Bien au-delà du couloir de vingt-cinq mètres.
        let elsewhere = activity(path([(0, 150), (2_000, 150)]))

        #expect(SegmentMatching.efforts(of: segment, in: elsewhere).isEmpty)
    }

    @Test("Un détour au milieu du segment invalide le passage")
    func detourBreaksTheMatch() throws {
        let (segment, _) = try straightRoadSegment()
        // Départ et arrivée au bon endroit, mais un crochet de 120 m au
        // milieu : les extrémités seules ne suffisent pas à valider.
        let detour = activity(path([(0, 0), (1_300, 0), (1_500, 120), (1_700, 0), (2_000, 0)]))

        #expect(SegmentMatching.efforts(of: segment, in: detour).isEmpty)
    }

    @Test("Trois tours de boucle donnent trois passages")
    func repeatedLapsCountSeparately() throws {
        // Une boucle rectangulaire de 400 × 200 m, dont le côté nord porte
        // le segment.
        let lap: [(x: Double, y: Double)] = [(0, 0), (400, 0), (400, 200), (0, 200), (0, 0)]
        let single = activity(path(lap))
        let segment = try #require(
            SegmentMatching.carve(from: single, name: "Le côté nord", startMeters: 620, endMeters: 980)
        )

        let three = activity(path(lap + lap.dropFirst() + lap.dropFirst()))
        let efforts = SegmentMatching.efforts(of: segment, in: three)

        #expect(efforts.count == 3, "chaque tour doit compter")
        let durations = efforts.map(\.duration)
        #expect(durations.allSatisfy { abs($0 - durations[0]) < 5 }, "les trois tours sont identiques")
        // Et les passages se suivent, sans se chevaucher.
        let starts = efforts.map(\.startMeters).sorted()
        #expect(starts == efforts.map(\.startMeters))
        #expect(starts[1] - starts[0] > 1_000)
    }

    @Test("Un segment de course ne se cherche pas dans une sortie vélo")
    func sportsDoNotMix() throws {
        let (segment, _) = try straightRoadSegment()
        let ride = activity(path([(0, 0), (2_000, 0)], speed: 8), sport: .ride)
        #expect(SegmentMatching.efforts(of: segment, in: ride).isEmpty)
    }

    @Test("Le classement range les passages du plus rapide au plus lent")
    func leaderboardIsSorted() throws {
        let (segment, _) = try straightRoadSegment()
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let activities = [3.0, 4.0, 3.5].enumerated().map { index, speed in
            activity(path([(0, 0), (2_000, 0)], speed: speed),
                     at: day.addingTimeInterval(Double(index) * 86_400))
        }

        let board = SegmentMatching.leaderboard(of: segment, in: activities)
        #expect(board.count == 3)
        #expect(board.map(\.duration) == board.map(\.duration).sorted())
        // Le plus rapide est bien celui couru à 4 m/s.
        #expect(abs(board[0].duration - 250) < 8)
    }

    @Test("Une sortie qui ne passe pas par là ne produit rien")
    func unrelatedActivityYieldsNothing() throws {
        let (segment, _) = try straightRoadSegment()
        let elsewhere = activity(path([(5_000, 5_000), (7_000, 5_000)]))
        #expect(SegmentMatching.efforts(of: segment, in: elsewhere).isEmpty)
    }

    @Test("Le couloir refuse un parcours suivi à l'envers")
    func corridorRejectsReverseTraversal() throws {
        // Le test « sens inverse » plus haut s'arrête plus tôt : sur une
        // ligne droite parcourue à l'envers, l'arrivée du segment est
        // atteinte avant son départ et aucun couple entrée/sortie ne se
        // forme. Le contrôle de sens du couloir n'est donc jamais sollicité
        // par ce chemin-là — on l'éprouve ici directement, sinon il resterait
        // du code défensif que rien ne vérifie.
        let source = activity(path([(0, 0), (2_000, 0)]))
        let segment = try #require(
            SegmentMatching.carve(from: source, name: "Ligne droite", startMeters: 1_000, endMeters: 2_000)
        )
        let backwards = activity(path([(2_000, 0), (0, 0)]))
        let trace = TraceAnalysis.clean(backwards.points, filter: Sport.run.filter)
        let grid = GeoGrid(
            points: trace.samples.map { ($0.point.latitude, $0.point.longitude) },
            cellMeters: 25
        )

        // Les points de contrôle du segment sont géographiquement tous dans
        // le couloir de la trace inverse : seule la progression les distingue.
        let followed = SegmentMatching.follows(
            checkpoints: segment.points,
            samples: trace.samples,
            grid: grid,
            between: 0,
            and: trace.samples.count - 1,
            tolerance: .default
        )
        #expect(!followed, "parcouru à l'envers, le couloir doit être refusé")

        // Et à l'endroit, il est accepté : sans ce second contrôle, le
        // premier ne prouverait rien.
        let forward = TraceAnalysis.clean(source.points, filter: Sport.run.filter)
        let forwardGrid = GeoGrid(
            points: forward.samples.map { ($0.point.latitude, $0.point.longitude) },
            cellMeters: 25
        )
        #expect(
            SegmentMatching.follows(
                checkpoints: segment.points,
                samples: forward.samples,
                grid: forwardGrid,
                between: 0,
                and: forward.samples.count - 1,
                tolerance: .default
            )
        )
    }

    @Test("Plusieurs segments se cherchent en une seule lecture de la trace")
    func batchMatchingFindsTheSameThings() throws {
        let source = activity(path([(0, 0), (3_000, 0)]))
        let first = try #require(
            SegmentMatching.carve(from: source, name: "Premier", startMeters: 200, endMeters: 1_000)
        )
        let second = try #require(
            SegmentMatching.carve(from: source, name: "Second", startMeters: 1_500, endMeters: 2_600)
        )
        let later = activity(path([(0, 0), (3_000, 0)], speed: 3.5))

        let batch = SegmentMatching.efforts(of: [first, second], in: later)
        let oneByOne = SegmentMatching.efforts(of: first, in: later)
            + SegmentMatching.efforts(of: second, in: later)

        #expect(batch.count == 2)
        #expect(Set(batch.map(\.id)) == Set(oneByOne.map(\.id)))
    }

    @Test("Le meilleur passage de chaque segment est retenu")
    func personalBestsAreKept() throws {
        let (segment, _) = try straightRoadSegment()
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let activities = [3.0, 4.2, 3.4].enumerated().map { index, speed in
            activity(path([(0, 0), (2_000, 0)], speed: speed),
                     at: day.addingTimeInterval(Double(index) * 86_400))
        }

        let bests = SegmentMatching.personalBests(of: [segment], in: activities)
        let best = try #require(bests[segment.id])
        #expect(abs(best.duration - 1_000 / 4.2) < 8, "le passage le plus rapide")
    }

    @Test("La pente du segment est calculée")
    func gradeIsComputed() throws {
        // 1 km de segment sur une route qui monte de 5 % : 50 m de D+.
        let source = activity(path([(0, 0), (2_000, 0)], climbPerMeter: 0.05))
        let segment = try #require(
            SegmentMatching.carve(from: source, name: "La côte", startMeters: 1_000, endMeters: 2_000)
        )
        #expect(abs(segment.elevationGain - 50) < 6)
        #expect(abs(segment.gradePercent - 5) < 0.6)
    }
}
