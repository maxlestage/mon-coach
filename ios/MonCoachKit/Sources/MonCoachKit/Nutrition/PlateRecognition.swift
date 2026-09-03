import Foundation

/// D'où vient une lecture : l'assiette entière, ou l'une de ses zones.
///
/// Pourquoi découper l'image
/// -------------------------
/// Un classificateur généraliste répond à la question « qu'est-ce que
/// c'est ? » posée à une image entière, et une assiette de poulet-riz-brocoli
/// n'est *pas* une chose : c'est trois choses. Le système répondait donc par
/// la plus voyante — souvent le féculent, parce qu'il occupe la place — et
/// les deux autres disparaissaient. Regarder aussi chaque quartier pose la
/// question trois fois de plus, sur des images où il n'y a qu'une chose à
/// voir. C'est le gain de précision le plus net qu'on puisse obtenir sans
/// serveur ni modèle maison.
public enum PlateRegion: String, Codable, Sendable, CaseIterable, Hashable {
    case whole
    case centre
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight

    public var label: LocalizedText {
        switch self {
        case .whole: LocalizedText(fr: "toute l'assiette", en: "the whole plate", es: "todo el plato")
        case .centre: LocalizedText(fr: "au centre", en: "in the middle", es: "en el centro")
        case .topLeft: LocalizedText(fr: "en haut à gauche", en: "top left", es: "arriba a la izquierda")
        case .topRight: LocalizedText(fr: "en haut à droite", en: "top right", es: "arriba a la derecha")
        case .bottomLeft: LocalizedText(fr: "en bas à gauche", en: "bottom left", es: "abajo a la izquierda")
        case .bottomRight: LocalizedText(fr: "en bas à droite", en: "bottom right", es: "abajo a la derecha")
        }
    }
}

/// Une chose que le système a cru voir, et où.
public struct PlateReading: Sendable, Equatable, Hashable {
    /// L'étiquette telle que le système la donne, avant toute mise à plat.
    public var identifier: String
    /// La note du classificateur, de 0 à 1. Ce n'est pas une probabilité.
    public var confidence: Double
    public var region: PlateRegion

    public init(identifier: String, confidence: Double, region: PlateRegion = .whole) {
        self.identifier = identifier
        self.confidence = confidence
        self.region = region
    }
}

/// Ce qu'une étiquette du système est devenue.
public enum PlateOutcome: Sendable, Equatable, Hashable {
    /// Un aliment du catalogue, retenu dans l'assiette.
    case food(String)
    /// Un aliment du catalogue, mais écarté du plan de l'athlète.
    case refused(String)
    /// Pas d'aliment, mais un rayon : « de la viande », « un féculent ».
    case aisle(FoodRole)
    /// Rien de connu. C'est ce que l'athlète peut traduire une bonne fois.
    case unknown
}

/// Une étiquette vue, ce qu'elle est devenue, et à quel point on y croit.
///
/// Ce type existe pour que l'écran puisse **tout** montrer. La version
/// précédente jetait en silence ce qu'elle ne savait pas traduire : devant
/// une assiette non reconnue, l'athlète ne pouvait pas savoir si le système
/// n'avait rien vu ou si c'était le catalogue qui ne suivait pas. La
/// différence change tout — dans un cas on refait la photo, dans l'autre on
/// apprend le mot une fois pour toutes.
public struct PlateSighting: Sendable, Equatable, Identifiable, Hashable {
    public var id: String { label }
    /// L'étiquette mise à plat : minuscules, blancs remplacés par des « _ ».
    public var label: String
    /// La meilleure note obtenue par cette étiquette, toutes zones confondues.
    public var confidence: Double
    public var outcome: PlateOutcome
    /// Les zones où elle est apparue, dans l'ordre du découpage.
    public var regions: [PlateRegion]

    public init(
        label: String,
        confidence: Double,
        outcome: PlateOutcome,
        regions: [PlateRegion] = [.whole]
    ) {
        self.label = label
        self.confidence = confidence
        self.outcome = outcome
        self.regions = regions
    }

    /// Le mot rendu lisible : « chocolate_chip_cookie » → « chocolate chip
    /// cookie ». Le système parle anglais, et c'est ainsi qu'il faut le
    /// montrer — le traduire à moitié donnerait un mot qui n'existe nulle
    /// part.
    public var readable: String {
        label.replacingOccurrences(of: "_", with: " ")
    }

