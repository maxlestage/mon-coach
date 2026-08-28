import Foundation

/// Les mathématiques d'une trace GPS : distance, filtrage, dénivelé, énergie.
///
/// Tout est pur et sans dépendance à CoreLocation, pour que ça se teste
/// ailleurs que sur un iPhone. La règle de conduite de ce fichier : un GPS
/// ment, et il ment de façons connues. Chaque filtre nomme le mensonge qu'il
/// corrige, et l'analyse compte ses rejets au lieu de les cacher.
public enum RunMath {

    /// Rayon moyen de la Terre (IUGG), en mètres.
    public static let earthRadiusMeters: Double = 6_371_008.8

    // MARK: - Géodésie

    /// Distance orthodromique entre deux points, en mètres (haversine).
    ///
    /// Sur les distances d'une foulée l'erreur du modèle sphérique est très
    /// en dessous du bruit du GPS lui-même : inutile d'aller chercher Vincenty.
    public static func distance(from a: GPSPoint, to b: GPSPoint) -> Double {
        distance(
            latitude1: a.latitude, longitude1: a.longitude,
            latitude2: b.latitude, longitude2: b.longitude
        )
    }

    public static func distance(
        latitude1: Double, longitude1: Double,
        latitude2: Double, longitude2: Double
    ) -> Double {
        let φ1 = latitude1 * .pi / 180
        let φ2 = latitude2 * .pi / 180
        let Δφ = (latitude2 - latitude1) * .pi / 180
        let Δλ = (longitude2 - longitude1) * .pi / 180

        let sinHalfΔφ = sin(Δφ / 2)
        let sinHalfΔλ = sin(Δλ / 2)
        let h = sinHalfΔφ * sinHalfΔφ + cos(φ1) * cos(φ2) * sinHalfΔλ * sinHalfΔλ
        // atan2 plutôt que asin : stable quand h approche 1 (points antipodaux).
        return 2 * earthRadiusMeters * atan2(sqrt(h), sqrt(max(0, 1 - h)))
    }

    // MARK: - Allure

    /// Allure en secondes par kilomètre. 0 si la distance est nulle.
    public static func pace(meters: Double, seconds: TimeInterval) -> Double {
        guard meters > 0, seconds > 0 else { return 0 }
        return seconds / (meters / 1_000)
    }

    /// Vitesse en mètres par seconde à partir d'une allure.
    public static func speed(fromPaceSecondsPerKm pace: Double) -> Double {
        guard pace > 0 else { return 0 }
        return 1_000 / pace
    }

    // MARK: - Lissage

    /// Moyenne glissante centrée. Renvoie la série telle quelle si la fenêtre
    /// est trop large pour être utile.
    static func movingAverage(_ values: [Double], window: Int) -> [Double] {
        guard window > 1, values.count > 2 else { return values }
        let half = window / 2
        return values.indices.map { i in
            let low = max(0, i - half)
            let high = min(values.count - 1, i + half)
            var sum = 0.0
            for j in low...high { sum += values[j] }
            return sum / Double(high - low + 1)
        }
    }

    /// Dénivelé positif cumulé d'une série d'altitudes déjà lissée.
    ///
    /// Le seuil fonctionne par hystérésis : la référence ne bouge que quand
    /// l'altitude s'en écarte franchement. Sans ça, un bruit de ±1 m sur une
    /// heure de course fabrique des centaines de mètres de D+ imaginaires.
    static func elevationGain(smoothedAltitudes: [Double], threshold: Double) -> Double {
        guard var reference = smoothedAltitudes.first else { return 0 }
        var gain = 0.0
        for altitude in smoothedAltitudes.dropFirst() {
            let delta = altitude - reference
            if delta >= threshold {
                gain += delta
                reference = altitude
            } else if delta <= -threshold {
                reference = altitude
            }
        }
        return gain
    }

    // MARK: - Dépense énergétique

    /// Énergie brute d'une course, en kilocalories.
    ///
    /// Coût horizontal : ~1,036 kcal par kilogramme et par kilomètre, la
    /// valeur classique de la littérature, remarquablement stable en fonction
    /// de l'allure. Coût vertical : le travail mécanique `m·g·h` divisé par un
    /// rendement musculaire de 25 %, soit ~0,0094 kcal par kilogramme et par
    /// mètre gravi.
    public static func energyKcal(meters: Double, elevationGain: Double, weightKg: Double) -> Double {
        guard meters > 0, weightKg > 0 else { return 0 }
        let horizontal = 1.036 * weightKg * (meters / 1_000)
        let vertical = 0.00938 * weightKg * max(0, elevationGain)
        return horizontal + vertical
    }

    // MARK: - Prédiction

    /// Prédit un temps de course sur une autre distance (formule de Riegel).
    ///
    /// `T₂ = T₁ · (D₂/D₁)^1,06`. Fiable dans un facteur ~4 autour de la
    /// distance de référence ; au-delà elle devient optimiste, surtout vers
    /// le marathon où le mur n'est pas dans l'équation.
    public static func predictedTime(
        fromDistance knownMeters: Double,
        time knownSeconds: TimeInterval,
        toDistance targetMeters: Double
    ) -> TimeInterval? {
        guard knownMeters > 0, knownSeconds > 0, targetMeters > 0 else { return nil }
        return knownSeconds * pow(targetMeters / knownMeters, 1.06)
    }

    /// Temps de course prévu sur une distance, à partir de l'allure de seuil.
    ///
    /// L'allure de seuil est, par construction, l'allure tenable une heure.
    /// On reconstruit donc la performance de référence « distance couverte en
    /// 3 600 s », puis on applique Riegel depuis celle-ci. Extrapoler
    /// directement depuis un kilomètre donnerait un marathon quarante fois
    /// plus long que la référence, très au-delà du domaine de validité de la
    /// formule.
    public static func predictedRaceTime(
        thresholdPaceSecondsPerKm threshold: Double,
        distanceMeters: Double
    ) -> TimeInterval? {
        guard threshold > 0, distanceMeters > 0 else { return nil }
        let hourDistance = 3_600 / threshold * 1_000
        return predictedTime(fromDistance: hourDistance, time: 3_600, toDistance: distanceMeters)
    }

    /// Estime l'allure de seuil (secondes par kilomètre) à partir d'une
    /// performance connue.
    ///
    /// Le seuil correspond à peu près à l'allure tenable une heure. On
    /// prédit donc le temps sur une distance parcourue en ~60 minutes,
    /// et on en tire l'allure.
    public static func thresholdPace(
        fromDistance meters: Double,
        time seconds: TimeInterval
    ) -> Double? {
        guard meters >= 1_000, seconds > 0 else { return nil }
        // Distance couverte en une heure à cette vitesse, corrigée par Riegel :
        // on cherche D tel que T(D) = 3600.
        // T = t · (D/d)^1,06  ⇒  D = d · (3600/t)^(1/1,06)
        let hourDistance = meters * pow(3_600 / seconds, 1 / 1.06)
        guard hourDistance > 0 else { return nil }
        return 3_600 / (hourDistance / 1_000)
    }
}
