import Foundation
import Testing
@testable import MonCoachKit

/// Les rappels ne servent que si on les garde allumés.
///
/// Ce qui se joue ici
/// ------------------
/// Une application qui sonne quatre fois le même soir se fait couper le son
/// la première semaine, et ne dira plus jamais rien — y compris le jour où
/// elle avait raison. Ces tests-ci ne vérifient pas que le rappel part : ils
/// vérifient qu'il se **tait** quand il n'a rien à dire.
@Suite("L'application relance, sans harceler")
struct ReminderPlannerTests {

    static let calendar = Fixtures.calendar
    static let settings = ReminderSettings(enabled: true, hour: 18, minute: 30)

    /// Un matin, pour que le rappel de dix-huit heures trente soit encore
    /// devant nous.
    static func morning(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 8))!
    }

    static func program() -> CoachingProgram {
        CoachEngine.buildProgram(
            for: Fixtures.intermediate(),
            startingOn: Fixtures.start,
            calendar: calendar
        )
    }

    @Test("Rien n'est posé tant que l'athlète n'a pas dit oui")
    func silentUntilAskedFor() {
        let plan = ReminderPlanner.plan(
            program: Self.program(),
            history: TrainingHistory(sessions: [], bodyLogs: [], readiness: []),
            settings: .off,
            from: Self.morning(2026, 9, 20),
            calendar: Self.calendar
        )
        #expect(plan.isEmpty, "une notification jamais demandée est une notification de trop")
    }

    @Test("Un seul rappel par jour, même quand trois ont raison")
    func atMostOnePerDay() {
        // Personne depuis dix jours : l'absence, la pesée et le bilan de
        // forme ont tous les trois quelque chose à dire le même soir.
        let history = TrainingHistory(
            sessions: [SessionLog(date: Fixtures.date(2026, 9, 5), durationMinutes: 60)],
            bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 5), weightKg: 80)],
            readiness: []
        )
        let plan = ReminderPlanner.plan(
            program: Self.program(), history: history, settings: Self.settings,
            from: Self.morning(2026, 9, 15), calendar: Self.calendar
        )
        let byDay = Dictionary(grouping: plan) {
            ReminderPlanner.dayStamp($0.date, calendar: Self.calendar)
        }
        for (day, sameDay) in byDay {
            #expect(sameDay.count == 1, "\(day) porte \(sameDay.count) rappels")
        }
    }

    @Test("Quand plusieurs ont raison, c'est le plus rare qui parle")
    func rarestSpeaksFirst() {
        let history = TrainingHistory(
            sessions: [SessionLog(date: Fixtures.date(2026, 9, 5), durationMinutes: 60)],
            bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 5), weightKg: 80)],
            readiness: []
        )
        let plan = ReminderPlanner.plan(
            program: Self.program(), history: history, settings: Self.settings,
            from: Self.morning(2026, 9, 15), calendar: Self.calendar
        )
        // Revenir après dix jours compte plus qu'une pesée oubliée, qui
        // compte plus qu'un bilan qu'on remplira en ouvrant l'application.
        #expect(plan.first?.kind == .comeBack)
    }

    @Test("On ne rappelle pas de revenir à quelqu'un qui s'entraîne")
    func noNudgeForSomeoneWhoShowsUp() {
        var sessions: [SessionLog] = []
        for day in 10...16 {
            sessions.append(SessionLog(date: Fixtures.date(2026, 9, day), durationMinutes: 60))
        }
        let history = TrainingHistory(
            sessions: sessions,
            bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 16), weightKg: 80)],
            readiness: []
        )
        let now = Self.morning(2026, 9, 17)
        let plan = ReminderPlanner.plan(
            program: Self.program(), history: history, settings: Self.settings,
            from: now, calendar: Self.calendar
        )
        // Ce qui compte est le silence pendant le délai de grâce. Au-delà, un
        // « ça fait cinq jours » posé pour dans cinq jours n'est pas une
        // erreur : il ne sonnera que si rien n'a été enregistré d'ici là, et
        // enregistrer passe par l'application, qui replanifie aussitôt. Le
        // rappel s'annule donc de lui-même dès qu'il devient faux.
        let graceEnds = Self.calendar.date(
            byAdding: .day, value: ReminderPlanner.quietDaysBeforeNudging,
            to: Fixtures.date(2026, 9, 16)
        )!
        let tooSoon = plan.filter { $0.kind == .comeBack && $0.date < graceEnds }
        #expect(tooSoon.isEmpty, "on ne relance pas quelqu'un qui s'entraînait avant-hier")
    }

    @Test("Une sortie compte autant qu'une séance de salle")
    func aRunCountsAsShowingUp() {
        // Quelqu'un qui a couru trois fois cette semaine n'a pas disparu.
        // Ne compter que la salle lui aurait envoyé « ça fait dix jours ».
        let history = TrainingHistory(
            sessions: [SessionLog(date: Fixtures.date(2026, 9, 1), durationMinutes: 60)],
            activities: [
                ActivityLog(startedAt: Fixtures.date(2026, 9, 16), sport: .run,
                            type: .easy, meters: 5000, duration: 1800,
                            elevationGain: 0)
            ]
        )
        let last = ReminderPlanner.lastEffort(history)
        #expect(last == Fixtures.date(2026, 9, 16))
    }

    @Test("La semaine ne se signale que lorsque le compte devient serré")
    func weekIsMentionedOnlyWhenItGetsTight() {
        // Quatre séances prévues, aucune faite, mais la semaine vient de
        // commencer : il n'y a rien à signaler.
        let early = ReminderPlanner.plan(
            program: Self.program(),
            history: TrainingHistory(
                bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 8), weightKg: 80)],
                activities: [ActivityLog(startedAt: Fixtures.date(2026, 9, 8), sport: .run,
                                         type: .easy, meters: 5000, duration: 1800,
                                         elevationGain: 0)]
            ),
            settings: ReminderSettings(enabled: true, hour: 18, minute: 30, kinds: [.sessionsLeft]),
            from: Self.morning(2026, 9, 8), calendar: Self.calendar
        )
        #expect(early.first(where: {
            Self.calendar.isDate($0.date, inSameDayAs: Fixtures.date(2026, 9, 8))
        }) == nil, "le lundi, quatre séances en sept jours ne sont pas une alerte")
    }

    @Test("Une pesée du jour fait taire le rappel de pesée")
    func aFreshWeighInSilencesIt() {
        let history = TrainingHistory(
            sessions: [SessionLog(date: Fixtures.date(2026, 9, 16), durationMinutes: 60)],
            bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 17), weightKg: 80)],
            readiness: []
        )
        let plan = ReminderPlanner.plan(
            program: Self.program(), history: history,
            settings: ReminderSettings(enabled: true, hour: 18, minute: 30, kinds: [.weighIn]),
            from: Self.morning(2026, 9, 17), calendar: Self.calendar
        )
        #expect(plan.isEmpty)
    }

    @Test("Chaque rappel est daté dans le futur, et nommé une seule fois")
    func remindersAreFutureAndUnique() {
        let now = Self.morning(2026, 9, 15)
        let plan = ReminderPlanner.plan(
            program: Self.program(),
            history: TrainingHistory(
                sessions: [SessionLog(date: Fixtures.date(2026, 9, 5), durationMinutes: 60)],
                bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 5), weightKg: 80)]
            ),
            settings: Self.settings, from: now, calendar: Self.calendar
        )
        #expect(!plan.isEmpty, "dix jours sans rien devrait produire quelque chose")
        for reminder in plan {
            #expect(reminder.date > now, "un rappel passé ne sonnera jamais")
        }
        #expect(Set(plan.map(\.id)).count == plan.count, "deux rappels ne partagent pas un identifiant")
        #expect(plan.map(\.date) == plan.map(\.date).sorted(), "du plus proche au plus lointain")
    }

    @Test("Les trois langues sont écrites")
    func everyReminderIsTranslated() {
        let plan = ReminderPlanner.plan(
            program: Self.program(),
            history: TrainingHistory(
                sessions: [SessionLog(date: Fixtures.date(2026, 9, 5), durationMinutes: 60)],
                bodyLogs: [BodyLog(date: Fixtures.date(2026, 9, 5), weightKg: 80)]
            ),
            settings: Self.settings, from: Self.morning(2026, 9, 15), calendar: Self.calendar
        )
        for reminder in plan {
            for language in Language.allCases {
                #expect(!reminder.title[language].isEmpty, "\(reminder.kind) sans titre en \(language.rawValue)")
                #expect(!reminder.message[language].isEmpty, "\(reminder.kind) sans texte en \(language.rawValue)")
            }
        }
    }
}
