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
    /// La fiche d'un mouvement proposé un jour creux.
    @State private var openedExtra: Exercise?
    @State private var showsPaywall = false

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
                        trialBanner
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
            .sheet(isPresented: $showsPaywall) { PaywallView() }
            .sheet(isPresented: $showingReadiness) {
                ReadinessSheet(date: now) { check in
                    store.recordReadiness(check)
                }
            }
            .sheet(isPresented: $showingRunTracker) {
                RunTrackerView(plannedRun: briefing?.plannedRun)
            }
            .sheet(item: $openedExtra) { exercise in
                GuidedTechniqueView(exercise: exercise, owned: store.profile?.equipment)
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
    private func plannedRunCard(_ run: PlannedRun, done: ActivityLog?) -> some View {
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
                            value: Format.speedOrPace(
                                sport: done.sport, meters: done.meters,
                                seconds: done.duration, unit: unit, language: language
                            ),
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
                SessionSummary(session: session, unit: unit, owned: store.profile?.equipment)

                PrimaryButton(title: "Démarrer la séance", systemImage: "play.fill") {
                    store.startSession(session)
                }
                GhostButton(title: "Je ne peux pas aujourd'hui", systemImage: "calendar.badge.minus") {
                    store.skipTodaySession(at: now)
                }
            }

        case .rest:
            // Deux jours très différents portent le même état. Le dernier de
            // la semaine est le vrai repos, et il le dit. Un jour creux au
            // milieu, lui, ne mérite pas « rien de prévu » : le moteur y pose
            // des mouvements à faire, et l'écran les propose.
            Card(
                title: briefing.extras.isEmpty ? "Repos" : "Rien d'imposé aujourd'hui",
                subtitle: "Semaine \(briefing.weekIndex ?? 0)"
            ) {
                CoachText(
                    briefing.extras.isEmpty ? DailyExtras.realRest : DailyExtras.invitation
                )

                if !briefing.extras.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(briefing.extras) { exercise in
                            Button {
                                openedExtra = exercise
                            } label: {
                                extraRow(exercise)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Ce qui attend, exercices compris — un jour de repos n'est
                // pas un écran vide. Sans les charges : elles se décident le
                // jour même, à partir du check-in de ce matin-là.
                if let next = briefing.nextSession {
                    Divider().overlay(Theme.separator)
                    Text("Ta prochaine séance : \(next.title[language])")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                    SessionSummary(
                        session: next, unit: unit, showsLoads: false,
                        owned: store.profile?.equipment
                    )
                }
            }

        case .blockFinished:
            Card(title: "Bloc terminé", subtitle: "Bien joué") {
                Text("Tu es arrivé au bout de ce bloc. Le coach peut en construire un nouveau à partir de ce que tes séances ont montré : volume, charges et calories seront ajustés.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                // Le bloc suivant est la seule chose que la fin de l'essai
                // retienne côté musculation — et elle n'arrive jamais au
                // milieu d'un bloc : celui qui est commencé va au bout.
                if store.isUnlocked(.nextBlocks, on: now) {
                    PrimaryButton(title: "Construire le bloc suivant", systemImage: "arrow.triangle.2.circlepath") {
                        store.startNextBlock(on: now)
                    }
                }
            }
            if !store.isUnlocked(.nextBlocks, on: now) {
                PlusLockedCard(feature: .nextBlocks)
            }
        }
    }

    /// Le compte à rebours de l'essai, tant qu'il court.
    ///
    /// Un rappel, pas une pression : il dit ce qui reste et disparaît de
    /// lui-même. Presser quelqu'un qui a encore neuf jours devant lui est la
    /// meilleure façon de le faire partir avant la fin.
    @ViewBuilder
    private var trialBanner: some View {
        if let banner = store.subscription.banner(on: now) {
            Button {
                showsPaywall = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.accent)
                    Text(banner[language])
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
                .padding(12)
                .background(Theme.accentMuted, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
        }
    }

    /// Un mouvement proposé un jour creux : ce qu'il travaille, et la fiche
    /// derrière. Pas de charge ni de série imposée — ce n'est pas une séance,
    /// et l'afficher comme une séance en ferait une dette de plus.
    private func extraRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 14))
                .foregroundStyle(Theme.accent)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name[language])
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                Text(
                    exercise.primaryMuscle.label[language]
                    + " · \(exercise.viableRepRange.lowerBound)–\(exercise.viableRepRange.upperBound)"
                )
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
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
                Text(first[language])
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
