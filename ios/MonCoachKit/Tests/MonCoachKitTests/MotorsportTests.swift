import Foundation
import Testing
@testable import MonCoachKit

/// Les sports mécaniques.
///
/// Ils partagent le mode de déplacement de la conduite — un rallye et une
/// autoroute dépassent tous deux le plafond du vélo — et n'ont rien à voir
/// avec elle par ailleurs. C'est cette distinction que ces tests gardent :
/// la façon dont un engin se déplace et la question de savoir si le corps
/// fournit sont deux choses différentes, et les confondre reviendrait à
/// dire qu'un pilote de motocross ne fait rien parce qu'il a un moteur.
@Suite("Les sports mécaniques")
struct MotorsportTests {

    private var mechanical: [Sport] { SportFamily.motorsport.sports }

    @Test("La famille existe et rassemble les engins à moteur")
    func theFamilyGathersTheEngines() {
        #expect(mechanical.count == 10)
        for sport in [Sport.motocross, .enduro, .motoTrial, .roadMotorcycling,
                      .karting, .circuitRacing, .rally, .quad, .jetSki, .snowmobile] {
            #expect(sport.family == .motorsport, Comment(rawValue: sport.rawValue))
        }
    }

    /// Le partage du mode est délibéré : c'est la vitesse qui commande le
    /// filtrage de la trace, et un rallye la dépasse comme une autoroute.
    @Test("Ils sont filtrés comme ce qui va vite")
    func theyAreFilteredAsFastThings() {
        for sport in mechanical {
            #expect(sport.mode == .motorised, Comment(rawValue: sport.rawValue))
            #expect(sport.filter.maxSpeed > Sport.ride.filter.maxSpeed)
        }
    }

    // MARK: - La distinction qui compte

    /// Le cœur de la famille. La conduite ne coûte rien ; le motocross
    /// coûte une heure d'effort réel. Les deux sont motorisés.
    @Test("Un motocross coûte, un trajet ne coûte pas")
    func anEngineIsNotAnExcuse() {
        let motocross = TraceMath.energyKcal(
            sport: .motocross, meters: 20_000, movingSeconds: 2_400,
            elevationGain: 100, weightKg: 75
        )
        let drive = TraceMath.energyKcal(
            sport: .driving, meters: 20_000, movingSeconds: 2_400,
            elevationGain: 100, weightKg: 75
        )
        #expect(motocross > 300, Comment(rawValue: "\(motocross) kcal"))
        #expect(drive == 0)
    }

    @Test("Tous comptent comme de l'entraînement, sauf la conduite")
    func allButDrivingAreTraining() {
        for sport in mechanical {
            #expect(sport.countsAsTraining, Comment(rawValue: sport.rawValue))
        }
        #expect(!Sport.driving.countsAsTraining)
    }

    /// Le revers : ils entrent bien dans les totaux et la charge, à la
    /// différence des trajets. Un pilote qui enchaîne les manches a fait sa
    /// séance de la semaine.
    @Test("Ils entrent dans les totaux et dans la charge")
    func theyEnterTheTotalsAndTheLoad() {
        let session = ActivityLog(
            startedAt: Date(timeIntervalSince1970: 1_700_000_000),
            sport: .motocross, type: .easy,
            meters: 18_000, duration: 2_400, elevationGain: 90,
            perceivedEffort: 8
        )
        #expect(ActivityStats.Scope.everything.matches(session))
        #expect(ActivityJournal.totals(of: [session]).activityCount == 1)
        #expect(TrainingLoadEngine.effort(for: session, maximumBpm: 180) > 0)
    }

    /// Aucun ne nourrit le plan de course : trente kilomètres d'enduro
    /// feraient tripler le volume de course prescrit la semaine suivante.
    @Test("Aucun ne nourrit le plan de course")
    func noneFeedsTheRunningPlan() {
        for sport in mechanical {
            #expect(!sport.feedsRunningPlan, Comment(rawValue: sport.rawValue))
        }
    }

    // MARK: - Le catalogue

    @Test("Chacun est nommé dans les trois langues, et distinctement")
    func eachIsNamedInThreeLanguages() {
        for language in Language.allCases {
            let names = Sport.allCases.map { $0.label[language] }
            #expect(Set(names).count == names.count)
            for sport in mechanical {
                #expect(sport.label[language].isEmpty == false)
            }
        }
    }

    /// Les valeurs sont prises basses, faute d'un Compendium qui couvre bien
    /// la pratique de compétition. Elles doivent rester dans l'échelle de
    /// l'effort — ni le repos, ni le sprint.
    @Test("Les dépenses restent plausibles, et aucune n'est nulle")
    func theEnergyCostsStayPlausible() {
        for sport in mechanical {
            #expect(sport.baseMET >= 3, Comment(rawValue: "\(sport.rawValue) : \(sport.baseMET)"))
            #expect(sport.baseMET <= 10, Comment(rawValue: "\(sport.rawValue) : \(sport.baseMET)"))
        }
        // Le motocross demande plus que la motoneige : le premier se pilote
        // debout sur les cale-pieds, la seconde assis.
        #expect(Sport.motocross.baseMET > Sport.snowmobile.baseMET)
    }

    @Test("Chacun ouvre une session d'entraînement, à la différence d'un trajet")
    func eachOpensAWorkoutSession() {
        for sport in mechanical {
            #expect(sport.opensWorkoutSession, Comment(rawValue: sport.rawValue))
        }
        #expect(!Sport.driving.opensWorkoutSession)
    }
}
