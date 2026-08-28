import Foundation

/// A single message from the coach, ranked so the app can show the two that matter.
public struct CoachInsight: Sendable, Equatable, Identifiable {
    public enum Severity: Int, Sendable, Comparable {
        case info = 0
        case suggestion = 1
        case warning = 2

        public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }
    }

    public enum Kind: String, Sendable {
        case adherence
        case volume
        case strength
        case bodyWeight
        case recovery
        case nutrition
        case technique
    }

    public let id: UUID
    public let kind: Kind
    public let severity: Severity
    public let title: String
    public let message: String

    public init(id: UUID = UUID(), kind: Kind, severity: Severity, title: String, message: String) {
        self.id = id
        self.kind = kind
        self.severity = severity
        self.title = title
        self.message = message
    }
}

/// What the coach concluded from the past week.
public struct WeeklyReview: Sendable, Equatable {
    /// Share of planned sessions actually completed, 0–1.
    public let adherence: Double
    /// Working sets logged versus planned.
    public let setsCompleted: Int
    public let setsPlanned: Int
    /// Estimated 1RM change per main lift over the review window, in kg.
    public let strengthTrend: [String: Double]
    /// Body-weight change per week, in kg. Nil when there is not enough data.
    public let weightTrendKgPerWeek: Double?
    /// Volume changes to carry into the next block, in sets per week.
    public let volumeAdjustments: [MuscleGroup: Int]
    /// Recommended change to daily calories.
    public let calorieAdjustment: Int
    /// Movements the athlete flagged as painful. The next block drops them.
    public let painfulExerciseIDs: [String]
    public let shouldDeload: Bool
    public let insights: [CoachInsight]
}

/// Compares what was planned to what happened and adjusts the next block.
public enum AdaptationEngine {

    public static func review(
        profile: UserProfile,
        plan: Mesocycle,
        history: TrainingHistory,
        nutrition: NutritionTarget,
        weekIndex: Int,
        calendar: Calendar = .current
    ) -> WeeklyReview {
        guard let week = plan.week(at: weekIndex),
              let weekStart = calendar.date(byAdding: .day, value: (weekIndex - 1) * 7, to: plan.startDate),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)
        else {
            return empty()
        }
        let interval = DateInterval(start: weekStart, end: weekEnd)
        let logged = history.sessions(in: interval).filter { !$0.skipped }

        // MARK: Adherence
        let plannedSessions = week.sessions.count
        let adherence = plannedSessions > 0 ? Double(logged.count) / Double(plannedSessions) : 0
        let setsPlanned = week.totalSets
        let setsCompleted = logged.reduce(0) { $0 + $1.sets.count }

        var insights: [CoachInsight] = []

        if adherence >= 1.0 {
            insights.append(CoachInsight(
                kind: .adherence,
                severity: .info,
                title: "Semaine complète",
                message: "\(logged.count) séances sur \(plannedSessions). C'est exactement ce qui fait la différence sur trois mois."
            ))
        } else if adherence < 0.6 {
            insights.append(CoachInsight(
                kind: .adherence,
                severity: .warning,
                title: "Moins de séances que prévu",
                message: "\(logged.count) séances sur \(plannedSessions). Avant de toucher au programme : est-ce que \(plannedSessions) séances par semaine est réaliste en ce moment ? Un plan à \(max(2, plannedSessions - 1)) séances que tu tiens vaut mieux."
            ))
        }

        // MARK: Strength
        var strengthTrend: [String: Double] = [:]
        for exerciseID in mainLiftIDs(in: plan) {
            let sets = history.sets(for: exerciseID)
            let points = sets.map { (date: $0.date, value: $0.estimatedOneRepMax) }
            if let slope = StrengthMath.trendPerDay(points) {
                strengthTrend[exerciseID] = slope * 7
            }
        }
        let stalledLifts = strengthTrend.filter { $0.value <= 0 }.keys.sorted()
        let progressingLifts = strengthTrend.filter { $0.value > 0.25 }.keys.sorted()

        if !progressingLifts.isEmpty {
            let names = progressingLifts.compactMap { ExerciseCatalog.exercise(id: $0)?.name }
            insights.append(CoachInsight(
                kind: .strength,
                severity: .info,
                title: "Ça progresse",
                message: "Ton 1RM estimé monte sur : \(names.joined(separator: ", ")). Ne change rien à ces mouvements."
            ))
        }
        if stalledLifts.count >= 2, adherence >= 0.75 {
            let names = stalledLifts.compactMap { ExerciseCatalog.exercise(id: $0)?.name }
            insights.append(CoachInsight(
                kind: .strength,
                severity: .suggestion,
                title: "Plateau sur plusieurs mouvements",
                message: "\(names.joined(separator: ", ")) stagnent alors que tu es assidu. C'est en général un signal de fatigue accumulée, pas de manque de volume."
            ))
        }

        // MARK: Body weight
        let bodyPoints = history.bodyLogs
            .filter { $0.date >= calendar.date(byAdding: .day, value: -28, to: weekEnd)! }
            .map { (date: $0.date, value: $0.weightKg) }
        let weightTrend = StrengthMath.trendPerDay(bodyPoints).map { $0 * 7 }

