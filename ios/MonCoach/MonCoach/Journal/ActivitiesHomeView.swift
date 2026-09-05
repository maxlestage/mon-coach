import SwiftUI
import MonCoachKit

/// L'onglet activités : le plan de course d'un côté, le journal de l'autre.
///
/// Un athlète qui ne court pas — vélo, randonnée — n'a pas de plan de
/// course : il arrive directement sur son journal, sans segment vide.
struct ActivitiesHomeView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    private enum Pane: Hashable { case plan, journal, stats, car }
    @State private var pane: Pane = .plan

    /// Le plan de course n'existe que pour qui court : un cycliste n'a pas
    /// à glisser devant un onglet vide pour atteindre ses courbes.
    private var runs: Bool { store.profile?.runs == true }

    /// La voiture n'apparaît qu'une fois qu'il y a un trajet, sur le même
    /// principe que le plan de course.
    ///
    /// C'est un volet de plus dans un sélecteur qui en compte déjà trois, et
    /// la plupart des athlètes n'enregistreront jamais un trajet de leur
    /// vie. Le montrer à tout le monde ajouterait un onglet vide à traverser
    /// pour atteindre ses courbes — exactement ce qu'on évite déjà pour le
    /// plan de course.
    ///
    /// Il suffit d'un trajet pour qu'il apparaisse, et il apparaît alors
    /// tout seul : rien à activer dans un réglage que personne ne lit.
    private var drives: Bool {
        store.history.activities.contains { !$0.sport.countsAsTraining }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $pane) {
                    if runs {
                        Text(LocalizedText(fr: "Plan", en: "Plan", es: "Plan")[language]).tag(Pane.plan)
                    }
                    Text(LocalizedText(fr: "Journal", en: "Journal", es: "Diario")[language]).tag(Pane.journal)
                    Text(UI.stats[language]).tag(Pane.stats)
                    if drives {
                        Text(LocalizedText(fr: "Voiture", en: "Car", es: "Coche")[language])
                            .tag(Pane.car)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)

                // Le journal reste ouvert quoi qu'il arrive : enregistrer
                // ce qu'on fait et le relire ne se monnaie pas. C'est le
                // plan qui prescrit et les courbes qui analysent qui
                // demandent Stride+.
                // Les trois volets se croisent en fondu plutôt que de se
                // remplacer d'un coup. La carte de chaleur et le journal
                // n'ont rien en commun visuellement : sans transition, on
                // ne sait pas une demi-seconde ce qu'on regarde.
                Group {
                    switch pane {
                    case .plan where runs:
                        if store.isUnlocked(.runningPlan) {
                            RunPlanView(embedded: true)
                        } else {
                            ScrollView {
                                PlusLockedCard(feature: .runningPlan).padding(16)
                            }
                        }
                    // Le journal des trajets ne se monnaie pas non plus :
                    // il ne prescrit ni n'analyse rien, il montre une donnée
                    // que l'athlète a lui-même enregistrée.
                    case .car:
                        CarView()
                    case .stats:
                        if store.isUnlocked(.progressCurves) {
                            StatsView()
                        } else {
                            ScrollView {
                                PlusLockedCard(feature: .progressCurves).padding(16)
                            }
                        }
                    default:
                        JournalView()
                    }
                }
                .transition(.opacity)
            }
            .animation(Motion.plain, value: pane)
            .screenBackground()
            .navigationTitle(UI.activities[language])
            .sectionGuide(.running)
        }
        .tint(Theme.accent)
        .onAppear {
            // Un athlète qui ne court pas ne doit jamais atterrir sur un
            // onglet que son profil ne montre pas.
            if !runs, pane == .plan { pane = .journal }
            // Un trajet supprimé fait disparaître le volet : y rester
            // laisserait un écran vide sans moyen d'en sortir.
            if !drives, pane == .car { pane = .journal }
        }
    }
}
