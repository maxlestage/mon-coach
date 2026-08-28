import Foundation
import MonCoachKit
#if canImport(ActivityKit)
import ActivityKit
#endif

/// Pilote la Live Activity de la séance en cours.
///
/// Toute la matière affichée vient de `ActiveSession.activitySnapshot(...)`,
/// calculée et testée dans MonCoachKit ; ici on ne fait que démarrer, pousser
/// et clore l'activité. Sur un appareil sans Live Activities (réglage coupé,
/// iOS trop ancien), chaque méthode est un no-op silencieux : la séance ne
/// dépend jamais de l'écran verrouillé.
@MainActor
final class WorkoutActivityController {

    #if canImport(ActivityKit)
    private var activity: Activity<WorkoutAttributes>?
    #endif

    func start(for active: ActiveSession, unit: UnitSystem) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = active.activitySnapshot(unit: unit)
        activity = try? Activity.request(
            attributes: WorkoutAttributes(sessionID: active.session.id),
            content: ActivityContent(state: state, staleDate: nil)
        )
        #endif
    }

    func update(for active: ActiveSession, unit: UnitSystem, restEndsAt: Date?) {
        #if canImport(ActivityKit)
        guard let activity else { return }
        let state = active.activitySnapshot(unit: unit, restEndsAt: restEndsAt)
        Task { await activity.update(ActivityContent(state: state, staleDate: nil)) }
        #endif
    }

    func end() {
        #if canImport(ActivityKit)
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
        #endif
    }
}
