import Foundation

/// Le passage entre l'application et ses widgets.
///
/// Un widget vit dans une extension : un autre processus, un autre bac à
/// sable, aucun accès au dossier de l'application. Le seul chemin est un
/// conteneur de groupe, déclaré des deux côtés — d'où la constante
/// `groupIdentifier`, qui doit rester identique aux entitlements. Si elle
/// s'en écarte, rien ne casse bruyamment : le widget affiche simplement un
/// écran vide pour toujours. Le test qui la compare aux fichiers
/// d'entitlements existe pour cette raison.
public struct WidgetSnapshotStore: Sendable {

    /// Le groupe d'applications, écrit ici et dans les deux entitlements.
    public static let groupIdentifier = "group.com.maxlestage.fitnesscoach"

    public static let fileName = "widget.json"

    public let url: URL?

    public init(url: URL?) { self.url = url }

    /// Le conteneur partagé, quand le système en donne un.
    ///
    /// Il n'y en a pas dans les tests, ni dans un aperçu Xcode : l'URL est
    /// alors nulle, la lecture rend `nil` et l'écriture ne fait rien. Une
    /// absence de widget est le bon comportement dans ce cas ; une erreur
    /// bloquante ne le serait pas.
    public static func shared(groupIdentifier: String = WidgetSnapshotStore.groupIdentifier) -> WidgetSnapshotStore {
        #if canImport(Darwin)
        let container = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupIdentifier
        )
        return WidgetSnapshotStore(url: container?.appending(path: fileName))
        #else
        // Linux ne connaît pas les groupes d'applications, et le moteur s'y
        // teste. Les tests fabriquent leur propre URL ; ce chemin-ci ne sert
        // qu'à laisser le module compiler.
        return WidgetSnapshotStore(url: nil)
        #endif
    }

    public func load() -> WidgetSnapshot? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        return try? StateStorage.decoder.decode(WidgetSnapshot.self, from: data)
    }

    /// Écrit l'instantané, et rend `true` si quelque chose a changé.
    ///
    /// Le retour sert à ne demander un rafraîchissement au système que
    /// lorsqu'il y a de quoi rafraîchir. WidgetKit rationne ces demandes ;
    /// les dépenser pour réécrire la même phrase, c'est ne plus en avoir
    /// quand la séance change vraiment.
    @discardableResult
    public func save(_ snapshot: WidgetSnapshot) -> Bool {
        guard let url else { return false }
        // La date d'écriture change à chaque fois : la comparer ferait
        // conclure « ça a changé » à chaque ouverture de l'application.
        if var previous = load() {
            previous.generatedAt = snapshot.generatedAt
            if previous == snapshot { return false }
        }
        guard let data = try? StateStorage.encoder.encode(snapshot) else { return false }
        try? data.write(to: url, options: [.atomic])
        return true
    }

    public func clear() {
        guard let url else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
