import SwiftUI
import MonCoachKit

/// Le coach de salle, ouvert depuis la séance en cours.
///
/// On arrive ici avec un appareil pris devant les yeux et trente secondes
/// d'attention : l'obstacle se choisit d'un geste, la réponse tient dans le
/// premier écran, et les remplacements sont assez près pour être pris sans
/// réfléchir.
struct GymCoachView: View {
    /// L'exercice qui pose problème, quand on vient d'une séance.
    var exercise: Exercise?
    var session: PlannedSession?

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var obstacle: GymObstacle = .equipmentBusy
    /// La fiche guidée ouverte depuis la sélection du jour.
    @State private var opened: Exercise?

    /// Appelé quand l'athlète choisit un remplacement, pour que la séance
    /// en cours le prenne en compte plutôt que de l'obliger à s'en souvenir.
    var onSubstitute: ((Exercise) -> Void)?

    private var answer: GymAnswer? {
        guard let profile = store.profile else { return nil }
        return GymCoach.answer(to: obstacle, exercise: exercise, profile: profile, session: session)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    // Ouvert depuis le Plan, sans exercice qui coince, ce
                    // n'est pas un obstacle qu'on vient chercher : c'est ce
                    // que la salle permet aujourd'hui. La sélection du jour
                    // passe alors devant.
                    if exercise == nil { dailyGymCard }
                    obstaclePicker

                    if let answer {
                        Card(title: answer.headline[language]) {
                            CoachText(answer.detail, color: Theme.primaryText)
                        }

                        if !answer.substitutions.isEmpty {
                            Card(
                                title: LocalizedText(
                                    fr: "À la place",
                                    en: "Instead",
                                    es: "En su lugar"
                                )[language],
                                subtitle: exercise?.name[language]
                            ) {
                                VStack(spacing: 14) {
                                    ForEach(answer.substitutions) { option in
                                        SubstitutionRow(option: option) {
                                            onSubstitute?(option.exercise)
                                            dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    if exercise != nil { dailyGymCard }
                    guideCard
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Coach de salle", en: "Gym coach", es: "Entrenador de sala")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .sheet(item: $opened) { exercise in
                GuidedTechniqueView(exercise: exercise)
            }
        }
    }

    /// Les mouvements que seule une salle permet, renouvelés chaque jour.
    ///
    /// On ouvre cet écran en étant déjà dans la salle, entouré de machines
    /// qu'on n'a pas chez soi et qu'on n'utilise jamais faute de savoir par
    /// où commencer. La liste change tous les jours, qu'on ait fait la
    /// précédente ou non : une liste qui attend d'être cochée devient une
    /// dette, et une dette qu'on ne rembourse pas, on cesse de la regarder.
    private var dailyGymCard: some View {
        let picks = GymSpecific.ofTheDay(profile: store.profile)
        return Group {
            if !picks.isEmpty {
                Card(
                    title: LocalizedText(
                        fr: "Les exercices de salle du jour",
                        en: "Today's gym-only moves",
                        es: "Los ejercicios de sala de hoy"
                    )[language],
                    subtitle: Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(language.locale))
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        CoachText(GymSpecific.howToUse)
                        ForEach(picks) { exercise in
                            Button {
                                opened = exercise
                            } label: {
                                dailyRow(exercise)
                            }
                            .buttonStyle(.plain)
                        }
                        CoachText(
                            LocalizedText(
                                fr: "Demain, ce sera quatre autres : rien à rattraper, rien à cocher.",
                                en: "Tomorrow it will be four different ones: nothing to catch up on, nothing to tick off.",
                                es: "Mañana serán otros cuatro: nada que recuperar, nada que marcar."
                            ),
                            font: .system(size: 12)
                        )
                    }
                }
            }
        }
    }

    private func dailyRow(_ exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(exercise.name[language])
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.primaryText)
                Spacer()
                Text("\(exercise.viableRepRange.lowerBound)–\(exercise.viableRepRange.upperBound)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
            }
            Text(
                exercise.equipment.map { $0.label[language] }.sorted().joined(separator: " + ")
                + " · " + exercise.primaryMuscle.label[language]
            )
            .font(.system(size: 11))
            .foregroundStyle(Theme.secondaryText)
            CoachText(GymSpecific.reason(for: exercise), font: .system(size: 12))
            HStack(spacing: 4) {
                Image(systemName: "book")
                    .font(.system(size: 10))
                Text(
                    LocalizedText(
                        fr: "Voir la fiche",
                        en: "See the technique",
                        es: "Ver la ficha"
                    )[language]
                )
                .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(Theme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
    }

    private var obstaclePicker: some View {
        Card(
            title: LocalizedText(
                fr: "Qu'est-ce qui bloque ?",
                en: "What is in the way?",
                es: "¿Qué te lo impide?"
            )[language]
        ) {
            FlowLayout(spacing: 8) {
                ForEach(GymObstacle.allCases) { candidate in
                    Button {
                        obstacle = candidate
                    } label: {
                        Pill(
                            text: candidate.label[language],
                            tint: candidate == obstacle ? Theme.accent : Theme.secondaryText
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    /// Le guide de la salle, replié : il ne doit pas passer devant la réponse
    /// à l'obstacle du moment, mais il est là quand on a le temps de lire.
    private var guideCard: some View {
        VStack(spacing: Theme.stackSpacing) {
            ForEach(GymTopic.allCases) { topic in
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(GymGuide.tips(for: topic)) { tip in
                            VStack(alignment: .leading, spacing: 5) {
                                CoachText(tip.title, font: Theme.captionFont, color: Theme.primaryText)
                                CoachText(tip.body, font: .system(size: 13))
                                if let takeaway = tip.takeaway {
                                    CoachText(takeaway, font: .system(size: 12), color: Theme.accent)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                } label: {
                    Text(topic.label[language])
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                }
                .tint(Theme.accent)
                .padding(Theme.cardPadding)
                .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .stroke(Theme.separator, lineWidth: 1)
                )
            }
        }
    }
}

/// Un remplacement proposé, avec ce qu'il change.
struct SubstitutionRow: View {
    var option: Substitution
    var onPick: () -> Void

    @Environment(\.language) private var language

    var body: some View {
        Button(action: onPick) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(option.exercise.name[language])
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                    Spacer()
                    Text("\(option.closeness)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }
                Text(
                    option.exercise.equipment
                        .map { $0.label[language] }
                        .sorted()
                        .joined(separator: " + ")
                )
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
                CoachText(option.reason, font: .system(size: 12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
