import Foundation

/// Un remplacement proposé pour un exercice qu'on ne peut pas faire.
public struct Substitution: Sendable, Equatable, Identifiable {
    public var id: String { exercise.id }
    public var exercise: Exercise
    /// Score de proximité, 0 à 100. Plus il est haut, plus le remplacement
    /// travaille la même chose de la même façon.
    public var closeness: Int
    /// Pourquoi ce mouvement-là, et ce qui change par rapport à l'original.
    public var reason: LocalizedText
}

/// La raison pour laquelle l'exercice prévu ne peut pas se faire.
///
/// Chacune appelle une réponse différente : un appareil pris se contourne en
/// changeant l'ordre de la séance, une douleur ne se contourne pas du tout.
public enum GymObstacle: String, Codable, CaseIterable, Sendable, Identifiable {
    /// L'appareil ou le rack est occupé.
    case equipmentBusy
    /// L'appareil est en panne, ou la salle ne l'a pas.
    case equipmentMissing
    /// Personne pour parer, et la charge est lourde.
    case noSpotter
    /// Une gêne apparaît sur ce mouvement précis.
    case discomfort
    /// Pas assez de temps pour la séance entière.
    case shortOnTime
    /// Trop de monde pour occuper un poste longtemps.
    case crowded

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .equipmentBusy:
            LocalizedText(fr: "L'appareil est pris", en: "The equipment is taken", es: "La máquina está ocupada")
        case .equipmentMissing:
            LocalizedText(fr: "L'appareil n'existe pas ici", en: "This gym does not have it", es: "Aquí no hay esa máquina")
        case .noSpotter:
            LocalizedText(fr: "Personne pour parer", en: "Nobody to spot me", es: "Nadie que me ayude")
        case .discomfort:
            LocalizedText(fr: "Ça tire quelque part", en: "Something is pulling", es: "Me molesta algo")
        case .shortOnTime:
            LocalizedText(fr: "Je n'ai pas le temps", en: "I am short on time", es: "No tengo tiempo")
        case .crowded:
            LocalizedText(fr: "La salle est bondée", en: "The gym is packed", es: "El gimnasio está lleno")
        }
    }
}

/// Ce que le coach répond quand la séance ne peut pas se dérouler comme prévu.
public struct GymAnswer: Sendable, Equatable {
    public var obstacle: GymObstacle
    /// La première chose à faire, en une phrase.
    public var headline: LocalizedText
    public var detail: LocalizedText
    /// Les remplacements proposés, du plus proche au plus éloigné. Vide quand
    /// l'obstacle ne se résout pas par un changement d'exercice.
    public var substitutions: [Substitution]
}

/// Le coach dans la salle, par opposition au coach qui écrit le programme.
///
/// Le programme suppose une salle vide et un athlète frais. La réalité est un
/// rack occupé, une machine en panne, dix-huit heures un mardi. Ce moteur ne
/// change pas le programme : il dit quoi faire à la place, maintenant, sans
/// perdre le stimulus prévu.
public enum GymCoach {

    // MARK: - Remplacer un exercice

    /// Les remplacements possibles pour un exercice, classés par proximité.
    ///
    /// - Parameters:
    ///   - exercise: le mouvement prévu.
    ///   - profile: pour le matériel disponible, les zones sensibles et les
    ///     exercices refusés.
    ///   - excludingEquipment: le matériel indisponible sur le moment — le
    ///     rack occupé, la machine en panne. C'est ce qui distingue « je n'ai
    ///     pas de barre » de « la barre est prise ».
    ///   - limit: nombre maximal de propositions.
    public static func substitutions(
        for exercise: Exercise,
        profile: UserProfile,
        excludingEquipment busy: Set<Equipment> = [],
        limit: Int = 4
    ) -> [Substitution] {
        let candidates: [Exercise] = ExerciseCatalog.available(for: profile).filter { candidate in
            candidate.id != exercise.id
                && candidate.equipment.isDisjoint(with: busy)
                && trains(candidate, like: exercise)
        }
        var proposals: [Substitution] = candidates.map { candidate in
            Substitution(
                exercise: candidate,
                closeness: closeness(of: candidate, to: exercise),
                reason: reason(replacing: exercise, with: candidate)
            )
        }
        // À proximité égale, l'ordre alphabétique : le même écran doit
        // proposer la même chose deux fois de suite, sinon l'athlète croit
        // que le coach hésite.
        proposals.sort { left, right in
            left.closeness == right.closeness
                ? left.exercise.id < right.exercise.id
                : left.closeness > right.closeness
        }
        return Array(varied(proposals).prefix(limit))
    }

