import SwiftUI
import MonCoachKit

/// La course au poignet.
///
/// Le GPS de la montre suffit : c'est tout l'intérêt, courir sans emporter
/// le téléphone. La trace remonte ensuite par la file persistante de
/// WatchConnectivity, au prochain rapprochement des deux appareils.
///
/// Trois chiffres, pas de carte. Un écran de 40 mm regardé en courant ne
/// porte pas une carte lisible, et la dessiner coûterait la batterie qui
/// doit tenir jusqu'à la fin de la sortie.
struct WatchRunView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var tracker = LocationTracker()
    @State private var page = 0

    private var unit: UnitSystem { store.unit }

    var body: some View {
        Group {
            switch tracker.state {
            case .idle, .requestingPermission:
                startScreen
            case .denied:
                deniedScreen
            case .running, .paused, .finished:
                TabView(selection: $page) {
                    liveScreen.tag(0)
                    splitsScreen.tag(1)
                }
                .tabViewStyle(.verticalPage)
            }
        }
        .navigationTitle(WatchUI.run[language])
    }

    private var startScreen: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let planned = store.todayRun {
                Text(planned.type.label[language])
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text(planned.note[language])
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                if let range = planned.paceRangeSecondsPerKm {
                    Text(
                        Format.pace(secondsPerKm: range.lowerBound, unit: unit)
                            + " – " + Format.pace(secondsPerKm: range.upperBound, unit: unit)
                    )
                    .font(.caption)
                    .foregroundStyle(.green)
                }
            }
            Button {
                tracker.start(type: store.todayRun?.type ?? .easy)
            } label: {
                Label(WatchUI.start[language], systemImage: "figure.run")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
    }

    private var deniedScreen: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "location.slash")
                .font(.title3)
                .foregroundStyle(.orange)
            Text(
                LocalizedText(
                    fr: "Autorise la localisation sur la montre pour mesurer une sortie.",
                    en: "Allow location on the watch to measure a run.",
                    es: "Permite la ubicación en el reloj para medir un rodaje."
                )[language]
            )
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
    }

    private var liveScreen: some View {
        VStack(spacing: 6) {
            Text(Format.distance(meters: tracker.meters, unit: unit, language: language))
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(Format.stopwatch(seconds: tracker.movingDuration))
                        .font(.system(.body, design: .rounded, weight: .semibold))
                    Text(Format.pace(secondsPerKm: tracker.recentPaceSecondsPerKm, unit: unit))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if !tracker.hasUsableSignal {
                    Text(
                        (tracker.currentAccuracy < 0 ? WatchUI.searchingGPS : WatchUI.weakSignal)[language]
                    )
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                }
            }

            HStack(spacing: 6) {
                Button {
                    tracker.state == .paused ? tracker.resume() : tracker.pause()
                } label: {
                    Image(systemName: tracker.state == .paused ? "play.fill" : "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .tint(.orange)

                Button {
                    if let log = tracker.finish() {
                        store.recordRun(log)
                    }
                    dismiss()
                } label: {
                    Image(systemName: "flag.checkered")
                        .frame(maxWidth: .infinity)
                }
                .tint(.green)
            }
            .buttonStyle(.bordered)
        }
    }

    private var splitsScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(tracker.splits) { split in
                    HStack {
                        Text("\(split.index)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(Format.pace(secondsPerKm: split.paceSecondsPerKm, unit: unit))
                            .font(.system(.caption, design: .rounded, weight: .medium))
                    }
                }
                if tracker.splits.isEmpty {
                    Text(
                        LocalizedText(
                            fr: "Le premier kilomètre s'affichera ici.",
                            en: "Your first kilometre will show up here.",
                            es: "Tu primer kilómetro aparecerá aquí."
                        )[language]
                    )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}
