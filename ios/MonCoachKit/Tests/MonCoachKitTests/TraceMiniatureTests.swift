import Foundation
import Testing
@testable import MonCoachKit

/// La vignette de trace, celle que la Live Activity dessine.
///
/// Elle ne se regarde nulle part avant d'être sur un écran verrouillé : ni
/// Linux, ni la CI, ni un test ne savent l'afficher. Ce qu'on peut vérifier,
/// en revanche, c'est tout ce qui rendrait le dessin faux — une boucle
/// étirée, un nord en bas, un budget dépassé, un gribouillage pour trois
/// mètres d'errance. C'est ce que font ces tests.
@Suite("La vignette de trace")
struct TraceMiniatureTests {

    /// Une trace synthétique : `count` points répartis le long d'un chemin.
    private func trace(_ coordinates: [(Double, Double)]) -> [GPSPoint] {
        coordinates.enumerated().map { index, pair in
            GPSPoint(
                timestamp: Date(timeIntervalSince1970: Double(index) * 5),
                latitude: pair.0,
                longitude: pair.1
            )
        }
    }

    /// Un kilomètre vers le nord, en cent points.
    private var straightNorth: [GPSPoint] {
        trace((0..<100).map { (48.85 + Double($0) * 0.00009, 2.35) })
    }

    // MARK: - Ce qu'elle refuse de dessiner

    @Test("Une sortie qui n'a pas commencé ne dessine rien")
    func nothingToDraw() {
        #expect(TraceMiniature.make(from: []).isEmpty)
        #expect(TraceMiniature.make(from: trace([(48.85, 2.35)])).isEmpty)
    }

    /// Le cas qui a motivé le seuil : on ramène toujours le parcours à la
    /// taille du cadre, donc sans plancher, trois mètres de tremblement GPS
    /// à l'arrêt rempliraient la vignette d'un gribouillage plein cadre.
    @Test("Le tremblement du GPS à l'arrêt ne devient pas un parcours")
    func jitterIsNotARoute() {
        let jitter = trace((0..<60).map { index in
            let wobble = Double(index % 7) * 0.00001  // ~1 m
            return (48.85 + wobble, 2.35 + wobble)
        })
        #expect(TraceMiniature.make(from: jitter).isEmpty)
    }

    @Test("Passé cinquante mètres, il y a quelque chose à voir")
    func pastTheThresholdItDraws() {
        #expect(!TraceMiniature.make(from: straightNorth).isEmpty)
    }

    // MARK: - Ce qu'elle garde de la forme

    /// Une ligne droite se réduit à ses deux bouts : c'est tout ce qu'il y a
    /// à en dire, et les quatre-vingt-dix-huit points du milieu ne
    /// changeraient pas un pixel.
    @Test("Une ligne droite ne coûte que deux points")
    func aStraightLineCostsTwoPoints() {
        let miniature = TraceMiniature.make(from: straightNorth)
        #expect(miniature.count == 2)
    }

    /// Le contre-exemple de la ligne droite : les quatre angles d'un carré
    /// doivent survivre, sinon la boucle devient un trait.
    @Test("Les angles d'une boucle survivent")
    func cornersSurvive() {
        var path: [(Double, Double)] = []
        let step = 0.00009  // ~10 m
        for i in 0..<25 { path.append((48.85 + Double(i) * step, 2.35)) }
        for i in 0..<25 { path.append((48.85 + 24 * step, 2.35 + Double(i) * step)) }
        for i in 0..<25 { path.append((48.85 + Double(24 - i) * step, 2.35 + 24 * step)) }
        for i in 0..<25 { path.append((48.85, 2.35 + Double(24 - i) * step)) }

        let miniature = TraceMiniature.make(from: trace(path))
        // Quatre angles, un départ et une arrivée : jamais deux points, et
        // pas non plus les cent d'origine.
        #expect(miniature.count >= 4)
        #expect(miniature.count <= 12)
    }

    /// Le nord en haut. Sans le retournement, une sortie vers le nord
    /// descendrait sur l'écran — la trace serait juste et illisible.
    @Test("Le nord est en haut")
    func northIsUp() {
        let miniature = TraceMiniature.make(from: straightNorth)
        let points = miniature.points
        // Le premier point est au sud, donc en bas de l'écran : son y est
        // le plus grand.
        #expect(points.first!.y > points.last!.y)
    }

