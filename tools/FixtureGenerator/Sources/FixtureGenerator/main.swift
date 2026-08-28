// Génère les valeurs de référence du moteur Swift, que le portage TypeScript
// du site doit reproduire à l'identique.
//
// Utilisation, depuis la racine du dépôt :
//
//   swift run --package-path tools/FixtureGenerator moteur \
//     > web/src/coach/__fixtures__/engine-reference.json
//   swift run --package-path tools/FixtureGenerator exemples \
//     > web/src/data/examples.json
//
// Le test `bun test` du site compare son propre calcul au premier fichier :
// toute divergence entre l'application et le simulateur du site fait échouer
// la CI. Le second contient ce que le site montre en exemple — une journée
// de repas, une fiche technique, un remplacement d'exercice — produit par le
// moteur lui-même plutôt que réécrit à la main, pour que la page ne puisse
// pas promettre autre chose que ce que l'application fait.

import Foundation
import MonCoachKit

struct Case: Encodable {
    var name: String
    var input: Input
    var expected: Expected

    struct Input: Encodable {
        var sex: String
        var age: Int
        var heightCm: Double
        var weightKg: Double
        var bodyFatPercent: Double?
        var experience: String
        var goal: String
        var daysPerWeek: Int
        var sessionMinutes: Int
        var activityLevel: String
        var sleepHours: Double
        var stressLevel: Int

        enum CodingKeys: String, CodingKey {
            case sex, age, heightCm, weightKg, bodyFatPercent, experience, goal
            case daysPerWeek, sessionMinutes, activityLevel, sleepHours, stressLevel
        }

        // Écrit explicitement, sans `encodeIfPresent` : la clé absente et la
        // clé à `null` ne sont pas la même chose de l'autre côté, en TypeScript.
        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(sex, forKey: .sex)
            try container.encode(age, forKey: .age)
            try container.encode(heightCm, forKey: .heightCm)
            try container.encode(weightKg, forKey: .weightKg)
            try container.encode(bodyFatPercent, forKey: .bodyFatPercent)
            try container.encode(experience, forKey: .experience)
            try container.encode(goal, forKey: .goal)
            try container.encode(daysPerWeek, forKey: .daysPerWeek)
            try container.encode(sessionMinutes, forKey: .sessionMinutes)
            try container.encode(activityLevel, forKey: .activityLevel)
            try container.encode(sleepHours, forKey: .sleepHours)
            try container.encode(stressLevel, forKey: .stressLevel)
        }
    }

    struct Expected: Encodable {
        var bmr: Double
        var tdee: Double
        var leanBodyMassKg: Double
        var leanMassIsEstimated: Bool
        var calories: Int
        var proteinG: Int
        var fatG: Int
        var carbsG: Int
        var maintenanceCalories: Int
        var weeklyWeightChangeKg: Double
        var weeklySets: [String: Int]
        var volumeTotal: Int
        var recoveryFactor: Double
        var split: String
        var weekCount: Int
    }
}

let calendar = Calendar(identifier: .gregorian)
let referenceDate = calendar.date(from: DateComponents(year: 2026, month: 9, day: 1))!

func profile(
    sex: Sex,
    age: Int,
    heightCm: Double,
    weightKg: Double,
    bodyFat: Double?,
    experience: ExperienceLevel,
    goal: PrimaryGoal,
    days: Int,
    minutes: Int,
    activity: ActivityLevel,
    sleep: Double,
    stress: Int
) -> UserProfile {
    let birth = calendar.date(byAdding: .year, value: -age, to: referenceDate)!
    return UserProfile(
        firstName: "Ref",
        birthDate: birth,
        sex: sex,
        heightCm: heightCm,
        weightKg: weightKg,
        bodyFatPercent: bodyFat,
        trainingMonths: experience == .beginner ? 3 : (experience == .intermediate ? 24 : 72),
        experience: experience,
        goal: goal,
        daysPerWeek: days,
        sessionMinutes: minutes,
        activityLevel: activity,
        averageSleepHours: sleep,
        stressLevel: stress
    )
}

var cases: [Case] = []

