import Foundation

// Les fiches des machines de salle : bas du corps et tirages.
//
// Une machine passe pour évidente parce qu'elle guide le mouvement. C'est
// exactement pour ça qu'elle mérite une fiche : le geste est imposé, donc
// tout se joue dans le réglage — et un réglage faux ne se voit pas, il se
// paie deux jours plus tard.
extension ExerciseBriefs {

    static let machinesLower: [ExerciseBrief] = [
        ExerciseBrief(
            id: "pendulum-squat",
            what: LocalizedText(
                fr: "Un squat sur un bras oscillant : la charge suit un arc de cercle au lieu d'une ligne droite. Le dos est entièrement porté par la machine, donc les cuisses travaillent jusqu'à l'échec sans que les lombaires disent stop avant.",
                en: "A squat on a swinging arm: the load follows an arc rather than a straight line. The machine carries your back completely, so the legs can reach failure without the low back calling time first.",
                es: "Una sentadilla sobre un brazo oscilante: la carga sigue un arco en vez de una línea recta. La máquina sostiene por completo tu espalda, así que las piernas llegan al fallo sin que las lumbares digan basta antes."
            ),
            setup: LocalizedText(
                fr: "Dos et bassin plaqués contre le dossier, pieds au milieu de la plateforme. Pousse par le milieu du pied : c'est l'arc de la machine qui gère le reste, tu n'as rien à équilibrer.",
                en: "Back and hips flat against the pad, feet mid-platform. Push through the middle of the foot: the machine's arc handles the rest, you have nothing to balance.",
                es: "Espalda y cadera pegadas al respaldo, pies en el centro de la plataforma. Empuja por el medio del pie: el arco de la máquina se encarga del resto, no tienes nada que equilibrar."
            ),
            watchOut: LocalizedText(
                fr: "Descendre plus bas que la machine ne le permet en décollant les talons. Les talons restent posés du début à la fin : s'ils se lèvent, remonte les pieds sur la plateforme plutôt que de forcer.",
                en: "Going deeper than the machine allows by letting the heels lift. The heels stay down throughout: if they rise, move your feet higher on the platform instead of forcing it.",
                es: "Bajar más de lo que permite la máquina despegando los talones. Los talones se quedan apoyados de principio a fin: si se levantan, sube los pies en la plataforma en vez de forzar."
            )
        ),
        ExerciseBrief(
            id: "belt-squat",
            what: LocalizedText(
                fr: "La charge pend à une ceinture accrochée aux hanches. Le bas du dos ne porte rien du tout : c'est le seul squat lourd praticable quand les lombaires sont fatiguées ou douloureuses.",
                en: "The load hangs from a belt at your hips. The low back carries nothing at all: the only heavy squat you can do when your lumbar spine is tired or sore.",
                es: "La carga cuelga de un cinturón en las caderas. La zona lumbar no soporta nada: es la única sentadilla pesada practicable cuando las lumbares están cansadas o doloridas."
            ),
            setup: LocalizedText(
                fr: "Ceinture bien basse sur les hanches, pas sur la taille. Tiens-toi aux poignées pour l'équilibre seulement — si tu tires dessus, tu allèges la charge sans le savoir.",
                en: "Belt low on the hips, not around the waist. Hold the handles for balance only — pull on them and you are quietly unloading the movement.",
                es: "Cinturón bien bajo en las caderas, no en la cintura. Agárrate a las asas solo para el equilibrio: si tiras de ellas, aligeras la carga sin darte cuenta."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher en avant comme sur un squat barre. Ici la charge tire vers le bas depuis les hanches : le buste doit rester vertical, sinon la ceinture glisse et la position devient bancale.",
                en: "Leaning forward as if under a bar. Here the load pulls straight down from your hips: the torso stays upright, otherwise the belt slides and the position goes crooked.",
                es: "Inclinarse hacia delante como en una sentadilla con barra. Aquí la carga tira hacia abajo desde las caderas: el torso debe quedar vertical, o el cinturón se desliza y la posición se descuadra."
            )
        ),
        ExerciseBrief(
            id: "smith-squat",
            what: LocalizedText(
                fr: "Le squat sur une barre guidée verticalement. Aucun équilibre à tenir et des crans de sécurité partout : c'est le squat lourd qu'on peut faire seul, sans personne pour surveiller.",
                en: "The squat on a vertically guided bar. No balance to hold and safety catches everywhere: the heavy squat you can do alone, with nobody spotting.",
                es: "La sentadilla en una barra guiada verticalmente. Sin equilibrio que mantener y con topes de seguridad: es la sentadilla pesada que puedes hacer solo, sin nadie vigilando."
            ),
            setup: LocalizedText(
                fr: "Avance les pieds de vingt centimètres par rapport à un squat libre. La barre ne peut pas reculer pour compenser ta descente : c'est à toi de te placer devant elle, sinon les genoux encaissent tout.",
                en: "Set your feet twenty centimetres further forward than in a free squat. The bar cannot travel back to follow you: it is on you to stand ahead of it, otherwise the knees take everything.",
                es: "Adelanta los pies veinte centímetros respecto a una sentadilla libre. La barra no puede retroceder para compensar tu bajada: te toca colocarte delante de ella, o las rodillas se lo llevan todo."
            ),
            watchOut: LocalizedText(
                fr: "Se placer comme sous une barre libre, pieds sous la barre. La trajectoire imposée oblige alors les genoux à avancer très loin sous une charge lourde. Si tu sens tirer devant les genoux, avance les pieds.",
                en: "Standing as you would under a free bar, feet under it. The fixed path then forces the knees far forward under heavy load. If you feel a pull in front of the knees, move your feet out.",
                es: "Colocarse como bajo una barra libre, con los pies debajo. La trayectoria fija obliga entonces a las rodillas a adelantarse mucho con carga pesada. Si notas tirón delante de las rodillas, adelanta los pies."
            )
        ),
        ExerciseBrief(
            id: "smith-split-squat",
            what: LocalizedText(
                fr: "La fente bulgare avec une barre guidée. L'équilibre étant réglé par la machine, toute l'attention et toute la charge vont dans la jambe avant.",
                en: "The Bulgarian split squat on a guided bar. With balance handled by the machine, all your attention and all the load go into the front leg.",
                es: "La zancada búlgara con barra guiada. Como la máquina resuelve el equilibrio, toda la atención y toda la carga van a la pierna delantera."
            ),
            setup: LocalizedText(
                fr: "Place le pied avant sous la barre, puis avance-le encore d'un demi-pied : la barre descend en ligne droite et ton genou ne doit pas avoir à partir devant. Pied arrière sur un banc à hauteur de genou.",
                en: "Put the front foot under the bar, then move it half a foot further forward: the bar drops in a straight line and your knee should not have to travel ahead. Rear foot on a knee-height bench.",
                es: "Coloca el pie delantero bajo la barra y adelántalo otro medio pie: la barra baja en línea recta y tu rodilla no debe tener que adelantarse. Pie trasero en un banco a la altura de la rodilla."
            ),
            watchOut: LocalizedText(
                fr: "Se mettre trop près : la barre étant fixe, tu ne peux pas reculer en cours de série, et le genou avant se retrouve loin devant les orteils à chaque répétition. Vérifie la position à vide avant de charger.",
                en: "Standing too close: with the bar fixed you cannot step back mid-set, and the front knee ends up well past the toes on every rep. Check the position unloaded before you load it.",
                es: "Colocarse demasiado cerca: como la barra es fija, no puedes retroceder a mitad de serie y la rodilla delantera acaba muy por delante de los dedos en cada repetición. Comprueba la posición en vacío antes de cargar."
            )
        ),
        ExerciseBrief(
            id: "single-leg-press",
            what: LocalizedText(
                fr: "La presse à cuisses avec une seule jambe. Ça double la charge relative pour la même pile de poids, et ça révèle immédiatement l'écart entre les deux côtés.",
                en: "The leg press with one leg. It doubles the relative load for the same stack, and it exposes the gap between your two sides immediately.",
                es: "La prensa de piernas con una sola pierna. Duplica la carga relativa con la misma placa y revela de inmediato la diferencia entre los dos lados."
            ),
            setup: LocalizedText(
                fr: "Pied au centre du plateau, pas sur le côté : décentré, le bassin part en rotation. Commence toujours par le côté faible et fais au côté fort exactement le même nombre de répétitions, pas une de plus.",
                en: "Foot in the centre of the platform, not off to one side: off-centre, the pelvis rotates. Always start with the weaker side and give the strong one exactly the same reps, not one more.",
                es: "Pie en el centro de la plataforma, no a un lado: descentrado, la pelvis rota. Empieza siempre por el lado débil y haz con el fuerte exactamente las mismas repeticiones, ni una más."
            ),
            watchOut: LocalizedText(
                fr: "Le bassin qui se décolle du siège du côté qui travaille. Ça arrive dès qu'on descend trop bas, et c'est une torsion lombaire sous charge : arrête la descente là où les fesses restent posées.",
                en: "The pelvis lifting off the seat on the working side. It happens as soon as you go too deep, and it is a loaded twist through the low back: stop the descent where your hips stay down.",
                es: "La pelvis que se despega del asiento del lado que trabaja. Ocurre en cuanto bajas demasiado, y es una torsión lumbar bajo carga: detén la bajada donde las caderas sigan apoyadas."
            )
        ),
        ExerciseBrief(
            id: "machine-hip-thrust",
            what: LocalizedText(
                fr: "Le hip thrust sur machine dédiée. Pas de barre à charger ni de mousse à caler : on passe directement au travail, et on peut monter très lourd sans logistique.",
                en: "The hip thrust on a dedicated machine. No bar to load and no pad to wedge: you go straight to the work, and you can load heavy with no logistics.",
                es: "El hip thrust en máquina dedicada. Sin barra que cargar ni almohadilla que colocar: vas directo al trabajo y puedes cargar mucho sin logística."
            ),
            setup: LocalizedText(
                fr: "Dossier réglé pour que le coussin tombe sur le pli de la hanche, pas sur le ventre. Pieds assez avancés pour que les tibias soient verticaux en haut du mouvement.",
                en: "Backrest set so the pad lands on the hip crease, not on your belly. Feet far enough forward that the shins are vertical at the top.",
                es: "Respaldo ajustado para que la almohadilla caiga en el pliegue de la cadera, no en el abdomen. Pies lo bastante adelantados para que las tibias queden verticales arriba."
            ),
            watchOut: LocalizedText(
                fr: "Monter en creusant le bas du dos. La machine autorise plus de charge, donc l'erreur coûte plus cher qu'avec une barre : menton rentré, côtes basses, et le mouvement s'arrête quand le bassin arrive à l'alignement.",
                en: "Getting height by arching the low back. The machine allows more weight, so the mistake costs more than with a bar: chin tucked, ribs down, and the movement ends when the hips reach the line.",
                es: "Subir arqueando la zona lumbar. La máquina permite más carga, así que el error cuesta más que con barra: barbilla metida, costillas bajas, y el movimiento acaba cuando la cadera llega a la alineación."
            )
        ),
        ExerciseBrief(
            id: "cable-kickback",
            what: LocalizedText(
                fr: "Une sangle à la cheville, tu envoies la jambe en arrière contre la poulie. C'est l'isolation du grand fessier, celle qui garde de la tension exactement là où le hip thrust en met le plus.",
                en: "A strap at the ankle, you drive the leg back against the cable. Glute-max isolation, keeping tension exactly where a hip thrust loads hardest.",
                es: "Una cincha en el tobillo, llevas la pierna hacia atrás contra la polea. Es el aislamiento del glúteo mayor, con tensión justo donde el hip thrust más carga."
            ),
            setup: LocalizedText(
                fr: "Poulie au plus bas, buste penché en avant et main sur le montant. La jambe part en arrière et légèrement vers l'extérieur, jusqu'à l'alignement avec le buste. Une seconde de contraction en fin de course.",
                en: "Pulley at its lowest, torso leaning forward with a hand on the frame. The leg travels back and slightly out, until it lines up with your torso. One second of squeeze at the end.",
                es: "Polea en el punto más bajo, torso inclinado hacia delante y mano en el soporte. La pierna va hacia atrás y algo hacia fuera, hasta alinearse con el torso. Un segundo de contracción al final."
            ),
            watchOut: LocalizedText(
                fr: "Envoyer la jambe le plus haut possible en cambrant. Au-delà de l'alignement, ce sont les lombaires qui montent la jambe, pas le fessier — et c'est comme ça qu'un exercice d'isolation finit par faire mal au dos.",
                en: "Throwing the leg as high as it will go by arching. Past the line, your low back is lifting the leg, not the glute — and that is how an isolation exercise ends up hurting your back.",
                es: "Lanzar la pierna lo más alto posible arqueando. Pasada la alineación, es la zona lumbar la que sube la pierna, no el glúteo, y así es como un ejercicio de aislamiento acaba doliendo en la espalda."
            )
        ),
        ExerciseBrief(
            id: "seated-calf-raise",
            what: LocalizedText(
                fr: "Les mollets assis, genoux pliés. Cette position met le jumeau hors jeu et laisse tout le travail au soléaire — le muscle profond qui porte la course de fond et qu'aucun mollet debout ne touche vraiment.",
                en: "Calves seated, knees bent. That position takes the gastrocnemius out and leaves the work to the soleus — the deep muscle that carries distance running and that standing raises barely reach.",
                es: "Gemelos sentado, con las rodillas flexionadas. Esa posición deja fuera al gemelo y da todo el trabajo al sóleo, el músculo profundo que sostiene la carrera de fondo y que las elevaciones de pie apenas tocan."
            ),
            setup: LocalizedText(
                fr: "Coussin sur le bas des cuisses, juste au-dessus des genoux. Avant-pieds sur la plateforme, talons dans le vide. Descends complètement, tiens deux secondes en bas, remonte au maximum.",
                en: "Pad on the lower thighs, just above the knees. Forefeet on the platform, heels hanging. Drop all the way, hold two seconds at the bottom, rise as high as you can.",
                es: "Almohadilla en la parte baja de los muslos, justo encima de las rodillas. Metatarsos en la plataforma, talones al aire. Baja del todo, aguanta dos segundos abajo y sube al máximo."
            ),
            watchOut: LocalizedText(
                fr: "Faire des demi-répétitions rapides parce que la charge est confortable. Le soléaire est fait d'endurance : il répond à des séries longues avec des pauses en bas, pas à trente petits rebonds.",
                en: "Rattling off fast half-reps because the load feels comfortable. The soleus is built for endurance: it answers to long sets with pauses at the bottom, not thirty little bounces.",
                es: "Hacer medias repeticiones rápidas porque la carga es cómoda. El sóleo es de resistencia: responde a series largas con pausas abajo, no a treinta rebotes pequeños."
            )
        ),
        ExerciseBrief(
            id: "hip-adduction",
            what: LocalizedText(
                fr: "Assis, tu resserres les genoux contre une résistance. Les adducteurs sont parmi les muscles les plus souvent blessés au sport, et presque jamais entraînés : celui-ci est là pour ça.",
                en: "Seated, you squeeze the knees together against resistance. Adductors are among the most commonly injured muscles in sport and almost never trained: this is what fixes that.",
                es: "Sentado, juntas las rodillas contra una resistencia. Los aductores están entre los músculos más lesionados en el deporte y casi nunca se entrenan: este ejercicio existe para eso."
            ),
            setup: LocalizedText(
                fr: "Ouvre au départ seulement jusqu'où c'est confortable, puis gagne quelques degrés de semaine en semaine. Referme lentement, et ouvre encore plus lentement : c'est l'ouverture freinée qui protège.",
                en: "Open only as far as is comfortable at first, then gain a few degrees week by week. Close slowly and open even more slowly: the controlled opening is what protects you.",
                es: "Al principio abre solo hasta donde resulte cómodo y gana unos grados cada semana. Cierra despacio y abre aún más despacio: la apertura frenada es la que protege."
            ),
            watchOut: LocalizedText(
                fr: "Charger lourd et se laisser écarter d'un coup en fin de série. C'est exactement le geste qui déchire un adducteur, reproduit sur une machine. Léger, complet, et jamais de retour lâché.",
                en: "Loading heavy and letting the legs be pulled apart at the end of a set. That is precisely the movement that tears an adductor, reproduced on a machine. Light, full range, and never a dropped return.",
                es: "Cargar mucho y dejarse abrir de golpe al final de la serie. Es justo el gesto que rompe un aductor, reproducido en una máquina. Ligero, completo y nunca soltar la vuelta."
            )
        ),
        ExerciseBrief(
            id: "chest-supported-row-machine",
            what: LocalizedText(
                fr: "Le rowing buste calé, en version machine. Le siège et le coussin font tout le travail de position : il ne reste plus qu'à tirer, ce qui en fait le tirage horizontal le plus facile à bien exécuter.",
                en: "The chest-supported row, machine version. Seat and pad do all the positioning work: all that is left is to pull, which makes it the easiest horizontal row to perform well.",
                es: "El remo con pecho apoyado, en versión máquina. El asiento y la almohadilla hacen todo el trabajo de colocación: solo queda tirar, lo que lo convierte en el remo horizontal más fácil de ejecutar bien."
            ),
            setup: LocalizedText(
                fr: "Règle le siège pour que les poignées arrivent à hauteur du bas des pectoraux. Poitrine collée au coussin, et laisse les omoplates s'écarter complètement à chaque retour.",
                en: "Set the seat so the handles sit at lower-chest height. Chest against the pad, and let the shoulder blades spread fully on every return.",
                es: "Ajusta el asiento para que las empuñaduras queden a la altura del pectoral inferior. Pecho pegado a la almohadilla, y deja que las escápulas se separen del todo en cada vuelta."
            ),
            watchOut: LocalizedText(
                fr: "Tirer avec les bras sans jamais bouger les omoplates. Sur une machine confortable c'est facile à ne pas remarquer : le dos ne travaille que si les omoplates se serrent, les bras ne sont que des crochets.",
                en: "Pulling with the arms while the shoulder blades never move. On a comfortable machine that is easy to miss: the back only works if the blades pinch — the arms are just hooks.",
                es: "Tirar con los brazos sin mover nunca las escápulas. En una máquina cómoda es fácil no darse cuenta: la espalda solo trabaja si las escápulas se juntan, los brazos solo son ganchos."
            )
        ),
        ExerciseBrief(
            id: "t-bar-row",
            what: LocalizedText(
                fr: "Un rowing sur une barre fixée au sol par un bout. La prise neutre et rapprochée charge fort le milieu du dos, et l'axe fixe rend la trajectoire plus stable qu'une barre libre.",
                en: "A row on a bar pinned to the floor at one end. The close neutral grip loads the mid-back hard, and the fixed pivot makes the path steadier than a free bar.",
                es: "Un remo con una barra fijada al suelo por un extremo. El agarre neutro y cerrado carga con fuerza la parte media de la espalda, y el eje fijo hace la trayectoria más estable que con barra libre."
            ),
            setup: LocalizedText(
                fr: "Pieds de part et d'autre de la barre, buste à quarante-cinq degrés, dos plat. La barre vient au nombril, pas à la poitrine. Genoux fléchis assez pour que le dos ne fasse pas tout le travail de maintien.",
                en: "Feet either side of the bar, torso at forty-five degrees, back flat. The bar comes to the navel, not the chest. Knees bent enough that your back is not doing all the holding.",
                es: "Pies a ambos lados de la barra, torso a cuarenta y cinco grados, espalda plana. La barra llega al ombligo, no al pecho. Rodillas flexionadas lo suficiente para que la espalda no haga todo el sostén."
            ),
            watchOut: LocalizedText(
                fr: "Empiler les disques jusqu'à ne plus pouvoir descendre, parce que la barre touche le sol avant que les bras soient tendus. Tu perds alors l'étirement, qui est la moitié utile du mouvement : moins de disques, plus d'amplitude.",
                en: "Stacking plates until the bar hits the floor before your arms straighten. You lose the stretch, which is the useful half of the movement: fewer plates, more range.",
                es: "Apilar discos hasta que la barra toca el suelo antes de que los brazos se estiren. Pierdes el estiramiento, que es la mitad útil del movimiento: menos discos, más recorrido."
            )
        ),
        ExerciseBrief(
            id: "assisted-pull-up",
            what: LocalizedText(
                fr: "La traction avec un contrepoids qui allège ton corps. Ce n'est pas une version au rabais : c'est la seule façon de faire de vraies tractions, complètes et nombreuses, avant d'en avoir la force.",
                en: "The pull-up with a counterweight taking part of your bodyweight. Not a lesser version: the only way to do real pull-ups — full range, decent numbers — before you have the strength.",
                es: "La dominada con un contrapeso que aligera tu cuerpo. No es una versión menor: es la única forma de hacer dominadas reales, completas y numerosas, antes de tener la fuerza."
            ),
            setup: LocalizedText(
                fr: "Règle l'assistance pour réussir huit à dix répétitions propres, pas trois péniblement. Genoux ou pieds bien posés sur la plateforme, corps gainé : elle ne doit pas t'aider à te balancer.",
                en: "Set the assistance to give you eight to ten clean reps, not three grinding ones. Knees or feet firmly on the pad, body braced: it should not be helping you swing.",
                es: "Ajusta la asistencia para lograr ocho o diez repeticiones limpias, no tres a duras penas. Rodillas o pies bien apoyados en la plataforma, cuerpo firme: no debe ayudarte a balancearte."
            ),
            watchOut: LocalizedText(
                fr: "Garder la même assistance pendant des mois. Elle doit baisser d'un cran dès que douze répétitions passent : sans ça, la machine te maintient exactement au niveau où tu es entré.",
                en: "Keeping the same assistance for months. It should come down a notch as soon as twelve reps go by: otherwise the machine keeps you exactly at the level you walked in with.",
                es: "Mantener la misma asistencia durante meses. Debe bajar un punto en cuanto salgan doce repeticiones: si no, la máquina te mantiene justo en el nivel con el que entraste."
            )
        ),
        ExerciseBrief(
            id: "machine-pullover",
            what: LocalizedText(
                fr: "Bras presque tendus, tu ramènes une barre d'au-dessus de la tête vers les cuisses. Le coude ne travaille pas, donc les dorsaux travaillent seuls — sur une amplitude bien plus grande qu'un tirage.",
                en: "Arms nearly straight, you bring a bar from overhead down to your thighs. The elbow does not work, so the lats work alone — over far more range than any pulldown.",
                es: "Con los brazos casi rectos, llevas una barra desde encima de la cabeza hasta los muslos. El codo no trabaja, así que los dorsales trabajan solos, con mucho más recorrido que un jalón."
            ),
            setup: LocalizedText(
                fr: "Siège réglé pour que l'axe de la machine soit à hauteur d'épaule. Dos plaqué, côtes basses. Laisse les bras partir loin derrière la tête au départ : c'est cet étirement qui justifie l'exercice.",
                en: "Seat set so the machine's pivot sits at shoulder height. Back flat, ribs down. Let the arms travel far behind your head at the start: that stretch is the whole point.",
                es: "Asiento ajustado para que el eje de la máquina quede a la altura del hombro. Espalda pegada, costillas bajas. Deja que los brazos vayan lejos por detrás de la cabeza al inicio: ese estiramiento justifica el ejercicio."
            ),
            watchOut: LocalizedText(
                fr: "Cambrer le bas du dos pour aller chercher plus d'étirement en haut. L'amplitude gagnée vient alors de la colonne, pas de l'épaule. Garde les côtes basses même si ça coûte dix degrés.",
                en: "Arching the low back to chase more stretch overhead. The range you gain comes from your spine, not your shoulder. Keep the ribs down even if it costs ten degrees.",
                es: "Arquear la zona lumbar para buscar más estiramiento arriba. El recorrido ganado viene de la columna, no del hombro. Mantén las costillas bajas aunque cueste diez grados."
            )
        ),
        ExerciseBrief(
            id: "single-arm-lat-pulldown",
            what: LocalizedText(
                fr: "Le tirage vertical à un bras. Sans l'autre côté pour compenser, le dorsal faible ne peut plus se cacher — et l'amplitude est plus grande parce que rien ne bloque au milieu.",
                en: "The vertical pull with one arm. With no other side to compensate, the weaker lat can no longer hide — and the range is longer because nothing blocks in the middle.",
                es: "El jalón vertical a un brazo. Sin el otro lado para compensar, el dorsal débil ya no puede esconderse, y el recorrido es mayor porque nada bloquea en el centro."
            ),
            setup: LocalizedText(
                fr: "Poignée simple, assis ou à genoux face à la poulie. Laisse l'épaule monter complètement en position haute, puis descends-la avant de plier le coude : l'épaule d'abord, le bras ensuite.",
                en: "Single handle, seated or kneeling facing the pulley. Let the shoulder rise fully at the top, then pull it down before you bend the elbow: shoulder first, arm second.",
                es: "Agarre simple, sentado o de rodillas frente a la polea. Deja que el hombro suba del todo arriba y bájalo antes de flexionar el codo: primero el hombro, luego el brazo."
            ),
            watchOut: LocalizedText(
                fr: "Faire tourner le buste pour aider. Le corps doit rester de face : si ton épaule opposée recule à chaque répétition, tu travailles la rotation du tronc et pas le dorsal.",
                en: "Twisting the torso to help. The body stays square: if your opposite shoulder pulls back on every rep, you are training trunk rotation, not your lat.",
                es: "Girar el torso para ayudar. El cuerpo se queda de frente: si el hombro contrario retrocede en cada repetición, entrenas la rotación del tronco y no el dorsal."
            )
        ),
        ExerciseBrief(
            id: "single-arm-cable-row",
            what: LocalizedText(
                fr: "Le tirage horizontal à un bras sur poulie. Chaque côté travaille seul, avec une tension constante et une amplitude plus longue qu'à deux mains.",
                en: "The horizontal cable row with one arm. Each side works alone, with constant tension and a longer range than two-handed.",
                es: "El remo horizontal a un brazo en polea. Cada lado trabaja solo, con tensión constante y más recorrido que a dos manos."
            ),
            setup: LocalizedText(
                fr: "Assis ou debout en fente, main libre sur la cuisse. Laisse le bras s'allonger et l'omoplate s'écarter complètement, puis tire le coude vers la hanche en gardant les épaules à la même hauteur.",
                en: "Seated, or standing in a split stance with the free hand on your thigh. Let the arm lengthen and the shoulder blade spread fully, then drive the elbow to the hip with both shoulders level.",
                es: "Sentado o de pie en zancada, con la mano libre en el muslo. Deja que el brazo se alargue y la escápula se separe del todo, luego lleva el codo a la cadera con los hombros a la misma altura."
            ),
            watchOut: LocalizedText(
                fr: "Terminer la traction par une rotation du buste. Ça donne l'impression d'aller plus loin, mais c'est la colonne qui tourne sous charge : le dos, lui, n'a rien gagné.",
                en: "Finishing the pull with a torso twist. It feels like more range, but it is your spine rotating under load: your back gained nothing.",
                es: "Terminar el tirón con una rotación del torso. Parece más recorrido, pero es la columna girando bajo carga: la espalda no ha ganado nada."
            )
        ),
        ExerciseBrief(
            id: "smith-row",
            what: LocalizedText(
                fr: "Le rowing sur barre guidée. La barre monte en ligne droite, donc tu n'as plus à la stabiliser : toute l'énergie va dans le dos, et le buste peut rester figé plus facilement.",
                en: "The row on a guided bar. The bar travels straight up, so you no longer stabilise it: all the energy goes into your back, and the torso is easier to keep frozen.",
                es: "El remo en barra guiada. La barra sube en línea recta, así que no tienes que estabilizarla: toda la energía va a la espalda y el torso se mantiene fijo más fácilmente."
            ),
            setup: LocalizedText(
                fr: "Place-toi pour que la ligne verticale de la barre croise ton nombril, pas ta poitrine : c'est ce placement qui décide quel morceau du dos travaille, et il se règle avant la première répétition.",
                en: "Stand so the bar's vertical line meets your navel, not your chest: that placement decides which part of your back works, and it is set before the first rep.",
                es: "Colócate de forma que la línea vertical de la barra cruce tu ombligo, no el pecho: esa colocación decide qué parte de la espalda trabaja, y se ajusta antes de la primera repetición."
            ),
            watchOut: LocalizedText(
                fr: "Se redresser progressivement au fil de la série. Comme la barre ne peut pas suivre le buste, tu finis par tirer dans un angle qui ne charge plus rien. Repère un point au sol et garde-le dans le regard.",
                en: "Standing up gradually through the set. Since the bar cannot follow your torso, you end up pulling at an angle that loads nothing. Pick a spot on the floor and keep your eyes on it.",
                es: "Incorporarse poco a poco durante la serie. Como la barra no puede seguir al torso, acabas tirando en un ángulo que ya no carga nada. Elige un punto en el suelo y mantén la mirada ahí."
            )
        ),
    ]
}
