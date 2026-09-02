import Foundation
import Observation
import MonCoachKit

#if canImport(HealthKit)
import HealthKit
import WatchKit

/// La session d'entraînement de la montre, pour tous les sports.
///
/// Ce qu'elle change
/// -----------------
/// Sans elle, la montre était une application comme une autre : suspendue
/// quelques secondes après que le poignet baisse. Le GPS se taisait, le
/// chrono se figeait, et le capteur cardiaque — qui ne mesure en continu
/// que pendant un entraînement déclaré — ne donnait rien. C'est ce qui
/// faisait dire que « ça ne marche pas » : ça marchait tant qu'on regardait
/// l'écran, et une sortie ne se fait pas en regardant l'écran.
///
/// La session tient l'application éveillée du départ à l'arrivée, allume
/// le capteur cardiaque, mesure la dépense, et pour les sports sans GPS —
/// tapis, rameur, natation — la distance que la montre sait estimer
/// d'elle-même. À la fin, l'entraînement est enregistré dans Santé pour que
/// les anneaux se ferment : c'est ce qu'attend quiconque porte une montre,
/// et c'est la seule chose que l'application y écrit.
///
/// Le GPS reste au `LocationTracker` : la trace, les kilomètres et le
/// dénivelé d'une sortie dehors viennent de lui, comme sur le téléphone.
/// La session lui donne simplement le droit de continuer écran éteint.
@MainActor
@Observable
final class WatchWorkout: NSObject {

    enum Phase: Equatable {
        case idle
        case starting
        case running
        case paused
        case ended
        /// HealthKit absent ou refusé : la sortie continue sans lui, au
        /// chrono et au GPS, comme avant.
        case unavailable
    }

    private(set) var phase: Phase = .idle
    private(set) var sport: Sport = .run
    private(set) var startedAt: Date?

    /// Le dernier battement vu. Zéro tant que le capteur n'a rien dit.
    private(set) var heartRateBpm: Double = 0
    private(set) var samples: [HeartRateSample] = []
    /// La dépense active depuis le départ, en kilocalories.
    private(set) var kilocalories: Double = 0
    /// La distance que la montre mesure elle-même, en mètres — foulée,
    /// cadence, longueurs de bassin. Zéro pour ce qu'elle ne sait pas
    /// mesurer.
    private(set) var measuredMeters: Double = 0
    /// Le temps d'effort, pauses exclues, relu chaque seconde.
    private(set) var elapsedSeconds: TimeInterval = 0

    private let healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var clock: Timer?

    static var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Départ

    func start(sport: Sport) async {
        self.sport = sport
        heartRateBpm = 0
        samples = []
        kilocalories = 0
        measuredMeters = 0
        elapsedSeconds = 0
        startedAt = Date()

        guard Self.isAvailable else {
            phase = .unavailable
            return
        }
        phase = .starting

        // Ce qu'on lit et ce qu'on écrit, dit une fois. L'entraînement
        // lui-même est la seule écriture ; les mesures sont lues.
        var toRead: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
        ]
        if let distance = sport.workoutDistanceType {
            toRead.insert(HKQuantityType(distance))
        }
        let toShare: Set<HKSampleType> = [HKObjectType.workoutType()]

        do {
            try await healthStore.requestAuthorization(toShare: toShare, read: toRead)

            let configuration = HKWorkoutConfiguration()
            configuration.activityType = sport.workoutActivityType
            configuration.locationType = sport.workoutLocationType
            switch sport {
            case .swim:
                // Sans longueur de bassin, la montre ne compte pas les
                // longueurs. Vingt-cinq mètres est le bassin le plus courant ;
                // un nageur de cinquante mètres verra sa distance doublée,
                // ce qui reste plus juste que zéro.
                configuration.swimmingLocationType = .pool
                configuration.lapLength = HKQuantity(unit: .meter(), doubleValue: 25)
            case .openWaterSwim:
                configuration.swimmingLocationType = .openWater
            default:
                break
            }

            let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            let builder = session.associatedWorkoutBuilder()
            builder.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )
            session.delegate = self
            builder.delegate = self
            self.session = session
            self.builder = builder

            let start = Date()
            session.startActivity(with: start)
            try await builder.beginCollection(at: start)
            startedAt = start
            phase = .running
            startClock()

