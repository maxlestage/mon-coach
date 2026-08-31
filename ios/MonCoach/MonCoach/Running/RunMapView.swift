import SwiftUI
import MonCoachKit

#if canImport(MapLibre)
import MapLibre
#endif

/// La carte d'une trace, sur fond OpenStreetMap.
///
/// Deux implémentations vivent dans ce fichier, choisies à la compilation.
/// Avec MapLibre résolu, c'est une vraie carte vectorielle. Sans lui — dépôt
/// cloné sans réseau, résolution de paquets qui échoue — l'application
/// compile quand même et affiche le tracé seul, à l'échelle, sans fond de
/// carte. Un athlète qui ne peut pas construire l'application est un athlète
/// perdu ; un athlète qui voit sa trace sans les rues, non.
struct RunMapView: View {
    var points: [GPSPoint]
    /// Le parcours prévu, dessiné sous la trace. Vide la plupart du temps.
    var route: [RoutePoint] = []
    /// Position courante à mettre en avant, pendant une sortie.
    var showsCurrentPosition: Bool = false
    /// Charger le fond de carte, c'est-à-dire contacter un serveur de tuiles.
    /// L'athlète peut le refuser : il garde alors son tracé, sans les rues et
    /// sans qu'aucune requête ne sorte du téléphone.
    var loadsTiles: Bool = true
    /// Appelé quand l'athlète touche la carte, en mode dessin de parcours.
    /// Nil partout ailleurs : une carte qu'on peut modifier par mégarde en
    /// relisant une sortie serait un piège.
    var onTapCoordinate: ((RoutePoint) -> Void)?

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            #if canImport(MapLibre)
            if loadsTiles {
                MapLibreRouteMap(
                    points: points,
                    route: route,
                    showsCurrentPosition: showsCurrentPosition,
                    onTapCoordinate: onTapCoordinate
                )
            } else {
                RouteShapeView(points: points, route: route)
            }
            #else
            RouteShapeView(points: points, route: route)
            #endif

            // L'attribution OpenStreetMap est une obligation de la licence
            // ODbL, pas une politesse. Elle reste visible sur la carte, y
            // compris en plein écran.
            if loadsTiles {
                Text("© OpenStreetMap")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Theme.primaryText.opacity(0.75))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Theme.background.opacity(0.65), in: Capsule())
                    .padding(8)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
    }
}

/// Le tracé seul, dessiné à l'échelle dans le repère de la vue.
///
/// Sert de repli sans MapLibre, et de vignette dans les listes : afficher
/// vingt cartes vectorielles dans un historique coûterait bien plus que ce
/// que ça apporte.
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
                        // Le parcours prévu passe dessous et en pointillé :
                        // ce qui est prévu ne doit jamais se confondre avec
                        // ce qui a été fait.
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

#if canImport(MapLibre)

/// La carte vectorielle MapLibre, avec des tuiles OpenStreetMap.
struct MapLibreRouteMap: UIViewRepresentable {
    var points: [GPSPoint]
    var route: [RoutePoint] = []
    var showsCurrentPosition: Bool
    var onTapCoordinate: ((RoutePoint) -> Void)?

