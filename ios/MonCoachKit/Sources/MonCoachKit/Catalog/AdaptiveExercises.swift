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
/// Ces soixante-deux-là comblent exactement ces trous. Ils restent en dehors
/// de `ExerciseCatalog.all` pour une raison de discipline : les ajouter au
/// catalogue commun aurait modifié les séances de tout le monde — le
/// sélecteur départage à égalité sur l'identifiant — pour un bénéfice nul
/// à qui n'en a pas besoin.
///
/// La liste est en deux moitiés, et la seconde est arrivée après coup.
/// Les premiers mouvements sont à la machine, à la poulie et à l'haltère :
/// mesurés avec une salle complète, ils comblaient tout. Chez quelqu'un qui
/// s'entraîne avec deux élastiques, ils n'existent pas — et l'application
/// lui annonçait alors qu'elle n'avait rien pour onze muscles sur quatorze.
/// Vérifier une seule configuration de matériel était la façon exacte de ne
/// pas le voir.
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
        ),

        // MARK: - Un élastique et un mur
        //
        // La partie qui manquait, et qui rendait tout le reste décoratif.
        //
        // Les mouvements ci-dessus sont à la machine, à la poulie ou à
        // l'haltère : ils comblent les trous d'une salle complète. Pour
        // quelqu'un qui s'entraîne chez lui avec deux élastiques, ils
        // n'existent pas — et le filtrage lui annonçait alors que le
        // catalogue n'avait rien pour onze muscles sur quatorze.
        //
        // Un élastique fait tout ce qu'une poulie fait, à un bras, pour
        // vingt euros. Un mur remplace l'équilibre. C'est tout ce qu'il
        // fallait, et le mesurer d'abord avec une salle complète est
        // exactement la façon de ne pas le voir.

        Exercise(
            id: "single-arm-band-high-row",
            name: LocalizedText(
                fr: "Tirage élastique haut à un bras",
                en: "Single-arm band high row",
                es: "Remo alto con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Ancre l'élastique au-dessus de toi et tire le coude vers l'arrière à hauteur d'épaule : c'est le dos en épaisseur, pas les dorsaux.",
                en: "Anchor the band above you and pull the elbow back at shoulder height: this is back thickness, not lats.",
                es: "Ancla la banda por encima de ti y lleva el codo atrás a la altura del hombro: esto es grosor de espalda, no dorsales."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.rearDelts, .biceps],
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
            id: "single-arm-band-shrug",
            name: LocalizedText(
                fr: "Haussement élastique à un bras",
                en: "Single-arm band shrug",
                es: "Encogimiento con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Debout sur l'élastique, monte l'épaule vers l'oreille sans rouler. Le trapèze soulève, il ne tourne pas.",
                en: "Standing on the band, lift the shoulder toward the ear without rolling it. The trap lifts, it does not rotate.",
                es: "De pie sobre la banda, sube el hombro hacia la oreja sin rodarlo. El trapecio levanta, no gira."
            ),
            primaryMuscle: .traps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.neck],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.20,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-band-overhead-press",
            name: LocalizedText(
                fr: "Développé élastique au-dessus de la tête, un bras",
                en: "Single-arm band overhead press",
                es: "Press con banda por encima de la cabeza a un brazo"
            ),
            cue: LocalizedText(
                fr: "L'élastique passe sous le pied ou sous la roue. Pousse vers le plafond sans cambrer : si le dos part en arrière, l'élastique est trop dur.",
                en: "The band runs under the foot or under the wheel. Press to the ceiling without arching: if the back leans away, the band is too strong.",
                es: "La banda pasa bajo el pie o bajo la rueda. Empuja hacia el techo sin arquear: si la espalda se va atrás, la banda es demasiado dura."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.band],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 8...20,
            loadFactor: 0.20,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-band-lateral-raise",
            name: LocalizedText(
                fr: "Élévation latérale élastique à un bras",
                en: "Single-arm band lateral raise",
                es: "Elevación lateral con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Monte jusqu'à l'horizontale, pas plus haut : au-dessus, c'est le trapèze qui prend le relais.",
                en: "Raise to horizontal, no higher: above that, the trap takes over.",
                es: "Sube hasta la horizontal, no más: por encima, el trapecio toma el relevo."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.10,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-band-reverse-fly",
            name: LocalizedText(
                fr: "Oiseau élastique à un bras",
                en: "Single-arm band reverse fly",
                es: "Pájaro con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Élastique ancré devant, à hauteur d'épaule. Ouvre en arc, bras tendu, sans hausser l'épaule.",
                en: "Band anchored in front, at shoulder height. Open in an arc, arm long, without shrugging.",
                es: "Banda anclada delante, a la altura del hombro. Abre en arco, brazo largo, sin encoger el hombro."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.back],
            pattern: .isolation,
            equipment: [.band],
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
            id: "single-arm-band-curl",
            name: LocalizedText(
                fr: "Curl élastique à un bras",
                en: "Single-arm band curl",
                es: "Curl con banda a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude fixé contre le flanc. L'élastique tire le plus fort en haut, là où le biceps est le plus court : ralentis la descente.",
                en: "Elbow pinned to the ribs. The band pulls hardest at the top, where the biceps is shortest: slow the way down.",
                es: "Codo fijo contra el costado. La banda tira más arriba, donde el bíceps está más corto: frena la bajada."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.band],
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
            id: "single-arm-band-overhead-extension",
            name: LocalizedText(
                fr: "Extension élastique nuque à un bras",
                en: "Single-arm band overhead extension",
                es: "Extensión con banda tras nuca a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude haut et immobile, seul l'avant-bras bouge. Le triceps ne travaille en entier que bras au-dessus de la tête.",
                en: "Elbow high and still, only the forearm moves. The triceps only works fully with the arm overhead.",
                es: "Codo alto e inmóvil, solo se mueve el antebrazo. El tríceps solo trabaja entero con el brazo por encima de la cabeza."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.band],
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
            id: "single-arm-band-wrist-curl",
            name: LocalizedText(
                fr: "Flexion de poignet élastique",
                en: "Single-arm band wrist curl",
                es: "Flexión de muñeca con banda"
            ),
            cue: LocalizedText(
                fr: "Avant-bras posé sur la cuisse, seule la main bouge. Amplitude complète, jamais de secousse.",
                en: "Forearm resting on the thigh, only the hand moves. Full range, never a jerk.",
                es: "Antebrazo apoyado en el muslo, solo se mueve la mano. Recorrido completo, nunca un tirón."
            ),
            primaryMuscle: .forearms,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.wrist],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.08,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneArm]
        ),

        // MARK: - Une jambe, sans machine
        //
        // L'appui de la main sur un mur ou un dossier n'est pas un détail
        // de confort : c'est lui qui retire l'exigence d'équilibre, et donc
        // ce qui rend ces trois-là possibles quand un côté ne répond plus.
        Exercise(
            id: "single-leg-sit-to-stand",
            name: LocalizedText(
                fr: "Assis-debout à une jambe",
                en: "Single-leg sit-to-stand",
                es: "Sentarse y levantarse a una pierna"
            ),
            cue: LocalizedText(
                fr: "Assis au bord d'une chaise, une main sur un appui, l'autre jambe devant. Lève-toi sur la jambe qui travaille, redescends en freinant. Chaise plus haute si c'est trop dur, plus basse si c'est trop simple.",
                en: "Seated on the edge of a chair, one hand on a support, the other leg out front. Stand on the working leg, lower under control. Higher chair if it is too hard, lower if too easy.",
                es: "Sentado al borde de una silla, una mano en un apoyo, la otra pierna al frente. Levántate con la pierna que trabaja y baja frenando. Silla más alta si cuesta, más baja si sobra."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings],
            pattern: .squat,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.standing, .oneLeg]
        ),
        Exercise(
            id: "single-leg-band-curl",
            name: LocalizedText(
                fr: "Flexion de jambe élastique",
                en: "Single-leg band curl",
                es: "Curl femoral con banda"
            ),
            cue: LocalizedText(
                fr: "Élastique à la cheville, ancré devant toi. Ramène le talon vers la fesse sans que la cuisse avance.",
                en: "Band at the ankle, anchored in front of you. Bring the heel to the glute without letting the thigh travel forward.",
                es: "Banda en el tobillo, anclada delante de ti. Lleva el talón al glúteo sin que el muslo se adelante."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.calves],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.10,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "seated-single-leg-hip-thrust",
            name: LocalizedText(
                fr: "Pont fessier à une jambe, dos sur un siège",
                en: "Single-leg hip thrust off a seat",
                es: "Puente de glúteo a una pierna con la espalda en un asiento"
            ),
            cue: LocalizedText(
                fr: "Omoplates appuyées sur un canapé ou une chaise, un pied au sol. Monte le bassin jusqu'à l'alignement, serre en haut une seconde. Aucun passage par le sol.",
                en: "Shoulder blades on a sofa or chair, one foot on the floor. Drive the hips to a straight line and squeeze at the top for a second. No trip to the floor.",
                es: "Omóplatos apoyados en un sofá o silla, un pie en el suelo. Sube la cadera hasta la línea recta y aprieta un segundo arriba. Sin pasar por el suelo."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .hinge,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "supported-single-leg-calf-raise",
            name: LocalizedText(
                fr: "Mollet à une jambe, main à l'appui",
                en: "Supported single-leg calf raise",
                es: "Gemelo a una pierna con apoyo de la mano"
            ),
            cue: LocalizedText(
                fr: "Une main au mur : elle tient l'équilibre, elle ne pousse pas. Monte le plus haut possible, redescends jusqu'à l'étirement complet.",
                en: "One hand on the wall: it holds balance, it does not push. Rise as high as you can, lower to a full stretch.",
                es: "Una mano en la pared: sostiene el equilibrio, no empuja. Sube lo más alto posible y baja hasta el estiramiento completo."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 3,
            viableRepRange: 10...25,
            loadFactor: 0.0,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.standing, .oneLeg]
        ),

        // MARK: - Une jambe, assis
        //
        // Les deux précédents demandent de tenir debout. Pour quelqu'un dont
        // les jambes fonctionnent mais qui ne tient pas debout longtemps —
        // sclérose en plaques, insuffisance cardiaque, arthrose sévère — ils
        // ne servent à rien, et le quadriceps comme le mollet redevenaient
        // introuvables. Assis, un élastique suffit aux deux.
        Exercise(
            id: "seated-band-leg-extension",
            name: LocalizedText(
                fr: "Extension de jambe élastique, assis",
                en: "Seated band leg extension",
                es: "Extensión de pierna con banda, sentado"
            ),
            cue: LocalizedText(
                fr: "Élastique à la cheville, ancré derrière la chaise. Tends la jambe à l'horizontale et tiens une seconde en haut.",
                en: "Band at the ankle, anchored behind the chair. Straighten the leg to horizontal and hold a second at the top.",
                es: "Banda en el tobillo, anclada detrás de la silla. Estira la pierna a la horizontal y aguanta un segundo arriba."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.12,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "seated-band-calf-raise",
            name: LocalizedText(
                fr: "Mollet assis à l'élastique",
                en: "Seated band calf raise",
                es: "Gemelo sentado con banda"
            ),
            cue: LocalizedText(
                fr: "Élastique passé sur le genou, pied à plat. Pousse par l'avant du pied, talon le plus haut possible, puis redescends jusqu'à l'étirement.",
                en: "Band over the knee, foot flat. Drive through the ball of the foot, heel as high as it goes, then lower to a stretch.",
                es: "Banda sobre la rodilla, pie plano. Empuja con la punta del pie, talón lo más alto posible, y baja hasta el estiramiento."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.band],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.10,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneLeg]
        ),

        // MARK: - Chaque matériel, pas seulement l'élastique
        //
        // Le même défaut qu'au tour précédent, d'un cran plus loin. La
        // première moitié de cette liste supposait une salle ; la deuxième
        // supposait un élastique. Mesuré matériel par matériel plutôt que
        // par lot, le catalogue laissait encore dix muscles sans rien à
        // quelqu'un qui n'a que le poids de son corps, cinq à quelqu'un qui
        // n'a que des haltères, huit à quelqu'un qui n'a que des machines.
        //
        // Une liste d'exercices adaptés qui exige d'acheter un accessoire
        // précis n'est pas adaptée : elle déplace la barrière.
        //
        // Ce qui suit couvre le poids du corps seul — une table, un mur,
        // une chaise, une serviette suffisent — puis les haltères sans
        // banc, la kettlebell, les machines, les poulies et la barre de
        // traction. Chacun à un seul côté.

        Exercise(
            id: "single-arm-incline-push-up",
            name: LocalizedText(
                fr: "Pompe inclinée à un bras",
                en: "Single-arm incline push-up",
                es: "Flexión inclinada a un brazo"
            ),
            cue: LocalizedText(
                fr: "Main sur une table, un plan de travail ou un mur : plus l'appui est haut, plus c'est léger. Descends lentement, l'autre main derrière le dos.",
                en: "Hand on a table, a worktop or a wall: the higher the surface, the lighter it is. Lower slowly, the other hand behind your back.",
                es: "Mano en una mesa, una encimera o la pared: cuanto más alto el apoyo, más ligero. Baja despacio, la otra mano tras la espalda."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders, .core],
            pattern: .horizontalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 4,
            viableRepRange: 5...20,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-table-row",
            name: LocalizedText(
                fr: "Tirage sous une table à un bras",
                en: "Single-arm table row",
                es: "Remo bajo una mesa a un brazo"
            ),
            cue: LocalizedText(
                fr: "Allongé sous une table solide, une main au bord. Tire la poitrine vers le plateau, talons au sol. Genoux pliés pour alléger.",
                en: "Lying under a sturdy table, one hand on the edge. Pull the chest to the top, heels on the floor. Bend the knees to make it lighter.",
                es: "Tumbado bajo una mesa firme, una mano en el borde. Lleva el pecho hacia el tablero, talones en el suelo. Dobla las rodillas para aligerar."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm, .floorTransfer]
        ),
        Exercise(
            id: "single-arm-scapular-push-up",
            name: LocalizedText(
                fr: "Pompe scapulaire à un bras",
                en: "Single-arm scapular push-up",
                es: "Flexión escapular a un brazo"
            ),
            cue: LocalizedText(
                fr: "En appui incliné, bras tendu qui ne plie pas : seule l'omoplate bouge. Écarte, puis serre. C'est court, et c'est tout le mouvement.",
                en: "In an incline position, arm straight and staying straight: only the shoulder blade moves. Push away, then pull together. It is short, and that is the whole movement.",
                es: "En apoyo inclinado, brazo estirado que no se dobla: solo se mueve la escápula. Separa y luego junta. Es corto, y ese es todo el movimiento."
            ),
            primaryMuscle: .traps,
            secondaryMuscles: [.shoulders],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.0,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-table-curl",
            name: LocalizedText(
                fr: "Curl sous une table",
                en: "Table curl",
                es: "Curl bajo la mesa"
            ),
            cue: LocalizedText(
                fr: "Assis, paume tournée vers le haut sous le plateau. Tire comme pour soulever la table : la résistance est celle que tu décides.",
                en: "Seated, palm up under the tabletop. Pull as if lifting the table: the resistance is the one you choose.",
                es: "Sentado, palma hacia arriba bajo el tablero. Tira como si levantaras la mesa: la resistencia es la que tú decides."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 2,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-close-incline-push-up",
            name: LocalizedText(
                fr: "Pompe serrée inclinée à un bras",
                en: "Single-arm close incline push-up",
                es: "Flexión cerrada inclinada a un brazo"
            ),
            cue: LocalizedText(
                fr: "Même appui que la pompe inclinée, coude qui frôle les côtes au lieu de s'ouvrir. C'est le triceps qui finit le mouvement.",
                en: "Same surface as the incline push-up, elbow brushing the ribs instead of flaring. The triceps finishes the movement.",
                es: "Mismo apoyo que la flexión inclinada, con el codo rozando las costillas en vez de abrirse. El tríceps termina el movimiento."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [.chest, .shoulders],
            pattern: .horizontalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.elbow, .wrist],
            stimulusRating: 3,
            viableRepRange: 6...20,
            loadFactor: 0.0,
            baseRestSeconds: 75,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-prone-raise",
            name: LocalizedText(
                fr: "Élévation à plat ventre, un bras",
                en: "Single-arm prone raise",
                es: "Elevación en prono a un brazo"
            ),
            cue: LocalizedText(
                fr: "À plat ventre sur un lit, bras pendant dans le vide. Monte en arc jusqu'à l'horizontale, pouce vers le plafond, sans hausser l'épaule.",
                en: "Face down on a bed, arm hanging off the edge. Raise in an arc to horizontal, thumb up, without shrugging.",
                es: "Boca abajo en una cama, brazo colgando. Sube en arco hasta la horizontal, pulgar hacia arriba, sin encoger el hombro."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.back, .shoulders],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.0,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-pike-incline-push-up",
            name: LocalizedText(
                fr: "Pompe piquée inclinée à un bras",
                en: "Single-arm pike incline push-up",
                es: "Flexión pica inclinada a un brazo"
            ),
            cue: LocalizedText(
                fr: "Main sur un appui haut, hanches hautes, tête qui descend vers l'appui. Remonte l'appui tant que ce n'est pas tenable : c'est le réglage, pas un renoncement.",
                en: "Hand on a high surface, hips high, head travelling down toward the surface. Raise the surface until it is manageable: that is the adjustment, not a retreat.",
                es: "Mano en un apoyo alto, caderas altas, la cabeza baja hacia el apoyo. Sube el apoyo hasta que sea llevadero: eso es el ajuste, no una renuncia."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 3,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-hand-towel-squeeze",
            name: LocalizedText(
                fr: "Serrage de serviette",
                en: "Towel squeeze",
                es: "Apretón de toalla"
            ),
            cue: LocalizedText(
                fr: "Une serviette roulée dans la main, serre trois secondes, relâche complètement. La main atteinte y a autant sa place que l'autre.",
                en: "A rolled towel in the hand, squeeze for three seconds, release fully. The affected hand belongs here as much as the other.",
                es: "Una toalla enrollada en la mano, aprieta tres segundos, suelta del todo. La mano afectada tiene aquí tanto sitio como la otra."
            ),
            primaryMuscle: .forearms,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.wrist],
            stimulusRating: 2,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-leg-hinge-to-chair",
            name: LocalizedText(
                fr: "Charnière de hanche à une jambe, vers une chaise",
                en: "Single-leg hinge to a chair",
                es: "Bisagra de cadera a una pierna hacia una silla"
            ),
            cue: LocalizedText(
                fr: "Une main sur un appui, une chaise derrière toi. Pousse les hanches en arrière jusqu'à frôler l'assise, dos droit, puis reviens.",
                en: "One hand on a support, a chair behind you. Push the hips back until you graze the seat, back flat, then return.",
                es: "Una mano en un apoyo, una silla detrás. Empuja la cadera atrás hasta rozar el asiento, espalda recta, y vuelve."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes, .core],
            pattern: .hinge,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 8...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.standing, .oneLeg]
        ),
        Exercise(
            id: "single-arm-dumbbell-floor-press",
            name: LocalizedText(
                fr: "Développé haltère au sol, un bras",
                en: "Single-arm dumbbell floor press",
                es: "Press con mancuerna en el suelo a un brazo"
            ),
            cue: LocalizedText(
                fr: "Allongé au sol, le coude s'arrête sur le sol : la course est raccourcie, l'épaule protégée. C'est voulu.",
                en: "Lying on the floor, the elbow stops on the floor: the range is shortened, the shoulder protected. That is deliberate.",
                es: "Tumbado en el suelo, el codo se detiene en el suelo: el recorrido se acorta y el hombro queda protegido. Es intencionado."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm, .floorTransfer]
        ),
        Exercise(
            id: "supported-single-arm-dumbbell-row",
            name: LocalizedText(
                fr: "Tirage haltère à un bras, main en appui",
                en: "Supported single-arm dumbbell row",
                es: "Remo con mancuerna a un brazo con apoyo"
            ),
            cue: LocalizedText(
                fr: "L'autre main sur un dossier de chaise, buste penché. Tire le coude vers la hanche, sans tourner les épaules.",
                en: "The other hand on a chair back, trunk hinged forward. Drive the elbow to the hip without rotating the shoulders.",
                es: "La otra mano en el respaldo de una silla, tronco inclinado. Lleva el codo a la cadera sin girar los hombros."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm, .standing]
        ),
        Exercise(
            id: "single-arm-dumbbell-high-row",
            name: LocalizedText(
                fr: "Tirage haltère haut à un bras",
                en: "Single-arm dumbbell high row",
                es: "Remo alto con mancuerna a un brazo"
            ),
            cue: LocalizedText(
                fr: "Même appui, mais le coude part vers l'extérieur à hauteur d'épaule : c'est le dos en épaisseur, pas les dorsaux.",
                en: "Same support, but the elbow travels out at shoulder height: this is back thickness, not lats.",
                es: "Mismo apoyo, pero el codo sale hacia fuera a la altura del hombro: esto es grosor de espalda, no dorsales."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.rearDelts, .traps],
            pattern: .horizontalPull,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 8...15,
            loadFactor: 0.25,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm, .standing]
        ),
        Exercise(
            id: "single-arm-dumbbell-reverse-fly",
            name: LocalizedText(
                fr: "Oiseau haltère à un bras",
                en: "Single-arm dumbbell reverse fly",
                es: "Pájaro con mancuerna a un brazo"
            ),
            cue: LocalizedText(
                fr: "Buste penché, autre main en appui. Ouvre en arc jusqu'à l'horizontale, bras presque tendu, sans hausser l'épaule.",
                en: "Trunk hinged, other hand supported. Open in an arc to horizontal, arm almost straight, without shrugging.",
                es: "Tronco inclinado, la otra mano apoyada. Abre en arco hasta la horizontal, brazo casi recto, sin encoger el hombro."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.back],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.08,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm, .standing]
        ),
        Exercise(
            id: "single-arm-dumbbell-overhead-extension",
            name: LocalizedText(
                fr: "Extension haltère nuque à un bras",
                en: "Single-arm dumbbell overhead extension",
                es: "Extensión con mancuerna tras nuca a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude haut et immobile, l'haltère descend derrière la tête. Seul l'avant-bras bouge.",
                en: "Elbow high and still, the dumbbell travels behind the head. Only the forearm moves.",
                es: "Codo alto e inmóvil, la mancuerna baja tras la cabeza. Solo se mueve el antebrazo."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.dumbbell],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 3,
            viableRepRange: 8...15,
            loadFactor: 0.15,
            baseRestSeconds: 75,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "supported-single-leg-dumbbell-rdl",
            name: LocalizedText(
                fr: "Soulevé roumain à une jambe, main en appui",
                en: "Supported single-leg dumbbell RDL",
                es: "Peso muerto rumano a una pierna con apoyo"
            ),
            cue: LocalizedText(
                fr: "Une main sur un dossier, l'haltère dans l'autre. La jambe libre part derrière en contrepoids, le dos reste droit.",
                en: "One hand on a chair back, the dumbbell in the other. The free leg swings back as a counterweight, the back stays flat.",
                es: "Una mano en un respaldo, la mancuerna en la otra. La pierna libre va atrás como contrapeso, la espalda recta."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes, .back],
            pattern: .hinge,
            equipment: [.dumbbell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.standing, .oneLeg]
        ),
        Exercise(
            id: "single-arm-kettlebell-press",
            name: LocalizedText(
                fr: "Développé kettlebell à un bras",
                en: "Single-arm kettlebell press",
                es: "Press con pesa rusa a un brazo"
            ),
            cue: LocalizedText(
                fr: "La kettlebell repose contre l'avant-bras, poignet droit. Pousse au plafond sans cambrer.",
                en: "The bell rests against the forearm, wrist straight. Press to the ceiling without arching.",
                es: "La pesa descansa contra el antebrazo, muñeca recta. Empuja al techo sin arquear."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps, .core],
            pattern: .verticalPush,
            equipment: [.kettlebell],
            isCompound: true,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 4,
            viableRepRange: 5...12,
            loadFactor: 0.25,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm, .standing]
        ),
        Exercise(
            id: "single-arm-kettlebell-row",
            name: LocalizedText(
                fr: "Tirage kettlebell à un bras",
                en: "Single-arm kettlebell row",
                es: "Remo con pesa rusa a un brazo"
            ),
            cue: LocalizedText(
                fr: "Autre main sur un appui, buste penché. Tire le coude vers la hanche, la kettlebell frôle la jambe.",
                en: "Other hand on a support, trunk hinged. Drive the elbow to the hip, the bell brushing the leg.",
                es: "La otra mano en un apoyo, tronco inclinado. Lleva el codo a la cadera, la pesa rozando la pierna."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps],
            pattern: .horizontalPull,
            equipment: [.kettlebell],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 4,
            viableRepRange: 6...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm, .standing]
        ),
        Exercise(
            id: "single-arm-machine-row",
            name: LocalizedText(
                fr: "Tirage machine à un bras",
                en: "Single-arm machine row",
                es: "Remo en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Poitrine contre le coussin : c'est lui qui empêche le buste de compenser. Coude vers l'arrière, pas la main.",
                en: "Chest against the pad: it is what stops the trunk compensating. Elbow back, not the hand.",
                es: "Pecho contra la almohadilla: es lo que impide que el tronco compense. Codo atrás, no la mano."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-machine-shoulder-press",
            name: LocalizedText(
                fr: "Développé épaules machine à un bras",
                en: "Single-arm machine shoulder press",
                es: "Press de hombros en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Dos plaqué au dossier. L'autre main tient la poignée du siège : elle empêche le buste de tourner.",
                en: "Back flat against the pad. The other hand holds the seat handle: it stops the trunk turning.",
                es: "Espalda pegada al respaldo. La otra mano sujeta el asiento: impide que el tronco gire."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.machine],
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
            id: "single-arm-cable-shrug",
            name: LocalizedText(
                fr: "Haussement poulie à un bras",
                en: "Single-arm cable shrug",
                es: "Encogimiento en polea a un brazo"
            ),
            cue: LocalizedText(
                fr: "Poulie basse, bras tendu le long du corps. Monte l'épaule vers l'oreille, tiens en haut, redescends complètement.",
                en: "Low pulley, arm long at your side. Lift the shoulder toward the ear, hold at the top, lower all the way.",
                es: "Polea baja, brazo estirado al costado. Sube el hombro hacia la oreja, aguanta arriba y baja del todo."
            ),
            primaryMuscle: .traps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.neck],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.25,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-cable-wrist-curl",
            name: LocalizedText(
                fr: "Flexion de poignet à la poulie",
                en: "Single-arm cable wrist curl",
                es: "Flexión de muñeca en polea"
            ),
            cue: LocalizedText(
                fr: "Avant-bras posé sur la cuisse, paume vers le haut, poulie basse devant. Seule la main bouge.",
                en: "Forearm on the thigh, palm up, low pulley in front. Only the hand moves.",
                es: "Antebrazo sobre el muslo, palma arriba, polea baja delante. Solo se mueve la mano."
            ),
            primaryMuscle: .forearms,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.wrist],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.1,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-leg-cable-knee-extension",
            name: LocalizedText(
                fr: "Extension de genou à la poulie",
                en: "Single-leg cable knee extension",
                es: "Extensión de rodilla en polea"
            ),
            cue: LocalizedText(
                fr: "Sangle à la cheville, poulie basse derrière. Assis, tends la jambe à l'horizontale et tiens une seconde.",
                en: "Ankle strap, low pulley behind. Seated, straighten the leg to horizontal and hold a second.",
                es: "Tobillera, polea baja detrás. Sentado, estira la pierna a la horizontal y aguanta un segundo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.15,
            baseRestSeconds: 75,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "single-leg-cable-calf-raise",
            name: LocalizedText(
                fr: "Mollet à la poulie, une jambe",
                en: "Single-leg cable calf raise",
                es: "Gemelo en polea a una pierna"
            ),
            cue: LocalizedText(
                fr: "Sangle à la cheville ou poignée tenue basse, une main à l'appui. Monte sur l'avant du pied, redescends jusqu'à l'étirement.",
                en: "Ankle strap or a handle held low, one hand on a support. Rise onto the ball of the foot, lower to a full stretch.",
                es: "Tobillera o agarre bajo, una mano en un apoyo. Sube sobre la punta del pie y baja hasta el estiramiento."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.2,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "single-arm-dead-hang",
            name: LocalizedText(
                fr: "Suspension à une main",
                en: "Single-arm dead hang",
                es: "Colgado a una mano"
            ),
            cue: LocalizedText(
                fr: "Pieds au sol ou sur un tabouret pour n'en prendre qu'une partie. La prise lâche avant tout le reste : c'est elle qu'on entraîne.",
                en: "Feet on the floor or a stool to take only part of your weight. The grip fails before everything else: it is the grip we are training.",
                es: "Pies en el suelo o en un taburete para tomar solo parte del peso. El agarre falla antes que todo lo demás: es el agarre lo que se entrena."
            ),
            primaryMuscle: .forearms,
            secondaryMuscles: [.lats],
            pattern: .isolation,
            equipment: [.pullUpBar],
            isCompound: false,
            stressedAreas: [.shoulder, .wrist],
            stimulusRating: 3,
            viableRepRange: 3...10,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-table-high-row",
            name: LocalizedText(
                fr: "Tirage haut sous une table, un bras",
                en: "Single-arm table high row",
                es: "Remo alto bajo una mesa a un brazo"
            ),
            cue: LocalizedText(
                fr: "Même table que le tirage précédent, mais le coude part vers l'extérieur à hauteur d'épaule : c'est le dos en épaisseur qui travaille, pas les dorsaux.",
                en: "Same table as the previous row, but the elbow travels out at shoulder height: back thickness works here, not the lats.",
                es: "La misma mesa que el remo anterior, pero el codo sale hacia fuera a la altura del hombro: trabaja el grosor de espalda, no los dorsales."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.rearDelts, .traps, .biceps],
            pattern: .horizontalPull,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm, .floorTransfer]
        ),
        Exercise(
            id: "single-arm-machine-pulldown",
            name: LocalizedText(
                fr: "Tirage vertical machine à un bras",
                en: "Single-arm machine pulldown",
                es: "Jalón en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Assis calé sous les cales, tire le coude vers la hanche du même côté. Le buste ne part pas en arrière pour aider.",
                en: "Seated under the pads, pull the elbow to the hip on the same side. The trunk does not lean back to help.",
                es: "Sentado bajo las almohadillas, lleva el codo a la cadera del mismo lado. El tronco no se echa atrás para ayudar."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps],
            pattern: .verticalPull,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-reverse-pec-deck",
            name: LocalizedText(
                fr: "Oiseau machine à un bras",
                en: "Single-arm reverse pec deck",
                es: "Pájaro en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Poitrine contre le coussin, un seul bras engagé. Ouvre jusqu'à l'alignement des épaules, pas au-delà.",
                en: "Chest against the pad, one arm engaged. Open until the shoulders line up, no further.",
                es: "Pecho contra la almohadilla, un solo brazo. Abre hasta alinear los hombros, no más."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.back],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.12,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-arm-machine-triceps-extension",
            name: LocalizedText(
                fr: "Extension triceps machine à un bras",
                en: "Single-arm machine triceps extension",
                es: "Extensión de tríceps en máquina a un brazo"
            ),
            cue: LocalizedText(
                fr: "Coude calé sur le coussin, il ne bouge pas de la série. Tends complètement, reviens en freinant.",
                en: "Elbow set on the pad, it does not move for the whole set. Extend fully, return under control.",
                es: "Codo apoyado en la almohadilla, no se mueve en toda la serie. Extiende del todo y vuelve frenando."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.15,
            baseRestSeconds: 75,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "single-leg-machine-hip-thrust",
            name: LocalizedText(
                fr: "Poussée de hanche machine à une jambe",
                en: "Single-leg machine hip thrust",
                es: "Empuje de cadera en máquina a una pierna"
            ),
            cue: LocalizedText(
                fr: "Un pied sur la plateforme, l'autre relevé. Monte jusqu'à l'alignement, serre une seconde, redescends sans poser la charge.",
                en: "One foot on the platform, the other lifted. Drive to a straight line, squeeze a second, lower without resting the weight.",
                es: "Un pie en la plataforma, el otro elevado. Sube hasta la línea recta, aprieta un segundo y baja sin apoyar la carga."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .hinge,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.3,
            baseRestSeconds: 120,
            isUnilateral: true,
            demands: [.oneLeg]
        ),

        // MARK: - Assis, sans rien
        //
        // Le trou le plus grave, et le dernier trouvé. Tous les tirages à un
        // bras au poids du corps passent par le sol — sous une table, allongé.
        // Résultat : quelqu'un en fauteuil qui s'entraîne chez lui avec des
        // haltères n'avait ni dos, ni dorsaux, ni gainage. Trois muscles
        // majeurs, pour la configuration la plus courante de tout ce menu.
        //
        // Ces six-là ne demandent qu'une table, une chaise et un sol.

        Exercise(
            id: "seated-single-arm-table-pull",
            name: LocalizedText(
                fr: "Traction sur une table, assis",
                en: "Seated single-arm table pull",
                es: "Tracción sobre una mesa, sentado"
            ),
            cue: LocalizedText(
                fr: "Assis face à une table lourde ou fauteuil freiné, main sous le plateau. Tire ton buste vers la table, coude vers la hanche, puis retiens le retour.",
                en: "Seated at a heavy table, or with the chair brakes on, hand under the top. Pull your trunk toward the table, elbow to the hip, then resist the way back.",
                es: "Sentado ante una mesa pesada, o con los frenos puestos, mano bajo el tablero. Lleva el tronco hacia la mesa, codo a la cadera, y frena la vuelta."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.back, .biceps],
            pattern: .horizontalPull,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 6...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "seated-single-arm-table-pull-high",
            name: LocalizedText(
                fr: "Traction haute sur une table, assis",
                en: "Seated single-arm high table pull",
                es: "Tracción alta sobre una mesa, sentado"
            ),
            cue: LocalizedText(
                fr: "Même prise, mais le coude part vers l'extérieur à hauteur d'épaule. Serre l'omoplate en fin de course : c'est là que le dos travaille.",
                en: "Same grip, but the elbow travels out at shoulder height. Squeeze the shoulder blade at the end: that is where the back works.",
                es: "El mismo agarre, pero el codo sale hacia fuera a la altura del hombro. Aprieta la escápula al final: ahí trabaja la espalda."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.rearDelts, .traps],
            pattern: .horizontalPull,
            equipment: [.bodyweight],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 8...15,
            loadFactor: 0.0,
            baseRestSeconds: 90,
            isUnilateral: true,
            demands: [.oneArm]
        ),
        Exercise(
            id: "seated-trunk-lean",
            name: LocalizedText(
                fr: "Buste penché contrôlé, assis",
                en: "Seated controlled trunk lean",
                es: "Inclinación de tronco controlada, sentado"
            ),
            cue: LocalizedText(
                fr: "Assis, mains libres. Penche le buste en avant lentement, aussi loin que tu contrôles, puis reviens sans t'aider des bras. C'est le retour qui compte.",
                en: "Seated, hands free. Lean the trunk forward slowly, as far as you control, then come back without using your arms. It is the way back that counts.",
                es: "Sentado, manos libres. Inclina el tronco despacio, hasta donde controles, y vuelve sin ayudarte con los brazos. Lo que cuenta es la vuelta."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [.back],
            pattern: .coreBrace,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 5...15,
            loadFactor: 0.0,
            baseRestSeconds: 75,
            isUnilateral: false,
            demands: []
        ),
        Exercise(
            id: "seated-single-leg-knee-extension",
            name: LocalizedText(
                fr: "Extension de genou assis, sans charge",
                en: "Seated single-leg knee extension",
                es: "Extensión de rodilla sentado, sin carga"
            ),
            cue: LocalizedText(
                fr: "Assis, tends la jambe à l'horizontale et tiens deux secondes avant de redescendre lentement. Le poids de la jambe suffit longtemps.",
                en: "Seated, straighten the leg to horizontal and hold two seconds before lowering slowly. The weight of the leg is enough for a long while.",
                es: "Sentado, estira la pierna a la horizontal y aguanta dos segundos antes de bajar despacio. El peso de la pierna basta mucho tiempo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 3,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "seated-single-leg-heel-raise",
            name: LocalizedText(
                fr: "Talon levé assis",
                en: "Seated single-leg heel raise",
                es: "Elevación de talón sentado"
            ),
            cue: LocalizedText(
                fr: "Pied à plat, monte le talon le plus haut possible en poussant par l'avant du pied, puis redescends jusqu'au sol. Appuie sur le genou avec la main pour alourdir.",
                en: "Foot flat, lift the heel as high as it goes by driving through the ball of the foot, then lower to the floor. Press on the knee with your hand to add load.",
                es: "Pie plano, sube el talón lo más alto posible empujando con la punta, y baja hasta el suelo. Presiona la rodilla con la mano para añadir carga."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.ankle],
            stimulusRating: 2,
            viableRepRange: 12...25,
            loadFactor: 0.0,
            baseRestSeconds: 45,
            isUnilateral: true,
            demands: [.oneLeg]
        ),
        Exercise(
            id: "seated-single-leg-heel-drag",
            name: LocalizedText(
                fr: "Talon tiré au sol, assis",
                en: "Seated single-leg heel drag",
                es: "Arrastre de talón sentado"
            ),
            cue: LocalizedText(
                fr: "Talon au sol, jambe tendue devant. Tire le talon vers toi en appuyant fort contre le sol : c'est le frottement qui fait la résistance.",
                en: "Heel on the floor, leg straight out front. Drag the heel toward you while pressing hard into the floor: the friction is the resistance.",
                es: "Talón en el suelo, pierna estirada al frente. Arrastra el talón hacia ti presionando fuerte contra el suelo: el rozamiento es la resistencia."
            ),
            primaryMuscle: .hamstrings,
            secondaryMuscles: [.glutes],
            pattern: .isolation,
            equipment: [.bodyweight],
            isCompound: false,
            stressedAreas: [.knee],
            stimulusRating: 2,
            viableRepRange: 8...20,
            loadFactor: 0.0,
            baseRestSeconds: 60,
            isUnilateral: true,
            demands: [.oneLeg]
        )
    ]
}
