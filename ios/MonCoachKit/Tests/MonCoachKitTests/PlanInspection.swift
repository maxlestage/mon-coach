import Foundation
import Testing
@testable import MonCoachKit

@Suite("Inspection", .disabled("outil de diagnostic : à activer à la main pour lire un bloc complet"))
struct DumpTests {
    @Test func dumpPlan() {
        let profile = Fixtures.intermediate(daysPerWeek: 4, sessionMinutes: 70)
        let program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        print("SPLIT:", program.plan.split.label, "| semaines:", program.plan.weekCount)
        print("KCAL:", program.nutrition.calories, "P", program.nutrition.proteinG, "L", program.nutrition.fatG, "G", program.nutrition.carbsG)
        for (m, s) in program.plan.weeklyVolumeTarget.sorted(by: { $0.key.rawValue < $1.key.rawValue }) where s > 0 {
            print("  vol", m.rawValue, s)
        }
        for week in program.plan.weeks.prefix(2) {
            print("--- semaine \(week.index) deload=\(week.isDeload) total=\(week.totalSets)")
            for session in week.sessions {
                print("  [\(session.dayIndex)] \(session.title) — \(session.totalSets) séries, ~\(session.estimatedMinutes) min")
                for ex in session.exercises {
                    let name = ExerciseCatalog.exercise(id: ex.exerciseID)?.name ?? ex.exerciseID
                    print("      \(name): \(ex.sets.count)×\(ex.sets[0].repsLabel) @RPE \(ex.sets[0].targetRPE) repos \(ex.restSeconds)s")
                }
            }
        }
    }
}

