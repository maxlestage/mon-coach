import Foundation
import HealthKit
import MonCoachKit

/// Lit dans Santé ce que le téléphone ne savait pas encore voir.
///
/// Ce qui manquait
/// ---------------
/// La montre écrivait ses séances dans Santé, et le téléphone n'y lisait
/// rien. Le manque était à sens unique, et il se voyait à trois endroits :
/// on tapait ses heures de sommeil à la main alors que la montre les
/// connaissait, un poids relevé par une balance connectée restait invisible,
/// et une sortie faite avec une autre application n'existait pas — donc ne
/// comptait pas dans la charge de la semaine, donc faussait les poids de la
/// semaine suivante.
///
/// Ce que ce type fait, et ne fait pas
/// -----------------------------------
/// Il traduit, il ne décide pas. Ce qu'on adopte, ce qu'on écarte et ce
/// qu'on ne touche jamais est écrit dans `HealthImport`, qui se teste sur
/// n'importe quelle machine. Ici il n'y a que des requêtes.
///
/// Il ne demande **que la lecture**. L'écriture appartient à la montre, qui
/// enregistre la séance en cours ; le téléphone n'a rien à ajouter dans
/// Santé, et demander un droit dont on ne se sert pas est la meilleure façon
/// de se faire refuser celui dont on se sert.
@MainActor
final class HealthReader {

    private let store = HKHealthStore()

    /// Les noms sous lesquels nos propres enregistrements apparaissent.
    ///
    /// Une séance que nous avons écrite et que nous relirions serait comptée
    /// deux fois. Le nom du bundle serait plus sûr qu'un libellé, mais Santé
    /// expose le nom affiché : on prend les deux formes connues.
    static let ourSources: Set<String> = ["Stride", "Stride Entraînement", "MonCoach"]

    /// Ce qu'on demande à lire. Rien de plus : chaque type en trop est une
    /// case en plus dans l'écran d'autorisation, et une raison de plus de
    /// tout refuser.
    private var readTypes: Set<HKObjectType> {
        var types: Set<HKObjectType> = [HKObjectType.workoutType()]
        if let mass = HKObjectType.quantityType(forIdentifier: .bodyMass) { types.insert(mass) }
        if let sleep = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { types.insert(sleep) }
        return types
    }

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Demande l'accès en lecture.
    ///
    /// Apple ne dit jamais si la lecture a été accordée — c'est délibéré de
    /// leur part : savoir qu'on vous refuse l'accès au poids en apprend déjà
    /// sur vous. On ne peut donc que demander, puis lire : zéro résultat
    /// veut dire « refusé » ou « rien à lire », et rien ne les distingue.
    /// L'écran doit le dire ainsi plutôt que d'annoncer un succès.
    func requestAccess() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            return true
        } catch {
            return false
        }
    }

    // MARK: - Les lectures
    //
    // Chaque requête traduit ses résultats **dans le gestionnaire**, avant de
    // rendre la main. Ce n'est pas un détail de style : un `HKSample` est une
    // classe d'Objective-C que Swift 6 ne laisse pas traverser une frontière
    // de concurrence. Nos propres types, eux, sont de simples valeurs et
    // passent partout. Traduire tôt règle la question une fois pour toutes,
    // au lieu de la contourner à chaque appel.

    func weights(since start: Date) async -> [HealthWeight] {
        guard let type = HKQuantityType.quantityType(forIdentifier: .bodyMass) else { return [] }
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: HKQuery.predicateForSamples(withStart: start, end: Date()),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, _ in
                let samples = (results as? [HKQuantitySample]) ?? []
                continuation.resume(returning: samples.map {
                    HealthWeight(
                        date: $0.startDate,
                        kilograms: $0.quantity.doubleValue(for: .gramUnit(with: .kilo))
                    )
                })
            }
            store.execute(query)
        }
    }

    /// Les nuits, recomposées.
    ///
    /// Santé ne donne pas « sept heures et demie » : elle donne une suite de
    /// morceaux — endormi, sommeil profond, réveillé deux minutes. On
    /// additionne ce qui est du sommeil, et on rattache le total au jour du
    /// réveil, parce que c'est la séance de ce jour-là qui en dépend.
    func nights(since start: Date, calendar: Calendar = .current) async -> [HealthSleep] {
        guard let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return [] }
        let asleep: Set<Int> = [
            HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
            HKCategoryValueSleepAnalysis.asleepCore.rawValue,
            HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
            HKCategoryValueSleepAnalysis.asleepREM.rawValue,
        ]
        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: type,
                predicate: HKQuery.predicateForSamples(withStart: start, end: Date()),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, _ in
                let samples = (results as? [HKCategorySample]) ?? []
                var perDay: [Date: TimeInterval] = [:]
                for sample in samples where asleep.contains(sample.value) {
                    let day = calendar.startOfDay(for: sample.endDate)
                    perDay[day, default: 0] += sample.endDate.timeIntervalSince(sample.startDate)
                }
                continuation.resume(returning: perDay
                    .map { HealthSleep(wakeDate: $0.key, hours: $0.value / 3600) }
                    .sorted { $0.wakeDate < $1.wakeDate })
            }
            store.execute(query)
        }
    }

    func workouts(since start: Date) async -> [HealthWorkout] {
        await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: HKObjectType.workoutType(),
                predicate: HKQuery.predicateForSamples(withStart: start, end: Date()),
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, results, _ in
                let samples = (results as? [HKWorkout]) ?? []
                continuation.resume(returning: samples.map { workout in
                    // La distance vit sous deux clés selon le sport, et sous
                    // aucune pour une séance de salle. Zéro est alors la
                    // réponse juste, pas une mesure manquante.
                    let distance = workout.statistics(for: HKQuantityType(.distanceWalkingRunning))?
                        .sumQuantity()?.doubleValue(for: .meter)
                        ?? workout.statistics(for: HKQuantityType(.distanceCycling))?
                        .sumQuantity()?.doubleValue(for: .meter)
                        ?? 0
                    let energy = workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
                        .sumQuantity()?.doubleValue(for: .kilocalorie())
                    return HealthWorkout(
                        startedAt: workout.startDate,
                        duration: workout.duration,
                        meters: distance,
                        kilocalories: energy,
                        sport: Sport.from(workout.workoutActivityType),
                        source: workout.sourceRevision.source.name
                    )
                })
            }
            store.execute(query)
        }
    }
}
