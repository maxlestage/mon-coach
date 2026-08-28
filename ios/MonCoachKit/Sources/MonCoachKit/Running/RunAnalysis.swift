import Foundation

/// Les réglages du filtrage d'une trace GPS.
///
/// Les valeurs par défaut visent la course à pied en extérieur avec le GPS
/// d'un téléphone ou d'une montre. Elles sont volontairement exposées : un
/// trail en forêt et un 400 m sur piste n'ont pas le même bruit.
public struct TraceFilter: Sendable, Equatable {
    /// Précision horizontale au-delà de laquelle un point est jeté, en mètres.
    public var maxHorizontalAccuracy: Double
    /// Vitesse au-delà de laquelle un déplacement est jugé impossible, en m/s.
    /// 12 m/s, c'est 2:19/km : plus rapide que le record du monde du 100 m
    /// tenu sur un kilomètre. Un tel saut est un artefact, pas une foulée.
    public var maxSpeed: Double
    /// En dessous de cette vitesse, on considère l'athlète à l'arrêt, en m/s.
    public var pauseSpeed: Double
    /// Déplacement minimal pour qu'un segment compte, en mètres.
    public var minSegmentMeters: Double
    /// Largeur de la fenêtre de lissage de l'altitude, en nombre de points.
    public var elevationWindow: Int
    /// Écart d'altitude à franchir avant de compter du dénivelé, en mètres.
    public var elevationThreshold: Double

    public init(
        maxHorizontalAccuracy: Double = 25,
        maxSpeed: Double = 12,
        pauseSpeed: Double = 0.5,
        minSegmentMeters: Double = 1,
        elevationWindow: Int = 5,
        elevationThreshold: Double = 1
    ) {
        self.maxHorizontalAccuracy = maxHorizontalAccuracy
        self.maxSpeed = maxSpeed
        self.pauseSpeed = pauseSpeed
        self.minSegmentMeters = minSegmentMeters
        self.elevationWindow = elevationWindow
        self.elevationThreshold = elevationThreshold
    }

    public static let outdoor = TraceFilter()
    /// Plus permissif sur la précision : sous les arbres ou entre les
    /// immeubles, exiger 25 m reviendrait à jeter la sortie entière.
    public static let trail = TraceFilter(maxHorizontalAccuracy: 40, elevationWindow: 7, elevationThreshold: 1.5)
}

/// Un point retenu, enrichi de ce que l'analyse en a déduit.
public struct TraceSample: Sendable, Equatable {
    public var point: GPSPoint
    /// Distance parcourue depuis le départ, en mètres.
    public var cumulativeMeters: Double
    /// Temps en mouvement depuis le départ, pauses exclues.
    public var cumulativeMovingSeconds: TimeInterval
    /// Altitude après lissage, en mètres.
    public var smoothedAltitude: Double
}

/// Une trace nettoyée, avec le compte de ce qui a été écarté.
///
/// Les rejets sont publics et affichés dans l'app : si une sortie annonce
/// 8,2 km au lieu des 9 attendus, l'athlète a le droit de savoir que
/// quarante points ont été jetés pour imprécision.
public struct CleanTrace: Sendable, Equatable {
    public var samples: [TraceSample]
    public var meters: Double
    public var movingDuration: TimeInterval
    public var elapsedDuration: TimeInterval
    public var elevationGain: Double
    public var elevationLoss: Double
    /// Points écartés parce que leur précision annoncée était insuffisante.
    public var rejectedForAccuracy: Int
    /// Points écartés parce que le déplacement impliqué était impossible.
    public var rejectedForSpeed: Int
    /// Points écartés parce qu'ils n'avançaient pas dans le temps.
    public var rejectedForOrder: Int

    public var isEmpty: Bool { samples.count < 2 }
    public var paceSecondsPerKm: Double { RunMath.pace(meters: meters, seconds: movingDuration) }
    /// Part des points d'origine effectivement retenus, 0 à 1.
    public var retention: Double {
        let rejected = rejectedForAccuracy + rejectedForSpeed + rejectedForOrder
        let total = samples.count + rejected
        return total > 0 ? Double(samples.count) / Double(total) : 0
    }
}

