import Foundation

/// Deux photos à comparer, et ce qui les sépare.
public struct BodyComparison: Sendable, Equatable {
    public var earlier: BodyLog
    public var later: BodyLog
    public var earlierPhotoID: String
    public var laterPhotoID: String

    /// Jours entre les deux.
    public var days: Int
    /// L'écart de poids, en kilos. Négatif quand on a perdu.
    public var weightDelta: Double

    public init(
        earlier: BodyLog, later: BodyLog,
        earlierPhotoID: String, laterPhotoID: String,
        days: Int, weightDelta: Double
    ) {
        self.earlier = earlier
        self.later = later
        self.earlierPhotoID = earlierPhotoID
        self.laterPhotoID = laterPhotoID
        self.days = days
        self.weightDelta = weightDelta
    }
}

/// Choisit les deux photos qui montrent quelque chose.
///
/// Pourquoi ce choix ne va pas de soi
/// ----------------------------------
/// Mettre côte à côte la première et la dernière photo semble évident, et
/// c'est faux dans le cas le plus fréquent : quelqu'un qui prend une photo
/// toutes les deux semaines depuis deux ans verrait toujours la même paire,
/// figée, et l'écran cesserait de dire quoi que ce soit.
///
/// L'inverse — les deux dernières — est faux aussi : deux photos à quinze
/// jours d'écart ne montrent rien, et donner « rien » à voir à quelqu'un qui
/// travaille depuis six semaines est la façon la plus sûre de le décourager.
///
/// La règle retenue
/// ----------------
/// La photo la plus récente, comparée à la plus ancienne qui soit **assez
/// vieille pour qu'un écart se voie**. Six semaines : en dessous, la
/// différence tient dans l'éclairage et l'heure de la journée ; au-dessus,
/// elle est réelle. Faute de photo assez ancienne, on ne compare rien et on
/// le dit — c'est plus honnête que de montrer deux images identiques.
public enum BodyProgress {

    /// L'écart minimum pour qu'une comparaison ait un sens.
    ///
    /// Six semaines. Le corps change lentement, et l'éclairage d'une salle
    /// de bain change vite : à quinze jours, on compare deux photos, pas
    /// deux états.
    public static let meaningfulDays = 42

    /// La paire à montrer, ou nil s'il n'y a rien d'honnête à comparer.
    public static func comparison(
        in logs: [BodyLog], on date: Date = Date(), calendar: Calendar = .current
    ) -> BodyComparison? {
        let withPhotos = logs
            .filter { !$0.photoIDs.isEmpty }
            .sorted { $0.date < $1.date }
        guard let latest = withPhotos.last,
              let laterPhoto = latest.photoIDs.last
        else { return nil }

        // La plus ancienne qui soit assez loin de la dernière. La plus
        // ancienne tout court ferait une paire qui ne bouge plus jamais.
        let candidates = withPhotos.filter {
            let gap = calendar.dateComponents(
                [.day], from: calendar.startOfDay(for: $0.date),
                to: calendar.startOfDay(for: latest.date)
            ).day ?? 0
            return gap >= meaningfulDays
        }
        guard let earliest = candidates.last,
              let earlierPhoto = earliest.photoIDs.first
        else { return nil }

        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: earliest.date),
            to: calendar.startOfDay(for: latest.date)
        ).day ?? 0

        return BodyComparison(
            earlier: earliest, later: latest,
            earlierPhotoID: earlierPhoto, laterPhotoID: laterPhoto,
            days: days, weightDelta: latest.weightKg - earliest.weightKg
        )
    }

    /// Ce qu'on écrit sous la comparaison.
    ///
    /// Le nombre de jours et l'écart de poids, sans commentaire sur ce que
    /// l'image montre : personne, et surtout pas une application, ne devrait
    /// dire à quelqu'un de quoi il a l'air. Les deux photos parlent d'elles-
    /// mêmes ; le texte se contente des faits mesurés.
    public static func caption(_ comparison: BodyComparison) -> LocalizedText {
        let weeks = comparison.days / 7
        let delta = comparison.weightDelta
        let kilos = String(format: "%.1f", abs(delta))

        let span = LocalizedText(
            fr: weeks >= 8 ? "\(comparison.days / 30) mois d'écart" : "\(weeks) semaines d'écart",
            en: weeks >= 8 ? "\(comparison.days / 30) months apart" : "\(weeks) weeks apart",
            es: weeks >= 8 ? "\(comparison.days / 30) meses de diferencia" : "\(weeks) semanas de diferencia"
        )

        // Un demi-kilo est du bruit : l'heure de la pesée, le repas de la
        // veille. L'annoncer comme un résultat serait mentir sur la précision.
        guard abs(delta) >= 0.5 else {
            return LocalizedText(
                fr: "\(span.fr) · poids stable",
                en: "\(span.en) · weight steady",
                es: "\(span.es) · peso estable"
            )
        }
        return LocalizedText(
            fr: "\(span.fr) · \(delta < 0 ? "−" : "+")\(kilos) kg",
            en: "\(span.en) · \(delta < 0 ? "−" : "+")\(kilos) kg",
            es: "\(span.es) · \(delta < 0 ? "−" : "+")\(kilos) kg"
        )
    }
}
