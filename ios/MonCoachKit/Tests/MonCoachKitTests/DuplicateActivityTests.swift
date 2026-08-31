import Foundation
import Testing
@testable import MonCoachKit

@Suite("Une sortie ne rentre pas deux fois")
@MainActor
struct DuplicateActivityTests {

    private func makeStore() -> CoachStore {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-dup-\(UUID().uuidString).json")
        )
        return CoachStore(storage: storage)
    }

    private func activity(
        at start: Date,
        sport: Sport = .run,
        meters: Double = 10_400,
        minutes: Double = 60,
        points: Int = 0,
        bpm: Double? = nil
    ) -> ActivityLog {
        var log = ActivityLog(
            startedAt: start,
            sport: sport,
            type: .easy,
            points: (0..<points).map {
                GPSPoint(
                    timestamp: start.addingTimeInterval(Double($0)),
                    latitude: 48.85 + Double($0) * 0.0001,
                    longitude: 2.35
                )
            },
            meters: meters,
            duration: minutes * 60,
            elevationGain: 50
        )
        if let bpm {
            log.heartRate = [HeartRateSample(timestamp: start, bpm: bpm)]
        }
        return log
    }

    private var noon: Date { Date(timeIntervalSince1970: 1_780_000_000) }

    @Test("Le même GPX importé deux fois ne fait qu'une sortie")
    func reimportingTheSameFileIsNotADuplicate() throws {
        let store = makeStore()
        let document = GPX.document(for: activity(at: noon, points: 40))

        let first = try store.importGPX(document)
        let second = try store.importGPX(document)

        #expect(store.history.activities.count == 1, "le journal affiche la sortie en double")
        if case .imported = first {} else {
            Issue.record("le premier import doit compter comme une vraie entrée")
        }
        if case .alreadyKnown = second {} else {
            Issue.record("le second doit se dire déjà connu, pas s'annoncer comme une sortie de plus")
        }
    }

    @Test("Les kilomètres d'un doublon ne comptent pas deux fois")
    func duplicatesDoNotInflateVolume() {
        let store = makeStore()
        store.recordRun(activity(at: noon, meters: 10_400))
        // La même sortie, remontée par un autre chemin : la montre après le
        // téléphone, avec une mesure très légèrement différente.
        store.recordRun(activity(at: noon.addingTimeInterval(30), meters: 10_450))

        #expect(store.history.activities.count == 1)
        #expect(store.history.weeklyRunMeters(endingOn: noon) < 11_000, "les kilomètres sont comptés deux fois")
    }

    @Test("Deux vraies sorties du même jour restent deux sorties")
    func genuinelySeparateOutingsSurvive() {
        let store = makeStore()
        // Un fractionné le matin, un footing le soir : même sport, même
        // distance, et surtout deux vrais entraînements. En effacer un
        // serait effacer du travail réellement fait.
        store.recordRun(activity(at: noon, meters: 10_000))
        store.recordRun(activity(at: noon.addingTimeInterval(8 * 3_600), meters: 10_000))
        #expect(store.history.activities.count == 2)

        // Deux distances franchement différentes au même moment non plus :
        // un aller de cinq kilomètres n'est pas une sortie de vingt.
        store.recordRun(activity(at: noon.addingTimeInterval(60), meters: 5_000))
        #expect(store.history.activities.count == 3)

        // Ni deux sports différents.
        store.recordRun(activity(at: noon, sport: .ride, meters: 10_000))
        #expect(store.history.activities.count == 4)
    }

    @Test("En cas de doublon, on garde la mesure la plus riche")
    func theRicherRecordingWins() {
        let store = makeStore()
        // La trace complète arrive d'abord, puis un import maigre du même
        // parcours : perdre la trace pour garder l'import serait perdre la
        // carte, les segments et les records.
        store.recordRun(activity(at: noon, points: 500, bpm: 150))
        store.recordRun(activity(at: noon.addingTimeInterval(20), points: 3))

        #expect(store.history.activities.count == 1)
        #expect((store.history.activities.first?.points.count ?? 0) == 500)
        #expect(store.history.activities.first?.heartRate.isEmpty == false)

        // Et dans l'autre sens : la trace riche arrivée en second remplace
        // la pauvre, sans perdre ce que celle-ci portait.
        let other = makeStore()
        var thin = activity(at: noon, points: 2)
        thin.perceivedEffort = 7
        thin.note = "Sortie du soir"
        other.recordRun(thin)
        other.recordRun(activity(at: noon.addingTimeInterval(20), points: 400, bpm: 160))

        #expect(other.history.activities.count == 1)
        let kept = other.history.activities.first
        #expect((kept?.points.count ?? 0) == 400, "la trace la plus complète doit gagner")
        #expect(kept?.perceivedEffort == 7, "le ressenti saisi ne doit pas se perdre dans la fusion")
        #expect(kept?.note == "Sortie du soir")
    }

    @Test("Une sortie modifiée puis réenregistrée ne se dédouble pas")
    func editingAnActivityKeepsOneEntry() {
        let store = makeStore()
        var run = activity(at: noon, points: 100)
        store.recordRun(run)
        run.perceivedEffort = 8
        run.note = "Jambes lourdes"
        store.recordRun(run)

        #expect(store.history.activities.count == 1)
        #expect(store.history.activities.first?.perceivedEffort == 8)
        #expect(store.history.activities.first?.note == "Jambes lourdes")
    }

    @Test("Deux séances sans distance au même moment sont la même")
    func untracedSessionsCompareOnTime() {
        let store = makeStore()
        store.recordRun(activity(at: noon, sport: .yoga, meters: 0, minutes: 60))
        store.recordRun(activity(at: noon.addingTimeInterval(45), sport: .yoga, meters: 0, minutes: 60))
        #expect(store.history.activities.count == 1)

        // Mais deux cours à des heures différentes restent deux séances.
        store.recordRun(activity(at: noon.addingTimeInterval(4 * 3_600), sport: .yoga, meters: 0, minutes: 60))
        #expect(store.history.activities.count == 2)
    }

    @Test("Une distance recopiée n'est pas effacée par une remontée sans distance")
    func typedDistanceSurvives() {
        let store = makeStore()
        // Le tapis, avec la distance de la machine saisie sur le téléphone.
        store.recordRun(activity(at: noon, sport: .treadmill, meters: 8_000, minutes: 40))
        // La même séance remontée par la montre, qui ne peut rien mesurer.
        store.recordRun(activity(at: noon.addingTimeInterval(10), sport: .treadmill, meters: 0, minutes: 40))

        #expect(store.history.activities.count == 1)
        #expect(store.history.activities.first?.meters == 8_000)
    }
}

