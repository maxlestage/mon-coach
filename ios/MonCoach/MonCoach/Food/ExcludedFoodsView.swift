import SwiftUI
import MonCoachKit

/// Tout le catalogue, pour dire d'avance ce qu'on ne mangera pas.
///
/// Pourquoi cette vue existe
/// -------------------------
/// Le refus se déclarait devant l'assiette, en touchant un aliment servi.
/// C'est le bon endroit pour un dégoût — il naît là — et le mauvais pour une
/// allergie : l'allergique sait d'avance ce qu'il ne mangera jamais, et
/// attendre que l'arachide soit servie pour la refuser, c'est attendre
/// qu'elle soit servie. Ici, le catalogue entier se cherche et se parcourt,
/// avant le premier repas comme après le centième.
///
/// La liste des écartés ouvre l'écran : c'est elle qu'on vient vérifier.
/// Chaque refus et chaque retour passent par la même feuille que devant
/// l'assiette — un seul chemin, une seule règle, y compris celle qui
/// empêche de vider un rôle entier.
struct ExcludedFoodsView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var search = ""
    /// L'aliment qu'on est en train de juger, le temps de la feuille.
    @State private var questioned: Food?

    private var refusedIDs: Set<String> { store.profile?.excludedFoods ?? [] }

    private var refused: [Food] {
        refusedIDs
            .compactMap { FoodCatalog.food(id: $0) }
            .sorted { $0.name[language] < $1.name[language] }
    }

    /// La recherche ignore les accents et la casse : « peche » doit trouver
    /// la pêche, surtout tapé d'une main dans une cuisine.
    private func matches(_ food: Food) -> Bool {
        guard !search.isEmpty else { return true }
        return normalized(food.name[language]).contains(normalized(search))
    }

    private func normalized(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: language.locale)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card {
                        CoachText(
                            LocalizedText(
                                fr: "Allergie, intolérance ou simple dégoût : écarte ici tout ce que tu ne veux pas voir dans ton assiette. Les repas, les recettes et la liste de courses se refont aussitôt sans ces aliments — et un plat qui en dépendait est remplacé par un autre.",
                                en: "Allergy, intolerance or plain dislike: rule out here anything you never want on your plate. Meals, recipes and the shopping list rebuild at once without those foods — and a dish that relied on one is replaced by another.",
                                es: "Alergia, intolerancia o simple rechazo: descarta aquí todo lo que no quieras ver en tu plato. Las comidas, las recetas y la lista de la compra se rehacen al momento sin esos alimentos, y un plato que dependía de uno se sustituye por otro."
                            )
                        )
                    }

                    searchCard

                    if !refused.isEmpty && search.isEmpty {
                        refusedCard
                    }

                    catalogCards
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(
                    fr: "Ce que tu ne manges pas",
                    en: "What you don't eat",
                    es: "Lo que no comes"
                )[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .sheet(item: $questioned) { food in
                RefuseFoodSheet(food: food)
            }
        }
    }

    private var searchCard: some View {
        Card {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Theme.secondaryText)
                TextField(
                    LocalizedText(
                        fr: "Chercher un aliment",
                        en: "Search for a food",
                        es: "Buscar un alimento"
                    )[language],
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

    /// Les écartés d'abord : c'est la liste qu'on vient vérifier, celle qui
    /// n'apparaissait nulle part d'assez visible.
    private var refusedCard: some View {
        Card(
            title: LocalizedText(
                fr: "Écartés en ce moment",
                en: "Ruled out right now",
                es: "Descartados ahora mismo"
            )[language],
            subtitle: LocalizedText(
                fr: "Jamais servis, jamais sur la liste de courses. Les goûts changent : « Remettre » suffit.",
                en: "Never served, never on the shopping list. Tastes change: “Put back” is all it takes.",
                es: "Nunca servidos, nunca en la lista de la compra. Los gustos cambian: «Devolver» basta."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(refused) { food in
                    HStack(spacing: 10) {
                        Button {
                            questioned = food
                        } label: {
                            Text(food.name[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            store.allowFood(food.id)
                        } label: {
                            Text(
                                LocalizedText(
                                    fr: "Remettre",
                                    en: "Put back",
                                    es: "Devolver"
                                )[language]
                            )
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    /// Le catalogue par rayon, dans l'ordre de l'assiette. Chaque ligne
    /// ouvre la même feuille que devant un repas : remplaçants d'abord,
    /// refus ensuite.
    @ViewBuilder
    private var catalogCards: some View {
        let matching = FoodCatalog.all.filter(matches)
        if matching.isEmpty {
            Card {
                CoachText(
                    LocalizedText(
                        fr: "Aucun aliment ne porte ce nom dans le catalogue. Ce qui n'y figure pas ne sera jamais servi de toute façon.",
                        en: "No food in the catalogue goes by that name. Whatever is not in it will never be served anyway.",
                        es: "Ningún alimento del catálogo lleva ese nombre. Lo que no está en él nunca se servirá de todos modos."
                    )
                )
            }
        } else {
            ForEach(FoodRole.allCases, id: \.self) { role in
                let foods = matching
                    .filter { $0.role == role }
                    .sorted { $0.name[language] < $1.name[language] }
                if !foods.isEmpty {
                    Card(title: role.label[language]) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(foods) { food in
                                Button {
                                    questioned = food
                                } label: {
                                    HStack(spacing: 10) {
                                        Text(food.name[language])
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(
                                                refusedIDs.contains(food.id)
                                                    ? Theme.secondaryText
                                                    : Theme.primaryText
                                            )
                                            .strikethrough(refusedIDs.contains(food.id))
                                        Spacer()
                                        if refusedIDs.contains(food.id) {
                                            Pill(
                                                text: LocalizedText(
                                                    fr: "écarté", en: "out", es: "fuera"
                                                )[language],
                                                tint: Theme.danger
                                            )
                                        } else {
                                            Text("\(Int(food.kcal)) kcal · \(Int(food.proteinG)) g P")
                                                .font(.system(size: 11))
                                                .foregroundStyle(Theme.secondaryText)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }
}
