import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le détecteur montre tout ce qu'il a vu")
struct PlateSightingTests {

    @Test("Ce qui n'est pas traduit est rendu quand même")
    func unknownLabelsSurvive() {
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "chicken", confidence: 0.4),
            PlateReading(identifier: "biryani", confidence: 0.9),
            PlateReading(identifier: "kimchi", confidence: 0.3),
        ])
        // L'ancienne version jetait en silence ce qu'elle ne savait pas
        // traduire : l'athlète ne pouvait pas savoir si le système n'avait
        // rien vu, ou si c'était le catalogue qui ne suivait pas. Un mot
        // d'aliment inconnu reste donc affiché, et proposé à l'apprentissage.
        #expect(analysis.sightings.count == 3)
        #expect(analysis.unknown.map(\.label).sorted() == ["biryani", "kimchi"])
        #expect(analysis.items.map(\.foodID) == ["blanc-de-poulet"])
    }

    @Test("Le décor ne compte pas comme quelque chose qu'on a vu")
    func sceneryIsDropped() {
        // Ce test dit l'inverse du précédent, et ce n'est pas une
        // contradiction : la règle « montre tout » vaut pour les mots
        // d'aliments. La table et la fourchette ne sont pas des aliments mal
        // traduits, ce sont des objets. Les afficher poussait six lignes de
        // décor devant le premier vrai aliment, et pire : l'application
        // proposait de les apprendre. Traduire « wood processed » en aliment
        // aurait sali la table de corrections pour toutes les photos
        // suivantes.
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "structure", confidence: 0.95),
            PlateReading(identifier: "wood processed", confidence: 0.93),
            PlateReading(identifier: "container", confidence: 0.9),
            PlateReading(identifier: "utensil", confidence: 0.88),
            PlateReading(identifier: "tableware", confidence: 0.86),
            PlateReading(identifier: "bottle", confidence: 0.84),
            PlateReading(identifier: "chicken", confidence: 0.4),
        ])
        #expect(analysis.sightings.map(\.label) == ["chicken"])
        #expect(analysis.unknown.isEmpty, "rien de tout cela ne s'apprend")
        #expect(analysis.items.map(\.foodID) == ["blanc-de-poulet"])
    }

    @Test("Une ligne porte le nom de l'aliment dans la langue de l'athlète")
    func sightingsAreNamedInTheAthletesLanguage() {
        // L'écran affichait le mot brut du classificateur en titre, et le nom
        // français en petit sur le côté : une liste anglaise dans une
        // application française, où l'information utile était la plus
        // discrète.
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "chicken_breast", confidence: 0.8),
        ])
        guard let sighting = analysis.sightings.first else {
            Issue.record("le poulet ne se reconnaît plus")
            return
        }
        #expect(sighting.name(in: .french) == "Blanc de poulet")
        #expect(sighting.name(in: .spanish) != sighting.name(in: .french))
        #expect(!sighting.namedBySystem)
        // Le mot du système reste lisible : c'est lui qu'on apprend.
        #expect(sighting.readable == "chicken breast")
    }

    @Test("Un mot inconnu garde le mot du système, sans traduction inventée")
    func unknownWordsKeepTheSystemWord() {
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "biryani", confidence: 0.8),
        ])
        guard let sighting = analysis.sightings.first else {
            Issue.record("le mot inconnu a disparu")
            return
        }
        #expect(sighting.namedBySystem)
        #expect(sighting.name(in: .french) == "biryani")
    }

    @Test("Un aliment écarté du plan est dit, pas caché")
    func refusedFoodsAreNamed() {
        let analysis = PlateVision.analyse(
            [PlateReading(identifier: "peanut", confidence: 0.8)],
            excluding: ["cacahuetes"]
        )
        #expect(analysis.items.isEmpty, "un aliment refusé n'entre pas dans l'assiette")
        #expect(analysis.refused.map(\.label) == ["peanut"])
        // Taire l'arachide serait le pire des silences pour un allergique :
        // il croirait que la photo ne l'a pas vue.
        if case .refused(let foodID) = analysis.refused.first?.outcome {
            #expect(foodID == "cacahuetes")
        } else {
            Issue.record("l'aliment refusé doit rester nommé")
        }
    }

    @Test("Tout est trié du plus sûr au moins sûr")
    func sightingsAreSortedByConfidence() throws {
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "rice", confidence: 0.2),
            // Un mot d'aliment que le catalogue ne connaît pas : il tient la
            // tête de liste par sa note. « napkin » faisait le même office
            // avant que la serviette ne soit reconnue pour ce qu'elle est —
            // du décor, et donc écartée.
            PlateReading(identifier: "biryani", confidence: 0.9),
            PlateReading(identifier: "steak", confidence: 0.5),
        ])
        let confidences = analysis.sightings.map(\.confidence)
        #expect(confidences == confidences.sorted(by: >))
        #expect(analysis.sightings.first?.label == "biryani")
    }

    @Test("Le mot du système se lit sans souligné")
    func labelsAreReadable() {
        let sighting = PlateSighting(label: "chocolate_chip_cookie", confidence: 0.3, outcome: .unknown)
        #expect(sighting.readable == "chocolate chip cookie")
    }
}

