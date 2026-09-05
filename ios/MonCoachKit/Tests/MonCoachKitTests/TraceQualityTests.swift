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

    /// Ce test disait auparavant que quarante points à 80 m étaient jetés.
    /// Ils ne le sont plus : ils sont gardés, comptés dans la distance, et
    /// dits. La promesse — « on ne cache pas ce qui s'est passé » — n'a pas
    /// changé ; c'est la réponse qui a changé, de « jeté » à « gardé et
    /// signalé ».
    @Test("Des points imprécis sont gardés, comptés, et dits")
    func poorPointsAreKeptAndReported() throws {
        var points = cleanRun()
        // Sous les arbres, le GPS annonce lui-même son erreur. Un point sur
        // deux sur presque toute la sortie : la mesure repose franchement
        // dessus, et ça se dit.
        for index in stride(from: 20, to: 300, by: 2) {
            points[index].horizontalAccuracy = 80
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        let note = try #require(TraceAnalysis.quality(of: trace))

        #expect(trace.rejectedForAccuracy == 0)
        #expect(trace.keptWithPoorAccuracy == 140)
        #expect(note.retention == 1)
        #expect(note.reasons.contains { $0.fr.contains("signal faible") })
        #expect(note.reasons.allSatisfy { $0.isComplete })
        #expect(note.headline.isComplete)
    }

    /// L'autre moitié de la règle : quelques points flous sur une sortie en
    /// ville sont l'ordinaire, et ne méritent aucune remarque. Une remarque
    /// à chaque sortie est une remarque qu'on apprend à ne plus lire.
    @Test("Quelques points flous ne déclenchent rien")
    func aFewPoorPointsStayQuiet() {
        var points = cleanRun()
        for index in stride(from: 50, to: 90, by: 2) {
            points[index].horizontalAccuracy = 80
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.run.filter)
        #expect(trace.keptWithPoorAccuracy == 20)
        #expect(TraceAnalysis.quality(of: trace) == nil)
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
        //
        // Deux cent cinquante mètres et non quatre-vingt-dix : depuis que la
        // précision se lit sur deux seuils, quatre-vingt-dix mètres est du
        // signal médiocre qu'on garde, pas du bruit qu'on jette. Pour tester
        // une trace vraiment amputée, il faut des points vraiment muets.
        for index in 0..<150 {
            points[index * 2].horizontalAccuracy = 250
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
        // Au-delà du tolérable : ces points-là sont vraiment jetés, et c'est
        // ce que la note doit pouvoir raconter depuis une activité relue.
        for index in stride(from: 40, to: 120, by: 2) {
            points[index].horizontalAccuracy = 250
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
