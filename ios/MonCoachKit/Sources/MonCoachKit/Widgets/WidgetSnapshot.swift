import Foundation

/// Ce que l'écran d'accueil et le cadran de la montre affichent.
///
/// Pourquoi un instantané, et non le magasin
/// -----------------------------------------
/// Une extension de widget est un autre processus, avec son propre bac à
/// sable : elle ne voit rien de ce que l'application écrit dans son dossier.
/// Le passage se fait par un conteneur partagé, et la question devient alors
/// : qu'y met-on ?
///
/// Pas l'état complet. Le déplacer dans le conteneur partagé ferait migrer
/// l'historique de tous ceux qui ont déjà l'application, pour un gain qui
/// s'arrête à quelques lignes de texte ; et un widget qui rejoue le moteur
/// à chaque rafraîchissement dépense la mémoire d'une extension — trente
/// mégaoctets — pour recalculer ce que l'application vient de calculer.
///
/// On y met donc le résultat : des phrases déjà écrites, déjà traduites,
/// déjà mises aux unités de l'athlète. Le widget n'a plus rien à décider,
/// ce qui est exactement ce qu'on attend d'un écran qu'on regarde une
/// seconde.
public struct WidgetSnapshot: Codable, Sendable, Equatable {

    /// La couleur de la journée. Le widget n'en déduit rien d'autre : c'est
    /// le moteur qui sait si le jour est dur, creux ou en attente.
    public enum Tone: String, Codable, Sendable {
        /// Il y a quelque chose à faire.
        case training
        /// Repos prescrit — pas un jour vide, un jour de récupération.
        case rest
        /// Quelque chose demande une décision : bloc terminé, reprise.
        case attention
    }

    /// L'instant de l'écriture. Le widget s'en sert pour se taire quand
    /// l'instantané est d'avant-hier : mieux vaut ne rien dire que dire la
    /// séance d'hier comme si c'était celle du jour.
    public var generatedAt: Date
    /// Le jour que décrit l'instantané, à minuit. Comparé au jour affiché
    /// plutôt qu'à `generatedAt` : un instantané écrit à 23 h 50 décrit
    /// encore la bonne journée à 23 h 59, et plus rien à 0 h 10.
    public var day: Date
    public var tone: Tone

    /// « Haut du corps A », « Repos », « Bloc terminé ».
    public var title: String
    /// « 5 exercices · 18 séries », « Récupération ».
    public var detail: String
    public var symbolName: String

    /// La sortie prévue, quand il y en a une et qu'elle n'est pas faite :
    /// « 8,0 km · Endurance ». Un jour peut porter une séance et une sortie.
    public var run: String?

    /// L'avancement de la semaine, en séries. Nil hors d'un bloc.
    public var setsCompleted: Int?
    public var setsPlanned: Int?

    /// « Semaine 2 », ou « Semaine 4 · décharge ».
    public var weekLabel: String?

    public init(
        generatedAt: Date,
        day: Date,
        tone: Tone,
        title: String,
        detail: String,
        symbolName: String,
        run: String? = nil,
        setsCompleted: Int? = nil,
        setsPlanned: Int? = nil,
        weekLabel: String? = nil
    ) {
        self.generatedAt = generatedAt
        self.day = day
        self.tone = tone
        self.title = title
        self.detail = detail
        self.symbolName = symbolName
        self.run = run
        self.setsCompleted = setsCompleted
        self.setsPlanned = setsPlanned
        self.weekLabel = weekLabel
    }

    /// L'instantané est-il encore celui du jour affiché ?
    ///
    /// Un widget se rafraîchit quand le système veut bien, pas quand on le
    /// demande : celui de 7 h peut rester à l'écran jusqu'à midi, et celui
    /// d'hier soir jusqu'à demain si l'application n'a pas été rouverte.
    /// Passé le changement de jour, il ne décrit plus rien.
    public func isCurrent(on date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(day, inSameDayAs: date)
    }
}

// MARK: - Fabrication

extension WidgetSnapshot {

