import Foundation
import Testing
@testable import MonCoachKit

@Suite("Mathématiques de la force")
struct StrengthMathTests {

    @Test("Une série à RPE 10 sur 1 répétition vaut le 1RM")
    func singleAtMaxIsOneRepMax() {
        #expect(abs(StrengthMath.estimatedOneRepMax(weightKg: 100, reps: 1, rpe: 10) - 100) < 0.01)
    }

    @Test("Le RPE déplace le 1RM estimé dans le bon sens")
    func rpeShiftsEstimate() {
        let hard = StrengthMath.estimatedOneRepMax(weightKg: 100, reps: 5, rpe: 10)
        let easy = StrengthMath.estimatedOneRepMax(weightKg: 100, reps: 5, rpe: 7)
        #expect(easy > hard, "5 répétitions faciles impliquent un 1RM plus élevé que 5 répétitions à l'échec")
    }

    @Test("Charge prescrite et 1RM estimé sont réciproques")
    func loadAndEstimateAreInverses() {
        let oneRM = 140.0
        for reps in 1...12 {
            for rpe in [7.0, 8.0, 9.0, 10.0] {
                let load = StrengthMath.load(forOneRepMax: oneRM, reps: reps, rpe: rpe)
                let back = StrengthMath.estimatedOneRepMax(weightKg: load, reps: reps, rpe: rpe)
                #expect(abs(back - oneRM) < 0.001, "\(reps) reps @ RPE \(rpe)")
            }
        }
    }

    @Test("Les charges sont arrondies à ce qu'on peut réellement mettre sur la barre")
    func rounding() {
        #expect(StrengthMath.round(63.7, to: .standard) == 62.5)
        #expect(StrengthMath.round(63.7, to: .fine) == 64)
        #expect(StrengthMath.round(63.7, to: .coarse) == 65)
        #expect(StrengthMath.round(0.4, to: .standard) == 2.5, "on ne prescrit jamais zéro")
    }

    @Test("La tendance linéaire retrouve une pente connue")
    func trendFit() {
        let start = Fixtures.start
        let points = (0..<10).map { day in
            (date: Fixtures.calendar.date(byAdding: .day, value: day, to: start)!, value: 80.0 - Double(day) * 0.1)
        }
        let slope = StrengthMath.trendPerDay(points)
        #expect(slope != nil)
        #expect(abs(slope! + 0.1) < 0.0001)
    }

    @Test("Une seule mesure ne suffit pas à faire une tendance")
    func trendNeedsData() {
        #expect(StrengthMath.trendPerDay([(date: Fixtures.start, value: 80)]) == nil)
        #expect(StrengthMath.trendPerDay([]) == nil)
    }
}

@Suite("Progression des charges")
struct ProgressionTests {

    private func setup() -> (Exercise, SetPrescription, UserProfile) {
        let exercise = ExerciseCatalog.exercise(id: "bench-press")!
        let prescription = SetPrescription(index: 0, repLowerBound: 6, repUpperBound: 10, targetRPE: 8)
        return (exercise, prescription, Fixtures.intermediate())
    }

    @Test("Sans historique, la charge de départ vient du 1RM connu")
    func seedsFromKnownMax() {
        let (exercise, prescription, profile) = setup()
        let decision = ProgressionEngine.decide(
            exercise: exercise,
            prescription: prescription,
            history: .empty,
            profile: profile,
            isDeloadWeek: false
        )
        #expect(decision.action == .start)
        // 90 kg de 1RM, 8 répétitions à RPE 8 → autour de 65 kg.
        #expect(decision.loadKg != nil)
        #expect(decision.loadKg! > 55 && decision.loadKg! < 75, "obtenu \(decision.loadKg!)")
    }

