#if canImport(HealthKit)

import HealthKit

/// Ce que chaque sport devient pour la montre.
///
/// Pourquoi une session d'entraînement HealthKit est indispensable
/// ----------------------------------------------------------------
/// Sur watchOS, une application qui mesure une sortie sans ouvrir de
/// session d'entraînement est suspendue quelques secondes après que le
/// poignet baisse : le GPS se tait, le chrono se fige, et le capteur
/// cardiaque ne mesure qu'un battement toutes les quelques minutes. C'est
/// la session qui tient l'application éveillée, allume le capteur en
/// continu, et fait compter l'effort dans les anneaux d'Activité — ce que
/// toute personne qui porte une montre attend d'une application de sport.
///
/// La table est un `switch` exhaustif, pas un dictionnaire : un sport
/// ajouté au catalogue sans son type d'entraînement ne compile pas, au lieu
/// d'être enregistré en « autre » sans que personne ne s'en aperçoive.
extension Sport {

    /// Le type d'entraînement Apple qui correspond au sport.
    ///
    /// Le plus proche quand il n'y a pas d'exact : le trail est une course,
    /// le padel un tennis, les raquettes une randonnée. C'est ce type qui
    /// décide de la façon dont la montre estime la dépense.
    public var workoutActivityType: HKWorkoutActivityType {
        switch self {
        case .run, .trail, .treadmill: .running
        case .walk: .walking
        case .hike, .snowshoe: .hiking

        case .ride, .mountainBike, .gravelRide, .eBike, .indoorRide: .cycling
        case .inlineSkate, .skateboard, .iceSkate: .skatingSports

        case .swim, .openWaterSwim: .swimming
        case .rowing, .rowingMachine: .rowing
        case .kayak, .canoe, .standUpPaddle: .paddleSports
        case .surf, .windsurf, .kitesurf: .surfingSports
        case .sailing: .sailing

        case .alpineSki: .downhillSkiing
        case .nordicSki, .skiTouring: .crossCountrySkiing
        case .snowboard: .snowboarding

        case .weightTraining: .traditionalStrengthTraining
        case .hiit: .highIntensityIntervalTraining
        case .crossTraining: .crossTraining
        case .elliptical: .elliptical
        case .stairMaster: .stairClimbing
        case .yoga: .yoga
        case .pilates: .pilates
        case .stretching: .flexibility

        case .climbing: .climbing
        case .golf: .golf
        case .tennis, .padel: .tennis
        case .badminton: .badminton
        case .football: .soccer
        case .basketball: .basketball
        case .boxing: .boxing
        case .martialArts: .martialArts
        case .dance: .dance
        case .equestrian: .equestrianSports
        }
    }

    /// Dehors ou dedans, tel que la montre le comprend.
    ///
    /// Ce n'est pas qu'une étiquette : en extérieur, la montre allume son
    /// GPS et étalonne sa foulée ; en intérieur, elle compte les pas et la
    /// cadence sans chercher un signal qui ne viendra pas.
    public var workoutLocationType: HKWorkoutSessionLocationType {
        tracksLocation ? .outdoor : .indoor
    }

    /// La distance que la montre mesure d'elle-même pour ce sport, quand
    /// elle en mesure une.
    ///
    /// Elle compte pour ce qui n'a pas de GPS : un tapis de course, un
    /// rameur, un home trainer ont une distance, que la montre estime à la
    /// foulée ou à la cadence. Rien pour un cours de yoga ni un match de
    /// tennis : une distance inventée vaudrait moins que pas de distance.
    public var workoutDistanceType: HKQuantityTypeIdentifier? {
        switch self {
        case .run, .trail, .walk, .hike, .treadmill, .snowshoe, .golf:
            .distanceWalkingRunning
        case .ride, .mountainBike, .gravelRide, .eBike, .indoorRide:
            .distanceCycling
        case .swim, .openWaterSwim:
            .distanceSwimming
        case .rowing, .rowingMachine:
            .distanceRowing
        case .kayak, .canoe, .standUpPaddle:
            .distancePaddleSports
        case .inlineSkate, .skateboard, .iceSkate:
            .distanceSkatingSports
        case .alpineSki, .snowboard:
            .distanceDownhillSnowSports
        case .nordicSki, .skiTouring:
            .distanceCrossCountrySkiing
        default:
            nil
        }
    }

    /// Une distance a-t-elle un sens pour ce sport, alors que rien ne la
    /// mesure ?
    ///
    /// C'est le cas des machines : un home trainer et un vélo elliptique
    /// affichent leur distance sur leur propre écran, et la montre ne la
    /// voit pas. On la demande alors à l'athlète à la fin, à la couronne,
    /// plutôt que d'enregistrer zéro kilomètre pour quarante minutes.
    public var asksDistanceAtTheEnd: Bool {
        switch self {
        case .indoorRide, .elliptical, .stairMaster: true
        default: false
        }
    }
}

#endif
