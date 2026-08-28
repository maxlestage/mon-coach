import ActivityKit
import SwiftUI
import WidgetKit
import MonCoachKit

@main
struct MonCoachWidgets: WidgetBundle {
    var body: some Widget {
        WorkoutLiveActivity()
        RunLiveActivity()
    }
}

/// La séance en cours, sur l'écran verrouillé et dans la Dynamic Island.
///
/// Le compte à rebours de repos est piloté par une date : le système anime
/// le chrono tout seul, sans réveiller l'application.
struct WorkoutLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkoutAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(Color(red: 0.05, green: 0.06, blue: 0.08))
                .activitySystemActionForegroundColor(.green)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.exerciseName)
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .lineLimit(1)
                        Text(context.state.setLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if let load = context.state.suggestedLoadKg {
                        Text(Format.load(load, unit: context.state.unit))
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    BottomBar(state: context.state)
                }
            } compactLeading: {
                Image(systemName: context.state.isFinished ? "checkmark.seal.fill" : "dumbbell.fill")
                    .foregroundStyle(.green)
            } compactTrailing: {
                if let end = context.state.restEndsAt, end > .now {
                    Text(timerInterval: Date.now...end, countsDown: true)
                        .monospacedDigit()
                        .frame(maxWidth: 44)
                        .foregroundStyle(.orange)
                } else {
                    Text("\(context.state.completedSets)/\(context.state.totalSets)")
                        .font(.system(.caption2, design: .rounded, weight: .bold))
                }
            } minimal: {
                Image(systemName: "dumbbell.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}

private struct LockScreenView: View {
    let state: WorkoutActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(state.sessionTitle, systemImage: "dumbbell.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(state.completedSets)/\(state.totalSets) séries")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.exerciseName)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(state.setLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if let load = state.suggestedLoadKg {
                    Text(Format.load(load, unit: state.unit))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
            }

            BottomBar(state: state)
        }
        .padding(14)
    }
}

/// Barre commune : repos en cours ou progression de la séance.
private struct BottomBar: View {
    let state: WorkoutActivitySnapshot

    var body: some View {
        if let end = state.restEndsAt, end > .now {
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .foregroundStyle(.orange)
                Text("Repos")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(timerInterval: Date.now...end, countsDown: true)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.orange)
                Spacer()
            }
        } else {
            ProgressView(value: state.progress)
                .tint(.green)
        }
    }
}

/// La sortie en cours, sur l'écran verrouillé et dans la Dynamic Island.
///
/// C'est le seul écran qui compte pendant une course : le téléphone est dans
/// une poche ou un brassard, et le déverrouiller en courant n'arrive pas.
struct RunLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RunAttributes.self) { context in
            RunLockScreenView(state: context.state)
                .activityBackgroundTint(Color(red: 0.05, green: 0.06, blue: 0.08))
                .activitySystemActionForegroundColor(.green)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.distance)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                        Text(context.state.typeLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.pace)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                        if context.state.elevationGain >= 10 {
                            Text("+\(context.state.elevationGain) m")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    RunTimer(state: context.state)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            } compactLeading: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            } compactTrailing: {
                Text(context.state.distance)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            } minimal: {
                Image(systemName: "figure.run")
                    .foregroundStyle(.green)
            }
            .keylineTint(.green)
        }
    }
}

/// Le chrono d'une sortie.
///
/// En marche, le système anime le compteur tout seul à partir de la date de
/// départ, sans réveiller l'application une seule fois. En pause, on affiche
/// le temps figé : laisser tourner un chrono à l'arrêt est un mensonge que
/// l'athlète paiera en relisant sa sortie.
struct RunTimer: View {
    var state: RunActivitySnapshot

    var body: some View {
        if state.isPaused {
            Text(Format.stopwatch(seconds: state.movingSeconds))
        } else {
            Text(state.startedAt, style: .timer)
        }
    }
}

struct RunLockScreenView: View {
    var state: RunActivitySnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label(state.typeLabel, systemImage: "figure.run")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.green)
                Spacer()
                if state.hasWeakSignal {
                    Image(systemName: "antenna.radiowaves.left.and.right.slash")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                if state.isPaused {
                    Text("⏸")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            HStack(alignment: .firstTextBaseline, spacing: 16) {
                Text(state.distance)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                VStack(alignment: .leading, spacing: 2) {
                    RunTimer(state: state)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(state.pace)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if state.elevationGain >= 10 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("+\(state.elevationGain)")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(.orange)
                        Text("m")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(14)
    }
}
