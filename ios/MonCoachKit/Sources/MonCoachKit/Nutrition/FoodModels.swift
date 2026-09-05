import Foundation

/// Le rang d'un aliment dans le programme.
///
/// Trois niveaux, et pas de morale : « à limiter » ne veut pas dire
/// « interdit ». Un aliment tombe dans un rang à cause de ce qu'il apporte
/// par calorie, pas à cause de sa réputation. Chaque aliment porte la raison
/// de son rang, parce qu'une consigne sans raison ne se tient pas six mois.
public enum FoodTier: String, Codable, CaseIterable, Sendable, Comparable {
    /// La base de l'assiette. Dense en nutriments, rassasiant par calorie.
    case base
    /// Utile, mais à doser : calorique, pauvre en fibres, ou déséquilibré seul.
    case moderate
    /// À garder pour le plaisir, en connaissance de cause.
    case occasional

    public var label: LocalizedText {
        switch self {
        case .base:
            LocalizedText(fr: "À privilégier", en: "Build meals on these", es: "Para priorizar")
        case .moderate:
            LocalizedText(fr: "Avec modération", en: "In moderation", es: "Con moderación")
        case .occasional:
            LocalizedText(fr: "Occasionnel", en: "Occasional", es: "Ocasional")
        }
    }

    public var guidance: LocalizedText {
        switch self {
        case .base:
            LocalizedText(
                fr: "Ces aliments composent l'essentiel de la journée. Beaucoup de protéines, de fibres et de micronutriments pour peu de calories : ils rassasient avant de faire dépasser le total.",
                en: "These make up most of the day. Plenty of protein, fibre and micronutrients per calorie: they fill you up before they blow your total.",
                es: "Estos alimentos forman la mayor parte del día. Mucha proteína, fibra y micronutrientes por caloría: sacian antes de disparar el total."
            )
        case .moderate:
            LocalizedText(
                fr: "Utiles, mais denses en calories ou pauvres en fibres. Ils se pèsent au lieu de se servir à l'œil : c'est la seule différence entre les deux premiers rangs.",
                en: "Useful, but calorie-dense or short on fibre. Weigh them instead of eyeballing them — that is the only real difference from the tier above.",
                es: "Útiles, pero densos en calorías o pobres en fibra. Se pesan en lugar de servirse a ojo: esa es la única diferencia con el nivel anterior."
            )
        case .occasional:
            LocalizedText(
                fr: "Beaucoup de calories, peu de rassasiement, peu de micronutriments. Rien n'est interdit : au-delà d'environ 10 % des calories de la semaine, ces aliments prennent la place de ceux qui font le travail.",
                en: "Lots of calories, little fullness, few micronutrients. Nothing is banned: past roughly 10 % of the week's calories, these simply crowd out the food doing the work.",
                es: "Muchas calorías, poca saciedad, pocos micronutrientes. Nada está prohibido: más allá de un 10 % de las calorías semanales, desplazan a los alimentos que hacen el trabajo."
            )
        }
    }

    static let order: [FoodTier: Int] = [.base: 0, .moderate: 1, .occasional: 2]

    public static func < (lhs: FoodTier, rhs: FoodTier) -> Bool {
        (order[lhs] ?? 0) < (order[rhs] ?? 0)
    }
}

/// Le rôle d'un aliment dans une assiette. C'est ce que lit le constructeur
/// de repas pour savoir quoi mettre où.
public enum FoodRole: String, Codable, CaseIterable, Sendable {
    case protein
    case carb
    case vegetable
    case fruit
    case fat
    case dairy
    case drink
    case treat

    public var label: LocalizedText {
        switch self {
        case .protein: LocalizedText(fr: "Protéines", en: "Protein", es: "Proteína")
        case .carb: LocalizedText(fr: "Féculents", en: "Starches", es: "Farináceos")
        case .vegetable: LocalizedText(fr: "Légumes", en: "Vegetables", es: "Verduras")
        case .fruit: LocalizedText(fr: "Fruits", en: "Fruit", es: "Fruta")
        case .fat: LocalizedText(fr: "Matières grasses", en: "Fats", es: "Grasas")
        case .dairy: LocalizedText(fr: "Produits laitiers", en: "Dairy", es: "Lácteos")
        case .drink: LocalizedText(fr: "Boissons", en: "Drinks", es: "Bebidas")
        case .treat: LocalizedText(fr: "Plaisir", en: "Treats", es: "Caprichos")
        }
    }
}

