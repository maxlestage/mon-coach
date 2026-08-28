import Foundation
import Testing
@testable import MonCoachKit

/// Fabrique une trace régulière : un point par seconde, à vitesse constante,
/// cap plein est, avec une pente donnée.
private func trace(
    speedMetersPerSecond speed: Double,
    seconds: Int,
    climbPerSecond: Double = 0,
    accuracy: Double = 5,
    start: Date = Date(timeIntervalSince1970: 1_700_000_000)
) -> [GPSPoint] {
    // À cette latitude un degré de longitude vaut environ 74 700 m.
    let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
    return (0...seconds).map { index in
        GPSPoint(
            timestamp: start.addingTimeInterval(Double(index)),
            latitude: 48.85,
            longitude: 2.35 + (Double(index) * speed) / metersPerDegree,
            altitude: 100 + Double(index) * climbPerSecond,
            horizontalAccuracy: accuracy,
            verticalAccuracy: 5
        )
    }
}

@Suite("Multi-sport")
struct SportTests {

    @Test("Une randonnée en montée n'est pas prise pour un arrêt")
    func hikeUphillIsNotAPause() {
        // 1,3 km/h, soit 0,36 m/s : le pas d'un randonneur dans une pente
        // raide. C'est en dessous du seuil de pause de la course.
        let points = trace(speedMetersPerSecond: 0.36, seconds: 1_800, climbPerSecond: 0.15)

        let asRun = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let asHike = TraceAnalysis.clean(points, filter: Sport.hike.filter)

        #expect(asRun.meters < 10, "le filtre de la course efface la randonnée")
        #expect(asHike.meters > 600, "la randonnée doit garder sa distance")
        #expect(asHike.movingDuration > 1_700)
        // 0,15 m/s pendant 1 800 s : 270 m de dénivelé.
        #expect(abs(asHike.elevationGain - 270) < 15)
    }

    @Test("Une descente à vélo n'est pas prise pour un saut de GPS")
    func fastDescentSurvives() {
        // 65 km/h : plausible en descente, impossible à pied.
        let points = trace(speedMetersPerSecond: 18, seconds: 120, climbPerSecond: -0.5)

        let asRun = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let asRide = TraceAnalysis.clean(points, filter: Sport.ride.filter)

        #expect(asRun.rejectedForSpeed > 100, "à pied, ces points sont impossibles")
        #expect(asRun.meters < 100)
        #expect(abs(asRide.meters - 2_160) < 60, "à vélo, la descente est réelle")
        #expect(asRide.rejectedForSpeed == 0)
    }

    @Test("Chaque sport garde son propre seuil de pause et de précision")
    func filtersDiffer() {
        let pauses = Set(Sport.allCases.map(\.filter.pauseSpeed))
        #expect(pauses.count >= 3, "trois sports au moins doivent différer")
        #expect(Sport.hike.filter.pauseSpeed < Sport.run.filter.pauseSpeed)
        #expect(Sport.ride.filter.maxSpeed > Sport.run.filter.maxSpeed)
        #expect(Sport.trail.filter.maxHorizontalAccuracy > Sport.run.filter.maxHorizontalAccuracy)
    }

    @Test("Seules la course et le trail nourrissent le plan de course")
    func onlyFootRunningFeedsThePlan() {
        #expect(Sport.run.feedsRunningPlan)
        #expect(Sport.trail.feedsRunningPlan)
        #expect(!Sport.ride.feedsRunningPlan)
        #expect(!Sport.walk.feedsRunningPlan)
        #expect(!Sport.hike.feedsRunningPlan)
    }

    @Test("Une sortie vélo ne gonfle pas le kilométrage hebdomadaire")
    func rideDoesNotInflateWeeklyVolume() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        let run = ActivityLog(
            startedAt: day, sport: .run, type: .easy,
            meters: 8_000, duration: 2_600, elevationGain: 20
        )
        let ride = ActivityLog(
            startedAt: day, sport: .ride, type: .easy,
            meters: 60_000, duration: 7_200, elevationGain: 400
        )
        let history = TrainingHistory(activities: [run, ride])

