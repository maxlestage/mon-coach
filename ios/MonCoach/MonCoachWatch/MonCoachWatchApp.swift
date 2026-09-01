import SwiftUI
import MonCoachKit

@main
@MainActor
struct MonCoachWatchApp: App {
    @State private var store = WatchStore()

    var body: some Scene {
        WindowGroup {
            WatchRootView()
                .environment(store)
        }
    }
}

/// La pile de navigation de la montre.
///
/// L'accueil est toujours l'accueil, et la séance se pousse par-dessus.
///
/// Elle le remplaçait, et c'était une prison : tant qu'une séance était en
/// cours — même démarrée par erreur, même reprise le lendemain — l'écran de
/// séance était la seule chose que la montre savait afficher. Il n'y avait
/// plus de liste d'activités, donc plus de choix : quelqu'un qui décidait
/// finalement d'aller courir devait d'abord enregistrer une séance qu'il
/// n'avait pas faite. Poussée plutôt que substituée, elle se quitte d'un
/// glissement vers la droite et se retrouve d'un appui.
struct WatchRootView: View {
    @Environment(WatchStore.self) private var store

    var body: some View {
        NavigationStack {
            WatchTodayView()
        }
        // La montre parle la langue choisie sur le téléphone, reçue dans
        // l'instantané. Elle n'a pas de réglage à elle : deux endroits pour
        // choisir la même chose, c'est un endroit de trop.
        .language(store.language)
    }
}
