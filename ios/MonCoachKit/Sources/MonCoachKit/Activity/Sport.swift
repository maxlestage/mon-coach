import Foundation

/// La famille d'un sport, telle qu'on la cherche dans une liste.
///
/// Le classement n'est pas décoratif : quarante-huit sports en une colonne
/// ne se parcourent pas, et personne ne cherche « aviron » entre « padel »
/// et « yoga ». On range par ce qui porte le corps — les pieds, des roues,
/// l'eau, la neige, une machine — parce que c'est ainsi qu'on se demande
/// « je fais quoi aujourd'hui ».
public enum SportFamily: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case foot
    case wheels
    case water
    case snow
    case indoor
    case adaptive
    case motorsport
    case travel
    case other

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .foot: LocalizedText(fr: "Sports à pied", en: "On foot", es: "Deportes a pie")
        case .wheels: LocalizedText(fr: "Sports sur roues", en: "On wheels", es: "Sobre ruedas")
        case .water: LocalizedText(fr: "Sports d'eau", en: "On water", es: "En el agua")
        case .snow: LocalizedText(fr: "Sports d'hiver", en: "On snow and ice", es: "Nieve y hielo")
        case .indoor: LocalizedText(fr: "En salle", en: "Indoors", es: "En sala")
        // Le nom porte la pratique, pas la personne.
        //
        // Les autres familles disent un terrain — à pied, sur roues, dans
        // l'eau. Une famille nommée d'après un handicap étiquetterait celui
        // qui la choisit au lieu de dire ce qu'il fait. « Adaptés » dit la
        // seule chose qui compte ici : le sport s'ajuste au corps, et non
        // l'inverse.
        //
        // C'est aussi le seul mot qui ne prend pas parti. La France a deux
        // fédérations — Handisport pour le handicap physique et sensoriel,
        // Sport Adapté pour le handicap mental et psychique — et retenir le
        // nom de l'une exclurait les pratiquants de l'autre. « Sport
        // adapté » au sens large, « adaptive sports » en anglais, est le
        // terme que le reste du monde emploie.
        case .adaptive: LocalizedText(
            fr: "Sports adaptés", en: "Adaptive sports", es: "Deportes adaptados"
        )
        case .motorsport: LocalizedText(
            fr: "Sports mécaniques", en: "Motorsport", es: "Deportes de motor"
        )
        // Une famille qui dit franchement que ce n'est pas du sport.
        //
        // La ranger dans « Autres sports » aurait suffi techniquement, et
        // aurait menti dans le mot le plus visible de l'écran. Un trajet en
        // voiture n'est pas un sport : il se trace, il ne se compte pas.
        case .travel: LocalizedText(
            fr: "Déplacements", en: "Getting around", es: "Desplazamientos"
        )
        case .other: LocalizedText(fr: "Autres sports", en: "Other sports", es: "Otros deportes")
        }
    }

    /// Les sports de cette famille, dans l'ordre du catalogue.
    public var sports: [Sport] { Sport.allCases.filter { $0.family == self } }
}

/// Comment le corps se déplace — ce qui décide du filtrage de la trace.
///
/// Six modes plutôt que quarante-huit réglages : un kayak et un paddle
/// dérivent de la même façon, un VTT et un gravel sautent de la même façon.
/// Écrire un jeu de seuils par sport garantirait qu'un des quarante-huit
/// finisse par mentir sans que personne s'en aperçoive.
public enum SportMode: String, Codable, Sendable, Hashable {
    /// Ce qui court : foulée rapide, GPS dégagé.
    case running
    /// Ce qui court en terrain couvert : mêmes vitesses, ciel bouché.
    case trailRunning
    /// Ce qui marche : lent, et d'autant plus fragile au filtrage.
    case walking
    /// Ce qui roule : vite, et sensible au faux dénivelé.
    case rolling
    /// Ce qui flotte : pas de dénivelé, jamais.
    case floating
    /// Ce qui glisse sur la neige : descentes rapides, D+ réel.
    case gliding
    /// Ce qui ne va nulle part : un tapis, un rameur, un tapis de sol.
    case stationary
    /// Ce qui est motorisé : ça se déplace vite, et le corps ne fournit
    /// rien. Le mode existe pour que le reste du moteur puisse le savoir
    /// sans avoir à connaître la liste des sports concernés.
    case motorised
}

