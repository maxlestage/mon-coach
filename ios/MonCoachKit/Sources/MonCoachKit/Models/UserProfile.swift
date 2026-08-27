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

    // MARK: Preferences
    public var unit: UnitSystem

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
        unit: UnitSystem = .metric
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
        self.unit = unit
    }

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
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
