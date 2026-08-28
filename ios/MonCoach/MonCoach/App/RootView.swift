import SwiftUI
import MonCoachKit

/// Decides between onboarding and the app, and hosts the session player.
struct RootView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    /// Le pont vers la montre vit ici : la vue racine est le seul endroit qui
    /// voit à la fois le magasin et le cycle de vie de l'application.
    @State private var watchLink = WatchLink()

    var body: some View {
        @Bindable var store = store

        Group {
            if store.isOnboarded {
                TabView {
                    Tab(UI.today[store.language], systemImage: "bolt.fill") {
                        TodayView()
                    }
                    Tab(UI.plan[store.language], systemImage: "list.bullet.rectangle") {
                        PlanView()
                    }
                    // L'onglet n'apparaît que s'il a quelque chose à dire :
                    // un plan de course, ou des activités déjà enregistrées.
                    // Un onglet vide en permanence apprend surtout à ne plus
                    // regarder la barre d'onglets.
                    if store.profile?.runs == true || !store.history.activities.isEmpty {
                        Tab(UI.running[store.language], systemImage: "figure.run") {
                            ActivitiesHomeView()
                        }
                    }
                    Tab(UI.food[store.language], systemImage: "fork.knife") {
                        FoodView()
                    }
                    Tab(UI.progress[store.language], systemImage: "chart.line.uptrend.xyaxis") {
                        ProgressDashboardView()
                    }
                    Tab(UI.profile[store.language], systemImage: "person.fill") {
                        ProfileView()
                    }
                }
            } else {
                OnboardingView { profile in
                    store.completeOnboarding(with: profile)
                }
            }
        }
        // Toute l'interface est rendue dans la langue du magasin : changer
        // de langue dans le profil rafraîchit l'écran sur-le-champ.
        .language(store.language)
        .fullScreenCover(item: $store.activeSession) { _ in
            SessionPlayerView()
        }
        .onAppear {
            watchLink.activate(store: store)
        }
        // L'instantané part vers la montre à chaque changement qui la
        // concerne : nouvelle séance enregistrée, nouveau bloc, retour au
        // premier plan après une nuit.
        .onChange(of: store.history) { _, _ in watchLink.push() }
        .onChange(of: store.plan) { _, _ in watchLink.push() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { watchLink.push() }
        }
    }
}
