import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Laitages et œufs.
extension FoodCatalog {
    static let moreDairy: [Food] = [
        Food(
            id: "yaourt-grec",
            name: LocalizedText(fr: "Yaourt grec nature", en: "Plain Greek yoghurt", es: "Yogur griego natural"),
            role: .dairy, tier: .moderate,
            kcal: 121, proteinG: 6.4, carbsG: 4, fatG: 9, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Deux fois plus gras que le skyr pour moitié moins de protéines : la douceur se paie, le skyr reste l'outil.",
                en: "Twice the fat of skyr for half the protein: the creaminess has a price — skyr stays the tool.",
                es: "El doble de grasa que el skyr con la mitad de proteína: la cremosidad se paga, el skyr sigue siendo la herramienta."
            )
        ),
        Food(
            id: "yaourt-nature",
            name: LocalizedText(fr: "Yaourt nature", en: "Plain yoghurt", es: "Yogur natural"),
            role: .dairy, tier: .base,
            kcal: 61, proteinG: 4, carbsG: 5, fatG: 3, fiberG: 0,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le dessert par défaut qui ne coûte presque rien au total de la journée.",
                en: "The default dessert that costs the day's total almost nothing.",
                es: "El postre por defecto que apenas cuesta nada al total del día."
            )
        ),
        Food(
            id: "petit-suisse",
            name: LocalizedText(fr: "Petit-suisse (3 %)", en: "Petit-suisse fresh cheese", es: "Petit-suisse"),
            role: .dairy, tier: .base,
            kcal: 87, proteinG: 9.3, carbsG: 3.5, fatG: 3.6, fiberG: 0,
            portionG: 120,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fromage blanc en format qui se finit : la protéine d'un dessert, la taille d'un goûter.",
                en: "Fromage blanc in a format you finish: a dessert's protein, a snack's size.",
                es: "El queso fresco en formato que se termina: la proteína de un postre, el tamaño de una merienda."
            )
        ),
        Food(
            id: "kefir-lait",
            name: LocalizedText(fr: "Kéfir de lait", en: "Milk kefir", es: "Kéfir de leche"),
            role: .drink, tier: .base,
            kcal: 55, proteinG: 3.4, carbsG: 4.5, fatG: 2.5, fiberG: 0,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un lait fermenté vivant : les macros du lait demi-écrémé, les ferments en plus.",
                en: "A living fermented milk: semi-skimmed macros with live cultures on top.",
                es: "Una leche fermentada viva: las macros de la semidesnatada con fermentos de regalo."
            )
        ),
        Food(
            id: "mozzarella",
            name: LocalizedText(fr: "Mozzarella", en: "Mozzarella", es: "Mozzarella"),
            role: .dairy, tier: .moderate,
            kcal: 280, proteinG: 18, carbsG: 2, fatG: 22, fiberG: 0,
            portionG: 60,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus légère que la plupart des fromages affinés, mais une boule entière vaut un repas en calories.",
                en: "Lighter than most aged cheeses, but a whole ball is a meal's worth of calories.",
                es: "Más ligera que la mayoría de quesos curados, pero una bola entera vale un almuerzo en calorías."
            )
        ),
        Food(
            id: "ricotta",
            name: LocalizedText(fr: "Ricotta", en: "Ricotta", es: "Ricotta"),
            role: .dairy, tier: .base,
            kcal: 150, proteinG: 9, carbsG: 4, fatG: 11, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le plus léger des fromages crémeux : là où le mascarpone triple la note, la ricotta la garde tenable.",
                en: "The lightest of the creamy cheeses: where mascarpone triples the bill, ricotta keeps it payable.",
                es: "El más ligero de los quesos cremosos: donde el mascarpone triplica la cuenta, la ricotta la deja pagable."
            )
        ),
        Food(
            id: "parmesan",
            name: LocalizedText(fr: "Parmesan", en: "Parmesan", es: "Parmesano"),
            role: .dairy, tier: .moderate,
            kcal: 392, proteinG: 33, carbsG: 3.2, fatG: 28, fiberG: 0,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le plus protéiné des fromages, et tellement dense en goût que vingt grammes suffisent — c'est toute sa ruse.",
                en: "The most protein-rich of cheeses, and so intense that twenty grams is plenty — that is its whole trick.",
                es: "El queso más proteico, y tan intenso que con veinte gramos basta: ese es todo su truco."
            )
        ),
        Food(
            id: "emmental",
            name: LocalizedText(fr: "Emmental", en: "Emmental", es: "Emmental"),
            role: .dairy, tier: .moderate,
            kcal: 380, proteinG: 28, carbsG: 0.5, fatG: 29, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fromage du quotidien : correct en protéines, dense en calories — le râpé disparaît plus vite qu'on ne le compte.",
                en: "The everyday cheese: decent protein, dense calories — grated, it vanishes faster than you count it.",
                es: "El queso de diario: correcto en proteína, denso en calorías; rallado desaparece más rápido de lo que se cuenta."
            )
        ),
        Food(
            id: "chevre-buche",
            name: LocalizedText(fr: "Chèvre (bûche)", en: "Goat's cheese log", es: "Rulo de cabra"),
            role: .dairy, tier: .moderate,
            kcal: 290, proteinG: 20, carbsG: 2.5, fatG: 22, fiberG: 0,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Souvent mieux toléré que la vache, tout aussi calorique : le régime change, la densité non.",
                en: "Often better tolerated than cow's milk, just as caloric: the tolerance changes, the density doesn't.",
                es: "A menudo mejor tolerado que la vaca e igual de calórico: cambia la tolerancia, no la densidad."
            )
        ),
        Food(
            id: "caseine",
            name: LocalizedText(fr: "Caséine (poudre)", en: "Casein powder", es: "Caseína en polvo"),
            role: .protein, tier: .moderate,
            kcal: 370, proteinG: 78, carbsG: 8, fatG: 1.5, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La whey lente : trois heures de diffusion, la dose du soir quand le dîner a manqué de protéines.",
                en: "Slow whey: three hours of release, the evening scoop when dinner ran short of protein.",
                es: "La whey lenta: tres horas de liberación, el cazo nocturno cuando la cena se quedó corta de proteína."
            )
        ),
    ]
}
