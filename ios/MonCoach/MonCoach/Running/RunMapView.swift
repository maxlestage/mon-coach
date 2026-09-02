import SwiftUI
import MapKit
import MonCoachKit

/// La carte d'une trace, sur Apple Plans.
///
/// Pourquoi Apple Plans
/// --------------------
/// La carte est le seul écran de l'application qui montre autre chose que
/// ce que l'athlète a lui-même produit, et c'est celui où l'on se demande
/// « je suis où ? ». Apple Plans est la carte que le téléphone connaît
/// déjà : même rendu, mêmes noms de rues, même mode sombre que partout
/// ailleurs sur l'appareil, et aucun paquet tiers à résoudre pour compiler.
/// Le fond de carte est servi par Apple, dans le cadre du système ; ce que
/// l'application dessine dessus — la trace, le parcours prévu — reste
/// calculé sur le téléphone.
///
/// Le réglage « fond de carte » reste : l'athlète qui ne veut contacter
/// aucun serveur garde sa trace, dessinée à l'échelle sans les rues.
struct RunMapView: View {
    var points: [GPSPoint]
    /// Le parcours prévu, dessiné sous la trace. Vide la plupart du temps.
    var route: [RoutePoint] = []
    /// Position courante à mettre en avant, pendant une sortie.
    var showsCurrentPosition: Bool = false
    /// Charger le fond de carte. L'athlète peut le refuser : il garde alors
    /// son tracé, sans les rues et sans qu'aucune requête ne sorte du
    /// téléphone.
    var loadsTiles: Bool = true
    /// Appelé quand l'athlète touche la carte, en mode dessin de parcours.
    /// Nil partout ailleurs : une carte qu'on peut modifier par mégarde en
    /// relisant une sortie serait un piège.
    var onTapCoordinate: ((RoutePoint) -> Void)?

