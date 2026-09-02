import Combine
import SwiftUI
import MonCoachKit

/// The screen used with one hand, between sets, in a noisy gym.
///
/// It shows one movement at a time, the exact set that is owed, and a big
/// enough control to log it without aiming.
struct SessionPlayerView: View {
    @Environment(\.language) private var language
    @State private var guidedExercise: Exercise?
    @State private var gymObstacleFor: Exercise?
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    @State private var restRemaining: Int = 0
    @State private var showingFinishConfirmation = false
    @State private var weightKg: Double = 0
    @State private var reps: Int = 0
    @State private var rpe: Double = 8
    @State private var painFlag = false
    @State private var selectedExerciseID: UUID?
    @State private var liveActivity = WorkoutActivityController()

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var active: ActiveSession? { store.activeSession }
    private var unit: UnitSystem { store.profile?.unit ?? .metric }

    var body: some View {
        NavigationStack {
            Group {
                if let active {
                    content(active)
                } else {
                    Text(LocalizedText(fr: "Aucune séance en cours.", en: "No session in progress.", es: "Ninguna sesión en curso.")[language])
                        .foregroundStyle(Theme.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .screenBackground()
                }
            }
            .navigationTitle(active?.session.title[language] ?? LocalizedText(fr: "Séance", en: "Session", es: "Sesión")[language])
            .sheet(item: $guidedExercise) { exercise in
                GuidedTechniqueView(exercise: exercise, owned: store.profile?.equipment)
            }
            .sheet(item: $gymObstacleFor) { exercise in
                GymCoachView(
                    exercise: exercise,
                    session: store.activeSession?.session
                ) { replacement in
                    substitute(exercise, with: replacement)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(LocalizedText(fr: "Terminer", en: "Finish", es: "Terminar")[language]) { showingFinishConfirmation = true }
                        .disabled((active?.loggedSetCount ?? 0) == 0)
                }
            }
            .confirmationDialog(
                LocalizedText(fr: "Terminer la séance ?", en: "Finish the session?", es: "¿Terminar la sesión?")[language],
                isPresented: $showingFinishConfirmation,
                titleVisibility: .visible
            ) {
                Button(LocalizedText(fr: "Terminer et enregistrer", en: "Finish and save", es: "Terminar y guardar")[language]) {
                    store.finishActiveSession()
                    dismiss()
                }
                Button(LocalizedText(fr: "Continuer la séance", en: "Keep going", es: "Continuar la sesión")[language], role: .cancel) {}
            } message: {
                Text(LocalizedText(fr: "Les séries déjà enregistrées sont conservées. Les séries restantes seront simplement absentes du bilan.", en: "Sets already logged are kept. The remaining sets will simply be missing from the review.", es: "Las series ya registradas se conservan. Las restantes simplemente faltarán en el balance.")[language])
            }
        }
        .preferredColorScheme(.dark)
        .tint(Theme.accent)
        .onReceive(ticker) { _ in
            if restRemaining > 0 { restRemaining -= 1 }
        }
        .onAppear {
            // L'écran verrouillé fait partie de Stride+. La séance, elle,
            // se déroule exactement pareil sans : c'est un confort qu'on
            // retire, jamais l'entraînement.
            if let active, store.isUnlocked(.liveActivities) {
                liveActivity.start(for: active, unit: unit, language: language)
            }
        }
        .onDisappear {
            // Séance terminée ou lecteur fermé : l'écran verrouillé ne doit
            // pas continuer d'afficher une séance qui n'existe plus.
            liveActivity.end()
        }
    }

    // MARK: - Content

    private func content(_ active: ActiveSession) -> some View {
        VStack(spacing: 0) {
            progressHeader(active)
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let current = currentPrescription(active) {
                        currentCard(active, prescription: current)
                    } else {
                        Card(title: LocalizedText(fr: "Séance terminée", en: "Session complete", es: "Sesión terminada")[language]) {
                            Text(LocalizedText(fr: "Toutes les séries prévues sont enregistrées. Tu peux clôturer la séance.", en: "All planned sets are logged. You can close the session.", es: "Todas las series previstas están registradas. Puedes cerrar la sesión.")[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                            PrimaryButton(title: LocalizedText(fr: "Enregistrer la séance", en: "Save the session", es: "Guardar la sesión")[language], systemImage: "checkmark") {
                                store.finishActiveSession()
                                dismiss()
                            }
                        }
                    }
                    remainingCard(active)
                }
                .padding(20)
            }
            .screenBackground()
        }
        .screenBackground()
    }

    private func progressHeader(_ active: ActiveSession) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(active.loggedSetCount) / \(active.session.totalSets) séries")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                Spacer()
                if restRemaining > 0 {
                    Label(Format.clock(seconds: restRemaining), systemImage: "timer")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.warning)
                }
            }
            ProgressBar(value: active.progress)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Theme.background)
    }

    /// The movement being worked on: either the one the athlete tapped, or
    /// the first one with sets still owed.
    private func currentPrescription(_ active: ActiveSession) -> ExercisePrescription? {
        if let selectedExerciseID,
           let picked = active.session.exercises.first(where: { $0.id == selectedExerciseID }),
           !active.isComplete(picked) {
            return picked
        }
        return active.currentExercise
    }

    /// Applique un remplacement à la séance en cours.
    ///
    /// La prescription garde son identifiant : les séries déjà enregistrées
    /// y restent attachées, et elles portent le nom du mouvement sur lequel
    /// elles ont réellement été faites.
    private func substitute(_ original: Exercise, with replacement: Exercise) {
        guard var active = store.activeSession,
              let prescription = active.session.exercises.first(where: { $0.exerciseID == original.id })
        else { return }
        active.substitute(prescription: prescription.id, with: replacement)
        store.activeSession = active
    }

    private func currentCard(_ active: ActiveSession, prescription: ExercisePrescription) -> some View {
        let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)
        let set = active.nextSet(of: prescription)
        let done = active.logs(for: prescription)

        return Card(
            title: exercise?.name[language] ?? prescription.exerciseID,
            subtitle: exercise.map { "\($0.primaryMuscle.label[language]) · \($0.pattern.label[language])" }
        ) {
            if let note = prescription.note {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(Theme.warning)
                        .font(.system(size: 13))
                    Text(note[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Le mode guidé est à un geste de la série en cours : c'est là
            // qu'on se demande si on fait le mouvement correctement, pas dans
            // un menu deux écrans plus loin.
            if let exercise {
                HStack(spacing: 18) {
                    Button {
                        guidedExercise = exercise
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "figure.strengthtraining.traditional")
                            Text(LocalizedText(fr: "Mode guidé", en: "Guided mode", es: "Modo guiado")[language])
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)

                    // Le bouton est ici, à côté de la série en cours, parce
                    // que c'est là qu'on se tient quand on découvre que le
                    // rack est occupé.
                    Button {
                        gymObstacleFor = exercise
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "person.2.slash")
                            Text(
                                LocalizedText(
                                    fr: "L'appareil est pris",
                                    en: "Equipment is taken",
                                    es: "La máquina está ocupada"
                                )[language]
                            )
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.warning)
                    }
                    .buttonStyle(.plain)
                }
            }

            if let set {
                Text("Série \(set.index + 1) sur \(prescription.sets.count) · \(set.repsLabel) répétitions · \(Format.rpe(set.targetRPE))")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.accent)

                entryControls(set: set)

                PrimaryButton(title: LocalizedText(fr: "Valider la série", en: "Log the set", es: "Validar la serie")[language], systemImage: "checkmark") {
                    log(set: set, of: prescription, restSeconds: prescription.restSeconds)
                }
            }

            if !done.isEmpty {
                Divider().overlay(Theme.separator)
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(done) { entry in
                        HStack {
                            Text(LocalizedText(fr: "Série \(entry.setIndex + 1)", en: "Set \(entry.setIndex + 1)", es: "Serie \(entry.setIndex + 1)")[language])
                                .font(Theme.captionFont)
                                .foregroundStyle(Theme.secondaryText)
                            Spacer()
                            Text("\(Format.load(entry.weightKg, unit: unit)) × \(entry.reps) · \(Format.rpe(entry.rpe))")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(entry.painFlag ? Theme.danger : Theme.primaryText)
                        }
                    }
                }
                GhostButton(title: LocalizedText(fr: "Annuler la dernière série", en: "Undo the last set", es: "Deshacer la última serie")[language], systemImage: "arrow.uturn.backward") {
                    store.activeSession?.undoLastSet(of: prescription)
                }
            }
        }
        .onAppear { prime(set: set, prescription: prescription) }
        .onChange(of: prescription.id) { _, _ in prime(set: set, prescription: prescription) }
    }

    private func entryControls(set: SetPrescription) -> some View {
        VStack(spacing: 14) {
            StepperRow(
                label: LocalizedText(fr: "Charge", en: "Load", es: "Carga")[language],
                value: Format.load(weightKg, unit: unit),
                onDecrement: { weightKg = max(0, weightKg - increment) },
                onIncrement: { weightKg += increment }
            )
            StepperRow(
                label: LocalizedText(fr: "Répétitions", en: "Reps", es: "Repeticiones")[language],
                value: "\(reps)",
                onDecrement: { reps = max(0, reps - 1) },
                onIncrement: { reps += 1 }
            )
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(LocalizedText(fr: "Difficulté ressentie", en: "Perceived effort", es: "Dificultad percibida")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Text("\(Format.rpe(rpe)) · \(rirLabel)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.primaryText)
                }
                Slider(value: $rpe, in: 5...10, step: 0.5)
                    .tint(Theme.accent)
            }
            Toggle(isOn: $painFlag) {
                Text(LocalizedText(fr: "J'ai senti une douleur articulaire", en: "I felt joint pain", es: "Sentí dolor articular")[language])
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.primaryText)
            }
            .tint(Theme.danger)
        }
    }

    private var rirLabel: String {
        let rir = Int((10 - rpe).rounded())
        return rir <= 0 ? LocalizedText(fr: "aucune répétition en réserve", en: "no reps in reserve", es: "ninguna repetición en reserva")[language] : LocalizedText(fr: "\(rir) répétition\(rir > 1 ? "s" : "") en réserve", en: "\(rir) rep\(rir > 1 ? "s" : "") in reserve", es: "\(rir) repetición\(rir > 1 ? "es" : "") en reserva")[language]
    }

    private var increment: Double {
        store.profile?.loadIncrement.stepKg ?? 2.5
    }

    private func remainingCard(_ active: ActiveSession) -> some View {
        Card(title: LocalizedText(fr: "Le reste de la séance", en: "The rest of the session", es: "El resto de la sesión")[language]) {
            VStack(spacing: 10) {
                ForEach(active.session.exercises) { prescription in
                    Button {
                        selectedExerciseID = prescription.id
                    } label: {
                        HStack {
                            Image(systemName: active.isComplete(prescription) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(active.isComplete(prescription) ? Theme.accent : Theme.secondaryText)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ExerciseCatalog.exercise(id: prescription.exerciseID)?.name[language] ?? prescription.exerciseID)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Theme.primaryText)
                                Text("\(active.logs(for: prescription).count) / \(prescription.sets.count) séries")
                                    .font(.system(size: 11))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Actions

    /// Pre-fills the entry controls with the prescription, so the common case
    /// is a single tap on "valider".
    private func prime(set: SetPrescription?, prescription: ExercisePrescription) {
        guard let set else { return }
        weightKg = set.suggestedLoadKg ?? weightKg
        reps = set.repUpperBound
        rpe = set.targetRPE
        painFlag = false
    }

    private func log(set: SetPrescription, of prescription: ExercisePrescription, restSeconds: Int) {
        store.activeSession?.log(
            set,
            of: prescription,
            weightKg: weightKg,
            reps: reps,
            rpe: rpe,
            painFlag: painFlag
        )
        restRemaining = restSeconds
        painFlag = false
        if let active = store.activeSession {
            liveActivity.update(
                for: active,
                unit: unit,
                language: language,
                restEndsAt: Date().addingTimeInterval(TimeInterval(restSeconds))
            )
        }
        if let active = store.activeSession,
           let next = active.nextSet(of: prescription) {
            prime(set: next, prescription: prescription)
        } else {
            selectedExerciseID = nil
        }
    }
}

/// Big minus / value / plus row, sized for tapping without looking.
struct StepperRow: View {
    var label: String
    var value: String
    var onDecrement: () -> Void
    var onIncrement: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            HStack(spacing: 12) {
                stepButton("minus", action: onDecrement)
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .frame(maxWidth: .infinity)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                stepButton("plus", action: onIncrement)
            }
        }
    }

    private func stepButton(_ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .bold))
                .frame(width: 54, height: 54)
                .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(Theme.primaryText)
        }
        .buttonStyle(.plain)
    }
}