    /// Ce qu'il faut écrire sur la ligne, dans la langue de l'athlète.
    ///
    /// Pourquoi ce n'est pas `readable`
    /// --------------------------------
    /// L'écran montrait le mot brut du classificateur — « chicken_breast » —
    /// et rangeait le nom français en petit sur le côté. Résultat : une
    /// liste anglaise dans une application française, où l'information la
    /// plus utile était la plus discrète.
    ///
    /// Dès qu'on sait à quoi le mot correspond, on connaît son nom dans la
    /// bonne langue : le catalogue le porte, et le rayon aussi. Le mot du
    /// système garde sa place, en dessous et annoncé comme tel — c'est lui
    /// qu'on apprend, donc le cacher tout à fait rendrait l'apprentissage
    /// incompréhensible.
    ///
    /// Reste le cas honnête : un mot que le catalogue ne connaît pas ne se
    /// traduit pas. On l'affiche tel quel, en anglais, parce qu'inventer une
    /// traduction pour un mot dont on ignore le sens serait une invention de
    /// plus, pas une aide.
    public func name(in language: Language) -> String {
        switch outcome {
        case .food(let foodID), .refused(let foodID):
            return FoodCatalog.food(id: foodID)?.name[language] ?? readable
        case .aisle(let role):
            return role.label[language]
        case .unknown:
            return readable
        }
    }

    /// Le nom affiché est-il celui du système, faute de mieux ?
    ///
    /// L'écran s'en sert pour dire « mot du système » sous un mot anglais,
    /// plutôt que de laisser croire à une faute de traduction.
    public var namedBySystem: Bool {
        outcome == .unknown
    }
}

/// Tout ce qu'une photo a donné.
public struct PlateAnalysis: Sendable, Equatable {
    /// Les aliments retenus, du plus sûr au moins sûr.
    public var items: [PlateItem]
    /// Les rayons devinés, quand le système n'a pas su nommer.
    public var roles: [FoodRole]
    /// Absolument tout ce qui a été vu, du plus sûr au moins sûr.
    public var sightings: [PlateSighting]

    public init(items: [PlateItem], roles: [FoodRole], sightings: [PlateSighting]) {
        self.items = items
        self.roles = roles
        self.sightings = sightings
    }

    public static let empty = PlateAnalysis(items: [], roles: [], sightings: [])

    /// Ce qui a été reconnu mais qui est écarté du plan — allergie, dégoût.
    /// Le taire serait le pire des silences : l'athlète croirait que
    /// l'application n'a pas vu l'arachide.
    public var refused: [PlateSighting] {
        sightings.filter { if case .refused = $0.outcome { true } else { false } }
    }

    /// Les mots que le catalogue ne sait pas traduire. Ce sont eux qu'on
    /// propose d'apprendre.
    public var unknown: [PlateSighting] {
        sightings.filter { $0.outcome == .unknown }
    }
}

/// Un aliment et l'accord qu'on a trouvé pour lui, le temps du tri.
private struct FusedFood {
    var foodID: String
    var confidence: Double
    var rank: Int
}

extension PlateVision {

    /// Les mots qui décrivent la cuisson ou le cadrage, pas l'aliment.
    ///
    /// Le système en met partout : « grilled_salmon », « close_up_of_food »,
    /// « homemade_pizza ». Les retirer avant de chercher fait passer une
    /// bonne moitié des étiquettes composées qui échouaient jusqu'ici.
    static let seasoning: Set<String> = [
        "grilled", "roasted", "roast", "fried", "deep_fried", "baked", "steamed",
        "boiled", "raw", "cooked", "smoked", "seared", "sauteed", "braised",
        "poached", "mashed", "sliced", "chopped", "diced", "shredded", "minced",
        "fresh", "frozen", "canned", "hot", "cold", "warm", "homemade",
        "plate", "plateful", "dish", "bowl", "serving", "portion", "meal",
        "food", "meat", "closeup", "close", "up", "of", "and", "with", "on",
        "a", "the", "some", "half", "whole", "piece", "pieces", "slice", "slices",
    ]

