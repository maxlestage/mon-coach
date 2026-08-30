import Foundation

/// Everything the coach produced from one profile.
public struct CoachingProgram: Sendable, Equatable {
    public let profile: UserProfile
    public let metrics: BodyMetrics
    public let nutrition: NutritionTarget
    public let plan: Mesocycle
    /// Weeks to the target weight at the prescribed rate, when a target exists.
    public let weeksToGoal: Int?
    /// The running block, when the athlete runs. Nil otherwise, and every
    /// running screen stays hidden.
    public let runningBlock: RunningBlock?
}

/// What the app shows on the home screen for a given day.
public struct TodayBriefing: Sendable, Equatable {
    public enum State: Sendable, Equatable {
        case training(PlannedSession)
        case rest
        case blockFinished
    }

    public let date: Date
    public let state: State
    public let weekIndex: Int?
    public let isDeloadWeek: Bool
    public let readiness: ReadinessVerdict
    public let nutrition: NutritionTarget
    /// Load decisions per exercise, keyed by prescription id, so the UI can
    /// explain every number it shows.
    public let loadDecisions: [UUID: LoadDecision]
    /// The run scheduled today, if any. A day can carry both a lift and a
    /// run: they are two different asks, not two states of one.
    public let plannedRun: PlannedRun?
    /// The run already recorded today, if the athlete has been out.
    public let recordedRun: ActivityLog?
    /// What to eat today, built around the same macros as `nutrition`.
    public let food: DayPlan
    /// On a rest day, the session coming next — so the home screen can say
    /// what is ahead instead of just « rien aujourd'hui ». Nil on training
    /// days: today's session already lives in `state`, and showing the same
    /// list twice would only pad the screen.
    public let nextSession: PlannedSession?

    public var session: PlannedSession? {
        if case let .training(session) = state { return session }
        return nil
    }
}

/// The single entry point the app talks to.
///
/// Every method is a pure function of its inputs: the same profile and the
/// same history always produce the same plan, which is what makes the whole
/// thing testable and what lets the app run entirely offline.
public enum CoachEngine {

    // MARK: - Building a program

    public static func buildProgram(
        for profile: UserProfile,
        startingOn startDate: Date = Date(),
        calendar: Calendar = .current
    ) -> CoachingProgram {
        let metrics = BodyMetricsEngine.metrics(for: profile, on: startDate)
        let nutrition = NutritionEngine.target(for: profile, metrics: metrics)
        let plan = PlanBuilder.build(for: profile, startingOn: startDate, calendar: calendar)
        return CoachingProgram(
            profile: profile,
            metrics: metrics,
            nutrition: nutrition,
            plan: plan,
            weeksToGoal: NutritionEngine.weeksToTarget(profile: profile, target: nutrition),
            runningBlock: runningBlock(for: profile, plan: plan, on: startDate, calendar: calendar)
        )
    }

    /// The running block that goes with a strength plan.
    ///
    /// Hard runs are steered away from the days the strength plan expects to
    /// use, which is what `shouldTrain` already decides for the lifting side.
    static func runningBlock(
        for profile: UserProfile,
        plan: Mesocycle,
        on date: Date,
        calendar: Calendar
    ) -> RunningBlock? {
        guard let running = profile.running else { return nil }
        let sessionsPerWeek = plan.week(at: 1)?.sessions.count ?? profile.daysPerWeek
        let strengthDays = Set(
            (0..<7).filter { shouldTrain(daysElapsed: $0, sessionsPerWeek: sessionsPerWeek) }
        )
        return RunPlanner.block(
            profile: profile,
            running: running,
            weekCount: plan.weeks.count,
            strengthDays: strengthDays,
            today: date,
            calendar: calendar
        )
    }

