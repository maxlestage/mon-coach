import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Poissons et produits de la mer.
extension FoodCatalog {
    static let moreSea: [Food] = [
        Food(
            id: "truite",
            name: LocalizedText(fr: "Truite", en: "Trout", es: "Trucha"),
            role: .protein, tier: .base,
            kcal: 148, proteinG: 21, carbsG: 0, fatG: 6.7, fiberG: 0,
            portionG: 140,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Les oméga-3 du saumon en version locale et souvent moins chère.",
                en: "Salmon's omega-3s in a local, often cheaper package.",
                es: "Los omega-3 del salmón en versión local y a menudo más barata."
            )
        ),
        Food(
            id: "maquereau",
            name: LocalizedText(fr: "Maquereau", en: "Mackerel", es: "Caballa"),
            role: .protein, tier: .base,
            kcal: 205, proteinG: 19, carbsG: 0, fatG: 14, fiberG: 0,
            portionG: 140,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Parmi les plus riches en oméga-3 du rayon, pour trois fois moins cher que le saumon.",
                en: "Among the richest in omega-3 at the counter, for a third of the price of salmon.",
                es: "De los más ricos en omega-3 del mostrador, por un tercio del precio del salmón."
            )
        ),
        Food(
            id: "hareng",
            name: LocalizedText(fr: "Hareng", en: "Herring", es: "Arenque"),
            role: .protein, tier: .base,
            kcal: 190, proteinG: 18, carbsG: 0, fatG: 13, fiberG: 0,
            portionG: 130,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Oméga-3, vitamine D et sélénium — le petit poisson gras que la mer du Nord mange depuis toujours.",
                en: "Omega-3, vitamin D and selenium — the oily little fish the North Sea has always lived on.",
                es: "Omega-3, vitamina D y selenio: el pescadito azul del que el mar del Norte vive desde siempre."
            )
        ),
        Food(
            id: "dorade",
            name: LocalizedText(fr: "Dorade", en: "Sea bream", es: "Dorada"),
            role: .protein, tier: .base,
            kcal: 128, proteinG: 22, carbsG: 0, fatG: 4.4, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un poisson blanc ferme qui pardonne la cuisson — celui par lequel commencer si le poisson t'ennuie.",
                en: "A firm white fish that forgives the cook — the one to start with if fish bores you.",
                es: "Un pescado blanco firme que perdona la cocción: por el que empezar si el pescado te aburre."
            )
        ),
        Food(
            id: "bar",
            name: LocalizedText(fr: "Bar (loup)", en: "Sea bass", es: "Lubina"),
            role: .protein, tier: .base,
            kcal: 124, proteinG: 21, carbsG: 0, fatG: 4, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le maigre des poissons nobles : la texture du restaurant, les macros du cabillaud.",
                en: "The lean end of the fine-fish counter: restaurant texture, cod macros.",
                es: "Lo magro entre los pescados nobles: textura de restaurante, macros de bacalao."
            )
        ),
        Food(
            id: "colin-lieu",
            name: LocalizedText(fr: "Colin / lieu noir", en: "Pollock", es: "Abadejo"),
            role: .protein, tier: .base,
            kcal: 92, proteinG: 20, carbsG: 0, fatG: 1, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le poisson blanc le moins cher au kilo de protéines — celui des étudiants qui font leurs macros.",
                en: "The cheapest white fish per kilo of protein — the one for students who track macros.",
                es: "El pescado blanco más barato por kilo de proteína: el de los estudiantes que cuentan macros."
            )
        ),
        Food(
            id: "sole",
            name: LocalizedText(fr: "Sole", en: "Sole", es: "Lenguado"),
            role: .protein, tier: .base,
            kcal: 86, proteinG: 18, carbsG: 0, fatG: 1.5, fiberG: 0,
            portionG: 140,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque aussi maigre que le blanc d'œuf, et une chair qui se défait à la fourchette.",
                en: "Nearly as lean as egg white, with flesh that parts at the fork.",
                es: "Casi tan magro como la clara de huevo, con una carne que se deshace con el tenedor."
            )
        ),
        Food(
            id: "tilapia",
            name: LocalizedText(fr: "Tilapia", en: "Tilapia", es: "Tilapia"),
            role: .protein, tier: .base,
            kcal: 96, proteinG: 20, carbsG: 0, fatG: 1.7, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Neutre en goût et imbattable en prix : la toile blanche des sauces qui ont du caractère.",
                en: "Neutral in taste and unbeatable on price: the blank canvas for sauces with character.",
                es: "Neutro de sabor e imbatible de precio: el lienzo en blanco para salsas con carácter."
            )
        ),
        Food(
            id: "thon-frais",
            name: LocalizedText(fr: "Thon frais", en: "Fresh tuna", es: "Atún fresco"),
            role: .protein, tier: .base,
            kcal: 144, proteinG: 23, carbsG: 0, fatG: 4.9, fiberG: 0,
            portionG: 140,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le steak de la mer : la densité protéique du bœuf maigre, les oméga-3 en plus.",
                en: "The steak of the sea: lean beef's protein density, with omega-3 on top.",
                es: "El filete del mar: la densidad proteica de la ternera magra, con omega-3 de regalo."
            )
        ),
        Food(
            id: "saumon-fume",
            name: LocalizedText(fr: "Saumon fumé", en: "Smoked salmon", es: "Salmón ahumado"),
            role: .protein, tier: .moderate,
            kcal: 180, proteinG: 23, carbsG: 0, fatG: 10, fiberG: 0,
            portionG: 75,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le saumon, en plus salé et bien plus cher : un plaisir d'occasion plus qu'une base d'assiette.",
                en: "Salmon, saltier and much dearer: an occasion food more than a plate's foundation.",
                es: "El salmón, más salado y bastante más caro: más un placer de ocasión que una base del plato."
            )
        ),
        Food(
            id: "anchois",
            name: LocalizedText(fr: "Anchois (à l'huile, égouttés)", en: "Anchovies (in oil, drained)", es: "Anchoas (en aceite, escurridas)"),
            role: .protein, tier: .moderate,
            kcal: 210, proteinG: 29, carbsG: 0, fatG: 10, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Trente grammes suffisent à assaisonner un plat entier en protéines et en iode — et en sel, d'où la modération.",
                en: "Thirty grams season a whole dish with protein and iodine — and salt, hence the moderation.",
                es: "Treinta gramos aliñan un plato entero con proteína y yodo, y con sal: de ahí la moderación."
            )
        ),
        Food(
            id: "moules",
            name: LocalizedText(fr: "Moules", en: "Mussels", es: "Mejillones"),
            role: .protein, tier: .base,
            kcal: 111, proteinG: 17, carbsG: 4, fatG: 2.2, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Fer, B12 et zinc au niveau de la viande rouge, pour moitié moins de calories.",
                en: "Iron, B12 and zinc at red-meat levels, for half the calories.",
                es: "Hierro, B12 y zinc a nivel de carne roja, con la mitad de calorías."
            )
        ),
        Food(
            id: "calamars",
            name: LocalizedText(fr: "Calamars", en: "Squid", es: "Calamares"),
            role: .protein, tier: .base,
            kcal: 92, proteinG: 16, carbsG: 3, fatG: 1.4, fiberG: 0,
            portionG: 140,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Maigre et élastique sous la dent — tout se joue à la cuisson : une minute, ou une heure, jamais entre les deux.",
                en: "Lean and springy — the cooking decides everything: one minute or one hour, never in between.",
                es: "Magro y firme al diente: todo se decide en la cocción, un minuto o una hora, nunca entre medias."
            )
        ),
        Food(
            id: "noix-st-jacques",
            name: LocalizedText(fr: "Noix de Saint-Jacques", en: "Scallops", es: "Vieiras"),
            role: .protein, tier: .base,
            kcal: 88, proteinG: 17, carbsG: 2.4, fatG: 0.8, fiberG: 0,
            portionG: 120,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La protéine la plus maigre de la mer après la sole — et celle qui se gâche le plus vite en cuisant trop.",
                en: "The leanest protein in the sea after sole — and the quickest ruined by overcooking.",
                es: "La proteína más magra del mar tras el lenguado, y la que antes se estropea si se pasa de cocción."
            )
        ),
        Food(
            id: "crabe",
            name: LocalizedText(fr: "Crabe", en: "Crab", es: "Cangrejo"),
            role: .protein, tier: .base,
            kcal: 97, proteinG: 19, carbsG: 0, fatG: 1.5, fiberG: 0,
            portionG: 120,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le profil des crevettes avec plus de zinc — la boîte au naturel fait très bien l'affaire.",
                en: "The shrimp profile with more zinc — plain tinned works perfectly well.",
                es: "El perfil de las gambas con más zinc: la lata al natural sirve perfectamente."
            )
        ),
        Food(
            id: "surimi",
            name: LocalizedText(fr: "Surimi", en: "Surimi sticks", es: "Surimi"),
            role: .protein, tier: .moderate,
            kcal: 95, proteinG: 8, carbsG: 12, fatG: 1.5, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Moitié poisson, moitié amidon et sucre : la protéine y est plus diluée que le nom le laisse croire.",
                en: "Half fish, half starch and sugar: the protein is more diluted than the name suggests.",
                es: "Mitad pescado, mitad almidón y azúcar: la proteína está más diluida de lo que sugiere el nombre."
            )
        ),
    ]
}
