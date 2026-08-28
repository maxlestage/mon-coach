#if canImport(CoreLocation)

import CoreLocation
import Foundation
import Observation

/// Le suivi GPS d'une sortie en cours.
///
/// Le tracker ne fait qu'une chose : accumuler des points bruts et rendre en
/// continu ce que l'analyse en tire. Toute la mesure — filtrage, distance,
/// dénivelé, découpage — vit ailleurs dans ce paquet, où elle se teste sans
/// iPhone. Ici il ne reste que CoreLocation et le cycle de vie.
///
/// Le fichier entier est encadré par `canImport(CoreLocation)` : le paquet
/// doit continuer à compiler et à se tester sur Linux, où CoreLocation
/// n'existe pas. Le téléphone et la montre partagent ainsi le même tracker
/// au lieu d'en entretenir deux copies qui divergeraient au premier correctif.
@MainActor
@Observable
public final class LocationTracker: NSObject {

    public enum State: Equatable {
        case idle
        case requestingPermission
        case denied
        case running
        case paused
        case finished
    }

    public private(set) var state: State = .idle
    /// La trace brute, jamais amputée : les filtres peuvent changer, les
    /// points d'origine non.
    public private(set) var points: [GPSPoint] = []
    public private(set) var trace: CleanTrace?
    public private(set) var startedAt: Date?
    /// Précision du dernier point reçu, en mètres. Négative tant qu'aucun
    /// point n'est arrivé — c'est ce que l'écran affiche pour dire « je
    /// cherche le signal ».
    public private(set) var currentAccuracy: Double = -1

    public var type: RunType = .easy
    public let filter: TraceFilter

    private let manager = CLLocationManager()

    public init(filter: TraceFilter = .outdoor) {
        self.filter = filter
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        manager.activityType = .fitness
        // Un point par mètre au plus : plus fin, on n'enregistre que du bruit.
        manager.distanceFilter = 1
        manager.pausesLocationUpdatesAutomatically = false
    }

    // MARK: - Ce que l'écran lit

    public var meters: Double { trace?.meters ?? 0 }
    public var movingDuration: TimeInterval { trace?.movingDuration ?? 0 }
    public var elevationGain: Double { trace?.elevationGain ?? 0 }
    public var paceSecondsPerKm: Double { trace?.paceSecondsPerKm ?? 0 }

    /// L'allure des trois cents derniers mètres, celle qu'un coureur regarde.
    ///
    /// L'allure moyenne depuis le départ ne sert à rien pendant l'effort :
    /// elle est déjà figée par les premiers kilomètres et ne réagit plus à ce
    /// qu'on fait maintenant.
    public var recentPaceSecondsPerKm: Double {
        guard let samples = trace?.samples, let last = samples.last else { return 0 }
        let window = 300.0
        guard let reference = samples.last(where: { last.cumulativeMeters - $0.cumulativeMeters >= window })
        else { return paceSecondsPerKm }
        return RunMath.pace(
            meters: last.cumulativeMeters - reference.cumulativeMeters,
            seconds: last.cumulativeMovingSeconds - reference.cumulativeMovingSeconds
        )
    }

    public var splits: [Split] {
        guard let trace else { return [] }
        return RunAnalysis.splits(of: trace, elevationThreshold: filter.elevationThreshold)
    }

    /// Le signal est-il assez bon pour que les chiffres veuillent dire
    /// quelque chose ? Dit franchement plutôt que masqué.
    public var hasUsableSignal: Bool {
        currentAccuracy >= 0 && currentAccuracy <= filter.maxHorizontalAccuracy
    }

    public var isActive: Bool { state == .running || state == .paused }

    // MARK: - Commandes

    public func start(type: RunType) {
        self.type = type
        points = []
        trace = nil
        startedAt = Date()

        switch manager.authorizationStatus {
        case .notDetermined:
            state = .requestingPermission
            manager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            state = .denied
        default:
            beginUpdates()
        }
    }

    public func pause() {
        guard state == .running else { return }
        state = .paused
        manager.stopUpdatingLocation()
    }

    public func resume() {
        guard state == .paused else { return }
        beginUpdates()
    }

    /// Arrête la sortie et rend le journal, ou nil si rien n'a été parcouru.
    ///
    /// Une sortie de trente mètres est un démarrage raté, pas une séance :
    /// l'enregistrer polluerait l'historique et fausserait le kilométrage
    /// hebdomadaire dont dépend tout le plan.
    public func finish() -> RunLog? {
        manager.stopUpdatingLocation()
        state = .finished
        let log = RunAnalysis.summarise(rawPoints: points, type: type, filter: filter)
        return log.meters >= 100 ? log : nil
    }

    public func reset() {
        manager.stopUpdatingLocation()
        state = .idle
        points = []
        trace = nil
        startedAt = nil
        currentAccuracy = -1
    }

    private func beginUpdates() {
        state = .running
        // Continuer écran éteint, mais seulement pendant une sortie : le mode
        // « toujours » n'est jamais demandé au démarrage de l'application.
        manager.allowsBackgroundLocationUpdates = true
        manager.startUpdatingLocation()
    }

    private func ingest(_ locations: [CLLocation]) {
        guard state == .running else { return }
        for location in locations {
            currentAccuracy = location.horizontalAccuracy
            points.append(
                GPSPoint(
                    timestamp: location.timestamp,
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude,
                    altitude: location.altitude,
                    horizontalAccuracy: location.horizontalAccuracy,
                    verticalAccuracy: location.verticalAccuracy
                )
            )
        }
        trace = RunAnalysis.clean(points, filter: filter)
    }
}

extension LocationTracker: CLLocationManagerDelegate {

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated { ingest(locations) }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        MainActor.assumeIsolated {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                if state == .requestingPermission { beginUpdates() }
            case .denied, .restricted:
                state = .denied
            default:
                break
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Une erreur ponctuelle n'arrête pas la sortie : CoreLocation en émet
        // au moindre passage sous un tunnel, et perdre l'enregistrement pour
        // ça serait pire que de continuer avec un trou dans la trace.
    }
}


#endif
