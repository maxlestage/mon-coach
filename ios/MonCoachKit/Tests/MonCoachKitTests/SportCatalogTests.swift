import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le catalogue des sports")
struct SportCatalogTests {

    @Test("Le catalogue est large, et chaque sport se range quelque part")
    func everySportHasAFamily() {
        #expect(Sport.allCases.count >= 40, "\(Sport.allCases.count) sports : trop peu pour ce qu'on fait vraiment")
        let placed = SportFamily.allCases.flatMap(\.sports)
        #expect(Set(placed) == Set(Sport.allCases), "un sport n'appartient à aucune famille, ou à deux")
        #expect(placed.count == Sport.allCases.count, "un sport est rangé deux fois")
        for family in SportFamily.allCases {
            #expect(!family.sports.isEmpty, Comment(rawValue: "\(family.rawValue) est vide"))
        }
    }

    @Test("Chaque sport sait se nommer, s'afficher et se mesurer")
    func everySportIsComplete() {
        for sport in Sport.allCases {
            #expect(sport.label.isComplete, Comment(rawValue: sport.rawValue))
            #expect(!sport.symbolName.isEmpty, Comment(rawValue: sport.rawValue))
            // Le Compendium ne descend pas sous 1,5 MET (assis, immobile) et
            // ne dépasse pas 16 pour ce qu'un amateur pratique une heure.
            #expect((2.0...16.0).contains(sport.baseMET), Comment(rawValue: "\(sport.rawValue) : \(sport.baseMET) MET"))
            #expect((1.0...9.0).contains(sport.defaultIntensity), Comment(rawValue: sport.rawValue))
            #expect(sport.filter.maxSpeed > 0, Comment(rawValue: sport.rawValue))
        }
        for family in SportFamily.allCases {
            #expect(family.label.isComplete, Comment(rawValue: family.rawValue))
        }
    }

    /// Siri construit sa liste de sports à partir de ces noms. Deux sports
    /// qui se nomment pareil y apparaissent en double, et rien ne dit lequel
    /// on a choisi — ni à l'athlète, ni à l'application.
    @Test("Deux sports ne portent jamais le même nom")
    func sportNamesAreUnique() {
        for language in Language.allCases {
            var seen: [String: Sport] = [:]
            for sport in Sport.allCases {
                let name = sport.label[language].lowercased()
                if let other = seen[name] {
                    Issue.record("\(sport.rawValue) et \(other.rawValue) se nomment tous deux « \(name) » en \(language.rawValue)")
                }
                seen[name] = sport
            }
        }
    }

    @Test("Les cinq sports d'origine gardent leur identifiant et leurs seuils")
    func historyStillReadsTheSameWay() {
        // Un historique déjà enregistré porte ces rangs-là. Les changer
        // ferait relire toutes les sorties passées comme des courses.
        #expect(Sport(rawValue: "run") == .run)
        #expect(Sport(rawValue: "trail") == .trail)
        #expect(Sport(rawValue: "ride") == .ride)
        #expect(Sport(rawValue: "walk") == .walk)
        #expect(Sport(rawValue: "hike") == .hike)

        #expect(Sport.run.filter == TraceFilter())
        #expect(Sport.ride.filter.maxSpeed == 30)
        #expect(Sport.hike.filter.minSegmentMeters == 0.2)
        #expect(Sport.trail.filter.maxHorizontalAccuracy == 40)
    }

    @Test("Seule la course à pied nourrit le plan de course")
    func onlyRunningFeedsThePlan() {
        let feeding = Sport.allCases.filter(\.feedsRunningPlan)
        #expect(Set(feeding) == [.run, .trail, .treadmill], "\(feeding.map(\.rawValue))")
    }

