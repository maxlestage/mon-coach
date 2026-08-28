import Foundation

/// The weekly set budget the plan is built around.
public struct VolumePrescription: Sendable, Equatable {
    /// Weekly working sets per muscle group.
    public let weeklySets: [MuscleGroup: Int]
    /// Multiplier applied to the baseline because of recovery inputs.
    public let recoveryFactor: Double
    public let rationale: [String]

    public func sets(for muscle: MuscleGroup) -> Int { weeklySets[muscle] ?? 0 }

    public var total: Int { weeklySets.values.reduce(0, +) }
}

/// Decides how many hard sets per muscle per week the athlete should do.
///
/// Baselines are the commonly cited MEV→MAV landmarks, scaled by experience,
/// then adjusted for goal, session budget and recovery capacity.
public enum VolumeEngine {

    /// Weekly sets a well-recovered intermediate should land on.
    static func baseline(for muscle: MuscleGroup) -> Int {
        switch muscle {
        case .chest: 14
        case .back: 14
        case .lats: 12
        case .quads: 14
        case .hamstrings: 12
        case .glutes: 10
        case .shoulders: 12
        case .rearDelts: 8
        case .biceps: 10
        case .triceps: 10
        case .traps: 6
        case .calves: 8
        case .forearms: 4
        case .core: 6
        }
    }

    public static func prescription(for profile: UserProfile) -> VolumePrescription {
        var rationale: [String] = []

        // Beginners grow on far less; advanced athletes need more to progress.
        let experienceFactor: Double = switch profile.experience {
        case .beginner: 0.65
        case .intermediate: 1.0
        case .advanced: 1.2
        }
        if profile.experience == .beginner {
            rationale.append("Volume volontairement bas : à ton niveau, la technique et la régularité comptent bien plus que le nombre de séries.")
        }

        // The goal shifts where volume goes.
        let goalFactor: Double = switch profile.goal {
        case .hypertrophy: 1.0
        case .recomposition: 0.95
        case .strength: 0.8   // fewer, heavier sets
        case .fatLoss: 0.9    // recovery is capped by the deficit
        case .generalHealth: 0.75
        }
        if profile.goal == .strength {
            rationale.append("Moins de séries mais plus lourdes : la force se construit sur l'intensité, pas sur le tonnage.")
        }
        if profile.goal == .fatLoss {
            rationale.append("Volume légèrement réduit : en déficit, la récupération est le facteur limitant.")
        }

        // Recovery capacity from sleep and stress.
        var recovery = 1.0
        if profile.averageSleepHours < 6 {
            recovery -= 0.15
            rationale.append("Moins de 6 h de sommeil : le volume est réduit de 15 % tant que ça ne bouge pas, sinon tu accumules de la fatigue sans progresser.")
        } else if profile.averageSleepHours < 7 {
            recovery -= 0.07
        } else if profile.averageSleepHours >= 8 {
            recovery += 0.05
        }
        if profile.stressLevel >= 4 {
            recovery -= 0.10
            rationale.append("Niveau de stress élevé : on garde de la marge pour éviter de transformer chaque séance en dette de récupération.")
        }
        if profile.age() >= 45 {
            recovery -= 0.08
        }
        recovery = recovery.clamped(to: 0.6...1.15)

        // The session budget caps everything: sets you have no time for are
        // sets you will not do.
        let weeklySetCapacity = weeklySetCapacity(for: profile)

        var raw: [MuscleGroup: Double] = [:]
        for muscle in MuscleGroup.allCases {
            raw[muscle] = Double(baseline(for: muscle)) * experienceFactor * goalFactor * recovery
        }

        // Scale everything down proportionally if the athlete cannot fit it in.
        let rawTotal = raw.values.reduce(0, +)
        var scale = 1.0
        if rawTotal > Double(weeklySetCapacity) {
            scale = Double(weeklySetCapacity) / rawTotal
            rationale.append("Le volume a été ajusté à \(profile.daysPerWeek) séances de \(profile.sessionMinutes) min : mieux vaut un plan que tu termines qu'un plan idéal que tu abandonnes.")
        }

        // Below 2 weekly sets a muscle is not being trained; round it to zero
        // and let the compounds cover it rather than pretending otherwise.
        var weekly: [MuscleGroup: Int] = [:]
        for (muscle, value) in raw {
            let scaled = Int((value * scale).rounded())
            weekly[muscle] = scaled >= 2 ? scaled : (MuscleGroup.primary.contains(muscle) ? 2 : 0)
        }

        return VolumePrescription(weeklySets: weekly, recoveryFactor: recovery, rationale: rationale)
    }

    /// How many working sets realistically fit in the athlete's week.
    ///
    /// A working set costs its rest plus time under tension; 8 minutes per
    /// session go to warm-up and are not available for work.
    static func weeklySetCapacity(for profile: UserProfile) -> Int {
        let usableMinutes = max(0, profile.sessionMinutes - 8)
        // ~2 min per set on average across compounds and isolation.
        let setsPerSession = Double(usableMinutes) / 2.0
        return Int((setsPerSession * Double(profile.daysPerWeek)).rounded())
    }
}
