import Foundation
import Testing
@testable import MonCoachKit

@Suite("Parcours préparés")
struct PlannedRouteTests {

    /// Un carré d'environ un kilomètre de côté, en partant de Paris.
    private func square() -> [RoutePoint] {
        let base = 48.85
        let side = 1_000 / 111_320.0
        let east = 1_000 / (111_320.0 * cos(base * .pi / 180))
        return [
            RoutePoint(latitude: base, longitude: 2.35),
            RoutePoint(latitude: base + side, longitude: 2.35),
            RoutePoint(latitude: base + side, longitude: 2.35 + east),
            RoutePoint(latitude: base, longitude: 2.35 + east),
            RoutePoint(latitude: base, longitude: 2.35),
        ]
    }

    @Test("La longueur d'un parcours est la somme de ses côtés")
    func lengthAddsUp() {
        let meters = RoutePlanner.length(of: square())
        #expect(abs(meters - 4_000) < 20, "un carré d'un kilomètre de côté fait 4 km, pas \(meters)")
        #expect(RoutePlanner.length(of: []) == 0)
        #expect(RoutePlanner.length(of: [RoutePoint(latitude: 48.85, longitude: 2.35)]) == 0)
    }

    @Test("Un parcours qui revient au départ se sait en boucle")
    func loopKnowsItself() {
        let loop = PlannedRoute(name: "Tour du parc", points: square())
        #expect(loop.isLoop)

        var open = square()
        open.removeLast()
        #expect(!PlannedRoute(name: "Aller simple", points: open).isLoop)
    }

    @Test("La distance restante décroît le long du parcours")
    func remainingShrinksAsYouGo() {
        let route = square()
        let total = RoutePlanner.length(of: route)
        let atStart = RoutePlanner.remainingMeters(from: route[0], on: route)
        let atCorner = RoutePlanner.remainingMeters(from: route[2], on: route)
        #expect(abs((atStart ?? 0) - total) < 20, "au départ, tout reste à faire")
        #expect((atCorner ?? 0) < (atStart ?? 0), "au deuxième virage, il en reste moins")
        #expect(abs((atCorner ?? 0) - 2_000) < 30, "il reste deux côtés, soit 2 km")
    }

    @Test("Être au milieu d'une ligne droite n'est pas s'en écarter")
    func midSegmentIsOnRoute() {
        // Deux points espacés d'un kilomètre : le milieu est sur le tracé,
        // même s'il est loin des deux sommets.
        let line = [
            RoutePoint(latitude: 48.85, longitude: 2.35),
            RoutePoint(latitude: 48.85 + 1_000 / 111_320.0, longitude: 2.35),
        ]
        let middle = RoutePoint(latitude: 48.85 + 500 / 111_320.0, longitude: 2.35)
        let deviation = RoutePlanner.deviation(of: middle, from: line) ?? .infinity
        #expect(deviation < 5, "écart mesuré : \(deviation) m — le point est sur la droite")
        #expect(!RoutePlanner.isOffRoute(middle, from: line))
    }

    @Test("Cent mètres à côté, c'est hors parcours ; dix mètres, non")
    func offRouteHasAThreshold() {
        let line = [
            RoutePoint(latitude: 48.85, longitude: 2.35),
            RoutePoint(latitude: 48.86, longitude: 2.35),
        ]
        let metersPerDegreeLon = 111_320.0 * cos(48.855 * .pi / 180)
        let tenMetresAside = RoutePoint(latitude: 48.855, longitude: 2.35 + 10 / metersPerDegreeLon)
        let hundredAside = RoutePoint(latitude: 48.855, longitude: 2.35 + 100 / metersPerDegreeLon)
        #expect(!RoutePlanner.isOffRoute(tenMetresAside, from: line))
        #expect(RoutePlanner.isOffRoute(hundredAside, from: line))
    }

    @Test("Le temps prévu suit l'allure, et refuse l'impossible")
    func estimatedTimeFollowsPace() {
        #expect(RoutePlanner.estimatedSeconds(meters: 10_000, paceSecondsPerKm: 300) == 3_000)
        #expect(RoutePlanner.estimatedSeconds(meters: 0, paceSecondsPerKm: 300) == nil)
        #expect(RoutePlanner.estimatedSeconds(meters: 10_000, paceSecondsPerKm: 0) == nil)
    }

