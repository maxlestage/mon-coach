import Foundation

// Les fiches des mouvements de jambes et de hanches.
//
// Chaque fiche dit trois choses que la fiche de famille ne peut pas dire :
// ce que ce mouvement-là donne, comment on le règle, et l'erreur qui lui est
// propre. Tout le reste — muscles, séries, repos, matériel — se déduit du
// catalogue et n'est jamais recopié ici.
extension ExerciseBriefs {

    static let legs: [ExerciseBrief] = [
        ExerciseBrief(
            id: "back-squat",
            what: LocalizedText(
                fr: "La barre sur le haut du dos, tu t'accroupis et tu remontes. C'est le mouvement qui charge le plus de muscle d'un coup, et celui qui progresse le plus vite les six premiers mois.",
                en: "Bar across the upper back, you sit down and stand back up. It loads more muscle at once than anything else, and it progresses fastest in the first six months.",
                es: "La barra sobre la parte alta de la espalda, te pones en cuclillas y subes. Es el movimiento que carga más músculo de una vez, y el que progresa más rápido los primeros seis meses."
            ),
            setup: LocalizedText(
                fr: "Barre posée sur les trapèzes, pas sur les cervicales. Crochets à hauteur de sternum : si tu dois te mettre sur la pointe des pieds pour la sortir, ils sont trop hauts. Deux pas en arrière, pas quatre — sortir de la cage fatigue déjà.",
                en: "Bar on the traps, never on the neck bones. Hooks at sternum height: if you have to go on tiptoe to lift it out, they are too high. Two steps back, not four — walking out already costs you.",
                es: "Barra sobre los trapecios, nunca sobre las cervicales. Ganchos a la altura del esternón: si tienes que ponerte de puntillas para sacarla, están demasiado altos. Dos pasos atrás, no cuatro: salir de la jaula ya cansa."
            ),
            watchOut: LocalizedText(
                fr: "Le buste qui plonge en avant pendant que les hanches montent plus vite que les épaules : la barre finit sur le bas du dos. Si ça arrive à la troisième répétition, la charge est trop lourde — pas ta technique.",
                en: "The chest diving forward while the hips rise faster than the shoulders: the bar ends up on your low back. If it happens on the third rep, the load is too heavy — not your technique.",
                es: "El pecho que se hunde hacia delante mientras las caderas suben más rápido que los hombros: la barra acaba en la zona lumbar. Si ocurre en la tercera repetición, la carga es excesiva, no tu técnica."
            )
        ),
        ExerciseBrief(
            id: "front-squat",
            what: LocalizedText(
                fr: "La barre devant, posée sur les épaules. Le buste reste bien plus droit qu'au squat barre : les quadriceps prennent davantage, le bas du dos beaucoup moins.",
                en: "Bar in front, resting on the shoulders. The torso stays far more upright than in a back squat: the quads take more, the low back much less.",
                es: "La barra delante, apoyada en los hombros. El torso queda mucho más recto que en la sentadilla trasera: los cuádriceps se llevan más y la zona lumbar mucho menos."
            ),
            setup: LocalizedText(
                fr: "La barre repose sur le creux des épaules, pas dans les mains : les doigts ne font que l'empêcher de rouler. Coudes le plus haut possible, bras parallèles au sol. Si tes poignets crient, croise les bras sur la barre plutôt que de forcer la prise.",
                en: "The bar sits in the shelf of your shoulders, not in your hands: the fingers only stop it rolling. Elbows as high as you can, upper arms parallel to the floor. If your wrists scream, cross your arms over the bar instead of forcing the grip.",
                es: "La barra descansa en el hueco de los hombros, no en las manos: los dedos solo evitan que ruede. Codos lo más altos posible, brazos paralelos al suelo. Si te duelen las muñecas, cruza los brazos sobre la barra en vez de forzar el agarre."
            ),
            watchOut: LocalizedText(
                fr: "Les coudes qui tombent. Dès qu'ils descendent, la barre glisse vers l'avant et tu la rattrapes avec le dos. C'est le seul signal à surveiller, et il vient avant l'échec musculaire : arrête la série quand ils lâchent.",
                en: "The elbows dropping. The moment they fall, the bar slides forward and your back catches it. It is the one signal to watch, and it comes before muscular failure: end the set when they give.",
                es: "Los codos que caen. En cuanto bajan, la barra se desliza hacia delante y la recoges con la espalda. Es la única señal a vigilar, y llega antes del fallo muscular: termina la serie cuando cedan."
            )
        ),
        ExerciseBrief(
            id: "goblet-squat",
            what: LocalizedText(
                fr: "Un haltère tenu contre la poitrine. Le contrepoids devant t'oblige à rester droit tout seul : c'est le squat qui s'apprend en une séance au lieu de trois mois.",
                en: "A dumbbell held against the chest. The counterweight in front keeps you upright by itself: this is the squat you learn in one session instead of three months.",
                es: "Una mancuerna sujeta contra el pecho. El contrapeso delante te obliga a mantenerte recto por sí solo: es la sentadilla que se aprende en una sesión en vez de en tres meses."
            ),
            setup: LocalizedText(
                fr: "L'haltère à la verticale, tenue par la tête du haut, coudes collés au buste et pointés vers le sol. Pieds un peu plus larges que les épaules pour laisser la place aux coudes entre les genoux en bas.",
                en: "Dumbbell vertical, held by the top head, elbows tucked and pointing down. Feet slightly wider than shoulders so the elbows have room between the knees at the bottom.",
                es: "La mancuerna en vertical, sujeta por la cabeza superior, codos pegados al torso y apuntando al suelo. Pies algo más anchos que los hombros para que los codos quepan entre las rodillas abajo."
            ),
            watchOut: LocalizedText(
                fr: "Laisser l'haltère s'éloigner du sternum. Dix centimètres d'écart et ce sont tes lombaires qui tiennent la charge à bout de bras. Elle doit rester collée, quitte à prendre plus léger.",
                en: "Letting the dumbbell drift off your sternum. Ten centimetres of gap and your low back is holding the weight at arm's length. It stays glued, even if that means going lighter.",
                es: "Dejar que la mancuerna se aleje del esternón. Diez centímetros de separación y es tu zona lumbar la que sostiene la carga con el brazo extendido. Debe quedar pegada, aunque tengas que bajar peso."
            )
        ),
        ExerciseBrief(
            id: "hack-squat",
            what: LocalizedText(
                fr: "Un squat sur rails, dos calé contre un dossier incliné. La machine tient ton équilibre, donc tu peux aller très près de l'échec sans risque de te retrouver coincé sous une barre.",
                en: "A squat on rails, back braced against an angled pad. The machine holds your balance, so you can push close to failure with no risk of getting pinned under a bar.",
                es: "Una sentadilla sobre raíles, con la espalda apoyada en un respaldo inclinado. La máquina sostiene tu equilibrio, así que puedes acercarte al fallo sin riesgo de quedarte atrapado bajo una barra."
            ),
            setup: LocalizedText(
                fr: "Pieds au milieu du plateau, écartement des épaules : plus haut ça devient fessiers, plus bas ça écrase les genoux. Le bas du dos doit rester en contact avec le dossier pendant toute la descente.",
                en: "Feet mid-platform, shoulder width: higher turns it into glutes, lower crushes the knees. Your low back stays in contact with the pad through the whole descent.",
                es: "Pies en el centro de la plataforma, a la anchura de los hombros: más arriba pasa a glúteos, más abajo machaca las rodillas. La zona lumbar debe permanecer en contacto con el respaldo durante toda la bajada."
            ),
            watchOut: LocalizedText(
                fr: "Le bassin qui s'enroule en bas et décolle du dossier. Tu ne le sens pas sur le moment, et tu le sens le lendemain dans le bas du dos. Descends seulement jusqu'où le contact tient.",
                en: "The pelvis tucking at the bottom and lifting off the pad. You do not feel it at the time; you feel it the next day in your low back. Descend only as far as the contact holds.",
                es: "La pelvis que se enrolla abajo y se despega del respaldo. No lo notas en el momento, lo notas al día siguiente en la zona lumbar. Baja solo hasta donde el contacto aguante."
            )
        ),
        ExerciseBrief(
            id: "leg-press",
            what: LocalizedText(
                fr: "Assis, tu pousses un plateau chargé avec les jambes. Beaucoup de charge pour zéro exigence d'équilibre : c'est le moyen le plus simple d'ajouter du volume aux cuisses quand le squat a déjà tout pris.",
                en: "Seated, you push a loaded platform with your legs. Plenty of load with no balance demand: the simplest way to add quad volume once squats have taken everything.",
                es: "Sentado, empujas una plataforma cargada con las piernas. Mucha carga y ninguna exigencia de equilibrio: la forma más sencilla de añadir volumen de cuádriceps cuando la sentadilla ya se lo ha llevado todo."
            ),
            setup: LocalizedText(
                fr: "Pieds à mi-hauteur du plateau, écartement des hanches. Fesses et bas du dos plaqués : si le siège se règle, avance-le jusqu'à ce que tes genoux arrivent à la poitrine sans que le bassin bouge.",
                en: "Feet mid-platform, hip width. Glutes and low back flat on the seat: if it adjusts, bring it forward until your knees reach your chest without the pelvis moving.",
                es: "Pies a media altura de la plataforma, a la anchura de las caderas. Glúteos y lumbares pegados: si el asiento se regula, adelántalo hasta que las rodillas lleguen al pecho sin que la pelvis se mueva."
            ),
            watchOut: LocalizedText(
                fr: "Verrouiller les genoux en fin de poussée avec deux cents kilos dessus. Ça soulage sur le moment et ça met toute la charge sur l'articulation. Garde toujours un léger angle en haut.",
                en: "Locking the knees at the top under two hundred kilos. It feels like a rest and it dumps the whole load onto the joint. Always keep a slight bend at the top.",
                es: "Bloquear las rodillas al final del empuje con doscientos kilos encima. Alivia en el momento y descarga todo el peso en la articulación. Mantén siempre una ligera flexión arriba."
            )
        ),
        ExerciseBrief(
            id: "bulgarian-split-squat",
            what: LocalizedText(
                fr: "Une jambe devant, le pied arrière posé sur un banc. C'est le mouvement le plus efficace du catalogue pour les fessiers et les quadriceps par kilo soulevé — et le plus détesté, pour la même raison.",
                en: "One leg in front, rear foot on a bench. Kilo for kilo it is the most effective glute and quad movement in the catalogue — and the most hated, for the same reason.",
                es: "Una pierna delante, el pie trasero sobre un banco. Es el movimiento más eficaz del catálogo para glúteos y cuádriceps por kilo levantado, y el más odiado por la misma razón."
            ),
            setup: LocalizedText(
                fr: "Le banc à hauteur de genou, jamais plus haut. Recule jusqu'à ce que ton tibia avant soit vertical en bas : si le genou dépasse largement les orteils, tu es trop près. Pied arrière posé sur le dessus, pas accroché.",
                en: "Bench at knee height, never higher. Step out until your front shin is vertical at the bottom: if the knee travels well past the toes, you are too close. Rear foot resting on top, not hooked.",
                es: "El banco a la altura de la rodilla, nunca más alto. Aléjate hasta que la tibia delantera quede vertical abajo: si la rodilla sobrepasa mucho los dedos, estás demasiado cerca. Pie trasero apoyado encima, no enganchado."
            ),
            watchOut: LocalizedText(
                fr: "Pousser avec la jambe arrière. Elle n'est qu'un appui : tout doit venir du talon avant. Si tu sens ton quadriceps arrière brûler, avance ton pied avant de dix centimètres.",
                en: "Pushing with the back leg. It is only a kickstand: everything comes from the front heel. If your rear quad is burning, move the front foot ten centimetres further out.",
                es: "Empujar con la pierna trasera. Solo es un apoyo: todo debe venir del talón delantero. Si notas arder el cuádriceps trasero, adelanta diez centímetros el pie delantero."
            )
        ),
        ExerciseBrief(
            id: "bodyweight-squat",
            what: LocalizedText(
                fr: "Le squat sans rien dans les mains. Ce n'est pas un exercice au rabais : c'est là qu'on installe l'amplitude et le contrôle, et il reste dur si on ralentit la descente.",
                en: "The squat with nothing in your hands. Not a lesser exercise: this is where range and control get built, and it stays hard if you slow the descent.",
                es: "La sentadilla sin nada en las manos. No es un ejercicio menor: aquí se instalan el rango y el control, y sigue siendo duro si ralentizas la bajada."
            ),
            setup: LocalizedText(
                fr: "Bras tendus devant à l'horizontale : ça sert de contrepoids et t'empêche de basculer en avant. Descends aussi bas que ton dos reste neutre, pas plus.",
                en: "Arms straight out in front at shoulder height: they act as a counterweight and stop you tipping forward. Go as low as your back stays neutral, no lower.",
                es: "Brazos extendidos al frente a la altura de los hombros: hacen de contrapeso y evitan que te vayas hacia delante. Baja hasta donde la espalda siga neutra, no más."
            ),
            watchOut: LocalizedText(
                fr: "Rebondir en bas pour enchaîner. Le rebond fait le travail à la place des cuisses, et c'est précisément ce qu'on essaie de leur donner. Trois secondes à la descente, marque un temps, remonte.",
                en: "Bouncing at the bottom to chain reps. The bounce does the work instead of your quads, which is exactly the work you were trying to give them. Three seconds down, pause, stand up.",
                es: "Rebotar abajo para encadenar. El rebote hace el trabajo en lugar de los cuádriceps, que es justo el trabajo que querías darles. Tres segundos de bajada, pausa, sube."
            )
        ),
        ExerciseBrief(
            id: "walking-lunge",
            what: LocalizedText(
                fr: "Des fentes qui avancent, un pas après l'autre. Une jambe à la fois, avec un déplacement en plus : le cœur monte, et l'équilibre travaille autant que les cuisses.",
                en: "Lunges that travel, one step after another. One leg at a time with movement on top: your heart rate climbs and balance works as hard as the legs.",
                es: "Zancadas que avanzan, paso a paso. Una pierna cada vez con desplazamiento añadido: el corazón sube y el equilibrio trabaja tanto como las piernas."
            ),
            setup: LocalizedText(
                fr: "Un grand pas, assez long pour que le genou arrière descende sous la hanche sans que le genou avant parte loin devant. Buste droit, regard à dix mètres — regarder ses pieds fait pencher.",
                en: "A long step, long enough for the rear knee to drop below the hip without the front knee shooting forward. Torso tall, eyes ten metres ahead — looking at your feet makes you lean.",
                es: "Un paso largo, suficiente para que la rodilla trasera baje por debajo de la cadera sin que la delantera se vaya hacia delante. Torso erguido, mirada a diez metros: mirarse los pies te inclina."
            ),
            watchOut: LocalizedText(
                fr: "Le genou arrière qui claque au sol. Ça veut dire que tu tombes au lieu de descendre. Si tu ne peux pas contrôler les vingt derniers centimètres, prends des haltères plus légères ou raccourcis la série.",
                en: "The rear knee banging the floor. It means you are falling rather than lowering. If you cannot control the last twenty centimetres, take lighter dumbbells or cut the set short.",
                es: "La rodilla trasera que golpea el suelo. Significa que te dejas caer en vez de bajar. Si no controlas los últimos veinte centímetros, coge mancuernas más ligeras o acorta la serie."
            )
        ),
        ExerciseBrief(
            id: "conventional-deadlift",
            what: LocalizedText(
                fr: "Ramasser une barre au sol et se redresser. C'est le mouvement qui déplace le plus de kilos, et celui qui fatigue le plus longtemps : une séance lourde se paie encore deux jours après.",
                en: "Pick a bar off the floor and stand up. It moves more kilos than anything else, and it fatigues you the longest: a heavy session still costs you two days later.",
                es: "Recoger una barra del suelo y erguirse. Es el movimiento que desplaza más kilos y el que más fatiga a largo plazo: una sesión pesada se paga aún dos días después."
            ),
            setup: LocalizedText(
                fr: "Barre au-dessus du milieu du pied, tibias qui la frôlent presque. Prise juste en dehors des jambes. Avant de tirer, tends les bras et « pousse le sol » : la barre doit décoller sans à-coup, pas être arrachée.",
                en: "Bar over mid-foot, shins almost touching it. Grip just outside the legs. Before you pull, straighten the arms and push the floor away: the bar should break the ground smoothly, not get yanked.",
                es: "Barra sobre la mitad del pie, tibias casi rozándola. Agarre justo por fuera de las piernas. Antes de tirar, estira los brazos y empuja el suelo: la barra debe despegar sin tirón."
            ),
            watchOut: LocalizedText(
                fr: "Le dos qui s'arrondit au décollage. Une seule répétition ainsi et tu peux perdre une semaine. Si tu ne peux pas garder le dos plat en position de départ, surélève la barre sur des blocs — ce n'est pas tricher, c'est adapter.",
                en: "The back rounding as the bar leaves the floor. One rep like that can cost you a week. If you cannot keep a flat back in the start position, raise the bar on blocks — that is not cheating, it is fitting the lift to you.",
                es: "La espalda que se redondea al despegar. Una sola repetición así puede costarte una semana. Si no puedes mantener la espalda plana en la posición inicial, eleva la barra sobre bloques: no es hacer trampa, es adaptar."
            )
        ),
        ExerciseBrief(
            id: "romanian-deadlift",
            what: LocalizedText(
                fr: "La barre part de la taille et descend le long des jambes, genoux presque fixes. C'est l'exercice qui construit les ischio-jambiers et les fessiers dans leur position étirée, là où ils grossissent le plus.",
                en: "The bar starts at the waist and travels down the legs with the knees nearly fixed. It builds hamstrings and glutes in their stretched position, where they grow most.",
                es: "La barra parte de la cintura y baja por las piernas con las rodillas casi fijas. Construye isquiotibiales y glúteos en su posición estirada, donde más crecen."
            ),
            setup: LocalizedText(
                fr: "Genoux déverrouillés puis figés : ils ne bougent plus de la série. Ce sont les hanches qui reculent, comme pour fermer une porte de voiture avec les fesses. La barre reste collée aux cuisses tout le long.",
                en: "Knees unlocked then frozen: they do not move again for the whole set. It is the hips that travel back, as if shutting a car door with your backside. The bar stays glued to the thighs.",
                es: "Rodillas desbloqueadas y luego fijas: no se mueven en toda la serie. Son las caderas las que van hacia atrás, como si cerraras la puerta del coche con el trasero. La barra queda pegada a los muslos."
            ),
            watchOut: LocalizedText(
                fr: "Descendre plus bas que ce que ton étirement permet. Le repère n'est pas le sol : c'est le moment où tu ne sens plus tirer derrière les cuisses parce que le dos a pris le relais. Remonte à ce moment-là.",
                en: "Going lower than your hamstrings allow. The cue is not the floor: it is the moment the pull behind your thighs stops because your back has taken over. Come back up right there.",
                es: "Bajar más de lo que permite tu flexibilidad. La referencia no es el suelo: es el momento en que deja de tirar detrás de los muslos porque la espalda ha tomado el relevo. Sube justo ahí."
            )
        ),
        ExerciseBrief(
            id: "dumbbell-rdl",
            what: LocalizedText(
                fr: "Le soulevé roumain avec deux haltères. Elles descendent plus près du corps qu'une barre et laissent aller un peu plus bas : plus d'étirement, moins de charge.",
                en: "The Romanian deadlift with two dumbbells. They travel closer to the body than a bar and let you go a little lower: more stretch, less load.",
                es: "El peso muerto rumano con dos mancuernas. Bajan más cerca del cuerpo que una barra y permiten llegar algo más abajo: más estiramiento, menos carga."
            ),
            setup: LocalizedText(
                fr: "Haltères devant les cuisses, paumes vers toi, et elles glissent contre la jambe pendant toute la descente. Pieds à largeur de hanches, poids sur le milieu du pied.",
                en: "Dumbbells in front of the thighs, palms facing you, sliding against the leg through the whole descent. Feet hip width, weight through mid-foot.",
                es: "Mancuernas delante de los muslos, palmas hacia ti, deslizándose contra la pierna durante toda la bajada. Pies a la anchura de las caderas, peso en el medio del pie."
            ),
            watchOut: LocalizedText(
                fr: "Les haltères qui partent en avant. Dès qu'elles s'éloignent, le bras de levier double et le bas du dos encaisse la différence. Si tes avant-bras brûlent avant tes ischios, c'est ce qui se passe.",
                en: "The dumbbells drifting forward. The moment they leave your legs the lever doubles and your low back pays the difference. If your forearms burn before your hamstrings, that is what is happening.",
                es: "Las mancuernas que se van hacia delante. En cuanto se separan, el brazo de palanca se duplica y la zona lumbar paga la diferencia. Si te arden los antebrazos antes que los isquios, es eso."
            )
        ),
        ExerciseBrief(
            id: "hip-thrust",
            what: LocalizedText(
                fr: "Dos calé sur un banc, tu montes le bassin avec une barre posée sur les hanches. C'est le seul mouvement qui charge les fessiers au maximum pile en position contractée.",
                en: "Back against a bench, you drive your hips up with a bar across them. It is the one movement that loads the glutes hardest exactly where they are shortest.",
                es: "Con la espalda apoyada en un banco, subes la cadera con una barra sobre ella. Es el único movimiento que carga al máximo los glúteos justo en posición contraída."
            ),
            setup: LocalizedText(
                fr: "Le bord du banc juste sous les omoplates, pas au milieu du dos. Talons sous les genoux quand tu es en haut : si tu les avances, ce sont les ischios qui travaillent. Une mousse épaisse sur la barre, sinon la douleur arrête la série avant les fessiers.",
                en: "The bench edge just under the shoulder blades, not mid-back. Heels under the knees at the top: further forward and the hamstrings take over. Use a thick pad on the bar, or the pain ends the set before your glutes do.",
                es: "El borde del banco justo bajo las escápulas, no en mitad de la espalda. Talones bajo las rodillas arriba: más adelante y trabajan los isquios. Una almohadilla gruesa en la barra, o el dolor acabará la serie antes que los glúteos."
            ),
            watchOut: LocalizedText(
                fr: "Monter en cambrant le bas du dos au lieu de serrer les fessiers. Rentre le menton et garde les côtes basses : la hanche s'arrête quand le buste et les cuisses sont alignés, jamais plus haut.",
                en: "Getting height by arching the low back instead of squeezing the glutes. Tuck the chin and keep the ribs down: the hips stop when torso and thighs line up, never higher.",
                es: "Subir arqueando la zona lumbar en vez de apretar los glúteos. Mete la barbilla y mantén las costillas bajas: la cadera se detiene cuando torso y muslos se alinean, nunca más arriba."
            )
        ),
        ExerciseBrief(
            id: "glute-bridge",
            what: LocalizedText(
                fr: "Le hip thrust au sol, sans banc et sans matériel. L'amplitude est plus courte, mais il se fait n'importe où et il apprend à serrer les fessiers avant de charger.",
                en: "The hip thrust on the floor, no bench and no kit. Shorter range, but it works anywhere and it teaches you to squeeze the glutes before you load them.",
                es: "El hip thrust en el suelo, sin banco ni material. El recorrido es más corto, pero se hace en cualquier sitio y enseña a apretar los glúteos antes de cargar."
            ),
            setup: LocalizedText(
                fr: "Talons assez proches des fessiers pour que tu puisses les toucher du bout des doigts. Pousse dans les talons, pas dans les orteils : ça change tout de suite qui travaille.",
                en: "Heels close enough to your glutes that your fingertips can touch them. Push through the heels, not the toes: it changes who works, immediately.",
                es: "Talones lo bastante cerca de los glúteos como para tocarlos con la punta de los dedos. Empuja con los talones, no con los dedos: cambia de inmediato quién trabaja."
            ),
            watchOut: LocalizedText(
                fr: "Sentir les ischio-jambiers crampés plutôt que les fessiers. C'est le signe que les pieds sont trop loin : rapproche-les de cinq centimètres et recommence.",
                en: "Feeling your hamstrings cramp instead of your glutes. That means the feet are too far out: bring them five centimetres closer and start again.",
                es: "Notar calambres en los isquiotibiales en vez de los glúteos. Señal de que los pies están demasiado lejos: acércalos cinco centímetros y vuelve a empezar."
            )
        ),
        ExerciseBrief(
            id: "back-extension",
            what: LocalizedText(
                fr: "Buste dans le vide sur un banc à 45°, tu te redresses. Ça renforce le bas du dos et les fessiers ensemble — et un bas du dos fort est ce qui rend les autres mouvements sûrs.",
                en: "Torso hanging off a 45° bench, you straighten up. It strengthens the low back and glutes together — and a strong low back is what makes the other lifts safe.",
                es: "El torso en el aire sobre un banco a 45°, te incorporas. Refuerza la zona lumbar y los glúteos juntos, y una lumbar fuerte es lo que hace seguros los demás movimientos."
            ),
            setup: LocalizedText(
                fr: "Le coussin doit s'arrêter juste sous les hanches, pas sur le ventre : trop haut, tu ne peux plus fléchir la hanche et tout se passe dans les vertèbres.",
                en: "The pad stops just below the hip bones, not on your belly: too high and you cannot hinge at the hip, so everything happens in the spine.",
                es: "La almohadilla se detiene justo debajo de las caderas, no sobre el abdomen: demasiado alta y no puedes flexionar la cadera, así que todo ocurre en las vértebras."
            ),
            watchOut: LocalizedText(
                fr: "Monter au-delà de l'alignement pour aller chercher plus d'amplitude. Il n'y a rien à gagner au-dessus de la ligne, et une compression de plus sur les lombaires à chaque répétition.",
                en: "Rising past the straight line to chase range. There is nothing to gain above the line, and one more compression through the low back on every rep.",
                es: "Subir más allá de la alineación buscando recorrido. No hay nada que ganar por encima de la línea, y sí una compresión más en las lumbares en cada repetición."
            )
        ),
        ExerciseBrief(
            id: "kettlebell-swing",
            what: LocalizedText(
                fr: "Une charnière de hanche explosive : la kettlebell part d'entre les jambes et monte à hauteur de poitrine par la seule extension des hanches. Ça travaille la puissance, pas la force maximale.",
                en: "An explosive hip hinge: the kettlebell comes from between the legs and rises to chest height purely from hip extension. It trains power, not maximal strength.",
                es: "Una bisagra de cadera explosiva: la pesa sale de entre las piernas y sube a la altura del pecho solo por la extensión de la cadera. Entrena potencia, no fuerza máxima."
            ),
            setup: LocalizedText(
                fr: "La kettlebell posée à trente centimètres devant toi. Bascule-la vers l'arrière entre les jambes comme une passe de rugby, puis claque les hanches. Les bras ne font que guider — ils ne tirent jamais.",
                en: "Kettlebell set thirty centimetres in front of you. Hike it back between the legs like a rugby pass, then snap the hips. The arms only guide — they never pull.",
                es: "La pesa colocada treinta centímetros delante de ti. Lánzala hacia atrás entre las piernas como un pase de rugby y luego proyecta la cadera. Los brazos solo guían, nunca tiran."
            ),
            watchOut: LocalizedText(
                fr: "En faire un squat avec les bras. Si tu plies beaucoup les genoux et que tu soulèves la kettlebell avec les épaules, tu prendras mal au dos sans jamais travailler les fessiers. Le mouvement est horizontal aux hanches, pas vertical.",
                en: "Turning it into a squat plus an arm raise. Bend the knees a lot and lift with the shoulders and you will hurt your back without ever working the glutes. The movement is horizontal at the hips, not vertical.",
                es: "Convertirlo en una sentadilla con brazos. Si flexionas mucho las rodillas y levantas la pesa con los hombros, te harás daño en la espalda sin trabajar nunca los glúteos. El movimiento es horizontal en la cadera, no vertical."
            )
        ),
    ]
}
