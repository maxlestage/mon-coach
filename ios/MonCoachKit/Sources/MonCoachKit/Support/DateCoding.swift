import Foundation

/// Comment les dates sont écrites et relues, partout dans le paquet.
///
/// Le format ISO 8601 sans fraction arrondit à la seconde. Sur une date de
/// création c'est indolore ; sur une trace GPS, c'est destructeur. Une montre
/// échantillonne à deux hertz : après un aller-retour sur le disque, un point
/// sur deux porte l'horodatage de son voisin, l'analyse voit un intervalle
/// nul et les jette comme « non croissants ». Mesuré : la moitié d'une trace
/// perdue, et un indicateur de rétention qui annonce 50 % de rejets alors que
/// le GPS n'y était pour rien.
///
/// L'écriture ajoute donc les millisecondes — la précision du format, et
/// largement au-delà de ce qu'un GPS échantillonne. La lecture accepte les
/// deux écritures : les fichiers déjà enregistrés n'ont pas de fraction, et
/// refuser de les lire mettrait tout l'historique de côté.
public enum DateCoding {

    /// Les fractions sont écrites, jamais devinées.
    static let withFractionalSeconds = Date.ISO8601FormatStyle(includingFractionalSeconds: true)
    /// L'écriture d'avant, encore lue.
    static let withoutFractionalSeconds = Date.ISO8601FormatStyle()

    public static func string(from date: Date) -> String {
        withFractionalSeconds.format(date)
    }

    public static func date(from string: String) throws -> Date {
        if let parsed = try? withFractionalSeconds.parse(string) { return parsed }
        return try withoutFractionalSeconds.parse(string)
    }

    /// Applique la stratégie à un encodeur JSON.
    public static func apply(to encoder: JSONEncoder) {
        encoder.dateEncodingStrategy = .custom { date, target in
            var container = target.singleValueContainer()
            try container.encode(string(from: date))
        }
    }

    /// Applique la stratégie à un décodeur JSON.
    public static func apply(to decoder: JSONDecoder) {
        decoder.dateDecodingStrategy = .custom { source in
            let container = try source.singleValueContainer()
            let text = try container.decode(String.self)
            do {
                return try date(from: text)
            } catch {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Date ISO 8601 illisible : \(text)"
                )
            }
        }
    }
}
