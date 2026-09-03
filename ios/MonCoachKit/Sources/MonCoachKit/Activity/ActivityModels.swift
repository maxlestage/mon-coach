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
/// Un instant de puissance, en watts.
public struct PowerSample: Codable, Sendable, Equatable, Hashable {
    public var timestamp: Date
    public var watts: Int

    public init(timestamp: Date, watts: Int) {
        self.timestamp = timestamp
        self.watts = watts
    }
}

/// Un instant de cadence, en tours par minute.
public struct CadenceSample: Codable, Sendable, Equatable, Hashable {
    public var timestamp: Date
    public var rpm: Double

    public init(timestamp: Date, rpm: Double) {
        self.timestamp = timestamp
        self.rpm = rpm
    }
}

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
    /// Les battements mesurés pendant la sortie, si un capteur était là.
    public var heartRate: [HeartRateSample]
    /// La dépense active mesurée par la montre, en kilocalories.
    ///
    /// Nil pour une sortie enregistrée au téléphone ou avant que la montre
    /// la mesure : le moteur l'estime alors d'après la distance et le
    /// dénivelé. Quand elle est là, c'est elle qui compte — une mesure au
    /// poignet, cardio compris, vaut mieux qu'un modèle au kilomètre.
    public var kilocalories: Double?
    /// Effort ressenti, 1 à 10, saisi après la sortie.
    public var perceivedEffort: Int?
    public var note: String?
    /// Le matériel de la sortie — chaussures, vélo. Nil pour une sortie
    /// enregistrée avant que le matériel existe, ou sans matériel déclaré.
    public var gearID: UUID?
    /// La puissance mesurée par un capteur, en watts.
    ///
    /// Pourquoi elle est à part de la fréquence cardiaque
    /// --------------------------------------------------
    /// Le cardio dit ce que l'effort a coûté ; la puissance dit ce qu'il a
    /// produit. Les deux se ressemblent sur le plat et divergent partout
    /// ailleurs : dans une bosse, le cœur monte avec la chaleur et la
    /// fatigue alors que les watts ne mentent pas. Pour le vélo, c'est la
    /// mesure du sport — un entraînement sérieux se pilote dessus.
    ///
    /// Vide pour toute sortie sans capteur, ce qui reste le cas le plus
    /// courant : elle ne remplace rien, elle s'ajoute.
    public var power: [PowerSample]
    /// La cadence mesurée, en tours par minute — pédalier ou foulée.
    public var cadence: [CadenceSample]
    /// Les photos prises pendant la sortie, par identifiant.
    ///
    /// Les images elles-mêmes vivent en fichiers à part (`PhotoStore`) :
    /// l'état est relu et réécrit à chaque geste de l'athlète, et y coller
    /// des photos le ferait peser cent mégaoctets.
    public var photoIDs: [String]

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
        heartRate: [HeartRateSample] = [],
        kilocalories: Double? = nil,
        perceivedEffort: Int? = nil,
        note: String? = nil,
        gearID: UUID? = nil,
        power: [PowerSample] = [],
        cadence: [CadenceSample] = [],
        photoIDs: [String] = []
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
        self.heartRate = heartRate
        self.kilocalories = kilocalories
        self.perceivedEffort = perceivedEffort
        self.note = note
        self.gearID = gearID
        self.power = power
        self.cadence = cadence
        self.photoIDs = photoIDs
    }

    /// La puissance moyenne de la sortie, en watts.
    ///
    /// Une moyenne simple, pas une puissance normalisée : celle-ci demande
    /// une fenêtre glissante de trente secondes et une élévation à la
    /// quatrième puissance, et l'annoncer sans l'avoir calculée ainsi serait
    /// un chiffre qui ressemble à la bonne métrique sans en être une.
    public var averagePower: Int? {
        guard !power.isEmpty else { return nil }
        return Int((power.map { Double($0.watts) }.reduce(0, +) / Double(power.count)).rounded())
    }

    /// La cadence moyenne, en tours par minute.
    ///
    /// Les instants à zéro sont comptés : quelqu'un qui passe un tiers de sa
    /// sortie en roue libre pédale vraiment moins, et l'effacer donnerait
    /// une cadence de coureur d'échappée à une descente de col.
    public var averageCadence: Int? {
        guard !cadence.isEmpty else { return nil }
        return Int((cadence.map(\.rpm).reduce(0, +) / Double(cadence.count)).rounded())
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
        heartRate = try container.decodeIfPresent([HeartRateSample].self, forKey: .heartRate) ?? []
        perceivedEffort = try container.decodeIfPresent(Int.self, forKey: .perceivedEffort)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        gearID = try container.decodeIfPresent(UUID.self, forKey: .gearID)
        photoIDs = try container.decodeIfPresent([String].self, forKey: .photoIDs) ?? []
        // Absentes de tout ce qui a été enregistré avant les capteurs
        // externes. Les exiger rendrait illisible l'historique entier.
        power = try container.decodeIfPresent([PowerSample].self, forKey: .power) ?? []
        cadence = try container.decodeIfPresent([CadenceSample].self, forKey: .cadence) ?? []
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

    /// Ces deux enregistrements décrivent-ils la même sortie ?
    ///
    /// Pourquoi cette question se pose
    /// -------------------------------
    /// L'identifiant ne suffit pas. Un même fichier GPX importé deux fois
    /// produit deux identifiants — l'analyse en fabrique un neuf à chaque
    /// lecture — et le journal affiche alors la sortie en double, avec ses
    /// kilomètres comptés deux fois dans le volume de la semaine et dans la
    /// charge. Le même problème se pose quand le téléphone et la montre ont
    /// mesuré la sortie tous les deux.
    ///
    /// On compare donc ce qui identifie vraiment une sortie : le sport,
    /// l'heure de départ et la distance. Les tolérances sont serrées à
    /// dessein — deux minutes et cinq pour cent — parce que l'erreur
    /// inverse est bien pire : deux séries de côtes espacées d'un quart
    /// d'heure sont deux vraies sorties, et en effacer une serait effacer
    /// du travail réellement fait.
    public func describesSameOuting(as other: ActivityLog) -> Bool {
        guard sport == other.sport else { return false }
        guard abs(startedAt.timeIntervalSince(other.startedAt)) <= 120 else { return false }
        // Pour ce qui ne se déplace pas, la distance n'est pas une mesure :
        // c'est un chiffre recopié depuis l'écran d'une machine, présent
        // d'un côté et absent de l'autre selon l'appareil qui a enregistré.
        // La comparer ferait de la même séance de tapis deux séances dès
        // que la montre l'a remontée sans distance. L'heure suffit — deux
        // vrais cours de yoga ne commencent pas à deux minutes d'écart.
        guard sport.tracksLocation else { return true }
        guard meters > 0 || other.meters > 0 else { return true }
        let biggest = Swift.max(meters, other.meters)
        return abs(meters - other.meters) / biggest <= 0.05
    }

    /// Ce que cet enregistrement a de plus que l'autre.
    ///
    /// Sert à choisir lequel garder quand les deux décrivent la même
    /// sortie : celui qui porte le plus de mesures. Une trace de montre
    /// avec cardio vaut mieux qu'un import GPX sans battements, et
    /// l'inverse est vrai si c'est l'import qui porte la trace complète.
    public var measurementRichness: Int {
        points.count + heartRate.count * 2 + (bestEfforts?.count ?? 0)
    }
}
