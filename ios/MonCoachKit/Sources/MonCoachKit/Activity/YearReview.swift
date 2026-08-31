import Foundation

/// Un mois de l'année sportive.
public struct MonthTotals: Sendable, Equatable, Identifiable {
    public var id: Int { month }
    /// 1 pour janvier.
    public var month: Int
    public var totals: PeriodTotals

    public init(month: Int, totals: PeriodTotals) {
        self.month = month
        self.totals = totals
    }
}

/// Une sortie qui a marqué l'année, réduite à ce qu'on en montre.
///
/// L'identifiant suffit à retrouver la sortie complète : recopier ses
/// milliers de points GPS dans le bilan ferait un objet de plusieurs
/// mégaoctets pour afficher trois chiffres.
public struct YearHighlight: Sendable, Equatable, Identifiable {
    public var id: UUID { activityID }
    public var activityID: UUID
    public var date: Date
    public var sport: Sport
    public var meters: Double
    public var duration: TimeInterval
    public var elevationGain: Double

    init(_ activity: ActivityLog) {
        activityID = activity.id
        date = activity.startedAt
        sport = activity.sport
        meters = activity.meters
        duration = activity.duration
        elevationGain = activity.elevationGain
    }
}

/// Le bilan d'une année sportive.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le journal répond à « qu'est-ce que j'ai fait cette semaine ». Personne
/// n'y lit une année : il faudrait faire défiler cinquante-deux barres et
/// additionner de tête. Or c'est à l'échelle de l'année que le travail
/// devient visible — un athlète régulier ne voit rien changer d'une semaine
/// à l'autre, et découvre en décembre qu'il a couru mille kilomètres.
///
/// Tout est recalculé depuis l'historique à chaque lecture, rien n'est
/// stocké : un bilan figé au 31 décembre mentirait dès qu'une sortie serait
/// importée après coup.
public struct YearReview: Sendable, Equatable {
    public var year: Int
    public var totals: PeriodTotals
    public var bySport: [Sport: PeriodTotals]
    /// Les douze mois, toujours les douze — un mois sans sortie est une
    /// information, pas une ligne à sauter.
    public var months: [MonthTotals]
    /// Nombre de jours distincts avec au moins une sortie.
    public var activeDays: Int
    /// La plus longue suite de semaines consécutives avec une sortie.
    public var longestStreakWeeks: Int
    public var longestActivity: YearHighlight?
    public var highestClimb: YearHighlight?
    /// Les records personnels établis cette année-là : ceux qui tiennent
    /// encore aujourd'hui, et qui datent de cette année.
    public var records: [BestEffort]
    /// La distance de l'année précédente, quand il y en a une.
    public var previousYearMeters: Double?

    public var isEmpty: Bool { totals.activityCount == 0 }

    /// Le mois le plus chargé, à la distance.
    public var busiestMonth: MonthTotals? {
        months.filter { $0.totals.meters > 0 }.max { $0.totals.meters < $1.totals.meters }
    }

    /// L'écart avec l'année précédente, en mètres. Nil la première année :
    /// comparer à zéro afficherait « +100 % » à quelqu'un qui débute, ce qui
    /// ne veut rien dire.
    public var metersVersusPreviousYear: Double? {
        guard let previous = previousYearMeters, previous > 0 else { return nil }
        return totals.meters - previous
    }
}

extension YearReview {

