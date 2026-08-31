import Foundation

/// Les mouvements qu'on ne peut faire qu'en salle.
///
/// Pourquoi ce fichier existe
/// --------------------------
/// Le reste du catalogue est bâti pour être faisable partout : une barre, des
/// haltères, un banc, un sol. C'est le bon défaut — un plan qu'on ne peut pas
/// exécuter chez soi un jour de pluie ne sert à rien.
///
/// Mais quelqu'un qui paie un abonnement paie précisément pour ce qu'il n'a
/// pas chez lui : une presse, une poulie qui garde la tension en haut du
/// mouvement, une machine qui laisse aller à l'échec sans partenaire. Ne
/// jamais les proposer, c'est vendre une salle et prescrire un salon.
///
/// Chaque mouvement d'ici demande au moins un équipement qui ne se trouve que
/// dans une salle — machine guidée, poulie, Smith, station à dips. C'est ce
/// que `GymSpecific` lit pour composer la sélection du jour.
extension ExerciseCatalog {

    static let gymOnly: [Exercise] = gymLegs + gymBack + gymPush + gymArms + gymCore

    // MARK: - Jambes

    static let gymLegs: [Exercise] = [
        Exercise(
            id: "pendulum-squat",
            name: LocalizedText(fr: "Squat pendulaire", en: "Pendulum squat", es: "Sentadilla pendular"),
            cue: LocalizedText(
                fr: "Laisse la machine tenir ton dos : pousse par le milieu du pied, descends jusqu'à la cuisse parallèle.",
                en: "Let the machine hold your back: push through mid-foot, descend until the thigh is parallel.",
                es: "Deja que la máquina sostenga tu espalda: empuja con el medio del pie y baja hasta el muslo paralelo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings],
            pattern: .squat,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 5,
            viableRepRange: 6...15,
            loadFactor: 1.4,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "belt-squat",
            name: LocalizedText(fr: "Squat à la ceinture", en: "Belt squat", es: "Sentadilla con cinturón"),
            cue: LocalizedText(
                fr: "La charge pend aux hanches : le bas du dos ne porte rien, c'est tout l'intérêt.",
                en: "The load hangs from the hips: your low back carries nothing, which is the whole point.",
                es: "La carga cuelga de las caderas: tu zona lumbar no soporta nada, y de eso se trata."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes],
            pattern: .squat,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 1.3,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "smith-squat",
            name: LocalizedText(fr: "Squat à la Smith", en: "Smith machine squat", es: "Sentadilla en Smith"),
            cue: LocalizedText(
                fr: "Avance les pieds de vingt centimètres : la barre est fixe, c'est à toi de placer ton corps.",
                en: "Set the feet twenty centimetres forward: the bar is fixed, so you place your body around it.",
                es: "Adelanta los pies veinte centímetros: la barra es fija, eres tú quien coloca el cuerpo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes, .hamstrings],
            pattern: .squat,
            equipment: [.smithMachine],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 5...12,
            loadFactor: 0.95,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "smith-split-squat",
            name: LocalizedText(fr: "Fente bulgare à la Smith", en: "Smith split squat", es: "Zancada búlgara en Smith"),
            cue: LocalizedText(
                fr: "La barre guidée te dispense de l'équilibre : toute l'attention part dans la jambe avant.",
                en: "The guided bar removes the balance problem: all the attention goes into the front leg.",
                es: "La barra guiada elimina el equilibrio: toda la atención va a la pierna adelantada."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes],
            pattern: .lunge,
            equipment: [.smithMachine],
            isCompound: true,
            stressedAreas: [.knee],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.5,
            baseRestSeconds: 120,
            isUnilateral: true
        ),
        Exercise(
            id: "single-leg-press",
            name: LocalizedText(fr: "Presse à une jambe", en: "Single-leg press", es: "Prensa a una pierna"),
            cue: LocalizedText(
                fr: "Pied au centre du plateau, bassin qui ne se décolle jamais du dossier.",
                en: "Foot in the middle of the platform, hips that never lift off the backrest.",
                es: "Pie en el centro de la plataforma, cadera que nunca se despega del respaldo."
            ),
            primaryMuscle: .quads,
            secondaryMuscles: [.glutes],
            pattern: .lunge,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.9,
            baseRestSeconds: 120,
            isUnilateral: true
        ),
        Exercise(
            id: "machine-hip-thrust",
            name: LocalizedText(fr: "Hip thrust machine", en: "Machine hip thrust", es: "Hip thrust en máquina"),
            cue: LocalizedText(
                fr: "Menton rentré, côtes basses : monte jusqu'à ce que le bassin soit aligné avec les épaules.",
                en: "Chin tucked, ribs down: rise until the hips line up with the shoulders.",
                es: "Barbilla metida, costillas bajas: sube hasta alinear la cadera con los hombros."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .hinge,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 1.2,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "cable-kickback",
            name: LocalizedText(fr: "Kickback fessier à la poulie", en: "Cable glute kickback", es: "Patada de glúteo en polea"),
            cue: LocalizedText(
                fr: "La jambe part en arrière, pas en l'air : le bas du dos ne doit pas se creuser pour aller plus loin.",
                en: "The leg goes backwards, not upwards: the low back must not arch to gain range.",
                es: "La pierna va hacia atrás, no hacia arriba: la zona lumbar no debe arquearse para ganar recorrido."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.hamstrings],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...20,
            loadFactor: 0.15,
            baseRestSeconds: 60,
            isUnilateral: true
        ),
        Exercise(
            id: "seated-calf-raise",
            name: LocalizedText(fr: "Mollets assis", en: "Seated calf raise", es: "Gemelos sentado"),
            cue: LocalizedText(
                fr: "Genou plié, c'est le soléaire qui travaille : descends en bas complètement, sans rebondir.",
                en: "Knee bent, this is the soleus working: drop all the way down without bouncing.",
                es: "Rodilla flexionada, trabaja el sóleo: baja del todo, sin rebotar."
            ),
            primaryMuscle: .calves,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.5,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "hip-adduction",
            name: LocalizedText(fr: "Adducteurs machine", en: "Hip adduction machine", es: "Aductores en máquina"),
            cue: LocalizedText(
                fr: "Amplitude complète et lente : les adducteurs se blessent quand on ne les entraîne jamais.",
                en: "Full and slow range: adductors get hurt precisely when they are never trained.",
                es: "Recorrido completo y lento: los aductores se lesionan justo cuando nunca se entrenan."
            ),
            primaryMuscle: .glutes,
            secondaryMuscles: [.quads],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 12...25,
            loadFactor: 0.5,
            baseRestSeconds: 75
        ),
    ]

    // MARK: - Dos

    static let gymBack: [Exercise] = [
        Exercise(
            id: "chest-supported-row-machine",
            name: LocalizedText(
                fr: "Rowing machine buste calé",
                en: "Chest-supported machine row",
                es: "Remo en máquina con pecho apoyado"
            ),
            cue: LocalizedText(
                fr: "Le buste est tenu par l'appui : tire avec les coudes, le bas du dos ne participe pas.",
                en: "The pad holds your torso: pull with the elbows, the low back takes no part.",
                es: "El respaldo sujeta el torso: tira con los codos, la zona lumbar no participa."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps, .rearDelts],
            pattern: .horizontalPull,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 5,
            viableRepRange: 8...15,
            loadFactor: 1.0,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "t-bar-row",
            name: LocalizedText(fr: "Rowing T-bar", en: "T-bar row", es: "Remo en T"),
            cue: LocalizedText(
                fr: "Buste à quarante-cinq degrés, dos plat : la barre vient au nombril, pas au sternum.",
                en: "Torso at forty-five degrees, flat back: the bar meets your navel, not your sternum.",
                es: "Torso a cuarenta y cinco grados, espalda plana: la barra llega al ombligo, no al esternón."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 5,
            viableRepRange: 6...12,
            loadFactor: 1.0,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "assisted-pull-up",
            name: LocalizedText(fr: "Traction assistée", en: "Assisted pull-up", es: "Dominada asistida"),
            cue: LocalizedText(
                fr: "L'assistance est là pour te laisser faire de vraies tractions, pas pour te porter : baisse-la dès que huit répétitions passent.",
                en: "The assistance exists to let you do real pull-ups, not to carry you: reduce it as soon as eight reps go up.",
                es: "La asistencia está para que hagas dominadas de verdad, no para llevarte: bájala en cuanto salgan ocho repeticiones."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.biceps, .back],
            pattern: .verticalPull,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 6...12,
            loadFactor: 0.8,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "machine-pullover",
            name: LocalizedText(fr: "Pull-over machine", en: "Machine pullover", es: "Pull-over en máquina"),
            cue: LocalizedText(
                fr: "Bras presque tendus : ce sont les dorsaux qui ramènent, pas les coudes qui plient.",
                en: "Arms nearly straight: the lats bring the handle down, the elbows do not bend.",
                es: "Brazos casi estirados: son los dorsales los que traen el agarre, no los codos los que se doblan."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.chest, .triceps],
            pattern: .verticalPull,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 10...15,
            loadFactor: 0.7,
            baseRestSeconds: 90
        ),
        Exercise(
            id: "single-arm-lat-pulldown",
            name: LocalizedText(
                fr: "Tirage vertical à un bras",
                en: "Single-arm lat pulldown",
                es: "Jalón a un brazo"
            ),
            cue: LocalizedText(
                fr: "Un bras à la fois laisse descendre l'épaule plus bas : cherche l'étirement en haut avant de tirer.",
                en: "One arm at a time lets the shoulder travel further: find the stretch at the top before you pull.",
                es: "Un brazo cada vez deja bajar más el hombro: busca el estiramiento arriba antes de tirar."
            ),
            primaryMuscle: .lats,
            secondaryMuscles: [.biceps],
            pattern: .verticalPull,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.4,
            baseRestSeconds: 90,
            isUnilateral: true
        ),
        Exercise(
            id: "single-arm-cable-row",
            name: LocalizedText(
                fr: "Tirage horizontal à un bras",
                en: "Single-arm cable row",
                es: "Remo a un brazo en polea"
            ),
            cue: LocalizedText(
                fr: "Laisse l'épaule partir en avant en fin de retour, puis ramène-la : c'est l'amplitude que le tirage à deux bras te refuse.",
                en: "Let the shoulder travel forward at the end of the return, then bring it back: that is the range a two-arm row denies you.",
                es: "Deja que el hombro avance al final del retorno y luego tráelo: ese es el recorrido que el remo a dos brazos te niega."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.45,
            baseRestSeconds: 90,
            isUnilateral: true
        ),
        Exercise(
            id: "smith-row",
            name: LocalizedText(fr: "Rowing à la Smith", en: "Smith machine row", es: "Remo en Smith"),
            cue: LocalizedText(
                fr: "La barre monte en ligne droite : place-toi pour qu'elle croise ton nombril, pas tes cuisses.",
                en: "The bar travels in a straight line: stand so that it meets your navel, not your thighs.",
                es: "La barra sube en línea recta: colócate para que te llegue al ombligo, no a los muslos."
            ),
            primaryMuscle: .back,
            secondaryMuscles: [.lats, .biceps],
            pattern: .horizontalPull,
            equipment: [.smithMachine],
            isCompound: true,
            stressedAreas: [.lowerBack],
            stimulusRating: 4,
            viableRepRange: 8...12,
            loadFactor: 0.75,
            baseRestSeconds: 120
        ),
    ]

    // MARK: - Poussée

    static let gymPush: [Exercise] = [
        Exercise(
            id: "incline-machine-press",
            name: LocalizedText(
                fr: "Développé incliné machine",
                en: "Incline machine press",
                es: "Press inclinado en máquina"
            ),
            cue: LocalizedText(
                fr: "Poignées à hauteur de clavicules : plus haut, l'épaule prend tout le travail.",
                en: "Handles at collarbone height: any higher and the shoulder takes all the work.",
                es: "Agarres a la altura de las clavículas: más arriba, el hombro se lleva todo el trabajo."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.shoulders, .triceps],
            pattern: .horizontalPush,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.9,
            baseRestSeconds: 120
        ),
        Exercise(
            id: "pec-deck",
            name: LocalizedText(fr: "Écarté machine", en: "Pec deck", es: "Contractor de pecho"),
            cue: LocalizedText(
                fr: "Coudes légèrement fléchis et figés : ce sont les pectoraux qui referment, pas les bras qui poussent.",
                en: "Elbows slightly bent and locked there: the chest closes the arc, the arms do not press.",
                es: "Codos algo flexionados y fijos: es el pectoral el que cierra, no los brazos los que empujan."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.6,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "low-cable-crossover",
            name: LocalizedText(
                fr: "Écarté poulie basse",
                en: "Low-to-high cable fly",
                es: "Cruce de polea baja"
            ),
            cue: LocalizedText(
                fr: "Les mains montent vers le menton et se croisent : le haut des pectoraux ne travaille que dans cette direction.",
                en: "The hands rise towards the chin and cross: the upper chest only works in that direction.",
                es: "Las manos suben hacia la barbilla y se cruzan: el pectoral superior sólo trabaja en esa dirección."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.shoulders],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.3,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "smith-incline-press",
            name: LocalizedText(
                fr: "Développé incliné à la Smith",
                en: "Smith incline press",
                es: "Press inclinado en Smith"
            ),
            cue: LocalizedText(
                fr: "Aucun équilibre à gérer : va chercher l'échec proprement, les crochets sont à portée de pouce.",
                en: "No balance to manage: chase failure cleanly, the hooks are a thumb-turn away.",
                es: "Sin equilibrio que gestionar: busca el fallo con limpieza, los ganchos están a un giro de pulgar."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.shoulders, .triceps],
            pattern: .horizontalPush,
            equipment: [.smithMachine],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...12,
            loadFactor: 0.75,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "smith-overhead-press",
            name: LocalizedText(
                fr: "Développé militaire à la Smith",
                en: "Smith overhead press",
                es: "Press militar en Smith"
            ),
            cue: LocalizedText(
                fr: "Assis dossier droit : la trajectoire est imposée, à toi de régler le banc pour qu'elle passe devant ton front.",
                en: "Seated with an upright back: the path is fixed, so set the bench until it passes in front of your forehead.",
                es: "Sentado con respaldo recto: la trayectoria es fija, ajusta el banco para que pase por delante de tu frente."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [.triceps],
            pattern: .verticalPush,
            equipment: [.smithMachine],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...12,
            loadFactor: 0.55,
            baseRestSeconds: 150
        ),
        Exercise(
            id: "machine-lateral-raise",
            name: LocalizedText(
                fr: "Élévation latérale machine",
                en: "Machine lateral raise",
                es: "Elevación lateral en máquina"
            ),
            cue: LocalizedText(
                fr: "La résistance reste la même en bas comme en haut : c'est ce que les haltères ne savent pas faire.",
                en: "The resistance is the same at the bottom as at the top: that is what dumbbells cannot do.",
                es: "La resistencia es la misma abajo que arriba: eso es lo que las mancuernas no consiguen."
            ),
            primaryMuscle: .shoulders,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 10...20,
            loadFactor: 0.35,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "reverse-pec-deck",
            name: LocalizedText(
                fr: "Écarté inversé machine",
                en: "Reverse pec deck",
                es: "Contractor inverso"
            ),
            cue: LocalizedText(
                fr: "Ouvre avec les coudes, sans serrer les omoplates : ce sont les deltoïdes arrière qu'on vise, pas les trapèzes.",
                en: "Open with the elbows without squeezing the shoulder blades: the rear delts are the target, not the traps.",
                es: "Abre con los codos sin apretar las escápulas: el objetivo son los deltoides posteriores, no los trapecios."
            ),
            primaryMuscle: .rearDelts,
            secondaryMuscles: [.traps, .back],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 4,
            viableRepRange: 12...20,
            loadFactor: 0.3,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "assisted-dip",
            name: LocalizedText(fr: "Dips assistés", en: "Assisted dip", es: "Fondos asistidos"),
            cue: LocalizedText(
                fr: "Penche le buste en avant pour les pectoraux, garde-le droit pour les triceps : le même appareil fait les deux.",
                en: "Lean the torso forward for the chest, keep it upright for the triceps: the same machine does both.",
                es: "Inclina el torso adelante para el pectoral, mantenlo recto para el tríceps: la misma máquina hace las dos cosas."
            ),
            primaryMuscle: .chest,
            secondaryMuscles: [.triceps, .shoulders],
            pattern: .horizontalPush,
            equipment: [.machine],
            isCompound: true,
            stressedAreas: [.shoulder],
            stimulusRating: 4,
            viableRepRange: 6...12,
            loadFactor: 0.8,
            baseRestSeconds: 120
        ),
    ]

    // MARK: - Bras

    static let gymArms: [Exercise] = [
        Exercise(
            id: "preacher-curl-machine",
            name: LocalizedText(
                fr: "Curl pupitre machine",
                en: "Machine preacher curl",
                es: "Curl predicador en máquina"
            ),
            cue: LocalizedText(
                fr: "Bras calés jusqu'aux aisselles : tends complètement en bas, c'est là que le biceps s'allonge.",
                en: "Arms wedged up to the armpits: straighten fully at the bottom, that is where the biceps lengthens.",
                es: "Brazos apoyados hasta las axilas: estira del todo abajo, ahí es donde el bíceps se alarga."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.35,
            baseRestSeconds: 75
        ),
        Exercise(
            id: "cable-hammer-curl",
            name: LocalizedText(
                fr: "Curl marteau à la corde",
                en: "Cable hammer curl",
                es: "Curl martillo en polea"
            ),
            cue: LocalizedText(
                fr: "Paumes face à face du début à la fin : c'est le brachial, sous le biceps, qui pousse le bras vers le haut.",
                en: "Palms facing each other throughout: it is the brachialis, under the biceps, that pushes the arm up.",
                es: "Palmas enfrentadas de principio a fin: es el braquial, bajo el bíceps, el que empuja el brazo hacia arriba."
            ),
            primaryMuscle: .biceps,
            secondaryMuscles: [.forearms],
            pattern: .isolation,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [],
            stimulusRating: 3,
            viableRepRange: 10...15,
            loadFactor: 0.3,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "machine-triceps-extension",
            name: LocalizedText(
                fr: "Extension triceps machine",
                en: "Machine triceps extension",
                es: "Extensión de tríceps en máquina"
            ),
            cue: LocalizedText(
                fr: "Coudes plaqués contre l'appui : s'ils s'écartent, ce sont les épaules qui finissent le mouvement.",
                en: "Elbows pinned against the pad: if they drift out, the shoulders finish the movement.",
                es: "Codos pegados al apoyo: si se separan, son los hombros los que terminan el movimiento."
            ),
            primaryMuscle: .triceps,
            secondaryMuscles: [],
            pattern: .isolation,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.elbow],
            stimulusRating: 4,
            viableRepRange: 8...15,
            loadFactor: 0.4,
            baseRestSeconds: 75
        ),
    ]

    // MARK: - Ceinture abdominale

    static let gymCore: [Exercise] = [
        Exercise(
            id: "ab-crunch-machine",
            name: LocalizedText(fr: "Crunch machine", en: "Machine crunch", es: "Crunch en máquina"),
            cue: LocalizedText(
                fr: "Enroule la colonne, ne plie pas les hanches : le mouvement est court, et c'est normal.",
                en: "Curl the spine, do not fold at the hips: the movement is short, and that is correct.",
                es: "Enrolla la columna, no flexiones la cadera: el recorrido es corto, y así debe ser."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [],
            pattern: .coreBrace,
            equipment: [.machine],
            isCompound: false,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 10...20,
            loadFactor: 0.5,
            baseRestSeconds: 60
        ),
        Exercise(
            id: "cable-woodchop",
            name: LocalizedText(
                fr: "Rotation à la poulie",
                en: "Cable woodchop",
                es: "Leñador en polea"
            ),
            cue: LocalizedText(
                fr: "La rotation vient du tronc, les bras restent tendus : les hanches suivent, elles ne mènent pas.",
                en: "The rotation comes from the trunk, the arms stay long: the hips follow, they do not lead.",
                es: "La rotación viene del tronco, los brazos quedan estirados: las caderas siguen, no mandan."
            ),
            primaryMuscle: .core,
            secondaryMuscles: [.shoulders],
            pattern: .coreBrace,
            equipment: [.cable],
            isCompound: false,
            stressedAreas: [.lowerBack],
            stimulusRating: 3,
            viableRepRange: 10...15,
            loadFactor: 0.25,
            baseRestSeconds: 60,
            isUnilateral: true
        ),
    ]
}
