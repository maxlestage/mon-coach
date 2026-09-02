import SwiftUI
import MonCoachKit

/// The 20-second check-in that lets the coach scale the day's session.
struct ReadinessSheet: View {
    @Environment(\.language) private var language
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
                        Text(LocalizedText(fr: "Réponds vite et honnêtement. Ces quatre curseurs décident si la séance du jour se fait telle quelle, allégée, ou raccourcie.", en: "Answer quickly and honestly. These four sliders decide whether today's session runs as is, lighter, or shorter.", es: "Responde rápido y con sinceridad. Estos cuatro controles deciden si la sesión de hoy se hace tal cual, más ligera o más corta.")[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    scale(LocalizedText(fr: "Qualité du sommeil", en: "Sleep quality", es: "Calidad del sueño")[language], value: $sleepQuality, low: LocalizedText(fr: "Horrible", en: "Awful", es: "Horrible")[language], high: LocalizedText(fr: "Excellente", en: "Excellent", es: "Excelente")[language])
                    Card(title: LocalizedText(fr: "Heures dormies", en: "Hours slept", es: "Horas dormidas")[language]) {
                        SliderRow(
                            value: $sleepHours,
                            range: 3...11,
                            step: 0.5,
                            display: "\(Format.number(sleepHours, decimals: 1)) h"
                        )
                    }
                    scale(LocalizedText(fr: "Courbatures", en: "Soreness", es: "Agujetas")[language], value: $soreness, low: LocalizedText(fr: "Aucune", en: "None", es: "Ninguna")[language], high: LocalizedText(fr: "Très fortes", en: "Severe", es: "Muy fuertes")[language])
                    scale(LocalizedText(fr: "Motivation", en: "Motivation", es: "Motivación")[language], value: $motivation, low: LocalizedText(fr: "Zéro", en: "Zero", es: "Cero")[language], high: LocalizedText(fr: "À fond", en: "All in", es: "A tope")[language])
                    scale(LocalizedText(fr: "Stress", en: "Stress", es: "Estrés")[language], value: $stress, low: LocalizedText(fr: "Serein", en: "Calm", es: "Tranquilo")[language], high: LocalizedText(fr: "Sous l'eau", en: "Underwater", es: "Desbordado")[language])

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
                    Button(UI.cancel[language]) { dismiss() }
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
    @Environment(\.language) private var language
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
                    Card(title: LocalizedText(fr: "Poids du jour", en: "Today's weight", es: "Peso de hoy")[language], subtitle: LocalizedText(fr: "Le matin, à jeun, après être passé aux toilettes : c'est la mesure la moins bruitée.", en: "In the morning, fasted, after the bathroom: it is the least noisy reading.", es: "Por la mañana, en ayunas, después de ir al baño: es la medida menos ruidosa.")[language]) {
                        SliderRow(
                            value: $weightKg,
                            range: 35...200,
                            step: 0.1,
                            display: Format.weight(weightKg, unit: unit)
                        )
                    }
                    Card(title: LocalizedText(fr: "Masse grasse", en: "Body fat", es: "Grasa corporal")[language]) {
                        Toggle(LocalizedText(fr: "Je suis aussi mon taux de gras", en: "I also track my body fat", es: "También sigo mi porcentaje de grasa")[language], isOn: $tracksBodyFat)
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
            .navigationTitle(LocalizedText(fr: "Pesée", en: "Weigh-in", es: "Pesaje")[language])
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
