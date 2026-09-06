import Foundation

/// Les fiches des mouvements adaptés.
///
/// Elles existent pour la même raison que les autres, et une de plus : ces
/// mouvements-là sont ceux que personne n'a jamais vus faire. Un développé
/// couché, on en a vu mille ; une traction sur le plateau d'une table
/// depuis un fauteuil, aucune. La fiche n'est pas un supplément ici, c'est
/// la seule source.
///
/// Elles ont failli ne jamais exister. Le verrou qui interdit d'ajouter un
/// exercice sans sa fiche ne lisait que `ExerciseCatalog.all`, et les
/// mouvements adaptés vivent à part — soixante-deux mouvements sont donc
/// passés à travers sans que rien ne rougisse. Le test lit maintenant les
/// deux listes.
extension ExerciseBriefs {

    static let adaptive: [ExerciseBrief] = [
        ExerciseBrief(
            id: "single-arm-machine-chest-press",
            what: LocalizedText(
                fr: "Le développé pectoraux d'une machine, mené par un seul bras. La machine tient la trajectoire à ta place, ce qui est précisément ce qui manque quand l'autre côté ne stabilise pas.",
                en: "A machine chest press driven by one arm. The machine holds the path for you, which is exactly what is missing when the other side does not stabilise.",
                es: "El press de pecho de una máquina, llevado con un solo brazo. La máquina mantiene la trayectoria por ti, que es justo lo que falta cuando el otro lado no estabiliza."
            ),
            setup: LocalizedText(
                fr: "Assieds-toi de façon que la poignée arrive à hauteur du milieu de la poitrine, pas des épaules. Cale l'épaule opposée contre le dossier et garde-la là : c'est elle qui empêche le buste de tourner pendant la poussée.",
                en: "Set the seat so the handle arrives at mid-chest height, not shoulder height. Brace the opposite shoulder into the backrest and keep it there: it is what stops the trunk turning as you press.",
                es: "Ajusta el asiento para que el agarre quede a la altura del centro del pecho, no de los hombros. Apoya el hombro contrario en el respaldo y mantenlo ahí: es lo que impide que el tronco gire al empujar."
            ),
            watchOut: LocalizedText(
                fr: "Le buste qui pivote pour accompagner le bras. Tu le sens à ce que l'épaule opposée décolle du dossier : la course s'allonge sur le papier et le pectoral, lui, n'a rien gagné.",
                en: "The trunk rotating to follow the arm. You feel it when the opposite shoulder lifts off the pad: the range looks longer and the chest has gained nothing.",
                es: "El tronco girando para acompañar al brazo. Lo notas cuando el hombro contrario se despega del respaldo: el recorrido parece mayor y el pectoral no ha ganado nada."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-press",
            what: LocalizedText(
                fr: "La poussée pectorale avec un élastique ancré derrière toi. La résistance monte à mesure que le bras s'avance, donc c'est en fin de course qu'il faut serrer.",
                en: "The chest press with a band anchored behind you. The resistance rises as the arm travels forward, so it is at the end of the range that you squeeze.",
                es: "El empuje de pecho con una banda anclada detrás. La resistencia sube a medida que el brazo avanza, así que hay que apretar al final del recorrido."
            ),
            setup: LocalizedText(
                fr: "Ancre l'élastique à hauteur d'épaule — poignée de porte, montant de lit, roue freinée. Recule jusqu'à sentir une tension avant même de commencer : sans elle, la moitié du mouvement se fait dans le vide.",
                en: "Anchor the band at shoulder height — a door handle, a bed frame, a locked wheel. Step out until you feel tension before you even start: without it, half the movement happens in thin air.",
                es: "Ancla la banda a la altura del hombro: un pomo, el somier, una rueda frenada. Aléjate hasta notar tensión antes de empezar: sin ella, medio movimiento se hace en el vacío."
            ),
            watchOut: LocalizedText(
                fr: "Le buste qui part avec le bras au lieu de résister. L'élastique tire en diagonale et cherche à te faire tourner : si tu finis la série de biais, c'est lui qui a gagné, pas toi.",
                en: "The trunk travelling with the arm instead of resisting. The band pulls diagonally and tries to turn you: if you finish the set at an angle, the band won, not you.",
                es: "El tronco yéndose con el brazo en vez de resistir. La banda tira en diagonal y busca girarte: si terminas la serie de lado, ha ganado ella, no tú."
            )
        ),
        ExerciseBrief(
            id: "single-arm-cable-fly",
            what: LocalizedText(
                fr: "L'écarté à la poulie, un bras à la fois. Le pectoral finit son travail quand la main traverse la ligne du corps, et c'est la seule chose que ce mouvement cherche.",
                en: "The cable fly, one arm at a time. The chest finishes its work when the hand crosses the midline of the body, and that is the only thing this movement is after.",
                es: "La apertura en polea, un brazo cada vez. El pectoral termina su trabajo cuando la mano cruza la línea del cuerpo, y es lo único que busca este movimiento."
            ),
            setup: LocalizedText(
                fr: "Poulie à hauteur d'épaule, coude à peine fléchi et fixé à cet angle du début à la fin. Fais un pas devant la poulie pour garder de la tension même bras ouvert.",
                en: "Pulley at shoulder height, elbow barely bent and locked at that angle from start to finish. Take a step past the pulley so there is still tension with the arm open.",
                es: "Polea a la altura del hombro, codo apenas flexionado y fijo en ese ángulo de principio a fin. Da un paso por delante de la polea para conservar tensión con el brazo abierto."
            ),
            watchOut: LocalizedText(
                fr: "Plier le coude en cours de route. Dès qu'il se ferme, l'écarté devient une poussée et le pectoral perd la tension d'étirement qui fait tout l'intérêt du mouvement.",
                en: "Bending the elbow along the way. The moment it closes, the fly becomes a press and the chest loses the stretch tension that is the whole point.",
                es: "Doblar el codo por el camino. En cuanto se cierra, la apertura se vuelve un empuje y el pectoral pierde la tensión en estiramiento que da sentido al ejercicio."
            )
        ),
        ExerciseBrief(
            id: "single-arm-shoulder-press",
            what: LocalizedText(
                fr: "Le développé épaules à l'haltère, assis, un bras. Le dossier remplace le gainage que l'autre côté assurait, ce qui laisse l'épaule travailler seule.",
                en: "The seated dumbbell shoulder press, one arm. The backrest replaces the bracing the other side used to provide, which lets the shoulder work on its own.",
                es: "El press de hombros con mancuerna, sentado, a un brazo. El respaldo sustituye la estabilización que daba el otro lado, y deja al hombro trabajar solo."
            ),
            setup: LocalizedText(
                fr: "Dossier presque vertical, dos plaqué. L'autre main tient le bord du banc : c'est elle qui empêche le buste de s'incliner du côté opposé pour aider en fin de poussée.",
                en: "Backrest almost upright, back flat against it. The other hand holds the edge of the bench: it is what stops the trunk leaning away to help at the top of the press.",
                es: "Respaldo casi vertical, espalda pegada. La otra mano sujeta el borde del banco: impide que el tronco se incline al lado contrario para ayudar al final del empuje."
            ),
            watchOut: LocalizedText(
                fr: "L'inclinaison latérale du buste. Elle passe inaperçue parce qu'elle est lente : tu la reconnais au fait que le bas du dos travaille alors que tu fais un exercice d'épaules.",
                en: "The sideways lean of the trunk. It goes unnoticed because it is slow: you recognise it when your low back is working during a shoulder exercise.",
                es: "La inclinación lateral del tronco. Pasa desapercibida porque es lenta: la reconoces cuando la zona lumbar trabaja en un ejercicio de hombros."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-row",
            what: LocalizedText(
                fr: "Le tirage horizontal à l'élastique, un bras. C'est le mouvement de dos qui demande le moins de matériel et le plus d'attention au trajet du coude.",
                en: "The horizontal band row, one arm. It is the back movement that needs the least equipment and the most attention to where the elbow travels.",
                es: "El remo horizontal con banda, a un brazo. Es el movimiento de espalda que menos material exige y más atención pide al recorrido del codo."
            ),
            setup: LocalizedText(
                fr: "Ancre l'élastique à hauteur de nombril, face à toi. Tire le coude vers la hanche du même côté, jamais la main vers l'épaule : le dorsal travaille sur le trajet du coude.",
                en: "Anchor the band at navel height, in front of you. Drive the elbow to the hip on the same side, never the hand to the shoulder: the lat works along the elbow's path.",
                es: "Ancla la banda a la altura del ombligo, frente a ti. Lleva el codo a la cadera del mismo lado, nunca la mano al hombro: el dorsal trabaja en el recorrido del codo."
            ),
            watchOut: LocalizedText(
                fr: "L'épaule qui monte vers l'oreille en fin de tirage. Le trapèze prend alors le travail que le dorsal devait faire, et tu ressens la fatigue dans la nuque au lieu du dos.",
                en: "The shoulder rising toward the ear at the end of the pull. The trap takes the work the lat should be doing, and you feel it in your neck instead of your back.",
                es: "El hombro subiendo hacia la oreja al final del tirón. El trapecio se lleva el trabajo del dorsal, y notas el cansancio en el cuello en vez de en la espalda."
            )
        ),
        ExerciseBrief(
            id: "single-arm-reverse-fly",
            what: LocalizedText(
                fr: "L'oiseau à la poulie, un bras. Il vise les deltoïdes postérieurs, la partie de l'épaule que tous les mouvements de poussée laissent en arrière.",
                en: "The cable reverse fly, one arm. It targets the rear delts, the part of the shoulder every pressing movement leaves behind.",
                es: "El pájaro en polea, a un brazo. Apunta a los deltoides posteriores, la parte del hombro que todo empuje deja atrás."
            ),
            setup: LocalizedText(
                fr: "Poulie basse en diagonale, prise à la main opposée croisée devant toi. Ouvre en arc jusqu'à l'alignement des épaules et pas plus loin : au-delà, c'est l'articulation qui encaisse.",
                en: "Low pulley on a diagonal, handle taken across the body. Open in an arc until the shoulders line up and no further: past that, the joint takes the load.",
                es: "Polea baja en diagonal, agarre cruzado por delante del cuerpo. Abre en arco hasta alinear los hombros y no más: pasado eso, lo encaja la articulación."
            ),
            watchOut: LocalizedText(
                fr: "Hausser l'épaule pour finir le mouvement. C'est le réflexe le plus fréquent ici : si le haut du trapèze chauffe, la charge est trop lourde de deux crans.",
                en: "Shrugging to finish the movement. It is the most common reflex here: if the upper trap heats up, the load is two notches too heavy.",
                es: "Encoger el hombro para terminar el movimiento. Es el reflejo más frecuente aquí: si el trapecio superior se calienta, la carga sobra dos puntos."
            )
        ),
        ExerciseBrief(
            id: "seated-shrug",
            what: LocalizedText(
                fr: "Le haussement d'épaule assis, un côté à la fois. Assis, le buste ne peut pas se balancer pour aider : le trapèze fait le mouvement ou personne ne le fait.",
                en: "The seated shrug, one side at a time. Seated, the trunk cannot swing to help: the trap does the movement or nobody does.",
                es: "El encogimiento sentado, un lado cada vez. Sentado, el tronco no puede balancearse para ayudar: lo hace el trapecio o no lo hace nadie."
            ),
            setup: LocalizedText(
                fr: "Assis au bord du banc, bras pendant à la verticale. Monte l'épaule droit vers l'oreille, tiens une seconde en haut, redescends jusqu'au bout : c'est la descente complète qui étire le muscle.",
                en: "Seated on the edge of the bench, arm hanging vertically. Lift the shoulder straight toward the ear, hold a second at the top, lower all the way: it is the full descent that stretches the muscle.",
                es: "Sentado al borde del banco, brazo colgando en vertical. Sube el hombro recto hacia la oreja, aguanta un segundo arriba y baja del todo: la bajada completa es la que estira el músculo."
            ),
            watchOut: LocalizedText(
                fr: "Rouler l'épaule vers l'arrière en montant. Le trapèze soulève, il ne tourne pas : la rotation ajoute une contrainte à l'articulation sans rien ajouter au muscle.",
                en: "Rolling the shoulder backwards on the way up. The trap lifts, it does not rotate: the rotation adds strain to the joint and nothing to the muscle.",
                es: "Rodar el hombro hacia atrás al subir. El trapecio levanta, no gira: la rotación añade tensión a la articulación y nada al músculo."
            )
        ),
        ExerciseBrief(
            id: "single-arm-triceps-pushdown",
            what: LocalizedText(
                fr: "L'extension à la poulie, un bras. Le triceps est le seul muscle de ce mouvement, à condition que le coude reste où il est.",
                en: "The cable pushdown, one arm. The triceps is the only muscle in this movement, provided the elbow stays where it is.",
                es: "La extensión en polea, a un brazo. El tríceps es el único músculo de este movimiento, siempre que el codo se quede donde está."
            ),
            setup: LocalizedText(
                fr: "Poulie haute, coude collé au flanc, buste légèrement penché en avant. L'autre main peut tenir le montant : elle stabilise, elle ne pousse pas.",
                en: "High pulley, elbow pinned to the ribs, trunk leaning slightly forward. The other hand may hold the frame: it stabilises, it does not push.",
                es: "Polea alta, codo pegado al costado, tronco ligeramente inclinado. La otra mano puede sujetar el marco: estabiliza, no empuja."
            ),
            watchOut: LocalizedText(
                fr: "Le coude qui avance en cours de série. Dès qu'il quitte les côtes, l'épaule prend la charge et tu peux descendre beaucoup plus lourd sans que le triceps y soit pour rien.",
                en: "The elbow drifting forward during the set. Once it leaves the ribs, the shoulder takes the load and you can push far heavier with the triceps doing none of it.",
                es: "El codo adelantándose durante la serie. En cuanto deja las costillas, el hombro asume la carga y puedes bajar mucho más peso sin que el tríceps intervenga."
            )
        ),
        ExerciseBrief(
            id: "wheelchair-press-up",
            what: LocalizedText(
                fr: "La poussée sur les mains courantes ou les accoudoirs, bassin décollé du siège. C'est du triceps, et c'est aussi le geste qui soulage les points d'appui.",
                en: "The press-up on the rims or armrests, hips lifted off the seat. It is triceps work, and it is also the move that unloads the pressure points.",
                es: "La elevación sobre los aros o los reposabrazos, cadera despegada del asiento. Es trabajo de tríceps, y también el gesto que alivia los puntos de apoyo."
            ),
            setup: LocalizedText(
                fr: "Mains bien à plat, épaules basses et éloignées des oreilles avant de pousser. Monte jusqu'à décoller franchement, tiens deux secondes, redescends sans t'écraser sur le siège.",
                en: "Hands flat, shoulders down and away from the ears before you push. Rise until you clearly lift off, hold two seconds, lower without dropping onto the seat.",
                es: "Manos bien planas, hombros bajos y lejos de las orejas antes de empujar. Sube hasta despegar claramente, aguanta dos segundos y baja sin dejarte caer."
            ),
            watchOut: LocalizedText(
                fr: "Laisser les épaules remonter vers les oreilles pendant la poussée. C'est ce qui coince l'articulation, et c'est l'usure d'épaule la plus courante chez qui pousse un fauteuil toute la journée.",
                en: "Letting the shoulders ride up toward the ears during the push. That is what pinches the joint, and it is the most common shoulder wear for anyone pushing a chair all day.",
                es: "Dejar que los hombros suban hacia las orejas al empujar. Eso es lo que pinza la articulación, y es el desgaste de hombro más común en quien impulsa una silla todo el día."
            )
        ),
        ExerciseBrief(
            id: "single-leg-curl",
            what: LocalizedText(
                fr: "Le leg curl mené par une seule jambe. Les ischio-jambiers sont le muscle que les mouvements de jambe unilatéraux oublient le plus souvent : celui-ci ne fait que ça.",
                en: "The leg curl driven by one leg. The hamstrings are the muscle single-leg work forgets most often: this one does nothing else.",
                es: "El curl femoral llevado por una sola pierna. Los isquiotibiales son el músculo que más olvida el trabajo unilateral: este solo hace eso."
            ),
            setup: LocalizedText(
                fr: "Règle l'axe de la machine sur ton genou, pas au jugé, et cale le rouleau juste au-dessus du talon. Bassin plaqué contre le coussin du début à la fin.",
                en: "Line the machine's axis up with your knee rather than guessing, and set the roller just above the heel. Hips flat on the pad from start to finish.",
                es: "Alinea el eje de la máquina con tu rodilla, no a ojo, y coloca el rodillo justo encima del talón. Cadera pegada al asiento de principio a fin."
            ),
            watchOut: LocalizedText(
                fr: "Le bassin qui se soulève en fin de flexion. Il ajoute de l'amplitude sur le papier et met le bas du dos au travail : si les fesses décollent, enlève une plaque.",
                en: "The hips lifting at the end of the curl. It adds range on paper and puts the low back to work: if the hips come up, take a plate off.",
                es: "La cadera levantándose al final de la flexión. Añade recorrido aparente y pone a trabajar la lumbar: si el glúteo despega, quita un disco."
            )
        ),
        ExerciseBrief(
            id: "single-leg-extension",
            what: LocalizedText(
                fr: "L'extension de genou à la machine, une jambe. C'est le seul mouvement qui charge le quadriceps sans rien demander à l'équilibre ni à l'autre jambe.",
                en: "The machine knee extension, one leg. It is the only movement that loads the quad while asking nothing of your balance or of the other leg.",
                es: "La extensión de rodilla en máquina, a una pierna. Es el único movimiento que carga el cuádriceps sin pedir nada al equilibrio ni a la otra pierna."
            ),
            setup: LocalizedText(
                fr: "Dossier réglé pour que le creux du genou touche le bord du siège. Tends complètement et tiens une seconde en haut : c'est la fin de course qui fait le quadriceps, pas le début.",
                en: "Set the backrest so the back of the knee meets the edge of the seat. Extend fully and hold a second at the top: the end of the range builds the quad, not the start.",
                es: "Ajusta el respaldo para que el hueco de la rodilla toque el borde del asiento. Extiende del todo y aguanta un segundo arriba: el final del recorrido construye el cuádriceps, no el inicio."
            ),
            watchOut: LocalizedText(
                fr: "Lancer la jambe et laisser retomber. La descente freinée vaut plus que la montée : lâchée, elle rend le mouvement inutile et cogne l'articulation en fin de course.",
                en: "Throwing the leg up and letting it drop. The controlled descent is worth more than the lift: dropped, it makes the movement useless and bangs the joint at the bottom.",
                es: "Lanzar la pierna y dejarla caer. La bajada frenada vale más que la subida: soltada, hace inútil el movimiento y golpea la articulación al final."
            )
        ),
        ExerciseBrief(
            id: "single-leg-seated-calf-raise",
            what: LocalizedText(
                fr: "Le mollet assis, une jambe. Assis, c'est le soléaire qui travaille — la partie profonde du mollet, celle qui tient la marche et qu'aucun mouvement debout ne cible aussi bien.",
                en: "The seated calf raise, one leg. Seated, the soleus does the work — the deep part of the calf, the one that carries walking and that no standing movement targets as well.",
                es: "El gemelo sentado, a una pierna. Sentado trabaja el sóleo, la parte profunda de la pantorrilla, la que sostiene la marcha y que ningún movimiento de pie trabaja igual."
            ),
            setup: LocalizedText(
                fr: "Avant du pied sur la marche, talon dans le vide. Descends jusqu'à l'étirement complet avant de remonter le plus haut possible : sur ce muscle, la moitié d'amplitude ne donne rien.",
                en: "Ball of the foot on the step, heel hanging free. Drop to a full stretch before rising as high as you can: on this muscle, half a range gives nothing.",
                es: "Punta del pie en el escalón, talón al aire. Baja hasta el estiramiento completo antes de subir lo más alto posible: en este músculo, medio recorrido no da nada."
            ),
            watchOut: LocalizedText(
                fr: "Rebondir en bas pour enchaîner. Le tendon renvoie l'énergie et le muscle ne fait rien : marque un temps d'arrêt en position basse, la série devient deux fois plus dure à charge égale.",
                en: "Bouncing at the bottom to link the reps. The tendon returns the energy and the muscle does nothing: pause at the bottom and the set becomes twice as hard at the same load.",
                es: "Rebotar abajo para encadenar. El tendón devuelve la energía y el músculo no hace nada: haz una pausa abajo y la serie se vuelve el doble de dura con el mismo peso."
            )
        ),
        ExerciseBrief(
            id: "seated-band-rotation",
            what: LocalizedText(
                fr: "La rotation du buste contre un élastique, assis. C'est du gainage en rotation, la seule forme de gainage qui ne demande pas de descendre au sol.",
                en: "The seated trunk rotation against a band. It is rotational core work, the only kind of core work that does not ask you to get down to the floor.",
                es: "La rotación de tronco contra una banda, sentado. Es trabajo de core en rotación, la única forma que no exige bajar al suelo."
            ),
            setup: LocalizedText(
                fr: "Élastique ancré sur le côté, à hauteur de poitrine, mains jointes devant le sternum. Tourne les côtes, pas les bras : les mains restent devant le sternum tout du long.",
                en: "Band anchored to the side at chest height, hands together in front of the sternum. Rotate the ribs, not the arms: the hands stay in front of the sternum throughout.",
                es: "Banda anclada al lado, a la altura del pecho, manos juntas frente al esternón. Gira las costillas, no los brazos: las manos permanecen frente al esternón."
            ),
            watchOut: LocalizedText(
                fr: "Tirer avec les bras en gardant le buste fixe. Le mouvement paraît identique et ne travaille plus rien : si les épaules bougent plus que les côtes, ralentis jusqu'à sentir la différence.",
                en: "Pulling with the arms while the trunk stays put. It looks the same and trains nothing: if the shoulders move more than the ribs, slow down until you feel the difference.",
                es: "Tirar con los brazos manteniendo el tronco fijo. Parece igual y no entrena nada: si los hombros se mueven más que las costillas, ve despacio hasta notar la diferencia."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-high-row",
            what: LocalizedText(
                fr: "Le tirage élastique avec le coude haut. Il vise le dos en épaisseur, celui qui tient la posture assise, là où le tirage classique vise la largeur.",
                en: "The band row with a high elbow. It targets back thickness, the part that holds seated posture, where the ordinary row targets width.",
                es: "El remo con banda y codo alto. Apunta al grosor de la espalda, el que sostiene la postura sentada, donde el remo clásico busca anchura."
            ),
            setup: LocalizedText(
                fr: "Ancre l'élastique au-dessus de ta tête et tire le coude vers l'arrière à hauteur d'épaule. Serre l'omoplate vers la colonne en fin de course et tiens-la une seconde.",
                en: "Anchor the band above your head and pull the elbow back at shoulder height. Squeeze the shoulder blade toward the spine at the end and hold it a second.",
                es: "Ancla la banda por encima de tu cabeza y lleva el codo atrás a la altura del hombro. Aprieta la escápula hacia la columna al final y aguanta un segundo."
            ),
            watchOut: LocalizedText(
                fr: "Tirer avec la main au lieu du coude. Le trajet paraît le même et ce sont les biceps qui font le travail : si l'avant-bras brûle avant le dos, c'est ça.",
                en: "Pulling with the hand instead of the elbow. The path looks the same and the biceps does the job: if the forearm burns before the back, that is it.",
                es: "Tirar con la mano en vez del codo. El recorrido parece igual y trabaja el bíceps: si el antebrazo arde antes que la espalda, es eso."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-shrug",
            what: LocalizedText(
                fr: "Le haussement d'épaule sur un élastique, un côté. La résistance croît vers le haut, donc là où le trapèze est le plus fort — l'inverse d'un haltère.",
                en: "The band shrug, one side. The resistance grows toward the top, exactly where the trap is strongest — the opposite of a dumbbell.",
                es: "El encogimiento con banda, un lado. La resistencia crece arriba, justo donde el trapecio es más fuerte, al revés que una mancuerna."
            ),
            setup: LocalizedText(
                fr: "Debout sur l'élastique, poignée à la main, bras tendu. Monte l'épaule droit vers l'oreille et redescends complètement : la longueur d'élastique règle la charge mieux qu'aucun choix de poids.",
                en: "Standing on the band, handle in hand, arm straight. Lift the shoulder straight toward the ear and lower all the way: the band length sets the load better than any choice of weight.",
                es: "De pie sobre la banda, agarre en la mano, brazo estirado. Sube el hombro recto hacia la oreja y baja del todo: la longitud de la banda ajusta la carga mejor que cualquier peso."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher du côté opposé pour gagner de la hauteur. Le trapèze ne monte pas plus haut, c'est le buste qui descend : garde les deux hanches à la même hauteur.",
                en: "Leaning away to gain height. The trap does not rise higher, the trunk drops: keep both hips at the same height.",
                es: "Inclinarse al lado contrario para ganar altura. El trapecio no sube más, baja el tronco: mantén ambas caderas a la misma altura."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-overhead-press",
            what: LocalizedText(
                fr: "Le développé au-dessus de la tête avec un élastique, un bras. C'est le mouvement d'épaule le plus complet qui tienne dans un sac.",
                en: "The overhead press with a band, one arm. It is the most complete shoulder movement that fits in a bag.",
                es: "El press por encima de la cabeza con banda, a un brazo. Es el movimiento de hombro más completo que cabe en una bolsa."
            ),
            setup: LocalizedText(
                fr: "L'élastique passe sous le pied, ou sous la roue freinée. Pousse vers le plafond en gardant les côtes basses : si le dos se cambre, l'élastique est trop dur ou trop court.",
                en: "The band runs under the foot, or under a locked wheel. Press to the ceiling with the ribs down: if the back arches, the band is too strong or too short.",
                es: "La banda pasa bajo el pie, o bajo la rueda frenada. Empuja hacia el techo con las costillas bajas: si la espalda se arquea, la banda es dura o corta de más."
            ),
            watchOut: LocalizedText(
                fr: "Cambrer le bas du dos pour finir la poussée. C'est le raccourci le plus courant du développé au-dessus de la tête, et il transforme un exercice d'épaule en compression lombaire.",
                en: "Arching the low back to finish the press. It is the most common shortcut in overhead pressing, and it turns a shoulder exercise into low-back compression.",
                es: "Arquear la lumbar para terminar el empuje. Es el atajo más común del press por encima de la cabeza y convierte un ejercicio de hombro en compresión lumbar."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-lateral-raise",
            what: LocalizedText(
                fr: "L'élévation latérale à l'élastique. Le deltoïde moyen est ce qui donne la largeur d'épaule, et il ne travaille que sur ce trajet-là.",
                en: "The band lateral raise. The middle delt is what gives shoulder width, and it only works along this one path.",
                es: "La elevación lateral con banda. El deltoides medio es lo que da anchura de hombro, y solo trabaja en ese recorrido."
            ),
            setup: LocalizedText(
                fr: "Debout sur l'élastique, bras le long du corps. Monte de côté jusqu'à l'horizontale, coude très légèrement fléchi, main jamais plus haute que l'épaule.",
                en: "Standing on the band, arm at your side. Raise out to horizontal, elbow very slightly bent, hand never higher than the shoulder.",
                es: "De pie sobre la banda, brazo al costado. Sube de lado hasta la horizontal, codo apenas flexionado, mano nunca por encima del hombro."
            ),
            watchOut: LocalizedText(
                fr: "Monter plus haut que l'épaule. Au-delà de l'horizontale, c'est le trapèze qui prend le relais : le mouvement paraît plus ample et le deltoïde a déjà fini son travail.",
                en: "Going higher than the shoulder. Past horizontal the trap takes over: the movement looks bigger and the delt has already finished its job.",
                es: "Subir por encima del hombro. Pasada la horizontal, el trapecio toma el relevo: el movimiento parece mayor y el deltoides ya ha terminado."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-reverse-fly",
            what: LocalizedText(
                fr: "L'oiseau à l'élastique, un bras. C'est le contrepoids direct de tout ce qui pousse, et le premier mouvement qui manque quand on s'entraîne à la maison.",
                en: "The band reverse fly, one arm. It is the direct counterweight to everything that presses, and the first movement missing when you train at home.",
                es: "El pájaro con banda, a un brazo. Es el contrapeso directo de todo lo que empuja, y el primero que falta cuando se entrena en casa."
            ),
            setup: LocalizedText(
                fr: "Élastique ancré devant toi à hauteur d'épaule, bras tendu. Ouvre en arc vers l'extérieur en pensant à écarter la main du sternum, pas à tirer vers l'arrière.",
                en: "Band anchored in front at shoulder height, arm straight. Open in an outward arc thinking about taking the hand away from the sternum, not pulling backwards.",
                es: "Banda anclada delante a la altura del hombro, brazo estirado. Abre en arco hacia fuera pensando en alejar la mano del esternón, no en tirar hacia atrás."
            ),
            watchOut: LocalizedText(
                fr: "Plier le coude pour aller plus loin. Le mouvement devient un tirage, le dorsal prend le travail, et le deltoïde postérieur — le seul muscle visé — ne voit rien passer.",
                en: "Bending the elbow to reach further. It becomes a row, the lat takes over, and the rear delt — the only muscle aimed at — sees nothing.",
                es: "Doblar el codo para llegar más lejos. Se convierte en un remo, el dorsal se lleva el trabajo y el deltoides posterior, único objetivo, no ve nada."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-curl",
            what: LocalizedText(
                fr: "Le curl à l'élastique. La résistance est maximale en haut, là où le biceps est le plus court : c'est l'inverse d'un haltère, et ça change la sensation.",
                en: "The band curl. Resistance peaks at the top, where the biceps is shortest: the opposite of a dumbbell, and it changes the feel.",
                es: "El curl con banda. La resistencia es máxima arriba, donde el bíceps está más corto: al revés que una mancuerna, y cambia la sensación."
            ),
            setup: LocalizedText(
                fr: "Debout sur l'élastique, coude fixé contre les côtes. Monte jusqu'en haut, tiens la contraction une seconde, et surtout ralentis la descente : c'est là que l'élastique se laisse le plus voler le travail.",
                en: "Standing on the band, elbow pinned to the ribs. Curl to the top, hold the squeeze a second, and above all slow the way down: that is where a band most easily steals the work.",
                es: "De pie sobre la banda, codo fijo en las costillas. Sube hasta arriba, aguanta un segundo y sobre todo frena la bajada: ahí es donde la banda te roba más trabajo."
            ),
            watchOut: LocalizedText(
                fr: "Laisser l'élastique ramener la main sans résister. La moitié du gain d'un curl vient de la descente freinée : lâchée, la série ne compte qu'à moitié.",
                en: "Letting the band pull the hand back without resisting. Half the gain of a curl comes from the controlled descent: dropped, the set counts for half.",
                es: "Dejar que la banda devuelva la mano sin resistir. La mitad del beneficio del curl viene de la bajada frenada: soltada, la serie cuenta a medias."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-overhead-extension",
            what: LocalizedText(
                fr: "L'extension nuque à l'élastique. Bras au-dessus de la tête, la longue portion du triceps est étirée, et c'est la seule position où elle travaille en entier.",
                en: "The overhead band extension. With the arm above the head the long head of the triceps is stretched, and it is the only position where it works fully.",
                es: "La extensión tras nuca con banda. Con el brazo por encima de la cabeza, la porción larga del tríceps se estira, y es la única posición donde trabaja entera."
            ),
            setup: LocalizedText(
                fr: "Élastique ancré bas derrière toi, coude pointé vers le plafond et immobile. Seul l'avant-bras bouge, sur un arc court : c'est un petit mouvement qui fatigue vite.",
                en: "Band anchored low behind you, elbow pointing to the ceiling and still. Only the forearm moves, over a short arc: it is a small movement that tires quickly.",
                es: "Banda anclada abajo detrás de ti, codo apuntando al techo e inmóvil. Solo se mueve el antebrazo, en un arco corto: es un movimiento pequeño que cansa rápido."
            ),
            watchOut: LocalizedText(
                fr: "Le coude qui s'ouvre vers l'extérieur au fil des répétitions. Il soulage le triceps sans que tu t'en aperçoives : si le mouvement devient facile en fin de série, regarde ton coude.",
                en: "The elbow flaring outward as the reps go on. It relieves the triceps without you noticing: if the movement gets easier late in the set, look at your elbow.",
                es: "El codo abriéndose hacia fuera con las repeticiones. Alivia al tríceps sin que lo notes: si el movimiento se vuelve fácil al final de la serie, mira el codo."
            )
        ),
        ExerciseBrief(
            id: "single-arm-band-wrist-curl",
            what: LocalizedText(
                fr: "La flexion de poignet à l'élastique. L'avant-bras est ce qui lâche en premier sur presque tous les tirages : ici il est seul et ne peut plus se cacher.",
                en: "The band wrist curl. The forearm is what gives out first on almost every pull: here it is alone and can no longer hide.",
                es: "La flexión de muñeca con banda. El antebrazo es lo primero que falla en casi todos los tirones: aquí está solo y ya no puede esconderse."
            ),
            setup: LocalizedText(
                fr: "Avant-bras posé sur la cuisse, paume vers le haut, élastique sous le pied. Laisse la main descendre jusqu'au bout des doigts, puis remonte en fermant complètement.",
                en: "Forearm on the thigh, palm up, band under the foot. Let the hand roll down to the fingertips, then curl back up closing fully.",
                es: "Antebrazo sobre el muslo, palma hacia arriba, banda bajo el pie. Deja que la mano baje hasta las yemas y sube cerrando del todo."
            ),
            watchOut: LocalizedText(
                fr: "Décoller l'avant-bras de la cuisse pour aider. Le coude prend alors une part du mouvement, et l'avant-bras — tout l'objet de l'exercice — travaille sur une amplitude réduite.",
                en: "Lifting the forearm off the thigh to help. The elbow then takes part of the movement, and the forearm — the whole point — works over a shortened range.",
                es: "Despegar el antebrazo del muslo para ayudar. El codo se lleva parte del movimiento y el antebrazo, todo el objetivo, trabaja en un recorrido reducido."
            )
        ),
        ExerciseBrief(
            id: "single-leg-sit-to-stand",
            what: LocalizedText(
                fr: "Se lever d'une chaise sur une seule jambe. C'est le mouvement de quadriceps le plus utile qui existe, parce que c'est exactement ce qu'on fait vingt fois par jour.",
                en: "Standing up from a chair on one leg. It is the most useful quad movement there is, because it is exactly what you do twenty times a day.",
                es: "Levantarse de una silla con una sola pierna. Es el movimiento de cuádriceps más útil que existe, porque es justo lo que se hace veinte veces al día."
            ),
            setup: LocalizedText(
                fr: "Assis au bord, une main sur un appui stable, l'autre jambe tendue devant. La hauteur de la chaise est le réglage de charge : plus haute si c'est trop dur, plus basse si c'est trop simple.",
                en: "Seated on the edge, one hand on a stable support, the other leg out in front. The chair height is the load setting: higher if it is too hard, lower if too easy.",
                es: "Sentado al borde, una mano en un apoyo estable, la otra pierna estirada al frente. La altura de la silla es el ajuste de carga: más alta si cuesta, más baja si sobra."
            ),
            watchOut: LocalizedText(
                fr: "S'aider de la main d'appui pour tirer. Elle est là pour l'équilibre, pas pour la force : si le bras se contracte, remonte la chaise plutôt que de tricher.",
                en: "Pulling with the support hand. It is there for balance, not for force: if the arm strains, raise the chair rather than cheat.",
                es: "Ayudarse con la mano de apoyo para tirar. Está para el equilibrio, no para la fuerza: si el brazo se tensa, sube la silla en vez de hacer trampa."
            )
        ),
        ExerciseBrief(
            id: "single-leg-band-curl",
            what: LocalizedText(
                fr: "La flexion de jambe à l'élastique, debout ou assis. Elle remplace le leg curl quand il n'y a pas de machine, et travaille le muscle qui protège le genou.",
                en: "The band leg curl, standing or seated. It replaces the machine curl when there is none, and works the muscle that protects the knee.",
                es: "El curl femoral con banda, de pie o sentado. Sustituye a la máquina cuando no la hay y trabaja el músculo que protege la rodilla."
            ),
            setup: LocalizedText(
                fr: "Élastique en boucle autour de la cheville, ancré devant toi au ras du sol. Ramène le talon vers la fesse en gardant la cuisse strictement immobile.",
                en: "Band looped around the ankle, anchored in front of you at floor level. Bring the heel toward the glute keeping the thigh strictly still.",
                es: "Banda en el tobillo, anclada delante a ras de suelo. Lleva el talón al glúteo manteniendo el muslo completamente quieto."
            ),
            watchOut: LocalizedText(
                fr: "La cuisse qui avance pendant la flexion. Elle raccourcit le trajet du talon et fait travailler la hanche à la place : si le genou se déplace, la charge est trop forte.",
                en: "The thigh travelling forward during the curl. It shortens the heel's path and puts the hip to work instead: if the knee moves, the band is too strong.",
                es: "El muslo adelantándose durante la flexión. Acorta el recorrido del talón y hace trabajar la cadera: si la rodilla se desplaza, la banda es demasiado dura."
            )
        ),
        ExerciseBrief(
            id: "seated-single-leg-hip-thrust",
            what: LocalizedText(
                fr: "Le pont fessier à une jambe, épaules posées sur un canapé. Le fessier est le muscle le plus fort du corps, et c'est le seul mouvement qui le charge sans passer par le sol.",
                en: "The single-leg hip thrust with the shoulders on a sofa. The glute is the strongest muscle in the body, and this is the only movement that loads it without a trip to the floor.",
                es: "El puente de glúteo a una pierna con los omóplatos en un sofá. El glúteo es el músculo más fuerte del cuerpo, y este es el único movimiento que lo carga sin pasar por el suelo."
            ),
            setup: LocalizedText(
                fr: "Omoplates au bord de l'assise, pied à plat sous le genou. Monte jusqu'à ce que le corps forme une ligne des épaules aux genoux, serre une seconde, redescends sans t'asseoir.",
                en: "Shoulder blades on the edge of the seat, foot flat under the knee. Drive up until the body makes a line from shoulders to knees, squeeze a second, lower without sitting down.",
                es: "Omóplatos en el borde del asiento, pie plano bajo la rodilla. Sube hasta que el cuerpo forme una línea de hombros a rodillas, aprieta un segundo y baja sin sentarte."
            ),
            watchOut: LocalizedText(
                fr: "Monter en cambrant le bas du dos au lieu de serrer les fessiers. La hauteur atteinte est la même et le lendemain c'est le dos qui est raide : rentre les côtes avant de pousser.",
                en: "Rising by arching the low back instead of squeezing the glutes. The height is the same and the next day it is your back that is stiff: tuck the ribs before you drive.",
                es: "Subir arqueando la lumbar en lugar de apretar el glúteo. La altura es la misma y al día siguiente la espalda está rígida: mete las costillas antes de empujar."
            )
        ),
        ExerciseBrief(
            id: "supported-single-leg-calf-raise",
            what: LocalizedText(
                fr: "Le mollet debout sur une jambe, la main à l'appui. C'est le gastrocnémien, la partie superficielle, celle qui pousse quand on monte une marche.",
                en: "The standing single-leg calf raise with a hand on a support. This is the gastrocnemius, the surface part, the one that pushes when you climb a step.",
                es: "El gemelo de pie a una pierna con la mano en un apoyo. Es el gastrocnemio, la parte superficial, la que empuja al subir un escalón."
            ),
            setup: LocalizedText(
                fr: "Une main au mur, pied à plat ou avant du pied sur une marche. La main tient l'équilibre et rien d'autre : si tu t'appuies dessus, tu allèges le mollet d'autant.",
                en: "One hand on the wall, foot flat or ball of the foot on a step. The hand holds balance and nothing else: lean on it and you unload the calf by that much.",
                es: "Una mano en la pared, pie plano o punta en un escalón. La mano sostiene el equilibrio y nada más: si te apoyas, alivias al gemelo en esa medida."
            ),
            watchOut: LocalizedText(
                fr: "Plier le genou en montant. Le mollet ne travaille en entier que jambe tendue : genou fléchi, le mouvement devient un demi-mollet assis fait debout.",
                en: "Bending the knee as you rise. The calf only works fully with the leg straight: with a bent knee it becomes a half seated calf raise done standing.",
                es: "Doblar la rodilla al subir. El gemelo solo trabaja entero con la pierna estirada: con la rodilla flexionada se convierte en medio gemelo sentado hecho de pie."
            )
        ),
        ExerciseBrief(
            id: "seated-band-leg-extension",
            what: LocalizedText(
                fr: "L'extension de genou assis contre un élastique. Elle charge le quadriceps sans se lever, sans machine et sans que l'autre jambe intervienne.",
                en: "The seated knee extension against a band. It loads the quad without standing up, without a machine and without the other leg helping.",
                es: "La extensión de rodilla sentado contra una banda. Carga el cuádriceps sin levantarse, sin máquina y sin que la otra pierna intervenga."
            ),
            setup: LocalizedText(
                fr: "Élastique en boucle à la cheville, ancré derrière la chaise au ras du sol. Tends la jambe jusqu'à l'horizontale et tiens deux secondes en haut.",
                en: "Band looped at the ankle, anchored behind the chair at floor level. Straighten the leg to horizontal and hold two seconds at the top.",
                es: "Banda en el tobillo, anclada detrás de la silla a ras de suelo. Estira la pierna hasta la horizontal y aguanta dos segundos arriba."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher en arrière pour finir l'extension. Le buste recule, le genou n'est pas plus tendu, et le bas du dos encaisse une tension qui n'a rien à faire là.",
                en: "Leaning back to finish the extension. The trunk moves, the knee is no straighter, and the low back takes a strain that has no business being there.",
                es: "Echarse atrás para terminar la extensión. El tronco se mueve, la rodilla no se estira más y la lumbar recibe una tensión que no le corresponde."
            )
        ),
        ExerciseBrief(
            id: "seated-band-calf-raise",
            what: LocalizedText(
                fr: "Le mollet assis avec un élastique sur le genou. C'est le soléaire, chargé sans machine et sans avoir à tenir debout.",
                en: "The seated calf raise with a band over the knee. This is the soleus, loaded without a machine and without having to stand.",
                es: "El gemelo sentado con una banda sobre la rodilla. Es el sóleo, cargado sin máquina y sin tener que estar de pie."
            ),
            setup: LocalizedText(
                fr: "Élastique passé sur le dessus du genou, les deux bouts sous l'avant du pied. Monte le talon le plus haut possible, puis redescends jusqu'à ce que le talon touche le sol.",
                en: "Band over the top of the knee, both ends under the ball of the foot. Lift the heel as high as it goes, then lower until the heel touches the floor.",
                es: "Banda sobre la rodilla, ambos extremos bajo la punta del pie. Sube el talón lo más alto posible y baja hasta que toque el suelo."
            ),
            watchOut: LocalizedText(
                fr: "Pousser sur le genou avec la main en même temps que le mollet monte. La charge devient impossible à suivre d'une séance à l'autre : la main appuie, elle n'accompagne pas.",
                en: "Pushing on the knee with your hand as the calf rises. The load becomes impossible to track from session to session: the hand presses, it does not follow.",
                es: "Empujar la rodilla con la mano mientras el gemelo sube. La carga se vuelve imposible de seguir de una sesión a otra: la mano presiona, no acompaña."
            )
        ),
        ExerciseBrief(
            id: "single-arm-incline-push-up",
            what: LocalizedText(
                fr: "La pompe à un bras, mains surélevées. C'est le développé couché de qui n'a rien : la hauteur de l'appui remplace le choix des disques.",
                en: "The one-arm push-up with the hands raised. It is the bench press for people who own nothing: the height of the surface replaces the choice of plates.",
                es: "La flexión a un brazo con las manos elevadas. Es el press de banca de quien no tiene nada: la altura del apoyo sustituye a la elección de discos."
            ),
            setup: LocalizedText(
                fr: "Main au centre de la poitrine sur une table, un plan de travail ou un mur. Plus l'appui est haut, plus c'est léger : commence au mur et descends d'un meuble à chaque fois que quinze répétitions passent.",
                en: "Hand under the centre of the chest on a table, a worktop or a wall. The higher the surface the lighter it is: start at the wall and drop one piece of furniture each time fifteen reps go through.",
                es: "Mano en el centro del pecho sobre una mesa, una encimera o la pared. Cuanto más alto el apoyo, más ligero: empieza en la pared y baja un mueble cada vez que salgan quince repeticiones."
            ),
            watchOut: LocalizedText(
                fr: "Laisser le bassin tourner vers le bras qui pousse. C'est le réflexe naturel et il vide le mouvement : garde les deux hanches face à l'appui, quitte à monter d'un cran.",
                en: "Letting the hips rotate toward the pushing arm. It is the natural reflex and it empties the movement: keep both hips square to the surface, even if you have to go one step higher.",
                es: "Dejar que la cadera gire hacia el brazo que empuja. Es el reflejo natural y vacía el movimiento: mantén ambas caderas de frente, aunque tengas que subir un nivel."
            )
        ),
        ExerciseBrief(
            id: "single-arm-table-row",
            what: LocalizedText(
                fr: "Le tirage horizontal sous une table. C'est l'exact contraire de la pompe, et c'est le seul tirage qui ne demande ni barre, ni élastique, ni machine.",
                en: "The horizontal row under a table. It is the exact opposite of the push-up, and the only pull that needs no bar, no band and no machine.",
                es: "El remo horizontal bajo una mesa. Es lo contrario exacto de la flexión, y el único tirón que no exige barra, banda ni máquina."
            ),
            setup: LocalizedText(
                fr: "Allongé sous une table lourde, une main au bord du plateau, talons au sol. Tire la poitrine vers la table. Genoux pliés pour alléger, jambes tendues pour alourdir.",
                en: "Lying under a heavy table, one hand on the edge, heels on the floor. Pull the chest to the table. Bend the knees to lighten it, straighten the legs to load it.",
                es: "Tumbado bajo una mesa pesada, una mano en el borde, talones en el suelo. Lleva el pecho a la mesa. Rodillas dobladas para aligerar, piernas estiradas para cargar."
            ),
            watchOut: LocalizedText(
                fr: "Le corps qui se tord vers la main qui tire. Vérifie que la hanche libre ne monte pas : si elle monte, tu tires moins de poids que tu ne le crois, et de travers.",
                en: "The body twisting toward the pulling hand. Check the free hip is not rising: if it rises you are pulling less weight than you think, and crookedly.",
                es: "El cuerpo torciéndose hacia la mano que tira. Comprueba que la cadera libre no sube: si sube, estás tirando menos peso del que crees, y torcido."
            )
        ),
        ExerciseBrief(
            id: "single-arm-scapular-push-up",
            what: LocalizedText(
                fr: "Le mouvement le plus court du catalogue : l'omoplate qui s'écarte puis se resserre, bras tendu. Il entretient le trapèze et la mobilité de l'épaule.",
                en: "The shortest movement in the catalogue: the shoulder blade sliding out then back, arm straight. It maintains the trap and shoulder mobility.",
                es: "El movimiento más corto del catálogo: la escápula que se separa y vuelve a juntarse, brazo estirado. Mantiene el trapecio y la movilidad del hombro."
            ),
            setup: LocalizedText(
                fr: "En appui incliné sur une table, bras verrouillé et qui le reste. Laisse la poitrine descendre de deux centimètres en relâchant l'omoplate, puis pousse le sol pour l'écarter.",
                en: "In an incline position on a table, arm locked and staying locked. Let the chest drop two centimetres by releasing the shoulder blade, then push the surface away to spread it.",
                es: "En apoyo inclinado sobre una mesa, brazo bloqueado y que sigue bloqueado. Deja bajar el pecho dos centímetros soltando la escápula y luego empuja para separarla."
            ),
            watchOut: LocalizedText(
                fr: "Plier le coude. Dès qu'il bouge, ce n'est plus une pompe scapulaire mais une pompe ordinaire de très petite amplitude, et l'omoplate ne bouge plus du tout.",
                en: "Bending the elbow. The moment it moves, this stops being a scapular push-up and becomes a very short ordinary one, with the shoulder blade no longer moving at all.",
                es: "Doblar el codo. En cuanto se mueve, deja de ser una flexión escapular y pasa a ser una flexión normal muy corta, con la escápula inmóvil."
            )
        ),
        ExerciseBrief(
            id: "single-arm-table-curl",
            what: LocalizedText(
                fr: "Le curl contre le dessous d'une table. La table ne bouge pas : c'est toi qui décides de la résistance, répétition par répétition.",
                en: "The curl against the underside of a table. The table does not move: you decide the resistance, rep by rep.",
                es: "El curl contra la parte inferior de una mesa. La mesa no se mueve: tú decides la resistencia, repetición a repetición."
            ),
            setup: LocalizedText(
                fr: "Assis, paume tournée vers le haut sous le plateau, coude contre les côtes. Tire comme pour soulever la table, tiens cinq secondes, relâche progressivement.",
                en: "Seated, palm up under the tabletop, elbow against the ribs. Pull as if lifting the table, hold five seconds, release gradually.",
                es: "Sentado, palma hacia arriba bajo el tablero, codo contra las costillas. Tira como si levantaras la mesa, aguanta cinco segundos y suelta poco a poco."
            ),
            watchOut: LocalizedText(
                fr: "Serrer d'un coup puis relâcher d'un coup. La tension doit monter en deux secondes et redescendre en deux : c'est la seule façon de rendre un exercice sans charge mesurable d'une fois sur l'autre.",
                en: "Clamping down and letting go abruptly. Tension should build over two seconds and fade over two: it is the only way to make a load-free exercise comparable between sessions.",
                es: "Apretar de golpe y soltar de golpe. La tensión debe subir en dos segundos y bajar en dos: es la única forma de que un ejercicio sin carga sea comparable entre sesiones."
            )
        ),
        ExerciseBrief(
            id: "single-arm-close-incline-push-up",
            what: LocalizedText(
                fr: "La pompe à un bras, coude serré contre le corps. Le pectoral participe, mais c'est le triceps qui finit la répétition.",
                en: "The one-arm push-up with the elbow tucked. The chest helps, but the triceps finishes the rep.",
                es: "La flexión a un brazo con el codo pegado. El pectoral participa, pero el tríceps termina la repetición."
            ),
            setup: LocalizedText(
                fr: "Même appui que la pompe inclinée, mais le coude frôle les côtes au lieu de s'ouvrir à quarante-cinq degrés. Descends jusqu'à ce que la main touche le sternum.",
                en: "Same surface as the incline push-up, but the elbow brushes the ribs instead of flaring to forty-five degrees. Lower until the hand touches the sternum.",
                es: "Mismo apoyo que la flexión inclinada, pero el codo roza las costillas en vez de abrirse a cuarenta y cinco grados. Baja hasta que la mano toque el esternón."
            ),
            watchOut: LocalizedText(
                fr: "Ouvrir le coude dès que ça devient dur. C'est exactement à ce moment-là que le triceps commence à travailler : monte l'appui plutôt que de laisser le coude s'écarter.",
                en: "Flaring the elbow as soon as it gets hard. That is exactly the moment the triceps starts working: raise the surface instead of letting the elbow drift out.",
                es: "Abrir el codo en cuanto cuesta. Es justo cuando el tríceps empieza a trabajar: sube el apoyo en vez de dejar que el codo se abra."
            )
        ),
        ExerciseBrief(
            id: "single-arm-prone-raise",
            what: LocalizedText(
                fr: "L'élévation bras tendu à plat ventre. Sans aucune charge, la gravité suffit à faire travailler le deltoïde postérieur sur toute sa course.",
                en: "The straight-arm raise lying face down. With no weight at all, gravity is enough to work the rear delt through its full range.",
                es: "La elevación con brazo estirado boca abajo. Sin ninguna carga, la gravedad basta para trabajar el deltoides posterior en todo su recorrido."
            ),
            setup: LocalizedText(
                fr: "À plat ventre sur un lit, épaule au bord, bras pendant dans le vide. Monte en arc jusqu'à l'horizontale, pouce vers le plafond, et tiens une seconde en haut.",
                en: "Face down on a bed, shoulder at the edge, arm hanging free. Raise in an arc to horizontal, thumb up, and hold a second at the top.",
                es: "Boca abajo en una cama, hombro en el borde, brazo colgando. Sube en arco hasta la horizontal, pulgar hacia arriba, y aguanta un segundo."
            ),
            watchOut: LocalizedText(
                fr: "Rouler le buste pour aller plus haut. Le bras monte de dix centimètres de plus et le deltoïde n'y est pour rien : garde la poitrine collée au matelas.",
                en: "Rolling the trunk to go higher. The arm rises ten centimetres more and the delt has nothing to do with it: keep the chest flat on the mattress.",
                es: "Rodar el tronco para subir más. El brazo sube diez centímetros más y el deltoides no tiene nada que ver: mantén el pecho pegado al colchón."
            )
        ),
        ExerciseBrief(
            id: "single-arm-pike-incline-push-up",
            what: LocalizedText(
                fr: "La pompe hanches hautes, un bras. C'est le développé au-dessus de la tête version poids du corps : l'épaule pousse à la verticale.",
                en: "The hips-high push-up, one arm. It is the overhead press in a bodyweight version: the shoulder presses vertically.",
                es: "La flexión con caderas altas, a un brazo. Es el press por encima de la cabeza en versión peso corporal: el hombro empuja en vertical."
            ),
            setup: LocalizedText(
                fr: "Main sur un appui haut, pieds reculés, hanches poussées vers le plafond. La tête descend vers l'appui, pas vers l'avant. Remonte l'appui tant que ce n'est pas tenable.",
                en: "Hand on a high surface, feet back, hips pushed to the ceiling. The head travels down toward the surface, not forward. Raise the surface until it is manageable.",
                es: "Mano en un apoyo alto, pies atrás, caderas hacia el techo. La cabeza baja hacia el apoyo, no hacia delante. Sube el apoyo hasta que sea llevadero."
            ),
            watchOut: LocalizedText(
                fr: "Laisser les hanches redescendre en cours de série. La pompe redevient une pompe ordinaire et l'épaule cesse de pousser à la verticale, sans que rien ne le signale.",
                en: "Letting the hips drop during the set. It turns back into an ordinary push-up and the shoulder stops pressing vertically, with nothing to signal it.",
                es: "Dejar caer las caderas durante la serie. Vuelve a ser una flexión normal y el hombro deja de empujar en vertical, sin que nada lo avise."
            )
        ),
        ExerciseBrief(
            id: "single-hand-towel-squeeze",
            what: LocalizedText(
                fr: "Le serrage de serviette. C'est de la force de préhension, ce qui lâche en premier sur presque tous les tirages, et le premier geste qui revient après une atteinte de la main.",
                en: "The towel squeeze. This is grip strength, what fails first on almost every pull, and the first thing to come back after a hand is affected.",
                es: "El apretón de toalla. Es fuerza de agarre, lo primero que falla en casi todo tirón, y lo primero que vuelve tras una afectación de la mano."
            ),
            setup: LocalizedText(
                fr: "Une serviette roulée dans la main, coude posé. Serre trois secondes en cherchant à faire se toucher les doigts, puis ouvre complètement la main : l'ouverture compte autant que la fermeture.",
                en: "A rolled towel in the hand, elbow resting. Squeeze three seconds trying to make the fingers meet, then open the hand fully: the opening counts as much as the closing.",
                es: "Una toalla enrollada en la mano, codo apoyado. Aprieta tres segundos buscando que los dedos se toquen, y abre la mano del todo: abrir cuenta tanto como cerrar."
            ),
            watchOut: LocalizedText(
                fr: "Oublier l'ouverture. Serrer sans jamais ouvrir en grand renforce une main qui se ferme et rien d'autre, ce qui est exactement le contraire de ce qu'on cherche.",
                en: "Forgetting to open. Squeezing without ever opening wide strengthens a hand that closes and nothing else, which is exactly the opposite of what you want.",
                es: "Olvidar la apertura. Apretar sin abrir del todo refuerza una mano que se cierra y nada más, justo lo contrario de lo que se busca."
            )
        ),
        ExerciseBrief(
            id: "single-leg-hinge-to-chair",
            what: LocalizedText(
                fr: "La charnière de hanche vers une chaise, sur une jambe. Elle apprend à plier par les hanches et non par le dos, ce qui sert bien au-delà de la séance.",
                en: "The single-leg hip hinge to a chair. It teaches you to bend at the hips rather than the back, which serves well beyond the session.",
                es: "La bisagra de cadera hacia una silla, a una pierna. Enseña a doblar por la cadera y no por la espalda, algo que sirve mucho más allá de la sesión."
            ),
            setup: LocalizedText(
                fr: "Une main sur un appui, une chaise juste derrière toi. Pousse les hanches en arrière jusqu'à frôler l'assise sans t'asseoir, dos droit, puis reviens en serrant la fesse.",
                en: "One hand on a support, a chair right behind you. Push the hips back until you graze the seat without sitting, back flat, then return by squeezing the glute.",
                es: "Una mano en un apoyo, una silla justo detrás. Empuja la cadera atrás hasta rozar el asiento sin sentarte, espalda recta, y vuelve apretando el glúteo."
            ),
            watchOut: LocalizedText(
                fr: "Arrondir le dos pour aller plus bas. La profondeur ne vient pas de la colonne : si le bas du dos s'arrondit, tu es déjà allé plus loin que ta hanche ne le permet.",
                en: "Rounding the back to go lower. Depth does not come from the spine: if the low back rounds, you have already gone further than your hip allows.",
                es: "Redondear la espalda para bajar más. La profundidad no viene de la columna: si la lumbar se redondea, ya has ido más lejos de lo que permite tu cadera."
            )
        ),
        ExerciseBrief(
            id: "single-arm-dumbbell-floor-press",
            what: LocalizedText(
                fr: "Le développé haltère au sol. Le sol arrête le coude avant que l'épaule ne parte en arrière, ce qui en fait le développé le plus sûr qui existe.",
                en: "The dumbbell floor press. The floor stops the elbow before the shoulder travels back, which makes it the safest press there is.",
                es: "El press con mancuerna en el suelo. El suelo detiene el codo antes de que el hombro se vaya atrás, lo que lo hace el press más seguro que existe."
            ),
            setup: LocalizedText(
                fr: "Allongé, genoux pliés, coude à quarante-cinq degrés du corps. Descends jusqu'à ce que le triceps touche le sol, marque une pause d'une seconde, puis pousse.",
                en: "Lying down, knees bent, elbow at forty-five degrees from the body. Lower until the triceps touches the floor, pause for a second, then press.",
                es: "Tumbado, rodillas dobladas, codo a cuarenta y cinco grados del cuerpo. Baja hasta que el tríceps toque el suelo, pausa un segundo y empuja."
            ),
            watchOut: LocalizedText(
                fr: "Rebondir sur le sol pour repartir. La pause d'une seconde est tout l'intérêt du mouvement : sans elle, c'est le rebond qui pousse et le pectoral se repose.",
                en: "Bouncing off the floor to start the next rep. The one-second pause is the whole point: without it the bounce does the pressing and the chest rests.",
                es: "Rebotar en el suelo para volver a subir. La pausa de un segundo es todo el sentido del ejercicio: sin ella empuja el rebote y el pectoral descansa."
            )
        ),
        ExerciseBrief(
            id: "supported-single-arm-dumbbell-row",
            what: LocalizedText(
                fr: "Le tirage haltère un bras, l'autre main en appui. C'est le mouvement de dos le plus rentable quand on n'a qu'un haltère et une chaise.",
                en: "The one-arm dumbbell row with the other hand supported. It is the most productive back movement when all you have is a dumbbell and a chair.",
                es: "El remo con mancuerna a un brazo con la otra mano apoyada. Es el movimiento de espalda más rentable cuando solo hay una mancuerna y una silla."
            ),
            setup: LocalizedText(
                fr: "L'autre main bien à plat sur un dossier, buste penché à quarante-cinq degrés au moins. Tire le coude le long des côtes vers la hanche, sans laisser l'épaule remonter.",
                en: "The other hand flat on a chair back, trunk hinged to at least forty-five degrees. Draw the elbow along the ribs toward the hip, without letting the shoulder ride up.",
                es: "La otra mano plana en un respaldo, tronco inclinado al menos cuarenta y cinco grados. Lleva el codo por las costillas hacia la cadera, sin dejar subir el hombro."
            ),
            watchOut: LocalizedText(
                fr: "Ouvrir les épaules à chaque répétition pour aller plus haut. La rotation du buste ajoute de la hauteur et pas de travail : les deux épaules restent parallèles au sol.",
                en: "Opening the shoulders each rep to reach higher. Trunk rotation adds height and no work: both shoulders stay parallel to the floor.",
                es: "Abrir los hombros en cada repetición para llegar más alto. La rotación del tronco añade altura y ningún trabajo: ambos hombros paralelos al suelo."
            )
        ),
        ExerciseBrief(
            id: "single-arm-dumbbell-high-row",
            what: LocalizedText(
                fr: "Le tirage haltère coude ouvert. Il travaille le dos en épaisseur et les deltoïdes postérieurs, que le tirage classique laisse de côté.",
                en: "The dumbbell row with a flared elbow. It works back thickness and the rear delts, which the classic row leaves out.",
                es: "El remo con mancuerna y codo abierto. Trabaja el grosor de la espalda y los deltoides posteriores, que el remo clásico deja de lado."
            ),
            setup: LocalizedText(
                fr: "Même appui que le tirage classique, mais le coude part vers l'extérieur à hauteur d'épaule. L'haltère monte vers l'aisselle, pas vers la hanche.",
                en: "Same support as the classic row, but the elbow travels out at shoulder height. The dumbbell rises toward the armpit, not the hip.",
                es: "Mismo apoyo que el remo clásico, pero el codo sale hacia fuera a la altura del hombro. La mancuerna sube hacia la axila, no hacia la cadera."
            ),
            watchOut: LocalizedText(
                fr: "Charger comme sur un tirage classique. Le bras de levier est bien plus long ici : la même charge devient trois fois plus dure, et c'est l'épaule qui paie la différence.",
                en: "Loading it like a classic row. The lever is far longer here: the same weight becomes three times harder, and the shoulder pays the difference.",
                es: "Cargar como en un remo clásico. El brazo de palanca es mucho mayor: el mismo peso resulta tres veces más duro, y lo paga el hombro."
            )
        ),
        ExerciseBrief(
            id: "single-arm-dumbbell-reverse-fly",
            what: LocalizedText(
                fr: "L'oiseau à l'haltère, un bras, buste penché. Le plus petit muscle de l'épaule, et celui dont dépend la tenue des épaules en fin de journée.",
                en: "The one-arm bent-over dumbbell reverse fly. The smallest muscle in the shoulder, and the one your shoulder posture depends on by the end of the day.",
                es: "El pájaro con mancuerna a un brazo, tronco inclinado. El músculo más pequeño del hombro, y del que depende la postura al final del día."
            ),
            setup: LocalizedText(
                fr: "Buste penché, autre main sur un appui, haltère pendant sous l'épaule. Ouvre en arc jusqu'à l'horizontale avec un haltère léger : c'est un mouvement qui ne se charge pas.",
                en: "Trunk hinged, other hand on a support, dumbbell hanging under the shoulder. Open in an arc to horizontal with a light dumbbell: this is not a movement to load.",
                es: "Tronco inclinado, la otra mano apoyada, mancuerna colgando bajo el hombro. Abre en arco hasta la horizontal con poco peso: no es un movimiento para cargar."
            ),
            watchOut: LocalizedText(
                fr: "Prendre trop lourd et lancer. Ici plus qu'ailleurs, un haltère lancé ne travaille rien : si tu dois donner un coup pour démarrer, divise le poids par deux.",
                en: "Going too heavy and swinging. Here more than anywhere, a swung dumbbell trains nothing: if you need a jolt to start, halve the weight.",
                es: "Coger demasiado peso y lanzar. Aquí más que en ningún sitio, una mancuerna lanzada no entrena nada: si necesitas un impulso para empezar, reduce el peso a la mitad."
            )
        ),
        ExerciseBrief(
            id: "single-arm-dumbbell-overhead-extension",
            what: LocalizedText(
                fr: "L'extension nuque à l'haltère. Le triceps y travaille en position étirée, ce qu'aucune extension à la poulie basse ne permet.",
                en: "The overhead dumbbell extension. The triceps works in a stretched position, which no low-pulley extension allows.",
                es: "La extensión tras nuca con mancuerna. El tríceps trabaja en posición estirada, algo que ninguna extensión en polea baja permite."
            ),
            setup: LocalizedText(
                fr: "Assis ou debout, coude pointé vers le plafond, l'autre main peut soutenir le coude. L'haltère descend derrière la tête jusqu'à l'étirement, puis remonte sans que le coude bouge.",
                en: "Seated or standing, elbow pointing at the ceiling, the other hand may support the elbow. The dumbbell drops behind the head to a stretch, then rises with the elbow still.",
                es: "Sentado o de pie, codo apuntando al techo, la otra mano puede sostener el codo. La mancuerna baja tras la cabeza hasta el estiramiento y sube sin que el codo se mueva."
            ),
            watchOut: LocalizedText(
                fr: "Descendre plus bas que l'épaule ne le permet. L'étirement est déjà complet quand l'avant-bras touche le biceps : au-delà, c'est l'articulation de l'épaule qui s'ouvre.",
                en: "Going lower than the shoulder allows. The stretch is already complete when the forearm meets the biceps: past that, it is the shoulder joint opening up.",
                es: "Bajar más de lo que permite el hombro. El estiramiento ya es completo cuando el antebrazo toca el bíceps: más allá, se abre la articulación del hombro."
            )
        ),
        ExerciseBrief(
            id: "supported-single-leg-dumbbell-rdl",
            what: LocalizedText(
                fr: "Le soulevé roumain à une jambe, main en appui. Il charge les ischio-jambiers et le fessier ensemble, ce qu'aucun mouvement isolé ne fait.",
                en: "The supported single-leg Romanian deadlift. It loads hamstrings and glute together, which no isolation movement does.",
                es: "El peso muerto rumano a una pierna con apoyo. Carga isquiotibiales y glúteo a la vez, algo que ningún aislamiento consigue."
            ),
            setup: LocalizedText(
                fr: "Une main sur un dossier, haltère dans l'autre, jambe libre qui part en arrière comme un contrepoids. Descends jusqu'à sentir l'étirement derrière la cuisse, pas plus bas.",
                en: "One hand on a chair back, dumbbell in the other, free leg swinging back as a counterweight. Lower until you feel the stretch behind the thigh, no further.",
                es: "Una mano en un respaldo, mancuerna en la otra, pierna libre atrás como contrapeso. Baja hasta notar el estiramiento tras el muslo, no más."
            ),
            watchOut: LocalizedText(
                fr: "Chercher la profondeur au lieu de l'étirement. Le repère est la sensation derrière la cuisse : quand elle disparaît et que le dos s'arrondit, tu es descendu trop bas.",
                en: "Chasing depth instead of the stretch. The marker is the feeling behind the thigh: when it fades and the back rounds, you have gone too low.",
                es: "Buscar profundidad en vez de estiramiento. La referencia es la sensación tras el muslo: cuando desaparece y la espalda se redondea, has bajado demasiado."
            )
        ),
        ExerciseBrief(
            id: "single-arm-kettlebell-press",
            what: LocalizedText(
                fr: "Le développé kettlebell, un bras. La masse pend sous la main au lieu d'être dans l'axe, ce qui oblige tout le buste à tenir pendant que l'épaule pousse.",
                en: "The one-arm kettlebell press. The mass hangs below the hand instead of sitting in line, which forces the whole trunk to hold while the shoulder presses.",
                es: "El press con pesa rusa a un brazo. La masa cuelga bajo la mano en vez de estar en el eje, lo que obliga a todo el tronco a sostener mientras el hombro empuja."
            ),
            setup: LocalizedText(
                fr: "Kettlebell calée contre l'avant-bras, poignet strictement droit, coude devant les côtes. Pousse en vissant légèrement la paume vers l'avant en fin de course.",
                en: "Bell resting against the forearm, wrist strictly straight, elbow in front of the ribs. Press while turning the palm slightly forward at the top.",
                es: "Pesa apoyada en el antebrazo, muñeca completamente recta, codo delante de las costillas. Empuja girando ligeramente la palma hacia delante al final."
            ),
            watchOut: LocalizedText(
                fr: "Laisser le poignet casser vers l'arrière. La kettlebell tire dessus en permanence : poignet plié, c'est l'articulation qui encaisse toute la charge à la place du muscle.",
                en: "Letting the wrist break backwards. The bell pulls on it constantly: with a bent wrist the joint takes the whole load instead of the muscle.",
                es: "Dejar que la muñeca se doble hacia atrás. La pesa tira de ella todo el rato: con la muñeca doblada, la articulación asume toda la carga en lugar del músculo."
            )
        ),
        ExerciseBrief(
            id: "single-arm-kettlebell-row",
            what: LocalizedText(
                fr: "Le tirage kettlebell, un bras. La poignée épaisse fait travailler la préhension en même temps que le dos, ce qu'un haltère ne fait pas.",
                en: "The one-arm kettlebell row. The thick handle trains the grip at the same time as the back, which a dumbbell does not.",
                es: "El remo con pesa rusa a un brazo. El asa gruesa trabaja el agarre a la vez que la espalda, cosa que una mancuerna no hace."
            ),
            setup: LocalizedText(
                fr: "Autre main sur un appui, buste penché, kettlebell pendant librement. Tire le coude vers la hanche en laissant la masse frôler la jambe : c'est le trajet le plus court et le plus fort.",
                en: "Other hand on a support, trunk hinged, bell hanging free. Draw the elbow to the hip letting the mass brush the leg: it is the shortest and strongest path.",
                es: "La otra mano apoyada, tronco inclinado, pesa colgando libre. Lleva el codo a la cadera dejando que la masa roce la pierna: es el recorrido más corto y fuerte."
            ),
            watchOut: LocalizedText(
                fr: "Laisser la kettlebell partir devant en fin de descente. Elle t'entraîne vers l'avant et le dos doit rattraper : garde-la sous l'épaule, jamais devant.",
                en: "Letting the bell swing forward at the bottom. It pulls you forward and the back has to catch you: keep it under the shoulder, never in front.",
                es: "Dejar que la pesa se vaya hacia delante al final. Te arrastra y la espalda tiene que frenarte: mantenla bajo el hombro, nunca delante."
            )
        ),
        ExerciseBrief(
            id: "single-arm-machine-row",
            what: LocalizedText(
                fr: "Le tirage horizontal à la machine, un bras, poitrine contre le coussin. Le coussin fait le travail de gainage que le tirage libre demande au bas du dos.",
                en: "The chest-supported machine row, one arm. The pad does the bracing work that a free row asks of the low back.",
                es: "El remo en máquina con pecho apoyado, a un brazo. La almohadilla hace el trabajo de estabilización que un remo libre pide a la lumbar."
            ),
            setup: LocalizedText(
                fr: "Règle le coussin pour que la poignée arrive à hauteur du nombril bras tendu. Poitrine collée pendant toute la série, coude qui part vers l'arrière et pas vers l'extérieur.",
                en: "Set the pad so the handle reaches navel height with the arm straight. Chest glued to the pad for the whole set, elbow travelling back rather than out.",
                es: "Ajusta la almohadilla para que el agarre llegue a la altura del ombligo con el brazo estirado. Pecho pegado toda la serie, codo hacia atrás y no hacia fuera."
            ),
            watchOut: LocalizedText(
                fr: "Décoller la poitrine du coussin en fin de tirage. C'est le seul moyen de tricher sur cette machine, et il annule précisément ce pour quoi on l'a choisie.",
                en: "Peeling the chest off the pad at the end of the pull. It is the only way to cheat on this machine, and it cancels exactly what you chose it for.",
                es: "Despegar el pecho de la almohadilla al final del tirón. Es la única forma de hacer trampa en esta máquina, y anula justo aquello por lo que se eligió."
            )
        ),
        ExerciseBrief(
            id: "single-arm-machine-shoulder-press",
            what: LocalizedText(
                fr: "Le développé épaules guidé, un bras. La trajectoire est imposée, donc l'épaule pousse sans avoir à se stabiliser — utile quand l'autre côté ne compense pas.",
                en: "The guided shoulder press, one arm. The path is fixed, so the shoulder presses without having to stabilise — useful when the other side does not compensate.",
                es: "El press de hombros guiado, a un brazo. La trayectoria está impuesta, así que el hombro empuja sin tener que estabilizar, útil cuando el otro lado no compensa."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que les poignées partent à hauteur d'oreille, pas plus bas. Dos plaqué au dossier, l'autre main tenant le siège pour empêcher le buste de tourner.",
                en: "Seat set so the handles start at ear height, no lower. Back flat on the pad, the other hand holding the seat to stop the trunk turning.",
                es: "Asiento ajustado para que los agarres empiecen a la altura de la oreja, no más abajo. Espalda pegada al respaldo, la otra mano sujetando el asiento para que el tronco no gire."
            ),
            watchOut: LocalizedText(
                fr: "Décoller le bas du dos du dossier pour finir la poussée. La cambrure ajoute quelques centimètres et transfère la charge à la colonne : garde le creux des reins au contact.",
                en: "Lifting the low back off the pad to finish the press. The arch adds a few centimetres and hands the load to the spine: keep the small of your back in contact.",
                es: "Despegar la lumbar del respaldo para terminar el empuje. El arqueo añade unos centímetros y pasa la carga a la columna: mantén la zona lumbar en contacto."
            )
        ),
        ExerciseBrief(
            id: "single-arm-cable-shrug",
            what: LocalizedText(
                fr: "Le haussement d'épaule à la poulie basse. La poulie tire droit vers le bas quelle que soit la hauteur, donc la tension ne tombe jamais.",
                en: "The low-pulley shrug. The cable pulls straight down at any height, so the tension never drops.",
                es: "El encogimiento en polea baja. La polea tira recto hacia abajo a cualquier altura, así que la tensión no cae nunca."
            ),
            setup: LocalizedText(
                fr: "Debout à côté de la poulie, bras tendu le long du corps. Monte l'épaule vers l'oreille, tiens une seconde, laisse redescendre jusqu'à sentir l'étirement du trapèze.",
                en: "Standing beside the pulley, arm long at your side. Lift the shoulder toward the ear, hold a second, let it lower until you feel the trap stretch.",
                es: "De pie junto a la polea, brazo estirado al costado. Sube el hombro hacia la oreja, aguanta un segundo y baja hasta notar el estiramiento del trapecio."
            ),
            watchOut: LocalizedText(
                fr: "Plier le coude pour aider. Dès que l'avant-bras entre dans le mouvement, c'est un demi-tirage : le bras reste tendu et pendu du début à la fin.",
                en: "Bending the elbow to help. The moment the forearm joins in it becomes a half row: the arm stays straight and hanging from start to finish.",
                es: "Doblar el codo para ayudar. En cuanto el antebrazo entra, es medio remo: el brazo permanece estirado y colgando de principio a fin."
            )
        ),
        ExerciseBrief(
            id: "single-arm-cable-wrist-curl",
            what: LocalizedText(
                fr: "La flexion de poignet à la poulie. La poulie garde une tension constante là où un haltère n'en donne qu'en fin de course.",
                en: "The cable wrist curl. The cable keeps constant tension where a dumbbell only gives it at the top.",
                es: "La flexión de muñeca en polea. La polea mantiene tensión constante donde una mancuerna solo la da al final."
            ),
            setup: LocalizedText(
                fr: "Assis, avant-bras posé sur la cuisse, paume vers le haut, poulie basse devant toi. Laisse la poignée rouler jusqu'au bout des doigts avant de refermer la main.",
                en: "Seated, forearm on the thigh, palm up, low pulley in front. Let the handle roll to the fingertips before closing the hand again.",
                es: "Sentado, antebrazo sobre el muslo, palma arriba, polea baja delante. Deja que el agarre ruede hasta las yemas antes de cerrar la mano."
            ),
            watchOut: LocalizedText(
                fr: "Ne travailler que la moitié haute de l'amplitude. L'ouverture des doigts fait autant pour l'avant-bras que la fermeture, et c'est la partie que tout le monde saute.",
                en: "Only working the top half of the range. Opening the fingers does as much for the forearm as closing them, and it is the part everyone skips.",
                es: "Trabajar solo la mitad alta del recorrido. Abrir los dedos hace tanto por el antebrazo como cerrarlos, y es la parte que todos se saltan."
            )
        ),
        ExerciseBrief(
            id: "single-leg-cable-knee-extension",
            what: LocalizedText(
                fr: "L'extension de genou à la poulie, sangle à la cheville. C'est le leg extension de qui n'a pas la machine, avec le même trajet exactement.",
                en: "The cable knee extension with an ankle strap. It is the leg extension for people without the machine, along exactly the same path.",
                es: "La extensión de rodilla en polea con tobillera. Es la extensión de cuádriceps de quien no tiene la máquina, con el mismo recorrido."
            ),
            setup: LocalizedText(
                fr: "Sangle juste au-dessus de la cheville, poulie basse derrière toi, assis sur un banc. Tends la jambe à l'horizontale et tiens une seconde en haut.",
                en: "Strap just above the ankle, low pulley behind you, seated on a bench. Straighten the leg to horizontal and hold a second at the top.",
                es: "Tobillera justo encima del tobillo, polea baja detrás, sentado en un banco. Estira la pierna hasta la horizontal y aguanta un segundo arriba."
            ),
            watchOut: LocalizedText(
                fr: "Reculer le buste pour finir. Sur poulie, rien ne t'y oblige comme sur une machine : le buste doit rester vertical, seul le genou s'ouvre.",
                en: "Leaning the trunk back to finish. On a cable nothing holds you as a machine would: the trunk stays upright, only the knee opens.",
                es: "Echar el tronco atrás para terminar. En polea nada te sujeta como en una máquina: el tronco sigue vertical, solo se abre la rodilla."
            )
        ),
        ExerciseBrief(
            id: "single-leg-cable-calf-raise",
            what: LocalizedText(
                fr: "Le mollet à la poulie. La charge tire vers le bas en continu, ce qui évite le rebond auquel invite un mollet au poids du corps.",
                en: "The cable calf raise. The load pulls down continuously, which avoids the bounce a bodyweight calf raise invites.",
                es: "El gemelo en polea. La carga tira hacia abajo de forma continua, lo que evita el rebote al que invita un gemelo a peso corporal."
            ),
            setup: LocalizedText(
                fr: "Poignée basse tenue à la main du même côté, une main à l'appui, avant du pied sur une cale. Monte le plus haut possible, redescends jusqu'à l'étirement complet.",
                en: "Low handle held in the hand on the same side, one hand on a support, ball of the foot on a block. Rise as high as you can, lower to a full stretch.",
                es: "Agarre bajo en la mano del mismo lado, una mano en un apoyo, punta del pie en un alza. Sube lo más alto posible y baja hasta el estiramiento completo."
            ),
            watchOut: LocalizedText(
                fr: "Se hisser sur la main d'appui quand ça devient dur. Le mollet monte pareil et travaille moins : si le bras tire, allège la poulie de deux plaques.",
                en: "Hauling on the support hand when it gets hard. The calf rises the same and works less: if the arm pulls, take two plates off.",
                es: "Tirar con la mano de apoyo cuando cuesta. El gemelo sube igual y trabaja menos: si el brazo tira, quita dos discos."
            )
        ),
        ExerciseBrief(
            id: "single-arm-dead-hang",
            what: LocalizedText(
                fr: "La suspension à une main. C'est l'exercice de préhension le plus direct qui existe, et il étire l'épaule en même temps.",
                en: "The one-arm dead hang. It is the most direct grip exercise there is, and it stretches the shoulder at the same time.",
                es: "El colgado a una mano. Es el ejercicio de agarre más directo que existe, y a la vez estira el hombro."
            ),
            setup: LocalizedText(
                fr: "Pieds au sol ou sur un tabouret pour ne prendre qu'une partie du poids, épaule engagée et non relâchée. Compte en secondes, pas en répétitions.",
                en: "Feet on the floor or a stool to take only part of your weight, shoulder engaged rather than slack. Count in seconds, not reps.",
                es: "Pies en el suelo o en un taburete para tomar solo parte del peso, hombro activo y no suelto. Cuenta en segundos, no en repeticiones."
            ),
            watchOut: LocalizedText(
                fr: "Se laisser pendre épaule complètement relâchée. Le poids passe alors dans les ligaments et plus dans le muscle : garde une légère traction de l'omoplate vers le bas.",
                en: "Hanging with the shoulder completely slack. The weight then goes into the ligaments rather than the muscle: keep a slight downward pull of the shoulder blade.",
                es: "Colgarse con el hombro totalmente suelto. El peso pasa a los ligamentos y no al músculo: mantén una ligera tracción de la escápula hacia abajo."
            )
        ),
        ExerciseBrief(
            id: "single-arm-table-high-row",
            what: LocalizedText(
                fr: "Le tirage sous une table, coude ouvert. Il vise le dos en épaisseur, là où le tirage coude serré vise les dorsaux.",
                en: "The table row with a flared elbow. It targets back thickness, where the tucked-elbow row targets the lats.",
                es: "El remo bajo una mesa con codo abierto. Apunta al grosor de la espalda, donde el remo con codo pegado busca los dorsales."
            ),
            setup: LocalizedText(
                fr: "Même position que le tirage sous la table, mais le coude part vers l'extérieur à hauteur d'épaule. Serre l'omoplate en fin de course avant de redescendre.",
                en: "Same position as the table row, but the elbow travels out at shoulder height. Squeeze the shoulder blade at the top before lowering.",
                es: "Misma posición que el remo bajo la mesa, pero el codo sale hacia fuera a la altura del hombro. Aprieta la escápula al final antes de bajar."
            ),
            watchOut: LocalizedText(
                fr: "Monter la poitrine plus haut que l'épaule ne le permet. L'amplitude d'un tirage coude ouvert est courte par nature : la forcer va chercher la rotation dans l'articulation.",
                en: "Bringing the chest higher than the shoulder allows. The range of a flared row is short by nature: forcing it takes the rotation out of the joint.",
                es: "Subir el pecho más de lo que permite el hombro. El recorrido de un remo con codo abierto es corto por naturaleza: forzarlo saca la rotación de la articulación."
            )
        ),
        ExerciseBrief(
            id: "single-arm-machine-pulldown",
            what: LocalizedText(
                fr: "Le tirage vertical à la machine, un bras. Il travaille les dorsaux dans l'axe où ils sont les plus longs, assis et calé.",
                en: "The machine pulldown, one arm. It works the lats along the line where they are longest, seated and braced.",
                es: "El jalón en máquina a un brazo. Trabaja los dorsales en el eje donde son más largos, sentado y sujeto."
            ),
            setup: LocalizedText(
                fr: "Cales bien serrées sur les cuisses, buste presque vertical. Tire le coude vers la hanche du même côté et laisse remonter jusqu'à l'étirement complet de l'épaule.",
                en: "Thigh pads snug, trunk almost upright. Draw the elbow to the hip on the same side and let it rise back to a full shoulder stretch.",
                es: "Almohadillas ajustadas en los muslos, tronco casi vertical. Lleva el codo a la cadera del mismo lado y deja subir hasta el estiramiento completo del hombro."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher en arrière pour arracher la charge. Le buste part de vingt degrés, la charge monte, et le dorsal fait moins de la moitié de ce que le compteur annonce.",
                en: "Leaning back to rip the weight down. The trunk swings twenty degrees, the load goes up, and the lat does less than half of what the stack claims.",
                es: "Echarse atrás para arrancar la carga. El tronco se va veinte grados, el peso sube y el dorsal hace menos de la mitad de lo que marca la placa."
            )
        ),
        ExerciseBrief(
            id: "single-arm-reverse-pec-deck",
            what: LocalizedText(
                fr: "L'oiseau à la machine, un bras. Le coussin de poitrine supprime toute possibilité de tricher avec le buste, ce qui en fait la version la plus propre du mouvement.",
                en: "The machine reverse fly, one arm. The chest pad removes any way of cheating with the trunk, which makes it the cleanest version of the movement.",
                es: "El pájaro en máquina a un brazo. La almohadilla de pecho elimina cualquier trampa con el tronco, lo que lo convierte en la versión más limpia."
            ),
            setup: LocalizedText(
                fr: "Poitrine contre le coussin, poignée à hauteur d'épaule, bras presque tendu. Ouvre jusqu'à ce que le bras soit dans le plan des épaules et pas au-delà.",
                en: "Chest against the pad, handle at shoulder height, arm almost straight. Open until the arm is in the plane of the shoulders and no further.",
                es: "Pecho contra la almohadilla, agarre a la altura del hombro, brazo casi estirado. Abre hasta que el brazo esté en el plano de los hombros y no más."
            ),
            watchOut: LocalizedText(
                fr: "Charger lourd et raccourcir la course. C'est le mouvement où l'amplitude complète vaut plus que la charge : deux plaques de moins et dix centimètres de plus valent mieux.",
                en: "Loading heavy and shortening the range. This is the movement where full range beats load: two plates less and ten centimetres more is the better trade.",
                es: "Cargar mucho y acortar el recorrido. Es el movimiento donde el recorrido completo vale más que la carga: dos discos menos y diez centímetros más es mejor trato."
            )
        ),
        ExerciseBrief(
            id: "single-arm-machine-triceps-extension",
            what: LocalizedText(
                fr: "L'extension triceps guidée, un bras. Le coude est calé par la machine, ce qui règle d'avance le seul problème de cet exercice.",
                en: "The guided triceps extension, one arm. The elbow is set by the machine, which solves in advance the only problem this exercise has.",
                es: "La extensión de tríceps guiada, a un brazo. La máquina fija el codo, lo que resuelve de antemano el único problema de este ejercicio."
            ),
            setup: LocalizedText(
                fr: "Coude bien au creux du coussin, épaule basse. Tends complètement et reviens en freinant : sur une machine, la descente est la seule chose que tu contrôles encore.",
                en: "Elbow deep in the pad, shoulder down. Extend fully and return under control: on a machine, the descent is the only thing you still control.",
                es: "Codo bien encajado en la almohadilla, hombro bajo. Extiende del todo y vuelve frenando: en una máquina, la bajada es lo único que aún controlas."
            ),
            watchOut: LocalizedText(
                fr: "Hausser l'épaule pour pousser plus fort. L'épaule ajoute de la force et retire l'exercice au triceps : si elle monte vers l'oreille, enlève une plaque.",
                en: "Shrugging to push harder. The shoulder adds force and takes the exercise away from the triceps: if it rides toward the ear, take a plate off.",
                es: "Encoger el hombro para empujar más. El hombro añade fuerza y le quita el ejercicio al tríceps: si sube hacia la oreja, quita un disco."
            )
        ),
        ExerciseBrief(
            id: "single-leg-machine-hip-thrust",
            what: LocalizedText(
                fr: "La poussée de hanche guidée, une jambe. C'est le mouvement qui charge le plus le fessier, et la machine évite d'avoir à installer une barre sur le bassin.",
                en: "The guided hip thrust, one leg. It is the movement that loads the glute most, and the machine spares you setting a bar across your hips.",
                es: "El empuje de cadera guiado, a una pierna. Es el movimiento que más carga el glúteo, y la máquina evita colocarse una barra sobre la cadera."
            ),
            setup: LocalizedText(
                fr: "Un pied à plat au centre de la plateforme, tibia vertical en haut du mouvement. Monte jusqu'à l'alignement cuisses-buste, serre une seconde, redescends sans reposer la charge.",
                en: "One foot flat in the centre of the platform, shin vertical at the top. Drive up until thighs and trunk line up, squeeze a second, lower without resting the stack.",
                es: "Un pie plano en el centro de la plataforma, tibia vertical arriba. Sube hasta alinear muslos y tronco, aprieta un segundo y baja sin apoyar la carga."
            ),
            watchOut: LocalizedText(
                fr: "Monter plus haut que l'alignement en cambrant. Le fessier a fini son travail quand le corps est droit : au-delà, c'est le bas du dos qui prend la fin du mouvement.",
                en: "Going past the straight line by arching. The glute has finished when the body is straight: past that, the low back takes the end of the movement.",
                es: "Pasarse de la línea recta arqueando. El glúteo ha terminado cuando el cuerpo está recto: más allá, la lumbar se lleva el final del movimiento."
            )
        ),
        ExerciseBrief(
            id: "seated-single-arm-table-pull",
            what: LocalizedText(
                fr: "Le tirage sur le plateau d'une table, assis. C'est le seul mouvement de dorsaux qui se fait sans se lever, sans matériel et sans passer par le sol.",
                en: "The seated pull on a tabletop. It is the only lat movement done without standing, without equipment and without a trip to the floor.",
                es: "La tracción sobre el tablero de una mesa, sentado. Es el único movimiento de dorsales que se hace sin levantarse, sin material y sin pasar por el suelo."
            ),
            setup: LocalizedText(
                fr: "Table lourde, ou fauteuil freiné et roues bloquées. Main sous le plateau, tire ton buste vers la table en amenant le coude vers la hanche, puis retiens le retour.",
                en: "A heavy table, or the chair braked with the wheels locked. Hand under the top, pull your trunk toward the table bringing the elbow to the hip, then resist the way back.",
                es: "Mesa pesada, o silla frenada con las ruedas bloqueadas. Mano bajo el tablero, lleva el tronco hacia la mesa acercando el codo a la cadera y frena la vuelta."
            ),
            watchOut: LocalizedText(
                fr: "Tirer avec la table qui glisse. Si elle bouge d'un centimètre, la résistance disparaît au moment où le dos allait travailler : choisis un meuble qui ne bouge pas.",
                en: "Pulling on a table that slides. If it moves a centimetre the resistance vanishes just as the back was about to work: pick furniture that does not move.",
                es: "Tirar de una mesa que se desliza. Si se mueve un centímetro, la resistencia desaparece justo cuando la espalda iba a trabajar: elige un mueble que no se mueva."
            )
        ),
        ExerciseBrief(
            id: "seated-single-arm-table-pull-high",
            what: LocalizedText(
                fr: "Le même tirage sur le plateau, coude ouvert vers l'extérieur. Il travaille le dos en épaisseur et les deltoïdes postérieurs, que la version coude bas laisse de côté.",
                en: "The same tabletop pull with the elbow flared out. It works back thickness and the rear delts, which the low-elbow version leaves aside.",
                es: "La misma tracción sobre el tablero, con el codo abierto. Trabaja el grosor de la espalda y los deltoides posteriores, que la versión de codo bajo deja de lado."
            ),
            setup: LocalizedText(
                fr: "Même prise, mais le coude part vers l'extérieur à hauteur d'épaule. Cherche à serrer l'omoplate vers la colonne plutôt qu'à rapprocher le buste de la table.",
                en: "Same grip, but the elbow travels out at shoulder height. Aim to squeeze the shoulder blade toward the spine rather than to bring the trunk to the table.",
                es: "Mismo agarre, pero el codo sale hacia fuera a la altura del hombro. Busca apretar la escápula hacia la columna en vez de acercar el tronco a la mesa."
            ),
            watchOut: LocalizedText(
                fr: "Faire le même mouvement que la version coude bas sans s'en apercevoir. Si le coude descend vers les côtes, tu refais le tirage précédent : la hauteur du coude est tout ce qui les distingue.",
                en: "Doing the same movement as the low-elbow version without noticing. If the elbow drops toward the ribs you are repeating the previous pull: elbow height is all that separates them.",
                es: "Hacer el mismo movimiento que la versión de codo bajo sin darte cuenta. Si el codo baja hacia las costillas, repites el anterior: la altura del codo es lo único que los distingue."
            )
        ),
        ExerciseBrief(
            id: "seated-trunk-lean",
            what: LocalizedText(
                fr: "Le buste qui part en avant et revient, sans les bras. C'est du gainage pour qui ne descend pas au sol, et c'est le contrôle du retour qui compte.",
                en: "The trunk leaning forward and returning, without the arms. It is core work for anyone who does not get down to the floor, and the controlled return is what counts.",
                es: "El tronco que se inclina y vuelve, sin brazos. Es trabajo de core para quien no baja al suelo, y lo que cuenta es el control de la vuelta."
            ),
            setup: LocalizedText(
                fr: "Assis stable, mains sur les cuisses ou croisées. Penche-toi en avant lentement, aussi loin que tu peux revenir, et remonte sans t'aider des bras ni prendre d'élan.",
                en: "Seated stable, hands on the thighs or crossed. Lean forward slowly, only as far as you can come back from, and rise without using the arms or any swing.",
                es: "Sentado estable, manos en los muslos o cruzadas. Inclínate despacio, solo hasta donde puedas volver, y sube sin ayudarte con los brazos ni coger impulso."
            ),
            watchOut: LocalizedText(
                fr: "Aller plus loin que le point de retour. Le repère est simple : la profondeur juste est celle d'où tu remontes sans t'agripper. Un centimètre de plus et l'exercice devient une chute rattrapée.",
                en: "Going past the point of return. The marker is simple: the right depth is the one you rise from without grabbing anything. One centimetre more and it becomes a fall you catch.",
                es: "Ir más allá del punto de retorno. La referencia es simple: la profundidad justa es aquella desde la que subes sin agarrarte. Un centímetro más y es una caída que atrapas."
            )
        ),
        ExerciseBrief(
            id: "seated-single-leg-knee-extension",
            what: LocalizedText(
                fr: "L'extension de genou assis, sans charge. Le poids de la jambe suffit longtemps, et c'est le mouvement le plus accessible pour le quadriceps.",
                en: "The seated knee extension with no load. The weight of the leg is enough for a long while, and it is the most accessible quad movement there is.",
                es: "La extensión de rodilla sentado, sin carga. El peso de la pierna basta mucho tiempo, y es el movimiento de cuádriceps más accesible."
            ),
            setup: LocalizedText(
                fr: "Assis au fond du siège, cuisse posée. Tends la jambe à l'horizontale, tiens deux secondes en serrant le dessus de la cuisse, puis redescends en trois secondes.",
                en: "Seated well back, thigh supported. Straighten the leg to horizontal, hold two seconds squeezing the top of the thigh, then lower over three seconds.",
                es: "Sentado al fondo, muslo apoyado. Estira la pierna hasta la horizontal, aguanta dos segundos apretando la parte alta del muslo y baja en tres segundos."
            ),
            watchOut: LocalizedText(
                fr: "Aller vite pour faire du nombre. Sans charge, la seule variable qui reste est le temps : trente répétitions lancées valent moins que huit tenues deux secondes en haut.",
                en: "Going fast to rack up reps. With no load the only variable left is time: thirty swung reps are worth less than eight held two seconds at the top.",
                es: "Ir rápido para sumar repeticiones. Sin carga, la única variable que queda es el tiempo: treinta repeticiones lanzadas valen menos que ocho aguantadas dos segundos."
            )
        ),
        ExerciseBrief(
            id: "seated-single-leg-heel-raise",
            what: LocalizedText(
                fr: "Le talon levé assis, sans machine. C'est le mollet profond, entretenu avec la seule main posée sur le genou pour ajouter du poids.",
                en: "The seated heel raise with no machine. This is the deep calf, maintained with just a hand on the knee to add load.",
                es: "La elevación de talón sentado, sin máquina. Es el gemelo profundo, mantenido con solo una mano sobre la rodilla para añadir peso."
            ),
            setup: LocalizedText(
                fr: "Pied à plat au sol, genou à angle droit. Monte le talon le plus haut possible en poussant par l'avant du pied, tiens en haut, redescends jusqu'à ce que le talon touche.",
                en: "Foot flat on the floor, knee at a right angle. Lift the heel as high as it goes driving through the ball of the foot, hold at the top, lower until the heel lands.",
                es: "Pie plano en el suelo, rodilla en ángulo recto. Sube el talón lo más alto posible empujando con la punta, aguanta arriba y baja hasta que el talón toque."
            ),
            watchOut: LocalizedText(
                fr: "Enchaîner sans jamais toucher le sol. La descente complète est ce qui étire le muscle : si le talon reste en l'air, la série entretient une contraction et rien de plus.",
                en: "Cycling without ever touching down. The full descent is what stretches the muscle: if the heel stays up, the set maintains a contraction and nothing more.",
                es: "Encadenar sin tocar nunca el suelo. La bajada completa es lo que estira el músculo: si el talón se queda en el aire, la serie mantiene una contracción y nada más."
            )
        ),
        ExerciseBrief(
            id: "seated-single-leg-heel-drag",
            what: LocalizedText(
                fr: "Le talon tiré au sol, assis. La résistance vient du frottement, ce qui en fait le seul travail d'ischio-jambiers possible sans aucun matériel et sans se lever.",
                en: "The seated heel drag. The resistance comes from friction, which makes it the only hamstring work possible with no equipment and without standing.",
                es: "El arrastre de talón sentado. La resistencia viene del rozamiento, lo que lo hace el único trabajo de isquiotibiales posible sin material y sin levantarse."
            ),
            setup: LocalizedText(
                fr: "Jambe tendue devant, talon au sol. Appuie fort vers le bas et tire le talon vers toi sans lever le pied. La force d'appui règle la difficulté à elle seule.",
                en: "Leg straight out front, heel on the floor. Press down hard and drag the heel toward you without lifting the foot. How hard you press sets the difficulty on its own.",
                es: "Pierna estirada al frente, talón en el suelo. Presiona fuerte hacia abajo y arrastra el talón hacia ti sin levantar el pie. La fuerza de presión marca sola la dificultad."
            ),
            watchOut: LocalizedText(
                fr: "Lever le pied pour le ramener plus vite. Sans appui il n'y a plus de résistance du tout : le talon doit racler le sol sur tout le trajet, aller comme retour.",
                en: "Lifting the foot to bring it back faster. With no pressure there is no resistance at all: the heel must scrape the floor the whole way, out and back.",
                es: "Levantar el pie para traerlo más rápido. Sin presión no hay resistencia alguna: el talón debe rozar el suelo todo el recorrido, de ida y de vuelta."
            )
        )
    ]
}