    @Test("Ce qui ne se déplace pas ne prétend pas à une allure")
    func stationarySportsHaveNoPace() {
        for sport in Sport.allCases where !sport.tracksLocation {
            #expect(sport.readout == SpeedReadout.none, Comment(rawValue: sport.rawValue))
            #expect(sport.mode == .stationary, Comment(rawValue: sport.rawValue))
            #expect(
                Format.speedOrPace(sport: sport, meters: 5_000, seconds: 1_800, unit: .metric) == "—",
                Comment(rawValue: sport.rawValue)
            )
        }
        // Et l'inverse : tout ce qui se déplace sait dire à quelle vitesse.
        for sport in Sport.allCases where sport.tracksLocation {
            #expect(sport.readout != SpeedReadout.none, Comment(rawValue: sport.rawValue))
        }
    }

    @Test("Sur l'eau, le GPS n'invente pas de dénivelé")
    func waterHasNoClimb() {
        // Dix minutes de paddle sur une mer plate, avec le bruit d'altitude
        // qu'un GPS produit réellement au-dessus de l'eau : une dérive lente
        // de quelques mètres, qui monte et redescend sur une demi-minute.
        // Un bruit point à point serait le mauvais test — le lissage le
        // mange, et l'assertion passerait sans rien prouver.
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        var points: [GPSPoint] = []
        for index in 0..<600 {
            points.append(
                GPSPoint(
                    timestamp: start.addingTimeInterval(Double(index)),
                    latitude: 43.5 + Double(index) * 0.00002,
                    longitude: 7.0,
                    altitude: 4 * sin(Double(index) / 5),
                    horizontalAccuracy: 8,
                    verticalAccuracy: 12
                )
            )
        }
        let paddle = TraceAnalysis.clean(points, filter: Sport.standUpPaddle.filter)
        let run = TraceAnalysis.clean(points, filter: Sport.run.filter)
        #expect(paddle.elevationGain == 0, "le paddle a gravi \(Int(paddle.elevationGain)) m sur l'eau")
        #expect(run.elevationGain > 0, "le test ne veut rien dire si le bruit ne produit rien à pied")
        #expect(paddle.meters > 1_000, "la distance, elle, doit rester mesurée")
    }

    @Test("Une heure de sport sans distance coûte quand même des calories")
    func timeBasedSportsStillCost() {
        let hour: TimeInterval = 3_600
        let yoga = TraceMath.energyKcal(
            sport: .yoga, meters: 0, movingSeconds: hour, elevationGain: 0, weightKg: 75
        )
        let hiit = TraceMath.energyKcal(
            sport: .hiit, meters: 0, movingSeconds: hour, elevationGain: 0, weightKg: 75
        )
        // 2,5 MET × 75 kg × 1 h ≈ 188 kcal ; 8 MET ≈ 600.
        #expect(abs(yoga - 187.5) < 1)
        #expect(abs(hiit - 600) < 1)
        #expect(hiit > yoga * 2, "une heure de fractionné doit coûter bien plus qu'une heure de yoga")
        // Sans durée, rien n'est inventé.
        #expect(TraceMath.energyKcal(
            sport: .yoga, meters: 0, movingSeconds: 0, elevationGain: 0, weightKg: 75
        ) == 0)
    }

    @Test("La dépense d'une sortie tracée reste celle de son sport")
    func tracedSportsKeepTheirModel() {
        // Dix kilomètres en une heure : à pied c'est une course, à vélo
        // c'est une balade, et les deux ne coûtent pas la même chose.
        let onFoot = TraceMath.energyKcal(
            sport: .run, meters: 10_000, movingSeconds: 3_600, elevationGain: 0, weightKg: 75
        )
        let onBike = TraceMath.energyKcal(
            sport: .ride, meters: 10_000, movingSeconds: 3_600, elevationGain: 0, weightKg: 75
        )
        #expect(onFoot > onBike * 1.5, "à pied \(Int(onFoot)) kcal, à vélo \(Int(onBike))")
    }

    @Test("La charge d'une heure suit l'intensité du sport")
    func loadFollowsTheSport() {
        func activity(_ sport: Sport) -> ActivityLog {
            ActivityLog(
                startedAt: Date(), sport: sport, type: .easy,
                meters: 0, duration: 3_600, elevationGain: 0
            )
        }
        let yoga = TrainingLoadEngine.intensityWeight(for: activity(.yoga))
        let hiit = TrainingLoadEngine.intensityWeight(for: activity(.hiit))
        let easyRun = TrainingLoadEngine.intensityWeight(for: activity(.run))
        #expect(yoga < easyRun)
        #expect(hiit > easyRun)
        // La course garde son intention : un fractionné pèse plus qu'un
        // footing, quel que soit le sport-frère.
        var intervals = activity(.run)
        intervals.type = .intervals
        #expect(TrainingLoadEngine.intensityWeight(for: intervals) > easyRun)
    }

    @Test("Un tapis de course compte dans le plan quand sa distance est connue")
    func treadmillCountsTowardWeeklyVolume() {
        let day = Date(timeIntervalSince1970: 1_780_000_000)
        // Le téléphone ne mesure rien sur un tapis : la distance vient de
        // l'écran de la machine, recopiée à la main. Sans elle, la séance
        // entre dans le plan à zéro kilomètre — et le plan, croyant la
        // semaine vide, baisserait le volume de quelqu'un qui s'est
        // pourtant entraîné.
        var history = TrainingHistory()
        history.activities = [
            ActivityLog(
                startedAt: day, sport: .treadmill, type: .easy,
                meters: 8_000, duration: 2_400, elevationGain: 0
            ),
            // Le rameur, lui, ne nourrit pas le plan de course : ses mètres
            // ne sont pas des mètres de course à pied.
            ActivityLog(
                startedAt: day, sport: .rowingMachine, type: .easy,
                meters: 10_000, duration: 2_400, elevationGain: 0
            ),
        ]
        #expect(history.runs.count == 1)
        #expect(history.weeklyRunMeters(endingOn: day) == 8_000)

        // Et l'allure de seuil ne se lit que sur du dehors mesuré : un
        // tapis n'a pas de vent, pas de virage et pas de GPS.
        var indoorTempo = history.activities[0]
        indoorTempo.type = .tempo
        history.activities = [indoorTempo]
        #expect(history.demonstratedThresholdPace() == nil)
    }

    @Test("Le matériel suit le sport, sans liste tenue deux fois")
    func gearFollowsTheSport() {
        #expect(Gear.Kind.shoes.sports.contains(.run))
        #expect(Gear.Kind.shoes.sports.contains(.hike))
        #expect(Gear.Kind.bike.sports.contains(.ride))
        #expect(Gear.Kind.bike.sports.contains(.mountainBike), "un VTT est un vélo")
        #expect(!Gear.Kind.bike.sports.contains(.skateboard), "un skateboard n'est pas un vélo")
        #expect(!Gear.Kind.shoes.sports.contains(.swim))
        for sport in Sport.allCases {
            for kind in sport.gearKinds {
                #expect(kind.sports.contains(sport), Comment(rawValue: sport.rawValue))
            }
        }
    }
}
