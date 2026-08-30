import Foundation

/// What onboarding collects, before it becomes a `UserProfile`.
///
/// It keeps values in the shape a form needs (optionals, free text, display
/// units) and does the conversion in one place, so no view has to know that
/// storage is metric.
public struct ProfileDraft: Sendable {
    public var firstName: String = ""
    public var birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    public var sex: Sex = .male

    public var unit: UnitSystem = .metric
    public var heightCm: Double = 175
    public var weightKg: Double = 75
    public var knowsBodyFat: Bool = false
    public var bodyFatPercent: Double = 18
    public var waistCm: Double = 84

    public var trainingMonths: Int = 0
    public var experienceOverride: ExperienceLevel?

    public var goal: PrimaryGoal = .hypertrophy
    public var hasTargetWeight: Bool = false
    public var targetWeightKg: Double = 75
    public var hasDeadline: Bool = false
    public var deadline: Date = Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()

    public var daysPerWeek: Int = 4
    public var sessionMinutes: Int = 60
    public var equipment: Set<Equipment> = Equipment.fullGym
    public var loadIncrement: LoadIncrement = .standard

    public var limitations: Set<Limitation> = []

    public var activityLevel: ActivityLevel = .light
    public var sleepHours: Double = 7.5
    public var stressLevel: Int = 3
    public var dietPreference: DietPreference = .omnivore

    /// Known 1RMs, in kg, for the four lifts worth asking about.
    public var oneRepMax: [String: Double] = [:]

    /// Le profil dont ce brouillon est parti, quand il en vient d'un.
    ///
    /// Le formulaire ne demande pas tout ce que le profil porte : les
    /// aliments refusés se déclarent devant une assiette, les exercices
    /// douloureux après une série, le profil de course a son propre écran,
    /// et le nombre de repas, les cartes et la langue vivent dans les
    /// préférences. Sans mémoire de l'original, `makeProfile` reconstruisait
    /// un profil neuf où tout cela valait sa valeur par défaut : ouvrir son
    /// profil pour corriger son poids effaçait le profil de course entier.
    ///
    /// Le brouillon garde donc l'original et lui rend ce qu'il ne sait pas
    /// éditer. Un brouillon vierge — l'inscription — n'a rien à rendre.
    private var original: UserProfile?

    public var experience: ExperienceLevel {
        experienceOverride ?? .inferred(fromTrainingMonths: trainingMonths)
    }

    /// The lifts the questionnaire offers a 1RM field for. Everything else is
    /// derived from these or from strength standards.
    public static let baselineLiftIDs = ["back-squat", "bench-press", "conventional-deadlift", "overhead-press"]

    public var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && heightCm > 100 && heightCm < 250
            && weightKg > 30 && weightKg < 300
            && !equipment.isEmpty
    }

    public func makeProfile() -> UserProfile {
        UserProfile(
            id: original?.id ?? UUID(),
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            birthDate: birthDate,
            sex: sex,
            heightCm: heightCm,
            weightKg: weightKg,
            bodyFatPercent: knowsBodyFat ? bodyFatPercent : nil,
            waistCm: knowsBodyFat ? waistCm : nil,
            trainingMonths: trainingMonths,
            experience: experience,
            goal: goal,
            targetWeightKg: hasTargetWeight ? targetWeightKg : nil,
            deadline: hasDeadline ? deadline : nil,
            daysPerWeek: daysPerWeek,
            sessionMinutes: sessionMinutes,
            equipment: equipment,
            loadIncrement: loadIncrement,
            limitations: limitations,
            dislikedExerciseIDs: original?.dislikedExerciseIDs ?? [],
            activityLevel: activityLevel,
            averageSleepHours: sleepHours,
            stressLevel: stressLevel,
            dietPreference: dietPreference,
            knownOneRepMax: oneRepMax.filter { $0.value > 0 },
            mealsPerDay: original?.mealsPerDay,
            dislikedFoodIDs: original?.dislikedFoodIDs,
            running: original?.running,
            mapTiles: original?.mapTiles,
            unit: unit,
            language: original?.language
        )
    }

    /// Rebuilds a draft from an existing profile so the same form can edit it.
    public init() {}

    public init(profile: UserProfile) {
        firstName = profile.firstName
        birthDate = profile.birthDate
        sex = profile.sex
        unit = profile.unit
        heightCm = profile.heightCm
        weightKg = profile.weightKg
        knowsBodyFat = profile.bodyFatPercent != nil
        bodyFatPercent = profile.bodyFatPercent ?? 18
        waistCm = profile.waistCm ?? 84
        trainingMonths = profile.trainingMonths
        experienceOverride = profile.experience
        goal = profile.goal
        hasTargetWeight = profile.targetWeightKg != nil
        targetWeightKg = profile.targetWeightKg ?? profile.weightKg
        hasDeadline = profile.deadline != nil
        deadline = profile.deadline ?? Date()
        daysPerWeek = profile.daysPerWeek
        sessionMinutes = profile.sessionMinutes
        equipment = profile.equipment
        loadIncrement = profile.loadIncrement
        limitations = profile.limitations
        activityLevel = profile.activityLevel
        sleepHours = profile.averageSleepHours
        stressLevel = profile.stressLevel
        dietPreference = profile.dietPreference
        oneRepMax = profile.knownOneRepMax
        original = profile
    }
}
