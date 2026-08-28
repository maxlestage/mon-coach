import Foundation
import Testing
@testable import MonCoachKit

@Suite("Coach de salle : remplacements")
struct GymSubstitutionTests {

    static func exercise(_ id: String) -> Exercise {
        guard let found = ExerciseCatalog.exercise(id: id) else {
            Issue.record("exercice inconnu dans le catalogue : \(id)")
            return ExerciseCatalog.all[0]
        }
        return found
    }

    @Test("Un remplacement travaille toujours le même muscle")
    func alwaysSameMuscle() {
        let profile = Fixtures.intermediate()
        for exercise in ExerciseCatalog.available(for: profile) {
            for option in GymCoach.substitutions(for: exercise, profile: profile) {
                let same = option.exercise.primaryMuscle == exercise.primaryMuscle
                let supporting = option.exercise.pattern == exercise.pattern
                    && option.exercise.secondaryMuscles.contains(exercise.primaryMuscle)
                #expect(
                    same || supporting,
                    Comment(rawValue: "\(exercise.id) → \(option.exercise.id)")
                )
            }
        }
    }

    @Test("Un exercice ne se propose jamais lui-même")
    func neverItself() {
        let profile = Fixtures.intermediate()
        for exercise in ExerciseCatalog.available(for: profile) {
            let options = GymCoach.substitutions(for: exercise, profile: profile)
            #expect(!options.contains { $0.exercise.id == exercise.id })
        }
    }

    @Test("Le matériel occupé est vraiment exclu")
    func busyEquipmentIsExcluded() {
        let profile = Fixtures.intermediate()
        let bench = Self.exercise("bench-press")
        let options = GymCoach.substitutions(
            for: bench,
            profile: profile,
            excludingEquipment: [.barbell, .bench]
        )
        #expect(!options.isEmpty)
        for option in options {
            #expect(!option.exercise.equipment.contains(.barbell))
            #expect(!option.exercise.equipment.contains(.bench))
        }
    }

    @Test("Un remplacement respecte le matériel et les zones sensibles du profil")
    func respectsTheProfile() {
        var profile = Fixtures.beginner()          // matériel de maison
        profile.limitations = [.shoulder, .lowerBack]
        profile.dislikedExerciseIDs = ["push-up"]

        for exercise in ExerciseCatalog.available(for: profile) {
            for option in GymCoach.substitutions(for: exercise, profile: profile) {
                #expect(option.exercise.isAvailable(with: profile.equipment), Comment(rawValue: option.exercise.id))
                #expect(!option.exercise.conflicts(with: profile.limitations), Comment(rawValue: option.exercise.id))
                #expect(option.exercise.id != "push-up")
            }
        }
    }

    @Test("Les propositions sont classées de la plus proche à la plus éloignée")
    func orderedByCloseness() {
        let profile = Fixtures.intermediate()
        for exercise in ExerciseCatalog.available(for: profile) {
            let options = GymCoach.substitutions(for: exercise, profile: profile)
            for (left, right) in zip(options, options.dropFirst()) {
                #expect(left.closeness >= right.closeness, Comment(rawValue: exercise.id))
            }
        }
    }

    @Test("Le même écran propose deux fois la même chose")
    func deterministic() {
        let profile = Fixtures.intermediate()
        let squat = Self.exercise("back-squat")
        let first = GymCoach.substitutions(for: squat, profile: profile)
        let second = GymCoach.substitutions(for: squat, profile: profile)
        #expect(first.map(\.exercise.id) == second.map(\.exercise.id))
    }

    @Test("Les gros mouvements ont tous une alternative en salle complète")
    func mainLiftsAreCovered() {
        let profile = Fixtures.intermediate()
        for id in ["back-squat", "bench-press", "conventional-deadlift", "overhead-press", "barbell-row", "pull-up"] {
            let options = GymCoach.substitutions(for: Self.exercise(id), profile: profile)
            #expect(!options.isEmpty, Comment(rawValue: "aucune alternative pour \(id)"))
            #expect(options.count <= 4)
        }
    }

    @Test("Deux remplacements différents ne donnent pas la même justification")
    func reasonsAreSpecific() {
        // Trois cartes qui affichent la même phrase générique ressemblent à
        // un bug plutôt qu'à un conseil : ce qui les distingue, c'est le
        // matériel, et c'est ce qui change la charge à mettre.
        let profile = Fixtures.intermediate()
        for id in ["bench-press", "back-squat", "barbell-row", "overhead-press"] {
            guard let exercise = ExerciseCatalog.exercise(id: id) else { continue }
            let options = GymCoach.substitutions(
                for: exercise,
                profile: profile,
                excludingEquipment: exercise.equipment
            )
            guard options.count >= 2 else { continue }
            let distinct = Set(options.map(\.reason.fr))
            #expect(
                distinct.count >= max(2, options.count - 1),
                Comment(rawValue: "\(id) : \(options.count) options pour \(distinct.count) justifications")
            )
        }
    }

    @Test("Le squat barre propose bien des squats, pas des extensions de jambes")
    func squatProposesSquats() {
        let profile = Fixtures.intermediate()
        let options = GymCoach.substitutions(
            for: Self.exercise("back-squat"),
            profile: profile,
            excludingEquipment: [.barbell]
        )
        let ids = options.map(\.exercise.id)
        #expect(!ids.isEmpty)
        // Le premier choix doit rester un mouvement de squat chargé.
        let first = options[0].exercise
        #expect(first.pattern == .squat, Comment(rawValue: first.id))
        #expect(first.isCompound, Comment(rawValue: first.id))
    }

    @Test("Sans matériel du tout, la liste est vide plutôt que fausse")
    func noEquipmentGivesNothing() {
        var profile = Fixtures.intermediate()
        profile.equipment = [.bodyweight]
        let options = GymCoach.substitutions(
            for: Self.exercise("bench-press"),
            profile: profile,
            excludingEquipment: [.bodyweight]
        )
        #expect(options.isEmpty)
    }
}

