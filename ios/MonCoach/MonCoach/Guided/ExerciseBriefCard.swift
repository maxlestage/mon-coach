import SwiftUI
import MonCoachKit

/// La fiche d'un exercice précis, telle qu'on la lit debout devant une
/// machine.
///
/// Pourquoi elle passe avant la technique
/// --------------------------------------
/// La fiche guidée explique un schéma moteur — comment on s'accroupit,
/// comment on tire. Elle est juste, et elle vaut pour dix exercices à la
/// fois. Mais quelqu'un qui découvre une machine ne demande pas comment on
/// s'accroupit : il demande ce que cette machine-là lui veut, où mettre les
/// pieds, et ce qui va lui faire mal. Ces réponses viennent donc en premier,
/// et la technique de famille juste après.
///
/// Rien ici n'est recopié à la main : les muscles, la charge, le repos, le
/// matériel et les remplaçants se déduisent du catalogue. Une donnée recopiée
/// finit toujours par mentir le jour où l'autre change.
struct ExerciseBriefCard: View {
    var exercise: Exercise
    /// Le matériel dont l'athlète dispose, pour ne proposer que des
    /// remplaçants qu'il peut réellement faire.
    var owned: Set<Equipment>?

    @Environment(\.language) private var language

    private var brief: ExerciseBrief? { ExerciseBriefs.brief(for: exercise) }

    var body: some View {
        VStack(spacing: Theme.stackSpacing) {
            whatCard
            setupCard
            watchOutCard
            practicalCard
            alternativesCard
        }
    }

    // MARK: - Ce que c'est

    private var whatCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que c'est", en: "What it is", es: "Qué es"
            )[language]
        ) {
            if let brief {
                CoachText(brief.what, color: Theme.primaryText)
            }

            // Les muscles et leur part, avec la règle qui sert aussi à
            // compter le volume de la semaine : cent pour cent au principal,
            // cinquante à chaque secondaire.
            FlowLayout(spacing: 8) {
                ForEach(ExerciseBriefs.muscles(of: exercise)) { share in
                    HStack(spacing: 5) {
                        Text(share.muscle.label[language])
                            .font(.system(size: 13, weight: .medium))
                        Text("\(share.percent) %")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(share.credit >= 1 ? Theme.accent : Theme.secondaryText)
                    }
                    .foregroundStyle(Theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.surfaceRaised, in: Capsule())
                }
            }

            CoachText(ExerciseBriefs.role(of: exercise), font: .system(size: 13))
        }
    }

    // MARK: - Le réglage

    private var setupCard: some View {
        Card(
            title: LocalizedText(
                fr: "Comment le régler", en: "How to set it up", es: "Cómo ajustarlo"
            )[language],
            subtitle: LocalizedText(
                fr: "La partie qu'aucune vidéo ne montre assez lentement.",
                en: "The part no video shows slowly enough.",
                es: "La parte que ningún vídeo enseña lo bastante despacio."
            )[language]
        ) {
            if let brief {
                CoachText(brief.setup, color: Theme.primaryText)
            }
            // Le repère court du catalogue, celui qui s'affiche pendant la
            // série : le répéter ici évite d'avoir à retenir deux textes.
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.accent)
                Text(exercise.cue[language])
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    // MARK: - L'erreur

    private var watchOutCard: some View {
        Card(
            title: LocalizedText(
                fr: "L'erreur de ce mouvement",
                en: "The mistake this one invites",
                es: "El error de este movimiento"
            )[language]
        ) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.warning)
                if let brief {
                    CoachText(brief.watchOut, color: Theme.primaryText)
                }
            }
        }
    }

    // MARK: - La pratique

    private var practicalCard: some View {
        Card(
            title: LocalizedText(
                fr: "Charge, repos, matériel", en: "Load, rest, kit", es: "Carga, descanso, material"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                labelled(
                    icon: "scalemass",
                    text: ExerciseBriefs.loadAdvice(for: exercise)
                )
                labelled(
                    icon: "timer",
                    text: ExerciseBriefs.restAdvice(for: exercise)
                )
            }
            FlowLayout(spacing: 8) {
                ForEach(ExerciseBriefs.equipmentNeeded(for: exercise), id: \.self) { item in
                    Text(item.label[language])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Theme.surfaceRaised, in: Capsule())
                }
            }
        }
    }

    private func labelled(icon: String, text: LocalizedText) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Theme.accent)
                .frame(width: 16)
            Text(text[language])
                .font(.system(size: 13))
                .foregroundStyle(Theme.primaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Les remplaçants

    /// Ce qu'on fait quand la machine est prise.
    ///
    /// C'est la question la plus fréquente d'une salle pleine à dix-huit
    /// heures, et jusqu'ici la réponse était « débrouille-toi ». Les
    /// remplaçants partagent le schéma moteur et le muscle principal : ce
    /// sont de vrais échanges, pas des à-peu-près.
    @ViewBuilder
    private var alternativesCard: some View {
        let others = ExerciseBriefs.alternatives(to: exercise, owning: owned)
        if !others.isEmpty {
            Card(
                title: LocalizedText(
                    fr: "Si la machine est prise",
                    en: "If it is taken",
                    es: "Si está ocupada"
                )[language],
                subtitle: LocalizedText(
                    fr: "Même schéma, même muscle principal : ce sont de vrais échanges.",
                    en: "Same pattern, same primary muscle: these are genuine swaps.",
                    es: "Mismo patrón, mismo músculo principal: son intercambios reales."
                )[language]
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(others) { other in
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText)
                            Text(other.name[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Text(
                                other.equipment
                                    .sorted { $0.rawValue < $1.rawValue }
                                    .map { $0.label[language] }
                                    .joined(separator: " · ")
                            )
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(1)
                        }
                    }
                }
            }
        }
    }
}

/// Le bouton qui ouvre la fiche d'un exercice.
///
/// Il est volontairement partout : dans la séance du jour, dans le plan,
/// dans l'aperçu de l'inscription, dans le coach de salle. Une explication
/// qu'il faut aller chercher dans un écran dédié n'est pas lue — et c'est
/// précisément au moment où l'on voit le nom d'un mouvement inconnu qu'on a
/// besoin de savoir ce que c'est.
struct ExerciseInfoButton: View {
    var exercise: Exercise
    var owned: Set<Equipment>?

    @State private var showsBrief = false

    var body: some View {
        Button {
            showsBrief = true
        } label: {
            Image(systemName: "info.circle")
                .font(.system(size: 15))
                .foregroundStyle(Theme.secondaryText)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showsBrief) {
            GuidedTechniqueView(exercise: exercise, owned: owned)
        }
    }
}
