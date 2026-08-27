import Foundation

/// Chooses which movements fill a day's set budget.
///
/// The rules, in order of priority:
/// 1. Never prescribe something the athlete cannot load or that hits a flagged joint.
/// 2. Lead with a compound for the day's first muscle — that is where the
///    stimulus per minute is highest and the athlete is freshest.
/// 3. Credit secondary muscles for the work compounds already give them, so
///    a plan does not stack 20 sets of indirect biceps work on top of 10 direct ones.
/// 4. Break ties on stimulus rating, then rotate so consecutive weeks differ.
public enum ExerciseSelector {

    /// Maximum working sets to put on a single movement before adding another.
    static let maxSetsPerExercise = 4
    static let minSetsPerExercise = 2

    public struct Selection: Sendable, Equatable {
        public let exercise: Exercise
        public let sets: Int
    }

    /// Fills one day.
    ///
    /// - Parameters:
    ///   - budget: sets owed per muscle for this day.
    ///   - order: the day template's muscle order — training priority.
    ///   - rotation: shifts the pick within equally good options so that
    ///     week 2 does not repeat week 1 verbatim.
    public static func select(
        budget: [MuscleGroup: Int],
        order: [MuscleGroup],
        available: [Exercise],
        rotation: Int = 0
    ) -> [Selection] {
        var remaining: [MuscleGroup: Double] = budget.mapValues(Double.init)
        var used: Set<String> = []
        var selections: [Selection] = []

        for muscle in order {
            var owed = remaining[muscle] ?? 0
            var isFirstPickForMuscle = true

            while owed >= Double(minSetsPerExercise) {
                let candidates = available.filter { exercise in
                    !used.contains(exercise.id) && exercise.volumeCredit(for: muscle) >= 1.0
                }
                guard !candidates.isEmpty else { break }

                // The opening movement for a muscle should be the heaviest
                // compound available; later slots favour isolation, which is
                // easier to recover from and easier to add volume with.
                let preferCompound = isFirstPickForMuscle
                let ranked = candidates.sorted { lhs, rhs in
                    let lhsScore = score(lhs, preferCompound: preferCompound)
                    let rhsScore = score(rhs, preferCompound: preferCompound)
                    if lhsScore != rhsScore { return lhsScore > rhsScore }
                    return lhs.id < rhs.id
                }
                // Rotate only among the movements that scored equally at the top.
                let topScore = score(ranked[0], preferCompound: preferCompound)
                let tied = ranked.prefix { score($0, preferCompound: preferCompound) == topScore }
                let chosen = tied[(rotation % tied.count) + tied.startIndex]

                let sets = min(maxSetsPerExercise, Int(owed.rounded(.down)))
                guard sets >= minSetsPerExercise else { break }

                selections.append(Selection(exercise: chosen, sets: sets))
                used.insert(chosen.id)
                isFirstPickForMuscle = false

                // Spend the budget, and credit every muscle this movement works.
                owed -= Double(sets)
                remaining[muscle] = owed
                for other in chosen.allMuscles where other != muscle {
                    let credit = chosen.volumeCredit(for: other) * Double(sets)
                    remaining[other] = max(0, (remaining[other] ?? 0) - credit)
                }
            }
        }

        // A muscle with a real weekly budget deserves at least one movement
        // that trains it directly. Without this, a couple of big compounds can
        // eat a muscle's whole budget through secondary credit and it never
        // gets trained on purpose.
        for muscle in order {
            let owed = budget[muscle] ?? 0
            guard owed >= directWorkThreshold else { continue }
            guard !selections.contains(where: { $0.exercise.primaryMuscle == muscle }) else { continue }
            let candidates = available.filter {
                !used.contains($0.id) && $0.primaryMuscle == muscle
            }
            guard let direct = candidates.max(by: {
                score($0, preferCompound: false) < score($1, preferCompound: false)
            }) else { continue }
            selections.append(Selection(exercise: direct, sets: minSetsPerExercise))
            used.insert(direct.id)
        }

        return sortForSession(selections)
    }

    /// Sets from which a muscle is owed dedicated work rather than whatever
    /// the compounds happen to give it. Set to the minimum viable number of
    /// sets: if a day is responsible for a muscle at all, that muscle gets a
    /// movement of its own, otherwise a single big compound can swallow a
    /// whole push day through secondary credit.
    static let directWorkThreshold = minSetsPerExercise

    /// Higher is better. Compounds are worth more when the slot wants one,
    /// and a movement that also feeds another muscle the day owes is worth more.
    static func score(_ exercise: Exercise, preferCompound: Bool) -> Int {
        var value = exercise.stimulusRating * 10
        if exercise.isCompound == preferCompound { value += 25 }
        if exercise.isCompound { value += exercise.secondaryMuscles.count * 3 }
        return value
    }

    /// Heavy compounds first, isolation last; within a tier keep the muscle order.
    static func sortForSession(_ selections: [Selection]) -> [Selection] {
        selections.enumerated()
            .sorted { lhs, rhs in
                let lhsTier = tier(lhs.element.exercise)
                let rhsTier = tier(rhs.element.exercise)
                if lhsTier != rhsTier { return lhsTier < rhsTier }
                return lhs.offset < rhs.offset
            }
            .map(\.element)
    }

    static func tier(_ exercise: Exercise) -> Int {
        switch exercise.pattern {
        case .squat, .hinge: exercise.isCompound ? 0 : 2
        case .horizontalPush, .verticalPush, .horizontalPull, .verticalPull: exercise.isCompound ? 1 : 2
        case .lunge, .carry: 1
        case .isolation: 2
        case .coreBrace: 3
        }
    }
}
