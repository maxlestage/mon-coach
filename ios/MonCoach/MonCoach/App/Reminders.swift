import Foundation
import UserNotifications
import MonCoachKit

/// Pose sur le téléphone ce que le moteur a décidé de dire.
///
/// Le partage du travail
/// ---------------------
/// `ReminderPlanner` décide **quoi** rappeler et **quand** ; ce type-ci ne
/// fait que le porter au système. La séparation n'est pas décorative : les
/// règles — un seul rappel par jour, rien qui soit déjà fait, le plus rare
/// d'abord — se testent alors sur n'importe quelle machine, alors qu'un
/// `UNUserNotificationCenter` ne se teste nulle part.
///
/// Ce que ce type garantit
/// -----------------------
/// **On efface avant de poser.** Les notifications locales se programment à
/// l'avance et ne se recalculent pas toutes seules : celle de jeudi a été
/// écrite mardi, avec ce qu'on savait mardi. Faire une séance mercredi la
/// rend fausse. Reprogrammer sans effacer laisserait la fausse sonner à côté
/// de la vraie — c'est exactement le genre de rappel qui fait couper le son.
///
/// Comme tout est reposé à chaque changement, il n'y a jamais de rattrapage
/// à faire : l'état du téléphone est toujours celui du dernier calcul.
@MainActor
enum Reminders {

    /// Le préfixe qui nous appartient. On n'efface que le nôtre : une autre
    /// notification posée par l'application — une alarme de repos, par
    /// exemple — n'a pas à disparaître parce qu'on a noté une pesée.
    static let prefix = "rappel."

    /// Demande l'autorisation, une seule fois, et dit ce qu'elle a donné.
    ///
    /// Un refus n'est pas une erreur : c'est une réponse. On la rend telle
    /// quelle pour que l'écran puisse le dire — un interrupteur qui reste
    /// allumé alors que le système refuse est un mensonge à l'écran.
    static func requestPermission() async -> Bool {
        let centre = UNUserNotificationCenter.current()
        do {
            return try await centre.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// L'autorisation telle que le système la voit maintenant.
    ///
    /// Elle se retire dans les réglages d'iOS sans que l'application en soit
    /// prévenue. La relire à chaque affichage est le seul moyen de ne pas
    /// promettre des rappels qui ne partiront jamais.
    static func isAllowed() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    /// Efface les nôtres, puis repose ceux qui valent encore.
    static func reschedule(_ reminders: [Reminder], language: Language) async {
        let centre = UNUserNotificationCenter.current()
        await clear(centre)

        guard !reminders.isEmpty else { return }
        for reminder in reminders {
            let content = UNMutableNotificationContent()
            content.title = reminder.title[language]
            content.body = reminder.message[language]
            content.sound = .default

            let parts = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute], from: reminder.date
            )
            let request = UNNotificationRequest(
                identifier: prefix + reminder.id,
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            )
            try? await centre.add(request)
        }
    }

    /// Retire tout ce que nous avions posé, sans toucher au reste.
    static func cancelAll() async {
        await clear(UNUserNotificationCenter.current())
    }

    private static func clear(_ centre: UNUserNotificationCenter) async {
        let pending = await centre.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(prefix) }
        centre.removePendingNotificationRequests(withIdentifiers: ours)
    }
}
