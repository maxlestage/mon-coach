import Combine
import SwiftUI
import WatchKit
import MonCoachKit

/// La séance au poignet : une série à la fois, réglable à la couronne.
///
/// Tout est dimensionné pour être manipulé entre deux séries, essoufflé :
/// une seule valeur ajustable à la fois, des boutons pleine largeur, et la
/// validation pré-remplie avec la prescription.
struct WatchSessionView: View {
    @Environment(WatchStore.self) private var store
    @Environment(\.language) private var language

    @State private var weightKg: Double = 0
    @State private var reps: Double = 0
    @State private var rpe: Double = 8
    @State private var restRemaining: Int = 0
    @State private var adjusting: Adjusting = .weight
    @State private var confirmingFinish = false
    /// La fiche de l'exercice en cours, poussée par-dessus la série.
    @State private var showsBrief = false
    @State private var showsSubstitution = false

    private let ticker = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Adjusting: String, CaseIterable {
        case weight
        case reps
        case rpe

        var label: LocalizedText {
            switch self {
            case .weight: LocalizedText(fr: "Charge", en: "Load", es: "Carga")
            case .reps: LocalizedText(fr: "Rép", en: "Reps", es: "Rep")
            case .rpe: LocalizedText.constant("RPE")
            }
        }
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
            guard restRemaining > 0 else { return }
            restRemaining -= 1
            // Le poignet prévient quand le repos est fini.
            //
            // C'est tout l'intérêt d'un chrono à cette place : sans
            // vibration, il faut regarder l'écran pour savoir qu'on peut
            // repartir — et regarder sa montre toutes les dix secondes entre
            // deux séries, c'est exactement ce qu'on venait éviter. Les
            // trois dernières secondes préviennent doucement, la fin
            // franchement.
            switch restRemaining {
            case 0: WKInterfaceDevice.current().play(.notification)
            case 1...3: WKInterfaceDevice.current().play(.click)
            default: break
            }
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
        .confirmationDialog(
            LocalizedText(
                fr: "Terminer la séance ?",
                en: "Finish the session?",
                es: "¿Terminar la sesión?"
            )[language],
            isPresented: $confirmingFinish
        ) {
            Button(
                LocalizedText(
                    fr: "Terminer et synchroniser",
                    en: "Finish and sync",
                    es: "Terminar y sincronizar"
                )[language]
            ) { store.finishActiveSession() }
            // Une séance ouverte par erreur ne doit pas obliger à
            // enregistrer un entraînement qui n'a pas eu lieu.
            Button(WatchUI.discardSession[language], role: .destructive) {
                store.discardActiveSession()
            }
            Button(
                LocalizedText(fr: "Continuer", en: "Keep going", es: "Continuar")[language],
                role: .cancel
            ) {}
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

                Text(exercise?.name[language] ?? prescription.exerciseID)
                    .font(.system(.body, design: .rounded, weight: .bold))
                    .lineLimit(2)

                if let set {
                    Text(
                        LocalizedText(
                            fr: "Série \(set.index + 1)/\(prescription.sets.count) · \(set.repsLabel) rép · \(Format.rpe(set.targetRPE))",
                            en: "Set \(set.index + 1)/\(prescription.sets.count) · \(set.repsLabel) reps · \(Format.rpe(set.targetRPE))",
                            es: "Serie \(set.index + 1)/\(prescription.sets.count) · \(set.repsLabel) rep · \(Format.rpe(set.targetRPE))"
                        )[language]
                    )
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

                    // Trois boutons plutôt qu'un Picker, et ce n'est pas un
                    // pis-aller : watchOS n'a pas de style segmenté, et les
                    // deux styles qu'il offre échouent tous les deux ici. La
                    // roue se pilote à la couronne, déjà prise juste au-dessus
                    // par la valeur qu'on règle. Le lien de navigation pousse
                    // un écran entier pour changer de champ, entre deux séries,
                    // essoufflé. Une rangée de boutons garde le geste à un seul
                    // appui, sans quitter la série.
                    HStack(spacing: 4) {
                        ForEach(Adjusting.allCases, id: \.self) { choice in
                            Button {
                                adjusting = choice
                            } label: {
                                Text(choice.label[language])
                                    .font(.caption2)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(adjusting == choice ? .green : .gray)
                        }
                    }
                    .frame(height: 32)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(
                        LocalizedText(fr: "Réglage", en: "Adjusting", es: "Ajuste")[language]
                    )

                    // La fiche au poignet : c'est devant la machine qu'on se
                    // demande où mettre les pieds, et c'est précisément là
                    // qu'on n'a pas envie d'aller chercher son téléphone.
                    if exercise != nil {
                        Button {
                            showsBrief = true
                        } label: {
                            Label(
                                LocalizedText(
                                    fr: "La fiche",
                                    en: "The card",
                                    es: "La ficha"
                                )[language],
                                systemImage: "info.circle"
                            )
                            .font(.system(size: 12))
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    }

                    Button {
                        showsSubstitution = true
                    } label: {
                        Label(
                            LocalizedText(
                                fr: "Appareil pris",
                                en: "Kit taken",
                                es: "Máquina ocupada"
                            )[language],
                            systemImage: "person.2.slash"
                        )
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)

                    Button {
                        log(set: set, of: prescription)
                    } label: {
                        Label(
                            LocalizedText(
                                fr: "Valider la série",
                                en: "Log the set",
                                es: "Registrar la serie"
                            )[language],
                            systemImage: "checkmark"
                        )
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }

                ProgressView(value: active.progress)
                    .tint(.green)
                Text(
                    LocalizedText(
                        fr: "\(active.loggedSetCount)/\(active.session.totalSets) séries",
                        en: "\(active.loggedSetCount)/\(active.session.totalSets) sets",
                        es: "\(active.loggedSetCount)/\(active.session.totalSets) series"
                    )[language]
                )
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(active.session.title[language])
        .navigationDestination(isPresented: $showsBrief) {
            if let exercise {
                WatchExerciseBriefView(exercise: exercise)
            }
        }
        .navigationDestination(isPresented: $showsSubstitution) {
            WatchGymView(prescription: prescription) { replacement in
                store.substituteInActiveSession(prescription: prescription.id, with: replacement)
            }
        }
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
                Text(
                    LocalizedText(
                        fr: "\(Int(reps)) rép",
                        en: "\(Int(reps)) reps",
                        es: "\(Int(reps)) rep"
                    )[language]
                )
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
                Label(
                    LocalizedText(
                        fr: "Séance terminée",
                        en: "Session finished",
                        es: "Sesión terminada"
                    )[language],
                    systemImage: "checkmark.seal.fill"
                )
                    .font(.headline)
                    .foregroundStyle(.green)
                Text(
                    LocalizedText(
                        fr: "Toutes les séries sont enregistrées. Le journal part vers ton iPhone dès qu'il est à portée.",
                        en: "Every set is logged. The record goes to your iPhone as soon as it is in range.",
                        es: "Todas las series están registradas. El registro irá a tu iPhone en cuanto esté a tu alcance."
                    )[language]
                )
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
