import SwiftUI
import MonCoachKit

/// L'écran alimentation : ce qu'il y a à manger aujourd'hui, pourquoi, et
/// quoi acheter pour la semaine.
struct FoodView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var tab: Tab = .today
    @State private var showsShoppingList = false
    @State private var showsExclusions = false
    @State private var showsPlateCamera = false

    enum Tab: Hashable { case today, guide }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Picker("", selection: $tab) {
                        Text(UI.today[language]).tag(Tab.today)
                        Text(LocalizedText(fr: "Le guide", en: "The guide", es: "La guía")[language])
                            .tag(Tab.guide)
                    }
                    .pickerStyle(.segmented)

                    switch tab {
                    case .today: todayTab
                    case .guide: guideTab
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(UI.food[language])
            .toolbar {
                // Les refus à côté du panier : les deux se consultent
                // « quand on veut », pas quand un repas les fait apparaître.
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsPlateCamera = true
                    } label: {
                        Image(systemName: "camera")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsExclusions = true
                    } label: {
                        Image(systemName: "hand.raised")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsShoppingList = true
                    } label: {
                        Image(systemName: "cart")
                    }
                }
            }
            .sheet(isPresented: $showsShoppingList) {
                // Les repas du jour et les cibles restent gratuits ; c'est
                // la liste agrégée de la semaine qui demande Stride+.
                if store.isUnlocked(.shoppingList) {
                    ShoppingListView()
                } else {
                    NavigationStack {
                        ScrollView {
                            PlusLockedCard(feature: .shoppingList).padding(16)
                        }
                        .screenBackground()
                        .navigationTitle(
                            LocalizedText(fr: "Liste de courses", en: "Shopping list", es: "Lista de la compra")[language]
                        )
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            .sheet(isPresented: $showsExclusions) {
                ExcludedFoodsView()
            }
            .sheet(isPresented: $showsPlateCamera) {
                PlatePhotoView()
            }
        }
    }

    // MARK: - Aujourd'hui

    @ViewBuilder
    private var todayTab: some View {
        if let briefing = store.briefing() {
            let target = briefing.nutrition
            let day = briefing.food

            Card {
                HStack(spacing: 12) {
                    StatTile(value: "\(target.calories)", label: "kcal")
                    StatTile(value: "\(target.proteinG) g", label: LocalizedText(fr: "Protéines", en: "Protein", es: "Proteína")[language])
                    StatTile(value: "\(target.carbsG) g", label: LocalizedText(fr: "Glucides", en: "Carbs", es: "Hidratos")[language])
                    StatTile(value: "\(target.fatG) g", label: LocalizedText(fr: "Lipides", en: "Fat", es: "Grasas")[language])
                }
            }

            eatenCard(target: target)

            ForEach(day.meals) { meal in
                MealCard(meal: meal)
            }

            exclusionsCard

            ForEach(day.notes, id: \.self) { note in
                Card { CoachText(note, color: Theme.primaryText) }
            }

            Card(title: LocalizedText(fr: "Pourquoi ces chiffres", en: "Why these numbers", es: "Por qué estas cifras")[language]) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(target.rationale, id: \.self) { reason in
                        CoachText(reason, font: .system(size: 13))
                    }
                }
            }
        } else {
            Card { CoachText(LocalizedText(
                fr: "Le programme alimentaire arrive avec ton premier bloc d'entraînement.",
                en: "The food plan arrives with your first training block.",
                es: "El plan de alimentación llega con tu primer bloque de entrenamiento."
            )) }
        }
    }

    /// Ce qui a réellement été mangé aujourd'hui, d'après les assiettes
    /// photographiées.
    ///
    /// Le plan prescrit, ce bloc constate — et c'est l'écart entre les deux
    /// qui apprend quelque chose. Il ne s'affiche qu'une fois la première
    /// photo prise : afficher « 0 g mangé » à quelqu'un qui n'a rien
    /// photographié serait faux, et surtout décourageant au petit-déjeuner.
    @ViewBuilder
    private func eatenCard(target: NutritionTarget) -> some View {
        let plates = store.plates(on: Date())
        if !plates.isEmpty {
            let eaten = plates.map(\.macros).reduce(Macros.zero, +)
            let remaining = max(0, Double(target.proteinG) - eaten.proteinG)
            Card(
                title: LocalizedText(fr: "Ce que tu as mangé", en: "What you have eaten", es: "Lo que has comido")[language],
                subtitle: LocalizedText(
                    fr: "\(plates.count) assiette\(plates.count > 1 ? "s" : "") photographiée\(plates.count > 1 ? "s" : "") aujourd'hui. Ce sont des estimations : elles suivent une tendance, elles ne comptent pas au gramme.",
                    en: "\(plates.count) plate\(plates.count > 1 ? "s" : "") photographed today. These are estimates: they follow a trend, they do not count to the gram.",
                    es: "\(plates.count) plato\(plates.count > 1 ? "s" : "") fotografiado\(plates.count > 1 ? "s" : "") hoy. Son estimaciones: siguen una tendencia, no cuentan al gramo."
                )[language]
            ) {
                HStack(spacing: 12) {
                    StatTile(
                        value: "\(Int(eaten.proteinG)) / \(target.proteinG) g",
                        label: LocalizedText(fr: "Protéines", en: "Protein", es: "Proteína")[language]
                    )
                    StatTile(
                        value: "\(Int(eaten.kcal)) / \(target.calories)",
                        label: "kcal",
                        tint: Theme.secondaryText
                    )
                    StatTile(
                        value: "\(Int(remaining)) g",
                        label: LocalizedText(fr: "Restant", en: "Left", es: "Restante")[language],
                        tint: remaining > 0 ? Theme.warning : Theme.accent
                    )
                }
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(plates, id: \.date) { plate in
                        HStack(spacing: 10) {
                            Text(plate.date.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 12, design: .rounded))
                                .foregroundStyle(Theme.secondaryText)
                                .frame(width: 46, alignment: .leading)
                            Text(
                                plate.items
                                    .compactMap { $0.food?.name[language] }
                                    .prefix(3)
                                    .joined(separator: ", ")
                            )
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)
                            Spacer()
                            Text("\(Int(plate.proteinG)) g")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.accent)
                            Button {
                                store.deletePlate(at: plate.date)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    /// Les aliments écartés, en clair sous les repas du jour.
    ///
    /// Cette liste ne vivait que dans le profil, et seulement quand elle
    /// n'était pas vide : quelqu'un d'allergique ne voyait nulle part que
    /// l'application le savait, ni où le lui dire. Elle s'affiche désormais
    /// là où on mange, tous les jours, vide ou pleine — et elle mène à
    /// l'éditeur du catalogue entier, modifiable à tout moment.
    @ViewBuilder
    private var exclusionsCard: some View {
        let refused = (store.profile?.excludedFoods ?? [])
            .compactMap { FoodCatalog.food(id: $0) }
            .sorted { $0.name[language] < $1.name[language] }
        Card(
            title: LocalizedText(
                fr: "Ce que tu ne manges pas",
                en: "What you don't eat",
                es: "Lo que no comes"
            )[language],
            subtitle: (refused.isEmpty
                ? LocalizedText(
                    fr: "Allergie, intolérance ou dégoût : écarte un aliment quand tu veux, les repas et les recettes se refont sans lui.",
                    en: "Allergy, intolerance or dislike: rule out a food whenever you like, meals and recipes rebuild without it.",
                    es: "Alergia, intolerancia o rechazo: descarta un alimento cuando quieras, las comidas y recetas se rehacen sin él."
                )
                : LocalizedText(
                    fr: "Jamais servis, jamais sur la liste de courses. Les recettes qui en dépendaient sont remplacées par d'autres.",
                    en: "Never served, never on the shopping list. Recipes that relied on them are replaced by others.",
                    es: "Nunca servidos, nunca en la lista de la compra. Las recetas que dependían de ellos se sustituyen por otras."
                ))[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if !refused.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(refused) { food in
                            Pill(text: food.name[language], tint: Theme.danger)
                        }
                    }
                }
                Button {
                    showsExclusions = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "hand.raised")
                            .font(.system(size: 12, weight: .semibold))
                        Text(
                            LocalizedText(
                                fr: "Choisir dans tout le catalogue",
                                en: "Pick from the whole catalogue",
                                es: "Elegir en todo el catálogo"
                            )[language]
                        )
                        .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Theme.accent)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Le guide

    @ViewBuilder
    private var guideTab: some View {
        let diet = store.profile?.dietPreference ?? .omnivore

        Card(title: LocalizedText(fr: "Les échanges qui comptent", en: "The swaps that matter", es: "Los cambios que importan")[language]) {
            VStack(spacing: 12) {
                ForEach(FoodGuidance.swaps(for: diet)) { swap in
                    SwapRow(swap: swap)
                }
            }
        }

        ForEach(FoodGuidance.sections(diet: diet, excluding: store.profile?.excludedFoods ?? [])) { section in
            Card(title: section.role.label[language]) {
                VStack(alignment: .leading, spacing: 12) {
                    TierGroup(tier: .base, foods: section.base)
                    TierGroup(tier: .moderate, foods: section.moderate)
                    TierGroup(tier: .occasional, foods: section.occasional)
                }
            }
        }
    }
}

/// Un repas et ses quantités.
struct MealCard: View {
    var meal: Meal

    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store
    @State private var showingSteps = false
    /// L'aliment sur lequel on vient d'appuyer, le temps de dire si on
    /// l'aime ou non. Nil le reste du temps.
    @State private var questioned: Food?

    /// Le nom du plat quand il y en a un, le moment de la journée sinon.
    ///
    /// « Dîner » au-dessus d'une liste de grammes ne dit pas quoi cuisiner.
    /// Quand un plat porte le repas, c'est lui le titre : le moment redescend
    /// en sous-titre, où il n'a jamais rien appris à personne.
    private var title: String {
        meal.recipe?.name[language] ?? meal.slot.label[language]
    }

    private var subtitle: String {
        let macros = "\(Int(meal.macros.kcal)) kcal · \(Int(meal.macros.proteinG)) g"
        guard let recipe = meal.recipe else { return macros }
        return "\(meal.slot.label[language]) · \(recipe.minutes) min · \(macros)"
    }

    var body: some View {
        Card(title: title, subtitle: subtitle) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(meal.items) { item in
                    if let food = item.food {
                        // Chaque aliment s'ouvre : c'est devant l'assiette
                        // qu'on se rend compte qu'on n'aime pas quelque
                        // chose, pas dans un écran de réglages.
                        Button {
                            questioned = food
                        } label: {
                            HStack(alignment: .top, spacing: 10) {
                                Text("\(Int(item.grams)) g")
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                                    .frame(width: 56, alignment: .leading)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name[language])
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.primaryText)
                                    if food.tier != .base {
                                        Text(food.tier.label[language])
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(Theme.warning)
                                    }
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                if let recipe = meal.recipe {
                    Button {
                        showingSteps.toggle()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showingSteps ? "chevron.down" : "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                            Text(
                                LocalizedText(
                                    fr: "Comment le faire",
                                    en: "How to make it",
                                    es: "Cómo prepararlo"
                                )[language]
                            )
                            .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Theme.accent)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        LocalizedText(
                            fr: "Voir la préparation de \(recipe.name.fr)",
                            en: "Show how to make \(recipe.name.en)",
                            es: "Ver la preparación de \(recipe.name.es)"
                        )[language]
                    )

                    if showingSteps {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 10) {
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.accent)
                                        .frame(width: 16, alignment: .leading)
                                    Text(step[language])
                                        .font(.system(size: 13))
                                        .foregroundStyle(Theme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                if let note = meal.note {
                    CoachText(note, font: .system(size: 12))
                }
            }
        }
        .sheet(item: $questioned) { food in
            RefuseFoodSheet(food: food)
        }
    }
}

/// « Je n'aime pas ça » — et ce qu'on mangera à la place.
///
/// Refuser un aliment sans savoir ce qui le remplace fait peur : on ignore
/// ce qu'on perd. La feuille montre donc les remplaçants avant le geste,
/// pas après. Et quand le refus viderait un rôle — les dernières protéines
/// d'un régime — elle le dit au lieu de laisser une journée impossible.
struct RefuseFoodSheet: View {
    var food: Food

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    private var diet: DietPreference { store.profile?.dietPreference ?? .omnivore }
    private var alreadyRefused: Set<String> { store.profile?.excludedFoods ?? [] }
    private var isRefused: Bool { alreadyRefused.contains(food.id) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if isRefused {
                        Card(title: food.name[language]) {
                            CoachText(
                                LocalizedText(
                                    fr: "Cet aliment est écarté de tes repas. Tu peux le rétablir quand tu veux — les goûts changent.",
                                    en: "This food is kept out of your meals. You can bring it back whenever you like — tastes change.",
                                    es: "Este alimento está fuera de tus comidas. Puedes recuperarlo cuando quieras: los gustos cambian."
                                )
                            )
                            PrimaryButton(
                                title: LocalizedText(fr: "Le remettre au menu", en: "Put it back", es: "Volver a ponerlo")[language],
                                systemImage: "arrow.uturn.backward"
                            ) {
                                store.allowFood(food.id)
                                dismiss()
                            }
                        }
                    } else {
                        let canRefuse = FoodSubstitutions.canRefuse(
                            food.id, diet: diet, alreadyExcluded: alreadyRefused
                        )
                        let swaps = FoodSubstitutions.alternatives(
                            to: food.id, diet: diet, excluding: alreadyRefused
                        )
                        Card(
                            title: food.name[language],
                            subtitle: LocalizedText(
                                fr: "\(Int(food.kcal)) kcal · \(Int(food.proteinG)) g de protéines pour 100 g",
                                en: "\(Int(food.kcal)) kcal · \(Int(food.proteinG)) g protein per 100 g",
                                es: "\(Int(food.kcal)) kcal · \(Int(food.proteinG)) g de proteína por 100 g"
                            )[language]
                        ) {
                            CoachText(food.reason)
                        }

                        if canRefuse {
                            Card(
                                title: LocalizedText(fr: "À la place", en: "Instead", es: "En su lugar")[language],
                                subtitle: LocalizedText(
                                    fr: "Même rôle dans l'assiette, macros les plus proches : la journée ne bougera presque pas.",
                                    en: "Same role on the plate, closest macros: the day will barely move.",
                                    es: "Mismo papel en el plato, macros más cercanos: el día apenas cambiará."
                                )[language]
                            ) {
                                VStack(alignment: .leading, spacing: 10) {
                                    ForEach(swaps) { swap in
                                        HStack {
                                            Text(swap.name[language])
                                                .font(Theme.bodyFont)
                                                .foregroundStyle(Theme.primaryText)
                                            Spacer()
                                            Text("\(Int(swap.kcal)) kcal · \(Int(swap.proteinG)) g P")
                                                .font(.system(size: 11))
                                                .foregroundStyle(Theme.secondaryText)
                                        }
                                    }
                                }
                            }
                            PrimaryButton(
                                title: LocalizedText(
                                    fr: "Je n'aime pas, ne plus m'en servir",
                                    en: "I don't like it, stop serving it",
                                    es: "No me gusta, deja de servírmelo"
                                )[language],
                                systemImage: "hand.thumbsdown"
                            ) {
                                store.refuseFood(food.id)
                                dismiss()
                            }
                        } else {
                            Card(
                                title: LocalizedText(
                                    fr: "Celui-là, on le garde",
                                    en: "This one has to stay",
                                    es: "Este hay que conservarlo"
                                )[language]
                            ) {
                                CoachText(
                                    LocalizedText(
                                        fr: "C'est l'un des derniers aliments de son rôle que ton régime accepte. L'écarter aussi rendrait la journée impossible à construire. Rétablis-en un autre d'abord, ou élargis ton régime.",
                                        en: "It is one of the last foods in its role your diet accepts. Removing it too would make the day impossible to build. Bring another one back first, or widen your diet.",
                                        es: "Es uno de los últimos alimentos de su papel que tu dieta acepta. Quitarlo también haría imposible construir el día. Recupera otro antes, o amplía tu dieta."
                                    )
                                )
                            }
                        }
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Cet aliment", en: "This food", es: "Este alimento")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }
}

/// Un rang du guide et les aliments qui y tombent.
struct TierGroup: View {
    var tier: FoodTier
    var foods: [Food]

    @Environment(\.language) private var language
    @State private var expanded: String?

    var body: some View {
        if !foods.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Pill(text: tier.label[language], tint: tint)
                    Text("\(foods.count)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                }
                ForEach(foods) { food in
                    Button {
                        expanded = expanded == food.id ? nil : food.id
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(food.name[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                Spacer()
                                Text("\(Int(food.kcal)) kcal · \(Int(food.proteinG)) g P")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            if expanded == food.id {
                                CoachText(food.reason, font: .system(size: 12))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var tint: Color {
        switch tier {
        case .base: Theme.accent
        case .moderate: Theme.warning
        case .occasional: Theme.danger
        }
    }
}

/// Un échange, avec ce qu'il fait gagner.
struct SwapRow: View {
    var swap: FoodSwap

    @Environment(\.language) private var language

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(swap.from?.name[language] ?? swap.fromID)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .strikethrough()
                Image(systemName: "arrow.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
                Text(swap.to?.name[language] ?? swap.toID)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.primaryText)
                Spacer()
                if swap.gain == .calories {
                    Pill(text: "−\(Int(swap.kcalSaved)) kcal", tint: Theme.accent)
                } else {
                    Pill(text: swap.gain.label[language], tint: Theme.accent)
                }
            }
            CoachText(swap.reason, font: .system(size: 12))
        }
    }
}

/// La liste de courses de la semaine.
struct ShoppingListView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    /// Les cases cochées, gardées entre deux ouvertures.
    ///
    /// Elles vivaient dans la vue, et disparaissaient avec elle : on cochait
    /// la moitié de ses courses, on répondait à un message, tout était à
    /// refaire. Les réglages de l'appareil suffisent — c'est une commodité
    /// locale, pas une donnée du profil, et elle n'a rien à faire dans le
    /// fichier que l'athlète exporte.
    @AppStorage("courses-cochees") private var checkedRaw: String = ""

    /// Sur combien de semaines on fait ses courses. Gardé entre deux
    /// ouvertures : c'est une habitude, pas une question qu'on repose
    /// chaque samedi.
    @AppStorage("courses-duree") private var horizonWeeks: Int = 1

    private var horizon: MealPlanner.ShoppingHorizon {
        MealPlanner.ShoppingHorizon(rawValue: horizonWeeks) ?? .week
    }

    private var checked: Set<String> {
        Set(checkedRaw.split(separator: "\n").map(String.init))
    }

    private func toggle(_ foodID: String) {
        var next = checked
        if next.contains(foodID) { next.remove(foodID) } else { next.insert(foodID) }
        checkedRaw = next.sorted().joined(separator: "\n")
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let target = store.program?.nutrition {
                        let week = MealPlanner.week(
                            target: target,
                            diet: store.profile?.dietPreference ?? .omnivore,
                            mealsPerDay: store.profile?.mealCount ?? 4,
                            excluding: store.profile?.excludedFoods ?? []
                        )
                        let list = MealPlanner.shoppingList(for: week, horizon: horizon)
                        let done = list.filter { checked.contains($0.foodID) }.count
                        Card(
                            subtitle: horizon == .week
                                ? LocalizedText(
                                    fr: "Pour sept jours, \(done) sur \(list.count) pris. Les quantités sont celles du magasin : le riz et les pâtes sont donnés secs, le reste en conditionnements entiers.",
                                    en: "For seven days, \(done) of \(list.count) picked up. Quantities are shop quantities: rice and pasta are given dry, the rest in whole packs.",
                                    es: "Para siete días, \(done) de \(list.count) cogidos. Las cantidades son las de la tienda: el arroz y la pasta van en seco, el resto en envases enteros."
                                )[language]
                                : LocalizedText(
                                    fr: "Pour \(horizon.weeks) semaines, \(done) sur \(list.count) pris. Ce qui se garde est pris en une fois ; le frais reste à la quantité d'une semaine et porte « chaque semaine » — des épinards pour un mois pourrissent avant la troisième.",
                                    en: "For \(horizon.weeks) weeks, \(done) of \(list.count) picked up. What keeps is bought in one go; fresh food stays at one week's worth and is marked “every week” — a month of spinach rots before week three.",
                                    es: "Para \(horizon.weeks) semanas, \(done) de \(list.count) cogidos. Lo que se conserva se compra de una vez; lo fresco se queda en una semana y lleva «cada semana»: un mes de espinacas se pudre antes de la tercera."
                                )[language]
                        ) {
                            // La durée se choisit ici : personne ne fait ses
                            // courses au même rythme, et l'application n'a
                            // pas à trancher pour l'athlète.
                            Picker("", selection: $horizonWeeks) {
                                ForEach(MealPlanner.ShoppingHorizon.allCases) { choice in
                                    Text(choice.label[language]).tag(choice.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                            .padding(.bottom, 4)
                            if done > 0 {
                                Button {
                                    checkedRaw = ""
                                } label: {
                                    Text(
                                        LocalizedText(
                                            fr: "Tout décocher",
                                            en: "Clear all",
                                            es: "Desmarcar todo"
                                        )[language]
                                    )
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Theme.accent)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        // Un rayon par carte, dans l'ordre du magasin plutôt
                        // qu'en une seule colonne de trente lignes : c'est
                        // ainsi qu'on fait ses courses, et la liste sert à
                        // faire ses courses.
                        ForEach(aisles(of: list.filter { !$0.isPantry }), id: \.role) { aisle in
                            Card(title: aisle.role.label[language]) {
                                VStack(spacing: 6) {
                                    ForEach(aisle.lines) { line in
                                        Button {
                                            toggle(line.foodID)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Image(systemName: checked.contains(line.foodID)
                                                    ? "checkmark.circle.fill"
                                                    : "circle")
                                                    .foregroundStyle(checked.contains(line.foodID)
                                                        ? Theme.accent
                                                        : Theme.secondaryText)
                                                VStack(alignment: .leading, spacing: 1) {
                                                    Text(line.food?.name[language] ?? line.foodID)
                                                        .font(Theme.bodyFont)
                                                        .foregroundStyle(Theme.primaryText)
                                                        .strikethrough(checked.contains(line.foodID))
                                                    // Le frais ne se stocke pas : sa
                                                    // quantité est celle d'une semaine,
                                                    // et la ligne le dit plutôt que de
                                                    // laisser croire au mois entier.
                                                    if line.repeatsWeekly {
                                                        Text(
                                                            LocalizedText(
                                                                fr: "chaque semaine",
                                                                en: "every week",
                                                                es: "cada semana"
                                                            )[language]
                                                        )
                                                        .font(.system(size: 11, weight: .medium))
                                                        .foregroundStyle(Theme.warning)
                                                    }
                                                }
                                                Spacer()
                                                Text(line.quantity(language))
                                                    .font(Theme.captionFont)
                                                    .foregroundStyle(Theme.secondaryText)
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Le placard à part, et sans chiffres. « 10 g de
                        // graines de tournesol » n'est pas une course, c'est
                        // un reste de calcul : ces produits se rachètent
                        // quand le paquet est fini, pas au gramme.
                        let pantry = list.filter(\.isPantry)
                        if !pantry.isEmpty {
                            Card(
                                title: LocalizedText(
                                    fr: "Placard", en: "Cupboard", es: "Despensa"
                                )[language],
                                subtitle: LocalizedText(
                                    fr: "À racheter seulement si tu n'en as plus.",
                                    en: "Only worth buying if you have run out.",
                                    es: "Solo hay que comprarlo si se te ha acabado."
                                )[language]
                            ) {
                                VStack(spacing: 6) {
                                    ForEach(pantry) { line in
                                        Button {
                                            toggle(line.foodID)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Image(systemName: checked.contains(line.foodID)
                                                    ? "checkmark.circle.fill"
                                                    : "circle")
                                                    .foregroundStyle(checked.contains(line.foodID)
                                                        ? Theme.accent
                                                        : Theme.secondaryText)
                                                Text(line.quantity(language))
                                                    .font(Theme.bodyFont)
                                                    .foregroundStyle(Theme.primaryText)
                                                    .strikethrough(checked.contains(line.foodID))
                                                Spacer()
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
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Liste de courses", en: "Shopping list", es: "Lista de la compra")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }

    /// Les lignes groupées par rayon, dans l'ordre où le moteur les a rendues.
    ///
    /// L'ordre vient de `shoppingList`, qui trie déjà par rôle : le
    /// reproduire ici plutôt que de retrier évite deux classements qui
    /// divergent le jour où l'un des deux change.
    private func aisles(of list: [ShoppingLine]) -> [(role: FoodRole, lines: [ShoppingLine])] {
        var order: [FoodRole] = []
        var grouped: [FoodRole: [ShoppingLine]] = [:]
        for line in list {
            if grouped[line.role] == nil { order.append(line.role) }
            grouped[line.role, default: []].append(line)
        }
        return order.map { ($0, grouped[$0] ?? []) }
    }

}
