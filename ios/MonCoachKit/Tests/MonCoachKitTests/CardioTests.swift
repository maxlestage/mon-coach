import Foundation
import Testing
@testable import MonCoachKit

@Suite("Allure corrigée et cardio")
struct CardioTests {

    // MARK: - Allure corrigée du dénivelé

    @Test("Sur du plat, la correction ne change rien")
    func flatIsUntouched() {
        #expect(abs(GradeAdjustment.energyCostFactor(gradePercent: 0) - 1.0) < 0.01)
        #expect(abs(GradeAdjustment.flatEquivalentPace(paceSecondsPerKm: 300, gradePercent: 0) - 300) < 3)
    }

    @Test("La montée coûte, et de plus en plus cher")
    func uphillCostsProgressively() {
        let five = GradeAdjustment.energyCostFactor(gradePercent: 5)
        let ten = GradeAdjustment.energyCostFactor(gradePercent: 10)
        let twenty = GradeAdjustment.energyCostFactor(gradePercent: 20)
        #expect(five > 1.2 && five < 1.5, Comment(rawValue: "5 % → \(five)"))
        #expect(ten > 1.5 && ten < 2.1, Comment(rawValue: "10 % → \(ten)"))
        #expect(twenty > ten, "le coût croît avec la pente")
        // Et 6:00/km dans une côte à 10 % vaut nettement mieux que 6:00.
        let corrected = GradeAdjustment.flatEquivalentPace(paceSecondsPerKm: 360, gradePercent: 10)
        #expect(corrected < 240, Comment(rawValue: "6:00 à 10 % → \(Int(corrected)) s/km équivalent"))
    }

    @Test("Le minimum du coût n'est pas à plat mais en descente douce")
    func gentleDownhillHelps() {
        let gentle = GradeAdjustment.energyCostFactor(gradePercent: -10)
        let steep = GradeAdjustment.energyCostFactor(gradePercent: -30)
        #expect(gentle < 1.0, "une descente douce aide")
        #expect(steep > gentle, "une descente raide se paie en freinage")
    }

