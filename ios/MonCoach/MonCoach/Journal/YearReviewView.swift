import Charts
import SwiftUI
import MonCoachKit

/// Le bilan d'une année sportive.
///
/// Le journal répond à « qu'est-ce que j'ai fait cette semaine ». Personne
/// n'y lit une année : il faudrait faire défiler cinquante-deux barres et
/// additionner de tête. C'est pourtant à cette échelle que le travail
/// devient visible — un athlète régulier ne voit rien changer d'une semaine
/// à l'autre, et découvre en décembre qu'il a couru mille kilomètres.
struct YearReviewView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var year: Int

    /// L'année en cours par défaut : c'est celle qu'on vient regarder.
    init(year: Int = Calendar.current.component(.year, from: Date())) {
        _year = State(initialValue: year)
    }

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var maximumBpm: Double {
        HeartRateAnalysis.estimatedMaximum(age: store.profile?.age() ?? 30)
    }
    private var years: [Int] {
        let known = YearReview.availableYears(in: store.history.activities)
        return known.contains(year) ? known : ([year] + known).sorted(by: >)
    }
    private var review: YearReview {
        YearReview.review(of: store.history.activities, year: year, maximumBpm: maximumBpm)
    }

    var body: some View {
        let review = self.review
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if years.count > 1 { yearPicker }
                if review.isEmpty {
                    emptyCard
                } else {
                    totalsCard(review)
                    monthsCard(review)
                    sportsCard(review)
                    highlightsCard(review)
                    recordsCard(review)
                    shareCard(review)
                }
            }
            .padding(16)
        }
        .screenBackground()
        .navigationTitle(
            LocalizedText(fr: "Ton année", en: "Your year", es: "Tu año")[language]
        )
        .navigationBarTitleDisplayMode(.inline)
    }

    private var yearPicker: some View {
        Picker("", selection: $year) {
            ForEach(years, id: \.self) { year in
                Text(String(year)).tag(year)
            }
        }
        .pickerStyle(.segmented)
    }

    private var emptyCard: some View {
        Card(
            title: LocalizedText(
                fr: "Rien en \(String(year))",
                en: "Nothing in \(String(year))",
                es: "Nada en \(String(year))"
            )[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Aucune sortie cette année-là. Le bilan se remplit tout seul, sortie après sortie — et il compte aussi ce que tu importes en GPX.",
                    en: "No activity that year. The review fills itself in, activity after activity — and it counts what you import as GPX too.",
                    es: "Ninguna salida ese año. El balance se llena solo, salida tras salida, y también cuenta lo que importas en GPX."
                )
            )
        }
    }

    // MARK: - Les totaux

    private func totalsCard(_ review: YearReview) -> some View {
        Card(
            title: String(review.year),
            subtitle: LocalizedText(
                fr: "\(review.activeDays) jours de sport, \(review.longestStreakWeeks) semaines d'affilée au mieux",
                en: "\(review.activeDays) active days, \(review.longestStreakWeeks) weeks in a row at best",
                es: "\(review.activeDays) días de deporte, \(review.longestStreakWeeks) semanas seguidas como máximo"
            )[language]
        ) {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    StatTile(
                        value: Format.distance(meters: review.totals.meters, unit: unit, language: language),
                        label: UI.distance[language]
                    )
                    StatTile(
                        value: Format.stopwatch(seconds: review.totals.movingSeconds),
                        label: UI.duration[language]
                    )
                }
                HStack(spacing: 12) {
                    StatTile(
                        value: "\(review.totals.activityCount)",
                        label: LocalizedText(fr: "Sorties", en: "Activities", es: "Salidas")[language],
                        tint: Theme.primaryText
                    )
                    StatTile(
                        value: "\(Int(review.totals.elevationGain)) m",
                        label: UI.elevation[language],
                        tint: Theme.warning
                    )
                }
                if let versus = review.metersVersusPreviousYear {
                    let text = Format.distance(meters: abs(versus), unit: unit, language: language)
                    CoachText(
                        versus >= 0
                            ? LocalizedText(
                                fr: "\(text) de plus qu'en \(String(review.year - 1)).",
                                en: "\(text) more than in \(String(review.year - 1)).",
                                es: "\(text) más que en \(String(review.year - 1))."
                            )
                            : LocalizedText(
                                fr: "\(text) de moins qu'en \(String(review.year - 1)) — une année se juge aussi sur ce qu'elle a coûté ailleurs.",
                                en: "\(text) less than in \(String(review.year - 1)) — a year is also judged on what it cost elsewhere.",
                                es: "\(text) menos que en \(String(review.year - 1)): un año también se juzga por lo que costó en otra parte."
                            ),
                        color: versus >= 0 ? Theme.accent : Theme.secondaryText
                    )
                }
                if let comparison = comparisons(review) {
                    CoachText(comparison)
                }
            }
        }
    }

    /// Les comparaisons qui rendent un nombre lisible.
    ///
    /// Elles n'ajoutent aucune donnée : elles situent un chiffre que
    /// personne ne sait situer. Rendues seulement quand l'unité est
    /// dépassée — « 0,08 Everest » n'aide personne.
    private func comparisons(_ review: YearReview) -> LocalizedText? {
        var parts: [LocalizedText] = []
        if let marathons = review.marathons {
            let count = Format.number(marathons, decimals: 1, language: language)
            parts.append(LocalizedText(
                fr: "\(count) marathons de distance",
                en: "\(count) marathons of distance",
                es: "\(count) maratones de distancia"
            ))
        }
        if let everests = review.everests {
            let count = Format.number(everests, decimals: 1, language: language)
            parts.append(LocalizedText(
                fr: "\(count) fois la hauteur de l'Everest",
                en: "\(count) times the height of Everest",
                es: "\(count) veces la altura del Everest"
            ))
        }
        guard !parts.isEmpty else { return nil }
        return LocalizedText(
            fr: "Soit " + parts.map { $0[.french] }.joined(separator: ", et ") + ".",
            en: "That is " + parts.map { $0[.english] }.joined(separator: ", and ") + ".",
            es: "Es decir " + parts.map { $0[.spanish] }.joined(separator: ", y ") + "."
        )
    }

    // MARK: - Mois par mois

    private func monthsCard(_ review: YearReview) -> some View {
        Card(
            title: LocalizedText(fr: "Mois par mois", en: "Month by month", es: "Mes a mes")[language],
            subtitle: review.busiestMonth.map { month in
                LocalizedText(
                    fr: "Ton meilleur mois : \(monthName(month.month))",
                    en: "Your best month: \(monthName(month.month))",
                    es: "Tu mejor mes: \(monthName(month.month))"
                )[language]
            }
        ) {
            // L'abscisse est une date, pas le nom du mois : en français,
            // janvier, juin et juillet partagent leur initiale, et trois
            // mois se fondraient en une seule barre.
            Chart(review.months) { month in
                BarMark(
                    x: .value(
                        LocalizedText(fr: "Mois", en: "Month", es: "Mes")[language],
                        firstDay(of: month.month),
                        unit: .month
                    ),
                    y: .value(UI.distance[language], month.totals.meters / 1_000)
                )
                .foregroundStyle(Theme.accent)
                .cornerRadius(3)
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .month, count: 2)) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(date.formatted(.dateTime.month(.abbreviated).locale(language.locale)))
                        }
                    }
                }
            }
            .chartYAxisLabel("km")
            .frame(height: 170)
        }
    }

    // MARK: - Par sport

    private func sportsCard(_ review: YearReview) -> some View {
        Card(title: LocalizedText(fr: "Par sport", en: "By sport", es: "Por deporte")[language]) {
            VStack(spacing: 10) {
                let sports = Sport.allCases.filter { review.bySport[$0] != nil }
                let longest = max(1, sports.compactMap { review.bySport[$0]?.meters }.max() ?? 1)
                ForEach(sports) { sport in
                    let totals = review.bySport[sport]!
                    VStack(spacing: 4) {
                        HStack(spacing: 10) {
                            Image(systemName: sport.symbolName)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 22)
                            Text(sport.label[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Text(Format.distance(meters: totals.meters, unit: unit, language: language))
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.primaryText)
                        }
                        HStack(spacing: 10) {
                            ProgressBar(value: totals.meters / longest)
                            Text(
                                "\(totals.activityCount) · "
                                + Format.stopwatch(seconds: totals.movingSeconds)
                            )
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 96, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Les sorties qui ont marqué l'année

    private func highlightsCard(_ review: YearReview) -> some View {
        Group {
            if review.longestActivity != nil || review.highestClimb != nil {
                Card(
                    title: LocalizedText(
                        fr: "Ce dont tu te souviendras",
                        en: "What you will remember",
                        es: "Lo que recordarás"
                    )[language]
                ) {
                    VStack(spacing: 10) {
                        if let longest = review.longestActivity {
                            highlightRow(
                                longest,
                                icon: "arrow.left.and.right",
                                title: LocalizedText(
                                    fr: "La plus longue", en: "The longest", es: "La más larga"
                                ),
                                value: Format.distance(meters: longest.meters, unit: unit, language: language)
                            )
                        }
                        if let climb = review.highestClimb, climb.elevationGain >= 100 {
                            highlightRow(
                                climb,
                                icon: "mountain.2.fill",
                                title: LocalizedText(
                                    fr: "La plus haute", en: "The highest", es: "La más alta"
                                ),
                                value: "\(Int(climb.elevationGain)) m D+"
                            )
                        }
                    }
                }
            }
        }
    }

    private func highlightRow(
        _ highlight: YearHighlight,
        icon: String,
        title: LocalizedText,
        value: String
    ) -> some View {
        // La sortie complète est retrouvée par son identifiant : le bilan ne
        // transporte que le résumé, pas les milliers de points de la trace.
        let activity = store.history.activities.first { $0.id == highlight.activityID }
        return Group {
            if let activity {
                NavigationLink {
                    ActivityDetailView(activity: activity)
                } label: {
                    highlightLabel(highlight, icon: icon, title: title, value: value, chevron: true)
                }
                .buttonStyle(.plain)
            } else {
                highlightLabel(highlight, icon: icon, title: title, value: value, chevron: false)
            }
        }
    }

    private func highlightLabel(
        _ highlight: YearHighlight,
        icon: String,
        title: LocalizedText,
        value: String,
        chevron: Bool
    ) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Theme.warning)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(title[language])
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                Text(highlight.date.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.accent)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    // MARK: - Les records de l'année

    private func recordsCard(_ review: YearReview) -> some View {
        Group {
            if !review.records.isEmpty {
                Card(
                    title: LocalizedText(
                        fr: "Les records posés cette année",
                        en: "The records set this year",
                        es: "Los récords logrados este año"
                    )[language],
                    subtitle: LocalizedText(
                        fr: "Ceux qui tiennent encore aujourd'hui.",
                        en: "The ones that still stand today.",
                        es: "Los que todavía se mantienen hoy."
                    )[language]
                ) {
                    VStack(spacing: 8) {
                        ForEach(review.records) { record in
                            HStack {
                                Image(systemName: "trophy.fill")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.warning)
                                Text(record.distance.label[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                Spacer()
                                Text(Format.stopwatch(seconds: record.duration))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                                Text(record.date.formatted(.dateTime.day().month(.abbreviated)))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(width: 54, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Le partage

    private func shareCard(_ review: YearReview) -> some View {
        let text = review.summary(unit: unit, language: language)
        return Card {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(
                    LocalizedText(
                        fr: "Ton bilan ne part nulle part tout seul. Si tu veux le montrer, c'est toi qui l'envoies, et c'est cette phrase qui part — rien d'autre.",
                        en: "Your review goes nowhere on its own. If you want to show it, you send it yourself, and this sentence is what goes — nothing else.",
                        es: "Tu balance no va a ninguna parte por sí solo. Si quieres enseñarlo, lo envías tú, y lo que sale es esta frase, nada más."
                    )
                )
                Text(text)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.primaryText)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 10))
                ShareLink(item: text) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                        Text(LocalizedText(fr: "Partager", en: "Share", es: "Compartir")[language])
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.primaryText)
                }
            }
        }
    }

    // MARK: - Les mois, dans la langue de l'athlète

    private func firstDay(of month: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: 1)) ?? Date()
    }

    private func monthName(_ month: Int) -> String {
        firstDay(of: month).formatted(.dateTime.month(.wide).locale(language.locale))
    }
}