/// Ce qu'un aliment contient, et ce qu'il empêche.
public struct Food: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: String
    public var name: LocalizedText
    public var role: FoodRole
    public var tier: FoodTier

    // Pour 100 g de produit prêt à consommer.
    public var kcal: Double
    public var proteinG: Double
    public var carbsG: Double
    public var fatG: Double
    public var fiberG: Double
    /// Alcool en grammes. Il apporte 7 kcal par gramme et n'est ni un
    /// glucide, ni un lipide, ni une protéine : sans ce champ, une bière
    /// afficherait 16 kcal au lieu de 43, et les calories les plus faciles à
    /// oublier de la semaine deviendraient invisibles.
    public var alcoholG: Double

    /// Portion habituelle en grammes, pour proposer un point de départ crédible.
    public var portionG: Double
    /// Le régime le plus restrictif qui accepte cet aliment.
    public var diets: Set<DietPreference>
    /// Pourquoi il est à ce rang. Toujours renseigné : c'est la moitié du produit.
    public var reason: LocalizedText

    public init(
        id: String,
        name: LocalizedText,
        role: FoodRole,
        tier: FoodTier,
        kcal: Double,
        proteinG: Double,
        carbsG: Double,
        fatG: Double,
        fiberG: Double = 0,
        alcoholG: Double = 0,
        portionG: Double,
        diets: Set<DietPreference>,
        reason: LocalizedText
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.tier = tier
        self.kcal = kcal
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.fiberG = fiberG
        self.alcoholG = alcoholG
        self.portionG = portionG
        self.diets = diets
        self.reason = reason
    }

    /// Densité protéique : grammes de protéines pour 100 kcal. C'est le
    /// critère qui sépare vraiment un aliment protéiné d'un aliment gras.
    public var proteinPerHundredKcal: Double {
        kcal > 0 ? proteinG / kcal * 100 : 0
    }

    public func suits(_ diet: DietPreference) -> Bool { diets.contains(diet) }

    /// Les macros d'une quantité donnée.
    public func macros(grams: Double) -> Macros {
        let factor = grams / 100
        return Macros(
            kcal: kcal * factor,
            proteinG: proteinG * factor,
            carbsG: carbsG * factor,
            fatG: fatG * factor,
            fiberG: fiberG * factor,
            alcoholG: alcoholG * factor
        )
    }
}

/// Un total de macros, additionnable.
public struct Macros: Codable, Sendable, Equatable, Hashable {
    public var kcal: Double
    public var proteinG: Double
    public var carbsG: Double
    public var fatG: Double
    public var fiberG: Double
    public var alcoholG: Double

    public init(
        kcal: Double = 0,
        proteinG: Double = 0,
        carbsG: Double = 0,
        fatG: Double = 0,
        fiberG: Double = 0,
        alcoholG: Double = 0
    ) {
        self.kcal = kcal
        self.proteinG = proteinG
        self.carbsG = carbsG
        self.fatG = fatG
        self.fiberG = fiberG
        self.alcoholG = alcoholG
    }

    public static let zero = Macros()

    public static func + (lhs: Macros, rhs: Macros) -> Macros {
        Macros(
            kcal: lhs.kcal + rhs.kcal,
            proteinG: lhs.proteinG + rhs.proteinG,
            carbsG: lhs.carbsG + rhs.carbsG,
            fatG: lhs.fatG + rhs.fatG,
            fiberG: lhs.fiberG + rhs.fiberG,
            alcoholG: lhs.alcoholG + rhs.alcoholG
        )
    }

    public static func += (lhs: inout Macros, rhs: Macros) { lhs = lhs + rhs }
}

extension Sequence where Element == Macros {
    public var total: Macros { reduce(.zero, +) }
}

/// Le service auquel un aliment appartient dans un repas.
///
/// Pourquoi un repas a des services
/// --------------------------------
/// Le planificateur savait composer une assiette juste, et il ne savait
/// servir qu'elle : une protéine, un féculent, deux légumes, posés
/// ensemble. C'est une assiette de cantine, pas un repas — et un repas
/// français en a trois, ce qui n'est pas une coquetterie mais la façon dont
/// on mange vraiment. Une entrée de crudités change le rassasiement avant le
/// plat ; un dessert évite d'aller chercher autre chose une heure après.
///
/// Le service ne change rien au calcul : l'entrée et le dessert sont servis
/// en quantité fixe, comme les deux légumes du plat, et le solveur ajuste
/// le reste autour d'eux. Toutes les garanties de la journée tiennent donc
/// telles quelles — les macros dans leur budget, le minimum de protéines,
/// le régime respecté, les aliments refusés écartés.
public enum MealCourse: String, Codable, CaseIterable, Sendable, Identifiable {
    case starter
    case main
    case dessert

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .starter: LocalizedText(fr: "Entrée", en: "Starter", es: "Entrante")
        case .main: LocalizedText(fr: "Plat", en: "Main", es: "Plato")
        case .dessert: LocalizedText(fr: "Dessert", en: "Dessert", es: "Postre")
        }
    }
}

