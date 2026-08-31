import SwiftUI
import MonCoachKit

/// Dessiner un parcours avant de sortir.
///
/// Pourquoi cet écran existe
/// -------------------------
/// « Je veux courir douze kilomètres ce soir » n'est pas une question
/// d'entraînement, c'est une question de géographie : par où ? Sans réponse,
/// on refait le même tour depuis trois ans, ou on part au hasard et on
/// rentre à huit ou à seize.
///
/// Le parcours se pose à la main, point par point, et la distance se met à
/// jour à chaque appui. Aucun calcul d'itinéraire : celui-là demanderait un
/// serveur de routage, donc d'envoyer à quelqu'un l'endroit où l'on veut
/// aller courir — exactement ce que cette application a promis de ne jamais
/// faire. Le trait est droit d'un point à l'autre, et c'est à l'athlète de
/// poser assez de points pour suivre ses rues.
struct RoutePlannerView: View {
    /// Le parcours à reprendre, ou nil pour en commencer un.
    var existing: PlannedRoute?

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var points: [RoutePoint] = []
    @State private var name: String = ""
    @State private var sport: Sport = .run
    @State private var tooShort = false

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var loadsTiles: Bool { store.profile?.loadsMapTiles ?? true }
    private var meters: Double { RoutePlanner.length(of: points) }

    /// Le temps que ce parcours prendra, à l'allure d'endurance de l'athlète.
    ///
    /// L'allure de seuil est ce que le profil connaît ; une sortie tranquille
    /// se court environ une minute au kilomètre plus lentement. Sans seuil
    /// connu, rien n'est affiché : un temps inventé serait pire que pas de
    /// temps du tout.
    private var estimatedSeconds: TimeInterval? {
        guard let threshold = store.profile?.running?.thresholdPaceSecondsPerKm else { return nil }
        return RoutePlanner.estimatedSeconds(meters: meters, paceSecondsPerKm: threshold + 60)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if loadsTiles {
                    RunMapView(
                        points: [],
                        route: points,
                        showsCurrentPosition: true,
                        loadsTiles: true,
                        onTapCoordinate: { points.append($0) }
                    )
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, 12)
                } else {
                    noMapCard
                        .padding(16)
                    Spacer()
                }
                controls
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(
                    fr: "Dessiner un parcours",
                    en: "Draw a route",
                    es: "Dibujar un recorrido"
                )[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.cancel[language]) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(UI.save[language]) { save() }
                        .disabled(points.count < 2 || name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert(
                LocalizedText(
                    fr: "Ce parcours est trop court",
                    en: "This route is too short",
                    es: "Este recorrido es demasiado corto"
                )[language],
                isPresented: $tooShort
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                CoachText(
                    LocalizedText(
                        fr: "Il faut au moins trois cents mètres — en dessous, c'est un point posé par erreur plutôt qu'un parcours.",
                        en: "It needs at least three hundred metres — below that it is a stray tap, not a route.",
                        es: "Necesita al menos trescientos metros: por debajo es un toque perdido, no un recorrido."
                    )
                )
            }
            .onAppear(perform: load)
        }
    }

    private var noMapCard: some View {
        Card(
            title: LocalizedText(
                fr: "Le fond de carte est désactivé",
                en: "The map background is off",
                es: "El fondo de mapa está desactivado"
            )[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Dessiner un parcours demande de voir les rues, et donc de charger le fond de carte. Tu peux l'autoriser dans ton profil — ou importer un parcours en GPX, ce qui ne demande aucun réseau.",
                    en: "Drawing a route means seeing the streets, which means loading the map background. You can allow it in your profile — or import a GPX route, which needs no network at all.",
                    es: "Dibujar un recorrido exige ver las calles, y por tanto cargar el fondo de mapa. Puedes permitirlo en tu perfil, o importar un recorrido en GPX, que no necesita red."
                )
            )
        }
    }

    // MARK: - Les commandes

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                StatTile(
                    value: Format.distance(meters: meters, unit: unit, language: language),
                    label: UI.distance[language]
                )
                if let estimatedSeconds {
                    StatTile(
                        value: Format.stopwatch(seconds: estimatedSeconds),
                        label: LocalizedText(
                            fr: "Temps prévu", en: "Expected time", es: "Tiempo previsto"
                        )[language],
                        tint: Theme.secondaryText
                    )
                }
                StatTile(
                    value: "\(points.count)",
                    label: LocalizedText(fr: "Points", en: "Points", es: "Puntos")[language],
                    tint: Theme.secondaryText
                )
            }

            if points.isEmpty {
                CoachText(
                    LocalizedText(
                        fr: "Touche la carte pour poser le départ, puis suis tes rues point par point. Le trait va droit d'un point au suivant : dans un virage, pose-en un de plus.",
                        en: "Tap the map to drop the start, then follow your streets point by point. The line runs straight from one point to the next: in a bend, drop one more.",
                        es: "Toca el mapa para poner la salida y sigue tus calles punto a punto. La línea va recta de un punto al siguiente: en una curva, pon uno más."
                    ),
                    font: Theme.captionFont
                )
            }

            HStack(spacing: 8) {
                controlButton(
                    LocalizedText(fr: "Annuler", en: "Undo", es: "Deshacer"),
                    icon: "arrow.uturn.backward",
                    enabled: !points.isEmpty
                ) {
                    points.removeLast()
                }
                controlButton(
                    LocalizedText(fr: "Boucler", en: "Close loop", es: "Cerrar"),
                    icon: "arrow.triangle.capsulepath",
                    enabled: points.count >= 3
                ) {
                    // Revenir au départ est le geste le plus courant d'un
                    // parcours, et le refaire à la main au pixel près est
                    // impossible : le bouton repose exactement le premier
                    // point.
                    if let first = points.first { points.append(first) }
                }
                controlButton(
                    LocalizedText(fr: "Effacer", en: "Clear", es: "Borrar"),
                    icon: "trash",
                    enabled: !points.isEmpty
                ) {
                    points = []
                }
            }

            TextField(
                LocalizedText(
                    fr: "Le nom de ce parcours",
                    en: "The name of this route",
                    es: "El nombre de este recorrido"
                )[language],
                text: $name
            )
            .textFieldStyle(.plain)
            .font(Theme.bodyFont)
            .foregroundStyle(Theme.primaryText)
            .padding(12)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))

            Picker("", selection: $sport) {
                ForEach(Sport.allCases) { sport in
                    Text(sport.label[language]).tag(sport)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .background(Theme.surface)
    }

    private func controlButton(
        _ title: LocalizedText,
        icon: String,
        enabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(title[language])
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(enabled ? Theme.primaryText : Theme.secondaryText)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    // MARK: - Entrer et sortir

    private func load() {
        guard let existing, points.isEmpty else { return }
        points = existing.points
        name = existing.name
        sport = existing.sport
    }

    private func save() {
        let route = PlannedRoute(
            // Reprendre un parcours garde son identifiant : sans cela,
            // corriger un virage laisserait l'ancienne version dans la liste.
            id: existing?.id ?? UUID(),
            name: name.trimmingCharacters(in: .whitespaces),
            createdAt: existing?.createdAt ?? Date(),
            sport: sport,
            points: points
        )
        if store.saveRoute(route) {
            dismiss()
        } else {
            tooShort = true
        }
    }
}
