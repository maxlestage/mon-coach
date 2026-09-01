import Foundation

// Les fiches des mouvements de poussée : pectoraux, épaules, triceps.
extension ExerciseBriefs {

    static let push: [ExerciseBrief] = [
        ExerciseBrief(
            id: "bench-press",
            what: LocalizedText(
                fr: "Allongé, tu descends la barre sur la poitrine et tu la repousses. C'est la référence du haut du corps : le mouvement où la charge monte le plus vite, et celui qu'on mesure.",
                en: "Lying down, you lower the bar to your chest and push it back up. The upper-body benchmark: the movement where load climbs fastest, and the one people measure.",
                es: "Tumbado, bajas la barra al pecho y la empujas de vuelta. La referencia del tren superior: el movimiento en el que la carga sube más rápido, y el que se mide."
            ),
            setup: LocalizedText(
                fr: "Omoplates serrées l'une contre l'autre et tirées vers le bas, comme si tu voulais les glisser dans tes poches arrière : elles ne bougent plus de la série. Yeux sous la barre au départ. Pieds bien à plat, jambes qui poussent le sol.",
                en: "Shoulder blades pinched together and pulled down, as if tucking them into your back pockets: they do not move for the rest of the set. Eyes under the bar at the start. Feet flat, legs pushing the floor.",
                es: "Escápulas juntas y tiradas hacia abajo, como si quisieras metértelas en los bolsillos traseros: no se mueven en toda la serie. Ojos bajo la barra al inicio. Pies planos, piernas empujando el suelo."
            ),
            watchOut: LocalizedText(
                fr: "Les épaules qui roulent vers l'avant en fin de poussée pour aller chercher deux centimètres de plus. C'est là que naissent les douleurs d'épaule, et ces deux centimètres n'ajoutent rien aux pectoraux.",
                en: "The shoulders rolling forward at the top to chase two extra centimetres. That is where shoulder pain is born, and those two centimetres add nothing to your chest.",
                es: "Los hombros que ruedan hacia delante al final del empuje buscando dos centímetros más. Ahí nacen los dolores de hombro, y esos dos centímetros no añaden nada al pectoral."
            )
        ),
        ExerciseBrief(
            id: "incline-bench-press",
            what: LocalizedText(
                fr: "Le développé couché sur un banc incliné. L'angle déplace le travail vers le haut des pectoraux et l'avant de l'épaule — la partie qui donne la forme sous une chemise.",
                en: "The bench press on an inclined bench. The angle shifts work to the upper chest and front delt — the part that shows under a shirt.",
                es: "El press de banca en banco inclinado. El ángulo desplaza el trabajo al pectoral superior y al deltoides anterior, la parte que se ve bajo una camisa."
            ),
            setup: LocalizedText(
                fr: "Trente degrés, pas quarante-cinq. Au-delà, ce sont les épaules qui prennent la charge et les pectoraux ne voient plus rien passer. La barre descend haut sur la poitrine, sous les clavicules.",
                en: "Thirty degrees, not forty-five. Past that the shoulders take the load and the chest sees nothing. The bar comes down high on the chest, just under the collarbones.",
                es: "Treinta grados, no cuarenta y cinco. Más allá, los hombros se llevan la carga y el pectoral no ve nada. La barra baja alta en el pecho, bajo las clavículas."
            ),
            watchOut: LocalizedText(
                fr: "Charger comme au couché à plat. Sur incliné tu perds vingt pour cent de charge, c'est normal et ça ne se rattrape pas en cambrant : si tu creuses le dos pour redevenir à plat, autant faire un développé couché.",
                en: "Loading it like a flat bench. You lose twenty percent on an incline, that is normal, and arching does not win it back: if you flatten yourself out, you may as well be doing a flat bench.",
                es: "Cargar como en banca plana. En inclinado pierdes un veinte por ciento, es normal, y arquearse no lo recupera: si te pones plano, mejor haz banca plana."
            )
        ),
        ExerciseBrief(
            id: "dumbbell-bench-press",
            what: LocalizedText(
                fr: "Le développé couché avec deux haltères. Chaque bras travaille seul, l'amplitude descend plus bas qu'avec une barre, et l'épaule choisit sa trajectoire au lieu de la subir.",
                en: "The bench press with two dumbbells. Each arm works alone, the range goes deeper than a bar allows, and the shoulder picks its own path instead of being forced.",
                es: "El press de banca con dos mancuernas. Cada brazo trabaja solo, el recorrido baja más que con barra y el hombro elige su trayectoria en lugar de sufrirla."
            ),
            setup: LocalizedText(
                fr: "Assieds-toi, haltères sur les cuisses, puis bascule en arrière en les remontant d'un coup de genoux : c'est la seule façon sûre de les mettre en position quand elles sont lourdes. Pour reposer, fais l'inverse.",
                en: "Sit down, dumbbells on your thighs, then roll back kicking them up with your knees: that is the only safe way to get heavy ones into position. Reverse it to put them down.",
                es: "Siéntate con las mancuernas en los muslos y bascula hacia atrás impulsándolas con las rodillas: es la única forma segura de colocarlas cuando pesan. Para dejarlas, haz lo contrario."
            ),
            watchOut: LocalizedText(
                fr: "Descendre jusqu'à sentir tirer devant l'épaule. L'étirement du pectoral et la traction sur l'articulation ne sont pas la même sensation : la première est en travers de la poitrine, la seconde pointue et devant. Arrête-toi avant la seconde.",
                en: "Going down until you feel a pull at the front of the shoulder. A chest stretch and a joint being pulled are not the same feeling: the first spreads across the chest, the second is sharp and out front. Stop before the second.",
                es: "Bajar hasta notar tirón delante del hombro. El estiramiento del pectoral y la tracción de la articulación no son la misma sensación: el primero cruza el pecho, la segunda es puntiaguda y delantera. Párate antes de la segunda."
            )
        ),
        ExerciseBrief(
            id: "incline-dumbbell-press",
            what: LocalizedText(
                fr: "Le développé incliné aux haltères. Il additionne les deux avantages : l'angle qui vise le haut des pectoraux, et la liberté de trajectoire des haltères.",
                en: "The incline press with dumbbells. It stacks both advantages: the angle that targets the upper chest, and the free path dumbbells allow.",
                es: "El press inclinado con mancuernas. Suma las dos ventajas: el ángulo que apunta al pectoral superior y la libertad de trayectoria de las mancuernas."
            ),
            setup: LocalizedText(
                fr: "Trente degrés, dossier réglé avant de prendre les haltères. En haut, laisse-les converger légèrement sans les cogner : c'est la fin du mouvement du pectoral, pas une pose.",
                en: "Thirty degrees, backrest set before you pick up the dumbbells. At the top let them converge slightly without clanging: that is the end of the chest's job, not a pose.",
                es: "Treinta grados, respaldo ajustado antes de coger las mancuernas. Arriba deja que converjan ligeramente sin chocarlas: es el final del recorrido del pectoral, no una pose."
            ),
            watchOut: LocalizedText(
                fr: "Les coudes qui partent complètement sur les côtés, alignés avec les épaules. Garde-les à quarante-cinq degrés du buste : l'épaule reste dans un angle qu'elle supporte, et le pectoral travaille pareil.",
                en: "Elbows flaring straight out in line with the shoulders. Keep them at forty-five degrees to the torso: the shoulder stays in an angle it tolerates, and the chest works just as hard.",
                es: "Los codos abiertos del todo, alineados con los hombros. Mantenlos a cuarenta y cinco grados del torso: el hombro se queda en un ángulo que tolera y el pectoral trabaja igual."
            )
        ),
        ExerciseBrief(
            id: "machine-chest-press",
            what: LocalizedText(
                fr: "Le développé sur machine guidée. Aucun équilibre à gérer, aucun risque d'être coincé : c'est le mouvement où on peut aller le plus près de l'échec sans partenaire.",
                en: "The press on a guided machine. No balance to manage, no risk of getting pinned: this is where you can go closest to failure without a spotter.",
                es: "El press en máquina guiada. Sin equilibrio que gestionar y sin riesgo de quedarte atrapado: es donde puedes acercarte más al fallo sin compañero."
            ),
            setup: LocalizedText(
                fr: "Règle le siège pour que les poignées arrivent à hauteur du milieu des pectoraux, pas des épaules. Un cran trop haut et tu fais un développé épaules sans le savoir.",
                en: "Set the seat so the handles sit at mid-chest height, not shoulder height. One notch too high and you are doing a shoulder press without knowing it.",
                es: "Ajusta el asiento para que las empuñaduras queden a la altura media del pectoral, no de los hombros. Un punto más alto y estarás haciendo press de hombros sin saberlo."
            ),
            watchOut: LocalizedText(
                fr: "Le dos qui décolle du dossier pour arracher les dernières répétitions. À ce moment-là ce sont les lombaires qui poussent : garde le contact, et si la série s'arrête là, c'est qu'elle était finie.",
                en: "The back peeling off the pad to grind out the last reps. At that point your low back is pressing: keep the contact, and if the set ends there, it was over.",
                es: "La espalda que se despega del respaldo para arrancar las últimas repeticiones. En ese momento empuja la zona lumbar: mantén el contacto, y si la serie acaba ahí, es que estaba acabada."
            )
        ),
        ExerciseBrief(
            id: "push-up",
            what: LocalizedText(
                fr: "La poussée horizontale sans matériel. Le corps entier doit rester rigide, donc les abdominaux travaillent autant que les pectoraux — ce qu'un développé couché ne demande jamais.",
                en: "The horizontal press with no kit. The whole body has to stay rigid, so your abs work as hard as your chest — something a bench press never asks.",
                es: "El empuje horizontal sin material. Todo el cuerpo debe permanecer rígido, así que los abdominales trabajan tanto como el pectoral, algo que el press de banca nunca exige."
            ),
            setup: LocalizedText(
                fr: "Mains un peu plus larges que les épaules, à hauteur de poitrine et non d'épaules. Serre les fessiers et rentre les côtes : le corps fait une planche du crâne aux talons.",
                en: "Hands slightly wider than the shoulders, at chest height not shoulder height. Squeeze the glutes and tuck the ribs: the body is one plank from skull to heels.",
                es: "Manos algo más anchas que los hombros, a la altura del pecho y no de los hombros. Aprieta los glúteos y mete las costillas: el cuerpo es una tabla del cráneo a los talones."
            ),
            watchOut: LocalizedText(
                fr: "Le bassin qui tombe et la tête qui descend en premier. Si tu n'arrives pas à garder la ligne, mets les mains sur un banc plutôt que de faire des pompes sur les genoux : l'amplitude reste complète et le gainage travaille encore.",
                en: "The hips sagging and the head leading the way down. If you cannot hold the line, put your hands on a bench rather than dropping to your knees: the range stays full and the brace still works.",
                es: "La cadera que cae y la cabeza que baja primero. Si no puedes mantener la línea, apoya las manos en un banco en vez de hacerlas de rodillas: el recorrido sigue completo y el core sigue trabajando."
            )
        ),
        ExerciseBrief(
            id: "dip",
            what: LocalizedText(
                fr: "Suspendu entre deux barres parallèles, tu descends et tu remontes. Ça charge le bas des pectoraux et les triceps plus fort que n'importe quel développé, avec ton propre poids.",
                en: "Suspended between parallel bars, you lower and press back up. It loads the lower chest and triceps harder than any press, with your own bodyweight.",
                es: "Suspendido entre dos barras paralelas, bajas y subes. Carga el pectoral inferior y los tríceps más que cualquier press, con tu propio peso."
            ),
            setup: LocalizedText(
                fr: "Buste penché en avant et coudes qui s'écartent un peu pour viser les pectoraux ; buste droit et coudes serrés pour viser les triceps. Choisis avant la première répétition, pas au milieu de la série.",
                en: "Lean the torso forward with elbows slightly out for chest; stay upright with elbows tucked for triceps. Decide before the first rep, not mid-set.",
                es: "Torso inclinado hacia delante y codos algo abiertos para pectoral; torso recto y codos pegados para tríceps. Decide antes de la primera repetición, no a mitad de serie."
            ),
            watchOut: LocalizedText(
                fr: "Descendre jusqu'à ce que les épaules passent sous les coudes. Au-delà de l'horizontale, l'articulation encaisse tout le poids du corps dans sa position la plus fragile. Arrête-toi bras à quatre-vingt-dix degrés.",
                en: "Dropping until the shoulders sit below the elbows. Past horizontal, the joint takes your whole bodyweight in its most vulnerable position. Stop at ninety degrees.",
                es: "Bajar hasta que los hombros queden por debajo de los codos. Pasada la horizontal, la articulación soporta todo tu peso en su posición más frágil. Párate con los brazos a noventa grados."
            )
        ),
        ExerciseBrief(
            id: "cable-fly",
            what: LocalizedText(
                fr: "Bras presque tendus, tu rapproches les mains devant toi contre la résistance des poulies. C'est le seul mouvement de pectoraux qui garde de la tension en position contractée, là où une barre n'en met plus.",
                en: "Arms nearly straight, you bring your hands together against the cables. It is the one chest movement that keeps tension where you are shortest, exactly where a bar stops loading you.",
                es: "Con los brazos casi extendidos, juntas las manos delante contra la resistencia de las poleas. Es el único movimiento de pectoral que mantiene tensión en posición contraída, justo donde una barra deja de cargar."
            ),
            setup: LocalizedText(
                fr: "Poulies à hauteur d'épaule pour le milieu des pectoraux, plus haut pour le bas, plus bas pour le haut. Un pas en avant pour mettre de la tension dès le départ : rester entre les montants ne charge rien au début.",
                en: "Pulleys at shoulder height for mid-chest, higher for lower chest, lower for upper. Take a step forward so there is tension from the start: standing between the uprights loads nothing at the beginning.",
                es: "Poleas a la altura del hombro para el pectoral medio, más altas para el inferior, más bajas para el superior. Da un paso adelante para tener tensión desde el inicio: quedarte entre los soportes no carga nada al principio."
            ),
            watchOut: LocalizedText(
                fr: "Plier et tendre les coudes : ça devient un développé, et les triceps prennent le travail. L'angle du coude se règle au départ et ne bouge plus — tu ne fais que rapprocher les mains.",
                en: "Bending and straightening the elbows: it turns into a press and the triceps take over. Set the elbow angle at the start and leave it — all you do is bring the hands together.",
                es: "Flexionar y estirar los codos: se convierte en un press y los tríceps se llevan el trabajo. El ángulo del codo se fija al inicio y no cambia: solo juntas las manos."
            )
        ),
        ExerciseBrief(
            id: "overhead-press",
            what: LocalizedText(
                fr: "Debout, tu pousses une barre du haut de la poitrine jusqu'au-dessus de la tête. C'est le test le plus honnête du haut du corps : rien ne peut tricher à ta place, ni un banc ni un élan.",
                en: "Standing, you press a bar from the top of your chest to overhead. The most honest upper-body test there is: nothing can cheat for you — no bench, no momentum.",
                es: "De pie, empujas una barra desde la parte alta del pecho hasta encima de la cabeza. Es la prueba más honesta del tren superior: nada puede hacer trampa por ti, ni un banco ni el impulso."
            ),
            setup: LocalizedText(
                fr: "Prise juste plus large que les épaules, coudes légèrement devant la barre. Serre fessiers et abdominaux avant de pousser : sans ce verrou, la charge part dans le bas du dos. Recule la tête au passage pour laisser filer la barre.",
                en: "Grip just outside the shoulders, elbows slightly in front of the bar. Squeeze glutes and abs before you press: without that lock the load goes straight to your low back. Pull the head back to let the bar pass.",
                es: "Agarre justo por fuera de los hombros, codos ligeramente delante de la barra. Aprieta glúteos y abdomen antes de empujar: sin ese bloqueo la carga se va a la zona lumbar. Echa la cabeza atrás para dejar pasar la barra."
            ),
            watchOut: LocalizedText(
                fr: "Se cambrer en arrière pour finir la répétition. Ce n'est plus un développé militaire, c'est un développé incliné debout — avec une compression en plus sur les lombaires. Si tu dois cambrer, la série est finie.",
                en: "Leaning back to finish the rep. That is no longer an overhead press, it is a standing incline press — with an extra compression through your low back. If you have to lean, the set is over.",
                es: "Arquearse hacia atrás para terminar la repetición. Eso ya no es press militar, es un press inclinado de pie, con una compresión extra en las lumbares. Si tienes que arquearte, la serie ha terminado."
            )
        ),
        ExerciseBrief(
            id: "seated-dumbbell-press",
            what: LocalizedText(
                fr: "Le développé au-dessus de la tête, assis, avec deux haltères. Le dossier retire le travail de gainage, et les haltères laissent l'épaule tourner comme elle veut.",
                en: "The overhead press, seated, with two dumbbells. The backrest removes the bracing work, and the dumbbells let the shoulder rotate as it likes.",
                es: "El press por encima de la cabeza, sentado, con dos mancuernas. El respaldo elimina el trabajo de core y las mancuernas dejan que el hombro gire como quiera."
            ),
            setup: LocalizedText(
                fr: "Dossier à quatre-vingt-cinq degrés plutôt que parfaitement vertical : c'est plus doux pour l'épaule et ça ne change presque rien au travail. Descends jusqu'à ce que les haltères arrivent aux oreilles.",
                en: "Backrest at eighty-five degrees rather than bolt upright: kinder to the shoulder and it barely changes the work. Lower until the dumbbells reach your ears.",
                es: "Respaldo a ochenta y cinco grados en vez de totalmente vertical: es más amable con el hombro y casi no cambia el trabajo. Baja hasta que las mancuernas lleguen a las orejas."
            ),
            watchOut: LocalizedText(
                fr: "S'arrêter à mi-chemin parce que la charge est trop lourde. Une demi-amplitude sur un développé épaules ne construit presque rien : mieux vaut deux haltères plus légères et descendre jusqu'aux oreilles.",
                en: "Stopping halfway because the weight is too heavy. Half range on a shoulder press builds almost nothing: take lighter dumbbells and come down to your ears.",
                es: "Pararse a medio camino porque pesa demasiado. Medio recorrido en un press de hombros construye casi nada: mejor mancuernas más ligeras y bajar hasta las orejas."
            )
        ),
        ExerciseBrief(
            id: "machine-shoulder-press",
            what: LocalizedText(
                fr: "Le développé épaules sur machine. La trajectoire est imposée, ce qui rend le mouvement facile à apprendre et sûr à charger quand on n'a personne pour surveiller.",
                en: "The shoulder press on a machine. The path is fixed, which makes it easy to learn and safe to load when nobody is watching.",
                es: "El press de hombros en máquina. La trayectoria está impuesta, lo que lo hace fácil de aprender y seguro de cargar cuando no hay nadie mirando."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que les poignées partent à hauteur des oreilles, pas au-dessus de la tête : trop haut, tu perds la moitié basse du mouvement, celle qui fait grossir.",
                en: "Seat set so the handles start at ear height, not above your head: too high and you lose the bottom half of the movement, the half that builds.",
                es: "Asiento ajustado para que las empuñaduras arranquen a la altura de las orejas, no por encima de la cabeza: demasiado alto y pierdes la mitad baja del recorrido, la que hace crecer."
            ),
            watchOut: LocalizedText(
                fr: "Le à-coup en bas pour relancer la charge. Sur machine il ne coûte rien à l'équilibre, donc on le fait sans s'en rendre compte — et c'est l'articulation qui absorbe le choc. Marque un temps d'arrêt en bas.",
                en: "The bounce at the bottom to restart the weight. On a machine it costs nothing in balance, so you do it without noticing — and the joint absorbs the jolt. Pause at the bottom instead.",
                es: "El tirón abajo para relanzar la carga. En máquina no cuesta equilibrio, así que se hace sin darse cuenta, y es la articulación la que absorbe el golpe. Haz una pausa abajo."
            )
        ),
        ExerciseBrief(
            id: "pike-push-up",
            what: LocalizedText(
                fr: "Une pompe faite hanches hautes, presque à la verticale. C'est la seule façon de charger les épaules au-dessus de la tête sans matériel du tout.",
                en: "A push-up done with the hips high, almost vertical. The only way to load the shoulders overhead with no equipment at all.",
                es: "Una flexión con las caderas altas, casi en vertical. La única forma de cargar los hombros por encima de la cabeza sin ningún material."
            ),
            setup: LocalizedText(
                fr: "Marche vers tes mains jusqu'à faire un V renversé aussi fermé que possible. Le sommet du crâne vise le sol entre les mains, pas devant : c'est ce qui met les épaules dans l'axe.",
                en: "Walk your feet in until you make an inverted V as tight as you can. The crown of your head aims at the floor between your hands, not in front: that is what puts the shoulders in line.",
                es: "Camina hacia tus manos hasta formar una V invertida lo más cerrada posible. La coronilla apunta al suelo entre las manos, no delante: eso es lo que alinea los hombros."
            ),
            watchOut: LocalizedText(
                fr: "Descendre le front devant les mains : ça redevient une pompe inclinée et les épaules ne voient plus rien. Si c'est trop dur dans l'axe, pose les pieds plus bas plutôt que d'avancer la tête.",
                en: "Lowering your forehead in front of your hands: it turns back into a decline push-up and the shoulders see nothing. If straight down is too hard, put your feet lower rather than moving your head forward.",
                es: "Bajar la frente por delante de las manos: vuelve a ser una flexión declinada y los hombros no ven nada. Si en el eje es muy difícil, baja los pies en vez de adelantar la cabeza."
            )
        ),
    ]
}
