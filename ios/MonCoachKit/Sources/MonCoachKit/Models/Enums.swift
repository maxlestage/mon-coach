import Foundation

/// Biological sex, used only where a formula genuinely needs it
/// (BMR, lean-mass estimation, strength standards).
public enum Sex: String, Codable, CaseIterable, Sendable {
    case male
    case female

    public var label: String {
        switch self {
        case .male: "Homme"
        case .female: "Femme"
        }
    }
}

/// How much productive training history the athlete has.
/// Drives volume landmarks, progression model and deload frequency.
public enum ExperienceLevel: String, Codable, CaseIterable, Sendable, Comparable {
    case beginner
    case intermediate
    case advanced

    public var label: String {
        switch self {
        case .beginner: "Débutant"
        case .intermediate: "Intermédiaire"
        case .advanced: "Avancé"
        }
    }

    /// Rank used for ordering and for scaling volume landmarks.
    public var rank: Int {
        switch self {
        case .beginner: 0
        case .intermediate: 1
        case .advanced: 2
        }
    }

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rank < rhs.rank }

    /// Best-guess level from months of consistent training, used as an
    /// onboarding default the athlete can override.
    public static func inferred(fromTrainingMonths months: Int) -> ExperienceLevel {
        switch months {
        case ..<12: .beginner
        case 12..<36: .intermediate
        default: .advanced
        }
    }
}

/// The single objective the plan optimises for. Everything downstream
/// (calories, volume, rep ranges, exercise ranking) reads from this.
public enum PrimaryGoal: String, Codable, CaseIterable, Sendable {
    case hypertrophy
    case strength
    case fatLoss
    case recomposition
    case generalHealth

    public var label: String {
        switch self {
        case .hypertrophy: "Prise de muscle"
        case .strength: "Force maximale"
        case .fatLoss: "Perte de gras"
        case .recomposition: "Recomposition"
        case .generalHealth: "Forme générale"
        }
    }

    /// Rep range the plan centres its main work on.
    public var mainRepRange: ClosedRange<Int> {
        switch self {
        case .strength: 3...6
        case .hypertrophy: 6...12
        case .recomposition: 6...12
        case .fatLoss: 8...15
        case .generalHealth: 8...12
        }
    }

    /// Target RPE for working sets outside of deload weeks.
    public var workingRPE: Double {
        switch self {
        case .strength: 8.0
        case .hypertrophy: 8.5
        case .recomposition: 8.0
        case .fatLoss: 8.0
        case .generalHealth: 7.5
        }
    }
}

/// Daily activity outside of training. Multiplies BMR to reach TDEE.
public enum ActivityLevel: String, Codable, CaseIterable, Sendable {
    case sedentary
    case light
    case moderate
    case high
    case veryHigh

    public var label: String {
        switch self {
        case .sedentary: "Sédentaire (bureau, peu de marche)"
        case .light: "Légèrement actif"
        case .moderate: "Modérément actif"
        case .high: "Très actif"
        case .veryHigh: "Extrêmement actif (métier physique)"
        }
    }

    /// Non-training activity multiplier applied to BMR.
    /// Training expenditure is added separately so that days/week matters.
    public var multiplier: Double {
        switch self {
        case .sedentary: 1.20
        case .light: 1.32
        case .moderate: 1.42
        case .high: 1.55
        case .veryHigh: 1.70
        }
    }
}

/// Equipment the athlete can actually reach. Exercises are filtered against it.
public enum Equipment: String, Codable, CaseIterable, Sendable {
    case bodyweight
    case barbell
    case dumbbell
    case kettlebell
    case machine
    case cable
    case smithMachine
    case band
    case pullUpBar
    case bench
    case dipStation

    public var label: String {
        switch self {
        case .bodyweight: "Poids du corps"
        case .barbell: "Barre olympique"
        case .dumbbell: "Haltères"
        case .kettlebell: "Kettlebells"
        case .machine: "Machines guidées"
        case .cable: "Poulies"
        case .smithMachine: "Smith machine"
        case .band: "Élastiques"
        case .pullUpBar: "Barre de traction"
        case .bench: "Banc"
        case .dipStation: "Barres parallèles / dips"
        }
    }

    /// Ready-made kits offered during onboarding.
    public static let fullGym: Set<Equipment> = Set(Equipment.allCases)
    public static let homeGym: Set<Equipment> = [.bodyweight, .dumbbell, .band, .pullUpBar, .bench]
    public static let minimal: Set<Equipment> = [.bodyweight, .band]
}

