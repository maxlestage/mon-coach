import Foundation

/// Une trace réduite à ce qu'un écran verrouillé peut en montrer.
///
/// Pourquoi ce n'est pas une carte
/// ...............................
/// Une Live Activity ne peut pas en afficher une. Son extension tourne dans
/// un bac à sable qui n'a ni réseau, ni position, ni MapKit : elle dessine
/// ce qu'on lui donne, et rien d'autre. Et ce qu'on lui donne passe par un
/// état dont Apple limite la taille à quatre kilooctets — une tuile
/// d'image, même minuscule, ne tient pas dans ce budget, et une mise à jour
/// trop grosse est rejetée sans un mot.
///
/// Reste ce qui, du GPS, se dessine avec des traits : la forme du parcours.
/// C'est aussi la seule chose qu'on lise vraiment d'un coup d'œil sur un
/// écran verrouillé — pas où l'on est, mais où l'on est passé, et si la
/// boucle est en train de se refermer.
///
/// Ce que le format garantit
/// .........................
/// Deux octets par point, x puis y, dans un carré de 0 à 1 une fois relus.
/// Une cinquantaine de points suffisent à reconnaître un parcours, et
/// pèsent quelques centaines d'octets : le budget est tenu avec deux ordres
/// de grandeur de marge, ce qu'un test vérifie sur un instantané complet.
///
/// Les coordonnées sont celles de l'écran : x vers la droite, **y vers le
/// bas**, le nord en haut. La vue n'a donc rien à retourner.
public struct TraceMiniature: Codable, Sendable, Hashable {

    /// Les points, aplatis — x, y, x, y — chacun sur un octet.
    ///
    /// Un octet par coordonnée, soit 256 pas sur la largeur du dessin. Sur
    /// les soixante points d'écran que la vignette occupe, c'est quatre fois
    /// plus fin que ce que l'œil distingue : quantifier plus finement
    /// coûterait de la place pour un dessin identique.
    public var packed: [UInt8]

    public init(packed: [UInt8] = []) {
        self.packed = packed
    }

    public static let empty = TraceMiniature()

    /// Un point de la vignette, en coordonnées d'écran, 0 à 1.
    public struct Point: Sendable, Hashable {
        public var x: Double
        public var y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    /// Moins de deux points ne fait pas un trait.
    public var isEmpty: Bool { packed.count < 4 }
    public var count: Int { packed.count / 2 }

    public var points: [Point] {
        stride(from: 0, to: count * 2, by: 2).map { index in
            Point(
                x: Double(packed[index]) / 255,
                y: Double(packed[index + 1]) / 255
            )
        }
    }

    /// Où l'athlète se trouve à cet instant : le dernier point.
    public var current: Point? { points.last }
}

// MARK: - La fabrication

extension TraceMiniature {

    /// La distance minimale que doit couvrir une trace pour être dessinée.
    ///
    /// Sans ce seuil, quelqu'un arrêté à un feu rouge verrait le tremblement
    /// de son GPS — trois mètres d'errance — étalé sur toute la vignette,
    /// puisqu'on ramène toujours le parcours à la taille du cadre. Un
    /// gribouillage plein cadre pour trois mètres est un mensonge ; mieux
    /// vaut ne rien montrer tant qu'il n'y a rien à voir.
    public static let minimumSpanMeters: Double = 50

    /// Un degré de latitude, en mètres. Sert à décider si la trace est assez
    /// grande pour valoir un dessin, pas à mesurer une distance — la mesure
    /// juste est ailleurs, dans TraceMath.
    private static let metersPerDegree: Double = 111_320

