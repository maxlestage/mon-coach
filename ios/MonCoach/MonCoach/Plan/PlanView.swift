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
                        Card(title: "Aucun bloc en cours") {
                            Text("Termine l'inscription pour obtenir ton programme.")
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
            .navigationTitle("Mon plan")
            .sectionGuide(.plan)
        }
        .tint(Theme.accent)
    }

    private func overviewCard(_ plan: Mesocycle) -> some View {
        Card(title: plan.split.label[language], subtitle: plan.goal.label[language]) {
            HStack(spacing: 12) {
                StatTile(value: "\(plan.weekCount)", label: "semaines")
                StatTile(value: "\(plan.weeks.first?.sessions.count ?? 0)", label: "séances / semaine")
                StatTile(
                    value: "\(store.currentWeekIndex() ?? plan.weekCount)",
                    label: "semaine en cours"
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

        return Card(title: "Volume hebdomadaire visé", subtitle: "Séries dures par groupe musculaire") {
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
            title: week.isDeload ? "Semaine \(week.index) · décharge" : "Semaine \(week.index)",
            subtitle: "\(week.sessions.count) séances · \(week.totalSets) séries"
        ) {
            if isCurrent {
                Pill(text: "En cours")
            }
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    expandedWeek = expandedWeek == week.index ? nil : week.index
                }
            } label: {
                HStack {
                    Text(expandedWeek == week.index ? "Masquer le détail" : "Voir le détail")
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