    /// Le bilan d'une année, calculé depuis tout l'historique.
    ///
    /// L'historique entier est demandé, pas seulement l'année : les records
    /// « de l'année » sont les records de toujours qui datent de cette
    /// année-là, et la comparaison a besoin de l'année d'avant.
    public static func review(
        of activities: [ActivityLog],
        year: Int,
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> YearReview {
        let inYear = activities.filter { calendar.component(.year, from: $0.startedAt) == year }

        var bySport: [Sport: PeriodTotals] = [:]
        for sport in Set(inYear.map(\.sport)) {
            bySport[sport] = ActivityJournal.totals(
                of: inYear.filter { $0.sport == sport }, maximumBpm: maximumBpm
            )
        }

        let months = (1...12).map { month in
            MonthTotals(
                month: month,
                totals: ActivityJournal.totals(
                    of: inYear.filter { calendar.component(.month, from: $0.startedAt) == month },
                    maximumBpm: maximumBpm
                )
            )
        }

        let days = Set(inYear.map { calendar.startOfDay(for: $0.startedAt) })

        let previous = activities.filter {
            calendar.component(.year, from: $0.startedAt) == year - 1
        }

        return YearReview(
            year: year,
            totals: ActivityJournal.totals(of: inYear, maximumBpm: maximumBpm),
            bySport: bySport,
            months: months,
            activeDays: days.count,
            longestStreakWeeks: longestStreak(of: inYear, calendar: calendar),
            longestActivity: inYear.max { $0.meters < $1.meters }.map(YearHighlight.init),
            highestClimb: inYear
                .filter { $0.elevationGain > 0 }
                .max { $0.elevationGain < $1.elevationGain }
                .map(YearHighlight.init),
            records: BestEfforts.records(in: activities)
                .filter { calendar.component(.year, from: $0.date) == year }
                .sorted { $0.distance.meters < $1.distance.meters },
            previousYearMeters: previous.isEmpty
                ? nil
                : previous.reduce(0) { $0 + $1.meters }
        )
    }

    /// Les années où quelque chose s'est passé, la plus récente d'abord.
    public static func availableYears(
        in activities: [ActivityLog],
        calendar: Calendar = .current
    ) -> [Int] {
        Set(activities.map { calendar.component(.year, from: $0.startedAt) }).sorted(by: >)
    }

    /// La plus longue suite de semaines consécutives avec au moins une
    /// sortie.
    ///
    /// Comptée sur les semaines qui portent une sortie de l'année, sans
    /// borner aux semaines entièrement dans l'année : une série qui
    /// enjambe le premier janvier est bien une série.
    static func longestStreak(of activities: [ActivityLog], calendar: Calendar) -> Int {
        let weeks = Set(
            activities.compactMap { ActivityJournal.startOfWeek(of: $0.startedAt, calendar: calendar) }
        ).sorted()
        guard !weeks.isEmpty else { return 0 }
        var best = 1
        var current = 1
        for index in 1..<weeks.count {
            let expected = calendar.date(byAdding: .weekOfYear, value: 1, to: weeks[index - 1])
            if let expected, calendar.isDate(expected, inSameDayAs: weeks[index]) {
                current += 1
            } else {
                current = 1
            }
            best = Swift.max(best, current)
        }
        return best
    }
}

extension YearReview {

    /// Le bilan en une phrase, pour l'écran comme pour le partage.
    ///
    /// Écrit pour être lu par quelqu'un d'autre : c'est le seul texte de
    /// l'application destiné à sortir du téléphone, et il ne sort que si
    /// l'athlète le partage lui-même.
    public func summary(unit: UnitSystem, language: Language) -> String {
        let distance = Format.distance(meters: totals.meters, unit: unit, language: language)
        let time = Format.stopwatch(seconds: totals.movingSeconds)
        let climb = Int(totals.elevationGain.rounded())
        switch language {
        case .french:
            return "Mon année \(year) : \(totals.activityCount) sorties, \(distance), "
                + "\(time) en mouvement, \(climb) m de dénivelé."
        case .english:
            return "My \(year): \(totals.activityCount) activities, \(distance), "
                + "\(time) moving, \(climb) m climbed."
        case .spanish:
            return "Mi año \(year): \(totals.activityCount) salidas, \(distance), "
                + "\(time) en movimiento, \(climb) m de desnivel."
        }
    }

    /// Ce que le dénivelé de l'année représente en Everest — 8 849 m depuis
    /// le niveau de la mer.
    ///
    /// Une comparaison, pas une statistique : elle n'ajoute aucune donnée,
    /// elle rend lisible un nombre que personne ne sait situer. Rendue
    /// seulement au-delà d'un Everest entier, faute de quoi elle dirait
    /// « 0,08 Everest », ce qui n'aide personne.
    public var everests: Double? {
        let count = totals.elevationGain / 8_849
        return count >= 1 ? count : nil
    }

    /// La distance de l'année en marathons. Même règle : au-delà d'un seul.
    public var marathons: Double? {
        let count = totals.meters / 42_195
        return count >= 1 ? count : nil
    }
}
