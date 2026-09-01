import Foundation

// Les fiches des isolations de jambes, des mollets et du tronc.
extension ExerciseBriefs {

    static let core: [ExerciseBrief] = [
        ExerciseBrief(
            id: "leg-curl",
            what: LocalizedText(
                fr: "Tu plies les genoux contre une résistance. C'est la seule façon de travailler les ischio-jambiers dans leur second rôle — plier le genou — que le soulevé roumain ne touche jamais.",
                en: "You bend the knees against resistance. The only way to train the hamstrings in their second job — bending the knee — which a Romanian deadlift never touches.",
                es: "Flexionas las rodillas contra una resistencia. Es la única forma de trabajar los isquiotibiales en su segunda función, flexionar la rodilla, que el peso muerto rumano nunca toca."
            ),
            setup: LocalizedText(
                fr: "L'axe de la machine doit tomber pile sur l'axe de ton genou : c'est le seul réglage qui compte, et le seul que personne ne fait. Le rouleau juste au-dessus du talon, pas sur le mollet.",
                en: "The machine's pivot must line up exactly with your knee joint: the only setting that matters, and the one nobody adjusts. The pad sits just above the heel, not on the calf.",
                es: "El eje de la máquina debe coincidir exactamente con el de tu rodilla: es el único ajuste que importa y el único que nadie hace. El rodillo justo encima del talón, no sobre el gemelo."
            ),
            watchOut: LocalizedText(
                fr: "Lâcher le retour. Les ischio-jambiers se déchirent en s'allongeant sous charge, jamais en se contractant : c'est donc la phase de retour freinée qui les protège autant qu'elle les construit. Trois secondes, à chaque répétition.",
                en: "Dropping the return. Hamstrings tear while lengthening under load, never while contracting: so the controlled return is what protects them as much as it builds them. Three seconds, every rep.",
                es: "Soltar la vuelta. Los isquiotibiales se rompen al alargarse bajo carga, nunca al contraerse: por eso la fase de vuelta frenada los protege tanto como los construye. Tres segundos, en cada repetición."
            )
        ),
        ExerciseBrief(
            id: "leg-extension",
            what: LocalizedText(
                fr: "Assis, tu tends les genoux contre un rouleau. C'est l'isolation pure du quadriceps, et la seule qui charge le droit fémoral — la partie que le squat sollicite le moins.",
                en: "Seated, you straighten the knees against a pad. Pure quad isolation, and the only one that loads the rectus femoris — the part squats reach least.",
                es: "Sentado, extiendes las rodillas contra un rodillo. Es el aislamiento puro del cuádriceps y el único que carga el recto femoral, la parte que menos toca la sentadilla."
            ),
            setup: LocalizedText(
                fr: "Dossier réglé pour que l'arrière du genou touche le bord du siège. Rouleau sur le bas du tibia, au-dessus de la cheville. Verrouille une seconde en haut : c'est là que le quadriceps est le plus court et le plus chargé.",
                en: "Backrest set so the back of your knee meets the edge of the seat. Pad on the lower shin, above the ankle. Hold a second at the top: that is where the quad is shortest and most loaded.",
                es: "Respaldo ajustado para que la parte trasera de la rodilla toque el borde del asiento. Rodillo en la parte baja de la tibia, por encima del tobillo. Bloquea un segundo arriba: ahí el cuádriceps está más corto y más cargado."
            ),
            watchOut: LocalizedText(
                fr: "Lancer la charge par à-coups depuis le bas. Le genou est en position de cisaillement à ce moment-là : monte progressivement, sans claquer, et arrête la série quand le à-coup devient nécessaire.",
                en: "Jerking the weight up from the bottom. The knee is in a shearing position right there: build up smoothly without snapping, and end the set when the jerk becomes necessary.",
                es: "Lanzar la carga a tirones desde abajo. La rodilla está en posición de cizalla justo ahí: sube progresivamente, sin golpes, y termina la serie cuando el tirón se vuelva necesario."
            )
        ),
        ExerciseBrief(
            id: "nordic-curl",
            what: LocalizedText(
                fr: "À genoux, chevilles bloquées, tu descends le buste vers le sol en résistant. C'est l'exercice qui protège le plus efficacement les ischio-jambiers d'une déchirure en course.",
                en: "Kneeling with the ankles held, you lower your torso towards the floor while resisting. The single most effective exercise for protecting hamstrings from tearing when you run.",
                es: "De rodillas, con los tobillos sujetos, bajas el torso hacia el suelo resistiendo. Es el ejercicio que mejor protege los isquiotibiales de una rotura al correr."
            ),
            setup: LocalizedText(
                fr: "Chevilles calées sous une charge ou tenues par quelqu'un, genoux sur un tapis. Corps aligné des genoux aux épaules, fessiers serrés. Descends aussi lentement que possible et rattrape-toi aux mains à la fin.",
                en: "Ankles wedged under something heavy or held by a partner, knees on a mat. Body in one line from knees to shoulders, glutes tight. Lower as slowly as you can and catch yourself with your hands.",
                es: "Tobillos sujetos bajo una carga o por alguien, rodillas sobre una colchoneta. Cuerpo alineado de rodillas a hombros, glúteos apretados. Baja lo más lento posible y recíbete con las manos."
            ),
            watchOut: LocalizedText(
                fr: "Casser aux hanches pour ralentir. Dès que les fesses partent en arrière, les ischios sont déchargés et l'exercice ne sert plus à rien. Si tu tombes au bout de vingt centimètres, c'est normal : c'est de là qu'on part.",
                en: "Breaking at the hips to slow yourself down. The moment your hips go back, the hamstrings are unloaded and the exercise is pointless. If you fall after twenty centimetres, that is normal: everyone starts there.",
                es: "Romper por la cadera para frenar. En cuanto el trasero va hacia atrás, los isquios se descargan y el ejercicio deja de servir. Si caes a los veinte centímetros, es normal: ahí empieza todo el mundo."
            )
        ),
        ExerciseBrief(
            id: "hip-abduction",
            what: LocalizedText(
                fr: "Assis, tu écartes les genoux contre une résistance. Ça cible le moyen fessier, le muscle qui stabilise le bassin à chaque foulée et dont la faiblesse se paie en douleur de genou.",
                en: "Seated, you push the knees apart against resistance. It targets the gluteus medius, the muscle that steadies the pelvis on every stride and whose weakness shows up as knee pain.",
                es: "Sentado, separas las rodillas contra una resistencia. Apunta al glúteo medio, el músculo que estabiliza la pelvis en cada zancada y cuya debilidad se paga con dolor de rodilla."
            ),
            setup: LocalizedText(
                fr: "Penche le buste de vingt degrés en avant : cette inclinaison change le muscle recruté et met le moyen fessier dans son meilleur angle. Ouvre au maximum, pause d'une seconde, referme lentement.",
                en: "Lean the torso twenty degrees forward: that tilt changes which muscle is recruited and puts the glute medius in its best angle. Open as far as you can, pause a second, close slowly.",
                es: "Inclina el torso veinte grados hacia delante: esa inclinación cambia el músculo reclutado y coloca al glúteo medio en su mejor ángulo. Abre al máximo, pausa de un segundo, cierra despacio."
            ),
            watchOut: LocalizedText(
                fr: "S'agripper aux poignées et pousser avec les bras et le dos. Le mouvement fait vingt centimètres : s'il faut se contorsionner pour finir, la charge est trop lourde de moitié.",
                en: "Gripping the handles and pushing with your arms and back. The movement is twenty centimetres: if you have to contort to finish, the load is twice what it should be.",
                es: "Agarrarse a las asas y empujar con brazos y espalda. El movimiento son veinte centímetros: si hay que contorsionarse para terminar, la carga es el doble de lo que debería."
            )
        ),
        ExerciseBrief(
            id: "standing-calf-raise",
            what: LocalizedText(
                fr: "Debout, tu montes sur la pointe des pieds avec une charge. Genou tendu, c'est le jumeau qui travaille — le muscle qui donne la forme au mollet et qui pousse à chaque foulée.",
                en: "Standing, you rise onto the balls of your feet under load. With a straight knee it is the gastrocnemius working — the muscle that shapes the calf and drives every stride.",
                es: "De pie, subes sobre las puntas con una carga. Con la rodilla estirada trabaja el gemelo, el músculo que da forma a la pantorrilla y que impulsa cada zancada."
            ),
            setup: LocalizedText(
                fr: "Avant-pieds sur une marche, talons dans le vide. Genoux tendus sans être verrouillés. Descends jusqu'à sentir l'étirement complet et tiens deux secondes en bas : c'est l'étirement chargé qui fait grossir un mollet, pas le nombre de répétitions.",
                en: "Forefeet on a step, heels hanging. Knees straight but not locked. Drop until you feel the full stretch and hold two seconds at the bottom: loaded stretch grows a calf, not rep count.",
                es: "Metatarsos sobre un escalón, talones al aire. Rodillas estiradas sin bloquear. Baja hasta notar el estiramiento completo y aguanta dos segundos abajo: el estiramiento cargado hace crecer el gemelo, no el número de repeticiones."
            ),
            watchOut: LocalizedText(
                fr: "Rebondir sur le tendon d'Achille. Les mollets sont les rois du rebond élastique : sans pause en bas, le tendon rend l'énergie et le muscle ne travaille presque pas. Deux secondes d'arrêt, sinon la série ne compte pas.",
                en: "Bouncing off the Achilles tendon. Calves are the champions of elastic rebound: with no pause at the bottom the tendon returns the energy and the muscle barely works. Two seconds still, or the set does not count.",
                es: "Rebotar sobre el tendón de Aquiles. Los gemelos son los reyes del rebote elástico: sin pausa abajo, el tendón devuelve la energía y el músculo apenas trabaja. Dos segundos parado, o la serie no cuenta."
            )
        ),
        ExerciseBrief(
            id: "bodyweight-calf-raise",
            what: LocalizedText(
                fr: "Les mollets sans charge, sur une marche. Le mollet supporte ton poids des milliers de fois par jour : au poids du corps, il faut beaucoup de répétitions ou une seule jambe pour que ça compte.",
                en: "Calves with no load, on a step. Your calf carries your bodyweight thousands of times a day: with no added weight it takes high reps or one leg at a time to matter.",
                es: "Gemelos sin carga, sobre un escalón. El gemelo soporta tu peso miles de veces al día: sin carga añadida hacen falta muchas repeticiones o una sola pierna para que cuente."
            ),
            setup: LocalizedText(
                fr: "Une main au mur pour l'équilibre, pas pour s'aider. Dès que vingt répétitions passent facilement sur deux jambes, passe à une seule : c'est ta façon d'ajouter de la charge sans matériel.",
                en: "One hand on the wall for balance, not for help. As soon as twenty reps on two legs feel easy, switch to one: that is how you add load with no equipment.",
                es: "Una mano en la pared para el equilibrio, no para ayudarte. En cuanto veinte repeticiones a dos piernas resulten fáciles, pasa a una sola: así añades carga sin material."
            ),
            watchOut: LocalizedText(
                fr: "Faire l'amplitude du haut seulement. Sans les talons dans le vide, il ne reste que la moitié contractée du mouvement, celle qui apporte le moins. La marche n'est pas un détail, c'est l'exercice.",
                en: "Doing only the top half. Without the heels hanging you keep just the shortened half of the movement, the one that gives least. The step is not a detail, it is the exercise.",
                es: "Hacer solo el recorrido alto. Sin los talones al aire queda únicamente la mitad contraída del movimiento, la que menos aporta. El escalón no es un detalle, es el ejercicio."
            )
        ),
        ExerciseBrief(
            id: "hanging-leg-raise",
            what: LocalizedText(
                fr: "Suspendu à une barre, tu remontes les jambes. C'est l'exercice d'abdominaux le plus dur du catalogue, et le seul qui travaille aussi la prise et les dorsaux au passage.",
                en: "Hanging from a bar, you raise your legs. The hardest ab exercise in the catalogue, and the only one that also trains your grip and lats along the way.",
                es: "Colgado de una barra, subes las piernas. Es el ejercicio abdominal más duro del catálogo y el único que además trabaja el agarre y los dorsales."
            ),
            setup: LocalizedText(
                fr: "Épaules actives, pas relâchées dans les articulations. Le mouvement commence par un enroulement du bassin vers les côtes : les jambes montent après, elles ne mènent pas.",
                en: "Shoulders active, not hanging slack in the joints. The movement starts by curling the pelvis towards the ribs: the legs come after, they do not lead.",
                es: "Hombros activos, no colgando sueltos en las articulaciones. El movimiento empieza enrollando la pelvis hacia las costillas: las piernas suben después, no lideran."
            ),
            watchOut: LocalizedText(
                fr: "Lever les jambes sans enrouler le bassin. Ce sont alors les fléchisseurs de hanche qui travaillent, et les abdominaux ne font que tenir : beaucoup d'effort, aucun résultat visible. Plie les genoux si nécessaire, mais enroule.",
                en: "Raising the legs without curling the pelvis. Then the hip flexors do the work and your abs merely hold on: lots of effort, nothing to show. Bend the knees if you must, but curl.",
                es: "Levantar las piernas sin enrollar la pelvis. Entonces trabajan los flexores de cadera y los abdominales solo sujetan: mucho esfuerzo y ningún resultado. Flexiona las rodillas si hace falta, pero enrolla."
            )
        ),
        ExerciseBrief(
            id: "cable-crunch",
            what: LocalizedText(
                fr: "À genoux sous une poulie haute, tu enroules le buste. C'est le seul exercice d'abdominaux qui se charge progressivement — donc le seul où l'on peut vraiment progresser.",
                en: "Kneeling under a high pulley, you curl the torso down. The only ab exercise you can load progressively — hence the only one where you truly progress.",
                es: "De rodillas bajo una polea alta, enrollas el torso. Es el único ejercicio abdominal que se carga progresivamente, y por tanto el único en el que se progresa de verdad."
            ),
            setup: LocalizedText(
                fr: "Corde de chaque côté de la tête, mains contre les tempes et qui ne bougent plus. Hanches figées : si elles reculent, c'est devenu un mouvement de dos. Le geste est un enroulement, vertèbre après vertèbre.",
                en: "Rope either side of your head, hands at your temples and staying there. Hips frozen: if they travel back it has become a back movement. The action is a curl, vertebra by vertebra.",
                es: "Cuerda a ambos lados de la cabeza, manos en las sienes y quietas. Caderas fijas: si retroceden, se ha convertido en un movimiento de espalda. El gesto es un enrollamiento, vértebra a vértebra."
            ),
            watchOut: LocalizedText(
                fr: "Tirer avec les bras. Tu chargerais alors les dorsaux et les épaules, et les abdominaux ne feraient que suivre. Les mains sont collées à la tête : si elles s'en éloignent, la série est finie.",
                en: "Pulling with the arms. You would be loading lats and shoulders while the abs just follow. The hands are glued to your head: if they move away, the set is over.",
                es: "Tirar con los brazos. Estarías cargando dorsales y hombros mientras los abdominales solo acompañan. Las manos están pegadas a la cabeza: si se separan, la serie ha terminado."
            )
        ),
        ExerciseBrief(
            id: "plank",
            what: LocalizedText(
                fr: "Tenir le corps rigide en appui sur les avant-bras. Ce n'est pas un exercice pour faire des abdominaux visibles : c'est celui qui apprend à ne pas laisser le bas du dos s'effondrer sous charge.",
                en: "Holding the body rigid on your forearms. This is not an exercise for visible abs: it teaches you not to let the low back collapse under load.",
                es: "Mantener el cuerpo rígido apoyado en los antebrazos. No es un ejercicio para abdominales visibles: enseña a no dejar que la zona lumbar se hunda bajo carga."
            ),
            setup: LocalizedText(
                fr: "Coudes sous les épaules. Bascule le bassin vers l'arrière et serre les fessiers : le bas du dos doit s'aplatir. Serre aussi les abdominaux comme pour encaisser un coup — une planche molle tenue trois minutes ne vaut rien.",
                en: "Elbows under the shoulders. Tilt the pelvis back and squeeze the glutes: the low back should flatten. Brace the abs as if to take a punch — a slack plank held three minutes is worth nothing.",
                es: "Codos bajo los hombros. Bascula la pelvis hacia atrás y aprieta los glúteos: la zona lumbar debe aplanarse. Aprieta también el abdomen como para encajar un golpe: una plancha floja de tres minutos no vale nada."
            ),
            watchOut: LocalizedText(
                fr: "Chercher la durée. Une minute tenue dur vaut mieux que trois molles : si le bas du dos creuse ou si les fessiers lâchent, arrête, c'est fini. Pour rendre ça plus dur, lève un pied — pas le chronomètre.",
                en: "Chasing duration. One hard minute beats three slack ones: if the low back sags or the glutes let go, stop, it is over. To make it harder, lift a foot — not the clock.",
                es: "Buscar la duración. Un minuto duro vale más que tres flojos: si la lumbar se hunde o los glúteos ceden, para, se acabó. Para hacerlo más difícil, levanta un pie, no el cronómetro."
            )
        ),
        ExerciseBrief(
            id: "dead-bug",
            what: LocalizedText(
                fr: "Sur le dos, tu allonges un bras et la jambe opposée sans laisser bouger le bassin. C'est l'exercice qui apprend à dissocier les membres du tronc — exactement ce qu'on fait en courant.",
                en: "On your back, you extend one arm and the opposite leg without letting the pelvis move. It teaches you to move limbs independently of the trunk — exactly what running asks.",
                es: "Boca arriba, extiendes un brazo y la pierna contraria sin dejar que la pelvis se mueva. Enseña a disociar los miembros del tronco, justo lo que se hace al correr."
            ),
            setup: LocalizedText(
                fr: "Le bas du dos collé au sol du début à la fin : glisse une main dessous, elle ne doit pas pouvoir passer. Descends le bras et la jambe aussi bas que le contact tient, pas plus.",
                en: "Low back pressed to the floor throughout: slide a hand under it, there should be no room. Lower the arm and leg as far as the contact holds, no further.",
                es: "La zona lumbar pegada al suelo de principio a fin: mete una mano debajo, no debe caber. Baja brazo y pierna hasta donde el contacto aguante, no más."
            ),
            watchOut: LocalizedText(
                fr: "Aller vite. C'est un exercice de contrôle : quatre répétitions lentes avec le dos plaqué valent vingt rapides avec le dos creusé — celles-là entraînent précisément le défaut qu'on voulait corriger.",
                en: "Going fast. This is a control exercise: four slow reps with the back down beat twenty quick ones with it arched — those train exactly the fault you meant to fix.",
                es: "Ir rápido. Es un ejercicio de control: cuatro repeticiones lentas con la espalda pegada valen más que veinte rápidas con la espalda arqueada, que entrenan justo el defecto que querías corregir."
            )
        ),
        ExerciseBrief(
            id: "farmer-carry",
            what: LocalizedText(
                fr: "Marcher avec une charge lourde dans chaque main. Ça travaille la prise, les trapèzes et tout le tronc à la fois, et c'est le transfert le plus direct vers la vie réelle du catalogue.",
                en: "Walking with something heavy in each hand. It trains grip, traps and the whole trunk at once, and it is the most directly useful movement in the catalogue.",
                es: "Caminar con una carga pesada en cada mano. Trabaja el agarre, los trapecios y todo el tronco a la vez, y es el ejercicio con transferencia más directa a la vida real."
            ),
            setup: LocalizedText(
                fr: "Épaules basses et en arrière, côtes rentrées, regard loin. Des pas courts et réguliers plutôt que de grandes enjambées. Respire pendant la marche : bloquer sa respiration sur trente mètres fait tourner la tête.",
                en: "Shoulders down and back, ribs tucked, eyes ahead. Short even steps rather than long strides. Keep breathing as you walk: holding your breath for thirty metres makes the room spin.",
                es: "Hombros bajos y atrás, costillas metidas, mirada al frente. Pasos cortos y regulares en vez de zancadas largas. Respira mientras caminas: aguantar la respiración treinta metros marea."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher d'un côté parce que les charges sont mal réparties, ou parce qu'une main lâche avant l'autre. Repose les deux dès que le buste s'incline : la série est terminée, et continuer ne renforce que le déséquilibre.",
                en: "Leaning to one side because the loads are uneven, or because one hand fails first. Put both down the moment the torso tips: the set is over, and carrying on only trains the imbalance.",
                es: "Inclinarse hacia un lado porque las cargas están desequilibradas o porque una mano cede antes. Deja ambas en cuanto el torso se incline: la serie ha terminado, y seguir solo refuerza el desequilibrio."
            )
        ),
    ]
}
