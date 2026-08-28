import Foundation

/// Une ligne de liste de courses.
public struct ShoppingLine: Sendable, Equatable, Identifiable {
    public var id: String { foodID }
    public var foodID: String
    public var grams: Double
    public var role: FoodRole

    public var food: Food? { FoodCatalog.food(id: foodID) }
}

/// Construit des journées alimentaires qui atteignent les macros prescrites.
///
/// Le plan n'est pas une prescription à la calorie près : c'est un point de
/// départ crédible, avec des quantités pesables et des aliments qu'on trouve
/// dans n'importe quel magasin. L'écart réel à la cible est calculé et exposé
/// (`DayPlan.drift`) plutôt que maquillé — un plan qui prétend tomber juste
/// à la calorie ment sur la précision de tout le reste de la chaîne.
public enum MealPlanner {

    // MARK: - Les moments de la journée

    static func slots(mealsPerDay: Int, trainsToday: Bool) -> [(slot: MealSlot, share: Double)] {
        switch mealsPerDay.clamped(to: 3...5) {
        case 3:
            [(.breakfast, 0.30), (.lunch, 0.40), (.dinner, 0.30)]
        case 4:
            [(.breakfast, 0.27), (.lunch, 0.33), (.snack, 0.12), (.dinner, 0.28)]
        default:
            trainsToday
                ? [(.breakfast, 0.24), (.lunch, 0.29), (.preWorkout, 0.10), (.snack, 0.11), (.dinner, 0.26)]
                : [(.breakfast, 0.24), (.lunch, 0.30), (.snack, 0.11), (.dinner, 0.26), (.preWorkout, 0.09)]
        }
    }

    // MARK: - Réserves d'aliments par rôle et par moment

    /// Les protéines qui se mangent au petit-déjeuner sans effort.
    static let breakfastProteins: Set<String> = [
        "skyr", "fromage-blanc", "cottage", "oeuf", "blanc-oeuf", "tofu",
        "whey", "proteine-vegetale", "yaourt-soja",
    ]
    /// Les féculents du matin.
    static let breakfastCarbs: Set<String> = [
        "flocons-avoine", "pain-complet", "pain-blanc", "cracottes-seigle",
    ]

    static func pool(
        role: FoodRole,
        diet: DietPreference,
        excluding excluded: Set<String>,
        restrictedTo ids: Set<String>? = nil
    ) -> [Food] {
        FoodCatalog
            .available(diet: diet, excluding: excluded, roles: [role], maximumTier: .moderate)
            .filter { ids?.contains($0.id) ?? true }
    }

    /// Retire du choix les protéines qui ne peuvent pas faire le travail.
    ///
    /// Deux filtres, dans cet ordre. Faisabilité d'abord : le lait apporte
    /// 3,3 g de protéines aux 100 g, il faudrait 1,3 kg pour couvrir un repas
    /// — il n'a rien à faire dans ce créneau, pas plus que 385 g de blancs
    /// d'œufs, soit une douzaine d'œufs cassés pour une collation. Budget lipidique ensuite : quand
    /// la journée n'a que 62 g de gras pour 170 g de protéines, choisir deux
    /// fois du tofu fait déborder le total de 30 % avant même la première
    /// cuillère d'huile. Chaque filtre s'efface s'il ne laisse rien : mieux
    /// vaut un repas imparfait qu'un repas vide.
    static func viableProteins(_ pool: [Food], target: Macros, avoiding avoided: Set<String>) -> [Food] {
        guard target.proteinG > 0 else { return pool }
        let feasible = pool.filter { $0.proteinG > 0 && target.proteinG / $0.proteinG * 100 <= 350 }
        guard !feasible.isEmpty else { return pool }
        let budget = target.fatG / target.proteinG
        let lean = feasible.filter { $0.fatG / $0.proteinG <= budget * 1.2 }

        // On préfère toujours ne pas déborder sur le gras plutôt que varier :
        // une journée qui répète une protéine reste une journée juste, une
        // journée à +30 % de lipides ne l'est pas.
        for candidates in [lean.filter { !avoided.contains($0.id) }, lean,
                           feasible.filter { !avoided.contains($0.id) }, feasible] {
            if !candidates.isEmpty { return candidates }
        }
        return pool
    }

