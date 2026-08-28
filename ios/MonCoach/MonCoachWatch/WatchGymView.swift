import SwiftUI
import MonCoachKit

/// Le remplacement d'exercice, au poignet.
///
/// C'est là qu'on se tient quand on découvre que le rack est occupé : le
/// téléphone est au vestiaire, et la question tient en une ligne. Pas de
/// guide, pas de situations : juste ce qu'on peut faire à la place, tout de
/// suite.
struct WatchGymView: View {
    var prescription: ExercisePrescription
    /// Appelé quand l'athlète choisit un remplacement.
    var onPick: (Exercise) -> Void

    @Environment(WatchStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    private var exercise: Exercise? {
        ExerciseCatalog.exercise(id: prescription.exerciseID)
    }

    /// La montre ne connaît pas le profil complet : elle sait le matériel de
    /// l'exercice prescrit, ce qui suffit à écarter le poste occupé. On part
    /// donc d'un athlète en salle complète, sans zone sensible — le téléphone
    /// a déjà filtré ce qu'il ne fallait pas proposer quand il a construit la
    /// séance.
    private var options: [Substitution] {
        guard let exercise else { return [] }
        return GymCoach.substitutions(
            for: exercise,
            profile: UserProfile(
                firstName: "",
                birthDate: Date(timeIntervalSince1970: 0),
                sex: .male,
                heightCm: 175,
                weightKg: 75,
                goal: .hypertrophy
            ),
            excludingEquipment: exercise.equipment,
            limit: 3
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if let exercise {
                    Text(exercise.name[language])
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(.secondary)
                }

                if options.isEmpty {
                    Text(
                        LocalizedText(
                            fr: "Rien d'équivalent sans ce matériel. Passe au mouvement suivant et reviens plus tard.",
                            en: "Nothing equivalent without that kit. Move to the next exercise and come back later.",
                            es: "Nada equivalente sin ese material. Pasa al siguiente ejercicio y vuelve luego."
                        )[language]
                    )
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                } else {
                    ForEach(options) { option in
                        Button {
                            onPick(option.exercise)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.exercise.name[language])
                                    .font(.system(.body, design: .rounded, weight: .semibold))
                                    .multilineTextAlignment(.leading)
                                Text(
                                    option.exercise.equipment
                                        .map { $0.label[language] }
                                        .sorted()
                                        .joined(separator: " + ")
                                )
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.bordered)
                        .tint(.green)
                    }

                    Text(
                        LocalizedText(
                            fr: "La charge ne sera pas la même : vise le même effort en fin de série.",
                            en: "The load will not be the same: aim for the same effort at the end of the set.",
                            es: "La carga no será la misma: busca el mismo esfuerzo al final de la serie."
                        )[language]
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(
            LocalizedText(fr: "À la place", en: "Instead", es: "En su lugar")[language]
        )
    }
}
