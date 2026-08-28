import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// Condiments et plaisirs.
extension FoodCatalog {
    static let moreExtras: [Food] = [
        Food(
            id: "miel",
            name: LocalizedText(fr: "Miel", en: "Honey", es: "Miel"),
            role: .treat, tier: .moderate,
            kcal: 304, proteinG: 0.3, carbsG: 82, fatG: 0, fiberG: 0.2,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Du sucre avec une histoire : quelques traces d'antioxydants, mais la cuillère se compte comme du sucre.",
                en: "Sugar with a backstory: trace antioxidants, but the spoonful counts as sugar.",
                es: "Azúcar con historia: trazas de antioxidantes, pero la cucharada cuenta como azúcar."
            )
        ),
        Food(
            id: "confiture",
            name: LocalizedText(fr: "Confiture", en: "Jam", es: "Mermelada"),
            role: .treat, tier: .moderate,
            kcal: 240, proteinG: 0.4, carbsG: 58, fatG: 0.1, fiberG: 1,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un tiers de fruit, deux tiers de sucre : la fine couche sur le pain, pas la cuillère dans le pot.",
                en: "One third fruit, two thirds sugar: the thin layer on bread, not the spoon in the jar.",
                es: "Un tercio de fruta, dos tercios de azúcar: la capa fina en el pan, no la cuchara en el bote."
            )
        ),
        Food(
            id: "sirop-erable",
            name: LocalizedText(fr: "Sirop d'érable", en: "Maple syrup", es: "Sirope de arce"),
            role: .treat, tier: .moderate,
            kcal: 260, proteinG: 0, carbsG: 67, fatG: 0, fiberG: 0,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un sucre un peu moins dense que le miel, au goût qui porte plus loin : on en met moins, c'est tout son intérêt.",
                en: "A sugar slightly less dense than honey with a flavour that carries further: you use less — that is its whole point.",
                es: "Un azúcar algo menos denso que la miel con un sabor que llega más lejos: se usa menos, y ese es todo su interés."
            )
        ),
        Food(
            id: "pate-a-tartiner",
            name: LocalizedText(fr: "Pâte à tartiner", en: "Chocolate hazelnut spread", es: "Crema de cacao y avellanas"),
            role: .treat, tier: .occasional,
            kcal: 539, proteinG: 6, carbsG: 57, fatG: 31, fiberG: 3.4,
            portionG: 20,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Plus de la moitié sucre, un tiers huile de palme : la noisette de l'étiquette est surtout sur l'étiquette.",
                en: "More than half sugar, a third palm oil: the hazelnut on the label lives mostly on the label.",
                es: "Más de la mitad azúcar y un tercio aceite de palma: la avellana de la etiqueta vive sobre todo en la etiqueta."
            )
        ),
        Food(
            id: "bonbons",
            name: LocalizedText(fr: "Bonbons", en: "Sweets", es: "Gominolas"),
            role: .treat, tier: .occasional,
            kcal: 350, proteinG: 0.1, carbsG: 87, fatG: 0.1, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Du sucre à l'état pur, sans même le gras qui rassasie un peu : le paquet se finit parce que rien n'arrête.",
                en: "Pure sugar without even the fat that slightly fills: the bag empties because nothing pushes back.",
                es: "Azúcar en estado puro, sin siquiera la grasa que algo sacia: la bolsa se acaba porque nada frena."
            )
        ),
        Food(
            id: "barre-chocolatee",
            name: LocalizedText(fr: "Barre chocolatée", en: "Chocolate bar", es: "Barrita de chocolate"),
            role: .treat, tier: .occasional,
            kcal: 480, proteinG: 5, carbsG: 60, fatG: 24, fiberG: 1.5,
            portionG: 45,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le distributeur de dix-sept heures : 250 kcal en quatre-vingt-dix secondes, refaim une heure après.",
                en: "The 5 p.m. vending machine: 250 kcal in ninety seconds, hungry again an hour later.",
                es: "La máquina de las cinco: 250 kcal en noventa segundos, y hambre otra vez una hora después."
            )
        ),
        Food(
            id: "gateau-chocolat",
            name: LocalizedText(fr: "Gâteau au chocolat", en: "Chocolate cake", es: "Tarta de chocolate"),
            role: .treat, tier: .occasional,
            kcal: 410, proteinG: 5, carbsG: 50, fatG: 21, fiberG: 2,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La part d'anniversaire vaut un déjeuner en calories — elle se mange à l'anniversaire, pas au bureau le mardi.",
                en: "The birthday slice is a lunch's worth of calories — eaten at the birthday, not at the desk on a Tuesday.",
                es: "La porción de cumpleaños vale un almuerzo en calorías: se come en el cumpleaños, no en la oficina un martes."
            )
        ),
        Food(
            id: "sorbet",
            name: LocalizedText(fr: "Sorbet", en: "Sorbet", es: "Sorbete"),
            role: .treat, tier: .moderate,
            kcal: 130, proteinG: 0.5, carbsG: 32, fatG: 0.1, fiberG: 0.5,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La glace sans la crème : moitié moins de calories que la crème glacée, et le fruit en premier ingrédient.",
                en: "Ice cream without the cream: half the calories of dairy ice cream, with fruit as the first ingredient.",
                es: "El helado sin la nata: la mitad de calorías que el helado cremoso, con la fruta como primer ingrediente."
            )
        ),
        Food(
            id: "frites",
            name: LocalizedText(fr: "Frites", en: "French fries", es: "Patatas fritas (de guarnición)"),
            role: .treat, tier: .occasional,
            kcal: 310, proteinG: 3.4, carbsG: 40, fatG: 15, fiberG: 3.8,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La pomme de terre a triplé ses calories dans le bain d'huile — au four, les « frites » maison en gardent la moitié.",
                en: "The potato tripled its calories in the oil bath — oven-baked, home “fries” keep half as many.",
                es: "La patata triplicó sus calorías en el baño de aceite; al horno, las «fritas» caseras se quedan en la mitad."
            )
        ),
        Food(
            id: "burger",
            name: LocalizedText(fr: "Burger de fast-food", en: "Fast-food burger", es: "Hamburguesa de comida rápida"),
            role: .treat, tier: .occasional,
            kcal: 280, proteinG: 13, carbsG: 28, fatG: 13, fiberG: 1.5,
            portionG: 220,
            diets: [.omnivore],
            reason: LocalizedText(
                fr: "Le double-fromage dépasse les 600 kcal avant les frites — le burger maison au bœuf 5 % en vaut la moitié.",
                en: "The double-cheese passes 600 kcal before the fries — a home burger on 5 % beef is worth half that.",
                es: "La doble con queso pasa de 600 kcal antes de las patatas; la casera con carne al 5 % vale la mitad."
            )
        ),
        Food(
            id: "nuggets",
            name: LocalizedText(fr: "Nuggets de poulet", en: "Chicken nuggets", es: "Nuggets de pollo"),
            role: .treat, tier: .occasional,
            kcal: 296, proteinG: 15, carbsG: 18, fatG: 18, fiberG: 1,
            portionG: 100,
            diets: [.omnivore],
            reason: LocalizedText(
                fr: "Moitié poulet, moitié panure frite : la protéine annoncée arrive noyée dans l'huile du bain.",
                en: "Half chicken, half fried coating: the advertised protein arrives drowned in fryer oil.",
                es: "Mitad pollo, mitad rebozado frito: la proteína anunciada llega ahogada en el aceite de freír."
            )
        ),
        Food(
            id: "mayonnaise",
            name: LocalizedText(fr: "Mayonnaise", en: "Mayonnaise", es: "Mayonesa"),
            role: .fat, tier: .occasional,
            kcal: 680, proteinG: 1, carbsG: 2.5, fatG: 74, fiberG: 0,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "De l'huile fouettée : la cuillère à soupe vaut 100 kcal, et personne ne s'arrête à une cuillère.",
                en: "Whipped oil: the tablespoon is 100 kcal, and nobody stops at one tablespoon.",
                es: "Aceite batido: la cucharada vale 100 kcal, y nadie se queda en una cucharada."
            )
        ),
        Food(
            id: "ketchup",
            name: LocalizedText(fr: "Ketchup", en: "Ketchup", es: "Kétchup"),
            role: .treat, tier: .moderate,
            kcal: 100, proteinG: 1.2, carbsG: 23, fatG: 0.2, fiberG: 0.3,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un quart de sucre — quatre fois moins grave que la mayonnaise, quatre fois plus que la tomate qu'il invoque.",
                en: "A quarter sugar — four times better than mayo, four times worse than the tomato it claims.",
                es: "Una cuarta parte de azúcar: cuatro veces mejor que la mayonesa, cuatro veces peor que el tomate que invoca."
            )
        ),
        Food(
            id: "moutarde",
            name: LocalizedText(fr: "Moutarde", en: "Mustard", es: "Mostaza"),
            role: .treat, tier: .base,
            kcal: 66, proteinG: 4.4, carbsG: 5.8, fatG: 3.3, fiberG: 1.5,
            portionG: 10,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le condiment qui a du goût sans avoir de calories qui comptent : la base des sauces qui ne coûtent rien.",
                en: "The condiment with taste but no calories worth counting: the base of sauces that cost nothing.",
                es: "El condimento con sabor y sin calorías que cuenten: la base de las salsas que no cuestan nada."
            )
        ),
        Food(
            id: "cornichons",
            name: LocalizedText(fr: "Cornichons", en: "Gherkins", es: "Pepinillos"),
            role: .vegetable, tier: .base,
            kcal: 14, proteinG: 0.6, carbsG: 2.2, fatG: 0.2, fiberG: 1,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le croquant acide qui coupe l'envie de finir le plat — pour presque rien, sel mis à part.",
                en: "The sour crunch that kills the urge to finish the dish — for nearly nothing, salt aside.",
                es: "El crujido ácido que corta las ganas de rebañar, por casi nada, sal aparte."
            )
        ),
        Food(
            id: "sauce-tomate",
            name: LocalizedText(fr: "Sauce tomate nature", en: "Plain tomato sauce", es: "Tomate frito casero"),
            role: .vegetable, tier: .base,
            kcal: 38, proteinG: 1.4, carbsG: 6, fatG: 1, fiberG: 1.8,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La tomate concentrée par la cuisson, lycopène compris : la sauce qui compte comme un légume.",
                en: "Tomato concentrated by cooking, lycopene included: the sauce that counts as a vegetable.",
                es: "El tomate concentrado por la cocción, licopeno incluido: la salsa que cuenta como verdura."
            )
        ),
        Food(
            id: "pesto",
            name: LocalizedText(fr: "Pesto", en: "Pesto", es: "Pesto"),
            role: .fat, tier: .moderate,
            kcal: 460, proteinG: 5, carbsG: 6, fatG: 46, fiberG: 1.5,
            portionG: 25,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Basilic, oui — porté par l'huile et le fromage : deux cuillères assaisonnent, quatre doublent le plat.",
                en: "Basil, yes — carried by oil and cheese: two spoonfuls season, four double the dish.",
                es: "Albahaca, sí, a hombros de aceite y queso: dos cucharadas aliñan, cuatro doblan el plato."
            )
        ),
        Food(
            id: "sauce-soja",
            name: LocalizedText(fr: "Sauce soja", en: "Soy sauce", es: "Salsa de soja"),
            role: .treat, tier: .base,
            kcal: 53, proteinG: 8, carbsG: 5, fatG: 0, fiberG: 0.8,
            portionG: 15,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Du goût presque sans calories — c'est du sel liquide : la version réduite en sodium change vraiment la donne.",
                en: "Taste with almost no calories — it is liquid salt: the reduced-sodium version genuinely matters.",
                es: "Sabor casi sin calorías, pero es sal líquida: la versión baja en sodio cambia de verdad las cosas."
            )
        ),
    ]
}
