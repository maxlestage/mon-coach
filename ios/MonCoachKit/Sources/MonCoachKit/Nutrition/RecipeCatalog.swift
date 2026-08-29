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
        Recipe(
            id: "poulet-tomates-olives",
            name: LocalizedText(
                fr: "Poulet aux tomates et olives, semoule",
                en: "Chicken with tomatoes and olives",
                es: "Pollo con tomate y aceitunas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "semoule",
            fatID: "olives", extraIDs: ["tomate", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Saisis le poulet, réserve, puis fais fondre les oignons dans les sucs.",
                    en: "Sear the chicken, set aside, then soften the onions in the pan juices.",
                    es: "Sella el pollo, reserva y pocha la cebolla en los jugos."
                ),
                LocalizedText(
                    fr: "Tomates et olives, quinze minutes à couvert, poulet remis.",
                    en: "Tomatoes and olives, fifteen minutes covered, chicken returned.",
                    es: "Tomate y aceitunas, quince minutos tapado, pollo de vuelta."
                ),
            ]
        ),
        Recipe(
            id: "poulet-yaourt-epices",
            name: LocalizedText(
                fr: "Poulet mariné au yaourt, riz basmati",
                en: "Yoghurt-marinated chicken with rice",
                es: "Pollo marinado en yogur con arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["poivron", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Le yaourt attendrit là où le citron durcit : deux heures suffisent, une nuit est mieux.",
                    en: "Yoghurt tenderises where lemon toughens: two hours is enough, overnight is better.",
                    es: "El yogur ablanda donde el limón endurece: dos horas bastan, una noche es mejor."
                ),
                LocalizedText(
                    fr: "Poêle brûlante, sans essuyer la marinade : elle caramélise et fait la croûte.",
                    en: "Scorching pan, marinade left on: it caramelises and makes the crust.",
                    es: "Sartén ardiendo, sin quitar la marinada: caramela y forma la costra."
                ),
            ]
        ),
        Recipe(
            id: "poulet-poireaux-epeautre",
            name: LocalizedText(
                fr: "Poulet aux poireaux, épeautre",
                en: "Chicken with leeks and spelt",
                es: "Pollo con puerros y espelta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cuisse-de-poulet", carbID: "epeautre",
            fatID: "creme-legere", extraIDs: ["poireau", "carotte"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "L'épeautre demande trente-cinq minutes : lance-le en premier.",
                    en: "Spelt needs thirty-five minutes: start it first.",
                    es: "La espelta necesita treinta y cinco minutos: empieza por ella."
                ),
                LocalizedText(
                    fr: "Poireaux fondus à couvert, poulet doré, crème, vingt minutes ensemble.",
                    en: "Leeks softened covered, chicken browned, cream, twenty minutes together.",
                    es: "Puerros pochados, pollo dorado, nata, veinte minutos juntos."
                ),
            ]
        ),
        Recipe(
            id: "poulet-butternut",
            name: LocalizedText(
                fr: "Poulet rôti à la butternut",
                en: "Roast chicken with butternut squash",
                es: "Pollo asado con calabaza"
            ),
            slots: [.lunch, .dinner],
            proteinID: "poulet-roti", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["butternut", "oignon"],
            minutes: 55,
            steps: [
                LocalizedText(
                    fr: "Butternut et pommes de terre en gros cubes, plaque unique, 200 °C.",
                    en: "Butternut and potatoes in large cubes, one tray, 200 °C.",
                    es: "Calabaza y patata en cubos grandes, una bandeja, 200 °C."
                ),
                LocalizedText(
                    fr: "Le poulet posé dessus : son jus assaisonne les légumes mieux qu'aucune sauce.",
                    en: "The chicken on top: its juices season the vegetables better than any sauce.",
                    es: "El pollo encima: su jugo sazona las verduras mejor que ninguna salsa."
                ),
            ]
        ),
        Recipe(
            id: "dinde-chou-millet",
            name: LocalizedText(
                fr: "Dinde au chou, millet",
                en: "Turkey with cabbage and millet",
                es: "Pavo con col y mijo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "millet",
            fatID: "huile-olive", extraIDs: ["chou", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Le chou émincé fin cuit en huit minutes : plus longtemps, il devient soufre.",
                    en: "Finely shredded cabbage cooks in eight minutes: longer and it turns sulphurous.",
                    es: "La col en juliana fina se hace en ocho minutos: más tiempo y sabe a azufre."
                ),
                LocalizedText(
                    fr: "Dinde en dés saisie à part, réunie au dernier moment.",
                    en: "Diced turkey seared separately, brought together at the last moment.",
                    es: "Pavo en dados sellado aparte, unido al final."
                ),
            ]
        ),
        Recipe(
            id: "dinde-tomate-gnocchis",
            name: LocalizedText(
                fr: "Gnocchis à la dinde et à la tomate",
                en: "Gnocchi with turkey and tomato",
                es: "Ñoquis con pavo y tomate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "gnocchis",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "courgette"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Les gnocchis cuisent quand ils remontent : deux minutes, pas plus.",
                    en: "Gnocchi are done when they float: two minutes, no more.",
                    es: "Los ñoquis están listos cuando flotan: dos minutos, no más."
                ),
                LocalizedText(
                    fr: "Poêlés ensuite trente secondes, ils prennent une croûte qui change tout.",
                    en: "Pan-fried afterwards for thirty seconds, they get a crust that changes everything.",
                    es: "Salteados después treinta segundos, cogen una costra que lo cambia todo."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-carottes-orge",
            name: LocalizedText(
                fr: "Bœuf aux carottes, orge perlé",
                en: "Beef with carrots and pearl barley",
                es: "Ternera con zanahorias y cebada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-15", carbID: "orge-perle",
            fatID: "huile-olive", extraIDs: ["carotte", "oignon"],
            minutes: 55,
            steps: [
                LocalizedText(
                    fr: "Fais dorer la viande en plusieurs fois : entassée, elle bout dans son jus.",
                    en: "Brown the meat in batches: crowded, it boils in its own juice.",
                    es: "Dora la carne por tandas: amontonada, se cuece en su jugo."
                ),
                LocalizedText(
                    fr: "Quarante minutes à petit feu. L'orge rejoint la cocotte à mi-cuisson.",
                    en: "Forty minutes on low. The barley joins halfway through.",
                    es: "Cuarenta minutos a fuego lento. La cebada entra a mitad."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-aubergines-riz",
            name: LocalizedText(
                fr: "Bœuf aux aubergines, riz complet",
                en: "Beef with aubergine and brown rice",
                es: "Ternera con berenjena y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-5", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["aubergine", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Sale les aubergines vingt minutes avant : elles boivent deux fois moins d'huile.",
                    en: "Salt the aubergine twenty minutes ahead: it drinks half the oil.",
                    es: "Sala la berenjena veinte minutos antes: absorbe la mitad de aceite."
                ),
                LocalizedText(
                    fr: "Bœuf haché saisi à feu vif, aubergines, tomates, vingt minutes.",
                    en: "Mince seared over high heat, aubergine, tomatoes, twenty minutes.",
                    es: "Carne picada a fuego fuerte, berenjena, tomate, veinte minutos."
                ),
            ]
        ),
        Recipe(
            id: "steak-frites-four",
            name: LocalizedText(
                fr: "Steak, pommes de terre au four et salade",
                en: "Steak with oven chips and salad",
                es: "Filete con patatas al horno y ensalada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["salade", "tomate"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Pommes de terre en bâtonnets, trempées dix minutes à l'eau froide pour ôter l'amidon.",
                    en: "Potatoes in batons, soaked ten minutes in cold water to remove starch.",
                    es: "Patatas en bastones, a remojo diez minutos en agua fría para quitar almidón."
                ),
                LocalizedText(
                    fr: "Le steak se sort de la poêle une minute avant d'être à point : il finit en reposant.",
                    en: "Take the steak out a minute early: it finishes while resting.",
                    es: "Saca el filete un minuto antes: termina reposando."
                ),
            ]
        ),
        Recipe(
            id: "veau-citron-pates",
            name: LocalizedText(
                fr: "Veau au citron, pâtes",
                en: "Veal with lemon and pasta",
                es: "Ternera al limón con pasta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "veau-escalope", carbID: "pates-blanches",
            fatID: "beurre", extraIDs: ["courgette", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Escalopes très fines, une minute par face : au-delà, elles durcissent.",
                    en: "Very thin escalopes, one minute a side: beyond that they toughen.",
                    es: "Escalopes muy finos, un minuto por cara: más tiempo y se endurecen."
                ),
                LocalizedText(
                    fr: "Déglace au citron et au beurre froid : la sauce se lie hors du feu.",
                    en: "Deglaze with lemon and cold butter: the sauce binds off the heat.",
                    es: "Desglasa con limón y mantequilla fría: la salsa liga fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "porc-chou-rouge",
            name: LocalizedText(
                fr: "Porc au chou rouge, pommes de terre",
                en: "Pork with red cabbage and potatoes",
                es: "Cerdo con lombarda y patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-echine", carbID: "pomme-de-terre",
            fatID: "huile-colza", extraIDs: ["chou-rouge", "oignon"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Le chou rouge a besoin d'acide pour garder sa couleur : vinaigre dès le départ.",
                    en: "Red cabbage needs acid to keep its colour: vinegar from the start.",
                    es: "La lombarda necesita ácido para conservar el color: vinagre desde el principio."
                ),
                LocalizedText(
                    fr: "Trente minutes à couvert avec les oignons, porc doré ajouté à mi-parcours.",
                    en: "Thirty minutes covered with the onions, browned pork added halfway.",
                    es: "Treinta minutos tapado con la cebolla, cerdo dorado a mitad."
                ),
            ]
        ),
        Recipe(
            id: "porc-abricots-boulgour",
            name: LocalizedText(
                fr: "Porc aux abricots secs, boulgour",
                en: "Pork with dried apricots and bulgur",
                es: "Cerdo con orejones y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "boulgour",
            fatID: "amandes", extraIDs: ["oignon", "carotte"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Fais gonfler les abricots dix minutes dans l'eau chaude avant tout.",
                    en: "Plump the apricots ten minutes in hot water first.",
                    es: "Hidrata los orejones diez minutos en agua caliente antes de nada."
                ),
                LocalizedText(
                    fr: "Porc doré, oignons, carottes, abricots, cannelle : vingt minutes à couvert.",
                    en: "Browned pork, onions, carrots, apricots, cinnamon: twenty minutes covered.",
                    es: "Cerdo dorado, cebolla, zanahoria, orejones, canela: veinte minutos tapado."
                ),
            ]
        ),
        Recipe(
            id: "agneau-haricots-verts",
            name: LocalizedText(
                fr: "Agneau aux haricots verts, semoule",
                en: "Lamb with green beans and couscous",
                es: "Cordero con judías verdes y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "agneau-gigot", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["haricots-verts", "tomate"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Agneau en cubes doré à feu vif, ail et cumin après, jamais avant.",
                    en: "Lamb cubed and browned over high heat, garlic and cumin after, never before.",
                    es: "Cordero en cubos dorado a fuego fuerte, ajo y comino después, nunca antes."
                ),
                LocalizedText(
                    fr: "Tomates et haricots verts, vingt-cinq minutes à couvert.",
                    en: "Tomatoes and green beans, twenty-five minutes covered.",
                    es: "Tomate y judías verdes, veinticinco minutos tapado."
                ),
            ]
        ),
        Recipe(
            id: "lapin-carottes-polenta",
            name: LocalizedText(
                fr: "Lapin aux carottes, polenta",
                en: "Rabbit with carrots and polenta",
                es: "Conejo con zanahorias y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lapin", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["carotte", "champignons"],
            minutes: 50,
            steps: [
                LocalizedText(
                    fr: "Le lapin sèche vite : cuis-le à couvert, jamais à découvert.",
                    en: "Rabbit dries out fast: cook it covered, never uncovered.",
                    es: "El conejo se seca rápido: cocínalo tapado, nunca destapado."
                ),
                LocalizedText(
                    fr: "Carottes et champignons avec, quarante minutes à feu doux.",
                    en: "Carrots and mushrooms with it, forty minutes on low.",
                    es: "Zanahoria y champiñones con él, cuarenta minutos a fuego suave."
                ),
            ]
        ),
        Recipe(
            id: "foie-volaille-riz",
            name: LocalizedText(
                fr: "Foies de volaille au vinaigre, riz",
                en: "Chicken livers in vinegar with rice",
                es: "Higaditos al vinagre con arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "foie-de-volaille", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["oignon", "champignons"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Les foies se cuisent roses : gris, ils deviennent farineux.",
                    en: "Livers should stay pink: grey, they turn mealy.",
                    es: "Los higaditos deben quedar rosados: grises, se vuelven harinosos."
                ),
                LocalizedText(
                    fr: "Déglace au vinaigre balsamique, une minute, et verse sur le riz.",
                    en: "Deglaze with balsamic, one minute, and pour over the rice.",
                    es: "Desglasa con balsámico, un minuto, y vierte sobre el arroz."
                ),
            ]
        ),
        Recipe(
            id: "jambon-endives-puree",
            name: LocalizedText(
                fr: "Endives au jambon, purée",
                en: "Ham-wrapped chicory with mash",
                es: "Endibias con jamón y puré"
            ),
            slots: [.lunch, .dinner],
            proteinID: "jambon-blanc", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["endive", "oignon"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Fais braiser les endives vingt minutes : crues au four, elles rendent trop d'eau.",
                    en: "Braise the chicory twenty minutes: raw in the oven, it releases too much water.",
                    es: "Brasea las endibias veinte minutos: crudas al horno, sueltan demasiada agua."
                ),
                LocalizedText(
                    fr: "Roule-les dans le jambon, nappe de crème, vingt minutes à 200 °C.",
                    en: "Roll them in the ham, coat with cream, twenty minutes at 200 °C.",
                    es: "Enróllalas en el jamón, cubre con nata, veinte minutos a 200 °C."
                ),
            ]
        ),
        Recipe(
            id: "rosbif-betterave",
            name: LocalizedText(
                fr: "Rosbif, betterave et quinoa",
                en: "Roast beef with beetroot and quinoa",
                es: "Rosbif con remolacha y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "rosbif", carbID: "quinoa",
            fatID: "huile-noix", extraIDs: ["betterave", "roquette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Betterave cuite en dés, huile de noix, vinaigre : le sucré appelle l'acide.",
                    en: "Cooked beetroot in dice, walnut oil, vinegar: sweetness calls for acid.",
                    es: "Remolacha cocida en dados, aceite de nuez, vinagre: lo dulce pide ácido."
                ),
                LocalizedText(
                    fr: "Rosbif tranché fin au dernier moment, roquette par-dessus.",
                    en: "Beef sliced thin at the last moment, rocket over the top.",
                    es: "Rosbif en lonchas finas al final, rúcula por encima."
                ),
            ]
        ),
        Recipe(
            id: "cabillaud-chorizo-pois",
            name: LocalizedText(
                fr: "Cabillaud aux petits pois",
                en: "Cod with peas",
                es: "Bacalao con guisantes"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cabillaud", carbID: "petits-pois",
            fatID: "huile-olive", extraIDs: ["oignon", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Petits pois et oignons fondus ensemble, dix minutes, un fond de bouillon.",
                    en: "Peas and onions softened together, ten minutes, a little stock.",
                    es: "Guisantes y cebolla juntos, diez minutos, un poco de caldo."
                ),
                LocalizedText(
                    fr: "Cabillaud posé dessus, couvercle, huit minutes : il cuit à la vapeur.",
                    en: "Cod laid on top, lid on, eight minutes: it steams.",
                    es: "Bacalao encima, tapa, ocho minutos: se cuece al vapor."
                ),
            ]
        ),
        Recipe(
            id: "colin-tomate-riz",
            name: LocalizedText(
                fr: "Colin à la tomate, riz basmati",
                en: "Hake in tomato with basmati rice",
                es: "Merluza con tomate y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "colin-lieu", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais réduire la sauce avant d'y poser le poisson : après, il serait trop cuit.",
                    en: "Reduce the sauce before adding the fish: after, it would overcook.",
                    es: "Reduce la salsa antes de poner el pescado: después, se pasaría."
                ),
                LocalizedText(
                    fr: "Colin huit minutes à couvert, feu doux. La chair doit se détacher seule.",
                    en: "Hake eight minutes covered, low heat. The flesh should flake on its own.",
                    es: "Merluza ocho minutos tapada, fuego suave. La carne debe soltarse sola."
                ),
            ]
        ),
        Recipe(
            id: "saumon-epinards-pates",
            name: LocalizedText(
                fr: "Pâtes au saumon et aux épinards",
                en: "Salmon and spinach pasta",
                es: "Pasta con salmón y espinacas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon", carbID: "pates-completes",
            fatID: "creme-legere", extraIDs: ["epinards", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le saumon en cubes cuit dans la sauce en trois minutes, pas davantage.",
                    en: "Cubed salmon cooks in the sauce in three minutes, no more.",
                    es: "El salmón en dados se hace en la salsa en tres minutos, no más."
                ),
                LocalizedText(
                    fr: "Épinards fondus en dernier, une louche d'eau de cuisson pour lier.",
                    en: "Spinach wilted last, a ladle of pasta water to bind.",
                    es: "Espinacas al final, un cucharón del agua de cocción para ligar."
                ),
            ]
        ),
        Recipe(
            id: "poulet-coco-basmati",
            name: LocalizedText(
                fr: "Poulet au lait de coco, riz basmati",
                en: "Coconut chicken with basmati rice",
                es: "Pollo al coco con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "riz-basmati",
            fatID: "coco-rape", extraIDs: ["poivron", "epinards"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais griller la coco râpée à sec une minute : elle devient parfumée au lieu d'être fade.",
                    en: "Toast the desiccated coconut dry for a minute: it turns fragrant instead of bland.",
                    es: "Tuesta el coco rallado en seco un minuto: se vuelve aromático en vez de soso."
                ),
                LocalizedText(
                    fr: "Poulet doré, poivrons, un fond d'eau, dix minutes. Épinards à la fin.",
                    en: "Browned chicken, peppers, a little water, ten minutes. Spinach at the end.",
                    es: "Pollo dorado, pimientos, un poco de agua, diez minutos. Espinacas al final."
                ),
            ]
        ),
        Recipe(
            id: "poulet-tandoori",
            name: LocalizedText(
                fr: "Poulet tandoori, riz et concombre",
                en: "Tandoori chicken with rice and cucumber",
                es: "Pollo tandoori con arroz y pepino"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "riz-blanc",
            fatID: "huile-colza", extraIDs: ["concombre", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Yaourt, paprika, cumin, gingembre : la marinade colore autant qu'elle attendrit.",
                    en: "Yoghurt, paprika, cumin, ginger: the marinade colours as much as it tenderises.",
                    es: "Yogur, pimentón, comino, jengibre: la marinada colorea tanto como ablanda."
                ),
                LocalizedText(
                    fr: "Four très chaud, 240 °C, douze minutes : c'est la chaleur brutale qui fait le tandoori.",
                    en: "Very hot oven, 240 °C, twelve minutes: brutal heat is what makes tandoori.",
                    es: "Horno muy caliente, 240 °C, doce minutos: el calor brutal hace el tandoori."
                ),
            ]
        ),
        Recipe(
            id: "poulet-sesame-nouilles",
            name: LocalizedText(
                fr: "Poulet au sésame, vermicelles de riz",
                en: "Sesame chicken with rice noodles",
                es: "Pollo al sésamo con fideos de arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "vermicelles-riz",
            fatID: "graines-sesame", extraIDs: ["carotte", "germes-soja"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Vermicelles trempés trois minutes hors du feu, jamais bouillis.",
                    en: "Noodles soaked three minutes off the heat, never boiled.",
                    es: "Fideos a remojo tres minutos fuera del fuego, nunca hervidos."
                ),
                LocalizedText(
                    fr: "Poulet en lanières, feu vif, sésame grillé hors du feu pour qu'il ne brûle pas.",
                    en: "Chicken in strips, high heat, sesame toasted off the heat so it does not burn.",
                    es: "Pollo en tiras, fuego fuerte, sésamo tostado fuera del fuego para que no se queme."
                ),
            ]
        ),
        Recipe(
            id: "poulet-chorizo-pois-chiches",
            name: LocalizedText(
                fr: "Poulet aux pois chiches, semoule",
                en: "Chicken with chickpeas and couscous",
                es: "Pollo con garbanzos y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cuisse-de-poulet", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Les cuisses supportent la cuisson longue là où le blanc sèche en dix minutes.",
                    en: "Thighs take long cooking where breast dries out in ten minutes.",
                    es: "El contramuslo aguanta la cocción larga donde la pechuga se seca en diez minutos."
                ),
                LocalizedText(
                    fr: "Pois chiches et tomates, vingt-cinq minutes à couvert, paprika fumé.",
                    en: "Chickpeas and tomatoes, twenty-five minutes covered, smoked paprika.",
                    es: "Garbanzos y tomate, veinticinco minutos tapado, pimentón ahumado."
                ),
            ]
        ),
        Recipe(
            id: "dinde-boulettes-tomate",
            name: LocalizedText(
                fr: "Boulettes de dinde à la tomate, pâtes",
                en: "Turkey meatballs in tomato with pasta",
                es: "Albóndigas de pavo en tomate con pasta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "courgette"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "La dinde hachée est sèche : ajoute un œuf et de la mie trempée, jamais rien d'autre.",
                    en: "Turkey mince is dry: add an egg and soaked bread, nothing else.",
                    es: "El pavo picado es seco: añade un huevo y miga remojada, nada más."
                ),
                LocalizedText(
                    fr: "Boulettes dorées puis finies dans la sauce, vingt minutes.",
                    en: "Meatballs browned then finished in the sauce, twenty minutes.",
                    es: "Albóndigas doradas y terminadas en la salsa, veinte minutos."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-tacos",
            name: LocalizedText(
                fr: "Bœuf épicé en tortillas",
                en: "Spiced beef in corn tortillas",
                es: "Ternera especiada en tortillas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-5", carbID: "tortilla-mais",
            fatID: "avocat", extraIDs: ["tomate", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Bœuf haché à feu vif jusqu'à ce qu'il ne rende plus d'eau, puis les épices.",
                    en: "Mince over high heat until it stops releasing water, then the spices.",
                    es: "Carne picada a fuego fuerte hasta que deje de soltar agua, luego las especias."
                ),
                LocalizedText(
                    fr: "Tortillas chauffées à sec dix secondes par face : molles, elles se déchirent.",
                    en: "Tortillas dry-heated ten seconds a side: cold, they tear.",
                    es: "Tortillas en seco diez segundos por cara: frías, se rompen."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-champignons-polenta",
            name: LocalizedText(
                fr: "Bœuf aux champignons, polenta",
                en: "Beef with mushrooms and polenta",
                es: "Ternera con champiñones y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "polenta",
            fatID: "creme-legere", extraIDs: ["champignons", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Champignons en une seule couche, sans sel, jusqu'à coloration franche.",
                    en: "Mushrooms in a single layer, no salt, until properly browned.",
                    es: "Champiñones en una capa, sin sal, hasta que doren de verdad."
                ),
                LocalizedText(
                    fr: "Bœuf saisi une minute par face, crème hors du feu.",
                    en: "Beef seared one minute a side, cream off the heat.",
                    es: "Ternera sellada un minuto por cara, nata fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "porc-nouilles-sautees",
            name: LocalizedText(
                fr: "Porc sauté, vermicelles et chou",
                en: "Stir-fried pork with noodles and cabbage",
                es: "Cerdo salteado con fideos y col"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "vermicelles-riz",
            fatID: "huile-colza", extraIDs: ["chou", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Coupe le porc congelé une demi-heure : il se tranche alors très fin.",
                    en: "Freeze the pork half an hour: it then slices very thin.",
                    es: "Congela el cerdo media hora: así se corta muy fino."
                ),
                LocalizedText(
                    fr: "Feu maximal, un ingrédient à la fois, tout réuni à la fin.",
                    en: "Maximum heat, one ingredient at a time, brought together at the end.",
                    es: "Fuego máximo, un ingrediente cada vez, todo junto al final."
                ),
            ]
        ),
        Recipe(
            id: "agneau-pois-chiches",
            name: LocalizedText(
                fr: "Agneau aux pois chiches, boulgour",
                en: "Lamb with chickpeas and bulgur",
                es: "Cordero con garbanzos y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "agneau-gigot", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["tomate", "oignon"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Cumin, coriandre et cannelle grillés à sec avant d'être moulus : le goût double.",
                    en: "Cumin, coriander and cinnamon dry-toasted before grinding: the flavour doubles.",
                    es: "Comino, cilantro y canela tostados en seco antes de molerlos: el sabor se dobla."
                ),
                LocalizedText(
                    fr: "Agneau doré, tomates, pois chiches, trente minutes à couvert.",
                    en: "Browned lamb, tomatoes, chickpeas, thirty minutes covered.",
                    es: "Cordero dorado, tomate, garbanzos, treinta minutos tapado."
                ),
            ]
        ),
        Recipe(
            id: "saumon-miso-riz",
            name: LocalizedText(
                fr: "Saumon au miso, riz et brocoli",
                en: "Miso salmon with rice and broccoli",
                es: "Salmón al miso con arroz y brócoli"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon", carbID: "riz-blanc",
            fatID: "graines-sesame", extraIDs: ["brocoli", "germes-soja"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Le miso brûle vite : badigeonne le saumon en fin de cuisson, pas au début.",
                    en: "Miso burns fast: brush the salmon at the end, not the start.",
                    es: "El miso se quema rápido: pinta el salmón al final, no al principio."
                ),
                LocalizedText(
                    fr: "Brocoli vapeur cinq minutes, encore ferme sous la dent.",
                    en: "Broccoli steamed five minutes, still firm.",
                    es: "Brócoli al vapor cinco minutos, todavía firme."
                ),
            ]
        ),
        Recipe(
            id: "thon-frais-poivrons",
            name: LocalizedText(
                fr: "Thon frais poêlé, riz et poivrons",
                en: "Seared fresh tuna with rice and peppers",
                es: "Atún fresco a la plancha con arroz y pimientos"
            ),
            slots: [.lunch, .dinner],
            proteinID: "thon-frais", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le thon frais se saisit une minute par face et reste rouge au centre.",
                    en: "Fresh tuna sears one minute a side and stays red inside.",
                    es: "El atún fresco se sella un minuto por cara y queda rojo dentro."
                ),
                LocalizedText(
                    fr: "Cuit à cœur, il devient sec comme une conserve : c'est le seul risque.",
                    en: "Cooked through, it turns dry as a tin: that is the only risk.",
                    es: "Hecho del todo, queda seco como una lata: ese es el único riesgo."
                ),
            ]
        ),
        Recipe(
            id: "sardines-pates",
            name: LocalizedText(
                fr: "Pâtes aux sardines et au fenouil",
                en: "Pasta with sardines and fennel",
                es: "Pasta con sardinas e hinojo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "sardines", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["fenouil", "oignon"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fenouil émincé fondu quinze minutes : c'est lui qui porte le plat.",
                    en: "Sliced fennel softened fifteen minutes: it carries the dish.",
                    es: "Hinojo en láminas pochado quince minutos: él sostiene el plato."
                ),
                LocalizedText(
                    fr: "Sardines écrasées à la fourchette hors du feu, raisins secs et pignons si tu en as.",
                    en: "Sardines crushed with a fork off the heat, raisins and pine nuts if you have them.",
                    es: "Sardinas machacadas con tenedor fuera del fuego, pasas y piñones si tienes."
                ),
            ]
        ),
        Recipe(
            id: "maquereau-moutarde",
            name: LocalizedText(
                fr: "Maquereau à la moutarde, pommes de terre",
                en: "Mustard mackerel with potatoes",
                es: "Caballa a la mostaza con patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "maquereau", carbID: "pomme-de-terre",
            fatID: "huile-colza", extraIDs: ["salade", "radis"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le maquereau est gras : la moutarde et le vinaigre sont là pour couper.",
                    en: "Mackerel is oily: mustard and vinegar are there to cut it.",
                    es: "La caballa es grasa: la mostaza y el vinagre están para cortarla."
                ),
                LocalizedText(
                    fr: "Pommes de terre tièdes, radis en rondelles, salade. Rien à cuire de plus.",
                    en: "Warm potatoes, sliced radish, salad. Nothing more to cook.",
                    es: "Patatas templadas, rábano en rodajas, ensalada. Nada más que cocinar."
                ),
            ]
        ),
        Recipe(
            id: "crevettes-ail-pates",
            name: LocalizedText(
                fr: "Pâtes aux crevettes et à l'ail",
                en: "Garlic prawn pasta",
                es: "Pasta con gambas y ajo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crevettes", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["tomate", "roquette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Ail en lamelles dans l'huile froide, monté doucement : brûlé, il devient amer.",
                    en: "Sliced garlic in cold oil, warmed slowly: burnt, it turns bitter.",
                    es: "Ajo en láminas en aceite frío, subido despacio: quemado, amarga."
                ),
                LocalizedText(
                    fr: "Crevettes deux minutes, roquette hors du feu, elle fane juste ce qu'il faut.",
                    en: "Prawns two minutes, rocket off the heat, it wilts just enough.",
                    es: "Gambas dos minutos, rúcula fuera del fuego, se marchita lo justo."
                ),
            ]
        ),
        Recipe(
            id: "moules-riz-safran",
            name: LocalizedText(
                fr: "Moules au riz safrané",
                en: "Mussels with saffron rice",
                es: "Mejillones con arroz al azafrán"
            ),
            slots: [.lunch, .dinner],
            proteinID: "moules", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["oignon", "poivron"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Garde le jus de cuisson des moules : c'est le bouillon du riz, filtré.",
                    en: "Keep the mussel cooking liquid: strained, it is the rice's stock.",
                    es: "Guarda el caldo de los mejillones: colado, es el caldo del arroz."
                ),
                LocalizedText(
                    fr: "Riz nacré dans les oignons, jus des moules, dix-huit minutes sans remuer.",
                    en: "Rice coated in the onions, mussel liquid, eighteen minutes without stirring.",
                    es: "Arroz nacarado con la cebolla, caldo de mejillón, dieciocho minutos sin remover."
                ),
            ]
        ),
        Recipe(
            id: "surimi-riz-avocat",
            name: LocalizedText(
                fr: "Bol de surimi, riz et avocat",
                en: "Surimi bowl with rice and avocado",
                es: "Bol de surimi con arroz y aguacate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "surimi", carbID: "riz-blanc",
            fatID: "avocat", extraIDs: ["concombre", "carotte"],
            minutes: 15,
            steps: [
                LocalizedText(
                    fr: "Riz assaisonné tiède au vinaigre de riz : froid, il ne prend plus rien.",
                    en: "Rice seasoned warm with rice vinegar: cold, it takes nothing.",
                    es: "Arroz aliñado templado con vinagre de arroz: frío, ya no coge nada."
                ),
                LocalizedText(
                    fr: "Surimi effiloché à la main, légumes en bâtonnets, avocat en dernier.",
                    en: "Surimi shredded by hand, vegetables in batons, avocado last.",
                    es: "Surimi desmenuzado a mano, verduras en bastones, aguacate al final."
                ),
            ]
        ),
        Recipe(
            id: "tilapia-curry-coco",
            name: LocalizedText(
                fr: "Tilapia au curry, riz complet",
                en: "Tilapia curry with brown rice",
                es: "Tilapia al curry con arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tilapia", carbID: "riz-complet",
            fatID: "coco-rape", extraIDs: ["epinards", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Le poisson blanc s'émiette : ajoute-le entier et ne remue plus.",
                    en: "White fish falls apart: add it whole and stop stirring.",
                    es: "El pescado blanco se deshace: añádelo entero y deja de remover."
                ),
                LocalizedText(
                    fr: "Huit minutes à couvert suffisent, la vapeur fait le travail.",
                    en: "Eight minutes covered is enough, the steam does the work.",
                    es: "Ocho minutos tapado bastan, el vapor hace el trabajo."
                ),
            ]
        ),
        Recipe(
            id: "cabillaud-lentilles",
            name: LocalizedText(
                fr: "Cabillaud sur lentilles",
                en: "Cod on lentils",
                es: "Bacalao sobre lentejas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cabillaud", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "poireau"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Lentilles cuites avec carotte et poireau, sans sel jusqu'à la fin.",
                    en: "Lentils cooked with carrot and leek, no salt until the end.",
                    es: "Lentejas cocidas con zanahoria y puerro, sin sal hasta el final."
                ),
                LocalizedText(
                    fr: "Cabillaud posé dessus cinq minutes à couvert : la vapeur des lentilles le cuit.",
                    en: "Cod laid on top five minutes covered: the lentils' steam cooks it.",
                    es: "Bacalao encima cinco minutos tapado: el vapor de las lentejas lo cuece."
                ),
            ]
        ),
        Recipe(
            id: "truite-riz-amandes",
            name: LocalizedText(
                fr: "Truite aux amandes, riz basmati",
                en: "Trout with almonds and basmati rice",
                es: "Trucha con almendras y arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "truite", carbID: "riz-basmati",
            fatID: "amandes", extraIDs: ["haricots-verts", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Amandes effilées grillées à sec : dix secondes de trop et elles sont perdues.",
                    en: "Flaked almonds toasted dry: ten seconds too long and they are gone.",
                    es: "Almendras laminadas tostadas en seco: diez segundos de más y se pierden."
                ),
                LocalizedText(
                    fr: "Truite quatre minutes côté peau, deux de l'autre, amandes et citron dessus.",
                    en: "Trout four minutes skin down, two on the other, almonds and lemon over.",
                    es: "Trucha cuatro minutos por la piel, dos por el otro, almendras y limón encima."
                ),
            ]
        ),
        Recipe(
            id: "bar-fenouil-quinoa",
            name: LocalizedText(
                fr: "Bar au fenouil, quinoa",
                en: "Sea bass with fennel and quinoa",
                es: "Lubina con hinojo y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "bar", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["fenouil", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fenouil en fines lamelles, rôti vingt minutes : il devient sucré.",
                    en: "Fennel thinly sliced, roasted twenty minutes: it turns sweet.",
                    es: "Hinojo en láminas finas, asado veinte minutos: se vuelve dulce."
                ),
                LocalizedText(
                    fr: "Bar posé dessus, dix minutes de plus, citron et huile d'olive crue.",
                    en: "Bass laid on top, ten minutes more, lemon and raw olive oil.",
                    es: "Lubina encima, diez minutos más, limón y aceite crudo."
                ),
            ]
        ),
        Recipe(
            id: "calamars-grilles",
            name: LocalizedText(
                fr: "Calamars grillés, boulgour",
                en: "Grilled squid with bulgur",
                es: "Calamares a la plancha con bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "calamars", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["roquette", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Deux minutes à feu maximal : c'est la cuisson courte, l'autre option étant quarante minutes.",
                    en: "Two minutes at maximum heat: the short cooking, the other option being forty minutes.",
                    es: "Dos minutos a fuego máximo: la cocción corta, la otra opción son cuarenta minutos."
                ),
                LocalizedText(
                    fr: "Citron et ail hors du feu, jamais pendant : ils brûleraient.",
                    en: "Lemon and garlic off the heat, never during: they would burn.",
                    es: "Limón y ajo fuera del fuego, nunca durante: se quemarían."
                ),
            ]
        ),
        Recipe(
            id: "noix-st-jacques-risotto",
            name: LocalizedText(
                fr: "Saint-Jacques, orge façon risotto",
                en: "Scallops with barley risotto",
                es: "Vieiras con cebada en risotto"
            ),
            slots: [.lunch, .dinner],
            proteinID: "noix-st-jacques", carbID: "orge-perle",
            fatID: "beurre", extraIDs: ["champignons", "oignon"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "L'orge se cuit comme un risotto, louche par louche : trente minutes.",
                    en: "Barley cooks like risotto, ladle by ladle: thirty minutes.",
                    es: "La cebada se cocina como un risotto, cucharón a cucharón: treinta minutos."
                ),
                LocalizedText(
                    fr: "Saint-Jacques sèches, poêle brûlante, quatre-vingt-dix secondes par face.",
                    en: "Dry scallops, scorching pan, ninety seconds a side.",
                    es: "Vieiras secas, sartén ardiendo, noventa segundos por cara."
                ),
            ]
        ),
        Recipe(
            id: "crabe-pates-citron",
            name: LocalizedText(
                fr: "Pâtes au crabe et au citron",
                en: "Crab and lemon pasta",
                es: "Pasta con cangrejo y limón"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crabe", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["roquette", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le crabe ne se cuit pas ici : il se mélange hors du feu, c'est tout.",
                    en: "The crab is not cooked here: it is folded in off the heat, that is all.",
                    es: "El cangrejo no se cocina aquí: se mezcla fuera del fuego, nada más."
                ),
                LocalizedText(
                    fr: "Zeste de citron plutôt que jus : l'acide ferait tourner le goût iodé.",
                    en: "Lemon zest rather than juice: acid would turn the sea flavour.",
                    es: "Ralladura en vez de zumo: el ácido estropearía el sabor marino."
                ),
            ]
        ),
        Recipe(
            id: "hareng-betterave",
            name: LocalizedText(
                fr: "Hareng, betterave et pommes de terre",
                en: "Herring with beetroot and potatoes",
                es: "Arenque con remolacha y patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "hareng", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["betterave", "oignon"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Betterave cuite en dés, oignon rincé, crème et aneth : la salade du nord.",
                    en: "Diced cooked beetroot, rinsed onion, cream and dill: the northern salad.",
                    es: "Remolacha cocida en dados, cebolla enjuagada, nata y eneldo: la ensalada del norte."
                ),
                LocalizedText(
                    fr: "Hareng ajouté au dernier moment, sinon il colore tout en rose.",
                    en: "Herring added at the last moment, or it turns everything pink.",
                    es: "Arenque al final, si no lo tiñe todo de rosa."
                ),
            ]
        ),
        Recipe(
            id: "anchois-pates-chou-fleur",
            name: LocalizedText(
                fr: "Pâtes au chou-fleur et aux anchois",
                en: "Cauliflower and anchovy pasta",
                es: "Pasta con coliflor y anchoas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "anchois", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["chou-fleur", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Les anchois fondent dans l'huile chaude : ils ne salent pas, ils profondissent.",
                    en: "Anchovies melt in hot oil: they do not salt, they deepen.",
                    es: "Las anchoas se deshacen en aceite caliente: no salan, dan profundidad."
                ),
                LocalizedText(
                    fr: "Chou-fleur cuit jusqu'à s'écraser, vingt minutes : c'est la sauce elle-même.",
                    en: "Cauliflower cooked until it collapses, twenty minutes: it is the sauce itself.",
                    es: "Coliflor cocida hasta deshacerse, veinte minutos: es la salsa misma."
                ),
            ]
        ),
        Recipe(
            id: "tofu-brocoli-sesame",
            name: LocalizedText(
                fr: "Tofu et brocoli au sésame, riz basmati",
                en: "Tofu and broccoli with sesame",
                es: "Tofu y brócoli al sésamo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu", carbID: "riz-basmati",
            fatID: "graines-sesame", extraIDs: ["brocoli", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Presse le tofu dix minutes : sans ça il ne dore jamais.",
                    en: "Press the tofu ten minutes: without it, it never browns.",
                    es: "Prensa el tofu diez minutos: sin eso, nunca se dora."
                ),
                LocalizedText(
                    fr: "Brocoli deux minutes à l'eau bouillante avant de sauter : il reste vert et croquant.",
                    en: "Broccoli two minutes in boiling water before the pan: it stays green and crunchy.",
                    es: "Brócoli dos minutos en agua hirviendo antes de saltear: queda verde y crujiente."
                ),
            ]
        ),
        Recipe(
            id: "tofu-champignons-nouilles",
            name: LocalizedText(
                fr: "Tofu aux champignons, vermicelles",
                en: "Tofu with mushrooms and noodles",
                es: "Tofu con champiñones y fideos"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu-fume", carbID: "vermicelles-riz",
            fatID: "huile-colza", extraIDs: ["champignons", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le tofu fumé n'a pas besoin d'être pressé : il est déjà ferme et parfumé.",
                    en: "Smoked tofu needs no pressing: it is already firm and fragrant.",
                    es: "El tofu ahumado no necesita prensado: ya es firme y aromático."
                ),
                LocalizedText(
                    fr: "Champignons à feu vif d'abord, tout le reste ensuite.",
                    en: "Mushrooms over high heat first, everything else after.",
                    es: "Champiñones a fuego fuerte primero, lo demás después."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-chou-quinoa",
            name: LocalizedText(
                fr: "Tempeh au chou, quinoa",
                en: "Tempeh with cabbage and quinoa",
                es: "Tempeh con col y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["chou", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fais bouillir le tempeh cinq minutes avant : c'est ce qui enlève l'amertume.",
                    en: "Boil the tempeh five minutes first: that is what removes the bitterness.",
                    es: "Hierve el tempeh cinco minutos antes: eso quita el amargor."
                ),
                LocalizedText(
                    fr: "Puis dore-le à la poêle avec de la sauce soja et du sirop d'érable.",
                    en: "Then brown it in the pan with soy sauce and maple syrup.",
                    es: "Luego dóralo con salsa de soja y sirope de arce."
                ),
            ]
        ),
        Recipe(
            id: "seitan-tomate-pates",
            name: LocalizedText(
                fr: "Seitan à la tomate, pâtes complètes",
                en: "Seitan in tomato with wholewheat pasta",
                es: "Seitán con tomate y pasta integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "seitan", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "courgette"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Seitan en tranches dorées à part : dans la sauce d'emblée, il reste mou.",
                    en: "Seitan sliced and browned separately: straight into the sauce, it stays soft.",
                    es: "Seitán en lonchas dorado aparte: directo a la salsa, queda blando."
                ),
                LocalizedText(
                    fr: "Courgettes en dés dans la sauce, quinze minutes.",
                    en: "Diced courgettes in the sauce, fifteen minutes.",
                    es: "Calabacín en dados en la salsa, quince minutos."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-betterave",
            name: LocalizedText(
                fr: "Lentilles à la betterave, boulgour",
                en: "Lentils with beetroot and bulgur",
                es: "Lentejas con remolacha y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "boulgour",
            fatID: "huile-noix", extraIDs: ["betterave", "roquette"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Lentilles vertes vingt minutes, encore fermes : en purée, le plat perd tout.",
                    en: "Green lentils twenty minutes, still firm: mushy, the dish loses everything.",
                    es: "Lentejas verdes veinte minutos, aún firmes: hechas puré, el plato lo pierde todo."
                ),
                LocalizedText(
                    fr: "Betterave en dés, huile de noix, vinaigre de cidre, roquette crue.",
                    en: "Diced beetroot, walnut oil, cider vinegar, raw rocket.",
                    es: "Remolacha en dados, aceite de nuez, vinagre de sidra, rúcula cruda."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-courge",
            name: LocalizedText(
                fr: "Lentilles à la courge, riz complet",
                en: "Lentils with squash and brown rice",
                es: "Lentejas con calabaza y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["butternut", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Butternut en cubes rôtis vingt-cinq minutes : bouillie, elle devient aqueuse.",
                    en: "Butternut roasted in cubes twenty-five minutes: boiled, it turns watery.",
                    es: "Calabaza en cubos asada veinticinco minutos: hervida, queda aguada."
                ),
                LocalizedText(
                    fr: "Lentilles à part, réunies à la fin avec du cumin et du citron.",
                    en: "Lentils separately, combined at the end with cumin and lemon.",
                    es: "Lentejas aparte, unidas al final con comino y limón."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-epinards-curry",
            name: LocalizedText(
                fr: "Curry de pois chiches aux épinards, riz",
                en: "Chickpea and spinach curry with rice",
                es: "Curry de garbanzos con espinacas y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["epinards", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais chauffer les épices dans l'huile avant tout : c'est ce qui les réveille.",
                    en: "Warm the spices in the oil first: that is what wakes them.",
                    es: "Calienta las especias en el aceite primero: eso las despierta."
                ),
                LocalizedText(
                    fr: "Écrase un quart des pois chiches : ils épaississent la sauce.",
                    en: "Crush a quarter of the chickpeas: they thicken the sauce.",
                    es: "Machaca un cuarto de los garbanzos: espesan la salsa."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-butternut",
            name: LocalizedText(
                fr: "Pois chiches à la courge, semoule",
                en: "Chickpeas with squash and couscous",
                es: "Garbanzos con calabaza y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["butternut", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Courge et oignons rôtis ensemble, harissa et miel : le sucré-épicé du Maghreb.",
                    en: "Squash and onions roasted together, harissa and honey: the sweet-spiced north African note.",
                    es: "Calabaza y cebolla asadas juntas, harissa y miel: el dulce-picante magrebí."
                ),
                LocalizedText(
                    fr: "Pois chiches ajoutés dix minutes avant la fin, pour qu'ils dorent.",
                    en: "Chickpeas added ten minutes before the end, so they brown.",
                    es: "Garbanzos diez minutos antes del final, para que se doren."
                ),
            ]
        ),
        Recipe(
            id: "haricots-rouges-patate",
            name: LocalizedText(
                fr: "Haricots rouges à la patate douce",
                en: "Red beans with sweet potato",
                es: "Alubias rojas con boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-rouges", carbID: "patate-douce",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Patate douce en cubes rôtie à part : dans le ragoût, elle se délite.",
                    en: "Sweet potato roasted separately in cubes: in the stew it falls apart.",
                    es: "Boniato asado aparte en cubos: en el guiso se deshace."
                ),
                LocalizedText(
                    fr: "Haricots, poivrons, cumin et paprika fumé, vingt minutes.",
                    en: "Beans, peppers, cumin and smoked paprika, twenty minutes.",
                    es: "Alubias, pimientos, comino y pimentón ahumado, veinte minutos."
                ),
            ]
        ),
        Recipe(
            id: "haricots-blancs-kale",
            name: LocalizedText(
                fr: "Haricots blancs au chou kale, épeautre",
                en: "White beans with kale and spelt",
                es: "Alubias blancas con kale y espelta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-blancs", carbID: "epeautre",
            fatID: "huile-olive", extraIDs: ["chou-kale", "oignon"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Masse le kale à l'huile une minute : cru et non massé, il reste coriace.",
                    en: "Massage the kale with oil for a minute: raw and unmassaged, it stays tough.",
                    es: "Masajea el kale con aceite un minuto: crudo y sin masajear, queda duro."
                ),
                LocalizedText(
                    fr: "Épeataire trente-cinq minutes, haricots et kale réunis à la fin.",
                    en: "Spelt thirty-five minutes, beans and kale added at the end.",
                    es: "Espelta treinta y cinco minutos, alubias y kale al final."
                ),
            ]
        ),
        Recipe(
            id: "haricots-noirs-riz-coco",
            name: LocalizedText(
                fr: "Haricots noirs au riz de coco",
                en: "Black beans with coconut rice",
                es: "Alubias negras con arroz al coco"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-noirs", carbID: "riz-blanc",
            fatID: "coco-rape", extraIDs: ["poivron", "tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Le riz cuit avec la coco râpée prend un parfum que rien n'imite.",
                    en: "Rice cooked with desiccated coconut takes on a scent nothing imitates.",
                    es: "El arroz cocido con coco rallado coge un aroma inimitable."
                ),
                LocalizedText(
                    fr: "Haricots mijotés avec ail, cumin et un trait de vinaigre.",
                    en: "Beans simmered with garlic, cumin and a dash of vinegar.",
                    es: "Alubias guisadas con ajo, comino y un chorro de vinagre."
                ),
            ]
        ),
        Recipe(
            id: "falafel-boulgour",
            name: LocalizedText(
                fr: "Falafels, boulgour et concombre",
                en: "Falafel with bulgur and cucumber",
                es: "Falafel con bulgur y pepino"
            ),
            slots: [.lunch, .dinner],
            proteinID: "falafel", carbID: "boulgour",
            fatID: "tahini", extraIDs: ["concombre", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Falafels réchauffés au four, jamais au micro-ondes : ils deviendraient mous.",
                    en: "Falafel reheated in the oven, never the microwave: they would go soggy.",
                    es: "Falafel recalentado al horno, nunca al microondas: quedaría blando."
                ),
                LocalizedText(
                    fr: "Salade concombre-tomate au citron, sauce tahini à part.",
                    en: "Cucumber and tomato salad with lemon, tahini sauce on the side.",
                    es: "Ensalada de pepino y tomate con limón, salsa de tahini aparte."
                ),
            ]
        ),
        Recipe(
            id: "edamame-riz-avocat",
            name: LocalizedText(
                fr: "Bol d'édamame, riz et avocat",
                en: "Edamame bowl with rice and avocado",
                es: "Bol de edamame con arroz y aguacate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "edamame", carbID: "riz-blanc",
            fatID: "avocat", extraIDs: ["concombre", "carotte"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Édamame cinq minutes à l'eau salée : le sel entre par la cosse.",
                    en: "Edamame five minutes in salted water: the salt gets in through the pod.",
                    es: "Edamame cinco minutos en agua con sal: la sal entra por la vaina."
                ),
                LocalizedText(
                    fr: "Riz vinaigré tiède, légumes crus, avocat en dernier.",
                    en: "Warm seasoned rice, raw vegetables, avocado last.",
                    es: "Arroz avinagrado templado, verduras crudas, aguacate al final."
                ),
            ]
        ),
        Recipe(
            id: "feves-boulgour",
            name: LocalizedText(
                fr: "Fèves au boulgour et à la menthe",
                en: "Broad beans with bulgur and mint",
                es: "Habas con bulgur y menta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "feves", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["oignon", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fèves surgelées cinq minutes, pelées si la peau est épaisse.",
                    en: "Frozen broad beans five minutes, peeled if the skins are thick.",
                    es: "Habas congeladas cinco minutos, peladas si la piel es gruesa."
                ),
                LocalizedText(
                    fr: "Menthe et citron à froid : chauffés, ils perdent tout.",
                    en: "Mint and lemon cold: heated, they lose everything.",
                    es: "Menta y limón en frío: calentados, lo pierden todo."
                ),
            ]
        ),
        Recipe(
            id: "pois-casses-carottes",
            name: LocalizedText(
                fr: "Purée de pois cassés aux carottes",
                en: "Split pea purée with carrots",
                es: "Puré de guisantes secos con zanahoria"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-casses", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "poireau"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Les pois cassés n'ont pas besoin de trempage, contrairement aux autres légumineuses.",
                    en: "Split peas need no soaking, unlike other pulses.",
                    es: "Los guisantes secos no necesitan remojo, a diferencia de otras legumbres."
                ),
                LocalizedText(
                    fr: "Sel seulement à la fin, sinon ils restent fermes indéfiniment.",
                    en: "Salt only at the end, or they stay firm indefinitely.",
                    es: "Sala solo al final, si no quedan duros para siempre."
                ),
            ]
        ),
        Recipe(
            id: "proteine-soja-chili",
            name: LocalizedText(
                fr: "Chili de soja texturé, riz",
                en: "Textured soy chilli with rice",
                es: "Chili de soja texturizada con arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "proteine-soja", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Réhydrate le soja dans du bouillon, jamais dans l'eau : c'est là qu'il prend son goût.",
                    en: "Rehydrate the soy in stock, never water: that is where it takes its flavour.",
                    es: "Hidrata la soja en caldo, nunca en agua: ahí coge sabor."
                ),
                LocalizedText(
                    fr: "Vingt minutes à découvert avec les épices, il absorbe tout.",
                    en: "Twenty minutes uncovered with the spices, it absorbs everything.",
                    es: "Veinte minutos destapado con las especias, lo absorbe todo."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-shakshuka",
            name: LocalizedText(
                fr: "Shakshuka aux poivrons",
                en: "Shakshuka with peppers",
                es: "Shakshuka con pimientos"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["poivron", "sauce-tomate"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Poivrons fondus vingt minutes avant les œufs : pressés, ils restent crus.",
                    en: "Peppers softened twenty minutes before the eggs: rushed, they stay raw.",
                    es: "Pimientos pochados veinte minutos antes de los huevos: con prisa, quedan crudos."
                ),
                LocalizedText(
                    fr: "Creuse des puits, casse les œufs dedans, couvre cinq minutes.",
                    en: "Make wells, crack the eggs in, cover five minutes.",
                    es: "Haz huecos, casca los huevos dentro, tapa cinco minutos."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-riz-saute-legumes",
            name: LocalizedText(
                fr: "Riz sauté aux œufs et légumes",
                en: "Egg fried rice with vegetables",
                es: "Arroz salteado con huevo y verduras"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "riz-blanc",
            fatID: "huile-colza", extraIDs: ["carotte", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Brouille les œufs à part et réserve-les : cuits avec le riz, ils s'y noient.",
                    en: "Scramble the eggs separately and set aside: cooked with the rice, they drown in it.",
                    es: "Revuelve los huevos aparte y resérvalos: con el arroz, se pierden."
                ),
                LocalizedText(
                    fr: "Riz froid, feu maximal, œufs remis au tout dernier moment.",
                    en: "Cold rice, maximum heat, eggs returned at the very end.",
                    es: "Arroz frío, fuego máximo, huevos al final del todo."
                ),
            ]
        ),
        Recipe(
            id: "cottage-gnocchis",
            name: LocalizedText(
                fr: "Gnocchis au cottage et aux épinards",
                en: "Gnocchi with cottage cheese and spinach",
                es: "Ñoquis con requesón y espinacas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cottage", carbID: "gnocchis",
            fatID: "huile-olive", extraIDs: ["epinards", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Gnocchis poêlés après l'eau : la croûte vaut mieux que la sauce.",
                    en: "Gnocchi pan-fried after boiling: the crust beats the sauce.",
                    es: "Ñoquis salteados tras el agua: la costra vale más que la salsa."
                ),
                LocalizedText(
                    fr: "Cottage hors du feu, toujours : chauffé fort, il tranche.",
                    en: "Cottage cheese off the heat, always: heated hard, it splits.",
                    es: "Requesón fuera del fuego, siempre: muy caliente, se corta."
                ),
            ]
        ),
        Recipe(
            id: "skyr-pommes-terre-saumon",
            name: LocalizedText(
                fr: "Pommes de terre au skyr et aux herbes",
                en: "Potatoes with skyr and herbs",
                es: "Patatas con skyr y hierbas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "skyr", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["radis", "concombre"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Skyr, citron, ciboulette : une sauce qui remplace la crème sans y perdre.",
                    en: "Skyr, lemon, chives: a sauce that replaces cream without losing anything.",
                    es: "Skyr, limón, cebollino: una salsa que sustituye a la nata sin perder nada."
                ),
                LocalizedText(
                    fr: "Pommes de terre tièdes, radis et concombre crus pour le croquant.",
                    en: "Warm potatoes, raw radish and cucumber for crunch.",
                    es: "Patatas templadas, rábano y pepino crudos para el crujiente."
                ),
            ]
        ),
        Recipe(
            id: "tofu-poireaux-millet",
            name: LocalizedText(
                fr: "Tofu aux poireaux, millet",
                en: "Tofu with leeks and millet",
                es: "Tofu con puerros y mijo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu", carbID: "millet",
            fatID: "huile-colza", extraIDs: ["poireau", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Le millet cuit en vingt minutes et double de volume : compte petit.",
                    en: "Millet cooks in twenty minutes and doubles: measure small.",
                    es: "El mijo se hace en veinte minutos y dobla: mide poco."
                ),
                LocalizedText(
                    fr: "Poireaux fondus à couvert, tofu doré à part, réunis à la fin.",
                    en: "Leeks softened covered, tofu browned separately, combined at the end.",
                    es: "Puerros pochados tapados, tofu dorado aparte, unidos al final."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-tomate-polenta",
            name: LocalizedText(
                fr: "Tempeh à la tomate, polenta",
                en: "Tempeh in tomato with polenta",
                es: "Tempeh con tomate y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Tempeh en cubes dorés d'abord : la couleur porte tout le plat.",
                    en: "Tempeh cubed and browned first: the colour carries the dish.",
                    es: "Tempeh en dados dorado primero: el color sostiene el plato."
                ),
                LocalizedText(
                    fr: "Sauce tomate et poivrons, vingt minutes, origan à la fin.",
                    en: "Tomato sauce and peppers, twenty minutes, oregano at the end.",
                    es: "Salsa de tomate y pimientos, veinte minutos, orégano al final."
                ),
            ]
        ),
        Recipe(
            id: "seitan-brocoli-riz",
            name: LocalizedText(
                fr: "Seitan au brocoli, riz complet",
                en: "Seitan with broccoli and brown rice",
                es: "Seitán con brócoli y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "seitan", carbID: "riz-complet",
            fatID: "graines-sesame", extraIDs: ["brocoli", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Sauce soja, ail, gingembre, une cuillère de maïzena : la sauce nappe en trente secondes.",
                    en: "Soy, garlic, ginger, a spoon of cornflour: the sauce coats in thirty seconds.",
                    es: "Soja, ajo, jengibre, una cucharada de maicena: la salsa nape en treinta segundos."
                ),
                LocalizedText(
                    fr: "Brocoli croquant, seitan doré, tout réuni au dernier moment.",
                    en: "Crunchy broccoli, browned seitan, combined at the last moment.",
                    es: "Brócoli crujiente, seitán dorado, todo junto al final."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-champignons-pates",
            name: LocalizedText(
                fr: "Pâtes aux lentilles et champignons",
                en: "Lentil and mushroom pasta",
                es: "Pasta con lentejas y champiñones"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["champignons", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Champignons hachés fin avec les lentilles : ensemble, ils imitent la viande hachée.",
                    en: "Mushrooms finely chopped with the lentils: together they mimic mince.",
                    es: "Champiñones picados finos con las lentejas: juntos imitan la carne picada."
                ),
                LocalizedText(
                    fr: "Vingt minutes de mijotage. Le temps est le seul ingrédient qui manque toujours.",
                    en: "Twenty minutes of simmering. Time is the one ingredient always missing.",
                    es: "Veinte minutos de cocción. El tiempo es el único ingrediente que siempre falta."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-chou-fleur",
            name: LocalizedText(
                fr: "Pois chiches et chou-fleur rôtis, quinoa",
                en: "Roast chickpeas and cauliflower with quinoa",
                es: "Garbanzos y coliflor asados con quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "quinoa",
            fatID: "tahini", extraIDs: ["chou-fleur", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Chou-fleur en petits bouquets, 220 °C : il caramélise au lieu de blanchir.",
                    en: "Cauliflower in small florets, 220 °C: it caramelises instead of blanching.",
                    es: "Coliflor en ramilletes pequeños, 220 °C: se carameliza en vez de blanquearse."
                ),
                LocalizedText(
                    fr: "Pois chiches sur la même plaque, vingt-cinq minutes, tahini au citron.",
                    en: "Chickpeas on the same tray, twenty-five minutes, lemon tahini.",
                    es: "Garbanzos en la misma bandeja, veinticinco minutos, tahini al limón."
                ),
            ]
        ),
        Recipe(
            id: "poulet-estragon",
            name: LocalizedText(
                fr: "Poulet à l'estragon, pommes de terre",
                en: "Tarragon chicken with potatoes",
                es: "Pollo al estragón con patatas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["champignons", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "L'estragon s'ajoute en fin de cuisson : bouilli, il tourne au foin.",
                    en: "Tarragon goes in at the end: boiled, it turns to hay.",
                    es: "El estragón se añade al final: hervido, sabe a heno."
                ),
                LocalizedText(
                    fr: "Crème hors du feu, elle ne doit jamais bouillir.",
                    en: "Cream off the heat, it must never boil.",
                    es: "Nata fuera del fuego, nunca debe hervir."
                ),
            ]
        ),
        Recipe(
            id: "poulet-paprika-patate",
            name: LocalizedText(
                fr: "Poulet paprika, patate douce",
                en: "Paprika chicken with sweet potato",
                es: "Pollo al pimentón con boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "patate-douce",
            fatID: "huile-olive", extraIDs: ["poivron", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Le paprika brûle à feu vif : ajoute-le hors du feu, dans l'huile tiède.",
                    en: "Paprika burns on high heat: add it off the heat, in warm oil.",
                    es: "El pimentón se quema a fuego fuerte: añádelo fuera del fuego, en aceite templado."
                ),
                LocalizedText(
                    fr: "Patate douce rôtie vingt-cinq minutes à 200 °C.",
                    en: "Sweet potato roasted twenty-five minutes at 200 °C.",
                    es: "Boniato asado veinticinco minutos a 200 °C."
                ),
            ]
        ),
        Recipe(
            id: "poulet-olives-quinoa",
            name: LocalizedText(
                fr: "Poulet aux olives, quinoa",
                en: "Chicken with olives and quinoa",
                es: "Pollo con aceitunas y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cuisse-de-poulet", carbID: "quinoa",
            fatID: "olives", extraIDs: ["tomate", "poivron"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Dessale les olives cinq minutes à l'eau si elles sont très salées.",
                    en: "Rinse the olives five minutes if they are very salty.",
                    es: "Enjuaga las aceitunas cinco minutos si están muy saladas."
                ),
                LocalizedText(
                    fr: "Cuisses à couvert vingt-cinq minutes : elles fondent au lieu de sécher.",
                    en: "Thighs covered twenty-five minutes: they melt instead of drying.",
                    es: "Contramuslos tapados veinticinco minutos: se deshacen en vez de secarse."
                ),
            ]
        ),
        Recipe(
            id: "poulet-poivrons-epeautre",
            name: LocalizedText(
                fr: "Poulet aux poivrons, épeautre",
                en: "Chicken with peppers and spelt",
                es: "Pollo con pimientos y espelta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "epeautre",
            fatID: "huile-olive", extraIDs: ["poivron", "courgette"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Poivrons pelés au four : la peau est ce qui les rend indigestes.",
                    en: "Peppers peeled after roasting: the skin is what makes them hard to digest.",
                    es: " Pimientos pelados tras asar: la piel es lo que los hace indigestos."
                ),
                LocalizedText(
                    fr: "Épeautre trente-cinq minutes, lancé avant tout le reste.",
                    en: "Spelt thirty-five minutes, started before everything else.",
                    es: "Espelta treinta y cinco minutos, antes que nada."
                ),
            ]
        ),
        Recipe(
            id: "dinde-poireaux-riz",
            name: LocalizedText(
                fr: "Dinde aux poireaux, riz complet",
                en: "Turkey with leeks and brown rice",
                es: "Pavo con puerros y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "riz-complet",
            fatID: "creme-legere", extraIDs: ["poireau", "carotte"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Poireaux fondus à couvert, sans coloration : c'est une base douce, pas un rissolé.",
                    en: "Leeks softened covered, no colour: this is a gentle base, not a fry-up.",
                    es: "Puerros pochados tapados, sin color: es una base suave, no un sofrito."
                ),
                LocalizedText(
                    fr: "Dinde trois minutes seulement, elle sèche plus vite que le poulet.",
                    en: "Turkey three minutes only, it dries faster than chicken.",
                    es: "Pavo solo tres minutos, se seca antes que el pollo."
                ),
            ]
        ),
        Recipe(
            id: "dinde-curry-patate",
            name: LocalizedText(
                fr: "Curry de dinde à la patate douce",
                en: "Turkey curry with sweet potato",
                es: "Curry de pavo con boniato"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "patate-douce",
            fatID: "huile-colza", extraIDs: ["epinards", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Patate douce en cubes, dix minutes d'avance : elle est plus longue que la viande.",
                    en: "Sweet potato cubed, ten minutes' head start: it takes longer than the meat.",
                    es: "Boniato en cubos, diez minutos de ventaja: tarda más que la carne."
                ),
                LocalizedText(
                    fr: "Épinards à la toute fin, trente secondes suffisent.",
                    en: "Spinach at the very end, thirty seconds is enough.",
                    es: "Espinacas al final, treinta segundos bastan."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-brocoli-nouilles",
            name: LocalizedText(
                fr: "Bœuf au brocoli, vermicelles",
                en: "Beef and broccoli with noodles",
                es: "Ternera con brócoli y fideos"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "vermicelles-riz",
            fatID: "huile-colza", extraIDs: ["brocoli", "germes-soja"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Bœuf mariné dix minutes dans la sauce soja et la maïzena : elle protège la viande.",
                    en: "Beef marinated ten minutes in soy and cornflour: it shields the meat.",
                    es: "Ternera marinada diez minutos en soja y maicena: protege la carne."
                ),
                LocalizedText(
                    fr: "Feu maximal, une minute par face, réservé aussitôt.",
                    en: "Maximum heat, one minute a side, set aside at once.",
                    es: "Fuego máximo, un minuto por cara, reservar enseguida."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-haricots-verts",
            name: LocalizedText(
                fr: "Bœuf aux haricots verts, riz",
                en: "Beef with green beans and rice",
                es: "Ternera con judías verdes y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-5", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["haricots-verts", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Haricots verts blanchis huit minutes puis passés à l'eau froide : ils gardent le vert.",
                    en: "Green beans blanched eight minutes then cooled: they keep their green.",
                    es: "Judías verdes ocho minutos y luego agua fría: conservan el verde."
                ),
                LocalizedText(
                    fr: "Bœuf haché saisi à feu vif, ail et sauce soja à la fin.",
                    en: "Mince seared over high heat, garlic and soy at the end.",
                    es: "Carne picada a fuego fuerte, ajo y soja al final."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-navets-orge",
            name: LocalizedText(
                fr: "Bœuf aux navets, orge perlé",
                en: "Beef with turnips and barley",
                es: "Ternera con nabos y cebada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "boeuf-15", carbID: "orge-perle",
            fatID: "huile-olive", extraIDs: ["navet", "carotte"],
            minutes: 55,
            steps: [
                LocalizedText(
                    fr: "Les navets deviennent amers s'ils bouillent trop fort : petit feu, toujours.",
                    en: "Turnips turn bitter if boiled hard: low heat, always.",
                    es: "Los nabos amargan si hierven fuerte: fuego suave, siempre."
                ),
                LocalizedText(
                    fr: "Quarante-cinq minutes à couvert. L'orge rejoint à mi-cuisson.",
                    en: "Forty-five minutes covered. The barley joins halfway.",
                    es: "Cuarenta y cinco minutos tapado. La cebada entra a mitad."
                ),
            ]
        ),
        Recipe(
            id: "veau-tomate-polenta",
            name: LocalizedText(
                fr: "Veau à la tomate, polenta",
                en: "Veal in tomato with polenta",
                es: "Ternera con tomate y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "veau-escalope", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Veau fariné et doré, puis sorti : il finira deux minutes dans la sauce.",
                    en: "Veal floured and browned, then out: it finishes two minutes in the sauce.",
                    es: "Ternera enharinada y dorada, luego fuera: termina dos minutos en la salsa."
                ),
                LocalizedText(
                    fr: "Champignons à part, toujours : dans la sauce, ils rendent leur eau.",
                    en: "Mushrooms separately, always: in the sauce they release water.",
                    es: "Champiñones aparte, siempre: en la salsa sueltan agua."
                ),
            ]
        ),
        Recipe(
            id: "porc-lentilles",
            name: LocalizedText(
                fr: "Porc aux lentilles",
                en: "Pork with lentils",
                es: "Cerdo con lentejas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-echine", carbID: "pomme-de-terre",
            fatID: "huile-olive", extraIDs: ["carotte", "oignon"],
            minutes: 50,
            steps: [
                LocalizedText(
                    fr: "Lentilles cuites avec la viande : elles prennent tout le gras et le goût.",
                    en: "Lentils cooked with the meat: they take all the fat and flavour.",
                    es: "Lentejas cocidas con la carne: cogen toda la grasa y el sabor."
                ),
                LocalizedText(
                    fr: "Aucun sel avant la fin, sinon les lentilles restent dures.",
                    en: "No salt before the end, or the lentils stay hard.",
                    es: "Nada de sal antes del final, si no las lentejas quedan duras."
                ),
            ]
        ),
        Recipe(
            id: "porc-ananas-riz",
            name: LocalizedText(
                fr: "Porc à l'ananas, riz basmati",
                en: "Pork with pineapple and rice",
                es: "Cerdo con piña y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["poivron", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "L'ananas contient une enzyme qui attendrit la viande : dix minutes suffisent.",
                    en: "Pineapple contains an enzyme that tenderises meat: ten minutes is enough.",
                    es: "La piña tiene una enzima que ablanda la carne: diez minutos bastan."
                ),
                LocalizedText(
                    fr: "Au-delà d'une heure, la viande devient pâteuse. C'est le seul piège.",
                    en: "Beyond an hour, the meat turns mushy. That is the only trap.",
                    es: "Más de una hora y la carne se hace pastosa. Ese es el único riesgo."
                ),
            ]
        ),
        Recipe(
            id: "agneau-courgettes",
            name: LocalizedText(
                fr: "Agneau aux courgettes, riz",
                en: "Lamb with courgettes and rice",
                es: "Cordero con calabacín y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "agneau-gigot", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["courgette", "tomate"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Agneau doré à feu vif, jamais à couvert au début : il faut la croûte.",
                    en: "Lamb browned over high heat, never covered at first: you need the crust.",
                    es: "Cordero dorado a fuego fuerte, nunca tapado al principio: hace falta la costra."
                ),
                LocalizedText(
                    fr: "Courgettes ajoutées tard : vingt minutes et elles disparaissent.",
                    en: "Courgettes added late: twenty minutes and they vanish.",
                    es: "Calabacín tarde: veinte minutos y desaparece."
                ),
            ]
        ),
        Recipe(
            id: "lapin-champignons-pates",
            name: LocalizedText(
                fr: "Lapin aux champignons, pâtes",
                en: "Rabbit with mushrooms and pasta",
                es: "Conejo con champiñones y pasta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lapin", carbID: "pates-completes",
            fatID: "creme-legere", extraIDs: ["champignons", "oignon"],
            minutes: 50,
            steps: [
                LocalizedText(
                    fr: "Lapin à couvert, toujours : sa chair maigre sèche en un rien de temps.",
                    en: "Rabbit covered, always: its lean flesh dries in no time.",
                    es: "Conejo tapado, siempre: su carne magra se seca enseguida."
                ),
                LocalizedText(
                    fr: "Crème et moutarde hors du feu, à la fin.",
                    en: "Cream and mustard off the heat, at the end.",
                    es: "Nata y mostaza fuera del fuego, al final."
                ),
            ]
        ),
        Recipe(
            id: "jambon-gnocchis",
            name: LocalizedText(
                fr: "Gnocchis au jambon et aux petits pois",
                en: "Gnocchi with ham and peas",
                es: "Ñoquis con jamón y guisantes"
            ),
            slots: [.lunch, .dinner],
            proteinID: "jambon-blanc", carbID: "gnocchis",
            fatID: "creme-legere", extraIDs: ["oignon", "epinards"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Gnocchis deux minutes à l'eau, puis poêlés : c'est la croûte qui fait le plat.",
                    en: "Gnocchi two minutes in water, then pan-fried: the crust makes the dish.",
                    es: "Ñoquis dos minutos en agua, luego a la sartén: la costra hace el plato."
                ),
                LocalizedText(
                    fr: "Jambon hors du feu : cuit, il se dessèche et sale tout.",
                    en: "Ham off the heat: cooked, it dries and salts everything.",
                    es: "Jamón fuera del fuego: cocido, se seca y lo sala todo."
                ),
            ]
        ),
        Recipe(
            id: "rosbif-pates-froides",
            name: LocalizedText(
                fr: "Salade de pâtes au rosbif",
                en: "Cold pasta salad with roast beef",
                es: "Ensalada de pasta con rosbif"
            ),
            slots: [.lunch, .dinner],
            proteinID: "rosbif", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["tomate", "roquette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Rince les pâtes à l'eau froide : c'est la seule fois où c'est justifié.",
                    en: "Rinse the pasta in cold water: the only time it is justified.",
                    es: "Enjuaga la pasta en agua fría: la única vez que se justifica."
                ),
                LocalizedText(
                    fr: "Assaisonne généreusement : le froid éteint la moitié du goût.",
                    en: "Season generously: cold mutes half the flavour.",
                    es: "Aliña generosamente: el frío apaga la mitad del sabor."
                ),
            ]
        ),
        Recipe(
            id: "viande-grisons-salade",
            name: LocalizedText(
                fr: "Salade à la viande des Grisons",
                en: "Salad with air-dried beef",
                es: "Ensalada con cecina"
            ),
            slots: [.lunch, .dinner],
            proteinID: "viande-des-grisons", carbID: "pomme-de-terre",
            fatID: "huile-noix", extraIDs: ["salade", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "La viande des Grisons se tranche très fin : épaisse, elle devient coriace.",
                    en: "Air-dried beef sliced very thin: thick, it turns leathery.",
                    es: "La cecina se corta muy fina: gruesa, queda correosa."
                ),
                LocalizedText(
                    fr: "Pommes de terre tièdes, huile de noix, pas de sel : la viande sale assez.",
                    en: "Warm potatoes, walnut oil, no salt: the meat salts enough.",
                    es: "Patatas templadas, aceite de nuez, sin sal: la carne ya sala."
                ),
            ]
        ),
        Recipe(
            id: "saumon-fume-pates",
            name: LocalizedText(
                fr: "Pâtes au saumon fumé et au citron",
                en: "Pasta with smoked salmon and lemon",
                es: "Pasta con salmón ahumado y limón"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon-fume", carbID: "pates-blanches",
            fatID: "creme-legere", extraIDs: ["epinards", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Le saumon fumé ne se cuit jamais : il se coupe et se pose, c'est tout.",
                    en: "Smoked salmon is never cooked: it is cut and laid on, that is all.",
                    es: "El salmón ahumado no se cocina: se corta y se pone, nada más."
                ),
                LocalizedText(
                    fr: "Zeste de citron plutôt que jus, la crème tournerait.",
                    en: "Lemon zest rather than juice, the cream would split.",
                    es: "Ralladura en vez de zumo, la nata se cortaría."
                ),
            ]
        ),
        Recipe(
            id: "cabillaud-curry-quinoa",
            name: LocalizedText(
                fr: "Cabillaud au curry, quinoa",
                en: "Curried cod with quinoa",
                es: "Bacalao al curry con quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cabillaud", carbID: "quinoa",
            fatID: "coco-rape", extraIDs: ["epinards", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Poisson blanc ajouté entier et jamais remué : il s'émiette au moindre geste.",
                    en: "White fish added whole and never stirred: it flakes at the slightest move.",
                    es: "Pescado blanco entero y sin remover: se deshace al mínimo movimiento."
                ),
                LocalizedText(
                    fr: "Huit minutes à couvert, la vapeur fait tout.",
                    en: "Eight minutes covered, the steam does everything.",
                    es: "Ocho minutos tapado, el vapor lo hace todo."
                ),
            ]
        ),
        Recipe(
            id: "colin-poireaux-millet",
            name: LocalizedText(
                fr: "Colin aux poireaux, millet",
                en: "Hake with leeks and millet",
                es: "Merluza con puerros y mijo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "colin-lieu", carbID: "millet",
            fatID: "huile-olive", extraIDs: ["poireau", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Poireaux fondus vingt minutes : c'est le lit du poisson, il doit être fondant.",
                    en: "Leeks softened twenty minutes: this is the fish's bed, it must be melting.",
                    es: "Puerros pochados veinte minutos: es la cama del pescado, debe estar tierna."
                ),
                LocalizedText(
                    fr: "Colin dessus, couvercle, huit minutes.",
                    en: "Hake on top, lid on, eight minutes.",
                    es: "Merluza encima, tapa, ocho minutos."
                ),
            ]
        ),
        Recipe(
            id: "dorade-tomates-boulgour",
            name: LocalizedText(
                fr: "Dorade aux tomates, boulgour",
                en: "Sea bream with tomatoes and bulgur",
                es: "Dorada con tomate y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dorade", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["tomate", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Dorade entière au four : l'arête garde la chair moelleuse.",
                    en: "Whole bream in the oven: the bone keeps the flesh moist.",
                    es: "Dorada entera al horno: la espina mantiene la carne jugosa."
                ),
                LocalizedText(
                    fr: "Vingt-cinq minutes à 190 °C, tomates et oignons autour.",
                    en: "Twenty-five minutes at 190 °C, tomatoes and onions around it.",
                    es: "Veinticinco minutos a 190 °C, tomate y cebolla alrededor."
                ),
            ]
        ),
        Recipe(
            id: "sole-riz-champignons",
            name: LocalizedText(
                fr: "Sole aux champignons, riz",
                en: "Sole with mushrooms and rice",
                es: "Lenguado con champiñones y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "sole", carbID: "riz-blanc",
            fatID: "beurre", extraIDs: ["champignons", "epinards"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "La sole cuit en trois minutes : la surveiller est tout le travail.",
                    en: "Sole cooks in three minutes: watching it is the whole job.",
                    es: "El lenguado se hace en tres minutos: vigilarlo es todo el trabajo."
                ),
                LocalizedText(
                    fr: "Beurre noisette et citron hors du feu, versés dessus.",
                    en: "Brown butter and lemon off the heat, poured over.",
                    es: "Mantequilla avellana y limón fuera del fuego, por encima."
                ),
            ]
        ),
        Recipe(
            id: "thon-boite-salade-pates",
            name: LocalizedText(
                fr: "Salade de pâtes au thon",
                en: "Tuna pasta salad",
                es: "Ensalada de pasta con atún"
            ),
            slots: [.lunch, .dinner],
            proteinID: "thon-boite", carbID: "pates-completes",
            fatID: "olives", extraIDs: ["tomate", "poivron"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Thon égoutté mais pas pressé : pressé, il devient sec et filandreux.",
                    en: "Tuna drained but not squeezed: squeezed, it turns dry and stringy.",
                    es: "Atún escurrido pero no exprimido: exprimido, queda seco y fibroso."
                ),
                LocalizedText(
                    fr: "Assaisonne les pâtes tièdes, elles absorbent alors la vinaigrette.",
                    en: "Dress the pasta warm, it then absorbs the dressing.",
                    es: "Aliña la pasta templada, así absorbe el aliño."
                ),
            ]
        ),
        Recipe(
            id: "crevettes-quinoa-avocat",
            name: LocalizedText(
                fr: "Crevettes, quinoa et avocat",
                en: "Prawns with quinoa and avocado",
                es: "Gambas con quinoa y aguacate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crevettes", carbID: "quinoa",
            fatID: "avocat", extraIDs: ["concombre", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Crevettes deux minutes, pas plus : elles se replient quand c'est prêt.",
                    en: "Prawns two minutes, no more: they curl when they are ready.",
                    es: "Gambas dos minutos, no más: se curvan cuando están listas."
                ),
                LocalizedText(
                    fr: "Quinoa tiède, avocat et citron ajoutés hors du feu.",
                    en: "Warm quinoa, avocado and lemon added off the heat.",
                    es: "Quinoa templada, aguacate y limón fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "moules-pates-tomate",
            name: LocalizedText(
                fr: "Pâtes aux moules et à la tomate",
                en: "Mussel and tomato pasta",
                es: "Pasta con mejillones y tomate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "moules", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Décoquille la moitié des moules seulement : les autres font le décor.",
                    en: "Shell only half the mussels: the rest are the decoration.",
                    es: "Desconcha solo la mitad de los mejillones: el resto es la presentación."
                ),
                LocalizedText(
                    fr: "Le jus filtré remplace le sel : n'en ajoute pas avant d'avoir goûté.",
                    en: "The strained liquid replaces salt: add none before tasting.",
                    es: "El caldo colado sustituye la sal: no añadas antes de probar."
                ),
            ]
        ),
        Recipe(
            id: "calamars-riz-encre",
            name: LocalizedText(
                fr: "Calamars sautés au riz",
                en: "Sautéed squid with rice",
                es: "Calamares salteados con arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "calamars", carbID: "riz-blanc",
            fatID: "huile-olive", extraIDs: ["oignon", "poivron"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Poêle brûlante et calamars secs : humides, ils bouillent et durcissent.",
                    en: "Scorching pan and dry squid: wet, they boil and toughen.",
                    es: "Sartén ardiendo y calamares secos: húmedos, hierven y se endurecen."
                ),
                LocalizedText(
                    fr: "Deux minutes maximum, ail et persil hors du feu.",
                    en: "Two minutes maximum, garlic and parsley off the heat.",
                    es: "Dos minutos máximo, ajo y perejil fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "tilapia-tomate-semoule",
            name: LocalizedText(
                fr: "Tilapia à la tomate, semoule",
                en: "Tilapia in tomato with couscous",
                es: "Tilapia con tomate y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tilapia", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Fais réduire la sauce d'abord : le poisson n'a que huit minutes à donner.",
                    en: "Reduce the sauce first: the fish has only eight minutes to give.",
                    es: "Reduce la salsa primero: el pescado solo da ocho minutos."
                ),
                LocalizedText(
                    fr: "Semoule gonflée hors du feu, cinq minutes sous un torchon.",
                    en: "Couscous swollen off the heat, five minutes under a cloth.",
                    es: "Sémola hinchada fuera del fuego, cinco minutos bajo un paño."
                ),
            ]
        ),
        Recipe(
            id: "truite-fumee-pommes",
            name: LocalizedText(
                fr: "Truite, pommes de terre et cresson",
                en: "Trout with potatoes and watercress",
                es: "Trucha con patatas y berros"
            ),
            slots: [.lunch, .dinner],
            proteinID: "truite", carbID: "pomme-de-terre",
            fatID: "creme-legere", extraIDs: ["cresson", "radis"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Le cresson se mange cru : cuit, il perd son piquant et son intérêt.",
                    en: "Watercress is eaten raw: cooked, it loses its bite and its point.",
                    es: "Los berros se comen crudos: cocidos, pierden el picor y la gracia."
                ),
                LocalizedText(
                    fr: "Truite quatre minutes côté peau, deux de l'autre.",
                    en: "Trout four minutes skin down, two on the other side.",
                    es: "Trucha cuatro minutos por la piel, dos por el otro."
                ),
            ]
        ),
        Recipe(
            id: "bar-riz-gingembre",
            name: LocalizedText(
                fr: "Bar au gingembre, riz basmati",
                en: "Ginger sea bass with basmati rice",
                es: "Lubina al jengibre con arroz basmati"
            ),
            slots: [.lunch, .dinner],
            proteinID: "bar", carbID: "riz-basmati",
            fatID: "huile-colza", extraIDs: ["germes-soja", "carotte"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Gingembre en fines lamelles, pas râpé : râpé, il devient fibreux à la cuisson.",
                    en: "Ginger in thin slices, not grated: grated, it turns stringy when cooked.",
                    es: "Jengibre en láminas finas, no rallado: rallado, queda fibroso al cocinar."
                ),
                LocalizedText(
                    fr: "Vapeur douze minutes, huile chaude versée dessus à la fin.",
                    en: "Steamed twelve minutes, hot oil poured over at the end.",
                    es: "Al vapor doce minutos, aceite caliente por encima al final."
                ),
            ]
        ),
        Recipe(
            id: "noix-st-jacques-poireaux",
            name: LocalizedText(
                fr: "Saint-Jacques aux poireaux, riz",
                en: "Scallops with leeks and rice",
                es: "Vieiras con puerros y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "noix-st-jacques", carbID: "riz-blanc",
            fatID: "beurre", extraIDs: ["poireau", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Fondue de poireaux vingt minutes à couvert : c'est le lit, il doit être doux.",
                    en: "Leeks softened twenty minutes covered: this is the bed, it must be gentle.",
                    es: "Puerros pochados veinte minutos tapados: es la cama, debe ser suave."
                ),
                LocalizedText(
                    fr: "Saint-Jacques quatre-vingt-dix secondes par face, jamais davantage.",
                    en: "Scallops ninety seconds a side, never more.",
                    es: "Vieiras noventa segundos por cara, nunca más."
                ),
            ]
        ),
        Recipe(
            id: "poulet-blettes-riz",
            name: LocalizedText(
                fr: "Poulet aux blettes, riz complet",
                en: "Chicken with chard and brown rice",
                es: "Pollo con acelgas y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["blettes", "oignon"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Sépare les côtes des feuilles : elles cuisent en dix minutes contre une.",
                    en: "Separate the stalks from the leaves: ten minutes against one.",
                    es: "Separa las pencas de las hojas: diez minutos contra uno."
                ),
                LocalizedText(
                    fr: "Poulet doré à part, réuni à la fin.",
                    en: "Chicken browned separately, combined at the end.",
                    es: "Pollo dorado aparte, unido al final."
                ),
            ]
        ),
        Recipe(
            id: "poulet-asperges-quinoa",
            name: LocalizedText(
                fr: "Poulet aux asperges, quinoa",
                en: "Chicken with asparagus and quinoa",
                es: "Pollo con espárragos y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "blanc-de-poulet", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["asperge", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Casse les asperges à la main : elles cèdent exactement où la fibre commence.",
                    en: "Snap the asparagus by hand: it breaks exactly where the fibre starts.",
                    es: "Parte los espárragos a mano: ceden justo donde empieza la fibra."
                ),
                LocalizedText(
                    fr: "Quatre minutes à la poêle, pas plus : molles, elles ne valent plus rien.",
                    en: "Four minutes in the pan, no more: soft, they are worthless.",
                    es: "Cuatro minutos a la sartén, no más: blandos, no valen nada."
                ),
            ]
        ),
        Recipe(
            id: "dinde-potiron-millet",
            name: LocalizedText(
                fr: "Dinde au potiron, millet",
                en: "Turkey with pumpkin and millet",
                es: "Pavo con calabaza y mijo"
            ),
            slots: [.lunch, .dinner],
            proteinID: "dinde", carbID: "millet",
            fatID: "huile-colza", extraIDs: ["potiron", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Potiron rôti plutôt que bouilli : l'eau est son ennemie.",
                    en: "Pumpkin roasted rather than boiled: water is its enemy.",
                    es: "Calabaza asada en vez de hervida: el agua es su enemiga."
                ),
                LocalizedText(
                    fr: "Dinde trois minutes, réunie au potiron avec de la sauge.",
                    en: "Turkey three minutes, combined with the pumpkin and sage.",
                    es: "Pavo tres minutos, unido a la calabaza con salvia."
                ),
            ]
        ),
        Recipe(
            id: "boeuf-endives-pommes",
            name: LocalizedText(
                fr: "Bœuf aux endives braisées",
                en: "Beef with braised chicory",
                es: "Ternera con endibias braseadas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "steak", carbID: "pomme-de-terre",
            fatID: "beurre", extraIDs: ["endive", "oignon"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Les endives amères se corrigent au sucre : une pincée, pas davantage.",
                    en: "Bitter chicory is corrected with sugar: a pinch, no more.",
                    es: "La endibia amarga se corrige con azúcar: una pizca, no más."
                ),
                LocalizedText(
                    fr: "Vingt minutes à couvert, puis à découvert pour caraméliser.",
                    en: "Twenty minutes covered, then uncovered to caramelise.",
                    es: "Veinte minutos tapado, luego destapado para caramelizar."
                ),
            ]
        ),
        Recipe(
            id: "porc-fenouil-polenta",
            name: LocalizedText(
                fr: "Porc au fenouil, polenta",
                en: "Pork with fennel and polenta",
                es: "Cerdo con hinojo y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "porc-filet", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["fenouil", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Graines de fenouil grillées à sec : elles font le parfum, pas le bulbe.",
                    en: "Fennel seeds dry-toasted: they make the scent, not the bulb.",
                    es: "Semillas de hinojo tostadas en seco: ellas dan el aroma, no el bulbo."
                ),
                LocalizedText(
                    fr: "Porc à couvert vingt minutes, fenouil émincé avec.",
                    en: "Pork covered twenty minutes, sliced fennel with it.",
                    es: "Cerdo tapado veinte minutos, hinojo en láminas con él."
                ),
            ]
        ),
        Recipe(
            id: "agneau-artichauts",
            name: LocalizedText(
                fr: "Agneau aux artichauts, semoule",
                en: "Lamb with artichokes and couscous",
                es: "Cordero con alcachofas y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "agneau-gigot", carbID: "semoule",
            fatID: "huile-olive", extraIDs: ["artichaut", "oignon"],
            minutes: 45,
            steps: [
                LocalizedText(
                    fr: "Citronne les artichauts dès qu'ils sont parés : ils noircissent en trois minutes.",
                    en: "Lemon the artichokes as soon as they are trimmed: they blacken in three minutes.",
                    es: "Limón a las alcachofas al limpiarlas: se ennegrecen en tres minutos."
                ),
                LocalizedText(
                    fr: "Trente minutes à couvert avec l'agneau doré.",
                    en: "Thirty minutes covered with the browned lamb.",
                    es: "Treinta minutos tapado con el cordero dorado."
                ),
            ]
        ),
        Recipe(
            id: "veau-navets-riz",
            name: LocalizedText(
                fr: "Veau aux navets nouveaux, riz",
                en: "Veal with young turnips and rice",
                es: "Ternera con nabos tiernos y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "veau-escalope", carbID: "riz-blanc",
            fatID: "beurre", extraIDs: ["navet", "carotte"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Glace les navets au beurre et au sucre : c'est ce qui ôte l'amertume.",
                    en: "Glaze the turnips in butter and sugar: that is what removes the bitterness.",
                    es: "Glasea los nabos con mantequilla y azúcar: eso quita el amargor."
                ),
                LocalizedText(
                    fr: "Veau à la toute fin, deux minutes.",
                    en: "Veal at the very end, two minutes.",
                    es: "Ternera al final del todo, dos minutos."
                ),
            ]
        ),
        Recipe(
            id: "lapin-tomates-quinoa",
            name: LocalizedText(
                fr: "Lapin à la tomate, quinoa",
                en: "Rabbit in tomato with quinoa",
                es: "Conejo con tomate y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lapin", carbID: "quinoa",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "poivron"],
            minutes: 50,
            steps: [
                LocalizedText(
                    fr: "Lapin à couvert quarante minutes : à découvert, il devient sec et filandreux.",
                    en: "Rabbit covered forty minutes: uncovered, it turns dry and stringy.",
                    es: "Conejo tapado cuarenta minutos: destapado, queda seco y fibroso."
                ),
                LocalizedText(
                    fr: "Poivrons ajoutés à mi-cuisson pour qu'ils tiennent.",
                    en: "Peppers added halfway so they hold.",
                    es: "Pimientos a mitad para que aguanten."
                ),
            ]
        ),
        Recipe(
            id: "cabillaud-poireaux-polenta",
            name: LocalizedText(
                fr: "Cabillaud aux poireaux, polenta",
                en: "Cod with leeks and polenta",
                es: "Bacalao con puerros y polenta"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cabillaud", carbID: "polenta",
            fatID: "huile-olive", extraIDs: ["poireau", "epinards"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Polenta fouettée sans arrêt cinq minutes : c'est le seul secret.",
                    en: "Polenta whisked non-stop five minutes: that is the only secret.",
                    es: "Polenta batida sin parar cinco minutos: ese es el único secreto."
                ),
                LocalizedText(
                    fr: "Cabillaud huit minutes sur les poireaux, à couvert.",
                    en: "Cod eight minutes on the leeks, covered.",
                    es: "Bacalao ocho minutos sobre los puerros, tapado."
                ),
            ]
        ),
        Recipe(
            id: "saumon-asperges-riz",
            name: LocalizedText(
                fr: "Saumon aux asperges, riz basmati",
                en: "Salmon with asparagus and rice",
                es: "Salmón con espárragos y arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "saumon", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["asperge", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Saumon peau en bas quatre-vingts pour cent du temps : la peau protège la chair.",
                    en: "Salmon skin down eighty per cent of the time: the skin shields the flesh.",
                    es: "Salmón con la piel abajo el ochenta por ciento del tiempo: la piel protege la carne."
                ),
                LocalizedText(
                    fr: "Asperges quatre minutes seulement, à côté.",
                    en: "Asparagus four minutes only, alongside.",
                    es: "Espárragos solo cuatro minutos, al lado."
                ),
            ]
        ),
        Recipe(
            id: "thon-frais-sesame",
            name: LocalizedText(
                fr: "Thon au sésame, riz et concombre",
                en: "Sesame tuna with rice and cucumber",
                es: "Atún al sésamo con arroz y pepino"
            ),
            slots: [.lunch, .dinner],
            proteinID: "thon-frais", carbID: "riz-blanc",
            fatID: "graines-sesame", extraIDs: ["concombre", "radis"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Roule le thon dans le sésame et saisis-le trente secondes par face.",
                    en: "Roll the tuna in sesame and sear thirty seconds a side.",
                    es: "Reboza el atún en sésamo y séllalo treinta segundos por cara."
                ),
                LocalizedText(
                    fr: "Rouge au centre : cuit à cœur, il n'a plus aucun intérêt.",
                    en: "Red inside: cooked through, it has no interest left.",
                    es: "Rojo dentro: hecho del todo, pierde todo interés."
                ),
            ]
        ),
        Recipe(
            id: "sardines-poivrons",
            name: LocalizedText(
                fr: "Sardines aux poivrons, boulgour",
                en: "Sardines with peppers and bulgur",
                es: "Sardinas con pimientos y bulgur"
            ),
            slots: [.lunch, .dinner],
            proteinID: "sardines", carbID: "boulgour",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Poivrons rôtis et pelés : la peau est ce qu'on ne digère pas.",
                    en: "Peppers roasted and peeled: the skin is what does not digest.",
                    es: "Pimientos asados y pelados: la piel es lo que no se digiere."
                ),
                LocalizedText(
                    fr: "Sardines posées froides sur le boulgour tiède.",
                    en: "Sardines laid cold on the warm bulgur.",
                    es: "Sardinas frías sobre el bulgur templado."
                ),
            ]
        ),
        Recipe(
            id: "maquereau-riz-curry",
            name: LocalizedText(
                fr: "Maquereau au curry, riz complet",
                en: "Curried mackerel with brown rice",
                es: "Caballa al curry con arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "maquereau", carbID: "riz-complet",
            fatID: "huile-colza", extraIDs: ["oignon", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Le maquereau est gras : le curry et l'acide sont là pour l'équilibrer.",
                    en: "Mackerel is oily: curry and acid are there to balance it.",
                    es: "La caballa es grasa: el curry y el ácido la equilibran."
                ),
                LocalizedText(
                    fr: "Cinq minutes dans la sauce, jamais plus.",
                    en: "Five minutes in the sauce, never more.",
                    es: "Cinco minutos en la salsa, nunca más."
                ),
            ]
        ),
        Recipe(
            id: "crevettes-riz-ail",
            name: LocalizedText(
                fr: "Crevettes à l'ail, riz basmati",
                en: "Garlic prawns with basmati rice",
                es: "Gambas al ajillo con arroz"
            ),
            slots: [.lunch, .dinner],
            proteinID: "crevettes", carbID: "riz-basmati",
            fatID: "huile-olive", extraIDs: ["poivron", "tomate"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Ail dans l'huile froide, monté doucement : c'est comme ça qu'il parfume sans brûler.",
                    en: "Garlic in cold oil, warmed slowly: that is how it perfumes without burning.",
                    es: "Ajo en aceite frío, subido despacio: así perfuma sin quemarse."
                ),
                LocalizedText(
                    fr: "Crevettes deux minutes, persil hors du feu.",
                    en: "Prawns two minutes, parsley off the heat.",
                    es: "Gambas dos minutos, perejil fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "tofu-epinards-quinoa",
            name: LocalizedText(
                fr: "Tofu aux épinards, quinoa",
                en: "Tofu with spinach and quinoa",
                es: "Tofu con espinacas y quinoa"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tofu", carbID: "quinoa",
            fatID: "graines-courge", extraIDs: ["epinards", "champignons"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Tofu pressé puis doré : c'est la seule façon d'en faire autre chose qu'une éponge.",
                    en: "Tofu pressed then browned: the only way to make it more than a sponge.",
                    es: "Tofu prensado y dorado: la única forma de que no sea una esponja."
                ),
                LocalizedText(
                    fr: "Épinards trente secondes, graines de courge grillées dessus.",
                    en: "Spinach thirty seconds, toasted pumpkin seeds over.",
                    es: "Espinacas treinta segundos, pipas de calabaza tostadas encima."
                ),
            ]
        ),
        Recipe(
            id: "tempeh-brocoli-riz",
            name: LocalizedText(
                fr: "Tempeh au brocoli, riz complet",
                en: "Tempeh with broccoli and brown rice",
                es: "Tempeh con brócoli y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "tempeh", carbID: "riz-complet",
            fatID: "huile-colza", extraIDs: ["brocoli", "carotte"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Tempeh bouilli cinq minutes avant de le dorer : l'amertume part avec l'eau.",
                    en: "Tempeh boiled five minutes before browning: the bitterness leaves with the water.",
                    es: "Tempeh hervido cinco minutos antes de dorar: el amargor se va con el agua."
                ),
                LocalizedText(
                    fr: "Brocoli croquant, sauce soja et gingembre à la fin.",
                    en: "Crunchy broccoli, soy and ginger at the end.",
                    es: "Brócoli crujiente, soja y jengibre al final."
                ),
            ]
        ),
        Recipe(
            id: "seitan-poireaux-sarrasin",
            name: LocalizedText(
                fr: "Seitan aux poireaux, sarrasin",
                en: "Seitan with leeks and buckwheat",
                es: "Seitán con puerros y trigo sarraceno"
            ),
            slots: [.lunch, .dinner],
            proteinID: "seitan", carbID: "sarrasin",
            fatID: "huile-olive", extraIDs: ["poireau", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Le sarrasin cuit en douze minutes et ne se remue pas : il devient collant.",
                    en: "Buckwheat cooks in twelve minutes and is not stirred: it turns gluey.",
                    es: "El sarraceno se hace en doce minutos y no se remueve: se vuelve pegajoso."
                ),
                LocalizedText(
                    fr: "Poireaux fondus, seitan doré, réunis à la fin.",
                    en: "Softened leeks, browned seitan, combined at the end.",
                    es: "Puerros pochados, seitán dorado, unidos al final."
                ),
            ]
        ),
        Recipe(
            id: "lentilles-poireaux-riz",
            name: LocalizedText(
                fr: "Lentilles aux poireaux, riz complet",
                en: "Lentils with leeks and brown rice",
                es: "Lentejas con puerros y arroz integral"
            ),
            slots: [.lunch, .dinner],
            proteinID: "lentilles", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["poireau", "carotte"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Lentilles vertes vingt minutes, sans sel : le sel durcit la peau.",
                    en: "Green lentils twenty minutes, no salt: salt toughens the skins.",
                    es: "Lentejas verdes veinte minutos, sin sal: la sal endurece la piel."
                ),
                LocalizedText(
                    fr: "Vinaigre en fin de cuisson : il réveille tout le plat.",
                    en: "Vinegar at the end: it wakes the whole dish.",
                    es: "Vinagre al final: despierta todo el plato."
                ),
            ]
        ),
        Recipe(
            id: "pois-chiches-aubergine",
            name: LocalizedText(
                fr: "Pois chiches à l'aubergine, semoule",
                en: "Chickpeas with aubergine and couscous",
                es: "Garbanzos con berenjena y sémola"
            ),
            slots: [.lunch, .dinner],
            proteinID: "pois-chiches", carbID: "semoule",
            fatID: "tahini", extraIDs: ["aubergine", "tomate"],
            minutes: 35,
            steps: [
                LocalizedText(
                    fr: "Aubergine salée vingt minutes puis rincée : elle boit moitié moins d'huile.",
                    en: "Aubergine salted twenty minutes then rinsed: it drinks half the oil.",
                    es: "Berenjena salada veinte minutos y enjuagada: absorbe la mitad de aceite."
                ),
                LocalizedText(
                    fr: "Tahini au citron par-dessus, allongé d'eau tiède.",
                    en: "Lemon tahini over the top, loosened with warm water.",
                    es: "Tahini al limón por encima, aligerado con agua templada."
                ),
            ]
        ),
        Recipe(
            id: "haricots-rouges-mais",
            name: LocalizedText(
                fr: "Haricots rouges au maïs, tortillas",
                en: "Red beans with corn and tortillas",
                es: "Alubias rojas con maíz y tortillas"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-rouges", carbID: "mais-doux",
            fatID: "avocat", extraIDs: ["poivron", "tomate"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Maïs égoutté et poêlé à sec : il grille et devient sucré.",
                    en: "Corn drained and dry-fried: it chars and turns sweet.",
                    es: "Maíz escurrido y a la sartén en seco: se tuesta y endulza."
                ),
                LocalizedText(
                    fr: "Haricots écrasés à moitié pour lier, coriandre et citron vert.",
                    en: "Beans half-crushed to bind, coriander and lime.",
                    es: "Alubias medio machacadas para ligar, cilantro y lima."
                ),
            ]
        ),
        Recipe(
            id: "haricots-blancs-poireaux",
            name: LocalizedText(
                fr: "Haricots blancs aux poireaux, orge",
                en: "White beans with leeks and barley",
                es: "Alubias blancas con puerros y cebada"
            ),
            slots: [.lunch, .dinner],
            proteinID: "haricots-blancs", carbID: "orge-perle",
            fatID: "huile-olive", extraIDs: ["poireau", "carotte"],
            minutes: 40,
            steps: [
                LocalizedText(
                    fr: "Orge trente minutes : c'est la céréale la plus lente du placard.",
                    en: "Barley thirty minutes: the slowest grain in the cupboard.",
                    es: "Cebada treinta minutos: el cereal más lento de la despensa."
                ),
                LocalizedText(
                    fr: "Haricots à la fin, ils sont déjà cuits et se déferaient.",
                    en: "Beans at the end, they are already cooked and would fall apart.",
                    es: "Alubias al final, ya están cocidas y se desharían."
                ),
            ]
        ),
        Recipe(
            id: "edamame-sarrasin",
            name: LocalizedText(
                fr: "Édamame au sarrasin",
                en: "Edamame with buckwheat",
                es: "Edamame con trigo sarraceno"
            ),
            slots: [.lunch, .dinner],
            proteinID: "edamame", carbID: "sarrasin",
            fatID: "graines-sesame", extraIDs: ["carotte", "germes-soja"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Sarrasin rincé avant cuisson, jamais remué pendant.",
                    en: "Buckwheat rinsed before cooking, never stirred during.",
                    es: "Sarraceno enjuagado antes, nunca removido durante."
                ),
                LocalizedText(
                    fr: "Sauce soja, vinaigre de riz, sésame : trois ingrédients suffisent.",
                    en: "Soy, rice vinegar, sesame: three ingredients are enough.",
                    es: "Soja, vinagre de arroz, sésamo: tres ingredientes bastan."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-poireaux-pates",
            name: LocalizedText(
                fr: "Pâtes aux œufs et aux poireaux",
                en: "Pasta with eggs and leeks",
                es: "Pasta con huevo y puerros"
            ),
            slots: [.lunch, .dinner],
            proteinID: "oeuf", carbID: "pates-completes",
            fatID: "huile-olive", extraIDs: ["poireau", "champignons"],
            minutes: 25,
            steps: [
                LocalizedText(
                    fr: "Œufs battus versés hors du feu sur les pâtes chaudes : la chaleur suffit à les lier.",
                    en: "Beaten eggs poured off the heat onto hot pasta: the heat alone binds them.",
                    es: "Huevo batido fuera del fuego sobre la pasta caliente: el calor basta para ligar."
                ),
                LocalizedText(
                    fr: "Sur le feu, ils font une omelette. C'est la seule erreur possible.",
                    en: "On the heat, they make an omelette. That is the only mistake.",
                    es: "Al fuego, hacen tortilla. Es el único error posible."
                ),
            ]
        ),
        Recipe(
            id: "cottage-riz-tomate",
            name: LocalizedText(
                fr: "Riz au cottage et aux tomates",
                en: "Rice with cottage cheese and tomatoes",
                es: "Arroz con requesón y tomate"
            ),
            slots: [.lunch, .dinner],
            proteinID: "cottage", carbID: "riz-complet",
            fatID: "huile-olive", extraIDs: ["tomate", "roquette"],
            minutes: 20,
            steps: [
                LocalizedText(
                    fr: "Cottage ajouté au riz tiède, jamais brûlant : il tranche à la chaleur.",
                    en: "Cottage cheese into warm rice, never scalding: it splits with heat.",
                    es: "Requesón en arroz templado, nunca ardiendo: se corta con el calor."
                ),
                LocalizedText(
                    fr: "Tomates crues et roquette pour la fraîcheur.",
                    en: "Raw tomatoes and rocket for freshness.",
                    es: "Tomate crudo y rúcula para la frescura."
                ),
            ]
        ),
        Recipe(
            id: "proteine-soja-pates",
            name: LocalizedText(
                fr: "Pâtes à la bolognaise de soja",
                en: "Pasta with soy bolognese",
                es: "Pasta con boloñesa de soja"
            ),
            slots: [.lunch, .dinner],
            proteinID: "proteine-soja", carbID: "pates-blanches",
            fatID: "huile-olive", extraIDs: ["sauce-tomate", "champignons"],
            minutes: 30,
            steps: [
                LocalizedText(
                    fr: "Champignons hachés avec le soja : c'est eux qui donnent le goût de viande.",
                    en: "Mushrooms chopped in with the soy: they give the meaty flavour.",
                    es: "Champiñones picados con la soja: dan el sabor a carne."
                ),
                LocalizedText(
                    fr: "Vingt minutes à découvert, la sauce doit épaissir.",
                    en: "Twenty minutes uncovered, the sauce must thicken.",
                    es: "Veinte minutos destapado, la salsa debe espesar."
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
        Recipe(
            id: "skyr-banane-noix",
            name: LocalizedText(
                fr: "Skyr, banane et noix",
                en: "Skyr with banana and walnuts",
                es: "Skyr con plátano y nueces"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "flocons-avoine",
            fatID: "noix", extraIDs: ["banane"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Flocons crus dans le skyr : ils ramollissent en cinq minutes.",
                    en: "Raw oats in the skyr: they soften in five minutes.",
                    es: "Copos crudos en el skyr: se ablandan en cinco minutos."
                ),
                LocalizedText(
                    fr: "Banane écrasée plutôt qu'en rondelles : elle sucre l'ensemble.",
                    en: "Banana mashed rather than sliced: it sweetens the whole bowl.",
                    es: "Plátano aplastado en vez de en rodajas: endulza todo el bol."
                ),
            ]
        ),
        Recipe(
            id: "skyr-pomme-cannelle",
            name: LocalizedText(
                fr: "Skyr, pomme râpée et cannelle",
                en: "Skyr with grated apple and cinnamon",
                es: "Skyr con manzana rallada y canela"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "muesli-nature",
            fatID: "amandes", extraIDs: ["pomme"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Râpe la pomme avec la peau : c'est là que sont les fibres.",
                    en: "Grate the apple with its skin: that is where the fibre is.",
                    es: "Ralla la manzana con piel: ahí está la fibra."
                ),
                LocalizedText(
                    fr: "Cannelle généreuse : elle donne du sucré sans sucre.",
                    en: "Generous cinnamon: it gives sweetness without sugar.",
                    es: "Canela generosa: da dulzor sin azúcar."
                ),
            ]
        ),
        Recipe(
            id: "skyr-figues-pistaches",
            name: LocalizedText(
                fr: "Skyr, figues et pistaches",
                en: "Skyr with figs and pistachios",
                es: "Skyr con higos y pistachos"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "cracottes-seigle",
            fatID: "pistaches", extraIDs: ["figue"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Figues fraîches coupées en quatre au dernier moment.",
                    en: "Fresh figs quartered at the last moment.",
                    es: "Higos frescos en cuartos al final."
                ),
                LocalizedText(
                    fr: "Pistaches concassées, jamais entières : le goût ne sort qu'une fois brisées.",
                    en: "Pistachios crushed, never whole: the flavour only comes out broken.",
                    es: "Pistachos picados, nunca enteros: el sabor solo sale al romperlos."
                ),
            ]
        ),
        Recipe(
            id: "fromage-blanc-mangue",
            name: LocalizedText(
                fr: "Fromage blanc, mangue et coco",
                en: "Fromage blanc with mango and coconut",
                es: "Queso fresco con mango y coco"
            ),
            slots: [.breakfast],
            proteinID: "fromage-blanc", carbID: "flocons-avoine",
            fatID: "coco-rape", extraIDs: ["mangue"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Coco râpée grillée à sec une minute : elle change complètement de goût.",
                    en: "Desiccated coconut dry-toasted a minute: it changes flavour entirely.",
                    es: "Coco rallado tostado en seco un minuto: cambia por completo."
                ),
                LocalizedText(
                    fr: "Mangue en dés, fromage blanc, flocons.",
                    en: "Diced mango, fromage blanc, oats.",
                    es: "Mango en dados, queso fresco, copos."
                ),
            ]
        ),
        Recipe(
            id: "fromage-blanc-cerises",
            name: LocalizedText(
                fr: "Fromage blanc aux cerises",
                en: "Fromage blanc with cherries",
                es: "Queso fresco con cerezas"
            ),
            slots: [.breakfast],
            proteinID: "fromage-blanc", carbID: "muesli-nature",
            fatID: "amandes", extraIDs: ["cerises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Cerises dénoyautées la veille : le matin, personne n'a le temps.",
                    en: "Cherries pitted the night before: nobody has time in the morning.",
                    es: "Cerezas deshuesadas la víspera: por la mañana nadie tiene tiempo."
                ),
                LocalizedText(
                    fr: "Muesli ajouté au dernier moment pour qu'il croque.",
                    en: "Muesli added last so it stays crunchy.",
                    es: "Muesli al final para que cruja."
                ),
            ]
        ),
        Recipe(
            id: "cottage-tomate-pain",
            name: LocalizedText(
                fr: "Cottage cheese, tomate et pain complet",
                en: "Cottage cheese with tomato on wholemeal",
                es: "Requesón con tomate y pan integral"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "pain-complet",
            fatID: "huile-olive", extraIDs: ["orange"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Poivre du moulin et huile d'olive sur le cottage : c'est ce qui le réveille.",
                    en: "Cracked pepper and olive oil on the cottage cheese: that wakes it up.",
                    es: "Pimienta molida y aceite sobre el requesón: eso lo despierta."
                ),
                LocalizedText(
                    fr: "Orange à côté, pour l'acide et la vitamine C.",
                    en: "Orange alongside, for the acid and the vitamin C.",
                    es: "Naranja al lado, por el ácido y la vitamina C."
                ),
            ]
        ),
        Recipe(
            id: "cottage-ananas",
            name: LocalizedText(
                fr: "Cottage cheese et ananas",
                en: "Cottage cheese with pineapple",
                es: "Requesón con piña"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "cereales-mais",
            fatID: "noix-pecan", extraIDs: ["ananas"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Ananas frais plutôt qu'en boîte : le sirop double le sucre.",
                    en: "Fresh pineapple rather than tinned: the syrup doubles the sugar.",
                    es: "Piña fresca en vez de en lata: el almíbar dobla el azúcar."
                ),
                LocalizedText(
                    fr: "Noix de pécan concassées pour le gras et le croquant.",
                    en: "Crushed pecans for fat and crunch.",
                    es: "Nueces pecanas picadas para grasa y crujiente."
                ),
            ]
        ),
        Recipe(
            id: "oeufs-brouilles-tomate",
            name: LocalizedText(
                fr: "Œufs brouillés à la tomate",
                en: "Scrambled eggs with tomato",
                es: "Huevos revueltos con tomate"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-seigle",
            fatID: "beurre", extraIDs: ["poire"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Feu doux et remuage constant : les œufs brouillés ratent toujours par excès de feu.",
                    en: "Low heat and constant stirring: scrambled eggs fail from too much heat.",
                    es: "Fuego suave y remover sin parar: los revueltos fallan por exceso de fuego."
                ),
                LocalizedText(
                    fr: "Retire-les encore coulants, ils finissent dans l'assiette.",
                    en: "Take them out still runny, they finish on the plate.",
                    es: "Sácalos aún cremosos, terminan en el plato."
                ),
            ]
        ),
        Recipe(
            id: "omelette-champignons-matin",
            name: LocalizedText(
                fr: "Omelette aux champignons du matin",
                en: "Morning mushroom omelette",
                es: "Tortilla de champiñones matinal"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-complet",
            fatID: "huile-olive", extraIDs: ["kiwi"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Champignons à part et à feu vif : dans l'omelette, ils rendent leur eau.",
                    en: "Mushrooms separately over high heat: in the omelette they release water.",
                    es: "Champiñones aparte a fuego fuerte: en la tortilla sueltan agua."
                ),
                LocalizedText(
                    fr: "Omelette baveuse au centre, elle continue de cuire hors du feu.",
                    en: "Omelette runny in the middle, it keeps cooking off the heat.",
                    es: "Tortilla jugosa en el centro, sigue cuajando fuera del fuego."
                ),
            ]
        ),
        Recipe(
            id: "blanc-oeuf-galettes",
            name: LocalizedText(
                fr: "Blancs d'œufs brouillés, galettes de riz",
                en: "Scrambled egg whites with rice cakes",
                es: "Claras revueltas con tortitas de arroz"
            ),
            slots: [.breakfast],
            proteinID: "blanc-oeuf", carbID: "galettes-riz",
            fatID: "avocat", extraIDs: ["myrtilles"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Les blancs seuls sont fades : sel, poivre et une pointe de curcuma changent tout.",
                    en: "Whites alone are bland: salt, pepper and a touch of turmeric change everything.",
                    es: "Las claras solas son sosas: sal, pimienta y algo de cúrcuma lo cambian todo."
                ),
                LocalizedText(
                    fr: "Avocat écrasé sur les galettes, myrtilles à côté.",
                    en: "Mashed avocado on the rice cakes, blueberries alongside.",
                    es: "Aguacate aplastado en las tortitas, arándanos al lado."
                ),
            ]
        ),
        Recipe(
            id: "tofu-brouille-tortilla",
            name: LocalizedText(
                fr: "Tofu brouillé en tortilla",
                en: "Scrambled tofu in a tortilla",
                es: "Tofu revuelto en tortilla"
            ),
            slots: [.breakfast],
            proteinID: "tofu", carbID: "tortilla-mais",
            fatID: "avocat", extraIDs: ["orange"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Émiette le tofu à la main : au couteau, il fait des cubes qui ne ressemblent à rien.",
                    en: "Crumble the tofu by hand: with a knife it makes cubes that look like nothing.",
                    es: "Desmenuza el tofu con la mano: con cuchillo hace cubos sin gracia."
                ),
                LocalizedText(
                    fr: "Curcuma pour la couleur, levure maltée pour le goût d'œuf.",
                    en: "Turmeric for colour, nutritional yeast for the eggy taste.",
                    es: "Cúrcuma para el color, levadura nutricional para el sabor a huevo."
                ),
            ]
        ),
        Recipe(
            id: "tofu-pain-tomate",
            name: LocalizedText(
                fr: "Tofu grillé, pain et tomate",
                en: "Grilled tofu with bread and tomato",
                es: "Tofu a la plancha con pan y tomate"
            ),
            slots: [.breakfast],
            proteinID: "tofu", carbID: "pain-seigle",
            fatID: "huile-olive", extraIDs: ["clementine"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Tofu mariné dix minutes dans la sauce soja avant de le griller.",
                    en: "Tofu marinated ten minutes in soy before grilling.",
                    es: "Tofu marinado diez minutos en soja antes de la plancha."
                ),
                LocalizedText(
                    fr: "Pain frotté à la tomate et à l'ail, à la catalane.",
                    en: "Bread rubbed with tomato and garlic, Catalan style.",
                    es: "Pan restregado con tomate y ajo, a la catalana."
                ),
            ]
        ),
        Recipe(
            id: "whey-avoine-cacao",
            name: LocalizedText(
                fr: "Porridge protéiné au cacao",
                en: "Chocolate protein porridge",
                es: "Porridge proteico de cacao"
            ),
            slots: [.breakfast],
            proteinID: "whey", carbID: "flocons-avoine",
            fatID: "noisettes", extraIDs: ["banane"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Cacao amer dans les flocons pendant la cuisson, poudre hors du feu.",
                    en: "Bitter cocoa in the oats while cooking, powder off the heat.",
                    es: "Cacao amargo en los copos al cocer, el polvo fuera del fuego."
                ),
                LocalizedText(
                    fr: "La whey cuite devient granuleuse : c'est la seule règle.",
                    en: "Cooked whey turns grainy: that is the only rule.",
                    es: "La whey cocida queda granulosa: esa es la única regla."
                ),
            ]
        ),
        Recipe(
            id: "whey-galettes-fruits",
            name: LocalizedText(
                fr: "Galettes de riz, whey et fraises",
                en: "Rice cakes with whey and strawberries",
                es: "Tortitas de arroz con whey y fresas"
            ),
            slots: [.breakfast],
            proteinID: "whey", carbID: "galettes-riz",
            fatID: "puree-amande", extraIDs: ["fraises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Délaye la whey dans très peu d'eau : elle devient une crème à tartiner.",
                    en: "Mix the whey with very little water: it becomes a spread.",
                    es: "Disuelve la whey en muy poca agua: queda como una crema."
                ),
                LocalizedText(
                    fr: "Purée d'amande dessous, whey dessus, fraises pour finir.",
                    en: "Almond butter underneath, whey on top, strawberries to finish.",
                    es: "Crema de almendra debajo, whey encima, fresas al final."
                ),
            ]
        ),
        Recipe(
            id: "caseine-pain-figues",
            name: LocalizedText(
                fr: "Crème de caséine, pain et figues",
                en: "Casein cream with bread and figs",
                es: "Crema de caseína con pan e higos"
            ),
            slots: [.breakfast],
            proteinID: "caseine", carbID: "pain-cereales",
            fatID: "noix", extraIDs: ["figue"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "La caséine épaissit en quelques minutes : c'est ce qui la distingue de la whey.",
                    en: "Casein thickens in minutes: that is what sets it apart from whey.",
                    es: "La caseína espesa en minutos: eso la distingue de la whey."
                ),
                LocalizedText(
                    fr: "Étale-la sur le pain comme une crème, figues et noix dessus.",
                    en: "Spread it on the bread like a cream, figs and walnuts over.",
                    es: "Extiéndela sobre el pan como una crema, higos y nueces encima."
                ),
            ]
        ),
        Recipe(
            id: "petit-suisse-abricots",
            name: LocalizedText(
                fr: "Petits-suisses aux abricots",
                en: "Petits-suisses with apricots",
                es: "Petit-suisse con albaricoques"
            ),
            slots: [.breakfast],
            proteinID: "petit-suisse", carbID: "flocons-avoine",
            fatID: "graines-tournesol", extraIDs: ["abricot"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Abricots frais coupés en deux, jamais épluchés : la peau porte le goût.",
                    en: "Fresh apricots halved, never peeled: the skin carries the flavour.",
                    es: "Albaricoques por la mitad, nunca pelados: la piel lleva el sabor."
                ),
                LocalizedText(
                    fr: "Graines de tournesol grillées à sec trente secondes.",
                    en: "Sunflower seeds dry-toasted thirty seconds.",
                    es: "Pipas de girasol tostadas en seco treinta segundos."
                ),
            ]
        ),
        Recipe(
            id: "petit-suisse-raisin",
            name: LocalizedText(
                fr: "Petits-suisses au raisin et au sarrasin",
                en: "Petits-suisses with grapes and buckwheat",
                es: "Petit-suisse con uva y trigo sarraceno"
            ),
            slots: [.breakfast],
            proteinID: "petit-suisse", carbID: "sarrasin",
            fatID: "noisettes", extraIDs: ["raisin"],
            minutes: 8,
            steps: [
                LocalizedText(
                    fr: "Sarrasin cuit puis grillé à sec : il croque et sent la noisette.",
                    en: "Buckwheat cooked then dry-toasted: it crunches and smells nutty.",
                    es: "Sarraceno cocido y tostado en seco: cruje y huele a avellana."
                ),
                LocalizedText(
                    fr: "Raisin coupé en deux, sinon il roule hors du bol.",
                    en: "Grapes halved, otherwise they roll out of the bowl.",
                    es: "Uvas por la mitad, si no se salen del bol."
                ),
            ]
        ),
        Recipe(
            id: "yaourt-soja-mangue",
            name: LocalizedText(
                fr: "Yaourt de soja, mangue et chia",
                en: "Soy yoghurt with mango and chia",
                es: "Yogur de soja con mango y chía"
            ),
            slots: [.breakfast],
            proteinID: "yaourt-soja", carbID: "flocons-avoine",
            fatID: "graines-chia", extraIDs: ["mangue"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Chia mélangé la veille : il absorbe dix fois son poids en eau.",
                    en: "Chia mixed the night before: it absorbs ten times its weight in water.",
                    es: "Chía mezclada la víspera: absorbe diez veces su peso en agua."
                ),
                LocalizedText(
                    fr: "Mangue ajoutée au matin, jamais la veille : elle rend son jus.",
                    en: "Mango added in the morning, never the night before: it releases juice.",
                    es: "Mango por la mañana, nunca la víspera: suelta jugo."
                ),
            ]
        ),
        Recipe(
            id: "yaourt-soja-kaki",
            name: LocalizedText(
                fr: "Yaourt de soja au kaki",
                en: "Soy yoghurt with persimmon",
                es: "Yogur de soja con caqui"
            ),
            slots: [.breakfast],
            proteinID: "yaourt-soja", carbID: "muesli-nature",
            fatID: "graines-courge", extraIDs: ["kaki"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Le kaki doit être mou pour être bon : ferme, il est astringent.",
                    en: "Persimmon must be soft to be good: firm, it is astringent.",
                    es: "El caqui debe estar blando: firme, es astringente."
                ),
                LocalizedText(
                    fr: "Muesli au dernier moment, il ramollit vite.",
                    en: "Muesli at the last moment, it softens fast.",
                    es: "Muesli al final, se ablanda rápido."
                ),
            ]
        ),
        Recipe(
            id: "proteine-vegetale-myrtilles",
            name: LocalizedText(
                fr: "Bol végétal aux myrtilles",
                en: "Plant protein bowl with blueberries",
                es: "Bol vegetal con arándanos"
            ),
            slots: [.breakfast],
            proteinID: "proteine-vegetale", carbID: "flocons-avoine",
            fatID: "graines-lin", extraIDs: ["myrtilles"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Délaye la poudre dans l'eau froide avant tout : sinon elle fait des grumeaux.",
                    en: "Dissolve the powder in cold water first: otherwise it clumps.",
                    es: "Disuelve el polvo en agua fría primero: si no, se apelmaza."
                ),
                LocalizedText(
                    fr: "Lin moulu, jamais entier : entier, il traverse sans rien donner.",
                    en: "Ground flax, never whole: whole, it passes through giving nothing.",
                    es: "Lino molido, nunca entero: entero, pasa sin dar nada."
                ),
            ]
        ),
        Recipe(
            id: "proteine-vegetale-prune",
            name: LocalizedText(
                fr: "Bol végétal aux prunes",
                en: "Plant protein bowl with plums",
                es: "Bol vegetal con ciruelas"
            ),
            slots: [.breakfast],
            proteinID: "proteine-vegetale", carbID: "cracottes-seigle",
            fatID: "puree-amande", extraIDs: ["prune"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Prunes bien mûres : fermes, elles sont acides et sans parfum.",
                    en: "Very ripe plums: firm, they are sour and scentless.",
                    es: "Ciruelas bien maduras: firmes, son ácidas y sin aroma."
                ),
                LocalizedText(
                    fr: "Purée d'amande sur les tartines, bol de protéines à côté.",
                    en: "Almond butter on the crispbread, protein bowl alongside.",
                    es: "Crema de almendra en las tostadas, bol de proteína al lado."
                ),
            ]
        ),
        Recipe(
            id: "skyr-pruneaux",
            name: LocalizedText(
                fr: "Skyr aux pruneaux et graines de lin",
                en: "Skyr with prunes and flaxseed",
                es: "Skyr con ciruelas pasas y lino"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "flocons-avoine",
            fatID: "graines-lin", extraIDs: ["pruneaux"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Pruneaux trempés dix minutes dans le thé : ils redeviennent moelleux.",
                    en: "Prunes soaked ten minutes in tea: they turn soft again.",
                    es: "Ciruelas pasas a remojo diez minutos en té: vuelven a estar tiernas."
                ),
                LocalizedText(
                    fr: "Lin moulu par-dessus, jamais chauffé.",
                    en: "Ground flax over the top, never heated.",
                    es: "Lino molido por encima, nunca calentado."
                ),
            ]
        ),
        Recipe(
            id: "cottage-melon",
            name: LocalizedText(
                fr: "Cottage cheese au melon",
                en: "Cottage cheese with melon",
                es: "Requesón con melón"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "cracottes-seigle",
            fatID: "graines-courge", extraIDs: ["melon"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Melon et sel : la combinaison paraît étrange et fonctionne toujours.",
                    en: "Melon and salt: the pairing sounds odd and always works.",
                    es: "Melón y sal: la combinación suena rara y siempre funciona."
                ),
                LocalizedText(
                    fr: "Graines de courge pour le croquant.",
                    en: "Pumpkin seeds for crunch.",
                    es: "Pipas de calabaza para el crujiente."
                ),
            ]
        ),
        Recipe(
            id: "fromage-blanc-grenade",
            name: LocalizedText(
                fr: "Fromage blanc à la grenade",
                en: "Fromage blanc with pomegranate",
                es: "Queso fresco con granada"
            ),
            slots: [.breakfast],
            proteinID: "fromage-blanc", carbID: "sarrasin",
            fatID: "pistaches", extraIDs: ["grenade"],
            minutes: 10,
            steps: [
                LocalizedText(
                    fr: "Égrène la grenade sous l'eau : les graines coulent, les peaux flottent.",
                    en: "Deseed the pomegranate under water: seeds sink, pith floats.",
                    es: "Desgrana la granada bajo el agua: los granos se hunden, la piel flota."
                ),
                LocalizedText(
                    fr: "Sarrasin grillé, pistaches, fromage blanc.",
                    en: "Toasted buckwheat, pistachios, fromage blanc.",
                    es: "Sarraceno tostado, pistachos, queso fresco."
                ),
            ]
        ),
        Recipe(
            id: "oeuf-avocat-pain-cereales",
            name: LocalizedText(
                fr: "Œuf poché, avocat et pain aux céréales",
                en: "Poached egg with avocado on seeded bread",
                es: "Huevo escalfado con aguacate y pan de cereales"
            ),
            slots: [.breakfast],
            proteinID: "oeuf", carbID: "pain-cereales",
            fatID: "avocat", extraIDs: ["pamplemousse"],
            minutes: 12,
            steps: [
                LocalizedText(
                    fr: "Vinaigre dans l'eau frémissante, jamais bouillante : le blanc se rassemble.",
                    en: "Vinegar in simmering water, never boiling: the white gathers.",
                    es: "Vinagre en agua a fuego suave, nunca hirviendo: la clara se junta."
                ),
                LocalizedText(
                    fr: "Trois minutes exactement. Le jaune doit couler sur l'avocat.",
                    en: "Three minutes exactly. The yolk must run over the avocado.",
                    es: "Tres minutos exactos. La yema debe correr sobre el aguacate."
                ),
            ]
        ),
        Recipe(
            id: "skyr-cassis",
            name: LocalizedText(
                fr: "Skyr au cassis et flocons",
                en: "Skyr with blackcurrants and oats",
                es: "Skyr con grosellas y copos"
            ),
            slots: [.breakfast],
            proteinID: "skyr", carbID: "flocons-avoine",
            fatID: "graines-tournesol", extraIDs: ["cassis"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Le cassis est très acide : une pointe de miel suffit à l'équilibrer.",
                    en: "Blackcurrants are very tart: a touch of honey balances them.",
                    es: "La grosella es muy ácida: un poco de miel la equilibra."
                ),
                LocalizedText(
                    fr: "Flocons crus, graines de tournesol grillées.",
                    en: "Raw oats, toasted sunflower seeds.",
                    es: "Copos crudos, pipas de girasol tostadas."
                ),
            ]
        ),
        Recipe(
            id: "cottage-poire-noix",
            name: LocalizedText(
                fr: "Cottage cheese, poire et noix",
                en: "Cottage cheese with pear and walnuts",
                es: "Requesón con pera y nueces"
            ),
            slots: [.breakfast],
            proteinID: "cottage", carbID: "pain-complet",
            fatID: "noix", extraIDs: ["poire"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Poire mûre à point : dure, elle n'a aucun goût.",
                    en: "Perfectly ripe pear: hard, it has no flavour at all.",
                    es: "Pera en su punto: dura, no sabe a nada."
                ),
                LocalizedText(
                    fr: "Noix et poivre sur le cottage, pain grillé.",
                    en: "Walnuts and pepper on the cottage cheese, toasted bread.",
                    es: "Nueces y pimienta sobre el requesón, pan tostado."
                ),
            ]
        ),
        Recipe(
            id: "yaourt-soja-fraises-lin",
            name: LocalizedText(
                fr: "Yaourt de soja, fraises et lin",
                en: "Soy yoghurt with strawberries and flax",
                es: "Yogur de soja con fresas y lino"
            ),
            slots: [.breakfast],
            proteinID: "yaourt-soja", carbID: "cracottes-seigle",
            fatID: "graines-lin", extraIDs: ["fraises"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Fraises coupées et laissées cinq minutes avec un peu de citron : elles rendent leur jus.",
                    en: "Strawberries cut and left five minutes with a little lemon: they release juice.",
                    es: "Fresas cortadas cinco minutos con algo de limón: sueltan jugo."
                ),
                LocalizedText(
                    fr: "Ce jus remplace tout sucre ajouté.",
                    en: "That juice replaces any added sugar.",
                    es: "Ese jugo sustituye cualquier azúcar añadido."
                ),
            ]
        ),
        Recipe(
            id: "blanc-oeuf-avoine-pancakes",
            name: LocalizedText(
                fr: "Pancakes protéinés à l'avoine",
                en: "Oat protein pancakes",
                es: "Tortitas proteicas de avena"
            ),
            slots: [.breakfast],
            proteinID: "blanc-oeuf", carbID: "flocons-avoine",
            fatID: "puree-amande", extraIDs: ["banane"],
            minutes: 15,
            steps: [
                LocalizedText(
                    fr: "Mixe flocons, blancs et banane : la pâte doit couler lentement, pas vite.",
                    en: "Blend oats, whites and banana: the batter should pour slowly, not fast.",
                    es: "Tritura copos, claras y plátano: la masa debe caer despacio, no rápido."
                ),
                LocalizedText(
                    fr: "Feu doux et couvercle : c'est ce qui les fait gonfler sans brûler.",
                    en: "Low heat and a lid: that is what makes them rise without burning.",
                    es: "Fuego suave y tapa: eso hace que suban sin quemarse."
                ),
            ]
        ),
        Recipe(
            id: "caseine-flocons-mures",
            name: LocalizedText(
                fr: "Crème de caséine aux mûres",
                en: "Casein cream with blackberries",
                es: "Crema de caseína con moras"
            ),
            slots: [.breakfast],
            proteinID: "caseine", carbID: "flocons-avoine",
            fatID: "noix-pecan", extraIDs: ["mures"],
            minutes: 5,
            steps: [
                LocalizedText(
                    fr: "Mélangé le soir, le bol est une crème au matin : la caséine fait tout.",
                    en: "Mixed at night, the bowl is a cream by morning: the casein does it all.",
                    es: "Mezclado por la noche, por la mañana es una crema: la caseína lo hace todo."
                ),
                LocalizedText(
                    fr: "Mûres et pécans ajoutés au réveil.",
                    en: "Blackberries and pecans added on waking.",
                    es: "Moras y pecanas al despertar."
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
