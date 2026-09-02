import SwiftUI
import MonCoachKit

/// One bar of the weekly-volume chart. A named type rather than a tuple:
/// `ForEach` needs `Identifiable`, and Swift has no key paths into tuples.
struct VolumeEntry: Identifiable, Equatable {
    var muscle: MuscleGroup
    var sets: Int
    var id: MuscleGroup { muscle }
}

/// The whole block, week by week, so the athlete can see where this is going.
struct PlanView: View {
    @Environment(\.language) private var language
    @State private var showsGymCoach = false
    @Environment(CoachStore.self) private var store

    @State private var expandedWeek: Int?

    private var unit: UnitSystem { store.profile?.unit ?? .metric }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let plan = store.plan {
                        overviewCard(plan).appears(0)
                        volumeCard(plan).appears(1)
                        // Un bloc fait huit à douze semaines : le décalage
                        // se ferait sentir jusqu'à la fin de la liste si le
                        // moteur ne plafonnait pas le délai. Il le plafonne,
                        // et les semaines sous le pli arrivent ensemble.
                        ForEach(Array(plan.weeks.enumerated()), id: \.element.id) { index, week in
                            weekCard(week, plan: plan).appears(index + 2)
                        }
                    } else {
                        Card(title: LocalizedText(fr: "Aucun bloc en cours", en: "No block in progress", es: "Sin bloque en curso")[language]) {
                            Text(LocalizedText(fr: "Termine l'inscription pour obtenir ton programme.", en: "Finish signing up to get your programme.", es: "Termina el registro para obtener tu programa.")[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .appears(0)
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .sheet(isPresented: $showsGymCoach) {
                // Ouvert hors séance, le coach de salle sert de guide : pas
                // d'exercice en cours, donc pas de remplacement à proposer,
                // mais tout ce qu'on aurait aimé savoir avant d'y entrer.
                GymCoachView()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsGymCoach = true
                    } label: {
                        Image(systemName: "building.2")
                    }
                    .tint(Theme.accent)
                }
            }
            .navigationTitle(UI.plan[language])
            .sectionGuide(.plan)
        }
        .tint(Theme.accent)
    }

    private func overviewCard(_ plan: Mesocycle) -> some View {
        Card(title: plan.split.label[language], subtitle: plan.goal.label[language]) {
            HStack(spacing: 12) {
                StatTile(value: "\(plan.weekCount)", label: LocalizedText(fr: "semaines", en: "weeks", es: "semanas")[language])
                StatTile(value: "\(plan.weeks.first?.sessions.count ?? 0)", label: LocalizedText(fr: "séances / semaine", en: "sessions / week", es: "sesiones / semana")[language])
                StatTile(
                    value: "\(store.currentWeekIndex() ?? plan.weekCount)",
                    label: LocalizedText(fr: "semaine en cours", en: "current week", es: "semana en curso")[language]
                )
            }
            Text(plan.split.rationale[language])
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func volumeCard(_ plan: Mesocycle) -> some View {
        let entries = MuscleGroup.allCases
            .compactMap { muscle -> VolumeEntry? in
                let sets = plan.weeklyVolumeTarget[muscle] ?? 0
                return sets > 0 ? VolumeEntry(muscle: muscle, sets: sets) : nil
            }
            .sorted { $0.sets > $1.sets }
        let maximum = entries.map(\.sets).max() ?? 1

        return Card(title: LocalizedText(fr: "Volume hebdomadaire visé", en: "Weekly volume target", es: "Volumen semanal objetivo")[language], subtitle: LocalizedText(fr: "Séries dures par groupe musculaire", en: "Hard sets per muscle group", es: "Series duras por grupo muscular")[language]) {
            VStack(spacing: 8) {
                ForEach(entries) { entry in
                    HStack(spacing: 10) {
                        Text(entry.muscle.label[language])
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 130, alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        ProgressBar(value: Double(entry.sets) / Double(maximum))
                        Text("\(entry.sets)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.primaryText)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
    }

    private func weekCard(_ week: PlannedWeek, plan: Mesocycle) -> some View {
        let isCurrent = store.currentWeekIndex() == week.index
        return Card(
            title: week.isDeload ? LocalizedText(fr: "Semaine \(week.index) · décharge", en: "Week \(week.index) · deload", es: "Semana \(week.index) · descarga")[language] : LocalizedText(fr: "Semaine \(week.index)", en: "Week \(week.index)", es: "Semana \(week.index)")[language],
            subtitle: LocalizedText(fr: "\(week.sessions.count) séances · \(week.totalSets) séries", en: "\(week.sessions.count) sessions · \(week.totalSets) sets", es: "\(week.sessions.count) sesiones · \(week.totalSets) series")[language]
        ) {
            if isCurrent {
                Pill(text: LocalizedText(fr: "En cours", en: "In progress", es: "En curso")[language])
            }
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedWeek = expandedWeek == week.index ? nil : week.index
                }
            } label: {
                HStack {
                    Text(expandedWeek == week.index ? LocalizedText(fr: "Masquer le détail", en: "Hide details", es: "Ocultar el detalle")[language] : LocalizedText(fr: "Voir le détail", en: "Show details", es: "Ver el detalle")[language])
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                    Image(systemName: expandedWeek == week.index ? "chevron.up" : "chevron.down")
                }
                .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)

            if expandedWeek == week.index {
                VStack(spacing: 16) {
                    ForEach(week.sessions) { session in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(session.title[language])
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(Theme.primaryText)
                            SessionSummary(
                                session: session, unit: unit, showsLoads: false,
                                owned: store.profile?.equipment
                            )
                        }
                        .padding(12)
                        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
    }
}
