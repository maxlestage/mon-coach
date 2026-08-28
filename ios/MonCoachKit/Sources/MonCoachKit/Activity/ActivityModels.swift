import Foundation

// Les types de l'enregistrement d'une activité : le point brut tel que le
// système le donne, le segment mesuré, et l'activité une fois analysée.
// Ils ne savent rien du plan d'entraînement — un randonneur qui ne suit
// aucun programme enregistre exactement les mêmes objets.

/// Un point GPS brut, tel que le système le fournit.
///
/// L'altitude et les précisions sont conservées telles quelles : c'est
/// l'analyse qui décidera de ce qui est exploitable, et elle doit pouvoir
/// justifier ses rejets.
public struct GPSPoint: Codable, Sendable, Equatable, Hashable {
    public var timestamp: Date
    public var latitude: Double
    public var longitude: Double
    /// Altitude en mètres au-dessus du niveau de la mer.
    public var altitude: Double
    /// Rayon d'incertitude horizontale en mètres. Négatif si invalide.
    public var horizontalAccuracy: Double
    /// Incertitude verticale en mètres. Négatif si invalide.
    public var verticalAccuracy: Double

    public init(
        timestamp: Date,
        latitude: Double,
        longitude: Double,
        altitude: Double = 0,
        horizontalAccuracy: Double = 5,
        verticalAccuracy: Double = 5
    ) {
        self.timestamp = timestamp
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
    }
}

/// Un kilomètre couru, tel qu'il s'est réellement passé.
public struct Split: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: Int { index }
    /// 1 pour le premier kilomètre.
    public var index: Int
    /// Distance réellement couverte par ce segment, en mètres.
    /// Le dernier segment est souvent incomplet.
    public var meters: Double
    public var duration: TimeInterval
    /// Dénivelé positif du segment, en mètres.
    public var elevationGain: Double

    public init(index: Int, meters: Double, duration: TimeInterval, elevationGain: Double) {
        self.index = index
        self.meters = meters
        self.duration = duration
        self.elevationGain = elevationGain
    }

    /// Allure en secondes par kilomètre.
    public var paceSecondsPerKm: Double {
        meters > 0 ? duration / (meters / 1_000) : 0
    }
}

/// Une activité enregistrée : une course, une sortie vélo, une randonnée.
///
/// Le sport et le dénivelé négatif sont arrivés après la première version.
/// Un fichier écrit par une version antérieure ne les contient pas, et le
/// décodage synthétisé échouerait dessus — or un état illisible est mis de
/// côté, donc l'athlète verrait son historique entier disparaître. Le
/// décodeur écrit à la main plus bas leur donne une valeur par défaut :
/// avant le multi-sport, tout ce qui était enregistré était une course.
public struct ActivityLog: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var startedAt: Date
    /// Le sport pratiqué.
    public var sport: Sport
    /// L'intention de la séance — endurance, tempo, fractionné.
    public var type: RunType
    /// La trace brute. Conservée telle quelle : les filtres de l'analyse
    /// peuvent évoluer, les points d'origine ne doivent pas être perdus.
    public var points: [GPSPoint]
    /// Distance retenue après filtrage, en mètres.
    public var meters: Double
    /// Temps en mouvement, pauses exclues.
    public var duration: TimeInterval
    public var elevationGain: Double
    /// Dénivelé négatif, en mètres. Il compte : une randonnée en descente
    /// coûte aux jambes ce qu'elle ne coûte plus au souffle.
    public var elevationLoss: Double
    public var splits: [Split]
    /// Les meilleurs efforts trouvés dans cette activité, calculés une seule
    /// fois. `nil` pour une activité enregistrée avant qu'ils existent ;
    /// un tableau vide veut dire « calculé, rien trouvé ».
    public var bestEfforts: [BestEffort]?
    /// Effort ressenti, 1 à 10, saisi après la sortie.
    public var perceivedEffort: Int?
    public var note: String?

    public init(
        id: UUID = UUID(),
        startedAt: Date,
        sport: Sport = .run,
        type: RunType,
        points: [GPSPoint] = [],
        meters: Double,
        duration: TimeInterval,
        elevationGain: Double,
        elevationLoss: Double = 0,
        splits: [Split] = [],
        bestEfforts: [BestEffort]? = nil,
        perceivedEffort: Int? = nil,
        note: String? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.sport = sport
        self.type = type
        self.points = points
        self.meters = meters
        self.duration = duration
        self.elevationGain = elevationGain
        self.elevationLoss = elevationLoss
        self.splits = splits
        self.bestEfforts = bestEfforts
        self.perceivedEffort = perceivedEffort
        self.note = note
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startedAt = try container.decode(Date.self, forKey: .startedAt)
        // Les deux seules clés tolérées absentes, et pour une raison datée :
        // elles n'existaient pas avant le multi-sport.
        sport = try container.decodeIfPresent(Sport.self, forKey: .sport) ?? .run
        elevationLoss = try container.decodeIfPresent(Double.self, forKey: .elevationLoss) ?? 0
        type = try container.decode(RunType.self, forKey: .type)
        points = try container.decode([GPSPoint].self, forKey: .points)
        meters = try container.decode(Double.self, forKey: .meters)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        elevationGain = try container.decode(Double.self, forKey: .elevationGain)
        splits = try container.decode([Split].self, forKey: .splits)
        bestEfforts = try container.decodeIfPresent([BestEffort].self, forKey: .bestEfforts)
        perceivedEffort = try container.decodeIfPresent(Int.self, forKey: .perceivedEffort)
        note = try container.decodeIfPresent(String.self, forKey: .note)
    }

    /// Allure en secondes par kilomètre.
    public var paceSecondsPerKm: Double {
        meters > 0 ? duration / (meters / 1_000) : 0
    }

    /// Vitesse moyenne en kilomètres par heure — la lecture du cycliste.
    public var speedKmh: Double {
        duration > 0 ? (meters / 1_000) / (duration / 3_600) : 0
    }

    public var kilometers: Double { meters / 1_000 }

    /// Vrai si cette activité doit nourrir le plan de course.
    public var feedsRunningPlan: Bool { sport.feedsRunningPlan }
}
