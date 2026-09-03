import Foundation
import Testing
@testable import MonCoachKit

@Suite("L'instantané des widgets")
struct WidgetSnapshotTests {

    /// Le programme d'un athlète qui court : il porte des séances et un plan
    /// de course, ce qui permet de tomber sur les deux cas d'un même jour.
    private static func program() -> CoachingProgram {
        var profile = Fixtures.intermediate(daysPerWeek: 4)
        profile.running = RunningProfile(goal: .tenK, runsPerWeek: 3, currentWeeklyMeters: 24_000)
        return CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start)
    }

    private static func briefing(dayOffset: Int) -> TodayBriefing {
        let day = Fixtures.calendar.date(byAdding: .day, value: dayOffset, to: Fixtures.start)!
        return CoachEngine.briefing(
            for: program(),
            history: .empty,
            on: day,
            calendar: Fixtures.calendar
        )
    }

    @Test("Un jour de séance se dit en un titre et un compte")
    func trainingDayReadsAsASession() {
        guard let day = (0..<7).first(where: { Self.briefing(dayOffset: $0).session != nil }) else {
            Issue.record("aucune séance dans la première semaine")
            return
        }
        let briefing = Self.briefing(dayOffset: day)
        let snapshot = WidgetSnapshot.make(
            briefing: briefing,
            language: .french,
            unit: .metric,
            calendar: Fixtures.calendar
        )
        #expect(snapshot.tone == .training)
        #expect(snapshot.title == briefing.session?.title[.french])
        #expect(snapshot.detail.contains("exercices"))
        #expect(snapshot.detail.contains("séries"))
        #expect(snapshot.symbolName == "dumbbell.fill")
    }

    @Test("Un jour de repos dit ce qui vient, pas « rien »")
    func restDaySaysWhatIsNext() {
        // Le repos arrive quand la séance du jour est faite : le plan est
        // souple, il propose la suivante tant qu'il en reste une, et c'est
        // l'entraînement enregistré qui referme la journée.
        let program = Self.program()
        guard let first = program.plan.weeks.first?.sessions.first else {
            Issue.record("le bloc n'a pas de séance")
            return
        }
        var history = TrainingHistory.empty
        history.sessions.append(Fixtures.perfectSession(first, on: Fixtures.start))

        let briefing = CoachEngine.briefing(
            for: program, history: history, on: Fixtures.start, calendar: Fixtures.calendar
        )
        let snapshot = WidgetSnapshot.make(
            briefing: briefing,
            language: .french,
            unit: .metric,
            calendar: Fixtures.calendar
        )
        #expect(snapshot.tone == .rest)
        #expect(snapshot.title == "Repos")
        #expect(snapshot.detail.hasPrefix("Ensuite : "))
        #expect(snapshot.detail.contains(briefing.nextSession?.title[.french] ?? "—"))
    }

    @Test("La sortie prévue s'affiche, celle qui est faite disparaît")
    func theRunShowsUntilItIsDone() {
        guard let day = (0..<7).first(where: { Self.briefing(dayOffset: $0).plannedRun != nil }) else {
            Issue.record("aucune sortie dans la première semaine")
            return
        }
        let date = Fixtures.calendar.date(byAdding: .day, value: day, to: Fixtures.start)!
        let planned = Self.briefing(dayOffset: day)
        let waiting = WidgetSnapshot.make(
            briefing: planned, language: .french, unit: .metric, calendar: Fixtures.calendar
        )
        #expect(waiting.run != nil)
        #expect(waiting.run?.contains(planned.plannedRun?.type.label[.french] ?? "—") == true)

        // La même journée, une fois la sortie enregistrée.
        var history = TrainingHistory.empty
        history.activities.append(
            ActivityLog(
                startedAt: date, sport: .run, type: .easy,
                meters: 8_000, duration: 2_700, elevationGain: 0
            )
        )
        let done = CoachEngine.briefing(
            for: Self.program(), history: history, on: date, calendar: Fixtures.calendar
        )
        let after = WidgetSnapshot.make(
            briefing: done, language: .french, unit: .metric, calendar: Fixtures.calendar
        )
        #expect(after.run == nil, "le widget réclame une sortie déjà faite")
    }

    @Test("Une reprise passe devant la séance du jour")
    func theComebackComesFirst() {
        let briefing = Self.briefing(dayOffset: 0)
        let comeback = ReturnToTraining(
            daysAway: 24,
            loadReduction: 0.20,
            volumeReduction: 0.35,
            rampWeeks: 3,
            stayedActive: false,
            rebuildsBlock: false,
            headline: LocalizedText(fr: "Trois semaines sans séance", en: "x", es: "x"),
            message: LocalizedText(fr: "On reprend doucement.", en: "x", es: "x")
        )
        let snapshot = WidgetSnapshot.make(
            briefing: briefing,
            language: .french,
            unit: .metric,
            comeback: comeback,
            calendar: Fixtures.calendar
        )
        #expect(snapshot.tone == .attention)
        #expect(snapshot.title == "Trois semaines sans séance")
        #expect(snapshot.detail == "On reprend doucement.")
    }

    @Test("L'instantané d'hier ne parle plus d'aujourd'hui")
    func yesterdaysSnapshotKnowsItIsStale() {
        let snapshot = WidgetSnapshot.make(
            briefing: Self.briefing(dayOffset: 0),
            language: .french,
            unit: .metric,
            calendar: Fixtures.calendar
        )
        let tomorrow = Fixtures.calendar.date(byAdding: .day, value: 1, to: Fixtures.start)!
        #expect(snapshot.isCurrent(on: Fixtures.start, calendar: Fixtures.calendar))
        #expect(!snapshot.isCurrent(on: tomorrow, calendar: Fixtures.calendar))
    }

    @Test("Chaque langue produit son texte, et aucune ne reste en français")
    func everyLanguageIsWritten() {
        guard let day = (0..<7).first(where: { Self.briefing(dayOffset: $0).session != nil }) else {
            Issue.record("aucune séance dans la première semaine")
            return
        }
        let briefing = Self.briefing(dayOffset: day)
        let french = WidgetSnapshot.make(
            briefing: briefing, language: .french, unit: .metric, calendar: Fixtures.calendar
        )
        let english = WidgetSnapshot.make(
            briefing: briefing, language: .english, unit: .metric, calendar: Fixtures.calendar
        )
        let spanish = WidgetSnapshot.make(
            briefing: briefing, language: .spanish, unit: .metric, calendar: Fixtures.calendar
        )
        #expect(english.detail.contains("exercises") && english.detail.contains("sets"))
        #expect(spanish.detail.contains("ejercicios") && spanish.detail.contains("series"))
        #expect(french.detail != english.detail)
        #expect(french.weekLabel == "Semaine 1")
        #expect(english.weekLabel == "Week 1")
        #expect(spanish.weekLabel == "Semana 1")
    }

    @Test("Une sortie en minutes se dit en minutes, un fractionné en répétitions")
    func aRunSaysWhatItAsksFor() {
        let byDistance = PlannedRun(
            dayIndex: 0, type: .long, targetMeters: 12_000, note: .constant("")
        )
        #expect(byDistance.summary(unit: .metric) == "12,0 km")

        let byTime = PlannedRun(
            dayIndex: 0, type: .easy, targetDuration: 45 * 60, note: .constant("")
        )
        #expect(byTime.summary(unit: .metric) == "45 min")

        let intervals = PlannedRun(
            dayIndex: 0,
            type: .intervals,
            intervals: [RunInterval(
                repetitions: 6, meters: 400, recoverySeconds: 90, paceSecondsPerKm: 240
            )],
            note: .constant("")
        )
        #expect(intervals.summary(unit: .metric) == "6 × 0,40 km")

        // Une sortie qui ne demande rien ne prétend rien : c'est le cas
        // qu'un « 0,00 km » aurait affiché sans que personne ne le voie.
        let empty = PlannedRun(dayIndex: 0, type: .easy, note: .constant(""))
        #expect(empty.summary(unit: .metric) == nil)
    }

    @Test("Réécrire la même journée ne réveille pas le système")
    func writingTheSameDayChangesNothing() {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "widget-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let store = WidgetSnapshotStore(url: directory.appending(path: "widget.json"))

        var snapshot = WidgetSnapshot.make(
            briefing: Self.briefing(dayOffset: 0),
            language: .french,
            unit: .metric,
            calendar: Fixtures.calendar
        )
        #expect(store.save(snapshot), "la première écriture doit compter")

        // Rouvrir l'application une heure plus tard n'a rien changé au plan :
        // seule la date d'écriture bouge, et elle ne doit pas suffire.
        snapshot.generatedAt = snapshot.generatedAt.addingTimeInterval(3_600)
        #expect(!store.save(snapshot), "une écriture identique a demandé un rafraîchissement")

        snapshot.title = "Autre chose"
        #expect(store.save(snapshot))
        #expect(store.load()?.title == "Autre chose")
    }

    @Test("Le cadran de la montre dit la même journée que l'écran d'accueil")
    func theWatchSaysTheSameThing() {
        let program = Self.program()
        let briefing = CoachEngine.briefing(
            for: program, history: .empty, on: Fixtures.start, calendar: Fixtures.calendar
        )
        guard let session = briefing.session else {
            Issue.record("le premier jour n'a pas de séance")
            return
        }
        let watch = WatchSnapshot(
            generatedAt: Fixtures.start,
            firstName: "Max",
            unit: .metric,
            loadIncrement: .standard,
            weekIndex: briefing.weekIndex,
            isDeloadWeek: briefing.isDeloadWeek,
            readinessScore: 80,
            readinessHeadline: .constant(""),
            language: .french,
            session: session,
            completedSessionIDs: [],
            calories: 2_400,
            proteinG: 150,
            plannedRun: briefing.plannedRun,
            runDone: false
        )
        let fromPhone = WidgetSnapshot.make(
            briefing: briefing, language: .french, unit: .metric, calendar: Fixtures.calendar
        )
        let fromWatch = WidgetSnapshot.make(watch: watch, calendar: Fixtures.calendar)

        // Les deux chemins ne partagent pas une ligne de code ; s'ils
        // divergeaient, l'athlète lirait deux journées différentes sur deux
        // écrans posés côte à côte.
        #expect(fromWatch.title == fromPhone.title)
        #expect(fromWatch.detail == fromPhone.detail)
        #expect(fromWatch.symbolName == fromPhone.symbolName)
        #expect(fromWatch.tone == fromPhone.tone)
        #expect(fromWatch.run == fromPhone.run)
        #expect(fromWatch.weekLabel == fromPhone.weekLabel)
    }

    @Test("Sans numéro de semaine, la montre annonce un bloc terminé")
    func theWatchKnowsTheBlockIsOver() {
        let watch = WatchSnapshot(
            generatedAt: Fixtures.start,
            firstName: "Max",
            unit: .metric,
            loadIncrement: .standard,
            weekIndex: nil,
            isDeloadWeek: false,
            readinessScore: 80,
            readinessHeadline: .constant(""),
            language: .english,
            session: nil,
            completedSessionIDs: [],
            calories: 2_400,
            proteinG: 150,
            plannedRun: nil,
            runDone: false
        )
        let snapshot = WidgetSnapshot.make(watch: watch, calendar: Fixtures.calendar)
        #expect(snapshot.tone == .attention)
        #expect(snapshot.title == "Block finished")
        #expect(snapshot.weekLabel == nil)
    }

    /// Le groupe d'applications est déclaré au même endroit dans les quatre
    /// fichiers d'entitlements — ou dans aucun.
    ///
    /// Deux états sont corrects. Les quatre le déclarent : les widgets lisent
    /// ce que l'application écrit. Aucun ne le déclare : le groupe n'existe
    /// pas encore chez Apple, les widgets s'installent mais restent muets, et
    /// la signature passe.
    ///
    /// L'état à moitié activé, lui, ne se voit qu'au moment de l'archive, et
    /// il la fait échouer sur les quatre cibles à la fois :
    ///
    ///     Provisioning profile "…" doesn't match the entitlements file's
    ///     value for the com.apple.security.application-groups entitlement.
    ///
    /// C'est le build 74. D'où ce test.
    @Test("Les quatre entitlements déclarent le même groupe, ou aucun ne le déclare")
    func theAppGroupIsAllOrNothing() throws {
        let root = URL(filePath: #filePath)
            .deletingLastPathComponent()  // MonCoachKitTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // MonCoachKit
            .deletingLastPathComponent()  // ios
            .appending(path: "MonCoach")
        let files = [
            "MonCoach.entitlements",
            "MonCoachWidgets.entitlements",
            "MonCoachWatch.entitlements",
            "MonCoachWatchWidgets.entitlements",
        ]

        var declaring: [String] = []
        for name in files {
            let text = try String(contentsOf: root.appending(path: name), encoding: .utf8)
            // Sans retirer les commentaires XML, un groupe mis en sommeil
            // continuerait de compter comme déclaré : la chaîne est encore
            // dans le fichier, elle n'est simplement plus lue par Xcode.
            if active(text).contains("<string>\(WidgetSnapshotStore.groupIdentifier)</string>") {
                declaring.append(name)
            }
        }

        #expect(
            declaring.isEmpty || declaring.count == files.count,
            Comment(rawValue: "seuls \(declaring.joined(separator: ", ")) déclarent le groupe")
        )
    }

    /// Le fichier privé de ses commentaires XML.
    private func active(_ text: String) -> String {
        var result = ""
        var rest = Substring(text)
        while let open = rest.range(of: "<!--") {
            result += rest[rest.startIndex..<open.lowerBound]
            guard let close = rest.range(of: "-->", range: open.upperBound..<rest.endIndex) else {
                return result
            }
            rest = rest[close.upperBound...]
        }
        return result + rest
    }
}
