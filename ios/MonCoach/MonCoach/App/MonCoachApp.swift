import SwiftUI
import MonCoachKit

@main
@MainActor
struct MonCoachApp: App {
    @State private var store = CoachStore()
    @State private var plus = PlusStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(plus)
                .preferredColorScheme(.dark)
                .task {
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
                }
                .onChange(of: plus.isSubscribed) { _, subscribed in
                    store.setSubscribed(subscribed)
                }
        }
    }
}
