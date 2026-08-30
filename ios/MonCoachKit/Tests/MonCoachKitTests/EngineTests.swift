import Foundation
import Testing
@testable import MonCoachKit

@Suite("Métriques corporelles")
struct BodyMetricsTests {

    @Test("Mifflin-St Jeor tombe sur la valeur de référence")
    func mifflinReference() {
        // 78 kg, 178 cm, 30 ans, homme → 10*78 + 6.25*178 - 5*30 + 5 = 1747.5
        var profile = Fixtures.intermediate()
        profile.bodyFatPercent = nil
        let bmr = BodyMetricsEngine.mifflinStJeor(profile: profile, age: 30)
        #expect(abs(bmr - 1747.5) < 0.01)
    }

    @Test("Katch-McArdle prend le relais dès que le taux de gras est connu")
    func katchWhenBodyFatKnown() {
        let profile = Fixtures.intermediate()   // 16 % de gras
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        #expect(!metrics.leanMassIsEstimated)
        // 78 kg à 16 % → 65,52 kg de masse maigre → 370 + 21,6 × 65,52
        #expect(abs(metrics.leanBodyMassKg - 65.52) < 0.01)
        #expect(abs(metrics.bmr - (370 + 21.6 * 65.52)) < 0.01)
    }

    @Test("La masse maigre est estimée quand le taux de gras est inconnu")
    func boerFallback() {
        var profile = Fixtures.intermediate()
        profile.bodyFatPercent = nil
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        #expect(metrics.leanMassIsEstimated)
        #expect(metrics.ffmi == nil)
        #expect(metrics.leanBodyMassKg > 40 && metrics.leanBodyMassKg < profile.weightKg)
    }

    @Test("Plus de séances par semaine augmente la dépense totale")
    func trainingRaisesTDEE() {
        let three = BodyMetricsEngine.metrics(for: Fixtures.intermediate(daysPerWeek: 3), on: Fixtures.start)
        let six = BodyMetricsEngine.metrics(for: Fixtures.intermediate(daysPerWeek: 6), on: Fixtures.start)
        #expect(six.tdee > three.tdee)
    }
}

@Suite("Nutrition")
struct NutritionTests {

    @Test("La perte de gras produit un déficit, la prise de muscle un surplus")
    func caloriesFollowGoal() {
        for (goal, expectation) in [
            (PrimaryGoal.fatLoss, -1),
            (PrimaryGoal.hypertrophy, 1),
            (PrimaryGoal.recomposition, 0)
        ] {
            let profile = Fixtures.intermediate(goal: goal)
            let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
            let target = NutritionEngine.target(for: profile, metrics: metrics)
            let delta = target.calories - target.maintenanceCalories
            switch expectation {
            case -1: #expect(delta < -100, "\(goal) devrait être en déficit")
            case 1: #expect(delta > 50, "\(goal) devrait être en léger surplus")
            default: #expect(abs(delta) <= 25, "\(goal) devrait être au maintien")
            }
        }
    }

    @Test("Les macros couvrent exactement le total calorique")
    func macrosAddUp() {
        for goal in PrimaryGoal.allCases {
            let profile = Fixtures.intermediate(goal: goal)
            let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
            let target = NutritionEngine.target(for: profile, metrics: metrics)
            let sum = target.proteinKcal + target.fatKcal + target.carbsKcal
            // Les grammes sont arrondis : on tolère l'erreur d'arrondi.
            #expect(abs(sum - target.calories) <= 15, "\(goal) : \(sum) vs \(target.calories)")
        }
    }

    @Test("Les protéines sont plus hautes en déficit qu'en prise de masse")
    func proteinHigherInDeficit() {
        let metrics = BodyMetricsEngine.metrics(for: Fixtures.intermediate(), on: Fixtures.start)
        let cut = NutritionEngine.target(for: Fixtures.intermediate(goal: .fatLoss), metrics: metrics)
        let bulk = NutritionEngine.target(for: Fixtures.intermediate(goal: .hypertrophy), metrics: metrics)
        #expect(cut.proteinG > bulk.proteinG)
    }

    @Test("Un plancher calorique protège les régimes trop agressifs")
    func calorieFloor() {
        var profile = Fixtures.intermediate(goal: .fatLoss)
        profile.weightKg = 48
        profile.heightCm = 150
        profile.bodyFatPercent = 10
        profile.activityLevel = .sedentary
        profile.sessionMinutes = 30
        profile.daysPerWeek = 2
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        let target = NutritionEngine.target(for: profile, metrics: metrics)
        #expect(target.calories >= 1_200)
        #expect(target.carbsG >= 30)
    }

    @Test("Le délai jusqu'à l'objectif suit le rythme prescrit")
    func weeksToTarget() {
        var profile = Fixtures.intermediate(goal: .fatLoss)
        profile.targetWeightKg = 72   // −6 kg
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        let target = NutritionEngine.target(for: profile, metrics: metrics)
        let weeks = NutritionEngine.weeksToTarget(profile: profile, target: target)
        #expect(weeks != nil)
        #expect(weeks! >= 8 && weeks! <= 20, "attendu ~10 semaines, obtenu \(weeks!)")
    }

