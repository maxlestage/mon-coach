import Foundation

/// Un trajet que l'athlète refait, et tout ce qu'il en sait.
public struct FrequentRoute: Sendable, Equatable, Identifiable {
    /// L'identifiant de la sortie qui sert de représentante.
    public var id: UUID
    public var sport: Sport
    /// Le nombre de fois où ce trajet a été parcouru.
    public var timesDone: Int
    /// La distance typique — celle de la sortie représentante.
    public var meters: Double
    /// Le meilleur temps réalisé dessus, en mouvement.
    public var bestSeconds: TimeInterval
    /// Le temps de la dernière fois.
    public var lastSeconds: TimeInterval
    public var lastDone: Date
    public var firstDone: Date
    /// La trace à dessiner : celle d'une vraie sortie, jamais une moyenne.
    ///
    /// Moyenner des traces produirait une ligne qui ne passe par aucune rue
    /// — un fantôme qui coupe les virages et traverse les maisons. Celle-ci
    /// a été réellement parcourue.
    public var points: [GPSPoint]
    /// Les identifiants de toutes les sorties du groupe, de la plus récente
    /// à la plus ancienne.
    public var activityIDs: [UUID]

    /// L'allure moyenne du meilleur passage, en secondes par kilomètre.
    public var bestPaceSecondsPerKm: Double? {
        meters > 0 && bestSeconds > 0 ? bestSeconds / (meters / 1_000) : nil
    }

    /// A-t-on fait mieux la dernière fois que la moyenne de l'histoire ?
    public var lastWasBest: Bool { lastSeconds <= bestSeconds }
}

/// Reconnaît les trajets qu'on refait, sans rien connaître des routes.
///
/// Pourquoi ce type existe
/// -----------------------
/// La carte de chaleur montre où l'on va, en gros. Elle ne dit pas « ce
/// tour-là, tu l'as fait vingt-trois fois » — or c'est ce qu'on veut
/// savoir, parce que c'est le seul cadre où deux sorties sont vraiment
/// comparables : même montée, même vent dominant, même feu rouge.
///
/// La méthode ne suppose aucune carte routière et ne demande rien à
/// personne. Chaque sortie est réduite à l'ensemble des cases de cent
/// mètres qu'elle traverse ; deux sorties qui partagent l'essentiel de
/// leurs cases sont le même trajet. C'est grossier, et c'est voulu : un
/// trottoir changé de côté, un détour de cinquante mètres pour éviter des
/// travaux, ne doivent pas fabriquer un trajet de plus.
///
/// Tout est calculé sur l'appareil. C'est exactement le genre de donnée qui
/// ne doit jamais partir : la liste des trajets qu'une personne répète, ce
/// sont ses horaires, son domicile et son travail.
public enum FrequentRoutes {

    /// Le côté d'une case, en mètres.
    ///
    /// Cent mètres : assez grand pour absorber le bruit du GPS en ville —
    /// où il dépasse souvent trente mètres entre les immeubles — et assez
    /// petit pour que deux rues parallèles restent deux trajets.
    static let cellMeters: Double = 100

    /// La part de cases communes au-delà de laquelle deux sorties sont le
    /// même trajet.
    ///
    /// 0,7 plutôt que 0,9 : une boucle de dix kilomètres rallongée d'un
    /// kilomètre reste la même boucle, et quelqu'un qui coupe court parce
    /// qu'il pleut n'a pas inventé un parcours. Plus haut, chaque variante
    /// devenait un trajet distinct et la liste ne comptait plus que des
    /// « 1 fois ».
    static let sameRouteThreshold: Double = 0.7

    /// Combien de passages avant de parler d'habitude. Deux fois est une
    /// coïncidence.
    public static let minimumTimes = 3

    /// Combien de sorties on regarde, au plus.
    ///
    /// La comparaison est en n² : à trois cents sorties, cela fait
    /// quarante-cinq mille comparaisons d'ensembles, ce qui reste
    /// instantané. Au-delà, on garde les plus récentes — un trajet qu'on ne
    /// fait plus depuis deux ans n'est plus une habitude.
    static let maximumActivities = 300

    /// Les trajets récurrents, du plus fréquent au moins fréquent.
    public static func find(
        in activities: [ActivityLog],
        minimumTimes: Int = minimumTimes
    ) -> [FrequentRoute] {
        let candidates = activities
            .filter { $0.points.count >= 2 && $0.meters >= 500 && $0.sport.tracksLocation }
            .sorted { $0.startedAt > $1.startedAt }
            .prefix(maximumActivities)

        // L'empreinte est calculée une fois par sortie : la recalculer à
        // chaque comparaison multiplierait le coût par le nombre de groupes.
        let prints = candidates.map { (activity: $0, cells: signature(of: $0)) }

        var clusters: [[(activity: ActivityLog, cells: Set<Int64>)]] = []
        for entry in prints where !entry.cells.isEmpty {
            // On compare à la première sortie du groupe, pas à toutes : elle
            // est la plus récente, et une chaîne de proche en proche finirait
            // par réunir deux trajets qui n'ont rien en commun.
            let match = clusters.firstIndex { cluster in
                guard let head = cluster.first, head.activity.sport == entry.activity.sport
                else { return false }
                return overlap(head.cells, entry.cells) >= sameRouteThreshold
            }
            if let match {
                clusters[match].append(entry)
            } else {
                clusters.append([entry])
            }
        }

        return clusters
            .filter { $0.count >= Swift.max(2, minimumTimes) }
            .compactMap(route(from:))
            .sorted {
                $0.timesDone == $1.timesDone
                    ? $0.lastDone > $1.lastDone
                    : $0.timesDone > $1.timesDone
            }
    }

