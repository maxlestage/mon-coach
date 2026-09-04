import SwiftUI
import MonCoachKit

/// Le choix de l'activité — et, désormais, l'écran d'accueil lui-même.
///
/// Où il était, et pourquoi il en bouge
/// ....................................
/// Il vivait au fond de l'écran de course, derrière un bouton « Démarrer
/// une activité » posé au milieu d'un long défilement de cartes. Partir
/// courir demandait donc : lever le poignet, faire défiler, viser un bouton,
/// attendre un écran, puis choisir. Cinq gestes pour la seule chose qu'on
/// vient faire.
///
/// Il est maintenant une page de l'accueil, à un cran de couronne. Deux
/// gestes : tourner, appuyer. C'est la disposition de l'application Exercice
/// d'Apple, et ce n'est pas un hasard — au poignet, ce qu'on fait souvent
/// doit être ce qui coûte le moins.
///
/// La liste s'ouvre sur ce que l'athlète fait vraiment : la séance du jour
/// si elle attend, puis les quatre derniers sports pratiqués. Les
/// quarante-huit autres restent derrière leur famille, à un appui — une
/// couronne ne parcourt pas quarante-huit lignes.
struct WatchStartView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.language) private var language

    /// Le sport de la dernière sortie, gardé d'une fois sur l'autre.
    ///
    /// Ce n'est pas un réglage du plan mais une habitude : quelqu'un qui
    /// pédale tous les jours ne doit pas redescendre la liste chaque matin.
    /// Le rang brut plutôt que le type : `AppStorage` ne sait garder que des
    /// valeurs simples, et le catalogue des sports peut s'allonger sans que
    /// ce qui est déjà écrit sur la montre devienne illisible.
    @AppStorage("sport-de-la-sortie") private var lastSportID: String = Sport.run.rawValue

    /// Les derniers sports pratiqués, du plus récent au plus ancien.
    @AppStorage("sports-recents") private var recentIDs: String = ""

    private var unit: UnitSystem { store.unit }
    private var lastSport: Sport { Sport(rawValue: lastSportID) ?? .run }

    /// Le haut du menu : ce que l'athlète fait vraiment.
    private var favourites: [Sport] {
        var result: [Sport] = []
        for id in recentIDs.split(separator: ",") {
            if let sport = Sport(rawValue: String(id)), !result.contains(sport) {
                result.append(sport)
            }
        }
        if !result.contains(lastSport) { result.insert(lastSport, at: 0) }
        for fallback in [Sport.run, .ride, .walk] where result.count < 4 {
            if !result.contains(fallback) { result.append(fallback) }
        }
        return Array(result.prefix(4))
    }

    var body: some View {
        // Le style « carrousel » est celui de watchOS : la ligne visée
        // grandit, les autres s'effacent sur les bords de l'écran. Sur une
        // liste qu'on parcourt à la couronne sans regarder droit, c'est ce
        // qui dit où l'on est.
        List {
            // Ce qui tourne encore vient en tête, et rien ne passe devant :
            // une sortie ou une séance quittée d'un glissement continue —
            // la session d'entraînement et le GPS vivent dans le magasin,
            // pas dans l'écran. La montrer ici évite qu'on en démarre une
            // seconde par-dessus, ce qui perdrait la première.
            if store.activityInProgress {
                banner(
                    symbol: store.tracker.sport.symbolName,
                    title: WatchUI.activityInProgress[language],
                    detail: WatchUI.resumeActivity[language]
                ) { store.reopenActivity() }
            }
            if store.activeSession != nil {
                banner(
                    symbol: "figure.strengthtraining.traditional",
                    title: WatchUI.sessionInProgress[language],
                    detail: WatchUI.resumeSession[language]
                ) { store.reopenSession() }
            }

            // La journée, en une ligne et à un appui. La pastille de forme
            // se lit sans être lue ; le reste attend derrière.
            if let snapshot = store.snapshot {
                NavigationLink {
                    WatchDayView()
                } label: {
                    dayRow(snapshot)
                }
                .listRowBackground(Color.clear)
            }

            if let planned = store.todayRun {
                plannedRow(planned)
            }

            if let session = store.todaySession {
                Button {
                    store.startSession()
                } label: {
                    row(
                        symbol: "dumbbell.fill",
                        title: session.title[language],
                        detail: WatchUI.sessionSummary(
                            exercises: session.exercises.count,
                            sets: session.totalSets,
                            minutes: session.estimatedMinutes
                        )[language]
                    )
                }
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 14).fill(.green.opacity(0.22))
                )
            }

            ForEach(favourites) { sport in
                Button {
                    start(sport)
                } label: {
                    row(
                        symbol: sport.symbolName,
                        title: sport.label[language],
                        detail: note(for: sport)?[language]
                    )
                }
            }

            Section {
                ForEach(SportFamily.allCases) { family in
                    NavigationLink {
                        familyScreen(family)
                    } label: {
                        row(
                            symbol: family.sports.first?.symbolName ?? "figure.run",
                            title: family.label[language],
                            detail: nil
                        )
                    }
                }
            } header: {
                Text(WatchUI.allSports[language])
                    .font(.caption2)
            }
        }
        .listStyle(.carousel)
    }

    // MARK: - L'en-tête

    /// La journée résumée en une ligne : la forme à gauche, ce qu'elle dit
    /// à droite. C'est tout ce qu'un accueil doit en montrer ; le détail
    /// est derrière l'appui.
    private func dayRow(_ snapshot: WatchSnapshot) -> some View {
        HStack(spacing: 10) {
            Gauge(value: Double(snapshot.readinessScore), in: 0...100) {
                EmptyView()
            } currentValueLabel: {
                Text("\(snapshot.readinessScore)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(WatchTone.readiness(snapshot.readinessScore))
            .frame(width: 38, height: 38)

            VStack(alignment: .leading, spacing: 1) {
                Text(snapshot.readinessHeadline[language])
                    .font(.system(size: 13, design: .rounded).weight(.semibold))
                    .lineLimit(2)
                Text(WatchUI.week(snapshot.weekIndex ?? 0, deload: snapshot.isDeloadWeek)[language])
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }

    private func banner(
        symbol: String,
        title: String,
        detail: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            row(symbol: symbol, title: title, detail: detail)
        }
        .listRowBackground(
            RoundedRectangle(cornerRadius: 14).fill(.orange.opacity(0.28))
        )
    }

    // MARK: - Les lignes

    /// La sortie prescrite du jour : ce n'est pas un bouton, c'est une
    /// consigne. Elle se lit avant de choisir, pas à la place.
    private func plannedRow(_ planned: PlannedRun) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Label(planned.type.label[language], systemImage: "target")
                .font(.system(size: 13, design: .rounded).weight(.semibold))
                .foregroundStyle(.green)
            Text(planned.note[language])
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            if let range = planned.paceRangeSecondsPerKm {
                Text(
                    Format.pace(secondsPerKm: range.lowerBound, unit: unit)
                        + " – " + Format.pace(secondsPerKm: range.upperBound, unit: unit)
                )
                .font(.system(size: 12, design: .rounded).weight(.medium))
                .foregroundStyle(.green)
            }
        }
        .listRowBackground(Color.clear)
    }

    /// Une ligne de la liste : un symbole large, un nom, une précision.
    ///
    /// Le symbole fait vingt points et non quinze : c'est lui qu'on
    /// reconnaît en courant, avant d'avoir lu le mot.
    private func row(symbol: String, title: String, detail: String?) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbol)
                .font(.system(size: 20))
                .foregroundStyle(.green)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(.body, design: .rounded, weight: .medium))
                    .lineLimit(1)
                if let detail {
                    Text(detail)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
    }

    private func familyScreen(_ family: SportFamily) -> some View {
        List {
            ForEach(family.sports) { sport in
                Button {
                    start(sport)
                } label: {
                    row(
                        symbol: sport.symbolName,
                        title: sport.label[language],
                        detail: note(for: sport)?[language]
                    )
                }
            }
        }
        .listStyle(.carousel)
        .navigationTitle(family.label[language])
    }

    /// Ce qui distingue une ligne des autres, quand quelque chose la
    /// distingue.
    private func note(for sport: Sport) -> LocalizedText? {
        if store.todayRun != nil && sport == .run { return WatchUI.planned }
        if sport == lastSport { return WatchUI.lastTime }
        // Dit avant de partir : la montre mesure elle-même un tapis ou un
        // rameur, et compte au chrono ce qu'elle ne sait pas mesurer.
        if !sport.tracksLocation {
            return sport.workoutDistanceType != nil ? WatchUI.measuredByWatch : WatchUI.noGPS
        }
        return nil
    }

    // MARK: - Le départ

    /// Lance la sortie : la session d'entraînement d'abord, le GPS ensuite.
    ///
    /// L'intention de séance suit le plan quand c'est bien la course prévue
    /// qu'on va faire, et vaut « endurance » sinon : un tempo prescrit n'a
    /// aucun sens appliqué à une randonnée.
    private func start(_ sport: Sport) {
        lastSportID = sport.rawValue
        remember(sport)
        let planned = store.todayRun
        store.startActivity(
            sport: sport,
            type: sport.feedsRunningPlan ? (planned?.type ?? .easy) : .easy
        )
    }

    private func remember(_ sport: Sport) {
        var kept = [sport.rawValue]
        for id in recentIDs.split(separator: ",").map(String.init)
        where id != sport.rawValue && Sport(rawValue: id) != nil {
            kept.append(id)
        }
        recentIDs = kept.prefix(4).joined(separator: ",")
    }
}
