import Foundation
import WidgetKit
import MonCoachKit

/// Ce que l'application dit à ses widgets.
///
/// Le widget ne calcule rien : il lit une phrase déjà écrite. C'est donc
/// l'application qui doit la réécrire à chaque fois que la journée change de
/// sens — séance enregistrée, bloc relancé, langue modifiée, retour au
/// premier plan après une nuit.
///
/// Le rafraîchissement n'est demandé que si le texte a réellement changé.
/// WidgetKit rationne ces demandes : les dépenser pour réécrire la même
/// phrase, c'est ne plus en avoir le jour où la séance change vraiment.
@MainActor
enum WidgetBridge {

    static func push(store: CoachStore, on date: Date = Date()) {
        let snapshots = WidgetSnapshotStore.shared()

        // Sans profil ni plan, il n'y a rien à dire : l'instantané s'efface
        // plutôt que de laisser sur l'écran d'accueil la séance de quelqu'un
        // qui vient de tout remettre à zéro.
        guard store.isOnboarded, let briefing = store.briefing(on: date) else {
            snapshots.clear()
            WidgetCenter.shared.reloadAllTimelines()
            return
        }

        let snapshot = WidgetSnapshot.make(
            briefing: briefing,
            language: store.language,
            unit: store.profile?.unit ?? .metric,
            comeback: store.returnPlan(on: date),
            week: weekProgress(store: store, on: date),
            now: date
        )
        if snapshots.save(snapshot) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }

    /// Les séries de la semaine en cours, faites sur prévues.
    ///
    /// Le bilan hebdomadaire porte déjà ces deux nombres — les recompter ici
    /// serait une deuxième vérité, qui finirait par ne plus être la même que
    /// celle affichée dans l'application.
    private static func weekProgress(store: CoachStore, on date: Date) -> (completed: Int, planned: Int)? {
        guard let index = store.currentWeekIndex(on: date),
              let review = store.review(weekIndex: index),
              review.setsPlanned > 0
        else { return nil }
        return (review.setsCompleted, review.setsPlanned)
    }
}
