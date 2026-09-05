import AppIntents
import MonCoachKit

/// Le sport, tel que Siri et les Raccourcis le proposent.
///
/// Pourquoi une deuxième liste
/// ---------------------------
/// `Sport` vit dans MonCoachKit, et App Intents refuse deux choses que cela
/// impliquait : un enum déclaré dans une bibliothèque importée, et une table
/// de noms calculée à l'exécution. Son processeur de métadonnées veut des
/// valeurs littérales, écrites dans le module de l'application, qu'il puisse
/// lire sans exécuter une ligne de code — c'est ce qui lui permet de bâtir la
/// liste avant même que l'application ne démarre.
///
/// D'où cette copie. Elle est tenue synchronisée par un contrôle
/// (`tools/checks/sports_intents.py`) plutôt que par la vigilance : un sport
/// ajouté au catalogue et oublié ici ne se verrait qu'à l'usage, le jour où
/// quelqu'un le demanderait à Siri et s'entendrait répondre non.
///
/// Les noms sont en français. App Intents lit ses libellés dans un catalogue
/// de chaînes, que ce projet n'emploie pas — la traduction passe partout
/// ailleurs par `LocalizedText`, qui se résout à l'exécution et arrive donc
/// trop tard pour lui. Les phrases des raccourcis, elles, restent dans les
/// trois langues.
enum ActivitySport: String, AppEnum, CaseIterable {
    case run
    case trail
    case walk
    case hike
    case treadmill
    case ride
    case mountainBike
    case gravelRide
    case eBike
    case indoorRide
    case inlineSkate
    case skateboard
    case swim
    case openWaterSwim
    case rowing
    case kayak
    case canoe
    case standUpPaddle
    case surf
    case windsurf
    case kitesurf
    case sailing
    case alpineSki
    case nordicSki
    case skiTouring
    case snowboard
    case snowshoe
    case iceSkate
    case weightTraining
    case hiit
    case crossTraining
    case rowingMachine
    case elliptical
    case stairMaster
    case yoga
    case pilates
    case stretching
    // Sports adaptés. Ils sont dans la liste que Siri lit comme les autres :
    // demander « démarre un handbike » doit marcher exactement comme
    // demander « démarre une course », et une liste qui s'arrêterait aux
    // sports valides ferait de l'assistant vocal — l'outil qui sert le plus
    // quand les mains sont prises — le seul endroit inaccessible de
    // l'application.
    case adaptiveWalk
    case wheelchairPush
    case wheelchairRacing
    case handcycling
    case adaptiveTricycle
    case adaptiveSwim
    case seatedStrength
    case seatedMobility
    case wheelchairBasketball
    case wheelchairTennis
    case boccia

    // La conduite : demander « démarre un trajet » à Siri au volant est
    // exactement le geste que l'assistant vocal doit servir.
    case motocross
    case enduro
    case motoTrial
    case roadMotorcycling
    case karting
    case circuitRacing
    case rally
    case quad
    case jetSki
    case snowmobile

    case driving

    case climbing
    case golf
    case tennis
    case padel
    case badminton
    case football
    case basketball
    case boxing
    case martialArts
    case dance
    case equestrian

    // Stockées et non calculées : le processeur de métadonnées veut une
    // valeur qu'il puisse lire dans le source, et `let` évite au passage
    // l'état global mutable que Swift 6 refuse.
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Sport")

