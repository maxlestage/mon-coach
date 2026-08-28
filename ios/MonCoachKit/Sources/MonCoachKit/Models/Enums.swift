import Foundation

/// Biological sex, used only where a formula genuinely needs it
/// (BMR, lean-mass estimation, strength standards).
public enum Sex: String, Codable, CaseIterable, Sendable {
    case male
    case female

    public var label: LocalizedText {
        switch self {
        case .male: LocalizedText(fr: "Homme", en: "Male", es: "Hombre")
        case .female: LocalizedText(fr: "Femme", en: "Female", es: "Mujer")
        }
    }
}

/// How much productive training history the athlete has.
/// Drives volume landmarks, progression model and deload frequency.
public enum ExperienceLevel: String, Codable, CaseIterable, Sendable, Comparable {
    case beginner
    case intermediate
    case advanced

    public var label: LocalizedText {
        switch self {
        case .beginner: LocalizedText(fr: "Débutant", en: "Beginner", es: "Principiante")
        case .intermediate: LocalizedText(fr: "Intermédiaire", en: "Intermediate", es: "Intermedio")
        case .advanced: LocalizedText(fr: "Avancé", en: "Advanced", es: "Avanzado")
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

    public var label: LocalizedText {
        switch self {
        case .hypertrophy: LocalizedText(fr: "Prise de muscle", en: "Build muscle", es: "Ganar músculo")
        case .strength: LocalizedText(fr: "Force maximale", en: "Maximal strength", es: "Fuerza máxima")
        case .fatLoss: LocalizedText(fr: "Perte de gras", en: "Fat loss", es: "Pérdida de grasa")
        case .recomposition: LocalizedText(fr: "Recomposition", en: "Recomposition", es: "Recomposición")
        case .generalHealth: LocalizedText(fr: "Forme générale", en: "General fitness", es: "Forma general")
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

    public var label: LocalizedText {
        switch self {
        case .sedentary: LocalizedText(fr: "Sédentaire (bureau, peu de marche)", en: "Sedentary (desk job, little walking)", es: "Sedentario (oficina, poco caminar)")
        case .light: LocalizedText(fr: "Légèrement actif", en: "Lightly active", es: "Ligeramente activo")
        case .moderate: LocalizedText(fr: "Modérément actif", en: "Moderately active", es: "Moderadamente activo")
        case .high: LocalizedText(fr: "Très actif", en: "Very active", es: "Muy activo")
        case .veryHigh: LocalizedText(fr: "Extrêmement actif (métier physique)", en: "Extremely active (physical job)", es: "Extremadamente activo (trabajo físico)")
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

    public var label: LocalizedText {
        switch self {
        case .bodyweight: LocalizedText(fr: "Poids du corps", en: "Bodyweight", es: "Peso corporal")
        case .barbell: LocalizedText(fr: "Barre olympique", en: "Barbell", es: "Barra olímpica")
        case .dumbbell: LocalizedText(fr: "Haltères", en: "Dumbbells", es: "Mancuernas")
        case .kettlebell: LocalizedText(fr: "Kettlebells", en: "Kettlebells", es: "Pesas rusas")
        case .machine: LocalizedText(fr: "Machines guidées", en: "Machines", es: "Máquinas guiadas")
        case .cable: LocalizedText(fr: "Poulies", en: "Cables", es: "Poleas")
        case .smithMachine: LocalizedText(fr: "Smith machine", en: "Smith machine", es: "Máquina Smith")
        case .band: LocalizedText(fr: "Élastiques", en: "Resistance bands", es: "Bandas elásticas")
        case .pullUpBar: LocalizedText(fr: "Barre de traction", en: "Pull-up bar", es: "Barra de dominadas")
        case .bench: LocalizedText(fr: "Banc", en: "Bench", es: "Banco")
        case .dipStation: LocalizedText(fr: "Barres parallèles / dips", en: "Dip station", es: "Paralelas / fondos")
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

    public var label: LocalizedText {
        switch self {
        case .chest: LocalizedText(fr: "Pectoraux", en: "Chest", es: "Pectorales")
        case .back: LocalizedText(fr: "Dos (épaisseur)", en: "Back (thickness)", es: "Espalda (grosor)")
        case .lats: LocalizedText(fr: "Dorsaux (largeur)", en: "Lats (width)", es: "Dorsales (anchura)")
        case .traps: LocalizedText(fr: "Trapèzes", en: "Traps", es: "Trapecios")
        case .shoulders: LocalizedText(fr: "Épaules", en: "Shoulders", es: "Hombros")
        case .rearDelts: LocalizedText(fr: "Deltoïdes postérieurs", en: "Rear delts", es: "Deltoides posteriores")
        case .biceps: LocalizedText(fr: "Biceps", en: "Biceps", es: "Bíceps")
        case .triceps: LocalizedText(fr: "Triceps", en: "Triceps", es: "Tríceps")
        case .forearms: LocalizedText(fr: "Avant-bras", en: "Forearms", es: "Antebrazos")
        case .quads: LocalizedText(fr: "Quadriceps", en: "Quads", es: "Cuádriceps")
        case .hamstrings: LocalizedText(fr: "Ischio-jambiers", en: "Hamstrings", es: "Isquiotibiales")
        case .glutes: LocalizedText(fr: "Fessiers", en: "Glutes", es: "Glúteos")
        case .calves: LocalizedText(fr: "Mollets", en: "Calves", es: "Gemelos")
        case .core: LocalizedText(fr: "Gainage / abdominaux", en: "Core", es: "Core / abdomen")
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

    public var label: LocalizedText {
        switch self {
        case .horizontalPush: LocalizedText(fr: "Poussée horizontale", en: "Horizontal push", es: "Empuje horizontal")
        case .verticalPush: LocalizedText(fr: "Poussée verticale", en: "Vertical push", es: "Empuje vertical")
        case .horizontalPull: LocalizedText(fr: "Tirage horizontal", en: "Horizontal pull", es: "Tirón horizontal")
        case .verticalPull: LocalizedText(fr: "Tirage vertical", en: "Vertical pull", es: "Tirón vertical")
        case .squat: LocalizedText(fr: "Squat", en: "Squat", es: "Sentadilla")
        case .hinge: LocalizedText(fr: "Charnière de hanche", en: "Hip hinge", es: "Bisagra de cadera")
        case .lunge: LocalizedText(fr: "Fente / unilatéral", en: "Lunge / single-leg", es: "Zancada / unilateral")
        case .isolation: LocalizedText(fr: "Isolation", en: "Isolation", es: "Aislamiento")
        case .carry: LocalizedText(fr: "Port de charge", en: "Carry", es: "Transporte de carga")
        case .coreBrace: LocalizedText(fr: "Gainage", en: "Bracing", es: "Core")
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

    public var label: LocalizedText {
        switch self {
        case .shoulder: LocalizedText(fr: "Épaule", en: "Shoulder", es: "Hombro")
        case .lowerBack: LocalizedText(fr: "Bas du dos", en: "Low back", es: "Zona lumbar")
        case .knee: LocalizedText(fr: "Genou", en: "Knee", es: "Rodilla")
        case .hip: LocalizedText(fr: "Hanche", en: "Hip", es: "Cadera")
        case .elbow: LocalizedText(fr: "Coude", en: "Elbow", es: "Codo")
        case .wrist: LocalizedText(fr: "Poignet", en: "Wrist", es: "Muñeca")
        case .neck: LocalizedText(fr: "Nuque", en: "Neck", es: "Cuello")
        case .ankle: LocalizedText(fr: "Cheville", en: "Ankle", es: "Tobillo")
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

    public var label: LocalizedText {
        switch self {
        case .omnivore: LocalizedText(fr: "Omnivore", en: "Omnivore", es: "Omnívoro")
        case .vegetarian: LocalizedText(fr: "Végétarien", en: "Vegetarian", es: "Vegetariano")
        case .vegan: LocalizedText(fr: "Végétalien", en: "Vegan", es: "Vegano")
        case .pescatarian: LocalizedText(fr: "Pescétarien", en: "Pescatarian", es: "Pescetariano")
        case .halal: LocalizedText(fr: "Halal", en: "Halal", es: "Halal")
        case .glutenFree: LocalizedText(fr: "Sans gluten", en: "Gluten-free", es: "Sin gluten")
        }
    }
}

/// Display units. All storage and computation stay metric.
public enum UnitSystem: String, Codable, CaseIterable, Sendable {
    case metric
    case imperial

    public var label: LocalizedText {
        switch self {
        case .metric: LocalizedText(fr: "Métrique (kg / cm)", en: "Metric (kg / cm)", es: "Métrico (kg / cm)")
        case .imperial: LocalizedText(fr: "Impérial (lb / in)", en: "Imperial (lb / in)", es: "Imperial (lb / in)")
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

    public var label: LocalizedText {
        switch self {
        case .fine: LocalizedText(fr: "Micro-charges (1 kg)", en: "Micro-plates (1 kg)", es: "Microcargas (1 kg)")
        case .standard: LocalizedText(fr: "Disques standards (2,5 kg)", en: "Standard plates (2.5 kg)", es: "Discos estándar (2,5 kg)")
        case .coarse: LocalizedText(fr: "Haltères fixes (5 kg)", en: "Fixed dumbbells (5 kg)", es: "Mancuernas fijas (5 kg)")
        }
    }
}
