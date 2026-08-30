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
                                fr: "À chaque kilomètre : le numéro, l'allure, le temps total. La voix baisse la musique, elle ne la coupe pas.",
                                en: "At every kilometer: the number, the pace, the total time. The voice ducks your music, it never stops it.",
                                es: "En cada kilómetro: el número, el ritmo, el tiempo total. La voz baja la música, no la corta."
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
                .tint(Theme.accent)
            }

            tracesCard
        }
        .onAppear {
            if let plannedRun { selectedType = plannedRun.type }
            hasStrayActivity = RunActivityController.hasAny
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

            RunMapView(points: tracker.points, showsCurrentPosition: true, loadsTiles: loadsTiles)
                .frame(height: 260)
                // Les points arrivent chaque seconde ; le contrôleur limite
                // lui-même la cadence réellement poussée au système.
                .onChange(of: tracker.points.count) { _, _ in
                    liveActivity.update(tracker.activitySnapshot(unit: unit, language: language))
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
