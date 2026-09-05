import Foundation

/// Un point d'une série temporelle : une période, et ce qu'on y a fait.
public struct StatsPoint: Sendable, Equatable, Identifiable {
    public var id: Date { start }
    /// Le début de la période — lundi pour une semaine, le 1er pour un mois.
    public var start: Date
    public var meters: Double
    public var seconds: TimeInterval
    public var elevationGain: Double
    /// La charge cardiaque, ou à défaut la charge estimée du ressenti.
    public var load: Double
    public var activityCount: Int

    public var kilometres: Double { meters / 1_000 }
    public var minutes: Double { seconds / 60 }
    public var isEmpty: Bool { activityCount == 0 }

    /// L'allure moyenne de la période, en secondes par kilomètre.
    /// Nulle quand rien n'a été parcouru — une allure inventée sur zéro
    /// mètre ferait un creux dans la courbe là où il n'y a pas de donnée.
    public var paceSecondsPerKm: Double? {
        meters > 500 && seconds > 0 ? seconds / (meters / 1_000) : nil
    }
}

/// Deux périodes comparées : celle qui vient de finir, et la précédente.
///
/// C'est la seule comparaison qui aide. « 47 km cette semaine » ne dit rien
/// tout seul ; « 47 km, contre 31 la semaine dernière » dit tout.
public struct StatsComparison: Sendable, Equatable {
    public var current: PeriodTotals
    public var previous: PeriodTotals

    /// La variation d'une grandeur, en pourcentage. Nulle quand la période
    /// précédente était vide : on ne divise pas par zéro, et « +∞ % » n'a
    /// jamais encouragé personne.
    public func change(_ value: (PeriodTotals) -> Double) -> Double? {
        let before = value(previous)
        guard before > 0 else { return nil }
        return (value(current) - before) / before * 100
    }
}

/// Une case du calendrier hebdomadaire : un jour, et son volume.
public struct DayBubble: Sendable, Equatable, Identifiable {
    public var id: Int { weekdayIndex }
    /// 0 pour lundi, 6 pour dimanche.
    public var weekdayIndex: Int
    public var date: Date
    public var meters: Double
    public var seconds: TimeInterval
    public var activityCount: Int
    public var sports: [Sport]
}

/// Les séries que les graphiques lisent.
///
/// Pourquoi ce type existe
/// -----------------------
/// Chaque écran calculait ses totaux à sa façon : le journal comptait les
/// semaines d'un côté, le tableau de bord la charge de l'autre, et les deux
/// pouvaient afficher deux chiffres différents pour la même semaine sans
/// que rien ne l'empêche. Les séries sont désormais construites ici, une
/// fois, à partir des mêmes activités.
///
/// Toutes les fonctions rendent les périodes vides. C'est délibéré : une
/// courbe qui saute les semaines sans sortie dessine une régularité qui
/// n'existe pas, et le trou est précisément ce qu'il faut voir.
public enum ActivityStats {

    // MARK: - Ce qu'on regarde

    /// Le filtre d'un écran de statistiques.
    ///
    /// Un athlète qui court et pédale ne veut pas voir ses kilomètres
    /// additionnés : cent kilomètres de vélo et dix de course font cent dix
    /// kilomètres de rien du tout. On regarde un sport, ou une famille, ou
    /// tout — mais on sait toujours lequel.
    public enum Scope: Sendable, Equatable, Hashable {
        case everything
        case family(SportFamily)
        case sport(Sport)

        /// Un trajet en voiture n'est dans aucun total « tous sports ».
        ///
        /// C'est ici que l'exclusion se fait, et à un seul endroit : les sept
        /// calculs de statistiques passent tous par ce filtre. L'écrire sept
        /// fois aurait garanti qu'un des sept l'oublie, et ce serait celui-là
        /// qui annoncerait la semaine la plus chargée de l'année.
        ///
        /// Demander explicitement les déplacements — la famille ou le sport —
        /// les rend, en revanche. On ne cache pas la donnée : on refuse
        /// seulement de l'additionner à du sport.
        public func matches(_ activity: ActivityLog) -> Bool {
            switch self {
            case .everything: activity.sport.countsAsTraining
            case .family(let family): activity.sport.family == family
            case .sport(let sport): activity.sport == sport
            }
        }

