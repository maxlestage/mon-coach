import Foundation
import Testing
@testable import MonCoachKit

@Suite("Forme et fatigue")
struct TrainingLoadTests {

    private let calendar = Fixtures.calendar
    private let maxBpm = 190.0

    private func run(
        daysAgo: Int,
        minutes: Double = 60,
        type: RunType = .easy,
        rpe: Int? = nil,
        bpm: Double? = nil,
        from reference: Date
    ) -> ActivityLog {
        let start = calendar.date(byAdding: .day, value: -daysAgo, to: reference)!
        var heartRate: [HeartRateSample] = []
        if let bpm {
            heartRate = stride(from: 0.0, to: minutes * 60, by: 10).map {
                HeartRateSample(timestamp: start.addingTimeInterval($0), bpm: bpm)
            }
        }
        return ActivityLog(
            startedAt: start,
            type: type,
            meters: minutes * 1_000 / 6,
            duration: minutes * 60,
            elevationGain: 0,
            heartRate: heartRate,
            perceivedEffort: rpe
        )
    }

    @Test("Les trois sources d'effort parlent la même langue")
    func effortSourcesShareOneScale() {
        let reference = Fixtures.start
        // Une heure en zone 3 (~75 % du max) vaut ~180 points de TRIMP.
        let sensed = TrainingLoadEngine.effort(
            for: run(daysAgo: 0, bpm: 145, from: reference), maximumBpm: maxBpm
        )
        // Une heure à RPE 6 vaut 60 × 3 = 180 points.
        let felt = TrainingLoadEngine.effort(
            for: run(daysAgo: 0, rpe: 6, from: reference), maximumBpm: maxBpm
        )
        // Une heure de tempo sans rien vaut aussi 180 points.
        let assumed = TrainingLoadEngine.effort(
            for: run(daysAgo: 0, type: .tempo, from: reference), maximumBpm: maxBpm
        )
        // Les trois estiment la même séance : ils doivent tomber proches,
        // sinon la courbe change de sens selon qu'un capteur était là.
        #expect(abs(sensed - felt) / felt < 0.15, "capteur \(sensed) vs ressenti \(felt)")
        #expect(abs(assumed - felt) / felt < 0.15, "intention \(assumed) vs ressenti \(felt)")
    }

    @Test("Le capteur gagne sur le ressenti, le ressenti sur l'intention")
    func bestSourceWins() {
        let reference = Fixtures.start
        // RPE 10 mais cardio de promenade : le cardio fait foi.
        let contradictory = run(daysAgo: 0, rpe: 10, bpm: 110, from: reference)
        let effort = TrainingLoadEngine.effort(for: contradictory, maximumBpm: maxBpm)
        let feltOnly = TrainingLoadEngine.effort(
            for: run(daysAgo: 0, rpe: 10, from: reference), maximumBpm: maxBpm
        )
        #expect(effort < feltOnly, "le RPE a écrasé le capteur")
    }

    @Test("Une séance fatigue plus qu'elle ne construit, le jour même")
    func aSessionRaisesFatigueFasterThanFitness() {
        let reference = Fixtures.start
        let series = TrainingLoadEngine.series(
            activities: [run(daysAgo: 0, from: reference)],
            maximumBpm: maxBpm,
            endingOn: reference,
            calendar: calendar
        )
        let today = try! #require(series.last)
        #expect(today.fatigue > today.fitness)
        #expect(today.form < 0)
    }

    @Test("Quelques jours calmes après un bloc dur : la forme remonte")
    func taperingRaisesForm() {
        let reference = Fixtures.start
        // Trois semaines de charge quotidienne…
        var activities = (7...27).map { run(daysAgo: $0, from: reference) }
        let loaded = TrainingLoadEngine.series(
            activities: activities + [run(daysAgo: 6, from: reference)],
            maximumBpm: maxBpm,
            endingOn: calendar.date(byAdding: .day, value: -6, to: reference)!,
            calendar: calendar
        ).last!

        // …puis six jours de repos complet.
        activities.append(run(daysAgo: 6, from: reference))
        let rested = TrainingLoadEngine.series(
            activities: activities,
            maximumBpm: maxBpm,
            endingOn: reference,
            calendar: calendar
        ).last!

        #expect(rested.form > loaded.form, "le repos n'a pas rendu de forme")
        #expect(rested.fitness < loaded.fitness, "la condition ne décroît pas au repos")
        #expect(rested.fitness > loaded.fitness * 0.8, "six jours ont effondré six semaines")
    }

    @Test("Sans activité, pas de courbe — et pas de verdict sur du bruit")
    func silenceStaysSilent() {
        let series = TrainingLoadEngine.series(
            activities: [], maximumBpm: maxBpm, endingOn: Fixtures.start, calendar: calendar
        )
        #expect(series.isEmpty)

        let thin = FitnessPoint(date: Fixtures.start, fitness: 3, fatigue: 8)
        #expect(TrainingLoadEngine.verdict(for: thin) == nil)
    }

