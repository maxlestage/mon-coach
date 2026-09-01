import Foundation

/// Une portion dite comme on la dit à table, pas comme on la pèse.
///
/// Pourquoi cette échelle existe
/// -----------------------------
/// Personne ne sait regarder une assiette et annoncer « 173 grammes ».
/// Tout le monde sait dire « une paume de poulet » ou « deux poignées de
/// riz » — ce sont les repères que les diététiciens donnent depuis
/// toujours, précisément parce qu'ils voyagent avec la main de celui qui
/// mange. Les grammes qui suivent sont ceux d'un adulte moyen ; ils sont
/// approximatifs et le disent.
public enum PortionSize: String, Codable, CaseIterable, Sendable, Identifiable {
    case small
    case medium
    case large
    case double

    public var id: String { rawValue }

    /// Le facteur appliqué à la portion de référence de l'aliment.
    public var factor: Double {
        switch self {
        case .small: 0.5
        case .medium: 1.0
        case .large: 1.5
        case .double: 2.0
        }
    }

    public var label: LocalizedText {
        switch self {
        case .small: LocalizedText(fr: "Petite part", en: "Small", es: "Poca")
        case .medium: LocalizedText(fr: "Normale", en: "Normal", es: "Normal")
        case .large: LocalizedText(fr: "Grosse part", en: "Large", es: "Mucha")
        case .double: LocalizedText(fr: "Double", en: "Double", es: "Doble")
        }
    }

    /// Le repère visuel correspondant, par rôle : c'est lui qu'on regarde
    /// en tenant l'assiette.
    public func hint(for role: FoodRole) -> LocalizedText {
        switch role {
        case .protein:
            switch self {
            case .small: LocalizedText(fr: "une demi-paume", en: "half a palm", es: "media palma")
            case .medium: LocalizedText(fr: "une paume", en: "a palm", es: "una palma")
            case .large: LocalizedText(fr: "une paume et demie", en: "a palm and a half", es: "palma y media")
            case .double: LocalizedText(fr: "deux paumes", en: "two palms", es: "dos palmas")
            }
        case .carb:
            switch self {
            case .small: LocalizedText(fr: "un demi-poing", en: "half a fist", es: "medio puño")
            case .medium: LocalizedText(fr: "un poing", en: "a fist", es: "un puño")
            case .large: LocalizedText(fr: "un poing et demi", en: "a fist and a half", es: "puño y medio")
            case .double: LocalizedText(fr: "deux poings", en: "two fists", es: "dos puños")
            }
        case .fat:
            switch self {
            case .small: LocalizedText(fr: "un demi-pouce", en: "half a thumb", es: "medio pulgar")
            case .medium: LocalizedText(fr: "un pouce", en: "a thumb", es: "un pulgar")
            case .large: LocalizedText(fr: "un pouce et demi", en: "a thumb and a half", es: "pulgar y medio")
            case .double: LocalizedText(fr: "deux pouces", en: "two thumbs", es: "dos pulgares")
            }
        default:
            switch self {
            case .small: LocalizedText(fr: "une demi-poignée", en: "half a handful", es: "medio puñado")
            case .medium: LocalizedText(fr: "une poignée", en: "a handful", es: "un puñado")
            case .large: LocalizedText(fr: "une grosse poignée", en: "a big handful", es: "un buen puñado")
            case .double: LocalizedText(fr: "deux poignées", en: "two handfuls", es: "dos puñados")
            }
        }
    }
}

/// Un aliment reconnu dans une assiette, et ce qu'on croit en avoir.
public struct PlateItem: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: String { foodID }
    public var foodID: String
    public var portion: PortionSize
    /// La confiance de la reconnaissance, de 0 à 1. Nulle quand c'est
    /// l'athlète qui a ajouté l'aliment lui-même — il n'y a alors rien à
    /// deviner, donc rien à douter.
    public var confidence: Double?

    public init(foodID: String, portion: PortionSize = .medium, confidence: Double? = nil) {
        self.foodID = foodID
        self.portion = portion
        self.confidence = confidence
    }

    public var food: Food? { FoodCatalog.food(id: foodID) }

    /// Les grammes retenus : la portion de référence de l'aliment, mise à
    /// l'échelle du repère choisi.
    public var grams: Double {
        guard let food else { return 0 }
        return (food.portionG * portion.factor / 5).rounded() * 5
    }

    public var macros: Macros {
        food?.macros(grams: grams) ?? .zero
    }
}

