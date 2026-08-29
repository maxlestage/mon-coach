import Foundation

/// Comment un aliment s'achète vraiment.
///
/// Pourquoi ce fichier existe
/// --------------------------
/// Le plan compte en grammes de produit prêt à consommer, parce que c'est
/// ainsi qu'on calcule des macros. Une liste de courses, elle, se lit dans un
/// magasin : « 110 g d'huile d'olive » et « 1 740 g de riz complet cuit » n'y
/// veulent rien dire. On n'achète pas 110 g d'huile, on achète une bouteille ;
/// et le riz se vend cru, pas cuit — 1 740 g cuits, c'est 580 g dans le
/// paquet.
///
/// Deux traductions, donc, et elles sont indépendantes :
///
/// 1. **du cuit au cru**, pour tout ce qui gonfle à la cuisson ;
/// 2. **du poids au conditionnement**, pour tout ce qui se vend en boîte, en
///    pot, à la pièce, ou qui dort dans un placard.
///
/// Ce qui n'est dans aucune des deux tables se vend au poids, ce qui est le
/// cas de la plupart des fruits, légumes, viandes et poissons : le défaut est
/// donc juste, et une omission n'invente rien.
public enum ShoppingUnits {

    /// Un conditionnement, avec son singulier et son pluriel.
    ///
    /// Les deux formes plutôt qu'un « 2 × pot » : une liste de courses se lit
    /// d'un œil en tenant un cabas, et « 3 boîtes » se lit plus vite que
    /// n'importe quelle notation.
    public struct Pack: Sendable, Equatable, Hashable {
        public var one: LocalizedText
        public var many: LocalizedText
        /// Le poids du conditionnement. Zéro pour ce qui se garde au placard,
        /// dont la quantité hebdomadaire n'a pas à décider d'un achat.
        public var grams: Double

        public init(one: LocalizedText, many: LocalizedText, grams: Double = 0) {
            self.one = one
            self.many = many
            self.grams = grams
        }
    }

    public enum Purchase: Sendable, Equatable, Hashable {
        /// Au poids, tel quel : le rayon frais, la boucherie, la poissonnerie.
        case loose
        /// En conditionnement fermé : boîtes, pots, briques, paquets.
        case pack(Pack)
        /// À la pièce, parce que c'est ainsi qu'on les compte.
        case piece(Pack)
        /// Ce qu'on a déjà chez soi et qu'on rachète quand c'est fini.
        /// La quantité de la semaine est rappelée, elle ne commande rien.
        case pantry(Pack)
    }

    private static func bottle(_ fr: String, _ en: String, _ es: String) -> Purchase {
        .pantry(Pack(
            one: LocalizedText(fr: fr, en: en, es: es),
            many: LocalizedText(fr: fr, en: en, es: es)
        ))
    }

    private static func pack(
        _ grams: Double,
        _ one: (String, String, String),
        _ many: (String, String, String)
    ) -> Purchase {
        .pack(Pack(
            one: LocalizedText(fr: one.0, en: one.1, es: one.2),
            many: LocalizedText(fr: many.0, en: many.1, es: many.2),
            grams: grams
        ))
    }

    private static func piece(
        _ grams: Double,
        _ one: (String, String, String),
        _ many: (String, String, String)
    ) -> Purchase {
        .piece(Pack(
            one: LocalizedText(fr: one.0, en: one.1, es: one.2),
            many: LocalizedText(fr: many.0, en: many.1, es: many.2),
            grams: grams
        ))
    }

    /// Le poids sec à acheter, pour un gramme de produit cuit.
    ///
    /// Les féculents et les légumineuses absorbent deux à trois fois leur
    /// poids en eau. Sans cette table, la liste réclamait un kilo sept de riz
    /// pour une semaine — de quoi nourrir une famille — et l'écran devait
    /// s'excuser par une note demandant de « compter environ un tiers ».
    /// Une liste de courses n'a pas à se faire corriger par son lecteur.
    public static let dryWeight: [String: Double] = [
        "riz-blanc": 0.33, "riz-complet": 0.33, "riz-basmati": 0.33,
        "pates-completes": 0.45, "pates-blanches": 0.45,
        "quinoa": 0.35, "boulgour": 0.4, "semoule": 0.5, "epeautre": 0.4,
        "orge-perle": 0.35, "millet": 0.35, "sarrasin": 0.4, "polenta": 0.25,
        "lentilles": 0.4, "pois-casses": 0.4,
        "flocons-avoine": 1.0,
    ]