    @Test("La fenêtre rendue est la fenêtre demandée, le calcul commence avant")
    func windowIsHonest() {
        let reference = Fixtures.start
        let series = TrainingLoadEngine.series(
            activities: (0...120).map { run(daysAgo: $0, from: reference) },
            maximumBpm: maxBpm,
            endingOn: reference,
            days: 90,
            calendar: calendar
        )
        #expect(series.count == 90)
        // Après 120 jours de charge constante, la condition du premier point
        // affiché doit déjà être construite : si le calcul démarrait au bord
        // de la fenêtre, elle serait presque nulle.
        let first = try! #require(series.first)
        let last = try! #require(series.last)
        #expect(first.fitness > last.fitness * 0.5)
    }
}

@Suite("Matériel")
struct GearTests {

    private func activity(meters: Double, gearID: UUID?, daysAgo: Int = 0) -> ActivityLog {
        ActivityLog(
            startedAt: Fixtures.calendar.date(byAdding: .day, value: -daysAgo, to: Fixtures.start)!,
            type: .easy,
            meters: meters,
            duration: meters / 2.5,
            elevationGain: 0,
            gearID: gearID
        )
    }

    @Test("Le kilométrage se recalcule depuis les sorties, jamais stocké")
    func mileageIsDerived() {
        let shoes = Gear(name: "Pegasus", kind: .shoes)
        let activities = [
            activity(meters: 10_000, gearID: shoes.id),
            activity(meters: 8_000, gearID: shoes.id),
            activity(meters: 12_000, gearID: nil)
        ]
        #expect(GearTracker.meters(for: shoes.id, in: activities) == 18_000)
        #expect(GearTracker.activityCount(for: shoes.id, in: activities) == 2)
    }

    @Test("Des chaussures s'usent, un vélo non")
    func wearThresholds() {
        let shoes = Gear(name: "Vieilles", kind: .shoes)
        let bike = Gear(name: "Cadre", kind: .bike)
        let heavy = [activity(meters: 700_000, gearID: shoes.id),
                     activity(meters: 700_000, gearID: bike.id)]
        #expect(GearTracker.isWorn(shoes, in: heavy))
        #expect(!GearTracker.isWorn(bike, in: heavy))
    }

    @Test("La sortie prend le dernier matériel utilisé pour son sport")
    func suggestionFollowsHabit() {
        let old = Gear(name: "Anciennes", kind: .shoes)
        let new = Gear(name: "Neuves", kind: .shoes)
        let bike = Gear(name: "Vélo", kind: .bike)
        let gear = [old, new, bike]
        let activities = [
            activity(meters: 10_000, gearID: old.id, daysAgo: 10),
            activity(meters: 10_000, gearID: new.id, daysAgo: 1)
        ]
        #expect(GearTracker.suggested(for: .run, among: gear, activities: activities)?.id == new.id)
        #expect(GearTracker.suggested(for: .ride, among: gear, activities: activities)?.id == bike.id)
    }

    @Test("Un matériel retraité ne se propose plus, mais garde son histoire")
    func retirementStopsSuggestions() {
        var shoes = Gear(name: "Retraitées", kind: .shoes)
        let past = [activity(meters: 500_000, gearID: shoes.id, daysAgo: 3)]
        shoes.retiredAt = Fixtures.start
        #expect(GearTracker.suggested(for: .run, among: [shoes], activities: past) == nil)
        #expect(GearTracker.meters(for: shoes.id, in: past) == 500_000)
    }

    @Test("Le magasin affecte le matériel tout seul, et sait se corriger")
    @MainActor
    func storeAssignsAutomatically() {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "mon-coach-gear-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }
        let store = CoachStore(storage: storage)
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: Fixtures.start)
        let shoes = store.addGear(name: "Pegasus", kind: .shoes)

        store.recordRun(activity(meters: 10_000, gearID: nil))
        let recorded = try! #require(store.history.activities.last)
        #expect(recorded.gearID == shoes.id, "la sortie n'a pas pris les chaussures du moment")

        store.assignGear(nil, toActivity: recorded.id)
        #expect(store.history.activities.last?.gearID == nil)
    }

    @Test("Un historique d'avant le matériel se relit sans casse")
    func oldHistoryStillDecodes() throws {
        let history = TrainingHistory(activities: [activity(meters: 5_000, gearID: nil)])
        var object = try JSONSerialization.jsonObject(
            with: JSONEncoder().encode(history)
        ) as! [String: Any]
        // Le fichier d'un athlète d'avant : aucune clé « gear ».
        object.removeValue(forKey: "gear")
        let data = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(TrainingHistory.self, from: data)
        #expect(decoded.gear.isEmpty)
        #expect(decoded.activities.count == 1)
    }
}
