import Foundation
import Testing
@testable import MonCoachKit

private func makeStorage() -> StateStorage {
    StateStorage(url: URL.temporaryDirectory.appending(path: "mon-coach-watch-\(UUID().uuidString).json"))
}

private func cleanUp(_ storage: StateStorage) {
    try? FileManager.default.removeItem(at: storage.url)
}

private let today = Calendar.current.startOfDay(for: Date())

@MainActor
@Suite("Synchronisation avec la montre")
struct WatchSyncTests {

    private func onboardedStore() -> (CoachStore, StateStorage) {
        let storage = makeStorage()
        let store = CoachStore(storage: storage)
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        return (store, storage)
    }

    @Test("L'instantané du jour contient tout ce qu'il faut pour une séance au poignet")
    func snapshotIsComplete() {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }

        let snapshot = try! #require(store.watchSnapshot(on: today))
        #expect(snapshot.firstName == "Max")
        #expect(snapshot.weekIndex == 1)
        #expect(snapshot.calories > 1_200)

        let session = try! #require(snapshot.session, "le premier jour du bloc est un jour de séance")
        #expect(!session.exercises.isEmpty)
        // Les charges doivent être prescrites : la montre n'a pas l'historique
        // pour les recalculer.
        let loadable = session.exercises.filter {
            (ExerciseCatalog.exercise(id: $0.exerciseID)?.loadFactor ?? 0) > 0
        }
        #expect(!loadable.isEmpty)
        #expect(loadable.allSatisfy { ($0.sets.first?.suggestedLoadKg ?? 0) > 0 })
    }

    @Test("Sans profil, pas d'instantané — la montre affiche l'invite d'inscription")
    func noProfileNoSnapshot() {
        let storage = makeStorage()
        defer { cleanUp(storage) }
        #expect(CoachStore(storage: storage).watchSnapshot(on: today) == nil)
    }

    @Test("L'instantané survit à l'aller-retour JSON du canal WatchConnectivity")
    func snapshotRoundTrips() throws {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }

        let snapshot = try #require(store.watchSnapshot(on: today))
        let decoded = try WatchSyncCodec.decodeSnapshot(WatchSyncCodec.encode(snapshot))
        #expect(decoded.session == snapshot.session)
        #expect(decoded.readinessScore == snapshot.readinessScore)
        #expect(decoded.unit == snapshot.unit)
    }

    @Test("Un instantané d'une autre version se relit sans se perdre")
    func snapshotToleratesAnUnknownShape() throws {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }

        // La montre garde le dernier instantané sur disque, et les deux
        // applications ne se mettent pas à jour en même temps : un champ
        // ajouté d'un côté ne doit jamais rendre illisible ce qui est déjà
        // écrit de l'autre.
        let snapshot = try #require(store.watchSnapshot(on: today))
        let data = try WatchSyncCodec.encode(snapshot)
        var json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        json["unChampQuOnNeConnaitPas"] = "peu importe"
        let extended = try JSONSerialization.data(withJSONObject: json)

        let decoded = try WatchSyncCodec.decodeSnapshot(extended)
        #expect(decoded.firstName == snapshot.firstName)
        #expect(decoded.calories == snapshot.calories)
    }

    @Test("Une séance menée sur la montre entre dans l'historique et clôt la journée")
    func watchSessionLands() throws {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }
        let session = try #require(store.watchSnapshot(on: today)?.session)

        let log = Fixtures.perfectSession(session, on: today)
        let wire = try WatchSyncCodec.decodeSessionLog(WatchSyncCodec.encode(log))
        store.receiveFromWatch(wire)

        #expect(store.history.sessions.count == 1)
        #expect(store.history.sessions[0].sets.count == session.totalSets)
        #expect(store.briefing(on: today)?.state == .rest)
        // Et l'instantané suivant signale la séance comme faite.
        #expect(store.watchSnapshot(on: today)?.completedSessionIDs.contains(session.id) == true)
    }

    @Test("La même séance livrée deux fois n'entre qu'une fois")
    func duplicateDeliveryIsIdempotent() throws {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }
        let session = try #require(store.watchSnapshot(on: today)?.session)
        let log = Fixtures.perfectSession(session, on: today)

        store.receiveFromWatch(log)
        store.receiveFromWatch(log)
        #expect(store.history.sessions.count == 1)

        // Une relivraison plus complète remplace la première, ne s'y ajoute pas.
        var updated = log
        updated.note = "terminée au poignet"
        store.receiveFromWatch(updated)
        #expect(store.history.sessions.count == 1)
        #expect(store.history.sessions[0].note == "terminée au poignet")
    }

    @Test("Une séance ouverte puis abandonnée sur la montre n'entre pas dans l'historique")
    func emptyWatchSessionIsIgnored() throws {
        let (store, storage) = onboardedStore()
        defer { cleanUp(storage) }
        let session = try #require(store.watchSnapshot(on: today)?.session)

        store.receiveFromWatch(SessionLog(plannedSessionID: session.id, date: today))
        #expect(store.history.sessions.isEmpty)
    }
}

@Suite("Live Activity")
struct WorkoutActivityTests {

    private func activeSession() -> ActiveSession {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: today)
        let (loaded, _) = CoachEngine.prescribeLoads(
            for: plan.weeks[0].sessions[0],
            profile: Fixtures.intermediate(),
            history: .empty,
            isDeloadWeek: false
        )
        return ActiveSession(session: loaded, startedAt: today)
    }

    @Test("L'instantané suit la séance série après série")
    func snapshotTracksProgress() {
        var active = activeSession()
        let first = active.session.exercises[0]

        var snapshot = active.activitySnapshot(unit: .metric)
        #expect(!snapshot.isFinished)
        #expect(snapshot.completedSets == 0)
        #expect(snapshot.setLabel.contains("Série 1 sur \(first.sets.count)"))
        #expect(snapshot.suggestedLoadKg == first.sets[0].suggestedLoadKg)

        active.log(first.sets[0], of: first, weightKg: 60, reps: 10, rpe: 8, painFlag: false, at: today)
        let restEnd = today.addingTimeInterval(TimeInterval(first.restSeconds))
        snapshot = active.activitySnapshot(unit: .metric, restEndsAt: restEnd)
        #expect(snapshot.completedSets == 1)
        #expect(snapshot.setLabel.contains("Série 2"))
        #expect(snapshot.restEndsAt == restEnd)
        #expect(snapshot.progress > 0)
    }

    @Test("Séance complète : l'instantané passe en état terminé")
    func snapshotFinishes() {
        var active = activeSession()
        for prescription in active.session.exercises {
            for set in prescription.sets {
                active.log(set, of: prescription, weightKg: 50, reps: 8, rpe: 8, painFlag: false, at: today)
            }
        }
        let snapshot = active.activitySnapshot(unit: .metric)
        #expect(snapshot.isFinished)
        #expect(snapshot.progress == 1)
        #expect(snapshot.restEndsAt == nil)
    }

    @Test("L'état de la Live Activity se sérialise sans perte")
    func snapshotRoundTrips() throws {
        var active = activeSession()
        let first = active.session.exercises[0]
        active.log(first.sets[0], of: first, weightKg: 60, reps: 10, rpe: 8, painFlag: false, at: today)

        let snapshot = active.activitySnapshot(unit: .imperial, restEndsAt: today.addingTimeInterval(150))
        let encoder = JSONEncoder(); encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder(); decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(WorkoutActivitySnapshot.self, from: encoder.encode(snapshot))
        #expect(decoded == snapshot)
    }
}
