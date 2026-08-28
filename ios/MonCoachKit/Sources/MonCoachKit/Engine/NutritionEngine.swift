import Foundation

/// Daily nutrition target attached to a plan.
public struct NutritionTarget: Sendable, Equatable {
    public let calories: Int
    public let proteinG: Int
    public let fatG: Int
    public let carbsG: Int
    /// Body-weight change the target is aiming for, kg per week.
    /// Negative for a cut, positive for a lean bulk, zero when holding.
    public let weeklyWeightChangeKg: Double
    public let maintenanceCalories: Int
    public let rationale: [LocalizedText]

    public var proteinKcal: Int { proteinG * 4 }
    public var fatKcal: Int { fatG * 9 }
    public var carbsKcal: Int { carbsG * 4 }
}

/// Turns body metrics plus a goal into calories and macros.
public enum NutritionEngine {

    public static func target(for profile: UserProfile, metrics: BodyMetrics) -> NutritionTarget {
        let maintenance = metrics.tdee
        var rationale: [LocalizedText] = []

        // Rate of change is expressed as a share of body weight per week so
        // that it stays sane at 55 kg and at 110 kg.
        let weeklyChangeKg: Double
        switch profile.goal {
        case .fatLoss:
            // Leaner athletes must go slower or they pay for it in lean mass.
            let rate = (profile.bodyFatPercent ?? 22) < 15 ? 0.005 : 0.0075
            weeklyChangeKg = -profile.weightKg * rate
            rationale.append(
                LocalizedText(
                    fr: "Déficit calibré pour perdre environ \(String(format: "%.1f", abs(weeklyChangeKg))) kg par semaine, soit le rythme qui préserve le mieux la masse musculaire.",
                    en: "Deficit set to lose about \(String(format: "%.1f", abs(weeklyChangeKg))) kg a week, the rate that best preserves muscle.",
                    es: "Déficit calibrado para perder unos \(String(format: "%.1f", abs(weeklyChangeKg))) kg por semana, el ritmo que mejor preserva el músculo."
                )
            )
        case .hypertrophy:
            let rate = profile.experience == .beginner ? 0.0035 : 0.002
            weeklyChangeKg = profile.weightKg * rate
            rationale.append(
                LocalizedText(
                    fr: "Léger surplus : viser plus de \(String(format: "%.1f", weeklyChangeKg)) kg par semaine ferait surtout gagner du gras.",
                    en: "A small surplus: aiming for more than \(String(format: "%.1f", weeklyChangeKg)) kg a week would mostly add fat.",
                    es: "Superávit ligero: buscar más de \(String(format: "%.1f", weeklyChangeKg)) kg por semana añadiría sobre todo grasa."
                )
            )
        case .strength:
            weeklyChangeKg = profile.weightKg * 0.0015
            rationale.append(
                LocalizedText(
                    fr: "Surplus minime : assez pour soutenir la récupération sans alourdir les mouvements au poids de corps.",
                    en: "A minimal surplus: enough to support recovery without weighing down your bodyweight work.",
                    es: "Superávit mínimo: suficiente para sostener la recuperación sin lastrar los movimientos con peso corporal."
                )
            )
        case .recomposition:
            weeklyChangeKg = 0
            rationale.append(
                LocalizedText(
                    fr: "Calories de maintien : la recomposition se joue sur les protéines et la progression à l'entraînement, pas sur le déficit.",
                    en: "Maintenance calories: recomposition is won on protein and training progress, not on a deficit.",
                    es: "Calorías de mantenimiento: la recomposición se juega en la proteína y en la progresión del entrenamiento, no en el déficit."
                )
            )
        case .generalHealth:
            weeklyChangeKg = 0
            rationale.append(
                LocalizedText(
                    fr: "Calories de maintien, l'objectif étant la régularité plutôt qu'une variation de poids.",
                    en: "Maintenance calories, since the goal is consistency rather than a change in weight.",
                    es: "Calorías de mantenimiento, ya que el objetivo es la constancia y no un cambio de peso."
                )
            )
        }

        // 7 700 kcal ≈ 1 kg of body mass.
        let dailyDelta = weeklyChangeKg * 7_700 / 7
        var calories = maintenance + dailyDelta

        // Never prescribe below a floor: 22 kcal per kg of lean mass, and
        // never under 1 200 kcal outright.
        let floor = max(1_200, metrics.leanBodyMassKg * 22)
        if calories < floor {
            calories = floor
            rationale.append(
                LocalizedText(
                    fr: "Le déficit a été plafonné : descendre plus bas compromettrait la récupération et les apports en micronutriments.",
                    en: "The deficit was capped: going lower would compromise recovery and micronutrient intake.",
                    es: "El déficit se ha limitado: bajar más comprometería la recuperación y el aporte de micronutrientes."
                )
            )
        }

        // Protein: on lean mass, pushed up in a deficit where it protects muscle.
        let proteinPerKgLean: Double = switch profile.goal {
        case .fatLoss: 2.6
        case .recomposition: 2.4
        case .hypertrophy, .strength: 2.2
        case .generalHealth: 1.8
        }
        let proteinG = metrics.leanBodyMassKg * proteinPerKgLean

        // Fat: 0.8 g/kg body weight, but never below 20 % of calories.
        var fatG = profile.weightKg * 0.8
        let minFatG = calories * 0.20 / 9
        fatG = max(fatG, minFatG)

        // Carbs take whatever is left.
        var carbsG = (calories - proteinG * 4 - fatG * 9) / 4
        if carbsG < 50 {
            // Aggressive cuts can squeeze carbs out; trim fat back instead.
            let deficit = (50 - carbsG) * 4
            fatG = max(profile.weightKg * 0.5, fatG - deficit / 9)
            carbsG = (calories - proteinG * 4 - fatG * 9) / 4
            rationale.append(
                LocalizedText(
                    fr: "Les lipides ont été réduits au minimum physiologique pour garder assez de glucides autour des séances.",
                    en: "Fat was cut to the physiological minimum to keep enough carbohydrate around training.",
                    es: "Las grasas se han reducido al mínimo fisiológico para mantener hidratos suficientes alrededor del entrenamiento."
                )
            )
        }
        carbsG = max(carbsG, 30)

        rationale.append(
                LocalizedText(
                    fr: "\(Int(proteinG.rounded())) g de protéines, soit \(String(format: "%.1f", proteinPerKgLean)) g par kg de masse maigre : c'est le levier numéro un, avant même le total calorique.",
                    en: "\(Int(proteinG.rounded())) g of protein, or \(String(format: "%.1f", proteinPerKgLean)) g per kg of lean mass: the number-one lever, ahead of the calorie total itself.",
                    es: "\(Int(proteinG.rounded())) g de proteína, es decir \(String(format: "%.1f", proteinPerKgLean)) g por kg de masa magra: la palanca número uno, por delante del total calórico."
                )
            )

        if profile.dietPreference == .vegan || profile.dietPreference == .vegetarian {
            rationale.append(
                LocalizedText(
                    fr: "Régime sans viande : répartis les protéines sur 4 prises et combine légumineuses et céréales pour couvrir tous les acides aminés.",
                    en: "Meat-free diet: spread protein over four servings and combine pulses with grains to cover every amino acid.",
                    es: "Dieta sin carne: reparte la proteína en cuatro tomas y combina legumbres con cereales para cubrir todos los aminoácidos."
                )
            )
        }

        return NutritionTarget(
            calories: Int(calories.rounded()),
            proteinG: Int(proteinG.rounded()),
            fatG: Int(fatG.rounded()),
            carbsG: Int(carbsG.rounded()),
            weeklyWeightChangeKg: weeklyChangeKg,
            maintenanceCalories: Int(maintenance.rounded()),
            rationale: rationale
        )
    }

    /// Weeks needed to reach the target weight at the prescribed rate.
    /// Nil when no target is set or the target is already met.
    public static func weeksToTarget(profile: UserProfile, target: NutritionTarget) -> Int? {
        guard let goalWeight = profile.targetWeightKg else { return nil }
        let delta = goalWeight - profile.weightKg
        guard abs(delta) > 0.5, target.weeklyWeightChangeKg != 0 else { return nil }
        // Moving the wrong way means the goal and the target disagree.
        guard delta.sign == target.weeklyWeightChangeKg.sign else { return nil }
        return Int((delta / target.weeklyWeightChangeKg).rounded(.up))
    }
}
