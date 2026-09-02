import SwiftUI
import MonCoachKit

/// Une activité au poignet, quel que soit le sport.
///
/// Ce que l'écran mesure dépend du sport, et c'est le sport qui décide :
/// les kilomètres en grand pour ce qui se déplace, le chrono en grand pour
/// ce qui reste sur place, la distance de la montre pour ce qu'elle sait
/// estimer sans GPS — un tapis, un rameur, des longueurs. Sous le grand
/// chiffre, toujours le cardio et la dépense, parce que la session
/// d'entraînement les mesure pour tous.
///
/// Trois écrans : le choix, l'effort, le bilan. Le bilan est nouveau, et
/// c'est lui qui répond à la question restée ouverte des machines : un home
/// trainer affiche sa distance sur son propre écran, la montre ne la voit
/// pas, et on la demande à la couronne avant d'enregistrer plutôt que
/// d'écrire zéro kilomètre pour quarante minutes.
struct WatchRunView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var page = 0
    /// Le bilan de la sortie qui vient de finir, avant qu'on décide de
    /// l'enregistrer.
    @State private var summary: Summary?
    /// La distance dite à la couronne, en kilomètres, pour les machines.
    @State private var typedKm: Double = 0

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

    private var tracker: LocationTracker { store.tracker }
    private var workout: WatchWorkout { store.workout }
    private var unit: UnitSystem { store.unit }
    private var lastSport: Sport { Sport(rawValue: lastSportID) ?? .run }

    /// Ce que la sortie a produit, une fois arrêtée.
    struct Summary {
        var sport: Sport
        var seconds: TimeInterval
        var meters: Double
        var kilocalories: Double
        var averageBpm: Int
        /// Le journal prêt à partir, ou nil si la sortie est trop courte
        /// pour en être une.
        var log: ActivityLog?
    }

    /// Le haut du menu : ce que l'athlète fait vraiment.
    ///
    /// Quarante-huit sports ne se parcourent pas à la couronne. Les quatre
    /// derniers pratiqués tiennent sur un écran et couvrent presque toutes
    /// les sorties ; le reste attend derrière sa famille, à un appui.
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
        Group {
            if let summary {
                summaryScreen(summary)
            } else {
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
        }
        .navigationTitle(title)
    }

    private var title: String {
        if summary != nil { return WatchUI.summary[language] }
        switch tracker.state {
        case .idle, .requestingPermission, .denied: return WatchUI.activity[language]
        default: return tracker.sport.label[language]
        }
    }

    // MARK: - Le choix

    /// Le menu de départ.
    ///
    /// C'est l'écran entier, et pas un sélecteur caché derrière un second
    /// écran : au poignet, on tourne la couronne et on appuie. Une ligne
    /// touchée démarre la sortie — c'est le geste de l'application Exercice
    /// d'Apple, et c'est celui qu'on fait déjà sans y penser.
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

    private var deniedScreen: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "location.slash")
                .font(.title3)
                .foregroundStyle(.orange)
            Text(WatchUI.locationDenied[language])
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - L'effort

    /// Le temps d'effort affiché.
    ///
    /// Dehors, celui de la trace, pauses exclues par la vitesse — comme sur
    /// le téléphone. Dedans, celui de la session d'entraînement, qui sait
    /// quand on a mis en pause ; et le chrono du tracker si Santé manque.
    private var effortSeconds: TimeInterval {
        if tracker.sport.tracksLocation { return tracker.movingDuration }
        return workout.phase == .unavailable ? tracker.movingDuration : workout.elapsedSeconds
    }

    /// Les mètres à montrer en grand pour ce qui ne laisse pas de trace :
    /// ceux que la montre estime, quand elle en estime.
    private var indoorMeters: Double {
        tracker.sport.tracksLocation ? 0 : workout.measuredMeters
    }

    private var liveScreen: some View {
        VStack(spacing: 5) {
            // Le grand chiffre est celui qui bouge.
            Text(
                tracker.sport.tracksLocation
                    ? Format.distance(meters: tracker.meters, unit: unit, language: language)
                    : Format.stopwatch(seconds: effortSeconds)
            )
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .foregroundStyle(.green)
            .minimumScaleFactor(0.6)
            .lineLimit(1)
            .contentTransition(.numericText())

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 1) {
                    if tracker.sport.tracksLocation {
                        Text(Format.stopwatch(seconds: effortSeconds))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Text(Format.speedOrPace(
                            sport: tracker.sport,
                            secondsPerKm: tracker.recentPaceSecondsPerKm,
                            unit: unit,
                            language: language
                        ))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    } else if indoorMeters > 0 {
                        Text(Format.distance(meters: indoorMeters, unit: unit, language: language))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                        Text(WatchUI.measuredByWatch[language])
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(tracker.sport.label[language])
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 1) {
                    if workout.heartRateBpm > 0 {
                        HStack(spacing: 3) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.red)
                            Text("\(Int(workout.heartRateBpm))")
                                .font(.system(.body, design: .rounded, weight: .semibold))
                                .contentTransition(.numericText())
                        }
                    }
                    if workout.kilocalories > 0 {
                        Text("\(Int(workout.kilocalories)) kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .contentTransition(.numericText())
                    }
                }
            }

            // Ce qui manque, dit tout de suite : un signal GPS qu'on cherche,
            // ou Santé refusé — auquel cas ni cardio ni anneaux.
            if tracker.sport.tracksLocation, !tracker.hasUsableSignal {
                Text((tracker.currentAccuracy < 0 ? WatchUI.searchingGPS : WatchUI.weakSignal)[language])
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
            } else if workout.phase == .unavailable {
                Text(WatchUI.noHealth[language])
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
            }

            HStack(spacing: 6) {
                Button {
                    if tracker.state == .paused {
                        tracker.resume()
                        workout.resume()
                    } else {
                        tracker.pause()
                        workout.pause()
                    }
                } label: {
                    Image(systemName: tracker.state == .paused ? "play.fill" : "pause.fill")
                        .frame(maxWidth: .infinity)
                }
                .tint(.orange)

                Button {
                    finish()
                } label: {
                    Image(systemName: "flag.checkered")
                        .frame(maxWidth: .infinity)
                }
                .tint(.green)
            }
            .buttonStyle(.bordered)
        }
        .animation(.default, value: Int(effortSeconds))
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
                    Text(WatchUI.firstSplit[language])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Le bilan

    /// Arrête tout, et pose le bilan.
    ///
    /// La session d'entraînement se ferme tout de suite — c'est elle qui
    /// écrit dans Santé, et elle n'attend pas qu'on ait choisi d'enregistrer
    /// dans Stride ou non : les anneaux se ferment sur ce qui a été fait,
    /// pas sur ce qu'on garde dans son journal.
    private func finish() {
        let samples = workout.drainSamples()
        let kilocalories = workout.kilocalories
        let measured = workout.measuredMeters
        let sport = tracker.sport
        let average = samples.isEmpty
            ? 0
            : Int((samples.map(\.bpm).reduce(0, +) / Double(samples.count)).rounded())

        var log = tracker.finish()
        var seconds = tracker.movingDuration

        if !sport.tracksLocation {
            // Dedans, la session sait mieux que le chrono : elle exclut les
            // pauses et survit à l'écran éteint.
            if workout.phase != .unavailable { seconds = workout.elapsedSeconds }
            if seconds >= 60 {
                log = ActivityLog(
                    startedAt: workout.startedAt ?? tracker.startedAt ?? Date(),
                    sport: sport,
                    type: tracker.type,
                    meters: measured,
                    duration: seconds,
                    elevationGain: 0
                )
            } else {
                log = nil
            }
        }

        log?.heartRate = samples
        if kilocalories > 0 { log?.kilocalories = kilocalories }

        Task { await workout.finish() }

        typedKm = 0
        summary = Summary(
            sport: sport,
            seconds: seconds,
            meters: log?.meters ?? measured,
            kilocalories: kilocalories,
            averageBpm: average,
            log: log
        )
    }

    private func summaryScreen(_ summary: Summary) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                Label(summary.sport.label[language], systemImage: summary.sport.symbolName)
                    .font(.system(.body, design: .rounded, weight: .semibold))

                HStack(spacing: 10) {
                    figure(Format.stopwatch(seconds: summary.seconds), WatchUI.time)
                    if summary.meters > 0 {
                        figure(
                            Format.distance(meters: summary.meters, unit: unit, language: language),
                            WatchUI.distance
                        )
                    }
                }
                HStack(spacing: 10) {
                    if summary.kilocalories > 0 {
                        figure("\(Int(summary.kilocalories))", LocalizedText.constant("kcal"))
                    }
                    if summary.averageBpm > 0 {
                        figure("\(summary.averageBpm)", WatchUI.averageBpm)
                    }
                }

                if summary.log == nil {
                    Text(WatchUI.tooShort[language])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Button(WatchUI.close[language]) { leave() }
                        .buttonStyle(.bordered)
                } else {
                    // La distance des machines, à la couronne. La montre ne
                    // voit pas l'écran du home trainer ; l'athlète, si.
                    if summary.sport.asksDistanceAtTheEnd, summary.meters == 0 {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(WatchUI.machineDistance[language])
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(Format.distance(meters: typedKm * 1_000, unit: unit, language: language))
                                .font(.system(.title3, design: .rounded, weight: .bold))
                                .foregroundStyle(.green)
                                .focusable(true)
                                .digitalCrownRotation(
                                    $typedKm, from: 0, through: 200, by: 0.1,
                                    sensitivity: .medium, isContinuous: false,
                                    isHapticFeedbackEnabled: true
                                )
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.gray.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        save(summary)
                    } label: {
                        Label(WatchUI.save[language], systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button(WatchUI.discardActivity[language]) { leave() }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                }
            }
        }
    }

    private func figure(_ value: String, _ label: LocalizedText) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(.body, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label[language])
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save(_ summary: Summary) {
        guard var log = summary.log else { return leave() }
        if summary.sport.asksDistanceAtTheEnd, log.meters == 0, typedKm > 0 {
            log.meters = typedKm * 1_000
        }
        store.recordRun(log)
        leave()
    }

    /// Referme la sortie, enregistrée ou non, et rend l'écran d'accueil.
    private func leave() {
        tracker.reset()
        summary = nil
        dismiss()
    }
}
