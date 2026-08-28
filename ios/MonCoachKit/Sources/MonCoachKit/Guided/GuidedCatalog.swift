import Foundation

/// Le mode guidé : apprendre un mouvement sans regarder une vidéo.
///
/// Une vidéo montre ce qu'il faut faire, elle ne dit pas ce qu'on est en
/// train de rater. Un débutant qui la regarde voit un mouvement fluide et
/// conclut que le sien devrait l'être aussi ; il n'apprend ni les repères
/// internes, ni ce qu'il doit sentir. Ces fiches font l'inverse : chaque
/// étape donne un point de contrôle vérifiable sans miroir et sans caméra,
/// et chaque erreur est décrite par la sensation qui la trahit.
///
/// Elles fonctionnent hors ligne, ne coûtent rien en données, et se lisent
/// entre deux séries avec un téléphone dans une main.
public enum GuidedCatalog {

    /// La fiche d'un exercice : la sienne s'il en a une, sinon celle de son
    /// schéma moteur. Aucun exercice du catalogue n'est laissé sans fiche.
    public static func technique(for exercise: Exercise) -> GuidedTechnique {
        byExercise[exercise.id] ?? byPattern[exercise.pattern] ?? fallback
    }

    public static func technique(forExerciseID id: String) -> GuidedTechnique? {
        guard let exercise = ExerciseCatalog.exercise(id: id) else { return nil }
        return technique(for: exercise)
    }

    public static var all: [GuidedTechnique] {
        MovementPattern.allCases.compactMap { byPattern[$0] } + byExercise.values.sorted { $0.id < $1.id }
    }

    // MARK: - Par schéma moteur

    public static let byPattern: [MovementPattern: GuidedTechnique] =
        primaryPatterns.merging(secondaryPatterns) { first, _ in first }

