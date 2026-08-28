import Foundation
import Testing
@testable import MonCoachKit

private func sampleActivity() -> ActivityLog {
    let metersPerDegree = 111_320.0 * cos(48.85 * .pi / 180)
    let start = Date(timeIntervalSince1970: 1_700_000_000)
    var points: [GPSPoint] = []
    var heart: [HeartRateSample] = []
    for index in 0...300 {
        let seconds = Double(index) * 2
        points.append(GPSPoint(
            timestamp: start.addingTimeInterval(seconds),
            latitude: 48.85,
            longitude: 2.35 + seconds * 3 / metersPerDegree,
            altitude: 100 + Double(index) * 0.1
        ))
        if index % 3 == 0 {
            heart.append(HeartRateSample(timestamp: start.addingTimeInterval(seconds), bpm: 140 + Double(index % 20)))
        }
    }
    var log = TraceAnalysis.summarise(rawPoints: points, sport: .run, type: .easy)
    log.heartRate = heart
    return log
}

@Suite("GPX")
struct GPXTests {

    @Test("Une sortie exportée puis réimportée garde sa mesure")
    func roundTripKeepsTheMeasurement() throws {
        let original = sampleActivity()
        let document = GPX.document(for: original)
        let imported = try GPX.read(document)

        #expect(imported.points.count == original.points.count)
        #expect(imported.sport == .run)
        #expect(imported.heartRate.count == original.heartRate.count)

        // La mesure refaite sur les points réimportés doit être celle
        // d'origine — c'est ça, ne pas être une prison.
        let reanalysed = TraceAnalysis.summarise(rawPoints: imported.points, sport: .run, type: .easy)
        #expect(abs(reanalysed.meters - original.meters) < original.meters * 0.001)
        #expect(abs(reanalysed.duration - original.duration) < 1)
        // L'altitude est écrite au décimètre : le dénivelé y survit.
        #expect(abs(reanalysed.elevationGain - original.elevationGain) < 2)
    }

    @Test("Les horodatages sous la seconde survivent à l'export")
    func subSecondTimestampsSurvive() throws {
        let start = Date(timeIntervalSince1970: 1_700_000_000.5)
        let activity = ActivityLog(
            startedAt: start, sport: .run, type: .easy,
            points: [
                GPSPoint(timestamp: start, latitude: 48.85, longitude: 2.35),
                GPSPoint(timestamp: start.addingTimeInterval(0.5), latitude: 48.8501, longitude: 2.35),
            ],
            meters: 11, duration: 0.5, elevationGain: 0
        )
        let imported = try GPX.read(GPX.document(for: activity))
        #expect(imported.points[0].timestamp == start)
        #expect(imported.points[1].timestamp == start.addingTimeInterval(0.5))
    }

    @Test("Un GPX d'un autre outil se lit, dialecte compris")
    func foreignDialectsAreRead() throws {
        // Le style Strava : tout sur une ligne, type « running », hr Garmin.
        let foreign = """
        <?xml version="1.0" encoding="UTF-8"?><gpx version="1.1" creator="StravaGPX"><trk>\
        <name>Morning Run</name><type>running</type><trkseg>\
        <trkpt lat="45.7772" lon="4.8520"><ele>172.0</ele><time>2024-03-10T08:01:02Z</time>\
        <extensions><gpxtpx:TrackPointExtension><gpxtpx:hr>151</gpxtpx:hr>\
        </gpxtpx:TrackPointExtension></extensions></trkpt>\
        <trkpt lat="45.7773" lon="4.8521"><ele>172.4</ele><time>2024-03-10T08:01:07Z</time></trkpt>\
        </trkseg></trk></gpx>
        """
        let imported = try GPX.read(foreign)
        #expect(imported.points.count == 2)
        #expect(imported.sport == .run, "« running » est le dialecte Strava de « run »")
        #expect(imported.name == "Morning Run")
        #expect(imported.heartRate.first?.bpm == 151)
    }

    @Test("Un fichier hostile produit une erreur, jamais un plantage")
    func hostileFilesFailCleanly() {
        #expect(throws: GPX.ImportError.notGPX) { try GPX.read("PK\u{03}\u{04} pas du xml") }
        #expect(throws: GPX.ImportError.noUsablePoints) {
            try GPX.read("<gpx><trk><trkseg></trkseg></trk></gpx>")
        }
        // Coordonnées absurdes, NaN, sans horodatage : écartés un par un.
        let garbage = """
        <gpx><trk><trkseg>
        <trkpt lat="945.0" lon="4.85"><time>2024-03-10T08:01:02Z</time></trkpt>
        <trkpt lat="nan" lon="4.85"><time>2024-03-10T08:01:03Z</time></trkpt>
        <trkpt lat="45.77" lon="4.85"></trkpt>
        <trkpt lat="45.77" lon="4.85"><time>pas-une-date</time></trkpt>
        </trkseg></trk></gpx>
        """
        #expect(throws: GPX.ImportError.noUsablePoints) { try GPX.read(garbage) }
    }

    @Test("Les points arrivent triés même si le fichier ne l'est pas")
    func pointsAreSortedOnImport() throws {
        let unsorted = """
        <gpx><trk><trkseg>
        <trkpt lat="45.7773" lon="4.8521"><time>2024-03-10T08:01:07Z</time></trkpt>
        <trkpt lat="45.7772" lon="4.8520"><time>2024-03-10T08:01:02Z</time></trkpt>
        </trkseg></trk></gpx>
        """
        let imported = try GPX.read(unsorted)
        #expect(imported.points[0].timestamp < imported.points[1].timestamp)
    }

    @Test("Le nom est échappé à l'écriture : une note ne casse pas le fichier")
    func namesAreEscaped() throws {
        var activity = sampleActivity()
        activity.note = "Sortie <rapide> & humide"
        let document = GPX.document(for: activity)
        #expect(document.contains("Sortie &lt;rapide&gt; &amp; humide"))
        let imported = try GPX.read(document)
        #expect(imported.points.count == activity.points.count)
    }
}

@Suite("Import dans le magasin")
struct GPXStoreTests {

    // Le magasin vit sur l'acteur principal, comme les vues qui le lisent.
    @Test("Un GPX importé entre dans l'historique et compte pour les records")
    @MainActor
    func importedFilesJoinTheHistory() throws {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "gpx-import-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }
        let store = CoachStore(storage: storage)

        let document = GPX.document(for: sampleActivity())
        let imported = try store.importGPX(document)

        #expect(store.history.activities.count == 1)
        #expect(imported.meters > 1_500)
        #expect(imported.bestEfforts?.isEmpty == false, "les records se calculent à l'import")
        #expect(!imported.heartRate.isEmpty)

        // Et l'export de ce qui vient d'entrer reste lisible.
        let back = try GPX.read(store.exportGPX(imported))
        #expect(back.points.count == imported.points.count)
    }
}
