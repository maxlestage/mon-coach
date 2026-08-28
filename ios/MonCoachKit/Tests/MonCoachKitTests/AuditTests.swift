import Foundation
import Testing
@testable import MonCoachKit

/// Ce que la relecture a rattrapé. Chaque test ici correspond à un défaut
/// réel trouvé en vérifiant le travail, pas à une hypothèse.
@Suite("Relecture")
struct AuditTests {

    @Test("La vitesse est dite dans l'unité du sport")
    func speedIsSpokenInTheRightUnit() {
        // 30 km en une heure.
        let ride = Format.speedOrPace(
            sport: .ride, meters: 30_000, seconds: 3_600, unit: .metric
        )
        #expect(ride.contains("km/h"))
        #expect(!ride.contains("/km"), "un cycliste ne lit jamais une allure au kilomètre")

        let run = Format.speedOrPace(
            sport: .run, meters: 10_000, seconds: 3_000, unit: .metric
        )
        #expect(run.contains("/km"))
        #expect(run.hasPrefix("5:00"))

        // Marche et randonnée se lisent comme la course.
        for sport in [Sport.walk, .hike, .trail] {
            let text = Format.speedOrPace(sport: sport, meters: 5_000, seconds: 3_600, unit: .metric)
            #expect(text.contains("/km"), Comment(rawValue: "\(sport.rawValue) doit se lire en allure"))
        }
    }

    @Test("Les deux entrées de vitesse s'accordent")
    func bothEntryPointsAgree() {
        // 4:00/km, dit à partir des distances ou de l'allure déjà calculée.
        for sport in Sport.allCases {
            let fromDistance = Format.speedOrPace(
                sport: sport, meters: 10_000, seconds: 2_400, unit: .metric
            )
            let fromPace = Format.speedOrPace(
                sport: sport, secondsPerKm: 240, unit: .metric
            )
            #expect(fromDistance == fromPace, Comment(rawValue: "désaccord pour \(sport.rawValue)"))
        }
    }

    @Test("Une coordonnée aberrante ne fait pas tomber l'index spatial")
    func gridSurvivesGarbageCoordinates() {
        // Un GPX importé ne vient pas de nous : ces valeurs existent dans
        // des fichiers réels, écrits par des appareils en panne de fix.
        let poison: [(latitude: Double, longitude: Double)] = [
            (48.85, 2.35),
            (.greatestFiniteMagnitude, .greatestFiniteMagnitude),
            (-.greatestFiniteMagnitude, 0),
            (.nan, .nan),
            (.infinity, -.infinity),
            (1e300, -1e300),
        ]
        let grid = GeoGrid(points: poison, cellMeters: 25)
        // Le seul contrat qui compte : ça ne s'arrête pas brutalement, et le
        // point valide se retrouve.
        #expect(grid.candidates(latitude: 48.85, longitude: 2.35).contains(0))
        _ = grid.candidates(latitude: .nan, longitude: .nan)
        _ = grid.candidates(latitude: 1e300, longitude: 1e300)
    }