    /// Écarte les propositions qui se ressemblent trop pour tenir chacune
    /// une carte.
    ///
    /// Le catalogue contient plusieurs machines par mouvement, et sans cette
    /// coupe la liste des remplacements du développé couché serait « machine,
    /// machine incliné, dips assistés » — trois cartes qui disent la même
    /// chose, prises sur le même appareil, et qui ne laissent aucune place à
    /// une option vraiment différente. Deux par type de matériel suffisent :
    /// la troisième n'apporte rien qu'on ne sache déjà.
    static func varied(_ proposals: [Substitution], perEquipment: Int = 2) -> [Substitution] {
        var kept: [Substitution] = []
        var seen: [Set<Equipment>: Int] = [:]
        for proposal in proposals {
            let count = seen[proposal.exercise.equipment, default: 0]
            guard count < perEquipment else { continue }
            seen[proposal.exercise.equipment] = count + 1
            kept.append(proposal)
        }
        return kept
    }

    /// Un candidat n'est retenu que s'il travaille vraiment le même muscle.
    ///
    /// Le schéma moteur seul ne suffit pas : une élévation latérale et un
    /// développé militaire sont tous deux des poussées d'épaule, mais
    /// remplacer l'un par l'autre change complètement la séance. On exige donc
    /// le même muscle principal, ou le même schéma moteur avec le muscle
    /// principal au moins en secondaire.
    static func trains(_ candidate: Exercise, like exercise: Exercise) -> Bool {
        if candidate.primaryMuscle == exercise.primaryMuscle { return true }
        return candidate.pattern == exercise.pattern
            && candidate.secondaryMuscles.contains(exercise.primaryMuscle)
    }

    /// Score de proximité, 0 à 100.
    static func closeness(of candidate: Exercise, to exercise: Exercise) -> Int {
        var score = 0
        if candidate.primaryMuscle == exercise.primaryMuscle { score += 40 }
        if candidate.pattern == exercise.pattern { score += 25 }
        if candidate.isCompound == exercise.isCompound { score += 15 }
        // Un mouvement qui couvre les mêmes muscles secondaires laisse la
        // séance équilibrée : sans lui, le reste du corps perd son travail
        // indirect sans que personne ne s'en aperçoive.
        let sharedSecondary = Set(candidate.secondaryMuscles)
            .intersection(exercise.secondaryMuscles)
            .count
        score += min(10, sharedSecondary * 5)
        // À proximité égale, le mouvement au meilleur rapport stimulus/fatigue.
        score += candidate.stimulusRating * 2
        return min(100, score)
    }

    /// Pourquoi ce remplacement, et surtout ce qui change concrètement.
    ///
    /// Trois cartes qui affichent la même phrase générique ressemblent à un
    /// bug plutôt qu'à un conseil. Ce qui distingue les options les unes des
    /// autres, c'est le matériel : on le dit, parce que c'est ce qui change
    /// la charge à mettre.
    static func reason(replacing exercise: Exercise, with candidate: Exercise) -> LocalizedText {
        if let switched = equipmentChange(from: exercise, to: candidate) {
            // Deux options prises sur le même matériel reçoivent la même
            // phrase de matériel : c'est vrai, et insuffisant. Ce qui les
            // départage — le buste calé, l'isolation, le côté par côté —
            // est ajouté ici, faute de quoi les deux cartes seraient
            // indiscernables alors que les exercices ne le sont pas.
            guard let nuance = nuance(of: candidate, replacing: exercise) else { return switched }
            return switched + LocalizedText(fr: " ", en: " ", es: " ") + nuance
        }

        if candidate.primaryMuscle == exercise.primaryMuscle && candidate.pattern == exercise.pattern {
            return LocalizedText(
                fr: "Même muscle, même mouvement. Reprends la charge qui te donne le même nombre de répétitions au même effort : elle ne sera pas celle de l'exercice d'origine.",
                en: "Same muscle, same movement. Take the load that gives you the same reps at the same effort: it will not be the one from the original exercise.",
                es: "Mismo músculo, mismo movimiento. Usa la carga que te dé las mismas repeticiones al mismo esfuerzo: no será la del ejercicio original."
            )
        }
        if candidate.primaryMuscle == exercise.primaryMuscle {
            return LocalizedText(
                fr: "Même muscle, angle différent. Le stimulus est conservé ; la sensation, elle, ne sera pas identique, et c'est normal.",
                en: "Same muscle, different angle. The stimulus is kept; the feel will not be identical, and that is normal.",
                es: "Mismo músculo, ángulo distinto. El estímulo se mantiene; la sensación no será idéntica, y es normal."
            )
        }
        return LocalizedText(
            fr: "Même schéma moteur, avec le muscle visé en soutien. C'est le remplacement le plus éloigné de la liste : à ne prendre que si les précédents sont pris aussi.",
            en: "Same movement pattern, with the target muscle assisting. This is the furthest option on the list: take it only if the ones above are busy too.",
            es: "Mismo patrón de movimiento, con el músculo objetivo asistiendo. Es la opción más lejana de la lista: tómala solo si las anteriores también están ocupadas."
        )
    }

