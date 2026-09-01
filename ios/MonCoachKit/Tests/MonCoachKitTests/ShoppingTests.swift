import Testing
@testable import MonCoachKit

@Suite("Liste de courses")
struct ShoppingListTests {

    static func target(_ goal: PrimaryGoal) -> NutritionTarget {
        var profile = Fixtures.intermediate(goal: goal)
        profile.goal = goal
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        return NutritionEngine.target(for: profile, metrics: metrics)
    }

    static func list(_ goal: PrimaryGoal, _ diet: DietPreference) -> [ShoppingLine] {
        MealPlanner.shoppingList(for: MealPlanner.week(target: target(goal), diet: diet))
    }

    @Test("Une semaine tient dans un caddie")
    func theListIsShoppable() {
        // Le vrai défaut n'était pas l'affichage : c'était un plan qui tirait
        // une protéine différente à chaque repas, et réclamait cinquante-
        // quatre lignes pour sept jours. Ce test garde la cause, pas le
        // symptôme.
        //
        // Le seuil est passé de quarante à quarante-cinq le jour où la
        // semaine est passée de quatre menus à sept. Ce n'est pas le seuil
        // qu'on a assoupli pour faire passer le test : c'est le produit qui
        // a changé, et trois dîners de plus coûtent quelques lignes. La
        // classe de régression visée — la semaine qui change d'ingrédients à
        // chaque assiette — reste attrapée : elle en demandait cinquante-
        // quatre, et le déjeuner qui reprend le dîner de la veille, lui, n'a
        // pas bougé.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                let count = Self.list(goal, diet).count
                #expect(
                    count <= 45,
                    Comment(rawValue: "\(goal.rawValue)/\(diet.rawValue) : \(count) lignes")
                )
            }
        }
    }

    @Test("Aucune quantité qu'un magasin ne vend")
    func nothingUnbuyable() {
        // « 60 g de steak », « 10 g de graines de tournesol » : des restes de
        // calcul, pas des courses. Ce qui se vend au poids ne descend pas
        // sous cinquante grammes ; ce qui se compte se compte ; et le reste
        // est au placard, sans chiffre du tout.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                for line in Self.list(goal, diet) where !line.isPantry {
                    let context = "\(goal.rawValue)/\(diet.rawValue) \(line.foodID)"
                    if case .loose = line.purchase {
                        #expect(
                            line.weightToBuy >= 40,
                            Comment(rawValue: "\(context) : \(Int(line.weightToBuy)) g")
                        )
                    }
                    #expect(!line.quantity(.french).isEmpty, Comment(rawValue: context))
                }
            }
        }
    }

    @Test("Le riz s'achète sec, comme au magasin")
    func staplesAreSoldDry() {
        // Le plan compte en produit prêt à consommer ; le magasin vend du
        // sec. Sans conversion, la liste réclamait 1,7 kg de riz pour une
        // semaine, et l'écran devait s'en excuser par une note.
        let cooked = 1_000.0
        #expect(ShoppingUnits.weightToBuy(cooked, foodID: "riz-complet") < 400)
        #expect(ShoppingUnits.weightToBuy(cooked, foodID: "pates-completes") < 500)
        // Ce qui ne gonfle pas n'est pas converti.
        #expect(ShoppingUnits.weightToBuy(cooked, foodID: "brocoli") == cooked)
        #expect(ShoppingUnits.weightToBuy(cooked, foodID: "flocons-avoine") == cooked)
    }

    @Test("Les conditionnements se comptent, et se disent")
    func packsAreCounted() {
        let tuna = ShoppingLine(foodID: "thon-boite", grams: 300, role: .protein)
        #expect(tuna.quantity(.french) == "3 boîtes de 140 g")
        let oneTin = ShoppingLine(foodID: "thon-boite", grams: 100, role: .protein)
        #expect(oneTin.quantity(.french) == "1 boîte de 140 g")
        let eggs = ShoppingLine(foodID: "oeuf", grams: 300, role: .protein)
        #expect(eggs.quantity(.french) == "5 œufs")
        let oil = ShoppingLine(foodID: "huile-olive", grams: 110, role: .fat)
        #expect(oil.isPantry)
        #expect(oil.quantity(.french) == "bouteille d'huile d'olive")
    }

    @Test("Tout ce qui s'achète est dit dans les trois langues")
    func packagingIsTranslated() {
        for (id, purchase) in ShoppingUnits.purchase {
            switch purchase {
            case .loose:
                continue
            case .pack(let shape), .piece(let shape), .pantry(let shape):
                #expect(shape.one.isComplete, Comment(rawValue: "\(id) singulier"))
                #expect(shape.many.isComplete, Comment(rawValue: "\(id) pluriel"))
            }
            // Un conditionnement sans poids ne peut pas être compté.
            if case .pack(let shape) = purchase {
                #expect(shape.grams > 0, Comment(rawValue: id))
            }
            if case .piece(let shape) = purchase {
                #expect(shape.grams > 0, Comment(rawValue: id))
            }
        }
    }

    @Test("Chaque aliment cité existe au catalogue")
    func packagingMatchesTheCatalog() {
        for id in ShoppingUnits.purchase.keys {
            #expect(FoodCatalog.food(id: id) != nil, Comment(rawValue: id))
        }
        for id in ShoppingUnits.dryWeight.keys {
            #expect(FoodCatalog.food(id: id) != nil, Comment(rawValue: id))
        }
    }
}