    @Test("Un effort rangé suit la date corrigée de son activité")
    func storedEffortFollowsTheActivityDate() throws {
        let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var points: [GPSPoint] = []
        for index in 0...600 {
            points.append(
                GPSPoint(
                    timestamp: start.addingTimeInterval(Double(index) * 4),
                    latitude: 48.85,
                    longitude: 2.35 + Double(index) * 10 / metersPerDegree,
                    altitude: 100
                )
            )
        }
        var activity = TraceAnalysis.summarise(rawPoints: points, sport: .run, type: .easy)
        let corrected = start.addingTimeInterval(-3_600)
        activity.startedAt = corrected

        let efforts = BestEfforts.efforts(in: activity)
        #expect(!efforts.isEmpty)
        #expect(efforts.allSatisfy { $0.date == corrected },
                "un effort rangé ne doit pas garder une date que l'activité n'a plus")
    }

    @Test("Enregistrer une trace ne détruit pas un point sur deux")
    func savingKeepsSubSecondTimestamps() throws {
        // Une montre échantillonne à deux hertz. Écrite en ISO 8601 sans
        // fraction, la trace ressortait avec un point sur deux portant
        // l'horodatage de son voisin : intervalle nul, points jetés comme
        // « non croissants », et un indicateur de rétention annonçant 50 %
        // de rejets dont le GPS n'était pas responsable.
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
        let points = (0..<400).map { index -> GPSPoint in
            let seconds = Double(index) * 0.5
            return GPSPoint(
                timestamp: start.addingTimeInterval(seconds),
                latitude: 48.85,
                longitude: 2.35 + (seconds * 3.0) / metersPerDegree,
                altitude: 100
            )
        }
        let before = TraceAnalysis.summarise(rawPoints: points, sport: .run, type: .easy)

        let data = try StateStorage.encoder.encode(before)
        let after = try StateStorage.decoder.decode(ActivityLog.self, from: data)

        #expect(after.points == before.points, "la trace doit revenir intacte")
        let trace = TraceAnalysis.clean(after.points)
        #expect(trace.rejectedForOrder == 0, "aucun point ne doit devenir simultané à son voisin")
        #expect(trace.retention == 1.0)
    }

    @Test("La montre transmet aussi ses fractions de seconde")
    func watchTransferKeepsSubSecondTimestamps() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000.25)
        let log = ActivityLog(
            startedAt: start, sport: .run, type: .easy,
            points: [
                GPSPoint(timestamp: start, latitude: 48.85, longitude: 2.35),
                GPSPoint(timestamp: start.addingTimeInterval(0.5), latitude: 48.85, longitude: 2.3501),
            ],
            meters: 700, duration: 200, elevationGain: 0
        )
        let data = try WatchSyncCodec.encode(log)
        let back = try WatchSyncCodec.decodeRunLog(data)
        #expect(back.points == log.points)
        #expect(back.startedAt == start)
    }

    @Test("Une date écrite sans fraction reste lisible")
    func datesWithoutFractionStillParse() throws {
        // Le format d'avant. Refuser de le lire mettrait de côté tout
        // l'historique déjà enregistré.
        let json = """
        {"bodyLogs":[],"readiness":[],"runs":[{"duration":2600,"elevationGain":20,        "id":"5B9A2C10-0000-4000-8000-000000000001","meters":8000,"points":[],"splits":[],        "startedAt":"2023-11-14T22:13:20Z","type":"easy"}],"sessions":[]}
        """
        let history = try StateStorage.decoder.decode(TrainingHistory.self, from: Data(json.utf8))
        let activity = try #require(history.activities.first)
        #expect(activity.startedAt == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test("L'état complet fait l'aller-retour, segments compris")
    func persistedStateRoundTrips() throws {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let activity = ActivityLog(
            startedAt: day, sport: .hike, type: .easy,
            meters: 9_000, duration: 12_000, elevationGain: 700, elevationLoss: 700
        )
        let segment = Segment(
            name: "Col des Aravis",
            sport: .hike,
            points: [
                GPSPoint(timestamp: day, latitude: 45.87, longitude: 6.47, altitude: 1_200),
                GPSPoint(timestamp: day.addingTimeInterval(600), latitude: 45.88, longitude: 6.48, altitude: 1_450),
            ],
            meters: 1_400,
            elevationGain: 250,
            createdAt: day,
            sourceActivityID: activity.id
        )
        let state = PersistedState(
            profile: nil, plan: nil,
            history: TrainingHistory(activities: [activity]),
            segments: [segment]
        )

        let data = try StateStorage.encoder.encode(state)
        let back = try StateStorage.decoder.decode(PersistedState.self, from: data)

        #expect(back.segments == [segment])
        #expect(back.history.activities == [activity])
        #expect(back.history.activities.first?.elevationLoss == 700)
    }

    @Test("Un état écrit avant les segments reste lisible")
    func stateWithoutSegmentsStillLoads() throws {
        let json = """
        {"history":{"bodyLogs":[],"readiness":[],"runs":[],"sessions":[]}}
        """
        let state = try StateStorage.decoder.decode(PersistedState.self, from: Data(json.utf8))
        #expect(state.segments.isEmpty)
        #expect(state.profile == nil)
    }

    @Test("Le plan de course ne lit que ce qui se court")
    func theRunningPlanOnlyReadsRunning() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let history = TrainingHistory(activities: [
            ActivityLog(startedAt: day, sport: .ride, type: .easy,
                        meters: 60_000, duration: 7_200, elevationGain: 400),
            ActivityLog(startedAt: day, sport: .walk, type: .easy,
                        meters: 5_000, duration: 3_600, elevationGain: 10),
            ActivityLog(startedAt: day.addingTimeInterval(3_600), sport: .run, type: .easy,
                        meters: 8_000, duration: 2_600, elevationGain: 20),
        ])
        #expect(history.runs.count == 1)
        #expect(history.run(on: day)?.sport == .run)
        #expect(history.activity(on: day)?.sport == .run, "la plus récente du jour")
        #expect(history.weeklyRunMeters(endingOn: day) == 8_000)
    }
}
