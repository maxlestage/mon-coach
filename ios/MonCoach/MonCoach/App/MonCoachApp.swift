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
                }
        }
    }
}
