import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Boissons.
extension FoodCatalog {
    static let moreDrinks: [Food] = [
        Food(
            id: "boisson-amande",
            name: LocalizedText(fr: "Boisson à l'amande (sans sucres)", en: "Unsweetened almond drink", es: "Bebida de almendra (sin azúcar)"),
            role: .drink, tier: .base,
            kcal: 15, proteinG: 0.5, carbsG: 0.2, fatG: 1.2, fiberG: 0.3,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque de l'eau blanchie : très légère, mais sans les protéines du lait ni de la boisson soja.",
                en: "Nearly whitened water: very light, but without the protein of milk or soy drink.",
                es: "Casi agua blanqueada: ligerísima, pero sin la proteína de la leche ni de la bebida de soja."
            )
        ),
        Food(
            id: "boisson-avoine",
            name: LocalizedText(fr: "Boisson à l'avoine", en: "Oat drink", es: "Bebida de avena"),
            role: .drink, tier: .moderate,
            kcal: 46, proteinG: 0.8, carbsG: 7, fatG: 1.5, fiberG: 0.8,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "La plus douce des boissons végétales — parce que son amidon est déjà à moitié sucre.",
                en: "The sweetest of the plant drinks — because its starch is already half sugar.",
                es: "La más dulce de las bebidas vegetales, porque su almidón ya es medio azúcar."
            )
        ),
        Food(
            id: "kombucha",
            name: LocalizedText(fr: "Kombucha", en: "Kombucha", es: "Kombucha"),
            role: .drink, tier: .moderate,
            kcal: 20, proteinG: 0, carbsG: 4.8, fatG: 0, fiberG: 0,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un thé fermenté vivant, bien moins sucré qu'un soda — mais pas gratuit pour autant : l'étiquette varie du simple au triple.",
                en: "A living fermented tea, far less sweet than soda — but not free either: labels vary threefold.",
                es: "Un té fermentado vivo, mucho menos dulce que un refresco, pero no gratis: la etiqueta varía del simple al triple."
            )
        ),
        Food(
            id: "eau-gazeuse",
            name: LocalizedText(fr: "Eau gazeuse", en: "Sparkling water", es: "Agua con gas"),
            role: .drink, tier: .base,
            kcal: 0, proteinG: 0, carbsG: 0, fatG: 0, fiberG: 0,
            portionG: 330,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le soda sans le soda : les bulles occupent la place que le sucre réclamait.",
                en: "Soda without the soda: the bubbles fill the space the sugar was claiming.",
                es: "El refresco sin el refresco: las burbujas ocupan el sitio que pedía el azúcar."
            )
        ),
        Food(
            id: "soda-light",
            name: LocalizedText(fr: "Soda light", en: "Diet soda", es: "Refresco light"),
            role: .drink, tier: .moderate,
            kcal: 1, proteinG: 0, carbsG: 0.1, fatG: 0, fiberG: 0,
            portionG: 330,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Zéro calorie, vrai ; mais il entretient l'appel du très sucré — l'outil de transition, pas la destination.",
                en: "Zero calories, true; but it keeps the taste for intense sweetness alive — a transition tool, not the destination.",
                es: "Cero calorías, cierto; pero mantiene vivo el gusto por lo muy dulce: herramienta de transición, no destino."
            )
        ),
        Food(
            id: "the-noir",
            name: LocalizedText(fr: "Thé noir", en: "Black tea", es: "Té negro"),
            role: .drink, tier: .base,
            kcal: 1, proteinG: 0, carbsG: 0.2, fatG: 0, fiberG: 0,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La caféine du café en version douce et étalée — sans sucre, il ne compte simplement pas.",
                en: "Coffee's caffeine, gentler and slower — unsweetened, it simply doesn't count.",
                es: "La cafeína del café en versión suave y prolongada; sin azúcar, simplemente no cuenta."
            )
        ),
        Food(
            id: "chocolat-chaud",
            name: LocalizedText(fr: "Chocolat chaud", en: "Hot chocolate", es: "Chocolate caliente"),
            role: .drink, tier: .occasional,
            kcal: 77, proteinG: 3.2, carbsG: 10.5, fatG: 2.5, fiberG: 0.8,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un dessert qui se boit : la tasse du soir vaut deux carrés de chocolat noir — sans le croquant qui arrête.",
                en: "A drinkable dessert: the evening mug equals two squares of dark chocolate — without the snap that stops you.",
                es: "Un postre que se bebe: la taza de la noche vale dos onzas de chocolate negro, sin el crujido que frena."
            )
        ),
        Food(
            id: "vin-rouge",
            name: LocalizedText(fr: "Vin rouge", en: "Red wine", es: "Vino tinto"),
            role: .drink, tier: .occasional,
            kcal: 85, proteinG: 0.1, carbsG: 2.6, fatG: 0, fiberG: 0, alcoholG: 10.6,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le verre de 125 ml porte 85 kcal, presque toutes d'alcool — le polyphénol du raisin n'a jamais compensé l'éthanol.",
                en: "The 125 ml glass carries 85 kcal, nearly all of it alcohol — the grape's polyphenols never offset the ethanol.",
                es: "La copa de 125 ml lleva 85 kcal, casi todas de alcohol: los polifenoles de la uva nunca compensaron el etanol."
            )
        ),
        Food(
            id: "spiritueux",
            name: LocalizedText(fr: "Spiritueux (40°)", en: "Spirits (40 %)", es: "Licores (40°)"),
            role: .drink, tier: .occasional,
            kcal: 231, proteinG: 0, carbsG: 0.2, fatG: 0, fiberG: 0, alcoholG: 33,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le shot de 4 cl vaut 92 kcal d'alcool pur — et c'est le mélange soda qui double l'addition.",
                en: "A 4 cl shot is 92 kcal of pure alcohol — and it's the soda mixer that doubles the bill.",
                es: "El chupito de 4 cl son 92 kcal de alcohol puro, y es el refresco de la mezcla el que dobla la cuenta."
            )
        ),
    ]
}
