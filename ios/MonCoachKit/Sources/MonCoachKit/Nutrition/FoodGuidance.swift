import Foundation

/// Ce qu'un échange fait gagner. Déclaré par l'échange, vérifié par les tests
/// sur les valeurs du catalogue : un échange qui ne tient pas sa promesse
/// chiffrée casse la compilation des tests avant d'arriver à l'écran.
public enum SwapGain: String, Codable, Sendable, CaseIterable {
    case calories
    case protein
    case fibre
    /// Rien de mesurable dans la table, mais une meilleure qualité — le type
    /// d'acides gras, la nature du produit. Le seul cas où le chiffre ne
    /// justifie pas l'échange, et il est signalé comme tel.
    case quality

    public var label: LocalizedText {
        switch self {
        case .calories: LocalizedText(fr: "Moins de calories", en: "Fewer calories", es: "Menos calorías")
        case .protein: LocalizedText(fr: "Plus de protéines", en: "More protein", es: "Más proteína")
        case .fibre: LocalizedText(fr: "Plus de fibres", en: "More fibre", es: "Más fibra")
        case .quality: LocalizedText(fr: "Meilleure qualité", en: "Better quality", es: "Mejor calidad")
        }
    }
}

/// Un échange : ce qu'on remplace, par quoi, et ce que ça change.
///
/// Les deux quantités sont données séparément parce qu'un échange se fait à
/// portion réelle, pas à poids égal : trente grammes de biscuits ne se
/// remplacent pas par trente grammes de chocolat noir, mais par vingt.
/// Comparer à poids égal ferait passer la moitié de ces échanges pour des
/// mauvaises affaires alors qu'ils n'en sont pas.
public struct FoodSwap: Sendable, Equatable, Identifiable {
    public var id: String { "\(fromID)>\(toID)" }
    public var fromID: String
    public var toID: String
    public var fromGrams: Double
    public var toGrams: Double
    public var gain: SwapGain
    public var reason: LocalizedText

    public var from: Food? { FoodCatalog.food(id: fromID) }
    public var to: Food? { FoodCatalog.food(id: toID) }

    var fromMacros: Macros { from?.macros(grams: fromGrams) ?? .zero }
    var toMacros: Macros { to?.macros(grams: toGrams) ?? .zero }

    /// Calories économisées. Négatif si l'échange en ajoute.
    public var kcalSaved: Double { fromMacros.kcal - toMacros.kcal }
    public var proteinGained: Double { toMacros.proteinG - fromMacros.proteinG }
    public var fiberGained: Double { toMacros.fiberG - fromMacros.fiberG }
}

/// Un rayon du guide alimentaire.
public struct GuidanceSection: Sendable, Equatable, Identifiable {
    public var id: String { role.rawValue }
    public var role: FoodRole
    public var base: [Food]
    public var moderate: [Food]
    public var occasional: [Food]

    public var isEmpty: Bool { base.isEmpty && moderate.isEmpty && occasional.isEmpty }
}

/// Le guide « quoi mettre dans le caddie », rangé par rayon.
///
/// C'est la partie du produit qui survit à l'abonnement : un plan de repas
/// se périme, savoir pourquoi les lentilles battent le riz blanc ne se périme
/// pas. Rien n'est interdit ici, tout est classé et justifié.
public enum FoodGuidance {

    public static func sections(
        diet: DietPreference = .omnivore,
        excluding excluded: Set<String> = []
    ) -> [GuidanceSection] {
        let order: [FoodRole] = [.protein, .vegetable, .carb, .fruit, .fat, .dairy, .drink, .treat]
        return order.compactMap { role in
            let foods = FoodCatalog.available(diet: diet, excluding: excluded, roles: [role])
            let section = GuidanceSection(
                role: role,
                base: foods.filter { $0.tier == .base },
                moderate: foods.filter { $0.tier == .moderate },
                occasional: foods.filter { $0.tier == .occasional }
            )
            return section.isEmpty ? nil : section
        }
    }

    /// Les protéines les plus rentables : le plus de protéines par calorie.
    public static func leanestProteins(diet: DietPreference = .omnivore, limit: Int = 8) -> [Food] {
        FoodCatalog
            .available(diet: diet, roles: [.protein, .dairy], maximumTier: .base)
            .sorted { $0.proteinPerHundredKcal > $1.proteinPerHundredKcal }
            .prefix(limit)
            .map { $0 }
    }

    /// Les aliments qui rassasient le plus pour le moins de calories.
    public static func mostFilling(diet: DietPreference = .omnivore, limit: Int = 8) -> [Food] {
        FoodCatalog
            .available(diet: diet, maximumTier: .base)
            .filter { $0.kcal > 10 }
            .sorted { $0.fiberG / $0.kcal > $1.fiberG / $1.kcal }
            .prefix(limit)
            .map { $0 }
    }

