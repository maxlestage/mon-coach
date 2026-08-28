import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Protéines végétales.
extension FoodCatalog {
    static let morePlantProteins: [Food] = [
        Food(
            id: "haricots-rouges",
            name: LocalizedText(fr: "Haricots rouges", en: "Kidney beans", es: "Alubias rojas"),
            role: .protein, tier: .base,
            kcal: 127, proteinG: 8.7, carbsG: 16, fatG: 0.5, fiberG: 6.4,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le trio protéines-fibres-fer des légumineuses, dans la variété qui tient le mieux le chili.",
                en: "The legume protein-fibre-iron trio, in the variety that holds a chili best.",
                es: "El trío proteína-fibra-hierro de las legumbres, en la variedad que mejor aguanta un chili."
            )
        ),
        Food(
            id: "haricots-blancs",
            name: LocalizedText(fr: "Haricots blancs", en: "White beans", es: "Alubias blancas"),
            role: .protein, tier: .base,
            kcal: 115, proteinG: 8, carbsG: 15, fatG: 0.6, fiberG: 6.3,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les mêmes armes que les rouges, la peau plus fine : ceux par lesquels commencer si les légumineuses te pèsent.",
                en: "The same weapons as red beans with a thinner skin: the ones to start with if legumes sit heavy.",
                es: "Las mismas armas que las rojas con la piel más fina: por las que empezar si las legumbres te pesan."
            )
        ),
        Food(
            id: "pois-casses",
            name: LocalizedText(fr: "Pois cassés", en: "Split peas", es: "Guisantes partidos"),
            role: .protein, tier: .base,
            kcal: 116, proteinG: 8.3, carbsG: 15.5, fatG: 0.4, fiberG: 8.3,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus de fibres que n'importe quel autre plat de ce rayon, et pas de trempage : la légumineuse des soirs pressés.",
                en: "More fibre than anything else on this shelf, and no soaking: the weeknight legume.",
                es: "Más fibra que nada en este estante y sin remojo: la legumbre de las noches con prisa."
            )
        ),
        Food(
            id: "feves",
            name: LocalizedText(fr: "Fèves", en: "Broad beans", es: "Habas"),
            role: .protein, tier: .base,
            kcal: 88, proteinG: 7.6, carbsG: 10, fatG: 0.4, fiberG: 5.4,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La légumineuse la plus légère du rayon : des protéines et des fibres pour le prix calorique d'un légume.",
                en: "The lightest legume on the shelf: protein and fibre at a vegetable's caloric price.",
                es: "La legumbre más ligera del estante: proteína y fibra al precio calórico de una verdura."
            )
        ),
        Food(
            id: "tofu-fume",
            name: LocalizedText(fr: "Tofu fumé", en: "Smoked tofu", es: "Tofu ahumado"),
            role: .protein, tier: .base,
            kcal: 150, proteinG: 16, carbsG: 1.5, fatG: 9, fiberG: 1.5,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le tofu qui a déjà du goût en sortant du paquet — la porte d'entrée honnête vers le nature.",
                en: "The tofu that tastes of something straight from the pack — the honest gateway to plain.",
                es: "El tofu que ya sabe a algo al salir del paquete: la puerta de entrada honesta al natural."
            )
        ),
        Food(
            id: "houmous",
            name: LocalizedText(fr: "Houmous", en: "Hummus", es: "Hummus"),
            role: .fat, tier: .moderate,
            kcal: 250, proteinG: 7, carbsG: 12, fatG: 18, fiberG: 5,
            portionG: 50,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Des pois chiches, oui — noyés dans le tahini et l'huile : c'est une matière grasse qui a bonne réputation.",
                en: "Chickpeas, yes — drowned in tahini and oil: it is a fat with a good reputation.",
                es: "Garbanzos, sí, ahogados en tahini y aceite: es una grasa con buena reputación."
            )
        ),
        Food(
            id: "falafel",
            name: LocalizedText(fr: "Falafels", en: "Falafel", es: "Faláfel"),
            role: .protein, tier: .moderate,
            kcal: 330, proteinG: 13, carbsG: 30, fatG: 17, fiberG: 5,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Des pois chiches passés par la friture : la moitié des calories vient de l'huile du bain.",
                en: "Chickpeas that went through the fryer: half the calories come from the oil bath.",
                es: "Garbanzos pasados por la freidora: la mitad de las calorías viene del baño de aceite."
            )
        ),
    ]
}
