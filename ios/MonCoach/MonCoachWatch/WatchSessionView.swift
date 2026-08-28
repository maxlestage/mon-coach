import Combine
import SwiftUI
import MonCoachKit

/// La séance au poignet : une série à la fois, réglable à la couronne.
///
/// Tout est dimensionné pour être manipulé entre deux séries, essoufflé :
/// une seule valeur ajustable à la fois, des boutons pleine largeur, et la
/// validation pré-remplie avec la prescription.
struct WatchSessionView: View {
    @Environment(WatchStore.self) private var store

    @State private var weightKg: Double = 0
    @State private var reps: Double = 0
    @State private var rpe: Double = 8
    @State private var restRemaining: Int = 0
    @State private var adjusting: Adjusting = .weight
    @State private var confirmingFinish = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Adjusting: String, CaseIterable {
        case weight = "Charge"
        case reps = "Rép"
        case rpe = "RPE"
    }

    var body: some View {
        Group {
            if let active = store.activeSession, let current = active.currentExercise {
                exerciseView(active: active, prescription: current)
            } else {
                finishedView
            }
        }
        .onReceive(ticker) { _ in
            if restRemaining > 0 { restRemaining -= 1 }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    confirmingFinish = true
                } label: {
                    Image(systemName: "flag.checkered")
                }
            }
        }
        .confirmationDialog("Terminer la séance ?", isPresented: $confirmingFinish) {
            Button("Terminer et synchroniser") { store.finishActiveSession() }
            Button("Continuer", role: .cancel) {}
        }
    }

    // MARK: - Une série

    private func exerciseView(active: ActiveSession, prescription: ExercisePrescription) -> some View {
        let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)
        let set = active.nextSet(of: prescription)

        return ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if restRemaining > 0 {
                    restBanner
                }

                Text(exercise?.name ?? prescription.exerciseID)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .lineLimit(2)

                if let set {
                    Text("Série \(set.index + 1)/\(prescription.sets.count) · \(set.repsLabel) rép · \(Format.rpe(set.targetRPE))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    adjustedValue
                        .focusable()
                        .digitalCrownRotation(
                            crownBinding,
                            from: crownRange.lowerBound,
                            through: crownRange.upperBound,
                            by: crownStep,
                            sensitivity: .medium,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true
                        )

                    Picker("Réglage", selection: $adjusting) {
                        ForEach(Adjusting.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .frame(height: 32)

                    Button {
                        log(set: set, of: prescription)
                    } label: {
                        Label("Valider la série", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                ProgressView(value: active.progress)
                    .tint(.green)
                Text("\(active.loggedSetCount)/\(active.session.totalSets) séries")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(active.session.title)
        .onAppear { prime(set: set) }
        .onChange(of: prescription.id) { _, _ in prime(set: active.nextSet(of: prescription)) }
    }

    private var restBanner: some View {
        HStack {
            Image(systemName: "timer")
            Text(Format.clock(seconds: restRemaining))
                .font(.system(.body, design: .rounded, weight: .bold))
                .contentTransition(.numericText())
            Spacer()
        }
        .padding(8)
        .background(.orange.opacity(0.2), in: RoundedRectangle(cornerRadius: 10))
    }

    /// La valeur en cours de réglage, en gros, au centre.
    private var adjustedValue: some View {
        HStack(alignment: .firstTextBaseline) {
            Spacer()
            switch adjusting {
            case .weight:
                Text(weightKg > 0 ? Format.load(weightKg, unit: store.unit) : "au poids du corps")
                    .font(.system(size: weightKg > 0 ? 26 : 14, weight: .bold, design: .rounded))
            case .reps:
                Text("\(Int(reps)) rép")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
            case .rpe:
                Text(Format.rpe(rpe))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
            }
            Spacer()
        }
        .foregroundStyle(.green)
        .padding(.vertical, 2)
    }

    // MARK: - Couronne

    private var crownBinding: Binding<Double> {
        switch adjusting {
        case .weight: return $weightKg
        case .reps: return $reps
        case .rpe: return $rpe
        }
    }

    private var crownRange: ClosedRange<Double> {
        switch adjusting {
        case .weight: return 0...400
        case .reps: return 0...50
        case .rpe: return 5...10
        }
    }

    private var crownStep: Double {
        switch adjusting {
        case .weight: return store.loadStepKg
        case .reps: return 1
        case .rpe: return 0.5
        }
    }

    // MARK: - Actions

    private func prime(set: SetPrescription?) {
        guard let set else { return }
        weightKg = set.suggestedLoadKg ?? weightKg
        reps = Double(set.repUpperBound)
        rpe = set.targetRPE
        adjusting = .weight
    }

    private func log(set: SetPrescription, of prescription: ExercisePrescription) {
        store.activeSession?.log(
            set,
            of: prescription,
            weightKg: weightKg,
            reps: Int(reps),
            rpe: rpe,
            painFlag: false
        )
        restRemaining = prescription.restSeconds
        if let active = store.activeSession, let next = active.nextSet(of: prescription) {
            prime(set: next)
        }
    }

    // MARK: - Fin

    private var finishedView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Label("Séance terminée", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(.green)
                Text("Toutes les séries sont enregistrées. Le journal part vers ton iPhone dès qu'il est à portée.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Button("Enregistrer") {
                    store.finishActiveSession()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
        }
        .navigationTitle("Bravo")
    }
}
