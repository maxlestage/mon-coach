import Foundation
import Testing
@testable import MonCoachKit

/// La garantie de traduction, vérifiée sur ce que le moteur produit vraiment
/// et pas seulement sur les catalogues : un texte composé à l'exécution — une
/// justification qui cite un nombre, un bilan de semaine — est justement celui
/// qu'on oublie de traduire.
@Suite("Trois langues")
struct LocalizationCoverageTests {

    static func program(_ goal: PrimaryGoal, diet: DietPreference = .omnivore) -> CoachingProgram {
        var profile = Fixtures.intermediate(goal: goal, limitations: [.shoulder, .knee])
        profile.dietPreference = diet
        profile.running = RunningProfile(goal: .halfMarathon, runsPerWeek: 4, currentWeeklyMeters: 28_000)
        return CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
    }

    @Test("Tout le catalogue d'exercices est traduit")
    func exerciseCatalog() {
        for exercise in ExerciseCatalog.all {
            #expect(exercise.name.isComplete, Comment(rawValue: "nom : \(exercise.id)"))
            #expect(exercise.cue.isComplete, Comment(rawValue: "consigne : \(exercise.id)"))
        }
    }

    @Test("Tous les libellés d'énumération sont traduits")
    func enumLabels() {
        for value in Sex.allCases { #expect(value.label.isComplete) }
        for value in ExperienceLevel.allCases { #expect(value.label.isComplete) }
        for value in PrimaryGoal.allCases { #expect(value.label.isComplete) }
        for value in ActivityLevel.allCases { #expect(value.label.isComplete) }
        for value in Equipment.allCases { #expect(value.label.isComplete) }
        for value in MuscleGroup.allCases { #expect(value.label.isComplete) }
        for value in MovementPattern.allCases { #expect(value.label.isComplete) }
        for value in Limitation.allCases { #expect(value.label.isComplete) }
        for value in DietPreference.allCases { #expect(value.label.isComplete) }
        for value in UnitSystem.allCases { #expect(value.label.isComplete) }
        for value in LoadIncrement.allCases { #expect(value.label.isComplete) }
        for value in SplitTemplate.allCases {
            #expect(value.label.isComplete)
            #expect(value.rationale.isComplete)
        }
        for value: LoadDecision.Action in [.start, .increase, .hold, .decrease, .deload] {
            #expect(value.label.isComplete)
        }
        for value in Language.allCases { #expect(!value.endonym.isEmpty) }
    }

    @Test("Un programme complet ne contient aucun texte non traduit")
    func wholeProgram() {
        for goal in PrimaryGoal.allCases {
            let program = Self.program(goal)
            for note in program.nutrition.rationale {
                #expect(note.isComplete, Comment(rawValue: "\(goal.rawValue) : \(note.fr)"))
            }
            for note in program.plan.rationale {
                #expect(note.isComplete, Comment(rawValue: "\(goal.rawValue) : \(note.fr)"))
            }
            for week in program.plan.weeks {
                for session in week.sessions {
                    #expect(session.title.isComplete, Comment(rawValue: session.title.fr))
                    for prescription in session.exercises {
                        #expect(prescription.note?.isComplete ?? true)
                    }
                }
            }
            for note in program.runningBlock?.notes ?? [] { #expect(note.isComplete) }
        }
    }

    @Test("Un briefing complet est traduit, décisions de charge comprises")
    func briefing() {
        let program = Self.program(.hypertrophy)
        for dayOffset in 0..<14 {
            let date = Fixtures.calendar.date(byAdding: .day, value: dayOffset, to: Fixtures.start)!
            let check = ReadinessCheck(date: date, sleepQuality: 2, soreness: 4, motivation: 2, stress: 4)
            let briefing = CoachEngine.briefing(
                for: program,
                history: TrainingHistory(readiness: [check]),
                on: date,
                calendar: Fixtures.calendar
            )
            #expect(briefing.readiness.headline.isComplete)
            #expect(briefing.readiness.advice.isComplete)
            for decision in briefing.loadDecisions.values {
                #expect(decision.reason.isComplete, Comment(rawValue: decision.reason.fr))
                #expect(decision.action.label.isComplete)
            }
            for note in briefing.food.notes { #expect(note.isComplete) }
            for meal in briefing.food.meals { #expect(meal.note?.isComplete ?? true) }
            #expect(briefing.plannedRun?.note.isComplete ?? true)
        }
    }

    @Test("Chaque verdict de forme du jour est traduit, du feu vert au rouge")
    func everyReadinessVerdict() {
        let profile = Fixtures.intermediate()
        #expect(ReadinessEngine.verdict(for: nil, profile: profile).headline.isComplete)
        for quality in 1...5 {
            for soreness in 1...5 {
                let check = ReadinessCheck(
                    date: Fixtures.start,
                    sleepQuality: quality,
                    soreness: soreness,
                    motivation: quality,
                    stress: soreness
                )
                let verdict = ReadinessEngine.verdict(for: check, profile: profile)
                #expect(verdict.headline.isComplete)
                #expect(verdict.advice.isComplete)
            }
        }
    }

    @Test("Un bilan de semaine est traduit, quel que soit ce qui s'est passé")
    func weeklyReview() {
        let program = Self.program(.fatLoss)
        guard let week = program.plan.week(at: 1) else { return }

        // Trois semaines très différentes : parfaite, ratée, douloureuse.
        var perfect = TrainingHistory()
        var missed = TrainingHistory()
        var painful = TrainingHistory()
        for (index, session) in week.sessions.enumerated() {
            let date = Fixtures.calendar.date(byAdding: .day, value: index, to: Fixtures.start)!
            perfect.sessions.append(Fixtures.perfectSession(session, on: date))
            var hurt = Fixtures.perfectSession(session, on: date)
            hurt.sets = hurt.sets.map { set in
                var copy = set
                copy.painFlag = true
                return copy
            }
            painful.sessions.append(hurt)
        }
        for offset in 0..<5 {
            let date = Fixtures.calendar.date(byAdding: .day, value: offset, to: Fixtures.start)!
            let log = BodyLog(date: date, weightKg: 78 - Double(offset) * 0.4)
            perfect.bodyLogs.append(log)
            missed.bodyLogs.append(log)
            painful.bodyLogs.append(log)
        }

        for history in [perfect, missed, painful] {
            let review = AdaptationEngine.review(
                profile: program.profile,
                plan: program.plan,
                history: history,
                nutrition: program.nutrition,
                weekIndex: 1,
                calendar: Fixtures.calendar
            )
            #expect(!review.insights.isEmpty)
            for insight in review.insights {
                #expect(insight.title.isComplete, Comment(rawValue: insight.title.fr))
                #expect(insight.message.isComplete, Comment(rawValue: insight.message.fr))
            }
        }
    }

    @Test("Les trois langues donnent bien trois textes différents")
    func languagesActuallyDiffer() {
        // Une traduction copiée-collée depuis le français passerait `isComplete`
        // sans traduire quoi que ce soit : on vérifie donc que ça bouge.
        let program = Self.program(.hypertrophy)
        var identical = 0
        var total = 0
        for note in program.nutrition.rationale + program.plan.rationale {
            total += 1
            if note.fr == note.en { identical += 1 }
        }
        #expect(total > 0)
        #expect(identical == 0, Comment(rawValue: "\(identical) justifications sur \(total) non traduites"))

        // Sur le catalogue, quelques noms sont volontairement identiques
        // (« Dips », « Face pull », « Hip thrust ») : c'est le terme employé
        // dans les trois langues, pas un oubli.
        let untranslatedCues = ExerciseCatalog.all.filter { $0.cue.fr == $0.cue.en }
        #expect(untranslatedCues.isEmpty, Comment(rawValue: untranslatedCues.map(\.id).joined(separator: ", ")))
    }

    @Test("La langue de la montre suit celle du téléphone")
    @MainActor
    func watchFollowsThePhone() {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "mon-coach-langue-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        store.completeOnboarding(with: Fixtures.intermediate(), startingOn: Fixtures.start)

        store.setLanguage(.spanish)
        #expect(store.language == .spanish)
        #expect(store.watchSnapshot(on: Fixtures.start)?.language == .spanish)

        // Revenir à « suivre le système » ne fige pas la langue précédente.
        store.setLanguage(nil)
        #expect(store.language == CoachStore.systemLanguage)
    }

    @Test("La Live Activity traverse la frontière déjà traduite")
    func liveActivityIsRendered() {
        let program = Self.program(.hypertrophy)
        let briefing = CoachEngine.briefing(
            for: program,
            history: .empty,
            on: Fixtures.start,
            calendar: Fixtures.calendar
        )
        guard let session = briefing.session else { return }
        let active = ActiveSession(session: session)
        let french = active.activitySnapshot(unit: .metric, language: .french)
        let spanish = active.activitySnapshot(unit: .metric, language: .spanish)
        #expect(french.setLabel != spanish.setLabel)
        #expect(french.sessionTitle != spanish.sessionTitle || session.title.fr == session.title.es)
        #expect(!spanish.exerciseName.isEmpty)
    }
}
