import Foundation
import Testing
@testable import MonCoachKit

@Suite("Aliments refusés")
struct FoodSubstitutionTests {

    @Test("Le remplaçant tient le même rôle dans l'assiette")
    func alternativesKeepTheRole() {
        for food in FoodCatalog.all.prefix(60) {
            let swaps = FoodSubstitutions.alternatives(to: food.id, diet: .omnivore)
            for swap in swaps {
                #expect(swap.role == food.role, "\(swap.id) remplace \(food.id) d'un autre rôle")
                #expect(swap.id != food.id, "\(food.id) se remplace par lui-même")
            }
        }
    }

    @Test("Le remplaçant respecte le régime, et n'est jamais un déjà-refusé")
    func alternativesRespectDietAndRefusals() {
        let refused: Set<String> = Set(
            FoodCatalog.all.filter { $0.role == .protein }.prefix(3).map(\.id)
        )
        let target = try! #require(FoodCatalog.all.first { $0.role == .protein })
        let swaps = FoodSubstitutions.alternatives(
            to: target.id, diet: .vegetarian, excluding: refused
        )
        #expect(!swaps.isEmpty)
        for swap in swaps {
            #expect(swap.suits(.vegetarian), "\(swap.id) ne convient pas au régime végétarien")
            #expect(!refused.contains(swap.id), "\(swap.id) était déjà refusé")
        }
    }

    @Test("Le plus proche par les macros arrive en premier")
    func closestComesFirst() {
        let target = try! #require(FoodCatalog.food(id: "blanc-de-poulet"))
        let swaps = FoodSubstitutions.alternatives(to: target.id, diet: .omnivore, limit: 5)
        let distances = swaps.map { FoodSubstitutions.distance(from: target, to: $0) }
        #expect(distances == distances.sorted(), "les remplaçants ne sont pas classés par proximité")
    }

    @Test("Refuser ses dernières protéines est écarté, pas obéi")
    func refusingCannotEmptyARole() {
        var refused: Set<String> = []
        let proteins = FoodSubstitutions.candidates(role: .protein, diet: .vegan, excluding: [])
        #expect(proteins.count >= 3, "trop peu de protéines végan pour que le test veuille dire quelque chose")

        // On refuse tout sauf les deux dernières : chaque refus doit passer.
        for food in proteins.dropLast(2) {
            #expect(
                FoodSubstitutions.canRefuse(food.id, diet: .vegan, alreadyExcluded: refused),
                "\(food.id) refusé à tort"
            )
            refused.insert(food.id)
        }
        // Celui d'après ne laisserait qu'un seul aliment : il est écarté.
        let nextToLast = try! #require(proteins.dropLast().last)
        #expect(!FoodSubstitutions.canRefuse(nextToLast.id, diet: .vegan, alreadyExcluded: refused))
    }

    /// La cible d'un athlète réel : les macros d'un profil, pas des chiffres
    /// inventés qui pourraient n'avoir aucune solution.
    static func target() -> NutritionTarget {
        let profile = Fixtures.intermediate()
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        return NutritionEngine.target(for: profile, metrics: metrics)
    }

    @Test("Un aliment refusé disparaît vraiment de la journée")
    func refusedFoodLeavesThePlate() {
        let target = Self.target()
        let plain = MealPlanner.day(target: target, diet: .omnivore, dayIndex: 0, mealsPerDay: 4)
        let served = Set(plain.meals.flatMap { meal in meal.items.map { $0.foodID } })
        let victim = try! #require(served.first { FoodSubstitutions.canRefuse($0, diet: .omnivore, alreadyExcluded: []) })

        let without = MealPlanner.day(
            target: target, diet: .omnivore, dayIndex: 0, mealsPerDay: 4, excluding: [victim]
        )
        let after = Set(without.meals.flatMap { meal in meal.items.map { $0.foodID } })
        #expect(!after.contains(victim), "\(victim) est refusé et servi quand même")
        #expect(!after.isEmpty, "la journée s'est vidée au lieu de remplacer")
    }

    @Test("Le magasin refuse un aliment sans reconstruire le bloc")
    @MainActor
    func storeRefusesWithoutRebuildingThePlan() {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "mon-coach-taste-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }
        let store = CoachStore(storage: storage)
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: Fixtures.start)

        // Les identifiants des séances sont ce que le journal d'entraînement
        // désigne : les changer effacerait l'historique de l'athlète.
        let before = store.plan?.weeks.first?.sessions.map(\.id)
        #expect(store.refuseFood("blanc-de-poulet"))
        #expect(store.profile?.excludedFoods.contains("blanc-de-poulet") == true)
        #expect(store.plan?.weeks.first?.sessions.map(\.id) == before, "le bloc a été reconstruit")

        store.allowFood("blanc-de-poulet")
        #expect(store.profile?.excludedFoods.contains("blanc-de-poulet") == false)
    }
}

