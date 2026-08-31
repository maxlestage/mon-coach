import Foundation

/// Un point d'un parcours dessiné à l'avance.
///
/// Pas un `GPSPoint` : celui-là porte un horodatage et des précisions de
/// mesure, qui n'existent pas pour un endroit où l'on n'est pas encore
/// allé. Inventer une heure de passage sur un parcours prévu, c'est le
/// premier pas vers un « temps prévu » qui n'a jamais été couru.
public struct RoutePoint: Codable, Sendable, Equatable, Hashable {
    public var latitude: Double
    public var longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Un parcours préparé avant de sortir.
///
/// Pourquoi ce type existe
/// -----------------------
/// « Je veux courir douze kilomètres ce soir » n'est pas une question
/// d'entraînement, c'est une question de géographie : par où ? Sans réponse,
/// on fait le même tour depuis trois ans, ou on part au hasard et on rentre
/// à huit ou à seize.
///
/// Le parcours se dessine à la main, point par point, sur la carte. Aucun
/// calcul d'itinéraire : celui-là demanderait un serveur de routage, donc
/// d'envoyer à quelqu'un l'endroit où l'on veut aller courir — exactement
/// ce que cette application a promis de ne jamais faire. Un trait tiré à la
/// main sur ses propres rues n'a besoin de personne.
public struct PlannedRoute: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var createdAt: Date
    /// Le sport pour lequel il a été pensé — un tour de vélo de 60 km n'a
    /// rien à faire dans la liste d'un coureur.
    public var sport: Sport
    public var points: [RoutePoint]

    public init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        sport: Sport = .run,
        points: [RoutePoint]
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.sport = sport
        self.points = points
    }

    /// La longueur du parcours, en mètres.
    ///
    /// Recalculée, jamais stockée : un parcours dont on retire un point
    /// verrait sinon sa distance rester celle d'avant, et le chiffre affiché
    /// deviendrait faux sans que rien ne le dise.
    public var meters: Double { RoutePlanner.length(of: points) }

    /// Un parcours qui revient à son point de départ, à cent mètres près.
    public var isLoop: Bool {
        guard let first = points.first, let last = points.last, points.count >= 3 else { return false }
        return RoutePlanner.distance(from: first, to: last) <= 100
    }
}

/// Les calculs d'un parcours : sa longueur, où l'on en est dessus, et de
/// combien on s'en écarte.
public enum RoutePlanner {

    /// Un parcours plus court que ça n'est pas un parcours, c'est un point
    /// posé par erreur. Le seuil vaut moins qu'un tour de piste.
    public static let minimumMeters: Double = 300

    // MARK: - Longueur

    public static func distance(from a: RoutePoint, to b: RoutePoint) -> Double {
        TraceMath.distance(
            latitude1: a.latitude, longitude1: a.longitude,
            latitude2: b.latitude, longitude2: b.longitude
        )
    }

    public static func length(of points: [RoutePoint]) -> Double {
        guard points.count >= 2 else { return 0 }
        var total = 0.0
        for index in 1..<points.count {
            total += distance(from: points[index - 1], to: points[index])
        }
        return total
    }

    /// Le temps que ce parcours prendra à une allure donnée, en secondes.
    public static func estimatedSeconds(meters: Double, paceSecondsPerKm: Double) -> TimeInterval? {
        guard meters > 0, paceSecondsPerKm > 0 else { return nil }
        return meters / 1_000 * paceSecondsPerKm
    }

    // MARK: - Suivi pendant la sortie

    /// De combien de mètres cette position s'écarte du parcours.
    ///
    /// La distance est mesurée au segment le plus proche, pas au point le
    /// plus proche : sur une ligne droite dont les sommets sont espacés de
    /// cinq cents mètres, être au milieu de la droite donnerait un écart de
    /// deux cent cinquante mètres alors qu'on est exactement dessus.
    public static func deviation(of position: RoutePoint, from route: [RoutePoint]) -> Double? {
        guard let first = route.first else { return nil }
        guard route.count >= 2 else { return distance(from: position, to: first) }
        var best = Double.greatestFiniteMagnitude
        for index in 1..<route.count {
            best = Swift.min(
                best,
                distanceToSegment(position, from: route[index - 1], to: route[index])
            )
        }
        return best
    }

    /// Au-delà de cet écart, on ne suit plus le parcours : on s'est trompé
    /// de rue. Cinquante mètres laissent passer le bruit du GPS en ville et
    /// le fait de courir sur l'autre trottoir.
    public static let offRouteMeters: Double = 50

    public static func isOffRoute(_ position: RoutePoint, from route: [RoutePoint]) -> Bool {
        guard let deviation = deviation(of: position, from: route) else { return false }
        return deviation > offRouteMeters
    }

