import SwiftUI
import MonCoachKit

/// The questionnaire that turns a stranger into a profile the coach can plan for.
///
/// Every question here changes something concrete downstream, and each step
/// says which — people answer honestly when they can see why it is asked.
struct OnboardingView: View {

    enum Step: Int, CaseIterable {
        case welcome, identity, body, experience, goal, availability, equipment, limitations, lifestyle, baselines, summary

        var title: String {
            switch self {
            case .welcome: "Bienvenue"
            case .identity: "Toi"
            case .body: "Ton corps"
            case .experience: "Ton expérience"
            case .goal: "Ton objectif"
            case .availability: "Ta disponibilité"
            case .equipment: "Ton matériel"
            case .limitations: "Tes limites"
            case .lifestyle: "Ton quotidien"
            case .baselines: "Tes charges"
            case .summary: "Ton programme"
            }
        }
    }

    var onFinish: (UserProfile) -> Void

    @State private var draft = ProfileDraft()
    @State private var step: Step = .welcome

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.stackSpacing) {
                    content
                }
                .padding(20)
            }
            footer
        }
        .background(Theme.background)
        .preferredColorScheme(.dark)
    }

    // MARK: - Chrome

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(step.title)
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.primaryText)
                Spacer()
                Text("\(step.rawValue + 1)/\(Step.allCases.count)")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
            }
            ProgressBar(value: Double(step.rawValue) / Double(Step.allCases.count - 1))
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            if step != .welcome {
                Button {
                    move(-1)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 50, height: 50)
                        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(Theme.primaryText)
                }
                .buttonStyle(.plain)
            }

            if step == .summary {
                PrimaryButton(title: "Lancer mon programme", systemImage: "bolt.fill") {
                    onFinish(draft.makeProfile())
                }
                .disabled(!draft.isValid)
                .opacity(draft.isValid ? 1 : 0.5)
            } else {
                PrimaryButton(title: step == .welcome ? "Commencer" : "Continuer") {
                    move(1)
                }
                .disabled(!canAdvance)
                .opacity(canAdvance ? 1 : 0.5)
            }
        }
        .padding(20)
        .background(Theme.background)
    }

    private var canAdvance: Bool {
        switch step {
        case .identity: !draft.firstName.trimmingCharacters(in: .whitespaces).isEmpty
        case .equipment: !draft.equipment.isEmpty
        default: true
        }
    }

    private func move(_ delta: Int) {
        let index = (step.rawValue + delta).clamped(to: 0...(Step.allCases.count - 1))
        withAnimation(.easeInOut(duration: 0.2)) {
            step = Step(rawValue: index) ?? .welcome
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome: welcomeStep
        case .identity: identityStep
        case .body: bodyStep
        case .experience: experienceStep
        case .goal: goalStep
        case .availability: availabilityStep
        case .equipment: equipmentStep
        case .limitations: limitationsStep
        case .lifestyle: lifestyleStep
        case .baselines: baselinesStep
        case .summary: summaryStep
        }
    }

    private var welcomeStep: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Un coach, pas un carnet de notes.")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
            Text("Une dizaine de questions, puis un programme construit pour toi : le bon nombre de séries, les bons exercices avec ton matériel, et des charges qui s'ajustent séance après séance en fonction de ce que tu fais réellement.")
                .font(.system(size: 16))
                .foregroundStyle(Theme.secondaryText)

            VStack(alignment: .leading, spacing: 12) {
                promise(icon: "person.fill.checkmark", text: "Chaque réponse change quelque chose de concret dans ton plan. Aucune n'est là pour faire joli.")
                promise(icon: "wifi.slash", text: "Tout est calculé sur ton téléphone. Rien ne part sur un serveur, aucun compte à créer.")
                promise(icon: "arrow.triangle.2.circlepath", text: "Le programme se réécrit chaque semaine à partir de tes séances réelles.")
            }
            .padding(.top, 6)

            Text("Créé et fait par Maxime Nathan Lestage")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .padding(.top, 10)
        }
    }

    private func promise(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Theme.accent)
                .frame(width: 26)
            Text(text)
                .font(Theme.bodyFont)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var identityStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: "Comment tu t'appelles ?") {
                TextField("Prénom", text: $draft.firstName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .padding(12)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
            }
            Card(title: "Date de naissance", subtitle: "L'âge entre dans le calcul du métabolisme et dans la vitesse de récupération attendue.") {
                DatePicker("", selection: $draft.birthDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Theme.accent)
            }
            Card(title: "Sexe", subtitle: "Utilisé uniquement là où les formules en ont besoin : métabolisme de base, masse maigre estimée, repères de force.") {
                Picker("", selection: $draft.sex) {
                    ForEach(Sex.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var bodyStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: "Unités") {
                Picker("", selection: $draft.unit) {
                    ForEach(UnitSystem.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Card(title: "Taille") {
                SliderRow(
                    value: $draft.heightCm,
                    range: 130...220,
                    step: 1,
                    display: Format.height(draft.heightCm, unit: draft.unit)
                )
            }
            Card(title: "Poids actuel", subtitle: "Base de tes calories, de tes protéines et des charges de départ.") {
                SliderRow(
                    value: $draft.weightKg,
                    range: 35...200,
                    step: 0.5,
                    display: Format.weight(draft.weightKg, unit: draft.unit)
                )
            }
            Card(
                title: "Taux de masse grasse",
                subtitle: "Facultatif. Si tu le connais, le coach passe sur des formules plus précises (Katch-McArdle) et calcule tes protéines sur la masse maigre."
            ) {
                Toggle("Je connais mon taux", isOn: $draft.knowsBodyFat)
                    .tint(Theme.accent)
                    .foregroundStyle(Theme.primaryText)
                if draft.knowsBodyFat {
                    SliderRow(
                        value: $draft.bodyFatPercent,
                        range: 4...50,
                        step: 0.5,
                        display: "\(Format.number(draft.bodyFatPercent, decimals: 1)) %"
                    )
                    SliderRow(
                        value: $draft.waistCm,
                        range: 55...150,
                        step: 0.5,
                        display: "Tour de taille : \(Format.height(draft.waistCm, unit: draft.unit))"
                    )
                }
            }
        }
    }

    private var experienceStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: "Depuis combien de temps tu t'entraînes sérieusement ?",
                subtitle: "« Sérieusement » veut dire régulièrement, en notant ou en suivant une progression."
            ) {
                SliderRow(
                    value: Binding(
                        get: { Double(draft.trainingMonths) },
                        set: { draft.trainingMonths = Int($0) }
                    ),
                    range: 0...120,
                    step: 1,
                    display: draft.trainingMonths == 0
                        ? "Jamais / je reprends de zéro"
                        : "\(draft.trainingMonths) mois"
                )
            }
            Card(
                title: "Niveau",
                subtitle: "Déduit de ta réponse, mais tu peux le corriger. Il détermine ton volume de départ et la longueur de tes blocs."
            ) {
                Picker("", selection: Binding(
                    get: { draft.experience },
                    set: { draft.experienceOverride = $0 }
                )) {
                    ForEach(ExperienceLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.segmented)

                Text(experienceExplanation)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var experienceExplanation: String {
        switch draft.experience {
        case .beginner:
            "Peu de séries, beaucoup de technique, et des blocs de 6 semaines. C'est le niveau où l'on progresse le plus vite en faisant le moins."
        case .intermediate:
            "Volume standard, progression en double progression, blocs de 5 semaines."
        case .advanced:
            "Volume élevé, blocs courts de 4 semaines, décharges plus fréquentes : la récupération devient le facteur limitant."
        }
    }

    private var goalStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: "Qu'est-ce que tu veux, précisément ?") {
                VStack(spacing: 8) {
                    ForEach(PrimaryGoal.allCases, id: \.self) { goal in
                        SelectableRow(
                            title: goal.label,
                            subtitle: goalSubtitle(goal),
                            isSelected: draft.goal == goal
                        ) {
                            draft.goal = goal
                            if !draft.hasTargetWeight { draft.targetWeightKg = draft.weightKg }
                        }
                    }
                }
            }
            Card(title: "Poids visé", subtitle: "Facultatif. Sert à estimer combien de semaines il te faut au rythme prescrit.") {
                Toggle("J'ai un poids cible", isOn: $draft.hasTargetWeight)
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
                Toggle("J'ai une échéance", isOn: $draft.hasDeadline)
                    .tint(Theme.accent)
                    .foregroundStyle(Theme.primaryText)
                if draft.hasDeadline {
                    DatePicker("", selection: $draft.deadline, in: Date()..., displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(Theme.accent)
                }
            }
        }
    }

    private func goalSubtitle(_ goal: PrimaryGoal) -> String {
        switch goal {
        case .hypertrophy: "Séries de 6 à 12, léger surplus calorique, volume maximal que tu peux récupérer."
        case .strength: "Séries de 3 à 6, repos longs, moins de séries mais plus lourdes."
        case .fatLoss: "Déficit mesuré, protéines hautes, volume adapté à une récupération réduite."
        case .recomposition: "Calories de maintien, protéines très hautes : progresser en salle sans bouger sur la balance."
        case .generalHealth: "Deux à trois séances complètes, intensité modérée, zéro prise de tête."
        }
    }

    private var availabilityStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: "Combien de séances par semaine ?",
                subtitle: "Réponds avec ce que tu tiendras un mois de suite, pas avec ce que tu voudrais tenir."
            ) {
                Picker("", selection: $draft.daysPerWeek) {
                    ForEach(2...6, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)

                Text(SplitPlanner.split(for: previewProfile).rationale)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Card(
                title: "Combien de temps par séance ?",
                subtitle: "Échauffement compris. Le coach ne prescrira jamais plus long que ça."
            ) {
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
    }

    private var equipmentStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: "Où t'entraînes-tu ?") {
                HStack(spacing: 8) {
                    kitButton("Salle complète", Equipment.fullGym)
                    kitButton("Maison", Equipment.homeGym)
                    kitButton("Minimal", Equipment.minimal)
                }
            }
            Card(
                title: "Détail du matériel",
                subtitle: "Un exercice n'est proposé que si tu as tout ce qu'il demande. Mieux vaut décocher que d'improviser en salle."
            ) {
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
            }
            Card(
                title: "Plus petit incrément de charge",
                subtitle: "Les charges suggérées sont arrondies à ce que tu peux vraiment charger."
            ) {
                Picker("", selection: $draft.loadIncrement) {
                    ForEach(LoadIncrement.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
        }
    }

    private func kitButton(_ title: String, _ kit: Set<Equipment>) -> some View {
        Button {
            draft.equipment = kit
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    draft.equipment == kit ? Theme.accent : Theme.surfaceRaised,
                    in: RoundedRectangle(cornerRadius: 12)
                )
                .foregroundStyle(draft.equipment == kit ? Theme.background : Theme.primaryText)
        }
        .buttonStyle(.plain)
    }

    private var limitationsStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: "Une zone qui te fait mal ?",
                subtitle: "Tout exercice qui sollicite directement une zone cochée est retiré du catalogue. Rien ne sera « adapté » : il sera remplacé."
            ) {
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
            Card {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "cross.case.fill")
                        .foregroundStyle(Theme.warning)
                    Text("Une douleur qui dure n'est pas un problème de programmation. Cette application ne remplace pas un médecin ou un kinésithérapeute.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var lifestyleStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: "Activité en dehors des séances", subtitle: "Détermine ta dépense énergétique, donc tes calories.") {
                Picker("", selection: $draft.activityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Card(title: "Sommeil moyen", subtitle: "En dessous de 6 h, le coach réduit le volume : sinon tu accumules de la fatigue sans progresser.") {
                SliderRow(
                    value: $draft.sleepHours,
                    range: 4...10,
                    step: 0.5,
                    display: "\(Format.number(draft.sleepHours, decimals: 1)) h"
                )
            }
            Card(title: "Niveau de stress habituel", subtitle: "1 = serein, 5 = sous l'eau. Le stress chronique coûte de la récupération.") {
                SliderRow(
                    value: Binding(
                        get: { Double(draft.stressLevel) },
                        set: { draft.stressLevel = Int($0) }
                    ),
                    range: 1...5,
                    step: 1,
                    display: "\(draft.stressLevel) / 5"
                )
            }
            Card(title: "Alimentation", subtitle: "N'affecte pas les chiffres, seulement les conseils de répartition.") {
                Picker("", selection: $draft.dietPreference) {
                    ForEach(DietPreference.allCases, id: \.self) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.accent)
            }
        }
    }

    private var baselinesStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: "Tes maximums, si tu les connais",
                subtitle: "Facultatif : sans ces valeurs, le coach part des repères de force pour ton poids, ton sexe et ton niveau, puis corrige dès la première séance."
            ) {
                VStack(spacing: 10) {
                    ForEach(ProfileDraft.baselineLiftIDs, id: \.self) { id in
                        if let exercise = ExerciseCatalog.exercise(id: id) {
                            OneRepMaxRow(
                                name: exercise.name,
                                unit: draft.unit,
                                valueKg: Binding(
                                    get: { draft.oneRepMax[id] ?? 0 },
                                    set: { draft.oneRepMax[id] = $0 }
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: Summary

    private var previewProfile: UserProfile { draft.makeProfile() }

    private var summaryStep: some View {
        let program = CoachEngine.buildProgram(for: previewProfile)
        return VStack(spacing: Theme.stackSpacing) {
            Card(title: "Ce que le coach a décidé", subtitle: program.plan.split.label) {
                HStack(spacing: 12) {
                    StatTile(value: "\(program.plan.weekCount)", label: "semaines dans le bloc")
                    StatTile(value: "\(previewProfile.daysPerWeek)", label: "séances par semaine")
                    StatTile(value: "\(program.plan.weeks[0].totalSets)", label: "séries la 1re semaine")
                }
            }
            Card(title: "Tes cibles quotidiennes") {
                HStack(spacing: 12) {
                    StatTile(value: "\(program.nutrition.calories)", label: "kcal")
                    StatTile(value: "\(program.nutrition.proteinG) g", label: "protéines")
                    StatTile(value: "\(program.nutrition.carbsG) g", label: "glucides")
                    StatTile(value: "\(program.nutrition.fatG) g", label: "lipides")
                }
                if let weeks = program.weeksToGoal {
                    Text("Au rythme prescrit, ton poids cible est atteignable en environ \(weeks) semaines.")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.accent)
                }
            }
            Card(title: "Pourquoi ce plan et pas un autre") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(program.plan.rationale.enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 5, height: 5)
                                .padding(.top, 7)
                            Text(line)
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            Card(title: "Ta première séance") {
                if let first = program.plan.weeks.first?.sessions.first {
                    SessionSummary(session: first, unit: draft.unit)
                }
            }
        }
    }
}

// MARK: - Small form controls

/// A slider with its value shown above it, which is the only slider layout
/// that works when the thumb is under a thumb.
struct SliderRow: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double
    var display: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(display)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
            Slider(value: $value, in: range, step: step)
                .tint(Theme.accent)
        }
    }
}

/// A tappable row with a title, an explanation and a checkmark.
struct SelectableRow: View {
    var title: String
    var subtitle: String?
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundStyle(isSelected ? Theme.accent : Theme.secondaryText)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.primaryText)
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(12)
            .background(
                isSelected ? Theme.accentMuted : Theme.surfaceRaised,
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Multi-select chips that wrap onto as many lines as they need.
struct FlowSelection<Item: Hashable>: View {
    var items: [Item]
    var label: (Item) -> String
    var isSelected: (Item) -> Bool
    var toggle: (Item) -> Void

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    toggle(item)
                } label: {
                    Text(label(item))
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            isSelected(item) ? Theme.accent : Theme.surfaceRaised,
                            in: Capsule()
                        )
                        .foregroundStyle(isSelected(item) ? Theme.background : Theme.primaryText)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// One optional 1RM entry.
struct OneRepMaxRow: View {
    var name: String
    var unit: UnitSystem
    @Binding var valueKg: Double

    var body: some View {
        HStack {
            Text(name)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Theme.primaryText)
            Spacer()
            Text(valueKg > 0 ? Format.weight(valueKg, unit: unit, decimals: 0) : "Je ne sais pas")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(valueKg > 0 ? Theme.accent : Theme.secondaryText)
            Stepper("") {
                valueKg = min(400, valueKg + 5)
            } onDecrement: {
                valueKg = max(0, valueKg - 5)
            }
            .labelsHidden()
            .tint(Theme.accent)
        }
        .padding(.vertical, 4)
    }
}
