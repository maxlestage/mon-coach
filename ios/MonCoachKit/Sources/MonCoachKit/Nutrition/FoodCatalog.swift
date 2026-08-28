import Foundation

/// Le catalogue d'aliments du programme alimentaire.
///
/// Les valeurs sont données pour 100 g de produit **prêt à consommer** :
/// les féculents sont donc cuits, ce qui divise à peu près par trois les
/// chiffres qu'on lit sur le paquet, et c'est la source d'erreur numéro un
/// quand on suit ses macros pour la première fois. Les seules exceptions
/// sont les produits qui se pèsent secs par nature — flocons d'avoine,
/// huiles, oléagineux, poudres — et elles sont dites dans le texte.
///
/// Le rang de chaque aliment vient de ce qu'il apporte par calorie, jamais
/// d'une réputation. Aucun aliment n'est interdit : le catalogue en range
/// simplement certains dans « occasionnel », avec la raison écrite à côté.
public enum FoodCatalog {

    public static let all: [Food] = [
        Food(
            id: "blanc-de-poulet",
            name: LocalizedText(fr: "Blanc de poulet", en: "Chicken breast", es: "Pechuga de pollo"),
            role: .protein, tier: .base,
            kcal: 165, proteinG: 31.0, carbsG: 0, fatG: 3.6, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "31 g de protéines pour 165 kcal : la densité protéique la plus élevée du rayon boucherie.",
                en: "31 g of protein for 165 kcal: the highest protein density on the meat counter.",
                es: "31 g de proteína por 165 kcal: la mayor densidad proteica del mostrador de carnicería."
            )
        ),
        Food(
            id: "dinde",
            name: LocalizedText(fr: "Escalope de dinde", en: "Turkey breast", es: "Pechuga de pavo"),
            role: .protein, tier: .base,
            kcal: 147, proteinG: 30.0, carbsG: 0, fatG: 2.0, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Encore un peu plus maigre que le poulet, et moins cher au kilo de protéines.",
                en: "Slightly leaner than chicken, and cheaper per kilo of protein.",
                es: "Algo más magra que el pollo y más barata por kilo de proteína."
            )
        ),
        Food(
            id: "boeuf-5",
            name: LocalizedText(fr: "Bœuf haché 5 %", en: "Lean beef mince 5 %", es: "Carne picada de ternera 5 %"),
            role: .protein, tier: .base,
            kcal: 176, proteinG: 26.0, carbsG: 0, fatG: 8.0, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Fer héminique et zinc, que les sources végétales peinent à égaler. Le 5 % change tout : à 15 %, c'est 100 kcal de plus pour la même portion.",
                en: "Haem iron and zinc that plant sources struggle to match. The 5 % matters: at 15 % it is 100 kcal more for the same portion.",
                es: "Hierro hemo y zinc que las fuentes vegetales no igualan fácilmente. El 5 % importa: al 15 % son 100 kcal más por la misma ración."
            )
        ),
        Food(
            id: "steak",
            name: LocalizedText(fr: "Steak de bœuf", en: "Beef steak", es: "Filete de ternera"),
            role: .protein, tier: .moderate,
            kcal: 200, proteinG: 29.0, carbsG: 0, fatG: 9.0, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Excellent apport protéique, mais plus gras que le haché maigre : à peser plutôt qu'à servir à l'œil.",
                en: "Great protein, but fattier than lean mince: weigh it rather than eyeball it.",
                es: "Gran aporte proteico, pero más graso que la picada magra: pésalo en vez de calcularlo a ojo."
            )
        ),
        Food(
            id: "porc-filet",
            name: LocalizedText(fr: "Filet mignon de porc", en: "Pork tenderloin", es: "Solomillo de cerdo"),
            role: .protein, tier: .base,
            kcal: 190, proteinG: 27.0, carbsG: 0, fatG: 9.0, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "Le morceau maigre du porc, comparable au poulet et souvent moins cher.",
                en: "The lean cut of pork, comparable to chicken and often cheaper.",
                es: "El corte magro del cerdo, comparable al pollo y a menudo más barato."
            )
        ),
        Food(
            id: "saumon",
            name: LocalizedText(fr: "Saumon", en: "Salmon", es: "Salmón"),
            role: .protein, tier: .base,
            kcal: 208, proteinG: 20.0, carbsG: 0, fatG: 13.0, fiberG: 0,
            portionG: 130,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "La meilleure source alimentaire d'oméga-3 EPA et DHA. Deux portions par semaine suffisent à couvrir les besoins.",
                en: "The best food source of EPA and DHA omega-3s. Two portions a week cover the requirement.",
                es: "La mejor fuente alimentaria de omega-3 EPA y DHA. Dos raciones a la semana cubren las necesidades."
            )
        ),
        Food(
            id: "cabillaud",
            name: LocalizedText(fr: "Cabillaud", en: "Cod", es: "Bacalao fresco"),
            role: .protein, tier: .base,
            kcal: 82, proteinG: 18.0, carbsG: 0, fatG: 0.7, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "82 kcal aux 100 g : la protéine la moins chère en calories, précieuse en période de déficit.",
                en: "82 kcal per 100 g: the cheapest protein in calories, invaluable during a deficit.",
                es: "82 kcal por 100 g: la proteína más barata en calorías, muy útil en déficit."
            )
        ),
        Food(
            id: "thon-boite",
            name: LocalizedText(fr: "Thon au naturel", en: "Tuna in water", es: "Atún al natural"),
            role: .protein, tier: .base,
            kcal: 116, proteinG: 26.0, carbsG: 0, fatG: 1.0, fiberG: 0,
            portionG: 120,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Se garde des mois et se mange sans cuisson : la solution des jours où rien n'est prêt.",
                en: "Keeps for months and needs no cooking: the answer to days when nothing is ready.",
                es: "Se conserva meses y no necesita cocción: la solución para los días sin nada preparado."
            )
        ),
        Food(
            id: "sardines",
            name: LocalizedText(fr: "Sardines à l'huile égouttées", en: "Drained tinned sardines", es: "Sardinas en aceite escurridas"),
            role: .protein, tier: .base,
            kcal: 208, proteinG: 25.0, carbsG: 0, fatG: 11.0, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Oméga-3, calcium des arêtes et vitamine D, pour un prix dérisoire.",
                en: "Omega-3s, calcium from the bones and vitamin D, for almost nothing.",
                es: "Omega-3, calcio de las espinas y vitamina D, por muy poco dinero."
            )
        ),
        Food(
            id: "crevettes",
            name: LocalizedText(fr: "Crevettes", en: "Prawns", es: "Gambas"),
            role: .protein, tier: .base,
            kcal: 99, proteinG: 24.0, carbsG: 0.2, fatG: 0.3, fiberG: 0,
            portionG: 120,
            diets: [.omnivore, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Presque uniquement de la protéine, cuisson en trois minutes.",
                en: "Almost pure protein, cooked in three minutes.",
                es: "Casi solo proteína, lista en tres minutos."
            )
        ),
        Food(
            id: "oeuf",
            name: LocalizedText(fr: "Œufs entiers", en: "Whole eggs", es: "Huevos enteros"),
            role: .protein, tier: .base,
            kcal: 143, proteinG: 12.6, carbsG: 1.1, fatG: 9.5, fiberG: 0,
            portionG: 100,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Le profil d'acides aminés de référence, et le jaune porte la choline et les vitamines liposolubles : le jeter revient à jeter la moitié de l'intérêt.",
                en: "The reference amino-acid profile, and the yolk carries the choline and fat-soluble vitamins: binning it bins half the point.",
                es: "El perfil de aminoácidos de referencia, y la yema lleva la colina y las vitaminas liposolubles: tirarla es tirar la mitad del interés."
            )
        ),
        Food(
            id: "blanc-oeuf",
            name: LocalizedText(fr: "Blancs d'œufs", en: "Egg whites", es: "Claras de huevo"),
            role: .protein, tier: .base,
            kcal: 52, proteinG: 10.9, carbsG: 0.7, fatG: 0.2, fiberG: 0,
            portionG: 150,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Utiles pour monter les protéines sans les calories, en complément des œufs entiers, pas à leur place.",
                en: "Useful for adding protein without calories — alongside whole eggs, not instead of them.",
                es: "Útiles para subir proteína sin calorías, junto a los huevos enteros, no en su lugar."
            )
        ),
        Food(
            id: "skyr",
            name: LocalizedText(fr: "Skyr ou yaourt grec 0 %", en: "Skyr or 0 % Greek yoghurt", es: "Skyr o yogur griego 0 %"),
            role: .protein, tier: .base,
            kcal: 63, proteinG: 11.0, carbsG: 4.0, fatG: 0.2, fiberG: 0,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Deux fois plus de protéines qu'un yaourt classique, et une texture qui rassasie.",
                en: "Twice the protein of a plain yoghurt, with a texture that actually fills you up.",
                es: "El doble de proteína que un yogur normal, con una textura que sacia."
            )
        ),
        Food(
            id: "fromage-blanc",
            name: LocalizedText(fr: "Fromage blanc 0 %", en: "Quark / fat-free soft cheese", es: "Queso fresco batido 0 %"),
            role: .protein, tier: .base,
            kcal: 47, proteinG: 8.0, carbsG: 4.0, fatG: 0.2, fiberG: 0,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Protéines lentes du soir, très peu de calories.",
                en: "Slow evening protein, very few calories.",
                es: "Proteína lenta para la noche, con muy pocas calorías."
            )
        ),
        Food(
            id: "cottage",
            name: LocalizedText(fr: "Cottage cheese", en: "Cottage cheese", es: "Requesón"),
            role: .protein, tier: .base,
            kcal: 98, proteinG: 11.0, carbsG: 3.4, fatG: 4.3, fiberG: 0,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Riche en caséine : c'est la protéine qui tient le plus longtemps entre deux repas.",
                en: "Rich in casein: the protein that holds longest between meals.",
                es: "Rico en caseína: la proteína que más aguanta entre comidas."
            )
        ),
        Food(
            id: "whey",
            name: LocalizedText(fr: "Poudre de protéines (whey)", en: "Whey protein powder", es: "Proteína en polvo (whey)"),
            role: .protein, tier: .moderate,
            kcal: 380, proteinG: 78.0, carbsG: 8.0, fatG: 4.0, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un complément pratique, pas un aliment : utile quand la journée manque de 20 ou 30 g, inutile si les repas suffisent.",
                en: "A convenience, not a food: useful when the day is 20 or 30 g short, pointless when meals already cover it.",
                es: "Un complemento práctico, no un alimento: útil si al día le faltan 20 o 30 g, inútil si las comidas ya bastan."
            )
        ),
        Food(
            id: "proteine-vegetale",
            name: LocalizedText(fr: "Protéines végétales en poudre", en: "Plant protein powder", es: "Proteína vegetal en polvo"),
            role: .protein, tier: .moderate,
            kcal: 375, proteinG: 75.0, carbsG: 8.0, fatG: 5.0, fiberG: 4.0,
            portionG: 30,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Un mélange pois-riz couvre tous les acides aminés, ce qu'aucune des deux sources ne fait seule. Utile quand la journée manque de protéines maigres, inutile sinon.",
                en: "A pea-rice blend covers every amino acid, which neither source does alone. Useful when the day is short on lean protein, pointless otherwise.",
                es: "Una mezcla de guisante y arroz cubre todos los aminoácidos, cosa que ninguna de las dos hace sola. Útil cuando al día le falta proteína magra, inútil si no."
            )
        ),
        Food(
            id: "yaourt-soja",
            name: LocalizedText(fr: "Yaourt de soja nature", en: "Plain soy yoghurt", es: "Yogur de soja natural"),
            role: .dairy, tier: .base,
            kcal: 55, proteinG: 4.5, carbsG: 3.0, fatG: 2.5, fiberG: 0.6,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "La seule alternative végétale au yaourt qui apporte de vraies protéines. À prendre enrichie en calcium.",
                en: "The only plant yoghurt that brings real protein. Take the calcium-fortified version.",
                es: "El único yogur vegetal que aporta proteína de verdad. Tómalo enriquecido con calcio."
            )
        ),
        Food(
            id: "tofu",
            name: LocalizedText(fr: "Tofu ferme", en: "Firm tofu", es: "Tofu firme"),
            role: .protein, tier: .base,
            kcal: 144, proteinG: 15.0, carbsG: 3.0, fatG: 8.0, fiberG: 1.0,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Protéine complète d'origine végétale, riche en calcium quand il est coagulé au sulfate de calcium.",
                en: "A complete plant protein, high in calcium when set with calcium sulphate.",
                es: "Proteína vegetal completa, rica en calcio cuando se cuaja con sulfato de calcio."
            )
        ),
        Food(
            id: "tempeh",
            name: LocalizedText(fr: "Tempeh", en: "Tempeh", es: "Tempeh"),
            role: .protein, tier: .base,
            kcal: 192, proteinG: 20.0, carbsG: 8.0, fatG: 11.0, fiberG: 5.0,
            portionG: 120,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Soja fermenté : plus de protéines et plus de fibres que le tofu, et mieux digéré.",
                en: "Fermented soy: more protein and more fibre than tofu, and easier to digest.",
                es: "Soja fermentada: más proteína y más fibra que el tofu, y mejor digerida."
            )
        ),
        Food(
            id: "seitan",
            name: LocalizedText(fr: "Seitan", en: "Seitan", es: "Seitán"),
            role: .protein, tier: .base,
            kcal: 141, proteinG: 25.0, carbsG: 4.0, fatG: 1.9, fiberG: 0.6,
            portionG: 120,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "La protéine végétale la plus dense, mais c'est du gluten pur : exclu en cas de maladie cœliaque.",
                en: "The densest plant protein, but it is pure gluten: off the table for coeliacs.",
                es: "La proteína vegetal más densa, pero es gluten puro: descartada en caso de celiaquía."
            )
        ),
        Food(
            id: "edamame",
            name: LocalizedText(fr: "Édamame", en: "Edamame", es: "Edamame"),
            role: .protein, tier: .base,
            kcal: 121, proteinG: 12.0, carbsG: 9.0, fatG: 5.0, fiberG: 5.0,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Une collation qui apporte de vraies protéines végétales et des fibres.",
                en: "A snack that brings real plant protein and fibre.",
                es: "Un tentempié con proteína vegetal de verdad y fibra."
            )
        ),
        Food(
            id: "lentilles",
            name: LocalizedText(fr: "Lentilles cuites", en: "Cooked lentils", es: "Lentejas cocidas"),
            role: .protein, tier: .base,
            kcal: 116, proteinG: 9.0, carbsG: 20.0, fatG: 0.4, fiberG: 7.9,
            portionG: 180,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Protéines, fibres et fer pour un coût dérisoire. Associées à une céréale, elles couvrent tous les acides aminés.",
                en: "Protein, fibre and iron for almost nothing. Paired with a grain they cover every amino acid.",
                es: "Proteína, fibra y hierro por muy poco. Con un cereal cubren todos los aminoácidos."
            )
        ),
        Food(
            id: "pois-chiches",
            name: LocalizedText(fr: "Pois chiches cuits", en: "Cooked chickpeas", es: "Garbanzos cocidos"),
            role: .protein, tier: .base,
            kcal: 164, proteinG: 9.0, carbsG: 27.0, fatG: 2.6, fiberG: 7.6,
            portionG: 180,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "À la fois féculent et source de protéines : ils remplacent le riz autant que la viande.",
                en: "Both a starch and a protein source: they replace the rice as much as the meat.",
                es: "A la vez farináceo y fuente de proteína: sustituyen tanto al arroz como a la carne."
            )
        ),
        Food(
            id: "haricots-noirs",
            name: LocalizedText(fr: "Haricots noirs cuits", en: "Cooked black beans", es: "Frijoles negros cocidos"),
            role: .protein, tier: .base,
            kcal: 132, proteinG: 9.0, carbsG: 24.0, fatG: 0.5, fiberG: 8.7,
            portionG: 180,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Presque 9 g de fibres aux 100 g : peu d'aliments rassasient autant par calorie.",
                en: "Nearly 9 g of fibre per 100 g: few foods fill you up this much per calorie.",
                es: "Casi 9 g de fibra por 100 g: pocos alimentos sacian tanto por caloría."
            )
        ),
        Food(
            id: "proteine-soja",
            name: LocalizedText(fr: "Protéines de soja texturées", en: "Textured soy protein", es: "Soja texturizada"),
            role: .protein, tier: .base,
            kcal: 100, proteinG: 16.0, carbsG: 6.0, fatG: 1.0, fiberG: 3.0,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Se réhydrate en dix minutes et prend le goût de ce qui l'accompagne : la base bon marché des plats végétariens.",
                en: "Rehydrates in ten minutes and takes on the flavour around it: the cheap base of vegetarian dishes.",
                es: "Se hidrata en diez minutos y toma el sabor de lo que la acompaña: la base barata de los platos vegetarianos."
            )
        ),
        Food(
            id: "flocons-avoine",
            name: LocalizedText(fr: "Flocons d'avoine", en: "Rolled oats", es: "Copos de avena"),
            role: .carb, tier: .base,
            kcal: 372, proteinG: 13.0, carbsG: 60.0, fatG: 7.0, fiberG: 10.0,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Glucides lents et bêta-glucanes : ils tiennent la matinée là où un pain blanc lâche en deux heures.",
                en: "Slow carbs and beta-glucans: they hold the morning where white bread gives up after two hours.",
                es: "Hidratos lentos y betaglucanos: sostienen la mañana donde el pan blanco falla a las dos horas."
            )
        ),
        Food(
            id: "riz-complet",
            name: LocalizedText(fr: "Riz complet cuit", en: "Cooked brown rice", es: "Arroz integral cocido"),
            role: .carb, tier: .base,
            kcal: 123, proteinG: 2.7, carbsG: 26.0, fatG: 1.0, fiberG: 1.8,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Un peu plus de fibres et de magnésium que le riz blanc, pour le même usage.",
                en: "A little more fibre and magnesium than white rice, for the same job.",
                es: "Algo más de fibra y magnesio que el arroz blanco, para el mismo uso."
            )
        ),
        Food(
            id: "riz-blanc",
            name: LocalizedText(fr: "Riz blanc cuit", en: "Cooked white rice", es: "Arroz blanco cocido"),
            role: .carb, tier: .moderate,
            kcal: 130, proteinG: 2.7, carbsG: 28.0, fatG: 0.3, fiberG: 0.4,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Digeste et pratique autour de la séance, mais pauvre en fibres : il rassasie peu pour ses calories.",
                en: "Easy to digest and handy around training, but low in fibre: it fills you up little for the calories.",
                es: "Digestivo y práctico alrededor del entrenamiento, pero pobre en fibra: sacia poco para las calorías que aporta."
            )
        ),
        Food(
            id: "pates-completes",
            name: LocalizedText(fr: "Pâtes complètes cuites", en: "Cooked whole-wheat pasta", es: "Pasta integral cocida"),
            role: .carb, tier: .base,
            kcal: 124, proteinG: 5.0, carbsG: 26.0, fatG: 0.5, fiberG: 3.9,
            portionG: 200,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Deux fois plus rassasiantes que les pâtes blanches, pour un goût à peine différent une fois en sauce.",
                en: "Twice as filling as white pasta, and barely different once there is sauce on it.",
                es: "El doble de saciantes que la pasta blanca, y apenas distintas con salsa."
            )
        ),
        Food(
            id: "pomme-de-terre",
            name: LocalizedText(fr: "Pommes de terre à l'eau", en: "Boiled potatoes", es: "Patatas cocidas"),
            role: .carb, tier: .base,
            kcal: 87, proteinG: 2.0, carbsG: 20.0, fatG: 0.1, fiberG: 1.8,
            portionG: 250,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "L'aliment le mieux classé sur l'indice de satiété mesuré en laboratoire, toutes catégories confondues.",
                en: "The top-ranked food on the laboratory satiety index, across every category.",
                es: "El alimento mejor situado en el índice de saciedad medido en laboratorio, en todas las categorías."
            )
        ),
        Food(
            id: "patate-douce",
            name: LocalizedText(fr: "Patate douce", en: "Sweet potato", es: "Boniato"),
            role: .carb, tier: .base,
            kcal: 90, proteinG: 2.0, carbsG: 21.0, fatG: 0.1, fiberG: 3.3,
            portionG: 250,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Beaucoup de bêta-carotène et plus de fibres que la pomme de terre.",
                en: "Plenty of beta-carotene and more fibre than a regular potato.",
                es: "Mucho betacaroteno y más fibra que la patata."
            )
        ),
        Food(
            id: "quinoa",
            name: LocalizedText(fr: "Quinoa cuit", en: "Cooked quinoa", es: "Quinua cocida"),
            role: .carb, tier: .base,
            kcal: 120, proteinG: 4.4, carbsG: 21.0, fatG: 1.9, fiberG: 2.8,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Un des rares féculents à protéines complètes, et sans gluten.",
                en: "One of the few starches with complete protein, and no gluten.",
                es: "Uno de los pocos farináceos con proteína completa, y sin gluten."
            )
        ),
        Food(
            id: "pain-complet",
            name: LocalizedText(fr: "Pain complet au levain", en: "Wholegrain sourdough", es: "Pan integral de masa madre"),
            role: .carb, tier: .base,
            kcal: 247, proteinG: 13.0, carbsG: 41.0, fatG: 3.4, fiberG: 7.0,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Le levain et le son font descendre la charge glycémique et montent les fibres.",
                en: "Sourdough and bran lower the glycaemic load and raise the fibre.",
                es: "La masa madre y el salvado bajan la carga glucémica y suben la fibra."
            )
        ),
        Food(
            id: "pain-blanc",
            name: LocalizedText(fr: "Pain blanc", en: "White bread", es: "Pan blanco"),
            role: .carb, tier: .moderate,
            kcal: 265, proteinG: 9.0, carbsG: 49.0, fatG: 3.2, fiberG: 2.7,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Rien de dramatique, mais deux fois moins de fibres : il se mange sans être remarqué et compte quand même.",
                en: "Nothing dramatic, but half the fibre: it goes down unnoticed and still counts.",
                es: "Nada dramático, pero la mitad de fibra: se come sin notarlo y cuenta igual."
            )
        ),
        Food(
            id: "sarrasin",
            name: LocalizedText(fr: "Sarrasin cuit", en: "Cooked buckwheat", es: "Trigo sarraceno cocido"),
            role: .carb, tier: .base,
            kcal: 92, proteinG: 3.4, carbsG: 20.0, fatG: 0.6, fiberG: 2.7,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Sans gluten malgré son nom, riche en rutine et en magnésium.",
                en: "Gluten-free despite the name, rich in rutin and magnesium.",
                es: "Sin gluten pese al nombre, rico en rutina y magnesio."
            )
        ),
        Food(
            id: "tortilla-mais",
            name: LocalizedText(fr: "Tortillas de maïs", en: "Corn tortillas", es: "Tortillas de maíz"),
            role: .carb, tier: .base,
            kcal: 218, proteinG: 5.7, carbsG: 45.0, fatG: 2.9, fiberG: 6.0,
            portionG: 60,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Sans gluten, riches en fibres, et elles transforment n'importe quel reste en repas.",
                en: "Gluten-free, high in fibre, and they turn any leftovers into a meal.",
                es: "Sin gluten, ricas en fibra, y convierten cualquier sobra en una comida."
            )
        ),
        Food(
            id: "cracottes-seigle",
            name: LocalizedText(fr: "Tartines de seigle", en: "Rye crispbread", es: "Pan crujiente de centeno"),
            role: .carb, tier: .base,
            kcal: 366, proteinG: 9.0, carbsG: 66.0, fatG: 1.7, fiberG: 16.0,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "16 g de fibres aux 100 g : le support de collation le plus rassasiant du rayon.",
                en: "16 g of fibre per 100 g: the most filling snack base on the shelf.",
                es: "16 g de fibra por 100 g: la base de tentempié más saciante del estante."
            )
        ),
        Food(
            id: "brocoli",
            name: LocalizedText(fr: "Brocoli", en: "Broccoli", es: "Brócoli"),
            role: .vegetable, tier: .base,
            kcal: 34, proteinG: 2.8, carbsG: 7.0, fatG: 0.4, fiberG: 2.6,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Beaucoup de vitamine K et de sulforaphane, et il tient au ventre pour 34 kcal.",
                en: "Loads of vitamin K and sulforaphane, and it fills you up for 34 kcal.",
                es: "Mucha vitamina K y sulforafano, y llena por 34 kcal."
            )
        ),
        Food(
            id: "epinards",
            name: LocalizedText(fr: "Épinards", en: "Spinach", es: "Espinacas"),
            role: .vegetable, tier: .base,
            kcal: 23, proteinG: 2.9, carbsG: 3.6, fatG: 0.4, fiberG: 2.2,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Folates, fer non héminique et nitrates : à associer à une source de vitamine C pour absorber le fer.",
                en: "Folate, non-haem iron and nitrates: pair with vitamin C to absorb the iron.",
                es: "Folatos, hierro no hemo y nitratos: combínalas con vitamina C para absorber el hierro."
            )
        ),
        Food(
            id: "haricots-verts",
            name: LocalizedText(fr: "Haricots verts", en: "Green beans", es: "Judías verdes"),
            role: .vegetable, tier: .base,
            kcal: 31, proteinG: 1.8, carbsG: 7.0, fatG: 0.1, fiberG: 2.7,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Le légume d'accompagnement le plus simple : surgelé, il ne se perd jamais au fond du frigo.",
                en: "The simplest side vegetable: frozen, it never rots at the back of the fridge.",
                es: "La guarnición más simple: congeladas, nunca se pierden al fondo de la nevera."
            )
        ),
        Food(
            id: "courgette",
            name: LocalizedText(fr: "Courgette", en: "Courgette", es: "Calabacín"),
            role: .vegetable, tier: .base,
            kcal: 17, proteinG: 1.2, carbsG: 3.1, fatG: 0.3, fiberG: 1.0,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "17 kcal aux 100 g : elle double le volume d'un plat sans rien changer au total.",
                en: "17 kcal per 100 g: it doubles the volume of a dish without touching the total.",
                es: "17 kcal por 100 g: duplica el volumen de un plato sin tocar el total."
            )
        ),
        Food(
            id: "carotte",
            name: LocalizedText(fr: "Carottes", en: "Carrots", es: "Zanahorias"),
            role: .vegetable, tier: .base,
            kcal: 41, proteinG: 0.9, carbsG: 10.0, fatG: 0.2, fiberG: 2.8,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Bêta-carotène, fibres solubles, et elles se mangent crues sans préparation.",
                en: "Beta-carotene, soluble fibre, and they need no preparation raw.",
                es: "Betacaroteno, fibra soluble, y se comen crudas sin preparación."
            )
        ),
        Food(
            id: "tomate",
            name: LocalizedText(fr: "Tomates", en: "Tomatoes", es: "Tomates"),
            role: .vegetable, tier: .base,
            kcal: 18, proteinG: 0.9, carbsG: 3.9, fatG: 0.2, fiberG: 1.2,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Le lycopène devient plus disponible cuit qu'à cru : la sauce tomate compte vraiment.",
                en: "Lycopene becomes more available cooked than raw: tomato sauce genuinely counts.",
                es: "El licopeno está más disponible cocido que crudo: la salsa de tomate cuenta de verdad."
            )
        ),
        Food(
            id: "poivron",
            name: LocalizedText(fr: "Poivrons", en: "Peppers", es: "Pimientos"),
            role: .vegetable, tier: .base,
            kcal: 31, proteinG: 1.0, carbsG: 6.0, fatG: 0.3, fiberG: 2.1,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Plus de vitamine C qu'une orange, à poids égal.",
                en: "More vitamin C than an orange, gram for gram.",
                es: "Más vitamina C que una naranja, a igual peso."
            )
        ),
        Food(
            id: "chou-fleur",
            name: LocalizedText(fr: "Chou-fleur", en: "Cauliflower", es: "Coliflor"),
            role: .vegetable, tier: .base,
            kcal: 25, proteinG: 1.9, carbsG: 5.0, fatG: 0.3, fiberG: 2.0,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Il remplace une partie du féculent quand les calories serrent, sans faire un repas triste.",
                en: "It stands in for part of the starch when calories are tight, without making the plate sad.",
                es: "Sustituye parte del farináceo cuando aprietan las calorías, sin entristecer el plato."
            )
        ),
        Food(
            id: "champignons",
            name: LocalizedText(fr: "Champignons", en: "Mushrooms", es: "Champiñones"),
            role: .vegetable, tier: .base,
            kcal: 22, proteinG: 3.1, carbsG: 3.3, fatG: 0.3, fiberG: 1.0,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Ils apportent de l'umami, ce qui rend une assiette maigre satisfaisante.",
                en: "They bring umami, which is what makes a lean plate satisfying.",
                es: "Aportan umami, que es lo que hace satisfactorio un plato magro."
            )
        ),
        Food(
            id: "salade",
            name: LocalizedText(fr: "Salade verte", en: "Salad leaves", es: "Hojas de ensalada"),
            role: .vegetable, tier: .base,
            kcal: 15, proteinG: 1.4, carbsG: 2.9, fatG: 0.2, fiberG: 1.3,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Du volume pour rien, à condition de surveiller ce qu'on met dessus.",
                en: "Volume for nothing, as long as you watch what goes on top.",
                es: "Volumen por nada, siempre que vigiles lo que le pones encima."
            )
        ),
        Food(
            id: "chou",
            name: LocalizedText(fr: "Chou", en: "Cabbage", es: "Col"),
            role: .vegetable, tier: .base,
            kcal: 25, proteinG: 1.3, carbsG: 6.0, fatG: 0.1, fiberG: 2.5,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Il se garde trois semaines et coûte trois fois rien.",
                en: "It keeps for three weeks and costs next to nothing.",
                es: "Se conserva tres semanas y cuesta casi nada."
            )
        ),
        Food(
            id: "oignon",
            name: LocalizedText(fr: "Oignons", en: "Onions", es: "Cebollas"),
            role: .vegetable, tier: .base,
            kcal: 40, proteinG: 1.1, carbsG: 9.0, fatG: 0.1, fiberG: 1.7,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Des fibres prébiotiques, et le début de presque toutes les recettes.",
                en: "Prebiotic fibre, and the start of nearly every recipe.",
                es: "Fibra prebiótica, y el inicio de casi todas las recetas."
            )
        ),
        Food(
            id: "asperge",
            name: LocalizedText(fr: "Asperges", en: "Asparagus", es: "Espárragos"),
            role: .vegetable, tier: .base,
            kcal: 20, proteinG: 2.2, carbsG: 3.9, fatG: 0.1, fiberG: 2.1,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Riches en folates, et diurétiques : utile quand la rétention d'eau brouille la pesée.",
                en: "High in folate and mildly diuretic: useful when water retention muddies the scale.",
                es: "Ricos en folatos y algo diuréticos: útiles cuando la retención de agua enturbia la báscula."
            )
        ),
        Food(
            id: "betterave",
            name: LocalizedText(fr: "Betterave", en: "Beetroot", es: "Remolacha"),
            role: .vegetable, tier: .base,
            kcal: 43, proteinG: 1.6, carbsG: 10.0, fatG: 0.2, fiberG: 2.8,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Ses nitrates améliorent mesurablement l'endurance quand elle est prise régulièrement.",
                en: "Its nitrates measurably improve endurance when eaten regularly.",
                es: "Sus nitratos mejoran de forma medible la resistencia si se toma con regularidad."
            )
        ),
        Food(
            id: "banane",
            name: LocalizedText(fr: "Banane", en: "Banana", es: "Plátano"),
            role: .fruit, tier: .base,
            kcal: 89, proteinG: 1.1, carbsG: 23.0, fatG: 0.3, fiberG: 2.6,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Le fruit le plus pratique autour d'une séance : du potassium, des glucides, et un emballage intégré.",
                en: "The handiest fruit around training: potassium, carbs, and packaging included.",
                es: "La fruta más práctica alrededor del entrenamiento: potasio, hidratos y envase incluido."
            )
        ),
        Food(
            id: "pomme",
            name: LocalizedText(fr: "Pomme", en: "Apple", es: "Manzana"),
            role: .fruit, tier: .base,
            kcal: 52, proteinG: 0.3, carbsG: 14.0, fatG: 0.2, fiberG: 2.4,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "De la pectine, qui ralentit la digestion et calme la faim de fin d'après-midi.",
                en: "Pectin, which slows digestion and settles late-afternoon hunger.",
                es: "Pectina, que ralentiza la digestión y calma el hambre de media tarde."
            )
        ),
        Food(
            id: "orange",
            name: LocalizedText(fr: "Orange", en: "Orange", es: "Naranja"),
            role: .fruit, tier: .base,
            kcal: 47, proteinG: 0.9, carbsG: 12.0, fatG: 0.1, fiberG: 2.4,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Entière, elle apporte les fibres que le jus laisse dans la centrifugeuse.",
                en: "Whole, it brings the fibre the juicer leaves behind.",
                es: "Entera aporta la fibra que el zumo deja en la licuadora."
            )
        ),
        Food(
            id: "myrtilles",
            name: LocalizedText(fr: "Myrtilles", en: "Blueberries", es: "Arándanos"),
            role: .fruit, tier: .base,
            kcal: 57, proteinG: 0.7, carbsG: 14.0, fatG: 0.3, fiberG: 2.4,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Densité en polyphénols parmi les plus élevées, surgelées comme fraîches.",
                en: "Among the highest polyphenol densities, frozen just as much as fresh.",
                es: "De las mayores densidades en polifenoles, congelados igual que frescos."
            )
        ),
        Food(
            id: "fraises",
            name: LocalizedText(fr: "Fraises", en: "Strawberries", es: "Fresas"),
            role: .fruit, tier: .base,
            kcal: 32, proteinG: 0.7, carbsG: 7.7, fatG: 0.3, fiberG: 2.0,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "32 kcal aux 100 g : le dessert le moins cher en calories.",
                en: "32 kcal per 100 g: the cheapest dessert in calories.",
                es: "32 kcal por 100 g: el postre más barato en calorías."
            )
        ),
        Food(
            id: "kiwi",
            name: LocalizedText(fr: "Kiwi", en: "Kiwi", es: "Kiwi"),
            role: .fruit, tier: .base,
            kcal: 61, proteinG: 1.1, carbsG: 15.0, fatG: 0.5, fiberG: 3.0,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Deux kiwis couvrent la vitamine C de la journée, et ils aident au transit.",
                en: "Two kiwis cover the day's vitamin C, and they help things move.",
                es: "Dos kiwis cubren la vitamina C del día y ayudan al tránsito."
            )
        ),
        Food(
            id: "raisin",
            name: LocalizedText(fr: "Raisin", en: "Grapes", es: "Uvas"),
            role: .fruit, tier: .moderate,
            kcal: 69, proteinG: 0.7, carbsG: 18.0, fatG: 0.2, fiberG: 0.9,
            portionG: 150,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Peu de fibres pour beaucoup de sucre : un des rares fruits qu'on peut manger sans s'en rendre compte.",
                en: "Little fibre for a lot of sugar: one of the few fruits you can eat without noticing.",
                es: "Poca fibra para mucho azúcar: una de las pocas frutas que se comen sin darse cuenta."
            )
        ),
        Food(
            id: "dattes",
            name: LocalizedText(fr: "Dattes", en: "Dates", es: "Dátiles"),
            role: .fruit, tier: .moderate,
            kcal: 282, proteinG: 2.5, carbsG: 75.0, fatG: 0.4, fiberG: 8.0,
            portionG: 40,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Du sucre concentré, mais avec des fibres et du potassium : parfait avant une sortie longue, pas devant la télévision.",
                en: "Concentrated sugar, but with fibre and potassium: perfect before a long run, less so in front of the television.",
                es: "Azúcar concentrado, pero con fibra y potasio: perfectos antes de una tirada larga, menos frente al televisor."
            )
        ),
        Food(
            id: "huile-olive",
            name: LocalizedText(fr: "Huile d'olive vierge extra", en: "Extra-virgin olive oil", es: "Aceite de oliva virgen extra"),
            role: .fat, tier: .base,
            kcal: 884, proteinG: 0, carbsG: 0, fatG: 100.0, fiberG: 0,
            portionG: 15,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Le gras le mieux documenté sur la santé cardiovasculaire. Une cuillère à soupe pèse 120 kcal : c'est là que les déficits se perdent.",
                en: "The best-documented fat for cardiovascular health. One tablespoon is 120 kcal — this is where deficits quietly die.",
                es: "La grasa mejor documentada para la salud cardiovascular. Una cucharada son 120 kcal: ahí es donde se pierden los déficits."
            )
        ),
        Food(
            id: "huile-colza",
            name: LocalizedText(fr: "Huile de colza", en: "Rapeseed oil", es: "Aceite de colza"),
            role: .fat, tier: .base,
            kcal: 884, proteinG: 0, carbsG: 0, fatG: 100.0, fiberG: 0,
            portionG: 15,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "La meilleure huile végétale courante en oméga-3, à réserver à l'assaisonnement à froid.",
                en: "The best common vegetable oil for omega-3s — keep it for cold dressing.",
                es: "El mejor aceite vegetal común en omega-3, reservado para aliñar en frío."
            )
        ),
        Food(
            id: "avocat",
            name: LocalizedText(fr: "Avocat", en: "Avocado", es: "Aguacate"),
            role: .fat, tier: .base,
            kcal: 160, proteinG: 2.0, carbsG: 9.0, fatG: 15.0, fiberG: 7.0,
            portionG: 80,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Sept grammes de fibres et des acides gras mono-insaturés : un gras qui rassasie, ce qui est rare.",
                en: "Seven grams of fibre and monounsaturated fat: a fat that actually fills you up, which is rare.",
                es: "Siete gramos de fibra y grasa monoinsaturada: una grasa que sacia, cosa poco común."
            )
        ),
        Food(
            id: "amandes",
            name: LocalizedText(fr: "Amandes", en: "Almonds", es: "Almendras"),
            role: .fat, tier: .base,
            kcal: 579, proteinG: 21.0, carbsG: 22.0, fatG: 50.0, fiberG: 12.5,
            portionG: 30,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Vitamine E, magnésium et fibres. Une poignée, c'est 30 g : au-delà, la portion double sans qu'on le voie.",
                en: "Vitamin E, magnesium and fibre. A handful is 30 g: past that, the portion doubles unseen.",
                es: "Vitamina E, magnesio y fibra. Un puñado son 30 g: más allá, la ración se dobla sin verlo."
            )
        ),
        Food(
            id: "noix",
            name: LocalizedText(fr: "Noix", en: "Walnuts", es: "Nueces"),
            role: .fat, tier: .base,
            kcal: 654, proteinG: 15.0, carbsG: 14.0, fatG: 65.0, fiberG: 6.7,
            portionG: 30,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "La seule source végétale vraiment riche en oméga-3 ALA.",
                en: "The only plant source genuinely rich in ALA omega-3.",
                es: "La única fuente vegetal realmente rica en omega-3 ALA."
            )
        ),
        Food(
            id: "beurre-cacahuete",
            name: LocalizedText(fr: "Purée de cacahuète sans sucre", en: "Unsweetened peanut butter", es: "Crema de cacahuete sin azúcar"),
            role: .fat, tier: .moderate,
            kcal: 588, proteinG: 25.0, carbsG: 20.0, fatG: 50.0, fiberG: 6.0,
            portionG: 20,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Excellent, et redoutablement facile à surdoser : la cuillère à soupe fait 120 kcal.",
                en: "Excellent, and dangerously easy to over-serve: a tablespoon is 120 kcal.",
                es: "Excelente y peligrosamente fácil de sobrepasar: una cucharada son 120 kcal."
            )
        ),
        Food(
            id: "graines-chia",
            name: LocalizedText(fr: "Graines de chia", en: "Chia seeds", es: "Semillas de chía"),
            role: .fat, tier: .base,
            kcal: 486, proteinG: 17.0, carbsG: 42.0, fatG: 31.0, fiberG: 34.0,
            portionG: 20,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "34 g de fibres aux 100 g : deux cuillères couvrent un quart de la journée.",
                en: "34 g of fibre per 100 g: two spoons cover a quarter of the day.",
                es: "34 g de fibra por 100 g: dos cucharadas cubren un cuarto del día."
            )
        ),
        Food(
            id: "graines-lin",
            name: LocalizedText(fr: "Graines de lin moulues", en: "Ground flaxseed", es: "Semillas de lino molidas"),
            role: .fat, tier: .base,
            kcal: 534, proteinG: 18.0, carbsG: 29.0, fatG: 42.0, fiberG: 27.0,
            portionG: 15,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Il faut les moudre : entières, elles traversent l'intestin sans rien livrer.",
                en: "They have to be ground: whole, they pass straight through without delivering anything.",
                es: "Hay que molerlas: enteras atraviesan el intestino sin aportar nada."
            )
        ),
        Food(
            id: "graines-courge",
            name: LocalizedText(fr: "Graines de courge", en: "Pumpkin seeds", es: "Pipas de calabaza"),
            role: .fat, tier: .base,
            kcal: 559, proteinG: 30.0, carbsG: 11.0, fatG: 49.0, fiberG: 6.0,
            portionG: 25,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Une des meilleures sources végétales de zinc et de magnésium.",
                en: "One of the best plant sources of zinc and magnesium.",
                es: "Una de las mejores fuentes vegetales de zinc y magnesio."
            )
        ),
        Food(
            id: "beurre",
            name: LocalizedText(fr: "Beurre", en: "Butter", es: "Mantequilla"),
            role: .fat, tier: .moderate,
            kcal: 717, proteinG: 0.9, carbsG: 0.1, fatG: 81.0, fiberG: 0,
            portionG: 10,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Rien d'interdit, mais presque uniquement des acides gras saturés : il complète les huiles, il ne les remplace pas.",
                en: "Nothing forbidden, but almost entirely saturated fat: it complements the oils, it does not replace them.",
                es: "Nada prohibido, pero casi solo grasa saturada: complementa a los aceites, no los sustituye."
            )
        ),
        Food(
            id: "lait",
            name: LocalizedText(fr: "Lait demi-écrémé", en: "Semi-skimmed milk", es: "Leche semidesnatada"),
            role: .dairy, tier: .base,
            kcal: 46, proteinG: 3.3, carbsG: 4.8, fatG: 1.6, fiberG: 0,
            portionG: 250,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Calcium, protéines et vitamine B12 pour 46 kcal aux 100 ml.",
                en: "Calcium, protein and vitamin B12 for 46 kcal per 100 ml.",
                es: "Calcio, proteína y vitamina B12 por 46 kcal cada 100 ml."
            )
        ),
        Food(
            id: "boisson-soja",
            name: LocalizedText(fr: "Boisson de soja enrichie", en: "Fortified soy drink", es: "Bebida de soja enriquecida"),
            role: .dairy, tier: .base,
            kcal: 43, proteinG: 3.3, carbsG: 2.5, fatG: 1.8, fiberG: 0.6,
            portionG: 250,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "La seule alternative végétale au lait dont le profil protéique tient la comparaison. Prends-la enrichie en calcium et en B12.",
                en: "The only plant milk whose protein profile stands comparison. Take the version fortified with calcium and B12.",
                es: "La única alternativa vegetal a la leche cuyo perfil proteico aguanta la comparación. Tómala enriquecida con calcio y B12."
            )
        ),
        Food(
            id: "comte",
            name: LocalizedText(fr: "Fromage à pâte dure", en: "Hard cheese", es: "Queso curado"),
            role: .dairy, tier: .moderate,
            kcal: 402, proteinG: 27.0, carbsG: 1.0, fatG: 32.0, fiberG: 0,
            portionG: 30,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Beaucoup de protéines, mais autant de gras : 30 g suffisent à parfumer un plat entier.",
                en: "Plenty of protein, but as much fat: 30 g is enough to flavour a whole dish.",
                es: "Mucha proteína, pero otro tanto de grasa: 30 g bastan para dar sabor a un plato entero."
            )
        ),
        Food(
            id: "feta",
            name: LocalizedText(fr: "Feta", en: "Feta", es: "Feta"),
            role: .dairy, tier: .moderate,
            kcal: 264, proteinG: 14.0, carbsG: 4.1, fatG: 21.0, fiberG: 0,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Salée et parfumée : une petite quantité transforme une salade fade.",
                en: "Salty and pungent: a small amount rescues a bland salad.",
                es: "Salada y sabrosa: una cantidad pequeña salva una ensalada sosa."
            )
        ),
        Food(
            id: "eau",
            name: LocalizedText(fr: "Eau", en: "Water", es: "Agua"),
            role: .drink, tier: .base,
            kcal: 0, proteinG: 0, carbsG: 0, fatG: 0, fiberG: 0,
            portionG: 500,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "35 ml par kilo et par jour, plus 500 ml par heure d'entraînement. Une perte de 2 % du poids corporel en eau coûte déjà de la performance.",
                en: "35 ml per kilo per day, plus 500 ml per hour of training. Losing 2 % of body weight in water already costs performance.",
                es: "35 ml por kilo y día, más 500 ml por hora de entrenamiento. Perder un 2 % del peso corporal en agua ya cuesta rendimiento."
            )
        ),
        Food(
            id: "cafe",
            name: LocalizedText(fr: "Café", en: "Coffee", es: "Café"),
            role: .drink, tier: .base,
            kcal: 2, proteinG: 0.1, carbsG: 0, fatG: 0, fiberG: 0,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "3 mg de caféine par kilo une heure avant une séance améliorent la performance de façon reproductible.",
                en: "3 mg of caffeine per kilo an hour before training improves performance reproducibly.",
                es: "3 mg de cafeína por kilo una hora antes mejoran el rendimiento de forma reproducible."
            )
        ),
        Food(
            id: "the-vert",
            name: LocalizedText(fr: "Thé vert", en: "Green tea", es: "Té verde"),
            role: .drink, tier: .base,
            kcal: 1, proteinG: 0, carbsG: 0, fatG: 0, fiberG: 0,
            portionG: 250,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "De la caféine plus douce et des catéchines, sans calories.",
                en: "Gentler caffeine and catechins, with no calories.",
                es: "Cafeína más suave y catequinas, sin calorías."
            )
        ),
        Food(
            id: "jus-fruit",
            name: LocalizedText(fr: "Jus de fruit", en: "Fruit juice", es: "Zumo de fruta"),
            role: .drink, tier: .moderate,
            kcal: 45, proteinG: 0.5, carbsG: 10.4, fatG: 0.1, fiberG: 0.2,
            portionG: 200,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Le sucre du fruit sans ses fibres : un verre se boit en dix secondes et pèse autant que trois oranges.",
                en: "Fruit sugar without the fibre: a glass goes down in ten seconds and weighs as much as three oranges.",
                es: "El azúcar de la fruta sin su fibra: un vaso se bebe en diez segundos y pesa como tres naranjas."
            )
        ),
        Food(
            id: "soda",
            name: LocalizedText(fr: "Soda sucré", en: "Sugary soft drink", es: "Refresco azucarado"),
            role: .drink, tier: .occasional,
            kcal: 42, proteinG: 0, carbsG: 10.6, fatG: 0, fiberG: 0,
            portionG: 330,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Des calories qui ne rassasient pas du tout : le corps ne les compte pas au repas suivant.",
                en: "Calories that do not fill you up at all: the body fails to count them at the next meal.",
                es: "Calorías que no sacian nada: el cuerpo no las descuenta en la comida siguiente."
            )
        ),
        Food(
            id: "biere",
            name: LocalizedText(fr: "Bière", en: "Beer", es: "Cerveza"),
            role: .drink, tier: .occasional,
            kcal: 43, proteinG: 0.5, carbsG: 3.6, fatG: 0, fiberG: 0, alcoholG: 3.9,
            portionG: 330,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "L'alcool coupe la synthèse protéique pendant plusieurs heures et dégrade le sommeil profond, qui est là où la récupération se passe.",
                en: "Alcohol blunts protein synthesis for hours and wrecks deep sleep, which is where recovery happens.",
                es: "El alcohol frena la síntesis proteica durante horas y deteriora el sueño profundo, que es donde ocurre la recuperación."
            )
        ),
        Food(
            id: "chocolat-noir",
            name: LocalizedText(fr: "Chocolat noir 85 %", en: "85 % dark chocolate", es: "Chocolate negro 85 %"),
            role: .treat, tier: .moderate,
            kcal: 604, proteinG: 10.0, carbsG: 19.0, fatG: 47.0, fiberG: 11.0,
            portionG: 20,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Deux carrés suffisent, et c'est justement ce qui le rend tenable tous les jours.",
                en: "Two squares is enough, and that is exactly what makes it sustainable daily.",
                es: "Dos onzas bastan, y eso es justo lo que lo hace sostenible a diario."
            )
        ),
        Food(
            id: "chips",
            name: LocalizedText(fr: "Chips", en: "Crisps", es: "Patatas fritas de bolsa"),
            role: .treat, tier: .occasional,
            kcal: 536, proteinG: 7.0, carbsG: 53.0, fatG: 34.0, fiberG: 4.0,
            portionG: 30,
            diets: Set(DietPreference.allCases),
            reason: LocalizedText(
                fr: "Conçues pour qu'on ne s'arrête pas : gras, sel et croquant, sans fibres pour freiner.",
                en: "Engineered so you do not stop: fat, salt and crunch, with no fibre to slow you.",
                es: "Diseñadas para que no pares: grasa, sal y crujido, sin fibra que frene."
            )
        ),
        Food(
            id: "biscuits",
            name: LocalizedText(fr: "Biscuits industriels", en: "Packaged biscuits", es: "Galletas industriales"),
            role: .treat, tier: .occasional,
            kcal: 480, proteinG: 5.5, carbsG: 65.0, fatG: 22.0, fiberG: 2.0,
            portionG: 40,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Sucre et gras ensemble : la combinaison qui contourne le mieux les signaux de satiété.",
                en: "Sugar and fat together: the combination that best bypasses fullness signals.",
                es: "Azúcar y grasa juntos: la combinación que mejor esquiva las señales de saciedad."
            )
        ),
        Food(
            id: "viennoiserie",
            name: LocalizedText(fr: "Viennoiserie", en: "Pastry", es: "Bollería"),
            role: .treat, tier: .occasional,
            kcal: 406, proteinG: 8.0, carbsG: 46.0, fatG: 21.0, fiberG: 2.0,
            portionG: 60,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "400 kcal avant même d'avoir commencé la journée, et une faim de retour à onze heures.",
                en: "400 kcal before the day has even started, and hunger back by eleven.",
                es: "400 kcal antes de empezar el día, y hambre de vuelta a las once."
            )
        ),
        Food(
            id: "charcuterie",
            name: LocalizedText(fr: "Charcuterie", en: "Processed deli meat", es: "Embutidos"),
            role: .treat, tier: .occasional,
            kcal: 300, proteinG: 13.0, carbsG: 2.0, fatG: 27.0, fiberG: 0,
            portionG: 50,
            diets: [.omnivore, .glutenFree],
            reason: LocalizedText(
                fr: "Classée cancérogène avéré pour le côlon par le CIRC, et très salée. C'est le seul aliment de cette liste où la quantité compte vraiment.",
                en: "Classified by IARC as a proven colorectal carcinogen, and very salty. It is the one food here where the amount genuinely matters.",
                es: "Clasificada por la IARC como cancerígeno probado para el colon, y muy salada. Es el único alimento de esta lista donde la cantidad importa de verdad."
            )
        ),
        Food(
            id: "glace",
            name: LocalizedText(fr: "Crème glacée", en: "Ice cream", es: "Helado"),
            role: .treat, tier: .occasional,
            kcal: 207, proteinG: 3.5, carbsG: 24.0, fatG: 11.0, fiberG: 0.7,
            portionG: 80,
            diets: [.omnivore, .vegetarian, .pescatarian, .halal, .glutenFree],
            reason: LocalizedText(
                fr: "Un dessert qui a sa place, à condition qu'il soit servi dans un bol et pas mangé au pot.",
                en: "A dessert with its place, provided it lands in a bowl and not straight from the tub.",
                es: "Un postre con su sitio, siempre que se sirva en un bol y no se coma del envase."
            )
        ),
        Food(
            id: "pizza-surgelee",
            name: LocalizedText(fr: "Pizza surgelée", en: "Frozen pizza", es: "Pizza congelada"),
            role: .treat, tier: .occasional,
            kcal: 266, proteinG: 11.0, carbsG: 33.0, fatG: 10.0, fiberG: 2.3,
            portionG: 300,
            diets: [.omnivore, .vegetarian, .vegan, .pescatarian, .halal],
            reason: LocalizedText(
                fr: "Une pizza entière fait souvent 800 kcal : ce n'est pas un problème si elle est prévue, c'en est un si elle s'ajoute.",
                en: "A whole pizza is often 800 kcal: not a problem when it is planned, a problem when it is added.",
                es: "Una pizza entera suele ser 800 kcal: no es problema si está prevista, sí lo es si se añade."
            )
        ),
    ]

    static let index: [String: Food] = Dictionary(uniqueKeysWithValues: all.map { ($0.id, $0) })

    public static func food(id: String) -> Food? { index[id] }

    public static func all(role: FoodRole) -> [Food] { all.filter { $0.role == role } }

    public static func all(tier: FoodTier) -> [Food] { all.filter { $0.tier == tier } }

    /// Ce que l'athlète peut manger, une fois son régime et ses refus retirés.
    public static func available(
        diet: DietPreference,
        excluding excluded: Set<String> = [],
        roles: Set<FoodRole>? = nil,
        maximumTier: FoodTier = .occasional
    ) -> [Food] {
        all.filter { food in
            food.suits(diet)
                && !excluded.contains(food.id)
                && food.tier <= maximumTier
                && (roles?.contains(food.role) ?? true)
        }
    }
}