    /// Écrit l'instantané à partir de ce que le coach a décidé aujourd'hui.
    ///
    /// Tout est passé explicitement plutôt que lu dans un magasin : c'est ce
    /// qui rend la fabrication testable ailleurs que sur un téléphone, et le
    /// texte affiché à des milliers de gens mérite d'être vérifié.
    public static func make(
        briefing: TodayBriefing,
        language: Language,
        unit: UnitSystem,
        comeback: ReturnToTraining? = nil,
        week: (completed: Int, planned: Int)? = nil,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> WidgetSnapshot {
        let day = calendar.startOfDay(for: briefing.date)

        // La reprise passe devant tout le reste : quelqu'un qui revient de
        // trois semaines d'arrêt doit le lire avant de lire sa séance.
        if let comeback {
            return WidgetSnapshot(
                generatedAt: now,
                day: day,
                tone: .attention,
                title: comeback.headline[language],
                detail: comeback.message[language],
                symbolName: "arrow.uturn.backward.circle.fill",
                weekLabel: weekLabel(briefing: briefing, language: language)
            )
        }

        let tone: Tone
        let title: String
        let detail: String
        let symbol: String

        switch briefing.state {
        case .training(let session):
            tone = .training
            title = session.title[language]
            symbol = "dumbbell.fill"
            detail = LocalizedText(
                fr: "\(session.exercises.count) exercices · \(session.totalSets) séries",
                en: "\(session.exercises.count) exercises · \(session.totalSets) sets",
                es: "\(session.exercises.count) ejercicios · \(session.totalSets) series"
            )[language]
        case .rest:
            tone = .rest
            symbol = "moon.zzz.fill"
            title = LocalizedText(fr: "Repos", en: "Rest", es: "Descanso")[language]
            // Le repos dit ce qui vient : « rien aujourd'hui » sur un écran
            // d'accueil se lit comme « rien à faire de la semaine ».
            if let next = briefing.nextSession {
                detail = LocalizedText(
                    fr: "Ensuite : \(next.title[.french])",
                    en: "Next: \(next.title[.english])",
                    es: "Luego: \(next.title[.spanish])"
                )[language]
            } else {
                detail = LocalizedText(
                    fr: "C'est là que le travail se transforme",
                    en: "This is when the work turns into something",
                    es: "Es cuando el trabajo se convierte en algo"
                )[language]
            }
        case .blockFinished:
            tone = .attention
            symbol = "flag.checkered"
            title = LocalizedText(fr: "Bloc terminé", en: "Block finished", es: "Bloque terminado")[language]
            detail = LocalizedText(
                fr: "Ouvre Stride pour lancer le suivant",
                en: "Open Stride to start the next one",
                es: "Abre Stride para empezar el siguiente"
            )[language]
        }

        return WidgetSnapshot(
            generatedAt: now,
            day: day,
            tone: tone,
            title: title,
            detail: detail,
            symbolName: symbol,
            run: runLine(briefing: briefing, language: language, unit: unit),
            setsCompleted: week?.completed,
            setsPlanned: week?.planned,
            weekLabel: weekLabel(briefing: briefing, language: language)
        )
    }

    /// La sortie prévue, tant qu'elle n'est pas faite. Une fois enregistrée,
    /// elle disparaît : un widget qui réclame encore ce qu'on vient de faire
    /// est un widget qu'on désinstalle.
    private static func runLine(
        briefing: TodayBriefing,
        language: Language,
        unit: UnitSystem
    ) -> String? {
        guard let run = briefing.plannedRun, briefing.recordedRun == nil else { return nil }
        guard let demand = run.summary(unit: unit, language: language) else {
            return run.type.label[language]
        }
        return "\(demand) · \(run.type.label[language])"
    }

    private static func weekLabel(briefing: TodayBriefing, language: Language) -> String? {
        guard let index = briefing.weekIndex else { return nil }
        // `weekIndex` compte à partir de 1 — c'est déjà le numéro qu'on
        // affiche, et lui ajouter 1 faisait commencer les blocs à la
        // semaine 2.
        let week = LocalizedText(
            fr: "Semaine \(index)",
            en: "Week \(index)",
            es: "Semana \(index)"
        )[language]
        guard briefing.isDeloadWeek else { return week }
        let deload = LocalizedText(fr: "décharge", en: "deload", es: "descarga")[language]
        return "\(week) · \(deload)"
    }
}

// MARK: - Au poignet

extension WidgetSnapshot {

    /// Le même instantané, écrit à partir de ce que le téléphone a envoyé.
    ///
    /// La montre ne fait pas tourner le moteur : elle reçoit une journée
    /// déjà décidée. Une complication ne peut donc pas être fabriquée par le
    /// même chemin que le widget du téléphone — d'où cette seconde porte,
    /// qui produit exactement le même objet à partir d'une autre source.
    ///
    /// Deux choses lui manquent, et c'est assumé : l'avancement de la semaine
    /// en séries, que le téléphone n'envoie pas, et la distinction entre un
    /// jour de repos et une reprise après arrêt. Un cadran de montre montre
    /// une ligne ; ces deux-là appartiennent à l'écran d'accueil.
    public static func make(
        watch: WatchSnapshot,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> WidgetSnapshot {
        let language = watch.language
        let day = calendar.startOfDay(for: watch.generatedAt)

        let tone: Tone
        let title: String
        let detail: String
        let symbol: String

        if let session = watch.session {
            tone = .training
            symbol = "dumbbell.fill"
            title = session.title[language]
            detail = LocalizedText(
                fr: "\(session.exercises.count) exercices · \(session.totalSets) séries",
                en: "\(session.exercises.count) exercises · \(session.totalSets) sets",
                es: "\(session.exercises.count) ejercicios · \(session.totalSets) series"
            )[language]
        } else if watch.weekIndex == nil {
            // Sans numéro de semaine, le bloc est fini : c'est ce que le
            // téléphone envoie quand le plan est arrivé au bout.
            tone = .attention
            symbol = "flag.checkered"
            title = LocalizedText(fr: "Bloc terminé", en: "Block finished", es: "Bloque terminado")[language]
            detail = LocalizedText(
                fr: "Ouvre Stride sur ton téléphone",
                en: "Open Stride on your phone",
                es: "Abre Stride en tu teléfono"
            )[language]
        } else {
            tone = .rest
            symbol = "moon.zzz.fill"
            title = LocalizedText(fr: "Repos", en: "Rest", es: "Descanso")[language]
            detail = LocalizedText(
                fr: "Rien à soulever aujourd'hui",
                en: "Nothing to lift today",
                es: "Nada que levantar hoy"
            )[language]
        }

        var run: String?
        if let planned = watch.plannedRun, !watch.runDone {
            let demand = planned.summary(unit: watch.unit, language: language)
            run = demand.map { "\($0) · \(planned.type.label[language])" } ?? planned.type.label[language]
        }

        var weekLabel: String?
        if let index = watch.weekIndex {
            let week = LocalizedText(
                fr: "Semaine \(index)", en: "Week \(index)", es: "Semana \(index)"
            )[language]
            if watch.isDeloadWeek {
                let deload = LocalizedText(fr: "décharge", en: "deload", es: "descarga")[language]
                weekLabel = "\(week) · \(deload)"
            } else {
                weekLabel = week
            }
        }

        return WidgetSnapshot(
            generatedAt: now,
            day: day,
            tone: tone,
            title: title,
            detail: detail,
            symbolName: symbol,
            run: run,
            weekLabel: weekLabel
        )
    }
}
