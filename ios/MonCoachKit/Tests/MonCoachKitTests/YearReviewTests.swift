import Foundation
import Testing
@testable import MonCoachKit

@Suite("Ton année sportive")
struct YearReviewTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 10))!
    }

    private func activity(
        _ year: Int, _ month: Int, _ day: Int,
        meters: Double = 10_000,
        seconds: TimeInterval = 3_000,
        climb: Double = 100,
        sport: Sport = .run
    ) -> ActivityLog {
        ActivityLog(
            startedAt: date(year, month, day),
            sport: sport,
            type: .easy,
            meters: meters,
            duration: seconds,
            elevationGain: climb
        )
    }

    @Test("Une année vide se dit vide, sans inventer de mois")
    func emptyYearStaysEmpty() {
        let review = YearReview.review(of: [], year: 2026, calendar: calendar)
        #expect(review.isEmpty)
        #expect(review.months.count == 12, "un bilan doit toujours porter ses douze mois")
        #expect(review.months.allSatisfy { $0.totals.activityCount == 0 })
        #expect(review.busiestMonth == nil)
        #expect(review.metersVersusPreviousYear == nil)
    }

    @Test("Seule l'année demandée compte")
    func otherYearsStayOut() {
        let logs = [
            activity(2025, 6, 1, meters: 50_000),
            activity(2026, 3, 2, meters: 10_000),
            activity(2026, 3, 9, meters: 12_000),
            activity(2027, 1, 4, meters: 99_000),
        ]
        let review = YearReview.review(of: logs, year: 2026, calendar: calendar)
        #expect(review.totals.activityCount == 2)
        #expect(review.totals.meters == 22_000)
        #expect(review.previousYearMeters == 50_000)
        #expect(review.metersVersusPreviousYear == -28_000, "l'année d'avant était meilleure, il faut le dire")
    }

    @Test("La première année ne se compare à rien")
    func firstYearHasNoComparison() {
        let review = YearReview.review(of: [activity(2026, 5, 5)], year: 2026, calendar: calendar)
        #expect(review.previousYearMeters == nil)
        #expect(review.metersVersusPreviousYear == nil)
    }

    @Test("Le mois le plus chargé est celui qui porte le plus de kilomètres")
    func busiestMonthIsTheLongest() {
        let logs = [
            activity(2026, 2, 3, meters: 5_000),
            activity(2026, 9, 3, meters: 20_000),
            activity(2026, 9, 10, meters: 20_000),
            activity(2026, 11, 3, meters: 30_000),
        ]
        let review = YearReview.review(of: logs, year: 2026, calendar: calendar)
        #expect(review.busiestMonth?.month == 9, "septembre porte 40 km, novembre 30")
        #expect(review.months[8].totals.activityCount == 2)
    }

    @Test("Deux sorties le même jour font un jour actif, pas deux")
    func activeDaysCountDays() {
        let logs = [
            activity(2026, 4, 1),
            ActivityLog(
                startedAt: calendar.date(from: DateComponents(year: 2026, month: 4, day: 1, hour: 18))!,
                sport: .ride, type: .easy, meters: 30_000, duration: 3_600, elevationGain: 50
            ),
            activity(2026, 4, 2),
        ]
        let review = YearReview.review(of: logs, year: 2026, calendar: calendar)
        #expect(review.activeDays == 2)
        #expect(review.totals.activityCount == 3)
        #expect(review.bySport[.ride]?.activityCount == 1)
        #expect(review.bySport[.run]?.activityCount == 2)
    }

    @Test("La plus longue série compte les semaines qui se suivent")
    func streakCountsConsecutiveWeeks() {
        // Trois semaines d'affilée, un trou, puis deux.
        let logs = [
            activity(2026, 1, 5), activity(2026, 1, 12), activity(2026, 1, 19),
            activity(2026, 2, 2), activity(2026, 2, 9),
        ]
        let review = YearReview.review(of: logs, year: 2026, calendar: calendar)
        #expect(review.longestStreakWeeks == 3)
    }

    @Test("La plus longue sortie et la plus haute ne sont pas forcément la même")
    func highlightsAreFoundSeparately() {
        let flat = activity(2026, 5, 1, meters: 42_000, climb: 20)
        let steep = activity(2026, 6, 1, meters: 12_000, climb: 1_400, sport: .trail)
        let review = YearReview.review(of: [flat, steep], year: 2026, calendar: calendar)
        #expect(review.longestActivity?.activityID == flat.id)
        #expect(review.highestClimb?.activityID == steep.id)
        #expect(review.highestClimb?.sport == .trail)
    }

    @Test("Une année sans dénivelé n'invente pas de sommet")
    func flatYearHasNoClimb() {
        let review = YearReview.review(
            of: [activity(2026, 5, 1, climb: 0)], year: 2026, calendar: calendar
        )
        #expect(review.highestClimb == nil)
        #expect(review.everests == nil, "sous un Everest, la comparaison ne dit rien")
        #expect(review.marathons == nil, "10 km ne font pas un marathon")
    }

    @Test("Les comparaisons ne sortent qu'au-delà de l'unité")
    func comparisonsNeedAWholeUnit() {
        let big = (1...40).map { activity(2026, ($0 % 12) + 1, ($0 % 27) + 1, meters: 30_000, climb: 500) }
        let review = YearReview.review(of: big, year: 2026, calendar: calendar)
        #expect((review.marathons ?? 0) > 25, "1 200 km font bien plus qu'un marathon")
        #expect((review.everests ?? 0) > 2, "20 000 m de D+ font plus de deux Everest")
    }

    @Test("Les records de l'année sont ceux qui tiennent encore et datent de cette année")
    func recordsAreThisYearsSurvivors() {
        // Une sortie rapide en 2026, la même distance plus lente en 2027 :
        // le record reste celui de 2026, et n'apparaît pas dans le bilan 2027.
        let fast = traced(year: 2026, secondsPerKm: 240)
        let slow = traced(year: 2027, secondsPerKm: 300)
        let review2026 = YearReview.review(of: [fast, slow], year: 2026, calendar: calendar)
        let review2027 = YearReview.review(of: [fast, slow], year: 2027, calendar: calendar)
        #expect(!review2026.records.isEmpty, "la sortie la plus rapide a bien posé des records")
        #expect(review2027.records.isEmpty, "une sortie plus lente ne pose aucun record")
    }

    @Test("Le partage dit l'année, le nombre de sorties et la distance")
    func summaryReadsLikeASentence() {
        let logs = [activity(2026, 3, 1, meters: 10_000), activity(2026, 3, 8, meters: 15_000)]
        let review = YearReview.review(of: logs, year: 2026, calendar: calendar)
        let text = review.summary(unit: .metric, language: .french)
        #expect(text.contains("2026"))
        #expect(text.contains("2 sorties"))
        #expect(text.contains("25"), "25 km doivent apparaître dans la phrase : \(text)")
    }

    @Test("Les années disponibles vont de la plus récente à la plus ancienne")
    func yearsComeNewestFirst() {
        let logs = [activity(2024, 1, 1), activity(2026, 1, 1), activity(2024, 6, 1)]
        #expect(YearReview.availableYears(in: logs, calendar: calendar) == [2026, 2024])
        #expect(YearReview.availableYears(in: [], calendar: calendar).isEmpty)
    }

    /// Une sortie avec une vraie trace, pour que les records existent.
    private func traced(year: Int, secondsPerKm: Double) -> ActivityLog {
        let start = date(year, 7, 1)
        var points: [GPSPoint] = []
        // Six kilomètres plein nord, un point toutes les dix secondes.
        let step = 10.0
        let metersPerSecond = 1_000 / secondsPerKm
        var travelled = 0.0
        var elapsed = 0.0
        while travelled <= 6_000 {
            points.append(GPSPoint(
                timestamp: start.addingTimeInterval(elapsed),
                latitude: 48.85 + travelled / 111_320,
                longitude: 2.35,
                altitude: 40
            ))
            travelled += metersPerSecond * step
            elapsed += step
        }
        return TraceAnalysis.summarise(rawPoints: points, sport: .run, type: .tempo)
    }
}
