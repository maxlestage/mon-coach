import Foundation

// Les fiches des machines de salle : poussées, épaules, bras et tronc.
extension ExerciseBriefs {

    static let machinesUpper: [ExerciseBrief] = [
        ExerciseBrief(
            id: "incline-machine-press",
            what: LocalizedText(
                fr: "Le développé incliné sur machine. L'angle vise le haut des pectoraux et la machine tient la trajectoire : on peut aller à l'échec sans partenaire, ce qui est rarement raisonnable avec une barre inclinée.",
                en: "The incline press on a machine. The angle targets the upper chest and the machine holds the path: you can go to failure without a spotter, which is rarely wise under an incline bar.",
                es: "El press inclinado en máquina. El ángulo apunta al pectoral superior y la máquina sostiene la trayectoria: puedes llegar al fallo sin compañero, algo que rara vez es sensato con una barra inclinada."
            ),
            setup: LocalizedText(
                fr: "Règle le siège pour que les poignées partent à hauteur du haut des pectoraux, sous les clavicules. Un cran trop haut et tu fais un développé épaules mal réglé.",
                en: "Set the seat so the handles start at upper-chest height, under the collarbones. One notch too high and you are doing a badly set shoulder press.",
                es: "Ajusta el asiento para que las empuñaduras arranquen a la altura del pectoral superior, bajo las clavículas. Un punto más alto y harás un press de hombros mal ajustado."
            ),
            watchOut: LocalizedText(
                fr: "S'arrêter avant que les mains reviennent au niveau du buste. Sur machine on ne sent pas la perte d'amplitude, et c'est pourtant la moitié basse qui fait grossir le haut des pectoraux.",
                en: "Stopping before the hands come back level with your chest. On a machine you do not feel the lost range, and yet the bottom half is what grows the upper chest.",
                es: "Pararse antes de que las manos vuelvan al nivel del torso. En máquina no se nota la pérdida de recorrido, y sin embargo la mitad baja es la que hace crecer el pectoral superior."
            )
        ),
        ExerciseBrief(
            id: "pec-deck",
            what: LocalizedText(
                fr: "L'écarté sur machine, coudes posés sur des coussins. C'est l'isolation des pectoraux la plus simple à faire correctement : la machine impose l'angle du coude, qu'on ne peut donc pas rater.",
                en: "The fly on a machine, elbows on pads. The easiest chest isolation to do right: the machine sets the elbow angle for you, so you cannot get it wrong.",
                es: "La apertura en máquina, con los codos apoyados en almohadillas. Es el aislamiento de pectoral más fácil de hacer bien: la máquina fija el ángulo del codo, así que no puedes fallarlo."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que les coudes soient à hauteur des épaules, ni au-dessus ni en dessous. Dos plaqué. Ferme jusqu'à ce que les coussins se touchent presque et tiens une seconde.",
                en: "Seat set so the elbows sit at shoulder height, no higher and no lower. Back flat. Close until the pads nearly touch and hold a second.",
                es: "Asiento ajustado para que los codos queden a la altura de los hombros, ni más arriba ni más abajo. Espalda pegada. Cierra hasta que las almohadillas casi se toquen y aguanta un segundo."
            ),
            watchOut: LocalizedText(
                fr: "Ouvrir au maximum parce que la machine le permet. Un étirement extrême sur une machine qui tire les bras en arrière met l'épaule dans sa position la plus fragile : ouvre jusqu'à sentir tirer, pas plus loin.",
                en: "Opening as wide as the machine allows. An extreme stretch on a machine that pulls your arms back puts the shoulder in its most fragile position: open until you feel a stretch, no further.",
                es: "Abrir al máximo porque la máquina lo permite. Un estiramiento extremo en una máquina que tira de los brazos hacia atrás coloca el hombro en su posición más frágil: abre hasta notar el estiramiento, no más."
            )
        ),
        ExerciseBrief(
            id: "low-cable-crossover",
            what: LocalizedText(
                fr: "L'écarté depuis deux poulies basses, mains qui montent et se rejoignent devant la poitrine. La direction du câble charge le haut des pectoraux, ce qu'un écarté classique ne fait pas.",
                en: "The fly from two low pulleys, hands rising to meet in front of the chest. The cable direction loads the upper chest, which an ordinary fly does not.",
                es: "La apertura desde dos poleas bajas, con las manos subiendo hasta juntarse delante del pecho. La dirección del cable carga el pectoral superior, cosa que una apertura normal no hace."
            ),
            setup: LocalizedText(
                fr: "Poulies au plus bas, un pas en avant, buste légèrement penché. Coudes fixes et un peu fléchis. Les mains montent en diagonale jusqu'à hauteur de menton, elles ne se contentent pas de se rejoindre.",
                en: "Pulleys at the bottom, a step forward, torso leaning slightly. Elbows fixed and slightly bent. The hands rise diagonally to chin height — they do not merely meet.",
                es: "Poleas abajo, un paso adelante, torso ligeramente inclinado. Codos fijos y algo flexionados. Las manos suben en diagonal hasta la altura de la barbilla, no solo se juntan."
            ),
            watchOut: LocalizedText(
                fr: "Rester debout entre les poulies sans avancer. Sans ce pas en avant, il n'y a aucune tension en position basse, et l'exercice ne commence qu'à mi-chemin.",
                en: "Standing between the pulleys without stepping forward. Without that step there is no tension at the bottom, and the exercise only starts halfway through.",
                es: "Quedarse de pie entre las poleas sin avanzar. Sin ese paso adelante no hay tensión abajo y el ejercicio solo empieza a media altura."
            )
        ),
        ExerciseBrief(
            id: "smith-incline-press",
            what: LocalizedText(
                fr: "Le développé incliné sur barre guidée. La trajectoire fixe supprime la stabilisation : tu peux charger plus lourd sur le haut des pectoraux qu'avec une barre libre, seul et sans risque.",
                en: "The incline press on a guided bar. The fixed path removes stabilisation: you can load the upper chest heavier than with a free bar, alone and with no risk.",
                es: "El press inclinado en barra guiada. La trayectoria fija elimina la estabilización: puedes cargar el pectoral superior más que con barra libre, solo y sin riesgo."
            ),
            setup: LocalizedText(
                fr: "Banc à trente degrés, placé pour que la barre descende sur le haut de la poitrine, pas sur la gorge. Vérifie la trajectoire à vide : sur une barre guidée, un banc mal placé ne se rattrape pas en cours de série.",
                en: "Bench at thirty degrees, positioned so the bar comes down on the upper chest, not the throat. Check the path unloaded: on a guided bar, a badly placed bench cannot be corrected mid-set.",
                es: "Banco a treinta grados, colocado para que la barra baje sobre la parte alta del pecho, no sobre la garganta. Comprueba la trayectoria en vacío: en barra guiada, un banco mal colocado no se corrige a mitad de serie."
            ),
            watchOut: LocalizedText(
                fr: "Oublier de vérifier les crans de sécurité avant de charger. C'est le seul avantage réel de la barre guidée quand on s'entraîne seul, et c'est celui qu'on oublie systématiquement de régler.",
                en: "Forgetting to set the safety catches before loading. That is the guided bar's one genuine advantage when training alone, and the one thing everyone forgets to adjust.",
                es: "Olvidar comprobar los topes de seguridad antes de cargar. Es la única ventaja real de la barra guiada cuando entrenas solo, y lo que sistemáticamente se olvida ajustar."
            )
        ),
        ExerciseBrief(
            id: "smith-overhead-press",
            what: LocalizedText(
                fr: "Le développé militaire sur barre guidée, assis ou debout. Plus de barre à équilibrer au-dessus de la tête : toute la charge va dans les épaules, et rien dans le gainage.",
                en: "The overhead press on a guided bar, seated or standing. No bar to balance above your head: all the load goes into the shoulders and none into bracing.",
                es: "El press militar en barra guiada, sentado o de pie. Ya no hay barra que equilibrar sobre la cabeza: toda la carga va a los hombros y nada al core."
            ),
            setup: LocalizedText(
                fr: "Place-toi de sorte que la barre descende juste devant le menton, pas sur le nez. Comme elle ne peut pas contourner ta tête, c'est ton placement qui décide si le mouvement est confortable ou impossible.",
                en: "Position yourself so the bar comes down just in front of your chin, not onto your nose. Since it cannot travel around your head, your placement decides whether the movement is comfortable or impossible.",
                es: "Colócate de forma que la barra baje justo delante de la barbilla, no sobre la nariz. Como no puede rodear tu cabeza, tu colocación decide si el movimiento es cómodo o imposible."
            ),
            watchOut: LocalizedText(
                fr: "Compenser en avançant la tête à chaque montée. Le cou finit par payer un exercice d'épaules. Si la barre te gêne, recule le banc de cinq centimètres au lieu de bouger la tête.",
                en: "Compensating by pushing your head forward on every rep. Your neck ends up paying for a shoulder exercise. If the bar is in the way, move the bench five centimetres rather than your head.",
                es: "Compensar adelantando la cabeza en cada subida. El cuello acaba pagando un ejercicio de hombros. Si la barra te estorba, mueve el banco cinco centímetros en vez de la cabeza."
            )
        ),
        ExerciseBrief(
            id: "machine-lateral-raise",
            what: LocalizedText(
                fr: "L'élévation latérale sur machine, coudes contre des coussins. La résistance reste constante sur toute la course, alors qu'avec des haltères elle est nulle en bas et maximale en haut.",
                en: "The lateral raise on a machine, elbows against pads. Resistance stays constant through the whole range, where dumbbells give none at the bottom and most at the top.",
                es: "La elevación lateral en máquina, con los codos contra almohadillas. La resistencia se mantiene constante en todo el recorrido, mientras que con mancuernas es nula abajo y máxima arriba."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que l'axe de rotation de la machine soit au niveau de l'épaule, pas du coude. C'est le réglage que presque personne ne fait, et celui qui décide si le deltoïde travaille ou si le trapèze prend tout.",
                en: "Seat set so the machine's pivot lines up with your shoulder, not your elbow. Almost nobody adjusts this, and it decides whether the delt works or the trap takes over.",
                es: "Asiento ajustado para que el eje de giro de la máquina quede a la altura del hombro, no del codo. Casi nadie hace este ajuste, y es el que decide si trabaja el deltoides o se lo lleva el trapecio."
            ),
            watchOut: LocalizedText(
                fr: "Pousser avec les mains sur les poignées. La machine se pilote avec les coudes contre les coussins : dès que les mains poussent, ce sont les triceps et les trapèzes qui montent la charge.",
                en: "Pushing with your hands on the grips. This machine is driven by the elbows against the pads: the moment the hands push, triceps and traps are lifting the weight.",
                es: "Empujar con las manos en las asas. La máquina se maneja con los codos contra las almohadillas: en cuanto empujan las manos, suben la carga los tríceps y los trapecios."
            )
        ),
        ExerciseBrief(
            id: "reverse-pec-deck",
            what: LocalizedText(
                fr: "L'écarté machine à l'envers, face au dossier. C'est l'isolation de l'arrière d'épaule la plus stable qui soit : rien à stabiliser, donc on peut vraiment sentir le muscle travailler.",
                en: "The pec deck run backwards, facing the pad. The steadiest rear-delt isolation there is: nothing to stabilise, so you can actually feel the muscle work.",
                es: "La máquina de aperturas al revés, de cara al respaldo. Es el aislamiento de deltoides posterior más estable que existe: nada que estabilizar, así que puedes sentir el músculo trabajar."
            ),
            setup: LocalizedText(
                fr: "Poitrine collée au dossier, poignées réglées à hauteur d'épaules. Bras presque tendus. Ouvre jusqu'à l'alignement des bras avec le buste, pas au-delà : plus loin, ce sont les omoplates qui font le travail.",
                en: "Chest against the pad, handles set at shoulder height. Arms nearly straight. Open until the arms line up with your torso, no further: past that the shoulder blades do the work.",
                es: "Pecho pegado al respaldo, agarres a la altura de los hombros. Brazos casi rectos. Abre hasta alinear los brazos con el torso, no más: más allá trabajan las escápulas."
            ),
            watchOut: LocalizedText(
                fr: "Charger comme un rowing. L'arrière d'épaule est un petit muscle : à charge trop lourde, les coudes se plient et l'exercice devient un tirage horizontal médiocre. Léger, lent, et une pause en fin de course.",
                en: "Loading it like a row. The rear delt is a small muscle: too heavy and the elbows bend, turning it into a mediocre horizontal pull. Light, slow, and a pause at the end.",
                es: "Cargarlo como un remo. El deltoides posterior es un músculo pequeño: con demasiado peso los codos se flexionan y se convierte en un remo mediocre. Ligero, lento y con pausa al final."
            )
        ),
        ExerciseBrief(
            id: "assisted-dip",
            what: LocalizedText(
                fr: "Le dip avec un contrepoids. Ça rend accessible dès le premier mois un mouvement qui charge très fort le bas des pectoraux et les triceps, et qui demande sinon des années.",
                en: "The dip with a counterweight. It makes a movement that loads the lower chest and triceps very hard available in your first month, when it otherwise takes years.",
                es: "El fondo con contrapeso. Hace accesible desde el primer mes un movimiento que carga con fuerza el pectoral inferior y los tríceps, y que de otro modo exige años."
            ),
            setup: LocalizedText(
                fr: "Assistance réglée pour huit à dix répétitions complètes. Buste penché en avant pour les pectoraux, droit pour les triceps : décide avant de commencer, comme sur un dip libre.",
                en: "Assistance set for eight to ten full reps. Torso leaning forward for chest, upright for triceps: decide before you start, exactly as on a free dip.",
                es: "Asistencia ajustada para ocho o diez repeticiones completas. Torso inclinado hacia delante para pectoral, recto para tríceps: decide antes de empezar, igual que en un fondo libre."
            ),
            watchOut: LocalizedText(
                fr: "Descendre plus bas que sur un dip libre parce que l'assistance rend la remontée facile. La limite de l'épaule est la même : bras à quatre-vingt-dix degrés, pas plus bas, assistance ou non.",
                en: "Going deeper than on a free dip because the assistance makes coming back up easy. Your shoulder's limit has not changed: ninety degrees at the elbow, no lower, assisted or not.",
                es: "Bajar más que en un fondo libre porque la asistencia facilita la subida. El límite del hombro es el mismo: noventa grados de codo, no más abajo, con asistencia o sin ella."
            )
        ),
        ExerciseBrief(
            id: "preacher-curl-machine",
            what: LocalizedText(
                fr: "Le curl sur pupitre, bras posés sur un plan incliné. Le pupitre supprime tout élan possible : le biceps travaille seul, et l'étirement en bas est bien plus profond qu'un curl debout.",
                en: "The curl on a preacher pad, arms resting on an angled shelf. The pad removes every possible swing: the biceps works alone, and the stretch at the bottom is far deeper than a standing curl.",
                es: "El curl en banco predicador, con los brazos apoyados en un plano inclinado. El banco elimina cualquier impulso: el bíceps trabaja solo y el estiramiento abajo es mucho más profundo que en un curl de pie."
            ),
            setup: LocalizedText(
                fr: "Aisselles bien calées en haut du coussin, épaules basses. Descends jusqu'à ce que les bras soient presque tendus — pas complètement verrouillés, le coude n'aime pas ça sous charge.",
                en: "Armpits pressed into the top of the pad, shoulders down. Lower until the arms are nearly straight — not fully locked, the elbow dislikes that under load.",
                es: "Axilas bien apoyadas en la parte alta de la almohadilla, hombros bajos. Baja hasta que los brazos queden casi rectos, no del todo bloqueados: al codo no le gusta bajo carga."
            ),
            watchOut: LocalizedText(
                fr: "Décoller les fesses du siège pour finir la dernière répétition. Sur pupitre, tout ce que le corps ajoute passe par les coudes bloqués : c'est le meilleur moyen d'attraper une tendinite. Repose la charge, c'est fini.",
                en: "Lifting off the seat to grind out the last rep. On a preacher pad, everything the body adds goes through locked elbows: the surest route to tendinitis. Put it down, the set is over.",
                es: "Despegar el trasero del asiento para terminar la última repetición. En el banco predicador, todo lo que añade el cuerpo pasa por los codos bloqueados: la forma más segura de coger una tendinitis. Suelta la carga, se acabó."
            )
        ),
        ExerciseBrief(
            id: "cable-hammer-curl",
            what: LocalizedText(
                fr: "Le curl marteau à la corde. La prise neutre vise le brachial, et le câble maintient la tension jusqu'en haut, là où des haltères la perdent complètement.",
                en: "The hammer curl on a rope. The neutral grip targets the brachialis, and the cable holds tension all the way up, where dumbbells lose it entirely.",
                es: "El curl martillo con cuerda. El agarre neutro apunta al braquial y el cable mantiene la tensión hasta arriba, donde las mancuernas la pierden del todo."
            ),
            setup: LocalizedText(
                fr: "Corde sur poulie basse, un pas en arrière pour que le câble tire vers le bas et l'arrière. Coudes collés aux côtes. Écarte légèrement les extrémités de la corde en haut : ça contracte plus fort.",
                en: "Rope on a low pulley, one step back so the cable pulls down and behind. Elbows at your ribs. Spread the rope ends slightly at the top: it squeezes harder.",
                es: "Cuerda en polea baja, un paso atrás para que el cable tire hacia abajo y atrás. Codos pegados a las costillas. Separa un poco los extremos de la cuerda arriba: contrae más."
            ),
            watchOut: LocalizedText(
                fr: "Reculer les coudes pour monter plus haut. Dès que le coude part en arrière, l'épaule prend le relais et le bras travaille moins : le coude reste un axe fixe, du début à la fin.",
                en: "Pulling the elbows back to get higher. The moment the elbow travels back the shoulder takes over and the arm works less: the elbow is a fixed pivot from start to finish.",
                es: "Echar los codos atrás para subir más. En cuanto el codo retrocede, el hombro toma el relevo y el brazo trabaja menos: el codo es un eje fijo de principio a fin."
            )
        ),
        ExerciseBrief(
            id: "machine-triceps-extension",
            what: LocalizedText(
                fr: "L'extension de triceps sur machine, bras calés. Aucune stabilisation à gérer, donc on peut chercher l'échec proprement : c'est l'exercice de triceps le plus sûr du catalogue.",
                en: "The triceps extension on a machine, arms braced. No stabilisation to manage, so you can chase failure cleanly: the safest triceps exercise in the catalogue.",
                es: "La extensión de tríceps en máquina, con los brazos apoyados. Sin estabilización que gestionar, puedes buscar el fallo limpiamente: es el ejercicio de tríceps más seguro del catálogo."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que les coudes tombent pile sur l'axe de la machine. Coudes bien posés sur le coussin et qui n'en bougent plus. Tends complètement sans claquer l'articulation.",
                en: "Seat set so your elbows land exactly on the machine's pivot. Elbows planted on the pad and staying there. Extend fully without snapping the joint.",
                es: "Asiento ajustado para que los codos caigan justo en el eje de la máquina. Codos bien apoyados en la almohadilla y sin moverse. Extiende del todo sin chasquear la articulación."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher en avant avec tout le buste pour finir la série. Le triceps a fini son travail : ce qui pousse alors, c'est le poids du corps. Baisse d'un cran plutôt que d'ajouter trois répétitions qui ne comptent pas.",
                en: "Leaning in with the whole torso to finish the set. The triceps is done: what is pushing now is your bodyweight. Drop a notch rather than adding three reps that do not count.",
                es: "Inclinarse hacia delante con todo el torso para terminar la serie. El tríceps ya ha acabado: lo que empuja es el peso del cuerpo. Baja un punto en vez de añadir tres repeticiones que no cuentan."
            )
        ),
        ExerciseBrief(
            id: "ab-crunch-machine",
            what: LocalizedText(
                fr: "Le crunch sur machine, avec une charge réglable. C'est le seul exercice d'abdominaux, avec le crunch à la poulie, où la progression se mesure en kilos plutôt qu'en répétitions.",
                en: "The crunch on a machine, with adjustable load. Along with the cable crunch, the only ab exercise where progress is measured in kilos rather than reps.",
                es: "El crunch en máquina, con carga regulable. Junto con el crunch en polea, el único ejercicio abdominal donde el progreso se mide en kilos y no en repeticiones."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que ton nombril soit à peu près à l'axe de la machine. Le mouvement est un enroulement du sternum vers le bassin : la distance entre les côtes et le pubis diminue, c'est tout.",
                en: "Seat set so your navel is roughly at the machine's pivot. The movement is a curl of the sternum towards the pelvis: the distance between ribs and hips shortens, that is all.",
                es: "Asiento ajustado para que tu ombligo quede más o menos en el eje de la máquina. El movimiento es un enrollamiento del esternón hacia la pelvis: la distancia entre costillas y pubis se acorta, nada más."
            ),
            watchOut: LocalizedText(
                fr: "Plier aux hanches en gardant le dos droit. C'est alors le psoas qui travaille, pas les abdominaux, et le bas du dos encaisse. Si ton dos reste droit pendant la répétition, tu ne fais pas de crunch.",
                en: "Hinging at the hips with a straight back. Then your hip flexors work, not your abs, and your low back takes the strain. If your back stays straight through the rep, you are not crunching.",
                es: "Flexionar por la cadera manteniendo la espalda recta. Entonces trabaja el psoas, no los abdominales, y la zona lumbar lo paga. Si tu espalda sigue recta durante la repetición, no estás haciendo un crunch."
            )
        ),
        ExerciseBrief(
            id: "cable-woodchop",
            what: LocalizedText(
                fr: "Une diagonale à la poulie, du haut d'un côté vers le bas de l'autre. C'est le seul exercice du catalogue qui entraîne le tronc à résister à la rotation — ce qu'il fait toute la journée sans qu'on y pense.",
                en: "A diagonal on the cable, from high on one side to low on the other. The only exercise in the catalogue that trains the trunk to resist rotation — what it does all day without you noticing.",
                es: "Una diagonal en polea, de arriba a un lado hacia abajo al otro. Es el único ejercicio del catálogo que entrena al tronco a resistir la rotación, algo que hace todo el día sin que lo pienses."
            ),
            setup: LocalizedText(
                fr: "Pieds écartés et fixes, bras presque tendus. Ce sont les hanches et le tronc qui tournent ensemble, pas les bras qui tirent en travers du corps. Le regard suit les mains.",
                en: "Feet apart and planted, arms nearly straight. Hips and trunk rotate together — the arms do not drag the handle across your body. The eyes follow the hands.",
                es: "Pies separados y fijos, brazos casi rectos. Caderas y tronco giran juntos, los brazos no arrastran el agarre cruzando el cuerpo. La mirada sigue a las manos."
            ),
            watchOut: LocalizedText(
                fr: "Tourner en gardant les pieds cloués au sol. La rotation doit se répartir entre les hanches, le bassin et le tronc : si seuls les lombaires tournent sous charge, c'est exactement le mouvement qui bloque un dos. Laisse le pied arrière pivoter.",
                en: "Twisting with your feet nailed to the floor. The rotation should share between hips, pelvis and trunk: if only the lumbar spine turns under load, that is precisely the movement that locks a back up. Let the rear foot pivot.",
                es: "Girar con los pies clavados en el suelo. La rotación debe repartirse entre caderas, pelvis y tronco: si solo giran las lumbares bajo carga, ese es justo el movimiento que bloquea una espalda. Deja que el pie trasero pivote."
            )
        ),
    ]
}
