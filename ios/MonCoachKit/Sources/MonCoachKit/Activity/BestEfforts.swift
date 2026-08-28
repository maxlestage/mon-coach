import Foundation

/// Une distance de référence sur laquelle on garde un record.
public enum EffortDistance: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case fourHundred
    case oneKilometre
    case mile
    case fiveKilometres
    case tenKilometres
    case halfMarathon
    case marathon

    public var id: String { rawValue }

    public var meters: Double {
        switch self {
        case .fourHundred: 400
        case .oneKilometre: 1_000
        case .mile: 1_609.34
        case .fiveKilometres: 5_000
        case .tenKilometres: 10_000
        case .halfMarathon: 21_097.5
        case .marathon: 42_195
        }
    }

    public var label: LocalizedText {
        switch self {
        case .fourHundred: LocalizedText(fr: "400 m", en: "400 m", es: "400 m")
        case .oneKilometre: LocalizedText(fr: "1 km", en: "1 km", es: "1 km")
        case .mile: LocalizedText(fr: "1 mile", en: "1 mile", es: "1 milla")
        case .fiveKilometres: LocalizedText(fr: "5 km", en: "5 km", es: "5 km")
        case .tenKilometres: LocalizedText(fr: "10 km", en: "10 km", es: "10 km")
        case .halfMarathon: LocalizedText(fr: "Semi-marathon", en: "Half marathon", es: "Media maratón")
        case .marathon: LocalizedText(fr: "Marathon", en: "Marathon", es: "Maratón")
        }
    }
}

/// Le meilleur temps réalisé sur une distance, à l'intérieur d'une activité.
///
/// C'est un effort *à l'intérieur* d'une sortie, pas la sortie entière : le
/// meilleur 5 km d'un athlète est presque toujours un morceau d'un 10 km, et
/// ne le chercher que dans les sorties de 5 km exactement reviendrait à ne
/// jamais le trouver.
public struct BestEffort: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: String { "\(activityID.uuidString)-\(distance.rawValue)" }
    public var activityID: UUID
    public var date: Date
    public var sport: Sport
    public var distance: EffortDistance
    public var duration: TimeInterval
    /// Distance où commence l'effort dans la sortie, en mètres depuis le départ.
    public var startMeters: Double

    public init(
        activityID: UUID,
        date: Date,
        sport: Sport,
        distance: EffortDistance,
        duration: TimeInterval,
        startMeters: Double
    ) {
        self.activityID = activityID
        self.date = date
        self.sport = sport
        self.distance = distance
        self.duration = duration
        self.startMeters = startMeters
    }

    public var paceSecondsPerKm: Double {
        TraceMath.pace(meters: distance.meters, seconds: duration)
    }

    public var speedKmh: Double {
        duration > 0 ? (distance.meters / 1_000) / (duration / 3_600) : 0
    }
}

/// Le rang d'un effort dans l'histoire de l'athlète, et ce qu'on en dit.
public struct EffortRank: Sendable, Equatable, Identifiable, Hashable {
    public var id: String { effort.id }
    public var effort: BestEffort
    /// 1 pour un record, 2 pour le deuxième meilleur, etc.
    public var rank: Int
    /// Temps battu, quand il y en avait un. Nil au tout premier effort.
    public var previousBest: TimeInterval?

    public var isRecord: Bool { rank == 1 }

    /// L'annonce faite à l'athlète, dans sa langue.
    public var headline: LocalizedText {
        let name = effort.distance.label
        switch rank {
        case 1 where previousBest == nil:
            return LocalizedText(fr: "Premier ", en: "First ", es: "Primer ") + name
        case 1:
            return LocalizedText(fr: "Record sur ", en: "Best ever ", es: "Récord en ") + name
        case 2:
            return LocalizedText(fr: "2e meilleur ", en: "2nd best ", es: "2.º mejor ") + name
        case 3:
            return LocalizedText(fr: "3e meilleur ", en: "3rd best ", es: "3.er mejor ") + name
        default:
            return LocalizedText(
                fr: "\(rank)e meilleur ", en: "\(rank)th best ", es: "\(rank).º mejor "
            ) + name
        }
    }
}

/// Cherche les meilleurs efforts dans une trace, et les classe dans l'histoire.
public enum BestEfforts {

    /// Sports pour lesquels un record de distance a un sens.
    ///
    /// Le vélo en est exclu, et pas par oubli : un « meilleur 10 km » à vélo
    /// se gagne dans une descente ou avec le vent dans le dos, pas par la
    /// forme. En faire un record installerait une compétition contre la
    /// météo. Les segments, eux, comparent le même terrain — c'est là que la
    /// comparaison redevient juste.
    public static let rankedSports: Set<Sport> = [.run, .trail]

