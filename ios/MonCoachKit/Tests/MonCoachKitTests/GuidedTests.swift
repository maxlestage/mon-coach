import Foundation
import Testing
@testable import MonCoachKit

@Suite("Mode guidé")
struct GuidedTests {

    @Test("Chaque exercice du catalogue a une fiche")
    func everyExerciseIsCovered() {
        for exercise in ExerciseCatalog.all {
            let technique = GuidedCatalog.technique(for: exercise)
            #expect(!technique.steps.isEmpty, Comment(rawValue: exercise.id))
            #expect(!technique.mistakes.isEmpty, Comment(rawValue: exercise.id))
        }
    }

    @Test("Chaque schéma moteur a sa propre fiche, pas la fiche par défaut")
    func everyPatternHasItsOwnSheet() {
        // L'isolation et le port de charge en ont une aussi : la fiche par
        // défaut ne doit servir que si un schéma moteur est ajouté un jour
        // sans qu'on ait écrit la sienne.
        for pattern in MovementPattern.allCases {
            #expect(GuidedCatalog.byPattern[pattern] != nil, Comment(rawValue: pattern.rawValue))
        }
    }

    @Test("Tout le texte guidé existe dans les trois langues")
    func everythingIsTranslated() {
        for technique in GuidedCatalog.all {
            #expect(technique.title.isComplete, Comment(rawValue: technique.id))
            #expect(technique.breathing.isComplete, Comment(rawValue: technique.id))
            #expect(technique.tempo.isComplete, Comment(rawValue: technique.id))
            #expect(technique.oneThing.isComplete, Comment(rawValue: technique.id))
            #expect(technique.easier?.isComplete ?? true, Comment(rawValue: technique.id))
            #expect(technique.harder?.isComplete ?? true, Comment(rawValue: technique.id))
            for step in technique.steps {
                #expect(step.title.isComplete, Comment(rawValue: "\(technique.id) / \(step.index)"))
                #expect(step.detail.isComplete, Comment(rawValue: "\(technique.id) / \(step.index)"))
                #expect(step.checkpoint?.isComplete ?? true, Comment(rawValue: "\(technique.id) / \(step.index)"))
            }
            for mistake in technique.mistakes {
                #expect(mistake.symptom.isComplete, Comment(rawValue: technique.id))
                #expect(mistake.cause.isComplete, Comment(rawValue: technique.id))
                #expect(mistake.fix.isComplete, Comment(rawValue: technique.id))
            }
        }
        #expect(FirstSessions.rationale.isComplete)
    }

    @Test("Les étapes sont numérotées dans l'ordre, sans trou")
    func stepsAreOrdered() {
        for technique in GuidedCatalog.all {
            let indices = technique.steps.map(\.index)
            #expect(indices == Array(1...indices.count), Comment(rawValue: technique.id))
        }
    }

    @Test("Chaque fiche donne au moins un point de contrôle vérifiable seul")
    func everySheetHasACheckpoint() {
        for technique in GuidedCatalog.all {
            let checkpoints = technique.steps.compactMap(\.checkpoint)
            #expect(!checkpoints.isEmpty, Comment(rawValue: "aucun repère : \(technique.id)"))
        }
    }

    @Test("Une erreur décrit toujours un symptôme, une cause et une correction")
    func mistakesAreActionable() {
        for technique in GuidedCatalog.all {
            for mistake in technique.mistakes {
                // Une « correction » qui répète le symptôme ne corrige rien.
                #expect(mistake.fix.fr != mistake.symptom.fr)
                #expect(mistake.fix.fr.count > 30, Comment(rawValue: technique.id))
            }
        }
    }

    @Test("Un exercice inconnu ne fait pas planter la recherche de fiche")
    func unknownExercise() {
        #expect(GuidedCatalog.technique(forExerciseID: "n-existe-pas") == nil)
        #expect(GuidedCatalog.technique(forExerciseID: "back-squat") != nil)
    }

    @Test("Le squat, la charnière et la poussée ont leurs propres fiches détaillées")
    func mainPatternsAreDetailed() {
        for pattern in [MovementPattern.squat, .hinge, .horizontalPush] {
            let technique = GuidedCatalog.byPattern[pattern]
            #expect((technique?.steps.count ?? 0) >= 4, Comment(rawValue: pattern.rawValue))
            #expect((technique?.mistakes.count ?? 0) >= 2, Comment(rawValue: pattern.rawValue))
        }
    }
}

@Suite("Premières séances")
struct FirstSessionsTests {

    @Test("Le parcours couvre cinq semaines sans trou et se traduit")
    func pathIsComplete() {
        #expect(FirstSessions.path.map(\.week) == [1, 2, 3, 4, 5])
        for step in FirstSessions.path {
            #expect(step.title.isComplete)
            #expect(step.goal.isComplete)
            #expect(step.instruction.isComplete)
            #expect(step.readyWhen.isComplete)
        }
    }

    @Test("Le parcours suit les semaines et s'arrête après la cinquième")
    func stepFollowsTheWeeks() {
        let profile = Fixtures.beginner()
        for week in 1...5 {
            let date = Fixtures.calendar.date(byAdding: .day, value: (week - 1) * 7 + 2, to: Fixtures.start)!
            let step = FirstSessions.step(
                for: profile,
                startedOn: Fixtures.start,
                on: date,
                calendar: Fixtures.calendar
            )
            #expect(step?.week == week, Comment(rawValue: "semaine \(week)"))
        }
        let later = Fixtures.calendar.date(byAdding: .day, value: 60, to: Fixtures.start)!
        #expect(
            FirstSessions.step(for: profile, startedOn: Fixtures.start, on: later, calendar: Fixtures.calendar) == nil
        )
    }

    @Test("Un athlète expérimenté ne voit jamais le parcours débutant")
    func experiencedAthletesSkipIt() {
        for profile in [Fixtures.intermediate(), Fixtures.advanced()] {
            #expect(
                FirstSessions.step(
                    for: profile,
                    startedOn: Fixtures.start,
                    on: Fixtures.start,
                    calendar: Fixtures.calendar
                ) == nil
            )
        }
    }

    @Test("Une date antérieure au départ renvoie la première étape plutôt que rien")
    func beforeTheStart() {
        let before = Fixtures.calendar.date(byAdding: .day, value: -3, to: Fixtures.start)!
        let step = FirstSessions.step(
            for: Fixtures.beginner(),
            startedOn: Fixtures.start,
            on: before,
            calendar: Fixtures.calendar
        )
        #expect(step?.week == 1)
    }
}
