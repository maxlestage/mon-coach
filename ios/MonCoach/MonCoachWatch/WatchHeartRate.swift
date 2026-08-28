import Foundation
import MonCoachKit
import Observation

#if canImport(HealthKit)
import HealthKit

/// Le cardio du poignet, pendant une sortie.
///
/// La montre mesure les battements en continu via HealthKit ; ils partent
/// dans le journal de la sortie, et de là au téléphone. Tout reste dans le
/// couple montre-téléphone : HealthKit est une source ici, jamais une
/// destination — l'application n'écrit rien dans Santé.
@MainActor
@Observable
final class WatchHeartRate {

    private(set) var samples: [HeartRateSample] = []
    /// Le dernier battement vu, pour l'affichage en direct. Zéro tant que
    /// le capteur n'a rien dit.
    private(set) var currentBpm: Double = 0

    private let store = HKHealthStore()
    private var query: HKAnchoredObjectQuery?

    func start() {
        guard HKHealthStore.isHealthDataAvailable(),
              let heartRate = HKObjectType.quantityType(forIdentifier: .heartRate)
        else { return }

        store.requestAuthorization(toShare: [], read: [heartRate]) { [weak self] granted, _ in
            guard granted else { return }
            Task { @MainActor [weak self] in
                self?.beginQuery(for: heartRate)
            }
        }
    }

    private func beginQuery(for heartRate: HKQuantityType) {
        // Ancrée à maintenant : les battements d'hier n'appartiennent pas à
        // cette sortie.
        let predicate = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        let handler: @Sendable (
            HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?
        ) -> Void = { [weak self] _, added, _, _, _ in
            guard let added = added as? [HKQuantitySample], !added.isEmpty else { return }
            let unit = HKUnit.count().unitDivided(by: .minute())
            let incoming = added.map {
                HeartRateSample(timestamp: $0.startDate, bpm: $0.quantity.doubleValue(for: unit))
            }
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.samples.append(contentsOf: incoming)
                if let last = incoming.last { self.currentBpm = last.bpm }
            }
        }
        let query = HKAnchoredObjectQuery(
            type: heartRate,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit,
            resultsHandler: handler
        )
        query.updateHandler = handler
        store.execute(query)
        self.query = query
    }

    func stop() {
        if let query { store.stop(query) }
        query = nil
        currentBpm = 0
    }

    /// Rend les battements accumulés et repart de zéro.
    func drain() -> [HeartRateSample] {
        defer { samples = [] }
        return samples
    }
}

#else

/// Sans HealthKit — sur un simulateur minimal ou une plateforme de test —
/// le cardio est simplement absent, et l'écran n'en montre rien.
@MainActor
@Observable
final class WatchHeartRate {
    private(set) var samples: [HeartRateSample] = []
    private(set) var currentBpm: Double = 0
    func start() {}
    func stop() {}
    func drain() -> [HeartRateSample] { [] }
}

#endif
