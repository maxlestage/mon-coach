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

    @Test("Un jour de repos annonce la prochaine séance, exercices compris")
    func restDayAnnouncesTheNextSession() {
        let program = program()
        let first = try! #require(
            CoachEngine.briefing(for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar).session
        )
        let history = TrainingHistory(sessions: [Fixtures.perfectSession(first, on: Fixtures.start)])

        // Le même jour, une fois la séance faite : repos — mais pas muet.
        let after = CoachEngine.briefing(
            for: program, history: history, on: Fixtures.start, calendar: Fixtures.calendar
        )
        #expect(after.state == .rest)
        let next = try! #require(after.nextSession)
        #expect(next.id != first.id, "la séance annoncée est celle qu'on vient de faire")
        #expect(!next.exercises.isEmpty, "une séance annoncée sans exercices n'annonce rien")

        // Un jour d'entraînement, en revanche, n'annonce rien de plus : la
        // séance du jour est déjà là.
        let trainingDay = CoachEngine.briefing(
            for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar
        )
        #expect(trainingDay.nextSession == nil)
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

@Suite("La semaine se remplit par le début")
struct WeekShapeTests {

    private func program(daysPerWeek: Int) -> CoachingProgram {
        CoachEngine.buildProgram(
            for: Fixtures.intermediate(daysPerWeek: daysPerWeek),
            startingOn: Fixtures.start,
            calendar: Fixtures.calendar
        )
    }

    private func day(_ offset: Int) -> Date {
        Fixtures.calendar.date(byAdding: .day, value: offset, to: Fixtures.start)!
    }

    /// L'historique d'un athlète qui a fait ses séances, une par jour depuis
    /// le début de la semaine.
    ///
    /// Sans lui, la règle de rattrapage rend une séance tous les jours — et
    /// elle a raison : quelqu'un qui n'a rien fait de la semaine est en
    /// retard, pas au repos.
    private func weekDone(_ program: CoachingProgram, count: Int) -> TrainingHistory {
        var history = TrainingHistory.empty
        let sessions = program.plan.week(at: 1)?.sessions ?? []
        for (offset, session) in sessions.prefix(count).enumerated() {
            history.sessions.append(
                SessionLog(plannedSessionID: session.id, date: day(offset), durationMinutes: 45)
            )
        }
        return history
    }

    @Test("Six séances font six jours pleins, et le repos tombe le dernier")
    func restLandsOnTheLastDay() {
        let program = program(daysPerWeek: 6)
        var history = TrainingHistory.empty
        let sessions = program.plan.week(at: 1)?.sessions ?? []
        #expect(sessions.count == 6)

        // Chaque jour propose une séance, et on la fait avant de passer au
        // suivant : c'est la semaine telle qu'elle est vécue.
        for offset in 0..<6 {
            let briefing = CoachEngine.briefing(
                for: program, history: history, on: day(offset), calendar: Fixtures.calendar
            )
            let session = try! #require(
                briefing.session, Comment(rawValue: "jour \(offset) sans séance")
            )
            history.sessions.append(
                SessionLog(plannedSessionID: session.id, date: day(offset), durationMinutes: 45)
            )
        }

        let last = CoachEngine.briefing(
            for: program, history: history, on: day(6), calendar: Fixtures.calendar
        )
        #expect(last.state == .rest, "le septième jour doit être le repos")
        #expect(last.extras.isEmpty, "le vrai repos ne propose rien")
    }

    @Test("Les jours d'entraînement se suivent, sans trou au milieu")
    func trainingDaysAreConsecutive() {
        for daysPerWeek in 2...7 {
            let program = program(daysPerWeek: daysPerWeek)
            let sessions = program.plan.week(at: 1)?.sessions.count ?? 0
            let trains = (0..<7).map {
                CoachEngine.shouldTrain(daysElapsed: $0, sessionsPerWeek: sessions)
            }
            // Un seul basculement : vrai tant qu'on s'entraîne, faux ensuite.
            let flips = zip(trains, trains.dropFirst()).filter { $0 != $1 }.count
            #expect(flips <= 1, Comment(rawValue: "\(daysPerWeek) j/sem : \(trains)"))
            #expect(trains.first == true, "la semaine commence toujours par une séance")
        }
    }

    @Test("Un jour creux propose des exercices ; le dernier jour, non")
    func hollowDaysGetSomethingToDo() {
        // Quatre séances faites du lundi au jeudi : les jours 4 et 5 sont
        // creux, le 6 est le repos.
        let program = program(daysPerWeek: 4)
        let history = weekDone(program, count: 4)

        let hollow = CoachEngine.briefing(
            for: program, history: history, on: day(4), calendar: Fixtures.calendar
        )
        #expect(hollow.state == .rest)
        #expect(!hollow.extras.isEmpty, "un jour creux ne doit pas rester vide")
        #expect(hollow.extras.count == DailyExtras.dailyCount)

        let last = CoachEngine.briefing(
            for: program, history: history, on: day(6), calendar: Fixtures.calendar
        )
        #expect(last.state == .rest)
        #expect(last.extras.isEmpty, "le vrai repos ne propose rien")
    }

    @Test("Un jour de séance ne propose rien en plus")
    func trainingDaysCarryNoExtras() {
        let briefing = CoachEngine.briefing(
            for: program(daysPerWeek: 4), history: .empty,
            on: Fixtures.start, calendar: Fixtures.calendar
        )
        #expect(briefing.session != nil)
        #expect(briefing.extras.isEmpty)
    }
}

@Suite("Les exercices d'un jour creux")
struct DailyExtrasTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: Fixtures.start)!
    }

    @Test("Ils changent tous les jours, et jamais deux fois de suite les mêmes")
    func theyChangeEveryDay() {
        let profile = Fixtures.intermediate()
        var previous = Set<String>()
        for offset in 0..<45 {
            let today = Set(
                DailyExtras.ofTheDay(on: day(offset), profile: profile, calendar: calendar).map(\.id)
            )
            #expect(today.count == DailyExtras.dailyCount)
            #expect(
                today.isDisjoint(with: previous),
                Comment(rawValue: "jour \(offset) répète \(today.intersection(previous))")
            )
            previous = today
        }
    }

    @Test("On ne propose que ce que l'athlète peut faire")
    func onlyWhatTheAthleteCanDo() {
        var profile = Fixtures.intermediate()
        // Un salon : poids du corps et une paire d'haltères.
        profile.equipment = [.bodyweight, .dumbbell]
        profile.limitations = [.knee]
        for offset in 0..<30 {
            for exercise in DailyExtras.ofTheDay(on: day(offset), profile: profile, calendar: calendar) {
                #expect(exercise.isAvailable(with: profile.equipment), Comment(rawValue: exercise.id))
                #expect(!exercise.conflicts(with: profile.limitations), Comment(rawValue: exercise.id))
            }
        }
    }

    @Test("Un athlète sans rien du tout ne reçoit pas une liste vide")
    func bodyweightIsAlwaysEnough() {
        var profile = Fixtures.intermediate()
        profile.equipment = [.bodyweight]
        let picks = DailyExtras.ofTheDay(on: day(3), profile: profile, calendar: calendar)
        #expect(!picks.isEmpty, "il reste toujours des mouvements au poids du corps")
    }

    @Test("Les deux textes existent dans les trois langues")
    func textsAreTranslated() {
        #expect(DailyExtras.invitation.isComplete)
        #expect(DailyExtras.realRest.isComplete)
    }
}
