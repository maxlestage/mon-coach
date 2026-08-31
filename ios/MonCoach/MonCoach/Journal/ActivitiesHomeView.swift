import SwiftUI
import MonCoachKit

/// L'onglet activités : le plan de course d'un côté, le journal de l'autre.
///
/// Un athlète qui ne court pas — vélo, randonnée — n'a pas de plan de
/// course : il arrive directement sur son journal, sans segment vide.
struct ActivitiesHomeView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    private enum Pane: Hashable { case plan, journal, stats }
    @State private var pane: Pane = .plan

    /// Le plan de course n'existe que pour qui court : un cycliste n'a pas
    /// à glisser devant un onglet vide pour atteindre ses courbes.
    private var runs: Bool { store.profile?.runs == true }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $pane) {
                    if runs {
                        Text(LocalizedText(fr: "Plan", en: "Plan", es: "Plan")[language]).tag(Pane.plan)
                    }
                    Text(LocalizedText(fr: "Journal", en: "Journal", es: "Diario")[language]).tag(Pane.journal)
                    Text(UI.stats[language]).tag(Pane.stats)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

                switch pane {
                case .plan where runs:
                    RunPlanView(embedded: true)
                case .stats:
                    StatsView()
                default:
                    JournalView()
                }
            }
            .screenBackground()
            .navigationTitle(UI.activities[language])
        }
        .tint(Theme.accent)
        .onAppear {
            // Un athlète qui ne court pas ne doit jamais atterrir sur un
            // onglet que son profil ne montre pas.
            if !runs, pane == .plan { pane = .journal }
        }
    }
}
