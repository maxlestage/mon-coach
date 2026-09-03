import Foundation
import Testing
@testable import MonCoachKit

/// Importer de Santé, sans rien écraser ni rien compter deux fois.
///
/// Ce qui se joue ici
/// ------------------
/// Un import qui double les séances est pire que pas d'import du tout : la
/// charge d'entraînement de la semaine devient fausse, et c'est elle qui
/// décide des poids de la semaine suivante. Ces tests-ci gardent surtout ce
/// qu'on refuse d'importer.
@Suite("Ce que le téléphone prend dans Santé")
struct HealthImportTests {

    static let calendar = Fixtures.calendar

    static func at(_ day: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(
            year: 2026, month: 9, day: day, hour: hour, minute: minute
        ))!
    }

    // MARK: - Le poids

    @Test("Une pesée notée à la main n'est jamais remplacée")
    func typedWeightWins() {
        // Quelqu'un qui a noté 82,4 ne doit pas voir son chiffre écrasé par
        // celui d'un pèse-personne qu'il a oublié sous le lavabo.
        let mine = BodyLog(date: Self.at(10, 7), weightKg: 82.4)
        let adopted = HealthImport.newBodyLogs(
            from: [HealthWeight(date: Self.at(10, 9), kilograms: 79.1)],
            existing: [mine], calendar: Self.calendar
        )
        #expect(adopted.isEmpty)
    }

    @Test("Un jour vide se remplit")
    func emptyDayIsFilled() {
        let adopted = HealthImport.newBodyLogs(
            from: [HealthWeight(date: Self.at(11, 7), kilograms: 81.2)],
            existing: [BodyLog(date: Self.at(10, 7), weightKg: 82.4)],
            calendar: Self.calendar
        )
        #expect(adopted.count == 1)
        #expect(adopted.first?.weightKg == 81.2)
    }

    @Test("Trois pesées le même matin ne font qu'une ligne")
    func oneWeightPerDay() {
        // Une balance qui hésite écrit trois fois. Les garder toutes donne
        // une courbe de poids en dents de scie qui ne veut rien dire.
        let adopted = HealthImport.newBodyLogs(
            from: [
                HealthWeight(date: Self.at(12, 7, 0), kilograms: 80.9),
                HealthWeight(date: Self.at(12, 7, 1), kilograms: 81.4),
                HealthWeight(date: Self.at(12, 7, 2), kilograms: 81.1),
            ],
            existing: [], calendar: Self.calendar
        )
        #expect(adopted.count == 1)
        #expect(adopted.first?.weightKg == 81.1, "la dernière du matin, pas la première")
    }

    // MARK: - Le sommeil

    @Test("La nuit du jour se retrouve, les autres non")
    func sleepIsFoundForTheRightDay() {
        let nights = [
            HealthSleep(wakeDate: Self.at(10, 7), hours: 7.5),
            HealthSleep(wakeDate: Self.at(11, 7), hours: 6.0),
        ]
        #expect(HealthImport.sleepHours(on: Self.at(11, 18), from: nights, calendar: Self.calendar) == 6.0)
        #expect(HealthImport.sleepHours(on: Self.at(12, 18), from: nights, calendar: Self.calendar) == nil)
    }

    // MARK: - Les sorties

    @Test("Ce que la montre a écrit ne revient pas par Santé")
    func ourOwnWorkoutsAreNotReimported() {
        // La montre enregistre ses séances dans Santé. Les relire les
        // compterait deux fois, et une semaine à quatre sorties en
        // afficherait huit.
        let adopted = HealthImport.newActivities(
            from: [HealthWorkout(startedAt: Self.at(10, 18), duration: 1800,
                                 meters: 5000, sport: .run, source: "Stride")],
            existing: [], ourSourceNames: ["Stride", "Stride Entraînement"]
        )
        #expect(adopted.isEmpty)
    }

    @Test("Une sortie déjà au journal ne rentre pas deux fois")
    func alreadyLoggedIsSkipped() {
        // Deux applications qui suivent la même course la datent à quelques
        // secondes près. Exiger l'égalité stricte laisserait passer le
        // doublon.
        let existing = ActivityLog(
            startedAt: Self.at(10, 18), sport: .run, type: .easy,
            meters: 5000, duration: 1800, elevationGain: 0
        )
        let adopted = HealthImport.newActivities(
            from: [HealthWorkout(startedAt: Self.at(10, 18, 1), duration: 1800,
                                 meters: 5000, sport: .run, source: "Nike")],
            existing: [existing], ourSourceNames: ["Stride"]
        )
        #expect(adopted.isEmpty)
    }

    @Test("Deux sorties du même jour, bien séparées, rentrent toutes les deux")
    func twoRealSessionsBothCount() {
        let adopted = HealthImport.newActivities(
            from: [
                HealthWorkout(startedAt: Self.at(10, 7), duration: 1800,
                              meters: 5000, sport: .run, source: "Nike"),
                HealthWorkout(startedAt: Self.at(10, 18), duration: 2400,
                              meters: 20000, sport: .ride, source: "Nike"),
            ],
            existing: [], ourSourceNames: ["Stride"]
        )
        #expect(adopted.count == 2)
        #expect(adopted.map(\.sport) == [.run, .ride])
    }

    @Test("Deux imports d'affilée ne dupliquent pas non plus")
    func importIsIdempotentWithinOneBatch() {
        // Santé peut porter la même séance écrite par deux applications.
        let same = [
            HealthWorkout(startedAt: Self.at(10, 18), duration: 1800,
                          meters: 5000, sport: .run, source: "Nike"),
            HealthWorkout(startedAt: Self.at(10, 18, 2), duration: 1810,
                          meters: 5020, sport: .run, source: "Garmin"),
        ]
        let adopted = HealthImport.newActivities(
            from: same, existing: [], ourSourceNames: ["Stride"]
        )
        #expect(adopted.count == 1, "la même course écrite deux fois reste une course")
    }

    @Test("Une séance d'une seconde n'encombre pas le journal")
    func stubsAreDropped() {
        let adopted = HealthImport.newActivities(
            from: [HealthWorkout(startedAt: Self.at(10, 18), duration: 3,
                                 meters: 0, sport: .run, source: "Nike")],
            existing: [], ourSourceNames: ["Stride"]
        )
        #expect(adopted.isEmpty)
    }

    @Test("Une sortie importée dit d'où elle vient, dans les trois langues")
    func importedActivitiesSayWhereTheyComeFrom() {
        // Une sortie sans tracé qui apparaît sans explication passe pour un
        // bogue.
        let note = HealthImport.importNote("Garmin")
        for language in Language.allCases {
            #expect(note[language].contains("Garmin"))
            #expect(!note[language].isEmpty)
        }
        let adopted = HealthImport.newActivities(
            from: [HealthWorkout(startedAt: Self.at(10, 18), duration: 1800,
                                 meters: 5000, sport: .run, source: "Garmin")],
            existing: [], ourSourceNames: ["Stride"]
        )
        #expect(adopted.first?.note?.contains("Garmin") == true)
    }
}