    @Test("Un objectif de poids incohérent avec le but ne renvoie pas de délai")
    func contradictoryTarget() {
        var profile = Fixtures.intermediate(goal: .fatLoss)
        profile.targetWeightKg = 90   // vouloir grossir tout en perdant du gras
        let metrics = BodyMetricsEngine.metrics(for: profile, on: Fixtures.start)
        let target = NutritionEngine.target(for: profile, metrics: metrics)
        #expect(NutritionEngine.weeksToTarget(profile: profile, target: target) == nil)
    }
}

@Suite("Volume hebdomadaire")
struct VolumeTests {

    @Test("Un débutant reçoit moins de volume qu'un intermédiaire")
    func beginnerGetsLess() {
        var beginner = Fixtures.intermediate()
        beginner.experience = .beginner
        var advanced = Fixtures.intermediate()
        advanced.experience = .advanced
        let low = VolumeEngine.prescription(for: beginner).total
        let high = VolumeEngine.prescription(for: advanced).total
        #expect(low < high)
    }

    @Test("Le manque de sommeil réduit le volume prescrit")
    func sleepReducesVolume() {
        var rested = Fixtures.intermediate()
        rested.averageSleepHours = 8.5
        var tired = Fixtures.intermediate()
        tired.averageSleepHours = 5.0
        #expect(VolumeEngine.prescription(for: tired).recoveryFactor
                < VolumeEngine.prescription(for: rested).recoveryFactor)
    }

    @Test("Des séances courtes plafonnent le volume total")
    func sessionLengthCapsVolume() {
        let short = VolumeEngine.prescription(for: Fixtures.intermediate(daysPerWeek: 3, sessionMinutes: 30))
        let long = VolumeEngine.prescription(for: Fixtures.intermediate(daysPerWeek: 3, sessionMinutes: 90))
        #expect(short.total < long.total)
        #expect(short.total <= VolumeEngine.weeklySetCapacity(for: Fixtures.intermediate(daysPerWeek: 3, sessionMinutes: 30)) + 14)
    }

    @Test("Chaque groupe musculaire principal reçoit au moins deux séries")
    func primaryMusclesAreNeverAbandoned() {
        let prescription = VolumeEngine.prescription(for: Fixtures.intermediate(daysPerWeek: 2, sessionMinutes: 30))
        for muscle in MuscleGroup.primary {
            #expect(prescription.sets(for: muscle) >= 2, "\(muscle) est tombé à \(prescription.sets(for: muscle))")
        }
    }
}

@Suite("Structure de la semaine")
struct SplitTests {

    @Test("Le découpage suit le nombre de séances")
    func splitSelection() {
        #expect(SplitPlanner.split(for: Fixtures.intermediate(daysPerWeek: 2)) == .fullBody)
        #expect(SplitPlanner.split(for: Fixtures.intermediate(daysPerWeek: 3)) == .fullBody)
        #expect(SplitPlanner.split(for: Fixtures.intermediate(daysPerWeek: 4)) == .upperLower)
        #expect(SplitPlanner.split(for: Fixtures.intermediate(daysPerWeek: 5)) == .pushPullLegsUpperLower)
        #expect(SplitPlanner.split(for: Fixtures.intermediate(daysPerWeek: 6)) == .pushPullLegs)
    }

    @Test("Le nombre de jours correspond toujours à la disponibilité")
    func dayCountMatches() {
        for days in 2...7 {
            let profile = Fixtures.intermediate(daysPerWeek: days)
            let split = SplitPlanner.split(for: profile)
            #expect(SplitPlanner.days(for: split, daysPerWeek: days).count == days)
        }
    }

    @Test("La répartition ne perd pas de séries et n'en invente pas")
    func distributionConservesVolume() {
        let profile = Fixtures.intermediate(daysPerWeek: 4)
        let volume = VolumeEngine.prescription(for: profile)
        let days = SplitPlanner.days(for: .upperLower, daysPerWeek: 4)
        let distributed = SplitPlanner.distribute(volume: volume, across: days)

        for muscle in MuscleGroup.allCases {
            let assigned = distributed.reduce(0) { $0 + ($1[muscle] ?? 0) }
            let owners = days.filter { $0.muscles.contains(muscle) }.count
            if owners == 0 {
                #expect(assigned == 0, "\(muscle) reçoit des séries sans jour attitré")
            } else {
                #expect(assigned == volume.sets(for: muscle), "\(muscle) : \(assigned) réparties pour \(volume.sets(for: muscle)) prévues")
            }
        }
    }

    @Test("Aucun jour ne se retrouve avec une seule série sur un muscle")
    func noOrphanSets() {
        for days in 2...7 {
            let profile = Fixtures.intermediate(daysPerWeek: days)
            let volume = VolumeEngine.prescription(for: profile)
            let templates = SplitPlanner.days(for: SplitPlanner.split(for: profile), daysPerWeek: days)
            for day in SplitPlanner.distribute(volume: volume, across: templates) {
                for (muscle, sets) in day {
                    #expect(sets >= 2, "\(muscle) : \(sets) série isolée")
                }
            }
        }
    }
}
