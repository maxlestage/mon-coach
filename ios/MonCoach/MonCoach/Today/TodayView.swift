import SwiftUI
import MonCoachKit

/// The home screen: what to do today, and why.
struct TodayView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    @State private var showingReadiness = false
    @State private var showingWeighIn = false
    @State private var now = Date()
    @State private var showingRunTracker = false

    private var briefing: TodayBriefing? { store.briefing(on: now) }
    private var unit: UnitSystem { store.profile?.unit ?? .metric }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let briefing {
                        if let step = beginnerStep {
                            FirstSessionsCard(step: step)
                        }
                        readinessCard(briefing)
                        stateCard(briefing)
                        if let run = briefing.plannedRun {
                            plannedRunCard(run, done: briefing.recordedRun)
                        }
                        nutritionCard(briefing.nutrition)
                        insightsCard
                    } else {
                        Card(title: "Aucun programme") {
                            Text("Le coach n'a pas encore de plan pour toi.")
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(greeting)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingWeighIn = true
                    } label: {
                        Image(systemName: "scalemass")
                    }
                    .tint(Theme.accent)
                }
            }
            .sheet(isPresented: $showingReadiness) {
                ReadinessSheet(date: now) { check in
                    store.recordReadiness(check)
                }
            }
            .sheet(isPresented: $showingRunTracker) {
                RunTrackerView(plannedRun: briefing?.plannedRun)
            }
            .sheet(isPresented: $showingWeighIn) {
                WeighInSheet(unit: unit, currentKg: store.profile?.weightKg ?? 70) { log in
                    store.recordBodyLog(log)
                }
            }
        }
        .tint(Theme.accent)
    }

    /// L'étape du parcours débutant, quand il y en a une.
    private var beginnerStep: FirstSessionsStep? {
        guard let profile = store.profile, let plan = store.plan else { return nil }
        return FirstSessions.step(for: profile, startedOn: plan.startDate, on: now)
    }

    /// La sortie du jour, prête à être lancée.
    private func plannedRunCard(_ run: PlannedRun, done: RunLog?) -> some View {
        Card(
            title: run.type.label[language],
            subtitle: UI.running[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(run.note, color: Theme.primaryText)
                if let done {
                    HStack(spacing: 12) {
                        StatTile(
                            value: Format.distance(meters: done.meters, unit: unit, language: language),
                            label: UI.distance[language]
                        )
                        StatTile(
                            value: Format.stopwatch(seconds: done.duration),
                            label: UI.duration[language]
                        )
                        StatTile(
                            value: Format.pace(secondsPerKm: done.paceSecondsPerKm, unit: unit),
                            label: UI.pace[language]
                        )
                    }
                    Pill(
                        text: LocalizedText(fr: "Fait", en: "Done", es: "Hecho")[language],
                        tint: Theme.accent
                    )
                } else {
                    PrimaryButton(title: UI.start[language], systemImage: "figure.run") {
                        showingRunTracker = true
                    }
                }
            }
        }
    }

    private var greeting: String {
        let name = store.profile?.firstName ?? ""
        let hour = Calendar.current.component(.hour, from: now)
        let salutation = switch hour {
        case 5..<12: "Bonjour"
        case 12..<18: "Salut"
        default: "Bonsoir"
        }
        return name.isEmpty ? salutation : "\(salutation), \(name)"
    }

    // MARK: - Cards

    private func readinessCard(_ briefing: TodayBriefing) -> some View {
        Card(title: briefing.readiness.headline[language], subtitle: "Forme du jour") {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Theme.surfaceRaised, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: Double(briefing.readiness.score) / 100)
                        .stroke(scoreColor(briefing.readiness.score), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(briefing.readiness.score)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                }
                .frame(width: 64, height: 64)

                Text(briefing.readiness.advice[language])
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            GhostButton(
                title: hasCheckedInToday ? "Modifier mon check-in" : "Faire le check-in du jour",
                systemImage: "checkmark.circle"
            ) {
                showingReadiness = true
            }
        }
    }

    private var hasCheckedInToday: Bool {
        store.history.readiness(on: now) != nil
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 65...: Theme.accent
        case 45..<65: Theme.warning
        default: Theme.danger
        }
    }

    @ViewBuilder
    private func stateCard(_ briefing: TodayBriefing) -> some View {
        switch briefing.state {
        case let .training(session):
            Card(
                title: session.title[language],
                subtitle: briefing.isDeloadWeek
                    ? "Semaine \(briefing.weekIndex ?? 0) · décharge"
                    : "Semaine \(briefing.weekIndex ?? 0)"
            ) {
                if !session.focus.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(session.focus, id: \.self) { muscle in
                            Pill(text: muscle.label[language])
                        }
                    }
                }
                SessionSummary(session: session, unit: unit)

                PrimaryButton(title: "Démarrer la séance", systemImage: "play.fill") {
                    store.startSession(session)
                }
                GhostButton(title: "Je ne peux pas aujourd'hui", systemImage: "calendar.badge.minus") {
                    store.skipTodaySession(at: now)
                }
            }

        case .rest:
            Card(title: "Repos", subtitle: "Semaine \(briefing.weekIndex ?? 0)") {
                Text("Rien de prévu aujourd'hui. La récupération est la moitié du travail : mange tes protéines, dors, et reviens en forme.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

        case .blockFinished:
            Card(title: "Bloc terminé", subtitle: "Bien joué") {
                Text("Tu es arrivé au bout de ce bloc. Le coach peut en construire un nouveau à partir de ce que tes séances ont montré : volume, charges et calories seront ajustés.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                PrimaryButton(title: "Construire le bloc suivant", systemImage: "arrow.triangle.2.circlepath") {
                    store.startNextBlock(on: now)
                }
            }
        }
    }

    private func nutritionCard(_ target: NutritionTarget) -> some View {
        Card(title: "Aujourd'hui, côté assiette") {
            HStack(spacing: 12) {
                StatTile(value: "\(target.calories)", label: "kcal")
                StatTile(value: "\(target.proteinG) g", label: "protéines")
                StatTile(value: "\(target.carbsG) g", label: "glucides")
                StatTile(value: "\(target.fatG) g", label: "lipides")
            }
            if let first = target.rationale.first {
                Text(first)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var insightsCard: some View {
        let insights = store.latestInsights(on: now)
        if !insights.isEmpty {
            Card(title: "Ce que le coach a remarqué", subtitle: "Bilan de la semaine dernière") {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(insights.prefix(3)) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
    }
}
