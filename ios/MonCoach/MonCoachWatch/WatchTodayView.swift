import SwiftUI
import MonCoachKit

/// L'écran d'accueil de la montre : la journée en un coup d'œil.
struct WatchTodayView: View {
    @Environment(WatchStore.self) private var store

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
    }

    private var waiting: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "iphone.radiowaves.left.and.right")
                .font(.title3)
                .foregroundStyle(.green)
            Text("En attente du téléphone")
                .font(.headline)
            Text("Ouvre Mon Coach sur ton iPhone une première fois : la montre recevra la séance du jour et pourra ensuite fonctionner seule.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func content(_ snapshot: WatchSnapshot) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.isDeloadWeek ? "Semaine \(snapshot.weekIndex ?? 0) · décharge" : "Semaine \(snapshot.weekIndex ?? 0)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text(snapshot.readinessHeadline)
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
                Text(session.title)
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("\(session.exercises.count) exercices · \(session.totalSets) séries · ~\(session.estimatedMinutes) min")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.green.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))

            Button {
                store.startSession()
            } label: {
                Label("Démarrer", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        } else {
            VStack(alignment: .leading, spacing: 6) {
                Label("Repos", systemImage: "moon.zzz.fill")
                    .font(.system(.body, design: .rounded, weight: .semibold))
                Text("Rien de prévu aujourd'hui. \(snapshot.proteinG) g de protéines, et du sommeil.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }

        if store.pendingUploads > 0 {
            Label("Synchronisation en attente", systemImage: "arrow.triangle.2.circlepath")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }

        Text("Créé et fait par Maxime Nathan Lestage")
            .font(.system(size: 10))
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 6)
    }
}