    /// Les mots qui nomment le décor, jamais ce qu'on mange.
    ///
    /// Pourquoi les jeter plutôt que les montrer
    /// -----------------------------------------
    /// Un classificateur généraliste décrit toute l'image, et une photo
    /// d'assiette contient surtout autre chose que de la nourriture : la
    /// table, l'assiette, les couverts, la nappe, la bouteille à côté. Il
    /// rendait donc « structure », « wood processed », « container »,
    /// « utensil », « tableware » — six lignes en tête de liste avant le
    /// premier aliment.
    ///
    /// Les laisser coûtait deux fois. Elles noyaient ce qu'on cherchait, et
    /// surtout l'application proposait de les **apprendre** : traduire
    /// « wood processed » en un aliment aurait sali la table de corrections
    /// pour de bon, et cette table sert ensuite à toutes les photos.
    ///
    /// Le filtre ne s'applique qu'aux mots qui n'ont mené à rien. Si l'un
    /// d'eux désigne malgré tout un aliment du catalogue, c'est cet aliment
    /// qui gagne — un décor reconnu comme nourriture n'est plus du décor.
    static let scenery: Set<String> = [
        // La pièce et le mobilier
        "structure", "furniture", "table", "desk", "chair", "counter",
        "countertop", "kitchen", "restaurant", "cafe", "diner", "indoor",
        "indoors", "room", "interior", "floor", "wall", "window", "shelf",
        // La vaisselle et les couverts
        "tableware", "dishware", "utensil", "utensils", "cutlery", "silverware",
        "fork", "knife", "spoon", "chopsticks", "straw", "container",
        "containers", "bottle", "jar", "can", "tin", "glass", "cup", "mug",
        "tray", "pan", "pot", "skillet", "saucepan", "lid", "napkin",
        "tablecloth", "placemat", "coaster", "packaging", "wrapper", "box",
        "bag", "carton", "label", "menu",
        // Les matières
        "wood", "wood_processed", "wooden", "plastic", "metal", "steel",
        "ceramic", "porcelain", "paper", "cardboard", "textile", "fabric",
        "cloth", "linen", "marble", "granite", "stone", "glassware",
        // Ce qui n'est pas l'assiette
        "person", "people", "hand", "hands", "finger", "fingers", "arm",
        "face", "phone", "book", "plant", "flower", "candle", "light",
        "shadow", "reflection", "text", "handwriting", "logo",
    ]

    /// Les mots qui nomment un plat, et dont l'ingrédient de tête compte
    /// davantage.
    ///
    /// « chicken_curry » est du poulet, pas du riz ; « beef_stew » du bœuf.
    /// Ces mots-là ne valent donc qu'employés seuls : à l'intérieur d'un
    /// composé, ils s'effacent devant ce qui les accompagne. C'est
    /// exactement l'inverse d'un gâteau — « carrot_cake » est un gâteau, pas
    /// des carottes — et c'est pourquoi la liste est courte et explicite
    /// plutôt que devinée.
    static let dishes: Set<String> = [
        "stew", "casserole", "gratin", "curry", "chili",
    ]

    /// Le singulier d'un mot, quand le « s » final n'appartient pas au mot.
    ///
    /// « greens » et « baked_goods » sont des catégories du système dont le
    /// « s » fait partie du nom : les tronquer d'office les rendait
    /// introuvables. D'où la retenue.
    static func singular(_ word: String) -> String? {
        guard word.hasSuffix("s"), !word.hasSuffix("ss"), word.count > 3 else { return nil }
        return String(word.dropLast())
    }

