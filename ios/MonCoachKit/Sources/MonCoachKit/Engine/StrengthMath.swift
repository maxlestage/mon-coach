import Foundation

/// Pure strength maths shared by the progression and analytics engines.
public enum StrengthMath {

    /// Fraction of 1RM a set represents, from an RPE/reps chart
    /// (the standard RTS-style table, interpolated).
    ///
    /// The chart is indexed by *reps in reserve* (10 − RPE) and reps.
    /// Values outside the table fall back to Epley.
    public static func percentOfOneRepMax(reps: Int, rpe: Double) -> Double {
        let rir = (10.0 - rpe).clamped(to: 0...4)
        // Effective reps: a set of 5 @ RPE 8 sits where a set of 7 @ RPE 10 sits.
        let effectiveReps = Double(reps) + rir
        guard effectiveReps > 1 else { return 1.0 }
        // Epley inverted: 1RM = w * (1 + r/30)  =>  w/1RM = 1 / (1 + r/30)
        return 1.0 / (1.0 + (effectiveReps - 1.0) / 30.0)
    }

    /// Estimated 1RM from a performed set, taking RPE into account.
    public static func estimatedOneRepMax(weightKg: Double, reps: Int, rpe: Double = 10) -> Double {
        guard weightKg > 0, reps > 0 else { return 0 }
        let pct = percentOfOneRepMax(reps: reps, rpe: rpe)
        guard pct > 0 else { return weightKg }
        return weightKg / pct
    }

    /// Load to prescribe for a target reps × RPE, given an estimated 1RM.
    public static func load(forOneRepMax oneRM: Double, reps: Int, rpe: Double) -> Double {
        oneRM * percentOfOneRepMax(reps: reps, rpe: rpe)
    }

    /// Rounds a load to something the athlete can actually load on the bar.
    public static func round(_ loadKg: Double, to increment: LoadIncrement) -> Double {
        let step = increment.stepKg
        guard step > 0 else { return loadKg }
        return max(step, (loadKg / step).rounded() * step)
    }

    /// Untrained-to-elite strength standards as a multiple of body weight,
    /// used to seed a first prescription when no 1RM is known.
    /// Source: widely published lift-standard tables, rounded to 0.05.
    public static func standardOneRepMax(
        exercise: Exercise,
        profile: UserProfile
    ) -> Double? {
        guard exercise.isCompound else { return nil }
        let base: Double? = switch exercise.pattern {
        case .squat: profile.sex == .male ? 1.00 : 0.80
        case .hinge: profile.sex == .male ? 1.25 : 1.00
        case .horizontalPush: profile.sex == .male ? 0.75 : 0.45
        case .verticalPush: profile.sex == .male ? 0.50 : 0.30
        case .horizontalPull: profile.sex == .male ? 0.70 : 0.45
        case .verticalPull: profile.sex == .male ? 0.75 : 0.50
        case .lunge: profile.sex == .male ? 0.60 : 0.45
        default: nil
        }
        guard let base else { return nil }
        let experienceFactor: Double = switch profile.experience {
        case .beginner: 0.75
        case .intermediate: 1.05
        case .advanced: 1.35
        }
        // Age-related decline past 40, ~1% per year.
        let age = profile.age()
        let ageFactor = age > 40 ? max(0.7, 1.0 - Double(age - 40) * 0.01) : 1.0
        return profile.weightKg * base * experienceFactor * ageFactor * exercise.loadFactor
    }

    /// Slope of a simple least-squares fit, in units per day.
    /// Returns nil when there is not enough spread to fit a line.
    public static func trendPerDay(_ points: [(date: Date, value: Double)]) -> Double? {
        guard points.count >= 2 else { return nil }
        let t0 = points.map { $0.date.timeIntervalSince1970 }.min()!
        let xs = points.map { ($0.date.timeIntervalSince1970 - t0) / 86_400 }
        let ys = points.map { $0.value }
        let n = Double(xs.count)
        let meanX = xs.reduce(0, +) / n
        let meanY = ys.reduce(0, +) / n
        var num = 0.0
        var den = 0.0
        for (x, y) in zip(xs, ys) {
            num += (x - meanX) * (y - meanY)
            den += (x - meanX) * (x - meanX)
        }
        guard den > 0.0001 else { return nil }
        return num / den
    }
}