        var calorieAdjustment = 0
        if let trend = weightTrend, bodyPoints.count >= 4 {
            let target = nutrition.weeklyWeightChangeKg
            let error = trend - target
            // Only react to a drift big enough to be real rather than water weight.
            if abs(error) > max(0.15, abs(target) * 0.5) {
                // 7 700 kcal per kg, spread over the week.
                calorieAdjustment = Int((-error * 7_700 / 7 / 25).rounded()) * 25
                calorieAdjustment = calorieAdjustment.clamped(to: -400...400)
                let direction = calorieAdjustment > 0 ? "augmenter" : "réduire"
                insights.append(CoachInsight(
                    kind: .nutrition,
                    severity: .suggestion,
                    title: "Ajustement calorique",
                    message: "Ton poids évolue de \(formatSigned(trend)) kg/semaine alors qu'on visait \(formatSigned(target)). Je te propose de \(direction) de \(abs(calorieAdjustment)) kcal par jour."
                ))
            } else {
                insights.append(CoachInsight(
                    kind: .bodyWeight,
                    severity: .info,
                    title: "Poids sur la trajectoire",
                    message: "\(formatSigned(trend)) kg/semaine : tu es dans la fenêtre visée. On ne touche à rien."
                ))
            }
        } else if bodyPoints.count < 4 {
            insights.append(CoachInsight(
                kind: .bodyWeight,
                severity: .suggestion,
                title: "Pèse-toi plus souvent",
                message: "Il me faut au moins quatre pesées sur quatre semaines pour distinguer une vraie tendance des variations d'eau. Le matin, à jeun, c'est le plus fiable."
            ))
        }

        // MARK: Recovery
        let weekReadiness = history.readiness.filter { interval.contains($0.date) }
        let painSessions = logged.filter(\.hasPainFlag)
        var shouldDeload = week.isDeload

        let painfulExerciseIDs = Set(painSessions.flatMap(\.sets).filter(\.painFlag).map(\.exerciseID)).sorted()
        if !painfulExerciseIDs.isEmpty {
            let names = painfulExerciseIDs.compactMap { ExerciseCatalog.exercise(id: $0)?.name }.sorted()
            insights.append(CoachInsight(
                kind: .technique,
                severity: .warning,
                title: "Douleur signalée",
                message: "Tu as signalé une douleur sur : \(names.joined(separator: ", ")). Ces mouvements passent en charge réduite. Si ça revient la semaine prochaine, je les remplace."
            ))
        }

        let averageReadiness = weekReadiness.isEmpty
            ? nil
            : weekReadiness.map { Double(ReadinessEngine.verdict(for: $0, profile: profile).score) }
                .reduce(0, +) / Double(weekReadiness.count)

        if let average = averageReadiness, average < 50, weekIndex >= 3 {
            shouldDeload = true
            insights.append(CoachInsight(
                kind: .recovery,
                severity: .warning,
                title: "Décharge anticipée",
                message: "Ta forme moyenne est à \(Int(average))/100 depuis une semaine. On avance la décharge : ce n'est pas un recul, c'est ce qui permet à la progression de reprendre."
            ))
        }

        // MARK: Volume adjustment for the next block
        var volumeAdjustments: [MuscleGroup: Int] = [:]
        let completionRate = setsPlanned > 0 ? Double(setsCompleted) / Double(setsPlanned) : 0

        if completionRate >= 0.9 && adherence >= 0.9 && (averageReadiness ?? 70) >= 60 && stalledLifts.count < 2 {
            for muscle in MuscleGroup.primary {
                volumeAdjustments[muscle] = 2
            }
            insights.append(CoachInsight(
                kind: .volume,
                severity: .suggestion,
                title: "On peut monter le volume",
                message: "Tu as terminé \(Int(completionRate * 100)) % des séries prévues en récupérant bien. Le prochain bloc ajoutera 2 séries par semaine sur les gros groupes."
            ))
        } else if completionRate < 0.7 || (averageReadiness ?? 70) < 45 {
            for muscle in MuscleGroup.primary {
                volumeAdjustments[muscle] = -2
            }
            insights.append(CoachInsight(
                kind: .volume,
                severity: .suggestion,
                title: "On réduit le volume",
                message: "Le volume prévu n'est pas absorbé. Le prochain bloc retire 2 séries par semaine sur les gros groupes — moins de séries réellement dures valent mieux que plus de séries bâclées."
            ))
        }

        return WeeklyReview(
            adherence: adherence,
            setsCompleted: setsCompleted,
            setsPlanned: setsPlanned,
            strengthTrend: strengthTrend,
            weightTrendKgPerWeek: weightTrend,
            volumeAdjustments: volumeAdjustments,
            calorieAdjustment: calorieAdjustment,
            painfulExerciseIDs: painfulExerciseIDs,
            shouldDeload: shouldDeload,
            insights: insights.sorted { $0.severity > $1.severity }
        )
    }

    /// The compound movements worth tracking a strength trend on.
    static func mainLiftIDs(in plan: Mesocycle) -> [String] {
        var ids: [String] = []
        for week in plan.weeks {
            for session in week.sessions {
                for prescription in session.exercises.prefix(2) {
                    guard let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID),
                          exercise.isCompound,
                          exercise.loadFactor > 0,
                          !ids.contains(exercise.id)
                    else { continue }
                    ids.append(exercise.id)
                }
            }
        }
        return ids
    }

    static func empty() -> WeeklyReview {
        WeeklyReview(
            adherence: 0,
            setsCompleted: 0,
            setsPlanned: 0,
            strengthTrend: [:],
            weightTrendKgPerWeek: nil,
            volumeAdjustments: [:],
            calorieAdjustment: 0,
            painfulExerciseIDs: [],
            shouldDeload: false,
            insights: []
        )
    }

    static func formatSigned(_ value: Double) -> String {
        let text = String(format: "%+.2f", value)
        return text.replacingOccurrences(of: ".", with: ",")
    }
}
