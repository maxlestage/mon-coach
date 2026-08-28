import Foundation

/// Un conseil de salle, indépendant du programme.
public struct GymTip: Sendable, Equatable, Identifiable {
    public var id: String
    public var title: LocalizedText
    public var body: LocalizedText
    /// Ce qui rend le conseil vérifiable ou immédiatement applicable.
    public var takeaway: LocalizedText?
}

/// Un thème du guide de salle.
public enum GymTopic: String, Codable, CaseIterable, Sendable, Identifiable {
    /// La toute première séance, quand on ne sait pas où se mettre.
    case firstVisit
    /// Occuper la salle sans gêner, et sans se laisser gêner.
    case etiquette
    /// Choisir son créneau, ou survivre à celui qu'on n'a pas choisi.
    case timing
    /// Ne pas se faire mal, et savoir sortir d'une série ratée.
    case safety
    /// Ce qu'on emporte, et ce qui ne sert à rien.
    case kit

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .firstVisit:
            LocalizedText(fr: "La première fois", en: "The first time", es: "La primera vez")
        case .etiquette:
            LocalizedText(fr: "Vivre avec les autres", en: "Sharing the room", es: "Convivir con los demás")
        case .timing:
            LocalizedText(fr: "Choisir son heure", en: "Choosing your hour", es: "Elegir tu hora")
        case .safety:
            LocalizedText(fr: "Ne pas se faire mal", en: "Not getting hurt", es: "No hacerse daño")
        case .kit:
            LocalizedText(fr: "Ce qu'on emporte", en: "What to bring", es: "Qué llevar")
        }
    }
}

/// Le guide de la salle elle-même.
///
/// Le programme suppose qu'on sait déjà s'y prendre. La moitié des gens qui
/// arrêtent au bout de trois semaines n'arrêtent pas à cause du programme :
/// ils arrêtent parce qu'ils ne savent pas où se mettre, qu'ils ont peur de
/// prendre la place de quelqu'un, ou qu'ils sont venus à dix-huit heures un
/// mardi et n'ont rien pu faire. C'est de ça que parle ce guide.
public enum GymGuide {

    public static func tips(for topic: GymTopic) -> [GymTip] {
        switch topic {
        case .firstVisit: firstVisit
        case .etiquette: etiquette
        case .timing: timing
        case .safety: safety
        case .kit: kit
        }
    }

    public static var all: [GymTip] { GymTopic.allCases.flatMap(tips(for:)) }

    // MARK: - La première fois