    static let primaryPatterns: [MovementPattern: GuidedTechnique] = [
        .squat: GuidedTechnique(
            id: "pattern-squat",
            title: LocalizedText(fr: "S'accroupir avec une charge", en: "Squatting under load", es: "Ponerse en cuclillas con carga"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Placer les pieds", en: "Set the feet", es: "Colocar los pies"),
                    detail: LocalizedText(
                        fr: "Écartement des épaules, pointes ouvertes de 15 à 30°. Ton écartement juste est celui où tu peux descendre sans que le bas du dos s'arrondisse : essaie sans charge avant de charger.",
                        en: "Shoulder width, toes turned out 15 to 30°. Your right stance is the one where you can descend without the low back rounding: try it unloaded before you load it.",
                        es: "A la anchura de los hombros, puntas abiertas de 15 a 30°. Tu apertura correcta es aquella en la que puedes bajar sin que se redondee la zona lumbar: pruébalo sin carga antes de cargar."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tu dois sentir ton poids réparti entre le talon et la base du gros orteil, pas sur les orteils.",
                        en: "You should feel your weight between the heel and the base of the big toe, not on the toes.",
                        es: "Debes notar el peso repartido entre el talón y la base del dedo gordo, no en los dedos."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Gainer avant de descendre", en: "Brace before you descend", es: "Activa el core antes de bajar"),
                    detail: LocalizedText(
                        fr: "Inspire par le ventre, puis serre les abdominaux comme si quelqu'un allait te donner un coup de poing. C'est ce verrou qui protège le bas du dos, pas la ceinture.",
                        en: "Breathe into the belly, then brace your abs as if someone were about to punch you. That lock is what protects your low back — not the belt.",
                        es: "Inspira hacia el abdomen y aprieta como si fueran a darte un puñetazo. Ese bloqueo es lo que protege tu zona lumbar, no el cinturón."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Ton ventre doit être dur sur les côtés, pas seulement devant.",
                        en: "Your midsection should be hard at the sides, not only at the front.",
                        es: "Tu abdomen debe estar duro por los lados, no solo por delante."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Descendre", en: "Descend", es: "Bajar"),
                    detail: LocalizedText(
                        fr: "Plie les genoux et les hanches en même temps, en trois secondes. Les genoux avancent, c'est normal et sans danger. Descends jusqu'à ce que le pli de la hanche passe sous le genou, ou jusqu'où tu peux aller sans t'arrondir.",
                        en: "Bend knees and hips together over three seconds. The knees travel forward — that is normal and safe. Go until the hip crease passes below the knee, or as far as you can without rounding.",
                        es: "Flexiona rodillas y caderas a la vez durante tres segundos. Las rodillas se adelantan: es normal y seguro. Baja hasta que el pliegue de la cadera pase por debajo de la rodilla, o hasta donde puedas sin redondear."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tes talons restent au sol du début à la fin.",
                        en: "Your heels stay down from start to finish.",
                        es: "Los talones no se despegan en ningún momento."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Remonter", en: "Stand up", es: "Subir"),
                    detail: LocalizedText(
                        fr: "Pousse le sol avec tout le pied et remonte hanches et épaules à la même vitesse. Ne cherche pas à « sortir les fesses » : si les hanches montent plus vite, la barre te tire vers l'avant.",
                        en: "Push the floor away with the whole foot and let hips and shoulders rise at the same speed. Do not lead with the hips: if they rise first, the bar pulls you forward.",
                        es: "Empuja el suelo con todo el pie y sube caderas y hombros a la misma velocidad. No saques primero la cadera: si sube antes, la barra te lleva hacia delante."
                    )
                ),
            ],
            breathing: LocalizedText(
                fr: "Inspire et bloque en haut, garde l'air pendant toute la répétition, expire une fois revenu debout. Ne souffle jamais dans la remontée : tu perds le verrou au moment où tu en as le plus besoin.",
                en: "Breathe in and hold at the top, keep the air for the whole rep, breathe out once you are standing. Never exhale on the way up: you lose the brace exactly when you need it most.",
                es: "Inspira y bloquea arriba, mantén el aire toda la repetición y espira al volver de pie. Nunca sueltes el aire al subir: pierdes el bloqueo justo cuando más lo necesitas."
            ),
            tempo: LocalizedText(
                fr: "Trois secondes pour descendre, aucune pause, remontée aussi vite que tu peux tout en gardant le contrôle.",
                en: "Three seconds down, no pause, up as fast as you can while staying in control.",
                es: "Tres segundos para bajar, sin pausa, subida tan rápida como puedas manteniendo el control."
            ),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu bascules vers l'avant et tu finis sur les orteils.", en: "You tip forward and end up on your toes.", es: "Te vas hacia delante y acabas sobre los dedos."),
                    cause: LocalizedText(fr: "Chevilles raides, ou écartement trop étroit.", en: "Stiff ankles, or a stance that is too narrow.", es: "Tobillos rígidos o una apertura demasiado estrecha."),
                    fix: LocalizedText(fr: "Écarte les pieds de cinq centimètres et ouvre davantage les pointes. Si ça ne suffit pas, cale des disques de 2,5 cm sous les talons.", en: "Widen the stance by five centimetres and turn the toes out more. If that is not enough, put 2.5 cm plates under your heels.", es: "Separa los pies cinco centímetros y abre más las puntas. Si no basta, pon discos de 2,5 cm bajo los talones.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Le bas du dos tire, surtout en bas du mouvement.", en: "Your low back complains, mostly at the bottom.", es: "Te tira la zona lumbar, sobre todo abajo."),
                    cause: LocalizedText(fr: "Le bassin bascule en arrière parce que tu descends plus bas que ta mobilité ne le permet.", en: "The pelvis tucks under because you go deeper than your mobility allows.", es: "La pelvis se retroversa porque bajas más de lo que permite tu movilidad."),
                    fix: LocalizedText(fr: "Arrête la descente cinq centimètres plus haut. La profondeur reviendra toute seule en quelques semaines.", en: "Stop the descent five centimetres higher. Depth comes back on its own within weeks.", es: "Detén la bajada cinco centímetros más arriba. La profundidad volverá sola en unas semanas.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Tes genoux rentrent vers l'intérieur dans la remontée.", en: "Your knees cave inward on the way up.", es: "Las rodillas se meten hacia dentro al subir."),
                    cause: LocalizedText(fr: "Charge trop lourde, ou fessiers qui ne participent pas.", en: "Too much load, or glutes that are not contributing.", es: "Demasiada carga, o glúteos que no participan."),
                    fix: LocalizedText(fr: "Baisse la charge de 10 % et pense à « écarter le sol » avec les pieds pendant toute la remontée.", en: "Drop the load by 10 % and think about spreading the floor apart with your feet the whole way up.", es: "Baja la carga un 10 % y piensa en «separar el suelo» con los pies durante toda la subida.")
                ),
            ],
            easier: LocalizedText(
                fr: "Squat au poids du corps en tenant un montant de porte, puis squat goblet avec un haltère contre la poitrine : le contrepoids devant t'aide à rester droit.",
                en: "Bodyweight squat holding a door frame, then goblet squat with a dumbbell at the chest: the counterweight in front helps you stay upright.",
                es: "Sentadilla con el peso corporal agarrando el marco de una puerta, luego sentadilla goblet con una mancuerna al pecho: el contrapeso delante ayuda a mantenerte erguido."
            ),
            harder: LocalizedText(
                fr: "Ajoute une pause de deux secondes en bas : c'est ce qui révèle si la position est vraiment tenue ou seulement traversée.",
                en: "Add a two-second pause at the bottom: it reveals whether the position is genuinely held or merely passed through.",
                es: "Añade una pausa de dos segundos abajo: revela si de verdad sostienes la posición o solo la atraviesas."
            ),
            oneThing: LocalizedText(
                fr: "Les hanches et les épaules montent ensemble. Tout le reste se corrige plus tard.",
                en: "Hips and shoulders rise together. Everything else can be fixed later.",
                es: "Caderas y hombros suben juntos. Todo lo demás se corrige después."
            )
        ),

        .hinge: GuidedTechnique(
            id: "pattern-hinge",
            title: LocalizedText(fr: "Charnière de hanche", en: "Hip hinge", es: "Bisagra de cadera"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Apprendre le geste sans charge", en: "Learn the move unloaded", es: "Aprende el gesto sin carga"),
                    detail: LocalizedText(
                        fr: "Debout à vingt centimètres d'un mur, pousse les fesses en arrière jusqu'à toucher le mur, genoux à peine fléchis. Ce recul des hanches est tout le mouvement — ce n'est pas un squat penché.",
                        en: "Stand twenty centimetres from a wall and push your backside back until it touches, knees barely bent. That backward travel of the hips is the entire movement — it is not a leaning squat.",
                        es: "De pie a veinte centímetros de una pared, lleva el trasero atrás hasta tocarla, con las rodillas apenas flexionadas. Ese desplazamiento de la cadera es todo el movimiento: no es una sentadilla inclinada."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tu dois sentir l'arrière des cuisses s'étirer avant de sentir quoi que ce soit dans le dos.",
                        en: "You should feel the back of your thighs stretch before you feel anything in your back.",
                        es: "Debes notar el estiramiento en la parte posterior de los muslos antes que nada en la espalda."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Verrouiller le dos", en: "Lock the back", es: "Bloquear la espalda"),
                    detail: LocalizedText(
                        fr: "Sors la poitrine et tire les épaules vers les hanches. Le dos doit rester dans la même forme du début à la fin : ce n'est pas lui qui bouge.",
                        en: "Lift the chest and pull the shoulders down towards the hips. The back keeps the same shape start to finish: it is not the part that moves.",
                        es: "Saca el pecho y lleva los hombros hacia las caderas. La espalda mantiene la misma forma de principio a fin: no es ella la que se mueve."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Descendre en poussant les hanches", en: "Push the hips back", es: "Bajar llevando la cadera atrás"),
                    detail: LocalizedText(
                        fr: "La charge frôle les cuisses tout du long. Descends tant que le dos reste plat, pas plus bas : ce n'est pas la profondeur qui fait le travail, c'est la tension.",
                        en: "The load brushes your thighs the whole way. Go down only as far as the back stays flat: depth is not what does the work, tension is.",
                        es: "La carga roza los muslos todo el recorrido. Baja solo mientras la espalda siga plana: no es la profundidad la que trabaja, es la tensión."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Si la charge s'éloigne de tes jambes, tu as commencé à te pencher au lieu de reculer.",
                        en: "If the load drifts away from your legs, you started leaning instead of hinging.",
                        es: "Si la carga se aleja de las piernas, has empezado a inclinarte en vez de hacer bisagra."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Revenir", en: "Come back up", es: "Volver arriba"),
                    detail: LocalizedText(
                        fr: "Serre les fessiers et avance les hanches jusqu'à être debout. Ne cambre pas en haut : debout, c'est debout, pas penché en arrière.",
                        en: "Squeeze the glutes and drive the hips forward until you are standing. Do not lean back at the top: standing is standing.",
                        es: "Aprieta los glúteos y lleva la cadera adelante hasta quedar de pie. No te eches atrás arriba: de pie es de pie."
                    )
                ),
            ],
            breathing: LocalizedText(
                fr: "Inspire debout, bloque, effectue la répétition entière, expire en haut.",
                en: "Breathe in standing, hold, do the whole rep, breathe out at the top.",
                es: "Inspira de pie, bloquea, haz la repetición entera y espira arriba."
            ),
            tempo: LocalizedText(
                fr: "Deux secondes pour descendre, remontée franche. Ce mouvement se rate quand on le fait vite.",
                en: "Two seconds down, a decisive drive up. This movement goes wrong when it is rushed.",
                es: "Dos segundos para bajar, subida decidida. Este movimiento se estropea cuando se hace deprisa."
            ),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu sens le bas du dos travailler plus que les ischio-jambiers.", en: "Your low back works harder than your hamstrings.", es: "Notas más la lumbar que los isquiotibiales."),
                    cause: LocalizedText(fr: "Le dos s'arrondit en fin de descente, ou tu descends trop bas.", en: "The back rounds late in the descent, or you go too deep.", es: "La espalda se redondea al final de la bajada, o bajas demasiado."),
                    fix: LocalizedText(fr: "Arrête-toi à mi-tibia et filme-toi une fois de profil, ou pose une barre légère le long du dos : elle doit toucher la tête, le haut du dos et le sacrum en permanence.", en: "Stop at mid-shin, and run a light bar along your back: it must stay in contact with head, upper back and sacrum throughout.", es: "Párate a media espinilla y apoya una barra ligera a lo largo de la espalda: debe tocar cabeza, espalda alta y sacro en todo momento.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu plies beaucoup les genoux et ça ressemble à un squat.", en: "You bend the knees a lot and it turns into a squat.", es: "Doblas mucho las rodillas y parece una sentadilla."),
                    cause: LocalizedText(fr: "Réflexe naturel : le corps préfère un mouvement qu'il connaît.", en: "A natural reflex: the body prefers the movement it already knows.", es: "Reflejo natural: el cuerpo prefiere el movimiento que ya conoce."),
                    fix: LocalizedText(fr: "Refais dix répétitions contre le mur, sans charge, avant chaque série.", en: "Do ten reps against the wall, unloaded, before every set.", es: "Haz diez repeticiones contra la pared, sin carga, antes de cada serie.")
                ),
            ],
            easier: LocalizedText(
                fr: "Charnière avec un haltère léger à deux mains, ou pont fessier au sol : même travail, sans le levier du dos.",
                en: "Hinge with a light dumbbell held in both hands, or a floor glute bridge: the same work without the back lever.",
                es: "Bisagra con una mancuerna ligera a dos manos, o puente de glúteo en el suelo: el mismo trabajo sin la palanca de la espalda."
            ),
            harder: LocalizedText(
                fr: "Passe sur une jambe : le déséquilibre force les fessiers à travailler pour de bon.",
                en: "Go single-leg: the instability forces the glutes to actually work.",
                es: "Pasa a una pierna: el desequilibrio obliga a los glúteos a trabajar de verdad."
            ),
            oneThing: LocalizedText(
                fr: "Les hanches reculent, elles ne descendent pas.",
                en: "The hips travel back, not down.",
                es: "La cadera va hacia atrás, no hacia abajo."
            )
        ),

        .horizontalPush: GuidedTechnique(
            id: "pattern-horizontal-push",
            title: LocalizedText(fr: "Pousser devant soi", en: "Pushing in front of you", es: "Empujar hacia delante"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Poser les omoplates", en: "Set the shoulder blades", es: "Fijar las escápulas"),
                    detail: LocalizedText(
                        fr: "Serre les omoplates l'une vers l'autre et vers le bas, et garde-les là pendant toute la série. Elles ne bougent pas, même quand les bras bougent.",
                        en: "Pull the shoulder blades together and down, and keep them there for the whole set. They do not move, even while the arms do.",
                        es: "Junta las escápulas y bájalas, y mantenlas ahí toda la serie. No se mueven, aunque los brazos sí."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tes épaules doivent être plus loin de tes oreilles qu'au départ.",
                        en: "Your shoulders should sit further from your ears than when you started.",
                        es: "Tus hombros deben quedar más lejos de las orejas que al empezar."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Prendre appui avec les pieds", en: "Get the feet involved", es: "Meter los pies"),
                    detail: LocalizedText(
                        fr: "Pieds à plat, jambes tendues contre le sol. Une poussée ne commence pas aux bras : le corps entier doit être solide.",
                        en: "Feet flat, legs pressing into the floor. A press does not start at the arms: the whole body has to be solid.",
                        es: "Pies planos, piernas empujando contra el suelo. Un empuje no empieza en los brazos: todo el cuerpo debe estar firme."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Descendre en contrôle", en: "Lower under control", es: "Bajar con control"),
                    detail: LocalizedText(
                        fr: "Amène la charge vers le bas de la poitrine, coudes à environ 45° du corps. Coudes complètement écartés, c'est l'épaule qui prend ; coudes collés, c'est le triceps qui fait tout.",
                        en: "Bring the load to the lower chest, elbows at roughly 45° from the body. Elbows flared wide loads the shoulder; elbows glued in makes the triceps do everything.",
                        es: "Lleva la carga a la parte baja del pecho, con los codos a unos 45° del cuerpo. Codos muy abiertos cargan el hombro; codos pegados hacen que el tríceps lo haga todo."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tes avant-bras doivent rester verticaux, vus de face.",
                        en: "Your forearms should stay vertical, seen from the front.",
                        es: "Tus antebrazos deben mantenerse verticales vistos de frente."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Pousser", en: "Press", es: "Empujar"),
                    detail: LocalizedText(
                        fr: "Pousse en gardant les omoplates serrées. Ne verrouille pas les coudes d'un coup sec en haut : arrête-toi juste avant l'extension complète.",
                        en: "Press while keeping the blades pinned. Do not snap the elbows straight at the top: stop just short of full extension.",
                        es: "Empuja manteniendo las escápulas fijas. No bloquees los codos de golpe arriba: párate justo antes de la extensión completa."
                    )
                ),
            ],
            breathing: LocalizedText(
                fr: "Inspire pendant la descente, expire pendant la poussée, une fois passé le point le plus dur.",
                en: "Breathe in as you lower, out as you press, once past the hardest point.",
                es: "Inspira al bajar y espira al empujar, una vez pasado el punto más difícil."
            ),
            tempo: LocalizedText(
                fr: "Deux secondes pour descendre, une seconde de contact léger, poussée rapide.",
                en: "Two seconds down, one second of light contact, fast press.",
                es: "Dos segundos para bajar, un segundo de contacto leve, empuje rápido."
            ),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Une douleur pointue à l'avant de l'épaule.", en: "A sharp pain at the front of the shoulder.", es: "Un dolor punzante en la parte delantera del hombro."),
                    cause: LocalizedText(fr: "Coudes trop écartés et omoplates qui ne tiennent pas.", en: "Elbows flared too wide with blades that will not hold.", es: "Codos demasiado abiertos y escápulas que no aguantan."),
                    fix: LocalizedText(fr: "Rentre les coudes vers 45°, réduis l'amplitude en t'arrêtant cinq centimètres au-dessus de la poitrine, et baisse la charge.", en: "Bring the elbows in to 45°, shorten the range by stopping five centimetres above the chest, and reduce the load.", es: "Cierra los codos hacia 45°, acorta el recorrido parando cinco centímetros sobre el pecho y baja la carga.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Les bras montent l'un plus vite que l'autre.", en: "One arm rises faster than the other.", es: "Un brazo sube más rápido que el otro."),
                    cause: LocalizedText(fr: "Asymétrie normale, aggravée par une charge trop lourde.", en: "Normal asymmetry, made worse by too much load.", es: "Asimetría normal, agravada por una carga excesiva."),
                    fix: LocalizedText(fr: "Passe aux haltères pendant six semaines : chaque bras doit alors faire son propre travail.", en: "Switch to dumbbells for six weeks: each arm then has to do its own work.", es: "Cambia a mancuernas seis semanas: así cada brazo hace su propio trabajo.")
                ),
            ],
            easier: LocalizedText(
                fr: "Pompes contre un mur ou sur un banc, ou presse à la machine : la trajectoire est guidée, tu peux te concentrer sur la poussée.",
                en: "Push-ups against a wall or a bench, or a chest-press machine: the path is guided, so you can concentrate on pushing.",
                es: "Flexiones contra la pared o en un banco, o máquina de press: la trayectoria está guiada y puedes concentrarte en empujar."
            ),
            harder: LocalizedText(
                fr: "Marque une pause d'une seconde au contact, sans relâcher la tension.",
                en: "Pause for one second at the bottom without letting the tension go.",
                es: "Haz una pausa de un segundo abajo sin perder la tensión."
            ),
            oneThing: LocalizedText(
                fr: "Les omoplates restent serrées du premier au dernier centimètre.",
                en: "The shoulder blades stay pinned from the first centimetre to the last.",
                es: "Las escápulas siguen fijas del primer al último centímetro."
            )
        ),
    ]