/// Transforme une trace GPS brute en sortie exploitable.
public enum RunAnalysis {

    /// Nettoie une trace : ordonne, jette ce qui est faux, mesure le reste.
    public static func clean(_ rawPoints: [GPSPoint], filter: TraceFilter = .outdoor) -> CleanTrace {
        var rejectedForAccuracy = 0
        var rejectedForSpeed = 0
        var rejectedForOrder = 0

        // 1. Précision. Une précision négative signale, côté CoreLocation, une
        //    mesure invalide : ce n'est pas « très précis », c'est « pas de fix ».
        let accurate = rawPoints.filter { point in
            let ok = point.horizontalAccuracy >= 0 && point.horizontalAccuracy <= filter.maxHorizontalAccuracy
            if !ok { rejectedForAccuracy += 1 }
            return ok
        }
        let ordered = accurate.sorted { $0.timestamp < $1.timestamp }

        // 2. Continuité. On avance point par point en gardant le dernier point
        //    accepté comme référence : un saut isolé est écarté sans casser la
        //    suite de la trace.
        var kept: [GPSPoint] = []
        for point in ordered {
            guard let previous = kept.last else {
                kept.append(point)
                continue
            }
            let dt = point.timestamp.timeIntervalSince(previous.timestamp)
            guard dt > 0 else {
                rejectedForOrder += 1
                continue
            }
            let d = RunMath.distance(from: previous, to: point)
            if d / dt > filter.maxSpeed {
                rejectedForSpeed += 1
                continue
            }
            kept.append(point)
        }

        guard kept.count >= 2 else {
            return CleanTrace(
                samples: kept.map {
                    TraceSample(
                        point: $0,
                        cumulativeMeters: 0,
                        cumulativeMovingSeconds: 0,
                        smoothedAltitude: $0.altitude
                    )
                },
                meters: 0,
                movingDuration: 0,
                elapsedDuration: kept.count == 2
                    ? kept[1].timestamp.timeIntervalSince(kept[0].timestamp)
                    : 0,
                elevationGain: 0,
                elevationLoss: 0,
                rejectedForAccuracy: rejectedForAccuracy,
                rejectedForSpeed: rejectedForSpeed,
                rejectedForOrder: rejectedForOrder
            )
        }

        // 3. Altitude lissée sur les points retenus.
        let smoothed = RunMath.movingAverage(
            kept.map(\.altitude),
            window: filter.elevationWindow
        )

        // 4. Cumul. Un segment ne compte que s'il correspond à un vrai
        //    déplacement : sinon c'est l'athlète arrêté et le GPS qui vibre.
        var samples: [TraceSample] = [
            TraceSample(
                point: kept[0],
                cumulativeMeters: 0,
                cumulativeMovingSeconds: 0,
                smoothedAltitude: smoothed[0]
            )
        ]
        var meters = 0.0
        var moving = 0.0
        for index in 1..<kept.count {
            let previous = kept[index - 1]
            let point = kept[index]
            let dt = point.timestamp.timeIntervalSince(previous.timestamp)
            let d = RunMath.distance(from: previous, to: point)
            let isMoving = d >= filter.minSegmentMeters && dt > 0 && d / dt >= filter.pauseSpeed
            if isMoving {
                meters += d
                moving += dt
            }
            samples.append(
                TraceSample(
                    point: point,
                    cumulativeMeters: meters,
                    cumulativeMovingSeconds: moving,
                    smoothedAltitude: smoothed[index]
                )
            )
        }

        let altitudes = samples.map(\.smoothedAltitude)
        let gain = RunMath.elevationGain(
            smoothedAltitudes: altitudes,
            threshold: filter.elevationThreshold
        )
        let loss = RunMath.elevationGain(
            smoothedAltitudes: altitudes.map { -$0 },
            threshold: filter.elevationThreshold
        )

        return CleanTrace(
            samples: samples,
            meters: meters,
            movingDuration: moving,
            elapsedDuration: kept[kept.count - 1].timestamp.timeIntervalSince(kept[0].timestamp),
            elevationGain: gain,
            elevationLoss: loss,
            rejectedForAccuracy: rejectedForAccuracy,
            rejectedForSpeed: rejectedForSpeed,
            rejectedForOrder: rejectedForOrder
        )
    }

