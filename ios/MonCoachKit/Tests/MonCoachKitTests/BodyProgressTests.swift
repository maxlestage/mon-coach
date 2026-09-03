import Foundation
import Testing
@testable import MonCoachKit

/// Deux photos qui montrent quelque chose, ou aucune.
///
/// Ce qui se joue ici
/// ------------------
/// Une comparaison qui ne montre rien décourage plus qu'elle n'encourage.
/// Ces tests gardent surtout les deux refus : pas de paire figée, pas de
/// paire trop rapprochée.
@Suite("Comparer deux photos du corps")
struct BodyProgressTests {

    static let calendar = Fixtures.calendar

    static func log(_ month: Int, _ day: Int, kg: Double, photos: [String]) -> BodyLog {
        BodyLog(
            date: calendar.date(from: DateComponents(year: 2026, month: month, day: day))!,
            weightKg: kg, photoIDs: photos
        )
    }

    @Test("Sans photo, il n'y a rien à comparer")
    func noPhotosNoComparison() {
        let logs = [
            BodyLog(date: Fixtures.date(2026, 1, 5), weightKg: 84),
            BodyLog(date: Fixtures.date(2026, 6, 5), weightKg: 80),
        ]
        #expect(BodyProgress.comparison(in: logs, calendar: Self.calendar) == nil)
    }

    @Test("Une seule photo ne fait pas une comparaison")
    func onePhotoIsNotAPair() {
        let logs = [Self.log(1, 5, kg: 84, photos: ["a"])]
        #expect(BodyProgress.comparison(in: logs, calendar: Self.calendar) == nil)
    }

    @Test("Deux photos trop rapprochées ne montrent rien")
    func tooCloseTogetherShowsNothing() {
        // Quinze jours : la différence tient dans l'éclairage et l'heure de
        // la journée. Montrer deux images identiques à quelqu'un qui
        // travaille depuis deux semaines le découragerait pour rien.
        let logs = [
            Self.log(3, 1, kg: 84, photos: ["a"]),
            Self.log(3, 16, kg: 83.4, photos: ["b"]),
        ]
        #expect(BodyProgress.comparison(in: logs, calendar: Self.calendar) == nil)
    }

    @Test("Six semaines suffisent")
    func sixWeeksIsEnough() {
        let logs = [
            Self.log(3, 1, kg: 84, photos: ["a"]),
            Self.log(4, 12, kg: 81.5, photos: ["b"]),
        ]
        let pair = BodyProgress.comparison(in: logs, calendar: Self.calendar)
        #expect(pair?.earlierPhotoID == "a")
        #expect(pair?.laterPhotoID == "b")
        #expect(pair?.days == 42)
    }

    @Test("La paire avance avec le temps, elle ne se fige pas")
    func thePairMovesForward() {
        // Le piège de la solution évidente : comparer toujours la première
        // et la dernière donnerait à quelqu'un qui photographie depuis deux
        // ans une paire immuable, et un écran qui ne dit plus rien.
        let logs = [
            Self.log(1, 5, kg: 90, photos: ["janvier"]),
            Self.log(3, 5, kg: 86, photos: ["mars"]),
            Self.log(6, 5, kg: 82, photos: ["juin"]),
            Self.log(9, 5, kg: 80, photos: ["septembre"]),
        ]
        let pair = BodyProgress.comparison(in: logs, calendar: Self.calendar)
        #expect(pair?.laterPhotoID == "septembre")
        // La plus récente qui soit encore assez ancienne : juin, pas janvier.
        #expect(pair?.earlierPhotoID == "juin")
    }

    @Test("L'écart de poids est celui des deux photos montrées")
    func theDeltaMatchesThePairShown() {
        let logs = [
            Self.log(1, 5, kg: 90, photos: ["janvier"]),
            Self.log(6, 5, kg: 82, photos: ["juin"]),
            Self.log(9, 5, kg: 79.5, photos: ["septembre"]),
        ]
        guard let pair = BodyProgress.comparison(in: logs, calendar: Self.calendar) else {
            Issue.record("une paire était attendue")
            return
        }
        #expect(pair.weightDelta == -2.5)
    }

    @Test("Un demi-kilo n'est pas un résultat")
    func halfAKiloIsNoise() {
        // L'heure de la pesée et le repas de la veille pèsent autant.
        // L'annoncer comme un résultat mentirait sur la précision.
        let logs = [
            Self.log(1, 5, kg: 80, photos: ["a"]),
            Self.log(6, 5, kg: 80.3, photos: ["b"]),
        ]
        guard let pair = BodyProgress.comparison(in: logs, calendar: Self.calendar) else {
            Issue.record("une paire était attendue")
            return
        }
        let caption = BodyProgress.caption(pair)
        #expect(caption.fr.contains("stable"))
        #expect(!caption.fr.contains("kg"))
    }

    @Test("La légende dit les faits, et rien sur l'allure de la personne")
    func theCaptionStatesFactsOnly() {
        // Personne, et surtout pas une application, ne devrait dire à
        // quelqu'un de quoi il a l'air. Les photos parlent d'elles-mêmes.
        let logs = [
            Self.log(1, 5, kg: 90, photos: ["a"]),
            Self.log(6, 5, kg: 82, photos: ["b"]),
        ]
        guard let pair = BodyProgress.comparison(in: logs, calendar: Self.calendar) else {
            Issue.record("une paire était attendue")
            return
        }
        let caption = BodyProgress.caption(pair)
        for language in Language.allCases {
            #expect(!caption[language].isEmpty)
        }
        #expect(caption.fr.contains("8,0 kg") || caption.fr.contains("8.0 kg"))
        #expect(caption.fr.contains("−"))
    }
}
