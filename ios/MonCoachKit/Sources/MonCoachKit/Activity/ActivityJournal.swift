import Foundation

/// Les totaux d'une période, un sport ou tous.
public struct PeriodTotals: Sendable, Equatable {
    public var activityCount: Int
    public var meters: Double
    public var movingSeconds: TimeInterval
    public var elevationGain: Double
    /// Charge cardiaque cumulée, quand des battements existaient.
    public var trainingLoad: Double

    public static let zero = PeriodTotals(
        activityCount: 0, meters: 0, movingSeconds: 0, elevationGain: 0, trainingLoad: 0
    )

    public init(
        activityCount: Int,
        meters: Double,
        movingSeconds: TimeInterval,
        elevationGain: Double,
        trainingLoad: Double
    ) {
        self.activityCount = activityCount
        self.meters = meters
        self.movingSeconds = movingSeconds
        self.elevationGain = elevationGain
        self.trainingLoad = trainingLoad
    }
}

/// Une semaine du journal, prête à afficher.
public struct JournalWeek: Sendable, Equatable, Identifiable {
    public var id: Date { start }
    /// Le lundi de la semaine, à minuit.
    public var start: Date
    public var totals: PeriodTotals
    /// Totaux par sport, pour la répartition.
    public var bySport: [Sport: PeriodTotals]
}

/// Le journal : totaux, séries, répartitions — la mémoire de l'athlète.
public enum ActivityJournal {

    /// Les totaux d'un ensemble d'activités.
    public static func totals(
        of activities: [ActivityLog],
        maximumBpm: Double? = nil
    ) -> PeriodTotals {
        var result = PeriodTotals.zero
        // Les trajets ne comptent pas comme des séances. Sans cette ligne,
        // deux allers-retours au travail feraient une semaine à cinq
        // activités et cent kilomètres, et le coach en tirerait une charge
        // qu'aucune jambe n'a portée.
        for activity in activities where activity.sport.countsAsTraining {
            result.activityCount += 1
            result.meters += activity.meters
            result.movingSeconds += activity.duration
            result.elevationGain += activity.elevationGain
            if let maximumBpm, !activity.heartRate.isEmpty {
                result.trainingLoad += HeartRateAnalysis.trainingLoad(
                    secondsPerZone: HeartRateAnalysis.secondsPerZone(
                        samples: activity.heartRate, maximumBpm: maximumBpm
                    )
                )
            }
        }
        return result
    }

    /// Le journal par semaine, la plus récente d'abord.
    ///
    /// Les semaines vides sont incluses entre la première et la dernière
    /// activité : un journal qui saute les semaines sans sortie raconte une
    /// assiduité qui n'existe pas — le trou EST l'information.
    public static func weeks(
        of activities: [ActivityLog],
        upTo today: Date = Date(),
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> [JournalWeek] {
        // La première semaine du journal est celle de la première séance, et
        // non celle du premier trajet : un aller-retour fait six mois avant
        // de commencer à s'entraîner ouvrirait vingt-six semaines vides.
        let training = activities.filter { $0.sport.countsAsTraining }
        guard let earliest = training.map(\.startedAt).min() else { return [] }
        guard var cursor = startOfWeek(of: earliest, calendar: calendar) else { return [] }
        let last = startOfWeek(of: today, calendar: calendar) ?? today

        var byWeek: [Date: [ActivityLog]] = [:]
        for activity in activities where activity.sport.countsAsTraining {
            if let week = startOfWeek(of: activity.startedAt, calendar: calendar) {
                byWeek[week, default: []].append(activity)
            }
        }

        var result: [JournalWeek] = []
        while cursor <= last {
            let inWeek = byWeek[cursor] ?? []
            var bySport: [Sport: PeriodTotals] = [:]
            for sport in Set(inWeek.map(\.sport)) {
                bySport[sport] = totals(of: inWeek.filter { $0.sport == sport }, maximumBpm: maximumBpm)
            }
            result.append(JournalWeek(
                start: cursor,
                totals: totals(of: inWeek, maximumBpm: maximumBpm),
                bySport: bySport
            ))
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: cursor) else { break }
            cursor = next
        }
        return result.reversed()
    }

    /// Le lundi de la semaine d'une date. La semaine d'un athlète commence
    /// le lundi quel que soit le réglage régional : « cette semaine » doit
    /// vouloir dire la même chose pour tout le monde dans un même plan.
    static func startOfWeek(of date: Date, calendar: Calendar = .current) -> Date? {
        var mondayFirst = calendar
        mondayFirst.firstWeekday = 2
        return mondayFirst.dateInterval(of: .weekOfYear, for: date)?.start
    }