    static let caseDisplayRepresentations: [ActivitySport: DisplayRepresentation] = [
        .run: DisplayRepresentation(title: "Course à pied"),
        .trail: DisplayRepresentation(title: "Trail"),
        .walk: DisplayRepresentation(title: "Marche"),
        .hike: DisplayRepresentation(title: "Randonnée"),
        .treadmill: DisplayRepresentation(title: "Tapis de course"),
        .ride: DisplayRepresentation(title: "Vélo"),
        .mountainBike: DisplayRepresentation(title: "VTT"),
        .gravelRide: DisplayRepresentation(title: "Gravel"),
        .eBike: DisplayRepresentation(title: "Vélo électrique"),
        .indoorRide: DisplayRepresentation(title: "Home trainer"),
        .inlineSkate: DisplayRepresentation(title: "Roller"),
        .skateboard: DisplayRepresentation(title: "Skateboard"),
        .swim: DisplayRepresentation(title: "Natation"),
        .openWaterSwim: DisplayRepresentation(title: "Nage en eau libre"),
        .rowing: DisplayRepresentation(title: "Aviron"),
        .kayak: DisplayRepresentation(title: "Kayak"),
        .canoe: DisplayRepresentation(title: "Canoë"),
        .standUpPaddle: DisplayRepresentation(title: "Paddle"),
        .surf: DisplayRepresentation(title: "Surf"),
        .windsurf: DisplayRepresentation(title: "Planche à voile"),
        .kitesurf: DisplayRepresentation(title: "Kitesurf"),
        .sailing: DisplayRepresentation(title: "Voile"),
        .alpineSki: DisplayRepresentation(title: "Ski alpin"),
        .nordicSki: DisplayRepresentation(title: "Ski de fond"),
        .skiTouring: DisplayRepresentation(title: "Ski de randonnée"),
        .snowboard: DisplayRepresentation(title: "Snowboard"),
        .snowshoe: DisplayRepresentation(title: "Raquettes"),
        .iceSkate: DisplayRepresentation(title: "Patin à glace"),
        .weightTraining: DisplayRepresentation(title: "Musculation"),
        .hiit: DisplayRepresentation(title: "Fractionné en salle"),
        .crossTraining: DisplayRepresentation(title: "Renforcement"),
        .rowingMachine: DisplayRepresentation(title: "Rameur"),
        .elliptical: DisplayRepresentation(title: "Vélo elliptique"),
        .stairMaster: DisplayRepresentation(title: "Escalier"),
        .yoga: DisplayRepresentation(title: "Yoga"),
        .pilates: DisplayRepresentation(title: "Pilates"),
        .stretching: DisplayRepresentation(title: "Étirements"),
        .climbing: DisplayRepresentation(title: "Escalade"),
        .golf: DisplayRepresentation(title: "Golf"),
        .tennis: DisplayRepresentation(title: "Tennis"),
        .padel: DisplayRepresentation(title: "Padel"),
        .badminton: DisplayRepresentation(title: "Badminton"),
        .football: DisplayRepresentation(title: "Football"),
        .basketball: DisplayRepresentation(title: "Basket"),
        .boxing: DisplayRepresentation(title: "Boxe"),
        .martialArts: DisplayRepresentation(title: "Arts martiaux"),
        .dance: DisplayRepresentation(title: "Danse"),
        .equestrian: DisplayRepresentation(title: "Équitation"),

        .adaptiveWalk: DisplayRepresentation(title: "Marche adaptée"),
        .wheelchairPush: DisplayRepresentation(title: "Fauteuil"),
        .wheelchairRacing: DisplayRepresentation(title: "Fauteuil de course"),
        .handcycling: DisplayRepresentation(title: "Handbike"),
        .adaptiveTricycle: DisplayRepresentation(title: "Tricycle adapté"),
        .adaptiveSwim: DisplayRepresentation(title: "Natation adaptée"),
        .seatedStrength: DisplayRepresentation(title: "Renforcement assis"),
        .seatedMobility: DisplayRepresentation(title: "Mobilité assise"),
        .wheelchairBasketball: DisplayRepresentation(title: "Basket fauteuil"),
        .wheelchairTennis: DisplayRepresentation(title: "Tennis fauteuil"),
        .boccia: DisplayRepresentation(title: "Boccia"),

        .motocross: DisplayRepresentation(title: "Motocross"),
        .enduro: DisplayRepresentation(title: "Enduro"),
        .motoTrial: DisplayRepresentation(title: "Trial"),
        .roadMotorcycling: DisplayRepresentation(title: "Moto"),
        .karting: DisplayRepresentation(title: "Karting"),
        .circuitRacing: DisplayRepresentation(title: "Auto sur circuit"),
        .rally: DisplayRepresentation(title: "Rallye"),
        .quad: DisplayRepresentation(title: "Quad"),
        .jetSki: DisplayRepresentation(title: "Jet-ski"),
        .snowmobile: DisplayRepresentation(title: "Motoneige"),

        .driving: DisplayRepresentation(title: "Conduite"),
    ]

    /// Le sport du moteur. Les deux listes partagent leurs identifiants
    /// bruts, ce que le contrôle vérifie ; l'échec ne peut donc pas arriver,
    /// et la course est le repli le moins surprenant s'il arrivait quand même.
    var sport: Sport { Sport(rawValue: rawValue) ?? .run }
}
