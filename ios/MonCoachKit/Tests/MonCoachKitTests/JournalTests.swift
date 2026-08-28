import Foundation
import Testing
@testable import MonCoachKit

// Un calendrier fixe : les tests de semaines ne doivent pas dépendre du
// fuseau de la machine qui les exécute.
private let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    return calendar
}()

/// Une activité minimale un jour donné.
private func activity(
    day: String,
    sport: Sport = .run,
    meters: Double = 8_000,
    id: UUID = UUID()
) -> ActivityLog {
    let formatter = ISO8601DateFormatter()
    return ActivityLog(
        id: id,
        startedAt: formatter.date(from: day + "T10:00:00Z")!,
        sport: sport,
        type: .easy,
        meters: meters,
        duration: meters / 3,
        elevationGain: 40
    )
}

@Suite("Journal")
struct JournalTests {

    @Test("Les totaux additionnent ce qui doit l'être")
    func totalsAddUp() {
        let totals = ActivityJournal.totals(of: [
            activity(day: "2026-08-03", meters: 10_000),
            activity(day: "2026-08-05", sport: .ride, meters: 30_000),
        ])
        #expect(totals.activityCount == 2)
        #expect(totals.meters == 40_000)
        #expect(totals.elevationGain == 80)
    }

    @Test("Une semaine sans sortie apparaît dans le journal : le trou est l'information")
    func emptyWeeksAreKept() throws {
        // Une activité début août, une trois semaines plus tard.
        let weeks = ActivityJournal.weeks(
            of: [activity(day: "2026-08-03"), activity(day: "2026-08-25")],
            upTo: ISO8601DateFormatter().date(from: "2026-08-28T12:00:00Z")!,
            calendar: utc
        )
        #expect(weeks.count == 4, Comment(rawValue: "quatre semaines, dont deux vides (\(weeks.count))"))
        let empty = weeks.filter { $0.totals.activityCount == 0 }
        #expect(empty.count == 2)
        // La plus récente d'abord.
        #expect(weeks[0].start > weeks[1].start)
    }

    @Test("La semaine commence le lundi, pas selon le réglage régional")
    func weeksStartOnMonday() throws {
        // Le 2026-08-09 est un dimanche : il appartient à la semaine du
        // lundi 3, même pour un calendrier américain qui commence dimanche.
        var american = Calendar(identifier: .gregorian)
        american.timeZone = TimeZone(identifier: "UTC")!
        american.firstWeekday = 1
        let start = try #require(ActivityJournal.startOfWeek(
            of: ISO8601DateFormatter().date(from: "2026-08-09T10:00:00Z")!,
            calendar: american
        ))
        #expect(utc.component(.weekday, from: start) == 2, "un lundi")
        #expect(utc.component(.day, from: start) == 3)
    }

    @Test("La répartition par sport sépare le vélo de la course")
    func sportsAreSeparated() throws {
        let weeks = ActivityJournal.weeks(
            of: [
                activity(day: "2026-08-25", sport: .run, meters: 8_000),
                activity(day: "2026-08-26", sport: .ride, meters: 40_000),
            ],
            upTo: ISO8601DateFormatter().date(from: "2026-08-28T12:00:00Z")!,
            calendar: utc
        )
        let week = try #require(weeks.first)
        #expect(week.bySport[.run]?.meters == 8_000)
        #expect(week.bySport[.ride]?.meters == 40_000)
    }

    @Test("La série compte les semaines consécutives, et pardonne la semaine en cours")
    func streakForgivesTheCurrentWeek() {
        let today = ISO8601DateFormatter().date(from: "2026-08-26T12:00:00Z")!  // mercredi
        // Trois semaines pleines avant la semaine courante, rien cette semaine.
        let history = [
            activity(day: "2026-08-05"), activity(day: "2026-08-12"), activity(day: "2026-08-19"),
        ]
        #expect(ActivityJournal.weeklyStreak(of: history, today: today, calendar: utc) == 3,
                "la semaine en cours, encore vide, ne casse pas la série")
        // Avec une sortie cette semaine, elle compte.
        let withThisWeek = history + [activity(day: "2026-08-25")]
        #expect(ActivityJournal.weeklyStreak(of: withThisWeek, today: today, calendar: utc) == 4)
        // Un trou la semaine dernière casse tout.
        let broken = [activity(day: "2026-08-05"), activity(day: "2026-08-25")]
        #expect(ActivityJournal.weeklyStreak(of: broken, today: today, calendar: utc) == 1)
        #expect(ActivityJournal.weeklyStreak(of: [], today: today, calendar: utc) == 0)
    }

    @Test("Le bilan annuel ne mélange pas les années")
    func yearsDoNotBleed() {
        let bySport = ActivityJournal.yearBySport(
            of: [
                activity(day: "2025-12-31", meters: 10_000),
                activity(day: "2026-01-01", meters: 8_000),
            ],
            year: 2026,
            calendar: utc
        )
        #expect(bySport[.run]?.meters == 8_000)
    }
}

