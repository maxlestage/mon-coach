import Foundation

/// Un index spatial minimal : des points rangés en cases carrées.
///
/// Sans lui, reconnaître un segment revient à comparer chaque point de la
/// trace à chaque point du segment. Une sortie d'une heure porte trois mille
/// points, un segment en porte cent : trois cent mille distances par segment,
/// multipliées par le nombre de segments enregistrés, à chaque fin de sortie.
/// Avec les cases, on ne regarde que le voisinage immédiat.
struct GeoGrid: Sendable {

    /// Côté d'une case, en mètres. Choisi égal au rayon de recherche : une
    /// requête ne consulte alors que les neuf cases autour d'elle.
    let cellMeters: Double
    /// Latitude de référence pour convertir les longitudes en mètres. Un
    /// segment tient dans quelques kilomètres : une seule référence suffit,
    /// et l'erreur reste très en dessous du bruit du GPS.
    private let referenceLatitude: Double
    private let latitudeScale: Double
    private let longitudeScale: Double
    private var buckets: [Int64: [Int]] = [:]

    init(points: [(latitude: Double, longitude: Double)], cellMeters: Double) {
        self.cellMeters = cellMeters
        referenceLatitude = points.first?.latitude ?? 0
        latitudeScale = cellMeters / 111_320.0
        // À 60° de latitude un degré de longitude ne vaut plus que la moitié
        // d'un degré de latitude : ignorer le cosinus donnerait des cases
        // deux fois trop larges et ferait retomber la recherche à du linéaire.
        let metersPerDegreeLongitude = max(1, 111_320.0 * cos(referenceLatitude * .pi / 180))
        longitudeScale = cellMeters / metersPerDegreeLongitude

        for (index, point) in points.enumerated() {
            buckets[key(latitude: point.latitude, longitude: point.longitude), default: []].append(index)
        }
    }

    /// Bornes des indices de case.
    ///
    /// Volontairement très en deçà des limites d'un entier 32 bits : les
    /// voisines se calculent en ajoutant ±1, et un indice posé sur la borne
    /// maximale ferait déborder cette addition. Un dépassement d'entier, en
    /// Swift, n'est pas une valeur fausse — c'est un arrêt brutal de
    /// l'application. Une coordonnée aberrante doit donner un mauvais
    /// voisinage, jamais un plantage.
    private static let indexLimit: Int64 = 1 << 30

    private func cell(latitude: Double, longitude: Double) -> (row: Int64, column: Int64) {
        (
            index(of: latitude, scale: latitudeScale),
            index(of: longitude, scale: longitudeScale)
        )
    }

    private func index(of value: Double, scale: Double) -> Int64 {
        // `Int64(_:)` piège aussi sur un NaN ou un infini. Les points d'un
        // GPX importé ne viennent pas de nous et ne sont pas de confiance.
        guard value.isFinite, scale > 0 else { return 0 }
        let raw = (value / scale).rounded(.down)
        let limit = Double(Self.indexLimit)
        guard raw.isFinite else { return 0 }
        return Int64(raw.clamped(to: -limit...limit))
    }

    private func key(row: Int64, column: Int64) -> Int64 {
        // Les indices tiennent dans 31 bits une fois bornés : l'un décalé,
        // l'autre masqué, il n'y a pas de collision possible.
        (row << 32) | (column & 0xFFFF_FFFF)
    }

    private func key(latitude: Double, longitude: Double) -> Int64 {
        let (row, column) = cell(latitude: latitude, longitude: longitude)
        return key(row: row, column: column)
    }

    /// Les indices des points situés dans les neuf cases autour d'une position.
    ///
    /// Renvoie des candidats, pas des voisins : c'est à l'appelant de mesurer
    /// la distance réelle. La case sert seulement à ne pas tout regarder.
    func candidates(latitude: Double, longitude: Double) -> [Int] {
        let (row, column) = cell(latitude: latitude, longitude: longitude)
        var result: [Int] = []
        for deltaRow in Int64(-1)...1 {
            for deltaColumn in Int64(-1)...1 {
                let neighbour = key(row: row + deltaRow, column: column + deltaColumn)
                if let bucket = buckets[neighbour] { result.append(contentsOf: bucket) }
            }
        }
        return result
    }
}