@Suite("Regarder l'assiette par morceaux")
struct PlateRegionTests {

    @Test("Deux zones qui disent la même chose renforcent la conviction")
    func agreementRaisesConfidence() throws {
        let alone = PlateVision.analyse([
            PlateReading(identifier: "broccoli", confidence: 0.3, region: .whole),
        ])
        let agreed = PlateVision.analyse([
            PlateReading(identifier: "broccoli", confidence: 0.3, region: .whole),
            PlateReading(identifier: "broccoli", confidence: 0.3, region: .topLeft),
        ])
        let single = try #require(alone.items.first?.confidence)
        let double = try #require(agreed.items.first?.confidence)
        #expect(double > single, "vu deux fois vaut mieux que vu une fois")
        #expect(agreed.items.count == 1, "le même brocoli ne se compte pas deux fois")
    }

    @Test("Le quart d'assiette rattrape ce que l'image entière écrasait")
    func quadrantsRescueSmallFoods() throws {
        // Le cas réel : une assiette où le riz occupe la place et le poulet
        // le quart en haut à droite. Sur l'image entière, seul le riz sort.
        let wholeOnly = PlateVision.analyse([
            PlateReading(identifier: "rice", confidence: 0.30, region: .whole),
        ])
        #expect(wholeOnly.items.map(\.foodID) == ["riz-blanc"], "le poulet n'existe pas encore")

        let quartered = PlateVision.analyse([
            PlateReading(identifier: "rice", confidence: 0.30, region: .whole),
            PlateReading(identifier: "chicken", confidence: 0.22, region: .topRight),
            PlateReading(identifier: "chicken", confidence: 0.20, region: .centre),
            PlateReading(identifier: "chicken", confidence: 0.18, region: .bottomRight),
        ])
        let chicken = try #require(quartered.items.first { $0.foodID == "blanc-de-poulet" })
        let rice = try #require(quartered.items.first { $0.foodID == "riz-blanc" })
        // Trois zones d'accord contre un seul regard : le poulet passe
        // devant, alors qu'il sortait plus bas de chaque regard pris à part.
        #expect((chicken.confidence ?? 0) > (rice.confidence ?? 0))
    }

    @Test("Les zones où un aliment a été vu sont conservées")
    func regionsAreRemembered() throws {
        let analysis = PlateVision.analyse([
            PlateReading(identifier: "salmon", confidence: 0.4, region: .bottomLeft),
            PlateReading(identifier: "salmon", confidence: 0.2, region: .whole),
        ])
        let sighting = try #require(analysis.sightings.first { $0.label == "salmon" })
        #expect(sighting.regions == [.bottomLeft, .whole])
        #expect(sighting.confidence == 0.4, "on garde la meilleure note, pas la dernière")
    }
}

@Suite("Les mots composés du classificateur")
struct PlateLookupTests {

    @Test("La cuisson et le cadrage ne cachent plus l'aliment")
    func seasoningIsStripped() {
        #expect(PlateVision.food(for: "grilled_salmon") == "saumon")
        #expect(PlateVision.food(for: "plate_of_pasta") == "pates-completes")
        #expect(PlateVision.food(for: "close_up_of_a_hamburger") == "burger")
        #expect(PlateVision.food(for: "homemade_pizza") == "pizza-surgelee")
        #expect(PlateVision.food(for: "bowl_of_rice") == "riz-blanc")
    }

