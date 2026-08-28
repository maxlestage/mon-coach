import Foundation
import MonCoachKit

/// Les exemples que le site affiche, produits par le moteur.
///
/// Le site montrait jusqu'ici des principes ; il montre maintenant ce que
/// l'application produit vraiment. Écrire ces exemples à la main dans le site
/// aurait été plus rapide et faux dès la première modification du moteur :
/// ici, la CI régénère le fichier et échoue s'il a bougé, exactement comme
/// pour les valeurs de référence.
enum SiteExamples {

    // MARK: - Formes exportées

    struct Payload: Encodable {
        var athlete: Athlete
        var nutrition: Nutrition
        var day: Day
        var technique: Technique
        var substitution: SubstitutionExample
    }

    struct Athlete: Encodable {
        var sex: String
        var age: Int
        var heightCm: Double
        var weightKg: Double
        var bodyFatPercent: Double
        var goal: LocalizedText
        var daysPerWeek: Int
        var diet: LocalizedText
    }

    struct Nutrition: Encodable {
        var calories: Int
        var proteinG: Int
        var carbsG: Int
        var fatG: Int
    }

    struct Day: Encodable {
        var meals: [MealOut]
        var notes: [LocalizedText]
        var totalKcal: Int
        var totalProteinG: Int
        var totalFiberG: Int
    }

    struct MealOut: Encodable {
        var slot: LocalizedText
        var kcal: Int
        var proteinG: Int
        var note: LocalizedText?
        var items: [ItemOut]
    }

    struct ItemOut: Encodable {
        var name: LocalizedText
        var grams: Int
        var tier: String
        var reason: LocalizedText
    }

    struct Technique: Encodable {
        var exercise: LocalizedText
        var title: LocalizedText
        var oneThing: LocalizedText
        var breathing: LocalizedText
        var tempo: LocalizedText
        var easier: LocalizedText?
        var harder: LocalizedText?
        var steps: [StepOut]
        var mistakes: [MistakeOut]
    }

    struct StepOut: Encodable {
        var index: Int
        var title: LocalizedText
        var detail: LocalizedText
        var checkpoint: LocalizedText?
    }

    struct MistakeOut: Encodable {
        var symptom: LocalizedText
        var cause: LocalizedText
        var fix: LocalizedText
    }

    struct SubstitutionExample: Encodable {
        var exercise: LocalizedText
        var muscle: LocalizedText
        var busyEquipment: [LocalizedText]
        var headline: LocalizedText
        var detail: LocalizedText
        var options: [OptionOut]
    }

    struct OptionOut: Encodable {
        var name: LocalizedText
        var equipment: [LocalizedText]
        var closeness: Int
        var reason: LocalizedText
    }

    // MARK: - Construction

    /// L'athlète des exemples : le même que l'aperçu de la page d'accueil,
    /// pour que les chiffres du site racontent une seule histoire.
    static func athlete() -> UserProfile {
        var profile = UserProfile(
            firstName: "Exemple",
            birthDate: Calendar(identifier: .gregorian)
                .date(from: DateComponents(year: 1996, month: 3, day: 12))!,
            sex: .male,
            heightCm: 178,
            weightKg: 78,
            bodyFatPercent: 16,
            trainingMonths: 30,
            goal: .hypertrophy,
            daysPerWeek: 4,
            sessionMinutes: 70,
            equipment: Equipment.fullGym,
            activityLevel: .light,
            averageSleepHours: 7.5,
            stressLevel: 3
        )
        profile.mealsPerDay = 4
        return profile
    }

    static func build(on date: Date, calendar: Calendar) -> Payload {
        let profile = athlete()
        let metrics = BodyMetricsEngine.metrics(for: profile, on: date)
        let target = NutritionEngine.target(for: profile, metrics: metrics)
        let plan = MealPlanner.day(
            target: target,
            diet: profile.dietPreference,
            dayIndex: 2,
            mealsPerDay: profile.mealCount,
            trainsToday: true
        )
        let totals = plan.macros

        let meals = plan.meals.map { meal in
            MealOut(
                slot: meal.slot.label,
                kcal: Int(meal.macros.kcal.rounded()),
                proteinG: Int(meal.macros.proteinG.rounded()),
                note: meal.note,
                items: meal.items.compactMap { item in
                    guard let food = item.food else { return nil }
                    return ItemOut(
                        name: food.name,
                        grams: Int(item.grams.rounded()),
                        tier: food.tier.rawValue,
                        reason: food.reason
                    )
                }
            )
        }

        // Le squat : le mouvement que les débutants ratent le plus, et celui
        // dont la fiche est la plus complète.
        let squat = ExerciseCatalog.exercise(id: "back-squat")!
        let sheet = GuidedCatalog.technique(for: squat)

        // Le développé couché avec la barre et le banc pris : la situation la
        // plus banale d'une salle à dix-huit heures.
        let bench = ExerciseCatalog.exercise(id: "bench-press")!
        let answer = GymCoach.answer(to: .equipmentBusy, exercise: bench, profile: profile)

        return Payload(
            athlete: Athlete(
                sex: profile.sex.label.fr == "Homme" ? "male" : "female",
                age: profile.age(on: date, calendar: calendar),
                heightCm: profile.heightCm,
                weightKg: profile.weightKg,
                bodyFatPercent: profile.bodyFatPercent ?? 0,
                goal: profile.goal.label,
                daysPerWeek: profile.daysPerWeek,
                diet: profile.dietPreference.label
            ),
            nutrition: Nutrition(
                calories: target.calories,
                proteinG: target.proteinG,
                carbsG: target.carbsG,
                fatG: target.fatG
            ),
            day: Day(
                meals: meals,
                notes: plan.notes,
                totalKcal: Int(totals.kcal.rounded()),
                totalProteinG: Int(totals.proteinG.rounded()),
                totalFiberG: Int(totals.fiberG.rounded())
            ),
            technique: Technique(
                exercise: squat.name,
                title: sheet.title,
                oneThing: sheet.oneThing,
                breathing: sheet.breathing,
                tempo: sheet.tempo,
                easier: sheet.easier,
                harder: sheet.harder,
                steps: sheet.steps.map {
                    StepOut(index: $0.index, title: $0.title, detail: $0.detail, checkpoint: $0.checkpoint)
                },
                mistakes: sheet.mistakes.map {
                    MistakeOut(symptom: $0.symptom, cause: $0.cause, fix: $0.fix)
                }
            ),
            substitution: SubstitutionExample(
                exercise: bench.name,
                muscle: bench.primaryMuscle.label,
                busyEquipment: bench.equipment.map(\.label).sortedStably(),
                headline: answer.headline,
                detail: answer.detail,
                options: answer.substitutions.map { option in
                    OptionOut(
                        name: option.exercise.name,
                        equipment: option.exercise.equipment.map(\.label).sortedStably(),
                        closeness: option.closeness,
                        reason: option.reason
                    )
                }
            )
        )
    }
}
