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
        Recipe(
            id: "dinde-riz-cajun",
            name: LocalizedText(
                fr: "Dinde cajun, riz basmati",
                en: "Cajun turkey with basmati rice",
                es: "Pavo cajún con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Mélange paprika fumé, ail, origan et poivre de Cayenne, et enrobe la dinde en dés.",
                    en: "Mix smoked paprika, garlic, oregano and cayenne, and coat the diced turkey.",
                    es: "Mezcla pimentón ahumado, ajo, orégano y cayena, y reboza el pavo en dados."
                ),
                LocalizedText(
                    fr: "Poêle très chaude, en une seule couche : entassée, la viande bout au lieu de dorer.",
                    en: "Very hot pan, in a single layer: crowded, the meat stews instead of browning.",
                    es: "Sartén muy caliente, en una sola capa: amontonada, la carne se cuece en vez de dorarse."
                ),
                LocalizedText(
                    fr: "Ajoute poivrons et oignons, huit minutes, et sers sur le riz.",
                    en: "Add peppers and onions, eight minutes, and serve over the rice.",
                    es: "Añade pimientos y cebollas, ocho minutos, y sirve sobre el arroz."
                ),
            ]
        ),
        Recipe(
            id: "poulet-citron-boulgour",
            name: LocalizedText(
                fr: "Poulet au citron, boulgour",
                en: "Lemon chicken with bulgur",
                es: "Pollo al limón con bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["courgette", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais mariner le poulet dix minutes dans le jus de citron, l'ail et l'huile.",
                    en: "Marinate the chicken ten minutes in lemon juice, garlic and oil.",
                    es: "Marina el pollo diez minutos en zumo de limón, ajo y aceite."
                ),
                LocalizedText(
                    fr: "Saisis-le à feu vif, puis baisse et couvre cinq minutes.",
                    en: "Sear it over high heat, then lower and cover for five minutes.",
                    es: "Séllalo a fuego fuerte, baja y tapa cinco minutos."
                ),
                LocalizedText(
                    fr: "Courgettes et tomates dans la même poêle, boulgour gonflé à côté.",
                    en: "Courgettes and tomatoes in the same pan, bulgur swollen alongside.",
                    es: "Calabacín y tomate en la misma sartén, bulgur hinchado al lado."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-bourguignon-simple",
            name: LocalizedText(
                fr: "Bœuf mijoté aux carottes, pommes de terre",
                en: "Braised beef with carrots and potatoes",
                es: "Ternera guisada con zanahoria y patata"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-15", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "oignon"],
            minutes: 55,
            steps: [
                LocalizedText(
                    fr: "Fais dorer la viande par petites quantités : c'est la couleur qui fait le goût.",
                    en: "Brown the meat in small batches: the colour is what makes the flavour.",
                    es: "Dora la carne en tandas pequeñas: el color es lo que da el sabor."
                ),
                LocalizedText(
                    fr: "Ajoute oignons et carottes, mouille à hauteur, thym et laurier.",
                    en: "Add onions and carrots, cover with liquid, thyme and bay.",
                    es: "Añade cebolla y zanahoria, cubre de líquido, tomillo y laurel."
                ),
                LocalizedText(
                    fr: "Quarante minutes à couvert, feu très doux. Les pommes de terre rejoignent à mi-cuisson.",
                    en: "Forty minutes covered, very low heat. The potatoes join halfway.",
                    es: "Cuarenta minutos tapado a fuego muy suave. Las patatas entran a mitad."
                ),
            ]
        ),
        Recipe(
            id: "colin-poireaux",
            name: LocalizedText(
                fr: "Colin à la crème de poireaux, riz",
                en: "Hake with creamed leeks and rice",
                es: "Merluza con puerros a la crema y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "colin-lieu", carbID: "riz-blanc",
            fatID: "creme-legere", extraIDs: ["poireau", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Émince les poireaux finement et fais-les fondre à couvert, dix minutes, sans coloration.",
                    en: "Slice the leeks thinly and sweat them covered, ten minutes, without colour.",
                    es: "Corta los puerros finos y póchalos tapados diez minutos, sin que tomen color."
                ),
                LocalizedText(
                    fr: "Ajoute la crème et les carottes en rondelles, laisse épaissir.",
                    en: "Add the cream and the sliced carrots, let it thicken.",
                    es: "Añade la nata y la zanahoria en rodajas, deja espesar."
                ),
                LocalizedText(
                    fr: "Pose le colin dessus, couvre, huit minutes : il cuit à la vapeur de la sauce.",
                    en: "Lay the hake on top, cover, eight minutes: it steams in the sauce.",
                    es: "Coloca la merluza encima, tapa, ocho minutos: se cuece al vapor de la salsa."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-saucisse-vegetale",
            name: LocalizedText(
                fr: "Lentilles aux légumes, riz complet",
                en: "Lentils with vegetables and brown rice",
                es: "Lentejas con verduras y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["carotte", "celeri-branche"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Carottes, céleri et oignon en petits dés, dix minutes à l'huile : c'est la base de tout.",
                    en: "Carrot, celery and onion finely diced, ten minutes in oil: the base of everything.",
                    es: "Zanahoria, apio y cebolla en dados pequeños, diez minutos en aceite: la base de todo."
                ),
                LocalizedText(
                    fr: "Ajoute les lentilles et deux fois leur volume d'eau, laurier, vingt-cinq minutes.",
                    en: "Add the lentils and twice their volume of water, bay leaf, twenty-five minutes.",
                    es: "Añade las lentejas y el doble de su volumen de agua, laurel, veinticinco minutos."
                ),
                LocalizedText(
                    fr: "Sale seulement à la fin : le sel en début de cuisson durcit la peau des lentilles.",
                    en: "Salt only at the end: salt early toughens the skins.",
                    es: "Sala solo al final: la sal al principio endurece la piel de las lentejas."
                ),
            ]
        ),
        Recipe(
            id: "thon-riz-poivrons",
            name: LocalizedText(
                fr: "Riz sauté au thon et aux poivrons",
                en: "Tuna and pepper fried rice",
                es: "Arroz salteado con atún y pimientos"
            ),
            slots: [.lunch, .dinner],
            proteinID: "thon-boite", carbID: "riz-blanc",
            fatID: "huile-colza", extraIDs: ["poivron", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le riz de la veille est meilleur : froid, il ne colle pas et saute vraiment.",
                    en: "Yesterday's rice is better: cold, it does not stick and really fries.",
                    es: "El arroz del día anterior es mejor: frío, no se pega y saltea de verdad."
                ),
                LocalizedText(
                    fr: "Poivrons à feu vif, puis le riz, puis les germes de soja.",
                    en: "Peppers over high heat, then the rice, then the bean sprouts.",
                    es: "Pimientos a fuego fuerte, luego el arroz y después los brotes."
                ),
                LocalizedText(
                    fr: "Le thon en dernier, hors du feu, pour qu'il reste en morceaux.",
                    en: "Tuna last, off the heat, so it stays in pieces.",
                    es: "El atún al final, fuera del fuego, para que quede en trozos."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-epinards",
            name: LocalizedText(
                fr: "Pois chiches aux épinards, riz",
                en: "Chickpeas with spinach and rice",
                es: "Garbanzos con espinacas y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["epinards", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Ail et cumin dans l'huile, trente secondes, jusqu'à ce que ça sente.",
                    en: "Garlic and cumin in the oil, thirty seconds, until it smells.",
                    es: "Ajo y comino en el aceite, treinta segundos, hasta que huela."
                ),
                LocalizedText(
                    fr: "Tomates concassées et pois chiches égouttés, quinze minutes.",
                    en: "Chopped tomatoes and drained chickpeas, fifteen minutes.",
                    es: "Tomate troceado y garbanzos escurridos, quince minutos."
                ),
                LocalizedText(
                    fr: "Épinards en dernier, ils fondent en trente secondes. Un trait de vinaigre réveille tout.",
                    en: "Spinach last, it wilts in thirty seconds. A dash of vinegar wakes it all up.",
                    es: "Espinacas al final, se deshacen en treinta segundos. Un chorro de vinagre lo despierta."
                ),
            ]
        ),
        Recipe(
            id: "dorade-four",
            name: LocalizedText(
                fr: "Dorade au four, pommes de terre et fenouil",
                en: "Baked sea bream with potatoes and fennel",
                es: "Dorada al horno con patatas e hinojo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dorade", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["fenouil", "tomate"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre en fines rondelles et fenouil émincé au fond du plat, huile, sel.",
                    en: "Thinly sliced potatoes and fennel in the dish, oil, salt.",
                    es: "Patatas en rodajas finas e hinojo en el fondo de la fuente, aceite, sal."
                ),
                LocalizedText(
                    fr: "Vingt minutes à 200 °C, puis pose la dorade et les tomates dessus.",
                    en: "Twenty minutes at 200 °C, then lay the bream and tomatoes on top.",
                    es: "Veinte minutos a 200 °C, luego coloca la dorada y los tomates encima."
                ),
                LocalizedText(
                    fr: "Encore quinze minutes. L'œil du poisson devient blanc quand c'est cuit.",
                    en: "Fifteen minutes more. The fish's eye turns white when it is done.",
                    es: "Quince minutos más. El ojo del pescado se vuelve blanco cuando está listo."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-plat-haricots",
            name: LocalizedText(
                fr: "Œufs au plat à la tomate, pommes de terre sautées",
                en: "Fried eggs in tomato with sautéed potatoes",
                es: "Huevos fritos con alubias en tomate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer la sauce tomate avec du paprika, ajoute les épinards.",
                    en: "Heat the tomato sauce with paprika, add the spinach.",
                    es: "Calienta la salsa de tomate con pimentón y añade las espinacas."
                ),
                LocalizedText(
                    fr: "Casse les œufs directement dedans, couvre, quatre minutes.",
                    en: "Crack the eggs straight in, cover, four minutes.",
                    es: "Casca los huevos directamente encima, tapa, cuatro minutos."
                ),
                LocalizedText(
                    fr: "Le blanc doit être pris et le jaune coulant. Pommes de terre sautées à côté.",
                    en: "The white set, the yolk running. Sautéed potatoes alongside.",
                    es: "La clara cuajada y la yema líquida. Patatas salteadas al lado."
                ),
            ]
        ),
        Recipe(
            id: "crevettes-riz-coco",
            name: LocalizedText(
                fr: "Crevettes au curry, riz basmati",
                en: "Curried prawns with basmati rice",
                es: "Gambas al curry con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crevettes", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["poivron", "epinards"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer la pâte de curry dans l'huile avant tout le reste.",
                    en: "Warm the curry paste in the oil before anything else.",
                    es: "Calienta la pasta de curry en el aceite antes que nada."
                ),
                LocalizedText(
                    fr: "Poivrons trois minutes, puis les crevettes, puis les épinards.",
                    en: "Peppers three minutes, then the prawns, then the spinach.",
                    es: "Pimientos tres minutos, luego las gambas y después las espinacas."
                ),
                LocalizedText(
                    fr: "Deux minutes de plus et les crevettes deviennent caoutchouteuses. Coupe le feu tôt.",
                    en: "Two minutes more and the prawns turn rubbery. Cut the heat early.",
                    es: "Dos minutos más y las gambas se vuelven gomosas. Apaga pronto."
                ),
            ]
        ),
        Recipe(
            id: "porc-pommes-boulgour",
            name: LocalizedText(
                fr: "Porc aux pommes, boulgour",
                en: "Pork with apples and bulgur",
                es: "Cerdo con manzana y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-echine", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["oignon", "chou"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Fais dorer le porc en tranches épaisses, deux minutes par face, puis réserve.",
                    en: "Brown the thick pork slices, two minutes a side, then set aside.",
                    es: "Dora el cerdo en lonchas gruesas, dos minutos por cara, y reserva."
                ),
                LocalizedText(
                    fr: "Oignons et chou émincé dans la même poêle, dix minutes à couvert.",
                    en: "Onions and sliced cabbage in the same pan, ten minutes covered.",
                    es: "Cebolla y col en juliana en la misma sartén, diez minutos tapado."
                ),
                LocalizedText(
                    fr: "Remets le porc, un fond de cidre ou de bouillon, quinze minutes.",
                    en: "Return the pork, a splash of cider or stock, fifteen minutes.",
                    es: "Devuelve el cerdo, un chorro de sidra o caldo, quince minutos."
                ),
            ]
        ),
        Recipe(
            id: "tofu-curry-patate",
            name: LocalizedText(
                fr: "Curry de tofu, patate douce",
                en: "Tofu and sweet potato curry",
                es: "Curry de tofu y boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu-fume", carbID: "patate-douce",
            fatID: "huile-colza", extraIDs: ["epinards", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Patate douce en cubes, dix minutes à l'eau bouillante : elle finira dans la sauce.",
                    en: "Sweet potato in cubes, ten minutes in boiling water: it finishes in the sauce.",
                    es: "Boniato en cubos, diez minutos en agua hirviendo: termina en la salsa."
                ),
                LocalizedText(
                    fr: "Curry et gingembre dans l'huile, puis tomates et tofu fumé en dés.",
                    en: "Curry and ginger in the oil, then tomatoes and diced smoked tofu.",
                    es: "Curry y jengibre en el aceite, luego tomate y tofu ahumado en dados."
                ),
                LocalizedText(
                    fr: "Ajoute la patate douce et les épinards, dix minutes à petit feu.",
                    en: "Add the sweet potato and spinach, ten minutes on a low heat.",
                    es: "Añade el boniato y las espinacas, diez minutos a fuego suave."
                ),
            ]
        ),
        Recipe(
            id: "dinde-hachis",
            name: LocalizedText(
                fr: "Hachis de dinde, purée de pommes de terre",
                en: "Turkey shepherd's pie",
                es: "Pastel de pavo con puré de patata"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["carotte", "oignon"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Fais revenir la dinde hachée avec les carottes et les oignons en petits dés.",
                    en: "Cook the minced turkey with finely diced carrots and onions.",
                    es: "Sofríe el pavo picado con zanahoria y cebolla en dados pequeños."
                ),
                LocalizedText(
                    fr: "Écrase les pommes de terre cuites avec la crème, sans mixeur : le mixeur fait de la colle.",
                    en: "Mash the boiled potatoes with the cream, no blender: a blender makes glue.",
                    es: "Machaca las patatas cocidas con la nata, sin batidora: la batidora hace pegamento."
                ),
                LocalizedText(
                    fr: "Monte en couches, vingt minutes à 200 °C, jusqu'à ce que le dessus dore.",
                    en: "Layer it up, twenty minutes at 200 °C, until the top browns.",
                    es: "Monta por capas, veinte minutos a 200 °C, hasta que la superficie se dore."
                ),
            ]
        ),
        Recipe(
            id: "maquereau-quinoa",
            name: LocalizedText(
                fr: "Maquereau, quinoa et betterave",
                en: "Mackerel with quinoa and beetroot",
                es: "Caballa con quinoa y remolacha"
            ),
            slots: [.lunch, .dinner],
            proteinID: "maquereau", carbID: "quinoa",
            fatID: "huile-noix", extraIDs: ["betterave", "roquette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le quinoa cuit en douze minutes, rincé avant pour ôter l'amertume.",
                    en: "Quinoa cooks in twelve minutes, rinsed first to remove bitterness.",
                    es: "La quinoa se hace en doce minutos, enjuagada antes para quitar el amargor."
                ),
                LocalizedText(
                    fr: "Betterave cuite en dés, roquette, huile de noix et vinaigre.",
                    en: "Diced cooked beetroot, rocket, walnut oil and vinegar.",
                    es: "Remolacha cocida en dados, rúcula, aceite de nuez y vinagre."
                ),
                LocalizedText(
                    fr: "Le maquereau se pose dessus, à peine réchauffé. Aucune cuisson longue.",
                    en: "The mackerel goes on top, barely warmed. No long cooking.",
                    es: "La caballa se pone encima, apenas templada. Nada de cocciones largas."
                ),
            ]
        ),
        Recipe(
            id: "haricots-noirs-polenta",
            name: LocalizedText(
                fr: "Haricots noirs épicés, polenta",
                en: "Spiced black beans with polenta",
                es: "Alubias negras especiadas con polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-noirs", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Oignon et poivron à l'huile, puis cumin, paprika et un peu de cacao amer.",
                    en: "Onion and pepper in oil, then cumin, paprika and a little bitter cocoa.",
                    es: "Cebolla y pimiento en aceite, luego comino, pimentón y un poco de cacao amargo."
                ),
                LocalizedText(
                    fr: "Haricots rincés et un verre d'eau, quinze minutes à découvert.",
                    en: "Rinsed beans and a glass of water, fifteen minutes uncovered.",
                    es: "Alubias enjuagadas y un vaso de agua, quince minutos destapado."
                ),
                LocalizedText(
                    fr: "La polenta se fouette cinq minutes sans s'arrêter, sinon elle fait des grumeaux.",
                    en: "Whisk the polenta five minutes without stopping, or it turns lumpy.",
                    es: "Bate la polenta cinco minutos sin parar, si no se hace grumos."
                ),
            ]
        ),
        Recipe(
            id: "veau-champignons",
            name: LocalizedText(
                fr: "Veau aux champignons, pâtes",
                en: "Veal with mushrooms and pasta",
                es: "Ternera con champiñones y pasta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "veau-escalope", carbID: "pates-completes",
            fatID: "creme-legere", extraIDs: ["champignons", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Champignons à feu vif, en une seule couche, sans sel au début : le sel les fait rendre leur eau.",
                    en: "Mushrooms over high heat, in one layer, no salt at first: salt draws their water.",
                    es: "Champiñones a fuego fuerte, en una capa, sin sal al principio: la sal los hace soltar agua."
                ),
                LocalizedText(
                    fr: "Veau en lanières, deux minutes, puis la crème et les épinards.",
                    en: "Veal in strips, two minutes, then the cream and spinach.",
                    es: "Ternera en tiras, dos minutos, luego la nata y las espinacas."
                ),
                LocalizedText(
                    fr: "Une louche d'eau de cuisson des pâtes lie la sauce.",
                    en: "A ladle of pasta water binds the sauce.",
                    es: "Un cucharón del agua de la pasta liga la salsa."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-nouilles",
            name: LocalizedText(
                fr: "Tempeh sauté, vermicelles de riz",
                en: "Tempeh stir-fry with rice noodles",
                es: "Tempeh salteado con fideos de arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "vermicelles-riz",
            fatID: "huile-colza", extraIDs: ["carotte", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Fais dorer le tempeh en fines tranches : sans couleur, il reste amer.",
                    en: "Brown the thinly sliced tempeh: without colour it stays bitter.",
                    es: "Dora el tempeh en lonchas finas: sin color, queda amargo."
                ),
                LocalizedText(
                    fr: "Carottes en bâtonnets deux minutes, germes de soja trente secondes.",
                    en: "Julienned carrots two minutes, bean sprouts thirty seconds.",
                    es: "Zanahoria en bastones dos minutos, brotes de soja treinta segundos."
                ),
                LocalizedText(
                    fr: "Vermicelles réhydratés hors du feu, sauce soja, tout mélanger et servir.",
                    en: "Noodles rehydrated off the heat, soy sauce, toss and serve.",
                    es: "Fideos rehidratados fuera del fuego, salsa de soja, mezcla y sirve."
                ),
            ]
        ),
        Recipe(
            id: "truite-pommes-terre",
            name: LocalizedText(
                fr: "Truite aux amandes, pommes de terre",
                en: "Trout with almonds and potatoes",
                es: "Trucha con almendras y patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "truite", carbID: "pomme-de-terre",
            fatID: "amandes", extraIDs: ["haricots-verts", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais griller les amandes effilées à sec, elles brûlent en dix secondes de trop.",
                    en: "Toast the flaked almonds dry; ten seconds too long and they burn.",
                    es: "Tuesta las almendras laminadas en seco; diez segundos de más y se queman."
                ),
                LocalizedText(
                    fr: "La truite, quatre minutes côté peau, deux de l'autre.",
                    en: "The trout, four minutes skin down, two on the other side.",
                    es: "La trucha, cuatro minutos por la piel, dos por el otro lado."
                ),
                LocalizedText(
                    fr: "Amandes et jus de citron par-dessus, haricots verts et champignons poêlés à côté.",
                    en: "Almonds and lemon juice over it, green beans and pan-fried mushrooms alongside.",
                    es: "Almendras y zumo de limón encima, judías verdes y champiñones salteados al lado."
                ),
            ]
        ),
        Recipe(
            id: "poulet-paprika-quinoa",
            name: LocalizedText(
                fr: "Poulet au paprika, quinoa",
                en: "Paprika chicken with quinoa",
                es: "Pollo al pimentón con quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Enrobe le poulet de paprika doux et fumé, laisse-le dix minutes à température.",
                    en: "Coat the chicken in sweet and smoked paprika, leave it ten minutes at room temperature.",
                    es: "Reboza el pollo en pimentón dulce y ahumado, déjalo diez minutos a temperatura ambiente."
                ),
                LocalizedText(
                    fr: "Saisis-le, réserve, puis fais fondre poivrons et oignons dans les sucs.",
                    en: "Sear it, set aside, then soften peppers and onions in the pan juices.",
                    es: "Séllalo, reserva, y pocha pimientos y cebollas en los jugos."
                ),
                LocalizedText(
                    fr: "Remets le poulet, couvre dix minutes. Le quinoa cuit à côté en douze.",
                    en: "Return the chicken, cover ten minutes. The quinoa takes twelve alongside.",
                    es: "Devuelve el pollo, tapa diez minutos. La quinoa tarda doce al lado."
                ),
            ]
        ),
        Recipe(
            id: "poulet-moutarde-pates",
            name: LocalizedText(
                fr: "Poulet à la moutarde, pâtes complètes",
                en: "Mustard chicken with wholewheat pasta",
                es: "Pollo a la mostaza con pasta integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cuisse-de-poulet", carbID: "pates-completes",
            fatID: "creme-legere", extraIDs: ["champignons", "epinards"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Fais dorer les cuisses côté peau retirée, à feu moyen, sans les bouger.",
                    en: "Brown the skinless thighs over medium heat, without moving them.",
                    es: "Dora los contramuslos sin piel a fuego medio, sin moverlos."
                ),
                LocalizedText(
                    fr: "Champignons à part, à feu vif : entassés avec la viande, ils bouillent.",
                    en: "Mushrooms separately, high heat: crowded with the meat, they stew.",
                    es: "Champiñones aparte, fuego fuerte: junto a la carne, se cuecen."
                ),
                LocalizedText(
                    fr: "Réunis tout avec la crème et une cuillère de moutarde, épinards en dernier.",
                    en: "Bring it together with the cream and a spoon of mustard, spinach last.",
                    es: "Júntalo con la nata y una cucharada de mostaza, espinacas al final."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-poivrons-semoule",
            name: LocalizedText(
                fr: "Bœuf aux poivrons, semoule",
                en: "Beef with peppers and couscous",
                es: "Ternera con pimientos y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Taille le bœuf en lanières fines, contre le sens des fibres.",
                    en: "Cut the beef into thin strips, across the grain.",
                    es: "Corta la ternera en tiras finas, a contrafibra."
                ),
                LocalizedText(
                    fr: "Poêle brûlante, une minute par face, puis réserve au chaud.",
                    en: "Scorching pan, one minute a side, then keep warm.",
                    es: "Sartén ardiendo, un minuto por cara, y reserva al calor."
                ),
                LocalizedText(
                    fr: "Poivrons et tomates dix minutes ; la semoule gonfle hors du feu en cinq.",
                    en: "Peppers and tomatoes ten minutes; the couscous swells off the heat in five.",
                    es: "Pimientos y tomates diez minutos; la sémola se hincha fuera del fuego en cinco."
                ),
            ]
        ),
        Recipe(
            id: "boulettes-boeuf-tomate",
            name: LocalizedText(
                fr: "Boulettes de bœuf à la tomate, pâtes",
                en: "Beef meatballs in tomato with pasta",
                es: "Albóndigas de ternera en tomate con pasta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-5", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "courgette"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Mélange le bœuf haché avec de l'ail, du persil et un œuf ; forme des boulettes.",
                    en: "Mix the mince with garlic, parsley and an egg; shape into balls.",
                    es: "Mezcla la carne picada con ajo, perejil y un huevo; forma albóndigas."
                ),
                LocalizedText(
                    fr: "Fais-les dorer sur toutes leurs faces, puis retire-les : elles finiront dans la sauce.",
                    en: "Brown them all over, then take them out: they finish in the sauce.",
                    es: "Dóralas por todas sus caras y sácalas: terminan en la salsa."
                ),
                LocalizedText(
                    fr: "Sauce tomate et courgettes en dés, remets les boulettes, vingt minutes à couvert.",
                    en: "Tomato sauce and diced courgettes, return the meatballs, twenty minutes covered.",
                    es: "Salsa de tomate y calabacín en dados, devuelve las albóndigas, veinte minutos tapado."
                ),
            ]
        ),
        Recipe(
            id: "dinde-champignons-riz",
            name: LocalizedText(
                fr: "Dinde aux champignons, riz complet",
                en: "Turkey with mushrooms and brown rice",
                es: "Pavo con champiñones y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "riz-complet",
            fatID: "creme-legere", extraIDs: ["champignons", "poireau"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Poireaux émincés à feu doux, dix minutes à couvert, sans coloration.",
                    en: "Sliced leeks on a low heat, ten minutes covered, without colour.",
                    es: "Puerro en juliana a fuego suave, diez minutos tapado, sin color."
                ),
                LocalizedText(
                    fr: "Champignons à part et à feu vif, puis la dinde en dés, trois minutes.",
                    en: "Mushrooms separately over high heat, then the diced turkey, three minutes.",
                    es: "Champiñones aparte a fuego fuerte, luego el pavo en dados, tres minutos."
                ),
                LocalizedText(
                    fr: "Réunis, crème, cinq minutes à petit feu. Le riz complet demande trente-cinq minutes.",
                    en: "Combine, cream, five minutes on low. Brown rice needs thirty-five minutes.",
                    es: "Junta, nata, cinco minutos a fuego lento. El arroz integral necesita treinta y cinco minutos."
                ),
            ]
        ),
        Recipe(
            id: "porc-caramel-riz",
            name: LocalizedText(
                fr: "Porc laqué, riz basmati",
                en: "Sticky pork with basmati rice",
                es: "Cerdo lacado con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["chou", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Coupe le filet en médaillons épais et fais-les dorer deux minutes par face.",
                    en: "Cut the fillet into thick medallions and brown two minutes a side.",
                    es: "Corta el solomillo en medallones gruesos y dóralos dos minutos por cara."
                ),
                LocalizedText(
                    fr: "Sauce soja, un peu de miel, gingembre râpé : laisse réduire jusqu'à napper.",
                    en: "Soy sauce, a little honey, grated ginger: reduce until it coats.",
                    es: "Salsa de soja, un poco de miel, jengibre rallado: reduce hasta que nape."
                ),
                LocalizedText(
                    fr: "Chou et carottes râpés, sautés deux minutes, servis croquants.",
                    en: "Shredded cabbage and carrots, two minutes in the pan, served crunchy.",
                    es: "Col y zanahoria ralladas, dos minutos a la sartén, servidas crujientes."
                ),
            ]
        ),
        Recipe(
            id: "agneau-boulgour",
            name: LocalizedText(
                fr: "Agneau aux aubergines, boulgour",
                en: "Lamb with aubergine and bulgur",
                es: "Cordero con berenjena y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "agneau-gigot", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["aubergine", "tomate"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Aubergines en cubes, sel, vingt minutes d'attente : elles rendent leur eau et boivent moins d'huile.",
                    en: "Cubed aubergine, salt, twenty minutes' wait: it releases water and drinks less oil.",
                    es: "Berenjena en cubos, sal, veinte minutos de espera: suelta agua y absorbe menos aceite."
                ),
                LocalizedText(
                    fr: "Fais dorer l'agneau en gros dés, puis ajoute les aubergines rincées et séchées.",
                    en: "Brown the lamb in large dice, then add the rinsed and dried aubergine.",
                    es: "Dora el cordero en dados grandes y añade la berenjena enjuagada y seca."
                ),
                LocalizedText(
                    fr: "Tomates, cumin, vingt-cinq minutes à couvert. Le boulgour gonfle à côté.",
                    en: "Tomatoes, cumin, twenty-five minutes covered. The bulgur swells alongside.",
                    es: "Tomate, comino, veinticinco minutos tapado. El bulgur se hincha al lado."
                ),
            ]
        ),
        Recipe(
            id: "lapin-polenta",
            name: LocalizedText(
                fr: "Lapin aux olives, polenta",
                en: "Rabbit with olives and polenta",
                es: "Conejo con aceitunas y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lapin", carbID: "polenta",
            fatID: "olives", extraIDs: ["tomate", "oignon"],
            minutes: 50,
            steps: [
                LocalizedText(
                    fr: "Fais dorer les morceaux de lapin sur toutes leurs faces, patiemment.",
                    en: "Brown the rabbit pieces on every side, patiently.",
                    es: "Dora los trozos de conejo por todas sus caras, con paciencia."
                ),
                LocalizedText(
                    fr: "Oignons, tomates, thym, un verre d'eau : quarante minutes à couvert, feu doux.",
                    en: "Onions, tomatoes, thyme, a glass of water: forty minutes covered, low heat.",
                    es: "Cebolla, tomate, tomillo, un vaso de agua: cuarenta minutos tapado a fuego suave."
                ),
                LocalizedText(
                    fr: "Olives dix minutes avant la fin, sinon elles rendent tout amer.",
                    en: "Olives ten minutes before the end, or they turn everything bitter.",
                    es: "Aceitunas diez minutos antes del final, si no lo amargan todo."
                ),
            ]
        ),
        Recipe(
            id: "rosbif-froid-salade",
            name: LocalizedText(
                fr: "Rosbif froid, pommes de terre en salade",
                en: "Cold roast beef with potato salad",
                es: "Rosbif frío con ensalada de patata"
            ),
            slots: [.lunch, .dinner],
            proteinID: "rosbif", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["salade", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre cuites à l'eau, coupées et assaisonnées encore tièdes.",
                    en: "Boiled potatoes, sliced and dressed while still warm.",
                    es: "Patatas cocidas, cortadas y aliñadas todavía templadas."
                ),
                LocalizedText(
                    fr: "Le rosbif se tranche très fin, au dernier moment.",
                    en: "Slice the beef very thin, at the last moment.",
                    es: "El rosbif se corta muy fino, en el último momento."
                ),
                LocalizedText(
                    fr: "Salade, tomates, moutarde dans la vinaigrette. Aucune cuisson, dix minutes.",
                    en: "Salad, tomatoes, mustard in the dressing. No cooking, ten minutes.",
                    es: "Ensalada, tomate, mostaza en el aliño. Sin cocinar, diez minutos."
                ),
            ]
        ),
        Recipe(
            id: "foie-volaille-puree",
            name: LocalizedText(
                fr: "Foies de volaille, purée et pommes",
                en: "Chicken livers with mash",
                es: "Higaditos con puré"
            ),
            slots: [.lunch, .dinner],
            proteinID: "foie-de-volaille", carbID: "pomme-de-terre",
            fatID: "beurre", extraIDs: ["oignon", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Les foies se cuisent à feu vif, deux minutes par face : roses au centre, jamais gris.",
                    en: "Livers cook over high heat, two minutes a side: pink inside, never grey.",
                    es: "Los higaditos se hacen a fuego fuerte, dos minutos por cara: rosados dentro, nunca grises."
                ),
                LocalizedText(
                    fr: "Réserve-les, fais fondre les oignons dans la même poêle, déglace au vinaigre.",
                    en: "Set them aside, soften the onions in the same pan, deglaze with vinegar.",
                    es: "Resérvalos, pocha la cebolla en la misma sartén, desglasa con vinagre."
                ),
                LocalizedText(
                    fr: "Purée au beurre, épinards fondus une minute, tout réuni à l'assiette.",
                    en: "Buttery mash, spinach wilted a minute, brought together on the plate.",
                    es: "Puré con mantequilla, espinacas un minuto, todo junto en el plato."
                ),
            ]
        ),
        Recipe(
            id: "jambon-pates-petits-pois",
            name: LocalizedText(
                fr: "Pâtes au jambon et petits pois",
                en: "Pasta with ham and peas",
                es: "Pasta con jamón y guisantes"
            ),
            slots: [.lunch, .dinner],
            proteinID: "jambon-blanc", carbID: "petits-pois",
            fatID: "creme-legere", extraIDs: ["oignon", "champignons"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Oignons et champignons à la poêle pendant que les petits pois cuisent.",
                    en: "Onions and mushrooms in the pan while the peas cook.",
                    es: "Cebolla y champiñones en la sartén mientras se cuecen los guisantes."
                ),
                LocalizedText(
                    fr: "Jambon en lanières, ajouté hors du feu : cuit, il devient sec.",
                    en: "Ham in strips, added off the heat: cooked, it turns dry.",
                    es: "Jamón en tiras, fuera del fuego: cocido, se seca."
                ),
                LocalizedText(
                    fr: "Crème et poivre, mélange rapide, sers aussitôt.",
                    en: "Cream and pepper, a quick toss, serve at once.",
                    es: "Nata y pimienta, mezcla rápida, sirve enseguida."
                ),
            ]
        ),
        Recipe(
            id: "bar-vapeur-riz",
            name: LocalizedText(
                fr: "Bar vapeur au gingembre, riz basmati",
                en: "Steamed sea bass with ginger and rice",
                es: "Lubina al vapor con jengibre y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "bar", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["poireau", "germes-soja"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Pose le bar sur un lit de poireaux émincés, gingembre râpé dessus.",
                    en: "Lay the bass on a bed of sliced leeks, grated ginger over it.",
                    es: "Coloca la lubina sobre una cama de puerro, jengibre rallado encima."
                ),
                LocalizedText(
                    fr: "Douze minutes à la vapeur, ou à couvert dans un fond d'eau.",
                    en: "Twelve minutes steamed, or covered in a little water.",
                    es: "Doce minutos al vapor, o tapado con un poco de agua."
                ),
                LocalizedText(
                    fr: "Huile chaude et sauce soja versées dessus au moment de servir : ça grésille.",
                    en: "Hot oil and soy sauce poured over as you serve: it sizzles.",
                    es: "Aceite caliente y salsa de soja por encima al servir: chisporrotea."
                ),
            ]
        ),
        Recipe(
            id: "tilapia-pommes-terre",
            name: LocalizedText(
                fr: "Tilapia pané au four, pommes de terre",
                en: "Baked breaded tilapia with potatoes",
                es: "Tilapia empanada al horno con patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tilapia", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["haricots-verts", "carotte"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre et carottes en quartiers au four, 200 °C, vingt minutes.",
                    en: "Potatoes and carrots in wedges in the oven, 200 °C, twenty minutes.",
                    es: "Patatas y zanahorias en gajos al horno, 200 °C, veinte minutos."
                ),
                LocalizedText(
                    fr: "Pane le tilapia à la chapelure et au citron zesté, pose-le sur la plaque.",
                    en: "Coat the tilapia in breadcrumbs and lemon zest, add it to the tray.",
                    es: "Empana la tilapia con pan rallado y ralladura de limón, y ponla en la bandeja."
                ),
                LocalizedText(
                    fr: "Douze minutes de plus. Haricots verts à l'eau pendant ce temps.",
                    en: "Twelve minutes more. Green beans boiled meanwhile.",
                    es: "Doce minutos más. Judías verdes hervidas mientras tanto."
                ),
            ]
        ),
        Recipe(
            id: "sole-meuniere",
            name: LocalizedText(
                fr: "Sole meunière, pommes vapeur",
                en: "Sole meunière with steamed potatoes",
                es: "Lenguado a la meunière con patatas al vapor"
            ),
            slots: [.lunch, .dinner],
            proteinID: "sole", carbID: "pomme-de-terre",
            fatID: "beurre", extraIDs: ["haricots-verts", "champignons"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Farine légèrement la sole et secoue l'excédent : trop de farine brûle.",
                    en: "Flour the sole lightly and shake off the excess: too much flour burns.",
                    es: "Enharina el lenguado ligeramente y sacude el exceso: demasiada harina se quema."
                ),
                LocalizedText(
                    fr: "Beurre mousseux, trois minutes par face, arrose sans arrêt à la cuillère.",
                    en: "Foaming butter, three minutes a side, basting constantly with a spoon.",
                    es: "Mantequilla espumosa, tres minutos por cara, regando con una cuchara."
                ),
                LocalizedText(
                    fr: "Jus de citron dans la poêle hors du feu, versé sur le poisson.",
                    en: "Lemon juice in the pan off the heat, poured over the fish.",
                    es: "Zumo de limón en la sartén fuera del fuego, vertido sobre el pescado."
                ),
            ]
        ),
        Recipe(
            id: "calamars-riz",
            name: LocalizedText(
                fr: "Calamars à la tomate, riz blanc",
                en: "Squid in tomato with white rice",
                es: "Calamares con tomate y arroz blanco"
            ),
            slots: [.lunch, .dinner],
            proteinID: "calamars", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Les calamars se cuisent deux minutes ou quarante, jamais entre les deux.",
                    en: "Squid cooks in two minutes or forty, never in between.",
                    es: "El calamar se hace en dos minutos o en cuarenta, nunca a medias."
                ),
                LocalizedText(
                    fr: "Fais revenir poivrons et ail, ajoute les calamars et la sauce tomate.",
                    en: "Cook peppers and garlic, add the squid and tomato sauce.",
                    es: "Sofríe pimientos y ajo, añade los calamares y la salsa de tomate."
                ),
                LocalizedText(
                    fr: "Trente-cinq minutes à petit feu, à couvert : c'est là qu'ils redeviennent tendres.",
                    en: "Thirty-five minutes on low, covered: that is when they turn tender again.",
                    es: "Treinta y cinco minutos a fuego lento, tapado: ahí vuelven a estar tiernos."
                ),
            ]
        ),
        Recipe(
            id: "moules-frites-maison",
            name: LocalizedText(
                fr: "Moules marinière, pommes de terre",
                en: "Mussels with potatoes",
                es: "Mejillones con patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "moules", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["oignon", "celeri-branche"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Trie les moules : celles qui restent ouvertes après un choc se jettent.",
                    en: "Sort the mussels: any that stay open after a tap go in the bin.",
                    es: "Selecciona los mejillones: los que siguen abiertos tras un golpe se tiran."
                ),
                LocalizedText(
                    fr: "Oignon et céleri fondus, un verre de vin blanc ou d'eau, porte à ébullition.",
                    en: "Softened onion and celery, a glass of white wine or water, bring to the boil.",
                    es: "Cebolla y apio pochados, un vaso de vino blanco o agua, lleva a ebullición."
                ),
                LocalizedText(
                    fr: "Moules à couvert, cinq minutes, jusqu'à ce qu'elles s'ouvrent. Crème hors du feu.",
                    en: "Mussels covered, five minutes, until they open. Cream off the heat.",
                    es: "Mejillones tapados, cinco minutos, hasta que se abran. Nata fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "saumon-teriyaki",
            name: LocalizedText(
                fr: "Saumon teriyaki, riz et brocoli",
                en: "Teriyaki salmon with rice and broccoli",
                es: "Salmón teriyaki con arroz y brócoli"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon", carbID: "riz-blanc",
            fatID: "graines-sesame", extraIDs: ["brocoli", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Sauce soja, un peu de miel et de gingembre : fais réduire jusqu'à ce que ça nappe.",
                    en: "Soy sauce, a little honey and ginger: reduce until it coats.",
                    es: "Salsa de soja, un poco de miel y jengibre: reduce hasta que nape."
                ),
                LocalizedText(
                    fr: "Le saumon, peau en bas, quatre minutes, puis deux minutes dans la sauce.",
                    en: "The salmon, skin down, four minutes, then two minutes in the sauce.",
                    es: "El salmón, con la piel abajo, cuatro minutos, luego dos en la salsa."
                ),
                LocalizedText(
                    fr: "Brocoli et carottes vapeur, sésame grillé par-dessus.",
                    en: "Steamed broccoli and carrots, toasted sesame over the top.",
                    es: "Brócoli y zanahoria al vapor, sésamo tostado por encima."
                ),
            ]
        ),
        Recipe(
            id: "noix-st-jacques-puree",
            name: LocalizedText(
                fr: "Saint-Jacques, purée de céleri",
                en: "Scallops with celeriac purée",
                es: "Vieiras con puré de apionabo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "noix-st-jacques", carbID: "pomme-de-terre",
            fatID: "beurre", extraIDs: ["celeri-rave", "epinards"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Céleri-rave et pommes de terre cuits ensemble, écrasés au beurre.",
                    en: "Celeriac and potato boiled together, mashed with butter.",
                    es: "Apionabo y patata cocidos juntos, machacados con mantequilla."
                ),
                LocalizedText(
                    fr: "Sèche bien les Saint-Jacques : mouillées, elles ne dorent jamais.",
                    en: "Dry the scallops thoroughly: wet, they never brown.",
                    es: "Seca bien las vieiras: mojadas, nunca se doran."
                ),
                LocalizedText(
                    fr: "Poêle très chaude, quatre-vingt-dix secondes par face, pas une de plus.",
                    en: "Very hot pan, ninety seconds a side, not one more.",
                    es: "Sartén muy caliente, noventa segundos por cara, ni uno más."
                ),
            ]
        ),
        Recipe(
            id: "crabe-avocat-riz",
            name: LocalizedText(
                fr: "Crabe, avocat et riz vinaigré",
                en: "Crab with avocado and seasoned rice",
                es: "Cangrejo con aguacate y arroz avinagrado"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crabe", carbID: "riz-blanc",
            fatID: "avocat", extraIDs: ["concombre", "radis"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Assaisonne le riz chaud avec du vinaigre de riz et une pincée de sucre.",
                    en: "Season the warm rice with rice vinegar and a pinch of sugar.",
                    es: "Adereza el arroz caliente con vinagre de arroz y una pizca de azúcar."
                ),
                LocalizedText(
                    fr: "Concombre et radis en fines rondelles, salés cinq minutes puis égouttés.",
                    en: "Cucumber and radish thinly sliced, salted five minutes then drained.",
                    es: "Pepino y rábano en rodajas finas, salados cinco minutos y escurridos."
                ),
                LocalizedText(
                    fr: "Monte en bol : riz, crabe, avocat. Aucune cuisson au-delà du riz.",
                    en: "Build it in a bowl: rice, crab, avocado. No cooking beyond the rice.",
                    es: "Monta en bol: arroz, cangrejo, aguacate. Sin más cocción que el arroz."
                ),
            ]
        ),
        Recipe(
            id: "hareng-pommes-terre",
            name: LocalizedText(
                fr: "Hareng fumé, pommes de terre tièdes",
                en: "Smoked herring with warm potatoes",
                es: "Arenque ahumado con patatas templadas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "hareng", carbID: "pomme-de-terre",
            fatID: "huile-colza", extraIDs: ["oignon", "salade"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre à l'eau, coupées en rondelles encore chaudes.",
                    en: "Boiled potatoes, sliced while still hot.",
                    es: "Patatas cocidas, cortadas en rodajas todavía calientes."
                ),
                LocalizedText(
                    fr: "Oignons émincés très fin, rincés à l'eau froide pour ôter le piquant.",
                    en: "Very thinly sliced onions, rinsed in cold water to take the bite out.",
                    es: "Cebolla en juliana muy fina, enjuagada en agua fría para quitar el picor."
                ),
                LocalizedText(
                    fr: "Hareng en morceaux, huile de colza, poivre. Le tiède est la clé du plat.",
                    en: "Herring in pieces, rapeseed oil, pepper. Warm is the whole point.",
                    es: "Arenque en trozos, aceite de colza, pimienta. Lo templado es la clave."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-corail-patate",
            name: LocalizedText(
                fr: "Dahl de lentilles corail, patate douce",
                en: "Red lentil dhal with sweet potato",
                es: "Dahl de lentejas rojas con boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "patate-douce",
            fatID: "huile-colza", extraIDs: ["epinards", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer curcuma, cumin et gingembre dans l'huile : c'est là que le plat se joue.",
                    en: "Warm turmeric, cumin and ginger in the oil: that is where the dish is won.",
                    es: "Calienta cúrcuma, comino y jengibre en el aceite: ahí se decide el plato."
                ),
                LocalizedText(
                    fr: "Lentilles, patate douce en cubes, tomates, eau à hauteur.",
                    en: "Lentils, cubed sweet potato, tomatoes, water to cover.",
                    es: "Lentejas, boniato en cubos, tomate, agua hasta cubrir."
                ),
                LocalizedText(
                    fr: "Vingt-cinq minutes, épinards à la fin. Écrase un peu pour épaissir.",
                    en: "Twenty-five minutes, spinach at the end. Crush a little to thicken.",
                    es: "Veinticinco minutos, espinacas al final. Machaca un poco para espesar."
                ),
            ]
        ),
        Recipe(
            id: "pois-casses-legumes",
            name: LocalizedText(
                fr: "Soupe de pois cassés, pommes de terre",
                en: "Split pea soup with potatoes",
                es: "Sopa de guisantes secos con patata"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-casses", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "poireau"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Poireaux et carottes en petits dés, dix minutes à l'huile.",
                    en: "Leeks and carrots finely diced, ten minutes in oil.",
                    es: "Puerro y zanahoria en dados pequeños, diez minutos en aceite."
                ),
                LocalizedText(
                    fr: "Pois cassés rincés, pommes de terre, eau à trois centimètres au-dessus.",
                    en: "Rinsed split peas, potatoes, water three centimetres above.",
                    es: "Guisantes enjuagados, patatas, agua tres centímetros por encima."
                ),
                LocalizedText(
                    fr: "Trente-cinq minutes. Ne sale qu'à la fin, sinon les pois restent durs.",
                    en: "Thirty-five minutes. Salt only at the end, or the peas stay hard.",
                    es: "Treinta y cinco minutos. Sala solo al final, si no quedan duros."
                ),
            ]
        ),
        Recipe(
            id: "falafels-semoule",
            name: LocalizedText(
                fr: "Falafels, semoule et crudités",
                en: "Falafel with couscous and raw vegetables",
                es: "Falafel con sémola y crudités"
            ),
            slots: [.lunch, .dinner],
            proteinID: "falafel", carbID: "semoule",
            fatID: "tahini", extraIDs: ["tomate", "concombre"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Réchauffe les falafels au four plutôt qu'à la poêle : ils restent secs dedans.",
                    en: "Reheat the falafel in the oven rather than the pan: they stay dry inside.",
                    es: "Recalienta los falafel al horno en vez de a la sartén: quedan secos por dentro."
                ),
                LocalizedText(
                    fr: "Semoule gonflée hors du feu, cinq minutes, à la fourchette.",
                    en: "Couscous swollen off the heat, five minutes, fluffed with a fork.",
                    es: "Sémola hinchada fuera del fuego, cinco minutos, suelta con tenedor."
                ),
                LocalizedText(
                    fr: "Sauce au tahini allongée d'eau et de citron : elle épaissit avant de fluidifier.",
                    en: "Tahini sauce loosened with water and lemon: it thickens before it thins.",
                    es: "Salsa de tahini aligerada con agua y limón: espesa antes de aligerarse."
                ),
            ]
        ),
        Recipe(
            id: "edamame-quinoa",
            name: LocalizedText(
                fr: "Bol d'édamame, quinoa et avocat",
                en: "Edamame bowl with quinoa and avocado",
                es: "Bol de edamame con quinoa y aguacate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "edamame", carbID: "quinoa",
            fatID: "avocat", extraIDs: ["carotte", "chou-rouge"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Édamame cinq minutes à l'eau bouillante salée, puis écossés.",
                    en: "Edamame five minutes in salted boiling water, then podded.",
                    es: "Edamame cinco minutos en agua hirviendo con sal, y desgranado."
                ),
                LocalizedText(
                    fr: "Carottes et chou rouge en fines lanières, citron et sel : ils s'attendrissent seuls.",
                    en: "Carrot and red cabbage in thin strips, lemon and salt: they soften on their own.",
                    es: "Zanahoria y lombarda en tiras finas, limón y sal: se ablandan solas."
                ),
                LocalizedText(
                    fr: "Quinoa tiède au fond, tout par-dessus, avocat en dernier.",
                    en: "Warm quinoa in the base, everything over it, avocado last.",
                    es: "Quinoa templada en la base, todo encima, aguacate al final."
                ),
            ]
        ),
        Recipe(
            id: "proteine-soja-bolognaise",
            name: LocalizedText(
                fr: "Bolognaise de soja, pâtes complètes",
                en: "Soy bolognese with wholewheat pasta",
                es: "Boloñesa de soja con pasta integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "proteine-soja", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Réhydrate les protéines de soja dix minutes dans du bouillon chaud, pas de l'eau.",
                    en: "Rehydrate the soy protein ten minutes in hot stock, not water.",
                    es: "Hidrata la proteína de soja diez minutos en caldo caliente, no en agua."
                ),
                LocalizedText(
                    fr: "Carottes et oignons en petits dés, dix minutes : c'est eux qui donnent le fond sucré.",
                    en: "Carrots and onions finely diced, ten minutes: they give the sweet base.",
                    es: "Zanahoria y cebolla en dados pequeños, diez minutos: dan el fondo dulce."
                ),
                LocalizedText(
                    fr: "Soja égoutté, sauce tomate, vingt minutes à découvert.",
                    en: "Drained soy, tomato sauce, twenty minutes uncovered.",
                    es: "Soja escurrida, salsa de tomate, veinte minutos destapado."
                ),
            ]
        ),
        Recipe(
            id: "feves-riz-menthe",
            name: LocalizedText(
                fr: "Fèves au riz et à la menthe",
                en: "Broad beans with rice and mint",
                es: "Habas con arroz y menta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "feves", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["oignon", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fèves fraîches ou surgelées, cinq minutes à l'eau, puis pelées si la peau est épaisse.",
                    en: "Broad beans fresh or frozen, five minutes in water, peeled if the skins are thick.",
                    es: "Habas frescas o congeladas, cinco minutos en agua, peladas si la piel es gruesa."
                ),
                LocalizedText(
                    fr: "Oignons fondus, riz nacré dedans, eau bouillante, douze minutes à couvert.",
                    en: "Softened onions, rice coated in them, boiling water, twelve minutes covered.",
                    es: "Cebolla pochada, arroz nacarado, agua hirviendo, doce minutos tapado."
                ),
                LocalizedText(
                    fr: "Fèves, épinards et menthe ciselée hors du feu, couvercle cinq minutes.",
                    en: "Beans, spinach and chopped mint off the heat, lid on five minutes.",
                    es: "Habas, espinacas y menta picada fuera del fuego, tapa cinco minutos."
                ),
            ]
        ),
        Recipe(
            id: "tofu-aigre-doux",
            name: LocalizedText(
                fr: "Tofu aigre-doux, riz blanc",
                en: "Sweet and sour tofu with white rice",
                es: "Tofu agridulce con arroz blanco"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu", carbID: "riz-blanc",
            fatID: "huile-colza", extraIDs: ["poivron", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Presse le tofu, coupe-le en cubes, et fais-les dorer sans y toucher.",
                    en: "Press the tofu, cube it, and brown the cubes without touching them.",
                    es: "Prensa el tofu, córtalo en dados y dóralos sin tocarlos."
                ),
                LocalizedText(
                    fr: "Vinaigre, sauce soja, un peu de sucre et de concentré de tomate : c'est la sauce.",
                    en: "Vinegar, soy sauce, a little sugar and tomato purée: that is the sauce.",
                    es: "Vinagre, salsa de soja, algo de azúcar y concentrado de tomate: esa es la salsa."
                ),
                LocalizedText(
                    fr: "Poivrons et oignons croquants, tofu remis, sauce, deux minutes.",
                    en: "Crunchy peppers and onions, tofu returned, sauce, two minutes.",
                    es: "Pimientos y cebolla crujientes, tofu de vuelta, salsa, dos minutos."
                ),
            ]
        ),
        Recipe(
            id: "haricots-blancs-fenouil",
            name: LocalizedText(
                fr: "Haricots blancs au fenouil, polenta",
                en: "White beans with fennel and polenta",
                es: "Alubias blancas con hinojo y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-blancs", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["fenouil", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fenouil émincé, quinze minutes à couvert : il devient fondant et sucré.",
                    en: "Sliced fennel, fifteen minutes covered: it turns soft and sweet.",
                    es: "Hinojo en láminas, quince minutos tapado: queda tierno y dulce."
                ),
                LocalizedText(
                    fr: "Tomates et haricots rincés, dix minutes de plus, zeste de citron.",
                    en: "Tomatoes and rinsed beans, ten minutes more, lemon zest.",
                    es: "Tomate y alubias enjuagadas, diez minutos más, ralladura de limón."
                ),
                LocalizedText(
                    fr: "Polenta fouettée cinq minutes sans arrêt, sinon elle fait des grumeaux.",
                    en: "Polenta whisked five minutes without stopping, or it goes lumpy.",
                    es: "Polenta batida cinco minutos sin parar, si no hace grumos."
                ),
            ]
        ),
        Recipe(
            id: "seitan-champignons",
            name: LocalizedText(
                fr: "Seitan aux champignons, orge perlé",
                en: "Seitan with mushrooms and pearl barley",
                es: "Seitán con champiñones y cebada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "seitan", carbID: "orge-perle",
            fatID: "huile-olive", extraIDs: ["champignons", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "L'orge perlé demande trente minutes : lance-le avant tout le reste.",
                    en: "Pearl barley needs thirty minutes: start it before anything else.",
                    es: "La cebada perlada necesita treinta minutos: ponla antes que nada."
                ),
                LocalizedText(
                    fr: "Champignons à feu vif, en une seule couche, sans sel au début.",
                    en: "Mushrooms over high heat, in one layer, no salt at first.",
                    es: "Champiñones a fuego fuerte, en una capa, sin sal al principio."
                ),
                LocalizedText(
                    fr: "Seitan en tranches dorées, oignons, sauce soja et un peu de moutarde.",
                    en: "Sliced seitan browned, onions, soy sauce and a little mustard.",
                    es: "Seitán en lonchas doradas, cebolla, salsa de soja y algo de mostaza."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-satay",
            name: LocalizedText(
                fr: "Tempeh sauce cacahuète, riz complet",
                en: "Tempeh in peanut sauce with brown rice",
                es: "Tempeh con salsa de cacahuete y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "riz-complet",
            fatID: "beurre-cacahuete", extraIDs: ["chou", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais dorer le tempeh en bâtonnets : sans couleur, il garde son amertume.",
                    en: "Brown the tempeh in batons: without colour it keeps its bitterness.",
                    es: "Dora el tempeh en bastones: sin color, conserva su amargor."
                ),
                LocalizedText(
                    fr: "Purée de cacahuète, sauce soja, jus de citron, eau chaude : fouette jusqu'à fluidité.",
                    en: "Peanut butter, soy sauce, lemon juice, hot water: whisk until it flows.",
                    es: "Crema de cacahuete, salsa de soja, zumo de limón, agua caliente: bate hasta que fluya."
                ),
                LocalizedText(
                    fr: "Chou et carottes râpés, crus, pour le croquant. Sauce versée au moment de servir.",
                    en: "Shredded raw cabbage and carrots for crunch. Sauce poured as you serve.",
                    es: "Col y zanahoria ralladas, crudas, para el crujiente. Salsa al servir."
                ),
            ]
        ),
        Recipe(
            id: "haricots-noirs-tortillas",
            name: LocalizedText(
                fr: "Haricots noirs, tortillas de maïs",
                en: "Black beans with corn tortillas",
                es: "Alubias negras con tortillas de maíz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-noirs", carbID: "tortilla-mais",
            fatID: "avocat", extraIDs: ["tomate", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Oignons et cumin dans l'huile, puis les haricots rincés et un peu d'eau.",
                    en: "Onions and cumin in oil, then the rinsed beans and a little water.",
                    es: "Cebolla y comino en aceite, luego las alubias enjuagadas y un poco de agua."
                ),
                LocalizedText(
                    fr: "Écrase la moitié des haricots à la fourchette : c'est ce qui fait la texture.",
                    en: "Crush half the beans with a fork: that is what makes the texture.",
                    es: "Machaca la mitad de las alubias con un tenedor: eso da la textura."
                ),
                LocalizedText(
                    fr: "Tortillas passées à sec dans une poêle brûlante, dix secondes par face.",
                    en: "Tortillas dry-heated in a scorching pan, ten seconds a side.",
                    es: "Tortillas en seco en sartén ardiendo, diez segundos por cara."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-rotis",
            name: LocalizedText(
                fr: "Pois chiches rôtis, boulgour et roquette",
                en: "Roast chickpeas with bulgur and rocket",
                es: "Garbanzos asados con bulgur y rúcula"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "boulgour",
            fatID: "tahini", extraIDs: ["roquette", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Sèche bien les pois chiches, huile et épices, vingt-cinq minutes à 200 °C.",
                    en: "Dry the chickpeas well, oil and spices, twenty-five minutes at 200 °C.",
                    es: "Seca bien los garbanzos, aceite y especias, veinticinco minutos a 200 °C."
                ),
                LocalizedText(
                    fr: "Ils doivent croquer : humides, ils restent mous quoi qu'il arrive.",
                    en: "They must crunch: damp, they stay soft whatever you do.",
                    es: "Deben crujir: húmedos, quedan blandos hagas lo que hagas."
                ),
                LocalizedText(
                    fr: "Boulgour tiède, roquette, tomates, sauce au tahini par-dessus.",
                    en: "Warm bulgur, rocket, tomatoes, tahini sauce over the top.",
                    es: "Bulgur templado, rúcula, tomate, salsa de tahini por encima."
                ),
            ]
        ),
        Recipe(
            id: "omelette-espagnole",
            name: LocalizedText(
                fr: "Tortilla de pommes de terre",
                en: "Spanish potato omelette",
                es: "Tortilla de patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["oignon", "poivron"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre en fines rondelles, cuites doucement dans l'huile — confites, pas frites.",
                    en: "Potatoes thinly sliced, cooked gently in oil — confit, not fried.",
                    es: "Patatas en rodajas finas, cocinadas suavemente en aceite: confitadas, no fritas."
                ),
                LocalizedText(
                    fr: "Égoutte-les, mélange-les aux œufs battus et laisse reposer cinq minutes.",
                    en: "Drain them, mix into the beaten eggs and rest five minutes.",
                    es: "Escúrrelas, mézclalas con el huevo batido y deja reposar cinco minutos."
                ),
                LocalizedText(
                    fr: "Feu doux, quatre minutes, puis retourne d'un coup avec une assiette.",
                    en: "Low heat, four minutes, then flip in one go with a plate.",
                    es: "Fuego suave, cuatro minutos, y da la vuelta de golpe con un plato."
                ),
            ]
        ),
        Recipe(
            id: "blanc-oeuf-riz-saute",
            name: LocalizedText(
                fr: "Riz sauté aux blancs d'œufs",
                en: "Egg white fried rice",
                es: "Arroz salteado con claras"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-oeuf", carbID: "riz-blanc",
            fatID: "huile-colza", extraIDs: ["germes-soja", "carotte"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Riz froid de la veille : chaud, il colle et ne saute pas.",
                    en: "Cold rice from yesterday: warm, it sticks and will not fry.",
                    es: "Arroz frío del día anterior: caliente, se pega y no saltea."
                ),
                LocalizedText(
                    fr: "Carottes en petits dés et germes de soja, deux minutes à feu vif.",
                    en: "Diced carrots and bean sprouts, two minutes over high heat.",
                    es: "Zanahoria en dados y brotes de soja, dos minutos a fuego fuerte."
                ),
                LocalizedText(
                    fr: "Blancs d'œufs versés en filet en remuant : ils prennent en dix secondes.",
                    en: "Egg whites poured in a stream while stirring: they set in ten seconds.",
                    es: "Claras en hilo mientras remueves: cuajan en diez segundos."
                ),
            ]
        ),
        Recipe(
            id: "cottage-pates-epinards",
            name: LocalizedText(
                fr: "Pâtes crémeuses au cottage et épinards",
                en: "Creamy cottage cheese and spinach pasta",
                es: "Pasta cremosa con requesón y espinacas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cottage", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["epinards", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Fais fondre les épinards avec de l'ail, une minute suffit.",
                    en: "Wilt the spinach with garlic, a minute is enough.",
                    es: "Rehoga las espinacas con ajo, un minuto basta."
                ),
                LocalizedText(
                    fr: "Cottage cheese hors du feu, avec une louche d'eau de cuisson : il devient crémeux.",
                    en: "Cottage cheese off the heat, with a ladle of pasta water: it turns creamy.",
                    es: "Requesón fuera del fuego, con un cucharón del agua de cocción: queda cremoso."
                ),
                LocalizedText(
                    fr: "Chauffé trop fort, il tranche. C'est la seule erreur possible de ce plat.",
                    en: "Heated too hard, it splits. That is the only mistake this dish allows.",
                    es: "Calentado en exceso, se corta. Es el único error posible de este plato."
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
        Recipe(
            id: "skyr-avoine-pomme",
            name: LocalizedText(
                fr: "Skyr, avoine et pomme râpée",
                en: "Skyr with oats and grated apple",
                es: "Skyr con avena y manzana rallada"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "flocons-avoine",
            fatID: "noisettes", extraIDs: ["pomme"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Râpe la pomme avec la peau : c'est là que sont les fibres.",
                    en: "Grate the apple with its skin: that is where the fibre is.",
                    es: "Ralla la manzana con piel: ahí está la fibra."
                ),
                LocalizedText(
                    fr: "Mélange au skyr et aux flocons crus, cannelle, noisettes concassées.",
                    en: "Mix with the skyr and raw oats, cinnamon, crushed hazelnuts.",
                    es: "Mezcla con el skyr y los copos crudos, canela, avellanas picadas."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-durs-pain",
            name: LocalizedText(
                fr: "Œufs durs, pain de seigle et avocat",
                en: "Boiled eggs with rye bread and avocado",
                es: "Huevos duros con pan de centeno y aguacate"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-seigle",
            fatID: "avocat", extraIDs: ["orange"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Neuf minutes à l'eau frémissante donnent un jaune juste pris, pas gris.",
                    en: "Nine minutes at a simmer gives a just-set yolk, not grey.",
                    es: "Nueve minutos a fuego suave dan una yema cuajada, no gris."
                ),
                LocalizedText(
                    fr: "Passe-les sous l'eau froide aussitôt : c'est ce qui rend l'écalage facile.",
                    en: "Cool them under cold water at once: that is what makes peeling easy.",
                    es: "Pásalos por agua fría enseguida: así se pelan fácil."
                ),
                LocalizedText(
                    fr: "Avocat écrasé sur le pain, œufs en rondelles, poivre. Orange à côté.",
                    en: "Mashed avocado on the bread, sliced eggs, pepper. Orange alongside.",
                    es: "Aguacate aplastado sobre el pan, huevo en rodajas, pimienta. Naranja al lado."
                ),
            ]
        ),
        Recipe(
            id: "porridge-banane-cacahuete",
            name: LocalizedText(
                fr: "Porridge banane et cacahuète",
                en: "Banana and peanut porridge",
                es: "Porridge de plátano y cacahuete"
            ),
            slots: [.breakfast],
            proteinID: "whey", carbID: "flocons-avoine",
            fatID: "beurre-cacahuete", extraIDs: ["banane"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Flocons dans l'eau ou le lait, cinq minutes à feu doux en remuant.",
                    en: "Oats in water or milk, five minutes on low, stirring.",
                    es: "Copos en agua o leche, cinco minutos a fuego suave, removiendo."
                ),
                LocalizedText(
                    fr: "La poudre s'ajoute hors du feu : cuite, elle devient granuleuse.",
                    en: "The powder goes in off the heat: cooked, it turns grainy.",
                    es: "El polvo se añade fuera del fuego: cocido, queda granuloso."
                ),
                LocalizedText(
                    fr: "Banane écrasée dedans, purée de cacahuète par-dessus.",
                    en: "Mashed banana stirred in, peanut butter on top.",
                    es: "Plátano aplastado dentro, crema de cacahuete encima."
                ),
            ]
        ),
        Recipe(
            id: "skyr-mures-lin",
            name: LocalizedText(
                fr: "Skyr aux mûres et graines de lin",
                en: "Skyr with blackberries and flaxseed",
                es: "Skyr con moras y lino"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "muesli-nature",
            fatID: "graines-lin", extraIDs: ["mures"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Le lin doit être moulu : entier, il traverse sans rien apporter.",
                    en: "The flax must be ground: whole, it passes straight through.",
                    es: "El lino debe estar molido: entero, pasa sin aportar nada."
                ),
                LocalizedText(
                    fr: "Skyr, muesli, mûres, lin. Rien à cuire.",
                    en: "Skyr, muesli, blackberries, flax. Nothing to cook.",
                    es: "Skyr, muesli, moras, lino. Nada que cocinar."
                ),
            ]
        ),
        Recipe(
            id: "tartine-cottage-pamplemousse",
            name: LocalizedText(
                fr: "Tartines de cottage et pamplemousse",
                en: "Cottage cheese toast with grapefruit",
                es: "Tostada de requesón con pomelo"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "pain-seigle",
            fatID: "huile-olive", extraIDs: ["pamplemousse"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Cottage cheese sur le pain grillé, filet d'huile d'olive, poivre concassé.",
                    en: "Cottage cheese on toast, a drizzle of olive oil, cracked pepper.",
                    es: "Requesón sobre pan tostado, un chorrito de aceite, pimienta molida."
                ),
                LocalizedText(
                    fr: "Pamplemousse pelé à vif à côté : l'amertume réveille le reste.",
                    en: "Grapefruit cut into segments alongside: the bitterness wakes the rest up.",
                    es: "Pomelo pelado en gajos al lado: el amargor despierta lo demás."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-coque-mouillettes",
            name: LocalizedText(
                fr: "Œufs à la coque, mouillettes et clémentines",
                en: "Soft-boiled eggs with soldiers",
                es: "Huevos pasados por agua con tostadas"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-complet",
            fatID: "beurre", extraIDs: ["clementine"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Trois minutes trente à l'eau bouillante pour un blanc pris et un jaune coulant.",
                    en: "Three and a half minutes in boiling water: set white, running yolk.",
                    es: "Tres minutos y medio en agua hirviendo: clara cuajada, yema líquida."
                ),
                LocalizedText(
                    fr: "Sors-les à l'heure exacte : trente secondes de plus et le jaune fige.",
                    en: "Take them out on time: thirty seconds more and the yolk sets.",
                    es: "Sácalos a tiempo: treinta segundos más y la yema cuaja."
                ),
                LocalizedText(
                    fr: "Mouillettes beurrées, clémentines à côté.",
                    en: "Buttered soldiers, clementines alongside.",
                    es: "Tostadas con mantequilla, clementinas al lado."
                ),
            ]
        ),
        Recipe(
            id: "fromage-blanc-peche",
            name: LocalizedText(
                fr: "Fromage blanc, sarrasin grillé et pêche",
                en: "Fromage blanc with toasted buckwheat and peach",
                es: "Queso fresco con trigo sarraceno y melocotón"
            ),
            slots: [.breakfast],
            proteinID: "fromage-blanc", carbID: "sarrasin",
            fatID: "graines-courge", extraIDs: ["peche"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Sarrasin cuit passé à sec deux minutes : il croque et sent la noisette.",
                    en: "Cooked buckwheat dry-toasted two minutes: it crunches and smells nutty.",
                    es: "Trigo sarraceno cocido tostado en seco dos minutos: cruje y huele a fruto seco."
                ),
                LocalizedText(
                    fr: "Fromage blanc, pêche en quartiers, graines de courge.",
                    en: "Fromage blanc, peach wedges, pumpkin seeds.",
                    es: "Queso fresco, melocotón en gajos, pipas de calabaza."
                ),
            ]
        ),
        Recipe(
            id: "tofu-tartine-avocat",
            name: LocalizedText(
                fr: "Tofu grillé sur pain aux céréales, kiwi",
                en: "Grilled tofu on seeded bread with kiwi",
                es: "Tofu a la plancha con pan de cereales y kiwi"
            ),
            slots: [.breakfast],
            proteinID: "tofu", carbID: "pain-cereales",
            fatID: "avocat", extraIDs: ["kiwi"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Tofu en tranches fines, dorées deux minutes par face avec de la sauce soja.",
                    en: "Tofu in thin slices, browned two minutes a side with soy sauce.",
                    es: "Tofu en lonchas finas, doradas dos minutos por cara con salsa de soja."
                ),
                LocalizedText(
                    fr: "Avocat écrasé au citron sur le pain, tofu par-dessus.",
                    en: "Avocado mashed with lemon on the bread, tofu over it.",
                    es: "Aguacate aplastado con limón sobre el pan, tofu encima."
                ),
                LocalizedText(
                    fr: "Kiwi à côté : sa vitamine C aide à absorber le fer du tofu.",
                    en: "Kiwi alongside: its vitamin C helps absorb the iron in the tofu.",
                    es: "Kiwi al lado: su vitamina C ayuda a absorber el hierro del tofu."
                ),
            ]
        ),
        Recipe(
            id: "yaourt-soja-poire",
            name: LocalizedText(
                fr: "Yaourt de soja, flocons et poire",
                en: "Soy yoghurt with oats and pear",
                es: "Yogur de soja con avena y pera"
            ),
            slots: [.breakfast],
            proteinID: "yaourt-soja", carbID: "flocons-avoine",
            fatID: "noix", extraIDs: ["poire"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Flocons crus mélangés au yaourt la veille, au réfrigérateur.",
                    en: "Raw oats stirred into the yoghurt the night before, in the fridge.",
                    es: "Copos crudos mezclados con el yogur la noche anterior, en la nevera."
                ),
                LocalizedText(
                    fr: "Poire en dés et noix concassées au moment de manger.",
                    en: "Diced pear and crushed walnuts when you eat it.",
                    es: "Pera en dados y nueces picadas al momento de comer."
                ),
            ]
        ),
        Recipe(
            id: "petit-suisse-myrtilles",
            name: LocalizedText(
                fr: "Petits-suisses, galettes de riz et myrtilles",
                en: "Petits-suisses with rice cakes and blueberries",
                es: "Petit-suisse con tortitas de arroz y arándanos"
            ),
            slots: [.breakfast],
            proteinID: "petit-suisse", carbID: "galettes-riz",
            fatID: "puree-amande", extraIDs: ["myrtilles"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Purée d'amande sur les galettes, petits-suisses écrasés dessus.",
                    en: "Almond butter on the rice cakes, petits-suisses spread over.",
                    es: "Crema de almendra sobre las tortitas, petit-suisse encima."
                ),
                LocalizedText(
                    fr: "Myrtilles pour finir. Sans gluten et sans cuisson.",
                    en: "Blueberries to finish. Gluten-free and no cooking.",
                    es: "Arándanos para terminar. Sin gluten y sin cocinar."
                ),
            ]
        ),
        Recipe(
            id: "caseine-avoine-nuit",
            name: LocalizedText(
                fr: "Bol d'avoine de la nuit, framboises",
                en: "Overnight oats with raspberries",
                es: "Avena de la noche con frambuesas"
            ),
            slots: [.breakfast],
            proteinID: "caseine", carbID: "flocons-avoine",
            fatID: "graines-chia", extraIDs: ["framboises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Flocons, caséine, chia et lait mélangés le soir, au réfrigérateur.",
                    en: "Oats, casein, chia and milk mixed at night, in the fridge.",
                    es: "Copos, caseína, chía y leche mezclados por la noche, en la nevera."
                ),
                LocalizedText(
                    fr: "La caséine épaissit en dormant : au matin, c'est une crème.",
                    en: "Casein thickens overnight: by morning it is a cream.",
                    es: "La caseína espesa mientras duermes: por la mañana es una crema."
                ),
                LocalizedText(
                    fr: "Framboises écrasées par-dessus au réveil.",
                    en: "Crushed raspberries over it when you wake.",
                    es: "Frambuesas aplastadas por encima al despertar."
                ),
            ]
        ),
        Recipe(
            id: "proteine-vegetale-fraises",
            name: LocalizedText(
                fr: "Bol de céréales, protéines végétales et fraises",
                en: "Cereal bowl with plant protein and strawberries",
                es: "Bol de cereales con proteína vegetal y fresas"
            ),
            slots: [.breakfast],
            proteinID: "proteine-vegetale", carbID: "cereales-mais",
            fatID: "amandes", extraIDs: ["fraises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Délaye la poudre dans un fond d'eau froide avant d'ajouter le reste : sinon elle fait des grumeaux.",
                    en: "Dissolve the powder in a little cold water before adding the rest, or it clumps.",
                    es: "Disuelve el polvo en un poco de agua fría antes de añadir el resto, o se apelmaza."
                ),
                LocalizedText(
                    fr: "Céréales, fraises coupées, amandes concassées.",
                    en: "Cereal, sliced strawberries, crushed almonds.",
                    es: "Cereales, fresas cortadas, almendras picadas."
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