    /// Découpe une trace nettoyée en segments d'une distance donnée.
    ///
    /// Le dernier segment est presque toujours incomplet et il est conservé
    /// tel quel : c'est une information, pas un déchet. Son allure reste
    /// juste puisqu'elle est ramenée au kilomètre.
    public static func splits(
        of trace: CleanTrace,
        every distanceMeters: Double = 1_000,
        elevationThreshold: Double = 1
    ) -> [Split] {
        guard distanceMeters > 0, trace.samples.count >= 2, trace.meters > 0 else { return [] }

        var splits: [Split] = []
        var boundaryMeters = distanceMeters
        var splitStartMeters = 0.0
        var splitStartSeconds = 0.0
        var altitudesInSplit: [Double] = [trace.samples[0].smoothedAltitude]

        for index in 1..<trace.samples.count {
            let previous = trace.samples[index - 1]
            let sample = trace.samples[index]
            let segmentMeters = sample.cumulativeMeters - previous.cumulativeMeters
            let segmentSeconds = sample.cumulativeMovingSeconds - previous.cumulativeMovingSeconds

            // Un segment peut franchir plusieurs bornes s'il est long : on
            // les traite toutes avant de passer au point suivant.
            while segmentMeters > 0 && sample.cumulativeMeters >= boundaryMeters {
                let fraction = ((boundaryMeters - previous.cumulativeMeters) / segmentMeters)
                    .clamped(to: 0...1)
                let boundarySeconds = previous.cumulativeMovingSeconds + segmentSeconds * fraction
                let boundaryAltitude = previous.smoothedAltitude
                    + (sample.smoothedAltitude - previous.smoothedAltitude) * fraction

                altitudesInSplit.append(boundaryAltitude)
                splits.append(
                    Split(
                        index: splits.count + 1,
                        meters: boundaryMeters - splitStartMeters,
                        duration: boundarySeconds - splitStartSeconds,
                        elevationGain: RunMath.elevationGain(
                            smoothedAltitudes: altitudesInSplit,
                            threshold: elevationThreshold
                        )
                    )
                )

                splitStartMeters = boundaryMeters
                splitStartSeconds = boundarySeconds
                altitudesInSplit = [boundaryAltitude]
                boundaryMeters += distanceMeters
            }

            altitudesInSplit.append(sample.smoothedAltitude)
        }

        // Le reliquat.
        let last = trace.samples[trace.samples.count - 1]
        let remainingMeters = last.cumulativeMeters - splitStartMeters
        if remainingMeters > 1 {
            splits.append(
                Split(
                    index: splits.count + 1,
                    meters: remainingMeters,
                    duration: last.cumulativeMovingSeconds - splitStartSeconds,
                    elevationGain: RunMath.elevationGain(
                        smoothedAltitudes: altitudesInSplit,
                        threshold: elevationThreshold
                    )
                )
            )
        }
        return splits
    }

    /// Construit la sortie enregistrée à partir de la trace brute.
    public static func summarise(
        rawPoints: [GPSPoint],
        type: RunType,
        filter: TraceFilter = .outdoor,
        perceivedEffort: Int? = nil,
        note: String? = nil,
        id: UUID = UUID()
    ) -> RunLog {
        let trace = clean(rawPoints, filter: filter)
        return RunLog(
            id: id,
            startedAt: trace.samples.first?.point.timestamp ?? Date(),
            type: type,
            points: rawPoints,
            meters: trace.meters,
            duration: trace.movingDuration,
            elevationGain: trace.elevationGain,
            splits: splits(of: trace, elevationThreshold: filter.elevationThreshold),
            perceivedEffort: perceivedEffort,
            note: note
        )
    }
}