    /// La dernière position est celle que la vue marque d'un point.
    @Test("Le dernier point est là où l'athlète se trouve")
    func theLastPointIsWhereYouAre() {
        let miniature = TraceMiniature.make(from: straightNorth)
        #expect(miniature.current == miniature.points.last)
    }

    /// Un degré de longitude est plus court qu'un degré de latitude, et
    /// d'autant plus qu'on monte en latitude. Sans la correction, une boucle
    /// carrée arriverait aplatie sur l'écran.
    @Test("Une boucle carrée reste carrée, et ne s'étire pas en longitude")
    func aSquareStaysSquare() {
        // À 60° de latitude, un degré de longitude vaut la moitié d'un degré
        // de latitude : le cas est volontairement extrême.
        let latitude = 60.0
        let sideMeters = 300.0
        let dLat = sideMeters / 111_320
        let dLon = dLat / cos(latitude * .pi / 180)

        var path: [(Double, Double)] = []
        for i in 0..<20 { path.append((latitude, 10 + dLon * Double(i) / 19)) }
        for i in 0..<20 { path.append((latitude + dLat * Double(i) / 19, 10 + dLon)) }
        for i in 0..<20 { path.append((latitude + dLat, 10 + dLon * Double(19 - i) / 19)) }

        let points = TraceMiniature.make(from: trace(path)).points
        let width = points.map(\.x).max()! - points.map(\.x).min()!
        let height = points.map(\.y).max()! - points.map(\.y).min()!
        // Un carré : les deux côtés à cinq pour cent près, la quantification
        // sur un octet ne permettant pas mieux.
        #expect(abs(width - height) < 0.05, Comment(rawValue: "l=\(width) h=\(height)"))
    }

    @Test("Tout tient dans le cadre")
    func everythingFitsTheFrame() {
        let miniature = TraceMiniature.make(from: straightNorth)
        for point in miniature.points {
            #expect(point.x >= 0 && point.x <= 1)
            #expect(point.y >= 0 && point.y <= 1)
        }
    }

    /// Le défaut que la mesure a révélé, et qui ne se voyait sur aucun test
    /// de forme : un aller-retour se réduisait à deux points.
    ///
    /// Le premier et le dernier point sont au même endroit, et tout le
    /// parcours est aligné avec eux. Mesurée à la droite qui les porte, la
    /// distance de chaque point vaut zéro, le demi-tour compris — la sortie
    /// entière disparaissait. La moitié des sorties sont des aller-retours.
    @Test("Un aller-retour garde son demi-tour")
    func anOutAndBackKeepsItsTurn() {
        let path = (0..<900).map { index -> (Double, Double) in
            let along = index < 450 ? Double(index) : Double(900 - index)
            return (48.85 + along * 0.00002, 2.35)
        }
        let miniature = TraceMiniature.make(from: trace(path))
        #expect(miniature.count >= 3, Comment(rawValue: "\(miniature.count) points"))

        // Et le demi-tour est bien au bout : le point le plus au nord — donc
        // le plus haut, donc le plus petit y — n'est ni le premier ni le
        // dernier.
        let points = miniature.points
        let turn = points.firstIndex(of: points.min(by: { $0.y < $1.y })!)!
        #expect(turn > 0 && turn < points.count - 1)
    }

    /// L'autre défaut révélé par la mesure : la trace d'un col s'effondrait
    /// à deux points, perdant jusqu'à sa longueur.
    ///
    /// La tolérance doublait jusqu'à tenir dans le budget, et le doublement
    /// qui faisait passer sous la barre effaçait tout d'un coup, faute de
    /// resserrer ensuite entre la dernière valeur trop fine et celle-là.
    ///
    /// Ce que le test ne demande pas : que les lacets se *voient*. Un col de
    /// trois kilomètres large de soixante mètres est une forme étroite, et
    /// la dessiner presque droite est fidèle — à l'échelle, c'est ce qu'elle
    /// est. On vérifie que la trace survit, et que son mouvement latéral est
    /// encore dans la donnée, pas qu'un dessin de deux centimètres montre ce
    /// qu'il ne peut pas montrer.
    @Test("Un col en lacets ne s'effondre pas")
    func aSwitchbackClimbDoesNotCollapse() {
        let path = (0..<1800).map { index -> (Double, Double) in
            let t = Double(index)
            return (48.85 + t * 0.000015, 2.35 + sin(t / 47) * 0.0004)
        }
        let miniature = TraceMiniature.make(from: trace(path))
        #expect(miniature.count >= 20, Comment(rawValue: "\(miniature.count) points"))

        // Le mouvement latéral est encore là : la trace n'est pas devenue
        // une colonne d'abscisses identiques.
        let xs = Set(miniature.points.map(\.x))
        #expect(xs.count >= 3, Comment(rawValue: "\(xs.count) abscisses distinctes"))

        // Et toute la montée est là : du bas du cadre au haut.
        let ys = miniature.points.map(\.y)
        #expect(ys.max()! - ys.min()! > 0.9)
    }