    /// Choisit un aliment de façon déterministe mais variée d'un jour à l'autre.
    static func pick(_ foods: [Food], seed: Int) -> Food? {
        guard !foods.isEmpty else { return nil }
        // La même graine donne toujours le même aliment : le plan est
        // reproductible, donc testable, et il ne change pas sous les yeux
        // de l'athlète entre deux ouvertures de l'écran.
        return foods[((seed % foods.count) + foods.count) % foods.count]
    }

    // MARK: - Un repas

    /// Résout les quantités d'un repas pour atteindre ses macros.
    ///
    /// Les aliments s'apportent des macros les uns aux autres — l'avoine
    /// porte des protéines, le tofu porte du gras — donc une passe unique
    /// dépasse toujours la cible. On itère : à chaque tour, chaque quantité
    /// est recalculée en tenant compte de ce que les autres apportent déjà.
    /// Quatre tours suffisent à stabiliser.
    static func solve(
        protein: Food?,
        carb: Food?,
        fat: Food?,
        fixed: [Food],
        target: Macros
    ) -> [MealItem] {
        var foods: [String: Food] = [:]
        for food in fixed + [protein, carb, fat].compactMap({ $0 }) { foods[food.id] = food }
        var grams: [String: Double] = foods.mapValues(\.portionG)

        func macros(excluding id: String) -> Macros {
            grams.reduce(into: Macros.zero) { total, entry in
                guard entry.key != id, let food = foods[entry.key] else { return }
                total += food.macros(grams: entry.value)
            }
        }

        func fit(_ food: Food, needed: Double, per100: Double, range: ClosedRange<Double>) {
            guard per100 > 0 else { return }
            grams[food.id] = (needed / per100 * 100).clamped(to: range)
        }

        // Aucune borne basse au-dessus de zéro : quand les autres aliments
        // couvrent déjà une macro, l'aliment dédié doit pouvoir disparaître.
        // Une borne à 5 g sur le créneau « matières grasses » suffisait à
        // faire déborder toutes les journées de 35 %.
        for _ in 0..<4 {
            if let protein {
                fit(
                    protein,
                    needed: target.proteinG - macros(excluding: protein.id).proteinG,
                    per100: protein.proteinG,
                    range: 0...350
                )
            }
            if let fat {
                // Une huile se sert jusqu'à 30 g, une poignée d'oléagineux
                // pas au-delà du double de sa portion : personne ne mange
                // 44 g de graines de chia au dîner.
                fit(
                    fat,
                    needed: target.fatG - macros(excluding: fat.id).fatG,
                    per100: fat.fatG,
                    range: 0...min(60, max(15, fat.portionG * 2))
                )
            }
            if let carb {
                fit(
                    carb,
                    needed: target.carbsG - macros(excluding: carb.id).carbsG,
                    per100: carb.carbsG,
                    range: 0...400
                )
            }
        }

        // Ce qui tombe sous une quantité qu'on se donnerait la peine de
        // peser sort du repas au lieu d'y figurer pour rien.
        let fixedIDs = Set(fixed.map(\.id))
        for (id, amount) in grams where !fixedIDs.contains(id) {
            guard let food = foods[id] else { continue }
            let floor: Double = food.role == .fat ? 3 : 10
            if amount < floor {
                grams[id] = nil
                foods[id] = nil
            }
        }

        // Des quantités pesables : au gramme près pour les huiles et les
        // oléagineux, au multiple de 5 g pour le reste. Personne ne pèse
        // 187 g de riz.
        return foods.keys
            .compactMap { id -> MealItem? in
                guard let food = foods[id], let raw = grams[id] else { return nil }
                let step: Double = food.role == .fat && food.portionG <= 30 ? 1 : 5
                let rounded = max(step, (raw / step).rounded() * step)
                return MealItem(foodID: id, grams: rounded, macros: food.macros(grams: rounded))
            }
            .sorted { left, right in
                let lhs = roleOrder(left), rhs = roleOrder(right)
                return lhs == rhs ? left.foodID < right.foodID : lhs < rhs
            }
    }

    static func roleOrder(_ item: MealItem) -> Int {
        switch item.food?.role {
        case .protein: 0
        case .carb: 1
        case .vegetable: 2
        case .fruit: 3
        case .dairy: 4
        case .fat: 5
        default: 6
        }
    }

