import SwiftUI
import WidgetKit
import MonCoachKit

@main
struct StrideComplications: WidgetBundle {
    var body: some Widget {
        TodayComplication()
    }
}

/// La journée du coach, sur le cadran.
///
/// Une complication est le seul endroit de l'application qu'on regarde sans
/// avoir décidé de la regarder : elle est là quand on lève le poignet. Elle
/// doit donc répondre à une question et une seule — qu'est-ce que j'ai
/// aujourd'hui — et se taire dès qu'elle ne le sait plus.
struct TodayComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StrideWatchToday", provider: ComplicationProvider()) { entry in
            ComplicationView(snapshot: entry.snapshot)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Stride")
        .description(LocalizedText(
            fr: "Ta séance du jour sur le cadran.",
            en: "Your session for today, on the watch face.",
            es: "Tu sesión de hoy en la esfera."
        )[complicationLanguage])
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCorner,
        ])
    }
}

/// La langue du cadran.
///
/// L'instantané en porte une — celle réglée sur le téléphone — mais il
/// n'existe pas encore la première fois. Le système sert alors de repli.
private var complicationLanguage: Language {
    Language.best(matching: Locale.preferredLanguages)
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct ComplicationProvider: TimelineProvider {

    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        completion(ComplicationEntry(date: .now, snapshot: current(on: .now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        let now = Date()
        var entries = [ComplicationEntry(date: now, snapshot: current(on: now))]

        // Minuit, comme sur le téléphone : la séance d'hier disparaît du
        // cadran même si la montre n'a rien reçu de la nuit.
        if let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) {
            entries.append(ComplicationEntry(date: midnight, snapshot: current(on: midnight)))
            completion(Timeline(entries: entries, policy: .after(midnight)))
            return
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func current(on date: Date) -> WidgetSnapshot? {
        guard let snapshot = WidgetSnapshotStore.shared().load(),
              snapshot.isCurrent(on: date)
        else { return nil }
        return snapshot
    }
}

struct ComplicationView: View {
    @Environment(\.widgetFamily) private var family
    var snapshot: WidgetSnapshot?

    var body: some View {
        switch family {
        case .accessoryInline:
            Text(inlineText)
        case .accessoryCorner:
            Image(systemName: snapshot?.symbolName ?? "bolt.fill")
                .font(.title2)
                .widgetLabel(snapshot?.title ?? "Stride")
        case .accessoryRectangular:
            RectangularComplication(snapshot: snapshot)
        default:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: snapshot?.symbolName ?? "bolt.fill")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
    }

    private var inlineText: String {
        guard let snapshot else { return "Stride" }
        // Une ligne de cadran fait quelques dizaines de points : le titre
        // seul y tient, le détail passerait à la trappe au milieu d'un mot.
        if let run = snapshot.run, snapshot.tone == .rest {
            return run
        }
        return snapshot.title
    }
}

private struct RectangularComplication: View {
    var snapshot: WidgetSnapshot?

    var body: some View {
        if let snapshot {
            VStack(alignment: .leading, spacing: 1) {
                Label(snapshot.title, systemImage: snapshot.symbolName)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text(snapshot.detail)
                    .font(.system(size: 13))
                    .lineLimit(1)
                if let run = snapshot.run {
                    Text(run)
                        .font(.system(size: 13))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            VStack(alignment: .leading, spacing: 1) {
                Label("Stride", systemImage: "bolt.fill")
                    .font(.system(size: 15, weight: .semibold))
                Text(LocalizedText(
                    fr: "Ouvre l'application",
                    en: "Open the app",
                    es: "Abre la aplicación"
                )[complicationLanguage])
                .font(.system(size: 13))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