    /// Le meilleur temps sur une distance à l'intérieur d'une trace.
    ///
    /// Deux curseurs, une seule passe : la fenêtre avance et se rétracte sans
    /// jamais revenir en arrière. Recalculer chaque fenêtre indépendamment
    /// coûterait le carré du nombre de points, soit des dizaines de millions
    /// d'opérations pour un marathon échantillonné à la seconde.
    ///
    /// Le temps est interpolé aux deux bords : sans cela, un 5 km mesuré sur
    /// une trace échantillonnée tous les 8 m serait systématiquement mesuré
    /// sur 5 004 m, et le record dépendrait de la densité des points.
    public static func fastest(
        _ distanceMeters: Double,
        in trace: CleanTrace
    ) -> (duration: TimeInterval, startMeters: Double)? {
        guard distanceMeters > 0, trace.samples.count >= 2,
              trace.meters >= distanceMeters else { return nil }

        let samples = trace.samples
        var best: (duration: TimeInterval, startMeters: Double)?
        var low = 0

        for high in 1..<samples.count {
            // Avancer le bord arrière tant que la fenêtre reste assez longue.
            while low + 1 < high,
                  samples[high].cumulativeMeters - samples[low + 1].cumulativeMeters >= distanceMeters {
                low += 1
            }
            let span = samples[high].cumulativeMeters - samples[low].cumulativeMeters
            guard span >= distanceMeters else { continue }

            // Le bord arrière tombe entre `low` et `low + 1` : on interpole.
            let excess = span - distanceMeters
            let step = samples[low + 1].cumulativeMeters - samples[low].cumulativeMeters
            let fraction = step > 0 ? min(1, excess / step) : 0
            let startSeconds = samples[low].cumulativeMovingSeconds
                + (samples[low + 1].cumulativeMovingSeconds - samples[low].cumulativeMovingSeconds) * fraction
            let startMeters = samples[low].cumulativeMeters + step * fraction
            let duration = samples[high].cumulativeMovingSeconds - startSeconds

            guard duration > 0 else { continue }
            if best == nil || duration < best!.duration {
                best = (duration, startMeters)
            }
        }
        return best
    }

    /// Les meilleurs efforts contenus dans une trace déjà nettoyée.
    ///
    /// Appelé une fois, au moment où l'activité est résumée : la trace est
    /// alors déjà en mémoire et n'a pas à être renettoyée.
    public static func efforts(
        in trace: CleanTrace,
        activityID: UUID,
        date: Date,
        sport: Sport
    ) -> [BestEffort] {
        guard rankedSports.contains(sport) else { return [] }
        return EffortDistance.allCases.compactMap { distance in
            guard let found = fastest(distance.meters, in: trace) else { return nil }
            return BestEffort(
                activityID: activityID,
                date: date,
                sport: sport,
                distance: distance,
                duration: found.duration,
                startMeters: found.startMeters
            )
        }
    }

    /// Tous les meilleurs efforts d'une activité.
    ///
    /// Les efforts sont calculés une fois et rangés dans l'activité. Les
    /// recalculer à chaque lecture coûterait un nettoyage complet de trace
    /// par activité : classer une sortie contre cinq cents autres relirait
    /// près de deux millions de points, sur le fil principal, juste après
    /// que l'athlète a appuyé sur « terminer ».
    ///
    /// `nil` veut dire « jamais calculé » — une activité enregistrée par une
    /// version antérieure. Un tableau vide veut dire « calculé, rien à
    /// signaler », par exemple une sortie vélo : sans cette distinction, on
    /// recalculerait indéfiniment ce qui n'a rien à donner.
    public static func efforts(in activity: ActivityLog) -> [BestEffort] {
        if let stored = activity.bestEfforts { return stored }
        let trace = TraceAnalysis.clean(activity.points, filter: activity.sport.filter)
        return efforts(
            in: trace,
            activityID: activity.id,
            date: activity.startedAt,
            sport: activity.sport
        )
    }

    /// Le meilleur effort de l'athlète sur chaque distance, tous historiques
    /// confondus, le plus rapide d'abord.
    public static func records(in activities: [ActivityLog]) -> [BestEffort] {
        var best: [EffortDistance: BestEffort] = [:]
        for activity in activities {
            for effort in efforts(in: activity) {
                if let held = best[effort.distance], held.duration <= effort.duration { continue }
                best[effort.distance] = effort
            }
        }
        return EffortDistance.allCases.compactMap { best[$0] }
    }

    /// Ce qu'une activité a valu, replacé dans l'histoire de l'athlète.
    ///
    /// `history` doit contenir les activités *antérieures* : c'est contre
    /// elles qu'on classe. Une activité qui s'y trouverait aussi se battrait
    /// contre elle-même et ne serait jamais un record.
    public static func ranks(for activity: ActivityLog, against history: [ActivityLog]) -> [EffortRank] {
        let earlier = history.filter { $0.id != activity.id && $0.startedAt < activity.startedAt }
        var previous: [EffortDistance: [TimeInterval]] = [:]
        for older in earlier {
            for effort in efforts(in: older) {
                previous[effort.distance, default: []].append(effort.duration)
            }
        }
        return efforts(in: activity).map { effort in
            let others = previous[effort.distance] ?? []
            let faster = others.filter { $0 < effort.duration }.count
            return EffortRank(
                effort: effort,
                rank: faster + 1,
                previousBest: others.min()
            )
        }
    }

    /// Les distinctions qu'on met en avant après une sortie.
    ///
    /// Seuls les trois premiers rangs, et au plus trois lignes : annoncer
    /// « 14e meilleur 400 m » à quelqu'un qui vient de courir n'est pas une
    /// nouvelle, c'est du bruit. La plus longue distance d'abord — un record
    /// sur 10 km vaut mieux qu'un record sur 400 m glané dedans.
    public static func highlights(for activity: ActivityLog, against history: [ActivityLog]) -> [EffortRank] {
        ranks(for: activity, against: history)
            .filter { $0.rank <= 3 }
            .sorted { $0.effort.distance.meters > $1.effort.distance.meters }
            .prefix(3)
            .map { $0 }
    }
}
