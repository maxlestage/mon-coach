import Foundation
import Testing
@testable import MonCoachKit

/// Un magasin adossé à un fichier temporaire, isolé pour chaque test.
private func makeStorage(_ name: String = UUID().uuidString) -> StateStorage {
    StateStorage(url: URL.temporaryDirectory.appending(path: "mon-coach-test-\(name).json"))
}

private func cleanUp(_ storage: StateStorage) {
    try? FileManager.default.removeItem(at: storage.url)
    try? FileManager.default.removeItem(
        at: storage.url.deletingPathExtension().appendingPathExtension("corrupt.json")
    )
}

private let today = Calendar.current.startOfDay(for: Date())

@Suite("Séance en cours")
struct ActiveSessionTests {

    private func session() -> PlannedSession {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: today)
        let (loaded, _) = CoachEngine.prescribeLoads(
            for: plan.weeks[0].sessions[0],
            profile: Fixtures.intermediate(),
            history: .empty,
            isDeloadWeek: false
        )
        return loaded
    }

    @Test("Une séance qui commence n'a rien d'enregistré")
    func startsEmpty() {
        let active = ActiveSession(session: session(), startedAt: today)
        #expect(active.loggedSetCount == 0)
        #expect(active.progress == 0)
        #expect(active.currentExercise?.id == active.session.exercises.first?.id)
    }

    @Test("Les séries s'enregistrent dans l'ordre et l'exercice avance tout seul")
    func logsAdvance() {
        var active = ActiveSession(session: session(), startedAt: today)
        let first = active.session.exercises[0]

        for set in first.sets {
            #expect(active.nextSet(of: first)?.index == set.index)
            active.log(set, of: first, weightKg: 60, reps: set.repUpperBound, rpe: 8, painFlag: false, at: today)
        }

        #expect(active.isComplete(first))
        #expect(active.nextSet(of: first) == nil)
        #expect(active.logs(for: first).count == first.sets.count)
        #expect(active.currentExercise?.id == active.session.exercises[1].id)
    }

    @Test("Annuler retire la dernière série et rien d'autre")
    func undo() {
        var active = ActiveSession(session: session(), startedAt: today)
        let first = active.session.exercises[0]
        active.log(first.sets[0], of: first, weightKg: 60, reps: 8, rpe: 8, painFlag: false, at: today)
        active.log(first.sets[1], of: first, weightKg: 62.5, reps: 8, rpe: 8, painFlag: false, at: today)

        active.undoLastSet(of: first)
        #expect(active.logs(for: first).count == 1)
        #expect(active.logs(for: first)[0].weightKg == 60)

        active.undoLastSet(of: first)
        active.undoLastSet(of: first)   // une annulation de trop ne doit rien casser
        #expect(active.logs(for: first).isEmpty)
    }

    @Test("La progression reflète les séries réellement faites")
    func progress() {
        var active = ActiveSession(session: session(), startedAt: today)
        let total = active.session.totalSets
        for prescription in active.session.exercises {
            for set in prescription.sets {
                active.log(set, of: prescription, weightKg: 50, reps: 8, rpe: 8, painFlag: false, at: today)
            }
        }
        #expect(active.loggedSetCount == total)
        #expect(active.progress == 1.0)
        #expect(active.currentExercise == nil)
    }

    @Test("Le journal produit conserve toutes les séries et une durée plausible")
    func producesLog() {
        var active = ActiveSession(session: session(), startedAt: today)
        let first = active.session.exercises[0]
        active.log(first.sets[0], of: first, weightKg: 70, reps: 9, rpe: 8.5, painFlag: true, at: today)

        let log = active.log(finishedAt: today.addingTimeInterval(48 * 60))
        #expect(log.sets.count == 1)
        #expect(log.sets[0].painFlag)
        #expect(log.durationMinutes == 48)
        #expect(log.plannedSessionID == active.session.id)
        #expect(!log.skipped)
    }
}

@Suite("Formulaire de profil")
struct ProfileDraftTests {