/// Muscle groups the volume budget is tracked against.
public enum MuscleGroup: String, Codable, CaseIterable, Sendable {
    case chest
    case back
    case lats
    case traps
    case shoulders
    case rearDelts
    case biceps
    case triceps
    case forearms
    case quads
    case hamstrings
    case glutes
    case calves
    case core

    public var label: String {
        switch self {
        case .chest: "Pectoraux"
        case .back: "Dos (épaisseur)"
        case .lats: "Dorsaux (largeur)"
        case .traps: "Trapèzes"
        case .shoulders: "Épaules"
        case .rearDelts: "Deltoïdes postérieurs"
        case .biceps: "Biceps"
        case .triceps: "Triceps"
        case .forearms: "Avant-bras"
        case .quads: "Quadriceps"
        case .hamstrings: "Ischio-jambiers"
        case .glutes: "Fessiers"
        case .calves: "Mollets"
        case .core: "Gainage / abdominaux"
        }
    }

    /// Groups that carry the bulk of a plan's volume budget. Small
    /// stabilisers get whatever indirect work the compounds provide.
    public static let primary: [MuscleGroup] = [
        .chest, .back, .lats, .shoulders, .quads, .hamstrings, .glutes, .biceps, .triceps
    ]
}

/// Movement pattern, used to keep a session balanced (push/pull, hinge/squat).
public enum MovementPattern: String, Codable, CaseIterable, Sendable {
    case horizontalPush
    case verticalPush
    case horizontalPull
    case verticalPull
    case squat
    case hinge
    case lunge
    case isolation
    case carry
    case coreBrace

    public var label: String {
        switch self {
        case .horizontalPush: "Poussée horizontale"
        case .verticalPush: "Poussée verticale"
        case .horizontalPull: "Tirage horizontal"
        case .verticalPull: "Tirage vertical"
        case .squat: "Squat"
        case .hinge: "Charnière de hanche"
        case .lunge: "Fente / unilatéral"
        case .isolation: "Isolation"
        case .carry: "Port de charge"
        case .coreBrace: "Gainage"
        }
    }
}

/// A body area the athlete has flagged as painful or fragile.
/// Exercises declaring the same area are removed from selection.
public enum Limitation: String, Codable, CaseIterable, Sendable {
    case shoulder
    case lowerBack
    case knee
    case hip
    case elbow
    case wrist
    case neck
    case ankle

    public var label: String {
        switch self {
        case .shoulder: "Épaule"
        case .lowerBack: "Bas du dos"
        case .knee: "Genou"
        case .hip: "Hanche"
        case .elbow: "Coude"
        case .wrist: "Poignet"
        case .neck: "Nuque"
        case .ankle: "Cheville"
        }
    }
}

/// Dietary pattern. Only shifts protein sourcing advice, not the maths.
public enum DietPreference: String, Codable, CaseIterable, Sendable {
    case omnivore
    case vegetarian
    case vegan
    case pescatarian
    case halal
    case glutenFree

    public var label: String {
        switch self {
        case .omnivore: "Omnivore"
        case .vegetarian: "Végétarien"
        case .vegan: "Végétalien"
        case .pescatarian: "Pescétarien"
        case .halal: "Halal"
        case .glutenFree: "Sans gluten"
        }
    }
}

/// Display units. All storage and computation stay metric.
public enum UnitSystem: String, Codable, CaseIterable, Sendable {
    case metric
    case imperial

    public var label: String {
        switch self {
        case .metric: "Métrique (kg / cm)"
        case .imperial: "Impérial (lb / in)"
        }
    }
}

/// The smallest load increment the athlete can actually add to a bar or
/// a stack. Load suggestions are rounded to it.
public enum LoadIncrement: String, Codable, CaseIterable, Sendable {
    case fine      // micro-plates available
    case standard  // 2.5 kg per side
    case coarse    // fixed dumbbells / plate-loaded stacks

    public var stepKg: Double {
        switch self {
        case .fine: 1.0
        case .standard: 2.5
        case .coarse: 5.0
        }
    }

    public var label: String {
        switch self {
        case .fine: "Micro-charges (1 kg)"
        case .standard: "Disques standards (2,5 kg)"
        case .coarse: "Haltères fixes (5 kg)"
        }
    }
}