    /// Comment chaque aliment se vend, quand ce n'est pas au poids.
    public static let purchase: [String: Purchase] = [
        // À la pièce.
        "oeuf": piece(60, ("œuf", "egg", "huevo"), ("œufs", "eggs", "huevos")),
        "avocat": piece(150, ("avocat", "avocado", "aguacate"), ("avocats", "avocados", "aguacates")),
        "citron": piece(100, ("citron", "lemon", "limón"), ("citrons", "lemons", "limones")),
        "banane": piece(120, ("banane", "banana", "plátano"), ("bananes", "bananas", "plátanos")),
        "pomme": piece(150, ("pomme", "apple", "manzana"), ("pommes", "apples", "manzanas")),
        "poire": piece(160, ("poire", "pear", "pera"), ("poires", "pears", "peras")),
        "orange": piece(180, ("orange", "orange", "naranja"), ("oranges", "oranges", "naranjas")),
        "pamplemousse": piece(300, ("pamplemousse", "grapefruit", "pomelo"), ("pamplemousses", "grapefruits", "pomelos")),
        "kiwi": piece(80, ("kiwi", "kiwi", "kiwi"), ("kiwis", "kiwis", "kiwis")),
        "clementine": piece(70, ("clémentine", "clementine", "clementina"), ("clémentines", "clementines", "clementinas")),
        "peche": piece(150, ("pêche", "peach", "melocotón"), ("pêches", "peaches", "melocotones")),
        "artichaut": piece(300, ("artichaut", "artichoke", "alcachofa"), ("artichauts", "artichokes", "alcachofas")),
        "endive": piece(150, ("endive", "chicory", "endibia"), ("endives", "chicory heads", "endibias")),
        "salade": piece(200, ("salade", "lettuce", "lechuga"), ("salades", "lettuces", "lechugas")),
        "tortilla-mais": piece(30, ("tortilla", "tortilla", "tortilla"), ("tortillas", "tortillas", "tortillas")),
        "wrap-ble": piece(60, ("wrap", "wrap", "wrap"), ("wraps", "wraps", "wraps")),

        // En conditionnement.
        "thon-boite": pack(140, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "sardines": pack(100, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "maquereau": pack(120, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "anchois": pack(50, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "haricots-rouges": pack(400, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "haricots-blancs": pack(400, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "haricots-noirs": pack(400, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "pois-chiches": pack(400, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "mais-doux": pack(300, ("boîte", "tin", "lata"), ("boîtes", "tins", "latas")),
        "sauce-tomate": pack(400, ("brique", "carton", "brik"), ("briques", "cartons", "briks")),
        "skyr": pack(450, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "yaourt-grec": pack(450, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "fromage-blanc": pack(500, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "cottage": pack(400, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "ricotta": pack(250, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "petit-suisse": pack(60, ("petit-suisse", "pot", "petit-suisse"), ("petits-suisses", "pots", "petit-suisses")),
        "yaourt-nature": pack(125, ("yaourt", "yoghurt", "yogur"), ("yaourts", "yoghurts", "yogures")),
        "yaourt-soja": pack(125, ("yaourt", "yoghurt", "yogur"), ("yaourts", "yoghurts", "yogures")),
        "blanc-oeuf": pack(500, ("brique", "carton", "brik"), ("briques", "cartons", "briks")),
        "lait": pack(1_000, ("brique", "carton", "brik"), ("briques", "cartons", "briks")),
        "boisson-soja": pack(1_000, ("brique", "carton", "brik"), ("briques", "cartons", "briks")),
        "mozzarella": pack(125, ("boule", "ball", "bola"), ("boules", "balls", "bolas")),
        "feta": pack(200, ("bloc", "block", "bloque"), ("blocs", "blocks", "bloques")),
        "tofu": pack(250, ("bloc", "block", "bloque"), ("blocs", "blocks", "bloques")),
        "tofu-fume": pack(200, ("bloc", "block", "bloque"), ("blocs", "blocks", "bloques")),
        "tempeh": pack(200, ("bloc", "block", "bloque"), ("blocs", "blocks", "bloques")),
        "seitan": pack(200, ("bloc", "block", "bloque"), ("blocs", "blocks", "bloques")),
        "pain-complet": pack(400, ("pain", "loaf", "pan"), ("pains", "loaves", "panes")),
        "pain-seigle": pack(400, ("pain", "loaf", "pan"), ("pains", "loaves", "panes")),
        "pain-cereales": pack(400, ("pain", "loaf", "pan"), ("pains", "loaves", "panes")),
        "pain-blanc": pack(250, ("baguette", "baguette", "barra"), ("baguettes", "baguettes", "barras")),
        "cracottes-seigle": pack(250, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "galettes-riz": pack(130, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "muesli-nature": pack(500, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "granola": pack(500, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "cereales-mais": pack(500, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "vermicelles-riz": pack(250, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "gnocchis": pack(400, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "compote-ssa": pack(100, ("gourde", "pouch", "bolsita"), ("gourdes", "pouches", "bolsitas")),
        "surimi": pack(200, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "jambon-blanc": pack(160, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "saumon-fume": pack(150, ("paquet", "packet", "paquete"), ("paquets", "packets", "paquetes")),
        "houmous": pack(200, ("pot", "tub", "tarrina"), ("pots", "tubs", "tarrinas")),
        "pesto": pack(190, ("pot", "jar", "tarro"), ("pots", "jars", "tarros")),
        "olives": pack(200, ("bocal", "jar", "tarro"), ("bocaux", "jars", "tarros")),
        "cornichons": pack(200, ("bocal", "jar", "tarro"), ("bocaux", "jars", "tarros")),

        // Le placard : on en rachète quand c'est fini, pas chaque semaine.
        "huile-olive": bottle("bouteille d'huile d'olive", "bottle of olive oil", "botella de aceite de oliva"),
        "huile-colza": bottle("bouteille d'huile de colza", "bottle of rapeseed oil", "botella de aceite de colza"),
        "huile-noix": bottle("bouteille d'huile de noix", "bottle of walnut oil", "botella de aceite de nuez"),
        "beurre": bottle("plaquette de beurre", "block of butter", "pastilla de mantequilla"),
        "creme-fraiche": bottle("pot de crème", "pot of cream", "tarrina de nata"),
        "creme-legere": bottle("pot de crème légère", "pot of light cream", "tarrina de nata ligera"),
        "beurre-cacahuete": bottle("pot de purée de cacahuète", "jar of peanut butter", "tarro de crema de cacahuete"),
        "puree-amande": bottle("pot de purée d'amande", "jar of almond butter", "tarro de crema de almendra"),
        "tahini": bottle("pot de tahini", "jar of tahini", "tarro de tahini"),
        "graines-sesame": bottle("sachet de sésame", "bag of sesame seeds", "bolsa de sésamo"),
        "graines-lin": bottle("sachet de lin moulu", "bag of ground flaxseed", "bolsa de lino molido"),
        "graines-chia": bottle("sachet de chia", "bag of chia seeds", "bolsa de chía"),
        "graines-courge": bottle("sachet de graines de courge", "bag of pumpkin seeds", "bolsa de pipas de calabaza"),
        "graines-tournesol": bottle("sachet de graines de tournesol", "bag of sunflower seeds", "bolsa de pipas de girasol"),
        "coco-rape": bottle("sachet de noix de coco râpée", "bag of desiccated coconut", "bolsa de coco rallado"),
        "whey": bottle("pot de whey", "tub of whey", "bote de proteína de suero"),
        "caseine": bottle("pot de caséine", "tub of casein", "bote de caseína"),
        "proteine-vegetale": bottle("pot de protéines végétales", "tub of plant protein", "bote de proteína vegetal"),
        "amandes": bottle("sachet d'amandes", "bag of almonds", "bolsa de almendras"),
        "noix": bottle("sachet de noix", "bag of walnuts", "bolsa de nueces"),
        "noisettes": bottle("sachet de noisettes", "bag of hazelnuts", "bolsa de avellanas"),
        "noix-pecan": bottle("sachet de noix de pécan", "bag of pecans", "bolsa de nueces pecanas"),
        "noix-bresil": bottle("sachet de noix du Brésil", "bag of Brazil nuts", "bolsa de nueces de Brasil"),
        "cajou": bottle("sachet de noix de cajou", "bag of cashews", "bolsa de anacardos"),
        "pistaches": bottle("sachet de pistaches", "bag of pistachios", "bolsa de pistachos"),
        "cacahuetes": bottle("sachet de cacahuètes", "bag of peanuts", "bolsa de cacahuetes"),
        "raisins-secs": bottle("sachet de raisins secs", "bag of raisins", "bolsa de pasas"),
        "abricots-secs": bottle("sachet d'abricots secs", "bag of dried apricots", "bolsa de orejones"),
        "pruneaux": bottle("sachet de pruneaux", "bag of prunes", "bolsa de ciruelas pasas"),
        "dattes": bottle("sachet de dattes", "bag of dates", "bolsa de dátiles"),
    ]

    public static func purchase(for foodID: String) -> Purchase {
        purchase[foodID] ?? .loose
    }

    /// Le poids à acheter pour ce poids prêt à consommer.
    public static func weightToBuy(_ grams: Double, foodID: String) -> Double {
        grams * (dryWeight[foodID] ?? 1.0)
    }
}
