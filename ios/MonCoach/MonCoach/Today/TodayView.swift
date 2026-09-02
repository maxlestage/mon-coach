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
                        // Les cartes arrivent dans l'ordre où on les lit. Le
                        // numéro est écrit à la main parce que la pile n'est
                        // pas une liste : les cartes ne sont pas du même
                        // type, certaines n'existent pas tous les jours, et
                        // c'est l'ordre de lecture qui compte, pas l'ordre
                        // d'apparition dans le code.
                        if let step = beginnerStep {
                            FirstSessionsCard(step: step).appears(0)
                        }
                        readinessCard(briefing).appears(1)
                        stateCard(briefing).appears(2)
                        if let run = briefing.plannedRun {
                            plannedRunCard(run, done: briefing.recordedRun).appears(3)
                        }
                        nutritionCard(briefing.nutrition).appears(4)
                        trialBanner.appears(5)
                        insightsCard.appears(6)
                    } else {
                        Card(title: LocalizedText(fr: "Aucun programme", en: "No programme", es: "Sin programa")[language]) {
                            Text(LocalizedText(fr: "Le coach n'a pas encore de plan pour toi.", en: "The coach has no plan for you yet.", es: "El entrenador aún no tiene un plan para ti.")[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .appears(0)
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(greeting)
            .sectionGuide(.today)
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
        case 5..<12: LocalizedText(fr: "Bonjour", en: "Good morning", es: "Buenos días")[language]
        case 12..<18: LocalizedText(fr: "Salut", en: "Hi", es: "Hola")[language]
        default: LocalizedText(fr: "Bonsoir", en: "Good evening", es: "Buenas tardes")[language]
        }
        return name.isEmpty ? salutation : "\(salutation), \(name)"
    }

    // MARK: - Cards

    private func readinessCard(_ briefing: TodayBriefing) -> some View {
        Card(title: briefing.readiness.headline[language], subtitle: LocalizedText(fr: "Forme du jour", en: "Today's readiness", es: "Forma del día")[language]) {
            HStack(alignment: .center, spacing: 16) {
                ScoreRing(
                    score: briefing.readiness.score,
                    tint: scoreColor(briefing.readiness.score)
                )
                .frame(width: 64, height: 64)

                Text(briefing.readiness.advice[language])
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            GhostButton(
                title: hasCheckedInToday ? LocalizedText(fr: "Modifier mon check-in", en: "Edit my check-in", es: "Modificar mi check-in")[language] : LocalizedText(fr: "Faire le check-in du jour", en: "Do today's check-in", es: "Hacer el check-in de hoy")[language],
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
                    ? LocalizedText(fr: "Semaine \(briefing.weekIndex ?? 0) · décharge", en: "Week \(briefing.weekIndex ?? 0) · deload", es: "Semana \(briefing.weekIndex ?? 0) · descarga")[language]
                    : LocalizedText(fr: "Semaine \(briefing.weekIndex ?? 0)", en: "Week \(briefing.weekIndex ?? 0)", es: "Semana \(briefing.weekIndex ?? 0)")[language]
            ) {
                if !session.focus.isEmpty {
                    FlowLayout(spacing: 6) {
                        ForEach(session.focus, id: \.self) { muscle in
                            Pill(text: muscle.label[language])
                        }
                    }
                }
                SessionSummary(session: session, unit: unit, owned: store.profile?.equipment)

                PrimaryButton(title: LocalizedText(fr: "Démarrer la séance", en: "Start the session", es: "Empezar la sesión")[language], systemImage: "play.fill") {
                    store.startSession(session)
                }
                GhostButton(title: LocalizedText(fr: "Je ne peux pas aujourd'hui", en: "I can't today", es: "Hoy no puedo")[language], systemImage: "calendar.badge.minus") {
                    store.skipTodaySession(at: now)
                }
            }

        case .rest:
            // Deux jours très différents portent le même état. Le dernier de
            // la semaine est le vrai repos, et il le dit. Un jour creux au
            // milieu, lui, ne mérite pas « rien de prévu » : le moteur y pose
            // des mouvements à faire, et l'écran les propose.
            Card(
                title: briefing.extras.isEmpty ? LocalizedText(fr: "Repos", en: "Rest", es: "Descanso")[language] : LocalizedText(fr: "Rien d'imposé aujourd'hui", en: "Nothing imposed today", es: "Nada impuesto hoy")[language],
                subtitle: LocalizedText(fr: "Semaine \(briefing.weekIndex ?? 0)", en: "Week \(briefing.weekIndex ?? 0)", es: "Semana \(briefing.weekIndex ?? 0)")[language]
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
                    Text(LocalizedText(fr: "Ta prochaine séance : \(next.title[.french])", en: "Your next session: \(next.title[.english])", es: "Tu próxima sesión: \(next.title[.spanish])")[language])
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                    SessionSummary(
                        session: next, unit: unit, showsLoads: false,
                        owned: store.profile?.equipment
                    )
                }
            }

        case .blockFinished:
            Card(title: LocalizedText(fr: "Bloc terminé", en: "Block complete", es: "Bloque terminado")[language], subtitle: LocalizedText(fr: "Bien joué", en: "Well done", es: "Bien hecho")[language]) {
                Text(LocalizedText(fr: "Tu es arrivé au bout de ce bloc. Le coach peut en construire un nouveau à partir de ce que tes séances ont montré : volume, charges et calories seront ajustés.", en: "You have reached the end of this block. The coach can build a new one from what your sessions showed: volume, loads and calories will be adjusted.", es: "Has llegado al final de este bloque. El entrenador puede construir uno nuevo a partir de lo que mostraron tus sesiones: volumen, cargas y calorías se ajustarán.")[language])
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
        Card(title: LocalizedText(fr: "Aujourd'hui, côté assiette", en: "Today, on the plate", es: "Hoy, en el plato")[language]) {
            HStack(spacing: 12) {
                StatTile(value: "\(target.calories)", label: "kcal")
                StatTile(value: "\(target.proteinG) g", label: LocalizedText(fr: "protéines", en: "protein", es: "proteína")[language])
                StatTile(value: "\(target.carbsG) g", label: LocalizedText(fr: "glucides", en: "carbs", es: "hidratos")[language])
                StatTile(value: "\(target.fatG) g", label: LocalizedText(fr: "lipides", en: "fat", es: "grasas")[language])
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
            Card(title: LocalizedText(fr: "Ce que le coach a remarqué", en: "What the coach noticed", es: "Lo que notó el entrenador")[language], subtitle: LocalizedText(fr: "Bilan de la semaine dernière", en: "Last week's review", es: "Balance de la semana pasada")[language]) {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(insights.prefix(3)) { insight in
                        InsightRow(insight: insight)
                    }
                }
            }
        }
    }
}