    /// Une sortie en étoile : quatre branches parcourues aller-retour depuis
    /// le même point. La vignette doit rendre neuf points — centre, pointe,
    /// centre, pointe… — et pas un seul de plus.
    ///
    /// C'est le test le plus dur de la simplification : chaque branche est
    /// un aller-retour, donc quatre occasions de retomber dans le défaut
    /// précédent, et rien d'autre à garder que les extrémités.
    @Test("Une sortie en étoile garde ses quatre pointes")
    func aStarKeepsItsTips() {
        var path: [(Double, Double)] = []
        for branch in 0..<4 {
            let angle = Double(branch) * .pi / 2
            for i in 0..<150 {
                let d = Double(i) * 0.00006
                path.append((48.85 + sin(angle) * d, 2.35 + cos(angle) * d))
            }
            for i in 0..<150 {
                let d = Double(149 - i) * 0.00006
                path.append((48.85 + sin(angle) * d, 2.35 + cos(angle) * d))
            }
        }
        let miniature = TraceMiniature.make(from: trace(path))
        #expect(miniature.count == 9, Comment(rawValue: "\(miniature.count) points"))
    }

    // MARK: - Le budget

    /// Une sortie longue et sinueuse : deux heures de points GPS.
    private var longWindingRun: [GPSPoint] {
        trace((0..<2400).map { index in
            let t = Double(index)
            return (48.85 + sin(t / 60) * 0.01 + t * 0.000004,
                    2.35 + cos(t / 37) * 0.008)
        })
    }

    @Test("Une sortie de deux heures tient dans le budget")
    func aLongRunFitsTheBudget() {
        let miniature = TraceMiniature.make(from: longWindingRun)
        #expect(miniature.count <= 64, Comment(rawValue: "\(miniature.count) points"))
        #expect(miniature.count >= 8, Comment(rawValue: "\(miniature.count) points"))
    }

    /// Le budget qui compte vraiment : celui d'Apple.
    ///
    /// Un état de Live Activity dépassant quatre kilooctets est rejeté à la
    /// mise à jour, sans message et sans que l'application le sache. La
    /// vignette est la seule chose de cet état dont la taille dépende de la
    /// sortie ; c'est donc ici que la limite se surveille, sur l'instantané
    /// complet et encodé, pas sur une estimation.
    @Test("L'instantané complet reste loin de la limite d'Apple")
    func theWholeSnapshotStaysWellUnderApplesLimit() throws {
        let miniature = TraceMiniature.make(from: longWindingRun)
        let snapshot = RunActivitySnapshot(
            typeLabel: "Sortie longue en endurance fondamentale",
            distance: "21,10 km",
            pace: "5:24 /km",
            elevationGain: 342,
            startedAt: Date(),
            movingSeconds: 6_842,
            isPaused: false,
            hasWeakSignal: false,
            trace: miniature
        )
        let encoded = try JSONEncoder().encode(snapshot)
        #expect(encoded.count < 2048, Comment(rawValue: "\(encoded.count) octets"))
    }

    // MARK: - Ce qui reste vrai après un aller-retour

    @Test("Ce qu'on empaquette est ce qu'on relit")
    func packingRoundTrips() throws {
        let miniature = TraceMiniature.make(from: longWindingRun)
        let restored = try JSONDecoder().decode(
            TraceMiniature.self,
            from: JSONEncoder().encode(miniature)
        )
        #expect(restored == miniature)
        #expect(restored.points == miniature.points)
    }

    // MARK: - La réduction rendue publique

