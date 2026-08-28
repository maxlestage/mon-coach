import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le coach au quotidien")
struct CoachEngineTests {

    private func program(
        _ profile: UserProfile = Fixtures.intermediate()
    ) -> CoachingProgram {
        CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
    }

    @Test("Le premier jour du bloc propose une séance")
    func firstDayIsATrainingDay() {
        let briefing = CoachEngine.briefing(
            for: program(), history: .empty, on: Fixtures.start, calendar: Fixtures.calendar
        )
        #expect(briefing.weekIndex == 1)
        #expect(briefing.session != nil)
        #expect(briefing.isDeloadWeek == false)
    }

    @Test("Toutes les charges du jour sont chiffrées et justifiées")
    func loadsAreExplained() {
        let program = program()
        let briefing = CoachEngine.briefing(
            for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar
        )
        let session = try! #require(briefing.session)
        for prescription in session.exercises {
            let decision = briefing.loadDecisions[prescription.id]
            #expect(decision != nil, "\(prescription.exerciseID) sans décision de charge")
            #expect(decision!.reason.isComplete)

            let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)!
            if exercise.loadFactor > 0 {
                #expect(prescription.sets.allSatisfy { ($0.suggestedLoadKg ?? 0) > 0 },
                        "\(exercise.name) devrait avoir une charge suggérée")
            }
        }
    }

    @Test("Une séance déjà faite dans la journée n'en déclenche pas une seconde")
    func oneSessionPerDay() {
        let program = program()
        let briefing = CoachEngine.briefing(
            for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar
        )
        let session = try! #require(briefing.session)
        let history = TrainingHistory(sessions: [Fixtures.perfectSession(session, on: Fixtures.start)])

        let after = CoachEngine.briefing(
            for: program, history: history, on: Fixtures.start, calendar: Fixtures.calendar
        )
        #expect(after.state == .rest)
    }

    @Test("La séance suivante attend le lendemain, pas deux minutes plus tard")
    func nextSessionIsTheNextDay() {
        let program = program()
        let first = try! #require(
            CoachEngine.briefing(for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar).session
        )
        let history = TrainingHistory(sessions: [Fixtures.perfectSession(first, on: Fixtures.start)])
        let tomorrow = Fixtures.calendar.date(byAdding: .day, value: 1, to: Fixtures.start)!
        let second = CoachEngine.briefing(for: program, history: history, on: tomorrow, calendar: Fixtures.calendar)
        #expect(second.session?.id != first.id)
    }

    @Test("Une semaine entière se déroule sans jamais reproposer la même séance")
    func aFullWeekRunsThrough() {
        let program = program(Fixtures.intermediate(daysPerWeek: 4))
        var history = TrainingHistory()
        var done: [UUID] = []

        for offset in 0..<7 {
            let day = Fixtures.calendar.date(byAdding: .day, value: offset, to: Fixtures.start)!
            let briefing = CoachEngine.briefing(for: program, history: history, on: day, calendar: Fixtures.calendar)
            guard let session = briefing.session else { continue }
            #expect(!done.contains(session.id), "la séance \(session.title) est reproposée")
            done.append(session.id)
            history.sessions.append(Fixtures.perfectSession(session, on: day))
        }
        #expect(done.count == 4, "\(done.count) séances proposées sur 4")
    }

    @Test("Passé la fin du bloc, le coach le dit au lieu d'inventer une séance")
    func blockEnds() {
        let program = program()
        let after = Fixtures.calendar.date(byAdding: .day, value: program.plan.weekCount * 7 + 1, to: Fixtures.start)!
        let briefing = CoachEngine.briefing(for: program, history: .empty, on: after, calendar: Fixtures.calendar)
        #expect(briefing.state == .blockFinished)
        #expect(briefing.weekIndex == nil)
    }

    @Test("La forme du jour est prise en compte dans le briefing")
    func readinessReachesTheBriefing() {
        let program = program()
        let check = ReadinessCheck(date: Fixtures.start, sleepQuality: 1, soreness: 5, motivation: 1, stress: 5, sleepHours: 4)
        let history = TrainingHistory(readiness: [check])

        let tired = CoachEngine.briefing(for: program, history: history, on: Fixtures.start, calendar: Fixtures.calendar)
        let fresh = CoachEngine.briefing(for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar)

        #expect(tired.readiness.score < fresh.readiness.score)
        #expect(tired.session!.totalSets < fresh.session!.totalSets)
    }

    @Test("La semaine de décharge tombe bien à la fin du bloc")
    func deloadWeekIsFlagged() {
        let program = program()
        let day = Fixtures.calendar.date(
            byAdding: .day, value: (program.plan.weekCount - 1) * 7, to: Fixtures.start
        )!
        let briefing = CoachEngine.briefing(for: program, history: .empty, on: day, calendar: Fixtures.calendar)
        #expect(briefing.isDeloadWeek)
        #expect(briefing.weekIndex == program.plan.weekCount)
    }

    @Test("Le programme complet contient tout ce dont l'app a besoin")
    func programIsComplete() {
        let program = program()
        #expect(program.plan.weekCount >= 4)
        #expect(program.nutrition.calories > 1_200)
        #expect(!program.plan.rationale.isEmpty)
        #expect(program.metrics.tdee > program.metrics.bmr)
    }
}