        public var label: LocalizedText {
            switch self {
            case .everything: LocalizedText(fr: "Tous les sports", en: "All sports", es: "Todos los deportes")
            case .family(let family): family.label
            case .sport(let sport): sport.label
            }
        }

        /// Les kilomètres ont-ils un sens dans ce périmètre ?
        ///
        /// Additionner la distance de plusieurs sports ne veut rien dire, et
        /// une natation n'en a même pas. Sur « tous les sports », c'est le
        /// temps qui porte le graphique.
        public var comparesDistance: Bool {
            switch self {
            case .everything: false
            case .family(let family): family != .indoor && family != .other
            case .sport(let sport): sport.tracksLocation
            }
        }
    }

    // MARK: - Les séries

    /// Le volume semaine par semaine, la plus ancienne d'abord.
    ///
    /// L'ordre chronologique et non l'inverse : c'est celui d'un graphique,
    /// et le retourner dans chaque vue finirait par être oublié une fois.
    public static func weekly(
        of activities: [ActivityLog],
        scope: Scope = .everything,
        weeks: Int = 12,
        endingOn today: Date = Date(),
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> [StatsPoint] {
        guard weeks > 0, let thisWeek = ActivityJournal.startOfWeek(of: today, calendar: calendar)
        else { return [] }
        let kept = activities.filter(scope.matches)
        var byWeek: [Date: [ActivityLog]] = [:]
        for activity in kept {
            if let week = ActivityJournal.startOfWeek(of: activity.startedAt, calendar: calendar) {
                byWeek[week, default: []].append(activity)
            }
        }
        return (0..<weeks).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: .weekOfYear, value: -offset, to: thisWeek)
            else { return nil }
            return point(start: start, activities: byWeek[start] ?? [], maximumBpm: maximumBpm)
        }
    }

    /// Le volume mois par mois, le plus ancien d'abord.
    public static func monthly(
        of activities: [ActivityLog],
        scope: Scope = .everything,
        months: Int = 12,
        endingOn today: Date = Date(),
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> [StatsPoint] {
        guard months > 0,
              let thisMonth = calendar.dateInterval(of: .month, for: today)?.start
        else { return [] }
        let kept = activities.filter(scope.matches)
        var byMonth: [Date: [ActivityLog]] = [:]
        for activity in kept {
            if let month = calendar.dateInterval(of: .month, for: activity.startedAt)?.start {
                byMonth[month, default: []].append(activity)
            }
        }
        return (0..<months).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: .month, value: -offset, to: thisMonth)
            else { return nil }
            return point(start: start, activities: byMonth[start] ?? [], maximumBpm: maximumBpm)
        }
    }

    static func point(
        start: Date,
        activities: [ActivityLog],
        maximumBpm: Double?
    ) -> StatsPoint {
        let totals = ActivityJournal.totals(of: activities, maximumBpm: maximumBpm)
        // La charge cardiaque n'existe que si un capteur était là. Sans
        // ceinture ni montre, la série serait plate à zéro pour quelqu'un
        // qui s'entraîne six fois par semaine : on retombe alors sur la
        // charge du ressenti, qui est celle du reste du moteur.
        let load = totals.trainingLoad > 0
            ? totals.trainingLoad
            : activities.reduce(0) { $0 + TrainingLoadEngine.effort(for: $1, maximumBpm: maximumBpm ?? 190) }
        return StatsPoint(
            start: start,
            meters: totals.meters,
            seconds: totals.movingSeconds,
            elevationGain: totals.elevationGain,
            load: load,
            activityCount: totals.activityCount
        )
    }

    /// La semaine en cours, jour par jour — le calendrier d'entraînement.
    public static func week(
        of activities: [ActivityLog],
        scope: Scope = .everything,
        containing day: Date = Date(),
        calendar: Calendar = .current
    ) -> [DayBubble] {
        guard let monday = ActivityJournal.startOfWeek(of: day, calendar: calendar) else { return [] }
        let kept = activities.filter(scope.matches)
        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: monday) else { return nil }
            let inDay = kept.filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
            return DayBubble(
                weekdayIndex: offset,
                date: date,
                meters: inDay.reduce(0) { $0 + $1.meters },
                seconds: inDay.reduce(0) { $0 + $1.duration },
                activityCount: inDay.count,
                sports: Array(Set(inDay.map(\.sport))).sorted { $0.rawValue < $1.rawValue }
            )
        }
    }

    /// Les totaux d'une période et de celle qui la précède.
    ///
    /// Les deux fenêtres font exactement la même longueur : comparer une
    /// semaine entamée à une semaine entière donnerait une baisse tous les
    /// lundis matin.
    public static func comparison(
        of activities: [ActivityLog],
        scope: Scope = .everything,
        days: Int = 7,
        endingOn today: Date = Date(),
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> StatsComparison {
        let kept = activities.filter(scope.matches)
        let end = calendar.startOfDay(for: today).addingTimeInterval(24 * 3_600)
        let currentStart = end.addingTimeInterval(-Double(days) * 24 * 3_600)
        let previousStart = currentStart.addingTimeInterval(-Double(days) * 24 * 3_600)
        return StatsComparison(
            current: ActivityJournal.totals(
                of: kept.filter { $0.startedAt >= currentStart && $0.startedAt < end },
                maximumBpm: maximumBpm
            ),
            previous: ActivityJournal.totals(
                of: kept.filter { $0.startedAt >= previousStart && $0.startedAt < currentStart },
                maximumBpm: maximumBpm
            )
        )
    }

    /// La répartition du temps par sport sur une période, du plus pratiqué
    /// au moins pratiqué.
    ///
    /// Le temps et non la distance : c'est la seule grandeur que tous les
    /// sports partagent, et la seule qui permette de dire « je fais surtout
    /// du vélo » à quelqu'un qui nage aussi.
    public static func share(
        of activities: [ActivityLog],
        since: Date,
        until: Date = Date()
    ) -> [(sport: Sport, seconds: TimeInterval, activityCount: Int)] {
        let kept = activities.filter { $0.startedAt >= since && $0.startedAt <= until }
        var seconds: [Sport: TimeInterval] = [:]
        var counts: [Sport: Int] = [:]
        for activity in kept {
            seconds[activity.sport, default: 0] += activity.duration
            counts[activity.sport, default: 0] += 1
        }
        return seconds
            .map { (sport: $0.key, seconds: $0.value, activityCount: counts[$0.key] ?? 0) }
            .sorted {
                $0.seconds == $1.seconds
                    ? $0.sport.rawValue < $1.sport.rawValue
                    : $0.seconds > $1.seconds
            }
    }

    /// Le temps passé dans chaque zone cardiaque sur une période.
    ///
    /// Rendu vide plutôt que faux quand aucune activité ne porte de
    /// battements : un graphique de zones sans capteur cardiaque montrerait
    /// cinq barres à zéro, ce qui se lit comme « tu ne t'entraînes pas ».
    public static func heartRateZones(
        of activities: [ActivityLog],
        since: Date,
        maximumBpm: Double,
        until: Date = Date()
    ) -> [Int: TimeInterval] {
        let withHeart = activities.filter {
            $0.startedAt >= since && $0.startedAt <= until && !$0.heartRate.isEmpty
        }
        guard !withHeart.isEmpty else { return [:] }
        var total: [Int: TimeInterval] = [:]
        for activity in withHeart {
            let perZone = HeartRateAnalysis.secondsPerZone(
                samples: activity.heartRate, maximumBpm: maximumBpm
            )
            for (zone, seconds) in perZone { total[zone, default: 0] += seconds }
        }
        return total
    }

    /// L'allure moyenne semaine par semaine, pour les semaines qui en ont
    /// une. Sert à voir si l'on va plus vite qu'il y a trois mois.
    ///
    /// N'a de sens que sur un seul sport : mêler l'allure d'une randonnée à
    /// celle d'un fractionné produit une courbe qui monte et descend au
    /// gré de ce qu'on a fait, pas de ce qu'on vaut.
    public static func paceTrend(
        of activities: [ActivityLog],
        sport: Sport,
        weeks: Int = 12,
        endingOn today: Date = Date(),
        calendar: Calendar = .current
    ) -> [(start: Date, secondsPerKm: Double)] {
        guard sport.readout == .pacePerKilometre else { return [] }
        return weekly(
            of: activities, scope: .sport(sport), weeks: weeks,
            endingOn: today, calendar: calendar
        )
        .compactMap { point in
            point.paceSecondsPerKm.map { (start: point.start, secondsPerKm: $0) }
        }
    }
}