    /// L'ensemble des cases traversées par une sortie.
    ///
    /// Un ensemble, pas une liste : le temps passé dans une case ne compte
    /// pas. Sans cela, un feu rouge où l'on patiente pèserait dix fois plus
    /// qu'un kilomètre couru, et deux sorties se ressembleraient surtout par
    /// leurs arrêts.
    static func signature(of activity: ActivityLog) -> Set<Int64> {
        var cells = Set<Int64>()
        guard let first = activity.points.first(where: { $0.latitude.isFinite && $0.longitude.isFinite })
        else { return cells }
        let metersPerDegreeLat = 111_320.0
        let metersPerDegreeLon = Swift.max(1, 111_320.0 * cos(first.latitude * .pi / 180))
        for point in activity.points where point.latitude.isFinite && point.longitude.isFinite {
            let row = (point.latitude * metersPerDegreeLat / cellMeters).rounded(.down)
            let column = (point.longitude * metersPerDegreeLon / cellMeters).rounded(.down)
            // Les mêmes bornes que l'index spatial : une coordonnée aberrante
            // venue d'un GPX doit donner une mauvaise case, jamais un
            // dépassement d'entier — qui, en Swift, arrête l'application.
            let limit = Double(Int64(1) << 30)
            guard row.isFinite, column.isFinite else { continue }
            let safeRow = Int64(row.clamped(to: -limit...limit))
            let safeColumn = Int64(column.clamped(to: -limit...limit))
            cells.insert((safeRow << 32) | (safeColumn & 0xFFFF_FFFF))
        }
        return cells
    }

    /// La part de cases communes, rapportée au plus petit des deux
    /// ensembles.
    ///
    /// Rapportée au plus petit, et non à l'union : une sortie de cinq
    /// kilomètres entièrement contenue dans une de dix est le même début de
    /// parcours, mais ce n'est pas le même trajet — l'union le dit (0,5),
    /// le plus petit le dirait à tort (1,0). On garde donc les deux
    /// conditions : recouvrement fort ET longueurs comparables.
    static func overlap(_ left: Set<Int64>, _ right: Set<Int64>) -> Double {
        guard !left.isEmpty, !right.isEmpty else { return 0 }
        let shorter = Double(Swift.min(left.count, right.count))
        let longer = Double(Swift.max(left.count, right.count))
        // Une sortie deux fois plus longue n'est pas le même trajet, même si
        // elle passe partout où passe l'autre.
        guard shorter / longer >= 0.7 else { return 0 }
        return Double(left.intersection(right).count) / shorter
    }

    static func route(from cluster: [(activity: ActivityLog, cells: Set<Int64>)]) -> FrequentRoute? {
        let activities = cluster.map(\.activity)
        guard let last = activities.max(by: { $0.startedAt < $1.startedAt }),
              let first = activities.min(by: { $0.startedAt < $1.startedAt })
        else { return nil }

        // La trace montrée est celle de la sortie la plus proche de la
        // distance médiane : ni la plus courte ni la plus longue, donc celle
        // qui ressemble le plus à ce qu'on fait d'habitude.
        let sorted = activities.sorted { $0.meters < $1.meters }
        let representative = sorted[sorted.count / 2]
        let best = activities
            .filter { $0.duration > 0 }
            .min { $0.duration < $1.duration } ?? representative

        return FrequentRoute(
            id: representative.id,
            sport: representative.sport,
            timesDone: activities.count,
            meters: representative.meters,
            bestSeconds: best.duration,
            lastSeconds: last.duration,
            lastDone: last.startedAt,
            firstDone: first.startedAt,
            points: representative.points,
            activityIDs: activities.sorted { $0.startedAt > $1.startedAt }.map(\.id)
        )
    }

    /// Un nom proposé pour un trajet, à partir de ce qu'on en sait.
    ///
    /// Aucun nom de rue : l'application ne connaît aucune carte, et
    /// inventer « Boucle du canal » serait une invention. On dit ce qui est
    /// vrai — le sport et la distance — et l'athlète renomme s'il veut.
    public static func suggestedName(for route: FrequentRoute, language: Language) -> String {
        let kilometres = (route.meters / 1_000)
        let rounded = (kilometres * 2).rounded() / 2
        let distance = Format.number(rounded, decimals: rounded == rounded.rounded() ? 0 : 1, language: language)
        let loop = isLoop(route.points)
        switch language {
        case .french:
            return loop ? "Boucle de \(distance) km" : "Sortie de \(distance) km"
        case .english:
            return loop ? "\(distance) km loop" : "\(distance) km route"
        case .spanish:
            return loop ? "Bucle de \(distance) km" : "Ruta de \(distance) km"
        }
    }

    /// Le trajet revient-il à son point de départ ?
    ///
    /// Deux cents mètres de tolérance : on ne repart jamais du pas de sa
    /// porte au mètre près, et un aller-retour pur n'est pas une boucle.
    static func isLoop(_ points: [GPSPoint]) -> Bool {
        guard let start = points.first, let end = points.last, points.count > 2 else { return false }
        return TraceMath.distance(
            latitude1: start.latitude, longitude1: start.longitude,
            latitude2: end.latitude, longitude2: end.longitude
        ) < 200
    }
}
