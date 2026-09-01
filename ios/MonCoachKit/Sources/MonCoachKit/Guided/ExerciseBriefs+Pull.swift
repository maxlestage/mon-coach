import Foundation

// Les fiches des mouvements de tirage : dos, dorsaux, arrière d'épaule.
extension ExerciseBriefs {

    static let pull: [ExerciseBrief] = [
        ExerciseBrief(
            id: "barbell-row",
            what: LocalizedText(
                fr: "Buste penché, tu tires une barre vers le ventre. C'est le tirage horizontal qui permet le plus de charge, et celui qui épaissit le milieu du dos.",
                en: "Torso bent over, you row a bar to your stomach. The horizontal pull that allows the most load, and the one that thickens the mid-back.",
                es: "Con el torso inclinado, llevas una barra hacia el abdomen. Es el tirón horizontal que admite más carga y el que engrosa la parte media de la espalda."
            ),
            setup: LocalizedText(
                fr: "Buste à quarante-cinq degrés, genoux légèrement fléchis, dos plat comme une table. La barre part sous les épaules et vient au nombril, pas à la poitrine : viser trop haut transforme le mouvement en travail d'arrière d'épaule.",
                en: "Torso at forty-five degrees, knees soft, back flat as a table. The bar starts under the shoulders and comes to the navel, not the chest: aiming high turns it into rear-delt work.",
                es: "Torso a cuarenta y cinco grados, rodillas algo flexionadas, espalda plana como una mesa. La barra sale bajo los hombros y llega al ombligo, no al pecho: apuntar alto lo convierte en trabajo de deltoides posterior."
            ),
            watchOut: LocalizedText(
                fr: "Se redresser à chaque répétition pour aider. Si ton buste remonte de vingt degrés en tirant, c'est un soulevé de terre partiel, pas un rowing — et le bas du dos ramasse tout. Baisse la charge et fige le buste.",
                en: "Standing up a little on every rep to help. If your torso rises twenty degrees as you pull, that is a partial deadlift, not a row — and your low back takes it all. Drop the weight and freeze the torso.",
                es: "Incorporarse en cada repetición para ayudar. Si el torso sube veinte grados al tirar, eso es un peso muerto parcial, no un remo, y la zona lumbar se lo lleva todo. Baja la carga y fija el torso."
            )
        ),
        ExerciseBrief(
            id: "chest-supported-row",
            what: LocalizedText(
                fr: "Le rowing poitrine calée sur un banc incliné. Le banc supprime toute possibilité de tricher avec les hanches : ce qui monte vient du dos, point.",
                en: "The row with your chest braced on an inclined bench. The bench removes every way of cheating with the hips: what moves comes from your back, full stop.",
                es: "El remo con el pecho apoyado en un banco inclinado. El banco elimina cualquier posibilidad de hacer trampa con la cadera: lo que sube viene de la espalda, y punto."
            ),
            setup: LocalizedText(
                fr: "Banc à trente ou quarante-cinq degrés, poitrine collée du sternum au haut du ventre. Laisse les bras pendre complètement en bas : c'est l'étirement des dorsaux qui donne au mouvement sa valeur.",
                en: "Bench at thirty or forty-five degrees, chest glued from sternum to upper belly. Let the arms hang fully at the bottom: the lat stretch is what makes this movement worth doing.",
                es: "Banco a treinta o cuarenta y cinco grados, pecho pegado del esternón a la parte alta del abdomen. Deja los brazos colgar del todo abajo: el estiramiento del dorsal es lo que da valor al movimiento."
            ),
            watchOut: LocalizedText(
                fr: "Décoller la poitrine du banc dans les dernières répétitions. C'est exactement la triche que le banc devait empêcher, et elle revient dès que la charge est trop lourde. Si tu décolles, c'est fini.",
                en: "Peeling your chest off the bench on the last reps. That is precisely the cheat the bench was there to stop, and it returns the moment the load is too heavy. If you lift off, the set is done.",
                es: "Despegar el pecho del banco en las últimas repeticiones. Es justo la trampa que el banco debía impedir, y vuelve en cuanto la carga es excesiva. Si te despegas, se acabó."
            )
        ),
        ExerciseBrief(
            id: "seated-cable-row",
            what: LocalizedText(
                fr: "Assis face à une poulie basse, tu tires une poignée vers le ventre. La tension ne disparaît jamais, même en position étirée : c'est ce que ni une barre ni des haltères ne savent faire.",
                en: "Seated facing a low pulley, you pull a handle to your stomach. Tension never disappears, not even in the stretch: something neither a bar nor dumbbells can do.",
                es: "Sentado frente a una polea baja, llevas un agarre hacia el abdomen. La tensión nunca desaparece, ni siquiera en estiramiento: algo que ni una barra ni las mancuernas consiguen."
            ),
            setup: LocalizedText(
                fr: "Genoux légèrement fléchis, buste vertical. En position basse, laisse les omoplates s'écarter et les bras s'allonger complètement — puis serre les omoplates avant de plier les bras. L'ordre compte : omoplates d'abord, coudes ensuite.",
                en: "Knees soft, torso upright. At the stretch, let the shoulder blades spread and the arms lengthen fully — then pinch the blades before you bend the arms. The order matters: blades first, elbows second.",
                es: "Rodillas algo flexionadas, torso vertical. Abajo, deja que las escápulas se separen y los brazos se estiren del todo; luego junta las escápulas antes de flexionar los brazos. El orden importa: escápulas primero, codos después."
            ),
            watchOut: LocalizedText(
                fr: "Se balancer d'avant en arrière comme sur un rameur. Le buste peut bouger de dix degrés, pas de quarante : au-delà c'est l'élan qui déplace la charge et le dos ne fait plus rien.",
                en: "Rocking back and forth like a rowing machine. The torso may move ten degrees, not forty: past that, momentum moves the weight and your back stops working.",
                es: "Balancearse adelante y atrás como en un remoergómetro. El torso puede moverse diez grados, no cuarenta: más allá, el impulso mueve la carga y la espalda deja de trabajar."
            )
        ),
        ExerciseBrief(
            id: "one-arm-dumbbell-row",
            what: LocalizedText(
                fr: "Un genou et une main sur un banc, tu tires un haltère avec l'autre bras. L'amplitude est plus grande qu'à deux bras, et chaque côté rattrape son retard tout seul.",
                en: "One knee and one hand on a bench, you row a dumbbell with the other arm. More range than a two-arm row, and each side catches up on its own.",
                es: "Una rodilla y una mano en el banco, remas con una mancuerna con el otro brazo. Más recorrido que a dos brazos, y cada lado recupera su retraso por sí mismo."
            ),
            setup: LocalizedText(
                fr: "Dos parallèle au sol, hanches carrées. L'haltère part sous l'épaule et remonte vers la hanche, pas vers l'aisselle. Tire avec le coude : imagine que ton bras n'est qu'un crochet accroché à l'haltère.",
                en: "Back parallel to the floor, hips square. The dumbbell starts under the shoulder and travels towards the hip, not the armpit. Pull with the elbow: your arm is only a hook holding the weight.",
                es: "Espalda paralela al suelo, caderas cuadradas. La mancuerna sale bajo el hombro y sube hacia la cadera, no hacia la axila. Tira con el codo: tu brazo solo es un gancho que sostiene el peso."
            ),
            watchOut: LocalizedText(
                fr: "Faire tourner le buste pour monter plus haut. Ça ajoute cinq centimètres visibles et zéro travail du dos : c'est la colonne qui tourne sous charge. Garde les deux épaules à la même hauteur.",
                en: "Twisting the torso to get the weight higher. It buys five visible centimetres and no back work: that is your spine rotating under load. Keep both shoulders level.",
                es: "Girar el torso para subir más alto. Añade cinco centímetros visibles y cero trabajo de espalda: es la columna girando bajo carga. Mantén los dos hombros a la misma altura."
            )
        ),
        ExerciseBrief(
            id: "inverted-row",
            what: LocalizedText(
                fr: "Suspendu sous une barre basse, corps rigide, tu tires ta poitrine vers elle. C'est le tirage horizontal au poids du corps, et il se règle simplement en changeant l'angle des pieds.",
                en: "Hanging under a low bar, body rigid, you pull your chest to it. The bodyweight horizontal pull, and you scale it just by changing the angle of your feet.",
                es: "Colgado bajo una barra baja, cuerpo rígido, llevas el pecho hacia ella. Es el tirón horizontal con el peso del cuerpo, y se ajusta solo cambiando el ángulo de los pies."
            ),
            setup: LocalizedText(
                fr: "Plus les pieds sont loin devant et le corps proche de l'horizontale, plus c'est dur : c'est ton réglage de charge. Serre les fessiers pour que le bassin ne traîne pas derrière la poitrine.",
                en: "The further your feet go and the closer to horizontal your body gets, the harder it is: that is your load setting. Squeeze the glutes so your hips do not trail behind your chest.",
                es: "Cuanto más lejos van los pies y más horizontal queda el cuerpo, más difícil es: ese es tu ajuste de carga. Aprieta los glúteos para que la cadera no se quede detrás del pecho."
            ),
            watchOut: LocalizedText(
                fr: "Toucher la barre avec le menton en tendant le cou. La poitrine doit toucher, pas la tête. Si elle n'y arrive pas, redresse les pieds — l'exercice reste utile, le cou tendu ne l'est pas.",
                en: "Reaching the bar with your chin by craning your neck. The chest touches, not the head. If it cannot, walk your feet in — the exercise still works; a strained neck does not.",
                es: "Tocar la barra con la barbilla estirando el cuello. Debe tocar el pecho, no la cabeza. Si no llega, acerca los pies: el ejercicio sigue sirviendo, el cuello estirado no."
            )
        ),
        ExerciseBrief(
            id: "band-row",
            what: LocalizedText(
                fr: "Le tirage horizontal avec un élastique. La résistance monte au fur et à mesure : c'est le plus facile en position étirée et le plus dur en position contractée, l'inverse d'une poulie.",
                en: "The horizontal pull with a band. Resistance rises as you go: easiest at the stretch, hardest at the squeeze — the opposite of a cable.",
                es: "El tirón horizontal con una goma. La resistencia sube a medida que avanzas: lo más fácil en estiramiento y lo más duro en contracción, al revés que una polea."
            ),
            setup: LocalizedText(
                fr: "Accroche l'élastique à hauteur de poitrine et recule d'un pas de plus que nécessaire : il doit déjà être tendu bras allongés, sinon la moitié du mouvement ne charge rien.",
                en: "Anchor the band at chest height and step back one pace more than you think: it should already be taut with the arms out, otherwise half the movement loads nothing.",
                es: "Ancla la goma a la altura del pecho y retrocede un paso más de lo necesario: debe estar ya tensa con los brazos extendidos, o media repetición no carga nada."
            ),
            watchOut: LocalizedText(
                fr: "Laisser l'élastique te ramener en avant. Le retour est la moitié utile du mouvement : il doit prendre deux fois plus longtemps que la traction, sinon autant ne rien faire.",
                en: "Letting the band snap you forward. The way back is the useful half: it should take twice as long as the pull, or you may as well not bother.",
                es: "Dejar que la goma te devuelva de golpe. La vuelta es la mitad útil del movimiento: debe durar el doble que el tirón, o no merece la pena."
            )
        ),
        ExerciseBrief(
            id: "pull-up",
            what: LocalizedText(
                fr: "Suspendu paumes vers l'avant, tu montes jusqu'à passer le menton au-dessus de la barre. C'est la mesure la plus dure et la plus claire de la force relative du haut du corps.",
                en: "Hanging with palms forward, you pull until your chin clears the bar. The hardest and clearest measure of relative upper-body strength there is.",
                es: "Colgado con las palmas hacia delante, subes hasta pasar la barbilla por encima de la barra. Es la medida más dura y más clara de la fuerza relativa del tren superior."
            ),
            setup: LocalizedText(
                fr: "Prise un peu plus large que les épaules. Avant de tirer, descends les épaules loin des oreilles : cette première dizaine de centimètres est le mouvement, tout le reste en découle.",
                en: "Grip just outside shoulder width. Before you pull, drive your shoulders down away from your ears: that first ten centimetres is the movement, everything else follows.",
                es: "Agarre algo más ancho que los hombros. Antes de tirar, baja los hombros lejos de las orejas: esos primeros diez centímetros son el movimiento, todo lo demás se deriva."
            ),
            watchOut: LocalizedText(
                fr: "Se balancer pour arracher les dernières. Une traction avec élan travaille surtout les hanches. Mieux vaut trois tractions propres qu'un balancier de huit — et si trois ne viennent pas, prends l'assistance.",
                en: "Kipping to squeeze out the last reps. A swung pull-up mostly trains the hips. Three clean ones beat eight swung — and if three will not come, use the assisted version.",
                es: "Balancearse para arrancar las últimas. Una dominada con impulso trabaja sobre todo la cadera. Mejor tres limpias que ocho con balanceo, y si no salen tres, usa la asistida."
            )
        ),
        ExerciseBrief(
            id: "chin-up",
            what: LocalizedText(
                fr: "La traction paumes vers soi. Les biceps aident bien plus qu'en pronation, donc on en fait plus — et c'est souvent la première traction complète qu'on réussit.",
                en: "The pull-up with palms facing you. The biceps help far more than in a pronated grip, so you get more reps — and it is usually the first full pull-up anyone gets.",
                es: "La dominada con las palmas hacia ti. Los bíceps ayudan mucho más que en pronación, así que salen más repeticiones, y suele ser la primera dominada completa que se consigue."
            ),
            setup: LocalizedText(
                fr: "Mains à largeur d'épaules, pas plus serrées : trop près, les poignets et les coudes encaissent. Croise les pieds derrière toi et serre les fessiers pour ne pas te balancer.",
                en: "Hands at shoulder width, no closer: too narrow and your wrists and elbows pay for it. Cross your feet behind you and squeeze the glutes so you do not swing.",
                es: "Manos a la anchura de los hombros, no más juntas: demasiado cerca y muñecas y codos lo pagan. Cruza los pies detrás y aprieta los glúteos para no balancearte."
            ),
            watchOut: LocalizedText(
                fr: "Ne pas descendre complètement entre les répétitions. Rester à mi-hauteur fait des séries plus longues et des dorsaux qui ne progressent pas : bras tendus en bas à chaque fois, même si ça coûte trois répétitions.",
                en: "Not coming all the way down between reps. Staying half-way makes longer sets and lats that do not grow: arms straight at the bottom every time, even if it costs you three reps.",
                es: "No bajar del todo entre repeticiones. Quedarse a media altura da series más largas y dorsales que no progresan: brazos estirados abajo siempre, aunque cueste tres repeticiones."
            )
        ),
        ExerciseBrief(
            id: "lat-pulldown",
            what: LocalizedText(
                fr: "Le tirage vertical sur poulie, assis. Le même geste qu'une traction, mais avec une charge réglable au kilo près : c'est ainsi qu'on construit une traction quand on n'en a pas encore.",
                en: "The vertical pull on a cable, seated. The same movement as a pull-up but with load adjustable to the kilo: this is how you build a pull-up before you have one.",
                es: "El jalón vertical en polea, sentado. El mismo gesto que una dominada pero con carga ajustable al kilo: así se construye una dominada cuando aún no la tienes."
            ),
            setup: LocalizedText(
                fr: "Cuisses bien coincées sous les rouleaux, sinon tu décolles avant la charge. Prise un peu plus large que les épaules, la barre descend au sternum et les coudes pointent vers le sol, pas vers l'arrière.",
                en: "Thighs wedged firmly under the pads, otherwise you lift off before the weight does. Grip slightly wider than the shoulders, bar to the sternum, elbows pointing at the floor rather than behind you.",
                es: "Muslos bien sujetos bajo los rodillos, o te levantarás antes que la carga. Agarre algo más ancho que los hombros, la barra baja al esternón y los codos apuntan al suelo, no hacia atrás."
            ),
            watchOut: LocalizedText(
                fr: "Tirer la barre derrière la nuque. Ça ne travaille pas plus le dos, ça force l'épaule dans sa position la plus vulnérable et ça met la tête en avant. Devant, toujours.",
                en: "Pulling the bar behind your neck. It does not work the back any more, it forces the shoulder into its most vulnerable position and shoves your head forward. In front, always.",
                es: "Llevar la barra detrás de la nuca. No trabaja más la espalda, fuerza el hombro en su posición más vulnerable y adelanta la cabeza. Por delante, siempre."
            )
        ),
        ExerciseBrief(
            id: "straight-arm-pulldown",
            what: LocalizedText(
                fr: "Bras tendus, tu ramènes une barre de devant vers les cuisses. Le coude ne bouge pas, donc les biceps ne peuvent pas aider : ce sont les dorsaux tout seuls, et ça se sent.",
                en: "Arms straight, you sweep a bar from in front down to your thighs. The elbow does not move, so the biceps cannot help: it is the lats alone, and you feel it.",
                es: "Con los brazos estirados, llevas una barra desde delante hasta los muslos. El codo no se mueve, así que los bíceps no pueden ayudar: son los dorsales solos, y se nota."
            ),
            setup: LocalizedText(
                fr: "Poulie haute, un pas en arrière, buste penché de vingt degrés. Bras presque tendus avec un angle de coude figé au départ : il ne change plus jusqu'à la fin de la série.",
                en: "High pulley, a step back, torso leaning twenty degrees. Arms nearly straight with the elbow angle locked at the start: it does not change again for the whole set.",
                es: "Polea alta, un paso atrás, torso inclinado veinte grados. Brazos casi rectos con el ángulo del codo fijado al inicio: no cambia hasta el final de la serie."
            ),
            watchOut: LocalizedText(
                fr: "Charger comme un tirage vertical. Bras tendus, le levier est énorme : la bonne charge est deux à trois fois plus légère, et si tu dois plier les coudes pour finir, elle est trop lourde.",
                en: "Loading it like a pulldown. With straight arms the lever is huge: the right weight is two to three times lighter, and if you have to bend your elbows to finish, it is too heavy.",
                es: "Cargarlo como un jalón. Con los brazos rectos la palanca es enorme: la carga correcta es dos o tres veces más ligera, y si tienes que flexionar los codos para terminar, pesa demasiado."
            )
        ),
    ]
}
