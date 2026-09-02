import Charts
import SwiftUI
import MonCoachKit

/// A dated value on a chart. Charts needs `Identifiable`, and Swift has no
/// key paths into tuples, so the pairs the maths layer returns get wrapped here.
struct TrendPoint: Identifiable, Equatable {
    var date: Date
    var value: Double
    var id: Date { date }
}

/// One tracked lift and everything logged on it.
struct LiftHistory: Identifiable, Equatable {
    var exercise: Exercise
    var sets: [SetLog]
    var id: String { exercise.id }
}

/// What actually changed: body weight, estimated maxes, volume, consistency.
struct ProgressDashboardView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var history: TrainingHistory { store.history }

    /// Ce qu'on regarde du volume. Trois lectures d'une même réalité, et
    /// elles ne mentent pas au même endroit.
    @State private var measure: VolumeMeasure = .sets

    /// Vrai une fois que les barres ont poussé. Une seule fois : revenir
    /// sur l'onglet ne doit pas rejouer la croissance, sinon la mise en
    /// scène devient une attente qu'on subit à chaque coup d'œil.
    @State private var grown = false

    /// Les animations ne partent pas si le téléphone demande moins de
    /// mouvement — les barres sont alors à leur hauteur dès la première
    /// image, et le graphique se lit exactement pareil.
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Douze semaines : trois mois se lisent d'un coup d'œil au pouce, et
    /// c'est la durée d'un bloc et demi — assez pour qu'une tendance ait un
    /// sens, assez court pour que chaque barre reste distincte.
    private static let window = 12

    private var weeks: [VolumeWeek] {
        TrainingVolume.weeks(from: history.sessions, window: Self.window)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    summaryCard.appears(0)
                    volumeCard.appears(1)
                    bodyWeightCard.appears(2)
                    strengthCard.appears(3)
                    if store.isUnlocked(.weeklyReview) {
                        weeklyReviewCard.appears(4)
                    } else {
                        PlusLockedCard(feature: .weeklyReview).appears(4)
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(UI.progress[language])
            .sectionGuide(.progress)
        }
        .tint(Theme.accent)
    }

    // MARK: Summary

    private var summaryCard: some View {
        let completed = history.sessions.filter { !$0.skipped }
        let tonnage = completed.reduce(0.0) { $0 + $1.totalVolumeKg }
        let streak = TrainingVolume.streak(from: history.sessions)
        return Card(title: LocalizedText(fr: "Depuis le début", en: "Since the start", es: "Desde el principio")[language]) {
            HStack(spacing: 12) {
                StatTile(
                    value: "\(completed.count)",
                    label: completed.count > 1 ? LocalizedText(fr: "séances", en: "sessions", es: "sesiones")[language] : LocalizedText(fr: "séance", en: "session", es: "sesión")[language]
                )
                StatTile(value: "\(completed.reduce(0) { $0 + $1.sets.count })", label: LocalizedText(fr: "séries", en: "sets", es: "series")[language])
                StatTile(value: Self.tonnage(tonnage, unit: unit), label: LocalizedText(fr: "soulevé en tout", en: "lifted in total", es: "levantado en total")[language])
                StatTile(
                    value: "\(streak)",
                    label: streak > 1 ? LocalizedText(fr: "semaines d'affilée", en: "weeks in a row", es: "semanas seguidas")[language] : LocalizedText(fr: "semaine d'affilée", en: "week in a row", es: "semana seguida")[language]
                )
            }
        }
    }

    /// Le tonnage dit sans arrondir jusqu'à l'inutile.
    ///
    /// « 1 t » pour dix-huit cents kilos efface presque la moitié du chiffre,
    /// et c'est le genre de perte qu'on ne remarque pas parce qu'elle a
    /// l'air propre. Sous le millier on parle en unités de l'athlète,
    /// au-dessus on garde une décimale tant qu'elle change quelque chose.
    private static func tonnage(_ kg: Double, unit: UnitSystem) -> String {
        let value = unit == .metric ? kg : kg / 0.45359237
        let big = unit == .metric ? "t" : "k lb"
        if value < 1_000 { return Format.weight(kg, unit: unit, decimals: 0) }
        if value < 10_000 {
            return Format.number(value / 1_000, decimals: 1) + " " + big
        }
        return Format.number((value / 1_000).rounded(), decimals: 0) + " " + big
    }

    // MARK: Volume

    /// Le volume, semaine après semaine, sur une fenêtre fixe de trois mois.
    ///
    /// Ce qui a changé, et pourquoi
    /// ----------------------------
    /// La version précédente ne dessinait que les semaines travaillées. Avec
    /// deux séances au compteur, ça donnait deux barres aussi larges que
    /// l'écran, collées l'une à l'autre : plus d'axe du temps, pas de trou
    /// visible, aucune tendance lisible — un graphique où il n'y avait
    /// littéralement rien à voir.
    ///
    /// La fenêtre est maintenant fixe et se termine sur la semaine en cours.
    /// Les semaines sans séance y figurent, vides : c'est ce qui rend une
    /// barre haute lisible comme une grosse semaine et un blanc lisible
    /// comme une semaine sautée. La moyenne des semaines travaillées passe
    /// en trait pointillé, parce qu'une barre isolée ne dit rien tant qu'on
    /// n'a pas de quoi la comparer.
    @ViewBuilder
    private var volumeCard: some View {
        let weeks = self.weeks
        let average = TrainingVolume.average(of: weeks, measure: measure)
        let best = TrainingVolume.best(of: weeks, measure: measure)
        let worked = weeks.filter { !$0.isEmpty }

        Card(
            title: LocalizedText(fr: "Volume par semaine", en: "Volume per week", es: "Volumen por semana")[language],
            subtitle: measure.explanation[language]
        ) {
            Picker("", selection: $measure) {
                ForEach(VolumeMeasure.allCases) { option in
                    Text(option.label[language]).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Chart {
                ForEach(weeks) { week in
                    BarMark(
                        x: .value("Semaine", week.start, unit: .weekOfYear),
                        // Les barres poussent depuis le bas à l'ouverture,
                        // et se réajustent quand on change de mesure. Un
                        // graphique qui apparaît fini est une image ; un
                        // graphique qui pousse fait lire les hauteurs les
                        // unes par rapport aux autres, ce qui est tout ce
                        // qu'on lui demande.
                        y: .value(
                            measure.label[language],
                            grown ? measure.value(of: week) : 0
                        ),
                        width: .ratio(0.6)
                    )
                    .foregroundStyle(
                        week.id == weeks.last?.id ? Theme.accent : Theme.accent.opacity(0.45)
                    )
                    .cornerRadius(3)
                }

                if let average, worked.count >= 2 {
                    RuleMark(y: .value("Moyenne", average))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(Theme.primaryText.opacity(0.45))
                        .annotation(position: .top, alignment: .leading) {
                            Text(LocalizedText(fr: "moyenne \(Self.format(average, measure: measure, unit: unit))", en: "average \(Self.format(average, measure: measure, unit: unit))", es: "media \(Self.format(average, measure: measure, unit: unit))")[language])
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.secondaryText)
                        }
                }
            }
            .chartXAxis {
                // Une étiquette toutes les trois semaines : douze dates
                // collées deviennent une bouillie grise, et personne ne lit
                // un axe qu'il ne peut pas déchiffrer.
                AxisMarks(values: .stride(by: .weekOfYear, count: 3)) { _ in
                    AxisGridLine().foregroundStyle(Theme.separator)
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(.system(size: 10))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine().foregroundStyle(Theme.separator)
                    AxisValueLabel {
                        if let number = value.as(Double.self) {
                            Text(Self.axisLabel(number, measure: measure, unit: unit))
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                }
            }
            .frame(height: 170)
            .animation(reduceMotion ? nil : Motion.settle, value: measure)
            .onAppear {
                guard !grown else { return }
                grow()
            }
            .onTabSelected {
                guard grown, !reduceMotion else { return }
                Motion.replay { grown = false } then: { grow(after: Motion.splashHold) }
            }

            volumeStanding(weeks: weeks, average: average, best: best)
        }
    }

    private func grow(after lead: Double = 0) {
        if reduceMotion {
            grown = true
        } else {
            withAnimation(Motion.settle.delay(lead + 0.15)) { grown = true }
        }
    }

    /// Ce que la semaine en cours vaut par rapport aux précédentes.
    ///
    /// C'est la seule lecture qui fait agir : « quatre séries de moins que
    /// d'habitude » dit quoi faire, là où une barre isolée ne dit rien.
    @ViewBuilder
    private func volumeStanding(
        weeks: [VolumeWeek],
        average: Double?,
        best: VolumeWeek?
    ) -> some View {
        let current = weeks.last.map { measure.value(of: $0) } ?? 0
        HStack(spacing: 12) {
            StatTile(
                value: Self.format(current, measure: measure, unit: unit),
                label: LocalizedText(fr: "cette semaine", en: "this week", es: "esta semana")[language],
                tint: current > 0 ? Theme.accent : Theme.secondaryText
            )
            if let average {
                StatTile(
                    value: Self.format(average, measure: measure, unit: unit),
                    label: LocalizedText(fr: "moyenne", en: "average", es: "media")[language],
                    tint: Theme.secondaryText
                )
            }
            if let best {
                StatTile(
                    value: Self.format(measure.value(of: best), measure: measure, unit: unit),
                    label: LocalizedText(fr: "meilleure semaine", en: "best week", es: "mejor semana")[language],
                    tint: Theme.secondaryText
                )
            }
        }

        // Une phrase plutôt qu'un pourcentage : trois semaines de données ne
        // méritent pas d'être présentées comme une tendance, et le dire
        // vaut mieux que de laisser croire le contraire.
        Text(volumeSentence(weeks: weeks))
            .font(Theme.captionFont)
            .foregroundStyle(Theme.secondaryText)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func volumeSentence(weeks: [VolumeWeek]) -> String {
        let worked = weeks.filter { !$0.isEmpty }.count
        guard worked > 0 else {
            return LocalizedText(fr: "Rien d'enregistré sur les trois derniers mois. La première barre apparaîtra à ta première séance terminée.", en: "Nothing logged over the last three months. The first bar will appear after your first completed session.", es: "Nada registrado en los últimos tres meses. La primera barra aparecerá tras tu primera sesión terminada.")[language]
        }
        guard worked >= 3, let standing = TrainingVolume.standing(of: weeks, measure: measure) else {
            return LocalizedText(fr: "\(worked) semaine\(worked > 1 ? "s" : "") travaillée\(worked > 1 ? "s" : "") sur \(Self.window). C'est encore trop peu pour une tendance — les barres se comparent à partir de trois semaines.", en: "\(worked) week\(worked > 1 ? "s" : "") worked out of \(Self.window). Still too few for a trend — bars compare from three weeks on.", es: "\(worked) semana\(worked > 1 ? "s" : "") trabajada\(worked > 1 ? "s" : "") de \(Self.window). Aún es poco para una tendencia: las barras se comparan a partir de tres semanas.")[language]
        }
        let gap = standing.difference
        if abs(gap) < 0.5 {
            return LocalizedText(fr: "Cette semaine est dans ta moyenne. C'est exactement ce qu'on cherche : la progression vient de la régularité, pas d'une séance héroïque.", en: "This week is within your average. That is exactly what we want: progress comes from consistency, not from a heroic session.", es: "Esta semana está en tu media. Es exactamente lo que buscamos: el progreso viene de la regularidad, no de una sesión heroica.")[language]
        }
        let word = Self.format(abs(gap), measure: measure, unit: unit)
        return gap > 0
            ? LocalizedText(fr: "Cette semaine dépasse ta moyenne de \(word). Une bonne semaine ne se paie que si les suivantes tiennent — ne fais pas de ce pic la nouvelle norme.", en: "This week is \(word) above your average. A good week only pays off if the next ones hold — don't make this peak the new norm.", es: "Esta semana supera tu media en \(word). Una buena semana solo cuenta si las siguientes aguantan: no conviertas este pico en la nueva norma.")[language]
            : LocalizedText(fr: "Cette semaine est en retrait de \(word) sur ta moyenne. Rien de grave si la semaine n'est pas finie ; c'est en la répétant que ça se voit dans trois mois.", en: "This week is \(word) below your average. No big deal if the week isn't over; it is by repeating it that it shows in three months.", es: "Esta semana está \(word) por debajo de tu media. Nada grave si la semana no ha terminado; es al repetirla cuando se nota en tres meses.")[language]
    }

    /// Le chiffre d'une mesure, écrit comme on le dit.
    private static func format(_ value: Double, measure: VolumeMeasure, unit: UnitSystem) -> String {
        switch measure {
        case .sets: "\(Int(value.rounded()))"
        case .sessions: "\(Int(value.rounded()))"
        case .tonnage: tonnage(value, unit: unit)
        }
    }

    /// La même chose en plus court, pour un axe où la place manque.
    private static func axisLabel(_ value: Double, measure: VolumeMeasure, unit: UnitSystem) -> String {
        switch measure {
        case .sets, .sessions: "\(Int(value.rounded()))"
        case .tonnage:
            tonnage(value, unit: unit)
        }
    }

    // MARK: Body weight

    private var bodyWeightCard: some View {
        let logs = history.bodyLogs.sorted { $0.date < $1.date }
        let trend = StrengthMath.trendPerDay(logs.map { (date: $0.date, value: $0.weightKg) })

        return Card(
            title: LocalizedText(fr: "Poids de corps", en: "Body weight", es: "Peso corporal")[language],
            subtitle: logs.count >= 2
                ? LocalizedText(fr: "\(logs.count) pesée\(logs.count > 1 ? "s" : "") · la tendance se lit sur quatre semaines, jamais sur deux points.", en: "\(logs.count) weigh-in\(logs.count > 1 ? "s" : "") · the trend is read over four weeks, never from two points.", es: "\(logs.count) pesaje\(logs.count > 1 ? "s" : "") · la tendencia se lee en cuatro semanas, nunca en dos puntos.")[language]
                : LocalizedText(fr: "Deux pesées suffisent pour tracer une courbe ; quatre semaines pour en tirer une conclusion.", en: "Two weigh-ins are enough to draw a curve; four weeks to draw a conclusion.", es: "Dos pesajes bastan para trazar una curva; cuatro semanas para sacar una conclusión.")[language]
        ) {
            if logs.count >= 2 {
                Chart(logs) { log in
                    LineMark(
                        x: .value("Date", log.date),
                        y: .value("Poids", log.weightKg)
                    )
                    .foregroundStyle(Theme.accent)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Date", log.date),
                        y: .value("Poids", log.weightKg)
                    )
                    .foregroundStyle(Theme.accent)
                    .symbolSize(28)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                        AxisGridLine().foregroundStyle(Theme.separator)
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine().foregroundStyle(Theme.separator)
                        AxisValueLabel()
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .frame(height: 170)

                if let trend {
                    let weekly = trend * 7
                    HStack {
                        Text(LocalizedText(fr: "Tendance", en: "Trend", es: "Tendencia")[language])
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                        Spacer()
                        Text("\(Format.signed(weekly, decimals: 2)) kg / semaine")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(trendColor(weekly))
                    }
                }
            } else {
                Text(LocalizedText(fr: "Pèse-toi le matin, à jeun. Le coach ajuste tes calories à partir de la tendance sur quatre semaines, jamais d'une seule mesure.", en: "Weigh yourself in the morning, fasted. The coach adjusts your calories from the four-week trend, never from a single reading.", es: "Pésate por la mañana, en ayunas. El entrenador ajusta tus calorías según la tendencia de cuatro semanas, nunca por una sola medida.")[language])
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func trendColor(_ weekly: Double) -> Color {
        guard let direction = store.profile?.weightDirection else { return Theme.primaryText }
        switch direction {
        case .up: return weekly > 0 ? Theme.accent : Theme.warning
        case .down: return weekly < 0 ? Theme.accent : Theme.warning
        case .hold: return abs(weekly) < 0.2 ? Theme.accent : Theme.warning
        }
    }

    // MARK: Strength

    private var trackedLiftIDs: [String] {
        guard let plan = store.plan else { return [] }
        var ids: [String] = []
        for week in plan.weeks.prefix(1) {
            for session in week.sessions {
                for prescription in session.exercises.prefix(2) {
                    guard let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID),
                          exercise.isCompound,
                          !ids.contains(exercise.id)
                    else { continue }
                    ids.append(exercise.id)
                }
            }
        }
        return ids
    }

    private var strengthCard: some View {
        Card(title: LocalizedText(fr: "Force estimée", en: "Estimated strength", es: "Fuerza estimada")[language], subtitle: LocalizedText(fr: "1RM déduit de chaque série, RPE compris", en: "1RM inferred from each set, RPE included", es: "1RM deducido de cada serie, RPE incluido")[language]) {
            let lifts = trackedLiftIDs.compactMap { id -> LiftHistory? in
                guard let exercise = ExerciseCatalog.exercise(id: id) else { return nil }
                let sets = history.sets(for: id)
                return sets.isEmpty ? nil : LiftHistory(exercise: exercise, sets: sets)
            }

            if lifts.isEmpty {
                Text(LocalizedText(fr: "Aucune série enregistrée pour l'instant. Les courbes apparaîtront après ta première séance.", en: "No set logged yet. The curves will appear after your first session.", es: "Aún no hay series registradas. Las curvas aparecerán tras tu primera sesión.")[language])
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 18) {
                    ForEach(lifts) { lift in
                        liftRow(exercise: lift.exercise, sets: lift.sets)
                    }
                }
            }
        }
    }

    private func liftRow(exercise: Exercise, sets: [SetLog]) -> some View {
        let best = sets.map(\.estimatedOneRepMax).max() ?? 0
        let daily = dailyBest(sets)
        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(exercise.name[language])
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                // Une courbe de progression sans savoir ce qu'on mesure ne
                // dit rien : la fiche est à un appui, ici comme ailleurs.
                ExerciseInfoButton(exercise: exercise)
                Spacer()
                Text(Format.weight(best, unit: unit, decimals: 0))
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.accent)
            }
            if daily.count >= 2 {
                Chart(daily) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("1RM estimé", point.value)
                    )
                    .foregroundStyle(Theme.accent)
                    // Les points, parce qu'avec trois séances une ligne nue
                    // ne montre pas où sont les mesures — et on ne sait plus
                    // si l'on regarde trois jours ou trois mois.
                    PointMark(
                        x: .value("Date", point.date),
                        y: .value("1RM estimé", point.value)
                    )
                    .foregroundStyle(Theme.accent)
                    .symbolSize(24)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                        AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                        AxisGridLine().foregroundStyle(Theme.separator)
                        AxisValueLabel()
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
                .frame(height: 96)

                // Ce que la courbe vaut en un mot : sans ça, deux points
                // reliés par un trait laissent croire à une progression
                // qu'un seul bon jour peut avoir fabriquée.
                if let first = daily.first?.value, let last = daily.last?.value, first > 0 {
                    let gap = last - first
                    Text(
                        abs(gap) < 0.5
                            ? "Stable sur \(daily.count) journées enregistrées."
                            : "\(Format.signed(gap, decimals: 1)) kg depuis la première mesure, sur \(daily.count) journées."
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(gap >= 0 ? Theme.accent : Theme.secondaryText)
                }
            } else {
                Text(LocalizedText(fr: "Une seule journée enregistrée : la courbe démarre à la deuxième.", en: "Only one day logged: the curve starts on the second.", es: "Solo un día registrado: la curva empieza en el segundo.")[language])
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    /// One point per training day: the best estimated max of that day.
    private func dailyBest(_ sets: [SetLog]) -> [TrendPoint] {
        let calendar = Calendar.current
        var byDay: [Date: Double] = [:]
        for set in sets {
            let day = calendar.startOfDay(for: set.date)
            byDay[day] = max(byDay[day] ?? 0, set.estimatedOneRepMax)
        }
        return byDay.map { TrendPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
    }

    // MARK: Weekly review

    @ViewBuilder
    private var weeklyReviewCard: some View {
        if let week = store.currentWeekIndex(), week > 1, let review = store.review(weekIndex: week - 1) {
            Card(title: LocalizedText(fr: "Bilan de la semaine \(week - 1)", en: "Week \(week - 1) review", es: "Balance de la semana \(week - 1)")[language]) {
                HStack(spacing: 12) {
                    StatTile(value: "\(Int(review.adherence * 100)) %", label: LocalizedText(fr: "séances faites", en: "sessions done", es: "sesiones hechas")[language])
                    StatTile(value: "\(review.setsCompleted)/\(review.setsPlanned)", label: LocalizedText(fr: "séries", en: "sets", es: "series")[language])
                    if review.calorieAdjustment != 0 {
                        StatTile(
                            value: Format.signed(Double(review.calorieAdjustment), decimals: 0),
                            label: LocalizedText(fr: "kcal conseillées", en: "kcal advised", es: "kcal aconsejadas")[language],
                            tint: Theme.warning
                        )
                    }
                }
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(review.insights) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
    }
}
