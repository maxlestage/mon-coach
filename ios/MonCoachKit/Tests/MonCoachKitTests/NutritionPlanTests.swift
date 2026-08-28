import Foundation
import Testing
@testable import MonCoachKit

@Suite("Catalogue d'aliments")
struct FoodCatalogTests {

    @Test("Chaque aliment est traduit et justifié")
    func everyFoodIsComplete() {
        for food in FoodCatalog.all {
            #expect(food.name.isComplete, Comment(rawValue: "nom incomplet : \(food.id)"))
            #expect(food.reason.isComplete, Comment(rawValue: "raison incomplète : \(food.id)"))
            #expect(!food.diets.isEmpty, Comment(rawValue: "aucun régime : \(food.id)"))
            #expect(food.portionG > 0, Comment(rawValue: "portion nulle : \(food.id)"))
        }
        for tier in FoodTier.allCases {
            #expect(tier.label.isComplete)
            #expect(tier.guidance.isComplete)
        }
        for role in FoodRole.allCases { #expect(role.label.isComplete) }
        for slot in MealSlot.allCases { #expect(slot.label.isComplete) }
    }

    @Test("Aucun identifiant en double")
    func idsAreUnique() {
        let ids = FoodCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Les macros annoncées correspondent aux calories annoncées")
    func macrosMatchCalories() {
        for food in FoodCatalog.all where food.kcal > 20 {
            // Facteurs d'Atwater. Les fibres apportent moins que 4 kcal/g, donc
            // la somme dépasse toujours un peu l'énergie réelle des aliments
            // riches en fibres : la tolérance en tient compte.
            let sum = food.proteinG * 4 + food.carbsG * 4 + food.fatG * 9 + food.alcoholG * 7
            let drift = (sum - food.kcal) / food.kcal
            #expect(drift > -0.20 && drift < 0.30, Comment(rawValue: "\(food.id) : \(Int(drift * 100)) %"))
        }
    }

    @Test("Les régimes sont cohérents entre eux")
    func dietsAreConsistent() {
        // Ce qui convient à un végétalien convient à un végétarien.
        for food in FoodCatalog.all where food.suits(.vegan) {
            #expect(food.suits(.vegetarian), Comment(rawValue: food.id))
            #expect(food.suits(.pescatarian), Comment(rawValue: food.id))
            #expect(food.suits(.omnivore), Comment(rawValue: food.id))
        }
        // Un poisson n'est pas végétarien, une viande n'est pas pescétarienne.
        #expect(FoodCatalog.food(id: "saumon")?.suits(.vegetarian) == false)
        #expect(FoodCatalog.food(id: "blanc-de-poulet")?.suits(.pescatarian) == false)
        #expect(FoodCatalog.food(id: "porc-filet")?.suits(.halal) == false)
        #expect(FoodCatalog.food(id: "seitan")?.suits(.glutenFree) == false)
        #expect(FoodCatalog.food(id: "pain-complet")?.suits(.glutenFree) == false)
    }

    @Test("Chaque régime laisse de quoi construire une journée")
    func everyDietHasEnoughFood() {
        for diet in DietPreference.allCases {
            for role in [FoodRole.protein, .carb, .vegetable, .fruit, .fat] {
                let available = FoodCatalog.available(diet: diet, roles: [role], maximumTier: .moderate)
                #expect(available.count >= 3, Comment(rawValue: "\(diet.rawValue) / \(role.rawValue) : \(available.count)"))
            }
        }
    }

    @Test("Les rangs s'ordonnent, et le filtre les respecte")
    func tiersOrder() {
        #expect(FoodTier.base < FoodTier.moderate)
        #expect(FoodTier.moderate < FoodTier.occasional)
        let base = FoodCatalog.available(diet: .omnivore, maximumTier: .base)
        #expect(base.allSatisfy { $0.tier == .base })
        #expect(!FoodCatalog.all(tier: .occasional).isEmpty)
    }

    @Test("Un aliment exclu ne ressort jamais")
    func exclusionsHold() {
        let available = FoodCatalog.available(diet: .omnivore, excluding: ["saumon", "oeuf"])
        #expect(!available.contains { $0.id == "saumon" || $0.id == "oeuf" })
    }
}

@Suite("Journée alimentaire")
struct MealPlannerTests {

    static func target(_ goal: PrimaryGoal) -> NutritionTarget {
        var profile = Fixtures.intermediate(goal: goal)
        profile.goal = goal
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        return NutritionEngine.target(for: profile, metrics: metrics)
    }

    @Test("La journée tombe sur ses macros pour chaque objectif et chaque régime")
    func hitsTheTarget() {
        for goal in PrimaryGoal.allCases {
            let target = Self.target(goal)
            for diet in DietPreference.allCases {
                let day = MealPlanner.day(target: target, diet: diet, dayIndex: 3, mealsPerDay: 4)
                let drift = day.drift
                let context = "\(goal.rawValue) / \(diet.rawValue)"
                #expect(abs(drift.kcal) <= 0.08, Comment(rawValue: "\(context) kcal \(Int(drift.kcal * 100)) %"))
                // Douze pour cent et non dix : le plancher de portion peut
                // faire dépasser légèrement sur un objectif à protéines
                // basses. Douze grammes de protéines en trop n'ont aucune
                // conséquence ; trente grammes de poulet dans une assiette, si.
                #expect(abs(drift.proteinG) <= 0.12, Comment(rawValue: "\(context) P \(Int(drift.proteinG * 100)) %"))
                #expect(abs(drift.fatG) <= 0.25, Comment(rawValue: "\(context) L \(Int(drift.fatG * 100)) %"))
                #expect(abs(drift.carbsG) <= 0.20, Comment(rawValue: "\(context) G \(Int(drift.carbsG * 100)) %"))
            }
        }
    }

    @Test("Trois, quatre ou cinq repas : la journée reste juste")
    func anyMealCount() {
        let target = Self.target(.hypertrophy)
        for count in 3...5 {
            let day = MealPlanner.day(target: target, dayIndex: 1, mealsPerDay: count, trainsToday: true)
            #expect(day.meals.count == count)
            #expect(abs(day.drift.kcal) <= 0.08, Comment(rawValue: "\(count) repas"))
            #expect(abs(day.drift.proteinG) <= 0.12, Comment(rawValue: "\(count) repas"))
        }
    }

    @Test("Le nombre de repas est borné plutôt que de produire une journée absurde")
    func mealCountIsClamped() {
        let target = Self.target(.hypertrophy)
        #expect(MealPlanner.day(target: target, mealsPerDay: 1).meals.count == 3)
        #expect(MealPlanner.day(target: target, mealsPerDay: 12).meals.count == 5)
    }

    @Test("Le régime est respecté à la lettre dans chaque assiette")
    func dietIsRespected() {
        for diet in DietPreference.allCases {
            for index in 0..<7 {
                let day = MealPlanner.day(target: Self.target(.fatLoss), diet: diet, dayIndex: index)
                for item in day.meals.flatMap(\.items) {
                    guard let food = item.food else {
                        Issue.record("aliment inconnu : \(item.foodID)")
                        continue
                    }
                    #expect(food.suits(diet), Comment(rawValue: "\(diet.rawValue) : \(food.id)"))
                }
            }
        }
    }

    @Test("Un aliment refusé n'apparaît dans aucun repas de la semaine")
    func exclusionsAreHonoured() {
        let excluded: Set<String> = ["blanc-de-poulet", "oeuf", "riz-blanc", "flocons-avoine", "tofu"]
        let week = MealPlanner.week(target: Self.target(.hypertrophy), excluding: excluded)
        for item in week.flatMap(\.meals).flatMap(\.items) {
            #expect(!excluded.contains(item.foodID), Comment(rawValue: item.foodID))
        }
    }

    @Test("Aucun aliment de rang « occasionnel » n'est prescrit")
    func nothingOccasionalIsPlanned() {
        let week = MealPlanner.week(target: Self.target(.fatLoss))
        for item in week.flatMap(\.meals).flatMap(\.items) {
            #expect(item.food?.tier != .occasional, Comment(rawValue: item.foodID))
        }
    }

    @Test("Chaque repas contient une source de protéines identifiable")
    func everyMealHasProtein() {
        for diet in DietPreference.allCases {
            let day = MealPlanner.day(target: Self.target(.hypertrophy), diet: diet, mealsPerDay: 4)
            for meal in day.meals where meal.slot != .preWorkout {
                #expect(meal.macros.proteinG >= 15, Comment(rawValue: "\(diet.rawValue) / \(meal.slot.rawValue) : \(Int(meal.macros.proteinG)) g"))
            }
        }
    }

    @Test("Les déjeuners et dîners contiennent des légumes")
    func mainMealsHaveVegetables() {
        let day = MealPlanner.day(target: Self.target(.hypertrophy))
        for meal in day.meals where meal.slot == .lunch || meal.slot == .dinner {
            let vegetables = meal.items.filter { $0.food?.role == .vegetable }
            #expect(vegetables.count == 2, Comment(rawValue: meal.slot.rawValue))
        }
    }

    @Test("La semaine ne sert pas sept fois la même chose")
    func theWeekHasVariety() {
        let week = MealPlanner.week(target: Self.target(.hypertrophy))
        let proteins = week.flatMap(\.meals).flatMap(\.items).filter { $0.food?.role == .protein }
        #expect(Set(proteins.map(\.foodID)).count >= 5)
        let dinners = week.compactMap { day in day.meals.first { $0.slot == .dinner } }
        #expect(Set(dinners.map { $0.items.map(\.foodID) }).count >= 4)
    }

    @Test("Le même jour redonne toujours le même plan")
    func planIsDeterministic() {
        let target = Self.target(.recomposition)
        let first = MealPlanner.day(target: target, diet: .halal, dayIndex: 4)
        let second = MealPlanner.day(target: target, diet: .halal, dayIndex: 4)
        #expect(first.meals.map { $0.items } == second.meals.map { $0.items })
    }

    @Test("Aucune portion ne dépasse ce qu'on sert vraiment, correction comprise")
    func portionsArePractical() {
        // La correction calorique s'applique après le solveur : c'est
        // précisément là qu'une portion pouvait franchir son plafond sans que
        // personne ne le voie.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                let week = MealPlanner.week(target: Self.target(goal), diet: diet)
                for item in week.flatMap(\.meals).flatMap(\.items) {
                    guard let food = item.food else { continue }
                    let context = "\(goal.rawValue)/\(diet.rawValue) \(item.foodID) : \(Int(item.grams)) g"
                    #expect(item.grams >= 3, Comment(rawValue: context))
                    #expect(
                        item.grams <= MealPlanner.maximumGrams(for: food),
                        Comment(rawValue: context)
                    )
                    // Aucune assiette de féculent au-delà de 600 kcal.
                    if food.role == .carb {
                        #expect(item.macros.kcal <= 610, Comment(rawValue: context))
                    }
                    let step: Double = food.role == .fat ? 1 : 5
                    #expect(item.grams.truncatingRemainder(dividingBy: step) == 0, Comment(rawValue: context))
                }
            }
        }
    }

