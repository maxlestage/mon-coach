import Foundation

/// Les fiches des schémas moteurs restants.
///
/// Séparées du premier fichier pour une raison prosaïque : un littéral de
/// dictionnaire de cette taille fait ramer la vérification de types de Swift
/// jusqu'à l'échec de compilation. Deux dictionnaires fusionnés compilent en
/// une seconde.
extension GuidedCatalog {

    static let secondaryPatterns: [MovementPattern: GuidedTechnique] = [
        .verticalPush: GuidedTechnique(
            id: "pattern-vertical-push",
            title: LocalizedText(fr: "Pousser au-dessus de la tête", en: "Pressing overhead", es: "Empujar por encima de la cabeza"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Serrer les fessiers et les abdominaux", en: "Squeeze glutes and abs", es: "Aprieta glúteos y abdomen"),
                    detail: LocalizedText(
                        fr: "Debout, jambes tendues, fessiers contractés. Sans ça, les côtes s'ouvrent et le mouvement se transforme en cambrure du bas du dos.",
                        en: "Standing, legs locked, glutes squeezed. Without that the ribs flare and the movement turns into a low-back arch.",
                        es: "De pie, piernas bloqueadas, glúteos apretados. Sin eso las costillas se abren y el movimiento se convierte en un arqueo lumbar."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tes côtes doivent être « fermées » : le sternum ne pointe pas vers le plafond.",
                        en: "Your ribs should stay down: the sternum does not point at the ceiling.",
                        es: "Tus costillas deben quedar cerradas: el esternón no apunta al techo."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Placer les coudes", en: "Place the elbows", es: "Colocar los codos"),
                    detail: LocalizedText(
                        fr: "Coudes légèrement devant le corps, pas dans son axe. Les mains sont juste à l'extérieur des épaules.",
                        en: "Elbows slightly in front of the body, not in line with it. Hands just outside the shoulders.",
                        es: "Codos ligeramente por delante del cuerpo, no en su eje. Manos justo por fuera de los hombros."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Pousser en dégageant la tête", en: "Press and clear the head", es: "Empujar apartando la cabeza"),
                    detail: LocalizedText(
                        fr: "Recule légèrement la tête au démarrage pour laisser passer la charge, puis avance-la à nouveau une fois la barre au-dessus du front.",
                        en: "Pull your head back slightly at the start to let the load pass, then move it through once the bar clears your forehead.",
                        es: "Retrasa un poco la cabeza al inicio para dejar pasar la carga y vuelve a adelantarla cuando la barra supere la frente."
                    ),
                    checkpoint: LocalizedText(
                        fr: "En haut, tes bras doivent être derrière tes oreilles, pas devant.",
                        en: "At the top, your arms should be behind your ears, not in front.",
                        es: "Arriba, los brazos deben quedar por detrás de las orejas, no delante."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Redescendre", en: "Come back down", es: "Volver a bajar"),
                    detail: LocalizedText(
                        fr: "Deux secondes pour ramener la charge aux épaules, sans la laisser tomber sur les clavicules.",
                        en: "Two seconds to bring the load back to the shoulders, without dropping it onto your collarbones.",
                        es: "Dos segundos para bajar la carga a los hombros, sin dejarla caer sobre las clavículas."
                    )
                ),
            ],
            breathing: LocalizedText(
                fr: "Inspire et bloque en bas, expire une fois la charge verrouillée en haut.",
                en: "Breathe in and brace at the bottom, out once the load is locked overhead.",
                es: "Inspira y bloquea abajo, espira cuando la carga esté fijada arriba."
            ),
            tempo: LocalizedText(fr: "Poussée franche, deux secondes au retour.", en: "Decisive press, two seconds back.", es: "Empuje decidido, dos segundos de vuelta."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu te cambres beaucoup et le bas du dos tire.", en: "You arch hard and your low back complains.", es: "Te arqueas mucho y te tira la lumbar."),
                    cause: LocalizedText(fr: "Manque de mobilité d'épaule : le corps trouve l'amplitude ailleurs.", en: "Not enough shoulder mobility: the body finds the range somewhere else.", es: "Falta de movilidad de hombro: el cuerpo busca el recorrido en otro sitio."),
                    fix: LocalizedText(fr: "Fais-le assis avec un dossier, ou avec des haltères en prise neutre, jusqu'à ce que la mobilité vienne.", en: "Do it seated with a back support, or with dumbbells in a neutral grip, until the mobility comes.", es: "Hazlo sentado con respaldo, o con mancuernas en agarre neutro, hasta que llegue la movilidad.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "La charge part vers l'avant et tu dois avancer d'un pas.", en: "The load drifts forward and you have to step in.", es: "La carga se va hacia delante y tienes que dar un paso."),
                    cause: LocalizedText(fr: "Tu pousses autour de la tête au lieu de la dégager.", en: "You press around your head instead of clearing it.", es: "Empujas rodeando la cabeza en vez de apartarla."),
                    fix: LocalizedText(fr: "Recule la tête d'abord, puis pousse en ligne droite.", en: "Move the head back first, then press in a straight line.", es: "Retrasa primero la cabeza y luego empuja en línea recta.")
                ),
            ],
            easier: LocalizedText(fr: "Version assise avec dossier, ou pompes en position inclinée tête en bas.", en: "Seated version with a back rest, or pike push-ups.", es: "Versión sentada con respaldo, o flexiones en pica."),
            harder: LocalizedText(fr: "Une pause d'une seconde au niveau du front, là où le mouvement est le plus dur.", en: "A one-second pause at forehead height, where the movement is hardest.", es: "Una pausa de un segundo a la altura de la frente, donde el movimiento es más duro."),
            oneThing: LocalizedText(fr: "Fessiers serrés, côtes fermées. Le reste suit.", en: "Glutes tight, ribs down. The rest follows.", es: "Glúteos apretados, costillas abajo. Lo demás viene solo.")
        ),

        .horizontalPull: GuidedTechnique(
            id: "pattern-horizontal-pull",
            title: LocalizedText(fr: "Tirer vers soi", en: "Rowing", es: "Remar"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Fixer le buste", en: "Fix the torso", es: "Fijar el torso"),
                    detail: LocalizedText(
                        fr: "Le buste ne bouge pas de toute la série. S'il se redresse à chaque répétition, ce sont les lombaires qui tirent, pas le dos.",
                        en: "The torso does not move for the whole set. If it rises with every rep, your low back is doing the pulling, not your back.",
                        es: "El torso no se mueve en toda la serie. Si se levanta en cada repetición, tira la lumbar, no la espalda."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Partir bras tendus", en: "Start with straight arms", es: "Empezar con los brazos extendidos"),
                    detail: LocalizedText(
                        fr: "Laisse les omoplates s'écarter complètement au départ. C'est cette amplitude que la plupart des gens ne prennent jamais.",
                        en: "Let the shoulder blades separate fully at the start. That is the range most people never take.",
                        es: "Deja que las escápulas se separen del todo al inicio. Ese es el recorrido que casi nadie usa."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Tirer avec les coudes", en: "Pull with the elbows", es: "Tirar con los codos"),
                    detail: LocalizedText(
                        fr: "Pense à emmener tes coudes vers tes hanches, pas à ramener la barre. Les mains ne sont que des crochets.",
                        en: "Think about driving your elbows to your hips, not about pulling the bar. Your hands are only hooks.",
                        es: "Piensa en llevar los codos hacia las caderas, no en tirar de la barra. Las manos son solo ganchos."
                    ),
                    checkpoint: LocalizedText(
                        fr: "En fin de tirage, tes omoplates doivent s'être rapprochées de trois ou quatre centimètres.",
                        en: "At the end of the pull, your shoulder blades should have closed three or four centimetres.",
                        es: "Al final del tirón, tus escápulas deben haberse juntado tres o cuatro centímetros."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Relâcher en contrôle", en: "Release under control", es: "Soltar con control"),
                    detail: LocalizedText(
                        fr: "Trois secondes pour revenir, en laissant les omoplates s'écarter à nouveau jusqu'au bout.",
                        en: "Three seconds back, letting the shoulder blades open all the way again.",
                        es: "Tres segundos de vuelta, dejando que las escápulas se abran de nuevo por completo."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Expire en tirant, inspire en revenant.", en: "Out on the pull, in on the return.", es: "Espira al tirar, inspira al volver."),
            tempo: LocalizedText(fr: "Une seconde pour tirer, une pause d'une seconde en contraction, trois secondes au retour.", en: "One second to pull, one second squeezed, three seconds back.", es: "Un segundo para tirar, un segundo de contracción, tres de vuelta."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu sens surtout tes biceps.", en: "You mostly feel your biceps.", es: "Notas sobre todo los bíceps."),
                    cause: LocalizedText(fr: "Tu tires avec les mains avant d'engager les omoplates.", en: "You pull with the hands before the shoulder blades engage.", es: "Tiras con las manos antes de activar las escápulas."),
                    fix: LocalizedText(fr: "Commence chaque répétition par un centimètre de mouvement d'omoplates seules, avant de plier les coudes.", en: "Start every rep with one centimetre of shoulder-blade movement alone, before the elbows bend.", es: "Empieza cada repetición con un centímetro de movimiento escapular solo, antes de doblar los codos.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Ton buste se redresse à chaque répétition.", en: "Your torso rises with every rep.", es: "Tu torso se levanta en cada repetición."),
                    cause: LocalizedText(fr: "Charge trop lourde.", en: "Too much load.", es: "Demasiada carga."),
                    fix: LocalizedText(fr: "Baisse de 20 % et passe sur une version appuyée sur un banc, qui rend la triche impossible.", en: "Drop 20 % and switch to a chest-supported version, which makes cheating impossible.", es: "Baja un 20 % y pasa a una versión con apoyo en banco, que impide hacer trampa.")
                ),
            ],
            easier: LocalizedText(fr: "Tirage horizontal à la machine ou avec un élastique, buste stabilisé.", en: "Machine or band row with the torso supported.", es: "Remo en máquina o con banda, con el torso apoyado."),
            harder: LocalizedText(fr: "Pause de deux secondes en fin de tirage, omoplates serrées.", en: "Two-second pause at the top of the pull, blades squeezed.", es: "Pausa de dos segundos al final del tirón, escápulas apretadas."),
            oneThing: LocalizedText(fr: "Les omoplates démarrent le mouvement, les bras le finissent.", en: "The shoulder blades start the movement, the arms finish it.", es: "Las escápulas inician el movimiento, los brazos lo terminan.")
        ),

        .verticalPull: GuidedTechnique(
            id: "pattern-vertical-pull",
            title: LocalizedText(fr: "Tirer vers le bas", en: "Pulling down", es: "Tirar hacia abajo"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Choisir la prise", en: "Choose the grip", es: "Elegir el agarre"),
                    detail: LocalizedText(
                        fr: "Mains un peu plus larges que les épaules. Beaucoup plus large ne recrute pas plus le dos, ça réduit seulement l'amplitude.",
                        en: "Hands slightly wider than the shoulders. Much wider does not recruit more back, it only shortens the range.",
                        es: "Manos algo más abiertas que los hombros. Mucho más ancho no recluta más espalda, solo acorta el recorrido."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Descendre les épaules", en: "Drop the shoulders", es: "Bajar los hombros"),
                    detail: LocalizedText(
                        fr: "Avant de plier les coudes, éloigne tes épaules de tes oreilles. C'est le geste que le grand dorsal fait vraiment.",
                        en: "Before bending the elbows, move your shoulders away from your ears. That is the movement the lats actually make.",
                        es: "Antes de doblar los codos, aleja los hombros de las orejas. Ese es el gesto que hace realmente el dorsal."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Tu dois sentir une tension sous les aisselles avant même que les coudes ne bougent.",
                        en: "You should feel tension under the armpits before the elbows move at all.",
                        es: "Debes notar tensión bajo las axilas antes de que se muevan los codos."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Tirer les coudes vers les côtes", en: "Drive the elbows to the ribs", es: "Llevar los codos a las costillas"),
                    detail: LocalizedText(
                        fr: "Léger recul du buste, poitrine vers la barre. Amène la barre au haut de la poitrine, jamais derrière la nuque.",
                        en: "Lean back slightly, chest towards the bar. Bring the bar to the upper chest, never behind the neck.",
                        es: "Inclínate ligeramente atrás, pecho hacia la barra. Lleva la barra al pecho alto, nunca detrás de la nuca."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Remonter lentement", en: "Let it rise slowly", es: "Subir despacio"),
                    detail: LocalizedText(
                        fr: "Trois secondes, bras complètement tendus en haut. L'étirement complet fait partie du travail.",
                        en: "Three seconds, arms fully straight at the top. The full stretch is part of the work.",
                        es: "Tres segundos, brazos completamente extendidos arriba. El estiramiento completo es parte del trabajo."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Expire en tirant vers le bas, inspire en remontant.", en: "Out on the way down, in on the way up.", es: "Espira al bajar, inspira al subir."),
            tempo: LocalizedText(fr: "Une seconde pour tirer, trois secondes pour remonter.", en: "One second down, three seconds up.", es: "Un segundo para tirar, tres para subir."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu te balances d'avant en arrière.", en: "You swing back and forth.", es: "Te balanceas adelante y atrás."),
                    cause: LocalizedText(fr: "Charge trop lourde pour l'amplitude demandée.", en: "Too much load for the range asked of you.", es: "Demasiada carga para el recorrido pedido."),
                    fix: LocalizedText(fr: "Baisse la charge jusqu'à pouvoir faire dix répétitions sans que le buste bouge.", en: "Cut the load until you can do ten reps with a still torso.", es: "Baja la carga hasta poder hacer diez repeticiones sin mover el torso.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Tes avant-bras lâchent avant ton dos.", en: "Your forearms give out before your back.", es: "Los antebrazos ceden antes que la espalda."),
                    cause: LocalizedText(fr: "La prise est le maillon faible, ce qui est normal au début.", en: "Grip is the weak link, which is normal early on.", es: "El agarre es el eslabón débil, algo normal al principio."),
                    fix: LocalizedText(fr: "Utilise des sangles sur les deux dernières séries seulement, pour que la prise continue à progresser.", en: "Use straps on the last two sets only, so the grip keeps improving.", es: "Usa correas solo en las dos últimas series, para que el agarre siga progresando.")
                ),
            ],
            easier: LocalizedText(fr: "Tirage vertical à la poulie, ou traction assistée par un élastique sous les pieds.", en: "Lat pulldown, or a pull-up assisted by a band under the feet.", es: "Jalón al pecho, o dominada asistida con banda bajo los pies."),
            harder: LocalizedText(fr: "Traction avec cinq secondes de descente contrôlée à chaque répétition.", en: "Pull-ups with a five-second controlled lowering on every rep.", es: "Dominadas con cinco segundos de bajada controlada en cada repetición."),
            oneThing: LocalizedText(fr: "Les épaules descendent avant que les coudes ne plient.", en: "The shoulders drop before the elbows bend.", es: "Los hombros bajan antes de que se doblen los codos.")
        ),

        .lunge: GuidedTechnique(
            id: "pattern-lunge",
            title: LocalizedText(fr: "Travailler une jambe à la fois", en: "Working one leg at a time", es: "Trabajar una pierna a la vez"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Régler la longueur du pas", en: "Set the stride length", es: "Ajustar la longitud del paso"),
                    detail: LocalizedText(
                        fr: "Un pas trop court met tout sur le genou avant, un pas trop long tire sur l'aine. Le bon pas est celui où, en bas, les deux genoux forment un angle droit.",
                        en: "Too short and everything lands on the front knee, too long and the groin gets pulled. The right stride puts both knees at right angles at the bottom.",
                        es: "Un paso corto lo carga todo en la rodilla delantera, uno largo tira de la ingle. El paso correcto deja ambas rodillas en ángulo recto abajo."
                    )
                ),
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Trouver l'équilibre", en: "Find your balance", es: "Encontrar el equilibrio"),
                    detail: LocalizedText(
                        fr: "Fixe un point immobile à trois mètres devant toi. L'équilibre est un problème de regard avant d'être un problème de jambes.",
                        en: "Fix your eyes on a still point three metres ahead. Balance is a problem of gaze before it is a problem of legs.",
                        es: "Fija la mirada en un punto quieto a tres metros. El equilibrio es un problema de mirada antes que de piernas."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Descendre à la verticale", en: "Drop straight down", es: "Bajar en vertical"),
                    detail: LocalizedText(
                        fr: "Le genou arrière descend vers le sol sans le toucher. Ton buste reste vertical, ou légèrement penché si tu veux plus de fessier.",
                        en: "The back knee travels towards the floor without touching it. Torso stays vertical, or leans slightly forward if you want more glute.",
                        es: "La rodilla de atrás baja hacia el suelo sin tocarlo. El torso se mantiene vertical, o algo inclinado si quieres más glúteo."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Ton pied avant reste entièrement au sol, talon compris.",
                        en: "Your front foot stays fully down, heel included.",
                        es: "Tu pie delantero permanece completo en el suelo, talón incluido."
                    )
                ),
                TechniqueStep(
                    index: 4,
                    title: LocalizedText(fr: "Remonter par la jambe avant", en: "Drive through the front leg", es: "Subir con la pierna delantera"),
                    detail: LocalizedText(
                        fr: "Pousse dans le talon avant. La jambe arrière ne sert qu'à l'équilibre : si elle pousse, tu travailles autre chose.",
                        en: "Push through the front heel. The back leg is only for balance: if it pushes, you are training something else.",
                        es: "Empuja con el talón delantero. La pierna trasera solo equilibra: si empuja, estás entrenando otra cosa."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Inspire en descendant, expire en remontant.", en: "In on the way down, out on the way up.", es: "Inspira al bajar, espira al subir."),
            tempo: LocalizedText(fr: "Deux secondes pour descendre, remontée contrôlée. Ce n'est pas un mouvement qui se fait vite.", en: "Two seconds down, controlled drive up. This is not a movement to rush.", es: "Dos segundos para bajar, subida controlada. No es un movimiento para hacer deprisa."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Ton genou avant fait mal.", en: "Your front knee hurts.", es: "Te duele la rodilla delantera."),
                    cause: LocalizedText(fr: "Pas trop court : le genou passe très en avant des orteils avec toute la charge dessus.", en: "Stride too short: the knee travels well past the toes with all the load on it.", es: "Paso demasiado corto: la rodilla se adelanta mucho a los dedos con toda la carga encima."),
                    fix: LocalizedText(fr: "Allonge le pas de dix centimètres et repose plus de poids sur le talon avant.", en: "Lengthen the stride by ten centimetres and put more weight through the front heel.", es: "Alarga el paso diez centímetros y carga más el talón delantero.")
                ),
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu vacilles sur le côté à chaque répétition.", en: "You wobble sideways every rep.", es: "Te tambaleas de lado en cada repetición."),
                    cause: LocalizedText(fr: "Les pieds sont sur la même ligne, comme sur un fil.", en: "The feet are on the same line, as if on a tightrope.", es: "Los pies están en la misma línea, como en la cuerda floja."),
                    fix: LocalizedText(fr: "Écarte les pieds latéralement de la largeur des hanches : c'est deux rails, pas un fil.", en: "Set the feet hip-width apart sideways: it is two rails, not a rope.", es: "Separa los pies lateralmente a la anchura de las caderas: son dos raíles, no una cuerda.")
                ),
            ],
            easier: LocalizedText(fr: "Fente statique en te tenant à un support d'une main, sans charge.", en: "Split squat holding a support with one hand, unloaded.", es: "Zancada estática agarrándote a un apoyo con una mano, sin carga."),
            harder: LocalizedText(fr: "Pied arrière surélevé sur un banc : la jambe avant prend tout.", en: "Rear foot elevated on a bench: the front leg takes everything.", es: "Pie trasero elevado en un banco: la pierna delantera se lo lleva todo."),
            oneThing: LocalizedText(fr: "La jambe avant fait le travail, la jambe arrière tient l'équilibre.", en: "The front leg does the work, the back leg holds the balance.", es: "La pierna delantera trabaja, la trasera equilibra.")
        ),

        .coreBrace: GuidedTechnique(
            id: "pattern-core",
            title: LocalizedText(fr: "Tenir le tronc", en: "Holding the trunk", es: "Sostener el tronco"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Comprendre ce qu'on cherche", en: "Understand the point", es: "Entender qué se busca"),
                    detail: LocalizedText(
                        fr: "Le rôle des abdominaux n'est pas de plier le tronc, c'est de l'empêcher de bouger. Un gainage réussi est un gainage où rien ne bouge.",
                        en: "The job of your abs is not to bend the trunk, it is to stop it moving. A good brace is one where nothing moves.",
                        es: "La función del abdomen no es doblar el tronco, sino impedir que se mueva. Un buen bloqueo es aquel en el que nada se mueve."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Fermer les côtes", en: "Bring the ribs down", es: "Cerrar las costillas"),
                    detail: LocalizedText(
                        fr: "Rapproche tes côtes de ton bassin d'un ou deux centimètres. Le bas du dos se rapproche du sol : c'est la position à tenir.",
                        en: "Pull your ribs a centimetre or two towards your pelvis. The low back moves closer to the floor: that is the position to hold.",
                        es: "Acerca las costillas a la pelvis uno o dos centímetros. La lumbar se aproxima al suelo: esa es la posición que hay que mantener."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Une main glissée sous tes lombaires doit être serrée, pas libre.",
                        en: "A hand slipped under your low back should be squeezed, not loose.",
                        es: "Una mano deslizada bajo la lumbar debe quedar apretada, no suelta."
                    )
                ),
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Respirer sans lâcher", en: "Breathe without letting go", es: "Respirar sin soltar"),
                    detail: LocalizedText(
                        fr: "Respire par petites inspirations dans les côtes, sans jamais relâcher la position. Un gainage où l'on retient sa respiration ne dure jamais.",
                        en: "Take small breaths into the ribs without ever releasing the position. A brace you hold your breath through never lasts.",
                        es: "Respira en pequeñas inspiraciones hacia las costillas sin soltar nunca la posición. Un bloqueo con la respiración retenida nunca dura."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Respiration courte et continue. Ne jamais bloquer plus de quelques secondes.", en: "Short, continuous breathing. Never hold for more than a few seconds.", es: "Respiración corta y continua. Nunca bloquear más de unos segundos."),
            tempo: LocalizedText(fr: "Des tenues de 20 à 40 secondes valent mieux qu'une tenue de trois minutes bâclée.", en: "Holds of 20 to 40 seconds beat a sloppy three-minute one.", es: "Sostener de 20 a 40 segundos vale más que tres minutos mal hechos."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu sens le bas du dos et pas les abdominaux.", en: "You feel your low back and not your abs.", es: "Notas la lumbar y no el abdomen."),
                    cause: LocalizedText(fr: "Le bassin est basculé vers l'avant : les lombaires tiennent la position à leur place.", en: "The pelvis is tipped forward: the low back is holding the position instead.", es: "La pelvis está en anteversión: la lumbar sostiene la posición en su lugar."),
                    fix: LocalizedText(fr: "Bascule le bassin en rentrant légèrement les fesses, jusqu'à sentir les abdominaux prendre.", en: "Tuck the pelvis slightly until you feel the abs take over.", es: "Retroversiona un poco la pelvis hasta notar que el abdomen toma el relevo.")
                ),
            ],
            easier: LocalizedText(fr: "Gainage sur les genoux, ou mains sur un banc plutôt qu'au sol.", en: "Plank from the knees, or hands on a bench rather than the floor.", es: "Plancha de rodillas, o manos en un banco en vez del suelo."),
            harder: LocalizedText(fr: "Ajoute un déséquilibre — lever un pied, poser un poids sur le dos — plutôt que d'allonger la durée.", en: "Add instability — lift a foot, place a weight on your back — rather than adding time.", es: "Añade inestabilidad —levanta un pie, pon un peso en la espalda— en vez de más tiempo."),
            oneThing: LocalizedText(fr: "Rien ne bouge. Si quelque chose bouge, c'est trop dur.", en: "Nothing moves. If something moves, it is too hard.", es: "Nada se mueve. Si algo se mueve, es demasiado difícil.")
        ),

        .carry: GuidedTechnique(
            id: "pattern-carry",
            title: LocalizedText(fr: "Porter et marcher", en: "Carrying", es: "Cargar y caminar"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Ramasser la charge correctement", en: "Pick the load up properly", es: "Recoger la carga correctamente"),
                    detail: LocalizedText(
                        fr: "Le ramassage est déjà une charnière de hanche : hanches en arrière, dos plat. La plupart des dos se font mal en ramassant, pas en portant.",
                        en: "The pick-up is already a hip hinge: hips back, flat back. Most backs get hurt picking the load up, not carrying it.",
                        es: "Recoger ya es una bisagra de cadera: cadera atrás, espalda plana. La mayoría de lesiones lumbares ocurren al recoger, no al cargar."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Se grandir", en: "Stand tall", es: "Crecer"),
                    detail: LocalizedText(
                        fr: "Épaules basses et en arrière, sommet du crâne vers le plafond. Les épaules ne remontent pas vers les oreilles, même lourd.",
                        en: "Shoulders down and back, crown of the head towards the ceiling. The shoulders do not creep up, however heavy it is.",
                        es: "Hombros bajos y atrás, coronilla hacia el techo. Los hombros no suben hacia las orejas, por pesado que sea."
                    )
                ),
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Marcher court", en: "Walk with short steps", es: "Caminar con pasos cortos"),
                    detail: LocalizedText(
                        fr: "Petits pas, rythme régulier, pas de balancement latéral. Le but est que le tronc ne bouge pas malgré la charge.",
                        en: "Small steps, steady rhythm, no sideways sway. The point is for the trunk not to move despite the load.",
                        es: "Pasos pequeños, ritmo constante, sin balanceo lateral. El objetivo es que el tronco no se mueva pese a la carga."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Si tu te dandines, la charge est trop lourde ou tes pas sont trop longs.",
                        en: "If you are waddling, the load is too heavy or your steps are too long.",
                        es: "Si te contoneas, la carga es excesiva o tus pasos demasiado largos."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Respire normalement. Un port de charge ne se fait pas en apnée.", en: "Breathe normally. A carry is not done on held breath.", es: "Respira con normalidad. Una carga no se hace en apnea."),
            tempo: LocalizedText(fr: "Des trajets de 30 à 45 secondes, reposés.", en: "Trips of 30 to 45 seconds, well rested.", es: "Recorridos de 30 a 45 segundos, bien descansados."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tes mains lâchent avant tout le reste.", en: "Your hands give out before anything else.", es: "Las manos ceden antes que nada."),
                    cause: LocalizedText(fr: "C'est exactement ce que l'exercice cherche à corriger.", en: "That is exactly what the exercise is meant to fix.", es: "Es justo lo que el ejercicio busca corregir."),
                    fix: LocalizedText(fr: "Ne mets pas de sangles. Réduis la charge et allonge la distance à mesure que la prise progresse.", en: "Do not use straps. Reduce the load and extend the distance as the grip improves.", es: "No uses correas. Reduce la carga y alarga la distancia según mejore el agarre.")
                ),
            ],
            easier: LocalizedText(fr: "Porte d'un seul côté, avec la moitié de la charge : c'est plus dur pour le tronc et plus facile pour les mains.", en: "Carry on one side with half the load: harder on the trunk, easier on the hands.", es: "Carga de un solo lado con la mitad del peso: más duro para el tronco y más fácil para las manos."),
            harder: LocalizedText(fr: "Une seule charge, tenue au-dessus de la tête, bras verrouillé.", en: "A single load held overhead, arm locked.", es: "Una sola carga sostenida sobre la cabeza, brazo bloqueado."),
            oneThing: LocalizedText(fr: "Grand et immobile, du premier au dernier pas.", en: "Tall and still, from the first step to the last.", es: "Alto y quieto, del primer paso al último.")
        ),

        .isolation: GuidedTechnique(
            id: "pattern-isolation",
            title: LocalizedText(fr: "Isoler un muscle", en: "Isolating a muscle", es: "Aislar un músculo"),
            setup: [
                TechniqueStep(
                    index: 1,
                    title: LocalizedText(fr: "Bloquer tout ce qui n'est pas le muscle visé", en: "Lock everything that is not the target", es: "Bloquear todo lo que no sea el objetivo"),
                    detail: LocalizedText(
                        fr: "Appuie-toi, cale-toi, assieds-toi. Sur un mouvement d'isolation, tout ce qui bouge en plus est du travail volé au muscle qu'on vise.",
                        en: "Lean on something, wedge yourself in, sit down. On an isolation movement, anything else that moves is work stolen from the target.",
                        es: "Apóyate, cálzate, siéntate. En un movimiento de aislamiento, todo lo demás que se mueve es trabajo robado al músculo objetivo."
                    )
                ),
            ],
            execution: [
                TechniqueStep(
                    index: 2,
                    title: LocalizedText(fr: "Aller au bout des deux côtés", en: "Reach both ends", es: "Llegar a los dos extremos"),
                    detail: LocalizedText(
                        fr: "Étirement complet d'un côté, contraction complète de l'autre. C'est la position étirée sous charge qui fait le plus grossir un muscle.",
                        en: "Full stretch at one end, full contraction at the other. It is the loaded stretched position that grows a muscle most.",
                        es: "Estiramiento completo en un extremo, contracción completa en el otro. Es la posición estirada bajo carga la que más hace crecer al músculo."
                    ),
                    checkpoint: LocalizedText(
                        fr: "Si tu peux ajouter un centimètre d'amplitude, l'exercice n'est pas terminé.",
                        en: "If you can add a centimetre of range, the exercise is not finished.",
                        es: "Si puedes añadir un centímetro de recorrido, el ejercicio no ha terminado."
                    )
                ),
                TechniqueStep(
                    index: 3,
                    title: LocalizedText(fr: "Retenir le retour", en: "Resist the return", es: "Frenar la vuelta"),
                    detail: LocalizedText(
                        fr: "Trois secondes. Sur un mouvement d'isolation, c'est le retour qui fait tout le travail.",
                        en: "Three seconds. On an isolation movement, the return does all the work.",
                        es: "Tres segundos. En un movimiento de aislamiento, la vuelta hace todo el trabajo."
                    )
                ),
            ],
            breathing: LocalizedText(fr: "Expire dans l'effort, inspire au retour, sans jamais bloquer.", en: "Out on the effort, in on the return, never holding.", es: "Espira en el esfuerzo, inspira en la vuelta, sin bloquear nunca."),
            tempo: LocalizedText(fr: "Une seconde à l'effort, une pause d'une seconde, trois secondes au retour.", en: "One second on the effort, a one-second squeeze, three seconds back.", es: "Un segundo de esfuerzo, un segundo de contracción, tres de vuelta."),
            mistakes: [
                CommonMistake(
                    symptom: LocalizedText(fr: "Tu prends de l'élan avec le corps.", en: "You swing your body to help.", es: "Ayudas con el impulso del cuerpo."),
                    cause: LocalizedText(fr: "Charge trop lourde : sur un mouvement d'isolation, l'ego coûte le résultat.", en: "Too much load: on isolation work, ego costs you the result.", es: "Demasiada carga: en aislamiento, el ego te cuesta el resultado."),
                    fix: LocalizedText(fr: "Divise la charge par deux et fais quinze répétitions strictes. Tu sentiras la différence dès la première série.", en: "Halve the load and do fifteen strict reps. You will feel the difference on the first set.", es: "Reduce la carga a la mitad y haz quince repeticiones estrictas. Notarás la diferencia en la primera serie.")
                ),
            ],
            easier: LocalizedText(fr: "Passe à la machine ou à la poulie : la trajectoire est imposée, la triche devient difficile.", en: "Switch to a machine or a cable: the path is fixed and cheating gets hard.", es: "Pasa a máquina o polea: la trayectoria está fijada y hacer trampa se complica."),
            harder: LocalizedText(fr: "Après la dernière répétition complète, fais trois répétitions partielles dans la zone étirée.", en: "After the last full rep, add three partial reps in the stretched position.", es: "Tras la última repetición completa, añade tres parciales en la zona estirada."),
            oneThing: LocalizedText(fr: "Moins lourd, plus lent, amplitude complète.", en: "Lighter, slower, full range.", es: "Menos peso, más lento, recorrido completo.")
        ),
    ]
}
