import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Matières grasses et oléagineux.
extension FoodCatalog {
    static let moreFats: [Food] = [
        Food(
            id: "noisettes",
            name: LocalizedText(fr: "Noisettes", en: "Hazelnuts", es: "Avellanas"),
            role: .fat, tier: .moderate,
            kcal: 628, proteinG: 15, carbsG: 17, fatG: 61, fiberG: 9.7,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La vitamine E des amandes avec plus de gras mono-insaturés — même règle : la poignée se compte.",
                en: "Almond's vitamin E with more monounsaturated fat — same rule: the handful gets counted.",
                es: "La vitamina E de las almendras con más grasa monoinsaturada; misma regla: el puñado se cuenta."
            )
        ),
        Food(
            id: "cajou",
            name: LocalizedText(fr: "Noix de cajou", en: "Cashews", es: "Anacardos"),
            role: .fat, tier: .moderate,
            kcal: 553, proteinG: 18, carbsG: 30, fatG: 44, fiberG: 3.3,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les moins grasses des noix et les plus riches en glucides — d'où leur douceur, et leur facilité à disparaître.",
                en: "The least fatty of the nuts and the richest in carbs — hence their sweetness, and how fast they vanish.",
                es: "Los menos grasos de los frutos secos y los más ricos en carbohidratos: de ahí su dulzor, y lo rápido que desaparecen."
            )
        ),
        Food(
            id: "pistaches",
            name: LocalizedText(fr: "Pistaches", en: "Pistachios", es: "Pistachos"),
            role: .fat, tier: .moderate,
            kcal: 560, proteinG: 20, carbsG: 28, fatG: 45, fiberG: 10.6,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les plus protéinées du bocal, et la coque impose un rythme qui laisse la satiété parler.",
                en: "The most protein-rich in the jar, and the shell sets a pace that lets fullness speak.",
                es: "Los más proteicos del bote, y la cáscara impone un ritmo que deja hablar a la saciedad."
            )
        ),
        Food(
            id: "cacahuetes",
            name: LocalizedText(fr: "Cacahuètes non salées", en: "Unsalted peanuts", es: "Cacahuetes sin sal"),
            role: .fat, tier: .moderate,
            kcal: 567, proteinG: 26, carbsG: 16, fatG: 49, fiberG: 8.5,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Autant de protéines que bien des viandes au gramme — mais neuf fois plus de calories que le blanc de poulet.",
                en: "As much protein per gram as many meats — but nine times the calories of chicken breast.",
                es: "Tanta proteína por gramo como muchas carnes, pero nueve veces las calorías de la pechuga."
            )
        ),
        Food(
            id: "noix-bresil",
            name: LocalizedText(fr: "Noix du Brésil", en: "Brazil nuts", es: "Nueces de Brasil"),
            role: .fat, tier: .moderate,
            kcal: 659, proteinG: 14, carbsG: 12, fatG: 67, fiberG: 7.5,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Deux noix couvrent le sélénium du jour — au-delà de quatre par jour, il finit par être en excès.",
                en: "Two nuts cover the day's selenium — past four a day it eventually tips into excess.",
                es: "Dos nueces cubren el selenio del día; más de cuatro diarias acaban siendo un exceso."
            )
        ),
        Food(
            id: "noix-pecan",
            name: LocalizedText(fr: "Noix de pécan", en: "Pecans", es: "Nueces pecanas"),
            role: .fat, tier: .moderate,
            kcal: 691, proteinG: 9, carbsG: 14, fatG: 72, fiberG: 9.6,
            portionG: 25,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La plus grasse des noix courantes : le beurre du rayon oléagineux, à peser comme le beurre.",
                en: "The fattiest of the common nuts: the butter of the nut aisle, weighed like butter.",
                es: "El más graso de los frutos secos comunes: la mantequilla del estante, a pesar como la mantequilla."
            )
        ),
        Food(
            id: "puree-amande",
            name: LocalizedText(fr: "Purée d'amande", en: "Almond butter", es: "Crema de almendras"),
            role: .fat, tier: .moderate,
            kcal: 614, proteinG: 21, carbsG: 19, fatG: 53, fiberG: 10,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'amande en version tartinable : les mêmes qualités, sans le frein de la mastication — la cuillère se pèse.",
                en: "Almonds in spreadable form: the same virtues without the chewing brake — the spoon gets weighed.",
                es: "La almendra untable: las mismas virtudes sin el freno de masticar; la cucharada se pesa."
            )
        ),
        Food(
            id: "tahini",
            name: LocalizedText(fr: "Tahini (purée de sésame)", en: "Tahini", es: "Tahini"),
            role: .fat, tier: .moderate,
            kcal: 595, proteinG: 17, carbsG: 21, fatG: 54, fiberG: 9.3,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le calcium le plus dense du rayon végétal, et la base d'une sauce qui fait manger n'importe quel légume.",
                en: "The densest plant calcium on the shelf, and the base of a sauce that sells any vegetable.",
                es: "El calcio vegetal más denso del estante, y la base de una salsa que hace comer cualquier verdura."
            )
        ),
        Food(
            id: "graines-tournesol",
            name: LocalizedText(fr: "Graines de tournesol", en: "Sunflower seeds", es: "Pipas de girasol"),
            role: .fat, tier: .moderate,
            kcal: 584, proteinG: 21, carbsG: 20, fatG: 51, fiberG: 8.6,
            portionG: 25,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La vitamine E la moins chère du magasin, sur le yaourt ou la salade plutôt qu'à la volée.",
                en: "The cheapest vitamin E in the shop — on yoghurt or salad, not by the fistful.",
                es: "La vitamina E más barata de la tienda, sobre el yogur o la ensalada y no a puñados."
            )
        ),
        Food(
            id: "graines-sesame",
            name: LocalizedText(fr: "Graines de sésame", en: "Sesame seeds", es: "Semillas de sésamo"),
            role: .fat, tier: .moderate,
            kcal: 573, proteinG: 18, carbsG: 23, fatG: 50, fiberG: 11.8,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Une cuillère dorée à la poêle transforme un plat entier — calcium et croquant pour quinze grammes comptés.",
                en: "A pan-toasted spoonful transforms a whole dish — calcium and crunch for fifteen counted grams.",
                es: "Una cucharada dorada en la sartén transforma el plato: calcio y crujido por quince gramos contados."
            )
        ),
        Food(
            id: "olives",
            name: LocalizedText(fr: "Olives", en: "Olives", es: "Aceitunas"),
            role: .fat, tier: .base,
            kcal: 145, proteinG: 1, carbsG: 3.8, fatG: 15, fiberG: 3.3,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'huile d'olive encore dans son fruit, fibres comprises — l'apéritif le plus défendable du placard.",
                en: "Olive oil still inside its fruit, fibre included — the most defensible apéritif in the cupboard.",
                es: "El aceite de oliva aún en su fruto, fibra incluida: el aperitivo más defendible de la despensa."
            )
        ),
        Food(
            id: "huile-noix",
            name: LocalizedText(fr: "Huile de noix", en: "Walnut oil", es: "Aceite de nuez"),
            role: .fat, tier: .base,
            kcal: 900, proteinG: 0, carbsG: 0, fatG: 100, fiberG: 0,
            portionG: 10,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'oméga-3 végétal en assaisonnement — jamais à la poêle, la chaleur détruit précisément ce qu'on lui achète.",
                en: "Plant omega-3 as a dressing — never in the pan: heat destroys exactly what you bought it for.",
                es: "El omega-3 vegetal para aliñar; nunca a la sartén: el calor destruye justo lo que le compras."
            )
        ),
        Food(
            id: "huile-coco",
            name: LocalizedText(fr: "Huile de coco", en: "Coconut oil", es: "Aceite de coco"),
            role: .fat, tier: .occasional,
            kcal: 900, proteinG: 0, carbsG: 0, fatG: 100, fiberG: 0,
            portionG: 10,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus saturée que le beurre malgré sa réputation — la mode a couru plus vite que les données.",
                en: "More saturated than butter despite its reputation — the trend outran the data.",
                es: "Más saturado que la mantequilla pese a su fama: la moda corrió más que los datos."
            )
        ),
        Food(
            id: "creme-fraiche",
            name: LocalizedText(fr: "Crème fraîche (30 %)", en: "Crème fraîche (30 %)", es: "Nata fresca (30 %)"),
            role: .fat, tier: .moderate,
            kcal: 292, proteinG: 2.4, carbsG: 3, fatG: 30, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Une cuillère à soupe vaut une noix de beurre : le moelleux des sauces, au gramme près.",
                en: "One tablespoon equals a knob of butter: sauce silkiness, by the counted gram.",
                es: "Una cucharada vale un trozo de mantequilla: la cremosidad de las salsas, gramo a gramo."
            )
        ),
        Food(
            id: "creme-legere",
            name: LocalizedText(fr: "Crème légère (15 %)", en: "Light cream (15 %)", es: "Nata ligera (15 %)"),
            role: .fat, tier: .base,
            kcal: 162, proteinG: 2.6, carbsG: 4, fatG: 15, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La moitié des calories de l'entière pour le même geste en cuisine — l'allègement qui ne se goûte pas.",
                en: "Half the calories of full cream for the same kitchen move — the lightening you cannot taste.",
                es: "La mitad de calorías que la entera para el mismo gesto en cocina: el aligerado que no se nota."
            )
        ),
        Food(
            id: "coco-rape",
            name: LocalizedText(fr: "Noix de coco râpée", en: "Desiccated coconut", es: "Coco rallado"),
            role: .fat, tier: .moderate,
            kcal: 660, proteinG: 6.9, carbsG: 24, fatG: 65, fiberG: 16.3,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Des fibres records, mais du gras saturé aux deux tiers : la pincée qui parfume, pas la poignée.",
                en: "Record fibre, but two-thirds saturated fat: the pinch that flavours, not the handful.",
                es: "Fibra récord, pero dos tercios de grasa saturada: la pizca que aromatiza, no el puñado."
            )
        ),
    ]
}
