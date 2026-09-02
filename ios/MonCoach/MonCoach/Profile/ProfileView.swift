import SwiftUI

import MonCoachKit

/// Everything the athlete told the coach, editable, plus what the coach
/// derived from it.
struct ProfileView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    @State private var showingEditor = false
    @State private var showingResetConfirmation = false
    @State private var showingPaywall = false
    @State private var showingBenefits = false
    @State private var exportedURL: URL?
    /// Le type de matériel en cours d'ajout — c'est lui qui ouvre la boîte
    /// de saisie du nom. Nil quand rien ne s'ajoute.
    @State private var addingGearKind: Gear.Kind?
    @State private var newGearName = ""

    /// La porte vers ce que l'application apporte, et ce qu'elle refuse de
    /// faire.
    ///
    /// Dans le profil parce que c'est l'écran où l'on vient se demander « à
    /// quoi ça sert au juste » — juste au-dessus de l'abonnement, où la
    /// question devient chère.
    private var benefitsCard: some View {
        Button {
            showingBenefits = true
        } label: {
            Card {
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(
                            LocalizedText(
                                fr: "Ce que ça t'apporte",
                                en: "What it brings you",
                                es: "Lo que te aporta"
                            )[language]
                        )
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                        Text(
                            LocalizedText(
                                fr: "Chaque promesse, et le mécanisme qui la rend vraie.",
                                en: "Every promise, and the mechanism that makes it true.",
                                es: "Cada promesa, y el mecanismo que la hace cierta."
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let profile = store.profile, let program = store.program {
                        identityCard(profile).appears(0)
                        derivedCard(program).appears(1)
                        trainingCard(profile).appears(2)
                        constraintsCard(profile).appears(3)
                        preferencesCard(profile).appears(4)
                        runningCard(profile).appears(5)
                        benefitsCard.appears(6)
                        subscriptionCard.appears(7)
                        refusedFoodsCard.appears(8)
                        gearCard.appears(9)
                        dataCard.appears(10)
                        creditFooter.appears(11)
                    } else {
                        Card(title: "Profil vide") { EmptyView() }.appears(0)
                    }
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle("Profil")
            .sectionGuide(.profile)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Modifier") { showingEditor = true }
                        .disabled(store.profile == nil)
                }
            }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .sheet(isPresented: $showingBenefits) { BenefitsView() }
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

    /// L'état de l'abonnement, et la porte pour le prendre ou le gérer.
    ///
    /// Dans le profil et pas ailleurs : c'est là qu'on va chercher ce genre
    /// de chose, et un écran qui vendrait depuis l'accueil tous les jours
    /// finirait par ne plus être ouvert du tout.
    @ViewBuilder
    private var subscriptionCard: some View {
        let status = store.subscription
        let daysLeft = status.trialDaysLeft()
        Card(
            title: "Stride+",
            subtitle: status.isSubscribed
                ? "Abonnement actif. Merci — c'est ce qui paie le développement."
                : daysLeft > 0
                    ? "Essai en cours : \(daysLeft) jour\(daysLeft > 1 ? "s" : "") restant\(daysLeft > 1 ? "s" : ""). Tout est ouvert."
                    : "Essai terminé. Ton historique, ton bloc en cours et tes repas continuent."
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if status.isSubscribed {
                    Text(AlwaysFree.hostageClause[language])
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    // La résiliation passe par Apple : lui proposer un
                    // chemin ailleurs serait l'envoyer dans le mur.
                    Link(destination: URL(string: "https://apps.apple.com/account/subscriptions")!) {
                        Text("Gérer l'abonnement")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.accent)
                    }
                } else {
                    GhostButton(title: "Voir Stride+", systemImage: "sparkles") {
                        showingPaywall = true
                    }
                }
            }
        }
    }

    /// Les aliments écartés des repas, et de quoi se dédire.
    ///
    /// Le refus se déclare devant l'assiette, là où il naît. Mais se dédire
    /// depuis l'assiette suppose que l'aliment y revienne — or il n'y revient
    /// justement plus. Sans cette liste, un refus serait sans retour.
    @ViewBuilder
    private var refusedFoodsCard: some View {
        let refused = (store.profile?.excludedFoods ?? [])
            .compactMap { FoodCatalog.food(id: $0) }
            .sorted { $0.name[language] < $1.name[language] }
        if !refused.isEmpty {
            Card(
                title: LocalizedText(
                    fr: "Ce que tu n'aimes pas",
                    en: "What you don't like",
                    es: "Lo que no te gusta"
                )[language],
                subtitle: LocalizedText(
                    fr: "Ces aliments ne sont plus servis ni mis sur ta liste de courses. Les goûts changent : un appui les remet au menu.",
                    en: "These foods are no longer served or put on your shopping list. Tastes change: one tap puts them back.",
                    es: "Estos alimentos ya no se sirven ni aparecen en tu lista. Los gustos cambian: un toque los devuelve."
                )[language]
            ) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(refused) { food in
                        HStack(spacing: 10) {
                            Text(food.name[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Button {
                                store.allowFood(food.id)
                            } label: {
                                Text(
                                    LocalizedText(
                                        fr: "Remettre",
                                        en: "Put back",
                                        es: "Devolver"
                                    )[language]
                                )
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Theme.accent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    /// Les chaussures et les vélos, avec leur kilométrage vécu.
    ///
    /// Le kilométrage n'est stocké nulle part : il se recalcule depuis les
    /// sorties qui portent le matériel, donc il ne peut pas mentir. Des
    /// chaussures au-delà de 650 km sont signalées — la mousse rend l'âme
    /// avant la semelle, et les douleurs arrivent avant qu'on y pense.
    private var gearCard: some View {
        Card(
            title: LocalizedText(fr: "Chaussures et vélos", en: "Shoes and bikes", es: "Zapatillas y bicis")[language],
            subtitle: LocalizedText(
                fr: "Chaque sortie prend le dernier matériel utilisé, et se corrige depuis sa fiche.",
                en: "Every activity takes the last gear used, and can be fixed from its page.",
                es: "Cada salida toma el último material usado, y se corrige desde su ficha."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                let active = store.history.gear.filter { !$0.isRetired }
                if active.isEmpty {
                    CoachText(
                        LocalizedText(
                            fr: "Ajoute tes chaussures : l'application comptera leurs kilomètres et te dira quand les changer.",
                            en: "Add your shoes: the app will count their kilometres and tell you when to replace them.",
                            es: "Añade tus zapatillas: la aplicación contará sus kilómetros y te dirá cuándo cambiarlas."
                        )
                    )
                }
                ForEach(active) { gear in
                    gearRow(gear)
                }

                HStack(spacing: 10) {
                    GhostButton(
                        title: LocalizedText(fr: "+ Chaussures", en: "+ Shoes", es: "+ Zapatillas")[language]
                    ) {
                        newGearName = ""
                        addingGearKind = .shoes
                    }
                    GhostButton(
                        title: LocalizedText(fr: "+ Vélo", en: "+ Bike", es: "+ Bici")[language]
                    ) {
                        newGearName = ""
                        addingGearKind = .bike
                    }
                }
            }
        }
        .alert(
            LocalizedText(fr: "Un nom pour ce matériel", en: "A name for this gear", es: "Un nombre para este material")[language],
            isPresented: Binding(
                get: { addingGearKind != nil },
                set: { if !$0 { addingGearKind = nil } }
            )
        ) {
            TextField(
                LocalizedText(fr: "Pegasus 41, Gravel…", en: "Pegasus 41, Gravel…", es: "Pegasus 41, Gravel…")[language],
                text: $newGearName
            )
            Button(LocalizedText(fr: "Ajouter", en: "Add", es: "Añadir")[language]) {
                let trimmed = newGearName.trimmingCharacters(in: .whitespaces)
                if let kind = addingGearKind, !trimmed.isEmpty {
                    store.addGear(name: trimmed, kind: kind)
                }
                addingGearKind = nil
            }
            Button(UI.cancel[language], role: .cancel) { addingGearKind = nil }
        }
    }

    private func gearRow(_ gear: Gear) -> some View {
        let meters = GearTracker.meters(for: gear.id, in: store.history.activities)
        let worn = GearTracker.isWorn(gear, in: store.history.activities)
        return HStack(alignment: .center, spacing: 12) {
            Image(systemName: gear.kind == .bike ? "bicycle" : "shoe.2")
                .font(.system(size: 15))
                .foregroundStyle(worn ? Theme.warning : Theme.accent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(gear.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                Text(
                    worn
                        ? LocalizedText(
                            fr: "\(Format.distance(meters: meters, unit: store.profile?.unit ?? .metric, language: language)) — usées, pense à les remplacer",
                            en: "\(Format.distance(meters: meters, unit: store.profile?.unit ?? .metric, language: language)) — worn out, think about replacing them",
                            es: "\(Format.distance(meters: meters, unit: store.profile?.unit ?? .metric, language: language)) — gastadas, piensa en cambiarlas"
                        )[language]
                        : Format.distance(meters: meters, unit: store.profile?.unit ?? .metric, language: language)
                )
                .font(Theme.captionFont)
                .foregroundStyle(worn ? Theme.warning : Theme.secondaryText)
            }
            Spacer()
            Menu {
                Button(
                    LocalizedText(fr: "Mettre à la retraite", en: "Retire", es: "Retirar")[language],
                    role: .destructive
                ) {
                    store.retireGear(gear.id)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(Theme.secondaryText)
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
                    SettingRow(
                        label: LocalizedText(fr: "Objectif", en: "Goal", es: "Objetivo")[language]
                    ) {
                        Picker("", selection: runningGoalBinding) {
                            ForEach(RunningGoal.allCases, id: \.self) { goal in
                                Text(goal.label[language]).tag(goal)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .tint(Theme.accent)
                    }

                    SettingRow(
                        label: LocalizedText(
                            fr: "Kilométrage actuel",
                            en: "Current mileage",
                            es: "Kilometraje actual"
                        )[language]
                    ) {
                        Picker("", selection: weeklyMetersBinding) {
                            ForEach(weeklyMeterOptions, id: \.self) { meters in
                                Text(Format.distance(meters: meters, unit: profile.unit, language: language))
                                    .tag(meters)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.menu)
                        .tint(Theme.accent)
                    }

                    Stepper(value: runsPerWeekBinding, in: 1...6) {
                        Text(
                            LocalizedText(
                                fr: running.runsPerWeek == 1
                                    ? "1 sortie par semaine"
                                    : "\(running.runsPerWeek) sorties par semaine",
                                en: running.runsPerWeek == 1
                                    ? "1 run a week"
                                    : "\(running.runsPerWeek) runs a week",
                                es: running.runsPerWeek == 1
                                    ? "1 rodaje por semana"
                                    : "\(running.runsPerWeek) rodajes por semana"
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

    /// Les paliers de kilométrage hebdomadaire proposés.
    ///
    /// Une liste plutôt qu'un pas à pas : personne ne connaît son volume au
    /// kilomètre près, et aller de 15 à 40 par pas de un coûterait vingt-cinq
    /// appuis. Les paliers sont ronds dans l'unité de l'athlète — les dériver
    /// d'une seule liste par conversion donnerait « 24,14 km » à un coureur
    /// métrique, ou « 9,32 mi » à l'autre.
    private var weeklyMeterPresets: [Double] {
        switch store.profile?.unit ?? .metric {
        case .metric:
            let kilometres: [Double] = [0, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 80, 100]
            return kilometres.map { $0 * 1_000 }
        case .imperial:
            let miles: [Double] = [0, 3, 6, 9, 12, 15, 20, 25, 30, 40, 50, 60]
            return miles.map { $0 * 1_609.344 }
        }
    }

    /// Les paliers, plus la valeur enregistrée si elle n'en est pas un.
    ///
    /// Un menu SwiftUI dont la sélection ne figure pas parmi ses options
    /// s'affiche vide. Une valeur venue d'ailleurs — un changement d'unité,
    /// une version antérieure — disparaîtrait donc de l'écran tout en
    /// continuant de gouverner le plan.
    private var weeklyMeterOptions: [Double] {
        let current = store.profile?.running?.currentWeeklyMeters ?? 0
        var options = weeklyMeterPresets
        if !options.contains(where: { abs($0 - current) < 1 }) {
            options.append(current)
            options.sort()
        }
        return options
    }

    /// Le volume hebdomadaire actuel, sur lequel tout le plan de course
    /// s'appuie : l'allure prescrite, la charge de départ et la progression.
    private var weeklyMetersBinding: Binding<Double> {
        Binding(
            get: { store.profile?.running?.currentWeeklyMeters ?? 15_000 },
            set: { newValue in
                guard var profile = store.profile, var running = profile.running else { return }
                running.currentWeeklyMeters = max(0, newValue)
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
        VStack(spacing: 10) {
            Text("Stride — conçu et développé par Maxime Nathan Lestage")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            // Les notices des composants embarqués. Les licences BSD et ODbL
            // exigent que la notice accompagne la distribution — un binaire
            // n'a pas de fichier LICENSE à côté de lui, alors elle vit ici.
            Text(licencesText[language])
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText.opacity(0.8))
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 4)
    }

    private var licencesText: LocalizedText {
        LocalizedText(
            fr: "Cartes : MapLibre Native, licence BSD, © MapLibre contributors. Fond de carte © OpenStreetMap contributors, licence ODbL.",
            en: "Maps: MapLibre Native, BSD licence, © MapLibre contributors. Map data © OpenStreetMap contributors, ODbL licence.",
            es: "Mapas: MapLibre Native, licencia BSD, © MapLibre contributors. Datos de mapa © OpenStreetMap contributors, licencia ODbL."
        )
    }

    private func writeExport() -> URL? {
        guard let data = try? store.exportJSON() else { return nil }
        let url = URL.temporaryDirectory.appending(path: "mon-coach-export.json")
        try? data.write(to: url, options: [.atomic])
        return url
    }
}

/// Label on the left, value on the right — the whole profile screen is these.
/// Une ligne de réglage : le nom à gauche, le contrôle à droite.
///
/// La version modifiable de `LabeledRow`, dont elle reprend la géométrie. Un
/// menu SwiftUI posé seul dans une pile n'affiche que sa valeur, jamais ce
/// dont elle est la valeur : « 15,0 km » sans « Kilométrage actuel » à côté
/// ne veut rien dire.
struct SettingRow<Control: View>: View {
    var label: String
    @ViewBuilder var control: Control

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
            Spacer(minLength: 12)
            control
        }
    }
}

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