    @Test("Une trace amincie garde son début et sa fin")
    func thinningKeepsTheEnds() {
        let many = (0..<2_000).map {
            RoutePoint(latitude: 48.85 + Double($0) / 111_320.0, longitude: 2.35)
        }
        let thin = RoutePlanner.thinned(many, limit: 100)
        #expect(thin.count <= 101)
        #expect(thin.first == many.first)
        #expect(thin.last == many.last, "la fin d'un parcours est ce qu'on ne peut pas perdre")
    }

    @Test("Une sortie déjà courue redevient un parcours, un point posé par erreur non")
    func routeFromActivity() {
        let start = Date(timeIntervalSince1970: 1_700_000_000)
        let points = (0..<400).map {
            GPSPoint(
                timestamp: start.addingTimeInterval(Double($0) * 5),
                latitude: 48.85 + Double($0) * 10 / 111_320.0,
                longitude: 2.35,
                altitude: 35
            )
        }
        let activity = TraceAnalysis.summarise(rawPoints: points, sport: .trail, type: .long)
        let route = RoutePlanner.route(from: activity, named: "Le tour du lac")
        #expect(route?.sport == .trail, "un parcours de trail ne se propose pas à un cycliste")
        #expect((route?.meters ?? 0) > 3_000)

        let tiny = ActivityLog(startedAt: start, type: .easy, points: [], meters: 0, duration: 0, elevationGain: 0)
        #expect(RoutePlanner.route(from: tiny, named: "Rien") == nil)
    }
}

@Suite("Parcours en GPX")
struct RouteGPXTests {

    @Test("Un parcours exporté se relit à l'identique")
    func roundTrip() throws {
        let route = PlannedRoute(
            name: "Boucle du canal",
            sport: .ride,
            points: [
                RoutePoint(latitude: 48.8566, longitude: 2.3522),
                RoutePoint(latitude: 48.8600, longitude: 2.3600),
                RoutePoint(latitude: 48.8650, longitude: 2.3700),
            ]
        )
        let document = GPX.document(for: route)
        #expect(document.contains("<rte>"), "un parcours prévu s'écrit en route, pas en trace")
        // La seule heure du fichier est celle du dessin, dans les
        // métadonnées : aucun point ne porte d'heure de passage, puisque
        // personne n'y est encore passé.
        #expect(document.components(separatedBy: "<time>").count == 2)
        #expect(!document.contains("<rtept lat=\"48.856600\" lon=\"2.352200\"><time>"))

        let read = try GPX.readRoute(document)
        #expect(read.points.count == 3)
        #expect(read.name == "Boucle du canal")
        #expect(read.sport == .ride)
        #expect(abs(read.points[0].latitude - 48.8566) < 0.00001)
    }

    @Test("Un parcours téléchargé en trace se lit quand même")
    func readsATrackAsARoute() throws {
        // Le cas courant : un parcours exporté par un planificateur, en
        // <trkpt> et sans horodatage. `read` le refuse à raison ; celui-ci
        // doit l'accepter.
        let document = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1"><trk><name>Col de la Faucille</name><trkseg>
        <trkpt lat="46.3700" lon="6.0200"><ele>1100</ele></trkpt>
        <trkpt lat="46.3750" lon="6.0250"><ele>1180</ele></trkpt>
        <trkpt lat="46.3800" lon="6.0300"><ele>1260</ele></trkpt>
        </trkseg></trk></gpx>
        """
        let read = try GPX.readRoute(document)
        #expect(read.points.count == 3)
        #expect(read.name == "Col de la Faucille")
        #expect(throws: GPX.ImportError.noUsablePoints) { _ = try GPX.read(document) }
    }

    @Test("Ce qui n'est pas un GPX est refusé, et un GPX vide aussi")
    func rejectsWhatItCannotRead() {
        #expect(throws: GPX.ImportError.notGPX) { _ = try GPX.readRoute("bonjour") }
        #expect(throws: GPX.ImportError.noUsablePoints) {
            _ = try GPX.readRoute("<gpx version=\"1.1\"></gpx>")
        }
    }

    @Test("L'import d'une activité reconnaît toujours son sport")
    func activityImportStillReadsSport() throws {
        // Le repli sur le sport a été déplacé dans une fonction partagée :
        // ce test verrouille que l'import d'activité n'a rien perdu.
        let document = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1"><trk><name>Sortie</name><type>cycling</type><trkseg>
        <trkpt lat="48.8500" lon="2.3500"><time>2026-05-01T08:00:00Z</time></trkpt>
        <trkpt lat="48.8510" lon="2.3500"><time>2026-05-01T08:00:20Z</time></trkpt>
        <trkpt lat="48.8520" lon="2.3500"><time>2026-05-01T08:00:40Z</time></trkpt>
        </trkseg></trk></gpx>
        """
        let imported = try GPX.read(document)
        #expect(imported.sport == .ride)
        #expect(imported.name == "Sortie")
    }
}

