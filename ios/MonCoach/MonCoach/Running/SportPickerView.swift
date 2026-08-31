import SwiftUI
import MonCoachKit

/// « Je fais quoi ? » — le catalogue des sports, rangé et cherchable.
///
/// Pourquoi cette vue existe
/// -------------------------
/// Cinq sports tenaient dans une rangée de pastilles. Quarante-huit n'y
/// tiennent pas : une liste à plat de quarante-huit lignes ne se parcourt
/// pas, et personne ne cherche « aviron » entre « padel » et « yoga ». On
/// range donc par famille — les pieds, les roues, l'eau, la neige, la
/// salle — et on ouvre sur un champ de recherche, parce que celui qui sait
/// déjà ce qu'il va faire ne doit pas avoir à faire défiler.
///
/// Les derniers sports pratiqués passent en tête, avant les familles. Un
/// athlète ne fait pas quarante-huit sports : il en fait trois, et ces
/// trois-là ne doivent jamais demander plus d'un geste.
struct SportPickerView: View {
    /// Le sport actuellement retenu.
    @Binding var selection: Sport
    /// Les sports mis en avant, du plus récent au plus ancien.
    var recents: [Sport] = []
    /// Restreint aux sports qui laissent une trace — le dessin de parcours
    /// n'a rien à proposer à un cours de yoga.
    var locatedOnly: Bool = false

    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var search = ""

    private var pool: [Sport] {
        locatedOnly ? Sport.allCases.filter(\.tracksLocation) : Sport.allCases
    }

    private func matches(_ sport: Sport) -> Bool {
        guard !search.isEmpty else { return true }
        return normalized(sport.label[language]).contains(normalized(search))
    }

    /// La recherche ignore les accents et la casse : « velo » doit trouver
    /// le vélo, tapé d'une main avant de partir.
    private func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: language.locale)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    searchCard

                    let found = pool.filter(matches)
                    if found.isEmpty {
                        Card {
                            CoachText(
                                LocalizedText(
                                    fr: "Aucun sport de ce nom. Choisis celui qui s'en rapproche le plus : c'est lui qui règle la mesure et la dépense.",
                                    en: "No sport by that name. Pick the closest one: it is what sets the measurement and the energy cost.",
                                    es: "Ningún deporte con ese nombre. Elige el más parecido: es el que ajusta la medición y el gasto."
                                )
                            )
                        }
                    } else {
                        if search.isEmpty, !recentsShown.isEmpty {
                            group(
                                title: LocalizedText(
                                    fr: "Tes sports", en: "Your sports", es: "Tus deportes"
                                )[language],
                                sports: recentsShown
                            )
                        }
                        ForEach(SportFamily.allCases) { family in
                            let sports = found.filter { $0.family == family }
                            if !sports.isEmpty {
                                group(title: family.label[language], sports: sports)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Choisir un sport", en: "Choose a sport", es: "Elegir un deporte")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }

    private var recentsShown: [Sport] {
        var seen = Set<Sport>()
        return recents.filter { pool.contains($0) && seen.insert($0).inserted }
    }

    private var searchCard: some View {
        Card {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                TextField(
                    LocalizedText(fr: "Chercher", en: "Search", es: "Buscar")[language],
                    text: $search
                )
                .font(Theme.bodyFont)
                .autocorrectionDisabled()
                if !search.isEmpty {
                    Button {
                        search = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func group(title: String, sports: [Sport]) -> some View {
        Card(title: title) {
            VStack(spacing: 2) {
                ForEach(sports) { sport in
                    Button {
                        selection = sport
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: sport.symbolName)
                                .font(.system(size: 16))
                                .foregroundStyle(selection == sport ? Theme.accent : Theme.secondaryText)
                                .frame(width: 26)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(sport.label[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                // Ce que le sport change concrètement, dit
                                // en trois mots : sans quoi « Rameur » et
                                // « Aviron » se ressemblent à l'écran alors
                                // que l'un se trace et l'autre non.
                                Text(detail(for: sport))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer()
                            if selection == sport {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                        .padding(.vertical, 7)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func detail(for sport: Sport) -> String {
        if !sport.tracksLocation {
            return LocalizedText(
                fr: "Chrono et cardio, sans GPS",
                en: "Timer and heart rate, no GPS",
                es: "Cronómetro y pulso, sin GPS"
            )[language]
        }
        if sport.feedsRunningPlan {
            return LocalizedText(
                fr: "Compte dans ton plan de course",
                en: "Counts toward your running plan",
                es: "Cuenta en tu plan de carrera"
            )[language]
        }
        return sport.readout == .speed
            ? LocalizedText(fr: "GPS, vitesse en km/h", en: "GPS, speed in km/h", es: "GPS, velocidad en km/h")[language]
            : LocalizedText(fr: "GPS, allure au kilomètre", en: "GPS, pace per kilometre", es: "GPS, ritmo por kilómetro")[language]
    }
}
