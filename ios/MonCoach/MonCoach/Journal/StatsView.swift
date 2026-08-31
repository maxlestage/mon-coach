import Charts
import SwiftUI
import MonCoachKit

/// Les statistiques : ce que l'entraînement donne, en courbes.
///
/// Pourquoi cet écran existe
/// -------------------------
/// Le journal disait ce qu'on avait fait, sortie par sortie. Il ne disait
/// pas si ça montait. Or c'est la seule question qu'on se pose vraiment au
/// bout de trois mois — « est-ce que je progresse ? » — et elle n'a de
/// réponse que dans une série : un chiffre isolé ne progresse pas.
///
/// Tout est filtré par sport. C'est la décision structurante de l'écran :
/// additionner cent kilomètres de vélo et dix de course donne cent dix
/// kilomètres de rien du tout, et une courbe qui mélange les deux monte le
/// jour où l'on prend le vélo. Sur « tous les sports », c'est donc le temps
/// qui porte les graphiques — la seule grandeur que tous partagent.
struct StatsView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var scope: ActivityStats.Scope = .everything
    @State private var window: Window = .twelveWeeks
    @State private var showsScopePicker = false
    @State private var pickedSport: Sport = .run

    /// La fenêtre regardée. Quatre choix, pas dix : une liste de durées
    /// devient elle-même une décision à prendre avant de lire le graphique.
    enum Window: Int, CaseIterable, Identifiable {
        case sixWeeks = 6
        case twelveWeeks = 12
        case halfYear = 26
        case year = 52

        var id: Int { rawValue }
        var weeks: Int { rawValue }
        var label: LocalizedText {
            switch self {
            case .sixWeeks: LocalizedText(fr: "6 sem.", en: "6 wks", es: "6 sem.")
            case .twelveWeeks: LocalizedText(fr: "12 sem.", en: "12 wks", es: "12 sem.")
            case .halfYear: LocalizedText(fr: "6 mois", en: "6 mo", es: "6 meses")
            case .year: LocalizedText(fr: "1 an", en: "1 yr", es: "1 año")
            }
        }
    }

    private var activities: [ActivityLog] { store.history.activities }
    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var maximumBpm: Double {
        HeartRateAnalysis.estimatedMaximum(age: store.profile?.age() ?? 30)
    }

    private var series: [StatsPoint] {
        ActivityStats.weekly(
            of: activities, scope: scope, weeks: window.weeks, maximumBpm: maximumBpm
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if activities.isEmpty {
                    Card {
                        CoachText(
                            LocalizedText(
                                fr: "Les courbes arrivent avec tes premières sorties. Deux semaines suffisent à voir quelque chose.",
                                en: "The charts arrive with your first activities. Two weeks are enough to see something.",
                                es: "Las curvas llegan con tus primeras salidas. Dos semanas bastan para ver algo."
                            )
                        )
                    }
                } else {
                    scopeCard
                    thisWeekCard
                    volumeCard
                    weekCalendarCard
                    effortCard
                    paceCard
                    zonesCard
                    shareCard
                }
            }
            .padding(16)
        }
        .screenBackground()
        .sheet(isPresented: $showsScopePicker) {
            SportPickerView(selection: $pickedSport, recents: practisedSports)
        }
        .onChange(of: pickedSport) { _, sport in
            scope = .sport(sport)
        }
    }

    /// Les sports réellement pratiqués : c'est parmi eux qu'on filtre, pas
    /// parmi les quarante-huit du catalogue.
    private var practisedSports: [Sport] {
        var seen: [Sport] = []
        for activity in activities.sorted(by: { $0.startedAt > $1.startedAt })
        where !seen.contains(activity.sport) {
            seen.append(activity.sport)
        }
        return seen
    }

    // MARK: - Le périmètre

    private var scopeCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    ScopeChip(
                        title: LocalizedText(fr: "Tout", en: "All", es: "Todo")[language],
                        symbol: "square.grid.2x2",
                        selected: scope == .everything
                    ) { scope = .everything }

                    ForEach(practisedSports.prefix(2), id: \.self) { sport in
                        ScopeChip(
                            title: sport.label[language],
                            symbol: sport.symbolName,
                            selected: scope == .sport(sport)
                        ) { scope = .sport(sport) }
                    }

                    ScopeChip(
                        title: LocalizedText(fr: "Autre", en: "Other", es: "Otro")[language],
                        symbol: "ellipsis",
                        selected: isPickedElsewhere
                    ) { showsScopePicker = true }
                }
                Picker("", selection: $window) {
                    ForEach(Window.allCases) { choice in
                        Text(choice.label[language]).tag(choice)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    /// Le sport regardé sort-il des deux raccourcis affichés ?
    private var isPickedElsewhere: Bool {
        guard case .sport(let sport) = scope else { return false }
        return !practisedSports.prefix(2).contains(sport)
    }

    // MARK: - Cette semaine

    private var thisWeekCard: some View {
        let comparison = ActivityStats.comparison(
            of: activities, scope: scope, days: 7, maximumBpm: maximumBpm
        )
        return Card(
            title: LocalizedText(fr: "Ces sept jours", en: "These seven days", es: "Estos siete días")[language],
            subtitle: scope.label[language]
        ) {
            HStack(spacing: 12) {
                if scope.comparesDistance {
                    StatTile(
                        value: Format.distance(meters: comparison.current.meters, unit: unit, language: language),
                        label: UI.distance[language]
                    )
                }
                StatTile(
                    value: Format.stopwatch(seconds: comparison.current.movingSeconds),
                    label: UI.duration[language]
                )
                StatTile(
                    value: "\(comparison.current.activityCount)",
                    label: LocalizedText(fr: "Sorties", en: "Activities", es: "Salidas")[language]
                )
                if scope.comparesDistance {
                    StatTile(
                        value: "\(Int(comparison.current.elevationGain)) m",
                        label: UI.elevation[language],
                        tint: Theme.warning
                    )
                }
            }
            // Un chiffre isolé ne dit rien : c'est l'écart à la semaine
            // précédente qui informe, et lui seul.
            if let change = comparison.change({ scope.comparesDistance ? $0.meters : $0.movingSeconds }) {
                HStack(spacing: 6) {
                    Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 11, weight: .bold))
                    Text(
                        LocalizedText(
                            fr: "\(Format.signed(change, decimals: 0)) % par rapport aux sept jours d'avant",
                            en: "\(Format.signed(change, decimals: 0)) % versus the seven days before",
                            es: "\(Format.signed(change, decimals: 0)) % frente a los siete días anteriores"
                        )[language]
                    )
                    .font(Theme.captionFont)
                }
                .foregroundStyle(change >= 0 ? Theme.accent : Theme.secondaryText)
            }
        }
    }

    // MARK: - Le volume

    private var volumeCard: some View {
        let points = series
        let showsDistance = scope.comparesDistance
        return Card(
            title: showsDistance
                ? LocalizedText(fr: "Volume par semaine", en: "Weekly volume", es: "Volumen por semana")[language]
                : LocalizedText(fr: "Temps par semaine", en: "Weekly time", es: "Tiempo por semana")[language],
            subtitle: showsDistance
                ? nil
                : LocalizedText(
                    fr: "En heures : additionner les kilomètres de plusieurs sports ne voudrait rien dire.",
                    en: "In hours: adding up kilometres across sports would mean nothing.",
                    es: "En horas: sumar kilómetros de varios deportes no significaría nada."
                )[language]
        ) {
            Chart(points) { point in
                BarMark(
                    x: .value(LocalizedText(fr: "Semaine", en: "Week", es: "Semana")[language], point.start, unit: .weekOfYear),
                    y: .value(
                        showsDistance ? UI.distance[language] : UI.duration[language],
                        showsDistance ? point.kilometres : point.seconds / 3_600
                    )
                )
                .foregroundStyle(Theme.accent)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 170)

            if let best = points.max(by: { $0.meters < $1.meters }), !best.isEmpty, showsDistance {
                Text(
                    LocalizedText(
                        fr: "Meilleure semaine : \(Format.distance(meters: best.meters, unit: unit, language: language))",
                        en: "Best week: \(Format.distance(meters: best.meters, unit: unit, language: language))",
                        es: "Mejor semana: \(Format.distance(meters: best.meters, unit: unit, language: language))"
                    )[language]
                )
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    // MARK: - Le calendrier de la semaine

    private var weekCalendarCard: some View {
        let bubbles = ActivityStats.week(of: activities, scope: scope)
        let peak = bubbles.map(\.seconds).max() ?? 0
        return Card(
            title: LocalizedText(fr: "Ta semaine", en: "Your week", es: "Tu semana")[language],
            subtitle: LocalizedText(
                fr: "Les jours vides comptent autant que les autres : c'est là que se voit la régularité.",
                en: "Empty days count as much as the rest: that is where consistency shows.",
                es: "Los días vacíos cuentan tanto como el resto: ahí se ve la regularidad."
            )[language]
        ) {
            HStack(alignment: .top, spacing: 4) {
                ForEach(bubbles) { bubble in
                    VStack(spacing: 6) {
                        Text(weekdayInitial(bubble.weekdayIndex))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(Theme.secondaryText)
                        ZStack {
                            Circle()
                                .fill(bubble.activityCount > 0 ? Theme.accent.opacity(0.85) : Theme.surfaceRaised)
                                .frame(width: diameter(of: bubble.seconds, peak: peak))
                            if bubble.activityCount > 0, let sport = bubble.sports.first {
                                Image(systemName: sport.symbolName)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(Theme.background)
                            }
                        }
                        .frame(height: 44)
                        Text(bubble.activityCount > 0 ? Format.stopwatch(seconds: bubble.seconds) : "–")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    /// Le diamètre d'une bulle : proportionnel à la racine du temps, pas au
    /// temps. L'œil compare des aires, pas des rayons — à diamètre
    /// proportionnel, une sortie deux fois plus longue paraîtrait quatre
    /// fois plus grosse.
    private func diameter(of seconds: TimeInterval, peak: TimeInterval) -> CGFloat {
        guard seconds > 0, peak > 0 else { return 10 }
        return 16 + 26 * CGFloat((seconds / peak).squareRoot())
    }

    private func weekdayInitial(_ index: Int) -> String {
        let initials: [Language: [String]] = [
            .french: ["L", "M", "M", "J", "V", "S", "D"],
            .english: ["M", "T", "W", "T", "F", "S", "S"],
            .spanish: ["L", "M", "X", "J", "V", "S", "D"],
        ]
        return (initials[language] ?? initials[.french]!)[index]
    }

    // MARK: - L'effort

    private var effortCard: some View {
        let points = series
        return Card(
            title: LocalizedText(fr: "Effort par semaine", en: "Weekly effort", es: "Esfuerzo por semana")[language],
            subtitle: LocalizedText(
                fr: "Le temps passé pondéré par l'intensité : une heure de fractionné pèse plus que deux heures de marche.",
                en: "Time weighted by intensity: an hour of intervals weighs more than two hours of walking.",
                es: "El tiempo ponderado por la intensidad: una hora de series pesa más que dos horas de caminata."
            )[language]
        ) {
            Chart(points) { point in
                AreaMark(
                    x: .value(LocalizedText(fr: "Semaine", en: "Week", es: "Semana")[language], point.start, unit: .weekOfYear),
                    y: .value(LocalizedText(fr: "Effort", en: "Effort", es: "Esfuerzo")[language], point.load)
                )
                .foregroundStyle(
                    .linearGradient(
                        colors: [Theme.warning.opacity(0.55), Theme.warning.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                LineMark(
                    x: .value(LocalizedText(fr: "Semaine", en: "Week", es: "Semana")[language], point.start, unit: .weekOfYear),
                    y: .value(LocalizedText(fr: "Effort", en: "Effort", es: "Esfuerzo")[language], point.load)
                )
                .foregroundStyle(Theme.warning)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { _ in
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 150)
        }
    }

    // MARK: - L'allure

    @ViewBuilder
    private var paceCard: some View {
        // La tendance d'allure n'a de sens que sur un seul sport qui se lit
        // en allure : mêler un fractionné et une randonnée dessine une
        // courbe de ce qu'on a fait, pas de ce qu'on vaut.
        if case .sport(let sport) = scope, sport.readout == .pacePerKilometre {
            let trend = ActivityStats.paceTrend(of: activities, sport: sport, weeks: window.weeks)
            if trend.count >= 3 {
                Card(
                    title: LocalizedText(fr: "Allure moyenne", en: "Average pace", es: "Ritmo medio")[language],
                    subtitle: LocalizedText(
                        fr: "Plus la courbe descend, plus tu vas vite. Les semaines sans kilomètres sont absentes plutôt qu'à zéro.",
                        en: "The lower the curve, the faster you are. Weeks without kilometres are absent rather than zero.",
                        es: "Cuanto más baja la curva, más rápido vas. Las semanas sin kilómetros faltan en vez de valer cero."
                    )[language]
                ) {
                    Chart(trend, id: \.start) { entry in
                        LineMark(
                            x: .value(LocalizedText(fr: "Semaine", en: "Week", es: "Semana")[language], entry.start),
                            y: .value(UI.pace[language], entry.secondsPerKm / 60)
                        )
                        .foregroundStyle(Theme.accent)
                        .interpolationMethod(.catmullRom)
                        PointMark(
                            x: .value(LocalizedText(fr: "Semaine", en: "Week", es: "Semana")[language], entry.start),
                            y: .value(UI.pace[language], entry.secondsPerKm / 60)
                        )
                        .foregroundStyle(Theme.accent)
                    }
                    // L'axe est inversé : une allure plus basse est une
                    // meilleure allure, et une courbe qui descend quand on
                    // progresse se lit à l'envers de tout le reste.
                    .chartYScale(domain: .automatic(includesZero: false, reversed: true))
                    .frame(height: 150)

                    if let first = trend.first, let last = trend.last, trend.count >= 4 {
                        let gain = first.secondsPerKm - last.secondsPerKm
                        Text(
                            gain >= 5
                                ? LocalizedText(
                                    fr: "Tu as gagné \(Int(gain)) s au kilomètre depuis le début de la période.",
                                    en: "You have gained \(Int(gain)) s per kilometre since the start of the window.",
                                    es: "Has ganado \(Int(gain)) s por kilómetro desde el inicio del periodo."
                                )[language]
                                : LocalizedText(
                                    fr: "L'allure est stable sur la période. Sur des sorties faciles, c'est le résultat attendu : c'est le volume qui construit.",
                                    en: "Pace is stable over the window. On easy runs that is the expected result: volume is what builds.",
                                    es: "El ritmo se mantiene estable. En rodajes suaves es lo esperado: el volumen es lo que construye."
                                )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Les zones cardiaques

    @ViewBuilder
    private var zonesCard: some View {
        let since = Calendar.current.date(
            byAdding: .weekOfYear, value: -window.weeks, to: Date()
        ) ?? Date()
        let zones = ActivityStats.heartRateZones(
            of: activities.filter(scope.matches), since: since, maximumBpm: maximumBpm
        )
        if !zones.isEmpty {
            let table = HeartRateAnalysis.zones(maximumBpm: maximumBpm)
            let total = zones.values.reduce(0, +)
            Card(
                title: LocalizedText(fr: "Où bat ton cœur", en: "Where your heart beats", es: "Dónde late tu corazón")[language],
                subtitle: LocalizedText(
                    fr: "La majorité du temps doit se passer en bas : c'est le socle qui rend les séances dures possibles.",
                    en: "Most of the time should sit low: that base is what makes the hard sessions possible.",
                    es: "La mayor parte del tiempo debe estar abajo: esa base es la que hace posibles las sesiones duras."
                )[language]
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(table.reversed()) { zone in
                        let seconds = zones[zone.index] ?? 0
                        HStack(spacing: 10) {
                            Text("Z\(zone.index)")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.secondaryText)
                                .frame(width: 22, alignment: .leading)
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 5)
                                    .fill(zoneTint(zone.index))
                                    .frame(
                                        width: total > 0
                                            ? max(2, geometry.size.width * CGFloat(seconds / total))
                                            : 2
                                    )
                            }
                            .frame(height: 14)
                            Text(Format.stopwatch(seconds: seconds))
                                .font(.system(size: 11, design: .rounded))
                                .foregroundStyle(Theme.secondaryText)
                                .frame(width: 58, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    private func zoneTint(_ index: Int) -> Color {
        switch index {
        case 1, 2: Theme.accent
        case 3: Theme.warning
        default: Theme.danger
        }
    }

    // MARK: - La répartition

    @ViewBuilder
    private var shareCard: some View {
        let since = Calendar.current.date(
            byAdding: .weekOfYear, value: -window.weeks, to: Date()
        ) ?? Date()
        let share = ActivityStats.share(of: activities, since: since)
        if share.count > 1 {
            let total = share.reduce(0) { $0 + $1.seconds }
            Card(
                title: LocalizedText(fr: "Ce que tu fais vraiment", en: "What you actually do", es: "Lo que realmente haces")[language],
                subtitle: LocalizedText(
                    fr: "En temps, parce que c'est la seule grandeur que tous les sports partagent.",
                    en: "In time, because it is the only measure every sport shares.",
                    es: "En tiempo, porque es la única medida que todos los deportes comparten."
                )[language]
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(share.prefix(6), id: \.sport) { entry in
                        HStack(spacing: 10) {
                            Image(systemName: entry.sport.symbolName)
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack {
                                    Text(entry.sport.label[language])
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.primaryText)
                                    Spacer()
                                    Text("\(Int((entry.seconds / total * 100).rounded())) %")
                                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Theme.secondaryText)
                                }
                                GeometryReader { geometry in
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Theme.accent.opacity(0.75))
                                        .frame(width: max(2, geometry.size.width * CGFloat(entry.seconds / total)))
                                }
                                .frame(height: 8)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Une pastille de filtre : un sport, ou tout.
private struct ScopeChip: View {
    var title: String
    var symbol: String
    var selected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 11))
                Text(title)
                    .lineLimit(1)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(selected ? Theme.background : Theme.primaryText)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(selected ? Theme.accent : Theme.surfaceRaised, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
