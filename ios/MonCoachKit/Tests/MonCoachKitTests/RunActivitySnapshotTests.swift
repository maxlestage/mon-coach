import Foundation
import Testing
@testable import MonCoachKit

/// Ce que l'écran verrouillé annonce d'une sortie en cours.
///
/// La pastille de la Dynamic Island montrait un coureur quoi qu'on ait
/// choisi, et le titre disait « Endurance » au-dessus d'un VTT. Les deux
/// venaient de la même cause : l'état envoyé à l'extension ne portait pas le
/// sport. L'extension n'a pas le catalogue et ne pouvait pas le deviner.
@Suite("L'état de la Live Activity")
struct RunActivitySnapshotTests {

    /// Le symbole voyage dans l'état, et c'est celui du sport choisi.
    @Test(
        "La pastille montre le sport choisi",
        arguments: [Sport.run, .ride, .swim, .kayak, .wheelchairRacing, .motocross]
    )
    func theBadgeShowsTheChosenSport(sport: Sport) {
        let state = RunActivitySnapshot(
            typeLabel: sport.label[.french],
            symbolName: sport.symbolName,
            distance: "0,00 km",
            pace: "—",
            elevationGain: 0,
            startedAt: Date(),
            movingSeconds: 0,
            isPaused: false,
            hasWeakSignal: true
        )
        #expect(state.symbolName == sport.symbolName)
        #expect(!state.symbolName.isEmpty)
    }

    /// Deux sports différents ne peuvent pas montrer la même chose quand
    /// leurs symboles diffèrent — c'est tout l'objet du correctif.
    @Test("Un vélo ne s'annonce pas comme une course")
    func aRideIsNotAnnouncedAsARun() {
        #expect(Sport.ride.symbolName != Sport.run.symbolName)
        #expect(Sport.swim.symbolName != Sport.run.symbolName)
        #expect(Sport.motocross.symbolName != Sport.run.symbolName)
    }

    /// L'intention de séance n'a de sens que pour ce qui nourrit le plan de
    /// course : un tempo prescrit se reconnaît à son nom. Ailleurs, elle
    /// vaut « facile » faute de mieux, et l'afficher revenait à écrire
    /// « Endurance » au-dessus d'une sortie à VTT.
    @Test("Le titre dit l'intention pour une course, le sport pour le reste")
    func theTitleSaysTheIntentOnlyWhereItMeansSomething() {
        // Une course prévue au plan s'annonce par ce qu'on est parti faire.
        #expect(
            RunActivitySnapshot.title(sport: .run, type: .tempo, language: .french)
                == RunType.tempo.label[.french]
        )
        // Tout le reste s'annonce par son nom, quelle que soit l'intention
        // que l'appelant a passée — et il passe « facile » faute de mieux.
        for sport in [Sport.ride, .mountainBike, .swim, .kayak, .motocross, .wheelchairRacing] {
            #expect(
                RunActivitySnapshot.title(sport: sport, type: .tempo, language: .french)
                    == sport.label[.french],
                Comment(rawValue: sport.rawValue)
            )
        }
        // Et le titre est traduit comme le reste.
        #expect(
            RunActivitySnapshot.title(sport: .ride, type: .easy, language: .spanish)
                == Sport.ride.label[.spanish]
        )
    }
}