@Suite("Coach de salle : situations")
struct GymAnswerTests {

    static func session() -> PlannedSession? {
        let program = CoachEngine.buildProgram(
            for: Fixtures.intermediate(daysPerWeek: 4),
            startingOn: Fixtures.start,
            calendar: Fixtures.calendar
        )
        return program.plan.week(at: 1)?.sessions.first
    }

    @Test("Chaque obstacle reçoit une réponse traduite et exploitable")
    func everyObstacleAnswered() {
        let profile = Fixtures.intermediate()
        let exercise = ExerciseCatalog.exercise(id: "bench-press")
        for obstacle in GymObstacle.allCases {
            let answer = GymCoach.answer(
                to: obstacle,
                exercise: exercise,
                profile: profile,
                session: Self.session()
            )
            #expect(answer.obstacle == obstacle)
            #expect(obstacle.label.isComplete)
            #expect(answer.headline.isComplete, Comment(rawValue: obstacle.rawValue))
            #expect(answer.detail.isComplete, Comment(rawValue: obstacle.rawValue))
            #expect(answer.detail.fr.count > 80, Comment(rawValue: obstacle.rawValue))
            for option in answer.substitutions {
                #expect(option.reason.isComplete)
            }
        }
    }

    @Test("Un appareil pris propose d'abord de changer l'ordre, pas l'exercice")
    func busyEquipmentReordersFirst() {
        guard let session = Self.session(),
              let first = session.exercises.first,
              let exercise = ExerciseCatalog.exercise(id: first.exerciseID)
        else {
            Issue.record("pas de séance à inspecter")
            return
        }
        let answer = GymCoach.answer(
            to: .equipmentBusy,
            exercise: exercise,
            profile: Fixtures.intermediate(daysPerWeek: 4),
            session: session
        )
        // Le détail nomme le mouvement suivant de la séance.
        let next = ExerciseCatalog.exercise(id: session.exercises[1].exerciseID)
        #expect(answer.detail.fr.contains(next?.name.fr ?? "—"))
        #expect(answer.detail.en.contains(next?.name.en ?? "—"))
    }

    @Test("Sans pareur, aucune alternative à la barre n'est proposée")
    func noSpotterAvoidsTheBarbell() {
        let answer = GymCoach.answer(
            to: .noSpotter,
            exercise: ExerciseCatalog.exercise(id: "bench-press"),
            profile: Fixtures.intermediate()
        )
        #expect(!answer.substitutions.isEmpty)
        for option in answer.substitutions {
            #expect(!option.exercise.equipment.contains(.barbell), Comment(rawValue: option.exercise.id))
        }
    }

    @Test("Manquer de temps ne propose pas de remplacement : ce n'est pas le problème")
    func shortOnTimeHasNoSubstitutions() {
        let answer = GymCoach.answer(
            to: .shortOnTime,
            exercise: ExerciseCatalog.exercise(id: "bench-press"),
            profile: Fixtures.intermediate(),
            session: Self.session()
        )
        #expect(answer.substitutions.isEmpty)
        // Le conseil nomme les deux exercices à garder.
        guard let session = Self.session() else { return }
        let kept = ExerciseCatalog.exercise(id: session.exercises[0].exerciseID)
        #expect(answer.detail.fr.contains(kept?.name.fr ?? "—"))
    }

    @Test("Sans séance et sans exercice, la réponse reste utilisable")
    func worksWithoutContext() {
        for obstacle in GymObstacle.allCases {
            let answer = GymCoach.answer(to: obstacle, exercise: nil, profile: Fixtures.intermediate())
            #expect(answer.headline.isComplete)
            #expect(answer.detail.isComplete)
            #expect(answer.substitutions.isEmpty)
        }
    }
}

@Suite("Guide de salle")
struct GymGuideTests {

    @Test("Chaque thème a des conseils, tous traduits")
    func everyTopicIsFilled() {
        for topic in GymTopic.allCases {
            let tips = GymGuide.tips(for: topic)
            #expect(tips.count >= 2, Comment(rawValue: topic.rawValue))
            #expect(topic.label.isComplete)
            for tip in tips {
                #expect(tip.title.isComplete, Comment(rawValue: tip.id))
                #expect(tip.body.isComplete, Comment(rawValue: tip.id))
                #expect(tip.takeaway?.isComplete ?? true, Comment(rawValue: tip.id))
                #expect(tip.body.fr.count > 100, Comment(rawValue: "conseil trop court : \(tip.id)"))
            }
        }
    }

    @Test("Aucun identifiant en double")
    func idsAreUnique() {
        let ids = GymGuide.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Les traductions ne sont pas le français recopié")
    func translationsDiffer() {
        for tip in GymGuide.all {
            #expect(tip.title.en != tip.title.fr, Comment(rawValue: tip.id))
            #expect(tip.body.es != tip.body.fr, Comment(rawValue: tip.id))
        }
    }
}
