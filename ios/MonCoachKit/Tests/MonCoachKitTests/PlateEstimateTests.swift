import Foundation
import Testing
@testable import MonCoachKit

@Suite("L'assiette en photo")
struct PlateEstimateTests {

    @Test("Chaque aliment de la table existe vraiment au catalogue")
    func mappingPointsSomewhere() {
        var missing: [String] = []
        for (identifier, foodID) in PlateVision.mapping where FoodCatalog.food(id: foodID) == nil {
            missing.append("\(identifier) → \(foodID)")
        }
        #expect(missing.isEmpty, Comment(rawValue: "correspondances mortes : \(missing.sorted())"))
        #expect(PlateVision.mapping.count >= 60, "une table trop courte ne reconnaîtra presque rien")
    }
}

@Suite("Estimation d'une assiette")
struct PlateMathTests {

    @Test("Les propositions du système deviennent des aliments, dans l'ordre")
    func observationsBecomeFoods() {
        let items = PlateVision.foods(from: [
            ("chicken", 0.42),
            ("rice", 0.21),
            // Sous le seuil : le bas de liste d'un classificateur qui note
            // mille catégories est du bruit, et une banane à 2 % n'a rien à
            // faire dans l'assiette.
            ("banana", 0.02),
            // Inconnu de la table : on ne devine pas.
            ("tablecloth", 0.95),
        ])
        #expect(items.map(\.foodID) == ["blanc-de-poulet", "riz-blanc"])
        #expect(items.first?.confidence == 0.42)
        #expect(items.allSatisfy { $0.portion == .medium })
    }

    @Test("Un même aliment proposé deux fois n'est compté qu'une")
    func duplicatesCollapse() {
        let items = PlateVision.foods(from: [
            ("rice", 0.7), ("fried_rice", 0.5), ("risotto", 0.4),
        ])
        #expect(items.count == 1, "trois façons de dire « riz » font un seul riz dans l'assiette")
    }

    @Test("Un aliment refusé n'est pas proposé")
    func excludedFoodsStayOut() {
        let items = PlateVision.foods(
            from: [("chicken", 0.9), ("rice", 0.8)],
            excluding: ["blanc-de-poulet"]
        )
        #expect(items.map(\.foodID) == ["riz-blanc"])
    }

    @Test("La liste s'arrête avant de devenir un inventaire")
    func listIsCapped() {
        let many: [(identifier: String, confidence: Double)] = [
            ("chicken", 0.9), ("rice", 0.85), ("broccoli", 0.8), ("carrot", 0.75),
            ("tomato", 0.7), ("avocado", 0.65), ("apple", 0.6),
        ]
        #expect(PlateVision.foods(from: many).count == PlateVision.maximumItems)
    }

    @Test("La portion change les grammes, et les grammes se pèsent")
    func portionsScale() {
        let normal = PlateItem(foodID: "blanc-de-poulet", portion: .medium)
        let big = PlateItem(foodID: "blanc-de-poulet", portion: .double)
        #expect(big.grams == normal.grams * 2)
        #expect(big.macros.proteinG > normal.macros.proteinG)
        // Des quantités pesables : personne ne sert 137 g.
        #expect(normal.grams.truncatingRemainder(dividingBy: 5) == 0)
        // Un aliment inconnu ne fabrique pas de protéines.
        #expect(PlateItem(foodID: "n-existe-pas").grams == 0)
        #expect(PlateItem(foodID: "n-existe-pas").macros == Macros.zero)
    }

    @Test("L'estimation additionne l'assiette et annonce sa marge")
    func estimateSumsAndDoubts() {
        let guessed = PlateEstimate(items: [
            PlateItem(foodID: "blanc-de-poulet", portion: .medium, confidence: 0.8),
            PlateItem(foodID: "riz-blanc", portion: .large, confidence: 0.6),
        ])
        #expect(guessed.proteinG > 25, "une paume de poulet porte plus de 25 g")
        #expect(guessed.calories > 0)
        // Tout deviné : la marge est la plus large.
        #expect(guessed.uncertaintyPercent == 35)
        #expect(guessed.proteinRangeG.contains(Int(guessed.proteinG.rounded())))
        #expect(guessed.proteinRangeG.lowerBound < guessed.proteinRangeG.upperBound)

        // Tout confirmé par l'athlète : seule la quantité reste incertaine.
        let confirmed = PlateEstimate(items: [
            PlateItem(foodID: "blanc-de-poulet", portion: .medium),
            PlateItem(foodID: "riz-blanc", portion: .large),
        ])
        #expect(confirmed.uncertaintyPercent == 20)
        #expect(confirmed.macros == guessed.macros, "confirmer ne change pas ce qu'il y a dans l'assiette")

        // Une assiette vide ne prétend à aucune marge.
        #expect(PlateEstimate(items: []).uncertaintyPercent == 0)
        #expect(PlateEstimate(items: []).proteinG == 0)
    }