    @Test("Toutes les séries au sommet de la fourchette font monter la charge")
    func allTopRepsIncreases() {
        let (exercise, prescription, profile) = setup()
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: (0..<3).map {
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: $0, weightKg: 70, reps: 10, rpe: 7.5)
            })
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: false
        )
        #expect(decision.action == .increase)
        #expect(decision.loadKg! > 70)
    }

    @Test("Un arrondi ne doit jamais transformer une hausse en surplace")
    func increaseIsAlwaysRealForSmallLoads() {
        let exercise = ExerciseCatalog.exercise(id: "lateral-raise")!
        let prescription = SetPrescription(index: 0, repLowerBound: 12, repUpperBound: 15, targetRPE: 8)
        var profile = Fixtures.intermediate()
        profile.loadIncrement = .standard
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: (0..<3).map {
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: $0, weightKg: 10, reps: 15, rpe: 7)
            })
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: false
        )
        #expect(decision.action == .increase)
        #expect(decision.loadKg! > 10)
    }

    @Test("Des répétitions sous la fourchette font reculer la charge")
    func missedRepsDecrease() {
        let (exercise, prescription, profile) = setup()
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: (0..<3).map {
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: $0, weightKg: 90, reps: 4, rpe: 10)
            })
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: false
        )
        #expect(decision.action == .decrease)
        #expect(decision.loadKg! < 90)
    }

    @Test("Dans la fourchette sans atteindre le sommet, la charge ne bouge pas")
    func midRangeHolds() {
        let (exercise, prescription, profile) = setup()
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: (0..<3).map {
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: $0, weightKg: 80, reps: 8, rpe: 8)
            })
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: false
        )
        #expect(decision.action == .hold)
        #expect(decision.loadKg == 80)
    }

    @Test("Une douleur signalée l'emporte sur une séance par ailleurs parfaite")
    func painOverridesEverything() {
        let (exercise, prescription, profile) = setup()
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: (0..<3).map {
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: $0,
                       weightKg: 80, reps: 10, rpe: 7, painFlag: $0 == 2)
            })
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: false
        )
        #expect(decision.action == .decrease)
        #expect(decision.loadKg! < 80)
    }

    @Test("La semaine de décharge tourne autour de 60 % de la charge habituelle")
    func deloadDropsLoad() {
        let (exercise, prescription, profile) = setup()
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.start, sets: [
                SetLog(date: Fixtures.start, exerciseID: exercise.id, setIndex: 0, weightKg: 100, reps: 8, rpe: 8)
            ])
        ])
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: history,
            profile: profile, isDeloadWeek: true
        )
        #expect(decision.action == .deload)
        #expect(decision.loadKg == 60)
    }

    @Test("Un mouvement au poids du corps ne reçoit pas de charge inventée")
    func bodyweightHasNoLoad() {
        let exercise = ExerciseCatalog.exercise(id: "push-up")!
        let prescription = SetPrescription(index: 0, repLowerBound: 8, repUpperBound: 15, targetRPE: 8)
        let decision = ProgressionEngine.decide(
            exercise: exercise, prescription: prescription, history: .empty,
            profile: Fixtures.intermediate(), isDeloadWeek: false
        )
        #expect(decision.action == .start)
        #expect(decision.loadKg == nil)
    }
}

@Suite("Forme du jour")
struct ReadinessTests {

    @Test("Sans questionnaire, la séance est prescrite telle quelle")
    func noCheckInMeansNoChange() {
        let verdict = ReadinessEngine.verdict(for: nil, profile: Fixtures.intermediate())
        #expect(verdict.isGreenLight)
        #expect(verdict.loadMultiplier == 1.0)
    }

    @Test("Une excellente forme donne un feu vert")
    func greatDayIsGreen() {
        let check = ReadinessCheck(date: Fixtures.start, sleepQuality: 5, soreness: 1, motivation: 5, stress: 1, sleepHours: 8.5)
        let verdict = ReadinessEngine.verdict(for: check, profile: Fixtures.intermediate())
        #expect(verdict.score >= 80)
        #expect(verdict.isGreenLight)
    }

    @Test("Une mauvaise journée allège la séance sans l'annuler")
    func badDayScalesDown() {
        let check = ReadinessCheck(date: Fixtures.start, sleepQuality: 1, soreness: 5, motivation: 1, stress: 5, sleepHours: 4)
        let verdict = ReadinessEngine.verdict(for: check, profile: Fixtures.intermediate())
        #expect(verdict.score < 40)
        #expect(verdict.loadMultiplier < 0.9)
        #expect(verdict.setsToDrop > 0)
    }

    @Test("Le verdict allège vraiment la séance et ne descend jamais sous deux séries")
    func verdictAppliesToSession() {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let session = plan.weeks[0].sessions[0]
        let (loaded, _) = CoachEngine.prescribeLoads(
            for: session, profile: Fixtures.intermediate(), history: .empty, isDeloadWeek: false
        )
        let check = ReadinessCheck(date: Fixtures.start, sleepQuality: 1, soreness: 5, motivation: 2, stress: 5, sleepHours: 4.5)
        let verdict = ReadinessEngine.verdict(for: check, profile: Fixtures.intermediate())
        let adjusted = ReadinessEngine.apply(verdict, to: loaded, increment: .standard)

        #expect(adjusted.totalSets < loaded.totalSets)
        #expect(adjusted.exercises.allSatisfy { $0.sets.count >= 2 })
        #expect(adjusted.exercises.count == loaded.exercises.count)

        for (before, after) in zip(loaded.exercises, adjusted.exercises) {
            if let old = before.sets.first?.suggestedLoadKg, let new = after.sets.first?.suggestedLoadKg {
                #expect(new <= old)
            }
        }
    }

    @Test("Un dormeur habituellement court n'est pas pénalisé deux fois")
    func chronicShortSleepIsNotDoublePenalised() {
        var shortSleeper = Fixtures.intermediate()
        shortSleeper.averageSleepHours = 6.0
        let check = ReadinessCheck(date: Fixtures.start, sleepQuality: 3, soreness: 3, motivation: 3, stress: 3, sleepHours: 6.0)
        let penalised = ReadinessEngine.verdict(for: check, profile: Fixtures.intermediate())
        let adapted = ReadinessEngine.verdict(for: check, profile: shortSleeper)
        #expect(adapted.score > penalised.score)
    }
}
