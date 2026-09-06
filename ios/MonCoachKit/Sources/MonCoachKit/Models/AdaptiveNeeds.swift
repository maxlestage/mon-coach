import Foundation

/// Ce qu'un mouvement exige du corps.
///
/// Le catalogue disait déjà quelles articulations un exercice charge — c'est
/// ce qui permet d'écarter un squat quand le genou fait mal. Il ne disait
/// rien de ce qu'il faut *pouvoir faire* pour l'exécuter : tenir debout,
/// fournir des deux jambes, tenir une barre à deux mains. Tant que cette
/// information manquait, un coach ne pouvait pas distinguer « ce mouvement
/// va faire mal » de « ce mouvement est impossible », et prescrivait des
/// squats barre à quelqu'un qui ne se lève pas.
///
/// Huit exigences suffisent. Elles ne décrivent pas un handicap — elles
/// décrivent le mouvement, et c'est le rapprochement des deux qui décide.
///
/// « Un bras » et « les deux bras » sont deux exigences distinctes, et c'est
/// la distinction qui porte tout le reste : sans elle, une presse à une
/// jambe n'exigeait rien et se retrouvait proposée à quelqu'un dont aucune
/// jambe ne répond.
public enum BodyDemand: String, Codable, CaseIterable, Sendable, Hashable, Identifiable {
    /// Il faut tenir debout, sous charge, pendant la série.
    case standing
    /// Une jambe fournit — celle qu'on veut.
    case oneLeg
    /// Les deux jambes fournissent, ensemble.
    case bothLegs
    /// Un bras fournit — celui qu'on veut.
    case oneArm
    /// Les deux bras fournissent, ensemble.
    case bothArms
    /// Une barre tenue des deux mains : la prise ne se divise pas.
    case gripBothHands
    /// Il faut descendre au sol et s'en relever.
    case floorTransfer
    /// L'équilibre dynamique fait partie du mouvement, pas du décor.
    case balance

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .standing: LocalizedText(
            fr: "Tenir debout", en: "Standing", es: "Estar de pie"
        )
        case .oneLeg: LocalizedText(
            fr: "Une jambe", en: "One leg", es: "Una pierna"
        )
        case .bothLegs: LocalizedText(
            fr: "Les deux jambes", en: "Both legs", es: "Ambas piernas"
        )
        case .oneArm: LocalizedText(
            fr: "Un bras", en: "One arm", es: "Un brazo"
        )
        case .bothArms: LocalizedText(
            fr: "Les deux bras", en: "Both arms", es: "Ambos brazos"
        )
        case .gripBothHands: LocalizedText(
            fr: "Une barre à deux mains", en: "A bar in both hands", es: "Una barra con ambas manos"
        )
        case .floorTransfer: LocalizedText(
            fr: "Aller au sol et se relever", en: "Getting to the floor and up", es: "Bajar al suelo y levantarse"
        )
        case .balance: LocalizedText(
            fr: "L'équilibre en mouvement", en: "Balance under load", es: "Equilibrio en movimiento"
        )
        }
    }
}

/// Le côté du corps atteint, quand la situation en a un.
public enum BodySide: String, Codable, CaseIterable, Sendable, Hashable, Identifiable {
    case left
    case right

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .left: LocalizedText(fr: "Côté gauche", en: "Left side", es: "Lado izquierdo")
        case .right: LocalizedText(fr: "Côté droit", en: "Right side", es: "Lado derecho")
        }
    }

    public var opposite: BodySide { self == .left ? .right : .left }
}