@Suite("Carte de chaleur")
struct HeatmapTests {

    /// Une trace en ligne droite entre deux longitudes, à latitude fixe.
    private func line(
        from start: Double,
        to end: Double,
        latitude: Double = 48.85,
        id: UUID = UUID()
    ) -> ActivityLog {
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        let points = (0...100).map { index -> GPSPoint in
            let ratio = Double(index) / 100
            return GPSPoint(
                timestamp: begin.addingTimeInterval(Double(index)),
                latitude: latitude,
                longitude: start + (end - start) * ratio,
                altitude: 100
            )
        }
        return ActivityLog(
            id: id, startedAt: begin, sport: .run, type: .easy,
            points: points, meters: 1_000, duration: 300, elevationGain: 0
        )
    }

    @Test("Le poids d'une case est le nombre d'activités, pas de points")
    func visitsCountActivitiesNotPoints() throws {
        // Deux sorties sur le même chemin, une ailleurs. Les cases du chemin
        // partagé valent 2 — même si chaque sortie y a laissé cent points.
        let shared1 = line(from: 2.350, to: 2.360)
        let shared2 = line(from: 2.350, to: 2.360)
        let elsewhere = line(from: 2.380, to: 2.390)
        let grid = try #require(Heatmap.grid(of: [shared1, shared2, elsewhere]))

        #expect(grid.maxVisits == 2, "le chemin couru deux fois pèse 2, pas 200")
        let weights = Set(grid.cells.map(\.visits))
        #expect(weights == [1, 2])
    }

    @Test("Un athlète immobile au feu rouge ne fabrique pas un point chaud")
    func idlingDoesNotBurn() throws {
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        // Cent points au même endroit — l'attente au feu.
        let idle = ActivityLog(
            startedAt: begin, sport: .run, type: .easy,
            points: (0...100).map {
                GPSPoint(timestamp: begin.addingTimeInterval(Double($0)), latitude: 48.85, longitude: 2.35, altitude: 100)
            },
            meters: 0, duration: 100, elevationGain: 0
        )
        let grid = try #require(Heatmap.grid(of: [idle]))
        #expect(grid.maxVisits == 1)
    }

    @Test("Une emprise continentale élargit les cases au lieu d'exploser")
    func continentalSpanCoarsensTheGrid() throws {
        // Paris et Lisbonne : ~1 450 km. À 75 m la case, la grille naïve
        // ferait des centaines de millions de cases.
        let paris = line(from: 2.350, to: 2.360, latitude: 48.85)
        let lisbon = line(from: -9.14, to: -9.13, latitude: 38.72)
        let grid = try #require(Heatmap.grid(of: [paris, lisbon]))
        #expect(grid.columns * grid.rows <= 40_000)
        #expect(!grid.cells.isEmpty)
    }

    @Test("Des coordonnées invalides sont ignorées sans casser la grille")
    func garbageCoordinatesAreSkipped() throws {
        let begin = Date(timeIntervalSince1970: 1_700_000_000)
        var poisoned = line(from: 2.350, to: 2.360)
        poisoned.points.append(GPSPoint(timestamp: begin, latitude: .nan, longitude: .infinity, altitude: 0))
        let grid = try #require(Heatmap.grid(of: [poisoned]))
        #expect(grid.maxLatitude < 90)
        #expect(grid.cells.allSatisfy { $0.column >= 0 && $0.row >= 0 })
    }

    @Test("Sans aucune trace, pas de grille")
    func noTraceNoGrid() {
        #expect(Heatmap.grid(of: []) == nil)
        let empty = ActivityLog(
            startedAt: Date(), sport: .run, type: .easy,
            meters: 0, duration: 0, elevationGain: 0
        )
        #expect(Heatmap.grid(of: [empty]) == nil)
    }
}
