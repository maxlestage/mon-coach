import SwiftUI
import MonCoachKit

/// The questionnaire that turns a stranger into a profile the coach can plan for.
///
/// Every question here changes something concrete downstream, and each step
/// says which — people answer honestly when they can see why it is asked.
struct OnboardingView: View {
    @Environment(\.language) private var language

    enum Step: Int, CaseIterable {
        case welcome, identity, body, experience, goal, availability, equipment, limitations, lifestyle, baselines, summary

        var title: LocalizedText {
            switch self {
            case .welcome: LocalizedText(fr: "Bienvenue", en: "Welcome", es: "Bienvenido")
            case .identity: LocalizedText(fr: "Toi", en: "You", es: "Tú")
            case .body: LocalizedText(fr: "Ton corps", en: "Your body", es: "Tu cuerpo")
            case .experience: LocalizedText(fr: "Ton expérience", en: "Your experience", es: "Tu experiencia")
            case .goal: LocalizedText(fr: "Ton objectif", en: "Your goal", es: "Tu objetivo")
            case .availability: LocalizedText(fr: "Ta disponibilité", en: "Your availability", es: "Tu disponibilidad")
            case .equipment: LocalizedText(fr: "Ton matériel", en: "Your equipment", es: "Tu material")
            case .limitations: LocalizedText(fr: "Tes limites", en: "Your limits", es: "Tus límites")
            case .lifestyle: LocalizedText(fr: "Ton quotidien", en: "Your daily life", es: "Tu día a día")
            case .baselines: LocalizedText(fr: "Tes charges", en: "Your loads", es: "Tus cargas")
            case .summary: LocalizedText(fr: "Ton programme", en: "Your programme", es: "Tu programa")
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
                Text(step.title[language])
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
                PrimaryButton(title: LocalizedText(fr: "Lancer mon programme", en: "Start my programme", es: "Lanzar mi programa")[language], systemImage: "bolt.fill") {
                    onFinish(draft.makeProfile())
                }
                .disabled(!draft.isValid)
                .opacity(draft.isValid ? 1 : 0.5)
            } else {
                PrimaryButton(title: step == .welcome ? LocalizedText(fr: "Commencer", en: "Get started", es: "Empezar")[language] : LocalizedText(fr: "Continuer", en: "Continue", es: "Continuar")[language]) {
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
            Text(LocalizedText(fr: "Un coach, pas un carnet de notes.", en: "A coach, not a notebook.", es: "Un entrenador, no un cuaderno.")[language])
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
            Text(LocalizedText(fr: "Une dizaine de questions, puis un programme construit pour toi : le bon nombre de séries, les bons exercices avec ton matériel, et des charges qui s'ajustent séance après séance en fonction de ce que tu fais réellement.", en: "About ten questions, then a programme built for you: the right number of sets, the right exercises with your equipment, and loads that adjust session after session from what you actually do.", es: "Una decena de preguntas y luego un programa construido para ti: el número justo de series, los ejercicios adecuados con tu material, y cargas que se ajustan sesión tras sesión según lo que realmente haces.")[language])
                .font(.system(size: 16))
                .foregroundStyle(Theme.secondaryText)

            VStack(alignment: .leading, spacing: 12) {
                promise(icon: "person.fill.checkmark", text: LocalizedText(fr: "Chaque réponse change quelque chose de concret dans ton plan. Aucune n'est là pour faire joli.", en: "Every answer changes something concrete in your plan. None is there for show.", es: "Cada respuesta cambia algo concreto en tu plan. Ninguna está de adorno.")[language])
                promise(icon: "wifi.slash", text: LocalizedText(fr: "Tout est calculé sur ton téléphone. Rien ne part sur un serveur, aucun compte à créer.", en: "Everything is computed on your phone. Nothing goes to a server, no account to create.", es: "Todo se calcula en tu teléfono. Nada va a un servidor, sin cuenta que crear.")[language])
                promise(icon: "arrow.triangle.2.circlepath", text: LocalizedText(fr: "Le programme se réécrit chaque semaine à partir de tes séances réelles.", en: "The programme rewrites itself every week from your real sessions.", es: "El programa se reescribe cada semana a partir de tus sesiones reales.")[language])
            }
            .padding(.top, 6)

            Text(LocalizedText(fr: "Conçu et développé par Maxime Nathan Lestage", en: "Designed and developed by Maxime Nathan Lestage", es: "Diseñado y desarrollado por Maxime Nathan Lestage")[language])
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
            Card(title: LocalizedText(fr: "Comment tu t'appelles ?", en: "What's your name?", es: "¿Cómo te llamas?")[language]) {
                TextField(LocalizedText(fr: "Prénom", en: "First name", es: "Nombre")[language], text: $draft.firstName)
                    .textFieldStyle(.plain)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.primaryText)
                    .padding(12)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 12))
            }
            Card(title: LocalizedText(fr: "Date de naissance", en: "Date of birth", es: "Fecha de nacimiento")[language], subtitle: LocalizedText(fr: "L'âge entre dans le calcul du métabolisme et dans la vitesse de récupération attendue.", en: "Age goes into the metabolism calculation and the expected recovery speed.", es: "La edad entra en el cálculo del metabolismo y en la velocidad de recuperación esperada.")[language]) {
                DatePicker("", selection: $draft.birthDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Theme.accent)
            }
            Card(title: LocalizedText(fr: "Sexe", en: "Sex", es: "Sexo")[language], subtitle: LocalizedText(fr: "Utilisé uniquement là où les formules en ont besoin : métabolisme de base, masse maigre estimée, repères de force.", en: "Used only where the formulas need it: basal metabolism, estimated lean mass, strength benchmarks.", es: "Se usa solo donde las fórmulas lo necesitan: metabolismo basal, masa magra estimada, referencias de fuerza.")[language]) {
                Picker("", selection: $draft.sex) {
                    ForEach(Sex.allCases, id: \.self) { Text($0.label[language]).tag($0) }
                }
                .pickerStyle(.segmented)
            }
        }
    }

    private var bodyStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: LocalizedText(fr: "Unités", en: "Units", es: "Unidades")[language]) {
                Picker("", selection: $draft.unit) {
                    ForEach(UnitSystem.allCases, id: \.self) { Text($0.label[language]).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            Card(title: LocalizedText(fr: "Taille", en: "Height", es: "Estatura")[language]) {
                SliderRow(
                    value: $draft.heightCm,
                    range: 130...220,
                    step: 1,
                    display: Format.height(draft.heightCm, unit: draft.unit)
                )
            }
            Card(title: LocalizedText(fr: "Poids actuel", en: "Current weight", es: "Peso actual")[language], subtitle: LocalizedText(fr: "Base de tes calories, de tes protéines et des charges de départ.", en: "The basis of your calories, your protein and your starting loads.", es: "Base de tus calorías, tus proteínas y tus cargas de partida.")[language]) {
                SliderRow(
                    value: $draft.weightKg,
                    range: 35...200,
                    step: 0.5,
                    display: Format.weight(draft.weightKg, unit: draft.unit)
                )
            }
            Card(
                title: LocalizedText(fr: "Taux de masse grasse", en: "Body fat percentage", es: "Porcentaje de grasa")[language],
                subtitle: LocalizedText(fr: "Facultatif. Si tu le connais, le coach passe sur des formules plus précises (Katch-McArdle) et calcule tes protéines sur la masse maigre.", en: "Optional. If you know it, the coach switches to more precise formulas (Katch-McArdle) and computes your protein from lean mass.", es: "Opcional. Si lo conoces, el entrenador usa fórmulas más precisas (Katch-McArdle) y calcula tus proteínas sobre la masa magra.")[language]
            ) {
                Toggle(LocalizedText(fr: "Je connais mon taux", en: "I know my percentage", es: "Conozco mi porcentaje")[language], isOn: $draft.knowsBodyFat)
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
                        display: LocalizedText(fr: "Tour de taille : \(Format.height(draft.waistCm, unit: draft.unit))", en: "Waist: \(Format.height(draft.waistCm, unit: draft.unit))", es: "Cintura: \(Format.height(draft.waistCm, unit: draft.unit))")[language]
                    )
                }
            }
        }
    }

    private var experienceStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: LocalizedText(fr: "Depuis combien de temps tu t'entraînes sérieusement ?", en: "How long have you been training seriously?", es: "¿Desde cuándo entrenas en serio?")[language],
                subtitle: LocalizedText(fr: "« Sérieusement » veut dire régulièrement, en notant ou en suivant une progression.", en: "“Seriously” means regularly, logging or following a progression.", es: "«En serio» significa con regularidad, anotando o siguiendo una progresión.")[language]
            ) {
                SliderRow(
                    value: Binding(
                        get: { Double(draft.trainingMonths) },
                        set: { draft.trainingMonths = Int($0) }
                    ),
                    range: 0...120,
                    step: 1,
                    display: draft.trainingMonths == 0
                        ? LocalizedText(fr: "Jamais / je reprends de zéro", en: "Never / starting from scratch", es: "Nunca / empiezo de cero")[language]
                        : LocalizedText(fr: "\(draft.trainingMonths) mois", en: "\(draft.trainingMonths) months", es: "\(draft.trainingMonths) meses")[language]
                )
            }
            Card(
                title: LocalizedText(fr: "Niveau", en: "Level", es: "Nivel")[language],
                subtitle: LocalizedText(fr: "Déduit de ta réponse, mais tu peux le corriger. Il détermine ton volume de départ et la longueur de tes blocs.", en: "Inferred from your answer, but you can correct it. It sets your starting volume and the length of your blocks.", es: "Deducido de tu respuesta, pero puedes corregirlo. Determina tu volumen de partida y la duración de tus bloques.")[language]
            ) {
                Picker("", selection: Binding(
                    get: { draft.experience },
                    set: { draft.experienceOverride = $0 }
                )) {
                    ForEach(ExperienceLevel.allCases, id: \.self) { Text($0.label[language]).tag($0) }
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
            LocalizedText(fr: "Peu de séries, beaucoup de technique, et des blocs de 6 semaines. C'est le niveau où l'on progresse le plus vite en faisant le moins.", en: "Few sets, lots of technique, and 6-week blocks. It is the level where you progress fastest doing the least.", es: "Pocas series, mucha técnica y bloques de 6 semanas. Es el nivel en el que más rápido se progresa haciendo menos.")[language]
        case .intermediate:
            LocalizedText(fr: "Volume standard, progression en double progression, blocs de 5 semaines.", en: "Standard volume, double progression, 5-week blocks.", es: "Volumen estándar, doble progresión, bloques de 5 semanas.")[language]
        case .advanced:
            LocalizedText(fr: "Volume élevé, blocs courts de 4 semaines, décharges plus fréquentes : la récupération devient le facteur limitant.", en: "High volume, short 4-week blocks, more frequent deloads: recovery becomes the limiting factor.", es: "Volumen alto, bloques cortos de 4 semanas, descargas más frecuentes: la recuperación pasa a ser el factor limitante.")[language]
        }
    }

    private var goalStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: LocalizedText(fr: "Qu'est-ce que tu veux, précisément ?", en: "What do you want, precisely?", es: "¿Qué quieres, exactamente?")[language]) {
                VStack(spacing: 8) {
                    ForEach(PrimaryGoal.allCases, id: \.self) { goal in
                        SelectableRow(
                            title: goal.label[language],
                            subtitle: goalSubtitle(goal),
                            isSelected: draft.goal == goal
                        ) {
                            draft.goal = goal
                            if !draft.hasTargetWeight { draft.targetWeightKg = draft.weightKg }
                        }
                    }
                }
            }
            Card(title: LocalizedText(fr: "Poids visé", en: "Target weight", es: "Peso objetivo")[language], subtitle: LocalizedText(fr: "Facultatif. Sert à estimer combien de semaines il te faut au rythme prescrit.", en: "Optional. Used to estimate how many weeks you need at the prescribed pace.", es: "Opcional. Sirve para estimar cuántas semanas necesitas al ritmo prescrito.")[language]) {
                Toggle(LocalizedText(fr: "J'ai un poids cible", en: "I have a target weight", es: "Tengo un peso objetivo")[language], isOn: $draft.hasTargetWeight)
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
                Toggle(LocalizedText(fr: "J'ai une échéance", en: "I have a deadline", es: "Tengo una fecha límite")[language], isOn: $draft.hasDeadline)
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
        case .hypertrophy: LocalizedText(fr: "Séries de 6 à 12, léger surplus calorique, volume maximal que tu peux récupérer.", en: "Sets of 6 to 12, slight calorie surplus, the most volume you can recover from.", es: "Series de 6 a 12, ligero superávit calórico, el máximo volumen que puedas recuperar.")[language]
        case .strength: LocalizedText(fr: "Séries de 3 à 6, repos longs, moins de séries mais plus lourdes.", en: "Sets of 3 to 6, long rests, fewer but heavier sets.", es: "Series de 3 a 6, descansos largos, menos series pero más pesadas.")[language]
        case .fatLoss: LocalizedText(fr: "Déficit mesuré, protéines hautes, volume adapté à une récupération réduite.", en: "Measured deficit, high protein, volume adapted to reduced recovery.", es: "Déficit medido, proteínas altas, volumen adaptado a una recuperación reducida.")[language]
        case .recomposition: LocalizedText(fr: "Calories de maintien, protéines très hautes : progresser en salle sans bouger sur la balance.", en: "Maintenance calories, very high protein: progress in the gym without moving the scale.", es: "Calorías de mantenimiento, proteínas muy altas: progresar en el gimnasio sin mover la báscula.")[language]
        case .generalHealth: LocalizedText(fr: "Deux à trois séances complètes, intensité modérée, zéro prise de tête.", en: "Two to three full-body sessions, moderate intensity, zero fuss.", es: "Dos o tres sesiones completas, intensidad moderada, cero complicaciones.")[language]
        }
    }

    private var availabilityStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: LocalizedText(fr: "Combien de séances par semaine ?", en: "How many sessions per week?", es: "¿Cuántas sesiones por semana?")[language],
                subtitle: LocalizedText(fr: "Réponds avec ce que tu tiendras un mois de suite, pas avec ce que tu voudrais tenir.", en: "Answer with what you will keep up for a month straight, not what you would like to.", es: "Responde con lo que mantendrás un mes seguido, no con lo que te gustaría mantener.")[language]
            ) {
                Picker("", selection: $draft.daysPerWeek) {
                    ForEach(2...7, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)

                Text(SplitPlanner.split(for: previewProfile).rationale[language])
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Card(
                title: LocalizedText(fr: "Combien de temps par séance ?", en: "How long per session?", es: "¿Cuánto tiempo por sesión?")[language],
                subtitle: LocalizedText(fr: "Échauffement compris. Le coach ne prescrira jamais plus long que ça.", en: "Warm-up included. The coach will never prescribe longer than this.", es: "Calentamiento incluido. El entrenador nunca prescribirá más que esto.")[language]
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
            Card(title: LocalizedText(fr: "Où t'entraînes-tu ?", en: "Where do you train?", es: "¿Dónde entrenas?")[language]) {
                HStack(spacing: 8) {
                    kitButton(LocalizedText(fr: "Salle complète", en: "Full gym", es: "Gimnasio completo")[language], Equipment.fullGym)
                    kitButton(LocalizedText(fr: "Maison", en: "Home", es: "Casa")[language], Equipment.homeGym)
                    kitButton(LocalizedText(fr: "Minimal", en: "Minimal", es: "Mínimo")[language], Equipment.minimal)
                }
            }
            Card(
                title: LocalizedText(fr: "Détail du matériel", en: "Equipment details", es: "Detalle del material")[language],
                subtitle: LocalizedText(fr: "Un exercice n'est proposé que si tu as tout ce qu'il demande. Mieux vaut décocher que d'improviser en salle.", en: "An exercise is only offered if you have everything it needs. Better to untick than to improvise at the gym.", es: "Un ejercicio solo se propone si tienes todo lo que requiere. Mejor desmarcar que improvisar en el gimnasio.")[language]
            ) {
                FlowSelection(
                    items: Equipment.allCases,
                    label: { $0.label[language] },
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
                title: LocalizedText(fr: "Plus petit incrément de charge", en: "Smallest load increment", es: "Incremento de carga mínimo")[language],
                subtitle: LocalizedText(fr: "Les charges suggérées sont arrondies à ce que tu peux vraiment charger.", en: "Suggested loads are rounded to what you can actually load.", es: "Las cargas sugeridas se redondean a lo que realmente puedes cargar.")[language]
            ) {
                Picker("", selection: $draft.loadIncrement) {
                    ForEach(LoadIncrement.allCases, id: \.self) { Text($0.label[language]).tag($0) }
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
                title: LocalizedText(fr: "Une zone qui te fait mal ?", en: "An area that hurts?", es: "¿Alguna zona que te duela?")[language],
                subtitle: LocalizedText(fr: "Tout exercice qui sollicite directement une zone cochée est retiré du catalogue. Rien ne sera « adapté » : il sera remplacé.", en: "Any exercise that directly loads a ticked area is removed from the catalogue. Nothing will be “adapted”: it will be replaced.", es: "Todo ejercicio que solicite directamente una zona marcada se retira del catálogo. Nada se «adapta»: se sustituye.")[language]
            ) {
                FlowSelection(
                    items: Limitation.allCases,
                    label: { $0.label[language] },
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
                    Text(LocalizedText(fr: "Une douleur qui dure n'est pas un problème de programmation. Cette application ne remplace pas un médecin ou un kinésithérapeute.", en: "A pain that lasts is not a programming problem. This app does not replace a doctor or a physiotherapist.", es: "Un dolor que dura no es un problema de programación. Esta aplicación no sustituye a un médico ni a un fisioterapeuta.")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var lifestyleStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(title: LocalizedText(fr: "Activité en dehors des séances", en: "Activity outside sessions", es: "Actividad fuera de las sesiones")[language], subtitle: LocalizedText(fr: "Détermine ta dépense énergétique, donc tes calories.", en: "Sets your energy expenditure, hence your calories.", es: "Determina tu gasto energético, y por tanto tus calorías.")[language]) {
                Picker("", selection: $draft.activityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { Text($0.label[language]).tag($0) }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }
            Card(title: LocalizedText(fr: "Sommeil moyen", en: "Average sleep", es: "Sueño medio")[language], subtitle: LocalizedText(fr: "En dessous de 6 h, le coach réduit le volume : sinon tu accumules de la fatigue sans progresser.", en: "Below 6 h, the coach reduces volume: otherwise you accumulate fatigue without progressing.", es: "Por debajo de 6 h, el entrenador reduce el volumen: si no, acumulas fatiga sin progresar.")[language]) {
                SliderRow(
                    value: $draft.sleepHours,
                    range: 4...10,
                    step: 0.5,
                    display: "\(Format.number(draft.sleepHours, decimals: 1)) h"
                )
            }
            Card(title: LocalizedText(fr: "Niveau de stress habituel", en: "Usual stress level", es: "Nivel de estrés habitual")[language], subtitle: LocalizedText(fr: "1 = serein, 5 = sous l'eau. Le stress chronique coûte de la récupération.", en: "1 = calm, 5 = underwater. Chronic stress costs recovery.", es: "1 = tranquilo, 5 = desbordado. El estrés crónico cuesta recuperación.")[language]) {
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
            Card(title: LocalizedText(fr: "Alimentation", en: "Food", es: "Alimentación")[language], subtitle: LocalizedText(fr: "N'affecte pas les chiffres, seulement les conseils de répartition.", en: "Does not change the numbers, only the distribution advice.", es: "No afecta a las cifras, solo a los consejos de reparto.")[language]) {
                Picker("", selection: $draft.dietPreference) {
                    ForEach(DietPreference.allCases, id: \.self) { Text($0.label[language]).tag($0) }
                }
                .pickerStyle(.menu)
                .tint(Theme.accent)
            }
        }
    }

    private var baselinesStep: some View {
        VStack(spacing: Theme.stackSpacing) {
            Card(
                title: LocalizedText(fr: "Tes maximums, si tu les connais", en: "Your maxes, if you know them", es: "Tus máximos, si los conoces")[language],
                subtitle: LocalizedText(fr: "Facultatif : sans ces valeurs, le coach part des repères de force pour ton poids, ton sexe et ton niveau, puis corrige dès la première séance.", en: "Optional: without them, the coach starts from strength benchmarks for your weight, sex and level, then corrects from the first session.", es: "Opcional: sin estos valores, el entrenador parte de referencias de fuerza para tu peso, sexo y nivel, y corrige desde la primera sesión.")[language]
            ) {
                VStack(spacing: 10) {
                    ForEach(ProfileDraft.baselineLiftIDs, id: \.self) { id in
                        if let exercise = ExerciseCatalog.exercise(id: id) {
                            OneRepMaxRow(
                                name: exercise.name[language],
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
            Card(title: LocalizedText(fr: "Ce que le coach a décidé", en: "What the coach decided", es: "Lo que decidió el entrenador")[language], subtitle: program.plan.split.label[language]) {
                HStack(spacing: 12) {
                    StatTile(value: "\(program.plan.weekCount)", label: LocalizedText(fr: "semaines dans le bloc", en: "weeks in the block", es: "semanas en el bloque")[language])
                    StatTile(value: "\(previewProfile.daysPerWeek)", label: LocalizedText(fr: "séances par semaine", en: "sessions per week", es: "sesiones por semana")[language])
                    StatTile(value: "\(program.plan.weeks[0].totalSets)", label: LocalizedText(fr: "séries la 1re semaine", en: "sets in week 1", es: "series la 1.ª semana")[language])
                }
            }
            Card(title: LocalizedText(fr: "Tes cibles quotidiennes", en: "Your daily targets", es: "Tus objetivos diarios")[language]) {
                HStack(spacing: 12) {
                    StatTile(value: "\(program.nutrition.calories)", label: "kcal")
                    StatTile(value: "\(program.nutrition.proteinG) g", label: LocalizedText(fr: "protéines", en: "protein", es: "proteína")[language])
                    StatTile(value: "\(program.nutrition.carbsG) g", label: LocalizedText(fr: "glucides", en: "carbs", es: "hidratos")[language])
                    StatTile(value: "\(program.nutrition.fatG) g", label: LocalizedText(fr: "lipides", en: "fat", es: "grasas")[language])
                }
                if let weeks = program.weeksToGoal {
                    Text(LocalizedText(fr: "Au rythme prescrit, ton poids cible est atteignable en environ \(weeks) semaines.", en: "At the prescribed pace, your target weight is reachable in about \(weeks) weeks.", es: "Al ritmo prescrito, tu peso objetivo es alcanzable en unas \(weeks) semanas.")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.accent)
                }
            }
            Card(title: LocalizedText(fr: "Pourquoi ce plan et pas un autre", en: "Why this plan and not another", es: "Por qué este plan y no otro")[language]) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(program.plan.rationale.enumerated()), id: \.offset) { _, line in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Theme.accent)
                                .frame(width: 5, height: 5)
                                .padding(.top, 7)
                            Text(line[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            Card(title: LocalizedText(fr: "Ta première séance", en: "Your first session", es: "Tu primera sesión")[language]) {
                if let first = program.plan.weeks.first?.sessions.first {
                    SessionSummary(session: first, unit: draft.unit, owned: draft.equipment)
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
