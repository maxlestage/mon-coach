import SwiftUI
import MonCoachKit

/// L'écran d'accueil de la montre : la journée en un coup d'œil.
struct WatchTodayView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.language) private var language

    @State private var showsRun = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if let snapshot = store.snapshot {
                    content(snapshot)
                } else {
                    waiting
                }
            }
        }
        .navigationTitle("Mon Coach")
        .navigationDestination(isPresented: $showsRun) {
            WatchRunView()
        }
    }

    private var waiting: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.title3)
                .foregroundStyle(.green)
            Text(WatchUI.waiting[language])
                .font(.headline)
            Text(WatchUI.waitingDetail[language])
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func content(_ snapshot: WatchSnapshot) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(WatchUI.week(snapshot.weekIndex ?? 0, deload: snapshot.isDeloadWeek)[language])
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(snapshot.readinessHeadline[language])
                    .font(.headline)
            }
            Spacer()
            Gauge(value: Double(snapshot.readinessScore), in: 0...100) {
                EmptyView()
            } currentValueLabel: {
                Text("\(snapshot.readinessScore)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(.green)
            .frame(width: 44, height: 44)
        }

        if let session = store.todaySession {
            VStack(alignment: .leading, spacing: 6) {
                Text(session.title[language])
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text(
                    WatchUI.sessionSummary(
                        exercises: session.exercises.count,
                        sets: session.totalSets,
                        minutes: session.estimatedMinutes
                    )[language]
                )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

            Button {
                store.startSession()
            } label: {
                Label(WatchUI.start[language], systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Label(WatchUI.rest[language], systemImage: "moon.zzz.fill")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text(WatchUI.restDay(proteinG: snapshot.proteinG)[language])
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        if let run = store.todayRun {
            VStack(alignment: .leading, spacing: 6) {
                Label(run.type.label[language], systemImage: "figure.run")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                if let meters = run.targetMeters, meters > 0 {
                    Text(Format.distance(meters: meters, unit: store.unit, language: language))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Button {
                    showsRun = true
                } label: {
                    Label(WatchUI.start[language], systemImage: "location.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.10), in: RoundedRectangle(cornerRadius: 12))
        } else if snapshot.plannedRun != nil {
            Label(WatchUI.done[language], systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundStyle(.green)
        }

        // L'alimentation au poignet tient en deux nombres : le reste se lit
        // sur le téléphone, en cuisine.
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 1) {
                Text("\(snapshot.calories)")
                    .font(.system(.body, design: .rounded, weight: .bold))
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text("\(snapshot.proteinG) g")
                    .font(.system(.body, design: .rounded, weight: .bold))
                Text(LocalizedText(fr: "protéines", en: "protein", es: "proteína")[language])
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "fork.knife")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

        if store.pendingUploads > 0 {
            Label(WatchUI.syncing[language], systemImage: "arrow.triangle.2.circlepath")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }

        Text(WatchUI.credit[language])
            .font(.system(size: 10))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 6)
    }
}