    static let firstVisit: [GymTip] = [
        GymTip(
            id: "first-lap",
            title: LocalizedText(
                fr: "Fais un tour complet avant de toucher quoi que ce soit",
                en: "Walk the whole room before you touch anything",
                es: "Da una vuelta completa antes de tocar nada"
            ),
            body: LocalizedText(
                fr: "Cinq minutes à marcher dans la salle, à repérer où sont les haltères, les racks, les poulies et les machines de ta séance. Chercher un appareil pendant qu'on est essoufflé entre deux séries est la meilleure façon de bâcler la suivante.",
                en: "Five minutes walking the room, finding the dumbbells, the racks, the cables and the machines your session needs. Hunting for a machine while out of breath between sets is the surest way to rush the next one.",
                es: "Cinco minutos caminando por la sala, localizando mancuernas, racks, poleas y máquinas de tu sesión. Buscar un aparato mientras te falta el aire entre series es la mejor forma de estropear la siguiente."
            ),
            takeaway: LocalizedText(
                fr: "Tu dois pouvoir dire où se trouve chaque exercice de ta séance avant de commencer.",
                en: "You should be able to say where every exercise in your session lives before you start.",
                es: "Debes poder decir dónde está cada ejercicio de tu sesión antes de empezar."
            )
        ),
        GymTip(
            id: "first-nobody-watches",
            title: LocalizedText(
                fr: "Personne ne te regarde",
                en: "Nobody is watching you",
                es: "Nadie te está mirando"
            ),
            body: LocalizedText(
                fr: "C'est la peur qui fait arrêter le plus de gens, et c'est la plus infondée : tout le monde compte ses répétitions, regarde son téléphone, ou se regarde soi-même. Un débutant appliqué qui charge léger passe complètement inaperçu — bien plus qu'un habitué qui fait du bruit.",
                en: "This is the fear that stops the most people, and it is the least founded: everyone is counting their reps, looking at their phone, or looking at themselves. A careful beginner lifting light goes completely unnoticed — far more than a regular making noise.",
                es: "Es el miedo que más gente abandona, y el menos fundado: todos están contando repeticiones, mirando el móvil o mirándose a sí mismos. Un principiante aplicado que carga ligero pasa totalmente desapercibido, mucho más que un habitual que hace ruido."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "first-ask",
            title: LocalizedText(
                fr: "Demander est normal, et ça se dit en cinq mots",
                en: "Asking is normal, and takes five words",
                es: "Preguntar es normal, y son cinco palabras"
            ),
            body: LocalizedText(
                fr: "« Tu en as pour longtemps ? » suffit à savoir si un poste va se libérer. « Je peux faire une série entre les tiennes ? » est une demande courante et presque toujours acceptée. Le personnel, lui, est payé pour montrer comment marche une machine : ce n'est pas un service qu'on demande, c'est son travail.",
                en: "\"Are you going to be long?\" is enough to know whether a station will free up. \"Can I work in between your sets?\" is a common request and almost always accepted. Staff, meanwhile, are paid to show you how a machine works: asking is not a favour, it is their job.",
                es: "«¿Te queda mucho?» basta para saber si un puesto se va a liberar. «¿Puedo meter una serie entre las tuyas?» es una petición habitual y casi siempre aceptada. El personal, además, cobra por enseñarte cómo funciona una máquina: no es un favor, es su trabajo."
            ),
            takeaway: nil
        ),
    ]

    // MARK: - Vivre avec les autres

    static let etiquette: [GymTip] = [
        GymTip(
            id: "etiquette-share",
            title: LocalizedText(
                fr: "Partager un poste double sa disponibilité",
                en: "Sharing a station doubles its availability",
                es: "Compartir un puesto duplica su disponibilidad"
            ),
            body: LocalizedText(
                fr: "Deux personnes qui alternent sur le même appareil tiennent exactement dans le temps de repos l'une de l'autre. C'est la solution la plus simple aux heures de pointe, et c'est celle à laquelle on pense le moins.",
                en: "Two people alternating on the same machine fit exactly inside each other's rest. It is the simplest answer to peak hours, and the one nobody thinks of.",
                es: "Dos personas alternando en la misma máquina caben justo en el descanso de la otra. Es la solución más simple a las horas punta y la que menos se piensa."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "etiquette-put-back",
            title: LocalizedText(
                fr: "Ranger, et essuyer",
                en: "Rack it, and wipe it",
                es: "Recoger y limpiar"
            ),
            body: LocalizedText(
                fr: "Remettre les disques et les haltères prend dix secondes et t'évite d'être la personne dont tout le monde parle. Essuyer un banc n'est pas une politesse : c'est ce qui empêche une salle de devenir une pétri de staphylocoques.",
                en: "Putting the plates and dumbbells back takes ten seconds and keeps you from being the person everyone talks about. Wiping a bench is not politeness: it is what keeps a gym from becoming a petri dish.",
                es: "Devolver discos y mancuernas cuesta diez segundos y evita que seas la persona de la que todos hablan. Limpiar un banco no es cortesía: es lo que impide que un gimnasio se convierta en una placa de cultivo."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "etiquette-phone",
            title: LocalizedText(
                fr: "Le téléphone, entre les séries, pas pendant",
                en: "The phone between sets, not during",
                es: "El móvil entre series, no durante"
            ),
            body: LocalizedText(
                fr: "Un repos de deux minutes devient huit minutes dès qu'on ouvre une application. Ce n'est pas une question de morale : une séance qui traîne perd sa densité, et une salle bondée n'a pas la place pour un poste occupé par quelqu'un qui lit.",
                en: "A two-minute rest becomes eight the moment you open an app. This is not about morals: a session that drags loses its density, and a busy gym has no room for a station occupied by someone reading.",
                es: "Un descanso de dos minutos se convierte en ocho en cuanto abres una aplicación. No es una cuestión moral: una sesión que se alarga pierde densidad, y un gimnasio lleno no tiene sitio para un puesto ocupado por alguien que lee."
            ),
            takeaway: LocalizedText(
                fr: "Le chrono de repos de l'application vibre : range le téléphone entre deux séries et laisse-le te rappeler.",
                en: "The app's rest timer buzzes: put the phone away between sets and let it call you back.",
                es: "El cronómetro de descanso de la aplicación vibra: guarda el móvil entre series y deja que te avise."
            )
        ),
    ]

    // MARK: - Choisir son heure

    static let timing: [GymTip] = [
        GymTip(
            id: "timing-peak",
            title: LocalizedText(
                fr: "Les deux heures à éviter",
                en: "The two hours to avoid",
                es: "Las dos horas que hay que evitar"
            ),
            body: LocalizedText(
                fr: "Entre 17 h et 20 h en semaine, une salle reçoit l'essentiel de sa fréquentation de la journée. Décaler d'une heure — 16 h ou 20 h 30 — change complètement l'expérience, et le samedi matin est presque toujours plus calme qu'on ne le croit.",
                en: "Between 5 and 8 p.m. on weekdays, a gym takes most of its daily traffic. Shifting by an hour — 4 p.m. or 8:30 p.m. — changes the experience completely, and Saturday morning is almost always quieter than people expect.",
                es: "Entre las 17 y las 20 h entre semana, un gimnasio recibe la mayor parte de su afluencia diaria. Desplazarse una hora —a las 16 o a las 20:30— cambia por completo la experiencia, y el sábado por la mañana casi siempre está más tranquilo de lo que se cree."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "timing-morning",
            title: LocalizedText(
                fr: "L'heure idéale est celle que tu tiendras",
                en: "The best hour is the one you will keep",
                es: "La mejor hora es la que vas a mantener"
            ),
            body: LocalizedText(
                fr: "On s'entraîne à peine plus fort le soir que le matin, et l'écart est sans commune mesure avec celui entre venir et ne pas venir. Choisis le créneau qui résiste à une journée de travail difficile, pas celui qui te promet deux pour cent de performance en plus.",
                en: "You train barely harder in the evening than in the morning, and the gap is nothing next to the one between showing up and not showing up. Pick the slot that survives a hard day at work, not the one that promises two per cent more performance.",
                es: "Se entrena apenas más fuerte por la tarde que por la mañana, y esa diferencia no tiene comparación con la de venir o no venir. Elige el hueco que sobreviva a un día duro de trabajo, no el que promete un dos por ciento más de rendimiento."
            ),
            takeaway: nil
        ),
    ]

    // MARK: - Ne pas se faire mal

    static let safety: [GymTip] = [
        GymTip(
            id: "safety-bail",
            title: LocalizedText(
                fr: "Savoir rater une répétition avant d'en tenter une",
                en: "Know how to fail a rep before you try one",
                es: "Saber fallar una repetición antes de intentarla"
            ),
            body: LocalizedText(
                fr: "Au squat, les barres de sécurité du rack se règlent juste sous ton point bas : rater devient poser la barre. Au développé couché sans pareur, prends des haltères. Sur toute machine, une répétition ratée est sans danger — c'est la raison pour laquelle les machines existent.",
                en: "On the squat, the rack's safety pins sit just below your bottom position: failing becomes setting the bar down. Bench pressing without a spotter, use dumbbells. On any machine, a failed rep is harmless — that is what machines are for.",
                es: "En sentadilla, los seguros del rack se colocan justo bajo tu punto más bajo: fallar se convierte en dejar la barra. En press de banca sin ayudante, usa mancuernas. En cualquier máquina, una repetición fallida es inofensiva: para eso están las máquinas."
            ),
            takeaway: LocalizedText(
                fr: "Règle les barres de sécurité avant ta première série, pas avant la série lourde.",
                en: "Set the safety pins before your first set, not before the heavy one.",
                es: "Coloca los seguros antes de tu primera serie, no antes de la pesada."
            )
        ),
        GymTip(
            id: "safety-warmup",
            title: LocalizedText(
                fr: "L'échauffement se fait sur le mouvement, pas sur un vélo",
                en: "Warm up on the movement, not on a bike",
                es: "El calentamiento se hace en el movimiento, no en una bici"
            ),
            body: LocalizedText(
                fr: "Dix minutes de vélo réchauffent le corps sans préparer l'épaule à un développé. Deux ou trois séries montantes sur le premier exercice — à vide, puis à la moitié, puis aux trois quarts — font le vrai travail, et prennent moins de temps.",
                en: "Ten minutes on a bike warms the body without preparing the shoulder for a press. Two or three ramp-up sets on the first exercise — empty, then half, then three quarters — do the real work, and take less time.",
                es: "Diez minutos de bicicleta calientan el cuerpo sin preparar el hombro para un press. Dos o tres series ascendentes en el primer ejercicio —en vacío, luego a la mitad, luego a tres cuartos— hacen el trabajo real, y llevan menos tiempo."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "safety-ego",
            title: LocalizedText(
                fr: "La charge des autres ne veut rien dire pour toi",
                en: "What others lift means nothing for you",
                es: "Lo que levantan los demás no significa nada para ti"
            ),
            body: LocalizedText(
                fr: "Tu ne connais ni leur ancienneté, ni leur poids de corps, ni leur amplitude, ni ce qu'ils prennent. La seule comparaison qui existe est avec ta propre série de la semaine dernière, et l'application la garde pour toi précisément pour ça.",
                en: "You know neither their years of training, nor their body weight, nor their range of motion, nor what they take. The only comparison that exists is with your own set from last week, and the app keeps it for exactly that reason.",
                es: "No conoces ni sus años de entrenamiento, ni su peso corporal, ni su recorrido, ni lo que toman. La única comparación que existe es con tu propia serie de la semana pasada, y la aplicación la guarda precisamente por eso."
            ),
            takeaway: nil
        ),
    ]

    // MARK: - Ce qu'on emporte

    static let kit: [GymTip] = [
        GymTip(
            id: "kit-essentials",
            title: LocalizedText(
                fr: "Quatre choses suffisent",
                en: "Four things are enough",
                es: "Bastan cuatro cosas"
            ),
            body: LocalizedText(
                fr: "Une serviette, une bouteille d'eau, des chaussures à semelle plate pour les jambes, et le téléphone pour enregistrer les séries. Tout le reste — ceinture, sangles, gants — se justifie plus tard, et seulement si un problème précis apparaît.",
                en: "A towel, a water bottle, flat-soled shoes for leg work, and the phone to log the sets. Everything else — belt, straps, gloves — earns its place later, and only if a specific problem shows up.",
                es: "Una toalla, una botella de agua, zapatillas de suela plana para las piernas y el móvil para registrar las series. Todo lo demás —cinturón, correas, guantes— se justifica más tarde, y solo si aparece un problema concreto."
            ),
            takeaway: nil
        ),
        GymTip(
            id: "kit-shoes",
            title: LocalizedText(
                fr: "Les chaussures de running sont le mauvais choix pour les jambes",
                en: "Running shoes are the wrong choice for leg day",
                es: "Las zapatillas de running son mala elección para las piernas"
            ),
            body: LocalizedText(
                fr: "Une semelle amortissante est faite pour absorber un impact ; sous un squat, elle se compresse de façon irrégulière et te fait perdre l'équilibre. N'importe quelle chaussure à semelle plate et dure fait mieux l'affaire, y compris des chaussures de ville.",
                en: "A cushioned sole is made to absorb impact; under a squat it compresses unevenly and takes your balance with it. Any flat, firm sole does better, including a pair of everyday shoes.",
                es: "Una suela amortiguada está hecha para absorber impactos; bajo una sentadilla se comprime de forma irregular y te quita el equilibrio. Cualquier suela plana y firme funciona mejor, incluidos unos zapatos de calle."
            ),
            takeaway: nil
        ),
    ]
}
