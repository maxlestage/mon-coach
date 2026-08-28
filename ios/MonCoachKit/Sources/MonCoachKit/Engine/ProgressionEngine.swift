import Foundation

/// What the coach decided to do with the load on a movement, and why.
public struct LoadDecision: Sendable, Equatable {
    public enum Action: String, Sendable {
        case start          // first exposure, no history
        case increase
        case hold
        case decrease
        case deload

        public var label: String {
            switch self {
            case .start: "Première fois"
            case .increase: "On monte"
            case .hold: "On garde"
            case .decrease: "On réduit"
            case .deload: "Décharge"
            }
        }
    }

    public let action: Action
    public let loadKg: Double?
    public let reason: String
}

/// Turns history into the next load prescription.
///
/// The model is double progression, autoregulated by RPE:
/// hit the top of the rep range on every set at or under the target RPE and
/// the load goes up; fall under the bottom of the range, or blow past the
/// target RPE, and it comes down.
public enum ProgressionEngine {

    /// Load step as a share of the current working weight. Small muscles
    /// cannot take a 2.5 kg jump the way a squat can.
    static func increment(for exercise: Exercise, profile: UserProfile) -> Double {
        exercise.isCompound ? 0.025 : 0.05
    }

    public static func decide(
        exercise: Exercise,
        prescription: SetPrescription,
        history: TrainingHistory,
        profile: UserProfile,
        isDeloadWeek: Bool
    ) -> LoadDecision {
        let previous = lastWorkingSets(for: exercise.id, history: history)

        guard !previous.isEmpty else {
            let seed = seedLoad(exercise: exercise, prescription: prescription, profile: profile)
            return LoadDecision(
                action: .start,
                loadKg: seed,
                reason: seed == nil
                    ? "Première exposition : choisis une charge que tu contrôles sur toutes les répétitions, on ajustera dès la prochaine séance."
                    : "Estimation de départ à partir de ton profil. Si c'est trop facile ou trop lourd, corrige — la séance suivante en tiendra compte."
            )
        }

        let lastLoad = previous.map(\.weightKg).max() ?? 0

        if isDeloadWeek {
            let load = StrengthMath.round(lastLoad * 0.6, to: profile.loadIncrement)
            return LoadDecision(
                action: .deload,
                loadKg: load,
                reason: "Semaine de décharge : 60 % de ta charge habituelle. Le but est de récupérer, pas de performer."
            )
        }

        // A pain flag outranks everything else the numbers might say.
        if previous.contains(where: \.painFlag) {
            let load = StrengthMath.round(lastLoad * 0.85, to: profile.loadIncrement)
            return LoadDecision(
                action: .decrease,
                loadKg: load,
                reason: "Tu as signalé une douleur articulaire la dernière fois : −15 % et on surveille. Si ça persiste, on changera d'exercice."
            )
        }

        let allHitTop = previous.allSatisfy { $0.reps >= prescription.repUpperBound }
        let averageRPE = previous.map(\.rpe).reduce(0, +) / Double(previous.count)
        let anyBelowRange = previous.contains { $0.reps < prescription.repLowerBound }

        if allHitTop && averageRPE <= prescription.targetRPE {
            let step = increment(for: exercise, profile: profile)
            let target = lastLoad * (1 + step)
            var load = StrengthMath.round(target, to: profile.loadIncrement)
            // Rounding must never produce a "progression" that stands still.
            if load <= lastLoad { load = lastLoad + profile.loadIncrement.stepKg }
            return LoadDecision(
                action: .increase,
                loadKg: load,
                reason: "Toutes les séries au sommet de la fourchette à RPE \(format(averageRPE)) : la charge monte à \(format(load)) kg."
            )
        }

        if anyBelowRange || averageRPE >= prescription.targetRPE + 1.5 {
            let load = StrengthMath.round(lastLoad * 0.92, to: profile.loadIncrement)
            return LoadDecision(
                action: .decrease,
                loadKg: min(load, lastLoad),
                reason: "Les répétitions sont tombées sous la fourchette : on recule de 8 % pour repartir sur des séries propres."
            )
        }

        return LoadDecision(
            action: .hold,
            loadKg: lastLoad,
            reason: "Même charge : ajoute des répétitions cette fois-ci. On montera quand toutes les séries atteindront \(prescription.repUpperBound)."
        )
    }

    /// The most recent session's working sets for a movement.
    static func lastWorkingSets(for exerciseID: String, history: TrainingHistory) -> [SetLog] {
        let sets = history.sets(for: exerciseID)
        guard let lastDate = sets.last?.date else { return [] }
        let calendar = Calendar.current
        return sets.filter { calendar.isDate($0.date, inSameDayAs: lastDate) }
    }

    /// First-exposure load, derived from a known 1RM, a related lift, or
    /// published strength standards. Nil for bodyweight movements.
    static func seedLoad(
        exercise: Exercise,
        prescription: SetPrescription,
        profile: UserProfile
    ) -> Double? {
        guard exercise.loadFactor > 0 else { return nil }

        let targetReps = (prescription.repLowerBound + prescription.repUpperBound) / 2

        if let known = profile.knownOneRepMax[exercise.id] {
            return StrengthMath.round(
                StrengthMath.load(forOneRepMax: known, reps: targetReps, rpe: prescription.targetRPE),
                to: profile.loadIncrement
            )
        }

        // Borrow from a main lift sharing the same pattern, scaled by loadFactor.
        let sibling = profile.knownOneRepMax.compactMap { id, oneRM -> Double? in
            guard let other = ExerciseCatalog.exercise(id: id),
                  other.pattern == exercise.pattern,
                  other.loadFactor > 0
            else { return nil }
            return oneRM / other.loadFactor * exercise.loadFactor
        }.max()

        let oneRM = sibling ?? StrengthMath.standardOneRepMax(exercise: exercise, profile: profile)
            ?? isolationEstimate(exercise: exercise, profile: profile)

        guard let oneRM, oneRM > 0 else { return nil }
        return StrengthMath.round(
            StrengthMath.load(forOneRepMax: oneRM, reps: targetReps, rpe: prescription.targetRPE),
            to: profile.loadIncrement
        )
    }

    /// Isolation work has no meaningful strength standard; scale off body
    /// weight and the movement's own load factor instead.
    static func isolationEstimate(exercise: Exercise, profile: UserProfile) -> Double? {
        guard exercise.loadFactor > 0 else { return nil }
        let experienceFactor: Double = switch profile.experience {
        case .beginner: 0.6
        case .intermediate: 0.9
        case .advanced: 1.15
        }
        let sexFactor = profile.sex == .male ? 1.0 : 0.65
        return profile.weightKg * exercise.loadFactor * experienceFactor * sexFactor
    }

    private static func format(_ value: Double) -> String {
        value == value.rounded()
            ? String(Int(value))
            : String(format: "%.1f", value).replacingOccurrences(of: ".", with: ",")
    }
}
