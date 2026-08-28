import Foundation

/// One day of the weekly structure, before any exercise is chosen.
public struct DayTemplate: Sendable, Equatable {
    public let title: String
    /// Muscles this day is responsible for, in the order they should be trained.
    public let muscles: [MuscleGroup]
}

/// Picks the weekly structure and says which muscles each day owns.
public enum SplitPlanner {

    public static func split(for profile: UserProfile) -> SplitTemplate {
        switch profile.daysPerWeek {
        case ...3:
            // Below four sessions, full body wins on frequency every time.
            return .fullBody
        case 4:
            return .upperLower
        case 5:
            return .pushPullLegsUpperLower
        default:
            return profile.experience == .advanced ? .arnold : .pushPullLegs
        }
    }

    public static func days(for split: SplitTemplate, daysPerWeek: Int) -> [DayTemplate] {
        switch split {
        case .fullBody:
            return (0..<daysPerWeek).map { index in
                DayTemplate(
                    title: daysPerWeek > 1 ? "Full body \(letter(index))" : "Full body",
                    muscles: fullBodyRotation(index: index)
                )
            }

        case .upperLower:
            let upper = DayTemplate(
                title: "Haut du corps",
                muscles: [.chest, .lats, .back, .shoulders, .triceps, .biceps, .rearDelts]
            )
            let lower = DayTemplate(
                title: "Bas du corps",
                muscles: [.quads, .hamstrings, .glutes, .calves, .core]
            )
            return cycle([upper, lower], count: daysPerWeek)

        case .pushPullLegs:
            return cycle([pushDay, pullDay, legDay], count: daysPerWeek)

        case .pushPullLegsUpperLower:
            let upper = DayTemplate(
                title: "Haut du corps",
                muscles: [.chest, .lats, .back, .shoulders, .biceps, .triceps]
            )
            let lower = DayTemplate(
                title: "Bas du corps",
                muscles: [.quads, .hamstrings, .glutes, .calves, .core]
            )
            return cycle([pushDay, pullDay, legDay, upper, lower], count: daysPerWeek)

        case .arnold:
            let chestBack = DayTemplate(
                title: "Pectoraux / Dos",
                muscles: [.chest, .lats, .back]
            )
            let shouldersArms = DayTemplate(
                title: "Épaules / Bras",
                muscles: [.shoulders, .rearDelts, .biceps, .triceps, .forearms]
            )
            let legs = DayTemplate(
                title: "Jambes",
                muscles: [.quads, .hamstrings, .glutes, .calves, .core]
            )
            return cycle([chestBack, shouldersArms, legs], count: daysPerWeek)
        }
    }

    private static let pushDay = DayTemplate(
        title: "Push",
        muscles: [.chest, .shoulders, .triceps]
    )
    private static let pullDay = DayTemplate(
        title: "Pull",
        muscles: [.lats, .back, .rearDelts, .biceps, .traps]
    )
    private static let legDay = DayTemplate(
        title: "Legs",
        muscles: [.quads, .hamstrings, .glutes, .calves, .core]
    )

    /// Full-body days rotate which pattern leads so that the same muscle is
    /// not always trained last and fried.
    private static func fullBodyRotation(index: Int) -> [MuscleGroup] {
        let variants: [[MuscleGroup]] = [
            [.quads, .chest, .lats, .hamstrings, .shoulders, .triceps, .biceps, .core],
            [.hamstrings, .lats, .chest, .glutes, .shoulders, .biceps, .triceps, .core],
            [.glutes, .chest, .back, .quads, .rearDelts, .triceps, .biceps, .calves]
        ]
        return variants[index % variants.count]
    }

    private static func cycle(_ templates: [DayTemplate], count: Int) -> [DayTemplate] {
        guard !templates.isEmpty, count > 0 else { return [] }
        return (0..<count).map { index in
            let base = templates[index % templates.count]
            // Second pass through the rotation gets a suffix so the week reads clearly.
            guard index >= templates.count else { return base }
            return DayTemplate(title: "\(base.title) B", muscles: base.muscles)
        }
    }

    private static func letter(_ index: Int) -> String {
        let letters = ["A", "B", "C", "D", "E", "F"]
        return letters[index % letters.count]
    }

    /// Splits the weekly volume budget across the days that own each muscle.
    ///
    /// Returns, per day index, the number of working sets to devote to each
    /// muscle. Remainders go to the earliest days so that the harder work
    /// lands while the athlete is fresh.
    public static func distribute(
        volume: VolumePrescription,
        across days: [DayTemplate]
    ) -> [[MuscleGroup: Int]] {
        var perDay = [[MuscleGroup: Int]](repeating: [:], count: days.count)
        var load = [Int](repeating: 0, count: days.count)

        // Biggest budgets are placed first: they have the least freedom, and
        // letting them settle before the small ones keeps the week balanced.
        let ordered = MuscleGroup.allCases
            .filter { volume.sets(for: $0) > 0 }
            .sorted {
                let left = volume.sets(for: $0)
                let right = volume.sets(for: $1)
                return left == right ? $0.rawValue < $1.rawValue : left > right
            }

        for muscle in ordered {
            let weekly = volume.sets(for: muscle)
            let allOwners = days.indices.filter { days[$0].muscles.contains(muscle) }
            guard !allOwners.isEmpty else { continue }

            // A single set of anything is not worth the setup time, so a small
            // weekly budget is concentrated on fewer days rather than spread thin.
            let usableDays = max(1, min(allOwners.count, weekly / 2))
            // Concentrate on whichever eligible days are the emptiest so far —
            // otherwise every small budget piles onto the first day of the week
            // and the last day ends up with two exercises.
            let owners = allOwners
                .sorted { load[$0] == load[$1] ? $0 < $1 : load[$0] < load[$1] }
                .prefix(usableDays)
                .sorted()

            let base = weekly / owners.count
            var remainder = weekly % owners.count
            for dayIndex in owners {
                var sets = base
                if remainder > 0 {
                    sets += 1
                    remainder -= 1
                }
                if sets > 0 {
                    perDay[dayIndex][muscle] = sets
                    load[dayIndex] += sets
                }
            }
        }
        return perDay
    }
}
