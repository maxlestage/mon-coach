import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Féculents, pesés cuits comme le reste du rayon.
extension FoodCatalog {
    static let moreGrains: [Food] = [
        Food(
            id: "boulgour",
            name: LocalizedText(fr: "Boulgour", en: "Bulgur", es: "Bulgur"),
            role: .carb, tier: .base,
            kcal: 118, proteinG: 4.3, carbsG: 22, fatG: 0.4, fiberG: 3.5,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Du blé précuit qui garde plus de fibres que la semoule — prêt en dix minutes, rassasiant plus longtemps.",
                en: "Pre-cooked wheat that keeps more fibre than couscous — ready in ten minutes, filling for longer.",
                es: "Trigo precocido que conserva más fibra que el cuscús: listo en diez minutos, sacia más tiempo."
            )
        ),
        Food(
            id: "semoule",
            name: LocalizedText(fr: "Semoule / couscous", en: "Couscous", es: "Cuscús"),
            role: .carb, tier: .base,
            kcal: 125, proteinG: 4, carbsG: 24, fatG: 0.3, fiberG: 2.2,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Le féculent le plus rapide de la cuisine : cinq minutes, zéro surveillance, et la graine porte les épices.",
                en: "The fastest starch in the kitchen: five minutes, zero watching, and the grain carries the spices.",
                es: "El farináceo más rápido de la cocina: cinco minutos, cero vigilancia, y el grano lleva las especias."
            )
        ),
        Food(
            id: "orge-perle",
            name: LocalizedText(fr: "Orge perlé", en: "Pearl barley", es: "Cebada perlada"),
            role: .carb, tier: .base,
            kcal: 123, proteinG: 2.3, carbsG: 26, fatG: 0.4, fiberG: 3.8,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Les bêta-glucanes de l'avoine dans un grain qui se cuisine comme un risotto.",
                en: "Oat's beta-glucans in a grain that cooks like a risotto.",
                es: "Los betaglucanos de la avena en un grano que se cocina como un risotto."
            )
        ),
        Food(
            id: "epeautre",
            name: LocalizedText(fr: "Épeautre", en: "Spelt", es: "Espelta"),
            role: .carb, tier: .base,
            kcal: 127, proteinG: 5.5, carbsG: 24, fatG: 0.8, fiberG: 3.9,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Le blé ancien : un peu plus de protéines que le riz complet, une mâche qui tient le couteau.",
                en: "The ancient wheat: a little more protein than brown rice, a chew that stands its ground.",
                es: "El trigo antiguo: algo más de proteína que el arroz integral y una textura con carácter."
            )
        ),
        Food(
            id: "millet",
            name: LocalizedText(fr: "Millet", en: "Millet", es: "Mijo"),
            role: .carb, tier: .base,
            kcal: 119, proteinG: 3.5, carbsG: 23, fatG: 1, fiberG: 1.3,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Sans gluten et doux au goût : le remplaçant du couscous quand le blé est exclu.",
                en: "Gluten-free and mild: the couscous stand-in when wheat is off the table.",
                es: "Sin gluten y suave: el sustituto del cuscús cuando el trigo queda fuera."
            )
        ),
        Food(
            id: "polenta",
            name: LocalizedText(fr: "Polenta", en: "Polenta", es: "Polenta"),
            role: .carb, tier: .base,
            kcal: 85, proteinG: 2, carbsG: 18, fatG: 0.4, fiberG: 1,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le maïs en purée dorée, sans gluten, et l'un des féculents les moins denses une fois cuit.",
                en: "Golden corn porridge, gluten-free, and one of the least dense starches once cooked.",
                es: "El maíz en crema dorada, sin gluten, y uno de los farináceos menos densos ya cocido."
            )
        ),
        Food(
            id: "riz-basmati",
            name: LocalizedText(fr: "Riz basmati", en: "Basmati rice", es: "Arroz basmati"),
            role: .carb, tier: .base,
            kcal: 121, proteinG: 3.5, carbsG: 25, fatG: 0.4, fiberG: 0.7,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le riz blanc à l'index glycémique le plus doux — le grain long fait une vraie différence.",
                en: "The white rice with the gentlest glycaemic index — the long grain genuinely matters.",
                es: "El arroz blanco de índice glucémico más suave: el grano largo marca una diferencia real."
            )
        ),
        Food(
            id: "vermicelles-riz",
            name: LocalizedText(fr: "Vermicelles de riz", en: "Rice noodles", es: "Fideos de arroz"),
            role: .carb, tier: .base,
            kcal: 109, proteinG: 1.8, carbsG: 25, fatG: 0.2, fiberG: 1,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les nouilles sans gluten des soupes et des sautés : cuites en trois minutes dans l'eau du bouillon.",
                en: "The gluten-free noodle for soups and stir-fries: done in three minutes in the broth itself.",
                es: "Los fideos sin gluten de sopas y salteados: listos en tres minutos en el propio caldo."
            )
        ),
        Food(
            id: "pates-blanches",
            name: LocalizedText(fr: "Pâtes blanches", en: "White pasta", es: "Pasta blanca"),
            role: .carb, tier: .base,
            kcal: 155, proteinG: 5.5, carbsG: 30, fatG: 0.9, fiberG: 1.8,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Moins de fibres que les complètes, mais al dente leur index reste modéré — le vrai écart est plus petit que sa réputation.",
                en: "Less fibre than wholewheat, but cooked al dente the index stays moderate — the real gap is smaller than its reputation.",
                es: "Menos fibra que la integral, pero al dente su índice sigue moderado: la diferencia real es menor que su fama."
            )
        ),
        Food(
            id: "gnocchis",
            name: LocalizedText(fr: "Gnocchis", en: "Gnocchi", es: "Ñoquis"),
            role: .carb, tier: .moderate,
            kcal: 160, proteinG: 4, carbsG: 32, fatG: 1, fiberG: 1.5,
            portionG: 180,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "De la pomme de terre densifiée à la farine : le même volume rassasie moins que la pomme de terre entière.",
                en: "Potato densified with flour: the same volume fills less than the whole potato would.",
                es: "Patata densificada con harina: el mismo volumen sacia menos que la patata entera."
            )
        ),
        Food(
            id: "pain-seigle",
            name: LocalizedText(fr: "Pain de seigle", en: "Rye bread", es: "Pan de centeno"),
            role: .carb, tier: .base,
            kcal: 250, proteinG: 8.5, carbsG: 45, fatG: 1.5, fiberG: 7,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Le pain le plus riche en fibres du rayon, et celui qui tient le plus longtemps au corps.",
                en: "The highest-fibre bread on the shelf, and the one that stays with you longest.",
                es: "El pan más rico en fibra del estante, y el que más tiempo acompaña."
            )
        ),
        Food(
            id: "pain-cereales",
            name: LocalizedText(fr: "Pain aux céréales", en: "Multigrain bread", es: "Pan multicereales"),
            role: .carb, tier: .base,
            kcal: 265, proteinG: 10, carbsG: 43, fatG: 4.5, fiberG: 6,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Les graines ajoutent des fibres et un peu de gras utile — vérifie juste que « céréales » ne veut pas dire « décor ».",
                en: "The seeds add fibre and some useful fat — just check that “multigrain” doesn't mean “decoration”.",
                es: "Las semillas añaden fibra y algo de grasa útil; comprueba solo que «multicereales» no signifique «decoración»."
            )
        ),
        Food(
            id: "wrap-ble",
            name: LocalizedText(fr: "Wrap de blé", en: "Wheat wrap", es: "Tortilla de trigo"),
            role: .carb, tier: .moderate,
            kcal: 300, proteinG: 8, carbsG: 50, fatG: 7, fiberG: 3,
            portionG: 60,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Plus dense que le pain à poids égal, et le moelleux vient d'huiles ajoutées : deux wraps valent une demi-baguette.",
                en: "Denser than bread gram for gram, and the softness comes from added oils: two wraps equal half a baguette.",
                es: "Más densa que el pan a igual peso, y lo tierno viene de aceites añadidos: dos tortillas valen media barra."
            )
        ),
        Food(
            id: "muesli-nature",
            name: LocalizedText(fr: "Muesli sans sucre ajouté", en: "No-added-sugar muesli", es: "Muesli sin azúcar añadido"),
            role: .carb, tier: .base,
            kcal: 360, proteinG: 10, carbsG: 60, fatG: 7, fiberG: 8,
            portionG: 60,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Avoine, fruits secs et graines, rien d'enrobé : le granola sans la friture au sirop.",
                en: "Oats, dried fruit and seeds, nothing coated: granola without the syrup fry-up.",
                es: "Avena, fruta seca y semillas, nada recubierto: la granola sin la fritura de sirope."
            )
        ),
        Food(
            id: "granola",
            name: LocalizedText(fr: "Granola", en: "Granola", es: "Granola"),
            role: .carb, tier: .moderate,
            kcal: 450, proteinG: 8, carbsG: 55, fatG: 20, fiberG: 6,
            portionG: 50,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Du muesli cuit dans le sucre et l'huile : croustillant payé 90 kcal de plus les 100 g.",
                en: "Muesli baked in sugar and oil: the crunch costs 90 kcal more per 100 g.",
                es: "Muesli horneado en azúcar y aceite: el crujiente cuesta 90 kcal más por 100 g."
            )
        ),
        Food(
            id: "cereales-mais",
            name: LocalizedText(fr: "Céréales de maïs (corn flakes)", en: "Corn flakes", es: "Copos de maíz"),
            role: .carb, tier: .moderate,
            kcal: 380, proteinG: 7, carbsG: 84, fatG: 0.9, fiberG: 3,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque de l'amidon pur, digéré à la vitesse du sucre : le bol du matin qui a faim à dix heures.",
                en: "Nearly pure starch, digested at sugar speed: the breakfast bowl that is hungry again by ten.",
                es: "Casi almidón puro, digerido a velocidad de azúcar: el bol de la mañana que vuelve a tener hambre a las diez."
            )
        ),
        Food(
            id: "petits-pois",
            name: LocalizedText(fr: "Petits pois", en: "Green peas", es: "Guisantes"),
            role: .carb, tier: .base,
            kcal: 81, proteinG: 5.4, carbsG: 14, fatG: 0.4, fiberG: 5.7,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "À mi-chemin entre légume et féculent, avec les protéines des deux réunies.",
                en: "Halfway between vegetable and starch, with the protein of both combined.",
                es: "A medio camino entre verdura y farináceo, con la proteína de ambos."
            )
        ),
        Food(
            id: "mais-doux",
            name: LocalizedText(fr: "Maïs doux", en: "Sweetcorn", es: "Maíz dulce"),
            role: .carb, tier: .base,
            kcal: 96, proteinG: 3.4, carbsG: 19, fatG: 1.5, fiberG: 2.7,
            portionG: 140,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le féculent qui se prend pour un légume : parfait en salade, tant qu'il est compté comme féculent.",
                en: "The starch that thinks it's a vegetable: perfect in salads, as long as it's counted as starch.",
                es: "El farináceo que se cree verdura: perfecto en ensalada, siempre que se cuente como farináceo."
            )
        ),
    ]
}
