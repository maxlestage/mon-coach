import Foundation

/// Les mouvements qui n'apparaissent que lorsqu'une situation est déclarée.
///
/// Ils vivent à part du catalogue commun, et ce n'est pas un rangement.
/// Filtrer le catalogue par ce que le corps peut faire produit des trous
/// réels : pour quelqu'un dont un seul côté travaille, le catalogue commun
/// n'a plus rien du tout pour les pectoraux, les triceps, les deltoïdes
/// postérieurs, les ischio-jambiers ni les mollets — chacun de ces muscles
/// n'y est servi que par des mouvements à deux bras ou à deux jambes.
/// Un programme amputé de cinq muscles n'est pas un programme adapté,
/// c'est un programme cassé.
///
/// Ces treize-là comblent exactement ces trous. Ils restent en dehors de
/// `ExerciseCatalog.all` pour une raison de discipline : les ajouter au
/// catalogue commun aurait modifié les séances de tout le monde — le
/// sélecteur départage à égalité sur l'identifiant — pour un bénéfice nul
/// à qui n'en a pas besoin.
enum AdaptiveExercises {

    static let all: [Exercise] = [

        // MARK: - Pectoraux à un bras
        //
        // Le trou le plus large. Développé couché, développé haltères,
        // presse machine, écarté poulie, pec deck : les cinq exigent deux
        // bras. Sans ces deux mouvements, un hémiplégique n'a aucun
        // pectoral.
        Exercise(
            id: "single-arm-machine-chest-press",
            name: LocalizedText(
                fr: "Développé machine à un bras",
                en: "Single-arm machine chest press",
                es: "Press de pecho en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Cale l'épaule opposée contre le dossier : sans elle, le buste tourne et le pectoral perd la course.",
                en: "Brace the opposite shoulder into the pad: without it the trunk rotates and the chest loses the range.",
                es: "Apoya el hombro opuesto en el respaldo: sin él el tronco gira y el pectoral pierde el recorrido."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.35,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-band-press",
            name: LocalizedText(
                fr: "Développé élastique à un bras",
                en: "Single-arm band press",
                es: "Press con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Ancre l'élastique derrière toi à hauteur d'épaule et pousse en avant, sans laisser le buste partir.",
                en: "Anchor the band behind you at shoulder height and press forward without letting the trunk turn.",
                es: "Ancla la banda detrás de ti a la altura del hombro y empuja hacia delante sin dejar girar el tronco."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.band],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.20,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-cable-fly",
            name: LocalizedText(
                fr: "Écarté poulie à un bras",
                en: "Single-arm cable fly",
                es: "Aperturas en polea a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude à peine fléchi, main qui traverse la ligne du sternum : c'est là que le pectoral finit son travail.",
                en: "Elbow barely bent, hand crossing the line of the sternum: that is where the chest finishes its work.",
                es: "Codo apenas flexionado, mano cruzando la línea del esternón: ahí es donde el pectoral termina su trabajo."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.15,
            baseRestSeconds: 75,
            isUnilateral: true,
            demands: [.oneArm]
        ),

        // MARK: - Épaules et dos à un bras
        Exercise(
            id: "single-arm-shoulder-press",
            name: LocalizedText(
                fr: "Développé épaules à un bras",
                en: "Single-arm shoulder press",
                es: "Press de hombros a un brazo"
            ),
            cue: LocalizedText(
                fr: "Assis, dos calé. L'autre main tient le banc : c'est elle qui empêche le buste de s'incliner pour aider.",
                en: "Seated, back supported. The other hand holds the bench: it is what stops the trunk leaning in to help.",
                es: "Sentado, espalda apoyada. La otra mano sujeta el banco: es lo que impide que el tronco se incline para ayudar."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.dumbbell, .bench],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.25,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-band-row",
            name: LocalizedText(
                fr: "Tirage élastique à un bras",
                en: "Single-arm band row",
                es: "Remo con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Tire le coude vers la hanche, pas la main vers l'épaule : le dos travaille sur le trajet du coude.",
                en: "Drive the elbow to the hip, not the hand to the shoulder: the back works along the elbow's path.",
                es: "Lleva el codo hacia la cadera, no la mano hacia el hombro: la espalda trabaja en el recorrido del codo."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.band],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.20,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-reverse-fly",
            name: LocalizedText(
                fr: "Oiseau poulie à un bras",
                en: "Single-arm reverse fly",
                es: "Pájaro en polea a un brazo"
            ),
            cue: LocalizedText(
                fr: "Ouvre en arc, bras tendu, sans hausser l'épaule : dès qu'elle monte, le trapèze a pris le travail.",
                en: "Open in an arc, arm long, without shrugging: the moment the shoulder rises, the trap has taken over.",
                es: "Abre en arco, brazo largo, sin encoger el hombro: en cuanto sube, el trapecio ha tomado el trabajo."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.back],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.10,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "seated-shrug",
            name: LocalizedText(
                fr: "Haussement d'épaule assis",
                en: "Seated shrug",
                es: "Encogimiento sentado"
            ),
            cue: LocalizedText(
                fr: "Monte l'épaule vers l'oreille, sans rouler : le trapèze soulève, il ne tourne pas.",
                en: "Lift the shoulder toward the ear without rolling it: the trap lifts, it does not rotate.",
                es: "Sube el hombro hacia la oreja sin rodarlo: el trapecio levanta, no gira."
            ),
            primaryMuscle: .traps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.dumbbell, .bench],
            isCompound: false,
            stressedAreas: [.neck],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.30,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),

        // MARK: - Triceps
        //
        // Le catalogue commun les sert par la barre au front, l'extension
        // poulie à la corde et la machine — trois fois deux bras.
        Exercise(
            id: "single-arm-triceps-pushdown",
            name: LocalizedText(
                fr: "Extension poulie à un bras",
                en: "Single-arm triceps pushdown",
                es: "Extensión en polea a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude collé au flanc du début à la fin : dès qu'il avance, l'épaule a pris la série.",
                en: "Elbow pinned to the ribs throughout: the moment it drifts forward, the shoulder has taken the set.",
                es: "Codo pegado al costado de principio a fin: en cuanto se adelanta, el hombro se ha llevado la serie."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.12,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "wheelchair-press-up",
            name: LocalizedText(
                fr: "Poussée sur les accoudoirs",
                en: "Wheelchair press-up",
                es: "Elevación sobre los reposabrazos"
            ),
            cue: LocalizedText(
                fr: "Mains sur les mains courantes ou les accoudoirs, bassin décollé, épaules basses. C'est aussi le geste qui soulage les points d'appui.",
                en: "Hands on the rims or armrests, hips lifted, shoulders down. It is also the move that unloads the pressure points.",
                es: "Manos en los aros o reposabrazos, cadera despegada, hombros bajos. Es también el gesto que alivia los puntos de apoyo."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [.shoulders, .chest],
            pattern: .horizontalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 3,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            demands: [.bothArms]
        ),

        // MARK: - Une seule jambe
        //
        // Presse, leg curl, leg extension et mollets debout exigent tous
        // les deux jambes. La presse à une jambe existait déjà en salle ;
        // les trois autres manquaient.
        Exercise(
            id: "single-leg-curl",
            name: LocalizedText(
                fr: "Leg curl à une jambe",
                en: "Single-leg curl",
                es: "Curl femoral a una pierna"
            ),
            cue: LocalizedText(
                fr: "Bassin plaqué : s'il se soulève, la charge est trop lourde et le bas du dos travaille à la place.",
                en: "Hips flat: if they lift, the load is too heavy and the low back is doing the work instead.",
                es: "Cadera pegada: si se levanta, la carga es excesiva y la zona lumbar hace el trabajo."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.calves],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 8...15,
            loadFactor: 0.20,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "single-leg-extension",
            name: LocalizedText(
                fr: "Leg extension à une jambe",
                en: "Single-leg extension",
                es: "Extensión de cuádriceps a una pierna"
            ),
            cue: LocalizedText(
                fr: "Tends complètement et tiens une seconde en haut : c'est la fin du mouvement qui fait le quadriceps.",
                en: "Extend fully and hold a second at the top: it is the end of the range that builds the quad.",
                es: "Extiende del todo y aguanta un segundo arriba: es el final del recorrido lo que construye el cuádriceps."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.22,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "single-leg-seated-calf-raise",
            name: LocalizedText(
                fr: "Mollet assis à une jambe",
                en: "Single-leg seated calf raise",
                es: "Gemelo sentado a una pierna"
            ),
            cue: LocalizedText(
                fr: "Descends jusqu'à l'étirement complet avant de remonter : le mollet ne répond qu'à l'amplitude entière.",
                en: "Drop to a full stretch before rising: the calf only answers to full range.",
                es: "Baja hasta el estiramiento completo antes de subir: el gemelo solo responde al recorrido entero."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.25,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        ),

        // MARK: - Gainage sans passer par le sol
        //
        // Planche, dead bug et crunch poulie demandent tous de descendre
        // au sol et de s'en relever.
        Exercise(
            id: "seated-band-rotation",
            name: LocalizedText(
                fr: "Rotation élastique assis",
                en: "Seated band rotation",
                es: "Rotación con banda sentado"
            ),
            cue: LocalizedText(
                fr: "Fais tourner les côtes, pas les bras : les mains restent devant le sternum tout du long.",
                en: "Rotate the ribs, not the arms: the hands stay in front of the sternum the whole way.",
                es: "Gira las costillas, no los brazos: las manos permanecen frente al esternón todo el recorrido."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [],
            pattern: .coreBrace,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.0,
            baseRestSeconds: 60,
            demands: []
        )
    ]
}