    @Test("Une source de protéines n'est jamais servie en portion symbolique")
    func proteinPortionsAreReal() {
        // Trente-cinq grammes de sardines n'est pas une prescription, c'est
        // une garniture. Ce qui compte n'est pas la part des protéines du
        // repas — un porridge au fromage blanc en apporte légitimement autant
        // que le fromage blanc — mais que la portion servie en reste une.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                for index in 0..<7 {
                    let day = MealPlanner.day(target: Self.target(goal), diet: diet, dayIndex: index)
                    for item in day.meals.flatMap(\.items) {
                        guard let food = item.food else { continue }
                        #expect(
                            item.grams >= MealPlanner.minimumGrams(for: food) - 5,
                            Comment(rawValue: "\(goal.rawValue)/\(diet.rawValue) : \(Int(item.grams)) g de \(food.id), portion habituelle \(Int(food.portionG)) g")
                        )
                    }
                }
            }
        }
    }

    @Test("Les fibres restent dans une fourchette tenable, et l'excès est annoncé")
    func fibreStaysReasonable() {
        // Une grosse journée d'aliments entiers dépasse la recommandation, et
        // c'est normal — surtout en végétarien, où les légumineuses portent
        // les protéines. Ce qui ne serait pas normal, c'est de la servir sans
        // le dire, ou de tripler la recommandation.
        for goal in PrimaryGoal.allCases {
            for diet in DietPreference.allCases {
                let day = MealPlanner.day(target: Self.target(goal), diet: diet, dayIndex: 2)
                let recommended = day.target.kcal / 1_000 * 14
                let context = "\(goal.rawValue)/\(diet.rawValue) : \(Int(day.macros.fiberG)) g pour \(Int(recommended)) g"
                #expect(day.macros.fiberG >= recommended * 0.8, Comment(rawValue: context))
                #expect(day.macros.fiberG <= recommended * 2.3, Comment(rawValue: context))

                // Au-delà d'une fois et demie, la journée doit le signaler.
                if day.macros.fiberG > recommended * 1.5 {
                    #expect(
                        day.notes.contains { $0.fr.contains("fibres") && $0.fr.contains("progressivement") },
                        Comment(rawValue: "excès de fibres non signalé — \(context)")
                    )
                }
            }
        }
    }

    @Test("La journée apporte assez de fibres")
    func enoughFibre() {
        for diet in DietPreference.allCases {
            let day = MealPlanner.day(target: Self.target(.fatLoss), diet: diet)
            // 14 g pour 1 000 kcal est la recommandation classique ; on vérifie
            // qu'on n'en est pas loin, sans exiger la perfection.
            let expected = day.target.kcal / 1_000 * 14
            #expect(day.macros.fiberG >= expected * 0.8, Comment(rawValue: "\(diet.rawValue) : \(Int(day.macros.fiberG)) g"))
        }
    }

    @Test("Un jour de course ajoute la consigne d'hydratation et de recharge")
    func runningDayIsCalledOut() {
        let day = MealPlanner.day(target: Self.target(.hypertrophy), runsToday: true)
        #expect(day.notes.contains { $0.fr.contains("500 ml") })
        for note in day.notes { #expect(note.isComplete) }
    }

    @Test("Un régime végétalien reçoit l'avertissement B12")
    func veganWarning() {
        let day = MealPlanner.day(target: Self.target(.hypertrophy), diet: .vegan)
        #expect(day.notes.contains { $0.fr.contains("B12") })
        #expect(day.notes.contains { $0.en.contains("B12") })
        #expect(day.notes.contains { $0.es.contains("B12") })
    }

    @Test("La liste de courses agrège la semaine sans rien perdre")
    func shoppingList() {
        let week = MealPlanner.week(target: Self.target(.hypertrophy))
        let list = MealPlanner.shoppingList(for: week)
        let planned = Set(week.flatMap(\.meals).flatMap(\.items).map(\.foodID))
        #expect(Set(list.map(\.foodID)) == planned)
        #expect(list.allSatisfy { $0.grams > 0 })
        // Les protéines arrivent en tête, les matières grasses en fin de liste.
        #expect(list.first?.role == .protein)
        // Rien n'est compté deux fois.
        #expect(Set(list.map(\.foodID)).count == list.count)
        for line in list {
            let total = week
                .flatMap(\.meals)
                .flatMap(\.items)
                .filter { $0.foodID == line.foodID }
                .reduce(0.0) { $0 + $1.grams }
            #expect(line.grams >= total)
            #expect(line.grams < total + 10)
        }
    }

    @Test("Les macros s'additionnent sans dériver")
    func macrosAddUp() {
        let day = MealPlanner.day(target: Self.target(.hypertrophy))
        let fromItems = day.meals.flatMap(\.items).map(\.macros).total
        #expect(abs(fromItems.kcal - day.macros.kcal) < 0.001)
        #expect(Macros.zero + fromItems == fromItems)
    }
}

