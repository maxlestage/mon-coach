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
    /// Position courante à mettre en avant, pendant une sortie.
    var showsCurrentPosition: Bool = false
    /// Charger le fond de carte, c'est-à-dire contacter un serveur de tuiles.
    /// L'athlète peut le refuser : il garde alors son tracé, sans les rues et
    /// sans qu'aucune requête ne sorte du téléphone.
    var loadsTiles: Bool = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            #if canImport(MapLibre)
            if loadsTiles {
                MapLibreRouteMap(points: points, showsCurrentPosition: showsCurrentPosition)
            } else {
                RouteShapeView(points: points)
            }
            #else
            RouteShapeView(points: points)
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
    var lineWidth: CGFloat = 3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Theme.surfaceRaised
                if points.count >= 2 {
                    routePath(in: geometry.size)
                        .stroke(
                            Theme.accent,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
                        )
                }
            }
        }
    }

    /// Projette la trace dans la vue en gardant les proportions.
    ///
    /// La longitude est resserrée par le cosinus de la latitude : sans ça, un
    /// aller-retour est-ouest à Paris paraît 1,5 fois trop long, et le tracé
    /// ne ressemble plus au parcours.
    private func routePath(in size: CGSize) -> Path {
        let latitudes = points.map(\.latitude)
        let longitudes = points.map(\.longitude)
        guard let minLat = latitudes.min(), let maxLat = latitudes.max(),
              let minLon = longitudes.min(), let maxLon = longitudes.max()
        else { return Path() }

        let midLatRadians = (minLat + maxLat) / 2 * .pi / 180
        let spanX = max(0.000001, (maxLon - minLon) * cos(midLatRadians))
        let spanY = max(0.000001, maxLat - minLat)
        let inset: CGFloat = 12
        let scale = min((size.width - inset * 2) / spanX, (size.height - inset * 2) / spanY)
        let offsetX = (size.width - spanX * scale) / 2
        let offsetY = (size.height - spanY * scale) / 2

        func project(_ point: GPSPoint) -> CGPoint {
            CGPoint(
                x: offsetX + (point.longitude - minLon) * cos(midLatRadians) * scale,
                // L'axe des ordonnées est inversé : le nord est en haut.
                y: offsetY + (maxLat - point.latitude) * scale
            )
        }

        var path = Path()
        path.move(to: project(points[0]))
        for point in points.dropFirst() { path.addLine(to: project(point)) }
        return path
    }
}

#if canImport(MapLibre)

/// La carte vectorielle MapLibre, avec des tuiles OpenStreetMap.
struct MapLibreRouteMap: UIViewRepresentable {
    var points: [GPSPoint]
    var showsCurrentPosition: Bool

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
        if showsCurrentPosition && points.count < 2 {
            mapView.userTrackingMode = .follow
        }
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        mapView.showsUserLocation = showsCurrentPosition
        context.coordinator.draw(points, on: mapView)
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, MLNMapViewDelegate {
        private var drawnPointCount = 0
        private var pendingPoints: [GPSPoint] = []
        private var isStyleLoaded = false

        func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            isStyleLoaded = true
            draw(pendingPoints, on: mapView, force: true)
        }

        func draw(_ points: [GPSPoint], on mapView: MLNMapView, force: Bool = false) {
            pendingPoints = points
            guard isStyleLoaded, points.count >= 2 else { return }
            // Redessiner à chaque point reçu, une fois par seconde, ferait
            // clignoter la carte pour rien : on ne redessine qu'au-delà de
            // dix nouveaux points, ou à la demande.
            guard force || points.count - drawnPointCount >= 10 else { return }
            drawnPointCount = points.count

            // Le suivi de la position et le cadrage sur la trace se disputent
            // la caméra ; à partir d'ici, la trace gagne.
            mapView.userTrackingMode = .none

            var coordinates = points.map {
                CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
            }
            let polyline = MLNPolyline(coordinates: &coordinates, count: UInt(coordinates.count))

            if let existing = mapView.annotations { mapView.removeAnnotations(existing) }
            mapView.addAnnotation(polyline)
            mapView.setVisibleCoordinates(
                &coordinates,
                count: UInt(coordinates.count),
                edgePadding: UIEdgeInsets(top: 40, left: 30, bottom: 40, right: 30),
                animated: !force
            )
        }

        func mapView(_ mapView: MLNMapView, lineWidthForPolylineAnnotation annotation: MLNPolyline) -> CGFloat {
            4
        }

        func mapView(_ mapView: MLNMapView, strokeColorForShapeAnnotation annotation: MLNShape) -> UIColor {
            UIColor(Theme.accent)
        }
    }
}

#endif
