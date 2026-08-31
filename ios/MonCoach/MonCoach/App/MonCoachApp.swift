import SwiftUI
import MonCoachKit

@main
@MainActor
struct MonCoachApp: App {
    @State private var store = CoachStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
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
                }
        }
    }
}
