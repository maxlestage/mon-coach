import Foundation

/// Les exercices qu'on ne peut faire qu'en salle, et la sélection du jour.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le coach de salle répondait aux obstacles — l'appareil est pris, ça tire
/// quelque part — et ne proposait rien de lui-même. Or on ouvre cet écran en
/// étant déjà dans la salle, entouré de machines qu'on n'a pas chez soi et
/// qu'on n'utilise jamais parce qu'on ne sait pas par où commencer.
///
/// La sélection change chaque jour, qu'on ait fait la précédente ou non.
/// C'est délibéré : une liste qui attend d'être cochée devient une dette,
/// et une dette qu'on ne rembourse pas, on cesse de la regarder. Ici, ce qui
/// n'a pas été fait hier n'est pas en retard — c'est simplement passé.
///
/// Rien n'est stocké. La sélection se déduit de la date, ce qui garantit
/// trois choses à la fois : elle est la même toute la journée, elle change à
/// minuit, et deux téléphones du même athlète montrent la même chose sans
/// jamais se parler.
public enum GymSpecific {

    /// Le matériel qu'on ne trouve que dans une salle.
    ///
    /// Les haltères et la barre en sont exclus à dessein : beaucoup de gens
    /// en ont chez eux, et un « exercice de salle » qui se fait dans un
    /// salon ne mérite pas ce nom.
    public static let gymEquipment: Set<Equipment> = [.machine, .cable, .smithMachine, .dipStation]

    /// Tous les mouvements du catalogue qui réclament au moins un de ces
    /// équipements, triés par identifiant pour que l'ordre ne dépende pas de
    /// celui du catalogue.
    public static let all: [Exercise] = ExerciseCatalog.all
        .filter { !$0.equipment.isDisjoint(with: gymEquipment) }
        .sorted { $0.id < $1.id }

    /// Combien on en propose par jour. Quatre : de quoi glisser un
    /// mouvement nouveau dans une séance sans la remplacer.
    public static let dailyCount = 4

    /// La sélection du jour.
    ///
    /// Les blessures déclarées et les exercices écartés sont retirés — un
    /// mouvement qui fait mal n'a pas plus sa place ici qu'ailleurs. Le
    /// matériel du profil n'est filtré que si l'athlète a déclaré au moins
    /// un équipement de salle : sinon, c'est qu'il s'est décrit un garage,
    /// et cet écran est justement celui qu'il ouvre en visitant une salle.
    public static func ofTheDay(
        on date: Date = Date(),
        profile: UserProfile?,
        count: Int = dailyCount,
        calendar: Calendar = .current
    ) -> [Exercise] {
        let pool = candidates(for: profile)
        guard !pool.isEmpty, count > 0 else { return [] }
        return DailyRotation.selection(
            from: pool,
            dayIndex: DailyRotation.dayIndex(of: date, calendar: calendar),
            count: count,
            seed: seed
        )
    }

    /// Ce dans quoi la sélection a le droit de puiser.
    static func candidates(for profile: UserProfile?) -> [Exercise] {
        guard let profile else { return all }
        let ownsGymKit = !profile.equipment.isDisjoint(with: gymEquipment)
        return all.filter { exercise in
            !exercise.conflicts(with: profile.limitations)
                && !profile.dislikedExerciseIDs.contains(exercise.id)
                && (!ownsGymKit || exercise.isAvailable(with: profile.equipment))
        }
    }

    /// La graine du mélange. Propre à cette liste : deux viviers différents
    /// n'ont aucune raison de tourner dans le même ordre.
    static let seed: UInt64 = 0x5361_6C6C_6521

    /// Ce que cet exercice apporte qu'on n'a pas chez soi.
    ///
    /// Une phrase par équipement, pas par exercice : la raison est la même
    /// pour toutes les poulies, et l'écrire soixante fois garantirait qu'une
    /// d'entre elles finisse par mentir.
    public static func reason(for exercise: Exercise) -> LocalizedText {
        if exercise.equipment.contains(.cable) {
            return LocalizedText(
                fr: "À la poulie, la tension ne tombe jamais : contrairement aux haltères, l'exercice reste dur en haut du mouvement.",
                en: "On a cable, the tension never drops: unlike dumbbells, the movement stays hard at the top.",
                es: "En polea, la tensión nunca cae: a diferencia de las mancuernas, el movimiento sigue siendo duro arriba."
            )
        }
        if exercise.equipment.contains(.smithMachine) {
            return LocalizedText(
                fr: "La barre est guidée : plus d'équilibre à gérer, donc tu peux aller près de l'échec sans personne pour parer.",
                en: "The bar is guided: no balance to manage, so you can go close to failure with nobody to spot you.",
                es: "La barra va guiada: sin equilibrio que gestionar, puedes acercarte al fallo sin nadie que te ayude."
            )
        }
        if exercise.equipment.contains(.dipStation) {
            return LocalizedText(
                fr: "Le poids du corps sur des barres parallèles : une charge que rien d'autre ne reproduit à la maison.",
                en: "Bodyweight on parallel bars: a load nothing else reproduces at home.",
                es: "El peso del cuerpo en paralelas: una carga que nada más reproduce en casa."
            )
        }
        return LocalizedText(
            fr: "La machine tient la trajectoire à ta place : tu peux pousser jusqu'au bout sans que la technique lâche avant le muscle.",
            en: "The machine holds the path for you: you can push to the end without technique failing before the muscle does.",
            es: "La máquina sostiene la trayectoria por ti: puedes apretar hasta el final sin que la técnica falle antes que el músculo."
        )
    }

    /// Comment placer ces mouvements dans la séance du jour.
    public static let howToUse = LocalizedText(
        fr: "Ce sont des mouvements que ta salle a et que ton salon n'a pas. Prends-en un ou deux, en fin de séance, deux ou trois séries chacun : ils s'ajoutent à ton plan, ils ne le remplacent pas.",
        en: "These are movements your gym has and your living room does not. Take one or two at the end of your session, two or three sets each: they add to your plan, they do not replace it.",
        es: "Son movimientos que tu gimnasio tiene y tu salón no. Coge uno o dos al final de la sesión, dos o tres series cada uno: se suman a tu plan, no lo sustituyen."
    )
}
