import Testing
@testable import MonCoachKit

@Suite("Plats")
struct RecipeCatalogTests {

    @Test("Chaque plat ne cite que des aliments qui existent")
    func foodsResolve() {
        for recipe in RecipeCatalog.all {
            #expect(recipe.foods != nil, Comment(rawValue: "\(recipe.id) cite un aliment inconnu"))
        }
    }

    @Test("Les identifiants sont uniques")
    func idsAreUnique() {
        #expect(Set(RecipeCatalog.all.map(\.id)).count == RecipeCatalog.all.count)
    }

    @Test("Rien d'occasionnel n'est proposé comme ordinaire")
    func nothingOccasional() {
        for recipe in RecipeCatalog.all {
            #expect(recipe.tier < .occasional, Comment(rawValue: recipe.id))
        }
    }

    @Test("Un plat principal porte exactement deux légumes")
    func mainsCarryTwoVegetables() {
        for recipe in RecipeCatalog.all where !recipe.slots.isDisjoint(with: [.lunch, .dinner]) {
            let vegetables = recipe.extraIDs.compactMap { FoodCatalog.food(id: $0) }
                .filter { $0.role == .vegetable }
            #expect(vegetables.count == 2, Comment(rawValue: "\(recipe.id) : \(recipe.extraIDs)"))
        }
    }

    @Test("Un petit-déjeuner porte un fruit, et se mange au réveil")
    func breakfastsAreBreakfasts() {
        for recipe in RecipeCatalog.all where recipe.slots.contains(.breakfast) {
            let fruits = recipe.extraIDs.compactMap { FoodCatalog.food(id: $0) }
                .filter { $0.role == .fruit }
            #expect(fruits.count == 1, Comment(rawValue: "\(recipe.id) : \(recipe.extraIDs)"))
            // Les mêmes réserves que l'assiette composée : un dîner de
            // lentilles au réveil serait juste sur le papier et intenable.
            #expect(
                MealPlanner.breakfastProteins.contains(recipe.proteinID),
                Comment(rawValue: "\(recipe.id) : protéine \(recipe.proteinID)")
            )
            #expect(
                MealPlanner.breakfastCarbs.contains(recipe.carbID),
                Comment(rawValue: "\(recipe.id) : féculent \(recipe.carbID)")
            )
        }
    }

    @Test("Le féculent d'un plat principal ne mange pas la place des protéines")
    func mainsUseMainCarbs() {
        // La même règle que pour l'assiette composée, et pour la même raison :
        // un féculent à 13 g de protéines aux 100 g couvre à lui seul les
        // protéines du dîner, et le solveur supprime la source protéique.
        for recipe in RecipeCatalog.all where !recipe.slots.isDisjoint(with: [.lunch, .dinner]) {
            #expect(
                MealPlanner.mainCarbs.contains(recipe.carbID),
                Comment(rawValue: "\(recipe.id) : \(recipe.carbID)")
            )
        }
    }

    @Test("Tout est dit dans les trois langues")
    func everythingIsTranslated() {
        for recipe in RecipeCatalog.all {
            #expect(recipe.name.isComplete, Comment(rawValue: "nom de \(recipe.id)"))
            #expect(!recipe.steps.isEmpty, Comment(rawValue: "\(recipe.id) sans étapes"))
            for (index, step) in recipe.steps.enumerated() {
                #expect(step.isComplete, Comment(rawValue: "\(recipe.id) étape \(index + 1)"))
            }
        }
    }

    @Test("Le temps annoncé est un temps de cuisine")
    func timesArePlausible() {
        for recipe in RecipeCatalog.all {
            #expect(recipe.minutes > 0 && recipe.minutes <= 60, Comment(rawValue: recipe.id))
            // Un petit-déjeuner au-delà de quinze minutes ne se fait pas un
            // mardi matin, quelles que soient ses qualités.
            if recipe.slots == [.breakfast] {
                #expect(recipe.minutes <= 15, Comment(rawValue: recipe.id))
            }
        }
    }

    @Test("Chaque régime a de quoi manger, matin et soir")
    func everyDietIsServed() {
        for diet in DietPreference.allCases {
            let dinners = RecipeCatalog.available(slot: .dinner, diet: diet)
            let breakfasts = RecipeCatalog.available(slot: .breakfast, diet: diet)
            // Huit dîners au minimum : le menu en retient quatre, et sans
            // marge le choix se réduit aux mêmes plats pour tout le monde.
            #expect(dinners.count >= 8, Comment(rawValue: "\(diet.rawValue) : \(dinners.count) dîners"))
            // Quatre matins au minimum : le menu en retient deux, et il faut
            // de quoi choisir. Les régimes les plus étroits — végétalien,
            // sans gluten — sont ceux qui tombent en premier quand on ajoute
            // des recettes sans y penser.
            #expect(breakfasts.count >= 4, Comment(rawValue: "\(diet.rawValue) : \(breakfasts.count) matins"))
        }
    }

    @Test("Un aliment refusé écarte le plat entier")
    func exclusionsRemoveTheWholeDish() {
        let withSalmon = RecipeCatalog.available(slot: .dinner, diet: .omnivore)
        let without = RecipeCatalog.available(slot: .dinner, diet: .omnivore, excluding: ["saumon"])
        #expect(withSalmon.contains { $0.id == "saumon-patate-douce" })
        #expect(!without.contains { $0.id == "saumon-patate-douce" })
    }
}

