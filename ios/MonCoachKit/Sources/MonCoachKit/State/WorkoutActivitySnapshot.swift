import Foundation

/// L'état affiché par la Live Activity pendant une séance.
///
/// Struct plate et Codable : ActivityKit n'existe pas sous Linux, mais tout
/// ce que la Live Activity affiche se calcule ici, dans le paquet, où c'est
/// testé. L'extension iOS ne fait que l'habiller.
public struct WorkoutActivitySnapshot: Codable, Hashable, Sendable {
    public var sessionTitle: String
    public var exerciseName: String
    /// Consigne de la série en cours, prête à afficher ("Série 3 sur 4 · 6–12 rép").
    public var setLabel: String
    public var suggestedLoadKg: Double?
    public var unit: UnitSystem
    public var completedSets: Int
    public var totalSets: Int
    /// Fin du repos en cours. La Live Activity affiche un compte à rebours
    /// piloté par cette date : aucune mise à jour n'est nécessaire pendant
    /// que le chrono tourne.
    public var restEndsAt: Date?
    public var isFinished: Bool

    public var progress: Double {
        totalSets > 0 ? Double(completedSets) / Double(totalSets) : 1
    }

    public init(
        sessionTitle: String,
        exerciseName: String,
        setLabel: String,
        suggestedLoadKg: Double?,
        unit: UnitSystem,
        completedSets: Int,
        totalSets: Int,
        restEndsAt: Date?,
        isFinished: Bool
    ) {
        self.sessionTitle = sessionTitle
        self.exerciseName = exerciseName
        self.setLabel = setLabel
        self.suggestedLoadKg = suggestedLoadKg
        self.unit = unit
        self.completedSets = completedSets
        self.totalSets = totalSets
        self.restEndsAt = restEndsAt
        self.isFinished = isFinished
    }
}

extension ActiveSession {

    /// L'état de la Live Activity pour l'instant présent de la séance.
    ///
    /// - Parameter restEndsAt: fin du repos en cours, si un repos vient
    ///   d'être lancé par l'enregistrement d'une série.
    public func activitySnapshot(unit: UnitSystem, restEndsAt: Date? = nil) -> WorkoutActivitySnapshot {
        guard let prescription = currentExercise,
              let set = nextSet(of: prescription)
        else {
            return WorkoutActivitySnapshot(
                sessionTitle: session.title,
                exerciseName: "Séance terminée",
                setLabel: "\(loggedSetCount) séries enregistrées",
                suggestedLoadKg: nil,
                unit: unit,
                completedSets: loggedSetCount,
                totalSets: session.totalSets,
                restEndsAt: nil,
                isFinished: true
            )
        }

        let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)
        return WorkoutActivitySnapshot(
            sessionTitle: session.title,
            exerciseName: exercise?.name ?? prescription.exerciseID,
            setLabel: "Série \(set.index + 1) sur \(prescription.sets.count) · \(set.repsLabel) rép",
            suggestedLoadKg: set.suggestedLoadKg,
            unit: unit,
            completedSets: loggedSetCount,
            totalSets: session.totalSets,
            restEndsAt: restEndsAt,
            isFinished: false
        )
    }
}