    @Test("Hors du domaine mesuré, on borne au lieu d'extrapoler")
    func outsideTheDomainIsClamped() {
        let atLimit = GradeAdjustment.energyCostFactor(gradePercent: 45)
        let beyond = GradeAdjustment.energyCostFactor(gradePercent: 80)
        #expect(atLimit == beyond, "au-delà de ±45 %, la valeur est celle de la borne")
        #expect(GradeAdjustment.energyCostFactor(gradePercent: -80)
                == GradeAdjustment.energyCostFactor(gradePercent: -45))
    }

    @Test("À effort constant, la correction retrouve l'allure plate")
    func isoEffortRecoversFlatPace() throws {
        // L'invariant physique de la correction : un athlète qui monte et
        // descend à puissance constante doit ressortir avec l'allure qu'il
        // aurait tenue sur du plat à cette même puissance. On construit la
        // trace ainsi — vitesse divisée par le coût de la pente — et la
        // correction doit rendre l'allure plate de référence.
        let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let flatSpeed = 3.0  // 5:33/km sur plat
        var points: [GPSPoint] = []
        var seconds = 0.0
        for index in 0...400 {
            let distance = Double(index) * 5
            let uphill = distance <= 1_000
            let altitude = uphill ? 100 + distance * 0.10 : 200 - (distance - 1_000) * 0.10
            if index > 0 {
                let factor = GradeAdjustment.energyCostFactor(gradePercent: uphill ? 10 : -10)
                seconds += 5 / (flatSpeed / factor)
            }
            points.append(GPSPoint(
                timestamp: start.addingTimeInterval(seconds),
                latitude: 48.85,
                longitude: 2.35 + distance / metersPerDegree,
                altitude: altitude
            ))
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.trail.filter)
        let corrected = try #require(GradeAdjustment.flatEquivalentPace(of: trace))
        let flatPace = 1_000 / flatSpeed
        // Le lissage d'altitude adoucit les pentes aux transitions : quelques
        // pour cent d'écart sont le prix du lissage, pas un défaut.
        #expect(abs(corrected - flatPace) < flatPace * 0.06,
                Comment(rawValue: "corrigée \(Int(corrected)) s/km, attendu \(Int(flatPace))"))
        // Et l'allure brute, elle, est bien plus lente : la montée à
        // puissance constante coûte plus de temps que la descente n'en rend.
        #expect(trace.paceSecondsPerKm > corrected * 1.1)
    }

    @Test("À vitesse constante, une boucle vallonnée ressort plus lente — et c'est voulu")
    func constantSpeedLoopReadsSlower() throws {
        // Contre-intuitif mais physiquement juste : courir le vallonné à
        // vitesse constante est une mauvaise stratégie de puissance — on
        // sous-exploite la descente, dont l'aide (coût ×0,6) est plus faible
        // que la pénalité de la montée (coût ×1,66). L'équivalent-effort est
        // donc plus lent que la moyenne brute. Ce test fige ce comportement
        // pour qu'un « correctif » bien intentionné ne le casse pas.
        let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var points: [GPSPoint] = []
        for index in 0...400 {
            let distance = Double(index) * 5
            let altitude = distance <= 1_000 ? 100 + distance * 0.10 : 200 - (distance - 1_000) * 0.10
            points.append(GPSPoint(
                timestamp: start.addingTimeInterval(distance / 3.0),
                latitude: 48.85,
                longitude: 2.35 + distance / metersPerDegree,
                altitude: altitude
            ))
        }
        let trace = TraceAnalysis.clean(points, filter: Sport.trail.filter)
        let corrected = try #require(GradeAdjustment.flatEquivalentPace(of: trace))
        #expect(corrected > trace.paceSecondsPerKm)
    }

    // MARK: - Cardio

    @Test("La fréquence maximale estimée suit Tanaka, pas le folklore")
    func maximumFollowsTanaka() {
        #expect(abs(HeartRateAnalysis.estimatedMaximum(age: 30) - 187) < 0.5)
        #expect(abs(HeartRateAnalysis.estimatedMaximum(age: 50) - 173) < 0.5)
    }

    @Test("Les cinq zones couvrent tout, sans trou ni chevauchement")
    func zonesAreContiguous() {
        let zones = HeartRateAnalysis.zones(maximumBpm: 185)
        #expect(zones.count == 5)
        for index in 1..<zones.count {
            #expect(zones[index].range.lowerBound == zones[index - 1].range.upperBound)
        }
        #expect(zones[0].range.lowerBound == 92.5)
    }

    @Test("Le temps par zone se répartit comme l'effort")
    func timePerZoneFollowsTheEffort() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        // 10 min en endurance (120 bpm), 5 min au seuil (160 bpm), max 185.
        var samples: [HeartRateSample] = []
        for second in stride(from: 0, to: 600, by: 5) {
            samples.append(HeartRateSample(timestamp: start.addingTimeInterval(Double(second)), bpm: 120))
        }
        for second in stride(from: 600, to: 900, by: 5) {
            samples.append(HeartRateSample(timestamp: start.addingTimeInterval(Double(second)), bpm: 160))
        }
        let perZone = HeartRateAnalysis.secondsPerZone(samples: samples, maximumBpm: 185)
        let z2 = try #require(perZone[2])  // 120/185 = 65 %
        let z4 = try #require(perZone[4])  // 160/185 = 86 %
        #expect(abs(z2 - 600) < 15)
        #expect(abs(z4 - 300) < 15)
        #expect(perZone[5] == nil)
    }

    @Test("Un trou de capteur ne verse pas dix minutes dans une zone")
    func sensorGapsAreCapped() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let samples = [
            HeartRateSample(timestamp: start, bpm: 150),
            // Dix minutes de silence — manche qui frotte, capteur perdu.
            HeartRateSample(timestamp: start.addingTimeInterval(600), bpm: 152),
        ]
        let perZone = HeartRateAnalysis.secondsPerZone(samples: samples, maximumBpm: 185)
        let total = perZone.values.reduce(0, +)
        #expect(total <= 30, Comment(rawValue: "le trou doit être plafonné, pas versé (\(Int(total)) s)"))
    }

    @Test("La charge d'entraînement pondère par la zone")
    func loadWeighsByZone() {
        // 30 min en zone 2 contre 30 min en zone 4 : la seconde pèse double.
        let easy = HeartRateAnalysis.trainingLoad(secondsPerZone: [2: 1_800])
        let hard = HeartRateAnalysis.trainingLoad(secondsPerZone: [4: 1_800])
        #expect(easy == 60)
        #expect(hard == 120)
    }

    @Test("Les battements impossibles n'entrent pas dans la moyenne")
    func garbageBpmIsExcluded() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let samples = [
            HeartRateSample(timestamp: start, bpm: 150),
            HeartRateSample(timestamp: start.addingTimeInterval(5), bpm: 0),     // capteur muet
            HeartRateSample(timestamp: start.addingTimeInterval(10), bpm: 300),  // artefact
            HeartRateSample(timestamp: start.addingTimeInterval(15), bpm: 152),
        ]
        #expect(abs(HeartRateAnalysis.average(samples: samples)! - 151) < 0.51)
        #expect(HeartRateAnalysis.average(samples: []) == nil)
    }

    @Test("Une activité avec cardio survit à l'aller-retour disque")
    func heartRateRoundTrips() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000.25)
        let log = ActivityLog(
            startedAt: start, sport: .run, type: .easy,
            meters: 5_000, duration: 1_500, elevationGain: 10,
            heartRate: [HeartRateSample(timestamp: start, bpm: 147.5)]
        )
        let back = try StateStorage.decoder.decode(
            ActivityLog.self, from: StateStorage.encoder.encode(log)
        )
        #expect(back.heartRate == log.heartRate)

        // Et un fichier d'avant le cardio se décode toujours.
        let json = """
        {"duration":2600,"elevationGain":20,"id":"5B9A2C10-0000-4000-8000-000000000001",\
        "meters":8000,"points":[],"splits":[],"startedAt":"2023-11-14T22:13:20Z","type":"easy"}
        """
        let old = try StateStorage.decoder.decode(ActivityLog.self, from: Data(json.utf8))
        #expect(old.heartRate.isEmpty)
    }
}
