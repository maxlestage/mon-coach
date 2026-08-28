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

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    summaryCard
                    bodyWeightCard
                    strengthCard
                    weeklyReviewCard
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Progression")
        }
        .tint(Theme.accent)
    }

    // MARK: Summary

    private var summaryCard: some View {
        let completed = history.sessions.filter { !$0.skipped }
        let tonnage = completed.reduce(0.0) { $0 + $1.totalVolumeKg }
        return Card(title: "Depuis le début") {
            HStack(spacing: 12) {
                StatTile(value: "\(completed.count)", label: "séances")
                StatTile(value: "\(completed.reduce(0) { $0 + $1.sets.count })", label: "séries")
                StatTile(value: "\(Int(tonnage / 1000)) t", label: "tonnage soulevé")
                StatTile(value: "\(currentStreak)", label: "semaines d'affilée")
            }
        }
    }

    /// Consecutive weeks, counting back from this one, with at least one session.
    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = Date()
        while streak < 200 {
            guard let weekStart = calendar.date(byAdding: .day, value: -7, to: cursor) else { break }
            let trained = history.sessions.contains {
                !$0.skipped && $0.date > weekStart && $0.date <= cursor
            }
            guard trained else { break }
            streak += 1
            cursor = weekStart
        }
        return streak
    }

    // MARK: Body weight

    private var bodyWeightCard: some View {
        let logs = history.bodyLogs.sorted { $0.date < $1.date }
        let trend = StrengthMath.trendPerDay(logs.map { (date: $0.date, value: $0.weightKg) })

        return Card(
            title: "Poids de corps",
            subtitle: logs.count >= 2 ? nil : "Au moins quatre pesées sont nécessaires pour lire une tendance."
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
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 170)

                if let trend {
                    let weekly = trend * 7
                    HStack {
                        Text("Tendance")
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                        Spacer()
                        Text("\(Format.signed(weekly, decimals: 2)) kg / semaine")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundStyle(trendColor(weekly))
                    }
                }
            } else {
                Text("Pèse-toi le matin, à jeun. Le coach ajuste tes calories à partir de la tendance sur quatre semaines, jamais d'une seule mesure.")
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
        Card(title: "Force estimée", subtitle: "1RM déduit de chaque série, RPE compris") {
            let lifts = trackedLiftIDs.compactMap { id -> LiftHistory? in
                guard let exercise = ExerciseCatalog.exercise(id: id) else { return nil }
                let sets = history.sets(for: id)
                return sets.isEmpty ? nil : LiftHistory(exercise: exercise, sets: sets)
            }

            if lifts.isEmpty {
                Text("Aucune série enregistrée pour l'instant. Les courbes apparaîtront après ta première séance.")
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
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .chartXAxis(.hidden)
                .frame(height: 70)
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
            Card(title: "Bilan de la semaine \(week - 1)") {
                HStack(spacing: 12) {
                    StatTile(value: "\(Int(review.adherence * 100)) %", label: "séances faites")
                    StatTile(value: "\(review.setsCompleted)/\(review.setsPlanned)", label: "séries")
                    if review.calorieAdjustment != 0 {
                        StatTile(
                            value: Format.signed(Double(review.calorieAdjustment), decimals: 0),
                            label: "kcal conseillées",
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