/// Une assiette photographiée, estimée.
public struct PlateEstimate: Codable, Sendable, Equatable {
    public var items: [PlateItem]
    /// L'identifiant de la photo, quand elle a été gardée.
    public var photoID: String?
    public var date: Date

    public init(items: [PlateItem], photoID: String? = nil, date: Date = Date()) {
        self.items = items
        self.photoID = photoID
        self.date = date
    }

    public var macros: Macros {
        items.map(\.macros).reduce(Macros.zero, +)
    }

    public var proteinG: Double { macros.proteinG }
    public var calories: Double { macros.kcal }

    /// La marge d'erreur honnête de l'estimation, en pourcentage.
    ///
    /// Elle n'est pas décorative. Estimer une portion sur une photo est
    /// imprécis par nature : l'angle, la profondeur de l'assiette et la
    /// densité de ce qu'on ne voit pas dessous se cumulent. Annoncer
    /// « 43 g de protéines » sans dire « à dix grammes près » donnerait à
    /// ce chiffre une autorité qu'aucune photo ne peut lui donner.
    ///
    /// Elle se resserre quand l'athlète a confirmé lui-même les aliments :
    /// ce qui reste incertain est alors la quantité, plus l'identité.
    public var uncertaintyPercent: Double {
        guard !items.isEmpty else { return 0 }
        let guessed = items.filter { ($0.confidence ?? 1) < 1 }.count
        let share = Double(guessed) / Double(items.count)
        return 20 + 15 * share
    }

    /// La fourchette de protéines, arrondie au gramme.
    public var proteinRangeG: ClosedRange<Int> {
        let margin = proteinG * uncertaintyPercent / 100
        return Int((proteinG - margin).rounded())...Int((proteinG + margin).rounded())
    }
}

/// Ce que le classificateur de l'appareil peut dire, traduit en aliments.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le système sait reconnaître des milliers de choses dans une image, mais
/// il parle sa langue : « cheeseburger », « bell_pepper », « french_fries ».
/// Le catalogue, lui, parle en aliments pesables. Cette table fait le pont,
/// et elle vit dans le moteur — donc elle se teste — plutôt que dans la vue
/// qui appelle le système.
///
/// Ce qui n'est pas dans la table n'est pas deviné. Reconnaître « nourriture »
/// et servir « poulet » au hasard serait pire que ne rien proposer : on
/// enregistrerait des protéines qui n'ont jamais été mangées.
public enum PlateVision {

    /// La confiance en dessous de laquelle on ne propose rien.
    ///
    /// Cinq pour cent, et pas trente. Le premier réglage partait d'une idée
    /// fausse : que la confiance d'un classificateur généraliste est une
    /// probabilité, comparable à celle d'une pièce truquée. Elle ne l'est
    /// pas. Le classificateur du système note chaque étiquette
    /// indépendamment, sur plus de mille catégories, et une reconnaissance
    /// franche — une assiette de viande photographiée en plein jour — sort
    /// couramment autour de 0,1. À trente pour cent, rien ne passait
    /// jamais : cinq photos parfaitement nettes ne donnaient aucun aliment.
    ///
    /// Le tri fin ne se fait donc pas ici mais dans l'appel au système, qui
    /// sait dire lui-même quelles étiquettes sont fiables. Ce seuil-ci n'est
    /// plus qu'un plancher contre le bruit du bas de liste.
    public static let minimumConfidence = 0.05

    /// Combien d'aliments au plus on propose pour une assiette. Au-delà,
    /// c'est le classificateur qui énumère, pas l'assiette qui contient.
    public static let maximumItems = 5