let scenarios: [(String, UserProfile)] = [
    ("intermédiaire, prise de muscle, 4 séances",
     profile(sex: .male, age: 30, heightCm: 178, weightKg: 78, bodyFat: 16,
             experience: .intermediate, goal: .hypertrophy, days: 4, minutes: 70,
             activity: .light, sleep: 7.5, stress: 3)),
    ("débutante, forme générale, 3 séances courtes",
     profile(sex: .female, age: 26, heightCm: 165, weightKg: 60, bodyFat: nil,
             experience: .beginner, goal: .generalHealth, days: 3, minutes: 45,
             activity: .moderate, sleep: 7.0, stress: 2)),
    ("sèche agressive, peu de sommeil",
     profile(sex: .male, age: 41, heightCm: 183, weightKg: 96, bodyFat: 24,
             experience: .intermediate, goal: .fatLoss, days: 5, minutes: 60,
             activity: .sedentary, sleep: 5.5, stress: 4)),
    ("avancé, force, 6 séances",
     profile(sex: .male, age: 34, heightCm: 175, weightKg: 88, bodyFat: 12,
             experience: .advanced, goal: .strength, days: 6, minutes: 90,
             activity: .high, sleep: 8.5, stress: 2)),
    ("recomposition, deux séances par semaine",
     profile(sex: .female, age: 47, heightCm: 170, weightKg: 68, bodyFat: 28,
             experience: .intermediate, goal: .recomposition, days: 2, minutes: 50,
             activity: .light, sleep: 6.5, stress: 5)),
    ("petit gabarit, sèche plafonnée",
     profile(sex: .female, age: 22, heightCm: 152, weightKg: 47, bodyFat: 14,
             experience: .beginner, goal: .fatLoss, days: 3, minutes: 30,
             activity: .sedentary, sleep: 8.0, stress: 3))
]

for (name, athlete) in scenarios {
    let metrics = BodyMetricsEngine.metrics(for: athlete, on: referenceDate)
    let nutrition = NutritionEngine.target(for: athlete, metrics: metrics)
    let volume = VolumeEngine.prescription(for: athlete)
    let split = SplitPlanner.split(for: athlete)
    let plan = PlanBuilder.build(for: athlete, startingOn: referenceDate, calendar: calendar)

    var sets: [String: Int] = [:]
    for (muscle, value) in volume.weeklySets { sets[muscle.rawValue] = value }

    cases.append(
        Case(
            name: name,
            input: .init(
                sex: athlete.sex.rawValue,
                age: athlete.age(on: referenceDate, calendar: calendar),
                heightCm: athlete.heightCm,
                weightKg: athlete.weightKg,
                bodyFatPercent: athlete.bodyFatPercent,
                experience: athlete.experience.rawValue,
                goal: athlete.goal.rawValue,
                daysPerWeek: athlete.daysPerWeek,
                sessionMinutes: athlete.sessionMinutes,
                activityLevel: athlete.activityLevel.rawValue,
                sleepHours: athlete.averageSleepHours,
                stressLevel: athlete.stressLevel
            ),
            expected: .init(
                bmr: metrics.bmr,
                tdee: metrics.tdee,
                leanBodyMassKg: metrics.leanBodyMassKg,
                leanMassIsEstimated: metrics.leanMassIsEstimated,
                calories: nutrition.calories,
                proteinG: nutrition.proteinG,
                fatG: nutrition.fatG,
                carbsG: nutrition.carbsG,
                maintenanceCalories: nutrition.maintenanceCalories,
                weeklyWeightChangeKg: nutrition.weeklyWeightChangeKg,
                weeklySets: sets,
                volumeTotal: volume.total,
                recoveryFactor: volume.recoveryFactor,
                split: split.rawValue,
                weekCount: plan.weekCount
            )
        )
    )
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

let data: Data
switch CommandLine.arguments.dropFirst().first ?? "moteur" {
case "exemples":
    data = try encoder.encode(SiteExamples.build(on: referenceDate, calendar: calendar))
default:
    data = try encoder.encode(cases)
}
FileHandle.standardOutput.write(data)
FileHandle.standardOutput.write(Data("\n".utf8))
