import Foundation

/// Ce qu'un rappel a à dire.
///
/// La liste est courte exprès. Une application qui trouve quatre raisons de
/// sonner par jour se fait couper le son la première semaine, et ne dira
/// plus jamais rien — y compris le jour où elle avait raison.
public enum ReminderKind: String, Codable, Sendable, CaseIterable, Hashable {
    /// Des séances restent à faire cette semaine, et les jours manquent.
    case sessionsLeft
    /// Plus rien d'enregistré depuis plusieurs jours.
    case comeBack
    /// Aucune pesée cette semaine, alors que le poids pilote l'adaptation.
    case weighIn
    /// Aucun bilan de forme aujourd'hui, alors qu'il ajuste la séance.
    case readiness

    /// Qui parle en premier quand plusieurs ont quelque chose à dire.
    ///
    /// L'ordre n'est pas un goût : il va du plus rare au plus courant.
    /// Revenir après une semaine d'absence compte davantage qu'une pesée
    /// oubliée, et se peser compte davantage qu'un bilan de forme qu'on
    /// remplira de toute façon en ouvrant l'application.
    var rank: Int {
        switch self {
        case .comeBack: 0
        case .sessionsLeft: 1
        case .weighIn: 2
        case .readiness: 3
        }
    }
}

/// Un rappel prêt à être posé : quoi dire, et quand.
public struct Reminder: Sendable, Equatable, Identifiable, Hashable {
    public var kind: ReminderKind
    public var date: Date
    public var title: LocalizedText
    public var message: LocalizedText

    /// L'identifiant que le système garde. Un rappel par espèce et par jour :
    /// reposer le même écrase l'ancien au lieu d'en empiler deux.
    public var id: String

    public init(
        kind: ReminderKind,
        date: Date,
        title: LocalizedText,
        message: LocalizedText,
        id: String
    ) {
        self.kind = kind
        self.date = date
        self.title = title
        self.message = message
        self.id = id
    }
}

/// Ce que l'athlète a choisi d'entendre.
public struct ReminderSettings: Codable, Sendable, Equatable, Hashable {
    public var enabled: Bool
    /// L'heure à laquelle les rappels sonnent, en heures et minutes locales.
    public var hour: Int
    public var minute: Int
    /// Les espèces autorisées. Tout couper une par une doit rester possible :
    /// quelqu'un qui se pèse tous les matins n'a pas besoin qu'on le lui dise.
    public var kinds: Set<ReminderKind>

    public init(
        enabled: Bool = false,
        hour: Int = 18,
        minute: Int = 30,
        kinds: Set<ReminderKind> = Set(ReminderKind.allCases)
    ) {
        self.enabled = enabled
        self.hour = hour.clamped(to: 0...23)
        self.minute = minute.clamped(to: 0...59)
        self.kinds = kinds
    }

    public static let off = ReminderSettings()
}

/// Décide quoi rappeler, et quand.
///
/// Pourquoi ce type existe
/// -----------------------
/// Tout le moteur savait déjà quoi dire — la séance qui reste, la semaine
/// qui s'achève à moitié, le poids qu'on n'a pas noté depuis dix jours — et
/// attendait qu'on ouvre l'application pour le dire. Un coach qui ne parle
/// que lorsqu'on vient le voir n'est pas un coach, c'est un carnet.
///
/// Deux règles tiennent tout le reste :
///
/// 1. **On ne rappelle jamais ce qui est déjà fait.** Un rappel qui arrive
///    après coup coûte la confiance de tous les suivants.
/// 2. **Un seul par jour.** Quand plusieurs ont raison, le plus rare parle
///    et les autres se taisent. Quatre notifications le même soir, c'est le
///    son coupé pour de bon la semaine suivante.
///
/// Ce type ne pose aucune notification : il rend une liste. Ce qui la pose
/// est l'affaire du téléphone, ce qui la décide se teste sur n'importe quelle
/// machine.
public enum ReminderPlanner {

