import SwiftUI
import MonCoachKit
import UniformTypeIdentifiers

/// Le journal : la mémoire de l'athlète, sport par sport, semaine par
/// semaine — et la porte d'entrée et de sortie des données (GPX).
struct JournalView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var showsImporter = false
    @State private var importError = false
    @State private var importedCount = 0

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var maximumBpm: Double {
        HeartRateAnalysis.estimatedMaximum(age: store.profile?.age() ?? 30)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if store.history.activities.isEmpty {
                    emptyCard
                } else {
                    streakCard
                    heatmapCard
                    recordsCard
                    weeksCard
                }
                importCard
            }
            .padding(16)
        }
        .screenBackground()
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

    private var emptyCard: some View {
        Card(
            title: LocalizedText(fr: "Aucune activité", en: "No activities yet", es: "Aún sin actividades")[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Enregistre une sortie, ou importe ton historique en GPX : tout compte, d'où qu'il vienne.",
                    en: "Record an activity, or import your history as GPX: everything counts, wherever it comes from.",
                    es: "Registra una salida o importa tu historial en GPX: todo cuenta, venga de donde venga."
                )
            )
        }
    }

    // MARK: - Série et totaux

    private var streakCard: some View {
        let streak = ActivityJournal.weeklyStreak(of: store.history.activities)
        let year = Calendar.current.component(.year, from: Date())
        let byS = ActivityJournal.yearBySport(of: store.history.activities, year: year, maximumBpm: maximumBpm)
        return Card(
            title: LocalizedText(fr: "Cette année", en: "This year", es: "Este año")[language],
            subtitle: streak >= 2
                ? LocalizedText(
                    fr: "\(streak) semaines d'affilée avec au moins une sortie",
                    en: "\(streak) weeks in a row with at least one activity",
                    es: "\(streak) semanas seguidas con al menos una salida"
                )[language]
                : nil
        ) {
            VStack(spacing: 10) {
                ForEach(Sport.allCases.filter { byS[$0] != nil }) { sport in
                    let totals = byS[sport]!
                    HStack(spacing: 10) {
                        Image(systemName: sport.symbolName)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 24)
                        Text(sport.label[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                        Spacer()
                        Text(
                            Format.distance(meters: totals.meters, unit: unit, language: language)
                            + " · " + Format.stopwatch(seconds: totals.movingSeconds)
                            + " · \(Int(totals.elevationGain)) m D+"
                        )
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Carte de chaleur

    private var heatmapCard: some View {
        Group {
            if let grid = Heatmap.grid(of: store.history.activities) {
                Card(
                    title: LocalizedText(fr: "Tes parcours", en: "Your routes", es: "Tus recorridos")[language],
                    subtitle: LocalizedText(
                        fr: "Calculée sur l'appareil — cette image ne part nulle part.",
                        en: "Computed on the device — this image goes nowhere.",
                        es: "Calculada en el dispositivo: esta imagen no va a ninguna parte."
                    )[language]
                ) {
                    HeatmapCanvas(grid: grid)
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    // MARK: - Records

    private var recordsCard: some View {
        let records = BestEfforts.records(in: store.history.activities)
        return Group {
            if !records.isEmpty {
                Card(title: LocalizedText(fr: "Tes records", en: "Your records", es: "Tus récords")[language]) {
                    VStack(spacing: 8) {
                        ForEach(records) { record in
                            HStack {
                                Text(record.distance.label[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                Spacer()
                                Text(Format.stopwatch(seconds: record.duration))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                                Text(Format.pace(secondsPerKm: record.paceSecondsPerKm, unit: unit))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(width: 76, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Semaines

    private var weeksCard: some View {
        let weeks = ActivityJournal.weeks(of: store.history.activities, maximumBpm: maximumBpm).prefix(8)
        return Card(
            title: LocalizedText(fr: "Semaine par semaine", en: "Week by week", es: "Semana a semana")[language]
        ) {
            VStack(spacing: 10) {
                let maxMeters = max(1, weeks.map(\.totals.meters).max() ?? 1)
                ForEach(Array(weeks)) { week in
                    HStack(spacing: 10) {
                        Text(week.start.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 52, alignment: .leading)
                        ProgressBar(value: week.totals.meters / maxMeters)
                        Text(week.totals.activityCount == 0
                             ? "—"
                             : Format.distance(meters: week.totals.meters, unit: unit, language: language))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(week.totals.activityCount == 0 ? Theme.secondaryText : Theme.primaryText)
                            .frame(width: 64, alignment: .trailing)
                    }
                }
                // La liste des sorties récentes, ouvrables une à une.
                Divider().overlay(Theme.surfaceRaised)
                ForEach(store.history.activities.suffix(5).reversed()) { activity in
                    NavigationLink {
                        ActivityDetailView(activity: activity)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: activity.sport.symbolName)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.startedAt.formatted(.dateTime.day().month().hour().minute()))
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.primaryText)
                                Text(Format.distance(meters: activity.meters, unit: unit, language: language)
                                     + " · " + Format.speedOrPace(
                                        sport: activity.sport, meters: activity.meters,
                                        seconds: activity.duration, unit: unit, language: language))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Import

    private var importCard: some View {
        Card(
            title: LocalizedText(fr: "Ton historique t'appartient", en: "Your history is yours", es: "Tu historial es tuyo")[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(
                    LocalizedText(
                        fr: "Importe des fichiers GPX — d'une montre, d'une autre application, d'ailleurs. Ils entrent dans l'historique et comptent pour tes records. Et chaque sortie s'exporte en GPX depuis sa fiche.",
                        en: "Import GPX files — from a watch, another app, anywhere. They join your history and count towards your records. And every activity exports as GPX from its page.",
                        es: "Importa archivos GPX: de un reloj, de otra aplicación, de donde sea. Entran en tu historial y cuentan para tus récords. Y cada salida se exporta en GPX desde su ficha."
                    )
                )
                if importedCount > 0 {
                    Pill(text: LocalizedText(
                        fr: "\(importedCount) importée(s)",
                        en: "\(importedCount) imported",
                        es: "\(importedCount) importada(s)"
                    )[language])
                }
                PrimaryButton(
                    title: LocalizedText(fr: "Importer un GPX", en: "Import a GPX", es: "Importar un GPX")[language],
                    systemImage: "square.and.arrow.down"
                ) {
                    showsImporter = true
                }
            }
        }
    }
}

/// La carte de chaleur dessinée, case par case.
struct HeatmapCanvas: View {
    var grid: Heatmap.Grid

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.surfaceRaised))
            // La grille garde ses proportions géographiques : un carré de
            // rues doit rester un carré à l'écran.
            let scale = min(size.width / CGFloat(grid.columns), size.height / CGFloat(grid.rows))
            let offsetX = (size.width - CGFloat(grid.columns) * scale) / 2
            let offsetY = (size.height - CGFloat(grid.rows) * scale) / 2
            for cell in grid.cells {
                let intensity = Double(cell.visits) / Double(max(1, grid.maxVisits))
                let rect = CGRect(
                    x: offsetX + CGFloat(cell.column) * scale,
                    // Les lignes comptent depuis le sud : l'écran, depuis le haut.
                    y: offsetY + CGFloat(grid.rows - 1 - cell.row) * scale,
                    width: max(1, scale),
                    height: max(1, scale)
                )
                context.fill(
                    Path(rect),
                    with: .color(Theme.accent.opacity(0.25 + 0.75 * intensity))
                )
            }
        }
    }
}
