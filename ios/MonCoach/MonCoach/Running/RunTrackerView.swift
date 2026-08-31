import SwiftUI
import MonCoachKit
import UniformTypeIdentifiers

/// L'écran d'une sortie en cours.
///
/// Trois chiffres en grand, une carte, un bouton. Pendant une sortie, on lit
/// l'écran d'un coup d'œil en courant : tout ce qui demande à être cherché
/// ne sera pas lu.
struct RunTrackerView: View {
    var plannedRun: PlannedRun?

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var tracker = LocationTracker()
    @State private var selectedSport: Sport = .run
    @State private var selectedType: RunType = .easy
    @State private var finishedRun: ActivityLog?
    @State private var showsDiscardConfirmation = false
    @State private var liveActivity = RunActivityController()
    /// Reste-t-il une Live Activity affichée sans sortie en cours ?
    ///
    /// Relu à l'ouverture de l'écran plutôt qu'à la création de la vue : une
    /// activité peut apparaître ou disparaître entre les deux, et une valeur
    /// figée à l'initialisation afficherait un bouton pour rien — ou le
    /// cacherait quand il faudrait.
    @State private var hasStrayActivity = false
    @State private var showsImporter = false
    /// La voix des kilomètres. Créée une fois : le synthétiseur garde une
    /// file de phrases, en recréer un par annonce la viderait.
    @State private var announcer = VoiceAnnouncer()
    /// Annonces vocales au passage de chaque kilomètre. C'est une habitude
    /// d'écouteurs, pas un réglage de séance : elle se garde d'une sortie à
    /// l'autre.
    @AppStorage("annonces-vocales") private var speaksKilometres = true
    @State private var importError = false
    @State private var importedCount = 0
    /// Le parcours que l'athlète a choisi de suivre, s'il en a choisi un.
    @State private var followedRoute: PlannedRoute?
    /// L'écran de dessin, ouvert sur un parcours neuf ou sur un existant.
    @State private var planner: PlannerSheet?
    @State private var showsRouteImporter = false
    @State private var routeImportError = false
    /// A-t-on déjà dit qu'on était sorti du parcours ? Sans cette mémoire,
    /// la phrase se répéterait à chaque point GPS reçu, une fois par
    /// seconde, jusqu'à ce qu'on revienne.
    @State private var wasOffRoute = false

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var loadsTiles: Bool { store.profile?.loadsMapTiles ?? true }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    switch tracker.state {
                    case .idle, .requestingPermission:
                        prepareCard
                    case .denied:
                        deniedCard
                    case .running, .paused, .finished:
                        liveCard
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(UI.running[language])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) {
                        if tracker.isActive {
                            showsDiscardConfirmation = true
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .confirmationDialog(
                LocalizedText(
                    fr: "Abandonner cette sortie ?",
                    en: "Discard this run?",
                    es: "¿Descartar este rodaje?"
                )[language],
                isPresented: $showsDiscardConfirmation,
                titleVisibility: .visible
            ) {
                Button(UI.delete[language], role: .destructive) {
                    liveActivity.end()
                    tracker.reset()
                    dismiss()
                }
                Button(UI.cancel[language], role: .cancel) {}
            } message: {
                CoachText(
                    LocalizedText(
                        fr: "La trace enregistrée jusqu'ici sera perdue.",
                        en: "The trace recorded so far will be lost.",
                        es: "Se perderá la traza registrada hasta ahora."
                    )
                )
            }
            .sheet(item: $finishedRun) { run in
                RunSummaryView(run: run) {
                    finishedRun = nil
                    dismiss()
                }
            }
            .fileImporter(
                isPresented: $showsImporter,
                allowedContentTypes: [UTType(filenameExtension: "gpx") ?? .xml, .xml],
                allowsMultipleSelection: true
            ) { result in
                importedCount = 0
                guard case .success(let urls) = result else { return }
                for url in urls {
                    // L'accès sécurisé est requis pour un fichier venu des
                    // Fichiers ou d'AirDrop ; sans lui, la lecture échoue en
                    // silence sur un vrai appareil.
                    let secured = url.startAccessingSecurityScopedResource()
                    defer { if secured { url.stopAccessingSecurityScopedResource() } }
                    guard let text = try? String(contentsOf: url, encoding: .utf8),
                          (try? store.importGPX(text)) != nil
                    else {
                        importError = true
                        continue
                    }
                    importedCount += 1
                }
            }
            .alert(
                LocalizedText(
                    fr: "Ce fichier n'a pas pu être lu",
                    en: "This file could not be read",
                    es: "No se ha podido leer este archivo"
                )[language],
                isPresented: $importError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                CoachText(
                    LocalizedText(
                        fr: "Le fichier doit être un GPX avec des points horodatés.",
                        en: "The file must be a GPX with timestamped points.",
                        es: "El archivo debe ser un GPX con puntos con marca de tiempo."
                    )
                )
            }
            // Un deuxième import, et pas le même : celui-ci lit un parcours
            // à suivre, sans horodatage, et n'entre pas dans l'historique.
            .fileImporter(
                isPresented: $showsRouteImporter,
                allowedContentTypes: [UTType(filenameExtension: "gpx") ?? .xml, .xml],
                allowsMultipleSelection: false
            ) { result in
                guard case .success(let urls) = result, let url = urls.first else { return }
                let secured = url.startAccessingSecurityScopedResource()
                defer { if secured { url.stopAccessingSecurityScopedResource() } }
                let fallback = url.deletingPathExtension().lastPathComponent
                guard let text = try? String(contentsOf: url, encoding: .utf8) else {
                    routeImportError = true
                    return
                }
                // Nil pour deux raisons différentes — fichier illisible, ou
                // parcours trop court —, et l'athlète n'a pas à les
                // distinguer : dans les deux cas rien n'a été enregistré.
                let imported = try? store.importRouteGPX(
                    text, named: fallback, fallbackSport: selectedSport
                )
                if imported == nil { routeImportError = true }
            }
            .alert(
                LocalizedText(
                    fr: "Ce parcours n'a pas pu être lu",
                    en: "This route could not be read",
                    es: "No se ha podido leer este recorrido"
                )[language],
                isPresented: $routeImportError
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                CoachText(
                    LocalizedText(
                        fr: "Le fichier doit être un GPX contenant au moins deux points, et faire plus de trois cents mètres.",
                        en: "The file must be a GPX with at least two points, and longer than three hundred metres.",
                        es: "El archivo debe ser un GPX con al menos dos puntos y de más de trescientos metros."
                    )
                )
            }
            .sheet(item: $planner) { sheet in
                RoutePlannerView(existing: sheet.route)
            }
        }
    }