    /// Rebuilds a program around a plan that was already generated.
    ///
    /// Persistence stores the profile and the mesocycle, never the derived
    /// numbers: metrics and macros are cheap to recompute and must never
    /// drift from the formulas. The plan itself is stored rather than rebuilt
    /// because its session identifiers are what the training log points at.
    public static func program(
        profile: UserProfile,
        plan: Mesocycle,
        on date: Date = Date()
    ) -> CoachingProgram {
        let metrics = BodyMetricsEngine.metrics(for: profile, on: date)
        let nutrition = NutritionEngine.target(for: profile, metrics: metrics)
        return CoachingProgram(
            profile: profile,
            metrics: metrics,
            nutrition: nutrition,
            plan: plan,
            weeksToGoal: NutritionEngine.weeksToTarget(profile: profile, target: nutrition),
            runningBlock: runningBlock(for: profile, plan: plan, on: plan.startDate, calendar: .current)
        )
    }

    // MARK: - A day

    public static func briefing(
        for program: CoachingProgram,
        history: TrainingHistory,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> TodayBriefing {
        let check = history.readiness(on: date, calendar: calendar)
        let verdict = ReadinessEngine.verdict(for: check, profile: program.profile)

        guard let weekIndex = program.plan.weekIndex(for: date, calendar: calendar),
              let week = program.plan.week(at: weekIndex)
        else {
            return TodayBriefing(
                date: date,
                state: .blockFinished,
                weekIndex: nil,
                isDeloadWeek: false,
                readiness: verdict,
                nutrition: program.nutrition,
                loadDecisions: [:],
                plannedRun: nil,
                recordedRun: history.run(on: date, calendar: calendar),
                food: dayPlan(for: program, on: date, trains: false, runs: false, calendar: calendar),
                nextSession: nil
            )
        }

        let plannedRun = scheduledRun(for: program, weekIndex: weekIndex, on: date, calendar: calendar)
        let recordedRun = history.run(on: date, calendar: calendar)

        guard let planned = scheduledSession(in: week, on: date, program: program, history: history, calendar: calendar) else {
            return TodayBriefing(
                date: date,
                state: .rest,
                weekIndex: weekIndex,
                isDeloadWeek: week.isDeload,
                readiness: verdict,
                nutrition: program.nutrition,
                loadDecisions: [:],
                plannedRun: plannedRun,
                recordedRun: recordedRun,
                food: dayPlan(
                    for: program,
                    on: date,
                    trains: false,
                    runs: plannedRun != nil,
                    calendar: calendar
                ),
                nextSession: upcomingSession(
                    in: week,
                    program: program,
                    history: history,
                    calendar: calendar
                )
            )
        }

        let (loaded, decisions) = prescribeLoads(
            for: planned,
            profile: program.profile,
            history: history,
            isDeloadWeek: week.isDeload
        )
        let adjusted = ReadinessEngine.apply(verdict, to: loaded, increment: program.profile.loadIncrement)

        return TodayBriefing(
            date: date,
            state: .training(adjusted),
            weekIndex: weekIndex,
            isDeloadWeek: week.isDeload,
            readiness: verdict,
            nutrition: program.nutrition,
            loadDecisions: decisions,
            plannedRun: plannedRun,
            recordedRun: recordedRun,
            food: dayPlan(for: program, on: date, trains: true, runs: plannedRun != nil, calendar: calendar),
            nextSession: nil
        )
    }

    /// The food plan for a given day.
    ///
    /// The day index feeds the planner's rotation, so the week actually
    /// varies instead of serving the same four meals seven times.
    static func dayPlan(
        for program: CoachingProgram,
        on date: Date,
        trains: Bool,
        runs: Bool,
        calendar: Calendar
    ) -> DayPlan {
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: program.plan.startDate),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        return MealPlanner.day(
            target: program.nutrition,
            diet: program.profile.dietPreference,
            dayIndex: ((elapsed % 7) + 7) % 7,
            mealsPerDay: program.profile.mealCount,
            excluding: program.profile.excludedFoods,
            trainsToday: trains,
            runsToday: runs
        )
    }