    /// Réduit une trace à sa vignette.
    ///
    /// - Parameters:
    ///   - points: la trace, dans l'ordre.
    ///   - budget: le nombre de points qu'on s'autorise à garder.
    ///
    /// Ce que le budget ne peut pas faire
    /// ..................................
    /// Soixante-quatre points ne dessinent pas cent lacets. Mesuré sur des
    /// formes réelles, la marge est confortable — un col avec un lacet tous
    /// les cent cinquante mètres, une boucle urbaine bruitée, une sortie en
    /// étoile tiennent tous largement. Au-delà, la simplification lisse, et
    /// c'est ce que fait toute vignette.
    ///
    /// Elle lisse plutôt qu'elle n'invente : échantillonner un point sur n
    /// ferait tenir n'importe quelle trace dans le budget, mais dessinerait
    /// un serpentin de repliement qui n'a jamais été couru. Un parcours
    /// adouci est une approximation ; un parcours inventé est un mensonge,
    /// et cette application n'en fait pas sur ce qu'elle a mesuré.
    public static func make(from points: [GPSPoint], budget: Int = 64) -> TraceMiniature {
        guard points.count >= 2, budget >= 2 else { return .empty }

        // Latitude et longitude ne mesurent pas la même chose : à Paris, un
        // degré de longitude vaut deux tiers d'un degré de latitude. Dessiner
        // les deux à la même échelle étirerait tous les parcours d'est en
        // ouest — une boucle carrée deviendrait un rectangle. On corrige une
        // fois, ici, et tout le reste travaille dans un plan honnête.
        let meanLatitude = points.reduce(0.0) { $0 + $1.latitude } / Double(points.count)
        let squeeze = cos(meanLatitude * .pi / 180)
        let plane = points.map { Plane(x: $0.longitude * squeeze, y: $0.latitude) }

        let minX = plane.lazy.map(\.x).min() ?? 0
        let maxX = plane.lazy.map(\.x).max() ?? 0
        let minY = plane.lazy.map(\.y).min() ?? 0
        let maxY = plane.lazy.map(\.y).max() ?? 0
        let width = maxX - minX
        let height = maxY - minY
        let side = max(width, height)

        guard side * metersPerDegree >= minimumSpanMeters else { return .empty }

        // On simplifie dans le plan d'origine, avant de normaliser : la
        // tolérance a ainsi un sens géographique, et deux sorties de tailles
        // différentes sont traitées pareil une fois ramenées au cadre.
        let kept = fitting(plane, budget: budget, diagonal: hypot(width, height))

        // Le côté le plus long occupe tout le cadre, le plus court est
        // centré : c'est ce qui garde au parcours sa forme au lieu de
        // l'étirer aux dimensions de la vignette.
        let offsetX = (side - width) / 2
        let offsetY = (side - height) / 2

        var packed: [UInt8] = []
        packed.reserveCapacity(kept.count * 2)
        for point in kept {
            let x = (point.x - minX + offsetX) / side
            // Le nord est en haut : la latitude croît vers le nord, l'axe y
            // d'un écran croît vers le bas. On retourne ici, une fois, pour
            // que la vue n'ait pas à y penser.
            let y = 1 - (point.y - minY + offsetY) / side
            packed.append(byte(x))
            packed.append(byte(y))
        }
        return TraceMiniature(packed: packed)
    }

    private struct Plane {
        var x: Double
        var y: Double
    }

    private static func byte(_ value: Double) -> UInt8 {
        UInt8((value * 255).rounded().clamped(to: 0...255))
    }

