import Foundation
import Testing
@testable import MonCoachKit

/// Reprendre après un arrêt, sans se blesser ni se décourager.
///
/// Ce qui se joue ici
/// ------------------
/// Deux semaines de grippe, et l'application tendait les mêmes charges
/// qu'avant. Deux issues, toutes deux mauvaises : la blessure, ou l'échec à
/// la première série suivi d'un abandon. Ces tests gardent surtout la règle
/// qui rend la reprise supportable — couper le volume plus fort que la
/// charge — et le silence quand il ne s'est rien passé.
@Suite("Reprendre après un arrêt")
struct ReturnPlannerTests {

    static let calendar = Fixtures.calendar

    @Test("Une semaine sans salle n'est pas un arrêt")
    func aQuietWeekIsNotDetraining() {
        // Quatre séances par semaine, des jours de repos entre elles, un
        // week-end chargé : dix jours arrivent sans que rien n'aille mal.
        // Traiter cela comme un désentraînement serait faux, et vexant.
        #expect(ReturnPlanner.plan(daysAway: 3, stayedActive: false) == nil)
        #expect(ReturnPlanner.plan(daysAway: 9, stayedActive: false) == nil)
        #expect(ReturnPlanner.plan(daysAway: 10, stayedActive: false) != nil)
    }