    /// La correspondance entre ce que voit l'appareil et ce qu'on mange.
    ///
    /// Un identifiant peut viser un aliment précis (« salmon » → saumon) ou
    /// un représentant raisonnable de sa catégorie (« french_fries » →
    /// pommes de terre, faute de mieux dans un catalogue qui ne fait pas de
    /// friture). Le second cas est signalé à l'athlète, qui corrige.
    public static let mapping: [String: String] = [
        // Protéines animales
        "chicken": "blanc-de-poulet",
        "roast_chicken": "poulet-roti",
        "fried_chicken": "cuisse-de-poulet",
        "turkey": "dinde",
        "steak": "steak",
        "beef": "boeuf-5",
        "hamburger": "boeuf-15",
        "cheeseburger": "boeuf-15",
        "meatball": "boeuf-15",
        "pork": "porc-filet",
        "bacon": "jambon-blanc",
        "ham": "jambon-blanc",
        "sausage": "saucisse-toulouse",
        "salmon": "saumon",
        "sashimi": "saumon",
        "sushi": "riz-blanc",
        "tuna": "thon-boite",
        "fish": "cabillaud",
        "shrimp": "crevettes",
        "egg": "oeuf",
        "fried_egg": "oeuf",
        "omelette": "oeuf",
        "scrambled_eggs": "oeuf",
        // Féculents
        "rice": "riz-blanc",
        "fried_rice": "riz-blanc",
        "risotto": "riz-blanc",
        "pasta": "pates-completes",
        "spaghetti": "pates-completes",
        "lasagna": "pates-completes",
        "noodle": "pates-blanches",
        "ramen": "pates-blanches",
        "pizza": "pates-blanches",
        "bread": "pain-complet",
        "sandwich": "pain-complet",
        "toast": "pain-complet",
        "bagel": "pain-blanc",
        "baguette": "pain-blanc",
        "potato": "pomme-de-terre",
        "mashed_potato": "pomme-de-terre",
        "french_fries": "pomme-de-terre",
        "sweet_potato": "patate-douce",
        "quinoa": "quinoa",
        "couscous": "semoule",
        "oatmeal": "flocons-avoine",
        "porridge": "flocons-avoine",
        "cereal": "muesli-nature",
        "pancake": "pain-blanc",
        "tortilla": "tortilla-mais",
        "taco": "tortilla-mais",
        "burrito": "tortilla-mais",
        // Légumineuses et végétal
        "lentil": "lentilles",
        "chickpea": "pois-chiches",
        "hummus": "pois-chiches",
        "bean": "haricots-rouges",
        "tofu": "tofu",
        // Légumes
        "salad": "salade",
        "lettuce": "salade",
        "broccoli": "brocoli",
        "carrot": "carotte",
        "tomato": "tomate",
        "cucumber": "concombre",
        "spinach": "epinards",
        "pepper": "poivron",
        "bell_pepper": "poivron",
        "zucchini": "courgette",
        "green_bean": "haricots-verts",
        "mushroom": "champignons",
        "cauliflower": "chou-fleur",
        "onion": "oignon",
        "corn": "mais-doux",
        "pea": "petits-pois",
        "eggplant": "aubergine",
        "cabbage": "chou",
        "beet": "betterave",
        "asparagus": "asperge",
        "avocado": "avocat",
        // Fruits
        "banana": "banane",
        "apple": "pomme",
        "orange": "orange",
        "strawberry": "fraises",
        "blueberry": "myrtilles",
        "grape": "raisin",
        "kiwi": "kiwi",
        "mango": "mangue",
        "pineapple": "ananas",
        "watermelon": "pasteque",
        "peach": "peche",
        "pear": "poire",
        // Laitiers
        "yogurt": "skyr",
        "cheese": "fromage-blanc",
        "milk": "lait",
        "cottage_cheese": "cottage",
        // Matières grasses
        "olive_oil": "huile-olive",
        "butter": "beurre",
        "almond": "amandes",
        "peanut": "cacahuetes",
        "walnut": "noix",
        "nut": "amandes",
        "cashew": "cajou",
        "hazelnut": "noisettes",
        "pistachio": "pistaches",

        // Les mots que le classificateur emploie vraiment.
        //
        // Ceux-ci manquaient, et c'est ce qui faisait qu'une assiette
        // parfaitement lisible — une entrecôte, des grenailles, une salade —
        // ne donnait aucun aliment : le système ne dit pas toujours
        // « steak », il dit « beefsteak », « roast_beef », « grilled_meat ».
        "beefsteak": "steak",
        "sirloin": "steak",
        "roast_beef": "boeuf-5",
        "ground_beef": "boeuf-15",
        "brisket": "boeuf-15",
        "veal": "veau-escalope",
        "lamb": "agneau-gigot",
        "chicken_breast": "blanc-de-poulet",
        "drumstick": "cuisse-de-poulet",
        "cod": "cabillaud",
        "trout": "truite",
        "sardine": "sardines",
        "mackerel": "maquereau",
        "prawn": "crevettes",
        "mussel": "moules",
        "boiled_egg": "oeuf",
        "poached_egg": "oeuf",

        // Féculents et pains
        "new_potato": "pomme-de-terre",
        "baby_potato": "pomme-de-terre",
        "roast_potato": "pomme-de-terre",
        "boiled_potato": "pomme-de-terre",
        "potato_salad": "pomme-de-terre",
        "chip": "pomme-de-terre",
        "wholemeal_bread": "pain-complet",
        "whole_wheat_bread": "pain-complet",
        "sourdough": "pain-complet",
        "rye_bread": "pain-seigle",
        "flatbread": "pain-blanc",
        "pita": "pain-blanc",
        "crouton": "pain-blanc",
        "macaroni": "pates-blanches",
        "penne": "pates-completes",
        "tagliatelle": "pates-completes",
        "brown_rice": "riz-complet",
        "basmati": "riz-basmati",
        "polenta": "polenta",
        "bulgur": "boulgour",
        "barley": "orge-perle",
        "millet": "millet",

        // Légumes
        "green_salad": "salade",
        "mixed_salad": "salade",
        "leaf": "salade",
        "romaine": "salade",
        "baby_carrot": "carotte",
        "roasted_carrot": "carotte",
        "cherry_tomato": "tomate",
        "courgette": "courgette",
        "aubergine": "aubergine",
        "leek": "poireau",
        "radish": "radis",
        "turnip": "navet",
        "pumpkin": "potiron",
        "artichoke": "artichaut",
        "fennel": "fenouil",
        "celery": "celeri-branche",
        "brussels_sprout": "chou-bruxelles",
        "kale": "chou-kale",
        "endive": "endive",
        "leek_soup": "poireau",

        // Laitiers et desserts
        "burrata": "mozzarella",
        "mozzarella": "mozzarella",
        "feta": "feta",
        "goat_cheese": "chevre-buche",
        "parmesan": "parmesan",
        "greek_yogurt": "skyr",
        "curd": "fromage-blanc",

        // Ce qui se mange sans être un repas. Le catalogue les porte, et les
        // ignorer donnait le pire des écrans : une plaque de cookies
        // reconnue comme « rien de sûr ».
        "cookie": "biscuits",
        "biscuit": "biscuits",
        "shortbread": "biscuits",
        "cracker": "biscuits",
        "cake": "gateau-chocolat",
        "brownie": "gateau-chocolat",
        "muffin": "gateau-chocolat",
        "cupcake": "gateau-chocolat",
        "chocolate": "chocolat-noir",
        "candy": "bonbons",
        "sweet": "bonbons",
        "ice_cream": "glace",
        "sorbet": "glace",
    ]