    static func meal(
        slot: MealSlot,
        target: Macros,
        diet: DietPreference,
        excluded: Set<String>,
        avoidingProteins avoided: Set<String> = [],
        seed: Int
    ) -> Meal {
        let proteinPool: [Food]
        let carbPool: [Food]
        var fatPool: [Food] = []
        var fixed: [Food] = []

        switch slot {
        case .breakfast:
            proteinPool = pool(role: .protein, diet: diet, excluding: excluded, restrictedTo: breakfastProteins)
                + pool(role: .dairy, diet: diet, excluding: excluded, restrictedTo: breakfastProteins)
            carbPool = pool(role: .carb, diet: diet, excluding: excluded, restrictedTo: breakfastCarbs)
            fatPool = pool(role: .fat, diet: diet, excluding: excluded)
            if let fruit = pick(pool(role: .fruit, diet: diet, excluding: excluded), seed: seed) {
                fixed.append(fruit)
            }
        case .lunch, .dinner:
            proteinPool = pool(role: .protein, diet: diet, excluding: excluded)
            carbPool = pool(role: .carb, diet: diet, excluding: excluded)
            fatPool = pool(role: .fat, diet: diet, excluding: excluded)
            // Deux légumes différents : c'est là que se joue le volume de
            // l'assiette, et donc la sensation d'avoir vraiment mangé.
            let vegetables = pool(role: .vegetable, diet: diet, excluding: excluded)
            if let first = pick(vegetables, seed: seed) { fixed.append(first) }
            if let second = pick(vegetables.filter { $0.id != fixed.first?.id }, seed: seed + 5) {
                fixed.append(second)
            }
        case .snack:
            proteinPool = pool(role: .protein, diet: diet, excluding: excluded, restrictedTo: breakfastProteins)
            carbPool = pool(role: .fruit, diet: diet, excluding: excluded)
            fatPool = pool(role: .fat, diet: diet, excluding: excluded)
        case .preWorkout:
            proteinPool = []
            carbPool = pool(role: .carb, diet: diet, excluding: excluded)
            if let fruit = pick(pool(role: .fruit, diet: diet, excluding: excluded), seed: seed + 2) {
                fixed.append(fruit)
            }
        }

        // Une même protéine ne revient pas trois fois dans la journée, et une
        // poudre encore moins : c'est un dépannage, pas la colonne vertébrale
        // de trois repas.
        let items = solve(
            protein: pick(viableProteins(proteinPool, target: target, avoiding: avoided), seed: seed),
            carb: pick(carbPool, seed: seed + 1),
            fat: pick(fatPool, seed: seed + 3),
            fixed: fixed,
            target: target
        )
        return Meal(slot: slot, items: items, note: note(for: slot))
    }

    static func note(for slot: MealSlot) -> LocalizedText? {
        switch slot {
        case .breakfast:
            LocalizedText(
                fr: "Trente grammes de protéines dès le matin coupent la faim de la journée entière : c'est le repas le plus rentable à corriger.",
                en: "Thirty grams of protein first thing blunts hunger for the whole day: this is the highest-return meal to fix.",
                es: "Treinta gramos de proteína a primera hora cortan el hambre de todo el día: es la comida más rentable de corregir."
            )
        case .preWorkout:
            LocalizedText(
                fr: "Entre 60 et 90 minutes avant la séance, et sans gras ni fibres : ce sont eux qui pèsent sur l'estomac, pas les glucides.",
                en: "Sixty to ninety minutes before training, low in fat and fibre: those are what sit heavy, not the carbs.",
                es: "Entre 60 y 90 minutos antes de entrenar, sin grasa ni fibra: son ellas las que pesan en el estómago, no los hidratos."
            )
        case .dinner:
            LocalizedText(
                fr: "Manger tard ne fait pas grossir : c'est le total de la journée qui compte. Un dîner protéiné aide simplement à mieux dormir.",
                en: "Eating late does not make you fat: the day's total is what counts. A protein-rich dinner just helps you sleep.",
                es: "Cenar tarde no engorda: lo que cuenta es el total del día. Una cena proteica solo ayuda a dormir mejor."
            )
        case .snack, .lunch:
            nil
        }
    }