            // Dans l'eau, l'écran tactile n'obéit plus qu'aux gouttes : on
            // le verrouille, comme le fait l'application Exercice.
            if sport == .swim || sport == .openWaterSwim {
                WKInterfaceDevice.current().enableWaterLock()
            }
        } catch {
            // Refusé ou indisponible : la sortie se mesure quand même, au
            // GPS et au chrono. Ce qui manque, c'est le cardio, la dépense
            // et l'écran éteint — pas la sortie.
            phase = .unavailable
        }
    }

    // MARK: - Pause et reprise

    func pause() {
        guard phase == .running else { return }
        session?.pause()
        phase = .paused
    }

    func resume() {
        guard phase == .paused else { return }
        session?.resume()
        phase = .running
    }

    // MARK: - Fin

    /// Termine l'entraînement et l'enregistre dans Santé.
    ///
    /// L'enregistrement est ce qui ferme les anneaux. Il ne se fait pas
    /// sous une minute : une session ouverte par erreur n'a rien à faire
    /// dans l'historique de Santé.
    func finish() async {
        stopClock()
        guard let session, let builder else {
            phase = .ended
            return
        }
        let end = Date()
        session.end()
        do {
            try await builder.endCollection(at: end)
            if elapsedSeconds >= 60 {
                _ = try await builder.finishWorkout()
            } else {
                builder.discardWorkout()
            }
        } catch {
            builder.discardWorkout()
        }
        phase = .ended
        self.session = nil
        self.builder = nil
    }

    /// Abandonne sans rien écrire dans Santé.
    func discard() {
        stopClock()
        guard let session, let builder else {
            phase = .ended
            return
        }
        session.end()
        Task { @MainActor in
            try? await builder.endCollection(at: Date())
            builder.discardWorkout()
        }
        phase = .ended
        self.session = nil
        self.builder = nil
    }

    /// Rend les battements accumulés et repart de zéro.
    func drainSamples() -> [HeartRateSample] {
        defer { samples = [] }
        return samples
    }

    // MARK: - Le chrono

    /// Le temps d'effort est relu au constructeur d'entraînement plutôt
    /// qu'incrémenté : c'est lui qui sait quand la session était en pause,
    /// et un compteur maison finirait par diverger de ce que Santé montre.
    private func startClock() {
        stopClock()
        clock = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let builder = self.builder else { return }
                self.elapsedSeconds = builder.elapsedTime
            }
        }
    }

    private func stopClock() {
        clock?.invalidate()
        clock = nil
        if let builder { elapsedSeconds = builder.elapsedTime }
    }

    // MARK: - Ce qui arrive du capteur

    fileprivate func ingest(heartRate bpm: Double, at date: Date) {
        heartRateBpm = bpm
        samples.append(HeartRateSample(timestamp: date, bpm: bpm))
    }

    fileprivate func ingest(kilocalories: Double) {
        self.kilocalories = kilocalories
    }

    fileprivate func ingest(meters: Double) {
        measuredMeters = meters
    }

    fileprivate func sessionChanged(to state: HKWorkoutSessionState) {
        switch state {
        case .running: if phase == .starting || phase == .paused { phase = .running }
        case .paused: phase = .paused
        case .ended, .stopped: if phase != .unavailable { phase = .ended }
        default: break
        }
    }
}

// MARK: - Délégués

extension WatchWorkout: HKWorkoutSessionDelegate {

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in self.sessionChanged(to: toState) }
    }

    nonisolated func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: any Error) {
        // Une erreur de session ne vaut pas une sortie perdue : le GPS et
        // le chrono continuent. On note seulement que Santé n'est plus là.
        Task { @MainActor in
            if self.phase != .ended { self.phase = .unavailable }
        }
    }
}

extension WatchWorkout: HKLiveWorkoutBuilderDelegate {

    nonisolated func workoutBuilder(
        _ workoutBuilder: HKLiveWorkoutBuilder,
        didCollectDataOf collectedTypes: Set<HKSampleType>
    ) {
        // Les statistiques se lisent ici, hors de l'acteur principal, et
        // seules les valeurs — des nombres et une date — traversent.
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType,
                  let statistics = workoutBuilder.statistics(for: quantityType)
            else { continue }

            switch quantityType.identifier {
            case HKQuantityTypeIdentifier.heartRate.rawValue:
                let unit = HKUnit.count().unitDivided(by: .minute())
                if let bpm = statistics.mostRecentQuantity()?.doubleValue(for: unit) {
                    let date = statistics.mostRecentQuantityDateInterval()?.end ?? Date()
                    Task { @MainActor in self.ingest(heartRate: bpm, at: date) }
                }
            case HKQuantityTypeIdentifier.activeEnergyBurned.rawValue:
                if let kcal = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) {
                    Task { @MainActor in self.ingest(kilocalories: kcal) }
                }
            default:
                // Toute autre grandeur collectée est une distance : c'est la
                // seule autre chose qu'on a demandée.
                if let meters = statistics.sumQuantity()?.doubleValue(for: .meter()) {
                    Task { @MainActor in self.ingest(meters: meters) }
                }
            }
        }
    }

    nonisolated func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {}
}

#else

/// Sans HealthKit — sur une plateforme de test — la session n'existe pas,
/// et l'écran fait comme si elle était indisponible.
@MainActor
@Observable
final class WatchWorkout {
    enum Phase: Equatable { case idle, starting, running, paused, ended, unavailable }
    private(set) var phase: Phase = .idle
    private(set) var sport: Sport = .run
    private(set) var startedAt: Date?
    private(set) var heartRateBpm: Double = 0
    private(set) var samples: [HeartRateSample] = []
    private(set) var kilocalories: Double = 0
    private(set) var measuredMeters: Double = 0
    private(set) var elapsedSeconds: TimeInterval = 0
    static var isAvailable: Bool { false }
    func start(sport: Sport) async { self.sport = sport; startedAt = Date(); phase = .unavailable }
    func pause() {}
    func resume() {}
    func finish() async { phase = .ended }
    func discard() { phase = .ended }
    func drainSamples() -> [HeartRateSample] { [] }
}

#endif
