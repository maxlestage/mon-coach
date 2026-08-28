import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Fruits, frais et séchés.
extension FoodCatalog {
    static let moreFruits: [Food] = [
        Food(
            id: "poire",
            name: LocalizedText(fr: "Poire", en: "Pear", es: "Pera"),
            role: .fruit, tier: .base,
            kcal: 57, proteinG: 0.4, carbsG: 15, fatG: 0.1, fiberG: 3.1,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus de fibres que la pomme, dont l'essentiel dans la peau : elle se mange en entier.",
                en: "More fibre than an apple, most of it in the skin: eat it whole.",
                es: "Más fibra que la manzana, y casi toda en la piel: se come entera."
            )
        ),
        Food(
            id: "peche",
            name: LocalizedText(fr: "Pêche", en: "Peach", es: "Melocotón"),
            role: .fruit, tier: .base,
            kcal: 39, proteinG: 0.9, carbsG: 9.5, fatG: 0.3, fiberG: 1.5,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit d'été le plus léger après la pastèque — deux pêches valent une banane.",
                en: "The lightest summer fruit after watermelon — two peaches equal one banana.",
                es: "La fruta de verano más ligera tras la sandía: dos melocotones valen un plátano."
            )
        ),
        Food(
            id: "abricot",
            name: LocalizedText(fr: "Abricots", en: "Apricots", es: "Albaricoques"),
            role: .fruit, tier: .base,
            kcal: 48, proteinG: 1.4, carbsG: 11, fatG: 0.4, fiberG: 2,
            portionG: 120,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Trois abricots, une dose de bêta-carotène, cinquante kilocalories : l'en-cas d'été réglé.",
                en: "Three apricots, a dose of beta-carotene, fifty kilocalories: the summer snack, solved.",
                es: "Tres albaricoques, una dosis de betacaroteno, cincuenta kilocalorías: la merienda de verano resuelta."
            )
        ),
        Food(
            id: "prune",
            name: LocalizedText(fr: "Prunes", en: "Plums", es: "Ciruelas"),
            role: .fruit, tier: .base,
            kcal: 46, proteinG: 0.7, carbsG: 11.4, fatG: 0.3, fiberG: 1.4,
            portionG: 120,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les polyphénols sombres de la peau, et un transit que les pruneaux n'ont pas attendu pour aider.",
                en: "The dark polyphenols of the skin, and a transit the dried version never had a monopoly on helping.",
                es: "Los polifenoles oscuros de la piel, y un tránsito al que ya ayudan sin esperar a ser pasas."
            )
        ),
        Food(
            id: "cerises",
            name: LocalizedText(fr: "Cerises", en: "Cherries", es: "Cerezas"),
            role: .fruit, tier: .base,
            kcal: 63, proteinG: 1.1, carbsG: 16, fatG: 0.2, fiberG: 2.1,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les anthocyanes qui apaisent l'inflammation post-séance — le jus de cerise acide est un classique de la récupération.",
                en: "The anthocyanins that calm post-session inflammation — tart cherry juice is a recovery classic.",
                es: "Los antocianos que calman la inflamación tras la sesión: el zumo de cereza ácida es un clásico de la recuperación."
            )
        ),
        Food(
            id: "framboises",
            name: LocalizedText(fr: "Framboises", en: "Raspberries", es: "Frambuesas"),
            role: .fruit, tier: .base,
            kcal: 52, proteinG: 1.2, carbsG: 12, fatG: 0.7, fiberG: 6.5,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "6,5 g de fibres aux 100 g : le record du rayon fruits, à égalité avec bien des légumes secs.",
                en: "6.5 g of fibre per 100 g: the fruit-shelf record, level with many a dried legume.",
                es: "6,5 g de fibra por 100 g: el récord de la frutería, a la altura de muchas legumbres."
            )
        ),
        Food(
            id: "mures",
            name: LocalizedText(fr: "Mûres", en: "Blackberries", es: "Moras"),
            role: .fruit, tier: .base,
            kcal: 43, proteinG: 1.4, carbsG: 10, fatG: 0.5, fiberG: 5.3,
            portionG: 125,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque autant de fibres que la framboise, et gratuites au bord des chemins d'août.",
                en: "Nearly raspberry-level fibre, and free along the paths of August.",
                es: "Casi tanta fibra como la frambuesa, y gratis en los caminos de agosto."
            )
        ),
        Food(
            id: "cassis",
            name: LocalizedText(fr: "Cassis", en: "Blackcurrants", es: "Grosellas negras"),
            role: .fruit, tier: .base,
            kcal: 63, proteinG: 1.4, carbsG: 15, fatG: 0.4, fiberG: 4.3,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Quatre fois la vitamine C de l'orange, dans une baie que personne ne pense à compter.",
                en: "Four times the vitamin C of an orange, in a berry nobody thinks to count.",
                es: "Cuatro veces la vitamina C de la naranja, en una baya que nadie piensa en contar."
            )
        ),
        Food(
            id: "mangue",
            name: LocalizedText(fr: "Mangue", en: "Mango", es: "Mango"),
            role: .fruit, tier: .base,
            kcal: 60, proteinG: 0.8, carbsG: 15, fatG: 0.4, fiberG: 1.6,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus sucrée que la pomme mais pleine de bêta-carotène — un dessert qui se suffit.",
                en: "Sweeter than an apple but full of beta-carotene — a dessert that needs nothing else.",
                es: "Más dulce que la manzana pero llena de betacaroteno: un postre que se basta solo."
            )
        ),
        Food(
            id: "ananas",
            name: LocalizedText(fr: "Ananas", en: "Pineapple", es: "Piña"),
            role: .fruit, tier: .base,
            kcal: 50, proteinG: 0.5, carbsG: 13, fatG: 0.1, fiberG: 1.4,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'acidité qui réveille un fromage blanc — et sa broméline attendrit même la viande.",
                en: "The sharpness that wakes up fromage blanc — and its bromelain even tenderises meat.",
                es: "La acidez que despierta un queso fresco, y su bromelina hasta ablanda la carne."
            )
        ),
        Food(
            id: "pasteque",
            name: LocalizedText(fr: "Pastèque", en: "Watermelon", es: "Sandía"),
            role: .fruit, tier: .base,
            kcal: 30, proteinG: 0.6, carbsG: 7.5, fatG: 0.2, fiberG: 0.4,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit le plus léger du rayon : une part généreuse coûte moins qu'un biscuit.",
                en: "The lightest fruit on the shelf: a generous slice costs less than one biscuit.",
                es: "La fruta más ligera del estante: una tajada generosa cuesta menos que una galleta."
            )
        ),
        Food(
            id: "melon",
            name: LocalizedText(fr: "Melon", en: "Cantaloupe melon", es: "Melón cantalupo"),
            role: .fruit, tier: .base,
            kcal: 34, proteinG: 0.8, carbsG: 8, fatG: 0.2, fiberG: 0.9,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'entrée d'été qui hydrate autant qu'elle nourrit — et du potassium pour les jours de forte chaleur.",
                en: "The summer starter that hydrates as much as it feeds — with potassium for the hottest days.",
                es: "La entrada de verano que hidrata tanto como alimenta, con potasio para los días de más calor."
            )
        ),
        Food(
            id: "clementine",
            name: LocalizedText(fr: "Clémentines", en: "Clementines", es: "Clementinas"),
            role: .fruit, tier: .base,
            kcal: 47, proteinG: 0.9, carbsG: 12, fatG: 0.2, fiberG: 1.7,
            portionG: 120,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit d'hiver qui se transporte, s'épluche en dix secondes et se mange sans y penser.",
                en: "The winter fruit that travels, peels in ten seconds and gets eaten without thinking.",
                es: "La fruta de invierno que viaja, se pela en diez segundos y se come sin pensar."
            )
        ),
        Food(
            id: "pamplemousse",
            name: LocalizedText(fr: "Pamplemousse", en: "Grapefruit", es: "Pomelo"),
            role: .fruit, tier: .base,
            kcal: 42, proteinG: 0.8, carbsG: 10.5, fatG: 0.1, fiberG: 1.6,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'amertume qui cale mieux que le sucré — attention seulement à certains médicaments, l'interaction est réelle.",
                en: "The bitterness that satisfies better than sweetness — just mind some medications, the interaction is real.",
                es: "El amargor que sacia mejor que el dulzor; ojo solo con algunos medicamentos, la interacción es real."
            )
        ),
        Food(
            id: "grenade",
            name: LocalizedText(fr: "Grenade", en: "Pomegranate", es: "Granada"),
            role: .fruit, tier: .base,
            kcal: 83, proteinG: 1.7, carbsG: 19, fatG: 1.2, fiberG: 4,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Des polyphénols parmi les plus étudiés du rayon, et des graines qui croquent comme rien d'autre.",
                en: "Polyphenols among the most studied on the shelf, and seeds that crunch like nothing else.",
                es: "Polifenoles de los más estudiados del estante, y granos que crujen como ninguna otra cosa."
            )
        ),
        Food(
            id: "figue",
            name: LocalizedText(fr: "Figues fraîches", en: "Fresh figs", es: "Higos frescos"),
            role: .fruit, tier: .base,
            kcal: 74, proteinG: 0.8, carbsG: 19, fatG: 0.3, fiberG: 2.9,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit du calcium — rare chez les fruits — et une douceur qui remplace un dessert.",
                en: "The calcium fruit — rare among fruit — with a sweetness that stands in for dessert.",
                es: "La fruta del calcio, raro entre las frutas, con un dulzor que sustituye a un postre."
            )
        ),
        Food(
            id: "citron",
            name: LocalizedText(fr: "Citron", en: "Lemon", es: "Limón"),
            role: .fruit, tier: .base,
            kcal: 29, proteinG: 1.1, carbsG: 6, fatG: 0.3, fiberG: 2.8,
            portionG: 60,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'assaisonnement zéro calorie : il remplace la moitié du sel et la moitié des sauces.",
                en: "The zero-calorie seasoning: it replaces half the salt and half the sauces.",
                es: "El aliño de cero calorías: sustituye a la mitad de la sal y a la mitad de las salsas."
            )
        ),
        Food(
            id: "kaki",
            name: LocalizedText(fr: "Kaki", en: "Persimmon", es: "Caqui"),
            role: .fruit, tier: .base,
            kcal: 70, proteinG: 0.6, carbsG: 18, fatG: 0.2, fiberG: 3.6,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit d'automne oublié : plus de fibres que la pomme, et une chair qui se mange à la cuillère.",
                en: "The forgotten autumn fruit: more fibre than an apple, and a flesh you eat with a spoon.",
                es: "La fruta de otoño olvidada: más fibra que la manzana y una carne que se come a cucharadas."
            )
        ),
        Food(
            id: "abricots-secs",
            name: LocalizedText(fr: "Abricots secs", en: "Dried apricots", es: "Orejones"),
            role: .fruit, tier: .moderate,
            kcal: 241, proteinG: 3.4, carbsG: 53, fatG: 0.5, fiberG: 7.3,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le fruit moins l'eau : les fibres et le potassium concentrés, mais le sucre aussi — quatre abricots secs valent le fruit frais entier.",
                en: "The fruit minus the water: fibre and potassium concentrated, but so is the sugar — four dried apricots equal the whole fresh fruit.",
                es: "La fruta sin el agua: fibra y potasio concentrados, pero el azúcar también; cuatro orejones valen la fruta fresca entera."
            )
        ),
        Food(
            id: "pruneaux",
            name: LocalizedText(fr: "Pruneaux", en: "Prunes", es: "Ciruelas pasas"),
            role: .fruit, tier: .moderate,
            kcal: 240, proteinG: 2.2, carbsG: 57, fatG: 0.4, fiberG: 7.1,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le remède au transit le mieux documenté du rayon — en comptant ses 240 kcal aux 100 g.",
                en: "The best-documented transit remedy on the shelf — counting its 240 kcal per 100 g.",
                es: "El remedio para el tránsito mejor documentado del estante, contando sus 240 kcal por 100 g."
            )
        ),
        Food(
            id: "raisins-secs",
            name: LocalizedText(fr: "Raisins secs", en: "Raisins", es: "Pasas"),
            role: .fruit, tier: .moderate,
            kcal: 300, proteinG: 3.1, carbsG: 72, fatG: 0.5, fiberG: 4,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le sucre du raisin sans son eau : une poignée en randonnée oui, le paquet devant l'écran non.",
                en: "Grape sugar without the water: a handful on a hike yes, the bag in front of a screen no.",
                es: "El azúcar de la uva sin su agua: un puñado en la ruta sí, la bolsa frente a la pantalla no."
            )
        ),
        Food(
            id: "compote-ssa",
            name: LocalizedText(fr: "Compote sans sucre ajouté", en: "No-added-sugar apple purée", es: "Compota sin azúcar añadido"),
            role: .fruit, tier: .base,
            kcal: 45, proteinG: 0.3, carbsG: 11, fatG: 0.2, fiberG: 1.7,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La pomme, moins la mâche : honnête au goûter, mais le fruit entier rassasie davantage.",
                en: "Apple minus the chewing: honest as a snack, but the whole fruit fills you more.",
                es: "La manzana sin la masticación: honesta para merendar, pero la fruta entera sacia más."
            )
        ),
    ]
}
