import Foundation
import Testing

/// Ce que le bundle de la montre doit porter pour se lancer.
///
/// Pourquoi ces tests existent
/// ...........................
/// watchOS refuse de lancer une application dont l'Info.plist ne déclare
/// pas `WKApplication`. Le refus est silencieux du point de vue du dépôt :
/// le projet compile, l'archive part, TestFlight accepte, l'icône apparaît
/// sur le poignet — et l'application meurt à l'ouverture. Aucun journal ne
/// remonte tant qu'un testeur n'envoie pas un retour depuis l'appareil.
///
/// Une première tentative avait posé la clé en réglage de build,
/// `INFOPLIST_KEY_WKApplication`. Xcode ne traduit en clés d'Info.plist
/// qu'une liste fermée de réglages `INFOPLIST_KEY_…` et ignore le reste
/// sans un mot : le build est reparti vert, sans la clé, et a planté
/// exactement comme avant.
///
/// Le seul endroit sûr est donc le fichier lui-même — et le seul moyen
/// d'en être sûr est de le lire. Ces tests tournent sur Linux, à chaque
/// poussée, pour trois lignes qui coûtent un build TestFlight quand elles
/// manquent.
@Suite("Le bundle de la montre")
struct WatchBundleTests {

    private var watchInfoPlist: [String: Any] {
        get throws {
            let path = URL(filePath: #filePath)
                .deletingLastPathComponent()  // MonCoachKitTests
                .deletingLastPathComponent()  // Tests
                .deletingLastPathComponent()  // MonCoachKit
                .deletingLastPathComponent()  // ios
                .appending(path: "MonCoach/MonCoachWatch-Info.plist")
            let data = try Data(contentsOf: path)
            let parsed = try PropertyListSerialization.propertyList(
                from: data, options: [], format: nil
            )
            return parsed as? [String: Any] ?? [:]
        }
    }

    @Test("WKApplication, sans quoi watchOS refuse de lancer l'application")
    func theKeyThatMakesTheWatchLaunch() throws {
        #expect(try watchInfoPlist["WKApplication"] as? Bool == true)
    }

    @Test("La montre dit de quel téléphone elle est la compagne")
    func theCompanionIsNamed() throws {
        #expect(
            try watchInfoPlist["WKCompanionAppBundleIdentifier"] as? String
                == "com.maxlestage.fitnesscoach"
        )
    }

    /// Sans « workout-processing », la session d'entraînement est
    /// interrompue dès que l'application quitte l'avant-plan, c'est-à-dire
    /// dès que le poignet baisse. Et le mode doit être dans un tableau : le
    /// réglage de build équivalent en produisait une chaîne, que watchOS ne
    /// lit pas.
    @Test("L'entraînement continue poignet baissé")
    func theWorkoutSurvivesTheWristDropping() throws {
        let modes = try watchInfoPlist["WKBackgroundModes"] as? [String]
        #expect(modes == ["workout-processing"])
    }

    /// Le revers de la leçon : si quelqu'un remet un jour ces clés en
    /// réglage de build, ce test le dit avant qu'un build ne parte.
    @Test("Les clés de la montre ne repassent pas en réglages de build")
    func theKeysStayInTheFile() throws {
        let project = URL(filePath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appending(path: "MonCoach/MonCoach.xcodeproj/project.pbxproj")
        let text = try String(contentsOf: project, encoding: .utf8)
        #expect(!text.contains("INFOPLIST_KEY_WKApplication"))
        #expect(!text.contains("INFOPLIST_KEY_WKBackgroundModes"))
    }
}