    @Test("Le premier mot compte aussi quand le dernier ne dit rien")
    func headWordsAreTried() {
        // « salmon_fillet » échouait : seul le dernier mot était essayé, et
        // « fillet » ne menait nulle part à l'époque. Un saumon entier
        // disparaissait pour un suffixe.
        #expect(PlateVision.food(for: "salmon_fillet") == "saumon")
        #expect(PlateVision.food(for: "chicken_soup") == "blanc-de-poulet")
        #expect(PlateVision.food(for: "chicken_curry") == "blanc-de-poulet")
        // Employé seul, le mot du plat vaut de nouveau.
        #expect(PlateVision.food(for: "curry") == "riz-basmati")
        // Et l'inverse reste vrai là où le plat compte plus que l'ingrédient.
        #expect(PlateVision.food(for: "carrot_cake") == "gateau-chocolat")
        #expect(PlateVision.food(for: "tomato_salad") != nil)
    }

    @Test("La forme exacte passe toujours devant les morceaux")
    func exactFormWins() {
        // Sans cette règle, « peanut_butter » deviendrait du beurre parce que
        // « butter » est un mot connu.
        #expect(PlateVision.food(for: "peanut_butter") == "beurre-cacahuete")
        #expect(PlateVision.food(for: "chocolate_chip_cookie") == "biscuits")
        #expect(PlateVision.food(for: "sweet_potato") == "patate-douce")
    }

    @Test("Les catégories dont le « s » fait partie du nom survivent")
    func pluralsAreHandledCarefully() {
        #expect(PlateVision.category(for: "baked_goods") == .treat)
        #expect(PlateVision.category(for: "greens") == .vegetable)
        #expect(PlateVision.food(for: "cookies") == PlateVision.food(for: "cookie"))
    }

    @Test("Un mot vide ne fabrique pas d'aliment")
    func emptyLabelsFindNothing() {
        #expect(PlateVision.food(for: "") == nil)
        #expect(PlateVision.food(for: "food") == nil, "« nourriture » n'est pas un aliment")
        #expect(PlateVision.analyse([PlateReading(identifier: "", confidence: 0.9)]).sightings.isEmpty)
    }
}

@Suite("Ce que le détecteur apprend de l'athlète")
struct PlateLearningTests {

    @Test("Une traduction apprise passe devant la table commune")
    func learnedLabelsWin() {
        let readings = [PlateReading(identifier: "pastry", confidence: 0.6)]
        #expect(PlateVision.analyse(readings).items.isEmpty)

        let taught = PlateVision.analyse(readings, corrections: ["pastry": "viennoiserie"])
        #expect(taught.items.map(\.foodID) == ["viennoiserie"])
    }

    @Test("Une traduction apprise remplace une correspondance existante")
    func learnedLabelsOverrideTheTable() {
        let readings = [PlateReading(identifier: "curry", confidence: 0.5)]
        #expect(PlateVision.analyse(readings).items.first?.foodID == "riz-basmati")

        let mine = PlateVision.analyse(readings, corrections: ["curry": "riz-complet"])
        #expect(mine.items.first?.foodID == "riz-complet", "chez lui, c'est du riz complet")
    }

    @Test("Une traduction vers un aliment inexistant est ignorée")
    func brokenLearningIsIgnored() {
        let analysis = PlateVision.analyse(
            [PlateReading(identifier: "chicken", confidence: 0.5)],
            corrections: ["chicken": "n-existe-pas"]
        )
        #expect(analysis.items.map(\.foodID) == ["blanc-de-poulet"])
    }
}

@Suite("La portion habituelle")
struct PlatePortionMemoryTests {

    private func plate(_ foodID: String, _ portion: PortionSize) -> PlateEstimate {
        PlateEstimate(items: [PlateItem(foodID: foodID, portion: portion)])
    }

    @Test("Deux fois la même portion font une habitude")
    func repeatedPortionsBecomeTheDefault() {
        let history = [plate("riz-blanc", .large), plate("riz-blanc", .large)]
        #expect(PlateVision.preferredPortion(for: "riz-blanc", in: history) == .large)
    }

