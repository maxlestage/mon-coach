import Foundation

/// Derived body numbers. Everything here is a pure function of the profile.
public struct BodyMetrics: Sendable, Equatable {
    public let age: Int
    public let bmi: Double
    /// Lean body mass in kg — measured when body fat is known, Boer-estimated otherwise.
    public let leanBodyMassKg: Double
    public let leanMassIsEstimated: Bool
    /// Basal metabolic rate, kcal/day.
    public let bmr: Double
    /// Total daily energy expenditure including training, kcal/day.
    public let tdee: Double
    /// Fat-free mass index, only when body fat was actually supplied.
    public let ffmi: Double?

    public var bmiCategory: String {
        switch bmi {
        case ..<18.5: "Sous le poids de forme"
        case 18.5..<25: "Dans la norme"
        case 25..<30: "Au-dessus de la norme"
        default: "Nettement au-dessus de la norme"
        }
    }
}

/// Computes anthropometric and energetic estimates from a profile.
///
/// Formulas: Mifflin-St Jeor (BMR without body fat), Katch-McArdle (with),
/// Boer (lean mass estimate). Training expenditure is added on top of the
/// non-training activity multiplier so that days/week actually moves TDEE.
public enum BodyMetricsEngine {

    public static func metrics(for profile: UserProfile, on date: Date = Date()) -> BodyMetrics {
        let age = profile.age(on: date)
        let heightM = profile.heightCm / 100
        let bmi = heightM > 0 ? profile.weightKg / (heightM * heightM) : 0

        let measuredLean: Double? = profile.bodyFatPercent.map {
            profile.weightKg * (1 - $0.clamped(to: 3...60) / 100)
        }
        let lean = measuredLean ?? boerLeanMass(profile: profile)

        let bmr: Double
        if measuredLean != nil {
            // Katch-McArdle is the better estimate once lean mass is known.
            bmr = 370 + 21.6 * lean
        } else {
            bmr = mifflinStJeor(profile: profile, age: age)
        }

        let trainingKcalPerDay = trainingExpenditure(profile: profile)
        let tdee = bmr * profile.activityLevel.multiplier + trainingKcalPerDay

        let ffmi: Double? = measuredLean.flatMap { leanKg in
            guard heightM > 0 else { return nil }
            // Normalised to 1.80 m, the usual convention.
            return leanKg / (heightM * heightM) + 6.1 * (1.8 - heightM)
        }

        return BodyMetrics(
            age: age,
            bmi: bmi,
            leanBodyMassKg: lean,
            leanMassIsEstimated: measuredLean == nil,
            bmr: bmr,
            tdee: tdee,
            ffmi: ffmi
        )
    }

    static func mifflinStJeor(profile: UserProfile, age: Int) -> Double {
        let base = 10 * profile.weightKg + 6.25 * profile.heightCm - 5 * Double(age)
        return profile.sex == .male ? base + 5 : base - 161
    }

    /// Boer lean-mass estimate. Rough, but better than nothing and it keeps
    /// protein targets sane for heavier athletes.
    static func boerLeanMass(profile: UserProfile) -> Double {
        switch profile.sex {
        case .male: 0.407 * profile.weightKg + 0.267 * profile.heightCm - 19.2
        case .female: 0.252 * profile.weightKg + 0.473 * profile.heightCm - 48.3
        }
    }

    /// Resistance training burns roughly 6 kcal/min of session time,
    /// amortised over the week.
    static func trainingExpenditure(profile: UserProfile) -> Double {
        let perSession = Double(profile.sessionMinutes) * 6.0
        return perSession * Double(profile.daysPerWeek) / 7.0
    }
}
