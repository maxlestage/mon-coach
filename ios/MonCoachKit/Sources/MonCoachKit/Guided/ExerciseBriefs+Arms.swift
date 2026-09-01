import Foundation

// Les fiches des bras, des épaules latérales et des trapèzes.
extension ExerciseBriefs {

    static let arms: [ExerciseBrief] = [
        ExerciseBrief(
            id: "barbell-curl",
            what: LocalizedText(
                fr: "Le curl à deux mains sur une barre. C'est le mouvement de biceps qui accepte le plus de charge, donc celui où la progression se lit le plus clairement.",
                en: "The two-handed curl on a bar. The biceps movement that takes the most load, so the one where progress reads clearest.",
                es: "El curl a dos manos con barra. Es el movimiento de bíceps que admite más carga, así que en el que mejor se lee el progreso."
            ),
            setup: LocalizedText(
                fr: "Coudes collés aux côtes et fixés là : ils ne partent ni en avant ni en arrière. Prise à largeur d'épaules. Si tes poignets tirent avec une barre droite, prends une barre EZ, ce n'est pas une version au rabais.",
                en: "Elbows pinned to your ribs and left there: they go neither forward nor back. Shoulder-width grip. If a straight bar hurts your wrists, use an EZ bar — it is not a lesser version.",
                es: "Codos pegados a las costillas y fijos ahí: no van ni adelante ni atrás. Agarre a la anchura de los hombros. Si la barra recta te tira de las muñecas, usa una barra EZ, no es una versión menor."
            ),
            watchOut: LocalizedText(
                fr: "Le coup de reins pour lancer la barre. Il ajoute des kilos au compteur et rien aux biceps, et il finit par un bas du dos douloureux à cause d'un exercice de bras. Dos contre un mur si tu ne peux pas t'en empêcher.",
                en: "The hip kick to launch the bar. It adds kilos on paper and nothing to your biceps, and it ends with a sore low back from an arm exercise. Back against a wall if you cannot stop yourself.",
                es: "El tirón de cadera para lanzar la barra. Suma kilos en el papel y nada al bíceps, y acaba en una lumbar dolorida por un ejercicio de brazos. Espalda contra la pared si no puedes evitarlo."
            )
        ),
        ExerciseBrief(
            id: "incline-dumbbell-curl",
            what: LocalizedText(
                fr: "Assis sur un banc incliné, bras qui pendent derrière le corps. Le biceps commence étiré au maximum, et c'est dans cette position qu'il gagne le plus de longueur.",
                en: "Sitting on an inclined bench with the arms hanging behind you. The biceps starts fully stretched, and that is the position where it gains the most.",
                es: "Sentado en un banco inclinado, con los brazos colgando por detrás del cuerpo. El bíceps empieza en máximo estiramiento, y es en esa posición donde más gana."
            ),
            setup: LocalizedText(
                fr: "Dossier à quarante-cinq degrés, dos bien plaqué, bras complètement relâchés vers le sol. Ne remonte pas jusqu'à la verticale : au-delà des trois quarts, la tension tombe et l'intérêt de l'exercice avec.",
                en: "Backrest at forty-five degrees, back flat against it, arms hanging fully towards the floor. Do not curl all the way to vertical: past three quarters the tension drops and the point of the exercise with it.",
                es: "Respaldo a cuarenta y cinco grados, espalda bien pegada, brazos totalmente relajados hacia el suelo. No subas hasta la vertical: pasados tres cuartos la tensión cae y con ella el sentido del ejercicio."
            ),
            watchOut: LocalizedText(
                fr: "Avancer les épaules pour aider en bas. Si l'épaule roule vers l'avant, l'étirement disparaît et l'exercice devient un curl ordinaire assis. Garde les omoplates collées au dossier tout du long.",
                en: "Rolling the shoulders forward to help at the bottom. If the shoulder comes forward the stretch vanishes and it becomes an ordinary seated curl. Keep the shoulder blades on the pad throughout.",
                es: "Adelantar los hombros para ayudar abajo. Si el hombro rueda hacia delante, el estiramiento desaparece y se convierte en un curl sentado normal. Mantén las escápulas pegadas al respaldo."
            )
        ),
        ExerciseBrief(
            id: "hammer-curl",
            what: LocalizedText(
                fr: "Le curl paumes face à face. Cette prise vise le brachial et le long supinateur, les muscles qui poussent le biceps vers le haut et donnent de l'épaisseur au bras vu de côté.",
                en: "The curl with palms facing each other. This grip targets the brachialis and brachioradialis, the muscles that push the biceps up and thicken the arm seen from the side.",
                es: "El curl con las palmas enfrentadas. Este agarre apunta al braquial y al supinador largo, los músculos que empujan el bíceps hacia arriba y dan grosor al brazo visto de lado."
            ),
            setup: LocalizedText(
                fr: "Haltères comme deux marteaux, pouces vers le haut, poignets fermes. Monte le long du corps, pas en travers de la poitrine : le mouvement reste dans le plan de l'épaule.",
                en: "Dumbbells like two hammers, thumbs up, wrists firm. Curl along the body, not across the chest: the movement stays in the plane of the shoulder.",
                es: "Mancuernas como dos martillos, pulgares arriba, muñecas firmes. Sube junto al cuerpo, no cruzando el pecho: el movimiento se queda en el plano del hombro."
            ),
            watchOut: LocalizedText(
                fr: "Prendre plus lourd parce que la prise est plus forte, et se mettre à balancer. La prise neutre permet effectivement plus de charge, mais pas au point de faire bouger le buste.",
                en: "Going heavier because the grip is stronger, then starting to swing. The neutral grip does allow more weight, but not enough to justify the torso moving.",
                es: "Coger más peso porque el agarre es más fuerte y empezar a balancearse. El agarre neutro permite más carga, pero no tanta como para mover el torso."
            )
        ),
        ExerciseBrief(
            id: "cable-curl",
            what: LocalizedText(
                fr: "Le curl à la poulie basse. La tension est constante du début à la fin, alors qu'avec une barre elle s'effondre en haut : c'est le curl qui brûle le plus pour la charge la plus légère.",
                en: "The curl on a low pulley. Tension is constant end to end, where a bar loses it at the top: the curl that burns most for the least weight.",
                es: "El curl en polea baja. La tensión es constante de principio a fin, mientras que con barra se desploma arriba: es el curl que más quema con la carga más ligera."
            ),
            setup: LocalizedText(
                fr: "Debout à un pas de la poulie pour que le câble tire vers le bas et l'arrière. Coudes le long du corps. En haut, marque une seconde : c'est là que la poulie charge encore, contrairement à une barre.",
                en: "Stand one step from the pulley so the cable pulls down and back. Elbows at your sides. Hold a second at the top: that is where the cable still loads you, unlike a bar.",
                es: "De pie a un paso de la polea para que el cable tire hacia abajo y atrás. Codos junto al cuerpo. Arriba, marca un segundo: ahí la polea sigue cargando, al contrario que una barra."
            ),
            watchOut: LocalizedText(
                fr: "Laisser la poulie te ramener le bras d'un coup. Le retour freiné vaut autant que la montée, et sur poulie il est facile de l'oublier parce que rien ne pèse dans la main en bas.",
                en: "Letting the cable snap your arm back down. The controlled return is worth as much as the lift, and on a cable it is easy to forget because nothing feels heavy at the bottom.",
                es: "Dejar que la polea te devuelva el brazo de golpe. La vuelta frenada vale tanto como la subida, y en polea es fácil olvidarlo porque abajo no pesa nada en la mano."
            )
        ),
        ExerciseBrief(
            id: "overhead-cable-extension",
            what: LocalizedText(
                fr: "Bras au-dessus de la tête, tu tends les coudes contre la poulie. C'est la seule position qui étire la longue portion du triceps — celle qui fait la masse du bras, et que les extensions classiques ne touchent pas.",
                en: "Arms overhead, you straighten the elbows against the cable. The only position that stretches the long head of the triceps — the one that makes the arm's bulk, and that ordinary pushdowns never reach.",
                es: "Con los brazos sobre la cabeza, extiendes los codos contra la polea. Es la única posición que estira la porción larga del tríceps, la que da volumen al brazo y que las extensiones normales no tocan."
            ),
            setup: LocalizedText(
                fr: "Dos à la poulie, corde derrière la nuque, un pas en avant. Les coudes pointent vers l'avant et restent immobiles : seuls les avant-bras bougent. Buste légèrement penché pour ne pas cambrer.",
                en: "Back to the pulley, rope behind your neck, one step forward. Elbows point ahead and stay still: only the forearms move. Lean the torso slightly so you do not arch.",
                es: "De espaldas a la polea, cuerda tras la nuca, un paso adelante. Los codos apuntan al frente y no se mueven: solo se mueven los antebrazos. Torso algo inclinado para no arquearte."
            ),
            watchOut: LocalizedText(
                fr: "Les coudes qui s'écartent en fin de poussée. Ça soulage le triceps et met tout sur l'épaule, dans un angle qu'elle n'aime pas. Si tu ne peux pas les garder serrés, allège.",
                en: "The elbows flaring at the end of the push. It unloads the triceps and dumps everything on the shoulder, in an angle it dislikes. If you cannot keep them in, go lighter.",
                es: "Los codos que se abren al final del empuje. Descarga el tríceps y lo pone todo en el hombro, en un ángulo que no le gusta. Si no puedes mantenerlos cerrados, baja el peso."
            )
        ),
        ExerciseBrief(
            id: "skull-crusher",
            what: LocalizedText(
                fr: "Allongé, tu descends une barre vers le front en ne pliant que les coudes. Le triceps travaille en étirement partiel avec beaucoup de charge : c'est l'exercice de bras qui fait le plus de dégâts, dans le bon sens.",
                en: "Lying down, you lower a bar towards your forehead by bending only the elbows. The triceps works in partial stretch under real load: the arm exercise that does the most damage, in the good sense.",
                es: "Tumbado, bajas una barra hacia la frente flexionando solo los codos. El tríceps trabaja en estiramiento parcial con bastante carga: el ejercicio de brazo que más daño hace, en el buen sentido."
            ),
            setup: LocalizedText(
                fr: "Bras légèrement inclinés vers la tête plutôt que parfaitement verticaux : la tension ne tombe jamais à zéro en haut. Descends la barre derrière le crâne, pas sur le front — c'est plus sûr et ça étire davantage.",
                en: "Upper arms tilted slightly towards your head rather than dead vertical: tension never drops to zero at the top. Lower the bar behind your skull, not onto your forehead — safer and it stretches more.",
                es: "Brazos ligeramente inclinados hacia la cabeza en vez de totalmente verticales: la tensión nunca cae a cero arriba. Baja la barra por detrás del cráneo, no sobre la frente: es más seguro y estira más."
            ),
            watchOut: LocalizedText(
                fr: "La douleur pointue au coude. Elle vient presque toujours d'une barre droite et d'une charge trop lourde. Passe à une barre EZ et descends de deux crans : le triceps travaillera autant, le coude tiendra dix ans de plus.",
                en: "The sharp elbow pain. It almost always comes from a straight bar and too much weight. Switch to an EZ bar and drop two notches: the triceps works the same and the elbow lasts ten more years.",
                es: "El dolor punzante en el codo. Casi siempre viene de una barra recta y demasiado peso. Pasa a una barra EZ y baja dos puntos: el tríceps trabajará igual y el codo durará diez años más."
            )
        ),
        ExerciseBrief(
            id: "triceps-pushdown",
            what: LocalizedText(
                fr: "Debout face à une poulie haute, tu tends les coudes vers le bas. Tension constante, aucun risque, et on peut aller à l'échec sans conséquence : l'exercice de triceps le plus simple à bien faire.",
                en: "Standing at a high pulley, you straighten the elbows downwards. Constant tension, no risk, and you can hit failure with no consequence: the easiest triceps exercise to do well.",
                es: "De pie frente a una polea alta, extiendes los codos hacia abajo. Tensión constante, ningún riesgo y puedes llegar al fallo sin consecuencias: el ejercicio de tríceps más fácil de hacer bien."
            ),
            setup: LocalizedText(
                fr: "Coudes verrouillés le long du corps, buste penché de dix degrés pour laisser passer les avant-bras. Barre pour la charge, corde pour l'amplitude — la corde permet d'écarter les mains en bas, ce qui contracte plus fort.",
                en: "Elbows locked at your sides, torso leaning ten degrees so the forearms clear it. Bar for load, rope for range — the rope lets you spread your hands at the bottom, which squeezes harder.",
                es: "Codos bloqueados junto al cuerpo, torso inclinado diez grados para dejar paso a los antebrazos. Barra para carga, cuerda para recorrido: la cuerda permite separar las manos abajo, lo que contrae más."
            ),
            watchOut: LocalizedText(
                fr: "Se pencher sur la barre et pousser avec tout le corps. Dès que les épaules descendent avec les mains, ce sont les pectoraux qui poussent. Le seul repère : les coudes ne quittent jamais les côtes.",
                en: "Leaning over the bar and pushing with the whole body. The moment the shoulders travel down with the hands, your chest is doing the pushing. One cue: the elbows never leave your ribs.",
                es: "Inclinarse sobre la barra y empujar con todo el cuerpo. En cuanto los hombros bajan con las manos, empuja el pectoral. Una sola referencia: los codos no se separan nunca de las costillas."
            )
        ),
        ExerciseBrief(
            id: "close-grip-push-up",
            what: LocalizedText(
                fr: "La pompe mains rapprochées. Les coudes restent le long du corps, donc les triceps portent le mouvement au lieu des pectoraux — sans aucun matériel.",
                en: "The push-up with hands close together. The elbows stay by your sides, so the triceps carry the movement instead of the chest — with no equipment at all.",
                es: "La flexión con las manos juntas. Los codos quedan pegados al cuerpo, así que los tríceps llevan el movimiento en lugar del pectoral, sin ningún material."
            ),
            setup: LocalizedText(
                fr: "Mains sous les épaules, écartées de la largeur des paumes — pas en losange, qui écrase les poignets. Coudes qui frôlent les côtes pendant toute la descente.",
                en: "Hands under the shoulders, about a palm's width apart — not in a diamond, which wrecks the wrists. Elbows brushing the ribs through the whole descent.",
                es: "Manos bajo los hombros, separadas el ancho de una palma, no en diamante, que machaca las muñecas. Codos rozando las costillas durante toda la bajada."
            ),
            watchOut: LocalizedText(
                fr: "Écarter les coudes dès que ça devient dur. À ce moment-là tu fais une pompe normale et les triceps sont sortis du mouvement. Mieux vaut finir sur un banc, mains hautes, coudes serrés.",
                en: "Flaring the elbows as soon as it gets hard. At that point you are doing an ordinary push-up and the triceps have left. Better to finish with your hands on a bench, elbows still tucked.",
                es: "Abrir los codos en cuanto cuesta. En ese momento haces una flexión normal y los tríceps se han ido. Mejor terminar con las manos en un banco, codos pegados."
            )
        ),
        ExerciseBrief(
            id: "wrist-curl",
            what: LocalizedText(
                fr: "Le curl des poignets, avant-bras posés. Ça travaille les fléchisseurs de la main — ceux qui lâchent avant le dos sur un soulevé de terre ou un rowing lourd.",
                en: "The wrist curl, forearms resting. It trains the hand flexors — the ones that give out before your back on a heavy deadlift or row.",
                es: "El curl de muñeca con los antebrazos apoyados. Trabaja los flexores de la mano, los que ceden antes que la espalda en un peso muerto o un remo pesado."
            ),
            setup: LocalizedText(
                fr: "Avant-bras posés sur les cuisses ou un banc, poignets dans le vide. Laisse la barre rouler jusqu'au bout des doigts en bas, puis referme la main avant d'enrouler : c'est la moitié du travail.",
                en: "Forearms on your thighs or a bench, wrists past the edge. Let the bar roll to your fingertips at the bottom, then close the hand before you curl: that is half the work.",
                es: "Antebrazos apoyados en los muslos o un banco, muñecas al aire. Deja que la barra ruede hasta las yemas abajo y luego cierra la mano antes de enrollar: ahí está la mitad del trabajo."
            ),
            watchOut: LocalizedText(
                fr: "Charger comme un curl de biceps. L'amplitude est de quelques centimètres et le muscle est petit : une charge trop lourde ne fait plus que comprimer le poignet. Léger et long, c'est le seul réglage utile.",
                en: "Loading it like a biceps curl. The range is a few centimetres and the muscle is small: too much weight just compresses the wrist. Light and long is the only setting that works.",
                es: "Cargarlo como un curl de bíceps. El recorrido es de pocos centímetros y el músculo es pequeño: demasiado peso solo comprime la muñeca. Ligero y largo es el único ajuste útil."
            )
        ),
        ExerciseBrief(
            id: "lateral-raise",
            what: LocalizedText(
                fr: "Bras qui montent sur les côtés jusqu'à l'horizontale. C'est le seul mouvement qui cible vraiment le faisceau moyen de l'épaule, celui qui donne la largeur — aucun développé ne le fait.",
                en: "Arms rising to the sides up to horizontal. The only movement that genuinely targets the side delt, the one that gives width — no press does that.",
                es: "Brazos que suben por los lados hasta la horizontal. Es el único movimiento que apunta de verdad al deltoides medio, el que da anchura: ningún press lo hace."
            ),
            setup: LocalizedText(
                fr: "Buste penché de dix degrés en avant, coudes très légèrement fléchis et figés. Monte à hauteur d'épaule, pas plus haut : au-delà, ce sont les trapèzes qui prennent le relais.",
                en: "Torso leaning ten degrees forward, elbows slightly bent and locked there. Raise to shoulder height, no higher: past that the traps take over.",
                es: "Torso inclinado diez grados adelante, codos ligeramente flexionados y fijos. Sube hasta la altura del hombro, no más: por encima toman el relevo los trapecios."
            ),
            watchOut: LocalizedText(
                fr: "Hausser les épaules vers les oreilles pour finir. Si tu sens le haut des trapèzes brûler, la charge est trop lourde — et sur cet exercice, trop lourd veut souvent dire quatre kilos au lieu de huit.",
                en: "Shrugging towards your ears to finish. If the top of your traps is burning, the weight is too heavy — and on this exercise, too heavy often means four kilos instead of eight.",
                es: "Encoger los hombros hacia las orejas para terminar. Si te arde la parte alta del trapecio, la carga es excesiva, y en este ejercicio excesivo suele significar cuatro kilos en vez de ocho."
            )
        ),
        ExerciseBrief(
            id: "cable-lateral-raise",
            what: LocalizedText(
                fr: "L'élévation latérale à la poulie basse. Contrairement à un haltère, le câble charge aussi le début du mouvement — la partie où l'épaule est la plus faible et où elle progresse.",
                en: "The lateral raise on a low pulley. Unlike a dumbbell, the cable also loads the start of the movement — the part where the shoulder is weakest and where it improves.",
                es: "La elevación lateral en polea baja. A diferencia de una mancuerna, el cable también carga el inicio del movimiento, la parte donde el hombro es más débil y donde progresa."
            ),
            setup: LocalizedText(
                fr: "Poulie au plus bas, câble qui passe derrière toi et devant les jambes, poignée dans la main opposée. Un pas de côté pour que la tension soit déjà là bras le long du corps.",
                en: "Pulley at its lowest, cable passing behind you and in front of your legs, handle in the opposite hand. Step across so tension is already there with the arm down.",
                es: "Polea en el punto más bajo, cable pasando por detrás de ti y por delante de las piernas, agarre en la mano contraria. Da un paso lateral para que ya haya tensión con el brazo abajo."
            ),
            watchOut: LocalizedText(
                fr: "Tirer le câble en travers du corps plutôt que sur le côté. Le geste doit rester dans le plan de l'épaule, un peu en avant : si ta main finit derrière ton épaule, tu travailles l'arrière et pas le côté.",
                en: "Pulling the cable across your body instead of out to the side. The path stays in the plane of the shoulder, slightly forward: if your hand ends up behind your shoulder, you are training the rear delt, not the side.",
                es: "Tirar del cable cruzando el cuerpo en vez de hacia el lado. El gesto se queda en el plano del hombro, algo adelantado: si la mano acaba detrás del hombro, trabajas la parte posterior, no la lateral."
            )
        ),
        ExerciseBrief(
            id: "face-pull",
            what: LocalizedText(
                fr: "Tu tires une corde vers le visage en écartant les coudes. Ça travaille l'arrière de l'épaule et les rotateurs — les muscles qui compensent tout ce qu'on fait en poussant, et qui manquent à presque tout le monde.",
                en: "You pull a rope towards your face with the elbows high. It works the rear delt and the rotators — the muscles that offset everything you press, and that almost everyone lacks.",
                es: "Tiras de una cuerda hacia la cara separando los codos. Trabaja el deltoides posterior y los rotadores, los músculos que compensan todo lo que empujas y que a casi todo el mundo le faltan."
            ),
            setup: LocalizedText(
                fr: "Poulie à hauteur de visage. Tire la corde en séparant les mains, coudes au-dessus des poignets, jusqu'à ce que les pouces passent de chaque côté de la tête. Finis par une rotation externe, comme pour montrer tes biceps.",
                en: "Pulley at face height. Pull the rope apart, elbows above the wrists, until your thumbs pass either side of your head. Finish with an external rotation, as if showing your biceps.",
                es: "Polea a la altura de la cara. Tira de la cuerda separando las manos, codos por encima de las muñecas, hasta que los pulgares pasen a ambos lados de la cabeza. Termina con una rotación externa, como si enseñaras los bíceps."
            ),
            watchOut: LocalizedText(
                fr: "Le charger comme un rowing. Ce n'est pas un exercice de force : trop lourd, les coudes tombent et ça devient un tirage horizontal médiocre. Léger, lent, et une seconde de contraction en fin de course.",
                en: "Loading it like a row. This is not a strength exercise: too heavy and the elbows drop, turning it into a mediocre horizontal pull. Light, slow, and a one-second squeeze at the end.",
                es: "Cargarlo como un remo. No es un ejercicio de fuerza: con demasiado peso los codos caen y se convierte en un tirón horizontal mediocre. Ligero, lento y un segundo de contracción al final."
            )
        ),
        ExerciseBrief(
            id: "reverse-fly",
            what: LocalizedText(
                fr: "Buste penché, tu écartes deux haltères sur les côtés. C'est l'isolation de l'arrière d'épaule : la partie qu'aucun développé ne touche et qui tient l'articulation en place.",
                en: "Bent over, you spread two dumbbells out to the sides. The rear-delt isolation: the part no press touches, and the one that keeps the joint where it belongs.",
                es: "Con el torso inclinado, separas dos mancuernas hacia los lados. Es el aislamiento del deltoides posterior: la parte que ningún press toca y la que mantiene la articulación en su sitio."
            ),
            setup: LocalizedText(
                fr: "Buste presque parallèle au sol, ou poitrine calée sur un banc incliné si le bas du dos fatigue. Coudes légèrement fléchis et figés : le geste est un écartement, pas un rowing.",
                en: "Torso nearly parallel to the floor, or chest on an incline bench if your low back tires. Elbows slightly bent and locked: this is a spread, not a row.",
                es: "Torso casi paralelo al suelo, o pecho apoyado en un banco inclinado si la lumbar se cansa. Codos algo flexionados y fijos: es una apertura, no un remo."
            ),
            watchOut: LocalizedText(
                fr: "Serrer les omoplates au lieu d'écarter les bras. Ça déplace le travail sur le milieu du dos, qui est déjà servi par les rowings. L'arrière d'épaule travaille quand les bras s'éloignent, pas quand le dos se referme.",
                en: "Pinching the shoulder blades instead of spreading the arms. That shifts the work to the mid-back, which your rows already cover. The rear delt works when the arms travel out, not when the back closes.",
                es: "Juntar las escápulas en vez de separar los brazos. Eso lleva el trabajo a la parte media de la espalda, que ya cubren los remos. El deltoides posterior trabaja cuando los brazos se alejan, no cuando la espalda se cierra."
            )
        ),
        ExerciseBrief(
            id: "band-pull-apart",
            what: LocalizedText(
                fr: "Bras tendus devant, tu écartes un élastique jusqu'à la poitrine. Ça ne coûte presque rien en fatigue et ça se glisse partout : c'est l'exercice d'entretien de l'épaule par excellence.",
                en: "Arms straight out front, you pull a band apart to your chest. It costs almost no fatigue and fits anywhere: the shoulder-maintenance exercise par excellence.",
                es: "Con los brazos extendidos al frente, separas una goma hasta el pecho. Cuesta casi nada de fatiga y cabe en cualquier parte: el ejercicio de mantenimiento del hombro por excelencia."
            ),
            setup: LocalizedText(
                fr: "Élastique à hauteur d'épaules, bras tendus mais pas verrouillés. Écarte jusqu'à ce qu'il touche la poitrine, en gardant les coudes complètement tendus tout du long.",
                en: "Band at shoulder height, arms straight but not locked. Pull until it touches your chest, keeping the elbows fully extended throughout.",
                es: "Goma a la altura de los hombros, brazos estirados pero no bloqueados. Separa hasta que toque el pecho, manteniendo los codos completamente extendidos."
            ),
            watchOut: LocalizedText(
                fr: "Plier les coudes quand l'élastique devient dur. Ça raccourcit le levier et l'exercice ne fait plus rien. Prends un élastique plus souple : mieux vaut vingt répétitions bras tendus que dix bras pliés.",
                en: "Bending the elbows once the band gets hard. It shortens the lever and the exercise stops doing anything. Take a lighter band: twenty reps with straight arms beat ten with bent ones.",
                es: "Flexionar los codos cuando la goma se pone dura. Acorta la palanca y el ejercicio deja de servir. Coge una goma más suave: mejor veinte repeticiones con los brazos rectos que diez doblados."
            )
        ),
        ExerciseBrief(
            id: "shrug",
            what: LocalizedText(
                fr: "Tu montes les épaules vers les oreilles avec une charge dans les mains. C'est l'isolation du haut des trapèzes, le muscle qui remplit l'espace entre le cou et l'épaule.",
                en: "You raise the shoulders towards your ears holding a load. The upper-trap isolation, the muscle that fills the space between neck and shoulder.",
                es: "Subes los hombros hacia las orejas con una carga en las manos. Es el aislamiento del trapecio superior, el músculo que llena el espacio entre el cuello y el hombro."
            ),
            setup: LocalizedText(
                fr: "Bras tendus et relâchés, ils ne servent qu'à porter. Monte tout droit vers les oreilles et marque une seconde en haut : c'est la pause qui fait le travail, l'amplitude étant très courte.",
                en: "Arms straight and relaxed, they only carry. Raise straight towards the ears and hold a second at the top: the pause does the work, since the range is very short.",
                es: "Brazos estirados y relajados, solo sostienen. Sube recto hacia las orejas y marca un segundo arriba: la pausa hace el trabajo, porque el recorrido es muy corto."
            ),
            watchOut: LocalizedText(
                fr: "Faire des cercles avec les épaules. Le trapèze monte et descend, il ne tourne pas : les rotations chargées écrasent la coiffe des rotateurs sans rien ajouter au muscle.",
                en: "Rolling the shoulders in circles. The trap goes up and down, it does not rotate: loaded circles grind the rotator cuff and add nothing to the muscle.",
                es: "Hacer círculos con los hombros. El trapecio sube y baja, no gira: las rotaciones cargadas machacan el manguito rotador y no añaden nada al músculo."
            )
        ),
    ]
}
