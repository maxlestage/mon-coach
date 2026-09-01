import SwiftUI
import MonCoachKit

/// La fiche guidée d'un mouvement, déroulée étape par étape.
///
/// Pas de vidéo, et c'est le sujet : on avance étape par étape, chacune avec
/// un repère que l'athlète peut vérifier sur lui-même. Une vidéo passe en
/// trente secondes et ne se laisse pas interroger.
struct GuidedTechniqueView: View {
    var exercise: Exercise
    /// Le matériel dont dispose l'athlète, pour ne proposer que des
    /// remplaçants qu'il peut réellement faire.
    var owned: Set<Equipment>?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var step = 0
    @State private var showsMistakes = false

    private var technique: GuidedTechnique { GuidedCatalog.technique(for: exercise) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(LocalizedText(fr: "L'essentiel", en: "The one thing", es: "Lo esencial")[language])
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                            CoachText(technique.oneThing, font: Theme.headlineFont, color: Theme.primaryText)
                        }
                    }

                    // Ce qui est propre à *cet* exercice vient avant la
                    // technique de famille : devant une machine inconnue, la
                    // première question n'est pas « comment on s'accroupit »
                    // mais « qu'est-ce que cette machine me veut ».
                    ExerciseBriefCard(exercise: exercise, owned: owned)

                    Card(
                        title: LocalizedText(
                            fr: "La technique du geste",
                            en: "The technique of the movement",
                            es: "La técnica del gesto"
                        )[language],
                        subtitle: technique.title[language]
                    ) {
                        CoachText(
                            LocalizedText(
                                fr: "Ce qui suit vaut pour toute la famille de mouvements : ce qui protège ton dos ici le protège aussi ailleurs.",
                                en: "What follows holds for the whole family of movements: what protects your back here protects it elsewhere too.",
                                es: "Lo que sigue vale para toda la familia de movimientos: lo que protege tu espalda aquí la protege también en otros."
                            ),
                            font: .system(size: 13)
                        )
                    }

                    stepCard

                    Card(title: LocalizedText(fr: "Respiration", en: "Breathing", es: "Respiración")[language]) {
                        CoachText(technique.breathing)
                    }
                    Card(title: LocalizedText(fr: "Tempo", en: "Tempo", es: "Tempo")[language]) {
                        CoachText(technique.tempo)
                    }

                    mistakesCard

                    if let easier = technique.easier {
                        Card(title: LocalizedText(fr: "Plus facile", en: "Easier", es: "Más fácil")[language]) {
                            CoachText(easier)
                        }
                    }
                    if let harder = technique.harder {
                        Card(title: LocalizedText(fr: "Plus dur", en: "Harder", es: "Más difícil")[language]) {
                            CoachText(harder)
                        }
                    }

                    Card { CoachText(FirstSessions.rationale, font: .system(size: 12)) }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(exercise.name[language])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }

    private var stepCard: some View {
        let steps = technique.steps
        let current = steps[min(step, steps.count - 1)]
        return Card(
            title: current.title[language],
            subtitle: LocalizedText(
                fr: "Étape \(current.index) sur \(steps.count)",
                en: "Step \(current.index) of \(steps.count)",
                es: "Paso \(current.index) de \(steps.count)"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(current.detail, color: Theme.primaryText)

                if let checkpoint = current.checkpoint {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                        CoachText(checkpoint, font: .system(size: 13), color: Theme.accent)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.accentMuted, in: RoundedRectangle(cornerRadius: 10))
                }

                HStack(spacing: 12) {
                    GhostButton(
                        title: LocalizedText(fr: "Précédente", en: "Previous", es: "Anterior")[language],
                        systemImage: "chevron.left"
                    ) {
                        step = max(0, step - 1)
                    }
                    .disabled(step == 0)
                    .opacity(step == 0 ? 0.4 : 1)

                    PrimaryButton(
                        title: LocalizedText(fr: "Suivante", en: "Next", es: "Siguiente")[language],
                        systemImage: "chevron.right"
                    ) {
                        step = min(steps.count - 1, step + 1)
                    }
                    .disabled(step >= steps.count - 1)
                    .opacity(step >= steps.count - 1 ? 0.4 : 1)
                }
            }
        }
    }

    private var mistakesCard: some View {
        Card(
            title: LocalizedText(
                fr: "Si quelque chose ne va pas",
                en: "If something feels wrong",
                es: "Si algo no va bien"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 14) {
                ForEach(technique.mistakes) { mistake in
                    VStack(alignment: .leading, spacing: 5) {
                        CoachText(mistake.symptom, font: Theme.captionFont, color: Theme.warning)
                        CoachText(mistake.cause, font: .system(size: 12))
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "wrench.adjustable")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.accent)
                            CoachText(mistake.fix, font: .system(size: 13), color: Theme.primaryText)
                        }
                    }
                }
            }
        }
    }
}

/// Le parcours des premières semaines, sur l'écran du jour.
struct FirstSessionsCard: View {
    var step: FirstSessionsStep

    @Environment(\.language) private var language

    var body: some View {
        Card(
            title: step.title[language],
            subtitle: LocalizedText(
                fr: "Semaine \(step.week) du parcours débutant",
                en: "Week \(step.week) of the beginner path",
                es: "Semana \(step.week) del recorrido para principiantes"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(step.goal, font: Theme.headlineFont, color: Theme.accent)
                CoachText(step.instruction, color: Theme.primaryText)
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                    CoachText(step.readyWhen, font: .system(size: 12))
                }
            }
        }
    }
}
