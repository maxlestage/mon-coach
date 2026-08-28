import SwiftUI

import MonCoachKit

/// Everything the athlete told the coach, editable, plus what the coach
/// derived from it.
struct ProfileView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    @State private var showingEditor = false
    @State private var showingResetConfirmation = false
    @State private var exportedURL: URL?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let profile = store.profile, let program = store.program {
                        identityCard(profile)
                        derivedCard(program)
                        trainingCard(profile)
                        constraintsCard(profile)
                        preferencesCard(profile)
                        runningCard(profile)
                        dataCard
                        creditFooter
                    } else {
                        Card(title: "Profil vide") { EmptyView() }
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Profil")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") { showingEditor = true }
                        .disabled(store.profile == nil)
                }
            }
            .sheet(isPresented: $showingEditor) {
                if let profile = store.profile {
                    ProfileEditorView(profile: profile) { updated in
                        store.updateProfile(updated)
                    }
                }
            }
            .confirmationDialog(
                "Tout effacer ?",
                isPresented: $showingResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Effacer définitivement", role: .destructive) {
                    store.resetEverything()
                }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Ton profil, ton programme et l'intégralité de ton historique d'entraînement seront supprimés de cet appareil. C'est irréversible.")
            }
        }
        .tint(Theme.accent)
    }

    private func identityCard(_ profile: UserProfile) -> some View {
        Card(title: profile.firstName, subtitle: "\(profile.age()) ans · \(profile.sex.label[language])") {
            HStack(spacing: 12) {
                StatTile(value: Format.height(profile.heightCm, unit: profile.unit), label: "taille")
                StatTile(value: Format.weight(profile.weightKg, unit: profile.unit), label: "poids")
                if let fat = profile.bodyFatPercent {
                    StatTile(value: "\(Format.number(fat, decimals: 1)) %", label: "masse grasse")
                }
            }
        }
    }

    private func derivedCard(_ program: CoachingProgram) -> some View {
        Card(title: "Ce que le coach en déduit", subtitle: program.metrics.leanMassIsEstimated
            ? "Masse maigre estimée (formule de Boer) — renseigne ton taux de gras pour affiner"
            : "Calculs basés sur ta masse maigre mesurée") {
            HStack(spacing: 12) {
                StatTile(value: "\(Int(program.metrics.bmr))", label: "métabolisme de base")
                StatTile(value: "\(Int(program.metrics.tdee))", label: "dépense quotidienne")
                StatTile(value: Format.weight(program.metrics.leanBodyMassKg, unit: program.profile.unit, decimals: 1), label: "masse maigre")
                if let ffmi = program.metrics.ffmi {
                    StatTile(value: Format.number(ffmi, decimals: 1), label: "FFMI")
                }
            }
            Text("IMC \(Format.number(program.metrics.bmi, decimals: 1)) — \(program.metrics.bmiCategory). L'IMC ignore la composition corporelle : à masse musculaire élevée, il se trompe systématiquement.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func trainingCard(_ profile: UserProfile) -> some View {
        Card(title: "Entraînement") {
            LabeledRow(label: "Objectif", value: profile.goal.label[language])
            LabeledRow(label: "Niveau", value: profile.experience.label[language])
            LabeledRow(label: "Fréquence", value: "\(profile.daysPerWeek) séances / semaine")
            LabeledRow(label: "Durée", value: Format.duration(minutes: profile.sessionMinutes))
            LabeledRow(label: "Incrément", value: profile.loadIncrement.label[language])
            LabeledRow(label: "Sommeil", value: "\(Format.number(profile.averageSleepHours, decimals: 1)) h")
            LabeledRow(label: "Activité", value: profile.activityLevel.label[language])
        }
    }

    private func constraintsCard(_ profile: UserProfile) -> some View {
        Card(title: "Matériel et contraintes") {
            VStack(alignment: .leading, spacing: 10) {
                Text("Matériel disponible")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                FlowLayout(spacing: 6) {
                    ForEach(Array(profile.equipment).sorted { $0.rawValue < $1.rawValue }, id: \.self) {
                        Pill(text: $0.label[language])
                    }
                }
                if !profile.limitations.isEmpty {
                    Text("Zones épargnées")
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .padding(.top, 4)
                    FlowLayout(spacing: 6) {
                        ForEach(Array(profile.limitations).sorted { $0.rawValue < $1.rawValue }, id: \.self) {
                            Pill(text: $0.label[language], tint: Theme.warning)
                        }
                    }
                }
            }
        }
    }

    private var dataCard: some View {
        Card(title: "Tes données", subtitle: "Tout est stocké sur cet appareil. Rien n'est envoyé nulle part.") {
            if let exportedURL {
                ShareLink(item: exportedURL) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Partager l'export")
                    }
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.primaryText)
                }
            } else {
                GhostButton(title: "Exporter mes données (JSON)", systemImage: "square.and.arrow.up") {
                    exportedURL = writeExport()
                }
            }
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                Text("Tout effacer")
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.danger.opacity(0.15), in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.danger)
            }
            .buttonStyle(.plain)

            if let error = store.saveError?[language] {
                Text(error)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.danger)
            }
        }
    }

    /// Langue et fond de carte : les deux réglages qui ne se déduisent pas
    /// du corps de l'athlète.
    private func preferencesCard(_ profile: UserProfile) -> some View {
        Card(title: LocalizedText(fr: "Préférences", en: "Preferences", es: "Preferencias")[language]) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(UI.language[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    Picker(UI.language[language], selection: languageBinding) {
                        Text(UI.systemLanguage[language]).tag(Language?.none)
                        ForEach(Language.allCases) { option in
                            Text(option.endonym).tag(Language?.some(option))
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Toggle(isOn: mapTilesBinding) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(LocalizedText(fr: "Fond de carte", en: "Map background", es: "Fondo de mapa")[language])
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.primaryText)
                        CoachText(
                            LocalizedText(
                                fr: "Les cartes de tes sorties chargent des tuiles OpenStreetMap. C'est la seule chose, dans toute l'application, qui contacte un serveur. Désactive-le et tu gardes ton tracé, dessiné sur le téléphone à partir de tes propres points.",
                                en: "Your run maps load OpenStreetMap tiles. It is the only thing in the whole app that contacts a server. Turn it off and you keep your route, drawn on the phone from your own points.",
                                es: "Los mapas de tus rodajes cargan teselas de OpenStreetMap. Es lo único en toda la aplicación que contacta con un servidor. Desactívalo y conservas tu traza, dibujada en el teléfono con tus propios puntos."
                            ),
                            font: .system(size: 11)
                        )
                    }
                }
                .tint(Theme.accent)
            }
        }
    }

    /// La course : présente si l'athlète court, proposée sinon.
    private func runningCard(_ profile: UserProfile) -> some View {
        Card(title: UI.running[language]) {
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: runsBinding) {
                    Text(
                        LocalizedText(
                            fr: "Je cours aussi",
                            en: "I run as well",
                            es: "También corro"
                        )[language]
                    )
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.primaryText)
                }
                .tint(Theme.accent)

                if let running = profile.running {
                    LabeledRow(
                        label: LocalizedText(fr: "Objectif", en: "Goal", es: "Objetivo")[language],
                        value: running.goal.label[language]
                    )
                    LabeledRow(
                        label: LocalizedText(fr: "Sorties par semaine", en: "Runs per week", es: "Rodajes por semana")[language],
                        value: "\(running.runsPerWeek)"
                    )
                    LabeledRow(
                        label: LocalizedText(fr: "Kilométrage actuel", en: "Current mileage", es: "Kilometraje actual")[language],
                        value: Format.distance(meters: running.currentWeeklyMeters, unit: profile.unit, language: language)
                    )
                    Picker(
                        LocalizedText(fr: "Objectif", en: "Goal", es: "Objetivo")[language],
                        selection: runningGoalBinding
                    ) {
                        ForEach(RunningGoal.allCases, id: \.self) { goal in
                            Text(goal.label[language]).tag(goal)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(Theme.accent)

                    Stepper(value: runsPerWeekBinding, in: 1...6) {
                        Text(
                            LocalizedText(
                                fr: "\(running.runsPerWeek) sorties par semaine",
                                en: "\(running.runsPerWeek) runs a week",
                                es: "\(running.runsPerWeek) rodajes por semana"
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }

    // MARK: - Liaisons

    private var languageBinding: Binding<Language?> {
        Binding(
            get: { store.profile?.language },
            set: { store.setLanguage($0) }
        )
    }

    private var mapTilesBinding: Binding<Bool> {
        Binding(
            get: { store.profile?.loadsMapTiles ?? true },
            set: { newValue in
                guard var profile = store.profile else { return }
                profile.mapTiles = newValue
                store.updateProfile(profile)
            }
        )
    }

    private var runsBinding: Binding<Bool> {
        Binding(
            get: { store.profile?.runs ?? false },
            set: { newValue in
                guard var profile = store.profile else { return }
                // Désactiver la course efface le profil de coureur : garder un
                // objectif fantôme ferait réapparaître un plan que l'athlète
                // a explicitement rangé.
                profile.running = newValue ? RunningProfile() : nil
                store.updateProfile(profile)
            }
        )
    }

    private var runningGoalBinding: Binding<RunningGoal> {
        Binding(
            get: { store.profile?.running?.goal ?? .endurance },
            set: { newValue in
                guard var profile = store.profile, var running = profile.running else { return }
                running.goal = newValue
                profile.running = running
                store.updateProfile(profile)
            }
        )
    }

    private var runsPerWeekBinding: Binding<Int> {
        Binding(
            get: { store.profile?.running?.runsPerWeek ?? 3 },
            set: { newValue in
                guard var profile = store.profile, var running = profile.running else { return }
                running.runsPerWeek = newValue
                profile.running = running
                store.updateProfile(profile)
            }
        )
    }

    private var creditFooter: some View {
        Text("Mon Coach — conçu et développé par Maxime Nathan Lestage")
            .font(Theme.captionFont)
            .foregroundStyle(Theme.secondaryText)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
            .padding(.top, 4)
    }

    private func writeExport() -> URL? {
        guard let data = try? store.exportJSON() else { return nil }
        let url = URL.temporaryDirectory.appending(path: "mon-coach-export.json")
        try? data.write(to: url, options: [.atomic])
        return url
    }
}

/// Label on the left, value on the right — the whole profile screen is these.
struct LabeledRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 12)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.trailing)
        }
    }
}