@Suite("Le brouillon de profil garde ce qu'il n'édite pas")
struct ProfileDraftCarryTests {

    @Test("Modifier son poids n'efface ni la course, ni les refus, ni les préférences")
    func editingKeepsEverythingElse() {
        var profile = Fixtures.intermediate()
        profile.running = RunningProfile()
        profile.running?.currentWeeklyMeters = 42_000
        profile.dislikedFoodIDs = ["blanc-de-poulet"]
        profile.dislikedExerciseIDs = ["back-squat"]
        profile.mealsPerDay = 5
        profile.mapTiles = false
        profile.language = .spanish

        var draft = ProfileDraft(profile: profile)
        draft.weightKg = 80
        let saved = draft.makeProfile()

        #expect(saved.weightKg == 80, "la modification demandée n'a pas été appliquée")
        #expect(saved.id == profile.id, "le profil a changé d'identité en s'enregistrant")
        #expect(saved.running?.currentWeeklyMeters == 42_000, "le profil de course a été effacé")
        #expect(saved.dislikedFoodIDs == ["blanc-de-poulet"], "les aliments refusés ont été effacés")
        #expect(saved.dislikedExerciseIDs == ["back-squat"], "les exercices écartés ont été effacés")
        #expect(saved.mealsPerDay == 5, "le nombre de repas a été effacé")
        #expect(saved.mapTiles == false, "le choix des cartes a été effacé")
        #expect(saved.language == .spanish, "la langue a été effacée")
    }

    @Test("Un brouillon vierge n'invente rien à préserver")
    func freshDraftCarriesNothing() {
        var draft = ProfileDraft()
        draft.firstName = "Alex"
        let made = draft.makeProfile()
        #expect(made.running == nil)
        #expect(made.dislikedFoodIDs == nil)
        #expect(made.dislikedExerciseIDs.isEmpty)
    }
}

@Suite("Courses sur la durée qu'on veut")
struct ShoppingHorizonTests {

    private func week() -> [DayPlan] {
        MealPlanner.week(
            target: FoodSubstitutionTests.target(),
            diet: .omnivore,
            mealsPerDay: 4
        )
    }

    @Test("Le sec se prend pour toute la période, le frais pour une semaine")
    func keepersScaleAndFreshDoesNot() {
        let days = week()
        let oneWeek = MealPlanner.shoppingList(for: days)
        let oneMonth = MealPlanner.shoppingList(for: days, horizon: .month)

        #expect(oneWeek.count == oneMonth.count, "la liste change de contenu selon la durée")
        for line in oneWeek {
            let monthly = try! #require(oneMonth.first { $0.foodID == line.foodID })
            if line.keeps {
                #expect(monthly.grams == line.grams * 4, "\(line.foodID) ne suit pas la période")
                #expect(!monthly.repeatsWeekly)
            } else {
                #expect(monthly.grams == line.grams, "\(line.foodID) est du frais acheté pour un mois")
                #expect(monthly.repeatsWeekly, "\(line.foodID) est du frais et ne le dit pas")
            }
        }
    }

    @Test("Sur une semaine, rien n'est marqué à reprendre")
    func aWeekSaysNothingSpecial() {
        for line in MealPlanner.shoppingList(for: week()) {
            #expect(!line.repeatsWeekly)
        }
    }

    @Test("Les légumes et les fruits sont du frais, le riz et l'huile non")
    func perishabilityFollowsTheAisle() {
        let list = MealPlanner.shoppingList(for: week())
        for line in list {
            switch line.role {
            case .vegetable, .fruit, .dairy:
                #expect(!line.keeps, "\(line.foodID) est vendu comme se gardant un mois")
            case .carb, .fat:
                #expect(line.keeps, "\(line.foodID) est traité comme périssable")
            default:
                break
            }
        }
    }

    @Test("Chaque durée proposée est un nombre entier de semaines")
    func everyHorizonIsWholeWeeks() {
        for horizon in MealPlanner.ShoppingHorizon.allCases {
            #expect(horizon.weeks >= 1)
            #expect(horizon.days == horizon.weeks * 7)
        }
    }
}