/// Le sport d'une activité enregistrée.
///
/// Pourquoi cette liste est longue
/// -------------------------------
/// Un athlète ne fait pas cinq choses. Il court, il roule, il nage, il
/// grimpe, il rame l'hiver quand il pleut, et il fait du padel le jeudi.
/// Une application qui n'en connaît que cinq oblige à mentir sur les trois
/// quarts — et une heure de padel enregistrée en « marche » fausse la
/// charge, les calories et la fatigue du lendemain.
///
/// Chaque sport porte ce que le moteur doit savoir en faire : comment
/// filtrer sa trace, comment lire sa vitesse, ce qu'il coûte en énergie, ce
/// qu'il pèse sur la charge, et s'il nourrit le plan de course. Rien n'est
/// laissé à l'appelant, qui l'oublierait.
///
/// Les cinq premiers identifiants sont ceux d'avant : un historique déjà
/// enregistré se relit à l'identique.
public enum Sport: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    // MARK: À pied
    case run
    case trail
    case walk
    case hike
    case treadmill

    // MARK: Sur roues
    case ride
    case mountainBike
    case gravelRide
    case eBike
    case indoorRide
    case inlineSkate
    case skateboard

    // MARK: Sur l'eau
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

    // MARK: Neige et glace
    case alpineSki
    case nordicSki
    case skiTouring
    case snowboard
    case snowshoe
    case iceSkate

    // MARK: En salle
    case weightTraining
    case hiit
    case crossTraining
    case rowingMachine
    case elliptical
    case stairMaster
    case yoga
    case pilates
    case stretching

    // MARK: Sports adaptés
    //
    // Ce que cette famille change, et ce qu'elle ne change pas
    // -------------------------------------------------------
    // Elle ne crée pas un catalogue à part : ces sports vivent dans la même
    // énumération que les autres, portent les mêmes propriétés, et un
    // athlète qui fait du handbike le mardi et de la natation le jeudi
    // relit ses deux séances dans le même journal. Une application séparée
    // « pour les handicapés » serait une mise à l'écart de plus.
    //
    // Ce qu'elle change, c'est que le sport réellement pratiqué existe dans
    // la liste. Sans elle, une heure de basket fauteuil s'enregistrait en
    // « basket » — avec la dépense d'un joueur qui court — et deux
    // kilomètres poussés en fauteuil n'avaient aucune case du tout.
    //
    // L'hémiplégie n'y figure pas comme un sport, et c'est délibéré : c'est
    // un état du corps, pas une activité. Ce qui sert à quelqu'un dont un
    // côté ne répond plus, c'est que ce qu'il fait vraiment soit là — la
    // marche adaptée avec sa canne ou son releveur, le tricycle qui tient
    // debout tout seul, l'eau qui porte le côté atteint, le renforcement
    // assis qui travaille un côté à la fois, la mobilité contre la
    // spasticité. Ces cinq-là sont dans la liste pour cette raison.
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

    // MARK: Sports mécaniques
    //
    // Un moteur fait avancer l'engin ; il ne tient pas le guidon.
    //
    // La distinction avec la conduite n'est pas une nuance : c'est ce qui
    // décide si l'activité compte. Un trajet en voiture ne coûte rien —
    // on est assis, le corps ne fournit pas. Quarante minutes de motocross
    // sont un effort entier : le pilote tient l'engin aux bras et aux
    // jambes, encaisse les bosses, et sa fréquence cardiaque ne redescend
    // pas. Les deux se ressemblent de loin et n'ont rien à voir de près.
    //
    // Ils partagent en revanche le mode motorisé, parce que le filtrage de
    // la trace ne s'intéresse qu'à la vitesse : un rallye et une autoroute
    // dépassent tous deux le plafond du vélo.
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

    // MARK: Déplacements
    //
    // La conduite n'est pas un sport, et tout ce fichier est bâti pour des
    // sports. Elle entre quand même dans l'énumération, parce que c'est le
    // seul endroit d'où l'application sait tracer un déplacement — et
    // qu'un trajet noté « vélo » faute de mieux fabrique quarante kilomètres
    // de sport qui n'ont pas été faits.
    //
    // Ce qui la distingue est explicite partout où ça compte : elle ne coûte
    // aucune calorie, n'entre pas dans la charge d'entraînement, ne nourrit
    // pas le plan de course, et n'ouvre pas de session d'entraînement — donc
    // rien n'est écrit dans Santé et les anneaux ne bougent pas.
    case driving

    // MARK: Autres
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

    public var id: String { rawValue }

    // MARK: - Ce que ça s'appelle

    public var label: LocalizedText {
        switch self {
        case .run: LocalizedText(fr: "Course à pied", en: "Run", es: "Carrera")
        case .trail: LocalizedText(fr: "Trail", en: "Trail run", es: "Trail")
        case .walk: LocalizedText(fr: "Marche", en: "Walk", es: "Caminata")
        case .hike: LocalizedText(fr: "Randonnée", en: "Hike", es: "Senderismo")
        case .treadmill: LocalizedText(fr: "Tapis de course", en: "Treadmill", es: "Cinta de correr")

        case .ride: LocalizedText(fr: "Vélo", en: "Ride", es: "Bici")
        case .mountainBike: LocalizedText(fr: "VTT", en: "Mountain bike", es: "BTT")
        case .gravelRide: LocalizedText(fr: "Gravel", en: "Gravel ride", es: "Gravel")
        case .eBike: LocalizedText(fr: "Vélo électrique", en: "E-bike ride", es: "Bici eléctrica")
        case .indoorRide: LocalizedText(fr: "Home trainer", en: "Indoor ride", es: "Rodillo")
        case .inlineSkate: LocalizedText(fr: "Roller", en: "Inline skate", es: "Patinaje en línea")
        case .skateboard: LocalizedText(fr: "Skateboard", en: "Skateboard", es: "Monopatín")

        case .swim: LocalizedText(fr: "Natation", en: "Pool swim", es: "Natación")
        case .openWaterSwim: LocalizedText(fr: "Nage en eau libre", en: "Open water swim", es: "Aguas abiertas")
        case .rowing: LocalizedText(fr: "Aviron", en: "Rowing", es: "Remo")
        case .kayak: LocalizedText(fr: "Kayak", en: "Kayak", es: "Kayak")
        case .canoe: LocalizedText(fr: "Canoë", en: "Canoe", es: "Canoa")
        case .standUpPaddle: LocalizedText(fr: "Paddle", en: "Stand-up paddle", es: "Paddle surf")
        case .surf: LocalizedText(fr: "Surf", en: "Surfing", es: "Surf")
        case .windsurf: LocalizedText(fr: "Planche à voile", en: "Windsurf", es: "Windsurf")
        case .kitesurf: LocalizedText(fr: "Kitesurf", en: "Kitesurf", es: "Kitesurf")
        case .sailing: LocalizedText(fr: "Voile", en: "Sailing", es: "Vela")

        case .alpineSki: LocalizedText(fr: "Ski alpin", en: "Alpine ski", es: "Esquí alpino")
        case .nordicSki: LocalizedText(fr: "Ski de fond", en: "Nordic ski", es: "Esquí de fondo")
        case .skiTouring: LocalizedText(fr: "Ski de randonnée", en: "Ski touring", es: "Esquí de travesía")
        case .snowboard: LocalizedText(fr: "Snowboard", en: "Snowboard", es: "Snowboard")
        case .snowshoe: LocalizedText(fr: "Raquettes", en: "Snowshoe", es: "Raquetas de nieve")
        case .iceSkate: LocalizedText(fr: "Patin à glace", en: "Ice skate", es: "Patinaje sobre hielo")

        case .weightTraining: LocalizedText(fr: "Musculation", en: "Weight training", es: "Pesas")
        case .hiit: LocalizedText(fr: "Fractionné en salle", en: "HIIT", es: "HIIT")
        case .crossTraining: LocalizedText(fr: "Renforcement", en: "Cross training", es: "Entrenamiento cruzado")
        case .rowingMachine: LocalizedText(fr: "Rameur", en: "Rowing machine", es: "Remo indoor")
        case .elliptical: LocalizedText(fr: "Vélo elliptique", en: "Elliptical", es: "Elíptica")
        case .stairMaster: LocalizedText(fr: "Escalier", en: "Stair stepper", es: "Escaladora")
        case .yoga: LocalizedText(fr: "Yoga", en: "Yoga", es: "Yoga")
        case .pilates: LocalizedText(fr: "Pilates", en: "Pilates", es: "Pilates")
        case .stretching: LocalizedText(fr: "Étirements", en: "Stretching", es: "Estiramientos")

        case .adaptiveWalk: LocalizedText(
            fr: "Marche adaptée", en: "Adaptive walk", es: "Marcha adaptada"
        )
        case .wheelchairPush: LocalizedText(
            fr: "Fauteuil", en: "Wheelchair", es: "Silla de ruedas"
        )
        case .wheelchairRacing: LocalizedText(
            fr: "Fauteuil de course", en: "Wheelchair racing", es: "Silla de carreras"
        )
        case .handcycling: LocalizedText(fr: "Handbike", en: "Handcycling", es: "Handbike")
        case .adaptiveTricycle: LocalizedText(
            fr: "Tricycle adapté", en: "Adaptive tricycle", es: "Triciclo adaptado"
        )
        case .adaptiveSwim: LocalizedText(
            fr: "Natation adaptée", en: "Adaptive swimming", es: "Natación adaptada"
        )
        case .seatedStrength: LocalizedText(
            fr: "Renforcement assis", en: "Seated strength", es: "Fuerza sentado"
        )
        case .seatedMobility: LocalizedText(
            fr: "Mobilité assise", en: "Seated mobility", es: "Movilidad sentado"
        )
        case .wheelchairBasketball: LocalizedText(
            fr: "Basket fauteuil", en: "Wheelchair basketball", es: "Baloncesto en silla"
        )
        case .wheelchairTennis: LocalizedText(
            fr: "Tennis fauteuil", en: "Wheelchair tennis", es: "Tenis en silla"
        )
        case .boccia: LocalizedText(fr: "Boccia", en: "Boccia", es: "Boccia")

        case .motocross: LocalizedText(fr: "Motocross", en: "Motocross", es: "Motocross")
        case .enduro: LocalizedText(fr: "Enduro", en: "Enduro", es: "Enduro")
        case .motoTrial: LocalizedText(fr: "Trial", en: "Trials", es: "Trial")
        case .roadMotorcycling: LocalizedText(fr: "Moto", en: "Motorcycling", es: "Moto")
        case .karting: LocalizedText(fr: "Karting", en: "Karting", es: "Karting")
        case .circuitRacing: LocalizedText(
            fr: "Auto sur circuit", en: "Circuit racing", es: "Auto en circuito"
        )
        case .rally: LocalizedText(fr: "Rallye", en: "Rally", es: "Rally")
        case .quad: LocalizedText(fr: "Quad", en: "Quad biking", es: "Quad")
        case .jetSki: LocalizedText(fr: "Jet-ski", en: "Jet ski", es: "Moto acuática")
        case .snowmobile: LocalizedText(fr: "Motoneige", en: "Snowmobile", es: "Motonieve")

        case .driving: LocalizedText(fr: "Conduite", en: "Driving", es: "Conducción")

        case .climbing: LocalizedText(fr: "Escalade", en: "Climbing", es: "Escalada")
        case .golf: LocalizedText(fr: "Golf", en: "Golf", es: "Golf")
        case .tennis: LocalizedText(fr: "Tennis", en: "Tennis", es: "Tenis")
        case .padel: LocalizedText(fr: "Padel", en: "Padel", es: "Pádel")
        case .badminton: LocalizedText(fr: "Badminton", en: "Badminton", es: "Bádminton")
        case .football: LocalizedText(fr: "Football", en: "Football", es: "Fútbol")
        case .basketball: LocalizedText(fr: "Basket", en: "Basketball", es: "Baloncesto")
        case .boxing: LocalizedText(fr: "Boxe", en: "Boxing", es: "Boxeo")
        case .martialArts: LocalizedText(fr: "Arts martiaux", en: "Martial arts", es: "Artes marciales")
        case .dance: LocalizedText(fr: "Danse", en: "Dance", es: "Baile")
        case .equestrian: LocalizedText(fr: "Équitation", en: "Horse riding", es: "Equitación")
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
        case .walk: "figure.walk"
        case .hike: "mountain.2"
        case .treadmill: "figure.run.treadmill"

        case .ride: "bicycle"
        case .mountainBike: "figure.outdoor.cycle"
        case .gravelRide: "bicycle"
        case .eBike: "bicycle"
        case .indoorRide: "figure.indoor.cycle"
        case .inlineSkate: "figure.skating"
        case .skateboard: "skateboard"

        case .swim: "figure.pool.swim"
        case .openWaterSwim: "figure.open.water.swim"
        case .rowing: "figure.rower"
        case .kayak: "figure.sailing"
        case .canoe: "figure.sailing"
        case .standUpPaddle: "figure.surfing"
        case .surf: "figure.surfing"
        case .windsurf: "figure.sailing"
        case .kitesurf: "figure.surfing"
        case .sailing: "sailboat"

        case .alpineSki: "figure.skiing.downhill"
        case .nordicSki: "figure.skiing.crosscountry"
        case .skiTouring: "figure.skiing.crosscountry"
        case .snowboard: "figure.snowboarding"
        case .snowshoe: "snowflake"
        case .iceSkate: "figure.ice.skating"

        case .weightTraining: "dumbbell.fill"
        case .hiit: "figure.highintensity.intervaltraining"
        case .crossTraining: "figure.cross.training"
        case .rowingMachine: "figure.indoor.rowing"
        case .elliptical: "figure.elliptical"
        case .stairMaster: "figure.stair.stepper"
        case .yoga: "figure.yoga"
        case .pilates: "figure.pilates"
        case .stretching: "figure.flexibility"

        case .adaptiveWalk: "figure.walk.motion"
        case .wheelchairPush: "figure.roll"
        case .wheelchairRacing: "figure.roll.runningpace"
        case .handcycling: "figure.hand.cycling"
        case .adaptiveTricycle: "bicycle"
        case .adaptiveSwim: "figure.pool.swim"
        case .seatedStrength: "figure.strengthtraining.functional"
        case .seatedMobility: "figure.flexibility"
        case .wheelchairBasketball: "figure.basketball"
        case .wheelchairTennis: "figure.tennis"
        // Faute d'un symbole de boccia, celui du bowling : même geste de
        // lancer visé vers une cible. Une icône approchante vaut mieux
        // qu'un rond gris qui ne dit rien.
        case .boccia: "figure.bowling"

        // Le catalogue de symboles d'Apple ne connaît pas le motocross.
        // Plusieurs sports partagent donc la même moto, comme le vélo, le
        // gravel et le vélo électrique partagent déjà la même bicyclette :
        // une icône approchante vaut mieux qu'un rond gris.
        case .motocross, .enduro, .motoTrial, .roadMotorcycling, .quad: "motorcycle.fill"
        case .karting, .rally: "steeringwheel"
        case .circuitRacing: "flag.checkered"
        case .jetSki: "water.waves"
        case .snowmobile: "snowflake"

        case .driving: "car.fill"

        case .climbing: "figure.climbing"
        case .golf: "figure.golf"
        case .tennis: "figure.tennis"
        case .padel: "figure.tennis"
        case .badminton: "figure.badminton"
        case .football: "figure.soccer"
        case .basketball: "figure.basketball"
        case .boxing: "figure.boxing"
        case .martialArts: "figure.martial.arts"
        case .dance: "figure.dance"
        case .equestrian: "figure.equestrian.sports"
        }
    }

    // MARK: - Le rangement

    public var family: SportFamily {
        switch self {
        case .run, .trail, .walk, .hike, .treadmill:
            .foot
        case .ride, .mountainBike, .gravelRide, .eBike, .indoorRide, .inlineSkate, .skateboard:
            .wheels
        case .swim, .openWaterSwim, .rowing, .kayak, .canoe, .standUpPaddle,
             .surf, .windsurf, .kitesurf, .sailing:
            .water
        case .alpineSki, .nordicSki, .skiTouring, .snowboard, .snowshoe, .iceSkate:
            .snow
        case .weightTraining, .hiit, .crossTraining, .rowingMachine, .elliptical,
             .stairMaster, .yoga, .pilates, .stretching:
            .indoor
        case .adaptiveWalk, .wheelchairPush, .wheelchairRacing, .handcycling,
             .adaptiveTricycle, .adaptiveSwim, .seatedStrength, .seatedMobility,
             .wheelchairBasketball, .wheelchairTennis, .boccia:
            .adaptive
        case .motocross, .enduro, .motoTrial, .roadMotorcycling, .karting,
             .circuitRacing, .rally, .quad, .jetSki, .snowmobile:
            .motorsport
        case .driving:
            .travel
        case .climbing, .golf, .tennis, .padel, .badminton, .football,
             .basketball, .boxing, .martialArts, .dance, .equestrian:
            .other
        }
    }

    public var mode: SportMode {
        switch self {
        case .run: .running
        case .trail: .trailRunning
        case .walk: .walking
        case .hike, .snowshoe: .walking
        case .ride, .gravelRide, .eBike, .inlineSkate, .skateboard: .rolling
        case .mountainBike: .rolling
        case .openWaterSwim, .rowing, .kayak, .canoe, .standUpPaddle,
             .surf, .windsurf, .kitesurf, .sailing: .floating
        case .alpineSki, .nordicSki, .skiTouring, .snowboard, .iceSkate: .gliding
        // Le golf se marche : quatre heures et huit kilomètres, que le GPS
        // mesure très bien. L'équitation aussi se trace, à la vitesse d'un
        // vélo lent.
        case .golf: .walking
        case .equestrian: .rolling

        // Un fauteuil poussé à la main avance à l'allure d'un marcheur, et
        // son GPS est aussi fragile que le sien : le filtre de la marche
        // prend tout, ce qu'il faut pour ne pas perdre une trace lente. Un
        // fauteuil de course tient trente à l'heure — c'est un engin qui
        // roule, et le filtrage doit le savoir.
        case .adaptiveWalk: .walking
        case .wheelchairPush: .walking
        case .wheelchairRacing, .handcycling, .adaptiveTricycle: .rolling
        case .driving, .motocross, .enduro, .motoTrial, .roadMotorcycling,
             .karting, .circuitRacing, .rally, .quad, .jetSki, .snowmobile:
            .motorised
        default: .stationary
        }
    }

    /// Le sport laisse-t-il une trace sur une carte ?
    ///
    /// La question commande tout l'écran d'effort : un rameur qui affiche
    /// une carte vide et « 0,0 km » ment sur ce qu'il mesure. Ce qui ne se
    /// déplace pas s'enregistre au chronomètre et au cardio, et c'est
    /// suffisant — c'est exactement ce que fait une montre de sport.
    public var tracksLocation: Bool { mode != .stationary }

    /// L'activité compte-t-elle comme de l'entraînement ?
    ///
    /// La question ne se posait pas tant que le catalogue ne contenait que
    /// des sports. Elle se pose dès qu'il contient un trajet : une heure de
    /// voiture ne doit ni brûler de calories, ni peser sur la charge, ni
    /// compter comme une séance de la semaine.
    ///
    /// C'est une propriété et non un `if` dans chaque calcul : quatre
    /// endroits agrègent les activités, et celui qu'on oublierait serait
    /// exactement celui qui annoncerait « 5 séances cette semaine » dont
    /// deux étaient des allers-retours au travail.
    /// Elle ne se déduit pas du mode de déplacement, et c'est une leçon.
    ///
    /// Elle l'a fait un temps : « motorisé » voulait dire « ne compte pas »,
    /// ce qui était vrai tant que la conduite était seule dans ce mode. Les
    /// sports mécaniques l'ont démentie — ils partagent le même filtrage de
    /// trace, parce qu'un rallye et une autoroute dépassent tous deux le
    /// plafond du vélo, et pourtant l'un est un effort entier et l'autre
    /// non.
    ///
    /// La façon dont un engin se déplace et la question de savoir si le
    /// corps fournit sont deux choses différentes. Les confondre revenait à
    /// dire qu'un pilote de motocross ne fait rien parce qu'il a un moteur.
    public var countsAsTraining: Bool {
        switch self {
        case .driving: false
        default: true
        }
    }

    /// L'activité ouvre-t-elle une session d'entraînement HealthKit ?
    ///
    /// Non pour un trajet, et c'est le point : une session d'entraînement
    /// écrit dans Santé et ferme les anneaux. Deux heures d'autoroute
    /// enregistrées comme entraînement fausseraient la journée d'activité de
    /// l'athlète bien au-delà de cette application.
    ///
    /// La contrepartie est réelle et vaut d'être dite : sans session, la
    /// montre suspend l'application quelques secondes après que le poignet
    /// baisse. Un trajet se trace donc depuis le téléphone.
    public var opensWorkoutSession: Bool { countsAsTraining }

    /// Vrai quand l'activité alimente le plan de course.
    ///
    /// Décisif, et pas un détail de présentation : une sortie vélo de 60 km
    /// versée au kilométrage hebdomadaire ferait tripler le volume prescrit
    /// la semaine suivante, et une moyenne à 30 km/h prise pour une allure de
    /// seuil rendrait toutes les allures du plan intenables.
    ///
    /// Le tapis en est, et c'est voulu : les jambes ne savent pas qu'elles
    /// sont à l'intérieur.
    public var feedsRunningPlan: Bool {
        switch self {
        case .run, .trail, .treadmill: true
        default: false
        }
    }

    /// Ce qu'on affiche pour dire « à quelle vitesse ».
    public var readout: SpeedReadout {
        switch mode {
        case .running, .trailRunning, .walking: .pacePerKilometre
        // Une vitesse, comme pour tout ce qui roule : personne n'a jamais
        // annoncé un trajet en minutes par kilomètre.
        case .rolling, .floating, .gliding, .motorised: .speed
        // Un yoga n'a pas d'allure, et afficher « —:—/km » pendant une heure
        // n'apprend rien à personne.
        case .stationary: .none
        }
    }

    // MARK: - Le filtrage de la trace

    /// Les réglages de filtrage de la trace GPS pour ce sport.
    ///
    /// Ils viennent du mode, pas du sport : un kayak et un paddle dérivent
    /// de la même façon, et quarante-huit jeux de seuils écrits à la main
    /// garantiraient qu'un d'entre eux mente.
    public var filter: TraceFilter {
        switch mode {
        case .running:
            TraceFilter()
        case .trailRunning:
            // Sous les arbres et entre les parois, exiger 25 m de précision
            // reviendrait à jeter la sortie entière.
            TraceFilter(
                maxHorizontalAccuracy: 40,
                pauseSpeed: 0.4,
                elevationWindow: 7,
                elevationThreshold: 1.5
            )
        case .rolling:
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
        case .motorised:
            // Rien à voir avec un filtre de sport, et c'est voulu.
            //
            // 60 m/s, soit 216 km/h : au-delà, c'est un saut de GPS. Le seuil
            // du vélo — 108 km/h — jetterait toute portion d'autoroute, et
            // le trajet arriverait amputé de ses lignes droites.
            //
            // Le déplacement minimal monte à cinq mètres : à 130 km/h un
            // point par seconde couvre trente-six mètres, et affiner en
            // dessous ne fait qu'entasser du bruit. Le dénivelé enfin est
            // volontairement sourd : personne ne veut savoir combien une
            // voiture a « grimpé », et un seuil fin en fabriquerait des
            // centaines de mètres à chaque viaduc.
            TraceFilter(
                maxHorizontalAccuracy: 50,
                maxSpeed: 60,
                pauseSpeed: 1.5,
                minSegmentMeters: 5,
                elevationWindow: 9,
                elevationThreshold: 10
            )
        case .walking:
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
                pauseSpeed: 0.3,
                minSegmentMeters: 0.2,
                elevationWindow: 7,
                elevationThreshold: 1.5
            )
        case .floating:
            // Sur l'eau, l'altitude est du bruit et rien d'autre : la mer est
            // plate. Un seuil de dénivelé très haut ne « lisse » pas la
            // mesure, il refuse d'inventer les six cents mètres de D+ qu'un
            // GPS fabrique en deux heures de paddle.
            TraceFilter(
                maxHorizontalAccuracy: 40,
                maxSpeed: 20,
                pauseSpeed: 0.3,
                minSegmentMeters: 0.5,
                elevationWindow: 9,
                elevationThreshold: 1_000
            )
        case .gliding:
            // Une descente à ski dépasse les 100 km/h en pointe, et le D+ y
            // est réel — c'est même la mesure qui intéresse, en ski de
            // randonnée. Le seuil de pause reste bas : une remontée
            // mécanique est lente, mais elle n'est pas un arrêt.
            TraceFilter(
                maxHorizontalAccuracy: 40,
                maxSpeed: 35,
                pauseSpeed: 0.3,
                minSegmentMeters: 1,
                elevationWindow: 7,
                elevationThreshold: 2
            )
        case .stationary:
            // Aucune trace n'est enregistrée : ce filtre ne sert qu'à
            // n'avoir jamais de valeur absente à donner.
            TraceFilter()
        }
    }

    /// Vitesse en dessous de laquelle une moyenne est suspecte, en m/s.
    /// Sert à prévenir l'athlète, pas à corriger la mesure.
    public var implausiblySlowSpeed: Double {
        switch mode {
        case .running, .trailRunning: 1.0
        case .rolling: 1.5
        case .walking, .floating, .gliding: 0.2
        case .stationary: 0
        // Une moyenne sous 5 km/h sur un trajet en voiture veut dire que le
        // GPS n'a pas suivi, ou qu'on a passé l'heure dans un bouchon. Dans
        // les deux cas ça mérite d'être dit, et pas corrigé en douce.
        case .motorised: 1.4
        }
    }

    // MARK: - Ce que ça coûte

    /// L'équivalent métabolique du sport, d'après le Compendium of Physical
    /// Activities (Ainsworth et coll., 2011).
    ///
    /// Il ne sert qu'aux sports dont la dépense ne se déduit pas de la
    /// distance : à pied elle se compte au kilomètre, à vélo elle dépend du
    /// cube de la vitesse, mais une heure de yoga ou de padel n'a pas de
    /// distance du tout. Les valeurs sont celles de la table, à l'intensité
    /// « modérée » — celle d'un pratiquant qui s'entraîne, pas d'un
    /// compétiteur.
    public var baseMET: Double {
        switch self {
        case .run, .trail, .treadmill: 9.8
        case .walk: 3.5
        case .hike, .snowshoe: 6.0
        case .ride, .gravelRide, .indoorRide: 7.5
        case .mountainBike: 8.5
        case .eBike: 5.0
        case .inlineSkate: 7.5
        case .skateboard: 5.0

        case .swim, .openWaterSwim: 7.0
        case .rowing, .rowingMachine: 7.0
        case .kayak: 5.0
        case .canoe: 4.0
        case .standUpPaddle: 6.0
        case .surf: 3.0
        case .windsurf: 3.0
        case .kitesurf: 6.0
        case .sailing: 3.0

        case .alpineSki: 5.3
        case .nordicSki: 9.0
        case .skiTouring: 7.5
        case .snowboard: 5.3
        case .iceSkate: 7.0

        case .weightTraining: 5.0
        case .hiit: 8.0
        case .crossTraining: 7.5
        case .elliptical: 5.0
        case .stairMaster: 9.0
        case .yoga: 2.5
        case .pilates: 3.0
        case .stretching: 2.3

        // Les valeurs des sports adaptés sont plus incertaines que les
        // autres : le Compendium en documente peu, et la dépense dépend
        // beaucoup du niveau d'atteinte — deux personnes en fauteuil sur le
        // même parcours ne dépensent pas la même chose. Elles sont donc
        // prises basses. Sous-estimer une dépense fait manquer quelques
        // calories à l'assiette ; la surestimer fait croire à un déficit
        // qui n'existe pas, et c'est la faute qui se paie.
        //
        // Basses ne veut pas dire rabaissées. Le basket fauteuil coûte à peu
        // près ce que coûte le basket debout, et le fauteuil de course
        // approche la course à pied : un joueur qui pousse, freine et
        // relance pendant quarante minutes fournit un effort entier. Ce qui
        // baisse ici, c'est ce qui va réellement moins vite — une marche
        // avec canne, une nage dont un côté ne pousse pas.
        case .adaptiveWalk: 2.8
        case .wheelchairPush: 3.5
        case .wheelchairRacing: 8.0
        case .handcycling: 5.5
        case .adaptiveTricycle: 5.0
        case .adaptiveSwim: 6.0
        case .seatedStrength: 3.5
        case .seatedMobility: 2.0
        case .wheelchairBasketball: 6.5
        case .wheelchairTennis: 6.0
        case .boccia: 2.5

        // Zéro, et ce n'est pas une valeur manquante.
        //
        // Le Compendium donne 2,5 pour la conduite — le coût d'être assis,
        // éveillé, les mains occupées. C'est vrai et sans intérêt ici : ce
        // que compte cette application, c'est la dépense d'un effort, celle
        // qui creuse un déficit et qu'il faut remanger. Deux heures de
        // route affichées à 350 kcal feraient manger un repas pour un
        // entraînement qui n'a pas eu lieu.
        // Les sports mécaniques, et l'écart entre l'idée reçue et la mesure.
        //
        // « Il est assis, il ne fait rien » est faux pour la plupart d'entre
        // eux : un pilote de motocross tient l'engin aux bras et aux jambes
        // quarante minutes durant, encaisse les bosses, et sa fréquence
        // cardiaque ne redescend pas. Le karting fatigue les avant-bras et
        // la nuque plus qu'on ne le croit.
        //
        // Cela dit, le Compendium est mince ici — ses entrées datent et
        // couvrent mal la pratique de compétition. Les valeurs sont donc
        // prises basses, comme pour les sports adaptés : sous-estimer une
        // dépense fait manquer quelques calories, la surestimer fait croire
        // à un déficit qui n'existe pas. Pour ces sports plus que pour les
        // autres, c'est la ceinture cardio qui donne la vraie mesure.
        case .motocross, .enduro: 7.0
        case .motoTrial: 6.0
        case .karting, .jetSki: 5.0
        case .circuitRacing, .rally, .quad: 4.5
        case .roadMotorcycling: 4.0
        case .snowmobile: 3.5

        case .driving: 0

        case .climbing: 7.0
        case .golf: 4.3
        case .tennis: 7.0
        case .padel: 6.0
        case .badminton: 5.5
        case .football: 7.0
        case .basketball: 6.5
        case .boxing: 7.0
        case .martialArts: 7.5
        case .dance: 5.0
        case .equestrian: 5.5
        }
    }

    /// Le poids d'intensité par défaut d'une heure de ce sport, sur
    /// l'échelle du ressenti (1–10).
    ///
    /// Il sert quand l'athlète n'a pas noté son effort. Dérivé du MET plutôt
    /// qu'écrit à la main quarante-huit fois : deux tables disant la même
    /// chose finiraient par ne plus la dire pareil. Un MET de 10 — la course
    /// soutenue — vaut 8 sur l'échelle du ressenti ; un MET de 2,5 — les
    /// étirements — vaut 2.
    public var defaultIntensity: Double {
        (baseMET * 0.8).clamped(to: 1...9)
    }

    /// Le matériel qui équipe ce sport, quand il y en a un.
    public var gearKinds: Set<Gear.Kind> {
        switch family {
        case .foot: [.shoes]
        case .wheels: mode == .rolling && self != .inlineSkate && self != .skateboard ? [.bike] : []
        default: []
        }
    }
}

/// Comment se dit la vitesse, selon le sport.
///
/// Une allure au kilomètre pour ce qui se court ou se marche, une vitesse
/// horaire pour ce qui roule ou glisse : personne n'a jamais annoncé un col
/// en minutes par kilomètre. Et rien du tout pour ce qui ne se déplace
/// pas — un rameur affiche un temps, pas une allure.
public enum SpeedReadout: String, Codable, Sendable {
    case pacePerKilometre
    case speed
    case none
}