/// Une situation de handicap, du point de vue de ce que l'application doit
/// faire différemment.
///
/// La liste est courte et volontairement grossière. Elle ne prétend pas
/// classer les gens : deux hémiplégies ne se ressemblent pas, et aucune
/// case ne dira jamais ce qu'un corps fait vraiment. Ce qu'elle sert à
/// faire est plus modeste et plus utile — savoir quels mouvements ne pas
/// proposer, et quels sports mettre devant.
///
/// C'est aussi la raison pour laquelle rien ici n'est un diagnostic. On ne
/// demande pas un niveau de lésion ni un pourcentage d'incapacité : on
/// demande ce que ça change pour s'entraîner, et rien d'autre.
public enum AdaptiveSituation: String, Codable, CaseIterable, Sendable, Hashable, Identifiable {
    /// Un côté du corps ne répond plus ou mal — AVC, paralysie cérébrale,
    /// lésion cérébrale.
    case hemiplegia
    /// Les membres inférieurs ne répondent plus.
    case paraplegia
    /// Les quatre membres sont touchés, à des degrés variables.
    case tetraplegia
    /// Amputation ou agénésie d'un membre supérieur.
    case upperLimbLoss
    /// Amputation ou agénésie d'un membre inférieur.
    case lowerLimbLoss
    /// Debout difficile ou douloureux, endurance réduite — sclérose en
    /// plaques, myopathie, arthrose sévère, insuffisance cardiaque.
    case limitedMobility
    /// Déficience visuelle.
    case visualImpairment
    /// Déficience auditive.
    case hearingImpairment
    /// Handicap mental ou psychique.
    case intellectual

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .hemiplegia: LocalizedText(
            fr: "Hémiplégie", en: "Hemiplegia", es: "Hemiplejía"
        )
        case .paraplegia: LocalizedText(
            fr: "Paraplégie", en: "Paraplegia", es: "Paraplejía"
        )
        case .tetraplegia: LocalizedText(
            fr: "Tétraplégie", en: "Tetraplegia", es: "Tetraplejía"
        )
        case .upperLimbLoss: LocalizedText(
            fr: "Membre supérieur amputé ou absent",
            en: "Upper limb amputated or absent",
            es: "Miembro superior amputado o ausente"
        )
        case .lowerLimbLoss: LocalizedText(
            fr: "Membre inférieur amputé ou absent",
            en: "Lower limb amputated or absent",
            es: "Miembro inferior amputado o ausente"
        )
        case .limitedMobility: LocalizedText(
            fr: "Mobilité réduite", en: "Reduced mobility", es: "Movilidad reducida"
        )
        case .visualImpairment: LocalizedText(
            fr: "Déficience visuelle", en: "Visual impairment", es: "Discapacidad visual"
        )
        case .hearingImpairment: LocalizedText(
            fr: "Déficience auditive", en: "Hearing impairment", es: "Discapacidad auditiva"
        )
        case .intellectual: LocalizedText(
            fr: "Handicap mental ou psychique",
            en: "Intellectual or psychosocial disability",
            es: "Discapacidad intelectual o psíquica"
        )
        }
    }

    /// Ce que la situation change concrètement dans l'application.
    ///
    /// Écrit à la première personne du résultat, pas de la déficience :
    /// l'écran doit répondre à « qu'est-ce que ça me donne », pas répéter
    /// à quelqu'un ce qu'il sait déjà de son corps.
    public var effect: LocalizedText {
        switch self {
        case .hemiplegia: LocalizedText(
            fr: "Le coach ne propose plus que des mouvements qu'un seul côté peut mener : haltère, poulie, machine à un bras, presse à une jambe. La barre disparaît, la mobilité du côté atteint apparaît.",
            en: "The coach keeps only movements one side can carry: dumbbell, cable, single-arm machine, single-leg press. The barbell goes, mobility work for the affected side arrives.",
            es: "El entrenador solo propone movimientos que un lado puede llevar: mancuerna, polea, máquina a un brazo, prensa a una pierna. La barra desaparece, aparece la movilidad del lado afectado."
        )
        case .paraplegia: LocalizedText(
            fr: "Tout le travail se fait assis. Le haut du corps garde son programme entier, les jambes sortent du calcul de volume, et les sports proposés roulent au lieu de courir.",
            en: "Everything is done seated. The upper body keeps its full programme, the legs leave the volume budget, and the sports offered roll instead of run.",
            es: "Todo el trabajo se hace sentado. El tren superior conserva su programa entero, las piernas salen del cálculo de volumen y los deportes propuestos ruedan en lugar de correr."
        )
        case .tetraplegia: LocalizedText(
            fr: "Rien qui exige une prise ferme à deux mains ni un transfert au sol. Ce qui reste est réel — poulie légère, élastique, mobilité — et l'application ne prétend pas que ce soit tout.",
            en: "Nothing that needs a firm two-handed grip or a transfer to the floor. What remains is real — light cable, band, mobility — and the app does not pretend it is everything.",
            es: "Nada que exija un agarre firme a dos manos ni un traslado al suelo. Lo que queda es real — polea ligera, banda, movilidad — y la aplicación no finge que sea todo."
        )
        case .upperLimbLoss: LocalizedText(
            fr: "La barre et les mouvements à deux bras sortent. Tout le reste — jambes, gainage, cardio — garde son programme complet.",
            en: "The barbell and two-armed movements go. Everything else — legs, core, cardio — keeps its full programme.",
            es: "La barra y los movimientos a dos brazos salen. Todo lo demás — piernas, core, cardio — conserva su programa completo."
        )
        case .lowerLimbLoss: LocalizedText(
            fr: "Les mouvements qui demandent les deux jambes en appui sortent ; le travail à une jambe et le haut du corps restent entiers.",
            en: "Movements needing both legs under load go; single-leg work and the upper body stay whole.",
            es: "Los movimientos que exigen ambas piernas en apoyo salen; el trabajo a una pierna y el tren superior quedan enteros."
        )
        case .limitedMobility: LocalizedText(
            fr: "Rien qui demande de tenir debout longtemps ni de descendre au sol. Assis, appuyé, guidé : le programme continue, il change de position.",
            en: "Nothing that needs long standing or getting down to the floor. Seated, supported, guided: the programme continues, it changes position.",
            es: "Nada que exija estar de pie mucho tiempo ni bajar al suelo. Sentado, apoyado, guiado: el programa continúa, cambia de posición."
        )
        case .visualImpairment: LocalizedText(
            fr: "Aucun exercice n'est retiré — la déficience visuelle n'empêche pas un mouvement, elle change la façon dont il est annoncé. Les sports guidés et l'entraînement en salle passent devant, la planification de parcours passe derrière.",
            en: "No exercise is removed — a visual impairment does not stop a movement, it changes how it is announced. Guided sports and gym work come first, route planning goes last.",
            es: "No se retira ningún ejercicio: la discapacidad visual no impide un movimiento, cambia cómo se anuncia. Los deportes guiados y la sala pasan delante, la planificación de rutas detrás."
        )
        case .hearingImpairment: LocalizedText(
            fr: "Aucun exercice n'est retiré. L'application ne compte de toute façon sur aucun son pour dérouler une séance : tout ce qu'elle dit est écrit et vibré.",
            en: "No exercise is removed. The app relies on no sound to run a session anyway: everything it says is written and buzzed.",
            es: "No se retira ningún ejercicio. La aplicación no depende de ningún sonido para desarrollar una sesión: todo lo que dice está escrito y vibrado."
        )
        case .intellectual: LocalizedText(
            fr: "Aucun exercice n'est retiré. Le mode guidé pas à pas passe devant : une consigne à la fois, l'exercice expliqué avant d'être compté.",
            en: "No exercise is removed. Step-by-step guided mode comes first: one cue at a time, the movement explained before it is counted.",
            es: "No se retira ningún ejercicio. El modo guiado paso a paso pasa delante: una consigna a la vez, el ejercicio explicado antes de contarse."
        )
        }
    }

    /// La question du côté ne se pose que pour les situations qui en ont un.
    public var hasSide: Bool {
        switch self {
        case .hemiplegia, .upperLimbLoss, .lowerLimbLoss: true
        default: false
        }
    }

    /// Ce que le corps ne peut plus fournir, et donc les mouvements à écarter.
    ///
    /// Trois situations n'écartent rien, et c'est la partie qu'il ne faut
    /// pas rater : une déficience visuelle, auditive ou mentale n'empêche
    /// aucun mouvement. Retirer des exercices « par prudence » aurait été
    /// une façon polie de décider à la place de quelqu'un.
    public var unavailableDemands: Set<BodyDemand> {
        switch self {
        case .hemiplegia:
            // Le côté valide fournit ; l'autre non. Tout ce qui exige une
            // symétrie ou une barre sort, tout ce qui se fait d'un côté
            // reste. Debout reste : la plupart des hémiplégiques marchent,
            // et c'est précisément ce que la marche adaptée entretient.
            [.bothLegs, .bothArms, .gripBothHands, .balance]
        case .paraplegia:
            [.standing, .oneLeg, .balance, .floorTransfer]
        case .tetraplegia:
            // Les quatre membres, mais à des degrés variables : les bras
            // travaillent, la prise ferme est ce qui manque le plus souvent.
            // Retirer aussi les bras aurait vidé l'application au nom de la
            // prudence, ce qui n'aide personne.
            [.standing, .oneLeg, .gripBothHands, .balance, .floorTransfer]
        case .upperLimbLoss:
            [.bothArms, .gripBothHands]
        case .lowerLimbLoss:
            // Une prothèse tient debout ; elle ne fournit pas.
            [.bothLegs, .balance]
        case .limitedMobility:
            [.standing, .floorTransfer, .balance]
        case .visualImpairment, .hearingImpairment, .intellectual:
            []
        }
    }

    /// Les sports à mettre devant, dans l'ordre.
    public var suggestedSports: [Sport] {
        switch self {
        case .hemiplegia:
            [.adaptiveWalk, .adaptiveSwim, .adaptiveTricycle, .seatedStrength, .seatedMobility]
        case .paraplegia:
            [.wheelchairPush, .handcycling, .wheelchairRacing, .adaptiveSwim, .wheelchairBasketball, .wheelchairTennis, .seatedStrength]
        case .tetraplegia:
            [.wheelchairPush, .boccia, .seatedMobility, .adaptiveSwim, .seatedStrength]
        case .upperLimbLoss:
            [.adaptiveWalk, .adaptiveSwim, .ride, .run, .seatedStrength]
        case .lowerLimbLoss:
            [.handcycling, .adaptiveSwim, .wheelchairRacing, .seatedStrength, .adaptiveTricycle]
        case .limitedMobility:
            [.adaptiveWalk, .adaptiveSwim, .adaptiveTricycle, .seatedMobility, .seatedStrength]
        case .visualImpairment:
            [.adaptiveWalk, .swim, .rowingMachine, .seatedStrength, .weightTraining]
        case .hearingImpairment:
            [.run, .ride, .swim, .weightTraining]
        case .intellectual:
            [.adaptiveWalk, .swim, .boccia, .seatedMobility, .weightTraining]
        }
    }
}

