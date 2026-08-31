import Foundation
import Testing
@testable import MonCoachKit

@Suite("Exercices de salle du jour")
struct GymSpecificTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 9))!
    }

    @Test("Le vivier ne contient que ce qu'on ne peut pas faire chez soi")
    func poolIsGymOnly() {
        #expect(GymSpecific.all.count >= 40, "vivier de \(GymSpecific.all.count) : trop mince pour un mois")
        for exercise in GymSpecific.all {
            #expect(
                !exercise.equipment.isDisjoint(with: GymSpecific.gymEquipment),
                Comment(rawValue: "\(exercise.id) se fait sans machine, sans poulie, sans Smith")
            )
        }
        // Un squat barre se fait dans un garage : il n'a rien à faire ici.
        #expect(!GymSpecific.all.contains { $0.id == "back-squat" })
        #expect(!GymSpecific.all.contains { $0.id == "push-up" })
    }

    @Test("Deux jours de suite ne partagent jamais un exercice")
    func consecutiveDaysNeverRepeat() {
        // Sur deux mois entiers, jamais un mouvement ne revient le lendemain.
        var previous = Set<String>()
        for offset in 0..<60 {
            let date = calendar.date(byAdding: .day, value: offset, to: day(2026, 1, 1))!
            let today = Set(
                GymSpecific.ofTheDay(on: date, profile: nil, calendar: calendar).map(\.id)
            )
            #expect(today.count == GymSpecific.dailyCount, "jour \(offset) : \(today.count) exercices")
            #expect(
                today.isDisjoint(with: previous),
                Comment(rawValue: "jour \(offset) répète \(today.intersection(previous))")
            )
            previous = today
        }
    }

    @Test("La sélection ne bouge pas dans la journée, et change à minuit")
    func stableWithinADayAndNewTomorrow() {
        let morning = calendar.date(from: DateComponents(year: 2026, month: 5, day: 12, hour: 6))!
        let evening = calendar.date(from: DateComponents(year: 2026, month: 5, day: 12, hour: 23))!
        let tomorrow = calendar.date(from: DateComponents(year: 2026, month: 5, day: 13, hour: 6))!

        let first = GymSpecific.ofTheDay(on: morning, profile: nil, calendar: calendar).map(\.id)
        let second = GymSpecific.ofTheDay(on: evening, profile: nil, calendar: calendar).map(\.id)
        let next = GymSpecific.ofTheDay(on: tomorrow, profile: nil, calendar: calendar).map(\.id)

        #expect(first == second, "la liste a bougé entre le matin et le soir")
        #expect(first != next, "demain propose la même chose qu'aujourd'hui")
    }

    @Test("Tout le vivier finit par passer, sans qu'un exercice soit oublié")
    func everythingComesUpEventually() {
        var seen = Set<String>()
        for offset in 0..<(GymSpecific.all.count + 4) {
            let date = calendar.date(byAdding: .day, value: offset, to: day(2026, 1, 1))!
            seen.formUnion(GymSpecific.ofTheDay(on: date, profile: nil, calendar: calendar).map(\.id))
        }
        #expect(seen.count == GymSpecific.all.count, "il en manque \(GymSpecific.all.count - seen.count)")
    }

    @Test("Une blessure déclarée retire le mouvement, tous les jours")
    func limitationsAreRespected() {
        var profile = Fixtures.intermediate()
        profile.equipment = Equipment.fullGym
        profile.limitations = [.knee, .shoulder]
        let forbidden = Set(
            GymSpecific.all.filter { $0.conflicts(with: profile.limitations) }.map(\.id)
        )
        #expect(!forbidden.isEmpty, "le test ne veut rien dire si rien n'est interdit")

        for offset in 0..<40 {
            let date = calendar.date(byAdding: .day, value: offset, to: day(2026, 3, 1))!
            let today = GymSpecific.ofTheDay(on: date, profile: profile, calendar: calendar)
            #expect(today.allSatisfy { !forbidden.contains($0.id) })
        }
    }

    @Test("Un exercice écarté ne revient pas par cette porte")
    func dislikedStaysOut() {
        var profile = Fixtures.intermediate()
        profile.equipment = Equipment.fullGym
        let victim = GymSpecific.all[0].id
        profile.dislikedExerciseIDs = [victim]
        for offset in 0..<40 {
            let date = calendar.date(byAdding: .day, value: offset, to: day(2026, 3, 1))!
            #expect(!GymSpecific.ofTheDay(on: date, profile: profile, calendar: calendar)
                .contains { $0.id == victim })
        }
    }

    @Test("Une salle sans poulie ne propose pas de poulie")
    func equipmentIsRespectedWhenDeclared() {
        var profile = Fixtures.intermediate()
        // Une salle de machines guidées, sans poulie ni Smith.
        profile.equipment = [.bodyweight, .dumbbell, .bench, .machine]
        for offset in 0..<30 {
            let date = calendar.date(byAdding: .day, value: offset, to: day(2026, 4, 1))!
            for exercise in GymSpecific.ofTheDay(on: date, profile: profile, calendar: calendar) {
                #expect(exercise.isAvailable(with: profile.equipment), Comment(rawValue: exercise.id))
            }
        }
    }

    @Test("Un athlète qui s'entraîne chez lui voit quand même la salle")
    func homeAthleteStillSeesTheGym() {
        var profile = Fixtures.intermediate()
        // Aucun équipement de salle déclaré : c'est un salon. L'écran du
        // coach de salle s'ouvre pourtant en visitant une vraie salle, et
        // doit alors montrer ce qu'on y trouve.
        profile.equipment = [.bodyweight, .dumbbell, .bench]
        let today = GymSpecific.ofTheDay(on: day(2026, 6, 1), profile: profile, calendar: calendar)
        #expect(today.count == GymSpecific.dailyCount)
    }

    @Test("Une date d'avant 1970 ne fait pas sortir de la liste")
    func negativeDaysAreSafe() {
        let old = day(1965, 2, 3)
        let picks = GymSpecific.ofTheDay(on: old, profile: nil, calendar: calendar)
        #expect(picks.count == GymSpecific.dailyCount)
    }

    @Test("Un vivier plus petit qu'une journée ne plante pas")
    func tinyPoolIsHandled() {
        let two = Array(GymSpecific.all.prefix(2))
        let picks = DailyRotation.selection(from: two, dayIndex: 7, count: 4, seed: GymSpecific.seed)
        #expect(picks.count == 2)
        #expect(Set(picks.map(\.id)).count == 2, "le même exercice est servi deux fois")
        #expect(
            DailyRotation.selection(from: [], dayIndex: 3, count: 4, seed: GymSpecific.seed).isEmpty
        )
    }

    @Test("Le mélange est le même partout, et à chaque appel")
    func shuffleIsReproducible() {
        let once = DailyRotation.shuffled(GymSpecific.all, seed: 42).map(\.id)
        let twice = DailyRotation.shuffled(GymSpecific.all, seed: 42).map(\.id)
        #expect(once == twice)
        #expect(once != GymSpecific.all.map(\.id), "le mélange n'a rien mélangé")
        #expect(Set(once) == Set(GymSpecific.all.map(\.id)), "le mélange a perdu ou inventé un exercice")
    }

    @Test("Chaque exercice de salle sait dire ce qu'il apporte")
    func everyExerciseExplainsItself() {
        for exercise in GymSpecific.all {
            #expect(GymSpecific.reason(for: exercise).isComplete, Comment(rawValue: exercise.id))
        }
        #expect(GymSpecific.howToUse.isComplete)
    }

    @Test("Les nouveaux mouvements de salle sont utilisables par le reste du moteur")
    func newExercisesAreWellFormed() {
        for exercise in ExerciseCatalog.gymOnly {
            #expect(exercise.name.isComplete, Comment(rawValue: exercise.id))
            #expect(exercise.cue.isComplete, Comment(rawValue: exercise.id))
            #expect(exercise.cue.fr != exercise.cue.en, Comment(rawValue: exercise.id))
            #expect((1...5).contains(exercise.stimulusRating), Comment(rawValue: exercise.id))
            #expect(exercise.viableRepRange.lowerBound >= 1, Comment(rawValue: exercise.id))
            #expect(exercise.loadFactor > 0, Comment(rawValue: exercise.id))
            #expect(exercise.baseRestSeconds >= 45, Comment(rawValue: exercise.id))
            // Une fiche technique existe pour chacun, par schéma moteur.
            #expect(!GuidedCatalog.technique(for: exercise).steps.isEmpty, Comment(rawValue: exercise.id))
        }
    }

    @Test("Aucun identifiant n'est en double dans tout le catalogue")
    func idsStayUnique() {
        let ids = ExerciseCatalog.all.map(\.id)
        #expect(Set(ids).count == ids.count, "identifiants en double dans le catalogue")
    }
}
