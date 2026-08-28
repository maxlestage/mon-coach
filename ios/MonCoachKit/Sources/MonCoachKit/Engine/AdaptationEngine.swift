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
    public let title: LocalizedText
    public let message: LocalizedText

    public init(
        id: UUID = UUID(),
        kind: Kind,
        severity: Severity,
        title: LocalizedText,
        message: LocalizedText
    ) {
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
                title: LocalizedText(fr: "Semaine complète", en: "Full week", es: "Semana completa"),
                message: LocalizedText(
                    fr: "\(logged.count) séances sur \(plannedSessions). C'est exactement ce qui fait la différence sur trois mois.",
                    en: "\(logged.count) sessions out of \(plannedSessions). This is exactly what makes the difference over three months.",
                    es: "\(logged.count) sesiones de \(plannedSessions). Esto es justo lo que marca la diferencia en tres meses."
                )
            ))
        } else if adherence < 0.6 {
            insights.append(CoachInsight(
                kind: .adherence,
                severity: .warning,
                title: LocalizedText(fr: "Moins de séances que prévu", en: "Fewer sessions than planned", es: "Menos sesiones de las previstas"),
                message: LocalizedText(
                    fr: "\(logged.count) séances sur \(plannedSessions). Avant de toucher au programme : est-ce que \(plannedSessions) séances par semaine est réaliste en ce moment ? Un plan à \(max(2, plannedSessions - 1)) séances que tu tiens vaut mieux.",
                    en: "\(logged.count) sessions out of \(plannedSessions). Before changing the programme: is \(plannedSessions) sessions a week realistic right now? A \(max(2, plannedSessions - 1))-session plan you actually keep is worth more.",
                    es: "\(logged.count) sesiones de \(plannedSessions). Antes de tocar el programa: ¿son \(plannedSessions) sesiones semanales realistas ahora mismo? Vale más un plan de \(max(2, plannedSessions - 1)) sesiones que sí cumplas."
                )
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
            let names = progressingLifts.compactMap { ExerciseCatalog.exercise(id: $0)?.name }.joined(separator: ", ")
            insights.append(CoachInsight(
                kind: .strength,
                severity: .info,
                title: LocalizedText(fr: "Ça progresse", en: "Moving up", es: "Va progresando"),
                message: LocalizedText(
                    fr: "Ton 1RM estimé monte sur : \(names.fr). Ne change rien à ces mouvements.",
                    en: "Your estimated 1RM is rising on: \(names.en). Change nothing about these movements.",
                    es: "Tu 1RM estimado sube en: \(names.es). No cambies nada en estos movimientos."
                )
            ))
        }
        if stalledLifts.count >= 2, adherence >= 0.75 {
            let names = stalledLifts.compactMap { ExerciseCatalog.exercise(id: $0)?.name }.joined(separator: ", ")
            insights.append(CoachInsight(
                kind: .strength,
                severity: .suggestion,
                title: LocalizedText(fr: "Plateau sur plusieurs mouvements", en: "Plateau on several lifts", es: "Estancamiento en varios movimientos"),
                message: LocalizedText(
                    fr: "\(names.fr) stagnent alors que tu es assidu. C'est en général un signal de fatigue accumulée, pas de manque de volume.",
                    en: "\(names.en) have stalled even though you are showing up. That usually signals accumulated fatigue, not a lack of volume.",
                    es: "\(names.es) se han estancado aunque estás siendo constante. Suele ser señal de fatiga acumulada, no de falta de volumen."
                )
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
                let direction = calorieAdjustment > 0
                    ? LocalizedText(fr: "augmenter", en: "increase", es: "aumentar")
                    : LocalizedText(fr: "réduire", en: "reduce", es: "reducir")
                insights.append(CoachInsight(
                    kind: .nutrition,
                    severity: .suggestion,
                    title: LocalizedText(fr: "Ajustement calorique", en: "Calorie adjustment", es: "Ajuste calórico"),
                    message: LocalizedText(
                        fr: "Ton poids évolue de \(formatSigned(trend)) kg/semaine alors qu'on visait \(formatSigned(target)). Je te propose de \(direction.fr) de \(abs(calorieAdjustment)) kcal par jour.",
                        en: "Your weight is moving \(formatSigned(trend)) kg/week when we were aiming for \(formatSigned(target)). I suggest you \(direction.en) by \(abs(calorieAdjustment)) kcal a day.",
                        es: "Tu peso evoluciona \(formatSigned(trend)) kg/semana cuando buscábamos \(formatSigned(target)). Te propongo \(direction.es) \(abs(calorieAdjustment)) kcal al día."
                    )
                ))
            } else {
                insights.append(CoachInsight(
                    kind: .bodyWeight,
                    severity: .info,
                    title: LocalizedText(fr: "Poids sur la trajectoire", en: "Weight on track", es: "Peso en la trayectoria"),
                    message: LocalizedText(
                        fr: "\(formatSigned(trend)) kg/semaine : tu es dans la fenêtre visée. On ne touche à rien.",
                        en: "\(formatSigned(trend)) kg/week: you are inside the window we aimed for. Nothing changes.",
                        es: "\(formatSigned(trend)) kg/semana: estás dentro de la ventana buscada. No tocamos nada."
                    )
                ))
            }
        } else if bodyPoints.count < 4 {
            insights.append(CoachInsight(
                kind: .bodyWeight,
                severity: .suggestion,
                title: LocalizedText(fr: "Pèse-toi plus souvent", en: "Weigh yourself more often", es: "Pésate más a menudo"),
                message: LocalizedText(
                    fr: "Il me faut au moins quatre pesées sur quatre semaines pour distinguer une vraie tendance des variations d'eau. Le matin, à jeun, c'est le plus fiable.",
                    en: "I need at least four weigh-ins over four weeks to tell a real trend from water swings. First thing in the morning, fasted, is the most reliable.",
                    es: "Necesito al menos cuatro pesajes en cuatro semanas para distinguir una tendencia real de las variaciones de agua. Por la mañana, en ayunas, es lo más fiable."
                )
            ))
        }

        // MARK: Recovery
        let weekReadiness = history.readiness.filter { interval.contains($0.date) }
        let painSessions = logged.filter(\.hasPainFlag)
        var shouldDeload = week.isDeload

        let painfulExerciseIDs = Set(painSessions.flatMap(\.sets).filter(\.painFlag).map(\.exerciseID)).sorted()
        if !painfulExerciseIDs.isEmpty {
            let names = painfulExerciseIDs
                .compactMap { ExerciseCatalog.exercise(id: $0)?.name }
                .sortedStably()
                .joined(separator: ", ")
            insights.append(CoachInsight(
                kind: .technique,
                severity: .warning,
                title: LocalizedText(fr: "Douleur signalée", en: "Pain reported", es: "Dolor señalado"),
                message: LocalizedText(
                    fr: "Tu as signalé une douleur sur : \(names.fr). Ces mouvements passent en charge réduite. Si ça revient la semaine prochaine, je les remplace.",
                    en: "You flagged pain on: \(names.en). Those movements move to reduced load. If it comes back next week, I replace them.",
                    es: "Has señalado dolor en: \(names.es). Esos movimientos pasan a carga reducida. Si vuelve la semana que viene, los sustituyo."
                )
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
                title: LocalizedText(fr: "Décharge anticipée", en: "Deload brought forward", es: "Descarga adelantada"),
                message: LocalizedText(
                    fr: "Ta forme moyenne est à \(Int(average))/100 depuis une semaine. On avance la décharge : ce n'est pas un recul, c'est ce qui permet à la progression de reprendre.",
                    en: "Your average readiness has been \(Int(average))/100 for a week. We are bringing the deload forward: that is not a step back, it is what lets progress restart.",
                    es: "Tu forma media lleva una semana en \(Int(average))/100. Adelantamos la descarga: no es un retroceso, es lo que permite que la progresión se reanude."
                )
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
                title: LocalizedText(fr: "On peut monter le volume", en: "We can raise the volume", es: "Podemos subir el volumen"),
                message: LocalizedText(
                    fr: "Tu as terminé \(Int(completionRate * 100)) % des séries prévues en récupérant bien. Le prochain bloc ajoutera 2 séries par semaine sur les gros groupes.",
                    en: "You finished \(Int(completionRate * 100)) % of the planned sets while recovering well. The next block adds 2 sets a week on the big groups.",
                    es: "Has completado el \(Int(completionRate * 100)) % de las series previstas recuperando bien. El próximo bloque añade 2 series semanales en los grupos grandes."
                )
            ))
        } else if completionRate < 0.7 || (averageReadiness ?? 70) < 45 {
            for muscle in MuscleGroup.primary {
                volumeAdjustments[muscle] = -2
            }
            insights.append(CoachInsight(
                kind: .volume,
                severity: .suggestion,
                title: LocalizedText(fr: "On réduit le volume", en: "We are cutting the volume", es: "Reducimos el volumen"),
                message: LocalizedText(
                    fr: "Le volume prévu n'est pas absorbé. Le prochain bloc retire 2 séries par semaine sur les gros groupes — moins de séries réellement dures valent mieux que plus de séries bâclées.",
                    en: "The planned volume is not being absorbed. The next block removes 2 sets a week on the big groups — fewer genuinely hard sets beat more sloppy ones.",
                    es: "El volumen previsto no se está asimilando. El próximo bloque quita 2 series semanales en los grupos grandes: valen más pocas series realmente duras que muchas mal hechas."
                )
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