    // MARK: - Avant le départ

    private var prepareCard: some View {
        VStack(spacing: Theme.stackSpacing) {
            // Le vestige d'une sortie qui ne s'est pas terminée proprement.
            // Le lancement en fait le ménage tout seul, mais l'application
            // peut très bien être déjà ouverte quand ça arrive : le bouton
            // existe pour ce cas-là, et pour qu'on ne reste jamais coincé
            // avec un bandeau qu'on ne sait pas retirer.
            if hasStrayActivity {
                Card(
                    title: LocalizedText(
                        fr: "Une sortie est restée affichée",
                        en: "A run is still on your lock screen",
                        es: "Un rodaje sigue en la pantalla de bloqueo"
                    )[language]
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        CoachText(
                            LocalizedText(
                                fr: "Elle vient d'une sortie précédente qui ne s'est pas refermée. Rien n'est enregistré dessus, et la retirer n'efface aucune trace.",
                                en: "It comes from an earlier run that never closed. Nothing is being recorded on it, and removing it deletes no trace.",
                                es: "Viene de un rodaje anterior que no se cerró. No registra nada, y quitarla no borra ninguna traza."
                            )
                        )
                        Button {
                            RunActivityController.endAll()
                            WorkoutActivityController.endAll()
                            liveActivity.forget()
                            hasStrayActivity = false
                        } label: {
                            Text(
                                LocalizedText(
                                    fr: "La retirer",
                                    en: "Remove it",
                                    es: "Quitarla"
                                )[language]
                            )
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if let plannedRun {
                Card(title: plannedRun.type.label[language]) {
                    VStack(alignment: .leading, spacing: 10) {
                        CoachText(plannedRun.note, color: Theme.primaryText)
                        if let target = plannedRun.targetMeters, target > 0 {
                            HStack(spacing: 16) {
                                StatTile(
                                    value: Format.distance(meters: target, unit: unit, language: language),
                                    label: LocalizedText(fr: "Objectif", en: "Target", es: "Objetivo")[language]
                                )
                                if let range = plannedRun.paceRangeSecondsPerKm {
                                    StatTile(
                                        value: "\(Format.pace(secondsPerKm: range.lowerBound, unit: unit))"
                                            + " – \(Format.pace(secondsPerKm: range.upperBound, unit: unit))",
                                        label: UI.pace[language]
                                    )
                                }
                            }
                        }
                        ForEach(plannedRun.intervals, id: \.self) { interval in
                            Text("\(interval.repetitions) × \(Int(interval.meters)) m")
                                .font(Theme.headlineFont)
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
            }

            // Le sport d'abord : c'est lui qui règle les filtres GPS et la
            // façon de dire la vitesse. Une sortie prescrite est de la
            // course, le choix disparaît.
            if plannedRun == nil {
                Card(title: LocalizedText(fr: "Sport", en: "Sport", es: "Deporte")[language]) {
                    FlowLayout(spacing: 8) {
                        ForEach(Sport.allCases) { sport in
                            Button {
                                selectedSport = sport
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: sport.symbolName)
                                        .font(.system(size: 12))
                                    Text(sport.label[language])
                                }
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(selectedSport == sport ? Theme.background : Theme.primaryText)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    selectedSport == sport ? Theme.accent : Theme.surfaceRaised,
                                    in: Capsule()
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // L'intention de séance n'a de sens qu'en courant : un « tempo »
            // à vélo ou en randonnée ne pilote aucun plan.
            if selectedSport.feedsRunningPlan {
                Card(
                    title: LocalizedText(fr: "Type de sortie", en: "Run type", es: "Tipo de rodaje")[language]
                ) {
                    VStack(alignment: .leading, spacing: 10) {
                        FlowLayout(spacing: 8) {
                            ForEach(RunType.allCases, id: \.self) { type in
                                Button {
                                    selectedType = type
                                } label: {
                                    Pill(
                                        text: type.label[language],
                                        tint: selectedType == type ? Theme.accent : Theme.secondaryText
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        CoachText(selectedType.purpose)
                    }
                }
            }

            PrimaryButton(title: UI.start[language], systemImage: selectedSport.symbolName) {
                wasOffRoute = false
                tracker.start(
                    sport: plannedRun == nil ? selectedSport : .run,
                    type: selectedSport.feedsRunningPlan ? selectedType : .easy
                )
                liveActivity.start(
                    id: UUID(),
                    snapshot: tracker.activitySnapshot(unit: unit, language: language)
                )
            }

            // La carte avant le départ : voir le point bleu se poser sur la
            // bonne rue, c'est voir le GPS se caler — exactement ce que le
            // conseil en dessous demande d'attendre. Sans fond de carte
            // autorisé, il n'y a rien à montrer ici : la trace n'existe pas
            // encore, et un rectangle gris n'aiderait personne.
            if loadsTiles {
                RunMapView(points: [], showsCurrentPosition: true, loadsTiles: true)
                    .frame(height: 220)
            }

            CoachText(
                LocalizedText(
                    fr: "Le GPS met souvent trente secondes à se caler. Attends que la précision passe au vert avant de partir, sinon les premiers hectomètres seront faux.",
                    en: "GPS often takes thirty seconds to settle. Wait for the accuracy to turn green before you set off, or the first few hundred metres will be wrong.",
                    es: "El GPS suele tardar treinta segundos en asentarse. Espera a que la precisión se ponga en verde antes de salir, o los primeros cientos de metros saldrán mal."
                )
            )

            Card {
                Toggle(isOn: $speaksKilometres) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(
                            LocalizedText(
                                fr: "Annonces vocales",
                                en: "Voice announcements",
                                es: "Avisos de voz"
                            )[language]
                        )
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.primaryText)
                        Text(
                            LocalizedText(
                                fr: "À chaque kilomètre : le numéro, l'allure, le temps total — et un mot si tu quittes ton parcours. La voix baisse la musique, elle ne la coupe pas.",
                                en: "At every kilometer: the number, the pace, the total time — and a word if you leave your route. The voice ducks your music, it never stops it.",
                                es: "En cada kilómetro: el número, el ritmo, el tiempo total, y un aviso si te sales del recorrido. La voz baja la música, no la corta."
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
                .tint(Theme.accent)
            }

            routesCard
            tracesCard
        }
        .onAppear {
            if let plannedRun { selectedType = plannedRun.type }
            hasStrayActivity = RunActivityController.hasAny
        }
    }

    /// Les parcours préparés : en choisir un, en dessiner un, en importer un.
    ///
    /// Un parcours choisi ici s'affiche pendant toute la sortie, sous la
    /// trace : c'est la différence entre « douze kilomètres » et « ces
    /// douze kilomètres-là ».
    private var routesCard: some View {
        let sport = plannedRun == nil ? selectedSport : .run
        let available = store.routes(for: sport)
        return Card(
            title: LocalizedText(fr: "Tes parcours", en: "Your routes", es: "Tus recorridos")[language],
            subtitle: followedRoute.map { route in
                LocalizedText(
                    fr: "Tu suis « \(route.name) » : il s'affichera sur la carte.",
                    en: "You are following “\(route.name)”: it will show on the map.",
                    es: "Sigues «\(route.name)»: aparecerá en el mapa."
                )[language]
            }
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if available.isEmpty {
                    CoachText(
                        LocalizedText(
                            fr: "Aucun parcours pour l'instant. Dessine-en un sur la carte, importe un GPX, ou reprends une sortie que tu as aimée depuis sa fiche du journal.",
                            en: "No routes yet. Draw one on the map, import a GPX, or turn an activity you enjoyed into one from its journal page.",
                            es: "Aún no hay recorridos. Dibuja uno en el mapa, importa un GPX o convierte en recorrido una salida que te haya gustado desde su ficha."
                        )
                    )
                }
                ForEach(available) { route in
                    routeRow(route)
                }
                HStack(spacing: 8) {
                    GhostButton(
                        title: LocalizedText(fr: "Dessiner", en: "Draw", es: "Dibujar")[language],
                        systemImage: "pencil.and.outline"
                    ) {
                        planner = PlannerSheet(route: nil)
                    }
                    GhostButton(
                        title: LocalizedText(fr: "Importer", en: "Import", es: "Importar")[language],
                        systemImage: "square.and.arrow.down"
                    ) {
                        showsRouteImporter = true
                    }
                }
            }
        }
    }

    private func routeRow(_ route: PlannedRoute) -> some View {
        let isFollowed = followedRoute?.id == route.id
        return HStack(spacing: 10) {
            Button {
                // Un deuxième appui repose le parcours : suivre est un choix
                // qu'on doit pouvoir défaire sans chercher où.
                followedRoute = isFollowed ? nil : route
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isFollowed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isFollowed ? Theme.accent : Theme.secondaryText)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(route.name)
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                            .lineLimit(1)
                        Text(
                            Format.distance(meters: route.meters, unit: unit, language: language)
                            + (route.isLoop
                               ? " · " + LocalizedText(fr: "boucle", en: "loop", es: "bucle")[language]
                               : "")
                        )
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            Menu {
                Button {
                    planner = PlannerSheet(route: route)
                } label: {
                    Label(
                        LocalizedText(fr: "Modifier", en: "Edit", es: "Modificar")[language],
                        systemImage: "pencil"
                    )
                }
                ShareLink(
                    item: RouteFile(route: route),
                    preview: SharePreview(route.name)
                ) {
                    Label(
                        LocalizedText(fr: "Exporter en GPX", en: "Export as GPX", es: "Exportar en GPX")[language],
                        systemImage: "square.and.arrow.up"
                    )
                }
                Button(role: .destructive) {
                    if isFollowed { followedRoute = nil }
                    store.deleteRoute(route.id)
                } label: {
                    Label(UI.delete[language], systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    /// L'entrée et la sortie des traces, à portée de main de l'écran Course.
    ///
    /// Les deux existaient déjà — l'import dans le Journal, l'export sur la
    /// fiche de chaque sortie — mais c'est ici qu'on pense à elles : au
    /// moment de courir, pas en relisant l'historique. Le même geste, au
    /// même endroit que le besoin.
    private var tracesCard: some View {
        Card(
            title: LocalizedText(fr: "Tes traces", en: "Your traces", es: "Tus trazas")[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(
                    LocalizedText(
                        fr: "Importe un GPX d'une montre ou d'une autre application : il entre dans l'historique et compte pour tes records. Chaque sortie s'exporte aussi depuis sa fiche du journal.",
                        en: "Import a GPX from a watch or another app: it joins your history and counts towards your records. Every activity also exports from its journal page.",
                        es: "Importa un GPX de un reloj o de otra aplicación: entra en tu historial y cuenta para tus récords. Cada salida también se exporta desde su ficha del diario."
                    )
                )
                if importedCount > 0 {
                    Pill(text: LocalizedText(
                        fr: "\(importedCount) importée(s)",
                        en: "\(importedCount) imported",
                        es: "\(importedCount) importada(s)"
                    )[language])
                }
                GhostButton(
                    title: LocalizedText(fr: "Importer un GPX", en: "Import a GPX", es: "Importar un GPX")[language],
                    systemImage: "square.and.arrow.down"
                ) {
                    showsImporter = true
                }
                if let last = store.history.activities.last {
                    // Le fichier se fabrique au moment du partage seulement,
                    // comme sur la fiche : un GPX de sortie longue pèse des
                    // mégaoctets.
                    ShareLink(
                        item: GPXFile(activity: last),
                        preview: SharePreview(GPX.trackName(for: last))
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text(
                                LocalizedText(
                                    fr: "Exporter la dernière sortie",
                                    en: "Export the latest activity",
                                    es: "Exportar la última salida"
                                )[language]
                            )
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(Theme.primaryText)
                    }
                }
            }
        }
    }

    private var deniedCard: some View {
        Card(title: LocalizedText(fr: "GPS refusé", en: "Location denied", es: "Ubicación denegada")[language]) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(
                    LocalizedText(
                        fr: "Sans accès à ta position, l'application ne peut pas mesurer une sortie. Tu peux l'autoriser dans Réglages › Confidentialité › Service de localisation, ou enregistrer la sortie à la main.",
                        en: "Without access to your location, the app cannot measure a run. You can allow it in Settings › Privacy › Location Services, or log the run by hand.",
                        es: "Sin acceso a tu ubicación, la aplicación no puede medir un rodaje. Puedes permitirlo en Ajustes › Privacidad › Localización, o registrar el rodaje a mano."
                    ),
                    color: Theme.primaryText
                )
            }
        }
    }

    // MARK: - Pendant la sortie

    private var liveCard: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card {
                VStack(spacing: 14) {
                    Text(Format.distance(meters: tracker.meters, unit: unit, language: language))
                        .font(Theme.numberFont)
                        .foregroundStyle(Theme.accent)
                    HStack(spacing: 12) {
                        StatTile(
                            value: Format.stopwatch(seconds: tracker.movingDuration),
                            label: UI.duration[language]
                        )
                        StatTile(
                            value: Format.speedOrPace(
                                sport: tracker.sport,
                                secondsPerKm: tracker.recentPaceSecondsPerKm,
                                unit: unit,
                                language: language
                            ),
                            label: UI.pace[language]
                        )
                        StatTile(
                            value: "\(Int(tracker.elevationGain)) m",
                            label: UI.elevation[language]
                        )
                    }
                    signalRow
                }
            }

            routeProgressCard

            RunMapView(
                points: tracker.points,
                route: followedRoute?.points ?? [],
                showsCurrentPosition: true,
                loadsTiles: loadsTiles
            )
            .frame(height: 260)
            // Les points arrivent chaque seconde ; le contrôleur limite
            // lui-même la cadence réellement poussée au système, et l'écart
            // au parcours n'est dit qu'aux changements d'état.
            .onChange(of: tracker.points.count) { _, _ in
                liveActivity.update(tracker.activitySnapshot(unit: unit, language: language))
                announceRouteDeviation()
            }

            if !tracker.splits.isEmpty {
                Card(title: UI.splits[language]) {
                    SplitList(splits: tracker.splits, unit: unit)
                }
                .onChange(of: tracker.splits.count) { previous, current in
                    // Un kilomètre vient de se boucler. Le dernier segment de
                    // la liste est souvent entamé, pas fini : celui qu'on
                    // annonce est le dernier complet.
                    guard speaksKilometres, current > previous,
                          let done = tracker.splits.last(where: { $0.meters >= 950 })
                    else { return }
                    announcer.announce(
                        split: done,
                        totalSeconds: tracker.movingDuration,
                        language: language
                    )
                }
            }

            HStack(spacing: 12) {
                if tracker.state == .running {
                    GhostButton(title: UI.pause[language], systemImage: "pause.fill") {
                        tracker.pause()
                        liveActivity.update(
                            tracker.activitySnapshot(unit: unit, language: language),
                            force: true
                        )
                    }
                } else if tracker.state == .paused {
                    GhostButton(title: UI.resume[language], systemImage: "play.fill") {
                        tracker.resume()
                        liveActivity.update(
                            tracker.activitySnapshot(unit: unit, language: language),
                            force: true
                        )
                    }
                }
                PrimaryButton(title: UI.finish[language], systemImage: "flag.checkered") {
                    liveActivity.end()
                    if let run = tracker.finish() {
                        finishedRun = run
                    } else {
                        tracker.reset()
                        dismiss()
                    }
                }
            }
        }
    }

    /// Où l'on en est du parcours suivi.
    ///
    /// Deux choses seulement : ce qu'il reste, et si l'on est encore dessus.
    /// En courant, on lit l'écran d'un coup d'œil — tout le reste attendra
    /// la fin de la sortie.
    @ViewBuilder
    private var routeProgressCard: some View {
        if let followedRoute, let last = tracker.points.last {
            let position = RoutePoint(latitude: last.latitude, longitude: last.longitude)
            let remaining = RoutePlanner.remainingMeters(from: position, on: followedRoute.points)
            let offRoute = RoutePlanner.isOffRoute(position, from: followedRoute.points)
            Card(title: followedRoute.name) {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        if let remaining {
                            StatTile(
                                value: Format.distance(meters: remaining, unit: unit, language: language),
                                label: LocalizedText(
                                    fr: "Restant", en: "Remaining", es: "Restante"
                                )[language]
                            )
                        }
                        StatTile(
                            value: Format.distance(
                                meters: followedRoute.meters, unit: unit, language: language
                            ),
                            label: LocalizedText(
                                fr: "Le parcours", en: "The route", es: "El recorrido"
                            )[language],
                            tint: Theme.secondaryText
                        )
                    }
                    if offRoute {
                        HStack {
                            Pill(
                                text: LocalizedText(
                                    fr: "Tu t'es écarté du parcours",
                                    en: "You have left the route",
                                    es: "Te has salido del recorrido"
                                )[language],
                                tint: Theme.warning
                            )
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    /// Dit à voix haute qu'on a quitté le parcours, et qu'on y est revenu.
    ///
    /// Le téléphone est dans une poche : une pastille à l'écran ne sert à
    /// rien pour ça. La phrase ne sort qu'aux changements d'état, jamais en
    /// boucle — c'est tout l'objet de `wasOffRoute`.
    private func announceRouteDeviation() {
        guard let followedRoute, let last = tracker.points.last else { return }
        let position = RoutePoint(latitude: last.latitude, longitude: last.longitude)
        let offRoute = RoutePlanner.isOffRoute(position, from: followedRoute.points)
        guard offRoute != wasOffRoute else { return }
        wasOffRoute = offRoute
        guard speaksKilometres else { return }
        announcer.speak(
            offRoute
                ? LocalizedText(
                    fr: "Tu es sorti du parcours.",
                    en: "You have left the route.",
                    es: "Te has salido del recorrido."
                )[language]
                : LocalizedText(
                    fr: "Te revoilà sur le parcours.",
                    en: "You are back on the route.",
                    es: "Ya estás de vuelta en el recorrido."
                )[language],
            language: language
        )
    }

    private var signalRow: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(tracker.hasUsableSignal ? Theme.accent : Theme.warning)
                .frame(width: 8, height: 8)
            Text(signalText[language])
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            Spacer()
            if tracker.state == .paused {
                Pill(text: UI.pause[language], tint: Theme.warning)
            } else if tracker.isStationary {
                // Le chrono exclut déjà les arrêts ; sans ce mot, il a l'air
                // figé par un bug alors qu'il attend, comme promis.
                Pill(
                    text: LocalizedText(
                        fr: "À l'arrêt — le chrono attend",
                        en: "Stopped — the clock is waiting",
                        es: "Parado — el crono espera"
                    )[language],
                    tint: Theme.secondaryText
                )
            }
        }
    }

    private var signalText: LocalizedText {
        guard tracker.currentAccuracy >= 0 else {
            return LocalizedText(
                fr: "Recherche du signal GPS…",
                en: "Looking for GPS signal…",
                es: "Buscando señal GPS…"
            )
        }
        let metres = Int(tracker.currentAccuracy.rounded())
        return tracker.hasUsableSignal
            ? LocalizedText(
                fr: "Signal correct, précision ±\(metres) m",
                en: "Signal fine, accuracy ±\(metres) m",
                es: "Señal correcta, precisión ±\(metres) m"
            )
            : LocalizedText(
                fr: "Signal faible, précision ±\(metres) m : les points imprécis sont écartés.",
                en: "Weak signal, accuracy ±\(metres) m: imprecise points are being discarded.",
                es: "Señal débil, precisión ±\(metres) m: los puntos imprecisos se descartan."
            )
    }
}

/// La liste des kilomètres, avec une barre proportionnelle à l'allure.
struct SplitList: View {
    var splits: [Split]
    var unit: UnitSystem

    @Environment(\.language) private var language

    private var fastest: Double {
        splits.map(\.paceSecondsPerKm).filter { $0 > 0 }.min() ?? 1
    }
    private var slowest: Double {
        splits.map(\.paceSecondsPerKm).filter { $0 > 0 }.max() ?? 1
    }

    var body: some View {
        VStack(spacing: 8) {
            ForEach(splits) { split in
                HStack(spacing: 10) {
                    Text("\(split.index)")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .frame(width: 20, alignment: .leading)
                    ProgressBar(value: barValue(for: split), tint: Theme.accent)
                    Text(Format.pace(secondsPerKm: split.paceSecondsPerKm, unit: unit))
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.primaryText)
                        .frame(width: 76, alignment: .trailing)
                    if split.elevationGain >= 5 {
                        Text("+\(Int(split.elevationGain))")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.warning)
                            .frame(width: 34, alignment: .trailing)
                    } else {
                        Spacer().frame(width: 34)
                    }
                }
            }
            if splits.contains(where: { $0.meters < 950 }) {
                CoachText(
                    LocalizedText(
                        fr: "Le dernier segment est incomplet : son allure est ramenée au kilomètre, elle reste comparable.",
                        en: "The last split is incomplete: its pace is scaled to a full kilometre, so it stays comparable.",
                        es: "El último parcial está incompleto: su ritmo se escala a un kilómetro completo, así que sigue siendo comparable."
                    ),
                    font: .system(size: 11)
                )
            }
        }
    }

    /// Une barre pleine pour le kilomètre le plus rapide, courte pour le plus
    /// lent. Comparer les kilomètres entre eux dit bien plus que les comparer
    /// à une allure absolue.
    private func barValue(for split: Split) -> Double {
        guard slowest > fastest else { return 1 }
        return 1 - (split.paceSecondsPerKm - fastest) / (slowest - fastest) * 0.75
    }
}

/// L'écran de dessin, ouvert sur un parcours neuf ou sur un existant.
///
/// Une enveloppe identifiable plutôt que deux booléens : « je dessine » et
/// « je modifie celui-là » sont le même écran, et deux feuilles concurrentes
/// finiraient par s'ouvrir ensemble.
struct PlannerSheet: Identifiable {
    let id = UUID()
    var route: PlannedRoute?
}

/// Un parcours au format GPX, fabriqué au moment du partage seulement.
struct RouteFile: Transferable {
    var route: PlannedRoute

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .xml) { file in
            Data(GPX.document(for: file.route).utf8)
        }
        .suggestedFileName { file in "\(file.route.name).gpx" }
    }
}