@Suite("Guide alimentaire")
struct FoodGuidanceTests {

    @Test("Chaque rayon du guide est rempli et rangé")
    func sectionsAreSound() {
        for diet in DietPreference.allCases {
            let sections = FoodGuidance.sections(diet: diet)
            #expect(sections.count >= 6, Comment(rawValue: diet.rawValue))
            for section in sections {
                #expect(!section.isEmpty)
                #expect(section.base.allSatisfy { $0.tier == .base })
                #expect(section.moderate.allSatisfy { $0.tier == .moderate })
                #expect(section.occasional.allSatisfy { $0.tier == .occasional })
                for food in section.base + section.moderate + section.occasional {
                    #expect(food.suits(diet), Comment(rawValue: "\(diet.rawValue) : \(food.id)"))
                    #expect(food.role == section.role)
                }
            }
        }
    }

    @Test("Les protéines les plus rentables le sont vraiment")
    func leanestProteinsAreOrdered() {
        let leanest = FoodGuidance.leanestProteins()
        #expect(leanest.count == 8)
        for (previous, next) in zip(leanest, leanest.dropFirst()) {
            #expect(previous.proteinPerHundredKcal >= next.proteinPerHundredKcal)
        }
        // Le blanc d'œuf et le cabillaud n'ont pas de concurrent sérieux ici.
        #expect(leanest.prefix(3).contains { $0.id == "cabillaud" || $0.id == "blanc-oeuf" })
    }