    // MARK: - Une journée

    public static func day(
        target: NutritionTarget,
        diet: DietPreference = .omnivore,
        dayIndex: Int = 0,
        mealsPerDay: Int = 4,
        excluding excluded: Set<String> = [],
        trainsToday: Bool = false,
        runsToday: Bool = false
    ) -> DayPlan {
        let dayTarget = Macros(
            kcal: Double(target.calories),
            proteinG: Double(target.proteinG),
            carbsG: Double(target.carbsG),
            fatG: Double(target.fatG)
        )
        let layout = slots(mealsPerDay: mealsPerDay, trainsToday: trainsToday || runsToday)
        // Les protéines se répartissent équitablement plutôt qu'au prorata des
        // calories : au-delà d'environ 40 g par prise, le surplus ne sert plus
        // à construire du muscle, il sert de carburant.
        let proteinMeals = max(1, layout.filter { $0.slot != .preWorkout }.count)
        let proteinPerMeal = dayTarget.proteinG / Double(proteinMeals)

        var meals: [Meal] = []
        var usedProteins: Set<String> = []
        for (index, entry) in layout.enumerated() {
            let mealTarget = Macros(
                kcal: dayTarget.kcal * entry.share,
                proteinG: entry.slot == .preWorkout ? 0 : proteinPerMeal,
                carbsG: dayTarget.carbsG * entry.share,
                fatG: entry.slot == .preWorkout ? 0 : dayTarget.fatG * entry.share
            )
            let built = meal(
                slot: entry.slot,
                target: mealTarget,
                diet: diet,
                excluded: excluded,
                avoidingProteins: usedProteins,
                seed: dayIndex * 7 + index * 3
            )
            for item in built.items where item.food?.role == .protein {
                usedProteins.insert(item.foodID)
            }
            meals.append(built)
        }

        let corrected = balance(meals, toward: dayTarget)
        var dayNotes = notes(target: target, diet: diet, runsToday: runsToday)
        let powders = corrected
            .flatMap(\.items)
            .filter { ["whey", "proteine-vegetale"].contains($0.foodID) }
        if powders.count > 1 {
            dayNotes.insert(
                LocalizedText(
                    fr: "La poudre revient deux fois aujourd'hui, et ce n'est pas un hasard : à ce niveau de protéines pour ce niveau de calories, aucun aliment entier ne tient dans le budget lipidique. Si ça te dérange, remonte les calories ou baisse les protéines — ce sont les deux seuls leviers.",
                    en: "The powder shows up twice today, and not by accident: at this protein level for these calories, no whole food fits the fat budget. If that bothers you, raise the calories or lower the protein — those are the only two levers.",
                    es: "El polvo aparece dos veces hoy, y no por casualidad: con esta proteína para estas calorías, ningún alimento entero cabe en el presupuesto de grasa. Si te molesta, sube las calorías o baja la proteína: son las dos únicas palancas."
                ),
                at: 0
            )
        }

        return DayPlan(
            dayIndex: dayIndex,
            meals: corrected,
            target: dayTarget,
            notes: dayNotes
        )
    }

    /// Rattrape ce que la construction repas par repas laisse dériver.
    ///
    /// Deux corrections, dans cet ordre, et une seule fois chacune : les
    /// féculents referment l'écart calorique, puis les protéines sont
    /// rognées si les féculents en ont ramené trop au passage — l'avoine et
    /// le quinoa en portent, et une correction de +40 % sur les glucides
    /// suffisait à faire déborder les protéines de 12 %. Les féculents
    /// repassent une dernière fois pour absorber ce que le rognage a retiré.
    static func balance(_ meals: [Meal], toward target: Macros) -> [Meal] {
        var balanced = scaleCarbs(in: meals, toward: target)
        balanced = trimProtein(in: balanced, toward: target)
        return scaleCarbs(in: balanced, toward: target)
    }