    /// Le style de carte.
    ///
    /// Le rendu vectoriel de MapLibre a besoin d'un style ; celui-ci pointe
    /// vers un fournisseur de tuiles OpenStreetMap sans clé d'API. C'est la
    /// seule ressource réseau de toute l'application, et elle n'est chargée
    /// que sur les écrans de course.
    static let styleURL = URL(string: "https://tiles.openfreemap.org/styles/liberty")!

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: Self.styleURL)
        mapView.delegate = context.coordinator
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = showsCurrentPosition
        mapView.isRotateEnabled = false
        mapView.isPitchEnabled = false
        // Tant qu'il n'y a pas de trace, la carte suit l'athlète : c'est le
        // cas de l'écran d'avant-départ, où une carte du monde entier ne
        // renseignerait sur rien. Dès que la trace existe, c'est elle qui
        // cadre la vue — le suivi est rendu au moment du premier dessin.
        if showsCurrentPosition && points.count < 2 && route.isEmpty {
            mapView.userTrackingMode = .follow
        }
        if onTapCoordinate != nil {
            context.coordinator.attachTap(to: mapView)
        }
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        mapView.showsUserLocation = showsCurrentPosition
        context.coordinator.onTapCoordinate = onTapCoordinate
        context.coordinator.isPlanning = onTapCoordinate != nil
        context.coordinator.update(points: points, route: route, on: mapView)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, MLNMapViewDelegate {
        var onTapCoordinate: ((RoutePoint) -> Void)?
        /// En mode dessin, la caméra appartient à l'athlète : il vise sa rue
        /// et pose ses points. Recadrer à chaque point le renverrait sans
        /// arrêt là d'où il vient.
        var isPlanning = false

        /// Seules des valeurs sont gardées ici, jamais une annotation.
        ///
        /// Ce n'est pas un détail de style : la carte est isolée au fil
        /// principal, et Swift refuse qu'on lui confie un objet que ce
        /// coordinateur détient encore — deux fils pourraient le modifier en
        /// même temps. Une annotation fabriquée sur place et remise à la
        /// carte dans la foulée n'appartient plus à personne d'autre, et
        /// c'est pour ça qu'elle passe.
        private var drawnPointCount = 0
        private var pendingPoints: [GPSPoint] = []
        private var plannedRoute: [RoutePoint] = []
        private var isStyleLoaded = false
        private var hasFramedRoute = false

        /// Le titre sert d'étiquette : c'est par lui que les rappels de
        /// style savent lequel des deux tracés ils sont en train de peindre.
        private static let routeTitle = "parcours"

        /// Marqué au fil principal, contrairement au reste de ce
        /// coordinateur : `UIGestureRecognizer` et `UIView` y sont isolés
        /// par UIKit, et Swift 6 refuse qu'on y touche ailleurs.
        @MainActor
        func attachTap(to mapView: MLNMapView) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            // Le double-tap zoome, et il commence par un simple tap : sans
            // cette priorité, zoomer poserait deux points au passage.
            for existing in mapView.gestureRecognizers ?? [] {
                if let existing = existing as? UITapGestureRecognizer,
                   existing.numberOfTapsRequired > 1 {
                    tap.require(toFail: existing)
                }
            }
            mapView.addGestureRecognizer(tap)
        }

        @MainActor
        @objc private func handleTap(_ sender: UITapGestureRecognizer) {
            guard let mapView = sender.view as? MLNMapView, let onTapCoordinate else { return }
            let coordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
            onTapCoordinate(RoutePoint(latitude: coordinate.latitude, longitude: coordinate.longitude))
        }

        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            isStyleLoaded = true
            redraw(on: mapView, animated: false)
        }

        /// Retient ce qu'il y a à montrer, et ne redessine que s'il le faut.
        func update(points: [GPSPoint], route: [RoutePoint], on mapView: MLNMapView) {
            let routeChanged = route != plannedRoute
            pendingPoints = points
            plannedRoute = route
            guard isStyleLoaded else { return }
            // Redessiner à chaque point reçu, une fois par seconde, ferait
            // clignoter la carte pour rien : on ne redessine qu'au-delà de
            // dix nouveaux points de trace, ou quand le parcours change.
            guard routeChanged || points.count - drawnPointCount >= 10 else { return }
            redraw(on: mapView, animated: !routeChanged)
        }

        /// Repose les deux tracés d'un coup.
        ///
        /// Tout est retiré puis refait, plutôt que corrigé pièce par pièce :
        /// pour retirer une annotation précise, il faudrait la détenir, et
        /// une annotation détenue ne peut plus être confiée à la carte. Le
        /// coût est un redessin toutes les dix secondes de course.
        func redraw(on mapView: MLNMapView, animated: Bool) {
            guard isStyleLoaded else { return }
            drawnPointCount = pendingPoints.count
            if let existing = mapView.annotations { mapView.removeAnnotations(existing) }
            drawPlannedRoute(on: mapView)
            drawTrace(on: mapView, animated: animated)
        }

        private func drawPlannedRoute(on mapView: MLNMapView) {
            guard !plannedRoute.isEmpty else { return }

            // Les pastilles n'existent que pendant le dessin : c'est là
            // qu'elles servent, un point posé seul ne faisant pas de ligne et
            // le premier appui ne montrant sinon rien du tout. En suivant un
            // parcours, elles seraient du bruit — un tracé importé en porte
            // des centaines, une tous les quelques mètres.
            //
            // Posées une par une, et pas en un tableau : un objet fabriqué
            // sur place puis remis à la carte ne relève plus de personne
            // d'autre, là où un tableau constitué ici resterait à nous.
            if isPlanning {
                for point in plannedRoute {
                    let marker = MLNPointAnnotation()
                    marker.coordinate = CLLocationCoordinate2D(
                        latitude: point.latitude, longitude: point.longitude
                    )
                    marker.title = Self.routeTitle
                    mapView.addAnnotation(marker)
                }
            }

            guard plannedRoute.count >= 2 else { return }
            var coordinates = plannedRoute.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            let polyline = MLNPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
            polyline.title = Self.routeTitle
            mapView.addAnnotation(polyline)

            // Un parcours qu'on vient d'ouvrir se montre en entier, une fois.
            // En mode dessin, jamais : la caméra est à l'athlète.
            guard !isPlanning, !hasFramedRoute, pendingPoints.count < 2 else { return }
            hasFramedRoute = true
            mapView.userTrackingMode = .none
            mapView.setVisibleCoordinates(
                &coordinates,
                count: UInt(coordinates.count),
                edgePadding: UIEdgeInsets(top: 40, left: 30, bottom: 40, right: 30),
                animated: false
            )
        }

        private func drawTrace(on mapView: MLNMapView, animated: Bool) {
            guard pendingPoints.count >= 2 else { return }
            // Le suivi de la position et le cadrage sur la trace se disputent
            // la caméra ; à partir d'ici, la trace gagne.
            mapView.userTrackingMode = .none

            var coordinates = pendingPoints.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            mapView.addAnnotation(
                MLNPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
            )
            mapView.setVisibleCoordinates(
                &coordinates,
                count: UInt(coordinates.count),
                edgePadding: UIEdgeInsets(top: 40, left: 30, bottom: 40, right: 30),
                animated: animated
            )
        }

        // MARK: - Le style des tracés

        func mapView(_ mapView: MLNMapView, lineWidthForPolylineAnnotation annotation: MLNPolyline) -> CGFloat {
            annotation.title == Self.routeTitle ? 5 : 4
        }

        func mapView(_ mapView: MLNMapView, strokeColorForShapeAnnotation annotation: MLNShape) -> UIColor {
            // Le prévu et le fait ne portent pas la même couleur : sur la
            // carte pendant une sortie, il faut voir d'un coup d'œil lequel
            // des deux traits on est en train de suivre.
            annotation.title == Self.routeTitle ? UIColor(Theme.warning) : UIColor(Theme.accent)
        }

        func mapView(_ mapView: MLNMapView, alphaForShapeAnnotation annotation: MLNShape) -> CGFloat {
            annotation.title == Self.routeTitle ? 0.75 : 1
        }

        /// La pastille d'un point de parcours.
        ///
        /// Le cache d'images de la carte n'est pas consulté, à dessein :
        /// l'interroger reviendrait à rapporter ici un objet qui appartient
        /// au fil principal. Redessiner douze pixels coûte moins cher que
        /// cette gymnastique.
        func mapView(_ mapView: MLNMapView, imageFor annotation: MLNAnnotation) -> MLNAnnotationImage? {
            // La position de l'athlète passe aussi par ce rappel : lui donner
            // cette pastille remplacerait le point bleu du système par un
            // rond orange, et on ne saurait plus où l'on est.
            guard annotation is MLNPointAnnotation else { return nil }
            return MLNAnnotationImage(image: Self.dot, reuseIdentifier: "point-de-parcours")
        }

        private static var dot: UIImage {
            let size = CGSize(width: 12, height: 12)
            return UIGraphicsImageRenderer(size: size).image { context in
                let circle = CGRect(origin: .zero, size: size).insetBy(dx: 1, dy: 1)
                context.cgContext.setFillColor(UIColor(Theme.warning).cgColor)
                context.cgContext.fillEllipse(in: circle)
                context.cgContext.setStrokeColor(UIColor(Theme.background).cgColor)
                context.cgContext.setLineWidth(2)
                context.cgContext.strokeEllipse(in: circle)
            }
        }
    }
}

#endif
