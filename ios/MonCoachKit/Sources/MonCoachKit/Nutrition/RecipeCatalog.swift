import Foundation

/// Les plats que le coach sait proposer.
///
/// Chaque recette n'utilise que des aliments du catalogue, et c'est ce qui la
/// rend utilisable : les macros du plat se calculent, la liste de courses se
/// déduit, et le régime se vérifie au lieu de se déclarer.
///
/// Trois règles tiennent l'ensemble, et les tests les vérifient une par une :
///
/// - un plat principal porte **exactement deux légumes**, comme l'assiette
///   que le planificateur construisait déjà ;
/// - un petit-déjeuner porte **un fruit**, et sa protéine comme son féculent
///   se mangent au réveil sans effort ;
/// - **aucun aliment de rang occasionnel** n'entre dans une recette : un plat
///   proposé comme ordinaire ne peut pas reposer sur ce qu'on garde pour les
///   grandes occasions.
public enum RecipeCatalog {

    public static let all: [Recipe] = mains + breakfasts

    // MARK: - Plats principaux

    /// Le déjeuner et le dîner, c'est-à-dire les seuls repas qu'on cuisine.
    ///
    /// La variété n'est pas décorative. Le planificateur évite de répéter une
    /// protéine dans la journée, et la semaine doit tenir sans lasser : sans
    /// un choix large à chaque régime, on retombe sur trois plats en boucle,
    /// et un plan qu'on abandonne au bout de dix jours ne vaut rien.
    static let mains: [Recipe] = [
        Recipe(
            id: "poulet-basquaise",
            name: LocalizedText(
                fr: "Poulet basquaise, riz basmati",
                en: "Basque chicken with basmati rice",
                es: "Pollo a la vasca con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Émince les poivrons et les tomates. Coupe le poulet en gros morceaux.",
                    en: "Slice the peppers and tomatoes. Cut the chicken into large chunks.",
                    es: "Corta los pimientos y los tomates. Trocea el pollo en dados grandes."
                ),
                LocalizedText(
                    fr: "Saisis le poulet à l'huile d'olive sur feu vif, deux minutes par face, puis réserve.",
                    en: "Sear the chicken in olive oil over high heat, two minutes a side, then set aside.",
                    es: "Sella el pollo en aceite de oliva a fuego fuerte, dos minutos por cara, y reserva."
                ),
                LocalizedText(
                    fr: "Fais tomber les légumes dans la même poêle, remets le poulet, couvre et laisse vingt minutes.",
                    en: "Soften the vegetables in the same pan, return the chicken, cover and cook twenty minutes.",
                    es: "Pocha las verduras en la misma sartén, devuelve el pollo, tapa y cocina veinte minutos."
                ),
                LocalizedText(
                    fr: "Le riz cuit pendant ce temps. Rien à surveiller.",
                    en: "The rice cooks meanwhile. Nothing to watch.",
                    es: "El arroz se hace mientras tanto. Nada que vigilar."
                ),
            ]
        ),
        Recipe(
            id: "poulet-roti-four",
            name: LocalizedText(
                fr: "Poulet rôti, pommes de terre au four",
                en: "Roast chicken with oven potatoes",
                es: "Pollo asado con patatas al horno"
            ),
            slots: [.lunch, .dinner],
            proteinID: "poulet-roti", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "oignon"],
            minutes: 55,
            steps: [
                LocalizedText(
                    fr: "Four à 200 °C. Coupe les pommes de terre, les carottes et les oignons en gros morceaux.",
                    en: "Oven at 200 °C. Cut the potatoes, carrots and onions into large pieces.",
                    es: "Horno a 200 °C. Corta las patatas, las zanahorias y las cebollas en trozos grandes."
                ),
                LocalizedText(
                    fr: "Verse tout dans un plat, huile d'olive, sel, poivre, et mélange à la main.",
                    en: "Tip everything into a dish, olive oil, salt, pepper, and toss by hand.",
                    es: "Ponlo todo en una fuente, aceite, sal, pimienta, y mezcla con la mano."
                ),
                LocalizedText(
                    fr: "Pose le poulet dessus et enfourne quarante-cinq minutes. Les légumes cuisent dans le jus.",
                    en: "Sit the chicken on top and roast forty-five minutes. The vegetables cook in the juices.",
                    es: "Coloca el pollo encima y hornea cuarenta y cinco minutos. Las verduras se hacen en el jugo."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-brocoli",
            name: LocalizedText(
                fr: "Bœuf sauté au brocoli, riz complet",
                en: "Beef and broccoli stir-fry with brown rice",
                es: "Salteado de ternera y brócoli con arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "riz-complet",
            fatID: "huile-colza", extraIDs: ["brocoli", "germes-soja"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Taille le bœuf en fines lanières, contre le sens des fibres.",
                    en: "Cut the beef into thin strips, across the grain.",
                    es: "Corta la ternera en tiras finas, a contrafibra."
                ),
                LocalizedText(
                    fr: "Poêle très chaude, une minute par face, puis réserve : trop cuit, il durcit.",
                    en: "Very hot pan, one minute a side, then set aside: overcooked, it turns tough.",
                    es: "Sartén muy caliente, un minuto por cara, y reserva: pasado de punto, se endurece."
                ),
                LocalizedText(
                    fr: "Saute le brocoli cinq minutes, ajoute les germes de soja, remets la viande, sers aussitôt.",
                    en: "Stir-fry the broccoli five minutes, add the bean sprouts, return the beef, serve at once.",
                    es: "Saltea el brócoli cinco minutos, añade los brotes de soja, devuelve la carne y sirve."
                ),
            ]
        ),
        Recipe(
            id: "chili-boeuf",
            name: LocalizedText(
                fr: "Chili de bœuf, riz blanc",
                en: "Beef chilli with white rice",
                es: "Chili de ternera con arroz blanco"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-5", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais revenir le bœuf haché à feu vif jusqu'à ce qu'il ne rende plus d'eau.",
                    en: "Brown the mince over high heat until it stops releasing water.",
                    es: "Dora la carne picada a fuego fuerte hasta que deje de soltar agua."
                ),
                LocalizedText(
                    fr: "Ajoute les poivrons en dés, la sauce tomate, cumin et paprika.",
                    en: "Add the diced peppers, the tomato sauce, cumin and paprika.",
                    es: "Añade los pimientos en dados, la salsa de tomate, comino y pimentón."
                ),
                LocalizedText(
                    fr: "Vingt minutes à petit feu, à découvert. Plus c'est long, meilleur c'est.",
                    en: "Twenty minutes on a low heat, uncovered. The longer, the better.",
                    es: "Veinte minutos a fuego lento, destapado. Cuanto más tiempo, mejor."
                ),
            ]
        ),
        Recipe(
            id: "dinde-curry",
            name: LocalizedText(
                fr: "Curry de dinde, boulgour",
                en: "Turkey curry with bulgur",
                es: "Curry de pavo con bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "boulgour",
            fatID: "huile-colza", extraIDs: ["courgette", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais blondir l'oignon émincé, ajoute une cuillère de curry et laisse-la chauffer dix secondes.",
                    en: "Soften the sliced onion, add a spoon of curry powder and let it toast ten seconds.",
                    es: "Pocha la cebolla, añade una cucharada de curry y deja que se tueste diez segundos."
                ),
                LocalizedText(
                    fr: "Ajoute la dinde en dés et les courgettes, puis un fond d'eau.",
                    en: "Add the diced turkey and the courgettes, then a splash of water.",
                    es: "Añade el pavo en dados y los calabacines, y un poco de agua."
                ),
                LocalizedText(
                    fr: "Quinze minutes à couvert. Le boulgour gonfle à côté dans deux fois son volume d'eau bouillante.",
                    en: "Fifteen minutes covered. The bulgur swells alongside in twice its volume of boiling water.",
                    es: "Quince minutos tapado. El bulgur se hincha al lado en el doble de su volumen de agua."
                ),
            ]
        ),
        Recipe(
            id: "porc-polenta",
            name: LocalizedText(
                fr: "Filet mignon, polenta crémeuse",
                en: "Pork fillet with creamy polenta",
                es: "Solomillo de cerdo con polenta cremosa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "polenta",
            fatID: "creme-legere", extraIDs: ["champignons", "epinards"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Saisis le filet mignon entier sur toutes ses faces, puis quinze minutes à couvert, feu doux.",
                    en: "Sear the whole fillet on every side, then fifteen minutes covered, low heat.",
                    es: "Sella el solomillo entero por todas sus caras y quince minutos tapado a fuego suave."
                ),
                LocalizedText(
                    fr: "Sors-le et laisse-le reposer cinq minutes avant de trancher : c'est là qu'il reste tendre.",
                    en: "Take it out and rest it five minutes before slicing: that is what keeps it tender.",
                    es: "Sácalo y déjalo reposar cinco minutos antes de cortarlo: así queda tierno."
                ),
                LocalizedText(
                    fr: "Dans la même poêle, champignons puis épinards. La polenta cuit en cinq minutes avec la crème.",
                    en: "In the same pan, mushrooms then spinach. The polenta takes five minutes with the cream.",
                    es: "En la misma sartén, champiñones y luego espinacas. La polenta tarda cinco minutos con la nata."
                ),
            ]
        ),
        Recipe(
            id: "veau-semoule",
            name: LocalizedText(
                fr: "Escalope de veau, semoule aux légumes",
                en: "Veal escalope with vegetable couscous",
                es: "Escalope de ternera con sémola de verduras"
            ),
            slots: [.lunch, .dinner],
            proteinID: "veau-escalope", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["tomate", "courgette"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais revenir tomates et courgettes en dés dix minutes à l'huile d'olive.",
                    en: "Cook the diced tomatoes and courgettes ten minutes in olive oil.",
                    es: "Sofríe los tomates y calabacines en dados diez minutos en aceite de oliva."
                ),
                LocalizedText(
                    fr: "Verse la semoule sèche dessus, ajoute son volume d'eau bouillante, couvre et coupe le feu.",
                    en: "Pour the dry couscous over, add its volume of boiling water, cover and turn off the heat.",
                    es: "Echa la sémola seca encima, añade su volumen de agua hirviendo, tapa y apaga el fuego."
                ),
                LocalizedText(
                    fr: "Pendant les cinq minutes de repos, cuis les escalopes deux minutes par face.",
                    en: "During the five minutes it rests, cook the escalopes two minutes a side.",
                    es: "Durante los cinco minutos de reposo, haz los escalopes dos minutos por cara."
                ),
            ]
        ),
        Recipe(
            id: "saumon-patate-douce",
            name: LocalizedText(
                fr: "Saumon au four, patate douce",
                en: "Baked salmon with sweet potato",
                es: "Salmón al horno con boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon", carbID: "patate-douce",
            fatID: "huile-olive", extraIDs: ["brocoli", "fenouil"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Four à 190 °C. Patate douce en cubes et fenouil émincé sur la plaque, huile, vingt minutes.",
                    en: "Oven at 190 °C. Cubed sweet potato and sliced fennel on the tray, oil, twenty minutes.",
                    es: "Horno a 190 °C. Boniato en cubos e hinojo en láminas en la bandeja, aceite, veinte minutos."
                ),
                LocalizedText(
                    fr: "Pose le saumon et le brocoli dessus, remets douze minutes.",
                    en: "Lay the salmon and broccoli on top, back in for twelve minutes.",
                    es: "Coloca el salmón y el brócoli encima y hornea doce minutos más."
                ),
                LocalizedText(
                    fr: "Le saumon est cuit quand la chair se sépare toute seule. Une minute de trop et il sèche.",
                    en: "The salmon is done when the flesh flakes on its own. A minute more and it dries out.",
                    es: "El salmón está listo cuando la carne se separa sola. Un minuto más y se seca."
                ),
            ]
        ),
        Recipe(
            id: "cabillaud-ecrase",
            name: LocalizedText(
                fr: "Cabillaud poêlé, écrasé de pommes de terre",
                en: "Pan-fried cod with crushed potatoes",
                es: "Bacalao a la sartén con patata machacada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cabillaud", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["epinards", "poireau"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Cuis les pommes de terre à l'eau salée, puis écrase-les grossièrement à la fourchette avec l'huile.",
                    en: "Boil the potatoes in salted water, then crush them roughly with a fork and the oil.",
                    es: "Cuece las patatas en agua con sal y aplástalas con un tenedor junto con el aceite."
                ),
                LocalizedText(
                    fr: "Fais fondre le poireau émincé à feu doux, ajoute les épinards en fin de cuisson.",
                    en: "Sweat the sliced leek over low heat, add the spinach at the end.",
                    es: "Pocha el puerro a fuego suave y añade las espinacas al final."
                ),
                LocalizedText(
                    fr: "Le cabillaud, trois minutes côté peau, deux de l'autre. Il continue de cuire dans l'assiette.",
                    en: "The cod, three minutes skin down, two on the other side. It keeps cooking on the plate.",
                    es: "El bacalao, tres minutos por el lado de la piel, dos por el otro. Sigue cocinándose en el plato."
                ),
            ]
        ),
        Recipe(
            id: "thon-pates",
            name: LocalizedText(
                fr: "Pâtes au thon et aux tomates",
                en: "Tuna and tomato pasta",
                es: "Pasta con atún y tomate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "thon-boite", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["tomate", "courgette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Pendant que les pâtes cuisent, fais revenir les courgettes en rondelles.",
                    en: "While the pasta cooks, fry the sliced courgettes.",
                    es: "Mientras se cuece la pasta, saltea el calabacín en rodajas."
                ),
                LocalizedText(
                    fr: "Ajoute les tomates concassées, puis le thon égoutté hors du feu pour qu'il ne s'effrite pas.",
                    en: "Add the chopped tomatoes, then the drained tuna off the heat so it does not break up.",
                    es: "Añade el tomate troceado y el atún escurrido fuera del fuego para que no se deshaga."
                ),
                LocalizedText(
                    fr: "Une louche d'eau de cuisson lie la sauce mieux que n'importe quelle crème.",
                    en: "A ladle of pasta water binds the sauce better than any cream.",
                    es: "Un cucharón del agua de cocción liga la salsa mejor que cualquier nata."
                ),
            ]
        ),
        Recipe(
            id: "crevettes-vermicelles",
            name: LocalizedText(
                fr: "Crevettes sautées, vermicelles de riz",
                en: "Stir-fried prawns with rice noodles",
                es: "Gambas salteadas con fideos de arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crevettes", carbID: "vermicelles-riz",
            fatID: "huile-colza", extraIDs: ["poivron", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Les vermicelles ne cuisent pas : trois minutes dans l'eau bouillante hors du feu suffisent.",
                    en: "The noodles do not boil: three minutes in hot water off the heat is enough.",
                    es: "Los fideos no se cuecen: tres minutos en agua caliente fuera del fuego bastan."
                ),
                LocalizedText(
                    fr: "Poivrons à feu vif deux minutes, puis les crevettes, puis les germes de soja.",
                    en: "Peppers over high heat two minutes, then the prawns, then the bean sprouts.",
                    es: "Pimientos a fuego fuerte dos minutos, luego las gambas y después los brotes."
                ),
                LocalizedText(
                    fr: "Les crevettes sont cuites dès qu'elles se replient. Au-delà, elles deviennent caoutchouteuses.",
                    en: "The prawns are done the moment they curl. Beyond that they turn rubbery.",
                    es: "Las gambas están listas en cuanto se curvan. Más allá, se vuelven gomosas."
                ),
            ]
        ),
        Recipe(
            id: "truite-quinoa",
            name: LocalizedText(
                fr: "Truite, quinoa aux herbes",
                en: "Trout with herbed quinoa",
                es: "Trucha con quinoa a las hierbas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "truite", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["haricots-verts", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Rince le quinoa avant de le cuire : c'est ce qui enlève son amertume.",
                    en: "Rinse the quinoa before cooking: that is what removes its bitterness.",
                    es: "Enjuaga la quinoa antes de cocerla: eso le quita el amargor."
                ),
                LocalizedText(
                    fr: "Haricots verts à l'eau bouillante huit minutes, puis à l'eau froide pour garder le vert.",
                    en: "Green beans in boiling water eight minutes, then cold water to keep them green.",
                    es: "Judías verdes ocho minutos en agua hirviendo y luego agua fría para mantener el verde."
                ),
                LocalizedText(
                    fr: "La truite, quatre minutes par face à la poêle. Mélange le quinoa aux tomates, herbes et huile.",
                    en: "The trout, four minutes a side in the pan. Toss the quinoa with tomatoes, herbs and oil.",
                    es: "La trucha, cuatro minutos por cara. Mezcla la quinoa con tomate, hierbas y aceite."
                ),
            ]
        ),
        Recipe(
            id: "sardines-pommes-terre",
            name: LocalizedText(
                fr: "Sardines, pommes de terre tièdes",
                en: "Sardines with warm potatoes",
                es: "Sardinas con patatas templadas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "sardines", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["salade", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Cuis les pommes de terre en robe des champs, puis coupe-les en rondelles encore chaudes.",
                    en: "Boil the potatoes in their skins, then slice them while still hot.",
                    es: "Cuece las patatas con piel y córtalas en rodajas todavía calientes."
                ),
                LocalizedText(
                    fr: "Assaisonne-les tièdes : c'est là qu'elles prennent la vinaigrette, jamais froides.",
                    en: "Dress them warm: that is when they take the dressing, never cold.",
                    es: "Alíñalas templadas: es cuando cogen el aliño, nunca frías."
                ),
                LocalizedText(
                    fr: "Ajoute la salade, les tomates et les sardines. Aucune cuisson, dix minutes en tout.",
                    en: "Add the salad, tomatoes and sardines. No cooking, ten minutes in all.",
                    es: "Añade la ensalada, los tomates y las sardinas. Sin cocinar, diez minutos en total."
                ),
            ]
        ),
        Recipe(
            id: "omelette-pommes-terre",
            name: LocalizedText(
                fr: "Omelette aux champignons, pommes de terre sautées",
                en: "Mushroom omelette with sautéed potatoes",
                es: "Tortilla de champiñones con patatas salteadas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["champignons", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais dorer les pommes de terre déjà cuites, à feu moyen, sans les remuer trop souvent.",
                    en: "Brown the pre-cooked potatoes over medium heat, without stirring too often.",
                    es: "Dora las patatas ya cocidas a fuego medio, sin remover demasiado."
                ),
                LocalizedText(
                    fr: "Champignons à part, à feu vif : entassés, ils rendent leur eau et bouillent.",
                    en: "Mushrooms separately, over high heat: crowded, they release water and stew.",
                    es: "Champiñones aparte, a fuego fuerte: amontonados, sueltan agua y se cuecen."
                ),
                LocalizedText(
                    fr: "Verse les œufs battus sur les épinards, feu doux, et coupe le feu quand le centre tremble encore.",
                    en: "Pour the beaten eggs over the spinach, low heat, and stop while the centre still wobbles.",
                    es: "Vierte los huevos batidos sobre las espinacas, fuego suave, y apaga cuando el centro aún tiemble."
                ),
            ]
        ),
        Recipe(
            id: "dahl-lentilles",
            name: LocalizedText(
                fr: "Dahl de lentilles, riz basmati",
                en: "Lentil dhal with basmati rice",
                es: "Dahl de lentejas con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["tomate", "epinards"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer curcuma, cumin et gingembre dans l'huile avant tout le reste : c'est là que tout se joue.",
                    en: "Warm turmeric, cumin and ginger in the oil before anything else: that is where it is won.",
                    es: "Calienta cúrcuma, comino y jengibre en el aceite antes que nada: ahí se decide todo."
                ),
                LocalizedText(
                    fr: "Ajoute les lentilles et les tomates, couvre d'eau, vingt minutes à petits bouillons.",
                    en: "Add the lentils and tomatoes, cover with water, twenty minutes at a gentle simmer.",
                    es: "Añade las lentejas y los tomates, cubre de agua, veinte minutos a fuego lento."
                ),
                LocalizedText(
                    fr: "Les épinards en dernier, ils fondent en trente secondes. Sers sur le riz.",
                    en: "Spinach last, it wilts in thirty seconds. Serve over the rice.",
                    es: "Las espinacas al final, se deshacen en treinta segundos. Sirve sobre el arroz."
                ),
            ]
        ),
        Recipe(
            id: "curry-pois-chiches",
            name: LocalizedText(
                fr: "Curry de pois chiches, semoule",
                en: "Chickpea curry with couscous",
                es: "Curry de garbanzos con sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["courgette", "poivron"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Poivrons et courgettes en dés, dix minutes à l'huile avec une cuillère de curry.",
                    en: "Diced peppers and courgettes, ten minutes in oil with a spoon of curry powder.",
                    es: "Pimientos y calabacines en dados, diez minutos en aceite con una cucharada de curry."
                ),
                LocalizedText(
                    fr: "Ajoute les pois chiches égouttés et un verre d'eau, dix minutes de plus.",
                    en: "Add the drained chickpeas and a glass of water, ten minutes more.",
                    es: "Añade los garbanzos escurridos y un vaso de agua, diez minutos más."
                ),
                LocalizedText(
                    fr: "Écrase quelques pois chiches à la fourchette : ce sont eux qui épaississent la sauce.",
                    en: "Crush a few chickpeas with a fork: they are what thickens the sauce.",
                    es: "Aplasta algunos garbanzos con el tenedor: son los que espesan la salsa."
                ),
            ]
        ),
        Recipe(
            id: "tofu-sesame",
            name: LocalizedText(
                fr: "Tofu sauté au sésame, riz complet",
                en: "Sesame tofu stir-fry with brown rice",
                es: "Tofu salteado al sésamo con arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu", carbID: "riz-complet",
            fatID: "graines-sesame", extraIDs: ["brocoli", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Presse le tofu dix minutes sous un poids : sans ça, il ne dorera jamais.",
                    en: "Press the tofu ten minutes under a weight: without that it will never brown.",
                    es: "Prensa el tofu diez minutos bajo un peso: sin eso, nunca se dorará."
                ),
                LocalizedText(
                    fr: "Coupe-le en cubes et fais-les dorer sur toutes leurs faces, sans y toucher entre deux.",
                    en: "Cube it and brown the cubes on every side, without touching them in between.",
                    es: "Córtalo en dados y dóralos por todas sus caras, sin tocarlos entre medias."
                ),
                LocalizedText(
                    fr: "Ajoute brocoli et carottes, un filet de sauce soja, et les graines de sésame hors du feu.",
                    en: "Add broccoli and carrots, a dash of soy sauce, and the sesame seeds off the heat.",
                    es: "Añade brócoli y zanahorias, un chorro de salsa de soja, y el sésamo fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-patate-douce",
            name: LocalizedText(
                fr: "Tempeh poêlé, patate douce rôtie",
                en: "Pan-fried tempeh with roast sweet potato",
                es: "Tempeh a la sartén con boniato asado"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "patate-douce",
            fatID: "huile-olive", extraIDs: ["chou-kale", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Patate douce en cubes au four, 200 °C, vingt-cinq minutes.",
                    en: "Cubed sweet potato in the oven, 200 °C, twenty-five minutes.",
                    es: "Boniato en cubos al horno, 200 °C, veinticinco minutos."
                ),
                LocalizedText(
                    fr: "Fais dorer le tempeh en tranches avec l'oignon, puis déglace au vinaigre ou à la sauce soja.",
                    en: "Brown the sliced tempeh with the onion, then deglaze with vinegar or soy sauce.",
                    es: "Dora el tempeh en lonchas con la cebolla y desglasa con vinagre o salsa de soja."
                ),
                LocalizedText(
                    fr: "Le kale a besoin d'être massé à l'huile une minute avant cuisson, sinon il reste coriace.",
                    en: "The kale needs a minute massaged with oil before cooking, otherwise it stays tough.",
                    es: "El kale necesita un minuto masajeado con aceite antes de cocinarlo, si no queda duro."
                ),
            ]
        ),
        Recipe(
            id: "chili-haricots",
            name: LocalizedText(
                fr: "Chili de haricots rouges, riz blanc",
                en: "Red bean chilli with white rice",
                es: "Chili de alubias rojas con arroz blanco"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-rouges", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Oignon et poivrons à l'huile, puis cumin, paprika fumé et une pincée de cannelle.",
                    en: "Onion and peppers in oil, then cumin, smoked paprika and a pinch of cinnamon.",
                    es: "Cebolla y pimientos en aceite, luego comino, pimentón ahumado y una pizca de canela."
                ),
                LocalizedText(
                    fr: "Sauce tomate et haricots rincés, vingt minutes à découvert.",
                    en: "Tomato sauce and rinsed beans, twenty minutes uncovered.",
                    es: "Salsa de tomate y alubias enjuagadas, veinte minutos destapado."
                ),
                LocalizedText(
                    fr: "Il est meilleur réchauffé le lendemain : c'est un plat qui gagne à être fait en double.",
                    en: "It is better reheated the next day: a dish worth making twice the amount.",
                    es: "Está mejor recalentado al día siguiente: un plato que conviene hacer en doble."
                ),
            ]
        ),
        Recipe(
            id: "seitan-poivrons",
            name: LocalizedText(
                fr: "Seitan aux poivrons, boulgour",
                en: "Seitan with peppers and bulgur",
                es: "Seitán con pimientos y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "seitan", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Tranche le seitan finement et fais-le dorer à feu vif, il a besoin de couleur pour avoir du goût.",
                    en: "Slice the seitan thinly and brown it over high heat; it needs colour to taste of anything.",
                    es: "Corta el seitán fino y dóralo a fuego fuerte: necesita color para tener sabor."
                ),
                LocalizedText(
                    fr: "Ajoute poivrons et oignons émincés, huit minutes, avec du paprika.",
                    en: "Add the sliced peppers and onions, eight minutes, with paprika.",
                    es: "Añade los pimientos y cebollas en tiras, ocho minutos, con pimentón."
                ),
                LocalizedText(
                    fr: "Le boulgour gonfle à côté dans deux fois son volume d'eau bouillante, hors du feu.",
                    en: "The bulgur swells alongside in twice its volume of boiling water, off the heat.",
                    es: "El bulgur se hincha al lado en el doble de su volumen de agua hirviendo, fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "haricots-blancs-tomate",
            name: LocalizedText(
                fr: "Haricots blancs à la tomate, polenta",
                en: "White beans in tomato with polenta",
                es: "Alubias blancas con tomate y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-blancs", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais revenir l'ail et le romarin dans l'huile, sans les brûler.",
                    en: "Cook the garlic and rosemary in the oil, without burning them.",
                    es: "Sofríe el ajo y el romero en el aceite, sin quemarlos."
                ),
                LocalizedText(
                    fr: "Ajoute la sauce tomate et les haricots, quinze minutes à feu doux.",
                    en: "Add the tomato sauce and the beans, fifteen minutes on a low heat.",
                    es: "Añade la salsa de tomate y las alubias, quince minutos a fuego suave."
                ),
                LocalizedText(
                    fr: "Épinards en dernier. La polenta se fait en cinq minutes, en fouettant sans arrêt.",
                    en: "Spinach last. The polenta takes five minutes, whisking without stopping.",
                    es: "Espinacas al final. La polenta se hace en cinco minutos, batiendo sin parar."
                ),
            ]
        ),
        Recipe(
            id: "jambon-gratin-chou-fleur",
            name: LocalizedText(
                fr: "Gratin de chou-fleur au jambon, pommes de terre",
                en: "Cauliflower and ham gratin with potatoes",
                es: "Gratinado de coliflor con jamón y patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "jambon-blanc", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["chou-fleur", "oignon"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Cuis chou-fleur et pommes de terre à l'eau, en gros morceaux, dix minutes : ils finiront au four.",
                    en: "Boil the cauliflower and potatoes in big pieces, ten minutes: the oven finishes them.",
                    es: "Cuece la coliflor y las patatas en trozos grandes, diez minutos: el horno los termina."
                ),
                LocalizedText(
                    fr: "Égoutte-les très soigneusement. C'est l'eau restante qui rate un gratin, jamais autre chose.",
                    en: "Drain them thoroughly. Leftover water is what ruins a gratin, never anything else.",
                    es: "Escúrrelos muy bien. El agua que queda es lo que arruina un gratinado, nunca otra cosa."
                ),
                LocalizedText(
                    fr: "Mélange au jambon en dés, à l'oignon et à la crème, puis vingt minutes à 200 °C.",
                    en: "Mix with the diced ham, the onion and the cream, then twenty minutes at 200 °C.",
                    es: "Mezcla con el jamón en dados, la cebolla y la nata, y veinte minutos a 200 °C."
                ),
            ]
        ),
    ]

    // MARK: - Petits-déjeuners

    /// Le repas le plus rentable à corriger, et celui qu'on saute le plus.
    ///
    /// D'où des préparations courtes : au-delà de dix minutes un matin de
    /// semaine, un petit-déjeuner ne se fait pas, quelles que soient ses
    /// qualités nutritionnelles.
    static let breakfasts: [Recipe] = [
        Recipe(
            id: "porridge-myrtilles",
            name: LocalizedText(
                fr: "Porridge aux myrtilles et amandes",
                en: "Blueberry and almond porridge",
                es: "Porridge de arándanos y almendras"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "flocons-avoine",
            fatID: "amandes", extraIDs: ["myrtilles"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer les flocons dans l'eau ou le lait, cinq minutes, en remuant.",
                    en: "Heat the oats in water or milk, five minutes, stirring.",
                    es: "Calienta los copos en agua o leche, cinco minutos, removiendo."
                ),
                LocalizedText(
                    fr: "Ajoute le skyr hors du feu : chauffé, il tranche et devient granuleux.",
                    en: "Add the skyr off the heat: heated, it splits and turns grainy.",
                    es: "Añade el skyr fuera del fuego: calentado, se corta y queda granuloso."
                ),
                LocalizedText(
                    fr: "Myrtilles et amandes concassées par-dessus.",
                    en: "Blueberries and crushed almonds on top.",
                    es: "Arándanos y almendras picadas por encima."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-brouilles-pain",
            name: LocalizedText(
                fr: "Œufs brouillés, pain complet",
                en: "Scrambled eggs on wholemeal toast",
                es: "Huevos revueltos con pan integral"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-complet",
            fatID: "beurre", extraIDs: ["pomme"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Feu doux, beurre fondu, œufs battus : les œufs brouillés ratent toujours par excès de feu.",
                    en: "Low heat, melted butter, beaten eggs: scrambled eggs fail from too much heat, always.",
                    es: "Fuego suave, mantequilla derretida, huevos batidos: los revueltos fallan por exceso de fuego."
                ),
                LocalizedText(
                    fr: "Remue sans arrêt et retire du feu quand ils sont encore un peu coulants.",
                    en: "Stir constantly and take them off while still a little runny.",
                    es: "Remueve sin parar y retíralos cuando aún estén algo cremosos."
                ),
                LocalizedText(
                    fr: "Pain grillé, pomme à côté.",
                    en: "Toast, apple alongside.",
                    es: "Pan tostado, manzana al lado."
                ),
            ]
        ),
        Recipe(
            id: "bol-fromage-blanc",
            name: LocalizedText(
                fr: "Bol de fromage blanc, muesli et banane",
                en: "Fromage blanc bowl with muesli and banana",
                es: "Bol de queso fresco con muesli y plátano"
            ),
            slots: [.breakfast],
            proteinID: "fromage-blanc", carbID: "muesli-nature",
            fatID: "noix", extraIDs: ["banane"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Fromage blanc au fond, muesli par-dessus, banane en rondelles, noix concassées.",
                    en: "Fromage blanc in the bowl, muesli over it, sliced banana, crushed walnuts.",
                    es: "Queso fresco en el fondo, muesli encima, plátano en rodajas, nueces picadas."
                ),
                LocalizedText(
                    fr: "Aucune cuisson. C'est le petit-déjeuner des matins où il n'y a pas le temps.",
                    en: "No cooking. This is the breakfast for mornings with no time.",
                    es: "Sin cocinar. Es el desayuno de las mañanas sin tiempo."
                ),
            ]
        ),
        Recipe(
            id: "tofu-brouille",
            name: LocalizedText(
                fr: "Tofu brouillé, pain complet et avocat",
                en: "Scrambled tofu with wholemeal bread and avocado",
                es: "Tofu revuelto con pan integral y aguacate"
            ),
            slots: [.breakfast],
            proteinID: "tofu", carbID: "pain-complet",
            fatID: "avocat", extraIDs: ["orange"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Émiette le tofu à la main dans la poêle chaude, il doit perdre son eau avant de dorer.",
                    en: "Crumble the tofu by hand into the hot pan; it must lose its water before browning.",
                    es: "Desmenuza el tofu con la mano en la sartén caliente: debe soltar su agua antes de dorarse."
                ),
                LocalizedText(
                    fr: "Curcuma et un peu de levure maltée lui donnent la couleur et le goût de l'œuf brouillé.",
                    en: "Turmeric and a little nutritional yeast give it the colour and taste of scrambled egg.",
                    es: "Cúrcuma y un poco de levadura nutricional le dan el color y el sabor del huevo revuelto."
                ),
                LocalizedText(
                    fr: "Avocat écrasé sur le pain grillé, orange à côté.",
                    en: "Mashed avocado on the toast, orange alongside.",
                    es: "Aguacate aplastado sobre el pan tostado, naranja al lado."
                ),
            ]
        ),
        Recipe(
            id: "bol-soja-chia",
            name: LocalizedText(
                fr: "Yaourt de soja, avoine et graines de chia",
                en: "Soy yoghurt with oats and chia seeds",
                es: "Yogur de soja con avena y semillas de chía"
            ),
            slots: [.breakfast],
            proteinID: "yaourt-soja", carbID: "flocons-avoine",
            fatID: "graines-chia", extraIDs: ["framboises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Mélange yaourt, flocons et chia la veille au soir, au réfrigérateur.",
                    en: "Mix the yoghurt, oats and chia the night before, in the fridge.",
                    es: "Mezcla el yogur, los copos y la chía la noche anterior, en la nevera."
                ),
                LocalizedText(
                    fr: "Le chia absorbe dix fois son poids en eau : c'est lui qui donne la texture, pas le temps de pose.",
                    en: "Chia absorbs ten times its weight in water: that is what gives the texture, not the waiting.",
                    es: "La chía absorbe diez veces su peso en agua: eso da la textura, no el tiempo de reposo."
                ),
                LocalizedText(
                    fr: "Framboises au moment de manger.",
                    en: "Raspberries when you eat it.",
                    es: "Frambuesas al momento de comer."
                ),
            ]
        ),
        Recipe(
            id: "cottage-galettes",
            name: LocalizedText(
                fr: "Cottage cheese, galettes de riz et kiwi",
                en: "Cottage cheese with rice cakes and kiwi",
                es: "Requesón con tortitas de arroz y kiwi"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "galettes-riz",
            fatID: "puree-amande", extraIDs: ["kiwi"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Purée d'amande sur les galettes, cottage cheese par-dessus, kiwi en rondelles.",
                    en: "Almond butter on the rice cakes, cottage cheese over it, sliced kiwi.",
                    es: "Puré de almendra sobre las tortitas, requesón encima, kiwi en rodajas."
                ),
                LocalizedText(
                    fr: "Sans gluten, sans cuisson, et trente grammes de protéines. Poivre du moulin sur le cottage.",
                    en: "Gluten-free, no cooking, thirty grams of protein. Cracked pepper on the cottage cheese.",
                    es: "Sin gluten, sin cocinar, treinta gramos de proteína. Pimienta recién molida sobre el requesón."
                ),
            ]
        ),
        Recipe(
            id: "skyr-sarrasin",
            name: LocalizedText(
                fr: "Skyr, sarrasin grillé et poire",
                en: "Skyr with toasted buckwheat and pear",
                es: "Skyr con trigo sarraceno tostado y pera"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "sarrasin",
            fatID: "noisettes", extraIDs: ["poire"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Fais griller le sarrasin cuit à sec deux minutes : il devient croquant et sent la noisette.",
                    en: "Toast the cooked buckwheat dry for two minutes: it turns crunchy and smells of hazelnut.",
                    es: "Tuesta el trigo sarraceno cocido en seco dos minutos: queda crujiente y huele a avellana."
                ),
                LocalizedText(
                    fr: "Skyr dans le bol, sarrasin et noisettes dessus, poire en dés.",
                    en: "Skyr in the bowl, buckwheat and hazelnuts over it, diced pear.",
                    es: "Skyr en el bol, trigo sarraceno y avellanas encima, pera en dados."
                ),
            ]
        ),
        Recipe(
            id: "petit-suisse-seigle",
            name: LocalizedText(
                fr: "Petits-suisses, tartines de seigle et fraises",
                en: "Petits-suisses with rye crispbread and strawberries",
                es: "Petit-suisse con tostadas de centeno y fresas"
            ),
            slots: [.breakfast],
            proteinID: "petit-suisse", carbID: "cracottes-seigle",
            fatID: "graines-tournesol", extraIDs: ["fraises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Écrase les petits-suisses sur les tartines, ajoute les graines de tournesol.",
                    en: "Spread the petits-suisses on the crispbread, add the sunflower seeds.",
                    es: "Extiende el petit-suisse sobre las tostadas y añade las pipas de girasol."
                ),
                LocalizedText(
                    fr: "Fraises coupées à côté, un tour de moulin à poivre si tu oses — ça marche.",
                    en: "Sliced strawberries alongside, a twist of pepper if you dare — it works.",
                    es: "Fresas cortadas al lado, una vuelta de pimienta si te atreves: funciona."
                ),
            ]
        ),
    ]

    // MARK: - Interrogation

    public static let index: [String: Recipe] =
        Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    public static func recipe(id: String) -> Recipe? { index[id] }

    /// Les plats servables à ce moment, pour ce régime, sans les aliments
    /// refusés — et sans rien de rang occasionnel.
    ///
    /// L'ordre du catalogue est conservé : c'est lui qui rend le choix
    /// reproductible d'une exécution à l'autre, et donc vérifiable.
    public static func available(
        slot: MealSlot,
        diet: DietPreference,
        excluding excluded: Set<String> = []
    ) -> [Recipe] {
        all.filter { recipe in
            recipe.slots.contains(slot)
                && recipe.suits(diet)
                && !recipe.excludes(excluded)
                && recipe.tier < .occasional
        }
    }
}