    /// Referme l'écart calorique sur les féculents.
    ///
    /// Les repas visent des macros, pas des calories, et les deux ne
    /// coïncident pas exactement : les tables donnent l'énergie réelle des
    /// aliments, pas la somme 4/4/9 des macros, et l'écart se creuse sur les
    /// aliments riches en fibres. On rattrape sur les glucides, qui sont déjà
    /// la variable libre côté moteur nutritionnel — jamais sur les protéines,
    /// qui sont la seule macro qu'on ne négocie pas.
    static func scaleCarbs(in meals: [Meal], toward target: Macros) -> [Meal] {
        let gap = target.kcal - meals.map(\.macros).total.kcal
        guard abs(gap) > target.kcal * 0.02 else { return meals }

        let carbKcal = meals
            .flatMap(\.items)
            .filter { $0.food?.role == .carb }
            .reduce(0.0) { $0 + $1.macros.kcal }
        guard carbKcal > 0 else { return meals }

        return rescale(meals, role: .carb, by: ((carbKcal + gap) / carbKcal).clamped(to: 0.5...1.8))
    }

    /// Rogne les protéines quand elles débordent.
    ///
    /// Un dépassement de protéines n'est pas dangereux, mais il déplace des
    /// calories que le plan avait promises ailleurs. Au-delà de 6 %, on
    /// ramène les sources protéiques à la cible ; en dessous, on laisse.
    static func trimProtein(in meals: [Meal], toward target: Macros) -> [Meal] {
        let actual = meals.map(\.macros).total.proteinG
        guard target.proteinG > 0, actual > target.proteinG * 1.06 else { return meals }

        let fromProteinFoods = meals
            .flatMap(\.items)
            .filter { $0.food?.role == .protein }
            .reduce(0.0) { $0 + $1.macros.proteinG }
        guard fromProteinFoods > 0 else { return meals }

        let excess = actual - target.proteinG
        return rescale(meals, role: .protein, by: ((fromProteinFoods - excess) / fromProteinFoods).clamped(to: 0.6...1.0))
    }

    static func rescale(_ meals: [Meal], role: FoodRole, by scale: Double) -> [Meal] {
        meals.map { meal in
            var corrected = meal
            corrected.items = meal.items.compactMap { item in
                guard let food = item.food, food.role == role else { return item }
                let step: Double = food.role == .fat && food.portionG <= 30 ? 1 : 5
                let grams = max(step, (item.grams * scale / step).rounded() * step)
                return MealItem(foodID: item.foodID, grams: grams, macros: food.macros(grams: grams))
            }
            return corrected
        }
    }

    /// Une semaine entière, avec de la variété d'un jour à l'autre.
    public static func week(
        target: NutritionTarget,
        diet: DietPreference = .omnivore,
        mealsPerDay: Int = 4,
        excluding excluded: Set<String> = [],
        trainingDays: Set<Int> = [],
        runningDays: Set<Int> = []
    ) -> [DayPlan] {
        (0..<7).map { index in
            day(
                target: target,
                diet: diet,
                dayIndex: index,
                mealsPerDay: mealsPerDay,
                excluding: excluded,
                trainsToday: trainingDays.contains(index),
                runsToday: runningDays.contains(index)
            )
        }
    }

    /// La liste de courses d'une série de journées, agrégée par aliment.
    public static func shoppingList(for days: [DayPlan]) -> [ShoppingLine] {
        var totals: [String: Double] = [:]
        for day in days {
            for meal in day.meals {
                for item in meal.items {
                    totals[item.foodID, default: 0] += item.grams
                }
            }
        }
        return totals
            .compactMap { id, grams -> ShoppingLine? in
                guard let food = FoodCatalog.food(id: id) else { return nil }
                // Arrondi aux 10 g supérieurs : on achète un paquet, pas une dose.
                return ShoppingLine(foodID: id, grams: (grams / 10).rounded(.up) * 10, role: food.role)
            }
            .sorted {
                roleRank($0.role) == roleRank($1.role)
                    ? $0.foodID < $1.foodID
                    : roleRank($0.role) < roleRank($1.role)
            }
    }

    static func roleRank(_ role: FoodRole) -> Int {
        switch role {
        case .protein: 0
        case .vegetable: 1
        case .carb: 2
        case .fruit: 3
        case .dairy: 4
        case .fat: 5
        case .drink: 6
        case .treat: 7
        }
    }

    // MARK: - Ce qu'il faut dire en plus des chiffres

