import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Légumes.
extension FoodCatalog {
    static let moreVegetables: [Food] = [
        Food(
            id: "chou-bruxelles",
            name: LocalizedText(fr: "Choux de Bruxelles", en: "Brussels sprouts", es: "Coles de Bruselas"),
            role: .vegetable, tier: .base,
            kcal: 43, proteinG: 3.4, carbsG: 9, fatG: 0.3, fiberG: 3.8,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Parmi les légumes les plus denses en vitamine K et en fibres — rôtis au four, ils ne ressemblent plus du tout à leur réputation.",
                en: "Among the densest vegetables in vitamin K and fibre — roasted, they taste nothing like their reputation.",
                es: "De las verduras más densas en vitamina K y fibra; asadas no se parecen en nada a su fama."
            )
        ),
        Food(
            id: "chou-rouge",
            name: LocalizedText(fr: "Chou rouge", en: "Red cabbage", es: "Lombarda"),
            role: .vegetable, tier: .base,
            kcal: 31, proteinG: 1.4, carbsG: 7.4, fatG: 0.2, fiberG: 2.1,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les anthocyanes de la myrtille au prix du chou, et cru il croque des semaines au réfrigérateur.",
                en: "Blueberry's anthocyanins at cabbage price, and raw it stays crisp for weeks in the fridge.",
                es: "Los antocianos del arándano a precio de col, y cruda aguanta crujiente semanas en la nevera."
            )
        ),
        Food(
            id: "chou-kale",
            name: LocalizedText(fr: "Chou kale", en: "Kale", es: "Kale"),
            role: .vegetable, tier: .base,
            kcal: 49, proteinG: 4.3, carbsG: 9, fatG: 0.9, fiberG: 3.6,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus de protéines et de calcium que n'importe quelle salade — massé à l'huile, il cesse d'être une punition.",
                en: "More protein and calcium than any lettuce — massaged with oil, it stops being a punishment.",
                es: "Más proteína y calcio que cualquier lechuga; masajeado con aceite deja de ser un castigo."
            )
        ),
        Food(
            id: "blettes",
            name: LocalizedText(fr: "Blettes", en: "Swiss chard", es: "Acelgas"),
            role: .vegetable, tier: .base,
            kcal: 19, proteinG: 1.8, carbsG: 3.7, fatG: 0.2, fiberG: 1.6,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le magnésium des épinards, la mâche en plus — les côtes et les feuilles font deux légumes en un.",
                en: "Spinach's magnesium with more bite — stalks and leaves make two vegetables in one.",
                es: "El magnesio de las espinacas con más textura: pencas y hojas son dos verduras en una."
            )
        ),
        Food(
            id: "celeri-branche",
            name: LocalizedText(fr: "Céleri branche", en: "Celery", es: "Apio"),
            role: .vegetable, tier: .base,
            kcal: 16, proteinG: 0.7, carbsG: 3, fatG: 0.2, fiberG: 1.6,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque zéro calorie et un croquant qui occupe : le légume des faims de dix-sept heures.",
                en: "Nearly zero calories and a crunch that keeps you busy: the vegetable for five-o'clock hunger.",
                es: "Casi cero calorías y un crujido que entretiene: la verdura del hambre de las cinco."
            )
        ),
        Food(
            id: "celeri-rave",
            name: LocalizedText(fr: "Céleri-rave", en: "Celeriac", es: "Apionabo"),
            role: .vegetable, tier: .base,
            kcal: 42, proteinG: 1.5, carbsG: 9, fatG: 0.3, fiberG: 1.8,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "En purée, il imite la pomme de terre pour moitié moins de calories.",
                en: "Mashed, it impersonates potato at half the calories.",
                es: "En puré imita a la patata con la mitad de calorías."
            )
        ),
        Food(
            id: "fenouil",
            name: LocalizedText(fr: "Fenouil", en: "Fennel", es: "Hinojo"),
            role: .vegetable, tier: .base,
            kcal: 31, proteinG: 1.2, carbsG: 7.3, fatG: 0.2, fiberG: 3.1,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Cru il croque comme le céleri, cuit il fond comme l'oignon — deux légumes pour le prix d'un.",
                en: "Raw it crunches like celery, cooked it melts like onion — two vegetables for the price of one.",
                es: "Crudo cruje como el apio, cocido se funde como la cebolla: dos verduras por el precio de una."
            )
        ),
        Food(
            id: "poireau",
            name: LocalizedText(fr: "Poireau", en: "Leek", es: "Puerro"),
            role: .vegetable, tier: .base,
            kcal: 61, proteinG: 1.5, carbsG: 14, fatG: 0.3, fiberG: 1.8,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'oignon doux des plats mijotés, et ses fibres nourrissent le microbiote plus que la plupart des légumes.",
                en: "The mild onion of slow dishes, and its fibres feed the microbiome more than most vegetables do.",
                es: "La cebolla suave de los guisos, y su fibra alimenta el microbioma más que la mayoría de verduras."
            )
        ),
        Food(
            id: "aubergine",
            name: LocalizedText(fr: "Aubergine", en: "Aubergine", es: "Berenjena"),
            role: .vegetable, tier: .base,
            kcal: 25, proteinG: 1, carbsG: 6, fatG: 0.2, fiberG: 3,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Une éponge à huile au four ou à la poêle — rôtie entière, elle garde sa légèreté et son fondant.",
                en: "An oil sponge in the pan — roasted whole, it keeps both its lightness and its melt.",
                es: "Una esponja de aceite en la sartén; asada entera conserva su ligereza y su cremosidad."
            )
        ),
        Food(
            id: "concombre",
            name: LocalizedText(fr: "Concombre", en: "Cucumber", es: "Pepino"),
            role: .vegetable, tier: .base,
            kcal: 15, proteinG: 0.7, carbsG: 3.6, fatG: 0.1, fiberG: 0.5,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "De l'eau qui croque : le volume dans l'assiette qui ne coûte rien au total.",
                en: "Crunchy water: plate volume that costs the total nothing.",
                es: "Agua que cruje: volumen en el plato que no cuesta nada al total."
            )
        ),
        Food(
            id: "butternut",
            name: LocalizedText(fr: "Courge butternut", en: "Butternut squash", es: "Calabaza butternut"),
            role: .vegetable, tier: .base,
            kcal: 45, proteinG: 1, carbsG: 11.5, fatG: 0.1, fiberG: 2,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La douceur d'une purée de patate douce pour moitié moins de calories, et un stock d'hiver qui ne périme pas.",
                en: "Sweet-potato-mash sweetness at half the calories, and a winter stock that never spoils.",
                es: "El dulzor de un puré de boniato con la mitad de calorías, y una despensa de invierno que no caduca."
            )
        ),
        Food(
            id: "potiron",
            name: LocalizedText(fr: "Potiron", en: "Pumpkin", es: "Calabaza"),
            role: .vegetable, tier: .base,
            kcal: 26, proteinG: 1, carbsG: 6.5, fatG: 0.1, fiberG: 0.5,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le légume-soupe de l'hiver : du bêta-carotène en quantité pour presque rien en calories.",
                en: "The winter soup vegetable: plenty of beta-carotene for nearly nothing in calories.",
                es: "La verdura-sopa del invierno: betacaroteno en cantidad por casi nada en calorías."
            )
        ),
        Food(
            id: "navet",
            name: LocalizedText(fr: "Navet", en: "Turnip", es: "Nabo"),
            role: .vegetable, tier: .base,
            kcal: 28, proteinG: 0.9, carbsG: 6.4, fatG: 0.1, fiberG: 1.8,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le discret des pot-au-feu : de la famille du brocoli, avec les mêmes composés soufrés protecteurs.",
                en: "The quiet one in the stew: from broccoli's family, with the same protective sulfur compounds.",
                es: "El discreto del cocido: de la familia del brócoli, con los mismos compuestos azufrados protectores."
            )
        ),
        Food(
            id: "radis",
            name: LocalizedText(fr: "Radis", en: "Radishes", es: "Rábanos"),
            role: .vegetable, tier: .base,
            kcal: 16, proteinG: 0.7, carbsG: 3.4, fatG: 0.1, fiberG: 1.6,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le croquant poivré de l'apéritif qui ne doit rien au paquet de chips.",
                en: "The peppery crunch of apéritif hour that owes nothing to the crisps bag.",
                es: "El crujiente picante del aperitivo que no le debe nada a la bolsa de patatas."
            )
        ),
        Food(
            id: "endive",
            name: LocalizedText(fr: "Endive", en: "Endive", es: "Endibia"),
            role: .vegetable, tier: .base,
            kcal: 17, proteinG: 0.9, carbsG: 4, fatG: 0.1, fiberG: 3.1,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "L'amertume qui ouvre l'appétit et des fibres inuline qui nourrissent le microbiote.",
                en: "The bitterness that opens the appetite, and inulin fibres that feed the microbiome.",
                es: "El amargor que abre el apetito y fibras de inulina que alimentan el microbioma."
            )
        ),
        Food(
            id: "mache",
            name: LocalizedText(fr: "Mâche", en: "Lamb's lettuce", es: "Canónigos"),
            role: .vegetable, tier: .base,
            kcal: 21, proteinG: 2, carbsG: 3.6, fatG: 0.4, fiberG: 1.5,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La salade qui contient de vrais oméga-3 végétaux — rare dans un rayon où la laitue n'apporte que du croquant.",
                en: "The salad leaf with real plant omega-3s — rare on a shelf where lettuce brings only crunch.",
                es: "La ensalada con auténticos omega-3 vegetales: rara en un estante donde la lechuga solo aporta crujido."
            )
        ),
        Food(
            id: "roquette",
            name: LocalizedText(fr: "Roquette", en: "Rocket", es: "Rúcula"),
            role: .vegetable, tier: .base,
            kcal: 25, proteinG: 2.6, carbsG: 3.7, fatG: 0.7, fiberG: 1.6,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les nitrates qui dilatent les vaisseaux — la même famille de composés que la betterave des coureurs.",
                en: "The vessel-dilating nitrates — the same compound family as the runner's beetroot.",
                es: "Los nitratos que dilatan los vasos: la misma familia de compuestos que la remolacha de los corredores."
            )
        ),
        Food(
            id: "cresson",
            name: LocalizedText(fr: "Cresson", en: "Watercress", es: "Berros"),
            role: .vegetable, tier: .base,
            kcal: 21, proteinG: 2.3, carbsG: 2.7, fatG: 0.3, fiberG: 1.1,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le légume le mieux classé en nutriments par calorie des tables de référence — littéralement imbattable.",
                en: "The top-ranked vegetable for nutrients per calorie in the reference tables — literally unbeatable.",
                es: "La verdura mejor clasificada en nutrientes por caloría de las tablas de referencia: literalmente imbatible."
            )
        ),
        Food(
            id: "artichaut",
            name: LocalizedText(fr: "Artichaut", en: "Artichoke", es: "Alcachofa"),
            role: .vegetable, tier: .base,
            kcal: 47, proteinG: 3.3, carbsG: 10.5, fatG: 0.2, fiberG: 5.4,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un des champions des fibres — et l'inuline qu'il contient est celle que le microbiote préfère.",
                en: "One of the fibre champions — and its inulin is the kind the microbiome likes best.",
                es: "Uno de los campeones de la fibra, y su inulina es la que más le gusta al microbioma."
            )
        ),
        Food(
            id: "germes-soja",
            name: LocalizedText(fr: "Germes de soja", en: "Bean sprouts", es: "Brotes de soja"),
            role: .vegetable, tier: .base,
            kcal: 30, proteinG: 3, carbsG: 4.5, fatG: 0.2, fiberG: 1.8,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le croquant des plats sautés, avec un peu de protéines là où la plupart des légumes n'en ont pas.",
                en: "The stir-fry crunch, with a little protein where most vegetables have none.",
                es: "El crujiente del salteado, con algo de proteína donde la mayoría de verduras no tienen."
            )
        ),
    ]
}
