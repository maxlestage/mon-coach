import SwiftUI
import MonCoachKit

@main
@MainActor
struct MonCoachApp: App {
    @State private var store = CoachStore()
    @State private var plus = PlusStore()

    /// Vrai tant que le travail de démarrage n'est pas fini. L'écran de
    /// lancement couvre l'application pendant ce temps, et se retire en
    /// fondu quand tout est prêt — jamais avant, jamais longtemps après.
    @State private var launching = true

    /// Le temps minimum d'affichage de l'écran de lancement. En dessous, on
    /// a vu quelque chose sans avoir eu le temps de le lire ; au-dessus,
    /// on attend pour rien.
    private static let minimumLaunch: Duration = .seconds(1.6)

    /// Le temps maximum. L'App Store peut mettre longtemps à répondre — pas
    /// de réseau, un sous-sol de salle — et un écran de lancement qui
    /// attend une réponse qui ne vient pas est une application qui ne
    /// s'ouvre pas. Passé ce délai, l'écran se retire et le paywall dira
    /// lui-même que les prix n'ont pas pu être chargés.
    private static let maximumLaunch: Duration = .seconds(5)

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()

                if launching {
                    LaunchView(language: store.language)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
                .environment(store)
                .environment(plus)
                .preferredColorScheme(.dark)
                .task {
                    let started = ContinuousClock.now
                    let deadline = Task {
                        try? await Task.sleep(for: Self.maximumLaunch)
                        dismissLaunch()
                    }
                    defer { deadline.cancel() }

                    // Une Live Activity survit à l'application qui l'a
                    // créée — c'est tout son intérêt, et c'est aussi son
                    // piège : si l'application s'arrête brutalement, la
                    // référence qui permettait d'y mettre fin disparaît et
                    // l'activité reste sur l'écran verrouillé, indéboulonnable.
                    //
                    // Au lancement, rien n'est en cours : ni séance ni sortie
                    // ne survivent à une fermeture. Toute activité encore
                    // affichée est donc un vestige, et se retire.
                    RunActivityController.endAll()
                    WorkoutActivityController.endAll()

                    // Le même raisonnement pour les photos : une suppression
                    // interrompue — l'application tuée entre l'écriture de
                    // l'état et celle du disque — laisse des images que plus
                    // aucune sortie ne réclame et que rien ne peut plus
                    // atteindre. Le lancement en fait le ménage.
                    // Les doublons d'abord : un journal constitué avant
                    // que la règle existe en porte, et ils comptent leurs
                    // kilomètres deux fois dans le volume de la semaine.
                    // Avant le ménage des photos, parce que la fusion
                    // reprend celles des deux enregistrements.
                    store.mergeDuplicateActivities()
                    store.prunePhotos()

                    // L'essai part à la première ouverture, jamais avant :
                    // quatorze jours comptés depuis le moment où l'athlète
                    // a réellement vu le produit.
                    store.startTrialIfNeeded()

                    // Puis on demande à l'App Store ce qu'il en est. C'est
                    // lui qui décide, pas un fichier local : un droit
                    // d'accès stocké sur l'appareil serait un droit qu'on
                    // peut s'accorder soi-même.
                    await plus.load()
                    store.setSubscribed(plus.isSubscribed)

                    // Tout est prêt : l'écran de lancement se retire, une
                    // fois son minimum d'affichage passé.
                    await finishLaunch(startedAt: started)
                }
                .onChange(of: plus.isSubscribed) { _, subscribed in
                    store.setSubscribed(subscribed)
                }
        }
    }

    /// Retire l'écran de lancement, une fois le minimum d'affichage passé.
    private func finishLaunch(startedAt started: ContinuousClock.Instant) async {
        let elapsed = ContinuousClock.now - started
        if elapsed < Self.minimumLaunch {
            try? await Task.sleep(for: Self.minimumLaunch - elapsed)
        }
        dismissLaunch()
    }

    /// Le retrait lui-même, tolérant au double appel : le travail fini et
    /// la borne haute peuvent arriver l'un après l'autre.
    private func dismissLaunch() {
        guard launching else { return }
        withAnimation(.easeInOut(duration: 0.45)) {
            launching = false
        }
    }
}
