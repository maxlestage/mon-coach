import Foundation
import Testing
@testable import MonCoachKit

@Suite("Ce que la trace a jeté")
struct TraceQualityTests {

    private let start = Date(timeIntervalSince1970: 1_780_000_000)

    /// Une trace propre : un coureur régulier, GPS bien fixé.
    private func cleanRun(points count: Int = 300) -> [GPSPoint] {
        (0..<count).map { index in
            GPSPoint(
                timestamp: start.addingTimeInterval(Double(index)),
                latitude: 48.85 + Double(index) * 0.00003,
                longitude: 2.35,
                altitude: 40,
                horizontalAccuracy: 5
            )
        }
    }

    @Test("Une trace propre ne dit rien")
    func cleanTraceStaysQuiet() {
        let trace = TraceAnalysis.clean(cleanRun(), filter: Sport.run.filter)
        #expect(TraceAnalysis.quality(of: trace) == nil, "un écran qui rassure sans qu'on doute occupe la place")
    }

    @Test("Des points imprécis sont comptés, et dits")
    func inaccuratePointsAreReported() throws {
        var points = cleanRun()
        // Quarante points sous les arbres : le GPS annonce lui-même son
        // erreur. C'est le cas exact que la promesse décrit.
        for index in stride(from: 50, to: 130, by: 2) {
            points[index].horizontalAccuracy = 80
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let note = try #require(TraceAnalysis.quality(of: trace))

        #expect(note.rejectedTotal == 40)
        #expect(note.retention < 1)
        #expect(note.reasons.count == 1)
        #expect(note.reasons[0].fr.contains("40"))
        #expect(note.reasons[0].isComplete)
        #expect(note.headline.isComplete)
        #expect(note.headline.fr.contains("%"))
    }

    @Test("Un saut de GPS est dit comme un saut, pas comme une accélération")
    func impossibleJumpsAreReported() throws {
        var points = cleanRun()
        // Dix points à l'autre bout de la ville : un saut de fix, pas une
        // foulée. Les compter ajouterait des kilomètres jamais parcourus.
        for index in 100..<110 {
            points[index].latitude += 0.5
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let note = try #require(TraceAnalysis.quality(of: trace))
        #expect(note.rejectedTotal > 0)
        #expect(note.reasons.contains { $0.fr.contains("impossible") })
    }

    @Test("Une trace très amputée le dit franchement")
    func severeLossIsCalledOut() throws {
        var points = cleanRun()
        // La moitié de la sortie perdue : la distance affichée est fausse,
        // et l'athlète doit savoir que ce n'est pas lui qui a ralenti.
        for index in 0..<150 {
            points[index * 2].horizontalAccuracy = 90
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let note = try #require(TraceAnalysis.quality(of: trace))
        #expect(note.isSevere)
        #expect(note.headline.fr.contains("plus courte"))
    }

    @Test("Deux ou trois points au démarrage ne déclenchent pas d'alerte")
    func aFewPointsStayQuiet() {
        var points = cleanRun()
        for index in 0..<3 { points[index].horizontalAccuracy = 90 }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        // Trois points sur trois cents : une alerte à chaque sortie n'est
        // plus une alerte.
        #expect(TraceAnalysis.quality(of: trace) == nil)
    }

    @Test("La lecture se refait depuis une activité enregistrée")
    func activityIsReadable() throws {
        var points = cleanRun()
        for index in stride(from: 40, to: 120, by: 2) {
            points[index].horizontalAccuracy = 80
        }
        let activity = TraceAnalysis.summarise(rawPoints: points, sport: .run, type: .easy)
        #expect(TraceAnalysis.quality(of: activity) != nil)

        // Une séance sans trace n'a rien à dire là-dessus.
        let indoor = ActivityLog(
            startedAt: start, sport: .rowingMachine, type: .easy,
            meters: 0, duration: 1_800, elevationGain: 0
        )
        #expect(TraceAnalysis.quality(of: indoor) == nil)
    }
}
