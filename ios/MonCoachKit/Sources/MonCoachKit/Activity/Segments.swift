import Foundation

/// Un morceau de parcours découpé dans une sortie passée, pour s'y comparer.
///
/// C'est la moitié utile d'un segment partagé, celle qui ne demande pas de
/// serveur : la comparaison au monde entier disparaît, la comparaison au même
/// terrain reste. Une côte reste la même côte, et c'est ça qui rend le
/// chrono lisible — contrairement à un « meilleur 5 km » qui dépend d'où on
/// l'a couru.
public struct Segment: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    /// Écrit par l'athlète : jamais traduit, contrairement aux consignes du
    /// coach. « Côte du moulin » ne se traduit pas.
    public var name: String
    public var sport: Sport
    /// Le tracé de référence, tel qu'il a été parcouru la première fois.
    public var points: [GPSPoint]
    public var meters: Double
    public var elevationGain: Double
    public var createdAt: Date
    /// L'activité dans laquelle le segment a été découpé.
    public var sourceActivityID: UUID

    public init(
        id: UUID = UUID(),
        name: String,
        sport: Sport,
        points: [GPSPoint],
        meters: Double,
        elevationGain: Double,
        createdAt: Date = Date(),
        sourceActivityID: UUID
    ) {
        self.id = id
        self.name = name
        self.sport = sport
        self.points = points
        self.meters = meters
        self.elevationGain = elevationGain
        self.createdAt = createdAt
        self.sourceActivityID = sourceActivityID
    }

    /// Pente moyenne, en pourcentage.
    public var gradePercent: Double {
        meters > 0 ? elevationGain / meters * 100 : 0
    }
}

/// Un passage sur un segment, chronométré.
public struct SegmentEffort: Sendable, Equatable, Identifiable, Hashable {
    public var id: String { "\(segmentID.uuidString)-\(activityID.uuidString)-\(Int(startMeters))" }
    public var segmentID: UUID
    public var activityID: UUID
    public var date: Date
    public var duration: TimeInterval
    /// Où le passage commence dans l'activité, en mètres depuis le départ.
    public var startMeters: Double
    /// Distance réellement parcourue sur le segment, en mètres.
    public var meters: Double

    public init(
        segmentID: UUID,
        activityID: UUID,
        date: Date,
        duration: TimeInterval,
        startMeters: Double,
        meters: Double
    ) {
        self.segmentID = segmentID
        self.activityID = activityID
        self.date = date
        self.duration = duration
        self.startMeters = startMeters
        self.meters = meters
    }

    public var paceSecondsPerKm: Double {
        TraceMath.pace(meters: meters, seconds: duration)
    }
}

/// Reconnaît un segment dans une activité, et chronomètre le passage.
public enum SegmentMatching {

    /// Ce qu'on tolère pour dire « c'est le même parcours ».
    public struct Tolerance: Sendable, Equatable {
        /// Distance au point de départ ou d'arrivée du segment sous laquelle
        /// on considère qu'on y est passé, en mètres.
        public var endpointRadius: Double
        /// Largeur du couloir autour du tracé de référence, en mètres.
        public var corridorRadius: Double
        /// Pas d'échantillonnage du segment pour vérifier le couloir.
        public var samplingMeters: Double
        /// Part du segment qui doit être couverte pour valider le passage.
        public var minimumCoverage: Double
        /// Écart de longueur toléré entre le passage et le segment.
        public var lengthTolerance: Double

        public init(
            endpointRadius: Double = 25,
            corridorRadius: Double = 25,
            samplingMeters: Double = 20,
            minimumCoverage: Double = 0.9,
            lengthTolerance: Double = 0.25
        ) {
            self.endpointRadius = endpointRadius
            self.corridorRadius = corridorRadius
            self.samplingMeters = samplingMeters
            self.minimumCoverage = minimumCoverage
            self.lengthTolerance = lengthTolerance
        }