    @Test("Un brouillon vide n'est pas valide tant qu'il manque le prénom")
    func validation() {
        var draft = ProfileDraft()
        #expect(!draft.isValid)
        draft.firstName = "   "
        #expect(!draft.isValid, "des espaces ne sont pas un prénom")
        draft.firstName = "Max"
        #expect(draft.isValid)
    }

    @Test("Le niveau est déduit de l'ancienneté, et reste modifiable")
    func experienceInference() {
        var draft = ProfileDraft()
        draft.trainingMonths = 3
        #expect(draft.experience == .beginner)
        draft.trainingMonths = 20
        #expect(draft.experience == .intermediate)
        draft.trainingMonths = 60
        #expect(draft.experience == .advanced)

        draft.experienceOverride = .beginner
        #expect(draft.experience == .beginner, "le choix explicite doit l'emporter")
    }

    @Test("Les champs facultatifs restent absents quand ils ne sont pas cochés")
    func optionalFields() {
        var draft = ProfileDraft()
        draft.firstName = "Léa"
        draft.knowsBodyFat = false
        draft.hasTargetWeight = false
        draft.hasDeadline = false
        draft.oneRepMax["back-squat"] = 0

        let profile = draft.makeProfile()
        #expect(profile.bodyFatPercent == nil)
        #expect(profile.waistCm == nil)
        #expect(profile.targetWeightKg == nil)
        #expect(profile.deadline == nil)
        #expect(profile.knownOneRepMax.isEmpty, "un maximum à zéro veut dire « je ne sais pas »")
    }

    @Test("Un profil relu dans le formulaire ressort identique")
    func roundTripsThroughTheForm() {
        let original = Fixtures.intermediate(goal: .fatLoss, limitations: [.knee, .shoulder])
        let rebuilt = ProfileDraft(profile: original).makeProfile()

        #expect(rebuilt.firstName == original.firstName)
        #expect(rebuilt.sex == original.sex)
        #expect(rebuilt.heightCm == original.heightCm)
        #expect(rebuilt.weightKg == original.weightKg)
        #expect(rebuilt.bodyFatPercent == original.bodyFatPercent)
        #expect(rebuilt.experience == original.experience)
        #expect(rebuilt.goal == original.goal)
        #expect(rebuilt.daysPerWeek == original.daysPerWeek)
        #expect(rebuilt.sessionMinutes == original.sessionMinutes)
        #expect(rebuilt.equipment == original.equipment)
        #expect(rebuilt.limitations == original.limitations)
        #expect(rebuilt.knownOneRepMax == original.knownOneRepMax)
    }

    @Test("Le prénom est nettoyé de ses espaces")
    func trimsName() {
        var draft = ProfileDraft()
        draft.firstName = "  Max  "
        #expect(draft.makeProfile().firstName == "Max")
    }
}

@Suite("Stockage")
struct StateStorageTests {

    @Test("Un fichier absent donne un état vide plutôt qu'une erreur")
    func missingFile() {
        let storage = makeStorage()
        defer { cleanUp(storage) }
        let state = storage.load()
        #expect(state.profile == nil)
        #expect(state.plan == nil)
        #expect(state.history == .empty)
    }

    @Test("Ce qui est écrit est relu à l'identique")
    func roundTrip() throws {
        let storage = makeStorage()
        defer { cleanUp(storage) }

        let profile = Fixtures.intermediate()
        let plan = PlanBuilder.build(for: profile, startingOn: today)
        let history = TrainingHistory(
            sessions: [SessionLog(date: today, sets: [
                SetLog(date: today, exerciseID: "bench-press", setIndex: 0, weightKg: 80, reps: 8, rpe: 8)
            ])],
            bodyLogs: [BodyLog(date: today, weightKg: 78.4)],
            readiness: [ReadinessCheck(date: today, sleepQuality: 4, soreness: 2, motivation: 4, stress: 2)]
        )

        try storage.save(PersistedState(profile: profile, plan: plan, history: history))
        let restored = storage.load()

        #expect(restored.profile == profile)
        #expect(restored.plan == plan)
        #expect(restored.history == history)
    }

