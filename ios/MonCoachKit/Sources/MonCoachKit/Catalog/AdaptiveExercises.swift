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
/// Ces vingt-sept-là comblent exactement ces trous. Ils restent en dehors
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
        )
    ]
}
