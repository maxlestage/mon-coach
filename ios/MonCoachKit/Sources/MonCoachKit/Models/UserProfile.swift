import Foundation

/// Everything the coach knows about the athlete.
///
/// This is the single input the planning engines read from. Onboarding fills
/// it in; the profile screen edits it; every edit invalidates the current
/// mesocycle and triggers a rebuild.
public struct UserProfile: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID

    // MARK: Identity
    public var firstName: String
    public var birthDate: Date
    public var sex: Sex

    // MARK: Anthropometry
    public var heightCm: Double
    public var weightKg: Double
    /// Measured or estimated body-fat percentage, 0–100. Unlocks
    /// Katch-McArdle for BMR and FFMI for progress tracking.
    public var bodyFatPercent: Double?
    public var waistCm: Double?

    // MARK: History
    public var trainingMonths: Int
    public var experience: ExperienceLevel

    // MARK: Objective
    public var goal: PrimaryGoal
    public var targetWeightKg: Double?
    public var deadline: Date?

    // MARK: Availability
    /// Sessions per week the athlete commits to, 2–6.
    public var daysPerWeek: Int
    /// Minutes available per session, warm-up included.
    public var sessionMinutes: Int
    public var equipment: Set<Equipment>
    public var loadIncrement: LoadIncrement

    // MARK: Constraints
    public var limitations: Set<Limitation>
    public var dislikedExerciseIDs: Set<String>

    // MARK: Lifestyle
    public var activityLevel: ActivityLevel
    public var averageSleepHours: Double
    /// Self-reported baseline stress, 1 (calme) – 5 (sous l'eau).
    public var stressLevel: Int
    public var dietPreference: DietPreference

    // MARK: Baselines
    /// Known or estimated 1RM in kg, keyed by exercise id. Optional —
    /// the engine falls back to strength standards when it is empty.
    public var knownOneRepMax: [String: Double]

    // MARK: Food
    /// Repas par jour, 3 à 5. Optionnel dans le stockage : un profil
    /// enregistré avant l'arrivée du programme alimentaire doit continuer à
    /// se relire, pas déclencher une erreur de décodage qui coûterait tout
    /// l'historique de l'athlète.
    public var mealsPerDay: Int?
    /// Les aliments que l'athlète ne veut pas voir apparaître.
    public var dislikedFoodIDs: Set<String>?

    /// Le nombre de repas effectivement utilisé par le planificateur.
    public var mealCount: Int { (mealsPerDay ?? 4).clamped(to: 3...5) }
    public var excludedFoods: Set<String> { dislikedFoodIDs ?? [] }

    // MARK: Running
    /// The runner side of the athlete. Nil when they only lift — the whole
    /// running feature stays out of the way until they say they run.
    public var running: RunningProfile?
    /// Whether the run map may fetch OpenStreetMap tiles. Nil means yes.
    ///
    /// Tiles are the one thing in this app that reaches a server. An athlete
    /// who would rather nothing left the phone can turn them off and keep the
    /// route trace, drawn locally from their own points.
    public var mapTiles: Bool?

    /// Whether the run map is allowed to contact a tile server.
    public var loadsMapTiles: Bool { mapTiles ?? true }

    // MARK: Preferences
    public var unit: UnitSystem
    /// Chosen display language. Nil means "follow the system", which is what
    /// every new profile starts as.
    public var language: Language?

    public init(
        id: UUID = UUID(),
        firstName: String,
        birthDate: Date,
        sex: Sex,
        heightCm: Double,
        weightKg: Double,
        bodyFatPercent: Double? = nil,
        waistCm: Double? = nil,
        trainingMonths: Int = 0,
        experience: ExperienceLevel? = nil,
        goal: PrimaryGoal,
        targetWeightKg: Double? = nil,
        deadline: Date? = nil,
        daysPerWeek: Int = 3,
        sessionMinutes: Int = 60,
        equipment: Set<Equipment> = Equipment.fullGym,
        loadIncrement: LoadIncrement = .standard,
        limitations: Set<Limitation> = [],
        dislikedExerciseIDs: Set<String> = [],
        activityLevel: ActivityLevel = .light,
        averageSleepHours: Double = 7.5,
        stressLevel: Int = 3,
        dietPreference: DietPreference = .omnivore,
        knownOneRepMax: [String: Double] = [:],
        mealsPerDay: Int? = nil,
        dislikedFoodIDs: Set<String>? = nil,
        running: RunningProfile? = nil,
        mapTiles: Bool? = nil,
        unit: UnitSystem = .metric,
        language: Language? = nil
    ) {
        self.id = id
        self.firstName = firstName
        self.birthDate = birthDate
        self.sex = sex
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.bodyFatPercent = bodyFatPercent
        self.waistCm = waistCm
        self.trainingMonths = trainingMonths
        self.experience = experience ?? .inferred(fromTrainingMonths: trainingMonths)
        self.goal = goal
        self.targetWeightKg = targetWeightKg
        self.deadline = deadline
        self.daysPerWeek = daysPerWeek.clamped(to: 2...6)
        self.sessionMinutes = sessionMinutes.clamped(to: 20...150)
        self.equipment = equipment.isEmpty ? [.bodyweight] : equipment
        self.loadIncrement = loadIncrement
        self.limitations = limitations
        self.dislikedExerciseIDs = dislikedExerciseIDs
        self.activityLevel = activityLevel
        self.averageSleepHours = averageSleepHours
        self.stressLevel = stressLevel.clamped(to: 1...5)
        self.dietPreference = dietPreference
        self.knownOneRepMax = knownOneRepMax
        self.mealsPerDay = mealsPerDay
        self.dislikedFoodIDs = dislikedFoodIDs
        self.running = running
        self.mapTiles = mapTiles
        self.unit = unit
        self.language = language
    }

    /// The language to render every coach text in.
    public func language(matchingSystem preferred: [String]) -> Language {
        language ?? Language.best(matching: preferred)
    }

    public var runs: Bool { running != nil }

    public func age(on date: Date = Date(), calendar: Calendar = .current) -> Int {
        calendar.dateComponents([.year], from: birthDate, to: date).year ?? 0
    }

    /// Which way the athlete's body weight is meant to move. Nil when the
    /// goal implies holding weight steady.
    public var weightDirection: WeightDirection {
        switch goal {
        case .fatLoss: .down
        case .hypertrophy, .strength: .up
        case .recomposition, .generalHealth: .hold
        }
    }

    public enum WeightDirection: String, Sendable { case up, down, hold }
}

extension Comparable {
    /// Keeps a value inside a range. Used everywhere a slider, a form field or
    /// a formula could otherwise produce something absurd.
    public func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
