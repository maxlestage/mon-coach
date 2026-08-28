import SwiftUI
import MonCoachKit

/// Le bloc de course : ce qui est prévu, et ce qui a été fait.
struct RunPlanView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var showsTracker = false

    private var unit: UnitSystem { store.profile?.unit ?? .metric }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let block = store.program?.runningBlock {
                        headerCard(block)
                        weeklyCard(block)
                        ForEach(block.notes, id: \.self) { note in
                            Card { CoachText(note, color: Theme.primaryText) }
                        }
                        historyCard
                    } else {
                        invitationCard
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(UI.running[language])
            .toolbar {
                if store.program?.runningBlock != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showsTracker = true
                        } label: {
                            Image(systemName: "figure.run")
                        }
                    }
                }
            }
            .sheet(isPresented: $showsTracker) {
                RunTrackerView(plannedRun: store.briefing()?.plannedRun)
            }
        }
    }

    private func headerCard(_ block: RunningBlock) -> some View {
        Card(title: block.goal.label[language]) {
            HStack(spacing: 12) {
                StatTile(
                    value: Format.pace(secondsPerKm: block.thresholdPaceSecondsPerKm, unit: unit),
                    label: LocalizedText(fr: "Allure de seuil", en: "Threshold pace", es: "Ritmo de umbral")[language]
                )
                StatTile(
                    value: Format.distance(
                        meters: store.history.weeklyRunMeters(endingOn: Date()),
                        unit: unit,
                        language: language
                    ),
                    label: LocalizedText(fr: "7 derniers jours", en: "Last 7 days", es: "Últimos 7 días")[language]
                )
                if let distance = block.goal.raceDistanceMeters,
                   let predicted = RunMath.predictedRaceTime(
                       thresholdPaceSecondsPerKm: block.thresholdPaceSecondsPerKm,
                       distanceMeters: distance
                   ) {
                    StatTile(
                        value: Format.stopwatch(seconds: predicted),
                        label: LocalizedText(fr: "Projection", en: "Projection", es: "Proyección")[language],
                        tint: Theme.warning
                    )
                }
            }
        }
    }

    private func weeklyCard(_ block: RunningBlock) -> some View {
        let index = min(max(1, store.currentWeekIndex() ?? 1), block.weeks.count)
        let week = block.weeks[index - 1]
        return Card(
            title: LocalizedText(
                fr: "Semaine \(week.index) sur \(block.weeks.count)",
                en: "Week \(week.index) of \(block.weeks.count)",
                es: "Semana \(week.index) de \(block.weeks.count)"
            )[language],
            subtitle: Format.distance(meters: week.targetMeters, unit: unit, language: language)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(week.focus)
                ForEach(week.runs) { run in
                    RunRow(run: run, unit: unit)
                }
            }
        }
    }

    private var historyCard: some View {
        let recent = store.history.runs.suffix(6).reversed()
        return Group {
            if !recent.isEmpty {
                Card(title: LocalizedText(fr: "Dernières sorties", en: "Recent runs", es: "Últimos rodajes")[language]) {
                    VStack(spacing: 10) {
                        ForEach(Array(recent)) { run in
                            HStack(spacing: 12) {
                                RouteShapeView(points: run.points, lineWidth: 2)
                                    .frame(width: 52, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(run.type.label[language])
                                        .font(Theme.captionFont)
                                        .foregroundStyle(Theme.primaryText)
                                    Text(Format.distance(meters: run.meters, unit: unit, language: language)
                                        + " · " + Format.pace(secondsPerKm: run.paceSecondsPerKm, unit: unit))
                                        .font(.system(size: 12))
                                        .foregroundStyle(Theme.secondaryText)
                                }
                                Spacer()
                                Text(Format.stopwatch(seconds: run.duration))
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        }
                    }
                }
            }
        }
    }

    private var invitationCard: some View {
        Card(title: LocalizedText(fr: "Tu cours ?", en: "Do you run?", es: "¿Corres?")[language]) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(
                    LocalizedText(
                        fr: "Active la course dans ton profil et le coach construira un bloc qui tient compte de tes séances de musculation : les sorties dures ne tomberont pas les jours de jambes.",
                        en: "Turn running on in your profile and the coach will build a block that accounts for your lifting: hard runs will not land on leg days.",
                        es: "Activa la carrera en tu perfil y el entrenador construirá un bloque que tenga en cuenta tu fuerza: las sesiones duras no caerán en días de pierna."
                    ),
                    color: Theme.primaryText
                )
            }
        }
    }
}

/// Une sortie prévue, dans la liste de la semaine.
struct RunRow: View {
    var run: PlannedRun
    var unit: UnitSystem

    @Environment(\.language) private var language

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Pill(text: run.type.label[language], tint: tint)
                Spacer()
                if let meters = run.targetMeters, meters > 0 {
                    Text(Format.distance(meters: meters, unit: unit, language: language))
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.primaryText)
                }
            }
            CoachText(run.note, font: .system(size: 13))
            if let range = run.paceRangeSecondsPerKm {
                Text(
                    Format.pace(secondsPerKm: range.lowerBound, unit: unit)
                        + " – " + Format.pace(secondsPerKm: range.upperBound, unit: unit)
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Theme.accent)
            }
        }
        .padding(.vertical, 6)
    }

    private var tint: Color {
        switch run.type {
        case .intervals, .race: Theme.danger
        case .tempo: Theme.warning
        case .long: Theme.accent
        case .easy, .recovery: Theme.secondaryText
        }
    }
}
