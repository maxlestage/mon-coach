import SwiftUI
import MonCoachKit

/// L'onglet activités : le plan de course d'un côté, le journal de l'autre.
///
/// Un athlète qui ne court pas — vélo, randonnée — n'a pas de plan de
/// course : il arrive directement sur son journal, sans segment vide.
struct ActivitiesHomeView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    private enum Pane: Hashable { case plan, journal }
    @State private var pane: Pane = .plan

    var body: some View {
        NavigationStack {
            Group {
                if store.profile?.runs == true {
                    VStack(spacing: 0) {
                        Picker("", selection: $pane) {
                            Text(LocalizedText(fr: "Plan", en: "Plan", es: "Plan")[language]).tag(Pane.plan)
                            Text(LocalizedText(fr: "Journal", en: "Journal", es: "Diario")[language]).tag(Pane.journal)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 4)
                        if pane == .plan {
                            RunPlanView(embedded: true)
                        } else {
                            JournalView()
                        }
                    }
                    .screenBackground()
                } else {
                    JournalView()
                }
            }
            .navigationTitle(UI.running[language])
        }
        .tint(Theme.accent)
    }
}
