import ActivityKit
import Foundation
import MonCoachKit

/// Les attributs de la Live Activity de séance.
///
/// L'état dynamique est `WorkoutActivitySnapshot`, défini et testé dans
/// MonCoachKit : ce fichier ne fait qu'y accrocher ActivityKit.
///
/// ⚠️ Ce fichier existe en DEUX exemplaires strictement identiques —
/// `MonCoach/Session/WorkoutAttributes.swift` et
/// `MonCoachWidgets/WorkoutAttributes.swift` — parce qu'ActivityKit exige
/// que l'application et l'extension compilent le même type d'attributs.
/// Un job de CI compare les deux octet par octet : toute modification se
/// fait dans les deux, sinon la CI échoue.
struct WorkoutAttributes: ActivityAttributes {
    typealias ContentState = WorkoutActivitySnapshot

    /// Identifiant de la séance planifiée, fixe pour toute la durée de l'activité.
    var sessionID: UUID
}
