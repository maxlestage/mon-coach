import SwiftUI
import MonCoachKit

/// L'écran alimentation : ce qu'il y a à manger aujourd'hui, pourquoi, et
/// quoi acheter pour la semaine.
struct FoodView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var tab: Tab = .today
    @State private var showsShoppingList = false

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
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showsShoppingList = true
                    } label: {
                        Image(systemName: "cart")
                    }
                }
            }
            .sheet(isPresented: $showsShoppingList) {
                ShoppingListView()
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

            ForEach(day.meals) { meal in
                MealCard(meal: meal)
            }

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

    var body: some View {
        Card(
            title: meal.slot.label[language],
            subtitle: "\(Int(meal.macros.kcal)) kcal · \(Int(meal.macros.proteinG)) g"
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(meal.items) { item in
                    if let food = item.food {
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
                        }
                    }
                }
                if let note = meal.note {
                    CoachText(note, font: .system(size: 12))
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

    @State private var checked: Set<String> = []

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
                        let list = MealPlanner.shoppingList(for: week)
                        Card(
                            subtitle: LocalizedText(
                                fr: "Pour sept jours. Les quantités sont celles du produit prêt à consommer : compte environ un tiers pour les féculents secs.",
                                en: "For seven days. Quantities are for ready-to-eat product: count roughly a third for dry starches.",
                                es: "Para siete días. Las cantidades son de producto listo para consumir: cuenta un tercio para los farináceos secos."
                            )[language]
                        ) {
                            VStack(spacing: 6) {
                                ForEach(list) { line in
                                    Button {
                                        if checked.contains(line.foodID) {
                                            checked.remove(line.foodID)
                                        } else {
                                            checked.insert(line.foodID)
                                        }
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: checked.contains(line.foodID)
                                                ? "checkmark.circle.fill"
                                                : "circle")
                                                .foregroundStyle(checked.contains(line.foodID)
                                                    ? Theme.accent
                                                    : Theme.secondaryText)
                                            Text(line.food?.name[language] ?? line.foodID)
                                                .font(Theme.bodyFont)
                                                .foregroundStyle(Theme.primaryText)
                                                .strikethrough(checked.contains(line.foodID))
                                            Spacer()
                                            Text(quantity(line))
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

    /// Au-delà du kilo, on compte en kilos : personne n'achète 2 450 g de riz.
    private func quantity(_ line: ShoppingLine) -> String {
        line.grams >= 1_000
            ? "\(Format.number(line.grams / 1_000, decimals: 1, language: language)) kg"
            : "\(Int(line.grams)) g"
    }
}