    /// La série en cours : le nombre de semaines consécutives, jusqu'à
    /// aujourd'hui, avec au moins une activité.
    ///
    /// La semaine courante compte si elle a une activité, mais ne casse pas
    /// la série tant qu'elle est en cours : dire « série terminée » un mardi
    /// parce qu'on n'a pas encore couru serait une punition d'avance.
    public static func weeklyStreak(
        of activities: [ActivityLog],
        today: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard let thisWeek = startOfWeek(of: today, calendar: calendar) else { return 0 }
        let weeksWithActivity = Set(activities.compactMap { startOfWeek(of: $0.startedAt, calendar: calendar) })
        var streak = 0
        var cursor = thisWeek
        // La semaine courante : comptée si active, tolérée sinon.
        if weeksWithActivity.contains(cursor) { streak += 1 }
        while let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor),
              weeksWithActivity.contains(previous) {
            streak += 1
            cursor = previous
        }
        return streak
    }

    /// Les totaux de l'année, par sport — le bilan annuel.
    public static func yearBySport(
        of activities: [ActivityLog],
        year: Int,
        calendar: Calendar = .current,
        maximumBpm: Double? = nil
    ) -> [Sport: PeriodTotals] {
        let inYear = activities.filter { calendar.component(.year, from: $0.startedAt) == year }
        var result: [Sport: PeriodTotals] = [:]
        for sport in Set(inYear.map(\.sport)) {
            result[sport] = totals(of: inYear.filter { $0.sport == sport }, maximumBpm: maximumBpm)
        }
        return result
    }
}

/// La carte de chaleur : toutes les traces, agrégées en une image de là où
/// l'athlète va. Calculée sur l'appareil, comme tout le reste — c'est
/// exactement le genre de donnée qui ne doit jamais partir : l'agrégat des
/// trajets d'une personne est son domicile, son travail et ses habitudes.
public enum Heatmap {

    /// Une case de la grille, avec son poids.
    public struct Cell: Sendable, Equatable {
        /// Position dans la grille, colonne puis ligne, depuis le coin
        /// sud-ouest de l'emprise.
        public var column: Int
        public var row: Int
        /// Nombre de passages distincts (d'activités différentes).
        public var visits: Int
    }

    /// La grille entière.
    public struct Grid: Sendable, Equatable {
        public var minLatitude: Double
        public var minLongitude: Double
        public var maxLatitude: Double
        public var maxLongitude: Double
        public var columns: Int
        public var rows: Int
        public var cells: [Cell]
        /// Le plus grand nombre de passages d'une case, pour normaliser.
        public var maxVisits: Int
    }

    /// Agrège les traces en grille de cases d'environ `cellMeters` de côté.
    ///
    /// Le poids d'une case est le nombre d'ACTIVITÉS qui y passent, pas le
    /// nombre de points : sans cela, l'endroit où l'athlète attend au feu —
    /// dix points immobiles — pèserait comme dix passages, et la carte
    /// montrerait les feux rouges plutôt que les parcours.
    public static func grid(
        of activities: [ActivityLog],
        cellMeters: Double = 75,
        maxCells: Int = 40_000
    ) -> Grid? {
        let all = activities.flatMap { activity in
            activity.points.isEmpty ? [] : [activity]
        }
        guard !all.isEmpty else { return nil }

        var minLat = Double.greatestFiniteMagnitude
        var maxLat = -Double.greatestFiniteMagnitude
        var minLon = Double.greatestFiniteMagnitude
        var maxLon = -Double.greatestFiniteMagnitude
        for activity in all {
            for point in activity.points where point.latitude.isFinite && point.longitude.isFinite {
                minLat = Swift.min(minLat, point.latitude)
                maxLat = Swift.max(maxLat, point.latitude)
                minLon = Swift.min(minLon, point.longitude)
                maxLon = Swift.max(maxLon, point.longitude)
            }
        }
        guard minLat <= maxLat, minLon <= maxLon else { return nil }

        let metersPerDegreeLat = 111_320.0
        let midLatitude = (minLat + maxLat) / 2
        let metersPerDegreeLon = max(1, 111_320.0 * cos(midLatitude * .pi / 180))
        var cell = cellMeters
        func dimensions(for cellSize: Double) -> (columns: Int, rows: Int) {
            (
                max(1, Int(((maxLon - minLon) * metersPerDegreeLon / cellSize).rounded(.up))),
                max(1, Int(((maxLat - minLat) * metersPerDegreeLat / cellSize).rounded(.up)))
            )
        }
        // Un athlète qui a couru à Paris et à Lisbonne a une emprise de mille
        // kilomètres : à 75 m la case, la grille exploserait la mémoire. On
        // élargit les cases jusqu'à tenir — la carte perd du détail, pas des
        // données.
        var (columns, rows) = dimensions(for: cell)
        while columns * rows > maxCells {
            cell *= 2
            (columns, rows) = dimensions(for: cell)
        }

        var visitedBy: [Int: Set<UUID>] = [:]
        for activity in all {
            for point in activity.points where point.latitude.isFinite && point.longitude.isFinite {
                let column = Swift.min(columns - 1, Int((point.longitude - minLon) * metersPerDegreeLon / cell))
                let row = Swift.min(rows - 1, Int((point.latitude - minLat) * metersPerDegreeLat / cell))
                visitedBy[row * columns + column, default: []].insert(activity.id)
            }
        }

        let cells = visitedBy.map { key, visitors in
            Cell(column: key % columns, row: key / columns, visits: visitors.count)
        }
        return Grid(
            minLatitude: minLat,
            minLongitude: minLon,
            maxLatitude: maxLat,
            maxLongitude: maxLon,
            columns: columns,
            rows: rows,
            cells: cells.sorted { ($0.row, $0.column) < ($1.row, $1.column) },
            maxVisits: cells.map(\.visits).max() ?? 1
        )
    }
}