    static func notes(target: NutritionTarget, diet: DietPreference, runsToday: Bool) -> [LocalizedText] {
        var notes: [LocalizedText] = []

        notes.append(
            LocalizedText(
                fr: "Ces quantités sont des points de départ, pas une ordonnance. Pèse une semaine pour apprendre à quoi ressemble une portion, puis sers-toi à l'œil : le but est de ne plus avoir besoin de la balance.",
                en: "These amounts are a starting point, not a prescription. Weigh for a week to learn what a portion looks like, then serve by eye: the goal is to stop needing the scale.",
                es: "Estas cantidades son un punto de partida, no una receta. Pesa una semana para aprender cómo es una ración y luego sírvete a ojo: el objetivo es dejar de necesitar la báscula."
            )
        )

        notes.append(
            LocalizedText(
                fr: "Les féculents sont donnés cuits. Sur le paquet, ils sont donnés crus : 100 g de riz sec deviennent environ 300 g de riz cuit.",
                en: "Starches are given cooked. Packets give them raw: 100 g of dry rice becomes roughly 300 g cooked.",
                es: "Los farináceos se dan cocidos. En el paquete vienen crudos: 100 g de arroz seco son unos 300 g cocidos."
            )
        )

        let fiberTarget = Int((Double(target.calories) / 1_000 * 14).rounded())
        notes.append(
            LocalizedText(
                fr: "Vise environ \(fiberTarget) g de fibres par jour. C'est ce qui fait la différence entre un déficit tenable et un déficit qui craque le jeudi soir.",
                en: "Aim for roughly \(fiberTarget) g of fibre a day. That is the difference between a deficit you can hold and one that breaks on Thursday night.",
                es: "Apunta a unos \(fiberTarget) g de fibra al día. Es la diferencia entre un déficit sostenible y uno que se rompe el jueves por la noche."
            )
        )

        if diet == .vegan {
            notes.append(
                LocalizedText(
                    fr: "Régime végétalien : la vitamine B12 doit être complémentée, il n'y a pas d'alternative alimentaire fiable. Surveille aussi le fer, le zinc, l'iode et les oméga-3 à longue chaîne.",
                    en: "Vegan diet: vitamin B12 must be supplemented — there is no reliable food alternative. Keep an eye on iron, zinc, iodine and long-chain omega-3s too.",
                    es: "Dieta vegana: la vitamina B12 debe suplementarse, no hay alternativa alimentaria fiable. Vigila también el hierro, el zinc, el yodo y los omega-3 de cadena larga."
                )
            )
        }
        if diet == .vegan || diet == .vegetarian {
            notes.append(
                LocalizedText(
                    fr: "Associe légumineuses et céréales dans la journée : chacune manque d'un acide aminé que l'autre apporte. Pas besoin que ce soit dans le même repas.",
                    en: "Combine pulses and grains across the day: each is short of an amino acid the other supplies. They need not be in the same meal.",
                    es: "Combina legumbres y cereales a lo largo del día: a cada una le falta un aminoácido que la otra aporta. No hace falta que sea en la misma comida."
                )
            )
        }

        if runsToday {
            notes.append(
                LocalizedText(
                    fr: "Jour de course : bois 500 ml par heure d'effort et remets des glucides dans l'heure qui suit. Au-delà de 75 minutes de sortie, prévois 30 à 60 g de glucides par heure pendant la course.",
                    en: "Running day: drink 500 ml per hour of effort and put carbs back within the hour after. Past 75 minutes out, plan 30 to 60 g of carbs per hour during the run.",
                    es: "Día de carrera: bebe 500 ml por hora de esfuerzo y repón hidratos en la hora siguiente. Más allá de 75 minutos, prevé de 30 a 60 g de hidratos por hora durante el rodaje."
                )
            )
        }

        if target.weeklyWeightChangeKg < 0 {
            notes.append(
                LocalizedText(
                    fr: "En déficit, la faim est un signal normal, pas un échec. Les légumes, les protéines et le sommeil sont les trois leviers qui la rendent supportable — dans cet ordre.",
                    en: "In a deficit, hunger is a normal signal, not a failure. Vegetables, protein and sleep are the three levers that make it bearable — in that order.",
                    es: "En déficit, el hambre es una señal normal, no un fracaso. Verduras, proteína y sueño son las tres palancas que lo hacen llevadero, en ese orden."
                )
            )
        }

        return notes
    }
}
