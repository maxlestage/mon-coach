import Foundation
import Testing
@testable import MonCoachKit

@Suite("Inspection", .disabled("outil de diagnostic : à activer à la main pour lire un bloc complet"))
struct DumpTests {
    @Test func dumpPlan() {
        let profile = Fixtures.intermediate(daysPerWeek: 4, sessionMinutes: 70)
        let program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        print("SPLIT:", program.plan.split.label.fr, "| semaines:", program.plan.weekCount)
        print("KCAL:", program.nutrition.calories, "P", program.nutrition.proteinG, "L", program.nutrition.fatG, "G", program.nutrition.carbsG)
        for (m, s) in program.plan.weeklyVolumeTarget.sorted(by: { $0.key.rawValue < $1.key.rawValue }) where s > 0 {
            print("  vol", m.rawValue, s)
        }
        for week in program.plan.weeks.prefix(2) {
            print("--- semaine \(week.index) deload=\(week.isDeload) total=\(week.totalSets)")
            for session in week.sessions {
                print("  [\(session.dayIndex)] \(session.title.fr) — \(session.totalSets) séries, ~\(session.estimatedMinutes) min")
                for ex in session.exercises {
                    let name = ExerciseCatalog.exercise(id: ex.exerciseID)?.name.fr ?? ex.exerciseID
                    print("      \(name): \(ex.sets.count)×\(ex.sets[0].repsLabel) @RPE \(ex.sets[0].targetRPE) repos \(ex.restSeconds)s")
                }
            }
        }
    }
}


@Suite("Inspection alimentaire", .disabled("outil de diagnostic : à activer à la main"))
struct DumpFoodTests {
    @Test func dumpDay() {
        let profile = Fixtures.intermediate(goal: .fatLoss)
        let program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let target = program.nutrition
        print("CIBLE:", target.calories, "kcal | P", target.proteinG, "G", target.carbsG, "L", target.fatG)
        for diet in [DietPreference.omnivore, .vegan] {
            print("\n===== \(diet.rawValue) =====")
            let day = MealPlanner.day(target: target, diet: diet, dayIndex: 2, mealsPerDay: 4, trainsToday: true)
            for meal in day.meals {
                let m = meal.macros
                print("  [\(meal.slot.rawValue)] \(Int(m.kcal)) kcal — P\(Int(m.proteinG)) G\(Int(m.carbsG)) L\(Int(m.fatG))")
                for item in meal.items {
                    print("      \(Int(item.grams)) g  \(item.food?.name.fr ?? item.foodID)  [\(item.food?.tier.rawValue ?? "?")]")
                }
            }
            let t = day.macros, d = day.drift
            print("  TOTAL: \(Int(t.kcal)) kcal P\(Int(t.proteinG)) G\(Int(t.carbsG)) L\(Int(t.fatG)) fibres \(Int(t.fiberG))")
            print("  ÉCART: kcal \(Int(d.kcal*100))% P \(Int(d.proteinG*100))% G \(Int(d.carbsG*100))% L \(Int(d.fatG*100))%")
        }
    }
}
