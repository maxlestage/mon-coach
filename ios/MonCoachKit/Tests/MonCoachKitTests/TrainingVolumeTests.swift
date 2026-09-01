import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le volume, semaine par semaine")
struct TrainingVolumeTests {

    private let calendar = Calendar(identifier: .iso8601)
    /// Un mercredi, pour que la semaine en cours soit à moitié entamée —
    /// c'est le cas qui casse les compteurs mal écrits.
    private let today = ISO8601DateFormatter().date(from: "2026-09-02T12:00:00Z")!

    private func session(weeksAgo: Int, sets: Int, tonnage: Double = 0) -> SessionLog {
        let date = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today)!
        return SessionLog(
            date: date,
            sets: (0..<sets).map {
                SetLog(
                    date: date,
                    exerciseID: "back-squat",
                    setIndex: $0,
                    weightKg: tonnage / Double(max(sets, 1)) / 8,
                    reps: 8,
                    rpe: 8
                )
            }
        )
    }

    @Test("Les semaines sans séance restent dans la série")
    func emptyWeeksSurvive() {
        // C'est tout le sujet : deux séances espacées d'un mois donnaient
        // deux barres côte à côte, aussi larges que l'écran, sans trou
        // visible et sans axe du temps.
        let weeks = TrainingVolume.weeks(
            from: [session(weeksAgo: 0, sets: 6), session(weeksAgo: 4, sets: 6)],
            window: 12, endingOn: today, calendar: calendar
        )
        #expect(weeks.count == 12)
        let worked = weeks.filter { !$0.isEmpty }.count
        #expect(worked == 2)
        #expect(weeks.last?.sets == 6, "la dernière case est la semaine en cours")
        let twoWeeksAgo = weeks[weeks.count - 3]
        #expect(twoWeeksAgo.isEmpty, "le trou d'il y a deux semaines se voit")
    }

    @Test("La fenêtre se termine toujours sur la semaine en cours")
    func windowEndsOnThisWeek() throws {
        let weeks = TrainingVolume.weeks(from: [], window: 4, endingOn: today, calendar: calendar)
        let thisWeek = try #require(calendar.dateInterval(of: .weekOfYear, for: today)?.start)
        #expect(weeks.last?.start == thisWeek)
        let allEmpty = weeks.allSatisfy(\.isEmpty)
        #expect(allEmpty)
        // Une fenêtre vide reste une fenêtre : le graphique doit pouvoir se
        // dessiner avant la première séance, sinon il apparaît d'un coup un
        // jour et personne ne sait d'où il sort.
        #expect(weeks.count == 4)
    }

    @Test("Les séances sautées ne comptent pas")
    func skippedSessionsAreIgnored() {
        var skipped = session(weeksAgo: 0, sets: 6)
        skipped.skipped = true
        let weeks = TrainingVolume.weeks(
            from: [skipped], window: 4, endingOn: today, calendar: calendar
        )
        let allEmpty = weeks.allSatisfy(\.isEmpty)
        #expect(allEmpty)
    }

    @Test("Plusieurs séances dans la même semaine s'additionnent")
    func sessionsInAWeekAddUp() {
        let weeks = TrainingVolume.weeks(
            from: [session(weeksAgo: 0, sets: 6), session(weeksAgo: 0, sets: 4)],
            window: 4, endingOn: today, calendar: calendar
        )
        #expect(weeks.last?.sets == 10)
        #expect(weeks.last?.sessions == 2)
    }

    @Test("La moyenne ignore les semaines où l'on n'y est pas allé")
    func averageSkipsEmptyWeeks() {
        // Inclure les semaines d'avant l'inscription tirerait la référence
        // vers zéro et donnerait une ligne qui ne veut rien dire.
        let weeks = TrainingVolume.weeks(
            from: [session(weeksAgo: 0, sets: 10), session(weeksAgo: 1, sets: 6)],
            window: 12, endingOn: today, calendar: calendar
        )
        #expect(TrainingVolume.average(of: weeks, measure: .sets) == 8)
    }

    @Test("Sans aucune semaine travaillée, il n'y a pas de moyenne")
    func noAverageWithoutWork() {
        let weeks = TrainingVolume.weeks(from: [], window: 12, endingOn: today, calendar: calendar)
        #expect(TrainingVolume.average(of: weeks, measure: .sets) == nil)
        #expect(TrainingVolume.best(of: weeks, measure: .sets) == nil)
        #expect(TrainingVolume.standing(of: weeks, measure: .sets) == nil)
    }

    @Test("La semaine en cours se compare aux précédentes, pas à elle-même")
    func standingExcludesTheCurrentWeek() throws {
        let weeks = TrainingVolume.weeks(
            from: [
                session(weeksAgo: 0, sets: 4),
                session(weeksAgo: 1, sets: 10),
                session(weeksAgo: 2, sets: 10),
            ],
            window: 12, endingOn: today, calendar: calendar
        )
        let standing = try #require(TrainingVolume.standing(of: weeks, measure: .sets))
        #expect(standing.current == 4)
        // Dix, pas huit : s'inclure dans sa propre référence adoucirait
        // toujours l'écart, et c'est l'écart qu'on veut voir.
        #expect(standing.average == 10)
        #expect(standing.difference == -6)
    }

    @Test("La meilleure semaine est celle qui a le plus de la mesure choisie")
    func bestWeekFollowsTheMeasure() throws {
        let weeks = TrainingVolume.weeks(
            from: [
                session(weeksAgo: 0, sets: 4, tonnage: 8_000),
                session(weeksAgo: 1, sets: 12, tonnage: 2_000),
            ],
            window: 12, endingOn: today, calendar: calendar
        )
        #expect(TrainingVolume.best(of: weeks, measure: .sets)?.sets == 12)
        #expect(TrainingVolume.best(of: weeks, measure: .tonnage)?.sets == 4)
    }
}

@Suite("Les semaines d'affilée")
struct TrainingStreakTests {

    private let calendar = Calendar(identifier: .iso8601)
    private let today = ISO8601DateFormatter().date(from: "2026-09-02T12:00:00Z")!

    private func session(weeksAgo: Int) -> SessionLog {
        SessionLog(date: calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: today)!)
    }

    @Test("Trois semaines de suite font trois")
    func consecutiveWeeksCount() {
        let logs = [session(weeksAgo: 0), session(weeksAgo: 1), session(weeksAgo: 2)]
        #expect(TrainingVolume.streak(from: logs, endingOn: today, calendar: calendar) == 3)
    }

    @Test("Une semaine en cours encore vide ne casse pas la série")
    func theCurrentWeekIsNotFinished() {
        // On est mercredi et on n'y est pas encore allé : annoncer que la
        // série est cassée serait faux, et décourageant au pire moment.
        let logs = [session(weeksAgo: 1), session(weeksAgo: 2)]
        #expect(TrainingVolume.streak(from: logs, endingOn: today, calendar: calendar) == 2)
    }

    @Test("Un trou casse la série")
    func aGapEndsTheStreak() {
        let logs = [session(weeksAgo: 0), session(weeksAgo: 2), session(weeksAgo: 3)]
        #expect(TrainingVolume.streak(from: logs, endingOn: today, calendar: calendar) == 1)
    }

    @Test("Sans séance, la série vaut zéro")
    func noSessionsNoStreak() {
        #expect(TrainingVolume.streak(from: [], endingOn: today, calendar: calendar) == 0)
    }
}