/// Ce que l'athlète a déclaré de sa situation, et ce que l'application en
/// déduit.
///
/// Rangé dans le profil et nulle part ailleurs : c'est une donnée de santé,
/// elle ne quitte pas l'appareil, elle n'est envoyée à aucun serveur et
/// n'entre dans aucune statistique. Comme le reste du profil.
public struct AdaptiveNeeds: Codable, Sendable, Equatable, Hashable {
    public var situations: Set<AdaptiveSituation>
    /// Le côté atteint, pour les situations qui en ont un.
    public var affectedSide: BodySide?
    /// Déclaré à part des situations : on peut se déplacer en fauteuil sans
    /// être paraplégique — insuffisance cardiaque, myopathie, amputation
    /// bilatérale — et être paraplégique en marchant appareillé.
    public var usesWheelchair: Bool

    public init(
        situations: Set<AdaptiveSituation> = [],
        affectedSide: BodySide? = nil,
        usesWheelchair: Bool = false
    ) {
        self.situations = situations
        self.affectedSide = affectedSide
        self.usesWheelchair = usesWheelchair
    }

    /// Rien de déclaré, rien à adapter. Un profil dans cet état se comporte
    /// exactement comme un profil sans la section : c'est ce qui permet de
    /// la laisser toujours visible sans rien changer à personne.
    public var isActive: Bool { !situations.isEmpty || usesWheelchair }