    /// Au bout de combien de jours sans rien on propose de revenir.
    ///
    /// Trois jours seraient du harcèlement — une semaine chargée en compte
    /// deux sans séance sans que rien n'aille mal. Quatre, c'est le moment
    /// où l'absence cesse d'être un creux et devient une habitude qui part.
    public static let quietDaysBeforeNudging = 4

    /// Sur combien de jours on prépare d'avance.
    ///
    /// Les notifications locales se posent à l'avance et ne se recalculent
    /// pas toutes seules : une semaine donne de la marge à quelqu'un qui
    /// n'ouvre pas l'application, sans annoncer un futur qu'on ne connaît pas.
    public static let horizonDays = 7

    /// Les rappels à poser, du plus proche au plus lointain.
    public static func plan(
        program: CoachingProgram?,
        history: TrainingHistory,
        settings: ReminderSettings,
        from now: Date = Date(),
        calendar: Calendar = .current
    ) -> [Reminder] {
        guard settings.enabled, !settings.kinds.isEmpty else { return [] }

        var reminders: [Reminder] = []
        for offset in 0..<horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now),
                  let fireDate = at(settings.hour, settings.minute, on: day, calendar: calendar),
                  fireDate > now
            else { continue }

            // Ce qui est vrai *ce jour-là*, en ne comptant que ce qui est
            // déjà arrivé. On ne suppose aucune séance future : quelqu'un
            // qui s'entraîne demain fera taire le rappel de demain en
            // s'entraînant, pas parce qu'on l'avait deviné.
            let candidates = ReminderKind.allCases
                .filter { settings.kinds.contains($0) }
                .compactMap {
                    reminder($0, program: program, history: history,
                             on: fireDate, calendar: calendar)
                }
                .sorted { $0.kind.rank < $1.kind.rank }