@Suite("Nettoyage d'un journal qui porte déjà des doublons")
@MainActor
struct DuplicateCleanupTests {

    private var noon: Date { Date(timeIntervalSince1970: 1_780_000_000) }

    private func run(at start: Date, meters: Double, points: Int = 0, note: String? = nil) -> ActivityLog {
        ActivityLog(
            startedAt: start, sport: .run, type: .easy,
            points: (0..<points).map {
                GPSPoint(
                    timestamp: start.addingTimeInterval(Double($0)),
                    latitude: 48.85, longitude: 2.35
                )
            },
            meters: meters, duration: 3_600, elevationGain: 0, note: note
        )
    }

    /// Un magasin qui ouvre un fichier d'état déjà écrit.
    ///
    /// C'est le seul chemin réaliste : l'enregistrement refuse désormais un
    /// doublon, donc un journal qui en porte vient forcément du disque —
    /// écrit par une version d'avant la règle. C'est exactement la
    /// situation d'un téléphone qui se met à jour.
    private func storeLoading(_ activities: [ActivityLog]) throws -> CoachStore {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-clean-\(UUID().uuidString).json")
        )
        var history = TrainingHistory()
        history.activities = activities
        try storage.save(PersistedState(profile: nil, plan: nil, history: history))
        return CoachStore(storage: storage)
    }

    @Test("Le doublon déjà enregistré disparaît au lancement, sans rien perdre")
    func existingDuplicatesAreMerged() throws {
        // Deux entrées pour la même sortie, comme un GPX importé deux fois,
        // plus une vraie sortie d'un autre jour qui ne doit pas bouger.
        let store = try storeLoading([
            run(at: noon, meters: 10_400, points: 300),
            run(at: noon.addingTimeInterval(15), meters: 10_400, note: "Jambes lourdes"),
            run(at: noon.addingTimeInterval(86_400), meters: 8_000, points: 200),
        ])
        #expect(store.history.activities.count == 3, "le fichier porte bien le doublon au départ")

        #expect(store.mergeDuplicateActivities() == 1)
        #expect(store.history.activities.count == 2)
        let survivor = store.history.activities.first { $0.startedAt <= self.noon.addingTimeInterval(60) }
        #expect(survivor?.points.count == 300, "la trace complète doit rester")
        #expect(survivor?.note == "Jambes lourdes", "la note du doublon ne doit pas se perdre")

        // Un second passage ne trouve plus rien : l'opération est stable.
        #expect(store.mergeDuplicateActivities() == 0)
    }

    @Test("Un journal sain n'est pas touché")
    func healthyHistoryIsLeftAlone() throws {
        let store = try storeLoading([
            run(at: noon, meters: 10_000, points: 10),
            run(at: noon.addingTimeInterval(6 * 3_600), meters: 10_000, points: 10),
            run(at: noon.addingTimeInterval(86_400), meters: 5_000, points: 10),
        ])
        #expect(store.mergeDuplicateActivities() == 0)
        #expect(store.history.activities.count == 3)
    }
}
