import Foundation

/// Les six écrans de l'application, et ce qu'ils sont censés faire.
public enum AppSection: String, CaseIterable, Sendable, Identifiable, Hashable {
    case today
    case plan
    case running
    case food
    case progress
    case profile

    public var id: String { rawValue }

    public var title: LocalizedText {
        switch self {
        case .today: LocalizedText(fr: "Aujourd'hui", en: "Today", es: "Hoy")
        case .plan: LocalizedText(fr: "Plan", en: "Plan", es: "Plan")
        case .running: LocalizedText(fr: "Course", en: "Running", es: "Carrera")
        case .food: LocalizedText(fr: "Alimentation", en: "Food", es: "Alimentación")
        case .progress: LocalizedText(fr: "Progression", en: "Progress", es: "Progreso")
        case .profile: LocalizedText(fr: "Profil", en: "Profile", es: "Perfil")
        }
    }

    public var symbol: String {
        switch self {
        case .today: "bolt.fill"
        case .plan: "list.bullet.rectangle"
        case .running: "figure.run"
        case .food: "fork.knife"
        case .progress: "chart.line.uptrend.xyaxis"
        case .profile: "person.fill"
        }
    }
}

/// Un geste qu'on fait dans une section, et ce qu'il déclenche.
public struct SectionStep: Sendable, Equatable, Identifiable, Hashable {
    public var id: Int { index }
    public var index: Int
    public var action: LocalizedText
    public var result: LocalizedText

    public init(index: Int, action: LocalizedText, result: LocalizedText) {
        self.index = index
        self.action = action
        self.result = result
    }
}

/// Ce qu'un écran fait, ce qui tourne derrière, et ce qu'il ne fait pas.
///
/// Pourquoi ce type existe
/// -----------------------
/// Une application d'entraînement est une suite d'écrans qui prescrivent des
/// chiffres. Un chiffre prescrit sans qu'on sache d'où il vient ne se suit
/// pas longtemps : à la première séance qui pique, on décide que le coach
/// s'est trompé, et on a raison de le décider si personne n'a jamais expliqué
/// le calcul.
///
/// Chaque section porte donc trois choses. Ce qu'elle fait, en une phrase.
/// Ce qui tourne derrière — la vraie règle, pas une métaphore. Et ce qu'elle
/// **ne fait pas**, écrit noir sur blanc : c'est la partie qu'aucune
/// application ne met, et c'est celle qui évite qu'on lui reproche plus tard
/// une promesse qu'elle n'a jamais faite.
public struct SectionGuide: Sendable, Equatable, Identifiable {
    public var id: AppSection { section }
    public var section: AppSection
    /// La phrase qui dit à quoi sert l'écran.
    public var tagline: LocalizedText
    /// Ce qu'on y fait, geste par geste.
    public var steps: [SectionStep]
    /// Ce qui tourne derrière, dit sans métaphore.
    public var engine: [LocalizedText]
    /// Ce que la section ne fait pas, et pourquoi.
    public var limits: [LocalizedText]

    public init(
        section: AppSection,
        tagline: LocalizedText,
        steps: [SectionStep],
        engine: [LocalizedText],
        limits: [LocalizedText]
    ) {
        self.section = section
        self.tagline = tagline
        self.steps = steps
        self.engine = engine
        self.limits = limits
    }
}

/// Les guides des sections.
public enum SectionGuides {

    public static func guide(for section: AppSection) -> SectionGuide {
        all.first { $0.section == section } ?? all[0]
    }

