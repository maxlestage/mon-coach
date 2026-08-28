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
                    Tab("Aujourd'hui", systemImage: "bolt.fill") {
                        TodayView()
                    }
                    Tab("Plan", systemImage: "list.bullet.rectangle") {
                        PlanView()
                    }
                    Tab("Progression", systemImage: "chart.line.uptrend.xyaxis") {
                        ProgressDashboardView()
                    }
                    Tab("Profil", systemImage: "person.fill") {
                        ProfileView()
                    }
                }
            } else {
                OnboardingView { profile in
                    store.completeOnboarding(with: profile)
                }
            }
        }
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
