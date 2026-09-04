import SwiftUI
import MonCoachKit

/// La journée en détail : la forme, ce qui est prévu, ce qu'il faut manger.
///
/// C'était l'accueil, et ce n'était pas sa place. Rien là-dedans ne se fait
/// — ça se lit, une fois le matin. Ce qui se fait, c'est démarrer une
/// activité, et c'est cela qui occupe désormais l'écran d'ouverture.
///
/// Ce qui se lit se range donc à un appui, en grand, sur une page qui n'a
/// plus à partager la place avec des boutons.
struct WatchDayView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.language) private var language

    var body: some View {
        ScrollView {
            if let snapshot = store.snapshot {
                VStack(spacing: 12) {
                    Gauge(value: Double(snapshot.readinessScore), in: 0...100) {
                        EmptyView()
                    } currentValueLabel: {
                        Text("\(snapshot.readinessScore)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .tint(WatchTone.readiness(snapshot.readinessScore))
                    .frame(width: 96, height: 96)

                    Text(snapshot.readinessHeadline[language])
                        .font(.system(.headline, design: .rounded))
                        .multilineTextAlignment(.center)

                    if store.todaySession == nil && store.todayRun == nil {
                        Text(WatchUI.restDay(proteinG: snapshot.proteinG)[language])
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }

                    Divider()

                    // Les deux nombres de l'assiette, en grand : au poignet
                    // on ne compose pas un repas, on vérifie une cible.
                    HStack(spacing: 18) {
                        figure(
                            "\(snapshot.calories)",
                            "kcal",
                            symbol: "flame.fill",
                            color: .orange
                        )
                        figure(
                            "\(snapshot.proteinG)",
                            LocalizedText(fr: "g prot.", en: "g protein", es: "g prot.")[language],
                            symbol: "fork.knife",
                            color: .green
                        )
                    }

                    if store.runDone {
                        Label(WatchUI.runAgain[language], systemImage: "checkmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.green)
                    }

                    if store.pendingUploads > 0 {
                        Label(WatchUI.syncing[language], systemImage: "arrow.triangle.2.circlepath")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }

                    Text(WatchUI.credit[language])
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle(
            WatchUI.week(
                store.snapshot?.weekIndex ?? 0,
                deload: store.snapshot?.isDeloadWeek ?? false
            )[language]
        )
    }

    private func figure(
        _ value: String,
        _ label: String,
        symbol: String,
        color: Color
    ) -> some View {
        VStack(spacing: 1) {
            Image(systemName: symbol)
                .font(.system(size: 13))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
    }
}

/// Les couleurs que la montre donne à un chiffre.
///
/// Une couleur se lit sans être lue, et c'est tout ce qu'on demande à un
/// poignet levé au réveil : vert, on y va ; orange, on lève le pied ;
/// rouge, on se repose.
enum WatchTone {
    static func readiness(_ score: Int) -> Color {
        switch score {
        case 70...: return .green
        case 40..<70: return .orange
        default: return .red
        }
    }
}