@Suite("Plats dans la journée")
struct RecipeInPlanTests {

    static func target(_ goal: PrimaryGoal) -> NutritionTarget {
        var profile = Fixtures.intermediate(goal: goal)
        profile.goal = goal
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        return NutritionEngine.target(for: profile, metrics: metrics)
    }

    @Test("Les vrais repas portent un nom de plat")
    func mealsAreNamed() {
        // La raison d'être de tout ce travail. Sans ce test, une acceptation
        // trop stricte ferait retomber tous les repas sur l'assiette composée
        // sans qu'aucun autre test ne s'en aperçoive : les macros seraient
        // justes, la journée valide, et plus un seul plat nommé.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                let week = MealPlanner.week(target: Self.target(goal), diet: diet)
                let mains = week.flatMap(\.meals).filter { $0.slot == .lunch || $0.slot == .dinner }
                let named = mains.filter { $0.recipeID != nil }
                #expect(
                    named.count >= mains.count / 2,
                    Comment(rawValue: "\(goal.rawValue)/\(diet.rawValue) : \(named.count)/\(mains.count) nommés")
                )
            }
        }
    }

    @Test("Le plat nommé est bien celui qu'on a servi")
    func namedMealsMatchTheirRecipe() {
        let week = MealPlanner.week(target: Self.target(.hypertrophy))
        for meal in week.flatMap(\.meals) {
            guard let recipe = meal.recipe else { continue }
            // Un sous-ensemble, pas une égalité : le solveur peut ramener un
            // aliment à zéro gramme — une cuillère d'huile dans un repas déjà
            // au plafond lipidique — et le plat reste ce plat. Ce qui ne peut
            // pas disparaître, c'est ce qui le définit.
            #expect(
                Set(meal.items.map(\.foodID)).isSubset(of: Set(recipe.foodIDs)),
                Comment(rawValue: "\(recipe.id) : \(meal.items.map(\.foodID))")
            )
            #expect(
                meal.items.contains { $0.foodID == recipe.proteinID },
                Comment(rawValue: "\(recipe.id) sans sa protéine")
            )
        }
    }

    @Test("La semaine ne sert pas deux fois le même dîner")
    func dinnersVary() {
        let week = MealPlanner.week(target: Self.target(.hypertrophy))
        let dinners = week.compactMap { day in day.meals.first { $0.slot == .dinner } }
        #expect(Set(dinners.compactMap(\.recipeID)).count >= 4)
    }

    @Test("Le même jour redonne toujours le même plat")
    func dishesAreDeterministic() {
        let target = Self.target(.recomposition)
        let first = MealPlanner.day(target: target, diet: .vegan, dayIndex: 5)
        let second = MealPlanner.day(target: target, diet: .vegan, dayIndex: 5)
        #expect(first.meals.map(\.recipeID) == second.meals.map(\.recipeID))
    }

    @Test("Un en-cas n'est pas une recette")
    func snacksStayFoods() {
        let week = MealPlanner.week(target: Self.target(.fatLoss), mealsPerDay: 5)
        for meal in week.flatMap(\.meals) where meal.slot == .snack || meal.slot == .preWorkout {
            #expect(meal.recipeID == nil, Comment(rawValue: meal.slot.rawValue))
        }
    }
}
