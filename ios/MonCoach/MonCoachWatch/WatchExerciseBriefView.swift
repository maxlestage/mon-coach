import SwiftUI
import MonCoachKit

/// La fiche d'un exercice, au poignet.
///
/// Pourquoi elle existe aussi ici
/// ------------------------------
/// C'est en salle, devant la machine, qu'on se demande où mettre les pieds —
/// et c'est précisément là qu'on n'a pas envie de sortir son téléphone d'un
/// sac posé à l'autre bout. La montre porte donc la même fiche que le
/// téléphone, réduite à ce qui se lit debout : ce que c'est, comment on le
/// règle, et l'erreur à ne pas faire.
///
/// La technique pas à pas, elle, reste sur le téléphone : sept étapes avec
/// leurs points de contrôle ne se lisent pas sur quatre centimètres.
struct WatchExerciseBriefView: View {
    var exercise: Exercise

    @Environment(\.language) private var language

    private var brief: ExerciseBrief? { ExerciseBriefs.brief(for: exercise) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let brief {
                    section(
                        icon: "questionmark.circle",
                        title: LocalizedText(fr: "Ce que c'est", en: "What it is", es: "Qué es"),
                        text: brief.what,
                        tint: .green
                    )
                    section(
                        icon: "slider.horizontal.3",
                        title: LocalizedText(fr: "Le réglage", en: "The setup", es: "El ajuste"),
                        text: brief.setup,
                        tint: .green
                    )
                    section(
                        icon: "exclamationmark.triangle.fill",
                        title: LocalizedText(fr: "À éviter", en: "Avoid", es: "Evita"),
                        text: brief.watchOut,
                        tint: .orange
                    )
                }

                section(
                    icon: "scalemass",
                    title: LocalizedText(fr: "La charge", en: "The load", es: "La carga"),
                    text: ExerciseBriefs.loadAdvice(for: exercise),
                    tint: .gray
                )

                // Le repère court du catalogue : c'est celui qu'on relit
                // pendant la série elle-même.
                Text(exercise.cue[language])
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.green)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .navigationTitle(exercise.name[language])
    }

    private func section(
        icon: String,
        title: LocalizedText,
        text: LocalizedText,
        tint: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Label(title[language], systemImage: icon)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(tint)
            Text(text[language])
                .font(.system(size: 13))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
