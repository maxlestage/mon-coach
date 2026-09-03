import SwiftUI
import WidgetKit
import MonCoachKit

/// La journée du coach, sur l'écran d'accueil et sur l'écran verrouillé.
///
/// Ce qu'un widget doit faire, et ne pas faire
/// -------------------------------------------
/// Il se lit en une seconde, à travers un écran qu'on vient d'allumer. Il ne
/// décide rien, ne calcule rien, ne demande rien : il affiche la phrase que
/// l'application a écrite la dernière fois qu'elle savait quelque chose.
///
/// Et quand cette phrase n'est plus celle du jour, il se tait. Un widget qui
/// affiche la séance d'hier avec l'assurance d'aujourd'hui est pire qu'un
/// widget vide : on lui a fait confiance.
struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "StrideToday", provider: TodayProvider()) { entry in
            TodayWidgetView(snapshot: entry.snapshot)
                .containerBackground(Palette.background, for: .widget)
        }
        .configurationDisplayName("Stride")
        .description(LocalizedText(
            fr: "Ta séance du jour, sans ouvrir l'application.",
            en: "Your session for today, without opening the app.",
            es: "Tu sesión de hoy, sin abrir la aplicación."
        )[widgetLanguage])
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryCircular,
            .accessoryInline,
        ])
    }
}

/// La langue du widget.
///
/// Celle du téléphone, et non celle réglée dans l'application : les phrases
/// que porte l'instantané sont déjà traduites par le coach, mais les rares
/// mots qui appartiennent au widget — sa description dans la galerie, ce
/// qu'il dit quand il n'a rien à dire — sont écrits alors que l'application
/// n'a peut-être jamais été ouverte.
private var widgetLanguage: Language {
    Language.best(matching: Locale.preferredLanguages)
}

// MARK: - La lecture du fichier partagé

struct TodayEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?
}

struct TodayProvider: TimelineProvider {

    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, snapshot: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(TodayEntry(date: .now, snapshot: current(on: .now)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date()
        var entries = [TodayEntry(date: now, snapshot: current(on: now))]

        // Une entrée de plus, à minuit : le système la joue tout seul, sans
        // réveiller l'application. C'est ce qui fait que la séance d'hier
        // disparaît de l'écran d'accueil même si personne n'a rien ouvert.
        if let midnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0),
            matchingPolicy: .nextTime
        ) {
            entries.append(TodayEntry(date: midnight, snapshot: current(on: midnight)))
            completion(Timeline(entries: entries, policy: .after(midnight)))
            return
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// L'instantané, s'il décrit encore le jour demandé.
    private func current(on date: Date) -> WidgetSnapshot? {
        guard let snapshot = WidgetSnapshotStore.shared().load(),
              snapshot.isCurrent(on: date)
        else { return nil }
        return snapshot
    }
}

// MARK: - Les couleurs

/// Les mêmes que l'application, redites ici : une extension ne partage pas
/// le thème de l'application, et un widget d'une autre couleur que l'écran
/// qu'il ouvre se remarque tout de suite.
private enum Palette {
    static let background = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let accent = Color.green
    static let rest = Color(red: 0.45, green: 0.62, blue: 0.95)
    static let attention = Color.orange

    static func tint(_ tone: WidgetSnapshot.Tone) -> Color {
        switch tone {
        case .training: accent
        case .rest: rest
        case .attention: attention
        }
    }
}

// MARK: - Les vues

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    var snapshot: WidgetSnapshot?

    var body: some View {
        if let snapshot {
            switch family {
            case .accessoryInline:
                Text("\(snapshot.title) · \(snapshot.detail)")
            case .accessoryCircular:
                CircularView(snapshot: snapshot)
            case .accessoryRectangular:
                RectangularView(snapshot: snapshot)
            case .systemMedium:
                MediumView(snapshot: snapshot)
            default:
                SmallView(snapshot: snapshot)
            }
        } else {
            EmptyStateView()
        }
    }
}

/// Ce qu'on affiche quand on n'a rien à dire.
///
/// Pas la séance d'hier, pas un texte inventé : le nom de l'application et
/// une invitation à l'ouvrir. C'est le cas de la toute première installation,
/// et celui d'un widget que le système n'a pas rafraîchi depuis hier.
private struct EmptyStateView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        if family == .accessoryInline {
            Text("Stride")
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Palette.accent)
                Text("Stride")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                Text(LocalizedText(
                    fr: "Ouvre l'application pour voir ta journée.",
                    en: "Open the app to see your day.",
                    es: "Abre la aplicación para ver tu día."
                )[widgetLanguage])
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
    }
}

private struct SmallView: View {
    var snapshot: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: snapshot.symbolName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Palette.tint(snapshot.tone))
                if let week = snapshot.weekLabel {
                    Text(week)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Text(snapshot.title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            Text(snapshot.detail)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer(minLength: 0)

            if let run = snapshot.run {
                Label(run, systemImage: "figure.run")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Palette.accent)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

private struct MediumView: View {
    var snapshot: WidgetSnapshot

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: snapshot.symbolName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Palette.tint(snapshot.tone))
                    if let week = snapshot.weekLabel {
                        Text(week)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Text(snapshot.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                Text(snapshot.detail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Spacer(minLength: 0)
                if let run = snapshot.run {
                    Label(run, systemImage: "figure.run")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Palette.accent)
                        .lineLimit(1)
                }
            }

            if let done = snapshot.setsCompleted, let planned = snapshot.setsPlanned, planned > 0 {
                WeekRing(done: done, planned: planned, tint: Palette.tint(snapshot.tone))
                    .frame(width: 76)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

/// L'avancement de la semaine, en séries.
///
/// En séries et non en séances : une semaine à quatre séances dont trois
/// faites affiche « 3/4 » toute la semaine, ce qui ne dit rien du travail
/// réellement abattu. Les séries bougent à chaque entraînement.
private struct WeekRing: View {
    var done: Int
    var planned: Int
    var tint: Color

    private var share: Double { min(1, Double(done) / Double(planned)) }

    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .stroke(tint.opacity(0.18), lineWidth: 7)
                Circle()
                    .trim(from: 0, to: share)
                    .stroke(tint, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int((share * 100).rounded()))")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            Text(LocalizedText(
                fr: "\(done)/\(planned) séries",
                en: "\(done)/\(planned) sets",
                es: "\(done)/\(planned) series"
            )[widgetLanguage])
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

private struct RectangularView: View {
    var snapshot: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Label(snapshot.title, systemImage: snapshot.symbolName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
            Text(snapshot.detail)
                .font(.system(size: 12))
                .lineLimit(1)
            if let run = snapshot.run {
                Text(run)
                    .font(.system(size: 12))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CircularView: View {
    var snapshot: WidgetSnapshot

    var body: some View {
        // Un rond de complication mesure quelques millimètres : la jauge de
        // la semaine y tient, une phrase non. Sans bloc en cours, le symbole
        // du jour reste seul plutôt qu'un anneau vide qui ferait croire à
        // une semaine à zéro.
        if let done = snapshot.setsCompleted, let planned = snapshot.setsPlanned, planned > 0 {
            Gauge(value: min(1, Double(done) / Double(planned))) {
                Image(systemName: snapshot.symbolName)
            } currentValueLabel: {
                Image(systemName: snapshot.symbolName)
            }
            .gaugeStyle(.accessoryCircularCapacity)
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: snapshot.symbolName)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
    }
}
