import Foundation

/// Une ligne de liste de courses.
///
/// `grams` est ce que le plan prescrit : du produit prêt à consommer, parce
/// que c'est ainsi qu'on calcule des macros. Ce n'est pas ce qu'on achète, et
/// la différence n'est pas un détail — mille sept cents grammes de riz cuit
/// tiennent dans un demi-paquet.
public struct ShoppingLine: Sendable, Equatable, Identifiable {
    public var id: String { foodID }
    public var foodID: String
    public var grams: Double
    public var role: FoodRole

    public var food: Food? { FoodCatalog.food(id: foodID) }

    /// Le poids à mettre dans le panier : le cru pour ce qui gonfle en cuisant.
    public var weightToBuy: Double {
        ShoppingUnits.weightToBuy(grams, foodID: foodID)
    }

    public var purchase: ShoppingUnits.Purchase {
        ShoppingUnits.purchase(for: foodID)
    }

    /// Ce qui se garde au placard et se rachète quand c'est fini.
    ///
    /// Ces lignes-là n'ont pas de quantité utile : « 10 g de graines de
    /// tournesol » n'est pas une course, c'est un reste de calcul. Elles sont
    /// nommées et rangées à part, sans chiffre.
    public var isPantry: Bool {
        if case .pantry = purchase { return true }
        return false
    }

    /// Cet aliment survit-il à un mois de placard ?
    ///
    /// Question posée par la liste de courses au mois : le riz et les
    /// conserves se prennent en une fois, les épinards non. Le frais, c'est
    /// tout ce qui se vend au poids en protéines, plus les légumes, les
    /// fruits et les produits laitiers — quel que soit leur emballage. Les
    /// œufs, vendus à la pièce, tiennent le mois.
    public var keeps: Bool {
        switch role {
        case .vegetable, .fruit, .dairy:
            return false
        case .protein:
            if case .loose = purchase { return false }
            return true
        case .carb, .fat, .drink, .treat:
            return true
        }
    }

    /// Vrai quand la liste couvre plusieurs semaines et que cette ligne est
    /// du frais : la quantité est celle d'une semaine, à reprendre ensuite.
    public var repeatsWeekly: Bool = false

    /// Ce qu'il faut prendre dans le rayon, dit comme on le dirait.
    public func quantity(_ language: Language) -> String {
        switch purchase {
        case .loose:
            return weight(language)
        case .pantry(let shape):
            return shape.one[language]
        case .pack(let shape), .piece(let shape):
            guard shape.grams > 0 else { return shape.one[language] }
            let count = max(1, Int((weightToBuy / shape.grams).rounded(.up)))
            let noun = (count == 1 ? shape.one : shape.many)[language]
            if case .piece = purchase { return "\(count) \(noun)" }
            // Le format du conditionnement est rappelé : deux pots de 450 g et
            // deux pots de 150 g ne remplissent pas le même caddie.
            return "\(count) \(noun) de \(weight(language, grams: shape.grams))"
        }
    }