        public static let `default` = Tolerance()
        /// Plus large : sous les arbres, une trace honnête s'écarte de
        /// vingt mètres du tracé de référence sans que le coureur ait dévié.
        public static let forest = Tolerance(endpointRadius: 40, corridorRadius: 40)
    }

    /// Découpe un segment dans une activité, entre deux distances.
    ///
    /// Rend `nil` plutôt qu'un segment vide ou minuscule : un segment de
    /// trente mètres serait reconnu partout et ne voudrait rien dire.
    public static func carve(
        from activity: ActivityLog,
        name: String,
        startMeters: Double,
        endMeters: Double,
        minimumMeters: Double = 200
    ) -> Segment? {
        guard endMeters - startMeters >= minimumMeters else { return nil }
        let trace = TraceAnalysis.clean(activity.points, filter: activity.sport.filter)
        let inside = trace.samples.filter {
            $0.cumulativeMeters >= startMeters && $0.cumulativeMeters <= endMeters
        }
        guard inside.count >= 2 else { return nil }

        let meters = inside[inside.count - 1].cumulativeMeters - inside[0].cumulativeMeters
        guard meters >= minimumMeters else { return nil }

        return Segment(
            name: name,
            sport: activity.sport,
            points: inside.map(\.point),
            meters: meters,
            elevationGain: TraceMath.elevationGain(
                smoothedAltitudes: inside.map(\.smoothedAltitude),
                threshold: activity.sport.filter.elevationThreshold
            ),
            createdAt: activity.startedAt,
            sourceActivityID: activity.id
        )
    }

    /// Le point du tracé le plus proche d'une position, avec interpolation.
    ///
    /// On cherche le meilleur point *sur* la trace, pas le meilleur point
    /// enregistré : entre deux points espacés de dix mètres, l'entrée réelle
    /// du segment tombe entre les deux, et l'arrondir coûterait plusieurs
    /// secondes sur un segment court.
    static func closestApproach(
        to target: GPSPoint,
        in samples: [TraceSample],
        indices: [Int]
    ) -> (index: Int, meters: Double, seconds: TimeInterval, distance: Double)? {
        var best: (index: Int, meters: Double, seconds: TimeInterval, distance: Double)?
        for index in indices where index < samples.count {
            let sample = samples[index]
            let direct = TraceMath.distance(from: sample.point, to: target)
            if best == nil || direct < best!.distance {
                best = (index, sample.cumulativeMeters, sample.cumulativeMovingSeconds, direct)
            }
            // Projection sur le tronçon suivant : c'est là que tombe l'entrée
            // réelle quand les points sont espacés.
            guard index + 1 < samples.count else { continue }
            let next = samples[index + 1]
            let span = next.cumulativeMeters - sample.cumulativeMeters
            guard span > 0 else { continue }
            let toNext = TraceMath.distance(from: sample.point, to: next.point)
            guard toNext > 0 else { continue }
            let toTarget = TraceMath.distance(from: sample.point, to: target)
            let nextToTarget = TraceMath.distance(from: next.point, to: target)
            // Loi des cosinus : la position du pied de la perpendiculaire.
            let ratio = ((toTarget * toTarget - nextToTarget * nextToTarget) / (toNext * toNext) + 1) / 2
            guard ratio > 0, ratio < 1 else { continue }
            let height = max(0, toTarget * toTarget - (ratio * toNext) * (ratio * toNext))
            let distance = height.squareRoot()
            if distance < best!.distance {
                best = (
                    index,
                    sample.cumulativeMeters + span * ratio,
                    sample.cumulativeMovingSeconds
                        + (next.cumulativeMovingSeconds - sample.cumulativeMovingSeconds) * ratio,
                    distance
                )
            }
        }
        return best
    }

    /// Tous les passages sur un segment contenus dans une activité.
    ///
    /// Il peut y en avoir plusieurs : une boucle répétée trois fois donne
    /// trois passages, et les compter tous est exactement l'intérêt d'un
    /// segment sur une séance de côtes.
    public static func efforts(
        of segment: Segment,
        in activity: ActivityLog,
        tolerance: Tolerance = .default
    ) -> [SegmentEffort] {
        guard segment.sport == activity.sport else { return [] }
        let trace = TraceAnalysis.clean(activity.points, filter: activity.sport.filter)
        return efforts(of: segment, in: trace, of: activity, tolerance: tolerance)
    }