    /// Les mots du classificateur qui désignent une famille plutôt qu'un
    /// aliment.
    ///
    /// Le système décrit souvent une image par sa catégorie — « meat »,
    /// « dessert », « vegetable » — avant de nommer quoi que ce soit de
    /// précis. Ces mots-là ne donnent pas un aliment, mais ils donnent un
    /// rayon, et un rayon suffit à ne pas laisser l'athlète devant un écran
    /// vide : on lui ouvre la bonne page du catalogue plutôt que de lui
    /// dire qu'on n'a rien vu.
    public static let categories: [String: FoodRole] = [
        "meat": .protein,
        "poultry": .protein,
        "seafood": .protein,
        "fish": .protein,
        "shellfish": .protein,
        "egg": .protein,
        "legume": .protein,
        "vegetable": .vegetable,
        "salad": .vegetable,
        "greens": .vegetable,
        "fruit": .fruit,
        "berry": .fruit,
        "citrus": .fruit,
        "bread": .carb,
        "pasta": .carb,
        "grain": .carb,
        "cereal": .carb,
        "rice": .carb,
        "noodle": .carb,
        "dough": .carb,
        "batter": .carb,
        "dairy": .dairy,
        "cheese": .dairy,
        "yogurt": .dairy,
        "milk": .dairy,
        "nut": .fat,
        "oil": .fat,
        "seed": .fat,
        "dessert": .treat,
        "baked_goods": .treat,
        "pastry": .treat,
        "cookie": .treat,
        "biscuit": .treat,
        "cake": .treat,
        "chocolate": .treat,
        "candy": .treat,
        "ice_cream": .treat,
        "snack_food": .treat,
        "drink": .drink,
        "beverage": .drink,
        "juice": .drink,
        "coffee": .drink,
        "tea": .drink,
    ]

