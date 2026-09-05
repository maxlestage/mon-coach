import Foundation

/// Ce que deviennent les trajets, une fois qu'ils ne comptent plus comme du
/// sport.
///
/// Pourquoi ce fichier existe
/// ..........................
/// Le mode conduite a fait ce qu'on lui demandait : un trajet ne coûte
/// aucune calorie, ne pèse sur aucune charge, n'entre dans aucun total
/// « tous sports » et ne compte pas comme une séance. À force, il n'entrait
/// plus nulle part — l'application enregistrait fidèlement une donnée
/// qu'elle ne montrait plus jamais.
///
/// C'est le défaut symétrique de celui qu'on venait de corriger. Refuser
/// d'additionner un trajet à du sport est juste ; le faire disparaître ne
/// l'est pas. Les trajets ont donc leur propre compte, tenu ici, séparé et
/// complet.
public enum TravelStats {

    /// Le résumé d'un ensemble de trajets.
    public struct Summary: Sendable, Equatable {
        public var tripCount: Int
        public var meters: Double
        public var seconds: TimeInterval

        public static let zero = Summary(tripCount: 0, meters: 0, seconds: 0)

        public init(tripCount: Int, meters: Double, seconds: TimeInterval) {
            self.tripCount = tripCount
            self.meters = meters
            self.seconds = seconds
        }

        public var isEmpty: Bool { tripCount == 0 }

        /// La vitesse moyenne, en km/h, ou zéro si le temps manque.
        ///
        /// Moyenne sur le temps total et non sur le temps en mouvement :
        /// c'est la question qu'on se pose sur un trajet — combien de temps
        /// il a pris — et les arrêts en font partie.
        public var averageSpeedKmh: Double {
            guard seconds > 0 else { return 0 }
            return (meters / 1_000) / (seconds / 3_600)
        }
    }

    /// Les trajets, du plus récent au plus ancien.
    ///
    /// Le tri est ici et non chez l'appelant : trois écrans les demandent, et
    /// celui qui aurait oublié de trier aurait affiché un historique dans un
    /// ordre qui dépend de l'ordre d'enregistrement.
    public static func trips(in activities: [ActivityLog]) -> [ActivityLog] {
        activities
            .filter { !$0.sport.countsAsTraining }
            .sorted { $0.startedAt > $1.startedAt }
    }

    /// Le résumé des trajets d'une période.
    ///
    /// Les bornes sont facultatives et inclusives : sans elles, c'est le
    /// total de tout ce qui est enregistré.
    public static func summary(
        of activities: [ActivityLog],
        since: Date? = nil,
        until: Date? = nil
    ) -> Summary {
        var result = Summary.zero
        for trip in trips(in: activities) {
            if let since, trip.startedAt < since { continue }
            if let until, trip.startedAt > until { continue }
            result.tripCount += 1
            result.meters += trip.meters
            result.seconds += trip.duration
        }
        return result
    }

    /// Un mois de trajets.
    public struct Month: Sendable, Equatable, Identifiable {
        public var start: Date
        public var summary: Summary
        public var id: Date { start }
    }

    /// Les trajets par mois, du plus récent au plus ancien.
    ///
    /// Les mois sans trajet sont omis, contrairement au journal
    /// d'entraînement qui garde ses semaines vides. La différence est
    /// voulue : une semaine sans séance dit quelque chose sur l'assiduité,
    /// un mois sans trajet ne dit rien du tout — on n'a simplement pas pris
    /// la voiture, et personne ne s'est fixé d'objectif là-dessus.
    public static func byMonth(
        of activities: [ActivityLog],
        calendar: Calendar = .current
    ) -> [Month] {
        var buckets: [Date: Summary] = [:]
        for trip in trips(in: activities) {
            guard let start = calendar.date(
                from: calendar.dateComponents([.year, .month], from: trip.startedAt)
            ) else { continue }
            var summary = buckets[start] ?? .zero
            summary.tripCount += 1
            summary.meters += trip.meters
            summary.seconds += trip.duration
            buckets[start] = summary
        }
        return buckets
            .map { Month(start: $0.key, summary: $0.value) }
            .sorted { $0.start > $1.start }
    }
}
