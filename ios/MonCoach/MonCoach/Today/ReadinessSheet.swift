import SwiftUI
import MonCoachKit

/// The 20-second check-in that lets the coach scale the day's session.
struct ReadinessSheet: View {
    var date: Date
    var onSave: (ReadinessCheck) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var sleepQuality = 3
    @State private var soreness = 3
    @State private var motivation = 3
    @State private var stress = 3
    @State private var sleepHours = 7.5

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card {
                        Text("Réponds vite et honnêtement. Ces quatre curseurs décident si la séance du jour se fait telle quelle, allégée, ou raccourcie.")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    scale("Qualité du sommeil", value: $sleepQuality, low: "Horrible", high: "Excellente")
                    Card(title: "Heures dormies") {
                        SliderRow(
                            value: $sleepHours,
                            range: 3...11,
                            step: 0.5,
                            display: "\(Format.number(sleepHours, decimals: 1)) h"
                        )
                    }
                    scale("Courbatures", value: $soreness, low: "Aucune", high: "Très fortes")
                    scale("Motivation", value: $motivation, low: "Zéro", high: "À fond")
                    scale("Stress", value: $stress, low: "Serein", high: "Sous l'eau")

                    PrimaryButton(title: "Enregistrer", systemImage: "checkmark") {
                        onSave(
                            ReadinessCheck(
                                date: date,
                                sleepQuality: sleepQuality,
                                soreness: soreness,
                                motivation: motivation,
                                stress: stress,
                                sleepHours: sleepHours
                            )
                        )
                        dismiss()
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Check-in")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(Theme.accent)
    }

    private func scale(_ title: String, value: Binding<Int>, low: String, high: String) -> some View {
        Card(title: title) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { rating in
                    Button {
                        value.wrappedValue = rating
                    } label: {
                        Text("\(rating)")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                value.wrappedValue == rating ? Theme.accent : Theme.surfaceRaised,
                                in: RoundedRectangle(cornerRadius: 12)
                            )
                            .foregroundStyle(value.wrappedValue == rating ? Theme.background : Theme.primaryText)
                    }
                    .buttonStyle(.plain)
                }
            }
            HStack {
                Text(low)
                Spacer()
                Text(high)
            }
            .font(.system(size: 11))
            .foregroundStyle(Theme.secondaryText)
        }
    }
}

/// Records a weigh-in. Body weight drives calories and every load estimate,
/// so it is one tap from the home screen.
struct WeighInSheet: View {
    var unit: UnitSystem
    var currentKg: Double
    var onSave: (BodyLog) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var weightKg: Double
    @State private var tracksBodyFat = false
    @State private var bodyFat: Double = 18

    init(unit: UnitSystem, currentKg: Double, onSave: @escaping (BodyLog) -> Void) {
        self.unit = unit
        self.currentKg = currentKg
        self.onSave = onSave
        _weightKg = State(initialValue: currentKg)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card(title: "Poids du jour", subtitle: "Le matin, à jeun, après être passé aux toilettes : c'est la mesure la moins bruitée.") {
                        SliderRow(
                            value: $weightKg,
                            range: 35...200,
                            step: 0.1,
                            display: Format.weight(weightKg, unit: unit)
                        )
                    }
                    Card(title: "Masse grasse") {
                        Toggle("Je suis aussi mon taux de gras", isOn: $tracksBodyFat)
                            .tint(Theme.accent)
                            .foregroundStyle(Theme.primaryText)
                        if tracksBodyFat {
                            SliderRow(
                                value: $bodyFat,
                                range: 4...50,
                                step: 0.5,
                                display: "\(Format.number(bodyFat, decimals: 1)) %"
                            )
                        }
                    }
                    PrimaryButton(title: "Enregistrer", systemImage: "checkmark") {
                        onSave(
                            BodyLog(
                                date: Date(),
                                weightKg: weightKg,
                                bodyFatPercent: tracksBodyFat ? bodyFat : nil
                            )
                        )
                        dismiss()
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Pesée")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
        .tint(Theme.accent)
    }
}
