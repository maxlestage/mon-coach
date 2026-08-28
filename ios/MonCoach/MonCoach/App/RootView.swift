import SwiftUI
import MonCoachKit

/// Decides between onboarding and the app, and hosts the session player.
struct RootView: View {
    @Environment(CoachStore.self) private var store

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
    }
}