    @Test("Un fichier illisible est mis de côté, jamais supprimé")
    func corruptFileIsPreserved() throws {
        let storage = makeStorage()
        defer { cleanUp(storage) }
        try Data("ceci n'est pas du JSON".utf8).write(to: storage.url)

        let state = storage.load()
        #expect(state.profile == nil, "l'application doit redémarrer proprement")

        let backup = storage.url.deletingPathExtension().appendingPathExtension("corrupt.json")
        #expect(FileManager.default.fileExists(atPath: backup.path), "l'historique doit rester récupérable à la main")
        #expect(!FileManager.default.fileExists(atPath: storage.url.path))
    }
}

@MainActor
@Suite("Magasin de l'application")
struct CoachStoreTests {

    private func newStore() -> (CoachStore, StateStorage) {
        let storage = makeStorage()
        return (CoachStore(storage: storage), storage)
    }

    @Test("Avant l'inscription, il n'y a ni programme ni séance")
    func emptyBeforeOnboarding() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        #expect(!store.isOnboarded)
        #expect(store.program == nil)
        #expect(store.briefing() == nil)
        #expect(store.latestInsights().isEmpty)
    }

    @Test("L'inscription produit un programme, et il survit au redémarrage")
    func onboardingPersists() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }

        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        #expect(store.isOnboarded)
        #expect(store.program != nil)
        #expect(store.currentWeekIndex(on: today) == 1)

        // Une nouvelle instance lit le même fichier : c'est le redémarrage de l'app.
        let reopened = CoachStore(storage: storage)
        #expect(reopened.profile == store.profile)
        #expect(reopened.plan == store.plan)
        #expect(reopened.isOnboarded)
    }

    @Test("Une séance jouée est enregistrée, et la journée passe au repos")
    func completingASession() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)

        let session = try! #require(store.briefing(on: today)?.session)
        store.startSession(session)
        let active = try! #require(store.activeSession)

        for prescription in active.session.exercises {
            for set in prescription.sets {
                store.activeSession?.log(
                    set, of: prescription,
                    weightKg: set.suggestedLoadKg ?? 40,
                    reps: set.repUpperBound, rpe: set.targetRPE,
                    painFlag: false, at: today
                )
            }
        }
        store.finishActiveSession(at: today.addingTimeInterval(3600))

        #expect(store.activeSession == nil)
        #expect(store.history.sessions.count == 1)
        #expect(store.history.sessions[0].sets.count == session.totalSets)
        #expect(store.briefing(on: today)?.state == .rest, "on ne propose pas deux séances le même jour")

        let reopened = CoachStore(storage: storage)
        #expect(reopened.history.sessions.count == 1)
    }

    @Test("Une séance ouverte puis abandonnée sans rien faire n'est pas enregistrée")
    func abandonedSessionIsNotRecorded() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)

        let session = try! #require(store.briefing(on: today)?.session)
        store.startSession(session)
        store.finishActiveSession(at: today.addingTimeInterval(120))

        #expect(store.activeSession == nil)
        #expect(store.history.sessions.isEmpty)
        #expect(store.briefing(on: today)?.session != nil, "la séance reste due")
    }

    @Test("Une séance déclarée impossible est notée comme telle")
    func skipping() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)

        let due = try! #require(store.briefing(on: today)?.session)
        store.skipTodaySession(at: today)

        #expect(store.history.sessions.count == 1)
        #expect(store.history.sessions[0].skipped)
        #expect(store.briefing(on: today)?.state == .rest, "la journée est close")

        // La journée est perdue, pas la séance : elle repasse au prochain jour
        // d'entraînement de la semaine, sans que rien ne soit rayé du bloc.
        let nextTraining = (1...6)
            .compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) }
            .compactMap { store.briefing(on: $0)?.session }
            .first
        #expect(nextTraining?.id == due.id)
    }

    @Test("Le check-in du jour remplace le précédent au lieu de s'empiler")
    func readinessIsReplacedNotStacked() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)

        store.recordReadiness(ReadinessCheck(date: today, sleepQuality: 1, soreness: 5, motivation: 1, stress: 5))
        let tired = try! #require(store.briefing(on: today)).readiness.score

        store.recordReadiness(ReadinessCheck(date: today, sleepQuality: 5, soreness: 1, motivation: 5, stress: 1))
        #expect(store.history.readiness.count == 1)
        #expect(try! #require(store.briefing(on: today)).readiness.score > tired)
    }

    @Test("Une pesée du jour met à jour le poids qui sert aux calculs")
    func weighInUpdatesTheProfile() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        let before = try! #require(store.program).nutrition.calories

        store.recordBodyLog(BodyLog(date: Date(), weightKg: 84, bodyFatPercent: 18))
        #expect(store.profile?.weightKg == 84)
        #expect(store.profile?.bodyFatPercent == 18)
        #expect(try! #require(store.program).nutrition.calories != before)
        #expect(store.history.bodyLogs.count == 1)
    }

    @Test("Deux pesées le même jour n'en font qu'une")
    func oneWeighInPerDay() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)

        store.recordBodyLog(BodyLog(date: Date(), weightKg: 80))
        store.recordBodyLog(BodyLog(date: Date(), weightKg: 79.5))
        #expect(store.history.bodyLogs.count == 1)
        #expect(store.history.bodyLogs[0].weightKg == 79.5)
    }

    @Test("Modifier le profil reconstruit le bloc mais garde l'historique")
    func editingTheProfileKeepsHistory() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(daysPerWeek: 4), startingOn: today)

        let session = try! #require(store.briefing(on: today)?.session)
        store.startSession(session)
        store.activeSession?.log(
            session.exercises[0].sets[0], of: session.exercises[0],
            weightKg: 60, reps: 8, rpe: 8, painFlag: false, at: today
        )
        store.finishActiveSession(at: today.addingTimeInterval(1800))

        var updated = try! #require(store.profile)
        updated.daysPerWeek = 2
        store.updateProfile(updated, rebuildingFrom: today)

        #expect(store.plan?.split == .fullBody)
        #expect(store.plan?.weeks[0].sessions.count == 2)
        #expect(store.history.sessions.count == 1, "le journal appartient à l'athlète, pas au plan")
    }

    @Test("Le bloc suivant repart d'un plan neuf sans effacer le passé")
    func nextBlock() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        let firstPlanID = try! #require(store.plan).id

        store.skipTodaySession(at: today)
        store.startNextBlock(on: today)

        #expect(store.plan?.id != firstPlanID)
        #expect(store.history.sessions.count == 1)
        #expect(store.profile?.trainingMonths == Fixtures.intermediate().trainingMonths + 1)
    }

    @Test("L'export contient tout ce que l'athlète a saisi")
    func exportIsComplete() throws {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        store.recordBodyLog(BodyLog(date: Date(), weightKg: 77.2))

        let data = try store.exportJSON()
        let restored = try StateStorage.decoder.decode(PersistedState.self, from: data)
        #expect(restored.profile == store.profile)
        #expect(restored.plan == store.plan)
        #expect(restored.history.bodyLogs.count == 1)
    }

    @Test("Tout effacer efface vraiment tout, y compris sur le disque")
    func resetClearsEverything() {
        let (store, storage) = newStore()
        defer { cleanUp(storage) }
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        store.recordBodyLog(BodyLog(date: Date(), weightKg: 77))

        store.resetEverything()
        #expect(store.profile == nil)
        #expect(store.plan == nil)
        #expect(store.history == .empty)
        #expect(!CoachStore(storage: storage).isOnboarded)
    }

    @Test("Une écriture impossible remonte une erreur au lieu de perdre les données en silence")
    func saveFailureIsSurfaced() {
        // Un dossier inexistant : l'écriture ne peut pas aboutir.
        let storage = StateStorage(
            url: URL(filePath: "/nonexistent-\(UUID().uuidString)/state.json")
        )
        let store = CoachStore(storage: storage)
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: today)
        #expect(store.saveError != nil)
        #expect(store.isOnboarded, "l'état en mémoire reste utilisable pour la séance en cours")
    }
}
