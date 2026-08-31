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
    /// Vitesse instantanée du dernier point, en m/s. Négative quand le GPS
    /// ne sait pas la donner.
    public private(set) var currentSpeed: Double = -1

    /// Le temps écoulé d'une activité qui ne se déplace pas, en secondes.
    ///
    /// Un rameur, un cours de yoga, une heure de padel : rien à tracer, mais
    /// une durée bien réelle, qui porte à elle seule la dépense et la
    /// charge. Elle est comptée ici plutôt que dans l'écran, pour que la
    /// montre et le téléphone comptent pareil.
    public private(set) var stationarySeconds: TimeInterval = 0
    private var clock: Timer?

    public var type: RunType = .easy
    /// Le sport en cours. Fixé au départ : c'est lui qui décide des seuils.
    public private(set) var sport: Sport = .run
    /// Les seuils de mesure, dérivés du sport plutôt que figés à la création.
    public var filter: TraceFilter { sport.filter }

    private let manager = CLLocationManager()

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        // Absent de watchOS, où CoreLocation ne met jamais les relevés en
        // pause de lui-même : il n'y a rien à désactiver là-bas.
        #if !os(watchOS)
        manager.pausesLocationUpdatesAutomatically = false
        #endif
        configure(for: .run)
    }

    /// Règle CoreLocation pour le sport demandé.
    ///
    /// `distanceFilter` mérite l'attention : il fait taire le GPS tant que
    /// l'appareil n'a pas bougé de tant de mètres. Un mètre convient à la
    /// course, mais un randonneur qui monte à 1,3 km/h ne le franchit qu'au
    /// bout de trois secondes — la trace arrive alors trop clairsemée pour
    /// que l'altitude se lisse ou que l'allure instantanée veuille dire
    /// quelque chose. Pour ce qui se marche, on prend tout.
    private func configure(for sport: Sport) {
        switch sport.mode {
        case .running, .trailRunning:
            manager.activityType = .fitness
            manager.distanceFilter = 1
        case .rolling, .gliding:
            manager.activityType = .otherNavigation
            manager.distanceFilter = 3
        case .walking, .floating:
            manager.activityType = .fitness
            manager.distanceFilter = kCLDistanceFilterNone
        case .stationary:
            // Aucun suivi n'est démarré pour ces sports-là ; ce réglage ne
            // sert que si l'appelant se trompe, et il doit alors coûter le
            // moins de batterie possible.
            manager.activityType = .other
            manager.distanceFilter = 100
        }
    }

    // MARK: - Ce que l'écran lit

    public var meters: Double { trace?.meters ?? 0 }
    public var movingDuration: TimeInterval {
        sport.tracksLocation ? (trace?.movingDuration ?? 0) : stationarySeconds
    }
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
        return TraceMath.pace(
            meters: last.cumulativeMeters - reference.cumulativeMeters,
            seconds: last.cumulativeMovingSeconds - reference.cumulativeMovingSeconds
        )
    }

    public var splits: [Split] {
        guard let trace else { return [] }
        return TraceAnalysis.splits(of: trace, elevationThreshold: filter.elevationThreshold)
    }

    /// Le signal est-il assez bon pour que les chiffres veuillent dire
    /// quelque chose ? Dit franchement plutôt que masqué.
    public var hasUsableSignal: Bool {
        currentAccuracy >= 0 && currentAccuracy <= filter.maxHorizontalAccuracy
    }

    public var isActive: Bool { state == .running || state == .paused }

    /// L'athlète est-il à l'arrêt, feu rouge ou lacet à refaire ?
    ///
    /// Le chrono le sait déjà : le temps en mouvement exclut les arrêts par
    /// construction. Mais un chrono qui se fige sans un mot ressemble à un
    /// bug — cette lecture existe pour que l'écran puisse dire « à l'arrêt,
    /// le chrono attend » pendant que ça arrive. Le seuil est celui d'un pas
    /// très lent : en dessous, on ne se déplace pas, on piétine.
    public var isStationary: Bool {
        state == .running && currentSpeed >= 0 && currentSpeed < 0.5
    }

    // MARK: - Commandes

    public func start(sport: Sport = .run, type: RunType) {
        self.sport = sport
        self.type = type
        configure(for: sport)
        points = []
        trace = nil
        startedAt = Date()
        stationarySeconds = 0

        // Un sport qui ne se déplace pas ne demande ni permission ni GPS.
        // Allumer CoreLocation « au cas où » coûterait la batterie d'une
        // heure de séance pour dessiner une trace immobile, et ferait
        // demander l'accès à la position pour un cours de yoga.
        guard sport.tracksLocation else {
            state = .running
            startClock()
            return
        }

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
        stopClock()
        manager.stopUpdatingLocation()
    }

    public func resume() {
        guard state == .paused else { return }
        guard sport.tracksLocation else {
            state = .running
            startClock()
            return
        }
        beginUpdates()
    }

    /// L'horloge des activités sans trace.
    ///
    /// Une seconde de période, et le temps se relit à l'horloge du système
    /// plutôt que de s'incrémenter : un minuteur que le système retarde —
    /// écran verrouillé, application en arrière-plan — perdrait des
    /// secondes, et une séance d'une heure finirait à cinquante minutes.
    private func startClock() {
        stopClock()
        let base = stationarySeconds
        let from = Date()
        clock = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.state == .running else { return }
                self.stationarySeconds = base + Date().timeIntervalSince(from)
            }
        }
    }

    private func stopClock() {
        clock?.invalidate()
        clock = nil
    }

    /// Arrête la sortie et rend le journal, ou nil si rien n'a été parcouru.
    ///
    /// Une sortie de trente mètres est un démarrage raté, pas une séance :
    /// l'enregistrer polluerait l'historique et fausserait le kilométrage
    /// hebdomadaire dont dépend tout le plan.
    public func finish() -> ActivityLog? {
        manager.stopUpdatingLocation()
        stopClock()
        state = .finished
        guard sport.tracksLocation else {
            // Une minute : le plancher d'un vrai créneau. En dessous, c'est
            // un bouton effleuré en rangeant son téléphone, et une séance de
            // douze secondes dans l'historique fausserait la charge autant
            // qu'elle ferait douter du reste.
            guard stationarySeconds >= 60 else { return nil }
            return ActivityLog(
                startedAt: startedAt ?? Date(),
                sport: sport,
                type: type,
                points: [],
                meters: 0,
                duration: stationarySeconds,
                elevationGain: 0
            )
        }
        let log = TraceAnalysis.summarise(rawPoints: points, sport: sport, type: type)
        return log.meters >= 100 ? log : nil
    }

    public func reset() {
        manager.stopUpdatingLocation()
        stopClock()
        stationarySeconds = 0
        state = .idle
        points = []
        trace = nil
        startedAt = nil
        currentAccuracy = -1
        currentSpeed = -1
    }

    /// L'application déclare-t-elle le mode d'arrière-plan « location » ?
    ///
    /// La question n'a rien de rhétorique. `allowsBackgroundLocationUpdates`
    /// ne se contente pas d'être refusé quand la déclaration manque :
    /// CoreLocation **lève une exception**, et l'application meurt à
    /// l'instant précis où l'athlète appuie sur Démarrer. Sur tout le chemin
    /// de ce bouton, c'est la seule ligne qui puisse lever quoi que ce soit.
    ///
    /// Et la déclaration doit être un *tableau*. Un Info.plist engendré à
    /// partir d'un réglage de projet peut écrire une chaîne à sa place : iOS
    /// ne lit alors aucun mode, le réglage paraît juste et ne l'est pas.
    /// C'est pour ce cas-là que la vérification existe — pas pour le cas où
    /// quelqu'un aurait oublié la ligne.
    public static let declaresBackgroundLocation: Bool = {
        guard let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]
        else { return false }
        return modes.contains("location")
    }()

    private func beginUpdates() {
        state = .running
        // Continuer écran éteint, mais seulement pendant une sortie : le mode
        // « toujours » n'est jamais demandé au démarrage de l'application.
        //
        // Et seulement si l'application a le droit de le demander. Sans la
        // déclaration, mieux vaut une sortie qui s'arrête quand l'écran
        // s'éteint qu'une application qui meurt quand on appuie sur Démarrer.
        if Self.declaresBackgroundLocation {
            manager.allowsBackgroundLocationUpdates = true
        }
        manager.startUpdatingLocation()
    }

    private func ingest(_ locations: [CLLocation]) {
        guard state == .running else { return }
        for location in locations {
            currentAccuracy = location.horizontalAccuracy
            currentSpeed = location.speed
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
        trace = TraceAnalysis.clean(points, filter: filter)
    }
}

extension LocationTracker: CLLocationManagerDelegate {

    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        MainActor.assumeIsolated { ingest(locations) }
    }

    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
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

    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Une erreur ponctuelle n'arrête pas la sortie : CoreLocation en émet
        // au moindre passage sous un tunnel, et perdre l'enregistrement pour
        // ça serait pire que de continuer avec un trou dans la trace.
    }
}


#endif
