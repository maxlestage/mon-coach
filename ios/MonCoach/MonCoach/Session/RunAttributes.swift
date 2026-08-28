import ActivityKit
import Foundation
import MonCoachKit

/// Les attributs de la Live Activity d'une sortie.
///
/// L'état dynamique est `RunActivitySnapshot`, défini et testé dans
/// MonCoachKit : ce fichier ne fait qu'y accrocher ActivityKit.
///
/// ⚠️ Ce fichier existe en DEUX exemplaires strictement identiques —
/// `MonCoach/Session/RunAttributes.swift` et
/// `MonCoachWidgets/RunAttributes.swift` — parce qu'ActivityKit exige que
/// l'application et l'extension compilent le même type d'attributs.
/// Un job de CI compare les deux octet par octet : toute modification se
/// fait dans les deux, sinon la CI échoue.
struct RunAttributes: ActivityAttributes {
    typealias ContentState = RunActivitySnapshot

    /// Identifiant de la sortie, fixe pour toute la durée de l'activité.
    var runID: UUID
}