    /// Which session of the week belongs to this day.
    ///
    /// Sessions are not pinned to weekdays: the athlete gets the next session
    /// they have not done yet, as long as they did not already train today.
    /// A plan that survives a moved gym day is a plan people keep.
    static func scheduledSession(
        in week: PlannedWeek,
        on date: Date,
        program: CoachingProgram,
        history: TrainingHistory,
        calendar: Calendar
    ) -> PlannedSession? {
        let weekStart = calendar.date(
            byAdding: .day,
            value: (week.index - 1) * 7,
            to: program.plan.startDate
        ) ?? program.plan.startDate
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }

        let logged = history.sessions(in: DateInterval(start: weekStart, end: weekEnd))

        // A day the athlete already trained, or explicitly declared off, stays
        // closed. Both count here: re-proposing a session someone just told us
        // they cannot do is the fastest way to get an app deleted.
        if logged.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return nil
        }

        // Only sessions actually performed are struck off the week. A skipped
        // day costs the day, not the session: it comes back tomorrow.
        let completedIDs = Set(
            logged.filter { !$0.skipped }.compactMap(\.plannedSessionID)
        )
        let remaining = week.sessions.filter { !completedIDs.contains($0.id) }
        guard !remaining.isEmpty else { return nil }

        // Spread what is left over the days that are left, so someone who
        // misses Monday is not asked to train five days straight.
        let daysElapsed = calendar.dateComponents([.day], from: weekStart, to: date).day ?? 0
        let daysLeft = max(1, 7 - daysElapsed)
        return remaining.count >= daysLeft || shouldTrain(daysElapsed: daysElapsed, sessionsPerWeek: week.sessions.count)
            ? remaining.first
            : nil
    }

    /// The next session the athlete has not done yet — what a rest day can
    /// announce. Today's gates (already trained, spacing across the week) are
    /// deliberately ignored: the question is not « should you train today? »
    /// but « what is coming? ». When the week is exhausted, the first session
    /// of the next week answers it.
    ///
    /// The loads are not prescribed here, and the screen must not show any:
    /// they are decided the day itself, from that morning's check-in.
    static func upcomingSession(
        in week: PlannedWeek,
        program: CoachingProgram,
        history: TrainingHistory,
        calendar: Calendar
    ) -> PlannedSession? {
        let weekStart = calendar.date(
            byAdding: .day,
            value: (week.index - 1) * 7,
            to: program.plan.startDate
        ) ?? program.plan.startDate
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { return nil }
        let logged = history.sessions(in: DateInterval(start: weekStart, end: weekEnd))
        let completedIDs = Set(
            logged.filter { !$0.skipped }.compactMap(\.plannedSessionID)
        )
        if let next = week.sessions.first(where: { !completedIDs.contains($0.id) }) {
            return next
        }
        return program.plan.week(at: week.index + 1)?.sessions.first
    }

    /// The run prescribed for a given day, if the athlete runs.
    ///
    /// Run days are anchored on the plan's own week, so day 0 is the first
    /// day of the block rather than a Monday the athlete never agreed to.
    static func scheduledRun(
        for program: CoachingProgram,
        weekIndex: Int,
        on date: Date,
        calendar: Calendar
    ) -> PlannedRun? {
        guard let block = program.runningBlock,
              weekIndex >= 1, weekIndex <= block.weeks.count
        else { return nil }
        let weekStart = calendar.date(
            byAdding: .day,
            value: (weekIndex - 1) * 7,
            to: program.plan.startDate
        ) ?? program.plan.startDate
        let dayIndex = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: weekStart),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        guard (0..<7).contains(dayIndex) else { return nil }
        return block.weeks[weekIndex - 1].runs.first { $0.dayIndex == dayIndex }
    }

    /// Evenly spaced training days across the week.
    static func shouldTrain(daysElapsed: Int, sessionsPerWeek: Int) -> Bool {
        guard sessionsPerWeek > 0 else { return false }
        let spacing = 7.0 / Double(sessionsPerWeek)
        let slot = Int(Double(daysElapsed) / spacing)
        let slotStart = Int((Double(slot) * spacing).rounded())
        return slotStart == daysElapsed
    }

    // MARK: - Loads

    /// Fills in every suggested load for a session, and returns why.
    public static func prescribeLoads(
        for session: PlannedSession,
        profile: UserProfile,
        history: TrainingHistory,
        isDeloadWeek: Bool
    ) -> (session: PlannedSession, decisions: [UUID: LoadDecision]) {
        var decisions: [UUID: LoadDecision] = [:]
        var exercises: [ExercisePrescription] = []

        for prescription in session.exercises {
            guard let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID),
                  let topSet = prescription.sets.first
            else {
                exercises.append(prescription)
                continue
            }

            let decision = ProgressionEngine.decide(
                exercise: exercise,
                prescription: topSet,
                history: history,
                profile: profile,
                isDeloadWeek: isDeloadWeek
            )
            decisions[prescription.id] = decision

            var copy = prescription
            copy.sets = prescription.sets.map { set in
                var updated = set
                if let load = decision.loadKg {
                    // Back-off sets run lighter than the top set.
                    updated.suggestedLoadKg = set.isBackOff
                        ? StrengthMath.round(load * 0.88, to: profile.loadIncrement)
                        : load
                }
                return updated
            }
            exercises.append(copy)
        }

        var loaded = session
        loaded.exercises = exercises
        return (loaded, decisions)
    }

    // MARK: - Weekly review

    public static func weeklyReview(
        program: CoachingProgram,
        history: TrainingHistory,
        weekIndex: Int,
        calendar: Calendar = .current
    ) -> WeeklyReview {
        AdaptationEngine.review(
            profile: program.profile,
            plan: program.plan,
            history: history,
            nutrition: program.nutrition,
            weekIndex: weekIndex,
            calendar: calendar
        )
    }

    /// Builds the next block, folding in what the review learned.
    ///
    /// Volume changes are applied by nudging the profile the plan is built
    /// from, which keeps a single source of truth: there is no second,
    /// divergent copy of the athlete's settings.
    public static func nextBlock(
        after program: CoachingProgram,
        review: WeeklyReview,
        startingOn startDate: Date,
        calendar: Calendar = .current
    ) -> CoachingProgram {
        var profile = program.profile

        // Four weeks of training is roughly one month of training age.
        profile.trainingMonths += 1
        profile.experience = max(profile.experience, .inferred(fromTrainingMonths: profile.trainingMonths))

        // A body-weight trend that is real should update the profile, since
        // every calorie and load estimate downstream depends on it.
        if let trend = review.weightTrendKgPerWeek {
            profile.weightKg = max(35, profile.weightKg + trend * 4)
        }

        // Movements that hurt get retired rather than repeated.
        profile.dislikedExerciseIDs.formUnion(review.painfulExerciseIDs)

        var next = buildProgram(for: profile, startingOn: startDate, calendar: calendar)

        if review.calorieAdjustment != 0 {
            // Rebuilding recomputes nutrition from the new body weight; the
            // review's own adjustment is layered on top of that.
            let base = next.nutrition
            let calories = base.calories + review.calorieAdjustment
            let carbs = max(30, (Double(calories) - Double(base.proteinG) * 4 - Double(base.fatG) * 9) / 4)
            let signed = "\(review.calorieAdjustment > 0 ? "+" : "")\(review.calorieAdjustment)"
            next = CoachingProgram(
                profile: next.profile,
                metrics: next.metrics,
                nutrition: NutritionTarget(
                    calories: calories,
                    proteinG: base.proteinG,
                    fatG: base.fatG,
                    carbsG: Int(carbs.rounded()),
                    weeklyWeightChangeKg: base.weeklyWeightChangeKg,
                    maintenanceCalories: base.maintenanceCalories,
                    rationale: base.rationale + [
                        LocalizedText(
                            fr: "Ajustement de \(signed) kcal issu de l'évolution réelle de ton poids sur le bloc précédent.",
                            en: "A \(signed) kcal adjustment, taken from how your weight actually moved over the previous block.",
                            es: "Ajuste de \(signed) kcal a partir de cómo evolucionó realmente tu peso en el bloque anterior."
                        )
                    ]
                ),
                plan: next.plan,
                weeksToGoal: next.weeksToGoal,
                runningBlock: next.runningBlock
            )
        }

        return next
    }
}
