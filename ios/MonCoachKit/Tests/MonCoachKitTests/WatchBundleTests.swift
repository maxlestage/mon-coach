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

    private func plist(_ name: String) throws -> [String: Any] {
        let path = URL(filePath: #filePath)
            .deletingLastPathComponent()  // MonCoachKitTests
            .deletingLastPathComponent()  // Tests
            .deletingLastPathComponent()  // MonCoachKit
            .deletingLastPathComponent()  // ios
            .appending(path: "MonCoach/\(name)")
        let data = try Data(contentsOf: path)
        let parsed = try PropertyListSerialization.propertyList(
            from: data, options: [], format: nil
        )
        return parsed as? [String: Any] ?? [:]
    }

    private var watchInfoPlist: [String: Any] {
        get throws { try plist("MonCoachWatch-Info.plist") }
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
    ///
    /// On demande que le mode soit présent, pas qu'il soit seul : la liste
    /// s'est allongée depuis, et un test qui exige un tableau exact refuse
    /// les ajouts légitimes au lieu de garder ce qui compte.
    @Test("L'entraînement continue poignet baissé")
    func theWorkoutSurvivesTheWristDropping() throws {
        let modes = try watchInfoPlist["WKBackgroundModes"] as? [String]
        #expect(modes?.contains("workout-processing") == true)
    }

    /// Le second plantage de cette montre, et le plus cher : il ne tuait
    /// pas l'application au lancement mais à l'appui sur « Démarrer », ce
    /// qui laissait croire que le premier correctif avait marché.
    ///
    /// `LocationTracker` pose `allowsBackgroundLocationUpdates` pour
    /// suivre la trace écran éteint. Ce n'est pas un réglage mais une
    /// assertion : posée par une application dont le bundle ne déclare pas
    /// le mode d'arrière-plan, CoreLocation jette et l'application meurt.
    ///
    /// Le code ne la pose plus sans avoir lu le bundle — c'est ce qui
    /// empêche le plantage. Ce test garde l'autre moitié : que la
    /// déclaration soit là, pour que le suivi marche vraiment au lieu de
    /// s'arrêter silencieusement dès que le poignet baisse.
    ///
    /// Les deux applications sont vérifiées, parce que les deux partagent
    /// le même tracker : c'est cette communauté qui a fait voyager le
    /// défaut du téléphone — où il était déjà corrigé — jusqu'à la montre,
    /// où une exception l'avait rouvert.
    /// La clé est `UIBackgroundModes` des deux côtés, et c'est Apple qui
    /// l'a dit — en refusant le build 79 à l'envoi :
    ///
    ///     Validation failed. Invalid Info.plist value. The value for the
    ///     key 'WKBackgroundModes' in bundle …/MonCoachWatch.app is invalid.
    ///
    /// Les deux clés avaient été déclarées faute de source qui tranche.
    /// Celle-ci tranche.
    @Test(
        "Ce qui suit la position écran éteint le déclare",
        arguments: [
            ("MonCoachWatch-Info.plist", "UIBackgroundModes"),
            ("MonCoach/Info.plist", "UIBackgroundModes"),
        ]
    )
    func backgroundLocationIsDeclaredWhereItIsUsed(file: String, key: String) throws {
        let modes = try plist(file)[key] as? [String]
        #expect(
            modes?.contains("location") == true,
            Comment(rawValue: "\(file) → \(key) = \(modes ?? [])")
        )
    }

    /// La phrase qu'Apple montre quand l'application demande à suivre la
    /// position hors de l'avant-plan. Absente, la demande est refusée sans
    /// un mot.
    @Test("La montre explique pourquoi elle suit une sortie écran éteint")
    func theWatchExplainsBackgroundLocation() throws {
        let sentence = try watchInfoPlist["NSLocationAlwaysAndWhenInUseUsageDescription"] as? String
        #expect(sentence?.isEmpty == false)
    }

    /// Le revers du correctif précédent : « location » n'est pas une
    /// valeur de WKBackgroundModes, qui ne connaît que ses modes à lui.
    /// L'y remettre ne planterait pas au poignet — le code lit le bundle
    /// avant d'affirmer quoi que ce soit — mais ferait refuser l'envoi par
    /// Apple, après six minutes d'archive et un certificat consommé.
    @Test("La montre ne remet pas « location » là où Apple le refuse")
    func watchBackgroundModesStayWatchModes() throws {
        let modes = try watchInfoPlist["WKBackgroundModes"] as? [String] ?? []
        #expect(!modes.contains("location"), Comment(rawValue: "\(modes)"))
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
