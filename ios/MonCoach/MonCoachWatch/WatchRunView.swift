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

    private var lastSport: Sport { Sport(rawValue: lastSportID) ?? .run }

    /// Les sports dans l'ordre du menu : le dernier choisi en tête, les
    /// autres derrière, dans leur ordre habituel.
    ///
    /// Le premier de la liste est celui qu'on atteint sans tourner la
    /// couronne — c'est le seul rang qui coûte zéro geste, et il revient à
    /// ce qu'on fait le plus souvent.
    private var menu: [Sport] {
        [lastSport] + Sport.allCases.filter { $0 != lastSport }
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
                TabView(selection: $page) {
                    liveScreen.tag(0)
                    splitsScreen.tag(1)
                }
                .tabViewStyle(.verticalPage)
            }
        }
        .navigationTitle(WatchUI.run[language])
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
                ForEach(menu) { sport in
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
        }
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
        return nil
    }

    /// Lance la sortie, et retient le choix pour la prochaine fois.
    ///
    /// L'intention de séance suit le plan quand c'est bien la course prévue
    /// qu'on va faire, et vaut « endurance » sinon : un tempo prescrit n'a
    /// aucun sens appliqué à une randonnée.
    private func start(_ sport: Sport) {
        lastSportID = sport.rawValue
        let planned = store.todayRun
        tracker.start(
            sport: sport,
            type: sport == .run ? (planned?.type ?? .easy) : .easy
        )
        heart.start()
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
                    Text(Format.speedOrPace(
                        sport: tracker.sport,
                        secondsPerKm: tracker.recentPaceSecondsPerKm,
                        unit: unit,
                        language: language
                    ))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
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
