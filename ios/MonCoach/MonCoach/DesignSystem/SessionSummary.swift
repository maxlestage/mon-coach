import SwiftUI
import MonCoachKit

/// A read-only listing of a session: what is prescribed and at what load.
/// Used in the plan browser, in the onboarding preview and on the home screen.
struct SessionSummary: View {
    var session: PlannedSession
    var unit: UnitSystem
    var showsLoads: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Label("\(session.totalSets) séries", systemImage: "square.stack.3d.up.fill")
                Label(Format.duration(minutes: session.estimatedMinutes), systemImage: "clock")
            }
            .font(Theme.captionFont)
            .foregroundStyle(Theme.secondaryText)

            ForEach(session.exercises) { prescription in
                ExerciseSummaryRow(prescription: prescription, unit: unit, showsLoad: showsLoads)
                if prescription.id != session.exercises.last?.id {
                    Divider().overlay(Theme.separator)
                }
            }
        }
    }
}

struct ExerciseSummaryRow: View {
    var prescription: ExercisePrescription
    var unit: UnitSystem
    var showsLoad: Bool = true

    private var exercise: Exercise? {
        ExerciseCatalog.exercise(id: prescription.exerciseID)
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise?.name ?? prescription.exerciseID)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                Text(detail)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer(minLength: 0)
            if showsLoad, let load = prescription.sets.first?.suggestedLoadKg {
                Text(Format.load(load, unit: unit))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
            }
        }
    }

    private var detail: String {
        guard let first = prescription.sets.first else { return "" }
        let rest = "repos \(Format.clock(seconds: prescription.restSeconds))"
        return "\(prescription.sets.count) × \(first.repsLabel) · \(Format.rpe(first.targetRPE)) · \(rest)"
    }
}