    /// Les passages de plusieurs segments dans une même activité.
    ///
    /// La trace n'est nettoyée qu'une fois. Passer par la version à un
    /// segment dans une boucle la renettoierait à chaque tour : vingt
    /// segments contre cinq cents activités feraient dix mille nettoyages
    /// complets là où cinq cents suffisent.
    public static func efforts(
        of segments: [Segment],
        in activity: ActivityLog,
        tolerance: Tolerance = .default
    ) -> [SegmentEffort] {
        let relevant = segments.filter { $0.sport == activity.sport }
        guard !relevant.isEmpty else { return [] }
        let trace = TraceAnalysis.clean(activity.points, filter: activity.sport.filter)
        return relevant.flatMap { efforts(of: $0, in: trace, of: activity, tolerance: tolerance) }
    }

    static func efforts(
        of segment: Segment,
        in trace: CleanTrace,
        of activity: ActivityLog,
        tolerance: Tolerance
    ) -> [SegmentEffort] {
        guard segment.points.count >= 2 else { return [] }
        guard trace.samples.count >= 2, trace.meters >= segment.meters * (1 - tolerance.lengthTolerance)
        else { return [] }

        let samples = trace.samples
        let grid = GeoGrid(
            points: samples.map { ($0.point.latitude, $0.point.longitude) },
            cellMeters: max(tolerance.endpointRadius, tolerance.corridorRadius)
        )

        guard let first = segment.points.first, let last = segment.points.last else { return [] }
        let entries = approaches(to: first, samples: samples, grid: grid, radius: tolerance.endpointRadius)
        let exits = approaches(to: last, samples: samples, grid: grid, radius: tolerance.endpointRadius)
        guard !entries.isEmpty, !exits.isEmpty else { return [] }

        // Les points de contrôle : le segment échantillonné à pas régulier.
        let checkpoints = resample(segment.points, every: tolerance.samplingMeters)

        var efforts: [SegmentEffort] = []
        var consumedUntil = -1.0
        for entry in entries.sorted(by: { $0.meters < $1.meters }) {
            guard entry.meters > consumedUntil else { continue }
            // La sortie retenue est la première qui suit l'entrée et donne
            // une longueur plausible : prendre la plus lointaine collerait
            // deux tours de boucle en un seul passage.
            let candidates = exits
                .filter { $0.meters > entry.meters }
                .sorted { $0.meters < $1.meters }
            guard let exit = candidates.first(where: { exit in
                let covered = exit.meters - entry.meters
                return abs(covered - segment.meters) <= segment.meters * tolerance.lengthTolerance
            }) else { continue }

            guard follows(
                checkpoints: checkpoints,
                samples: samples,
                grid: grid,
                between: entry.index,
                and: exit.index,
                tolerance: tolerance
            ) else { continue }

            efforts.append(
                SegmentEffort(
                    segmentID: segment.id,
                    activityID: activity.id,
                    date: activity.startedAt.addingTimeInterval(entry.seconds),
                    duration: exit.seconds - entry.seconds,
                    startMeters: entry.meters,
                    meters: exit.meters - entry.meters
                )
            )
            consumedUntil = exit.meters
        }
        return efforts.filter { $0.duration > 0 }
    }