    @MainActor
    @Test("Le magasin garde les assiettes, et ne perd pas leurs photos")
    func storeKeepsPlates() throws {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-plates-\(UUID().uuidString).json")
        )
        let photos = PhotoStore(
            directory: URL.temporaryDirectory.appending(path: "stride-plate-photos-\(UUID().uuidString)")
        )
        defer {
            try? FileManager.default.removeItem(at: storage.url)
            try? FileManager.default.removeItem(at: photos.directory)
        }
        let store = CoachStore(storage: storage, photos: photos)
        let day = Date()
        let saved = store.recordPlate(
            PlateEstimate(
                items: [PlateItem(foodID: "blanc-de-poulet", portion: .medium)],
                date: day
            ),
            photo: Data([0x01, 0x02, 0x03])
        )
        #expect(saved.photoID != nil)
        #expect(store.plates(on: day).count == 1)
        #expect((store.eatenToday(on: day)?.proteinG ?? 0) > 25)

        // Le ménage des photos ne doit pas emporter celle de l'assiette :
        // aucune sortie ne la réclame, et elle doit rester.
        #expect(store.prunePhotos() == 0)
        #expect(store.plates(on: day).first?.photoID == saved.photoID)

        store.deletePlate(at: day)
        #expect(store.plates(on: day).isEmpty)
        #expect(store.eatenToday(on: day) == nil, "sans assiette, on ne sait pas — on ne dit pas zéro")
    }
}

@Suite("Ce que le classificateur dit vraiment")
struct PlateVocabularyTests {

    @Test("Les formes du système sont ramenées à une seule")
    func identifiersAreNormalised() {
        // Le système écrit selon les catégories : majuscules, espaces,
        // tirets, pluriels. Sans mise à plat, la moitié de ce qu'il propose
        // ne serait pas reconnue.
        #expect(PlateVision.food(for: "Cookie") != nil)
        #expect(PlateVision.food(for: "bell pepper") == PlateVision.food(for: "bell_pepper"))
        #expect(PlateVision.food(for: "cookies") == PlateVision.food(for: "cookie"))
        // Des frites sont des frites depuis que le catalogue les porte : les
        // rendre en « pomme de terre » sous-comptait la moitié des calories.
        #expect(PlateVision.food(for: "french-fries") == "frites")
        // Le dernier mot d'un composé porte le sens.
        #expect(PlateVision.food(for: "grilled_chicken") == "blanc-de-poulet")
        #expect(PlateVision.food(for: "chocolate_chip_cookie") != nil)
    }

    @Test("Les mots des photos réelles trouvent un aliment")
    func realWorldLabelsResolve() {
        // Ceux-là viennent d'assiettes qui n'avaient rien donné : une
        // entrecôte avec des grenailles et de la salade, des cookies, des
        // carottes rôties. Le seuil était trop haut, et ces mots-là
        // manquaient à la table.
        let expected = [
            "steak", "beefsteak", "roast_beef", "new_potato", "roast_potato",
            "green_salad", "lettuce", "cookie", "biscuit", "carrot",
            "roasted_carrot", "burrata", "mozzarella",
        ]
        for label in expected {
            #expect(
                PlateVision.food(for: label) != nil,
                Comment(rawValue: "« \(label) » ne mène à aucun aliment")
            )
        }
    }

    @Test("Une famille reconnue vaut mieux qu'un écran vide")
    func categoriesGiveARole() {
        // Le système décrit souvent par catégorie avant de nommer quoi que
        // ce soit. « De la viande et un dessert » n'est pas une assiette
        // chiffrée, mais c'est la bonne page du catalogue.
        #expect(PlateVision.category(for: "meat") == .protein)
        #expect(PlateVision.category(for: "Dessert") == .treat)
        #expect(PlateVision.category(for: "baked_goods") == .treat)
        #expect(PlateVision.category(for: "vegetables") == .vegetable)
        #expect(PlateVision.category(for: "chair") == nil, "un meuble n'est pas un rayon")

        let roles = PlateVision.roles(from: [
            ("meat", 0.4), ("dessert", 0.2), ("furniture", 0.9), ("tablecloth", 0.3),
        ])
        #expect(roles == [.protein, .treat])

        // Sous le seuil, rien : le bruit ne fabrique pas de rayon.
        #expect(PlateVision.roles(from: [("meat", 0.01)]).isEmpty)
    }

    @Test("La table couvre largement ce qu'on mange")
    func vocabularyIsWideEnough() {
        #expect(PlateVision.mapping.count >= 140, "\(PlateVision.mapping.count) mots : trop court")
        #expect(PlateVision.categories.count >= 30)
        // Et chaque rayon du catalogue a au moins un mot qui y mène.
        for role in FoodRole.allCases {
            #expect(
                PlateVision.categories.values.contains(role),
                Comment(rawValue: "aucun mot ne mène au rayon \(role.rawValue)")
            )
        }
    }
}
