import Foundation
import Testing
@testable import MonCoachKit

/// Le compte des trajets.
///
/// Il existe parce que le mode conduite avait trop bien réussi : à force
/// d'exclure les trajets de tout, l'application enregistrait fidèlement une
/// donnée qu'elle ne montrait plus jamais. Ces tests gardent les deux
/// moitiés de la règle — les trajets restent hors du sport, et ils existent
/// quelque part.
@Suite("Le compte des trajets")
struct TravelStatsTests {

    private let calendar = Calendar(identifier: .gregorian)

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 9
        var utc = Calendar(identifier: .gregorian)
        utc.timeZone = TimeZone(identifier: "UTC")!
        return utc.date(from: components)!
    }

    private func trip(_ when: Date, km: Double, minutes: Double) -> ActivityLog {
        ActivityLog(
            startedAt: when, sport: .driving, type: .easy,
            meters: km * 1_000, duration: minutes * 60, elevationGain: 0
        )
    }

    private func run(_ when: Date, km: Double) -> ActivityLog {
        ActivityLog(
            startedAt: when, sport: .run, type: .easy,
            meters: km * 1_000, duration: 3_000, elevationGain: 0
        )
    }

    private var mixed: [ActivityLog] {
        [
            trip(date(2026, 3, 2), km: 120, minutes: 95),
            run(date(2026, 3, 3), km: 10),
            trip(date(2026, 3, 18), km: 40, minutes: 45),
            run(date(2026, 4, 1), km: 12),
            trip(date(2026, 4, 6), km: 300, minutes: 180),
        ]
    }

    @Test("Seuls les trajets sont comptés")
    func onlyTripsAreCounted() {
        let trips = TravelStats.trips(in: mixed)
        #expect(trips.count == 3)
        #expect(trips.allSatisfy { $0.sport == .driving })
    }

    /// Trois écrans demandent cette liste : la trier ici évite qu'un des
    /// trois affiche un historique dans l'ordre d'enregistrement.
    @Test("Les trajets viennent du plus récent au plus ancien")
    func tripsComeNewestFirst() {
        let trips = TravelStats.trips(in: mixed)
        #expect(trips.map(\.startedAt) == trips.map(\.startedAt).sorted(by: >))
    }

    @Test("Le total dit les kilomètres, le temps et le nombre")
    func theTotalSaysEverything() {
        let summary = TravelStats.summary(of: mixed)
        #expect(summary.tripCount == 3)
        #expect(abs(summary.meters - 460_000) < 1)
        #expect(abs(summary.seconds - 320 * 60) < 1)
    }

    /// La moyenne porte sur le temps total, arrêts compris : c'est la
    /// question qu'on se pose sur un trajet — combien de temps il a pris.
    @Test("La vitesse moyenne compte les arrêts")
    func theAverageCountsTheStops() {
        let summary = TravelStats.summary(of: [trip(date(2026, 3, 2), km: 120, minutes: 120)])
        #expect(abs(summary.averageSpeedKmh - 60) < 0.01)
    }

    @Test("Un trajet immobile ne divise pas par zéro")
    func amotionlessTripDoesNotDivideByZero() {
        let summary = TravelStats.summary(
            of: [ActivityLog(startedAt: date(2026, 3, 2), sport: .driving, type: .easy,
                             meters: 0, duration: 0, elevationGain: 0)]
        )
        #expect(summary.averageSpeedKmh == 0)
    }

    @Test("Les bornes de période sont respectées")
    func theWindowIsRespected() {
        let march = TravelStats.summary(
            of: mixed, since: date(2026, 3, 1), until: date(2026, 3, 31)
        )
        #expect(march.tripCount == 2)
        #expect(abs(march.meters - 160_000) < 1)
    }

    @Test("Le compte par mois range chaque trajet dans son mois")
    func monthsAreSeparated() {
        let months = TravelStats.byMonth(of: mixed, calendar: calendar)
        #expect(months.count == 2)
        #expect(months[0].start > months[1].start)
        #expect(months[0].summary.tripCount == 1)
        #expect(months[1].summary.tripCount == 2)
    }

    /// Contrairement au journal d'entraînement, qui garde ses semaines
    /// vides parce qu'un trou dit quelque chose sur l'assiduité. Un mois
    /// sans trajet ne dit rien : on n'a pas pris la voiture, et personne ne
    /// s'est fixé d'objectif là-dessus.
    @Test("Les mois sans trajet sont omis, contrairement aux semaines vides")
    func emptyMonthsAreOmitted() {
        let far = [
            trip(date(2026, 1, 5), km: 20, minutes: 25),
            trip(date(2026, 6, 5), km: 20, minutes: 25),
        ]
        #expect(TravelStats.byMonth(of: far, calendar: calendar).count == 2)
    }

    @Test("Sans aucun trajet, tout est vide et rien ne casse")
    func nothingAtAllIsFine() {
        let onlySport = [run(date(2026, 3, 3), km: 10)]
        #expect(TravelStats.trips(in: onlySport).isEmpty)
        #expect(TravelStats.summary(of: onlySport).isEmpty)
        #expect(TravelStats.byMonth(of: onlySport, calendar: calendar).isEmpty)
        #expect(TravelStats.summary(of: []).averageSpeedKmh == 0)
    }

    /// Les deux moitiés de la règle, dans le même test : ce qui sort des
    /// totaux du sport entre dans ceux des trajets, et réciproquement.
    @Test("Ce qui sort du sport entre dans les trajets, et rien ne se perd")
    func nothingIsLostBetweenTheTwo() {
        let sport = ActivityJournal.totals(of: mixed)
        let travel = TravelStats.summary(of: mixed)
        #expect(sport.activityCount == 2)
        #expect(travel.tripCount == 3)
        #expect(sport.activityCount + travel.tripCount == mixed.count)
    }
}