@Suite("Bilan hebdomadaire et adaptation")
struct AdaptationTests {

    /// Runs one full week, logging every session exactly as prescribed.
    private func perfectWeek(
        profile: UserProfile = Fixtures.intermediate(daysPerWeek: 4)
    ) -> (CoachingProgram, TrainingHistory) {
        let program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        var history = TrainingHistory()
        for offset in 0..<7 {
            let day = Fixtures.calendar.date(byAdding: .day, value: offset, to: Fixtures.start)!
            let briefing = CoachEngine.briefing(for: program, history: history, on: day, calendar: Fixtures.calendar)
            guard let session = briefing.session else { continue }
            history.sessions.append(Fixtures.perfectSession(session, on: day))
        }
        return (program, history)
    }

    @Test("Une semaine complète est reconnue comme telle")
    func fullAdherence() {
        let (program, history) = perfectWeek()
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.adherence == 1.0)
        #expect(review.setsCompleted == review.setsPlanned)
        #expect(review.insights.contains { $0.kind == .adherence && $0.severity == .info })
    }

    @Test("Une semaine à moitié faite déclenche un avertissement, pas un reproche")
    func lowAdherenceWarns() {
        let program = CoachEngine.buildProgram(
            for: Fixtures.intermediate(daysPerWeek: 4), startingOn: Fixtures.start, calendar: Fixtures.calendar
        )
        let first = program.plan.weeks[0].sessions[0]
        let history = TrainingHistory(sessions: [Fixtures.perfectSession(first, on: Fixtures.start)])
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.adherence < 0.6)
        #expect(review.insights.contains { $0.kind == .adherence && $0.severity == .warning })
    }

    @Test("Un poids qui monte trop vite en sèche fait baisser les calories")
    func caloriesFollowRealWeight() {
        let profile = Fixtures.intermediate(goal: .fatLoss, daysPerWeek: 4)
        var (program, history) = perfectWeek(profile: profile)
        program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)

        // Le poids grimpe alors qu'on visait une perte.
        history.bodyLogs = (0..<6).map { index in
            BodyLog(
                date: Fixtures.calendar.date(byAdding: .day, value: index * 4 - 20, to: Fixtures.start)!,
                weightKg: 78 + Double(index) * 0.3
            )
        }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.weightTrendKgPerWeek != nil)
        #expect(review.weightTrendKgPerWeek! > 0)
        #expect(review.calorieAdjustment < 0, "le coach devrait réduire les calories, obtenu \(review.calorieAdjustment)")
        #expect(review.insights.contains { $0.kind == .nutrition })
    }

    @Test("Trop peu de pesées et le coach demande des données plutôt que d'inventer")
    func asksForMoreDataInsteadOfGuessing() {
        let (program, history) = perfectWeek()
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.weightTrendKgPerWeek == nil)
        #expect(review.calorieAdjustment == 0)
        #expect(review.insights.contains { $0.kind == .bodyWeight && $0.severity == .suggestion })
    }

    @Test("Une semaine parfaite et bien récupérée ouvre la porte à plus de volume")
    func volumeGoesUpAfterAGoodWeek() {
        var (program, history) = perfectWeek()
        history.readiness = (0..<4).map { index in
            ReadinessCheck(
                date: Fixtures.calendar.date(byAdding: .day, value: index, to: Fixtures.start)!,
                sleepQuality: 5, soreness: 2, motivation: 5, stress: 2, sleepHours: 8
            )
        }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.volumeAdjustments.values.allSatisfy { $0 > 0 })
        #expect(review.insights.contains { $0.kind == .volume })
    }

    @Test("Une semaine épuisante déclenche une décharge anticipée")
    func exhaustionTriggersEarlyDeload() {
        let program = CoachEngine.buildProgram(
            for: Fixtures.intermediate(daysPerWeek: 4), startingOn: Fixtures.start, calendar: Fixtures.calendar
        )
        let weekStart = Fixtures.calendar.date(byAdding: .day, value: 14, to: Fixtures.start)!
        var history = TrainingHistory()
        for offset in 0..<4 {
            let day = Fixtures.calendar.date(byAdding: .day, value: offset, to: weekStart)!
            history.readiness.append(
                ReadinessCheck(date: day, sleepQuality: 1, soreness: 5, motivation: 1, stress: 5, sleepHours: 4)
            )
        }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 3, calendar: Fixtures.calendar)
        #expect(review.shouldDeload)
        #expect(review.insights.contains { $0.kind == .recovery && $0.severity == .warning })
    }

    @Test("Un exercice douloureux disparaît du bloc suivant")
    func painfulExercisesAreRetired() {
        let program = CoachEngine.buildProgram(
            for: Fixtures.intermediate(daysPerWeek: 4), startingOn: Fixtures.start, calendar: Fixtures.calendar
        )
        let session = program.plan.weeks[0].sessions[0]
        let painfulID = session.exercises[0].exerciseID
        var log = Fixtures.perfectSession(session, on: Fixtures.start)
        log.sets = log.sets.map { set in
            var copy = set
            if set.exerciseID == painfulID { copy.painFlag = true }
            return copy
        }
        let history = TrainingHistory(sessions: [log])

        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        #expect(review.painfulExerciseIDs.contains(painfulID))
        #expect(review.insights.contains { $0.kind == .technique && $0.severity == .warning })

        let nextStart = Fixtures.calendar.date(byAdding: .day, value: 35, to: Fixtures.start)!
        let next = CoachEngine.nextBlock(after: program, review: review, startingOn: nextStart, calendar: Fixtures.calendar)
        let ids = Set(next.plan.weeks.flatMap { $0.sessions.flatMap { $0.exercises.map(\.exerciseID) } })
        #expect(!ids.contains(painfulID), "\(painfulID) revient malgré la douleur signalée")
    }

    @Test("Le bloc suivant repart du poids réellement mesuré")
    func nextBlockUsesMeasuredWeight() {
        var (program, history) = perfectWeek()
        history.bodyLogs = (0..<6).map { index in
            BodyLog(
                date: Fixtures.calendar.date(byAdding: .day, value: index * 4 - 20, to: Fixtures.start)!,
                weightKg: 78 + Double(index) * 0.2
            )
        }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 1, calendar: Fixtures.calendar)
        let nextStart = Fixtures.calendar.date(byAdding: .day, value: 35, to: Fixtures.start)!
        let next = CoachEngine.nextBlock(after: program, review: review, startingOn: nextStart, calendar: Fixtures.calendar)
        #expect(next.profile.weightKg > program.profile.weightKg)
        #expect(next.profile.trainingMonths == program.profile.trainingMonths + 1)
        #expect(next.plan.startDate == Fixtures.calendar.startOfDay(for: nextStart))
    }

    @Test("Un bilan sur une semaine hors du bloc ne fait pas planter le coach")
    func reviewOutsideTheBlockIsSafe() {
        let (program, history) = perfectWeek()
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: 99, calendar: Fixtures.calendar)
        #expect(review.adherence == 0)
        #expect(review.insights.isEmpty)
    }
}
