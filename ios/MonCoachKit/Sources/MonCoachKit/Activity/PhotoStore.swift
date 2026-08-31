import Foundation

/// Les photos des sorties, sur l'appareil et nulle part ailleurs.
///
/// Pourquoi ce type existe
/// -----------------------
/// Une sortie, ce n'est pas que des chiffres : c'est aussi le sommet, le
/// lever de soleil, le chien croisé au kilomètre huit. Strava l'a compris
/// avant tout le monde, et c'est ce qui fait qu'on rouvre une sortie de
/// l'an dernier.
///
/// Les images ne vont pas dans le fichier d'état. Celui-ci est relu en
/// entier à chaque lancement et réécrit à chaque geste : y coller des
/// photos en base64 ferait un fichier de cent mégaoctets, relu et réécrit
/// pour cocher une case de liste de courses. Chaque photo est donc un
/// fichier à part, et l'état ne garde que des identifiants.
///
/// Rien ne sort de l'appareil : pas de compte, pas de téléversement, pas de
/// vignette envoyée « pour l'aperçu ». Une photo de sortie dit où on était
/// et à quelle heure — c'est exactement la donnée qui ne doit jamais partir.
public struct PhotoStore: Sendable {

    public let directory: URL

    public init(directory: URL) {
        self.directory = directory
    }

    /// Le dossier des photos, à côté du fichier d'état.
    public static func applicationSupport(folderName: String = "photos") -> PhotoStore {
        let base = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? URL.temporaryDirectory
        return PhotoStore(directory: base.appending(path: folderName))
    }

    /// Range une image et rend son identifiant.
    ///
    /// L'appelant fournit déjà les octets compressés : la compression a
    /// besoin d'UIKit, qui n'existe pas ici — et ce fichier doit pouvoir se
    /// tester ailleurs que sur un iPhone.
    @discardableResult
    public func save(_ data: Data) throws -> String {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let id = UUID().uuidString
        try data.write(to: url(for: id), options: [.atomic])
        return id
    }

    /// Le fichier d'une photo.
    ///
    /// L'identifiant est vérifié plutôt que concaténé tel quel : il vient
    /// d'un fichier JSON sur le disque, et un identifiant fabriqué à la main
    /// contenant « ../ » désignerait un fichier hors du dossier. Un
    /// identifiant qui n'est pas un UUID ne désigne rien.
    public func url(for id: String) -> URL {
        guard UUID(uuidString: id) != nil else {
            return directory.appending(path: "invalide")
        }
        return directory.appending(path: "\(id).jpg")
    }

    public func data(for id: String) -> Data? {
        try? Data(contentsOf: url(for: id))
    }

    public func exists(_ id: String) -> Bool {
        FileManager.default.fileExists(atPath: url(for: id).path)
    }

    public func delete(_ id: String) {
        try? FileManager.default.removeItem(at: url(for: id))
    }

    /// Les identifiants des photos réellement présentes sur le disque.
    public var storedIDs: [String] {
        let names = (try? FileManager.default.contentsOfDirectory(atPath: directory.path)) ?? []
        return names
            .filter { $0.hasSuffix(".jpg") }
            .map { String($0.dropLast(4)) }
            .filter { UUID(uuidString: $0) != nil }
            .sorted()
    }

    /// Efface les photos que plus aucune sortie ne réclame.
    ///
    /// Sans ce ménage, supprimer une sortie de deux heures avec quinze
    /// photos libérerait deux kilo-octets d'état et laisserait trente
    /// mégaoctets d'images orphelines, invisibles et indestructibles.
    @discardableResult
    public func prune(keeping kept: Set<String>) -> Int {
        var removed = 0
        for id in storedIDs where !kept.contains(id) {
            delete(id)
            removed += 1
        }
        return removed
    }
}