    /// Ramène un identifiant du système à une forme comparable.
    ///
    /// Le système écrit « French_Fries », « bell pepper », « cookies » selon
    /// les catégories : sans cette mise à plat, la table ne reconnaîtrait
    /// que la moitié de ce qui lui est réellement présenté.
    static func normalised(_ identifier: String) -> String {
        identifier
            .lowercased()
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }

    /// Les formes sous lesquelles chercher un identifiant, de la plus
    /// fidèle à la plus permissive.
    ///
    /// Le singulier vient après la forme exacte, et jamais à sa place :
    /// certaines catégories du système finissent par un « s » qui fait
    /// partie du mot — « baked_goods », « greens » — et les tronquer
    /// d'office les rendait introuvables.
    ///
    /// Le dernier mot d'un composé vient en dernier : « grilled_chicken »
    /// est du poulet, « chocolate_chip_cookie » est un biscuit.
    static func lookupKeys(_ identifier: String) -> [String] {
        let key = normalised(identifier)
        var keys = [key]
        if key.hasSuffix("s"), !key.hasSuffix("ss"), key.count > 3 {
            keys.append(String(key.dropLast()))
        }
        for candidate in keys where candidate.contains("_") {
            if let tail = candidate.split(separator: "_").last.map(String.init) {
                keys.append(tail)
                if tail.hasSuffix("s"), !tail.hasSuffix("ss"), tail.count > 3 {
                    keys.append(String(tail.dropLast()))
                }
            }
        }
        return keys
    }

    /// L'aliment du catalogue visé par un identifiant, s'il y en a un.
    static func food(for identifier: String) -> String? {
        for key in lookupKeys(identifier) {
            if let found = mapping[key] { return found }
        }
        return nil
    }

    /// Le rayon visé par un identifiant, quand il ne nomme qu'une famille.
    static func category(for identifier: String) -> FoodRole? {
        for key in lookupKeys(identifier) {
            if let found = categories[key] { return found }
        }
        return nil
    }

    /// Les rayons que le système a cru voir, sans savoir nommer d'aliment.
    ///
    /// Servis à l'écran quand rien de précis n'a été reconnu : « il y a
    /// l'air d'y avoir de la viande et un féculent » vaut infiniment mieux
    /// que « je ne reconnais rien », qui est un cul-de-sac.
    public static func roles(
        from observations: [(identifier: String, confidence: Double)],
        limit: Int = 3
    ) -> [FoodRole] {
        var seen: [FoodRole] = []
        for observation in observations where observation.confidence >= minimumConfidence {
            if let role = category(for: observation.identifier), !seen.contains(role) {
                seen.append(role)
            }
            if seen.count == limit { break }
        }
        return seen
    }

    /// Traduit les propositions du système en aliments du catalogue.
    ///
    /// L'ordre des propositions est conservé : le classificateur les rend de
    /// la plus probable à la moins probable, et c'est l'information la plus
    /// utile qu'il donne. Un même aliment proposé deux fois — « chicken » et
    /// « roast_chicken » — n'est retenu qu'une fois, à sa meilleure
    /// confiance.
    public static func foods(
        from observations: [(identifier: String, confidence: Double)],
        excluding excluded: Set<String> = [],
        limit: Int = maximumItems
    ) -> [PlateItem] {
        var seen = Set<String>()
        var result: [PlateItem] = []
        for observation in observations
        where observation.confidence >= minimumConfidence {
            guard let foodID = food(for: observation.identifier),
                  FoodCatalog.food(id: foodID) != nil,
                  // Un aliment écarté du plan — allergie, dégoût — n'a rien à
                  // faire dans une assiette proposée. S'il y était vraiment,
                  // l'athlète l'ajoute lui-même, en connaissance de cause.
                  !excluded.contains(foodID),
                  seen.insert(foodID).inserted
            else { continue }
            result.append(
                PlateItem(foodID: foodID, portion: .medium, confidence: observation.confidence)
            )
            if result.count == limit { break }
        }
        return result
    }
}
