import SwiftUI
import MonCoachKit

/// Edits an existing profile.
///
/// Any change here rebuilds the block from today, which is deliberate: a plan
/// built for four sessions a week is the wrong plan the moment the athlete
/// drops to three.
struct ProfileEditorView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var draft: ProfileDraft
    private let onSave: (UserProfile) -> Void

    init(profile: UserProfile, onSave: @escaping (UserProfile) -> Void) {
        _draft = State(initialValue: ProfileDraft(profile: profile))
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    warning
                    bodySection
                    goalSection
                    availabilitySection
                    equipmentSection
                    limitationsSection
                    lifestyleSection
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Modifier mon profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        onSave(draft.makeProfile())
                        dismiss()
                    }
                    .disabled(!draft.isValid)
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(Theme.accent)
    }

    private var warning: some View {
        Card {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundStyle(Theme.warning)
                Text("Enregistrer reconstruit ton bloc à partir d'aujourd'hui. Ton historique d'entraînement est conservé, et la progression sur les mouvements qui restent au programme repart d'où elle en était.")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var bodySection: some View {
        Card(title: "Corps") {
            SliderRow(
                value: $draft.weightKg,
                range: 35...200,
                step: 0.5,
                display: "Poids : \(Format.weight(draft.weightKg, unit: draft.unit))"
            )
            SliderRow(
                value: $draft.heightCm,
                range: 130...220,
                step: 1,
                display: "Taille : \(Format.height(draft.heightCm, unit: draft.unit))"
            )
            Toggle("Je connais mon taux de masse grasse", isOn: $draft.knowsBodyFat)
                .tint(Theme.accent)
                .foregroundStyle(Theme.primaryText)
            if draft.knowsBodyFat {
                SliderRow(
                    value: $draft.bodyFatPercent,
                    range: 4...50,
                    step: 0.5,
                    display: "\(Format.number(draft.bodyFatPercent, decimals: 1)) %"
                )
            }
            Picker("Unités", selection: $draft.unit) {
                ForEach(UnitSystem.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)
        }
    }

    private var goalSection: some View {
        Card(title: "Objectif") {
            Picker("", selection: $draft.goal) {
                ForEach(PrimaryGoal.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.inline)
            .labelsHidden()

            Toggle("Poids cible", isOn: $draft.hasTargetWeight)
                .tint(Theme.accent)
                .foregroundStyle(Theme.primaryText)
            if draft.hasTargetWeight {
                SliderRow(
                    value: $draft.targetWeightKg,
                    range: 35...200,
                    step: 0.5,
                    display: Format.weight(draft.targetWeightKg, unit: draft.unit)
                )
            }
        }
    }

    private var availabilitySection: some View {
        Card(title: "Disponibilité") {
            Picker("Séances par semaine", selection: $draft.daysPerWeek) {
                ForEach(2...6, id: \.self) { Text("\($0)").tag($0) }
            }
            .pickerStyle(.segmented)
            SliderRow(
                value: Binding(
                    get: { Double(draft.sessionMinutes) },
                    set: { draft.sessionMinutes = Int($0) }
                ),
                range: 25...120,
                step: 5,
                display: Format.duration(minutes: draft.sessionMinutes)
            )
        }
    }

    private var equipmentSection: some View {
        Card(title: "Matériel") {
            FlowSelection(
                items: Equipment.allCases,
                label: { $0.label },
                isSelected: { draft.equipment.contains($0) },
                toggle: { item in
                    if draft.equipment.contains(item) {
                        draft.equipment.remove(item)
                    } else {
                        draft.equipment.insert(item)
                    }
                }
            )
            Picker("Incrément", selection: $draft.loadIncrement) {
                ForEach(LoadIncrement.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Theme.accent)
        }
    }

    private var limitationsSection: some View {
        Card(title: "Zones sensibles", subtitle: "Tout mouvement qui sollicite directement une zone cochée est retiré du programme.") {
            FlowSelection(
                items: Limitation.allCases,
                label: { $0.label },
                isSelected: { draft.limitations.contains($0) },
                toggle: { item in
                    if draft.limitations.contains(item) {
                        draft.limitations.remove(item)
                    } else {
                        draft.limitations.insert(item)
                    }
                }
            )
        }
    }

    private var lifestyleSection: some View {
        Card(title: "Quotidien") {
            Picker("Activité", selection: $draft.activityLevel) {
                ForEach(ActivityLevel.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Theme.accent)
            SliderRow(
                value: $draft.sleepHours,
                range: 4...10,
                step: 0.5,
                display: "Sommeil : \(Format.number(draft.sleepHours, decimals: 1)) h"
            )
            SliderRow(
                value: Binding(
                    get: { Double(draft.stressLevel) },
                    set: { draft.stressLevel = Int($0) }
                ),
                range: 1...5,
                step: 1,
                display: "Stress : \(draft.stressLevel) / 5"
            )
            Picker("Alimentation", selection: $draft.dietPreference) {
                ForEach(DietPreference.allCases, id: \.self) { Text($0.label).tag($0) }
            }
            .pickerStyle(.menu)
            .tint(Theme.accent)
        }
    }
}
