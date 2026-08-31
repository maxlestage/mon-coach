import Foundation
import Testing
@testable import MonCoachKit

@Suite("Séries de statistiques")
struct ActivityStatsTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    /// Un mercredi, pour que la semaine testée ne soit ni la première ni la
    /// dernière : les bornes se cassent aux extrémités, pas au milieu.
    private var today: Date {
        calendar.date(from: DateComponents(year: 2026, month: 4, day: 15, hour: 12))!
    }

    private func activity(
        daysAgo: Int,
        sport: Sport = .run,
        meters: Double = 10_000,
        minutes: Double = 50,
        bpm: Double? = nil
    ) -> ActivityLog {
        let start = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
        var log = ActivityLog(
            startedAt: start,
            sport: sport,
            type: .easy,
            meters: meters,
            duration: minutes * 60,
            elevationGain: 100
        )
        if let bpm {
            log.heartRate = (0..<Int(minutes * 60 / 10)).map {
                HeartRateSample(timestamp: start.addingTimeInterval(Double($0) * 10), bpm: bpm)
            }
        }
        return log
    }

    @Test("Les semaines sans sortie sont dans la série, à zéro")
    func emptyWeeksAreKept() {
        // Une seule sortie il y a cinq semaines : les autres semaines
        // existent quand même, sinon la courbe dessine une régularité que
        // personne n'a eue.
        let series = ActivityStats.weekly(
            of: [activity(daysAgo: 35)], weeks: 12, endingOn: today, calendar: calendar
        )
        #expect(series.count == 12)
        #expect(series.filter { !$0.isEmpty }.count == 1)
        #expect(series.filter(\.isEmpty).count == 11)
        // Et dans l'ordre du temps, du plus ancien au plus récent.
        #expect(series == series.sorted { $0.start < $1.start })
        #expect(series.last?.start == ActivityJournal.startOfWeek(of: today, calendar: calendar))
    }

    @Test("Le périmètre écarte les autres sports, sans les compter à moitié")
    func scopeFilters() {
        let logs = [
            activity(daysAgo: 1, sport: .run, meters: 10_000),
            activity(daysAgo: 2, sport: .ride, meters: 40_000),
            // Le 15 avril 2026 est un mercredi : trois jours plus tôt, on
            // tombe dans la semaine précédente. Ces trois-là sont bien tous
            // dans la semaine en cours.
            activity(daysAgo: 1, sport: .swim, meters: 0, minutes: 40),
        ]
        let all = ActivityStats.weekly(of: logs, weeks: 1, endingOn: today, calendar: calendar)
        let running = ActivityStats.weekly(
            of: logs, scope: .sport(.run), weeks: 1, endingOn: today, calendar: calendar
        )
        let onFoot = ActivityStats.weekly(
            of: logs, scope: .family(.foot), weeks: 1, endingOn: today, calendar: calendar
        )
        #expect(all.last?.activityCount == 3)
        #expect(running.last?.activityCount == 1)
        #expect(running.last?.meters == 10_000)
        #expect(onFoot.last?.activityCount == 1, "la natation et le vélo ne sont pas des sports à pied")
    }

    @Test("Les kilomètres ne s'additionnent pas entre sports différents")
    func distanceOnlyComparesWithinASport() {
        #expect(!ActivityStats.Scope.everything.comparesDistance, "10 km de course + 100 de vélo ne font pas 110")
        #expect(ActivityStats.Scope.sport(.run).comparesDistance)
        #expect(!ActivityStats.Scope.sport(.yoga).comparesDistance)
        #expect(ActivityStats.Scope.family(.wheels).comparesDistance)
        #expect(!ActivityStats.Scope.family(.indoor).comparesDistance)
    }

    @Test("La comparaison porte sur deux fenêtres de même longueur")
    func comparisonUsesEqualWindows() {
        let logs = [
            activity(daysAgo: 1, meters: 10_000),
            activity(daysAgo: 3, meters: 5_000),
            // La semaine d'avant : deux fois moins.
            activity(daysAgo: 9, meters: 7_500),
        ]
        let comparison = ActivityStats.comparison(
            of: logs, days: 7, endingOn: today, calendar: calendar
        )
        #expect(comparison.current.meters == 15_000)
        #expect(comparison.previous.meters == 7_500)
        #expect(comparison.change(\.meters).map { Int($0) } == 100)
        // Rien la semaine d'avant : pas de pourcentage plutôt qu'un infini.
        let fresh = ActivityStats.comparison(
            of: [activity(daysAgo: 1)], days: 7, endingOn: today, calendar: calendar
        )
        #expect(fresh.previous.activityCount == 0)
        #expect(fresh.change(\.meters) == nil)
    }

    @Test("La semaine se lit jour par jour, lundi en tête")
    func weekBubbles() {
        let bubbles = ActivityStats.week(
            of: [activity(daysAgo: 0), activity(daysAgo: 2, sport: .ride)],
            containing: today,
            calendar: calendar
        )
        #expect(bubbles.count == 7)
        #expect(bubbles.map(\.weekdayIndex) == Array(0...6))
        // Le 15 avril 2026 est un mercredi : index 2. Deux jours plus tôt,
        // le lundi : index 0.
        #expect(bubbles[2].activityCount == 1)
        #expect(bubbles[0].activityCount == 1)
        #expect(bubbles[0].sports == [.ride])
        #expect(bubbles[1].activityCount == 0, "le mardi doit rester vide et visible")
    }

    @Test("La répartition se compte en temps, du plus pratiqué au moins")
    func shareIsSortedByTime() {
        let logs = [
            activity(daysAgo: 1, sport: .run, minutes: 30),
            activity(daysAgo: 2, sport: .ride, minutes: 120),
            activity(daysAgo: 3, sport: .ride, minutes: 60),
            activity(daysAgo: 40, sport: .swim, minutes: 300),
        ]
        let since = calendar.date(byAdding: .day, value: -7, to: today)!
        let share = ActivityStats.share(of: logs, since: since, until: today)
        #expect(share.map(\.sport) == [.ride, .run], "la natation est hors période")
        #expect(share[0].seconds == 180 * 60)
        #expect(share[0].activityCount == 2)
    }

    @Test("Sans capteur cardiaque, les zones sont vides plutôt que fausses")
    func zonesNeedAHeartRate() {
        let since = calendar.date(byAdding: .day, value: -30, to: today)!
        let without = ActivityStats.heartRateZones(
            of: [activity(daysAgo: 1)], since: since, maximumBpm: 190, until: today
        )
        #expect(without.isEmpty, "cinq barres à zéro se lisent comme « tu ne t'entraînes pas »")

        let with = ActivityStats.heartRateZones(
            of: [activity(daysAgo: 1, minutes: 60, bpm: 150)],
            since: since, maximumBpm: 190, until: today
        )
        #expect(!with.isEmpty)
        #expect(with.values.reduce(0, +) > 3_000, "une heure à 150 doit peser une heure")
    }

    @Test("L'allure d'une semaine sans kilomètres n'est pas inventée")
    func paceNeedsDistance() {
        let series = ActivityStats.weekly(
            of: [activity(daysAgo: 1, meters: 10_000, minutes: 50)],
            scope: .sport(.run), weeks: 3, endingOn: today, calendar: calendar
        )
        #expect(series.last?.paceSecondsPerKm.map { Int($0) } == 300)
        #expect(series.first?.paceSecondsPerKm == nil, "une semaine vide n'a pas d'allure")

        // Et la tendance ne s'applique qu'à ce qui se lit en allure.
        #expect(ActivityStats.paceTrend(
            of: [activity(daysAgo: 1, sport: .ride)], sport: .ride, endingOn: today, calendar: calendar
        ).isEmpty, "un vélo se lit en km/h, pas en minutes par kilomètre")
    }

    @Test("La charge existe même sans ceinture cardiaque")
    func loadFallsBackToPerceivedEffort() {
        let noSensor = ActivityStats.weekly(
            of: [activity(daysAgo: 1, minutes: 60)], weeks: 1, endingOn: today, calendar: calendar
        )
        #expect((noSensor.last?.load ?? 0) > 0, "une courbe plate à zéro pour quelqu'un qui court")

        let sensor = ActivityStats.weekly(
            of: [activity(daysAgo: 1, minutes: 60, bpm: 165)],
            weeks: 1, endingOn: today, calendar: calendar, maximumBpm: 190
        )
        #expect((sensor.last?.load ?? 0) > 0)
    }

    @Test("Les mois vides comptent aussi, et dans l'ordre")
    func monthlySeries() {
        let series = ActivityStats.monthly(
            of: [activity(daysAgo: 40)], months: 6, endingOn: today, calendar: calendar
        )
        #expect(series.count == 6)
        #expect(series == series.sorted { $0.start < $1.start })
        #expect(series.filter { !$0.isEmpty }.count == 1)
    }
}