    @Test("Une seule fois ne fait pas une habitude")
    func oneOffChoicesDoNotSpeak() {
        #expect(PlateVision.preferredPortion(for: "riz-blanc", in: [plate("riz-blanc", .double)]) == nil)
    }

    @Test("À égalité, la plus grosse portion gagne")
    func tiesFavourTheLargerPortion() {
        let history = [
            plate("steak", .medium), plate("steak", .medium),
            plate("steak", .large), plate("steak", .large),
        ]
        // Sous-estimer ses protéines coûte plus cher à quelqu'un qui
        // s'entraîne que les surestimer d'une demi-paume.
        #expect(PlateVision.preferredPortion(for: "steak", in: history) == .large)
    }

    @Test("L'assiette proposée reprend la portion habituelle")
    func analysisUsesTheHabit() {
        let history = [plate("riz-blanc", .double), plate("riz-blanc", .double)]
        let analysis = PlateVision.analyse(
            [PlateReading(identifier: "rice", confidence: 0.5),
             PlateReading(identifier: "chicken", confidence: 0.4)],
            history: history
        )
        #expect(analysis.items.first { $0.foodID == "riz-blanc" }?.portion == .double)
        // Ce qui n'a pas d'habitude reste à « Normale » : on ne devine pas.
        #expect(analysis.items.first { $0.foodID == "blanc-de-poulet" }?.portion == .medium)
    }
}

@Suite("Le vocabulaire du détecteur")
struct PlateVocabularySizeTests {

    @Test("La table est assez large pour une assiette de tous les jours")
    func tableIsWideEnough() {
        // Elle est passée de 140 à plus du double : ce sont les mots des
        // plats — « carbonara », « poke_bowl », « shawarma » — et ceux de la
        // boucherie, qui manquaient tous. Un chiffre ici tient lieu de
        // garde-fou : personne ne réduit une table par accident.
        #expect(
            PlateVision.mapping.count >= 300,
            Comment(rawValue: "\(PlateVision.mapping.count) mots seulement")
        )
    }

    @Test("Les plats du quotidien trouvent tous un aliment")
    func everydayDishesResolve() {
        let everyday = [
            "carbonara", "poke_bowl", "shawarma", "falafel", "gnocchi",
            "smoked_salmon", "greek_yogurt", "peanut_butter", "granola",
            "chicken_thigh", "pork_chop", "scallop", "clementine", "pecan",
            "cheddar", "oat_milk", "croissant", "orange_juice", "sparkling_water",
        ]
        var missing: [String] = []
        for label in everyday where PlateVision.food(for: label) == nil {
            missing.append(label)
        }
        #expect(missing.isEmpty, Comment(rawValue: "sans aliment : \(missing)"))
    }

    @Test("Ce qui n'est pas de la nourriture ne devient pas un aliment")
    func nonFoodStaysNonFood() {
        // Le classificateur nomme la table, la nappe et les couverts avec
        // une belle assurance. Leur inventer un aliment enregistrerait des
        // protéines que personne n'a mangées.
        for label in ["tablecloth", "cutlery", "napkin", "chair", "smartphone"] {
            #expect(PlateVision.food(for: label) == nil, Comment(rawValue: label))
            #expect(PlateVision.category(for: label) == nil, Comment(rawValue: label))
        }
    }
}

@Suite("Les mots appris survivent à la fermeture")
@MainActor
struct PlateMemoryPersistenceTests {

    private func makeStorage() -> StateStorage {
        StateStorage(url: URL.temporaryDirectory.appending(path: "mon-coach-plate-\(UUID().uuidString).json"))
    }