    /// Ce que ce remplacement change en plus du matériel.
    ///
    /// Une seule phrase, la plus décisive d'abord : ce qui décharge le dos
    /// passe avant ce qui isole, qui passe avant un simple changement
    /// d'angle. Rien n'est rendu quand rien de notable ne change — une
    /// précision inventée pour remplir la carte serait pire que le silence.
    static func nuance(of candidate: Exercise, replacing exercise: Exercise) -> LocalizedText? {
        if exercise.stressedAreas.contains(.lowerBack) && !candidate.stressedAreas.contains(.lowerBack) {
            return LocalizedText(
                fr: "Et le bas du dos ne porte plus rien : c'est l'appui qui tient le buste.",
                en: "And the low back carries nothing any more: the pad holds your torso.",
                es: "Y la zona lumbar ya no soporta nada: el apoyo sujeta el torso."
            )
        }
        if candidate.isUnilateral && !exercise.isUnilateral {
            return LocalizedText(
                fr: "Et un côté à la fois : le côté faible ne peut plus se cacher derrière l'autre.",
                en: "And one side at a time: the weaker side can no longer hide behind the other.",
                es: "Y un lado cada vez: el lado débil ya no puede esconderse detrás del otro."
            )
        }
        if exercise.isCompound && !candidate.isCompound {
            return LocalizedText(
                fr: "C'est un mouvement d'isolation : moins de charge, mais toute la tension au bon endroit.",
                en: "This is an isolation movement: less load, but all the tension in the right place.",
                es: "Es un movimiento de aislamiento: menos carga, pero toda la tensión en el sitio correcto."
            )
        }
        if candidate.pattern != exercise.pattern {
            return LocalizedText(
                fr: "L'angle du mouvement change aussi : la sensation ne sera pas la même, et c'est normal.",
                en: "The angle of the movement changes too: the feel will not be the same, and that is fine.",
                es: "El ángulo del movimiento también cambia: la sensación no será la misma, y es normal."
            )
        }
        return nil
    }

