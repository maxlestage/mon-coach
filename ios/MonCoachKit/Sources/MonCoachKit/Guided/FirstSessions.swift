import Foundation

/// Le parcours des premières semaines, pour quelqu'un qui n'a jamais mis les
/// pieds dans une salle.
///
/// L'erreur classique du débutant n'est pas de mal faire un mouvement, c'est
/// de commencer trop lourd et d'arrêter en trois semaines. Ce parcours prend
/// le problème dans l'autre sens : les quatre premières semaines servent à
/// apprendre les gestes et à installer l'habitude, pas à progresser. La
/// progression commence en semaine 5, et elle commence sur des bases qui
/// tiennent.
public enum FirstSessions {

    public static let path: [FirstSessionsStep] = [
        FirstSessionsStep(
            week: 1,
            title: LocalizedText(fr: "Apprendre les gestes", en: "Learn the movements", es: "Aprender los gestos"),
            goal: LocalizedText(
                fr: "Faire chaque mouvement correctement, à vide ou très léger.",
                en: "Perform each movement correctly, empty bar or very light.",
                es: "Hacer cada movimiento correctamente, en vacío o muy ligero."
            ),
            instruction: LocalizedText(
                fr: "Lis la fiche guidée avant chaque exercice, fais deux séries de dix répétitions avec une charge ridicule, et arrête-toi là. Tu dois sortir de la salle en te disant que c'était trop facile : c'est exactement le but.",
                en: "Read the guided sheet before each exercise, do two sets of ten with a laughably light load, and stop. You should leave thinking it was too easy — that is exactly the point.",
                es: "Lee la ficha guiada antes de cada ejercicio, haz dos series de diez con una carga ridícula y para ahí. Debes salir pensando que fue demasiado fácil: ese es justo el objetivo."
            ),
            readyWhen: LocalizedText(
                fr: "Tu peux décrire chaque mouvement avec tes mots, sans relire la fiche.",
                en: "You can describe each movement in your own words, without rereading the sheet.",
                es: "Puedes describir cada movimiento con tus palabras, sin releer la ficha."
            )
        ),
        FirstSessionsStep(
            week: 2,
            title: LocalizedText(fr: "Trouver ta charge de départ", en: "Find your starting load", es: "Encontrar tu carga inicial"),
            goal: LocalizedText(
                fr: "Identifier, pour chaque exercice, le poids avec lequel dix répétitions restent faciles.",
                en: "Find, for each exercise, the weight that keeps ten reps easy.",
                es: "Identificar, para cada ejercicio, el peso con el que diez repeticiones siguen siendo fáciles."
            ),
            instruction: LocalizedText(
                fr: "Monte la charge de série en série jusqu'à ce que la dixième répétition demande un vrai effort — puis redescends d'un cran et note ce poids. C'est ton point de départ, pas ton maximum.",
                en: "Add weight set by set until the tenth rep takes real effort — then drop back one step and write that weight down. That is your starting point, not your maximum.",
                es: "Sube la carga serie a serie hasta que la décima repetición exija esfuerzo real, luego baja un escalón y anota ese peso. Ese es tu punto de partida, no tu máximo."
            ),
            readyWhen: LocalizedText(
                fr: "Chaque exercice a un poids noté dans l'application.",
                en: "Every exercise has a weight written down in the app.",
                es: "Cada ejercicio tiene un peso anotado en la aplicación."
            )
        ),
        FirstSessionsStep(
            week: 3,
            title: LocalizedText(fr: "Tenir le rythme", en: "Hold the rhythm", es: "Mantener el ritmo"),
            goal: LocalizedText(
                fr: "Faire toutes les séances prévues de la semaine, sans en sauter une.",
                en: "Complete every session the week asks for, without skipping one.",
                es: "Completar todas las sesiones de la semana, sin saltarte ninguna."
            ),
            instruction: LocalizedText(
                fr: "Même charge que la semaine dernière. La seule chose qui compte cette semaine, c'est d'y être allé. Une séance écourtée compte ; une séance sautée ne compte pas.",
                en: "Same load as last week. The only thing that counts this week is having shown up. A shortened session counts; a skipped one does not.",
                es: "La misma carga que la semana pasada. Lo único que cuenta esta semana es haber ido. Una sesión acortada cuenta; una saltada, no."
            ),
            readyWhen: LocalizedText(
                fr: "Tu as fait toutes tes séances, et les courbatures ne durent plus deux jours.",
                en: "You did every session, and the soreness no longer lasts two days.",
                es: "Has hecho todas las sesiones y las agujetas ya no duran dos días."
            )
        ),
        FirstSessionsStep(
            week: 4,
            title: LocalizedText(fr: "Apprendre à mesurer l'effort", en: "Learn to read your effort", es: "Aprender a medir el esfuerzo"),
            goal: LocalizedText(
                fr: "Savoir dire, à la fin d'une série, combien de répétitions il te restait.",
                en: "Be able to say, at the end of a set, how many reps you had left.",
                es: "Saber decir, al terminar una serie, cuántas repeticiones te quedaban."
            ),
            instruction: LocalizedText(
                fr: "Après chaque série, réponds à une seule question : « j'aurais pu en faire combien de plus ? ». C'est ce chiffre — deux, trois, quatre — qui pilotera toute la suite de ton entraînement. Tu vas te tromper les premières fois, et ce n'est pas grave.",
                en: "After every set, answer one question: how many more could I have done? That number — two, three, four — is what will drive the rest of your training. You will get it wrong at first, and that is fine.",
                es: "Después de cada serie, responde a una sola pregunta: ¿cuántas más habría podido hacer? Ese número —dos, tres, cuatro— guiará todo el resto de tu entrenamiento. Al principio te equivocarás, y no pasa nada."
            ),
            readyWhen: LocalizedText(
                fr: "Ton estimation colle à peu près à ce que tu arrives réellement à faire quand tu vas au bout.",
                en: "Your estimate roughly matches what you can actually do when you go all the way.",
                es: "Tu estimación coincide más o menos con lo que puedes hacer de verdad cuando llegas al final."
            )
        ),
        FirstSessionsStep(
            week: 5,
            title: LocalizedText(fr: "Commencer à progresser", en: "Start progressing", es: "Empezar a progresar"),
            goal: LocalizedText(
                fr: "Ajouter de la charge, maintenant que le reste tient.",
                en: "Add load, now that everything else holds.",
                es: "Añadir carga, ahora que lo demás se sostiene."
            ),
            instruction: LocalizedText(
                fr: "À partir d'ici, le coach prend le relais : il propose les charges, tu notes ce que tu fais, il ajuste. Le mode guidé reste accessible sur chaque exercice, aussi longtemps que tu en as besoin.",
                en: "From here the coach takes over: it proposes the loads, you log what you did, it adjusts. The guided sheets stay available on every exercise for as long as you need them.",
                es: "A partir de aquí toma el relevo el entrenador: propone las cargas, tú anotas lo que haces y él ajusta. Las fichas guiadas siguen disponibles en cada ejercicio todo el tiempo que las necesites."
            ),
            readyWhen: LocalizedText(
                fr: "Rien à attendre : c'est le début du programme normal.",
                en: "Nothing to wait for: this is the normal programme starting.",
                es: "Nada que esperar: aquí empieza el programa normal."
            )
        ),
    ]