    /// Les échanges qui changent le plus une journée, pour le moins d'effort.
    ///
    /// Chaque échange garde la même quantité et le même usage : ce ne sont pas
    /// des privations, ce sont des substitutions à assiette égale.
    public static let swaps: [FoodSwap] = [
        FoodSwap(
            fromID: "jus-fruit", toID: "orange",
            fromGrams: 200, toGrams: 200, gain: .fibre,
            reason: LocalizedText(
                fr: "Le fruit entier apporte les fibres que le jus laisse derrière lui, et il se mâche : le cerveau enregistre qu'on a mangé.",
                en: "Whole fruit brings the fibre the juice leaves behind, and it has to be chewed: the brain registers that you ate.",
                es: "La fruta entera aporta la fibra que el zumo deja atrás, y se mastica: el cerebro registra que has comido."
            )
        ),
        FoodSwap(
            fromID: "riz-blanc", toID: "pomme-de-terre",
            fromGrams: 250, toGrams: 250, gain: .calories,
            reason: LocalizedText(
                fr: "À calories égales, la pomme de terre rassasie nettement plus longtemps. C'est l'aliment le mieux classé sur l'indice de satiété.",
                en: "Calorie for calorie, potato keeps you full much longer. It tops the satiety index.",
                es: "A igualdad de calorías, la patata sacia mucho más. Encabeza el índice de saciedad."
            )
        ),
        FoodSwap(
            fromID: "pain-blanc", toID: "pain-complet",
            fromGrams: 80, toGrams: 80, gain: .fibre,
            reason: LocalizedText(
                fr: "Presque le même nombre de calories, deux fois et demie plus de fibres.",
                en: "Almost the same calories, two and a half times the fibre.",
                es: "Casi las mismas calorías, dos veces y media más fibra."
            )
        ),
        FoodSwap(
            fromID: "charcuterie", toID: "blanc-de-poulet",
            fromGrams: 100, toGrams: 100, gain: .protein,
            reason: LocalizedText(
                fr: "Le double de protéines, le tiers des calories, et on sort de la seule catégorie d'aliments classée cancérogène avérée.",
                en: "Twice the protein, a third of the calories, and out of the one food category rated a proven carcinogen.",
                es: "El doble de proteína, un tercio de las calorías, y fuera de la única categoría de alimentos clasificada como cancerígeno probado."
            )
        ),
        FoodSwap(
            fromID: "chips", toID: "edamame",
            fromGrams: 50, toGrams: 100, gain: .calories,
            reason: LocalizedText(
                fr: "Même geste, même croquant, mais des protéines et des fibres au lieu de gras et de sel.",
                en: "Same gesture, same crunch, but protein and fibre instead of fat and salt.",
                es: "El mismo gesto, el mismo crujido, pero proteína y fibra en lugar de grasa y sal."
            )
        ),
        FoodSwap(
            fromID: "viennoiserie", toID: "flocons-avoine",
            fromGrams: 60, toGrams: 60, gain: .fibre,
            reason: LocalizedText(
                fr: "Le petit-déjeuner qui tient jusqu'à midi, au lieu de celui qui rappelle la faim à onze heures.",
                en: "The breakfast that lasts until noon, instead of the one that brings hunger back at eleven.",
                es: "El desayuno que aguanta hasta el mediodía, en vez del que trae el hambre de vuelta a las once."
            )
        ),
        FoodSwap(
            fromID: "beurre", toID: "huile-olive",
            fromGrams: 15, toGrams: 10, gain: .quality,
            reason: LocalizedText(
                fr: "Une cuillère d'huile ne pèse pas moins lourd qu'une noix de beurre : ce qui change, ce sont les acides gras insaturés à la place des saturés. C'est le seul changement de gras qui a des preuves solides derrière lui, et il ne se joue pas sur les calories.",
                en: "A spoon of oil is no lighter than a knob of butter: what changes is unsaturated fat in place of saturated. It is the one fat swap with solid evidence behind it, and it is not about calories.",
                es: "Una cucharada de aceite no pesa menos que una nuez de mantequilla: lo que cambia es la grasa insaturada en lugar de la saturada. Es el único cambio de grasa con pruebas sólidas detrás, y no va de calorías."
            )
        ),
        FoodSwap(
            fromID: "soda", toID: "eau",
            fromGrams: 330, toGrams: 330, gain: .calories,
            reason: LocalizedText(
                fr: "L'échange le plus simple de toute la liste : environ 140 kcal par canette, que le corps ne déduira pas du repas suivant.",
                en: "The simplest swap on the list: about 140 kcal a can, which the body will not deduct from your next meal.",
                es: "El cambio más simple de la lista: unas 140 kcal por lata que el cuerpo no descontará de la comida siguiente."
            )
        ),
        FoodSwap(
            fromID: "biscuits", toID: "chocolat-noir",
            fromGrams: 30, toGrams: 20, gain: .calories,
            reason: LocalizedText(
                fr: "Le plaisir reste, mais deux carrés suffisent là où le paquet ne s'arrête jamais.",
                en: "The pleasure stays, but two squares are enough where the packet never stops.",
                es: "El placer se queda, pero dos onzas bastan donde el paquete no se detiene nunca."
            )
        ),
        FoodSwap(
            fromID: "glace", toID: "skyr",
            fromGrams: 150, toGrams: 150, gain: .calories,
            reason: LocalizedText(
                fr: "Avec des fruits rouges surgelés et deux carrés de chocolat râpés, c'est un dessert — avec 20 g de protéines dedans.",
                en: "With frozen berries and two squares of grated chocolate it is a dessert — with 20 g of protein in it.",
                es: "Con frutos rojos congelados y dos onzas de chocolate rallado es un postre, con 20 g de proteína dentro."
            )
        ),
    ]

    /// Les échanges qui concernent vraiment cet athlète.
    public static func swaps(for diet: DietPreference) -> [FoodSwap] {
        swaps.filter { swap in
            guard let to = swap.to else { return false }
            // On ne propose que des remplacements que l'athlète peut manger.
            // L'aliment remplacé, lui, peut très bien ne pas coller à son
            // régime : c'est justement pour ça qu'on le remplace.
            return to.suits(diet)
        }
    }
}