@Suite("Photos de sortie")
struct PhotoStoreTests {

    private func temporaryStore() -> PhotoStore {
        PhotoStore(
            directory: URL.temporaryDirectory.appending(path: "stride-photos-\(UUID().uuidString)")
        )
    }

    @Test("Une photo rangée se relit, et s'efface")
    func savesAndReads() throws {
        let store = temporaryStore()
        defer { try? FileManager.default.removeItem(at: store.directory) }

        let bytes = Data((0..<512).map { UInt8($0 % 251) })
        let id = try store.save(bytes)
        #expect(store.exists(id))
        #expect(store.data(for: id) == bytes)

        store.delete(id)
        #expect(!store.exists(id))
        #expect(store.data(for: id) == nil)
    }

    @Test("Un identifiant fabriqué à la main ne sort pas du dossier")
    func refusesToEscapeItsDirectory() {
        let store = temporaryStore()
        // Le cas que la vérification existe pour arrêter : un état modifié
        // à la main dont l'identifiant remonte l'arborescence.
        let url = store.url(for: "../../../etc/passwd")
        #expect(!url.path.contains("etc/passwd"))
        #expect(url.deletingLastPathComponent().path == store.directory.path)
        #expect(store.data(for: "../../../etc/passwd") == nil)
    }

    @Test("Le ménage n'emporte que les orphelines")
    func pruneKeepsWhatIsReferenced() throws {
        let store = temporaryStore()
        defer { try? FileManager.default.removeItem(at: store.directory) }

        let kept = try store.save(Data([1, 2, 3]))
        let orphan = try store.save(Data([4, 5, 6]))
        #expect(store.storedIDs.count == 2)

        let removed = store.prune(keeping: [kept])
        #expect(removed == 1)
        #expect(store.exists(kept))
        #expect(!store.exists(orphan))
    }

    @Test("Une sortie d'avant les photos se relit sans photo")
    func oldActivitiesDecodeWithoutPhotos() throws {
        let activity = ActivityLog(
            startedAt: Date(timeIntervalSince1970: 1_700_000_000),
            type: .easy, meters: 5_000, duration: 1_500, elevationGain: 20
        )
        let data = try StateStorage.encoder.encode(activity)
        var json = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        json.removeValue(forKey: "photoIDs")
        let stripped = try JSONSerialization.data(withJSONObject: json)
        let decoded = try StateStorage.decoder.decode(ActivityLog.self, from: stripped)
        #expect(decoded.photoIDs.isEmpty)
        #expect(decoded.meters == 5_000)
    }

    @Test("Le magasin attache une photo, la retire, et l'emporte avec la sortie")
    @MainActor
    func storeKeepsFilesAndStateTogether() throws {
        let name = UUID().uuidString
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-state-\(name).json")
        )
        let photos = PhotoStore(
            directory: URL.temporaryDirectory.appending(path: "stride-photos-\(name)")
        )
        defer {
            try? FileManager.default.removeItem(at: storage.url)
            try? FileManager.default.removeItem(at: photos.directory)
        }
        let store = CoachStore(storage: storage, photos: photos)
        let activity = ActivityLog(
            startedAt: Date(), type: .easy, meters: 8_000, duration: 2_400, elevationGain: 30
        )
        store.recordRun(activity)