    public static let all: [SectionGuide] = [
        SectionGuide(
            section: .today,
            tagline: LocalizedText(
                fr: "Ce qu'il y a à faire maintenant, et rien d'autre.",
                en: "What there is to do right now, and nothing else.",
                es: "Lo que hay que hacer ahora, y nada más."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Réponds au check-in : sommeil, courbatures, énergie.",
                        en: "Answer the check-in: sleep, soreness, energy.",
                        es: "Responde al check-in: sueño, agujetas, energía."
                    ),
                    result: LocalizedText(
                        fr: "La séance du jour est réajustée avant que tu la commences, pas après.",
                        en: "Today's session is adjusted before you start it, not after.",
                        es: "La sesión de hoy se ajusta antes de que empieces, no después."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "Ouvre la séance et déroule-la série par série.",
                        en: "Open the session and work through it set by set.",
                        es: "Abre la sesión y ve serie a serie."
                    ),
                    result: LocalizedText(
                        fr: "Chaque série enregistrée nourrit la charge de la fois suivante.",
                        en: "Every logged set feeds the load for next time.",
                        es: "Cada serie registrada alimenta la carga de la próxima vez."
                    )
                ),
                SectionStep(
                    index: 3,
                    action: LocalizedText(
                        fr: "Un jour sans séance, regarde les mouvements proposés dessous.",
                        en: "On a rest day, look at the movements suggested below.",
                        es: "En un día sin sesión, mira los movimientos propuestos debajo."
                    ),
                    result: LocalizedText(
                        fr: "Ce ne sont pas des devoirs : rien n'est compté si tu ne les fais pas.",
                        en: "They are not homework: nothing is counted if you skip them.",
                        es: "No son deberes: no se cuenta nada si no los haces."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "Le score de forme combine ton sommeil, tes courbatures, ton énergie et la charge des sept derniers jours. En dessous d'un certain seuil, le volume du jour baisse — jamais la technique, jamais l'amplitude.",
                    en: "The readiness score combines your sleep, soreness, energy and the last seven days of load. Below a threshold, today's volume comes down — never the technique, never the range.",
                    es: "La puntuación de forma combina sueño, agujetas, energía y la carga de los últimos siete días. Por debajo de un umbral, el volumen del día baja: nunca la técnica, nunca el rango."
                ),
                LocalizedText(
                    fr: "La séance servie est la prochaine que tu n'as pas faite, pas celle du mardi. Un plan qui survit à une séance déplacée est un plan qu'on garde.",
                    en: "The session served is the next one you have not done, not Tuesday's. A plan that survives a moved session is a plan people keep.",
                    es: "La sesión servida es la siguiente que no has hecho, no la del martes. Un plan que sobrevive a una sesión movida es un plan que se mantiene."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Le check-in n'est pas un diagnostic médical. Une douleur articulaire, ce n'est pas de la fatigue : elle se signale pendant la séance, et le mouvement concerné est remplacé.",
                    en: "The check-in is not a medical diagnosis. Joint pain is not fatigue: flag it during the session and the movement gets swapped.",
                    es: "El check-in no es un diagnóstico médico. Un dolor articular no es fatiga: se señala durante la sesión y el movimiento se sustituye."
                ),
            ]
        ),

