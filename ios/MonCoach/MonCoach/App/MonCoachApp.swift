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
        }
    }
}