            if let chosen = candidates.first { reminders.append(chosen) }
        }
        return reminders
    }

    // MARK: - Une espèce à la fois

    private static func reminder(
        _ kind: ReminderKind,
        program: CoachingProgram?,
        history: TrainingHistory,
        on date: Date,
        calendar: Calendar
    ) -> Reminder? {
        let identifier = "\(kind.rawValue).\(dayStamp(date, calendar: calendar))"
        switch kind {
        case .comeBack:
            guard let last = lastEffort(history) else { return nil }
            let days = calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: last),
                to: calendar.startOfDay(for: date)
            ).day ?? 0
            guard days >= quietDaysBeforeNudging else { return nil }
            return Reminder(
                kind: kind, date: date,
                title: LocalizedText(
                    fr: "Ça fait \(days) jours",
                    en: "It has been \(days) days",
                    es: "Han pasado \(days) días"
                ),
                message: LocalizedText(
                    fr: "Rien depuis \(days) jours. Une séance courte vaut mieux qu'une semaine parfaite qui n'arrive pas.",
                    en: "Nothing for \(days) days. A short session beats a perfect week that never comes.",
                    es: "Nada desde hace \(days) días. Una sesión corta vale más que una semana perfecta que no llega."
                ),
                id: identifier
            )

        case .sessionsLeft:
            guard let program,
                  let week = program.plan.weekIndex(for: date, calendar: calendar),
                  let planned = program.plan.weeks.first(where: { $0.index == week })
            else { return nil }
            let done = sessionsLogged(history, week: week, plan: program.plan, calendar: calendar)
            let left = planned.sessions.count - done
            guard left > 0 else { return nil }
            let daysLeft = daysRemaining(inWeek: week, plan: program.plan, on: date, calendar: calendar)
            // On ne parle que lorsque le compte devient serré : autant de
            // séances que de jours. Avant, il n'y a rien à signaler ; après,
            // c'est déjà raté et le dire ne sert qu'à enfoncer.
            guard daysLeft > 0, left >= daysLeft else { return nil }
            return Reminder(
                kind: kind, date: date,
                title: LocalizedText(
                    fr: left == 1 ? "Une séance à placer" : "\(left) séances à placer",
                    en: left == 1 ? "One session to fit in" : "\(left) sessions to fit in",
                    es: left == 1 ? "Una sesión por encajar" : "\(left) sesiones por encajar"
                ),
                message: LocalizedText(
                    fr: "Il reste \(left) séance\(left > 1 ? "s" : "") et \(daysLeft) jour\(daysLeft > 1 ? "s" : "") dans la semaine.",
                    en: "\(left) session\(left > 1 ? "s" : "") left and \(daysLeft) day\(daysLeft > 1 ? "s" : "") in the week.",
                    es: "Quedan \(left) sesi\(left > 1 ? "ones" : "ón") y \(daysLeft) día\(daysLeft > 1 ? "s" : "") en la semana."
                ),
                id: identifier
            )

        case .weighIn:
            guard let last = history.bodyLogs.map(\.date).max() else { return nil }
            let days = calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: last),
                to: calendar.startOfDay(for: date)
            ).day ?? 0
            guard days >= 7 else { return nil }
            return Reminder(
                kind: kind, date: date,
                title: LocalizedText(fr: "Une pesée", en: "A weigh-in", es: "Un pesaje"),
                message: LocalizedText(
                    fr: "Rien noté depuis \(days) jours. C'est le poids qui décide si les calories bougent.",
                    en: "Nothing logged for \(days) days. Weight is what decides whether calories move.",
                    es: "Nada anotado desde hace \(days) días. El peso decide si las calorías cambian."
                ),
                id: identifier
            )

        case .readiness:
            // Un bilan de forme ne vaut que le jour même : le rappeler pour
            // demain reviendrait à demander comment on dormira.
            guard let program, program.plan.weekIndex(for: date, calendar: calendar) != nil,
                  !history.readiness.contains(where: { calendar.isDate($0.date, inSameDayAs: date) })
            else { return nil }
            return Reminder(
                kind: kind, date: date,
                title: LocalizedText(fr: "Comment tu vas ?", en: "How are you doing?", es: "¿Cómo estás?"),
                message: LocalizedText(
                    fr: "Trente secondes de bilan, et la séance s'ajuste à la journée que tu as eue.",
                    en: "Thirty seconds of check-in, and the session adjusts to the day you had.",
                    es: "Treinta segundos de balance, y la sesión se ajusta al día que has tenido."
                ),
                id: identifier
            )
        }
    }

    // MARK: - Ce que l'historique dit

    /// La dernière fois que quelque chose a été fait, séance de salle ou
    /// sortie. Compter les deux est la seule mesure honnête : quelqu'un qui a
    /// couru trois fois cette semaine n'a pas disparu.
    static func lastEffort(_ history: TrainingHistory) -> Date? {
        let sessions = history.sessions.filter { !$0.skipped }.map(\.date)
        let activities = history.activities.map(\.startedAt)
        return (sessions + activities).max()
    }

    static func sessionsLogged(
        _ history: TrainingHistory,
        week: Int,
        plan: Mesocycle,
        calendar: Calendar
    ) -> Int {
        history.sessions.filter {
            !$0.skipped && plan.weekIndex(for: $0.date, calendar: calendar) == week
        }.count
    }

    /// Combien de jours restent dans la semaine du bloc, celui-ci compris.
    static func daysRemaining(
        inWeek week: Int,
        plan: Mesocycle,
        on date: Date,
        calendar: Calendar
    ) -> Int {
        let start = calendar.startOfDay(for: plan.startDate)
        guard let weekStart = calendar.date(byAdding: .day, value: (week - 1) * 7, to: start),
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)
        else { return 0 }
        let today = calendar.startOfDay(for: date)
        let days = calendar.dateComponents([.day], from: today, to: weekEnd).day ?? 0
        return max(0, days + 1)
    }

    // MARK: - Petites choses de calendrier

    static func at(_ hour: Int, _ minute: Int, on day: Date, calendar: Calendar) -> Date? {
        var parts = calendar.dateComponents([.year, .month, .day], from: day)
        parts.hour = hour
        parts.minute = minute
        parts.second = 0
        return calendar.date(from: parts)
    }

    static func dayStamp(_ date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
