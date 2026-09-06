import Foundation

/// Quelle version tourne sur cet appareil.
///
/// Ajouté après une conversation qu'aucun des deux camps ne pouvait
/// trancher : une fonction venait d'être livrée, le testeur ne la trouvait
/// pas, et personne n'avait le moyen de savoir si l'application installée
/// la contenait. Un numéro de build absent de l'écran ne coûte rien tant
/// que tout marche, et coûte une demi-journée le jour où quelque chose
/// manque.
///
/// Lu dans le bundle plutôt qu'écrit en dur : la CI pose le numéro de build
/// au moment de l'archive — c'est le numéro du run — et une constante
/// recopiée à la main aurait menti dès le build suivant.
enum Build {

    /// La version affichée sur l'App Store, par exemple « 1.0 ».
    static var version: String {
        string(for: "CFBundleShortVersionString") ?? "?"
    }

    /// Le numéro de build, celui que TestFlight affiche à côté.
    static var number: String {
        string(for: "CFBundleVersion") ?? "?"
    }

    /// « Version 1.0 (84) » — la forme qu'on peut lire à voix haute et
    /// recopier dans un message sans se tromper.
    static var stamp: String {
        "Version \(version) (\(number))"
    }

    private static func string(for key: String) -> String? {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
              !value.isEmpty
        else { return nil }
        return value
    }
}
