import SwiftUI
import MonCoachKit

/// « Ce tour-là, tu l'as fait vingt-trois fois. »
///
/// Pourquoi cette carte existe
/// ---------------------------
/// La carte des traces montre où l'on va ; elle ne dit pas ce qu'on répète.
/// Or le trajet habituel est le seul cadre où deux sorties sont vraiment
/// comparables — même montée, même vent dominant, mêmes feux rouges — et
/// c'est donc là, et nulle part ailleurs, qu'un progrès se lit sans
/// discussion.
///
/// Rien n'est nommé à la place de l'athlète : l'application ne connaît
/// aucune carte routière, et baptiser un trajet « Boucle du canal » serait
/// une invention. Elle dit la distance et la forme, et propose d'en faire
/// un parcours à suivre.
struct FrequentRoutesCard: View {
    var routes: [FrequentRoute]

    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    /// Le trajet qu'on vient d'enregistrer comme parcours, le temps de le
    /// dire. Nil le reste du temps.
    @State private var saved: UUID?

    private var unit: UnitSystem { store.profile?.unit ?? .metric }

    var body: some View {
        Card(
            title: LocalizedText(
                fr: "Tes trajets les plus pris",
                en: "The routes you take most",
                es: "Las rutas que más tomas"
            )[language],
            subtitle: LocalizedText(
                fr: "Reconnus en comparant tes traces entre elles, sans aucune carte : trois passages suffisent à parler d'habitude.",
                en: "Recognised by comparing your traces with each other, with no map involved: three passes are enough to call it a habit.",
                es: "Reconocidas comparando tus trazas entre sí, sin ningún mapa: tres pasadas bastan para hablar de costumbre."
            )[language]
        ) {
            VStack(spacing: 14) {
                ForEach(routes.prefix(4)) { route in
                    row(route)
                    if route.id != routes.prefix(4).last?.id {
                        Divider().background(Theme.separator)
                    }
                }
            }
        }
    }

    private func row(_ route: FrequentRoute) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TraceThumbnail(points: route.points)
                    .frame(width: 54, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(FrequentRoutes.suggestedName(for: route, language: language))
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                    HStack(spacing: 6) {
                        Image(systemName: route.sport.symbolName)
                            .font(.system(size: 10))
                        Text(
                            LocalizedText(
                                fr: "\(route.timesDone) fois",
                                en: "\(route.timesDone) times",
                                es: "\(route.timesDone) veces"
                            )[language]
                        )
                        Text("·")
                        Text(Format.distance(meters: route.meters, unit: unit, language: language))
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                }
                Spacer()
            }

            HStack(spacing: 12) {
                StatTile(
                    value: Format.stopwatch(seconds: route.bestSeconds),
                    label: LocalizedText(fr: "Meilleur", en: "Best", es: "Mejor")[language]
                )
                StatTile(
                    value: Format.stopwatch(seconds: route.lastSeconds),
                    label: LocalizedText(fr: "Dernière fois", en: "Last time", es: "Última vez")[language],
                    tint: route.lastWasBest ? Theme.accent : Theme.secondaryText
                )
                if let pace = route.bestPaceSecondsPerKm, route.sport.readout == .pacePerKilometre {
                    StatTile(
                        value: Format.pace(secondsPerKm: pace, unit: unit),
                        label: UI.pace[language]
                    )
                }
            }

            // Le trajet devient un parcours à suivre : c'est ce qui relie
            // « je fais souvent ça » à « je le refais maintenant, avec la
            // ligne sous les yeux ».
            Button {
                save(route)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: saved == route.id ? "checkmark.circle.fill" : "point.topleft.down.to.point.bottomright.curvepath")
                        .font(.system(size: 12, weight: .semibold))
                    Text(
                        saved == route.id
                            ? LocalizedText(
                                fr: "Ajouté à tes parcours",
                                en: "Added to your routes",
                                es: "Añadido a tus recorridos"
                            )[language]
                            : LocalizedText(
                                fr: "En faire un parcours à suivre",
                                en: "Make it a route to follow",
                                es: "Convertirlo en un recorrido"
                            )[language]
                    )
                    .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(saved == route.id ? Theme.accent : Theme.accent)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(saved == route.id)
        }
    }

    private func save(_ route: FrequentRoute) {
        guard let activity = store.history.activities.first(where: { $0.id == route.id }),
              let planned = RoutePlanner.route(
                from: activity,
                named: FrequentRoutes.suggestedName(for: route, language: language)
              ),
              store.saveRoute(planned)
        else { return }
        saved = route.id
    }
}

/// Une trace en tout petit : la forme d'un trajet, sans fond de carte.
///
/// Sans fond, et c'est délibéré : une vignette de carte demanderait une
/// tuile au réseau pour chaque ligne de la liste. La forme suffit à
/// reconnaître son propre parcours — c'est même à ça qu'on le reconnaît.
struct TraceThumbnail: View {
    var points: [GPSPoint]

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.surfaceRaised))
            let trace = RoutesCanvas.thinned(points)
            guard trace.count >= 2,
                  let minLat = trace.map(\.latitude).min(),
                  let maxLat = trace.map(\.latitude).max(),
                  let minLon = trace.map(\.longitude).min(),
                  let maxLon = trace.map(\.longitude).max()
            else { return }

            let midLatRadians = (minLat + maxLat) / 2 * .pi / 180
            let spanX = max(0.000001, (maxLon - minLon) * cos(midLatRadians))
            let spanY = max(0.000001, maxLat - minLat)
            let inset: CGFloat = 6
            let scale = min((size.width - inset * 2) / spanX, (size.height - inset * 2) / spanY)
            let offsetX = (size.width - spanX * scale) / 2
            let offsetY = (size.height - spanY * scale) / 2

            var path = Path()
            for (index, point) in trace.enumerated() {
                let position = CGPoint(
                    x: offsetX + (point.longitude - minLon) * cos(midLatRadians) * scale,
                    y: offsetY + (maxLat - point.latitude) * scale
                )
                if index == 0 { path.move(to: position) } else { path.addLine(to: position) }
            }
            context.stroke(
                path,
                with: .color(Theme.accent),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
        }
    }
}