    @Test("Le volume est toujours coupé plus fort que la charge")
    func volumeIsAlwaysCutHarderThanLoad() {
        // C'est la règle qui commande tout le reste : la force se perd
        // lentement, la tolérance au volume vite. L'inverse ferait un athlète
        // qui soulève léger et finit quand même courbaturé trois jours.
        for days in [10, 20, 21, 41, 42, 89, 90, 200, 400] {
            for active in [true, false] {
                guard let plan = ReturnPlanner.plan(daysAway: days, stayedActive: active) else {
                    Issue.record("\(days) jours devrait produire un plan")
                    continue
                }
                #expect(
                    plan.volumeReduction > plan.loadReduction,
                    "\(days) jours, actif \(active) : volume \(plan.volumeReduction) ≤ charge \(plan.loadReduction)"
                )
            }
        }
    }

    @Test("Plus l'arrêt est long, plus on redescend")
    func longerBreaksCutDeeper() {
        let steps = [10, 21, 42, 90].compactMap {
            ReturnPlanner.plan(daysAway: $0, stayedActive: false)
        }
        #expect(steps.count == 4)
        #expect(steps.map(\.loadReduction) == steps.map(\.loadReduction).sorted())
        #expect(steps.map(\.volumeReduction) == steps.map(\.volumeReduction).sorted())
        #expect(steps.map(\.rampWeeks) == steps.map(\.rampWeeks).sorted())
    }

    @Test("Avoir couru épargne du volume, jamais de la charge")
    func stayingActiveSpareVolumeButNotLoad() {
        // La capacité de travail se garde en bougeant ; la force est
        // spécifique. Courir ne fait pas pousser, et prétendre le contraire
        // enverrait quelqu'un sous une barre trop lourde.
        guard let idle = ReturnPlanner.plan(daysAway: 30, stayedActive: false),
              let active = ReturnPlanner.plan(daysAway: 30, stayedActive: true)
        else {
            Issue.record("trente jours devrait produire un plan")
            return
        }
        #expect(active.volumeReduction < idle.volumeReduction)
        #expect(active.loadReduction == idle.loadReduction)
    }

    @Test("Au-delà de six semaines, on reconstruit au lieu de reprendre le fil")
    func longBreaksRebuildTheBlock() {
        #expect(ReturnPlanner.plan(daysAway: 30, stayedActive: false)?.rebuildsBlock == false)
        #expect(ReturnPlanner.plan(daysAway: 60, stayedActive: false)?.rebuildsBlock == true)
    }

    @Test("L'allègement s'efface, il ne s'installe pas")
    func theEasingDisappears() {
        // Une reprise qui garderait ses dix pour cent de moins pour toujours
        // ne serait pas une reprise, ce serait une régression déguisée.
        guard let plan = ReturnPlanner.plan(daysAway: 45, stayedActive: false) else {
            Issue.record("quarante-cinq jours devrait produire un plan")
            return
        }
        let start = ReturnPlanner.easing(plan, weeksBack: 0)
        #expect(start.load == plan.loadReduction)
        #expect(start.volume == plan.volumeReduction)

        // À mi-parcours, il en reste une part.
        let middle = ReturnPlanner.easing(plan, weeksBack: plan.rampWeeks / 2)
        #expect(middle.load < start.load)
        #expect(middle.load > 0)

        // À la fin, plus rien — et jamais rien après.
        #expect(ReturnPlanner.easing(plan, weeksBack: plan.rampWeeks) == (0, 0))
        #expect(ReturnPlanner.easing(plan, weeksBack: plan.rampWeeks + 5) == (0, 0))
    }

    // MARK: - Ce que l'historique dit

    @Test("Une séance sautée n'est pas une séance")
    func skippedSessionsDoNotCount() {
        // C'est précisément ce que « sautée » veut dire : un jour où rien
        // n'a été soulevé. La compter rendrait l'arrêt invisible.
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.date(2026, 9, 1), durationMinutes: 60),
            SessionLog(date: Fixtures.date(2026, 9, 20), durationMinutes: 0, skipped: true),
        ])
        #expect(ReturnPlanner.lastStrengthSession(history) == Fixtures.date(2026, 9, 1))
    }

    @Test("Une seule sortie dans six semaines n'entretient rien")
    func oneRunInSixWeeksIsNotStayingActive() {
        let start = Fixtures.date(2026, 8, 1)
        let end = Fixtures.date(2026, 9, 12)
        let history = TrainingHistory(activities: [
            ActivityLog(startedAt: Fixtures.date(2026, 8, 20), sport: .run, type: .easy,
                        meters: 5000, duration: 1800, elevationGain: 0)
        ])
        #expect(!ReturnPlanner.stayedActive(history, between: start, and: end, calendar: Self.calendar))
    }

    @Test("Deux sorties par semaine, c'est de l'entretien")
    func regularRunsCountAsStayingActive() {
        let start = Fixtures.date(2026, 9, 1)
        let end = Fixtures.date(2026, 9, 22)
        var runs: [ActivityLog] = []
        for day in [3, 6, 10, 13, 17, 20] {
            runs.append(ActivityLog(
                startedAt: Fixtures.date(2026, 9, day), sport: .run, type: .easy,
                meters: 6000, duration: 2000, elevationGain: 0
            ))
        }
        let history = TrainingHistory(activities: runs)
        #expect(ReturnPlanner.stayedActive(history, between: start, and: end, calendar: Self.calendar))
    }

    @Test("Sans aucune séance au journal, il n'y a rien à reprendre")
    func nothingToReturnFrom() {
        // Un débutant qui n'a jamais soulevé n'est pas quelqu'un qui revient.
        #expect(ReturnPlanner.plan(history: TrainingHistory(), on: Fixtures.date(2026, 9, 20),
                                   calendar: Self.calendar) == nil)
    }

    @Test("Le plan lu depuis l'historique compte les bons jours")
    func planFromHistoryCountsTheRightDays() {
        let history = TrainingHistory(sessions: [
            SessionLog(date: Fixtures.date(2026, 9, 1), durationMinutes: 60)
        ])
        let plan = ReturnPlanner.plan(
            history: history, on: Fixtures.date(2026, 9, 25), calendar: Self.calendar
        )
        #expect(plan?.daysAway == 24)
    }

    @Test("Tout ce qui s'affiche est écrit dans les trois langues")
    func everythingIsTranslated() {
        for days in [10, 25, 50, 120, 400] {
            for active in [true, false] {
                guard let plan = ReturnPlanner.plan(daysAway: days, stayedActive: active) else { continue }
                for language in Language.allCases {
                    #expect(!plan.headline[language].isEmpty, "\(days) j sans titre en \(language.rawValue)")
                    #expect(!plan.message[language].isEmpty, "\(days) j sans texte en \(language.rawValue)")
                }
            }
        }
    }
}
