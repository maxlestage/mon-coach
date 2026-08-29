import Foundation

/// Lecture et écriture du format GPX 1.1.
///
/// C'est la contrepartie honnête d'un produit sans compte : les données de
/// l'athlète entrent et sortent dans le format que tout le monde parle —
/// montres, applications de sport, planificateurs d'itinéraires — sans
/// passer par personne. Un
/// produit qui garde tout sur l'appareil ET dans un format à lui serait une
/// prison avec de beaux principes.
public enum GPX {

    // MARK: - Écriture

    /// Une activité au format GPX 1.1, avec extensions cardio Garmin.
    ///
    /// L'extension `gpxtpx:hr` n'est pas du standard GPX mais c'est le
    /// dialecte que tous les outils lisent : un GPX « pur » perdrait le
    /// cardio en route.
    public static func document(for activity: ActivityLog) -> String {
        var lines: [String] = []
        lines.append(#"<?xml version="1.0" encoding="UTF-8"?>"#)
        lines.append(
            #"<gpx version="1.1" creator="Stride" xmlns="http://www.topografix.com/GPX/1/1" "#
            + #"xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">"#
        )
        lines.append("  <metadata><time>\(DateCoding.string(from: activity.startedAt))</time></metadata>")
        lines.append("  <trk>")
        lines.append("    <name>\(escape(trackName(for: activity)))</name>")
        lines.append("    <type>\(activity.sport.rawValue)</type>")
        lines.append("    <trkseg>")

        // Le cardio est apparié par horodatage, au plus proche dans une
        // fenêtre de cinq secondes : les deux capteurs n'échantillonnent
        // jamais au même rythme. Chaque battement n'est écrit qu'une fois —
        // le recopier sur chaque point voisin, comme le font certains
        // exports, triplait le nombre d'échantillons à la réimportation.
        let heart = activity.heartRate.sorted { $0.timestamp < $1.timestamp }
        var heartIndex = 0
        var lastWritten = -1
        for point in activity.points {
            var line = "      <trkpt lat=\"\(coordinate(point.latitude))\" lon=\"\(coordinate(point.longitude))\">"
            line += "<ele>\(String(format: "%.1f", point.altitude))</ele>"
            line += "<time>\(DateCoding.string(from: point.timestamp))</time>"
            while heartIndex + 1 < heart.count,
                  abs(heart[heartIndex + 1].timestamp.timeIntervalSince(point.timestamp))
                    <= abs(heart[heartIndex].timestamp.timeIntervalSince(point.timestamp)) {
                heartIndex += 1
            }
            if heartIndex < heart.count, heartIndex != lastWritten,
               abs(heart[heartIndex].timestamp.timeIntervalSince(point.timestamp)) <= 5 {
                lastWritten = heartIndex
                line += "<extensions><gpxtpx:TrackPointExtension>"
                    + "<gpxtpx:hr>\(Int(heart[heartIndex].bpm.rounded()))</gpxtpx:hr>"
                    + "</gpxtpx:TrackPointExtension></extensions>"
            }
            line += "</trkpt>"
            lines.append(line)
        }
        lines.append("    </trkseg>")
        lines.append("  </trk>")
        lines.append("</gpx>")
        return lines.joined(separator: "\n")
    }

    public static func trackName(for activity: ActivityLog) -> String {
        activity.note?.isEmpty == false
            ? activity.note!
            : "\(activity.sport.rawValue)-\(Int(activity.startedAt.timeIntervalSince1970))"
    }

    /// Six décimales : onze centimètres à l'équateur, en dessous du bruit du
    /// GPS. Plus de chiffres gonflerait le fichier sans rien dire de vrai.
    private static func coordinate(_ value: Double) -> String {
        String(format: "%.6f", value)
    }

    static func escape(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    // MARK: - Lecture

    /// Ce qu'un fichier GPX a livré.
    public struct Imported: Sendable, Equatable {
        public var points: [GPSPoint]
        public var heartRate: [HeartRateSample]
        public var name: String?
        /// Le sport déclaré par le fichier, s'il en déclare un de connu.
        public var sport: Sport?
    }

    public enum ImportError: Error, Equatable {
        case notGPX
        case noUsablePoints
    }

    /// Lit un GPX, d'où qu'il vienne.
    ///
    /// Un analyseur dédié plutôt que XMLParser de Foundation : celui-ci
    /// n'existe pas sur Linux dans swift-corelibs à l'identique, et le
    /// moteur doit se tester ici. Le format est balisé et plat, l'analyse
    /// séquentielle suffit — et un fichier hostile ne peut au pire que
    /// produire zéro point, jamais un plantage.
    public static func read(_ text: String) throws -> Imported {
        guard text.contains("<gpx") else { throw ImportError.notGPX }

        var points: [GPSPoint] = []
        var heart: [HeartRateSample] = []

        // Chaque <trkpt …> jusqu'à sa fermeture. Les fichiers réels mettent
        // parfois tout sur une ligne : on découpe sur la balise, pas sur la
        // ligne.
        let pieces = text.components(separatedBy: "<trkpt")
        for piece in pieces.dropFirst() {
            guard let end = piece.range(of: "</trkpt>") ?? piece.range(of: "/>") else { continue }
            let fragment = String(piece[..<end.lowerBound])
            guard let latitude = attribute("lat", in: fragment),
                  let longitude = attribute("lon", in: fragment),
                  latitude.isFinite, longitude.isFinite,
                  abs(latitude) <= 90, abs(longitude) <= 180
            else { continue }

            // Sans horodatage, un point ne sert ni l'allure ni le tri : on
            // le compte comme inutilisable plutôt que d'inventer un temps.
            guard let timeText = element("time", in: fragment),
                  let timestamp = try? DateCoding.date(from: timeText)
            else { continue }

            let elevation = element("ele", in: fragment).flatMap(Double.init) ?? 0
            points.append(GPSPoint(
                timestamp: timestamp,
                latitude: latitude,
                longitude: longitude,
                altitude: elevation.isFinite ? elevation : 0,
                // Un GPX ne transporte pas la précision : on déclare une
                // valeur moyenne plausible plutôt qu'une perfection fausse.
                horizontalAccuracy: 10,
                verticalAccuracy: 10
            ))
            if let bpmText = element("gpxtpx:hr", in: fragment) ?? element("hr", in: fragment),
               let bpm = Double(bpmText), bpm > 0, bpm < 260 {
                heart.append(HeartRateSample(timestamp: timestamp, bpm: bpm))
            }
        }

        guard points.count >= 2 else { throw ImportError.noUsablePoints }

        let name = element("name", in: text)
        let declaredType = element("type", in: text)?.lowercased()
        let sport = declaredType.flatMap { declared in
            Sport(rawValue: declared) ?? {
                // Les dialectes des autres exportateurs : « running » plutôt
                // que « run », « cycling » plutôt que « ride ». On reconnaît
                // sans exiger.
                switch declared {
                case "running", "run", "trail_running": Sport.run
                case "cycling", "biking", "ride": Sport.ride
                case "walking": Sport.walk
                case "hiking": Sport.hike
                default: nil
                }
            }()
        }
        return Imported(
            points: points.sorted { $0.timestamp < $1.timestamp },
            heartRate: heart,
            name: name,
            sport: sport
        )
    }

    private static func attribute(_ name: String, in fragment: String) -> Double? {
        guard let range = fragment.range(of: "\(name)=\"") else { return nil }
        let after = fragment[range.upperBound...]
        guard let close = after.firstIndex(of: "\"") else { return nil }
        return Double(after[..<close])
    }

    private static func element(_ name: String, in fragment: String) -> String? {
        guard let open = fragment.range(of: "<\(name)>"),
              let close = fragment.range(of: "</\(name)>", range: open.upperBound..<fragment.endIndex)
        else { return nil }
        return String(fragment[open.upperBound..<close.lowerBound])
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
