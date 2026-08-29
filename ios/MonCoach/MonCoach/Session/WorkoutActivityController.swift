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

    func start(for active: ActiveSession, unit: UnitSystem, language: Language) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let state = active.activitySnapshot(unit: unit, language: language)
        activity = try? Activity.request(
            attributes: WorkoutAttributes(sessionID: active.session.id),
            content: ActivityContent(state: state, staleDate: nil)
        )
        #endif
    }

    func update(for active: ActiveSession, unit: UnitSystem, language: Language, restEndsAt: Date?) {
        #if canImport(ActivityKit)
        guard let activity else { return }
        let state = active.activitySnapshot(unit: unit, language: language, restEndsAt: restEndsAt)
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

    /// Met fin à toutes les Live Activities de séance, y compris celles
    /// qu'une exécution précédente a laissées derrière elle.
    ///
    /// `end()` ne peut rien contre celles-là : il ne connaît que l'activité
    /// qu'il a lui-même démarrée, et une application qui s'arrête
    /// brutalement emporte cette référence sans emporter l'activité. Elle
    /// reste alors sur l'écran verrouillé, et plus rien dans l'application
    /// ne sait la retirer. Le système, lui, les rend toutes.
    nonisolated static func endAll() {
        #if canImport(ActivityKit)
        Task {
            for activity in Activity<WorkoutAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        #endif
    }
}

/// Pilote la Live Activity d'une sortie en cours.
///
/// Même principe que pour la séance, avec une contrainte de plus : pendant
/// une course le téléphone est dans une poche, donc l'écran verrouillé est
/// le seul écran. On pousse une mise à jour toutes les vingt secondes, pas à
/// chaque point GPS : le système limite la fréquence des mises à jour, et
/// une activité rejetée pour excès d'appels ne revient pas.
@MainActor
final class RunActivityController {

    #if canImport(ActivityKit)
    private var activity: Activity<RunAttributes>?
    #endif
    private var lastPush = Date.distantPast

    func start(id: UUID, snapshot: RunActivitySnapshot) {
        #if canImport(ActivityKit)
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        activity = try? Activity.request(
            attributes: RunAttributes(runID: id),
            content: ActivityContent(state: snapshot, staleDate: nil)
        )
        lastPush = Date()
        #endif
    }

    /// Pousse un nouvel état, au plus une fois toutes les vingt secondes.
    /// `force` sert aux changements que l'athlète a provoqués lui-même —
    /// mise en pause, reprise — qui doivent apparaître immédiatement.
    func update(_ snapshot: RunActivitySnapshot, force: Bool = false) {
        #if canImport(ActivityKit)
        guard let activity else { return }
        guard force || Date().timeIntervalSince(lastPush) >= 20 else { return }
        lastPush = Date()
        Task { await activity.update(ActivityContent(state: snapshot, staleDate: nil)) }
        #endif
    }

    func end() {
        #if canImport(ActivityKit)
        guard let activity else { return }
        self.activity = nil
        Task { await activity.end(nil, dismissalPolicy: .immediate) }
        #endif
    }

    /// Reste-t-il une Live Activity de sortie affichée quelque part ?
    ///
    /// La question porte sur le système, pas sur cet objet : une activité
    /// laissée par une exécution précédente est invisible d'ici et pourtant
    /// bien présente sur l'écran verrouillé.
    nonisolated static var hasAny: Bool {
        #if canImport(ActivityKit)
        return !Activity<RunAttributes>.activities.isEmpty
        #else
        return false
        #endif
    }

    /// Met fin à toutes les Live Activities de sortie, celles des exécutions
    /// précédentes comprises.
    nonisolated static func endAll() {
        #if canImport(ActivityKit)
        Task {
            for activity in Activity<RunAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
        #endif
    }

    /// Oublie l'activité tenue ici, sans y toucher.
    ///
    /// Sert après un `endAll` : l'activité n'existe plus, la référence ne
    /// doit pas laisser croire le contraire.
    func forget() {
        #if canImport(ActivityKit)
        activity = nil
        #endif
    }
}