    var body: some View {
        Group {
            if loadsTiles {
                AppleRouteMap(
                    points: points,
                    route: route,
                    showsCurrentPosition: showsCurrentPosition,
                    onTapCoordinate: onTapCoordinate
                )
            } else {
                RouteShapeView(points: points, route: route)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

/// La carte Apple Plans, avec les deux tracés dessus.
private struct AppleRouteMap: View {
    var points: [GPSPoint]
    var route: [RoutePoint]
    var showsCurrentPosition: Bool
    var onTapCoordinate: ((RoutePoint) -> Void)?

    /// La caméra. Elle suit l'athlète tant qu'il n'y a rien à cadrer, puis
    /// c'est la trace qui commande — sauf en mode dessin, où la caméra
    /// appartient à l'athlète : il vise sa rue et pose ses points, et le
    /// recadrer à chaque point le renverrait sans arrêt là d'où il vient.
    @State private var position: MapCameraPosition = .automatic
    /// Le nombre de points cadrés la dernière fois : on ne recadre qu'au-delà
    /// de dix nouveaux points, sinon la carte bouge à chaque seconde.
    @State private var framedCount = 0
    @State private var framedRoute = false

    private var isPlanning: Bool { onTapCoordinate != nil }

    private var traceCoordinates: [CLLocationCoordinate2D] {
        points.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        route.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var body: some View {
        MapReader { proxy in
            Map(position: $position, interactionModes: [.pan, .zoom]) {
                // Le prévu passe dessous et en pointillé : ce qui est prévu
                // ne doit jamais se confondre avec ce qui a été fait.
                if routeCoordinates.count >= 2 {
                    MapPolyline(coordinates: routeCoordinates)
                        .stroke(
                            Theme.warning.opacity(0.85),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [8, 6])
                        )
                }
                // Les pastilles n'existent que pendant le dessin : un point
                // posé seul ne fait pas de ligne, et le premier appui ne
                // montrerait sinon rien du tout.
                if isPlanning {
                    ForEach(Array(routeCoordinates.enumerated()), id: \.offset) { _, coordinate in
                        Annotation("", coordinate: coordinate) {
                            Circle()
                                .fill(Theme.warning)
                                .stroke(Theme.background, lineWidth: 2)
                                .frame(width: 12, height: 12)
                        }
                        .annotationTitles(.hidden)
                    }
                }
                if traceCoordinates.count >= 2 {
                    MapPolyline(coordinates: traceCoordinates)
                        .stroke(
                            Theme.accent,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
                        )
                }
                if showsCurrentPosition {
                    UserAnnotation()
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .mapControlVisibility(.hidden)
            .onTapGesture { location in
                guard let onTapCoordinate,
                      let coordinate = proxy.convert(location, from: .local)
                else { return }
                onTapCoordinate(RoutePoint(latitude: coordinate.latitude, longitude: coordinate.longitude))
            }
        }
        .onAppear { frame(initial: true) }
        .onChange(of: points.count) { _, _ in frame(initial: false) }
        .onChange(of: route.count) { _, _ in frame(initial: false) }
    }

    /// Cadre ce qu'il y a à montrer.
    private func frame(initial: Bool) {
        // En mode dessin, la caméra est à l'athlète — sauf au tout début,
        // où elle part de sa position.
        if isPlanning {
            if initial { position = .userLocation(fallback: .automatic) }
            return
        }

        if traceCoordinates.count >= 2 {
            guard initial || traceCoordinates.count - framedCount >= 10 else { return }
            framedCount = traceCoordinates.count
            withAnimation(initial ? nil : .easeInOut(duration: 0.6)) {
                position = .rect(Self.rect(around: traceCoordinates + routeCoordinates))
            }
            return
        }

        if routeCoordinates.count >= 2, !framedRoute {
            // Un parcours qu'on vient d'ouvrir se montre en entier, une fois.
            framedRoute = true
            position = .rect(Self.rect(around: routeCoordinates))
            return
        }

        if initial {
            // Rien à cadrer : la carte suit l'athlète. C'est l'écran
            // d'avant-départ, où une carte du monde entier ne renseignerait
            // sur rien.
            position = showsCurrentPosition ? .userLocation(fallback: .automatic) : .automatic
        }
    }

    /// L'emprise d'un ensemble de coordonnées, avec une marge.
    private static func rect(around coordinates: [CLLocationCoordinate2D]) -> MKMapRect {
        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        // Une marge d'un cinquième de chaque côté : la trace ne touche pas
        // les bords, et un aller-retour très allongé reste lisible.
        let dx = max(rect.size.width * 0.2, 60)
        let dy = max(rect.size.height * 0.2, 60)
        return rect.insetBy(dx: -dx, dy: -dy)
    }
}

/// Le tracé seul, dessiné à l'échelle dans le repère de la vue.
///
/// Sert quand le fond de carte est refusé, et de vignette dans les listes :
/// afficher vingt cartes dans un historique coûterait bien plus que ce que
/// ça apporte.
struct RouteShapeView: View {
    var points: [GPSPoint]
    /// Un parcours prévu, dessiné avec la trace ou seul.
    var route: [RoutePoint] = []
    var lineWidth: CGFloat = 3

    /// Les deux tracés ramenés au même type : le dessin ne connaît que des
    /// couples de coordonnées, et l'un des deux est souvent vide.
    private var traceCoordinates: [RoutePoint] {
        points.map { RoutePoint(latitude: $0.latitude, longitude: $0.longitude) }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.surfaceRaised
                let frame = Frame(of: traceCoordinates + route, in: geometry.size)
                if let frame {
                    if route.count >= 2 {
                        path(route, in: frame)
                            .stroke(
                                Theme.warning.opacity(0.85),
                                style: StrokeStyle(
                                    lineWidth: lineWidth - 0.5,
                                    lineCap: .round,
                                    lineJoin: .round,
                                    dash: [7, 5]
                                )
                            )
                    }
                    if traceCoordinates.count >= 2 {
                        path(traceCoordinates, in: frame)
                            .stroke(
                                Theme.accent,
                                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                            )
                    }
                }
            }
        }
    }

    private func path(_ coordinates: [RoutePoint], in frame: Frame) -> Path {
        var path = Path()
        guard let first = coordinates.first else { return path }
        path.move(to: frame.project(first))
        for point in coordinates.dropFirst() { path.addLine(to: frame.project(point)) }
        return path
    }

    /// L'emprise commune des tracés, et la projection qui les y range.
    ///
    /// La longitude est resserrée par le cosinus de la latitude : sans ça, un
    /// aller-retour est-ouest à Paris paraît 1,5 fois trop long, et le tracé
    /// ne ressemble plus au parcours.
    struct Frame {
        var minLatitude: Double
        var maxLatitude: Double
        var minLongitude: Double
        var cosinus: Double
        var scale: CGFloat
        var offsetX: CGFloat
        var offsetY: CGFloat

        init?(of coordinates: [RoutePoint], in size: CGSize, inset: CGFloat = 12) {
            let latitudes = coordinates.map(\.latitude)
            let longitudes = coordinates.map(\.longitude)
            guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
                  let minLon = longitudes.min(), let maxLon = longitudes.max()
            else { return nil }

            minLatitude = minLat
            maxLatitude = maxLat
            minLongitude = minLon
            cosinus = cos((minLat + maxLat) / 2 * .pi / 180)
            let spanX = max(0.000001, (maxLon - minLon) * cosinus)
            let spanY = max(0.000001, maxLat - minLat)
            scale = min((size.width - inset * 2) / spanX, (size.height - inset * 2) / spanY)
            offsetX = (size.width - spanX * scale) / 2
            offsetY = (size.height - spanY * scale) / 2
        }

        func project(_ point: RoutePoint) -> CGPoint {
            CGPoint(
                x: offsetX + (point.longitude - minLongitude) * cosinus * scale,
                // L'axe des ordonnées est inversé : le nord est en haut.
                y: offsetY + (maxLatitude - point.latitude) * scale
            )
        }
    }
}
