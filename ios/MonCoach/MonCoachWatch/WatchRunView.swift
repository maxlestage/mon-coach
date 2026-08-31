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
    @State private var heart = WatchHeartRate()
    @State private var page = 0

    /// Le sport de la dernière sortie, gardé d'une fois sur l'autre.
    ///
    /// Ce n'est pas un réglage du plan mais une habitude : quelqu'un qui
    /// pédale tous les jours ne doit pas redescendre la liste chaque matin.
    /// Le rang brut plutôt que le type : `AppStorage` ne sait garder que des
    /// valeurs simples, et le catalogue des sports peut s'allonger sans que
    /// ce qui est déjà écrit sur la montre devienne illisible.
    @AppStorage("sport-de-la-sortie") private var lastSportID: String = Sport.run.rawValue

    /// Les derniers sports pratiqués, du plus récent au plus ancien.
    ///
    /// Gardés en une chaîne de rangs séparés par des virgules : `AppStorage`
    /// ne sait retenir que des valeurs simples, et un rang inconnu — écrit
    /// par une version plus récente, ou retiré du catalogue — se jette à la
    /// lecture au lieu de faire tomber l'écran de départ.
    @AppStorage("sports-recents") private var recentIDs: String = ""

    private var lastSport: Sport { Sport(rawValue: lastSportID) ?? .run }

    /// Le haut du menu : ce que l'athlète fait vraiment.
    ///
    /// Quarante-huit sports ne se parcourent pas à la couronne. Les quatre
    /// derniers pratiqués tiennent sur un écran et couvrent presque toutes
    /// les sorties ; le reste attend derrière sa famille, à un appui. Le
    /// premier rang est celui qu'on atteint sans rien tourner — c'est le
    /// seul geste gratuit de l'écran, il revient au plus fréquent.
    private var favourites: [Sport] {
        var result: [Sport] = []
        for id in recentIDs.split(separator: ",") {
            if let sport = Sport(rawValue: String(id)), !result.contains(sport) {
                result.append(sport)
            }
        }
        if !result.contains(lastSport) { result.insert(lastSport, at: 0) }
        // Une montre neuve n'a pas d'historique : on part de ce que font
        // presque tous les athlètes, plutôt que d'une liste vide qui
        // obligerait à passer par les familles dès la première sortie.
        for fallback in [Sport.run, .ride, .walk] where result.count < 4 {
            if !result.contains(fallback) { result.append(fallback) }
        }
        return Array(result.prefix(4))
    }

    private var unit: UnitSystem { store.unit }

    var body: some View {
        Group {
            switch tracker.state {
            case .idle, .requestingPermission:
                startScreen
            case .denied:
                deniedScreen
            case .running, .paused, .finished:
                // La page des kilomètres n'existe que s'il y en a : un
                // rameur qui glisse vers une page vide croit avoir perdu
                // quelque chose.
                if tracker.sport.tracksLocation {
                    TabView(selection: $page) {
                        liveScreen.tag(0)
                        splitsScreen.tag(1)
                    }
                    .tabViewStyle(.verticalPage)
                } else {
                    liveScreen
                }
            }
        }
        .navigationTitle(
            (tracker.state == .idle || tracker.state == .requestingPermission
                ? WatchUI.activity
                : WatchUI.run)[language]
        )
    }

    /// Le menu de départ.
    ///
    /// C'est l'écran entier, et pas un sélecteur caché derrière un second
    /// écran : au poignet, on tourne la couronne et on appuie. Une ligne
    /// touchée démarre la sortie — c'est le geste de l'application Exercice
    /// d'Apple, et c'est celui qu'on fait déjà sans y penser.
    ///
    /// Le plan du jour est affiché, jamais imposé : il informe le choix, il
    /// ne le remplace pas. Un coureur qui décide d'aller marcher a ses
    /// raisons, et l'application n'a pas à les lui demander.
    private var startScreen: some View {
        List {
            if let planned = store.todayRun {
                VStack(alignment: .leading, spacing: 2) {
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
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 12).fill(.green.opacity(0.15))
                )
            }

            Section {
                // La séance du jour ouvre la liste. C'est la réponse à une
                // liste qui ne couvrait que les sorties : la séance se
                // démarrait ailleurs, et il fallait savoir où. Tout ce qu'on
                // peut faire se choisit ici, à la couronne — la séance en
                // tête parce que c'est le choix le plus probable, jamais
                // imposée parce que c'est un choix.
                if let session = store.todaySession {
                    Button {
                        store.startSession()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "dumbbell.fill")
                                .font(.system(size: 15))
                                .foregroundStyle(.green)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 1) {
                                Text(session.title[language])
                                    .font(.system(.body, design: .rounded, weight: .medium))
                                Text(
                                    WatchUI.sessionSummary(
                                        exercises: session.exercises.count,
                                        sets: session.totalSets,
                                        minutes: session.estimatedMinutes
                                    )[language]
                                )
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
                ForEach(favourites) { sport in
                    Button {
                        start(sport)
                    } label: {
                        row(for: sport)
                    }
                }
            } header: {
                Text(WatchUI.chooseActivity[language])
                    .font(.caption2)
            }

            // Tout le reste, rangé. Une famille par ligne, et sa liste
            // derrière : c'est un appui de plus pour les sports rares, et
            // quarante-quatre lignes de moins pour tous les autres.
            Section {
                ForEach(SportFamily.allCases) { family in
                    NavigationLink {
                        familyScreen(family)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: family.sports.first?.symbolName ?? "figure.run")
                                .font(.system(size: 15))
                                .foregroundStyle(.green)
                                .frame(width: 22)
                            Text(family.label[language])
                                .font(.system(.body, design: .rounded, weight: .medium))
                            Spacer()
                        }
                    }
                }
            } header: {
                Text(WatchUI.allSports[language])
                    .font(.caption2)
            }
        }
    }

    /// La liste d'une famille : tous ses sports, un appui pour partir.
    private func familyScreen(_ family: SportFamily) -> some View {
        List {
            ForEach(family.sports) { sport in
                Button {
                    start(sport)
                } label: {
                    row(for: sport)
                }
            }
        }
        .navigationTitle(family.label[language])
    }

    private func row(for sport: Sport) -> some View {
        HStack(spacing: 8) {
            Image(systemName: sport.symbolName)
                .font(.system(size: 15))
                .foregroundStyle(.green)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 1) {
                Text(sport.label[language])
                    .font(.system(.body, design: .rounded, weight: .medium))
                if let note = note(for: sport) {
                    Text(note[language])
                        .font(.system(size: 10))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }

    /// Ce qui distingue une ligne des autres, quand quelque chose la
    /// distingue. Rien à dire sur les autres : une mention par ligne ferait
    /// une liste illisible en courant.
    private func note(for sport: Sport) -> LocalizedText? {
        if store.todayRun != nil && sport == .run { return WatchUI.planned }
        if sport == lastSport { return WatchUI.lastTime }
        // Dit avant de partir, pas après : quelqu'un qui démarre un rameur
        // en attendant une carte a le droit de le savoir tout de suite.
        if !sport.tracksLocation { return WatchUI.noGPS }
        return nil
    }

    /// Lance la sortie, et retient le choix pour la prochaine fois.
    ///
    /// L'intention de séance suit le plan quand c'est bien la course prévue
    /// qu'on va faire, et vaut « endurance » sinon : un tempo prescrit n'a
    /// aucun sens appliqué à une randonnée.
    private func start(_ sport: Sport) {
        lastSportID = sport.rawValue
        remember(sport)
        let planned = store.todayRun
        tracker.start(
            sport: sport,
            type: sport.feedsRunningPlan ? (planned?.type ?? .easy) : .easy
        )
        heart.start()
    }

    /// Fait remonter ce sport en tête des favoris.
    private func remember(_ sport: Sport) {
        var kept = [sport.rawValue]
        for id in recentIDs.split(separator: ",").map(String.init)
        where id != sport.rawValue && Sport(rawValue: id) != nil {
            kept.append(id)
        }
        recentIDs = kept.prefix(4).joined(separator: ",")
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
            // Le grand chiffre est celui qui bouge : les kilomètres pour ce
            // qui se déplace, le chronomètre pour ce qui reste sur place.
            Text(
                tracker.sport.tracksLocation
                    ? Format.distance(meters: tracker.meters, unit: unit, language: language)
                    : Format.stopwatch(seconds: tracker.movingDuration)
            )
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    if tracker.sport.tracksLocation {
                        Text(Format.stopwatch(seconds: tracker.movingDuration))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Text(Format.speedOrPace(
                            sport: tracker.sport,
                            secondsPerKm: tracker.recentPaceSecondsPerKm,
                            unit: unit,
                            language: language
                        ))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(tracker.sport.label[language])
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer()
                if heart.currentBpm > 0 {
                    VStack(alignment: .trailing, spacing: 1) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.red)
                        Text("\(Int(heart.currentBpm))")
                            .font(.system(.body, design: .rounded, weight: .semibold))
                    }
                }
                if tracker.sport.tracksLocation, !tracker.hasUsableSignal {
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
                    heart.stop()
                    if var log = tracker.finish() {
                        log.heartRate = heart.drain()
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
