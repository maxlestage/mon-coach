import Testing
@testable import MonCoachKit

/// Les chiffres que le site annonce au public.
///
/// Pourquoi ces tests existent
/// ---------------------------
/// Une page de vente cite des nombres — « quatre-vingt-douze mouvements »,
/// « quarante-huit sports » — et ces nombres vieillissent tout seuls. Le
/// catalogue grandit, la promesse reste, et un beau jour la vitrine
/// annonce moins que le produit ne fait, ou pire, davantage.
///
/// Ces tests attachent la promesse au catalogue. Ils échouent le jour où
/// elle cesse d'être vraie, ce qui est exactement le moment où il faudrait
/// s'en apercevoir.
@Suite("Les chiffres annoncés au public")
struct CatalogueCountTests {

    @Test("Le catalogue tient les nombres affichés sur le site")
    func publishedCountsHold() {
        // « Le mode guidé sur les quatre-vingt-douze mouvements du catalogue »
        #expect(
            ExerciseCatalog.all.count >= 92,
            Comment(rawValue: "le site annonce 92 mouvements, le catalogue en a \(ExerciseCatalog.all.count)")
        )
        // « Quarante-huit sports, rangés par famille »
        #expect(
            Sport.allCases.count >= 48,
            Comment(rawValue: "le site annonce 48 sports, il y en a \(Sport.allCases.count)")
        )
        // Et le mode guidé couvre vraiment tout le catalogue : annoncer un
        // nombre de mouvements guidés suppose qu'aucun n'ouvre sur du vide.
        for exercise in ExerciseCatalog.all {
            #expect(
                !GuidedCatalog.technique(for: exercise).steps.isEmpty,
                Comment(rawValue: "\(exercise.id) n'a pas de fiche guidée")
            )
        }
    }

    @Test("La progression de course est celle que le site décrit")
    func runningProgressionMatchesTheClaim() {
        // Le site disait « +10 % par semaine de charge » ; le moteur, lui,
        // plafonne délibérément le pic à 1,6 fois le départ — au-delà, on
        // promettrait une progression que le tendon ne suit pas. C'est le
        // texte qui a été corrigé, pas le moteur : voici la règle réelle.
        let start = 20_000.0
        let running = RunningProfile(goal: .tenK, currentWeeklyMeters: start)
        let peak = RunPlanner.peakWeeklyMeters(running: running, start: start)
        #expect(peak <= start * 1.6, "le pic dépasse le plafond annoncé")

        // Et une semaine sur quatre redescend.
        #expect(RunPlanner.weeklyMeters(
            week: 4, total: 8, start: start, peak: peak,
            isRecoveryWeek: true, isTaper: false
        ) < RunPlanner.weeklyMeters(
            week: 4, total: 8, start: start, peak: peak,
            isRecoveryWeek: false, isTaper: false
        ))
    }
}
