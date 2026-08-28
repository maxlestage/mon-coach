import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Viandes et volailles.
extension FoodCatalog {
    static let moreMeats: [Food] = [
        Food(
            id: "cuisse-de-poulet",
            name: LocalizedText(fr: "Cuisse de poulet (sans peau)", en: "Chicken thigh (skinless)", es: "Muslo de pollo (sin piel)"),
            role: .protein, tier: .base,
            kcal: 179, proteinG: 24, carbsG: 0, fatG: 8.7, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus grasse que le blanc mais bien plus tendre : celle qu'on finit vraiment quand le blanc lasse.",
                en: "Fattier than breast but far more tender: the one you actually finish when breast gets old.",
                es: "Más graso que la pechuga pero mucho más tierno: el que de verdad te terminas cuando la pechuga cansa."
            )
        ),
        Food(
            id: "poulet-roti",
            name: LocalizedText(fr: "Poulet rôti (avec peau)", en: "Roast chicken (with skin)", es: "Pollo asado (con piel)"),
            role: .protein, tier: .moderate,
            kcal: 239, proteinG: 27, carbsG: 0, fatG: 14, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La peau double presque les lipides du blanc. Un très bon plat — qui se pèse, lui.",
                en: "The skin nearly doubles the fat of plain breast. A fine meal — one you weigh.",
                es: "La piel casi duplica la grasa de la pechuga. Un buen plato, pero de los que se pesan."
            )
        ),
        Food(
            id: "lapin",
            name: LocalizedText(fr: "Lapin", en: "Rabbit", es: "Conejo"),
            role: .protein, tier: .base,
            kcal: 173, proteinG: 29, carbsG: 0, fatG: 5.5, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Aussi maigre que la dinde, plus riche en vitamine B3, et injustement oublié.",
                en: "As lean as turkey, richer in niacin, and unfairly forgotten.",
                es: "Tan magro como el pavo, más rico en niacina e injustamente olvidado."
            )
        ),
        Food(
            id: "veau-escalope",
            name: LocalizedText(fr: "Escalope de veau", en: "Veal escalope", es: "Escalope de ternera lechal"),
            role: .protein, tier: .base,
            kcal: 172, proteinG: 31, carbsG: 0, fatG: 4.7, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le profil du blanc de poulet, avec le fer d'une viande rouge claire.",
                en: "The profile of chicken breast, with the iron of a light red meat.",
                es: "El perfil de la pechuga de pollo, con el hierro de una carne roja clara."
            )
        ),
        Food(
            id: "boeuf-15",
            name: LocalizedText(fr: "Bœuf haché 15 %", en: "Beef mince 15 %", es: "Carne picada de ternera 15 %"),
            role: .protein, tier: .moderate,
            kcal: 250, proteinG: 24, carbsG: 0, fatG: 17, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Cent kilocalories de plus que le 5 % pour la même portion : le pourcentage sur la barquette est la seule chose à lire.",
                en: "A hundred more kilocalories than the 5 % for the same portion: the percentage on the tray is the only thing to read.",
                es: "Cien kilocalorías más que el 5 % por la misma ración: el porcentaje de la bandeja es lo único que hay que leer."
            )
        ),
        Food(
            id: "rosbif",
            name: LocalizedText(fr: "Rosbif", en: "Roast beef", es: "Rosbif"),
            role: .protein, tier: .base,
            kcal: 160, proteinG: 28, carbsG: 0, fatG: 5, fiberG: 0,
            portionG: 130,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Du bœuf maigre qui se tranche froid : la protéine des déjeuners pressés.",
                en: "Lean beef that slices cold: the protein of hurried lunches.",
                es: "Ternera magra que se corta en frío: la proteína de los almuerzos con prisa."
            )
        ),
        Food(
            id: "agneau-gigot",
            name: LocalizedText(fr: "Gigot d'agneau", en: "Leg of lamb", es: "Pierna de cordero"),
            role: .protein, tier: .moderate,
            kcal: 230, proteinG: 26, carbsG: 0, fatG: 14, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Riche en zinc et en fer, mais deux fois plus gras que la volaille maigre : un plat du dimanche, pas du mardi.",
                en: "Rich in zinc and iron, but twice the fat of lean poultry: a Sunday dish, not a Tuesday one.",
                es: "Rico en zinc y hierro, pero con el doble de grasa que el ave magra: plato de domingo, no de martes."
            )
        ),
        Food(
            id: "foie-de-volaille",
            name: LocalizedText(fr: "Foie de volaille", en: "Chicken liver", es: "Hígado de pollo"),
            role: .protein, tier: .base,
            kcal: 167, proteinG: 24, carbsG: 1, fatG: 6.5, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'aliment le plus dense en fer et en vitamine A du catalogue. Une fois par semaine suffit, et c'est déjà beaucoup.",
                en: "The most iron- and vitamin-A-dense food in this catalogue. Once a week is enough — and already a lot.",
                es: "El alimento más denso en hierro y vitamina A del catálogo. Una vez por semana basta, y ya es mucho."
            )
        ),
        Food(
            id: "porc-echine",
            name: LocalizedText(fr: "Échine de porc", en: "Pork shoulder", es: "Aguja de cerdo"),
            role: .protein, tier: .moderate,
            kcal: 236, proteinG: 25, carbsG: 0, fatG: 15, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "Le morceau moelleux du porc — deux fois plus gras que le filet, qui reste le choix des jours comptés.",
                en: "The tender cut of pork — twice the fat of the loin, which stays the pick on counted days.",
                es: "El corte tierno del cerdo: el doble de grasa que el lomo, que sigue siendo la opción los días contados."
            )
        ),
        Food(
            id: "jambon-blanc",
            name: LocalizedText(fr: "Jambon blanc découenné", en: "Lean cooked ham", es: "Jamón cocido sin corteza"),
            role: .protein, tier: .moderate,
            kcal: 115, proteinG: 20, carbsG: 1, fatG: 3.5, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "La charcuterie la plus maigre du rayon — mais du sel et des nitrites : dépanner, pas fonder.",
                en: "The leanest of the deli counter — but salt and nitrites: a stopgap, not a staple.",
                es: "El fiambre más magro del mostrador, pero con sal y nitritos: saca de un apuro, no es una base."
            )
        ),
        Food(
            id: "viande-des-grisons",
            name: LocalizedText(fr: "Viande des Grisons", en: "Air-dried beef", es: "Cecina"),
            role: .protein, tier: .moderate,
            kcal: 175, proteinG: 37, carbsG: 0.5, fatG: 2.5, fiberG: 0,
            portionG: 60,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "37 g de protéines aux 100 g, record du catalogue — payé au prix d'une salaison intense.",
                en: "37 g of protein per 100 g, the catalogue record — paid for with heavy curing salt.",
                es: "37 g de proteína por 100 g, récord del catálogo, pagados con una salazón intensa."
            )
        ),
        Food(
            id: "bacon",
            name: LocalizedText(fr: "Bacon", en: "Bacon", es: "Beicon"),
            role: .protein, tier: .occasional,
            kcal: 400, proteinG: 30, carbsG: 1, fatG: 30, fiberG: 0,
            portionG: 40,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "Les trois quarts des calories viennent du gras et du fumage-salage. Le goût d'accord, la base non.",
                en: "Three quarters of the calories come from fat, smoke and salt. Fine as a flavour, not as a base.",
                es: "Tres cuartos de las calorías vienen de la grasa y del ahumado con sal. Como sabor vale, como base no."
            )
        ),
        Food(
            id: "saucisse-toulouse",
            name: LocalizedText(fr: "Saucisse de Toulouse", en: "Fresh pork sausage", es: "Salchicha fresca"),
            role: .protein, tier: .occasional,
            kcal: 300, proteinG: 16, carbsG: 1, fatG: 26, fiberG: 0,
            portionG: 125,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "Deux fois plus de gras que de protéines : la protéine y est un passager, pas le conducteur.",
                en: "Twice as much fat as protein: the protein rides along, it does not drive.",
                es: "El doble de grasa que de proteína: la proteína va de pasajera, no conduce."
            )
        ),
        Food(
            id: "merguez",
            name: LocalizedText(fr: "Merguez", en: "Merguez sausage", es: "Merguez"),
            role: .protein, tier: .occasional,
            kcal: 280, proteinG: 15, carbsG: 2, fatG: 24, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le profil de la saucisse, version agneau-bœuf : un plaisir de barbecue qui compte comme tel.",
                en: "The sausage profile, lamb-and-beef edition: a barbecue treat that counts as one.",
                es: "El perfil de la salchicha en versión cordero-ternera: un capricho de barbacoa que cuenta como tal."
            )
        ),
    ]
}