    @Test("Les aliments les plus rassasiants sortent en tête")
    func mostFillingAreOrdered() {
        let filling = FoodGuidance.mostFilling()
        #expect(!filling.isEmpty)
        for (previous, next) in zip(filling, filling.dropFirst()) {
            #expect(previous.fiberG / previous.kcal >= next.fiberG / next.kcal)
        }
    }

    @Test("Chaque échange existe, économise des calories ou apporte des protéines")
    func swapsAreReal() {
        for swap in FoodGuidance.swaps {
            #expect(swap.from != nil, Comment(rawValue: swap.fromID))
            #expect(swap.to != nil, Comment(rawValue: swap.toID))
            #expect(swap.reason.isComplete, Comment(rawValue: swap.id))
            #expect(swap.fromGrams > 0 && swap.toGrams > 0)
            // Chaque échange annonce ce qu'il fait gagner ; on vérifie que le
            // catalogue le confirme, sauf pour les échanges de qualité, qui
            // ne prétendent à aucun chiffre.
            let context = Comment(
                rawValue: "\(swap.id) : \(Int(swap.kcalSaved)) kcal, \(Int(swap.proteinGained)) g P, \(Int(swap.fiberGained)) g fibres"
            )
            switch swap.gain {
            case .calories: #expect(swap.kcalSaved >= 20, context)
            case .protein: #expect(swap.proteinGained >= 5, context)
            case .fibre: #expect(swap.fiberGained >= 2, context)
            case .quality: #expect(swap.reason.fr.count > 40, context)
            }
            #expect(swap.gain.label.isComplete)
        }
    }

    @Test("Un échange ne propose jamais un aliment interdit par le régime")
    func swapsRespectDiets() {
        for diet in DietPreference.allCases {
            for swap in FoodGuidance.swaps(for: diet) {
                #expect(swap.to?.suits(diet) == true, Comment(rawValue: "\(diet.rawValue) : \(swap.id)"))
            }
            #expect(!FoodGuidance.swaps(for: diet).isEmpty, Comment(rawValue: diet.rawValue))
        }
        // Un végétalien ne se voit pas proposer du blanc de poulet.
        #expect(!FoodGuidance.swaps(for: .vegan).contains { $0.toID == "blanc-de-poulet" })
    }
}
