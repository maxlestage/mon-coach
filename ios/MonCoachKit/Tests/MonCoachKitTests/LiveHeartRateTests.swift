import Foundation
import Testing
@testable import MonCoachKit

/// Le pouls en direct sur l'écran verrouillé.
///
/// Ce qui compte ici n'est pas le chiffre — il traverse tel quel — mais la
/// zone, parce que c'est elle qui parle. « Zone 2 » dit de continuer,
/// « zone 4 » dit que la sortie facile ne l'est plus, et une zone fausse
/// ferait lever le pied au mauvais moment.
@Suite("Le pouls en direct")
struct LiveHeartRateTests {

    /// Un athlète de quarante ans : 208 − 0,7 × 40 = 180 bpm.
    /// Les bornes tombent donc à 90, 108, 126, 144 et 162.
    private let maximum = HeartRateAnalysis.estimatedMaximum(age: 40)

    @Test("La fréquence maximale suit Tanaka, pas le folklore")
    func tanakaNotFolklore() {
        #expect(maximum == 180)
    }

    @Test(
        "Chaque battement tombe dans sa zone",
        arguments: [
            (60.0, 1),    // au repos : en bas, pas « hors zone »
            (95.0, 1),
            (110.0, 2),
            (130.0, 3),
            (150.0, 4),
            (170.0, 5),
            (200.0, 5),   // au-dessus du maximum estimé : toujours la 5
        ]
    )
    func everyBeatLandsInItsZone(bpm: Double, expected: Int) {
        #expect(HeartRateAnalysis.zone(for: bpm, maximumBpm: maximum) == expected)
    }

    /// Les bornes elles-mêmes : un battement pile sur une frontière
    /// appartient à la zone du dessus, comme partout ailleurs dans le
    /// paquet — c'est la même fonction qui répond aux deux endroits.
    @Test("Une borne appartient à la zone qu'elle ouvre")
    func aBoundaryOpensItsZone() {
        #expect(HeartRateAnalysis.zone(for: 108, maximumBpm: maximum) == 2)
        #expect(HeartRateAnalysis.zone(for: 107.9, maximumBpm: maximum) == 1)
    }

    /// La même réponse des deux côtés : l'écran verrouillé et le bilan de
    /// sortie posent la même question, et doivent l'obtenir de la même
    /// fonction. Deux calculs séparés finiraient par diverger d'une zone.
    @Test("Le direct et le bilan comptent les zones pareil")
    func liveAndReviewAgree() {
        let samples = (0..<60).map {
            HeartRateSample(timestamp: Date(timeIntervalSince1970: Double($0)), bpm: 150)
        }
        let seconds = HeartRateAnalysis.secondsPerZone(samples: samples, maximumBpm: maximum)
        let liveZone = HeartRateAnalysis.zone(for: 150, maximumBpm: maximum)
        #expect(seconds.keys.allSatisfy { $0 == liveZone })
    }

    // MARK: - Ce que l'écran verrouillé en fait

    private func snapshot(bpm: Int?, maximumBpm: Double?) -> RunActivitySnapshot {
        RunActivitySnapshot(
            typeLabel: "Endurance",
            distance: "8,40 km",
            pace: "5:12 /km",
            elevationGain: 64,
            startedAt: Date(),
            movingSeconds: 2_620,
            isPaused: false,
            hasWeakSignal: false,
            heartRateBpm: bpm,
            heartRateZone: bpm.flatMap { beat in
                maximumBpm.map { HeartRateAnalysis.zone(for: Double(beat), maximumBpm: $0) }
            }
        )
    }

    /// Le cas ordinaire : courir sans ceinture. Rien à afficher, et rien
    /// n'est affiché — une case vide ferait croire à une panne de capteur.
    @Test("Sans ceinture, il n'y a rien à montrer")
    func noStrapNothingToShow() {
        let state = snapshot(bpm: nil, maximumBpm: maximum)
        #expect(state.heartRateBpm == nil)
        #expect(state.heartRateZone == nil)
    }

    /// Un pouls sans âge connu garde son chiffre et perd sa zone. Mieux vaut
    /// un pouls sans couleur qu'une couleur inventée.
    @Test("Sans profil, le pouls reste, la zone tombe")
    func withoutAProfileTheBeatStaysTheZoneGoes() {
        let state = snapshot(bpm: 152, maximumBpm: nil)
        #expect(state.heartRateBpm == 152)
        #expect(state.heartRateZone == nil)
    }

    @Test("Avec la ceinture et le profil, la zone est là")
    func withBothTheZoneIsThere() {
        #expect(snapshot(bpm: 152, maximumBpm: maximum).heartRateZone == 4)
    }

    /// Le pouls et la trace voyagent dans le même état, sous le même
    /// plafond de quatre kilooctets. Deux ajouts qui tiennent chacun ne
    /// tiennent pas forcément ensemble : on mesure les deux réunis.
    @Test("Le pouls et la trace tiennent ensemble sous la limite d'Apple")
    func theBeatAndTheTraceFitTogether() throws {
        let winding = (0..<2400).map { index -> GPSPoint in
            let t = Double(index)
            return GPSPoint(
                timestamp: Date(timeIntervalSince1970: t * 3),
                latitude: 48.85 + sin(t / 60) * 0.01 + t * 0.000004,
                longitude: 2.35 + cos(t / 37) * 0.008
            )
        }
        var state = snapshot(bpm: 152, maximumBpm: maximum)
        state.trace = TraceMiniature.make(from: winding)
        let encoded = try JSONEncoder().encode(state)
        #expect(encoded.count < 2048, Comment(rawValue: "\(encoded.count) octets"))
    }
}