    // MARK: - Fiches communes aux familles restantes

    static let fallback = GuidedTechnique(
        id: "pattern-generic",
        title: LocalizedText(fr: "Exécuter proprement", en: "Executing cleanly", es: "Ejecutar limpio"),
        setup: [
            TechniqueStep(
                index: 1,
                title: LocalizedText(fr: "Se placer", en: "Get in position", es: "Colocarse"),
                detail: LocalizedText(
                    fr: "Installe-toi de façon à ce que le muscle visé soit en légère tension avant même la première répétition. Si tu dois te contorsionner pour démarrer, la charge est mal placée.",
                    en: "Set up so the target muscle is already under light tension before the first rep. If you have to contort yourself to start, the load is badly placed.",
                    es: "Colócate de modo que el músculo objetivo ya esté en ligera tensión antes de la primera repetición. Si tienes que contorsionarte para empezar, la carga está mal puesta."
                )
            ),
        ],
        execution: [
            TechniqueStep(
                index: 2,
                title: LocalizedText(fr: "Contrôler la descente", en: "Control the lowering", es: "Controlar la bajada"),
                detail: LocalizedText(
                    fr: "Deux secondes pour revenir, sans jamais laisser la charge tomber. C'est la phase qui construit le plus de muscle, et c'est celle que tout le monde bâcle.",
                    en: "Two seconds back, never letting the load drop. This is the phase that builds the most muscle, and the one everybody rushes.",
                    es: "Dos segundos para volver, sin dejar caer nunca la carga. Es la fase que más músculo construye y la que todo el mundo se salta."
                )
            ),
            TechniqueStep(
                index: 3,
                title: LocalizedText(fr: "Aller au bout de l'amplitude", en: "Use the whole range", es: "Usar todo el recorrido"),
                detail: LocalizedText(
                    fr: "Une amplitude complète avec 10 kg vaut mieux qu'une demi-amplitude avec 20. Réduis la charge jusqu'à pouvoir faire le mouvement en entier.",
                    en: "Full range with 10 kg beats half range with 20. Cut the load until you can do the whole movement.",
                    es: "Recorrido completo con 10 kg vale más que medio recorrido con 20. Baja la carga hasta poder hacer el movimiento entero."
                )
            ),
        ],
        breathing: LocalizedText(
            fr: "Expire dans l'effort, inspire dans le retour. Ne bloque jamais ta respiration sur une série longue.",
            en: "Breathe out on the effort, in on the return. Never hold your breath through a long set.",
            es: "Espira en el esfuerzo, inspira en la vuelta. Nunca bloquees la respiración en una serie larga."
        ),
        tempo: LocalizedText(
            fr: "Deux secondes au retour, une seconde à l'effort, sans à-coups.",
            en: "Two seconds back, one second on the effort, no jerking.",
            es: "Dos segundos de vuelta, uno de esfuerzo, sin tirones."
        ),
        mistakes: [
            CommonMistake(
                symptom: LocalizedText(fr: "Tu sens surtout tes articulations, pas le muscle.", en: "You mostly feel your joints, not the muscle.", es: "Notas sobre todo las articulaciones, no el músculo."),
                cause: LocalizedText(fr: "Charge trop lourde, exécutée avec de l'élan.", en: "Too much load, moved with momentum.", es: "Demasiada carga, movida con impulso."),
                fix: LocalizedText(fr: "Divise la charge par deux et refais la série en comptant trois secondes au retour.", en: "Halve the load and redo the set counting three seconds on the way back.", es: "Reduce la carga a la mitad y repite la serie contando tres segundos en la vuelta.")
            ),
        ],
        easier: LocalizedText(
            fr: "Réduis la charge et augmente les répétitions : entre 12 et 20 répétitions, le muscle travaille autant, et les articulations beaucoup moins.",
            en: "Cut the load and raise the reps: between 12 and 20 reps the muscle works just as hard and the joints far less.",
            es: "Baja la carga y sube las repeticiones: entre 12 y 20 el músculo trabaja igual y las articulaciones mucho menos."
        ),
        harder: LocalizedText(
            fr: "Ralentis le retour à quatre secondes avant d'ajouter du poids.",
            en: "Slow the lowering to four seconds before you add weight.",
            es: "Ralentiza la bajada a cuatro segundos antes de añadir peso."
        ),
        oneThing: LocalizedText(
            fr: "Contrôle le retour. C'est là que se trouve la moitié du résultat.",
            en: "Control the way back. Half the result lives there.",
            es: "Controla la vuelta. Ahí está la mitad del resultado."
        )
    )

    // MARK: - Fiches spécifiques à un exercice

    public static let byExercise: [String: GuidedTechnique] = [:]
}
