import Foundation

/// Everything the coach produced from one profile.
public struct CoachingProgram: Sendable, Equatable {
    public let profile: UserProfile
    public let metrics: BodyMetrics
    public let nutrition: NutritionTarget
    public let plan: Mesocycle
    /// Weeks to the target weight at the prescribed rate, when a target exists.
    public let weeksToGoal: Int?
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
            weeksToGoal: NutritionEngine.weeksToTarget(profile: profile, target: nutrition)
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
            weeksToGoal: NutritionEngine.weeksToTarget(profile: profile, target: nutrition)
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
                loadDecisions: [:]
            )
        }

        guard let planned = scheduledSession(in: week, on: date, program: program, history: history, calendar: calendar) else {
            return TodayBriefing(
                date: date,
                state: .rest,
                weekIndex: weekIndex,
                isDeloadWeek: week.isDeload,
                readiness: verdict,
                nutrition: program.nutrition,
                loadDecisions: [:]
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
            loadDecisions: decisions
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

        let done = history
            .sessions(in: DateInterval(start: weekStart, end: weekEnd))
            .filter { !$0.skipped }

        if done.contains(where: { calendar.isDate($0.date, inSameDayAs: date) }) {
            return nil // already trained today
        }

        let completedIDs = Set(done.compactMap(\.plannedSessionID))
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
                        "Ajustement de \(review.calorieAdjustment > 0 ? "+" : "")\(review.calorieAdjustment) kcal issu de l'évolution réelle de ton poids sur le bloc précédent."
                    ]
                ),
                plan: next.plan,
                weeksToGoal: next.weeksToGoal
            )
        }

        return next
    }
}