        #expect(history.activities.count == 2, "le vélo reste dans l'historique")
        #expect(history.runs.count == 1, "mais pas dans ce que lit le plan")
        #expect(history.weeklyRunMeters(endingOn: day) == 8_000)
    }

    @Test("Une moyenne à vélo ne devient jamais une allure de seuil")
    func rideNeverSetsThresholdPace() {
        let day = Date(timeIntervalSince1970: 1_700_000_000)
        // 40 km en une heure : 1:30/km. Pris pour une allure de seuil, tout
        // le plan deviendrait injouable.
        let ride = ActivityLog(
            startedAt: day, sport: .ride, type: .tempo,
            meters: 40_000, duration: 3_600, elevationGain: 100
        )
        #expect(TrainingHistory(activities: [ride]).demonstratedThresholdPace() == nil)

        // Et un trail non plus : mille mètres de D+ ne disent rien de la route.
        let trail = ActivityLog(
            startedAt: day, sport: .trail, type: .tempo,
            meters: 12_000, duration: 5_400, elevationGain: 900
        )
        #expect(TrainingHistory(activities: [trail]).demonstratedThresholdPace() == nil)
    }

    @Test("Le coût du vélo suit la vitesse, celui de la course la distance")
    func energyModelsDiffer() {
        let weight = 75.0
        // Même distance, deux vitesses : à pied le coût ne bouge pas.
        let runSlow = TraceMath.energyKcal(
            sport: .run, meters: 10_000, movingSeconds: 3_600, elevationGain: 0, weightKg: weight
        )
        let runFast = TraceMath.energyKcal(
            sport: .run, meters: 10_000, movingSeconds: 2_400, elevationGain: 0, weightKg: weight
        )
        #expect(abs(runSlow - runFast) < 0.01, "le coût de la course est indépendant de l'allure")

        // À vélo, le même parcours coûte plus cher quand on va plus vite.
        // L'écart total reste modeste — on roule moins longtemps — mais le
        // coût au kilomètre, lui, monte franchement. Les MET du Compendium
        // sont mesurés sur de vrais cyclistes : ils donnent le sens de la
        // variation, pas la loi en cube de la traînée.
        let rideSlow = TraceMath.energyKcal(
            sport: .ride, meters: 30_000, movingSeconds: 5_400, elevationGain: 0, weightKg: weight
        )
        let rideFast = TraceMath.energyKcal(
            sport: .ride, meters: 30_000, movingSeconds: 3_600, elevationGain: 0, weightKg: weight
        )
        #expect(rideFast > rideSlow, "à vélo, la vitesse coûte")
        #expect(rideFast / rideSlow > 1.08, "et elle coûte de façon visible")

        // Et le vélo reste très en dessous de la course sur la même distance.
        let run30 = TraceMath.energyKcal(
            sport: .run, meters: 30_000, movingSeconds: 10_800, elevationGain: 0, weightKg: weight
        )
        #expect(rideSlow < run30 * 0.6, "30 km à vélo coûtent moins que 30 km à pied")

        // La marche coûte environ la moitié de la course.
        let walk = TraceMath.energyKcal(
            sport: .walk, meters: 10_000, movingSeconds: 7_200, elevationGain: 0, weightKg: weight
        )
        #expect(walk > runSlow * 0.4 && walk < runSlow * 0.65)
    }

    @Test("Le MET du cycliste est continu : pas de marche d'escalier")
    func cyclingMETIsContinuous() {
        for speed in stride(from: 5.0, through: 34.0, by: 0.1) {
            let here = TraceMath.cyclingMET(speedKmh: speed)
            let next = TraceMath.cyclingMET(speedKmh: speed + 0.1)
            #expect(next >= here, "le MET ne doit jamais redescendre")
            #expect(next - here < 0.2, Comment(rawValue: "saut à \(speed) km/h"))
        }
    }

    @Test("Un historique écrit avant le multi-sport reste lisible")
    func oldFilesStillDecode() throws {
        // Exactement ce qu'écrivait la version précédente : ni sport, ni
        // dénivelé négatif. Le décodage doit réussir et supposer une course.
        let json = """
        {"runs":[{"duration":2600,"elevationGain":20,"id":"5B9A2C10-0000-4000-8000-000000000001",\
        "meters":8000,"points":[],"splits":[],"startedAt":"2023-11-14T22:13:20Z","type":"easy"}],\
        "bodyLogs":[],"readiness":[],"sessions":[]}
        """
        let history = try StateStorage.decoder.decode(TrainingHistory.self, from: Data(json.utf8))

        #expect(history.activities.count == 1)
        let activity = try #require(history.activities.first)
        #expect(activity.sport == .run, "avant le multi-sport, tout était une course")
        #expect(activity.elevationLoss == 0)
        #expect(activity.meters == 8_000)
    }

    @Test("Le fichier réécrit garde le nom de clé d'origine")
    func storageKeyIsStable() throws {
        let history = TrainingHistory(activities: [
            ActivityLog(startedAt: Date(), sport: .ride, type: .easy,
                        meters: 1_000, duration: 200, elevationGain: 0)
        ])
        let data = try StateStorage.encoder.encode(history)
        let text = try #require(String(data: data, encoding: .utf8))
        // Renommer la clé rendrait illisible tout historique déjà enregistré.
        #expect(text.contains("\"runs\""))
        #expect(!text.contains("\"activities\""))
    }
}
