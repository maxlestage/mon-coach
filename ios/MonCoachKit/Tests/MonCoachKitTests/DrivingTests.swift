import Foundation
import Testing
@testable import MonCoachKit

/// Le mode conduite.
///
/// Un trajet se trace comme une sortie et ne compte comme rien. Tout
/// l'intérêt du mode est dans ce « rien » : chaque endroit qui additionne
/// des activités doit l'ignorer, et celui qu'on oublierait serait
/// exactement celui qui annoncerait la semaine la plus chargée de l'année.
@Suite("Le mode conduite")
struct DrivingTests {

    private func trip(minutes: Double, km: Double, bpm: Int? = nil) -> ActivityLog {
        ActivityLog(
            startedAt: Date(timeIntervalSince1970: 1_700_000_000),
            sport: .driving,
            type: .easy,
            meters: km * 1_000,
            duration: minutes * 60,
            elevationGain: 0,
            heartRate: bpm.map { beat in
                (0..<Int(minutes * 60 / 5)).map {
                    HeartRateSample(
                        timestamp: Date(timeIntervalSince1970: 1_700_000_000 + Double($0) * 5),
                        bpm: Double(beat)
                    )
                }
            } ?? []
        )
    }

    private func run(minutes: Double, km: Double) -> ActivityLog {
        ActivityLog(
            startedAt: Date(timeIntervalSince1970: 1_700_100_000),
            sport: .run,
            type: .easy,
            meters: km * 1_000,
            duration: minutes * 60,
            elevationGain: 0
        )
    }

    // MARK: - Ce qu'un trajet est

    @Test("La conduite est un déplacement, pas un sport")
    func drivingIsTravelNotSport() {
        #expect(Sport.driving.family == .travel)
        #expect(Sport.driving.mode == .motorised)
        #expect(!Sport.driving.countsAsTraining)
        #expect(!Sport.driving.feedsRunningPlan)
    }

    /// Un trajet se trace : c'est la moitié de la demande. Sans trace, il ne
    /// resterait qu'un chronomètre, et l'application n'aurait aucune raison
    /// de connaître la conduite.
    @Test("Un trajet laisse une trace et affiche une vitesse")
    func aTripIsStillTraced() {
        #expect(Sport.driving.tracksLocation)
        #expect(Sport.driving.readout == .speed)
    }

    /// Le seuil du vélo — 108 km/h — couperait toute portion d'autoroute.
    @Test("Le filtre laisse passer une autoroute")
    func themotorwayIsNotFilteredOut() {
        let filter = Sport.driving.filter
        #expect(filter.maxSpeed > 36, Comment(rawValue: "\(filter.maxSpeed) m/s"))  // > 130 km/h
        #expect(Sport.ride.filter.maxSpeed < filter.maxSpeed)
    }

    // MARK: - Ce qu'un trajet ne coûte pas

    /// Le cœur du mode. Deux heures de route par les MET auraient donné
    /// environ 350 kcal, et ces 350 kcal seraient revenues dans la journée
    /// alimentaire sous forme d'un repas à manger pour un effort qui n'a
    /// pas eu lieu.
    @Test("Deux heures de route ne coûtent aucune calorie")
    func aDriveCostsNothing() {
        let energy = TraceMath.energyKcal(
            sport: .driving,
            meters: 180_000,
            movingSeconds: 7_200,
            elevationGain: 400,
            weightKg: 75
        )
        #expect(energy == 0)
        // Le contrôle : la même distance à vélo coûte, elle.
        #expect(TraceMath.energyKcal(
            sport: .ride, meters: 180_000, movingSeconds: 7_200,
            elevationGain: 400, weightKg: 75
        ) > 0)
    }

    /// Le piège le plus vicieux : une ceinture cardio laissée sur la
    /// poitrine pendant le trajet. Le cœur a bien battu, et sans garde
    /// explicite un embouteillage deviendrait la sortie la plus coûteuse de
    /// la semaine — après quoi le coach allégerait la séance du lendemain.
    @Test("Une ceinture oubliée pendant le trajet ne fabrique pas de charge")
    func aForgottenStrapDoesNotCreateLoad() {
        let load = TrainingLoadEngine.effort(
            for: trip(minutes: 90, km: 110, bpm: 95),
            maximumBpm: 180
        )
        #expect(load == 0)
    }

    // MARK: - Ce qu'un trajet ne fait pas gonfler

    @Test("Les trajets sortent des totaux « tous sports »")
    func tripsLeaveTheAllSportsTotals() {
        let mixed = [trip(minutes: 60, km: 80), run(minutes: 45, km: 9)]
        let totals = ActivityJournal.totals(of: mixed)
        #expect(totals.activityCount == 1)
        #expect(abs(totals.meters - 9_000) < 1)
    }

    @Test("Les trajets ne comptent pas comme des séances de la semaine")
    func tripsAreNotSessions() {
        let mixed = [trip(minutes: 60, km: 80), run(minutes: 45, km: 9)]
        let weeks = ActivityJournal.weeks(
            of: mixed,
            upTo: Date(timeIntervalSince1970: 1_700_200_000)
        )
        let counted = weeks.reduce(0) { $0 + $1.totals.activityCount }
        #expect(counted == 1)
    }

    /// On ne cache pas la donnée : on refuse seulement de l'additionner à du
    /// sport. Demander explicitement les déplacements les rend.
    @Test("Demander les déplacements les rend")
    func askingForTravelReturnsIt() {
        let mixed = [trip(minutes: 60, km: 80), run(minutes: 45, km: 9)]
        #expect(!ActivityStats.Scope.everything.matches(mixed[0]))
        #expect(ActivityStats.Scope.family(.travel).matches(mixed[0]))
        #expect(ActivityStats.Scope.sport(.driving).matches(mixed[0]))
    }

    // MARK: - Santé

    /// Une session d'entraînement écrit dans Santé et ferme les anneaux.
    /// Deux heures d'autoroute enregistrées comme entraînement fausseraient
    /// la journée d'activité bien au-delà de cette application.
    @Test("Un trajet n'ouvre pas de session d'entraînement")
    func aTripOpensNoWorkoutSession() {
        #expect(!Sport.driving.opensWorkoutSession)
        for sport in Sport.allCases where sport.countsAsTraining {
            #expect(sport.opensWorkoutSession, Comment(rawValue: sport.rawValue))
        }
    }
}