    @Test("Un mot appris se retrouve au lancement suivant")
    func learnedWordsPersist() {
        let storage = makeStorage()
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        store.learnPlateLabel("Pastry", as: "viennoiserie")
        // Mis à plat en passant : le classificateur écrit « Pastry », la
        // photo suivante dira peut-être « pastry ».
        #expect(store.plateCorrections["pastry"] == "viennoiserie")

        let reopened = CoachStore(storage: storage)
        #expect(reopened.plateCorrections["pastry"] == "viennoiserie")
        #expect(reopened.analysePlate([PlateReading(identifier: "pastry", confidence: 0.4)])
            .items.map(\.foodID) == ["viennoiserie"])
    }

    @Test("Un mot appris s'oublie")
    func learnedWordsCanBeForgotten() {
        let storage = makeStorage()
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        store.learnPlateLabel("pastry", as: "viennoiserie")
        store.forgetPlateLabel("pastry")
        #expect(store.plateCorrections.isEmpty)
        #expect(CoachStore(storage: storage).plateCorrections.isEmpty)
    }

    @Test("On n'apprend pas un aliment qui n'existe pas")
    func brokenLearningIsRefused() {
        let storage = makeStorage()
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        store.learnPlateLabel("pastry", as: "n-existe-pas")
        store.learnPlateLabel("", as: "viennoiserie")
        #expect(store.plateCorrections.isEmpty)
    }

    @Test("Une assiette enregistrée se corrige sans être refaite")
    func platesCanBeCorrected() throws {
        let storage = makeStorage()
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        let saved = store.recordPlate(PlateEstimate(items: [PlateItem(foodID: "riz-blanc")]))
        store.updatePlate(
            at: saved.date,
            items: [PlateItem(foodID: "riz-blanc"), PlateItem(foodID: "blanc-de-poulet")]
        )
        let reopened = CoachStore(storage: storage)
        let plate = try #require(reopened.plates(on: saved.date).first)
        #expect(plate.items.map(\.foodID) == ["riz-blanc", "blanc-de-poulet"])
        // La photo n'a pas bougé : c'est tout l'intérêt de corriger plutôt
        // que de supprimer et refaire.
        #expect(plate.photoID == saved.photoID)
    }

    @Test("L'historique récent nourrit la portion proposée")
    func recentPlatesFeedThePortion() {
        let storage = makeStorage()
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        store.recordPlate(PlateEstimate(items: [PlateItem(foodID: "riz-blanc", portion: .large)]))
        store.recordPlate(PlateEstimate(items: [PlateItem(foodID: "riz-blanc", portion: .large)]))

        let analysis = store.analysePlate([PlateReading(identifier: "rice", confidence: 0.4)])
        #expect(analysis.items.first?.portion == .large)
    }
}


@Suite("Le plan du jour comme a priori de l'assiette")
struct PlatePriorTests {

    @Test("À notes égales, l'aliment que le plan attendait passe devant")
    func expectedFoodWinsTies() {
        let readings = [
            PlateReading(identifier: "rice", confidence: 0.5),
            PlateReading(identifier: "chicken", confidence: 0.5),
        ]
        let plain = PlateVision.analyse(readings)
        guard let chicken = plain.items.first(where: { $0.foodID.contains("poulet") })?.foodID,
              let rice = plain.items.first(where: { $0.foodID.contains("riz") })?.foodID
        else {
            Issue.record("les étiquettes de départ ne se reconnaissent plus : \(plain.items.map(\.foodID))")
            return
        }
        let withRice = PlateVision.analyse(readings, expected: [rice])
        #expect(withRice.items.first?.foodID == rice)
        let withChicken = PlateVision.analyse(readings, expected: [chicken])
        #expect(withChicken.items.first?.foodID == chicken)
    }

    @Test("L'a priori ne fait pas apparaître un aliment que personne n'a vu")
    func priorNeverInventsFood() {
        let readings = [PlateReading(identifier: "rice", confidence: 0.5)]
        let analysis = PlateVision.analyse(readings, expected: ["saumon", "poulet", "oeuf"])
        #expect(analysis.items.count == 1)
        #expect(analysis.items.first?.foodID.contains("riz") == true)
    }

    @Test("L'a priori ne renverse pas une reconnaissance nette")
    func priorDoesNotOverturnAClearSighting() {
        let readings = [
            PlateReading(identifier: "chicken", confidence: 0.9),
            PlateReading(identifier: "rice", confidence: 0.4),
        ]
        let plain = PlateVision.analyse(readings)
        guard let rice = plain.items.first(where: { $0.foodID.contains("riz") })?.foodID else {
            Issue.record("le riz ne se reconnaît plus")
            return
        }
        let boosted = PlateVision.analyse(readings, expected: [rice])
        #expect(boosted.items.first?.foodID.contains("poulet") == true)
        #expect(PlateVision.planPrior < 1.5)
    }
}