    /// Le côté qui travaille, quand un seul le peut.
    public var workingSide: BodySide? {
        guard situations.contains(where: \.hasSide), let affectedSide else { return nil }
        return affectedSide.opposite
    }

    /// L'union de ce que chaque situation retire. Cumulatif, jamais négocié :
    /// deux situations déclarées retirent la somme de leurs impossibilités,
    /// pas leur intersection.
    public var unavailableDemands: Set<BodyDemand> {
        var demands = situations.reduce(into: Set<BodyDemand>()) { $0.formUnion($1.unavailableDemands) }
        if usesWheelchair {
            // Le fauteuil ne dit rien des jambes — on peut y être assis avec
            // des jambes qui fonctionnent. Il dit où se passe la séance.
            demands.formUnion([.standing, .balance, .floorTransfer])
        }
        return AdaptiveNeeds.closed(demands)
    }

    /// Les implications qu'aucune situation n'a besoin de réécrire.
    ///
    /// Aucune jambe ne fournit implique qu'elles ne fournissent pas à deux ;
    /// aucun bras implique aucune paire, et aucune barre. Sans cette
    /// fermeture, chaque situation devrait répéter la liste complète, et la
    /// première qui l'oublierait laisserait passer un squat.
    static func closed(_ demands: Set<BodyDemand>) -> Set<BodyDemand> {
        var closed = demands
        if closed.contains(.oneLeg) { closed.insert(.bothLegs) }
        if closed.contains(.oneArm) { closed.formUnion([.bothArms, .gripBothHands]) }
        if closed.contains(.bothArms) { closed.insert(.gripBothHands) }
        return closed
    }

    /// Les sports à mettre devant, sans doublon, dans l'ordre où les
    /// situations déclarées les ont proposés.
    public var suggestedSports: [Sport] {
        var seen: Set<Sport> = []
        var ordered: [Sport] = []
        // L'ordre des situations doit être stable : un `Set` n'en a pas, et
        // une liste de sports qui change d'ordre à chaque ouverture donne
        // l'impression que l'écran n'a pas d'avis.
        for situation in AdaptiveSituation.allCases where situations.contains(situation) {
            for sport in situation.suggestedSports where !seen.contains(sport) {
                seen.insert(sport)
                ordered.append(sport)
            }
        }
        if usesWheelchair {
            for sport in [Sport.wheelchairPush, .handcycling, .adaptiveSwim, .seatedStrength] where !seen.contains(sport) {
                seen.insert(sport)
                ordered.append(sport)
            }
        }
        return ordered
    }

    /// Vrai quand la déclaration ne retire aucun mouvement — déficience
    /// visuelle, auditive ou mentale seules. L'écran doit le dire au lieu
    /// de laisser croire à un filtrage silencieux.
    public var filtersNothing: Bool { isActive && unavailableDemands.isEmpty }
}
