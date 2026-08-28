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

/// Décide entre l'attente du téléphone, le repos et la séance.
struct WatchRootView: View {
    @Environment(WatchStore.self) private var store

    var body: some View {
        NavigationStack {
            if store.activeSession != nil {
                WatchSessionView()
            } else {
                WatchTodayView()
            }
        }
    }
}
