import Foundation
import MonCoachKit

/// What onboarding collects, before it becomes a `UserProfile`.
///
/// It keeps values in the shape a form needs (optionals, free text, display
/// units) and does the conversion in one place, so no view has to know that
/// storage is metric.
struct ProfileDraft {
    var firstName: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()
    var sex: Sex = .male

    var unit: UnitSystem = .metric
    var heightCm: Double = 175
    var weightKg: Double = 75
    var knowsBodyFat: Bool = false
    var bodyFatPercent: Double = 18
    var waistCm: Double = 84

    var trainingMonths: Int = 0
    var experienceOverride: ExperienceLevel?

    var goal: PrimaryGoal = .hypertrophy
    var hasTargetWeight: Bool = false
    var targetWeightKg: Double = 75
    var hasDeadline: Bool = false
    var deadline: Date = Calendar.current.date(byAdding: .month, value: 4, to: Date()) ?? Date()

    var daysPerWeek: Int = 4
    var sessionMinutes: Int = 60
    var equipment: Set<Equipment> = Equipment.fullGym
    var loadIncrement: LoadIncrement = .standard

    var limitations: Set<Limitation> = []

    var activityLevel: ActivityLevel = .light
    var sleepHours: Double = 7.5
    var stressLevel: Int = 3
    var dietPreference: DietPreference = .omnivore

    /// Known 1RMs, in kg, for the four lifts worth asking about.
    var oneRepMax: [String: Double] = [:]

    var experience: ExperienceLevel {
        experienceOverride ?? .inferred(fromTrainingMonths: trainingMonths)
    }

    /// The lifts the questionnaire offers a 1RM field for. Everything else is
    /// derived from these or from strength standards.
    static let baselineLiftIDs = ["back-squat", "bench-press", "conventional-deadlift", "overhead-press"]

    var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && heightCm > 100 && heightCm < 250
            && weightKg > 30 && weightKg < 300
            && !equipment.isEmpty
    }

    func makeProfile() -> UserProfile {
        UserProfile(
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
            activityLevel: activityLevel,
            averageSleepHours: sleepHours,
            stressLevel: stressLevel,
            dietPreference: dietPreference,
            knownOneRepMax: oneRepMax.filter { $0.value > 0 },
            unit: unit
        )
    }

    /// Rebuilds a draft from an existing profile so the same form can edit it.
    init() {}

    init(profile: UserProfile) {
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
    }
}