    /// Ce qu'il reste à parcourir depuis cette position, en mètres.
    ///
    /// On se projette sur le segment le plus proche, puis on additionne ce
    /// qui suit. Sur un aller-retour qui repasse au même endroit, le point
    /// le plus proche est ambigu par nature : la valeur rendue est alors
    /// celle du premier passage, et c'est une estimation assumée — mieux
    /// vaut un restant approché qu'aucun restant.
    public static func remainingMeters(from position: RoutePoint, on route: [RoutePoint]) -> Double? {
        guard route.count >= 2 else { return nil }
        var bestDistance = Double.greatestFiniteMagnitude
        var bestIndex = 1
        var bestProjection = 0.0
        for index in 1..<route.count {
            let (gap, along) = projection(position, from: route[index - 1], to: route[index])
            if gap < bestDistance {
                bestDistance = gap
                bestIndex = index
                bestProjection = along
            }
        }
        var remaining = distance(from: route[bestIndex - 1], to: route[bestIndex]) - bestProjection
        if bestIndex + 1 < route.count {
            for index in (bestIndex + 1)..<route.count {
                remaining += distance(from: route[index - 1], to: route[index])
            }
        }
        return Swift.max(0, remaining)
    }

    // MARK: - Géométrie locale

    /// Distance d'un point à un segment, en mètres.
    static func distanceToSegment(_ point: RoutePoint, from a: RoutePoint, to b: RoutePoint) -> Double {
        projection(point, from: a, to: b).gap
    }

    /// Projette un point sur un segment : l'écart perpendiculaire, et la
    /// distance parcourue le long du segment depuis son début.
    ///
    /// Le calcul se fait dans un plan local — un degré de latitude vaut
    /// 111 320 m, un degré de longitude le même resserré par le cosinus de
    /// la latitude. Sur les quelques centaines de mètres d'un segment,
    /// l'erreur de cette approximation est très en dessous du bruit du GPS,
    /// et elle évite une trigonométrie sphérique dont la précision serait
    /// invisible ici.
    static func projection(
        _ point: RoutePoint,
        from a: RoutePoint,
        to b: RoutePoint
    ) -> (gap: Double, along: Double) {
        let metersPerDegreeLat = 111_320.0
        let midLatitude = (a.latitude + b.latitude) / 2
        let metersPerDegreeLon = metersPerDegreeLat * cos(midLatitude * .pi / 180)

        let ax = 0.0, ay = 0.0
        let bx = (b.longitude - a.longitude) * metersPerDegreeLon
        let by = (b.latitude - a.latitude) * metersPerDegreeLat
        let px = (point.longitude - a.longitude) * metersPerDegreeLon
        let py = (point.latitude - a.latitude) * metersPerDegreeLat

        let segmentLengthSquared = (bx - ax) * (bx - ax) + (by - ay) * (by - ay)
        guard segmentLengthSquared > 0 else {
            return (sqrt(px * px + py * py), 0)
        }
        // Le paramètre est borné à [0, 1] : au-delà, la perpendiculaire
        // tombe hors du segment et c'est l'extrémité qui est la plus proche.
        let t = Swift.max(0, Swift.min(1, (px * bx + py * by) / segmentLengthSquared))
        let closestX = bx * t
        let closestY = by * t
        let gap = sqrt((px - closestX) * (px - closestX) + (py - closestY) * (py - closestY))
        return (gap, sqrt(segmentLengthSquared) * t)
    }

    // MARK: - Conversions

    /// Le parcours d'une sortie déjà courue : refaire ce qu'on a aimé est
    /// la façon la plus courante de préparer une sortie.
    ///
    /// La trace est amincie : garder dix mille points d'une sortie d'une
    /// heure alourdirait l'état pour une précision qu'un parcours n'a pas
    /// besoin d'avoir.
    public static func route(from activity: ActivityLog, named name: String) -> PlannedRoute? {
        let points = thinned(activity.points.map {
            RoutePoint(latitude: $0.latitude, longitude: $0.longitude)
        })
        guard length(of: points) >= minimumMeters else { return nil }
        return PlannedRoute(name: name, sport: activity.sport, points: points)
    }

    /// Ramène un tracé à un nombre de points raisonnable, extrémités
    /// gardées.
    public static func thinned(_ points: [RoutePoint], limit: Int = 500) -> [RoutePoint] {
        guard points.count > limit, limit >= 2 else { return points }
        let stride = points.count / limit + 1
        var kept = points.indices.filter { $0 % stride == 0 }.map { points[$0] }
        if let last = points.last, kept.last != last { kept.append(last) }
        return kept
    }
}