    /// L'étape du parcours à afficher pour une date donnée.
    /// Nil une fois le parcours terminé, ou pour un athlète expérimenté.
    public static func step(
        for profile: UserProfile,
        startedOn start: Date,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> FirstSessionsStep? {
        guard profile.experience == .beginner else { return nil }
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: start),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        guard days >= 0 else { return path.first }
        let week = days / 7 + 1
        return path.first { $0.week == week }
    }

    /// Pourquoi ce mode existe, en une carte à montrer une fois.
    public static let rationale = LocalizedText(
        fr: "Pas de vidéo, et c'est volontaire. Une vidéo montre un mouvement réussi ; elle ne dit pas ce que tu es en train de rater, ni ce que tu devrais sentir. Ces fiches donnent des repères que tu peux vérifier sur toi-même, sans miroir, sans caméra et sans réseau.",
        en: "No video, and that is deliberate. A video shows a movement done right; it does not tell you what you are getting wrong, or what you should be feeling. These sheets give you checkpoints you can verify on yourself — no mirror, no camera, no connection.",
        es: "Sin vídeo, y es a propósito. Un vídeo muestra un movimiento bien hecho; no te dice qué estás fallando ni qué deberías sentir. Estas fichas dan referencias que puedes comprobar en ti mismo, sin espejo, sin cámara y sin conexión."
    )
}