        SectionGuide(
            section: .plan,
            tagline: LocalizedText(
                fr: "Les semaines qui viennent, et pourquoi elles sont écrites comme ça.",
                en: "The weeks ahead, and why they are written that way.",
                es: "Las semanas que vienen, y por qué están escritas así."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Parcours les semaines du bloc et ouvre une séance.",
                        en: "Browse the weeks of the block and open a session.",
                        es: "Recorre las semanas del bloque y abre una sesión."
                    ),
                    result: LocalizedText(
                        fr: "Tu vois les exercices, les séries et les charges prévues, avec la fiche de chaque mouvement à un appui.",
                        en: "You see the exercises, sets and planned loads, with each movement's card one tap away.",
                        es: "Ves los ejercicios, series y cargas previstas, con la ficha de cada movimiento a un toque."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "Repère la semaine de décharge, marquée comme telle.",
                        en: "Spot the deload week, marked as such.",
                        es: "Localiza la semana de descarga, marcada como tal."
                    ),
                    result: LocalizedText(
                        fr: "Ce n'est pas une semaine perdue : c'est celle où le corps encaisse ce que les trois précédentes ont demandé.",
                        en: "It is not a wasted week: it is the one where the body absorbs what the three before asked of it.",
                        es: "No es una semana perdida: es donde el cuerpo asimila lo que le pidieron las tres anteriores."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "Un bloc dure quatre semaines : trois qui montent, une qui décharge. Le volume monte d'environ dix pour cent par semaine, ce qui est lent — et c'est la seule vitesse qui tient six mois.",
                    en: "A block runs four weeks: three that build, one that unloads. Volume rises about ten percent a week, which is slow — and it is the only speed that holds for six months.",
                    es: "Un bloque dura cuatro semanas: tres que suben y una de descarga. El volumen sube cerca de un diez por ciento semanal, que es lento, y es la única velocidad que aguanta seis meses."
                ),
                LocalizedText(
                    fr: "Les exercices sont choisis d'après ton matériel, tes limitations déclarées et le rendement de chaque mouvement. Changer une seule case du profil réécrit le bloc.",
                    en: "Exercises are picked from your equipment, your declared limitations and each movement's yield. Changing one profile field rewrites the block.",
                    es: "Los ejercicios se eligen según tu material, tus limitaciones declaradas y el rendimiento de cada movimiento. Cambiar un solo campo del perfil reescribe el bloque."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Le plan ne connaît pas ta vie : il ne sait pas que tu pars en déplacement jeudi. Une séance sautée n'est pas perdue, elle attend — mais c'est à toi de bouger, l'application ne devine rien.",
                    en: "The plan does not know your life: it has no idea you travel on Thursday. A skipped session is not lost, it waits — but moving it is on you; the app guesses nothing.",
                    es: "El plan no conoce tu vida: no sabe que viajas el jueves. Una sesión saltada no se pierde, espera, pero moverla es cosa tuya: la aplicación no adivina nada."
                ),
            ]
        ),

        SectionGuide(
            section: .running,
            tagline: LocalizedText(
                fr: "Tout ce qui se fait dehors, mesuré honnêtement.",
                en: "Everything you do outside, measured honestly.",
                es: "Todo lo que haces fuera, medido con honestidad."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Choisis ton sport parmi les quarante-huit, puis démarre.",
                        en: "Pick your sport from the forty-eight, then start.",
                        es: "Elige tu deporte entre los cuarenta y ocho y empieza."
                    ),
                    result: LocalizedText(
                        fr: "Le GPS enregistre, la carte se dessine, et les calories suivent la formule du sport choisi — pas celle de la course.",
                        en: "GPS records, the map draws itself, and calories follow the chosen sport's formula — not running's.",
                        es: "El GPS registra, el mapa se dibuja y las calorías siguen la fórmula del deporte elegido, no la de correr."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "À l'arrivée, regarde les fractions, le dénivelé et l'allure corrigée.",
                        en: "At the end, look at the splits, the elevation and the graded pace.",
                        es: "Al terminar, mira los parciales, el desnivel y el ritmo corregido."
                    ),
                    result: LocalizedText(
                        fr: "L'allure corrigée dit ce que ta sortie aurait valu à plat : c'est la seule façon de comparer une côte et un plat.",
                        en: "Graded pace says what your run would have been on the flat: the only way to compare a hill with a flat.",
                        es: "El ritmo corregido dice lo que habría valido tu salida en llano: la única forma de comparar una cuesta con un llano."
                    )
                ),
                SectionStep(
                    index: 3,
                    action: LocalizedText(
                        fr: "Ouvre la carte des trajets les plus pris.",
                        en: "Open the map of your most-used routes.",
                        es: "Abre el mapa de tus rutas más frecuentes."
                    ),
                    result: LocalizedText(
                        fr: "Un parcours refait trois fois devient une ligne, avec ton meilleur temps dessus.",
                        en: "A route done three times becomes a line, with your best time on it.",
                        es: "Una ruta repetida tres veces se convierte en una línea, con tu mejor tiempo."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "La trace GPS est nettoyée avant d'être mesurée : les points aberrants sont écartés, et l'écran te dit combien l'ont été. Une distance gonflée par un signal qui saute n'est pas une performance.",
                    en: "The GPS trace is cleaned before it is measured: outliers are dropped, and the screen tells you how many. A distance inflated by a jumping signal is not a performance.",
                    es: "La traza GPS se limpia antes de medirse: los puntos aberrantes se descartan y la pantalla te dice cuántos. Una distancia inflada por una señal que salta no es un rendimiento."
                ),
                LocalizedText(
                    fr: "Chaque sport a son coût énergétique propre, tiré du Compendium of Physical Activities. Un vélo n'est pas une course, et l'appliquer aux deux triplait les calories d'une sortie.",
                    en: "Each sport has its own energy cost, from the Compendium of Physical Activities. A ride is not a run, and using one formula for both tripled a ride's calories.",
                    es: "Cada deporte tiene su coste energético, tomado del Compendium of Physical Activities. Una bici no es una carrera, y usar una sola fórmula triplicaba las calorías de una salida."
                ),
                LocalizedText(
                    fr: "Seules la course, le trail et le tapis nourrissent le plan de course. Une sortie vélo compte dans ta fatigue, pas dans ton volume de course.",
                    en: "Only running, trail and treadmill feed the running plan. A ride counts towards your fatigue, not your running volume.",
                    es: "Solo correr, trail y cinta alimentan el plan de carrera. Una salida en bici cuenta en tu fatiga, no en tu volumen de carrera."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Sans capteur cardiaque, aucune zone n'est affichée : les inventer à partir de l'allure donnerait un graphique joli et faux.",
                    en: "With no heart-rate sensor, no zones are shown: inventing them from pace would give a pretty, false chart.",
                    es: "Sin sensor de frecuencia cardíaca no se muestran zonas: inventarlas a partir del ritmo daría un gráfico bonito y falso."
                ),
                LocalizedText(
                    fr: "En salle ou en piscine, le dénivelé n'est pas estimé. Zéro est plus honnête qu'un chiffre déduit du bruit de l'altimètre.",
                    en: "Indoors or in a pool, elevation is not estimated. Zero is more honest than a number derived from altimeter noise.",
                    es: "En interior o en piscina no se estima el desnivel. Cero es más honesto que un número deducido del ruido del altímetro."
                ),
            ]
        ),

        SectionGuide(
            section: .food,
            tagline: LocalizedText(
                fr: "Ce qu'il y a à manger, et ce que tu as vraiment mangé.",
                en: "What there is to eat, and what you actually ate.",
                es: "Qué hay que comer, y qué has comido de verdad."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Regarde les repas du jour et ouvre « Comment le faire ».",
                        en: "Look at today's meals and open “How to make it”.",
                        es: "Mira las comidas del día y abre «Cómo hacerlo»."
                    ),
                    result: LocalizedText(
                        fr: "Des quantités pesables et une recette en quelques lignes : de quoi cuisiner sans chercher ailleurs.",
                        en: "Weighable amounts and a recipe in a few lines: enough to cook without looking elsewhere.",
                        es: "Cantidades pesables y una receta en pocas líneas: suficiente para cocinar sin buscar en otro sitio."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "Photographie ton assiette avec l'appareil photo en haut.",
                        en: "Photograph your plate with the camera at the top.",
                        es: "Fotografía tu plato con la cámara de arriba."
                    ),
                    result: LocalizedText(
                        fr: "La reconnaissance propose ce qu'elle voit, tu corriges, et la journée se recalcule. Deux secondes par repas.",
                        en: "Recognition proposes what it sees, you correct it, and the day recomputes. Two seconds per meal.",
                        es: "El reconocimiento propone lo que ve, tú corriges y el día se recalcula. Dos segundos por comida."
                    )
                ),
                SectionStep(
                    index: 3,
                    action: LocalizedText(
                        fr: "Écarte ce que tu ne manges pas avec la main levée.",
                        en: "Rule out what you do not eat with the raised hand.",
                        es: "Descarta lo que no comes con la mano levantada."
                    ),
                    result: LocalizedText(
                        fr: "Allergie, intolérance ou dégoût : les repas, les recettes et la liste de courses se refont aussitôt sans ces aliments.",
                        en: "Allergy, intolerance or dislike: meals, recipes and the shopping list rebuild at once without those foods.",
                        es: "Alergia, intolerancia o rechazo: comidas, recetas y lista de la compra se rehacen al momento sin esos alimentos."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "Les cibles viennent de ton métabolisme estimé, de ton objectif et de ce que tu as réellement fait cette semaine. Elles bougent quand la balance bouge — sur une tendance de quatre semaines, jamais sur une pesée.",
                    en: "Targets come from your estimated metabolism, your goal and what you actually did this week. They move when the scale moves — on a four-week trend, never on one weigh-in.",
                    es: "Los objetivos vienen de tu metabolismo estimado, tu meta y lo que realmente hiciste esta semana. Se mueven cuando se mueve la báscula: con una tendencia de cuatro semanas, nunca con un pesaje."
                ),
                LocalizedText(
                    fr: "La semaine porte sept dîners différents, et le déjeuner reprend le dîner de la veille : on cuisine une fois, on mange deux fois. C'est ce qui rend la liste de courses achetable.",
                    en: "The week carries seven different dinners, and lunch reuses the previous night's dinner: cook once, eat twice. That is what makes the shopping list buyable.",
                    es: "La semana lleva siete cenas distintas, y la comida repite la cena de la víspera: se cocina una vez, se come dos. Eso hace comprable la lista."
                ),
                LocalizedText(
                    fr: "La reconnaissance d'assiette tourne sur le téléphone. Elle regarde l'image entière puis chacun de ses quartiers, montre tout ce qu'elle a cru voir, et retient les mots que tu lui apprends.",
                    en: "Plate recognition runs on the phone. It looks at the whole image then each of its quarters, shows everything it thought it saw, and remembers the words you teach it.",
                    es: "El reconocimiento de platos funciona en el teléfono. Mira la imagen entera y luego cada cuarto, muestra todo lo que creyó ver y recuerda las palabras que le enseñas."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Une photo ne voit ni le fond de l'assiette ni l'huile de cuisson. Les protéines sont annoncées en fourchette, jamais au gramme : sers-t'en pour une tendance, pas pour un compte.",
                    en: "A photo sees neither the bottom of the plate nor the cooking oil. Protein is given as a range, never to the gram: use it for a trend, not for a count.",
                    es: "Una foto no ve el fondo del plato ni el aceite de cocción. La proteína se da en horquilla, nunca al gramo: úsalo para una tendencia, no para una cuenta."
                ),
                LocalizedText(
                    fr: "Il n'y a pas de journal alimentaire à remplir, et il n'y en aura pas. La seule donnée nutritionnelle demandée est ton poids sur la balance.",
                    en: "There is no food diary to fill in, and there will not be one. The only nutrition data asked of you is your weight on the scale.",
                    es: "No hay diario alimentario que rellenar, ni lo habrá. El único dato nutricional que se te pide es tu peso en la báscula."
                ),
            ]
        ),

        SectionGuide(
            section: .progress,
            tagline: LocalizedText(
                fr: "Ce qui a changé, et sur quelle durée on peut le dire.",
                en: "What has changed, and over what span you can say it.",
                es: "Qué ha cambiado, y en qué plazo se puede afirmar."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Regarde le volume par semaine, sur douze semaines.",
                        en: "Look at the weekly volume, over twelve weeks.",
                        es: "Mira el volumen semanal, en doce semanas."
                    ),
                    result: LocalizedText(
                        fr: "Les semaines sans séance restent des barres vides : un trou est une information, et le cacher donnerait une moyenne fausse.",
                        en: "Weeks without a session stay as empty bars: a gap is information, and hiding it would give a false average.",
                        es: "Las semanas sin sesión siguen siendo barras vacías: un hueco es información, y ocultarlo daría una media falsa."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "Change de mesure : séries, tonnage, séances.",
                        en: "Switch measure: sets, tonnage, sessions.",
                        es: "Cambia de medida: series, tonelaje, sesiones."
                    ),
                    result: LocalizedText(
                        fr: "Les trois ne mentent pas au même endroit — le tonnage ignore le poids du corps, les séries ignorent la charge.",
                        en: "The three do not lie in the same place — tonnage ignores bodyweight, sets ignore load.",
                        es: "Las tres no mienten en el mismo sitio: el tonelaje ignora el peso corporal, las series ignoran la carga."
                    )
                ),
                SectionStep(
                    index: 3,
                    action: LocalizedText(
                        fr: "Pèse-toi le matin à jeun, et note-le dans le profil.",
                        en: "Weigh yourself in the morning, fasted, and log it in the profile.",
                        es: "Pésate por la mañana en ayunas y anótalo en el perfil."
                    ),
                    result: LocalizedText(
                        fr: "Quatre semaines de pesées suffisent à décider si les calories doivent bouger. Une seule ne décide de rien.",
                        en: "Four weeks of weigh-ins are enough to decide whether calories should move. One decides nothing.",
                        es: "Cuatro semanas de pesajes bastan para decidir si las calorías deben moverse. Uno solo no decide nada."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "La force estimée vient de chaque série enregistrée, charge et répétitions comprises, corrigée par le RPE que tu as donné. Ce n'est pas un maximum testé : c'est ce que tes séries laissent déduire.",
                    en: "Estimated strength comes from every logged set, load and reps included, corrected by the RPE you gave. It is not a tested max: it is what your sets let us infer.",
                    es: "La fuerza estimada viene de cada serie registrada, carga y repeticiones incluidas, corregida por el RPE que diste. No es un máximo probado: es lo que tus series permiten deducir."
                ),
                LocalizedText(
                    fr: "La moyenne de référence exclut les semaines vides et la semaine en cours. S'inclure dans sa propre référence adoucit toujours l'écart, et c'est l'écart qu'on veut voir.",
                    en: "The reference average excludes empty weeks and the current week. Including yourself in your own reference always softens the gap, and the gap is what you want to see.",
                    es: "La media de referencia excluye las semanas vacías y la actual. Incluirse en la propia referencia siempre suaviza la diferencia, y es la diferencia lo que queremos ver."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Sous trois semaines de données, aucune tendance n'est annoncée. Deux points reliés par un trait ne sont pas une progression, et le dire vaut mieux que de laisser croire le contraire.",
                    en: "Below three weeks of data, no trend is announced. Two points joined by a line are not progress, and saying so beats letting you believe otherwise.",
                    es: "Con menos de tres semanas de datos no se anuncia ninguna tendencia. Dos puntos unidos por una línea no son un progreso, y decirlo es mejor que dejar creer lo contrario."
                ),
            ]
        ),

        SectionGuide(
            section: .profile,
            tagline: LocalizedText(
                fr: "Tes réglages, tes données, et la porte de sortie.",
                en: "Your settings, your data, and the way out.",
                es: "Tus ajustes, tus datos y la puerta de salida."
            ),
            steps: [
                SectionStep(
                    index: 1,
                    action: LocalizedText(
                        fr: "Mets à jour ton matériel, tes limitations, ton objectif.",
                        en: "Update your equipment, your limitations, your goal.",
                        es: "Actualiza tu material, tus limitaciones, tu objetivo."
                    ),
                    result: LocalizedText(
                        fr: "Le bloc suivant est réécrit avec ces contraintes. Une limitation déclarée retire du catalogue tous les mouvements qui la chargent.",
                        en: "The next block is rewritten with those constraints. A declared limitation removes every movement that loads it.",
                        es: "El siguiente bloque se reescribe con esas restricciones. Una limitación declarada elimina todos los movimientos que la cargan."
                    )
                ),
                SectionStep(
                    index: 2,
                    action: LocalizedText(
                        fr: "Note ton poids, régulièrement et au même moment.",
                        en: "Log your weight, regularly and at the same time.",
                        es: "Anota tu peso, con regularidad y a la misma hora."
                    ),
                    result: LocalizedText(
                        fr: "C'est la seule mesure qui permet de vérifier si tes calories sont justes.",
                        en: "It is the only measure that lets us check whether your calories are right.",
                        es: "Es la única medida que permite comprobar si tus calorías son correctas."
                    )
                ),
                SectionStep(
                    index: 3,
                    action: LocalizedText(
                        fr: "Exporte tout en JSON quand tu veux.",
                        en: "Export everything as JSON whenever you like.",
                        es: "Exporta todo en JSON cuando quieras."
                    ),
                    result: LocalizedText(
                        fr: "Un fichier lisible avec tout ce que tu as entré. Et l'effacement complet est à côté, sans avoir à écrire à personne.",
                        en: "A readable file with everything you entered. And full erasure sits next to it, with nobody to write to.",
                        es: "Un archivo legible con todo lo que has introducido. Y el borrado completo está al lado, sin tener que escribir a nadie."
                    )
                ),
            ],
            engine: [
                LocalizedText(
                    fr: "Tout est écrit dans un fichier, sur ce téléphone. Il n'y a pas de compte, pas de serveur, et rien à synchroniser : c'est pour ça que l'application fonctionne entière en mode avion.",
                    en: "Everything is written to a file, on this phone. There is no account, no server and nothing to sync: that is why the app works entirely in airplane mode.",
                    es: "Todo se escribe en un archivo, en este teléfono. No hay cuenta, ni servidor, ni nada que sincronizar: por eso la aplicación funciona entera en modo avión."
                ),
            ],
            limits: [
                LocalizedText(
                    fr: "Comme rien n'est sur un serveur, rien ne se récupère si tu perds le téléphone sans sauvegarde. L'export JSON est ta sauvegarde : fais-le de temps en temps.",
                    en: "Since nothing is on a server, nothing comes back if you lose the phone with no backup. The JSON export is your backup: do it now and then.",
                    es: "Como nada está en un servidor, nada se recupera si pierdes el teléfono sin copia. La exportación JSON es tu copia: hazla de vez en cuando."
                ),
            ]
        ),
    ]
}