    private func weight(_ language: Language, grams value: Double? = nil) -> String {
        let raw = value ?? weightToBuy
        // « 600 g de riz complet cuit » désigne désormais du riz sec, et le
        // nom de l'aliment dit le contraire : il vient du catalogue, où il
        // décrit ce qu'on mange. Le préciser sur la quantité lève le doute
        // là où il se pose — devant le rayon, une balance à la main.
        let dry = (value == nil && (ShoppingUnits.dryWeight[foodID] ?? 1) < 1)
            ? " " + LocalizedText(fr: "secs", en: "dry", es: "en seco")[language]
            : ""
        if raw >= 1_000 {
            return "\(Format.number(raw / 1_000, decimals: 1, language: language)) kg\(dry)"
        }
        // Aux cinquante grammes : une balance de magasin n'est pas une
        // balance de cuisine, et « 347 g de carottes » ne s'achète pas.
        let rounded = value == nil ? (raw / 50).rounded(.up) * 50 : raw
        return "\(Int(rounded)) g\(dry)"
    }
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
        "whey", "proteine-vegetale", "yaourt-soja", "petit-suisse", "caseine",
    ]
    /// Les féculents du matin.
    ///
    /// Le sarrasin, les galettes de riz et les tortillas de maïs en font
    /// partie pour une raison précise : sans eux, un athlète sans gluten
    /// obtenait un petit-déjeuner sans aucun féculent, et la journée entière
    /// ratait ses glucides de 10 % sans que rien ne le signale.
    static let breakfastCarbs: Set<String> = [
        "flocons-avoine", "pain-complet", "pain-blanc", "cracottes-seigle",
        "sarrasin", "galettes-riz", "tortilla-mais", "muesli-nature",
        "pain-seigle", "pain-cereales", "cereales-mais",
    ]

    /// Les féculents d'un vrai repas.
    ///
    /// L'avoine et les tartines de seigle en sont volontairement absentes.
    /// Ce n'est pas qu'une question de goût : elles portent 9 à 13 g de
    /// protéines aux 100 g, et à 160 g dans une assiette elles ne laissent
    /// plus rien à faire à la source protéique, qui tombe alors à une portion
    /// symbolique — trente-cinq grammes de sardines.
    /// Le pain n'y figure pas : à 13 g de protéines aux 100 g, deux cents
    /// grammes de pain complet couvraient à eux seuls les protéines du dîner,
    /// et le solveur supprimait le poisson. Un dîner sans source protéique
    /// n'est pas un dîner, quels que soient les totaux.
    static let mainCarbs: Set<String> = [
        "riz-complet", "riz-blanc", "pates-completes", "pomme-de-terre",
        "patate-douce", "quinoa", "sarrasin", "tortilla-mais",
        // Les rayons générés : tous sous la barre des ~6 g de protéines aux
        // 100 g, celle au-delà de laquelle un féculent vide la place de la
        // source protéique.
        "boulgour", "semoule", "orge-perle", "epeautre", "millet", "polenta",
        "riz-basmati", "vermicelles-riz", "pates-blanches", "gnocchis",
        "petits-pois", "mais-doux",
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
        // La faisabilité se juge au plafond réel de l'aliment, pas à un
        // chiffre unique : le plafond de fibres limite un plat de pois
        // cassés à ce qu'il porte 15 g de fibres, soit une quinzaine de
        // grammes de protéines — pour un créneau à 35 g, cette source ne
        // peut pas livrer, et la laisser dans le pool ferait dériver la
        // journée. Sur un créneau plus léger, elle rejoue.
        let feasible = pool.filter {
            $0.proteinG > 0 && target.proteinG / $0.proteinG * 100 <= maximumGrams(for: $0)
        }
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

    /// Écarte les féculents qui mangeraient la place des protéines.
    ///
    /// Le symétrique de `viableProteins`, découvert sur le même genre de
    /// cas réel : sur un objectif santé — protéines basses, calories
    /// confortables — la rotation servait 480 g de quinoa, qui apportaient
    /// à eux seuls 21 g de protéines dans un repas qui n'en demandait que
    /// 29. La source protéique, déjà à son plancher de portion, ne pouvait
    /// plus descendre, et la journée dépassait sa cible sans qu'aucun
    /// aliment ne soit fautif isolément. La règle : servi à hauteur des
    /// glucides du repas, un féculent ne doit pas apporter plus de la
    /// moitié des protéines attendues. Sur un repas riche en protéines, le
    /// quinoa rejoue ; sur un repas léger, le riz prend sa place. Le filtre
    /// s'efface s'il ne laisse rien.
    static func viableCarbs(_ pool: [Food], target: Macros) -> [Food] {
        guard target.carbsG > 0, target.proteinG > 0 else { return pool }
        let fitting = pool.filter { carb in
            guard carb.carbsG > 0 else { return true }
            let grams = min(maximumGrams(for: carb), target.carbsG / carb.carbsG * 100)
            return grams * carb.proteinG / 100 <= target.proteinG * 0.5
        }
        return fitting.isEmpty ? pool : fitting
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

/// Comment choisir le plat d'un repas, quand il y en a un.
///
/// Trois modes, et non deux, parce que la contrainte de fibres se juge sur
/// la journée et non sur un repas. Un plancher de fibres appliqué repas par
/// repas ne laissait survivre que deux ou trois plats, et la semaine servait
/// trois dîners différents sur sept — le plan redevenait la boucle qu'on
/// voulait justement casser.
enum DishPreference {
    /// Le plat du jour, choisi par la graine : c'est la variété.
    case varied
    /// Le plat acceptable le plus riche en fibres, quand la journée en
    /// manque. On sacrifie la variété d'une journée, pas sa justesse.
    case richestInFibre
    /// Aucun plat : l'assiette composée aliment par aliment, qui a toujours
    /// plus de liberté pour tomber sur la cible. Le dernier recours.
    case none
}


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
        vegetableGrams: Double? = nil,
        target: Macros
    ) -> [MealItem] {
        var foods: [String: Food] = [:]
        for food in fixed + [protein, carb, fat].compactMap({ $0 }) { foods[food.id] = food }
        var grams: [String: Double] = foods.mapValues { food in
            food.role == .vegetable ? (vegetableGrams ?? food.portionG) : food.portionG
        }

        func macros(excluding id: String) -> Macros {
            grams.reduce(into: Macros.zero) { total, entry in
                guard entry.key != id, let food = foods[entry.key] else { return }
                total += food.macros(grams: entry.value)
            }
        }

        func fit(_ food: Food, needed: Double, per100: Double, range: ClosedRange<Double>) {
            guard per100 > 0 else { return }
            var amount = (needed / per100 * 100).clamped(to: range)
            // Une source protéique qu'on garde est servie en portion : sous
            // 40 % de sa portion habituelle, on la remonte plutôt que de
            // prescrire trente-cinq grammes de sardines. Les glucides, qui
            // sont ajustés après, absorbent la différence.
            let floor = minimumGrams(for: food)
            if amount > 0 && amount < floor { amount = min(floor, range.upperBound) }
            grams[food.id] = amount
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
                    range: 0...maximumGrams(for: protein)
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
                    range: 0...maximumGrams(for: fat)
                )
            }
            if let carb {
                fit(
                    carb,
                    needed: target.carbsG - macros(excluding: carb.id).carbsG,
                    per100: carb.carbsG,
                    range: 0...maximumGrams(for: carb)
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

        // Un repas garde sa source de protéines, même quand les autres
        // aliments couvrent déjà la cible : c'est ce que l'athlète va cuisiner,
        // et une assiette de riz et de haricots verts ne se présente pas comme
        // un dîner sous prétexte que le total tombe juste.
        if let protein, grams[protein.id] == nil {
            grams[protein.id] = minimumGrams(for: protein)
            foods[protein.id] = protein
        }

        // Des quantités pesables : au gramme près pour les huiles et les
        // oléagineux, au multiple de 5 g pour le reste. Personne ne pèse
        // 187 g de riz.
        return foods.keys
            .compactMap { id -> MealItem? in
                guard let food = foods[id], let raw = grams[id] else { return nil }
                let amount = rounded(raw, for: food)
                return MealItem(foodID: id, grams: amount, macros: food.macros(grams: amount))
            }
            .sorted { left, right in
                let lhs = roleOrder(left), rhs = roleOrder(right)
                return lhs == rhs ? left.foodID < right.foodID : lhs < rhs
            }
    }

    /// Arrondit une quantité à un multiple pesable, sans jamais franchir le
    /// plafond de l'aliment.
    ///
    /// L'arrondi se fait vers le bas quand il ferait dépasser : 242 g de pain
    /// arrondis à 245 g resteraient trois grammes au-dessus du plafond, et un
    /// plafond qu'on dépasse de trois grammes n'est plus un plafond.
    static func rounded(_ amount: Double, for food: Food) -> Double {
        let step: Double = food.role == .fat && food.portionG <= 30 ? 1 : 5
        let ceiling = (maximumGrams(for: food) / step).rounded(.down) * step
        // Le plancher vaut ici aussi : les corrections d'après-coup rognent
        // les protéines, et sans lui elles ramenaient le saumon à 40 g.
        let floor = min(ceiling, max(step, (minimumGrams(for: food) / step).rounded(.up) * step))
        let value = (amount / step).rounded() * step
        return min(max(value, floor), ceiling)
    }

    /// La plus petite quantité qui reste une portion.
    static func minimumGrams(for food: Food) -> Double {
        switch food.role {
        case .protein: food.portionG * 0.4
        case .carb: food.portionG * 0.25
        case .fat: 3
        default: 10
        }
    }

    /// La quantité maximale servie d'un aliment.
    ///
    /// Elle est définie ici plutôt qu'à l'intérieur du solveur parce que les
    /// corrections d'après-coup doivent la respecter aussi : sans ça, une
    /// correction calorique pouvait faire grimper une portion sans limite.
    ///
    /// Pour les féculents, le plafond est en calories et non en grammes.
    /// Un plafond en grammes traite 400 g de riz et 400 g de pommes de terre
    /// comme équivalents, alors que le premier apporte trois fois plus
    /// d'énergie — et il rend le total inatteignable pour un athlète sans
    /// gluten, dont les féculents disponibles sont justement les moins denses.
    static func maximumGrams(for food: Food) -> Double {
        let roleCeiling: Double = switch food.role {
        case .protein:
            // Au plus deux fois et demie la portion déclarée, bornée à
            // 350 g. Sans le multiple, une poudre à portion de 30 g pouvait
            // partir à 350 g — un shaker de dix doses — dès que le créneau
            // avait faim : la portion du catalogue dit ce qui est comestible,
            // le plafond doit l'écouter.
            min(350, food.portionG * 2.5)
        case .carb:
            // Aucune assiette de féculent ne dépasse 600 kcal, ni 700 g.
            min(700, 600 / max(0.4, food.kcal / 100))
        case .fat:
            // Les graines sont très riches en fibres : quarante grammes de
            // chia apportent à eux seuls un tiers de la journée. Une fois et
            // demie la portion suffit.
            min(60, max(15, food.portionG * 1.5))
        case .fruit:
            300
        case .vegetable, .dairy, .drink, .treat:
            400
        }
        // Et jamais plus de 15 g de fibres dans un seul plat, quel que soit
        // le rôle. La borne est digestive avant d'être arithmétique : une
        // assiette de 300 g de pois cassés en porte 25, et personne ne la
        // digère. C'est la règle qui empêche les journées végétales de
        // dériver vers 100 g de fibres quand le rayon des légumineuses
        // s'agrandit — chaque plat plafonné, la journée suit.
        guard food.fiberG > 0 else { return roleCeiling }
        return min(roleCeiling, 15 / food.fiberG * 100)
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
        seed: Int,
        menuDay: Int = 0,
        dishes preference: DishPreference = .varied,
        preferring imposed: Recipe? = nil
    ) -> Meal {
        let proteinPool: [Food]
        let carbPool: [Food]
        var fatPool: [Food] = []
        var fixed: [Food] = []
        var vegetableGrams: Double? = nil

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
            carbPool = pool(role: .carb, diet: diet, excluding: excluded, restrictedTo: mainCarbs)
            fatPool = pool(role: .fat, diet: diet, excluding: excluded)
            // Deux légumes différents : c'est là que se joue le volume de
            // l'assiette, et donc la sensation d'avoir vraiment mangé.
            let vegetables = pool(role: .vegetable, diet: diet, excluding: excluded)
            if let first = pick(vegetables, seed: seed) { fixed.append(first) }
            if let second = pick(vegetables.filter { $0.id != fixed.first?.id }, seed: seed + 5) {
                fixed.append(second)
            }
            // Deux légumes à 200 g dans chaque repas principal font 800 g de
            // légumes par jour, et à eux seuls la moitié d'un excès de fibres
            // qui rend la journée pénible à tenir. 150 g chacun restent deux
            // vraies portions.
            vegetableGrams = fixedVegetableGrams(for: slot)
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
        let assembled = solve(
            protein: pick(viableProteins(proteinPool, target: target, avoiding: avoided), seed: seed),
            carb: pick(viableCarbs(carbPool, target: target), seed: seed + 1),
            fat: pick(fatPool, seed: seed + 3),
            fixed: fixed,
            vegetableGrams: vegetableGrams,
            target: target
        )

        // Un plat nommé, si l'un d'eux tient la cible aussi bien que
        // l'assiette. Le plat ne choisit que les aliments — le solveur garde
        // le dernier mot sur les grammes — mais choisir les aliments lui
        // retire de la liberté, et cette liberté était de la précision.
        //
        // D'où la comparaison plutôt qu'un pari : les deux sont résolus, et
        // le plat n'est retenu que s'il ne coûte rien. Un nom de plat ne vaut
        // pas un écart calorique. C'est le calcul qui est le produit ; la
        // recette l'habille, elle ne le commande pas.
        // Le plat ne choisit que les aliments — le solveur garde le dernier
        // mot sur les grammes — mais choisir les aliments lui retire de la
        // liberté, et cette liberté était de la précision. D'où la
        // comparaison plutôt qu'un pari : les deux sont résolus, et le plat
        // n'est retenu que s'il tient la cible calorique aussi bien que
        // l'assiette, ou au moins dans le budget de la journée.
        //
        // Un nom de plat ne vaut pas un écart calorique. C'est le calcul qui
        // est le produit ; la recette l'habille, elle ne le commande pas.
        guard preference != .none else {
            return Meal(slot: slot, items: assembled, note: note(for: slot))
        }
        let tolerance = max(kcalDrift(assembled, target: target), 0.08)

        // Tous les plats sont résolus, puis on choisit parmi ceux qui
        // tiennent. Prendre le premier acceptable rencontré coûterait la
        // variété : les plats recalés le sont pour presque toutes les
        // graines, et la semaine servirait deux dîners différents sur sept.
        var acceptable: [(dish: Recipe, items: [MealItem], fibre: Double)] = []
        for dish in dishes(
            slot: slot, target: target, diet: diet,
            excluded: excluded, avoiding: avoided
        ) {
            let items = solve(
                protein: FoodCatalog.food(id: dish.proteinID),
                carb: FoodCatalog.food(id: dish.carbID),
                fat: FoodCatalog.food(id: dish.fatID),
                fixed: dish.extraIDs.compactMap { FoodCatalog.food(id: $0) },
                vegetableGrams: vegetableGrams,
                target: target
            )
            guard kcalDrift(items, target: target) <= tolerance else { continue }
            acceptable.append((dish, items, items.map(\.macros).total.fiberG))
        }

        // Un plat imposé l'emporte s'il tient la cible : c'est le restant
        // de la veille, servi à midi. Il est résolu contre la cible de ce
        // repas-ci, donc l'assiette n'est pas la même — c'est bien le même
        // plat, ce n'est pas la même portion.
        if let imposed {
            // Le restant se résout contre la cible de ce repas-ci : même
            // plat, autre portion. Et il est accepté un peu plus largement
            // que les autres — un déjeuner ne porte pas la même part de la
            // journée qu'un dîner, et refuser le restant pour deux pour cent
            // d'écart rendrait à la semaine les huit plats qu'on vient de
            // lui retirer. L'équilibrage de fin de journée absorbe le reste.
            if let match = acceptable.first(where: { $0.dish.id == imposed.id }) {
                return Meal(slot: slot, items: match.items, note: note(for: slot), recipeID: match.dish.id)
            }
            let items = solve(
                protein: FoodCatalog.food(id: imposed.proteinID),
                carb: FoodCatalog.food(id: imposed.carbID),
                fat: FoodCatalog.food(id: imposed.fatID),
                fixed: imposed.extraIDs.compactMap { FoodCatalog.food(id: $0) },
                vegetableGrams: vegetableGrams,
                target: target
            )
            if kcalDrift(items, target: target) <= max(tolerance, 0.12) {
                return Meal(slot: slot, items: items, note: note(for: slot), recipeID: imposed.id)
            }
        }

        let chosen: (dish: Recipe, items: [MealItem], fibre: Double)?
        switch preference {
        case .varied:
            // L'index vient du jour de menu, pas de la graine. La graine vaut
            // menuDay × 7 + slot × 3 : modulo un nombre de plats multiple de
            // sept, elle rendait le même plat tous les jours, et la semaine
            // servait trois dîners au lieu de quatre.
            chosen = acceptable.isEmpty
                ? nil
                : acceptable[((menuDay + seed) % acceptable.count + acceptable.count) % acceptable.count]
        case .richestInFibre:
            // À égalité de fibres, le premier du catalogue : le choix reste
            // reproductible, ce qu'un tri instable ne garantirait pas.
            chosen = acceptable.max { $0.fibre < $1.fibre }
        case .none:
            chosen = nil
        }

        if let chosen {
            return Meal(
                slot: slot,
                items: chosen.items,
                note: note(for: slot),
                recipeID: chosen.dish.id
            )
        }

        return Meal(slot: slot, items: assembled, note: note(for: slot))
    }

    /// De quoi décaler les plats d'un créneau à l'autre.
    ///
    /// Sans lui, déjeuner et dîner d'une même journée de menu tomberaient sur
    /// le même plat : ils partagent la liste des plats acceptables, et le
    /// jour de menu est le même.
    static func slotOffset(_ slot: MealSlot) -> Int {
        switch slot {
        case .breakfast: 0
        case .lunch: 1
        case .snack: 2
        case .dinner: 2
        case .preWorkout: 3
        }
    }

    /// Les plats de la semaine pour un créneau, choisis une fois.
    ///
    /// Le menu est une fonction pure de la cible, du régime et des aliments
    /// refusés : il ne dépend pas du jour. C'est ce qui permet à une journée
    /// isolée — celle d'aujourd'hui, dans l'écran du jour — de connaître le
    /// menu de sa semaine sans avoir à la construire.
    ///
    /// Les plats sont pris à intervalle régulier dans la liste plutôt qu'en
    /// tête : deux recettes voisines au catalogue partagent souvent une
    /// protéine, et quatre plats de suite feraient une semaine de poulet.
    static func menu(
        slot: MealSlot,
        target: Macros,
        diet: DietPreference,
        excluded: Set<String>,
        count: Int
    ) -> [Recipe] {
        // Le menu ne propose que des plats que le repas acceptera.
        //
        // Sans ce filtre, `menu` retenait des plats sur la seule faisabilité
        // de leur protéine, et `meal` les refusait ensuite sur l'écart
        // calorique : le menu était proposé puis ignoré, les déjeuners ne
        // reprenaient plus les dîners, et la semaine servait trois plats.
        // Deux endroits qui décident de la même chose finissent toujours par
        // décider différemment ; ils partagent désormais le critère.
        let candidates = dishes(
            slot: slot, target: target, diet: diet, excluded: excluded, avoiding: []
        ).filter { dish in
            let items = solve(
                protein: FoodCatalog.food(id: dish.proteinID),
                carb: FoodCatalog.food(id: dish.carbID),
                fat: FoodCatalog.food(id: dish.fatID),
                fixed: dish.extraIDs.compactMap { FoodCatalog.food(id: $0) },
                vegetableGrams: fixedVegetableGrams(for: slot),
                target: target
            )
            return kcalDrift(items, target: target) <= 0.08
        }
        guard !candidates.isEmpty, count > 0 else { return [] }
        let wanted = min(count, candidates.count)
        var chosen: [Recipe] = [candidates[0]]
        var basket = Set(candidates[0].foodIDs)

        while chosen.count < wanted {
            let remaining = candidates.filter { candidate in
                !chosen.contains { $0.id == candidate.id }
                    && !chosen.contains { $0.proteinID == candidate.proteinID }
            }
            guard !remaining.isEmpty else { break }

            // Parmi les plats qui restent, celui qui réutilise le plus le
            // panier déjà commencé — sans jamais reprendre une protéine déjà
            // prise, sinon la semaine se réduirait à un seul plat décliné.
            //
            // C'est ce qui évite trois riz différents dans la même semaine :
            // riz basmati, riz blanc et riz complet sont trois lignes de
            // course, trois paquets, et aucun palais ne fait la différence
            // dans un plat en sauce.
            let best = remaining.max { left, right in
                let leftShared = basket.intersection(left.foodIDs).count
                let rightShared = basket.intersection(right.foodIDs).count
                if leftShared != rightShared { return leftShared < rightShared }
                // À égalité, l'ordre du catalogue tranche : le choix reste
                // reproductible, ce qu'un tri instable ne garantirait pas.
                let leftRank = candidates.firstIndex { $0.id == left.id } ?? 0
                let rightRank = candidates.firstIndex { $0.id == right.id } ?? 0
                return leftRank > rightRank
            }
            guard let best else { break }
            chosen.append(best)
            basket.formUnion(best.foodIDs)
        }
        return chosen
    }

    /// Le poids fixe des légumes d'un repas, quand il en porte.
    ///
    /// Deux légumes à 150 g dans chaque repas principal : c'est là que se
    /// joue le volume de l'assiette, et le solveur ne les étire pas.
    static func fixedVegetableGrams(for slot: MealSlot) -> Double? {
        switch slot {
        case .lunch, .dinner: 150
        case .breakfast, .snack, .preWorkout: nil
        }
    }

    /// L'écart calorique d'un repas résolu à ce qu'on lui demandait.
    static func kcalDrift(_ items: [MealItem], target: Macros) -> Double {
        guard target.kcal > 0 else { return 0 }
        return abs(items.map(\.macros).total.kcal - target.kcal) / target.kcal
    }

    /// Les plats servables à ce moment, du plus voulu au dernier recours.
    ///
    /// Une liste plutôt qu'un choix unique : le plat retenu est celui qui
    /// tient la cible, et cela ne se sait qu'après l'avoir résolu. Renvoyer
    /// un seul candidat obligerait à le prendre ou à tout abandonner.
    ///
    /// L'ordre est celui du catalogue, protéines déjà servies rejetées en
    /// fin de liste. C'est un ordre stable, et c'est ce qui rend le choix
    /// reproductible : le même jour donne le même plat, d'une ouverture
    /// d'écran à l'autre et d'une exécution des tests à l'autre.
    static func dishes(
        slot: MealSlot,
        target: Macros,
        diet: DietPreference,
        excluded: Set<String>,
        avoiding avoided: Set<String>
    ) -> [Recipe] {
        let candidates = RecipeCatalog.available(slot: slot, diet: diet, excluding: excluded)
            .filter { canReach(target, with: $0) }
        guard !candidates.isEmpty else { return [] }

        // La protéine déjà servie aujourd'hui passe en fin de liste plutôt
        // que d'en sortir : la répétition est un défaut, un repas sans source
        // protéique en est un pire. L'ordre suffit — le choix se fait plus
        // loin, une fois qu'on sait lesquels tiennent vraiment la cible.
        let fresh = candidates.filter { !avoided.contains($0.proteinID) }
        let tired = candidates.filter { avoided.contains($0.proteinID) }
        return fresh + tired
    }

    /// Le solveur peut-il atteindre cette cible avec les aliments de ce plat ?
    static func canReach(_ target: Macros, with recipe: Recipe) -> Bool {
        guard let protein = FoodCatalog.food(id: recipe.proteinID),
              let carb = FoodCatalog.food(id: recipe.carbID),
              FoodCatalog.food(id: recipe.fatID) != nil,
              recipe.extraIDs.allSatisfy({ FoodCatalog.food(id: $0) != nil })
        else { return false }

        // La protéine doit pouvoir livrer sa part sans dépasser le plafond de
        // portion — le même critère que viableProteins applique à un pool.
        if target.proteinG > 0 {
            guard protein.proteinG > 0,
                  target.proteinG / protein.proteinG * 100 <= maximumGrams(for: protein)
            else { return false }
        }

        // Et le féculent ne doit pas couvrir à lui seul la moitié des
        // protéines du repas, faute de quoi le solveur supprime la source
        // protéique et le plat perd ce qui en faisait un plat.
        if target.carbsG > 0, target.proteinG > 0, carb.carbsG > 0 {
            let grams = min(maximumGrams(for: carb), target.carbsG / carb.carbsG * 100)
            guard grams * carb.proteinG / 100 <= target.proteinG * 0.5 else { return false }
        }
        return true
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

    /// Combien de versions différentes d'un repas dans une semaine.
    ///
    /// Le petit-déjeuner et la collation en ont deux, pas quatre. C'est ainsi
    /// qu'on mange — on ne réinvente pas son petit-déjeuner tous les matins —
    /// et c'est ce qui fait disparaître de la liste de courses les quatre
    /// fruits, quatre matières grasses et quatre poudres qu'aucun panier
    /// n'aurait contenus ensemble.
    static func variety(for slot: MealSlot, menuDay: Int) -> Int {
        switch slot {
        case .breakfast, .snack, .preWorkout: menuDay % 2
        case .lunch, .dinner: menuDay
        }
    }

    /// Le nombre de journées différentes dans une semaine.
    ///
    /// Quatre, et non sept. On ne cuisine pas sept plats différents par
    /// semaine, et surtout on ne fait pas les courses pour sept : le panier
    /// se remplit alors de portions qu'aucun magasin ne vend.
    static let distinctDaysPerWeek = 4


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

        // La semaine tient en quelques journées, répétées.
        //
        // Sans cela, chaque jour tirait ses aliments indépendamment, et la
        // liste de courses de la semaine comptait cinquante-quatre lignes
        // dont « 60 g de steak » et « 30 g de caséine ». Ce n'est pas une
        // liste de courses, c'est une addition : personne n'achète soixante
        // grammes de steak, et personne ne cuisine quinze protéines
        // différentes en sept jours.
        //
        // Quatre journées distinctes suffisent à ne pas lasser — c'est aussi
        // le seuil que vérifie le test de variété — et elles divisent par
        // deux le nombre d'ingrédients tout en doublant les quantités, qui
        // deviennent enfin celles d'un vrai panier.
        let menuDay = ((dayIndex % distinctDaysPerWeek) + distinctDaysPerWeek) % distinctDaysPerWeek

        func mealTarget(_ entry: (slot: MealSlot, share: Double)) -> Macros {
            Macros(
                kcal: dayTarget.kcal * entry.share,
                proteinG: entry.slot == .preWorkout ? 0 : proteinPerMeal,
                carbsG: dayTarget.carbsG * entry.share,
                fatG: entry.slot == .preWorkout ? 0 : dayTarget.fatG * entry.share
            )
        }

        // Le menu de la semaine : quelques dîners, et les déjeuners qui les
        // remangent le lendemain. C'est ainsi qu'on mange — on cuisine une
        // fois, on mange deux fois — et c'est ce qui rend la liste de courses
        // achetable : huit plats par semaine demandent quarante ingrédients
        // en portions que personne ne vend, quatre en demandent la moitié.
        let dinnerSlot = layout.firstIndex { $0.slot == .dinner }
        let dinners = dinnerSlot.map {
            menu(
                slot: .dinner, target: mealTarget(layout[$0]), diet: diet,
                excluded: excluded, count: distinctDaysPerWeek
            )
        } ?? []
        let breakfastSlot = layout.firstIndex { $0.slot == .breakfast }
        let breakfasts = breakfastSlot.map {
            // Deux, pas quatre : on ne réinvente pas son petit-déjeuner tous
            // les matins, et c'est ce qui retirait de la liste quatre fruits,
            // quatre matières grasses et quatre poudres.
            menu(
                slot: .breakfast, target: mealTarget(layout[$0]), diet: diet,
                excluded: excluded, count: 2
            )
        } ?? []

        func dish(for slot: MealSlot) -> Recipe? {
            switch slot {
            case .dinner:
                return dinners.isEmpty ? nil : dinners[menuDay % dinners.count]
            case .lunch:
                // Le dîner de la veille, refroidi et remangé à midi.
                guard !dinners.isEmpty else { return nil }
                let yesterday = (menuDay + distinctDaysPerWeek - 1) % distinctDaysPerWeek
                return dinners[yesterday % dinners.count]
            case .breakfast:
                return breakfasts.isEmpty ? nil : breakfasts[(menuDay % 2) % breakfasts.count]
            case .snack, .preWorkout:
                return nil
            }
        }

        /// Le plat qu'on impose à ce repas, selon ce qu'on est prêt à lâcher.
        ///
        /// Le rattrapage des fibres abandonnait tout le menu : les jours
        /// concernés ne suivaient plus rien, les déjeuners ne reprenaient
        /// plus les dîners de la veille et la semaine servait trois plats au
        /// lieu de quatre. Or le manque de fibres se comble au petit-déjeuner
        /// et à la collation, pas en changeant le dîner qu'on avait prévu de
        /// cuisiner : c'est là qu'on prend la liberté, et nulle part ailleurs.
        func imposed(_ slot: MealSlot, _ preference: DishPreference) -> Recipe? {
            switch preference {
            case .varied: return dish(for: slot)
            case .richestInFibre: return slot == .lunch || slot == .dinner ? dish(for: slot) : nil
            case .none: return nil
            }
        }

        func build(_ preference: DishPreference) -> [Meal] {
            var meals: [Meal] = []
            var usedProteins: Set<String> = []
            for (index, entry) in layout.enumerated() {
                let built = meal(
                    slot: entry.slot,
                    target: mealTarget(entry),
                    diet: diet,
                    excluded: excluded,
                    avoidingProteins: usedProteins,
                    seed: variety(for: entry.slot, menuDay: menuDay) * 7 + index * 3,
                    menuDay: variety(for: entry.slot, menuDay: menuDay),
                    dishes: preference,
                    preferring: imposed(entry.slot, preference)
                )
                for item in built.items where item.food?.role == .protein {
                    usedProteins.insert(item.foodID)
                }
                meals.append(built)
            }
            return meals
        }

        // Les fibres se jugent sur la journée, jamais sur un repas.
        //
        // Un plancher appliqué plat par plat ne laissait survivre que deux ou
        // trois recettes, et la semaine servait trois dîners différents sur
        // sept : la garantie était tenue et le produit perdu. Ici la journée
        // est construite normalement, puis mesurée, et ce n'est que si elle
        // manque de fibres qu'on renonce — d'abord à la variété, ensuite aux
        // plats. Deux journées sur trois n'en arrivent jamais là.
        let floor = Double(target.calories) / 1_000 * 14 * 0.8
        var meals = build(.varied)
        if balance(meals, toward: dayTarget).map(\.macros).total.fiberG < floor {
            meals = build(.richestInFibre)
            if balance(meals, toward: dayTarget).map(\.macros).total.fiberG < floor {
                meals = build(.none)
            }
        }

        let corrected = balance(meals, toward: dayTarget)
        var dayNotes = notes(
            target: target,
            diet: diet,
            runsToday: runsToday,
            achievedFibreG: corrected.map(\.macros).total.fiberG
        )
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
                let grams = rounded(item.grams * scale, for: food)
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

    /// Sur combien de temps on fait ses courses.
    ///
    /// Personne ne fait ses courses au même rythme, et l'application n'a pas
    /// à trancher : certains passent au marché le samedi, d'autres remplissent
    /// un coffre une fois par mois. Le plan de repas, lui, tourne sur sept
    /// jours — ce qu'on achète pour un mois, c'est quatre fois la semaine.
    public enum ShoppingHorizon: Int, Sendable, CaseIterable, Identifiable {
        case week = 1
        case fortnight = 2
        case month = 4

        public var id: Int { rawValue }
        public var weeks: Int { rawValue }
        public var days: Int { rawValue * 7 }

        public var label: LocalizedText {
            switch self {
            case .week: LocalizedText(fr: "1 semaine", en: "1 week", es: "1 semana")
            case .fortnight: LocalizedText(fr: "2 semaines", en: "2 weeks", es: "2 semanas")
            case .month: LocalizedText(fr: "1 mois", en: "1 month", es: "1 mes")
            }
        }
    }

    /// La liste de courses d'une série de journées, agrégée par aliment.
    ///
    /// Au-delà de la semaine, tout n'est pas multiplié : les épinards d'un
    /// mois pourrissent avant la troisième semaine. Ce qui se garde — riz,
    /// conserves, huiles — est pris pour toute la période ; le frais reste à
    /// la quantité d'une semaine et se signale comme étant à reprendre.
    /// Multiplier aveuglément aurait donné une liste que personne ne peut
    /// suivre, et une liste qu'on ne suit pas ne sert à rien.
    public static func shoppingList(
        for days: [DayPlan],
        horizon: ShoppingHorizon = .week
    ) -> [ShoppingLine] {
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
                var line = ShoppingLine(
                    foodID: id,
                    grams: (grams / 10).rounded(.up) * 10,
                    role: food.role
                )
                guard horizon != .week else { return line }
                if line.keeps {
                    line.grams = line.grams * Double(horizon.weeks)
                } else {
                    line.repeatsWeekly = true
                }
                return line
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

    static func notes(
        target: NutritionTarget,
        diet: DietPreference,
        runsToday: Bool,
        achievedFibreG: Double
    ) -> [LocalizedText] {
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

        // Une seule note sur les fibres, et le même chiffre des deux côtés :
        // deux notes voisines qui se contredisent d'un gramme donnent
        // l'impression que le coach ne sait pas compter.
        let fibreTargetG = Double(target.calories) / 1_000 * 14
        let fibreTarget = Int(fibreTargetG.rounded())
        let achieved = Int(achievedFibreG.rounded())
        // Le seuil se juge sur la cible réelle, pas sur son arrondi
        // d'affichage. Une recommandation de 30,8 g arrondie à 31 déplaçait
        // le seuil de 46,2 à 46,5 : une journée à 46,3 g dépassait sans que
        // rien ne le dise, et c'est précisément le silence qu'on voulait
        // éviter en écrivant cette note.
        if achievedFibreG > fibreTargetG * 1.5 {
            // Une journée d'aliments entiers, et surtout une journée
            // végétarienne où les légumineuses portent les protéines, dépasse
            // largement la recommandation. Ce n'est pas une erreur du plan,
            // mais ce n'est pas anodin : on le dit plutôt que d'appauvrir
            // l'assiette pour faire tomber un chiffre.
            notes.append(
                LocalizedText(
                    fr: "Cette journée apporte \(achieved) g de fibres, pour \(fibreTarget) g recommandés. C'est volontaire — ce sont les légumineuses et les légumes qui portent tes protéines — mais si tu n'en manges pas autant d'habitude, monte progressivement sur deux semaines et bois davantage : le passage brutal est ce qui rend les fibres désagréables, pas les fibres elles-mêmes.",
                    en: "This day brings \(achieved) g of fibre against \(fibreTarget) g recommended. That is deliberate — pulses and vegetables are carrying your protein — but if you do not normally eat that much, ramp up over two weeks and drink more: it is the sudden jump that makes fibre unpleasant, not the fibre itself.",
                    es: "Este día aporta \(achieved) g de fibra frente a los \(fibreTarget) g recomendados. Es intencionado —las legumbres y las verduras llevan tu proteína— pero si no sueles comer tanta, súbela poco a poco durante dos semanas y bebe más: lo que hace desagradable la fibra es el salto brusco, no la fibra."
                )
            )
        } else {
            notes.append(
                LocalizedText(
                    fr: "Cette journée apporte \(achieved) g de fibres, pour \(fibreTarget) g recommandés. C'est ce qui fait la différence entre un déficit tenable et un déficit qui craque le jeudi soir.",
                    en: "This day brings \(achieved) g of fibre against \(fibreTarget) g recommended. That is the difference between a deficit you can hold and one that breaks on Thursday night.",
                    es: "Este día aporta \(achieved) g de fibra frente a los \(fibreTarget) g recomendados. Es la diferencia entre un déficit sostenible y uno que se rompe el jueves por la noche."
                )
            )
        }

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
