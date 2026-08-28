import Foundation

/// Le sport d'une activité enregistrée.
///
/// Un même moteur de trace sert les cinq, mais pas avec les mêmes réglages :
/// un vélo descend à 70 km/h, un randonneur monte à 2 km/h, et le filtre qui
/// convient à l'un jette la sortie de l'autre. Chaque sport porte donc ses
/// propres seuils plutôt que de les laisser à l'appelant, qui les oublierait.
public enum Sport: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case run
    case trail
    case ride
    case walk
    case hike

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .run: LocalizedText(fr: "Course", en: "Run", es: "Carrera")
        case .trail: LocalizedText(fr: "Trail", en: "Trail run", es: "Trail")
        case .ride: LocalizedText(fr: "Vélo", en: "Ride", es: "Bici")
        case .walk: LocalizedText(fr: "Marche", en: "Walk", es: "Caminata")
        case .hike: LocalizedText(fr: "Randonnée", en: "Hike", es: "Senderismo")
        }
    }

    /// Le symbole système correspondant.
    ///
    /// Rangé ici et non dans les vues : le téléphone et la montre affichent
    /// les mêmes sports, et deux tables tenues séparément finiraient par ne
    /// plus montrer la même icône pour la même activité.
    public var symbolName: String {
        switch self {
        case .run: "figure.run"
        case .trail: "figure.hiking"
        case .ride: "bicycle"
        case .walk: "figure.walk"
        case .hike: "mountain.2"
        }
    }

    /// Vrai quand l'activité alimente le plan de course.
    ///
    /// Décisif, et pas un détail de présentation : une sortie vélo de 60 km
    /// versée au kilométrage hebdomadaire ferait tripler le volume prescrit
    /// la semaine suivante, et une moyenne à 30 km/h prise pour une allure de
    /// seuil rendrait toutes les allures du plan intenables.
    public var feedsRunningPlan: Bool {
        switch self {
        case .run, .trail: true
        case .ride, .walk, .hike: false
        }
    }

    /// Ce qu'on affiche pour dire « à quelle vitesse ».
    public var readout: SpeedReadout {
        switch self {
        case .run, .trail, .walk, .hike: .pacePerKilometre
        case .ride: .speed
        }
    }

    /// Les réglages de filtrage de la trace GPS pour ce sport.
    public var filter: TraceFilter {
        switch self {
        case .run:
            TraceFilter()
        case .trail:
            // Sous les arbres et entre les parois, exiger 25 m de précision
            // reviendrait à jeter la sortie entière.
            TraceFilter(
                maxHorizontalAccuracy: 40,
                pauseSpeed: 0.4,
                elevationWindow: 7,
                elevationThreshold: 1.5
            )
        case .ride:
            // 30 m/s, c'est 108 km/h : au-delà, c'est un saut de GPS, pas une
            // descente. Le seuil de pause monte, parce qu'un vélo à l'arrêt
            // dérive plus qu'un coureur, et le seuil de dénivelé aussi : à
            // 30 km/h le moindre bruit d'altitude est parcouru si vite qu'un
            // seuil d'un mètre fabrique du D+ à chaque coup de pédale.
            TraceFilter(
                maxSpeed: 30,
                pauseSpeed: 1.0,
                minSegmentMeters: 2,
                elevationWindow: 7,
                elevationThreshold: 2
            )
        case .walk:
            // Voir la randonnée : le déplacement minimal descend aussi, sinon
            // une flânerie à 2,9 km/h est comptée comme un arrêt.
            TraceFilter(maxSpeed: 4, pauseSpeed: 0.3, minSegmentMeters: 0.2)
        case .hike:
            // Deux seuils descendent ensemble, et il faut les deux.
            //
            // Le seuil de pause d'abord : 0,25 m/s, soit 0,9 km/h. Avec le
            // 0,5 m/s de la course, une montée raide — où l'on avance
            // réellement à 1,5 km/h — serait comptée comme un arrêt.
            //
            // Le déplacement minimal ensuite, et c'est celui qu'on oublie :
            // à 1,3 km/h et un point par seconde, chaque segment mesure
            // 36 cm. Le mètre exigé pour la course les jette tous, un par un,
            // et la randonnée finit à zéro kilomètre pour zéro minute — pas
            // amputée, effacée.
            TraceFilter(
                maxHorizontalAccuracy: 40,
                maxSpeed: 5,
                pauseSpeed: 0.25,
                minSegmentMeters: 0.2,
                elevationWindow: 7,
                elevationThreshold: 1.5
            )
        }
    }

    /// Vitesse en dessous de laquelle une moyenne est suspecte, en m/s.
    /// Sert à prévenir l'athlète, pas à corriger la mesure.
    public var implausiblySlowSpeed: Double {
        switch self {
        case .run, .trail: 1.0
        case .ride: 1.5
        case .walk, .hike: 0.2
        }
    }
}

/// Comment se dit la vitesse, selon le sport.
///
/// Une allure au kilomètre pour ce qui se court ou se marche, une vitesse
/// horaire pour ce qui roule : personne n'a jamais annoncé un col en
/// minutes par kilomètre.
public enum SpeedReadout: String, Codable, Sendable {
    case pacePerKilometre
    case speed
}