    /// Ce que le changement de matériel implique pour la charge.
    ///
    /// C'est la seule chose que l'athlète a besoin de savoir sur le moment :
    /// il sait déjà faire le mouvement, il ne sait pas avec combien.
    static func equipmentChange(from exercise: Exercise, to candidate: Exercise) -> LocalizedText? {
        let was = exercise.equipment
        let now = candidate.equipment

        if now.contains(.bodyweight) && !was.contains(.bodyweight) {
            return LocalizedText(
                fr: "Au poids du corps : la charge n'est plus réglable, c'est le nombre de répétitions qui l'est. Vise le même effort en fin de série, pas le même chiffre.",
                en: "Bodyweight: the load is no longer adjustable, the rep count is. Aim for the same effort at the end of the set, not the same number.",
                es: "Con el peso corporal: la carga ya no se regula, sí el número de repeticiones. Busca el mismo esfuerzo al final de la serie, no la misma cifra."
            )
        }
        if now.contains(.machine) && (was.contains(.barbell) || was.contains(.dumbbell)) {
            return LocalizedText(
                fr: "Sur machine : la trajectoire est guidée, donc tu peux aller plus près de l'échec sans risque. La charge affichée n'a rien à voir avec celle du poids libre, ne compare pas les deux.",
                en: "On a machine: the path is guided, so you can go closer to failure safely. The number on the stack has nothing to do with the free-weight load — do not compare them.",
                es: "En máquina: la trayectoria está guiada, así que puedes acercarte más al fallo sin riesgo. El número de la placa no tiene nada que ver con el peso libre: no los compares."
            )
        }
        if (now.contains(.barbell) || now.contains(.dumbbell)) && was.contains(.machine) {
            return LocalizedText(
                fr: "En poids libre : plus rien ne guide la trajectoire, et les muscles stabilisateurs entrent en jeu. Commence 20 % plus léger que sur la machine, quitte à monter à la série suivante.",
                en: "Free weight: nothing guides the path any more, and the stabilisers join in. Start 20 % lighter than on the machine, and go up on the next set if it was easy.",
                es: "Peso libre: ya nada guía la trayectoria y entran los estabilizadores. Empieza un 20 % más ligero que en la máquina y sube en la serie siguiente si va sobrado."
            )
        }
        if now.contains(.dumbbell) && was.contains(.barbell) {
            return LocalizedText(
                fr: "Aux haltères : chaque bras fait son propre travail, ce qui révèle les asymétries. Compte environ 40 % de la charge de la barre, par haltère.",
                en: "Dumbbells: each arm does its own work, which exposes asymmetries. Reckon on about 40 % of the barbell load, per dumbbell.",
                es: "Con mancuernas: cada brazo hace su trabajo, lo que revela las asimetrías. Cuenta con un 40 % de la carga de la barra, por mancuerna."
            )
        }
        if now.contains(.smithMachine) && !was.contains(.smithMachine) {
            return LocalizedText(
                fr: "À la Smith : la barre ne peut aller que verticalement, donc rien à équilibrer et personne à qui demander de parer. Recule ou avance les pieds jusqu'à ce que la trajectoire tombe juste.",
                en: "On the Smith: the bar can only travel vertically, so there is nothing to balance and nobody to ask for a spot. Move your feet until the fixed path lines up.",
                es: "En la Smith: la barra solo se mueve en vertical, así que no hay que equilibrar nada ni pedir ayuda. Mueve los pies hasta que la trayectoria fija te cuadre."
            )
        }
        if now.contains(.dipStation) && !was.contains(.dipStation) {
            return LocalizedText(
                fr: "Aux barres parallèles : c'est ton poids de corps qui fait la charge. Descends jusqu'à ce que l'épaule passe sous le coude, pas plus bas.",
                en: "On parallel bars: your bodyweight is the load. Go down until the shoulder passes below the elbow, and no further.",
                es: "En paralelas: la carga es tu propio peso. Baja hasta que el hombro pase por debajo del codo, no más."
            )
        }
        if now.contains(.cable) && !was.contains(.cable) {
            return LocalizedText(
                fr: "À la poulie : la tension reste constante sur toute l'amplitude, y compris là où le mouvement d'origine devenait facile. La charge sera plus basse pour le même effort.",
                en: "On the cable: tension stays constant through the whole range, including where the original movement got easy. The load will be lower for the same effort.",
                es: "En polea: la tensión se mantiene constante en todo el recorrido, incluso donde el movimiento original se volvía fácil. La carga será menor para el mismo esfuerzo."
            )
        }
        if now.contains(.band) && !was.contains(.band) {
            return LocalizedText(
                fr: "À l'élastique : la résistance augmente en fin de mouvement et disparaît au début. Ralentis le retour pour compenser ce que la position basse a perdu.",
                en: "With a band: resistance rises at the end of the movement and vanishes at the start. Slow the return down to make up for what the bottom position lost.",
                es: "Con banda: la resistencia sube al final del movimiento y desaparece al principio. Ralentiza la vuelta para compensar lo que pierde la posición baja."
            )
        }
        return nil
    }

    // MARK: - Répondre à une situation

