import Foundation

/// What the coach decided to do with the load on a movement, and why.
public struct LoadDecision: Sendable, Equatable {
    public enum Action: String, Sendable {
        case start          // first exposure, no history
        case increase
        case hold
        case decrease
        case deload

        public var label: LocalizedText {
            switch self {
            case .start: LocalizedText(fr: "Première fois", en: "First time", es: "Primera vez")
            case .increase: LocalizedText(fr: "On monte", en: "Going up", es: "Subimos")
            case .hold: LocalizedText(fr: "On garde", en: "Holding", es: "Mantenemos")
            case .decrease: LocalizedText(fr: "On réduit", en: "Backing off", es: "Bajamos")
            case .deload: LocalizedText(fr: "Décharge", en: "Deload", es: "Descarga")
            }
        }
    }

    public let action: Action
    public let loadKg: Double?
    public let reason: LocalizedText
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
                    ? LocalizedText(
                        fr: "Première exposition : choisis une charge que tu contrôles sur toutes les répétitions, on ajustera dès la prochaine séance.",
                        en: "First exposure: pick a load you control on every rep, and we adjust from the next session on.",
                        es: "Primera exposición: elige una carga que controles en todas las repeticiones y ajustamos ya en la siguiente sesión."
                    )
                    : LocalizedText(
                        fr: "Estimation de départ à partir de ton profil. Si c'est trop facile ou trop lourd, corrige — la séance suivante en tiendra compte.",
                        en: "A starting estimate from your profile. If it is too easy or too heavy, change it — the next session will take that into account.",
                        es: "Estimación inicial a partir de tu perfil. Si es demasiado fácil o pesada, corrígela: la siguiente sesión lo tendrá en cuenta."
                    )
            )
        }

        let lastLoad = previous.map(\.weightKg).max() ?? 0

        if isDeloadWeek {
            let load = StrengthMath.round(lastLoad * 0.6, to: profile.loadIncrement)
            return LoadDecision(
                action: .deload,
                loadKg: load,
                reason: LocalizedText(
                    fr: "Semaine de décharge : 60 % de ta charge habituelle. Le but est de récupérer, pas de performer.",
                    en: "Deload week: 60 % of your usual load. The point is to recover, not to perform.",
                    es: "Semana de descarga: el 60 % de tu carga habitual. El objetivo es recuperar, no rendir."
                )
            )
        }

        // A pain flag outranks everything else the numbers might say.
        if previous.contains(where: \.painFlag) {
            let load = StrengthMath.round(lastLoad * 0.85, to: profile.loadIncrement)
            return LoadDecision(
                action: .decrease,
                loadKg: load,
                reason: LocalizedText(
                    fr: "Tu as signalé une douleur articulaire la dernière fois : −15 % et on surveille. Si ça persiste, on changera d'exercice.",
                    en: "You flagged joint pain last time: −15 % and we watch it. If it persists, we change the exercise.",
                    es: "Señalaste dolor articular la última vez: −15 % y lo vigilamos. Si persiste, cambiamos de ejercicio."
                )
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
                reason: LocalizedText(
                    fr: "Toutes les séries au sommet de la fourchette à RPE \(format(averageRPE)) : la charge monte à \(format(load)) kg.",
                    en: "Every set at the top of the range at RPE \(format(averageRPE)): the load goes up to \(format(load)) kg.",
                    es: "Todas las series en la parte alta del rango a RPE \(format(averageRPE)): la carga sube a \(format(load)) kg."
                )
            )
        }

        if anyBelowRange || averageRPE >= prescription.targetRPE + 1.5 {
            let load = StrengthMath.round(lastLoad * 0.92, to: profile.loadIncrement)
            return LoadDecision(
                action: .decrease,
                loadKg: min(load, lastLoad),
                reason: LocalizedText(
                    fr: "Les répétitions sont tombées sous la fourchette : on recule de 8 % pour repartir sur des séries propres.",
                    en: "Reps dropped below the range: we step back 8 % to restart on clean sets.",
                    es: "Las repeticiones han caído por debajo del rango: retrocedemos un 8 % para volver a series limpias."
                )
            )
        }

        return LoadDecision(
            action: .hold,
            loadKg: lastLoad,
            reason: LocalizedText(
                fr: "Même charge : ajoute des répétitions cette fois-ci. On montera quand toutes les séries atteindront \(prescription.repUpperBound).",
                en: "Same load: add reps this time. We go up when every set reaches \(prescription.repUpperBound).",
                es: "Misma carga: añade repeticiones esta vez. Subiremos cuando todas las series lleguen a \(prescription.repUpperBound)."
            )
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