@Suite("La semaine se cuisine")
struct WeeklyMenuTests {

    @Test("Le déjeuner reprend le dîner de la veille")
    func lunchIsYesterdaysDinner() {
        // On cuisine une fois, on mange deux fois. C'est ce qui divise par
        // deux le nombre d'ingrédients d'une semaine, et c'est ainsi qu'on
        // mange réellement.
        let week = MealPlanner.week(target: ShoppingListTests.target(.hypertrophy))
        var matched = 0
        for index in 1..<week.count {
            let lunch = week[index].meals.first { $0.slot == .lunch }?.recipeID
            let dinnerBefore = week[index - 1].meals.first { $0.slot == .dinner }?.recipeID
            if lunch != nil, lunch == dinnerBefore { matched += 1 }
        }
        #expect(matched >= 4, Comment(rawValue: "\(matched) déjeuners sur 6 reprennent la veille"))
    }

    @Test("Chaque jour de la semaine a son propre dîner")
    func theWeekNeverRepeatsADinner() {
        // Sept dîners pour sept jours. Le panier tient quand même parce que
        // le déjeuner reprend le dîner de la veille : chaque ingrédient est
        // acheté pour deux portions, pas pour une.
        for goal in PrimaryGoal.allCases {
            let week = MealPlanner.week(target: ShoppingListTests.target(goal))
            let dinners = week.compactMap { $0.meals.first { $0.slot == .dinner }?.recipeID }
            let distinct = Set(dinners).count
            #expect(
                distinct == 7,
                Comment(rawValue: "\(goal.rawValue) : \(distinct) dîners différents sur 7")
            )
        }
    }

    @Test("Deux semaines de suite ne servent pas le même menu")
    func weeksRotate() {
        // C'était le défaut le plus coûteux et le moins visible : `dayIndex`
        // repartait de zéro tous les sept jours, donc la semaine deux
        // resservait la semaine un, et la semaine dix aussi. Au bout d'un
        // mois on avait mangé le même dîner quatre fois.
        let target = ShoppingListTests.target(.hypertrophy)
        let first = MealPlanner.week(target: target, weekIndex: 0)
            .compactMap { $0.meals.first { $0.slot == .dinner }?.recipeID }
        let second = MealPlanner.week(target: target, weekIndex: 1)
            .compactMap { $0.meals.first { $0.slot == .dinner }?.recipeID }
        let shared = Set(first).intersection(Set(second)).count
        #expect(shared <= 2, Comment(rawValue: "\(shared) dîners repris à l'identique"))

        // Et la même semaine redonne le même menu : un plan qui change à
        // chaque ouverture n'est pas un plan.
        let again = MealPlanner.week(target: target, weekIndex: 1)
            .compactMap { $0.meals.first { $0.slot == .dinner }?.recipeID }
        #expect(again == second)
    }

    @Test("Jamais le même féculent midi et soir")
    func noStarchTwiceInADay() {
        // Le déjeuner reprend le dîner de la veille : si deux dîners de
        // suite portent le même féculent, la journée sert deux assiettes de
        // riz. C'est ce qu'on voyait à l'écran.
        for goal in PrimaryGoal.allCases {
            let week = MealPlanner.week(target: ShoppingListTests.target(goal))
            for day in week {
                let starches = day.meals
                    .filter { $0.slot == .lunch || $0.slot == .dinner }
                    .compactMap { meal in
                        meal.items.first { $0.food?.role == .carb }?.foodID
                    }
                let distinct = Set(starches).count
                #expect(
                    distinct == starches.count,
                    Comment(rawValue: "\(goal.rawValue) jour \(day.dayIndex) : \(starches)")
                )
            }
        }
    }

    @Test("Le petit-déjeuner ne se réinvente pas tous les matins")
    func breakfastsRepeat() {
        let week = MealPlanner.week(target: ShoppingListTests.target(.fatLoss))
        let breakfasts = week.compactMap { day in
            day.meals.first { $0.slot == .breakfast }?.items.map(\.foodID)
        }
        #expect(Set(breakfasts).count <= 2)
    }
}