/// Un aliment servi en quantité, dans un repas.
public struct MealItem: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: String { foodID }
    public var foodID: String
    public var grams: Double
    public var macros: Macros
    /// Le service. « Plat » par défaut : c'est le cas de tout ce qui existait
    /// avant que les repas en aient.
    public var course: MealCourse

    public init(
        foodID: String,
        grams: Double,
        macros: Macros,
        course: MealCourse = .main
    ) {
        self.foodID = foodID
        self.grams = grams
        self.macros = macros
        self.course = course
    }

    /// Le décodage est écrit à la main pour une seule raison : le service est
    /// arrivé après. Un plan enregistré avant lui n'a pas la clé, et le
    /// décodeur engendré par Swift échouerait dessus — la valeur par défaut
    /// d'une propriété ne le rend pas tolérant. Un journal alimentaire qui
    /// refuse de se relire après une mise à jour est une perte de données.
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        foodID = try container.decode(String.self, forKey: .foodID)
        grams = try container.decode(Double.self, forKey: .grams)
        macros = try container.decode(Macros.self, forKey: .macros)
        course = try container.decodeIfPresent(MealCourse.self, forKey: .course) ?? .main
    }

    public var food: Food? { FoodCatalog.food(id: foodID) }
}

/// Un moment de la journée.
public enum MealSlot: String, Codable, CaseIterable, Sendable, Identifiable {
    case breakfast
    case lunch
    case snack
    case dinner
    case preWorkout

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .breakfast: LocalizedText(fr: "Petit-déjeuner", en: "Breakfast", es: "Desayuno")
        case .lunch: LocalizedText(fr: "Déjeuner", en: "Lunch", es: "Comida")
        case .snack: LocalizedText(fr: "Collation", en: "Snack", es: "Merienda")
        case .dinner: LocalizedText(fr: "Dîner", en: "Dinner", es: "Cena")
        case .preWorkout: LocalizedText(fr: "Avant la séance", en: "Pre-workout", es: "Antes de entrenar")
        }
    }
}

/// Un repas construit.
public struct Meal: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var slot: MealSlot
    public var items: [MealItem]
    public var note: LocalizedText?

    /// Le plat dont ce repas est la mise en quantité, s'il en porte un.
    ///
    /// Facultatif à dessein : un en-cas n'est pas une recette, et un repas
    /// dont aucun plat ne convenait au régime reste servi en aliments plutôt
    /// que supprimé. L'identifiant plutôt que la recette entière — elle est
    /// dans le catalogue, la dupliquer ici la laisserait dériver.
    public var recipeID: String?

    public init(
        id: UUID = UUID(),
        slot: MealSlot,
        items: [MealItem],
        note: LocalizedText? = nil,
        recipeID: String? = nil
    ) {
        self.id = id
        self.slot = slot
        self.items = items
        self.note = note
        self.recipeID = recipeID
    }

    public var macros: Macros { items.map(\.macros).total }

    /// Le plat, résolu depuis le catalogue.
    public var recipe: Recipe? { recipeID.flatMap(RecipeCatalog.recipe(id:)) }
}

/// Une journée alimentaire complète.
public struct DayPlan: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    /// Indice du jour dans la semaine, à partir de 0.
    public var dayIndex: Int
    public var meals: [Meal]
    public var target: Macros
    public var notes: [LocalizedText]

    public init(id: UUID = UUID(), dayIndex: Int, meals: [Meal], target: Macros, notes: [LocalizedText] = []) {
        self.id = id
        self.dayIndex = dayIndex
        self.meals = meals
        self.target = target
        self.notes = notes
    }

    public var macros: Macros { meals.map(\.macros).total }

    /// Écart relatif à la cible sur chaque macro, signé.
    public var drift: Macros {
        let actual = macros
        func delta(_ a: Double, _ t: Double) -> Double { t > 0 ? (a - t) / t : 0 }
        return Macros(
            kcal: delta(actual.kcal, target.kcal),
            proteinG: delta(actual.proteinG, target.proteinG),
            carbsG: delta(actual.carbsG, target.carbsG),
            fatG: delta(actual.fatG, target.fatG)
        )
    }
}