    /// Simplifie jusqu'à tenir dans le budget, en gardant le plus de
    /// détail possible.
    ///
    /// En deux temps, et le second n'est pas un raffinement de confort.
    /// Doubler la tolérance jusqu'à passer sous le budget suffisait à tenir
    /// la limite, mais pas à dessiner : sur un sentier en lacets, le
    /// doublement qui fait passer de cent points à moins de cinquante
    /// efface *tous* les lacets d'un coup, et le sentier arrive à l'écran
    /// comme une ligne droite. Mesuré : trois mille points de lacets se
    /// réduisaient à deux.
    ///
    /// On resserre donc ensuite entre la dernière tolérance trop fine et la
    /// première assez grossière, pour retenir la plus fine qui tienne — un
    /// lacet sur deux plutôt qu'aucun.
    private static func fitting(_ plane: [Plane], budget: Int, diagonal: Double) -> [Plane] {
        guard plane.count > budget else { return plane }

        var tooFine = 0.0
        var coarse = diagonal / 2000
        var fitted: [Plane]?
        for _ in 0..<24 {
            let kept = simplified(plane, epsilon: coarse)
            if kept.count <= budget {
                fitted = kept
                break
            }
            tooFine = coarse
            coarse *= 2
        }

        guard var best = fitted else {
            // Filet de sécurité : une trace qui résiste à vingt-quatre
            // doublements est pathologique, mais elle ne doit pas pour
            // autant faire sortir du budget. On prend alors un point sur n.
            let step = Int((Double(plane.count) / Double(budget)).rounded(.up))
            return plane.enumerated().compactMap { $0.offset % step == 0 ? $0.element : nil }
        }

        var low = tooFine
        var high = coarse
        for _ in 0..<12 {
            let middle = (low + high) / 2
            let kept = simplified(plane, epsilon: middle)
            if kept.count <= budget {
                best = kept
                high = middle
            } else {
                low = middle
            }
        }
        return best
    }

    /// Ramer-Douglas-Peucker : on ne garde que les points dont l'absence se
    /// verrait.
    ///
    /// Un point sur n, plus simple, coupe les virages au hasard — un lacet
    /// serré disparaît, une ligne droite garde vingt points inutiles. Ici
    /// c'est l'écart au segment qui décide : les angles survivent, les
    /// portions droites se réduisent à leurs deux extrémités.
    ///
    /// La descente est menée sur une pile explicite plutôt que par récursion.
    /// Une trace d'une heure fait quelques milliers de points, et une trace
    /// en escalier ferait descendre la récursion aussi profond qu'elle est
    /// longue — une pile qui déborde tuerait l'application pendant la sortie.
    private static func simplified(_ points: [Plane], epsilon: Double) -> [Plane] {
        guard points.count > 2 else { return points }
        var keep = [Bool](repeating: false, count: points.count)
        keep[0] = true
        keep[points.count - 1] = true

        var pending: [(Int, Int)] = [(0, points.count - 1)]
        while let (first, last) = pending.popLast() {
            guard last > first + 1 else { continue }
            var worst = 0.0
            var chosen = first
            for index in (first + 1)..<last {
                let distance = perpendicular(points[index], from: points[first], to: points[last])
                if distance > worst {
                    worst = distance
                    chosen = index
                }
            }
            guard worst > epsilon else { continue }
            keep[chosen] = true
            pending.append((first, chosen))
            pending.append((chosen, last))
        }
        return zip(points, keep).compactMap { $1 ? $0 : nil }
    }

    /// La distance d'un point au **segment**, et non à la droite infinie
    /// qui le porte.
    ///
    /// La nuance décide du sort des aller-retours, qui sont la moitié des
    /// sorties. Sur un aller-retour, le premier et le dernier point sont au
    /// même endroit, et tous les points du parcours sont alignés avec eux :
    /// mesurée à la droite, la distance de chacun vaut zéro, le demi-tour
    /// compris. Toute la sortie disparaissait — mesuré : neuf cents points
    /// se réduisaient à deux, et l'écran verrouillé montrait un moignon de
    /// deux mètres étiré en bas du cadre.
    ///
    /// Mesurée au segment, la projection est ramenée entre ses deux bouts :
    /// le demi-tour est alors à un kilomètre de son segment, il survit, et
    /// l'aller-retour se dessine comme un aller-retour.
    private static func perpendicular(_ point: Plane, from start: Plane, to end: Plane) -> Double {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else {
            return hypot(point.x - start.x, point.y - start.y)
        }
        let along = ((point.x - start.x) * dx + (point.y - start.y) * dy) / lengthSquared
        let clamped = min(max(along, 0), 1)
        return hypot(
            point.x - (start.x + clamped * dx),
            point.y - (start.y + clamped * dy)
        )
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