        let id = try #require(store.addPhoto(Data([9, 9, 9]), to: activity.id))
        #expect(store.history.activities.first?.photoIDs == [id])
        #expect(photos.exists(id))

        let second = try #require(store.addPhoto(Data([7, 7, 7]), to: activity.id))
        store.removePhoto(id, from: activity.id)
        #expect(store.history.activities.first?.photoIDs == [second])
        #expect(!photos.exists(id), "la photo retirée doit quitter le disque aussi")

        // Supprimer la sortie emporte ce qui restait : personne ne pourrait
        // plus atteindre ces fichiers autrement.
        store.deleteRun(activity.id)
        #expect(!photos.exists(second))
    }
}

@Suite("Les parcours dans le magasin")
struct StoredRouteTests {

    @MainActor
    private func store(_ name: String = UUID().uuidString) -> CoachStore {
        CoachStore(
            storage: StateStorage(
                url: URL.temporaryDirectory.appending(path: "stride-routes-\(name).json")
            ),
            photos: PhotoStore(
                directory: URL.temporaryDirectory.appending(path: "stride-routes-photos-\(name)")
            )
        )
    }

    private func line(kilometres: Double) -> [RoutePoint] {
        [
            RoutePoint(latitude: 48.85, longitude: 2.35),
            RoutePoint(latitude: 48.85 + kilometres * 1_000 / 111_320.0, longitude: 2.35),
        ]
    }

    @Test("Deux points posés par erreur ne font pas un parcours")
    @MainActor
    func tooShortIsRefused() {
        let store = store()
        #expect(!store.saveRoute(PlannedRoute(name: "Rien", points: line(kilometres: 0.1))))
        #expect(store.routes.isEmpty)
        #expect(store.saveRoute(PlannedRoute(name: "Le tour", points: line(kilometres: 3))))
        #expect(store.routes.count == 1)
    }

    @Test("Un parcours enregistré deux fois se remplace au lieu de se doubler")
    @MainActor
    func savingTwiceReplaces() {
        let store = store()
        var route = PlannedRoute(name: "Boucle", points: line(kilometres: 5))
        #expect(store.saveRoute(route))
        route.points.append(RoutePoint(latitude: 48.90, longitude: 2.36))
        #expect(store.saveRoute(route))
        #expect(store.routes.count == 1)
        #expect(store.routes.first?.points.count == 3)

        store.renameRoute(route.id, to: "Boucle du soir")
        #expect(store.routes.first?.name == "Boucle du soir")
        store.renameRoute(route.id, to: "")
        #expect(store.routes.first?.name == "Boucle du soir", "un nom vide n'est pas un nom")

        store.deleteRoute(route.id)
        #expect(store.routes.isEmpty)
    }

    @Test("Un parcours de vélo ne se propose pas à un coureur")
    @MainActor
    func routesAreFilteredBySport() {
        let store = store()
        #expect(store.saveRoute(PlannedRoute(name: "Le col", sport: .ride, points: line(kilometres: 20))))
        #expect(store.saveRoute(PlannedRoute(name: "Le parc", sport: .run, points: line(kilometres: 5))))
        #expect(store.routes(for: .run).map(\.name) == ["Le parc"])
        #expect(store.routes(for: .ride).map(\.name) == ["Le col"])
        // Ce qui se marche se court : un parcours de course sert aussi en
        // randonnée, et l'inverse.
        #expect(store.routes(for: .hike).map(\.name) == ["Le parc"])
    }

    @Test("Un GPX importé comme parcours n'entre pas dans l'historique")
    @MainActor
    func importedRouteIsNotAnActivity() throws {
        let store = store()
        let document = """
        <?xml version="1.0" encoding="UTF-8"?>
        <gpx version="1.1"><rte><name>Le tour du lac</name>
        <rtept lat="45.9000" lon="6.1300"></rtept>
        <rtept lat="45.9200" lon="6.1400"></rtept>
        <rtept lat="45.9400" lon="6.1500"></rtept>
        </rte></gpx>
        """
        let route = try #require(try store.importRouteGPX(document, named: "Sans nom"))
        #expect(route.name == "Le tour du lac")
        #expect(store.routes.count == 1)
        #expect(store.history.activities.isEmpty, "un parcours prévu n'est pas une sortie faite")
    }
}