    /// Ce que la carte des parcours faisait avant, et pourquoi ça se voyait.
    ///
    /// Garder un point sur n coupe les virages au hasard. Sur un parcours
    /// en créneaux, c'est mesurable : la version naïve rate des angles que
    /// la réduction par écart au segment garde tous.
    @Test("Réduire par la forme garde les virages qu'un point sur n perd")
    func shapeBeatsEveryNth() {
        // Vingt créneaux serrés, séparés par de longues lignes droites.
        var points: [GPSPoint] = []
        var latitude = 48.85
        for step in 0..<400 {
            let corner = step % 20 == 0
            latitude += corner ? 0.002 : 0.00002
            points.append(
                GPSPoint(timestamp: Date(timeIntervalSince1970: Double(step) * 5),
                         latitude: latitude, longitude: 2.35 + Double(step) * 0.0002)
            )
        }

        let budget = 60
        let shaped = TraceMiniature.drawable(points, budget: budget)
        let naive = points.indices.filter { $0 % (points.count / budget + 1) == 0 }.map { points[$0] }

        #expect(shaped.count <= budget)

        // Ce qui se mesure, c'est l'écart entre le parcours réel et la
        // **ligne dessinée** — donc la distance de chaque point d'origine
        // aux segments qui relient les points gardés.
        //
        // Le premier essai de ce test mesurait la distance au point gardé le
        // plus proche, et le point sur n gagnait : il répartit ses points
        // régulièrement. C'est une bonne mesure de couverture et une mauvaise
        // mesure de fidélité — un point au milieu d'une ligne droite est loin
        // de tout sommet et pourtant exactement sur le trait.
        func distanceToSegment(_ point: GPSPoint, _ start: GPSPoint, _ end: GPSPoint) -> Double {
            let dx = end.longitude - start.longitude
            let dy = end.latitude - start.latitude
            let lengthSquared = dx * dx + dy * dy
            guard lengthSquared > 0 else {
                return hypot(point.longitude - start.longitude, point.latitude - start.latitude)
            }
            var t = ((point.longitude - start.longitude) * dx
                     + (point.latitude - start.latitude) * dy) / lengthSquared
            t = min(1, max(0, t))
            return hypot(point.longitude - (start.longitude + t * dx),
                         point.latitude - (start.latitude + t * dy))
        }

        func drift(_ reduced: [GPSPoint]) -> Double {
            guard reduced.count >= 2 else { return .infinity }
            var worst = 0.0
            for point in points {
                var nearest = Double.infinity
                for index in 0..<(reduced.count - 1) {
                    nearest = min(nearest, distanceToSegment(point, reduced[index], reduced[index + 1]))
                }
                worst = max(worst, nearest)
            }
            return worst
        }
        #expect(drift(shaped) < drift(naive))
    }

    @Test("Les extrémités survivent toujours à la réduction")
    func endsAreKept() {
        let points = (0..<500).map { step in
            GPSPoint(timestamp: Date(timeIntervalSince1970: Double(step) * 5),
                     latitude: 48.85 + Double(step) * 0.0001,
                     longitude: 2.35 + sin(Double(step) / 9) * 0.001)
        }
        let reduced = TraceMiniature.drawable(points, budget: 40)
        #expect(reduced.first?.latitude == points.first?.latitude)
        #expect(reduced.last?.latitude == points.last?.latitude)
        #expect(reduced.count <= 40)
    }

    @Test("Une trace plus courte que le budget n'est pas touchée")
    func shortTracesPassThrough() {
        let points = (0..<10).map { step in
            GPSPoint(timestamp: Date(timeIntervalSince1970: Double(step) * 5),
                     latitude: 48.85 + Double(step) * 0.001, longitude: 2.35)
        }
        #expect(TraceMiniature.drawable(points, budget: 400).count == points.count)
    }

    /// L'étendue, qui sert à écarter du dessin ce qui n'est pas un parcours.
    /// Un point isolé ailleurs élargit le cadre et écrase tous les vrais
    /// parcours contre un bord — c'est ce qu'on voyait à l'écran.
    @Test("L'étendue distingue un parcours d'un point posé")
    func spanTellsRoutesFromDots() {
        let now = Date()
        let dot = [
            GPSPoint(timestamp: now, latitude: 48.8500, longitude: 2.3500),
            GPSPoint(timestamp: now, latitude: 48.85002, longitude: 2.35003),
        ]
        #expect(TraceMiniature.spanMeters(dot) < 20)

        let route = [
            GPSPoint(timestamp: now, latitude: 48.85, longitude: 2.35),
            GPSPoint(timestamp: now, latitude: 48.88, longitude: 2.35),
        ]
        #expect(TraceMiniature.spanMeters(route) > 3_000)
        #expect(TraceMiniature.spanMeters([]) == 0)
    }
}