    /// Les approches distinctes d'un point : un minimum local par passage.
    ///
    /// Sans le regroupement, dix points consécutifs à moins de vingt-cinq
    /// mètres du départ donneraient dix entrées pour un seul passage.
    private static func approaches(
        to target: GPSPoint,
        samples: [TraceSample],
        grid: GeoGrid,
        radius: Double
    ) -> [(index: Int, meters: Double, seconds: TimeInterval, distance: Double)] {
        let near = grid
            .candidates(latitude: target.latitude, longitude: target.longitude)
            .filter { TraceMath.distance(from: samples[$0].point, to: target) <= radius }
            .sorted()
        guard !near.isEmpty else { return [] }

        var groups: [[Int]] = [[near[0]]]
        for index in near.dropFirst() {
            // Deux approches séparées par plus de deux fois le rayon sont
            // deux passages distincts, pas le même.
            let previous = groups[groups.count - 1].last!
            if samples[index].cumulativeMeters - samples[previous].cumulativeMeters > radius * 2 {
                groups.append([index])
            } else {
                groups[groups.count - 1].append(index)
            }
        }
        return groups.compactMap { closestApproach(to: target, in: samples, indices: $0) }
    }

    /// Le tracé de référence, ré-échantillonné à pas régulier.
    private static func resample(_ points: [GPSPoint], every step: Double) -> [GPSPoint] {
        guard step > 0, points.count >= 2 else { return points }
        var result = [points[0]]
        var carried = 0.0
        for index in 1..<points.count {
            carried += TraceMath.distance(from: points[index - 1], to: points[index])
            if carried >= step {
                result.append(points[index])
                carried = 0
            }
        }
        if result.last != points[points.count - 1] { result.append(points[points.count - 1]) }
        return result
    }

    /// La portion de trace suit-elle vraiment le tracé de référence ?
    ///
    /// Chaque point de contrôle du segment doit trouver un point de trace
    /// dans son couloir, et les correspondances doivent avancer : c'est ce
    /// second test qui distingue un aller d'un retour. Sans lui, descendre
    /// une côte validerait le segment qui la monte.
    static func follows(
        checkpoints: [GPSPoint],
        samples: [TraceSample],
        grid: GeoGrid,
        between entryIndex: Int,
        and exitIndex: Int,
        tolerance: Tolerance
    ) -> Bool {
        guard entryIndex <= exitIndex else { return false }
        var matched = 0
        var lastIndex = entryIndex
        var regressions = 0

        for checkpoint in checkpoints {
            let candidates = grid
                .candidates(latitude: checkpoint.latitude, longitude: checkpoint.longitude)
                .filter { $0 >= entryIndex && $0 <= exitIndex }
            var bestIndex: Int?
            var bestDistance = Double.greatestFiniteMagnitude
            for index in candidates {
                let distance = TraceMath.distance(from: samples[index].point, to: checkpoint)
                if distance < bestDistance {
                    bestDistance = distance
                    bestIndex = index
                }
            }
            guard let bestIndex, bestDistance <= tolerance.corridorRadius else { continue }
            matched += 1
            if bestIndex < lastIndex { regressions += 1 }
            lastIndex = max(lastIndex, bestIndex)
        }

        guard !checkpoints.isEmpty else { return false }
        let coverage = Double(matched) / Double(checkpoints.count)
        // Quelques reculs sont normaux — un aller-retour au même carrefour,
        // un lacet serré. Une majorité de reculs, c'est l'autre sens.
        let mostlyForward = Double(regressions) < Double(max(1, matched)) * 0.25
        return coverage >= tolerance.minimumCoverage && mostlyForward
    }

    /// Tous les passages d'un athlète sur un segment, du plus rapide au plus lent.
    public static func leaderboard(
        of segment: Segment,
        in activities: [ActivityLog],
        tolerance: Tolerance = .default
    ) -> [SegmentEffort] {
        activities
            .flatMap { efforts(of: segment, in: $0, tolerance: tolerance) }
            .sorted { $0.duration < $1.duration }
    }

    /// Le meilleur passage de l'athlète sur chaque segment.
    public static func personalBests(
        of segments: [Segment],
        in activities: [ActivityLog],
        tolerance: Tolerance = .default
    ) -> [UUID: SegmentEffort] {
        var best: [UUID: SegmentEffort] = [:]
        for activity in activities {
            for effort in efforts(of: segments, in: activity, tolerance: tolerance) {
                if let held = best[effort.segmentID], held.duration <= effort.duration { continue }
                best[effort.segmentID] = effort
            }
        }
        return best
    }
}