    /// Les formes sous lesquelles chercher une étiquette, de la plus fidèle
    /// à la plus permissive.
    ///
    /// L'ordre est la précision : la forme exacte gagne toujours, et les
    /// morceaux ne servent qu'à ce qui n'a pas déjà trouvé. C'est pour cela
    /// que « peanut_butter » peut être du beurre de cacahuète sans que
    /// « butter » vienne d'abord dire « beurre ».
    ///
    /// Les mots sont ensuite essayés **de la fin vers le début** : en
    /// anglais, le nom d'un composé est le dernier mot. « chocolate_chip_
    /// cookie » est un biscuit, pas du chocolat ; « chicken_soup » reste du
    /// poulet parce que « soup » ne mène à rien.
    static func lookupKeys(_ identifier: String) -> [String] {
        let key = normalised(identifier)
        var keys: [String] = [key]
        if let single = singular(key) { keys.append(single) }

        // La même étiquette débarrassée de sa cuisson et de son cadrage.
        let tokens = key.split(separator: "_").map(String.init)
        let meaningful = tokens.filter { !seasoning.contains($0) }
        if meaningful.count != tokens.count, !meaningful.isEmpty {
            let stripped = meaningful.joined(separator: "_")
            keys.append(stripped)
            if let single = singular(stripped) { keys.append(single) }
        }

        // Puis chaque mot pris seul, du dernier au premier.
        for word in meaningful.reversed() {
            keys.append(word)
            if let single = singular(word) { keys.append(single) }
        }

        // Sans doublon, en gardant le premier venu : l'ordre est la règle.
        var seen = Set<String>()
        return keys.filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    /// L'aliment visé par une étiquette, en consultant d'abord ce que
    /// l'athlète a lui-même appris à l'application.
    ///
    /// Les traductions personnelles passent devant la table commune, et sans
    /// discussion : quelqu'un qui a dit une fois que « pastry » est chez lui
    /// une part de gâteau au chocolat en sait plus que n'importe quelle
    /// table écrite d'avance.
    static func food(for identifier: String, corrections: [String: String]) -> String? {
        let full = normalised(identifier)
        for key in lookupKeys(identifier) where key == full || !dishes.contains(key) {
            if let learned = corrections[key], FoodCatalog.food(id: learned) != nil {
                return learned
            }
        }
        return food(for: identifier)
    }

    /// La portion que l'athlète choisit d'habitude pour cet aliment.
    ///
    /// Pourquoi elle existe
    /// --------------------
    /// Tout partait de « Normale », et quelqu'un qui mange systématiquement
    /// deux poings de riz corrigeait la même chose à chaque repas. Ce n'est
    /// pas une devinette : c'est son propre historique qu'on lui rend. Il
    /// faut deux assiettes d'accord pour qu'elle parle — une seule fois ne
    /// fait pas une habitude, et se tromper de portion coûte plus cher que
    /// de ne rien proposer.
    /// Le poids de l'a priori du plan : 20 % de mieux pour un aliment
    /// attendu. Assez pour départager deux notes proches, pas assez pour
    /// renverser une reconnaissance nette.
    public static let planPrior: Double = 1.2

    public static func preferredPortion(
        for foodID: String,
        in plates: [PlateEstimate],
        minimumTimes: Int = 2
    ) -> PortionSize? {
        var counts: [PortionSize: Int] = [:]
        for plate in plates {
            for item in plate.items where item.foodID == foodID {
                counts[item.portion, default: 0] += 1
            }
        }
        guard let best = counts.max(by: { left, right in
            // À égalité, la plus grosse portion gagne : sous-estimer ses
            // protéines est l'erreur qui coûte le plus cher à quelqu'un qui
            // s'entraîne.
            left.value == right.value
                ? left.key.factor < right.key.factor
                : left.value < right.value
        }), best.value >= minimumTimes else { return nil }
        return best.key
    }

    /// Tout ce qu'une photo a donné, traduit.
    ///
    /// Ce que cette fonction fait de plus que l'ancienne
    /// ------------------------------------------------
    /// 1. elle rend **tout** ce qui a été vu, y compris ce qu'elle ne sait
    ///    pas traduire — un écran ne peut pas montrer ce qu'on lui a caché ;
    /// 2. elle fusionne les étiquettes qui désignent le même aliment et
    ///    compte leur accord : deux regards indépendants qui disent « poulet »
    ///    valent mieux qu'un seul, et l'ordre de la liste s'en ressent ;
    /// 3. elle consulte les traductions apprises de l'athlète avant la table
    ///    commune ;
    /// 4. elle propose la portion que l'athlète prend d'habitude pour cet
    ///    aliment, plutôt que « Normale » pour tout le monde.
    public static func analyse(
        _ readings: [PlateReading],
        excluding excluded: Set<String> = [],
        corrections: [String: String] = [:],
        history: [PlateEstimate] = [],
        expected: Set<String> = [],
        limit: Int = maximumItems
    ) -> PlateAnalysis {
        // Une étiquette peut revenir dans plusieurs zones : on la garde une
        // fois, à sa meilleure note, en mémorisant où elle est apparue.
        var order: [String] = []
        var best: [String: Double] = [:]
        var regions: [String: [PlateRegion]] = [:]
        for reading in readings where reading.confidence >= minimumConfidence {
            let label = normalised(reading.identifier)
            guard !label.isEmpty else { continue }
            if best[label] == nil { order.append(label) }
            best[label] = max(best[label] ?? 0, reading.confidence)
            if !(regions[label] ?? []).contains(reading.region) {
                regions[label, default: []].append(reading.region)
            }
        }

        // Ce que chaque étiquette est devenue.
        var sightings: [PlateSighting] = []
        for label in order {
            let confidence = best[label] ?? 0
            let seen = regions[label] ?? [.whole]
            let outcome: PlateOutcome
            if let foodID = food(for: label, corrections: corrections),
               FoodCatalog.food(id: foodID) != nil {
                outcome = excluded.contains(foodID) ? .refused(foodID) : .food(foodID)
            } else if let role = category(for: label) {
                outcome = .aisle(role)
            } else if scenery.contains(label) {
                // La table, l'assiette et la fourchette ne sont pas le repas.
                // Un mot du décor qui n'a mené à aucun aliment ne mérite ni
                // une ligne ni une proposition d'apprentissage.
                continue
            } else {
                outcome = .unknown
            }
            sightings.append(
                PlateSighting(label: label, confidence: confidence, outcome: outcome, regions: seen)
            )
        }

        // L'accord entre étiquettes et entre zones, pour chaque aliment.
        var support: [String: (confidence: Double, labels: Int, regions: Set<PlateRegion>, rank: Int)] = [:]
        for (index, sighting) in sightings.enumerated() {
            guard case .food(let foodID) = sighting.outcome else { continue }
            var entry = support[foodID] ?? (0, 0, [], index)
            entry.confidence = max(entry.confidence, sighting.confidence)
            entry.labels += 1
            entry.regions.formUnion(sighting.regions)
            support[foodID] = entry
        }

        var ranked: [FusedFood] = []
        for (foodID, entry) in support {
            // Ce n'est pas une probabilité qu'on additionne — les notes du
            // classificateur n'en sont pas. C'est un accord qu'on compte :
            // chaque étiquette de plus et chaque zone de plus qui disent la
            // même chose renforcent la même conviction.
            let agreement: Double = Double(entry.labels + entry.regions.count - 1)
            let boosted: Double = entry.confidence * (1 + 0.3 * (agreement - 1))
            // Le plan du jour comme a priori. Ce qui est dans l'assiette est
            // le plus souvent ce que le plan a prescrit ce jour-là ; quand le
            // classificateur hésite entre deux aliments, celui que le plan
            // attendait passe devant. Un a priori, pas une certitude : il ne
            // fait jamais apparaître un aliment que personne n'a vu, et il
            // ne suffit pas à faire passer un aliment vu de loin devant un
            // aliment vu nettement.
            let prior: Double = expected.contains(foodID) ? planPrior : 1
            ranked.append(FusedFood(foodID: foodID, confidence: min(1, boosted * prior), rank: entry.rank))
        }
        ranked.sort { left, right in
            left.confidence == right.confidence
                ? left.rank < right.rank
                : left.confidence > right.confidence
        }

        let items = ranked.prefix(limit).map { entry in
            PlateItem(
                foodID: entry.foodID,
                portion: preferredPortion(for: entry.foodID, in: history) ?? .medium,
                confidence: entry.confidence
            )
        }

        // Les rayons, dans l'ordre où ils ont été vus. Ils servent quand rien
        // de précis n'a été nommé, et restent affichables même quand des
        // aliments l'ont été : « il y a aussi un légume que je ne sais pas
        // nommer » est une information, pas du bruit.
        var roles: [FoodRole] = []
        for sighting in sightings {
            if case .aisle(let role) = sighting.outcome, !roles.contains(role) {
                roles.append(role)
            }
        }

        return PlateAnalysis(
            items: Array(items),
            roles: roles,
            sightings: sightings.sorted { $0.confidence > $1.confidence }
        )
    }
}
