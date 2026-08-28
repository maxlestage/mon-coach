import SwiftUI
import MonCoachKit

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
    @State private var selectedType: RunType = .easy
    @State private var finishedRun: ActivityLog?
    @State private var showsDiscardConfirmation = false
    @State private var liveActivity = RunActivityController()

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
        }
    }

    // MARK: - Avant le départ

    private var prepareCard: some View {
        VStack(spacing: Theme.stackSpacing) {
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

            PrimaryButton(title: UI.start[language], systemImage: "figure.run") {
                tracker.start(type: selectedType)
                liveActivity.start(
                    id: UUID(),
                    snapshot: tracker.activitySnapshot(unit: unit, language: language)
                )
            }

            CoachText(
                LocalizedText(
                    fr: "Le GPS met souvent trente secondes à se caler. Attends que la précision passe au vert avant de partir, sinon les premiers hectomètres seront faux.",
                    en: "GPS often takes thirty seconds to settle. Wait for the accuracy to turn green before you set off, or the first few hundred metres will be wrong.",
                    es: "El GPS suele tardar treinta segundos en asentarse. Espera a que la precisión se ponga en verde antes de salir, o los primeros cientos de metros saldrán mal."
                )
            )
        }
        .onAppear {
            if let plannedRun { selectedType = plannedRun.type }
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
                            value: Format.pace(secondsPerKm: tracker.recentPaceSecondsPerKm, unit: unit),
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
