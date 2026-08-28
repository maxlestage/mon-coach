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

    private func cell(latitude: Double, longitude: Double) -> (Int32, Int32) {
        (
            Int32((latitude / latitudeScale).rounded(.down)),
            Int32((longitude / longitudeScale).rounded(.down))
        )
    }

    private func key(latitude: Double, longitude: Double) -> Int64 {
        let (row, column) = cell(latitude: latitude, longitude: longitude)
        return Int64(row) << 32 | Int64(UInt32(bitPattern: column))
    }

    /// Les indices des points situés dans les neuf cases autour d'une position.
    ///
    /// Renvoie des candidats, pas des voisins : c'est à l'appelant de mesurer
    /// la distance réelle. La case sert seulement à ne pas tout regarder.
    func candidates(latitude: Double, longitude: Double) -> [Int] {
        let (row, column) = cell(latitude: latitude, longitude: longitude)
        var result: [Int] = []
        for dr in -1...1 {
            for dc in -1...1 {
                let neighbour = Int64(row + Int32(dr)) << 32
                    | Int64(UInt32(bitPattern: column + Int32(dc)))
                if let bucket = buckets[neighbour] { result.append(contentsOf: bucket) }
            }
        }
        return result
    }
}