    /// La réponse complète à un obstacle rencontré pendant la séance.
    public static func answer(
        to obstacle: GymObstacle,
        exercise: Exercise?,
        profile: UserProfile,
        session: PlannedSession? = nil
    ) -> GymAnswer {
        let busy: Set<Equipment> = obstacle == .equipmentBusy || obstacle == .equipmentMissing
            ? (exercise?.equipment ?? [])
            : []
        let options = exercise.map {
            substitutions(for: $0, profile: profile, excludingEquipment: busy)
        } ?? []

        switch obstacle {
        case .equipmentBusy:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Change l'ordre avant de changer l'exercice",
                    en: "Change the order before you change the exercise",
                    es: "Cambia el orden antes de cambiar el ejercicio"
                ),
                detail: reorderDetail(session: session, exercise: exercise),
                substitutions: options
            )

        case .equipmentMissing:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Remplace-le pour de bon",
                    en: "Replace it for good",
                    es: "Sustitúyelo definitivamente"
                ),
                detail: LocalizedText(
                    fr: "Si ta salle ne l'a pas, ce n'est pas un incident : c'est le programme qui est faux. Retire le matériel manquant de ton profil et le coach ne le proposera plus jamais, dans aucun bloc.",
                    en: "If your gym does not have it, this is not an incident: the programme is wrong. Remove the missing kit from your profile and the coach will never propose it again, in any block.",
                    es: "Si tu gimnasio no lo tiene, no es un incidente: el programa está mal. Quita ese material de tu perfil y el entrenador no volverá a proponerlo, en ningún bloque."
                ),
                substitutions: options
            )

        case .noSpotter:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Ne compte jamais sur un inconnu au moment critique",
                    en: "Never count on a stranger at the critical moment",
                    es: "Nunca cuentes con un desconocido en el momento crítico"
                ),
                detail: LocalizedText(
                    fr: "Sans pareur, deux règles : les barres de sécurité du rack réglées à la hauteur du point bas, et une répétition en réserve sur la dernière série. Sur un développé couché sans rack, passe aux haltères — on peut les lâcher sur le côté, on ne peut pas lâcher une barre posée sur sa cage thoracique.",
                    en: "Without a spotter, two rules: the rack's safety pins set at the height of the bottom position, and one rep left in reserve on the last set. Bench pressing without a rack, switch to dumbbells — you can drop those to the side, you cannot drop a bar lying on your ribcage.",
                    es: "Sin ayudante, dos reglas: los seguros del rack a la altura del punto bajo y una repetición en reserva en la última serie. En press de banca sin rack, pasa a mancuernas: se pueden soltar a los lados, una barra sobre las costillas no."
                ),
                substitutions: options.filter { !$0.exercise.equipment.contains(.barbell) }
            )

        case .discomfort:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Arrête ce mouvement-là, pas la séance",
                    en: "Stop that movement, not the session",
                    es: "Para ese movimiento, no la sesión"
                ),
                detail: LocalizedText(
                    fr: "Une gêne qui disparaît à l'échauffement se poursuit ; une douleur qui modifie ton exécution arrête l'exercice, tout de suite. Signale-la : le coach passe le mouvement en charge réduite la prochaine fois, et le remplace s'il revient. Le reste de la séance, lui, se fait normalement.",
                    en: "Discomfort that fades during the warm-up carries on; pain that changes how you move ends the exercise, right now. Flag it: the coach drops the load next time and replaces the movement if it comes back. The rest of the session happens as planned.",
                    es: "Una molestia que desaparece al calentar sigue; un dolor que cambia tu ejecución termina el ejercicio, ahora mismo. Señálalo: el entrenador baja la carga la próxima vez y sustituye el movimiento si vuelve. El resto de la sesión se hace con normalidad."
                ),
                substitutions: options
            )

        case .shortOnTime:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Coupe par la fin, jamais par le début",
                    en: "Cut from the end, never from the start",
                    es: "Recorta por el final, nunca por el principio"
                ),
                detail: shortOnTimeDetail(session: session),
                substitutions: []
            )

        case .crowded:
            return GymAnswer(
                obstacle: obstacle,
                headline: LocalizedText(
                    fr: "Occupe un seul poste, et fais-en plus",
                    en: "Hold one station, and do more with it",
                    es: "Ocupa un solo puesto y saca más de él"
                ),
                detail: LocalizedText(
                    fr: "Quand tout est pris, la stratégie n'est pas de courir après les machines : c'est de rester sur un poste et d'y enchaîner deux exercices qui ne se gênent pas — un haut du corps et un bas du corps, par exemple. Le repos de l'un devient le travail de l'autre, la séance raccourcit, et personne n'attend derrière toi.",
                    en: "When everything is taken, the answer is not to chase machines: it is to hold one station and pair two exercises that do not interfere — an upper-body and a lower-body one, for instance. The rest of one becomes the work of the other, the session gets shorter, and nobody waits behind you.",
                    es: "Cuando todo está ocupado, la respuesta no es perseguir máquinas: es quedarte en un puesto y encadenar dos ejercicios que no se estorben, uno de tren superior y otro de tren inferior, por ejemplo. El descanso de uno es el trabajo del otro, la sesión se acorta y nadie espera detrás de ti."
                ),
                substitutions: options
            )
        }
    }

    /// Ce qu'on fait pendant que le poste se libère.
    static func reorderDetail(session: PlannedSession?, exercise: Exercise?) -> LocalizedText {
        guard let session, let exercise,
              let position = session.exercises.firstIndex(where: { $0.exerciseID == exercise.id }),
              position < session.exercises.count - 1
        else {
            return LocalizedText(
                fr: "Passe au mouvement suivant de ta séance et reviens sur celui-ci quand le poste se libère. L'ordre compte moins qu'on ne le croit : ce qui compte, c'est de faire les séries dures avec de la force disponible.",
                en: "Move to the next movement in your session and come back to this one when the station frees up. Order matters less than people think: what matters is doing the hard sets while you still have strength.",
                es: "Pasa al siguiente movimiento de tu sesión y vuelve a este cuando se libere el puesto. El orden importa menos de lo que se cree: lo que importa es hacer las series duras con fuerza disponible."
            )
        }
        let next = session.exercises[position + 1].exerciseID
        let name = ExerciseCatalog.exercise(id: next)?.name ?? .constant(next)
        return LocalizedText(
            fr: "Fais \(name.fr) maintenant et reviens sur celui-ci après : c'est le mouvement suivant de ta séance, il ne te coûtera rien de le monter d'un cran. Ne remplace un exercice que si le poste est encore pris au moment d'y revenir.",
            en: "Do \(name.en) now and come back to this one after: it is the next movement in your session, so moving it up costs you nothing. Only replace an exercise if the station is still taken when you come back.",
            es: "Haz \(name.es) ahora y vuelve a este después: es el siguiente movimiento de tu sesión, así que adelantarlo no te cuesta nada. Sustituye un ejercicio solo si el puesto sigue ocupado cuando vuelvas."
        )
    }

    /// Comment raccourcir une séance sans la vider de sa substance.
    static func shortOnTimeDetail(session: PlannedSession?) -> LocalizedText {
        guard let session, session.exercises.count >= 2 else {
            return LocalizedText(
                fr: "Garde les deux premiers exercices en entier et arrête-toi là. Une demi-séance faite bat une séance entière repoussée à demain, puis à jamais.",
                en: "Keep the first two exercises in full and stop there. Half a session done beats a whole session postponed to tomorrow, then to never.",
                es: "Haz enteros los dos primeros ejercicios y para ahí. Media sesión hecha vale más que una sesión entera aplazada a mañana, y luego a nunca."
            )
        }
        let keep = session.exercises.prefix(2).compactMap {
            ExerciseCatalog.exercise(id: $0.exerciseID)?.name
        }
        let names = keep.joinedNaturally()
        let dropped = session.exercises.count - 2
        return LocalizedText(
            fr: "Fais \(names.fr) en entier, puis arrête-toi : les \(dropped) exercices suivants sont les accessoires, et ce sont eux qui coûtent le moins à sauter. Ne réduis pas toutes les séries de moitié — mieux vaut deux exercices complets que six bâclés.",
            en: "Do \(names.en) in full, then stop: the \(dropped) exercises after them are the accessories, and they are the cheapest to skip. Do not halve every set instead — two complete exercises beat six rushed ones.",
            es: "Haz \(names.es) enteros y para: los \(dropped) ejercicios siguientes son los accesorios, y son los más baratos de saltarse. No reduzcas a la mitad todas las series: valen más dos ejercicios completos que seis hechos deprisa."
        )
    }
}
