import SwiftUI

import MonCoachKit

/// Everything the athlete told the coach, editable, plus what the coach
/// derived from it.
struct ProfileView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    @State private var showingEditor = false
    /// Le système a-t-il refusé les notifications ? Relu à chaque affichage :
    /// l'autorisation se retire dans les réglages d'iOS sans prévenir.
    @State private var notificationsRefused = false
    /// Le résultat du dernier import : ce qui a été pris, ou rien.
    @State private var healthOutcome: LocalizedText?
    @State private var importingHealth = false
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

    /// Vrai quand l'écran est poussé depuis un autre : la barre du haut a
    /// déjà sa pile, en ajouter une seconde empile deux bandeaux.
    var embedded = false

    var body: some View {
        Group {
            if embedded { content } else { NavigationStack { content } }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if let profile = store.profile, let program = store.program {
                    identityCard(profile).appears(0)
                    derivedCard(program).appears(1)
                    trainingCard(profile).appears(2)
                    constraintsCard(profile).appears(3)
                    preferencesCard(profile).appears(4)
                    remindersCard.appears(5)
                    healthCard.appears(6)
                    cycleCard.appears(7)
                    runningCard(profile).appears(8)
                    benefitsCard.appears(9)
                    subscriptionCard.appears(10)
                    refusedFoodsCard.appears(11)
                    gearCard.appears(12)
                    dataCard.appears(13)
                    creditFooter.appears(14)
                } else {
                    Card(title: LocalizedText(fr: "Profil vide", en: "Empty profile", es: "Perfil vacío")[language]) { EmptyView() }.appears(0)
                }
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle(UI.profile[language])
        .sectionGuide(.profile)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(LocalizedText(fr: "Modifier", en: "Edit", es: "Editar")[language]) { showingEditor = true }
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
            LocalizedText(fr: "Tout effacer ?", en: "Erase everything?", es: "¿Borrar todo?")[language],
            isPresented: $showingResetConfirmation,
            titleVisibility: .visible
        ) {
            Button(LocalizedText(fr: "Effacer définitivement", en: "Erase permanently", es: "Borrar definitivamente")[language], role: .destructive) {
                store.resetEverything()
            }
            Button(UI.cancel[language], role: .cancel) {}
        } message: {
            Text(LocalizedText(fr: "Ton profil, ton programme et l'intégralité de ton historique d'entraînement seront supprimés de cet appareil. C'est irréversible.", en: "Your profile, your programme and your entire training history will be deleted from this device. This cannot be undone.", es: "Tu perfil, tu programa y todo tu historial de entrenamiento se borrarán de este dispositivo. Es irreversible.")[language])
        }
        // Poussé depuis « Aujourd'hui », le titre reste dans la barre :
        // un grand titre par-dessus un bouton de retour fait deux
        // étages pour dire une seule chose.
        .navigationBarTitleDisplayMode(embedded ? .inline : .large)
        .tint(Theme.accent)
    }

    private func identityCard(_ profile: UserProfile) -> some View {
        Card(title: profile.firstName, subtitle: LocalizedText(fr: "\(profile.age()) ans · \(profile.sex.label[.french])", en: "\(profile.age()) years old · \(profile.sex.label[.english])", es: "\(profile.age()) años · \(profile.sex.label[.spanish])")[language]) {
            HStack(spacing: 12) {
                StatTile(value: Format.height(profile.heightCm, unit: profile.unit), label: LocalizedText(fr: "taille", en: "height", es: "estatura")[language])
                StatTile(value: Format.weight(profile.weightKg, unit: profile.unit), label: LocalizedText(fr: "poids", en: "weight", es: "peso")[language])
                if let fat = profile.bodyFatPercent {
                    StatTile(value: "\(Format.number(fat, decimals: 1)) %", label: LocalizedText(fr: "masse grasse", en: "body fat", es: "grasa")[language])
                }
            }
        }
    }

    private func derivedCard(_ program: CoachingProgram) -> some View {
        Card(title: LocalizedText(fr: "Ce que le coach en déduit", en: "What the coach infers", es: "Lo que deduce el entrenador")[language], subtitle: program.metrics.leanMassIsEstimated
            ? LocalizedText(fr: "Masse maigre estimée (formule de Boer) — renseigne ton taux de gras pour affiner", en: "Estimated lean mass (Boer formula) — enter your body fat to refine", es: "Masa magra estimada (fórmula de Boer): indica tu grasa corporal para afinar")[language]
            : LocalizedText(fr: "Calculs basés sur ta masse maigre mesurée", en: "Calculations based on your measured lean mass", es: "Cálculos basados en tu masa magra medida")[language]) {
            HStack(spacing: 12) {
                StatTile(value: "\(Int(program.metrics.bmr))", label: LocalizedText(fr: "métabolisme", en: "metabolism", es: "metabolismo")[language])
                StatTile(value: "\(Int(program.metrics.tdee))", label: LocalizedText(fr: "dépense / jour", en: "spend / day", es: "gasto / día")[language])
                StatTile(value: Format.weight(program.metrics.leanBodyMassKg, unit: program.profile.unit, decimals: 1), label: LocalizedText(fr: "masse maigre", en: "lean mass", es: "masa magra")[language])
                if let ffmi = program.metrics.ffmi {
                    StatTile(value: Format.number(ffmi, decimals: 1), label: "FFMI")
                }
            }
            Text(LocalizedText(fr: "IMC \(Format.number(program.metrics.bmi, decimals: 1)) — \(program.metrics.bmiCategory). L'IMC ignore la composition corporelle : à masse musculaire élevée, il se trompe systématiquement.", en: "BMI \(Format.number(program.metrics.bmi, decimals: 1)) — \(program.metrics.bmiCategory). BMI ignores body composition: with high muscle mass it is systematically wrong.", es: "IMC \(Format.number(program.metrics.bmi, decimals: 1)) — \(program.metrics.bmiCategory). El IMC ignora la composición corporal: con mucha masa muscular se equivoca sistemáticamente.")[language])
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func trainingCard(_ profile: UserProfile) -> some View {
        Card(title: LocalizedText(fr: "Entraînement", en: "Training", es: "Entrenamiento")[language]) {
            LabeledRow(label: LocalizedText(fr: "Objectif", en: "Goal", es: "Objetivo")[language], value: profile.goal.label[language])
            LabeledRow(label: LocalizedText(fr: "Niveau", en: "Level", es: "Nivel")[language], value: profile.experience.label[language])
            LabeledRow(label: LocalizedText(fr: "Fréquence", en: "Frequency", es: "Frecuencia")[language], value: LocalizedText(fr: "\(profile.daysPerWeek) séances / semaine", en: "\(profile.daysPerWeek) sessions / week", es: "\(profile.daysPerWeek) sesiones / semana")[language])
            LabeledRow(label: LocalizedText(fr: "Durée", en: "Duration", es: "Duración")[language], value: Format.duration(minutes: profile.sessionMinutes))
            LabeledRow(label: LocalizedText(fr: "Incrément", en: "Increment", es: "Incremento")[language], value: profile.loadIncrement.label[language])
            LabeledRow(label: LocalizedText(fr: "Sommeil", en: "Sleep", es: "Sueño")[language], value: "\(Format.number(profile.averageSleepHours, decimals: 1)) h")
            LabeledRow(label: LocalizedText(fr: "Activité", en: "Activity", es: "Actividad")[language], value: profile.activityLevel.label[language])
        }
    }

    private func constraintsCard(_ profile: UserProfile) -> some View {
        Card(title: LocalizedText(fr: "Matériel et contraintes", en: "Equipment and constraints", es: "Material y limitaciones")[language]) {
            VStack(alignment: .leading, spacing: 10) {
                Text(LocalizedText(fr: "Matériel disponible", en: "Available equipment", es: "Material disponible")[language])
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                FlowLayout(spacing: 6) {
                    ForEach(Array(profile.equipment).sorted { $0.rawValue < $1.rawValue }, id: \.self) {
                        Pill(text: $0.label[language])
                    }
                }
                if !profile.limitations.isEmpty {
                    Text(LocalizedText(fr: "Zones épargnées", en: "Protected areas", es: "Zonas protegidas")[language])
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
                ? LocalizedText(fr: "Abonnement actif. Merci — c'est ce qui paie le développement.", en: "Subscription active. Thank you — this is what pays for development.", es: "Suscripción activa. Gracias: es lo que paga el desarrollo.")[language]
                : daysLeft > 0
                    ? LocalizedText(fr: "Essai en cours : \(daysLeft) jour\(daysLeft > 1 ? "s" : "") restant\(daysLeft > 1 ? "s" : ""). Tout est ouvert.", en: "Trial in progress: \(daysLeft) day\(daysLeft > 1 ? "s" : "") left. Everything is open.", es: "Prueba en curso: \(daysLeft) día\(daysLeft > 1 ? "s" : "") restante\(daysLeft > 1 ? "s" : ""). Todo está abierto.")[language]
                    : LocalizedText(fr: "Essai terminé. Ton historique, ton bloc en cours et tes repas continuent.", en: "Trial over. Your history, your current block and your meals carry on.", es: "Prueba terminada. Tu historial, tu bloque en curso y tus comidas continúan.")[language]
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
                        Text(LocalizedText(fr: "Gérer l'abonnement", en: "Manage subscription", es: "Gestionar la suscripción")[language])
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
        Card(title: LocalizedText(fr: "Tes données", en: "Your data", es: "Tus datos")[language], subtitle: LocalizedText(fr: "Tout est stocké sur cet appareil. Rien n'est envoyé nulle part.", en: "Everything is stored on this device. Nothing is sent anywhere.", es: "Todo se guarda en este dispositivo. No se envía nada a ninguna parte.")[language]) {
            if let exportedURL {
                ShareLink(item: exportedURL) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(LocalizedText(fr: "Partager l'export", en: "Share the export", es: "Compartir la exportación")[language])
                    }
                    .font(.system(size: 15, weight: .medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.primaryText)
                }
            } else {
                GhostButton(title: LocalizedText(fr: "Exporter mes données (JSON)", en: "Export my data (JSON)", es: "Exportar mis datos (JSON)")[language], systemImage: "square.and.arrow.up") {
                    exportedURL = writeExport()
                }
            }
            Button(role: .destructive) {
                showingResetConfirmation = true
            } label: {
                Text(LocalizedText(fr: "Tout effacer", en: "Erase everything", es: "Borrar todo")[language])
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
                                fr: "Les cartes de tes sorties sont celles d'Apple Plans, servies par le système. C'est la seule chose, dans toute l'application, qui contacte un serveur. Désactive-le et tu gardes ton tracé, dessiné sur le téléphone à partir de tes propres points.",
                                en: "Your activity maps are Apple Maps, served by the system. It is the only thing in the whole app that contacts a server. Turn it off and you keep your route, drawn on the phone from your own points.",
                                es: "Los mapas de tus salidas son los de Apple Plans, servidos por el sistema. Es lo único en toda la aplicación que contacta con un servidor. Desactívalo y conservas tu traza, dibujada en el teléfono con tus propios puntos."
                            ),
                            font: .system(size: 11)
                        )
                    }
                }
                .tint(Theme.accent)
            }
        }
    }


    // MARK: - Rappels

    /// Ce que l'application a le droit de dire, et quand.
    ///
    /// L'interrupteur ne ment jamais : si le système a retiré l'autorisation
    /// dans ses propres réglages — ce qui arrive sans que l'application en
    /// soit prévenue — il repasse éteint et le dit. Un interrupteur allumé
    /// sur des rappels qui ne partiront pas est pire que pas de rappels du
    /// tout, parce qu'on compte dessus.
    private var remindersCard: some View {
        Card(
            title: LocalizedText(fr: "Rappels", en: "Reminders", es: "Recordatorios")[language],
            subtitle: LocalizedText(
                fr: "Un seul par jour, jamais pour quelque chose de déjà fait. Tout se décide sur le téléphone.",
                en: "One a day at most, never for something already done. Everything is decided on the phone.",
                es: "Uno al día como mucho, nunca por algo ya hecho. Todo se decide en el teléfono."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Toggle(isOn: remindersEnabledBinding) {
                    Text(LocalizedText(fr: "M'envoyer des rappels", en: "Send me reminders", es: "Enviarme recordatorios")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.primaryText)
                }
                .tint(Theme.accent)

                if notificationsRefused {
                    CoachText(
                        LocalizedText(
                            fr: "Les notifications sont refusées dans les réglages d'iOS. Tant qu'elles le restent, rien ne partira — l'interrupteur ci-dessus ne peut rien y faire.",
                            en: "Notifications are turned off in iOS settings. Nothing will be sent while they are — the switch above cannot change that.",
                            es: "Las notificaciones están desactivadas en los ajustes de iOS. Mientras lo estén, no se enviará nada; el interruptor de arriba no puede cambiarlo."
                        ),
                        font: .system(size: 11)
                    )
                }

                if store.reminders.enabled {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedText(fr: "À quelle heure", en: "At what time", es: "A qué hora")[language])
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                        DatePicker(
                            "", selection: reminderTimeBinding, displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                        .tint(Theme.accent)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(ReminderKind.allCases, id: \.self) { kind in
                            Toggle(isOn: kindBinding(kind)) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(label(for: kind)[language])
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Theme.primaryText)
                                    Text(explanation(for: kind)[language])
                                        .font(.system(size: 11))
                                        .foregroundStyle(Theme.secondaryText)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            .tint(Theme.accent)
                        }
                    }
                }
            }
        }
        .task {
            // En deux temps, et non en une expression : l'opérateur `&&`
            // évalue son côté droit dans une autoclosure, et une autoclosure
            // n'accepte pas d'`await`. Le raccourci ne compile pas — et il
            // n'était pas seulement une élégance : n'interroger le système
            // que si l'athlète a demandé des rappels évite une question
            // inutile, et cet ordre-là est conservé.
            guard store.reminders.enabled else {
                notificationsRefused = false
                return
            }
            notificationsRefused = !(await Reminders.isAllowed())
        }
    }

    private func label(for kind: ReminderKind) -> LocalizedText {
        switch kind {
        case .sessionsLeft:
            LocalizedText(fr: "La semaine qui se termine", en: "The week running out", es: "La semana que se acaba")
        case .comeBack:
            LocalizedText(fr: "Après plusieurs jours sans rien", en: "After several quiet days", es: "Tras varios días en blanco")
        case .weighIn:
            LocalizedText(fr: "La pesée", en: "The weigh-in", es: "El pesaje")
        case .readiness:
            LocalizedText(fr: "Le bilan de forme", en: "The readiness check", es: "El balance de forma")
        }
    }

    private func explanation(for kind: ReminderKind) -> LocalizedText {
        switch kind {
        case .sessionsLeft:
            LocalizedText(
                fr: "Seulement quand il reste autant de séances que de jours.",
                en: "Only when as many sessions remain as days.",
                es: "Solo cuando quedan tantas sesiones como días."
            )
        case .comeBack:
            LocalizedText(
                fr: "Au bout de quatre jours sans séance ni sortie.",
                en: "After four days with no session and no activity.",
                es: "Tras cuatro días sin sesión ni salida."
            )
        case .weighIn:
            LocalizedText(
                fr: "C'est le poids qui décide si les calories bougent.",
                en: "Weight is what decides whether calories move.",
                es: "El peso decide si las calorías cambian."
            )
        case .readiness:
            LocalizedText(
                fr: "Trente secondes, et la séance s'ajuste à ta journée.",
                en: "Thirty seconds, and the session adjusts to your day.",
                es: "Treinta segundos, y la sesión se ajusta a tu día."
            )
        }
    }

    private var remindersEnabledBinding: Binding<Bool> {
        Binding(
            get: { store.reminders.enabled },
            set: { wanted in
                Task { @MainActor in
                    if wanted {
                        // On demande avant de promettre. Un interrupteur qui
                        // s'allume sur un refus serait un mensonge à l'écran.
                        let granted = await Reminders.requestPermission()
                        notificationsRefused = !granted
                        guard granted else { return }
                    }
                    var settings = store.reminders
                    settings.enabled = wanted
                    store.setReminders(settings)
                    await applyReminders()
                }
            }
        )
    }

    private var reminderTimeBinding: Binding<Date> {
        Binding(
            get: {
                var parts = DateComponents()
                parts.hour = store.reminders.hour
                parts.minute = store.reminders.minute
                return Calendar.current.date(from: parts) ?? Date()
            },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                var settings = store.reminders
                settings.hour = parts.hour ?? settings.hour
                settings.minute = parts.minute ?? settings.minute
                store.setReminders(settings)
                Task { await applyReminders() }
            }
        )
    }

    private func kindBinding(_ kind: ReminderKind) -> Binding<Bool> {
        Binding(
            get: { store.reminders.kinds.contains(kind) },
            set: { wanted in
                var settings = store.reminders
                if wanted { settings.kinds.insert(kind) } else { settings.kinds.remove(kind) }
                store.setReminders(settings)
                Task { await applyReminders() }
            }
        )
    }

    /// Efface les anciens rappels et repose ceux qui valent encore.
    @MainActor private func applyReminders() async {
        guard store.reminders.enabled else {
            await Reminders.cancelAll()
            return
        }
        await Reminders.reschedule(store.plannedReminders(), language: language)
    }



    // MARK: - Cycle

    /// Le suivi du cycle : éteint tant qu'on n'a rien renseigné.
    ///
    /// La date ne se devine pas et ne se demande pas au passage : c'est une
    /// donnée intime, et une application de sport n'a aucun droit acquis
    /// dessus. Elle se saisit ici, ou se lit dans Santé — et rien ne
    /// s'affiche ailleurs tant qu'elle est absente.
    private var cycleCard: some View {
        Card(
            title: LocalizedText(fr: "Cycle", en: "Cycle", es: "Ciclo")[language],
            subtitle: LocalizedText(
                fr: "Facultatif. Sert à situer tes journées, jamais à modifier tes charges.",
                en: "Optional. Used to place your days, never to change your loads.",
                es: "Opcional. Sirve para situar tus días, nunca para cambiar tus cargas."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(
                    LocalizedText(
                        fr: "Les effets des phases du cycle sur la performance sont petits et se contredisent d'une étude à l'autre. Plutôt que d'appliquer un tableau, l'application regarde tes propres bilans de forme : au bout de deux cycles, elle peut dire si une phase change quelque chose chez toi. Tant qu'elle ne l'a pas mesuré, elle ne dit rien.",
                        en: "The effects of cycle phases on performance are small and contradict each other from study to study. Rather than apply a table, the app looks at your own check-ins: after two cycles it can say whether a phase changes anything for you. Until it has measured that, it says nothing.",
                        es: "Los efectos de las fases del ciclo sobre el rendimiento son pequeños y se contradicen entre estudios. En vez de aplicar una tabla, la aplicación mira tus propios balances: tras dos ciclos puede decir si una fase cambia algo en ti. Mientras no lo haya medido, no dice nada."
                    ),
                    font: .system(size: 11)
                )

                Toggle(isOn: cycleTrackingBinding) {
                    Text(LocalizedText(fr: "Suivre mon cycle", en: "Track my cycle", es: "Seguir mi ciclo")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.primaryText)
                }
                .tint(Theme.accent)

                if store.profile?.lastPeriodStart != nil {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedText(fr: "Premier jour des dernières règles", en: "First day of your last period", es: "Primer día de tu última regla")[language])
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                        DatePicker("", selection: periodStartBinding, displayedComponents: .date)
                            .labelsHidden()
                            .tint(Theme.accent)
                    }
                    GhostButton(
                        title: LocalizedText(fr: "Lire depuis Santé", en: "Read from Health", es: "Leer desde Salud")[language],
                        systemImage: "heart.text.square"
                    ) {
                        Task { await readCycleFromHealth() }
                    }
                }
            }
        }
    }

    private var cycleTrackingBinding: Binding<Bool> {
        Binding(
            get: { store.profile?.lastPeriodStart != nil },
            set: { wanted in
                // Éteindre efface la date : ne pas suivre son cycle doit
                // vouloir dire que l'application ne le garde pas.
                store.setLastPeriodStart(wanted ? Date() : nil)
            }
        )
    }

    private var periodStartBinding: Binding<Date> {
        Binding(
            get: { store.profile?.lastPeriodStart ?? Date() },
            set: { store.setLastPeriodStart($0) }
        )
    }

    /// Va chercher le début du cycle dans Santé, quand l'athlète le demande.
    @MainActor private func readCycleFromHealth() async {
        let reader = HealthReader()
        reader.wantsCycle = true
        guard reader.isAvailable, await reader.requestAccess() else { return }
        if let start = await reader.lastPeriodStart() {
            store.setLastPeriodStart(start)
        }
    }

    // MARK: - Santé

    /// Ce que le téléphone va chercher dans Santé.
    ///
    /// La lecture seulement : l'écriture appartient à la montre, qui
    /// enregistre la séance en cours. Demander un droit dont on ne se sert
    /// pas est la meilleure façon de se faire refuser celui dont on se sert.
    private var healthCard: some View {
        Card(
            title: LocalizedText(fr: "Santé", en: "Health", es: "Salud")[language],
            subtitle: LocalizedText(
                fr: "Ton poids, tes nuits et les séances faites ailleurs. Rien n'est écrasé : Santé remplit les trous.",
                en: "Your weight, your nights, and sessions recorded elsewhere. Nothing is overwritten: Health fills the gaps.",
                es: "Tu peso, tus noches y las sesiones hechas en otro sitio. No se sobrescribe nada: Salud rellena los huecos."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                CoachText(
                    LocalizedText(
                        fr: "Une pesée que tu as notée toi-même n'est jamais remplacée, et ce que la montre a déjà écrit n'est pas relu — sinon chaque sortie compterait deux fois.",
                        en: "A weigh-in you entered yourself is never replaced, and what the watch already wrote is not read back — otherwise every activity would count twice.",
                        es: "Un pesaje que has anotado tú nunca se reemplaza, y lo que el reloj ya escribió no se relee: si no, cada salida contaría dos veces."
                    ),
                    font: .system(size: 11)
                )

                if let healthOutcome {
                    Text(healthOutcome[language])
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }

                GhostButton(
                    title: importingHealth
                        ? LocalizedText(fr: "Lecture…", en: "Reading…", es: "Leyendo…")[language]
                        : LocalizedText(fr: "Importer depuis Santé", en: "Import from Health", es: "Importar desde Salud")[language],
                    systemImage: "heart.text.square"
                ) {
                    Task { await importHealth() }
                }
                .disabled(importingHealth)
            }
        }
    }

    /// Lit les trente derniers jours et adopte ce qui manque.
    ///
    /// Trente jours : assez pour rattraper une installation récente, assez
    /// peu pour ne pas déverser des années de vieilles séances dans un
    /// journal qui raconte un bloc en cours.
    @MainActor private func importHealth() async {
        importingHealth = true
        defer { importingHealth = false }

        let reader = HealthReader()
        guard reader.isAvailable, await reader.requestAccess() else {
            healthOutcome = LocalizedText(
                fr: "Santé n'est pas accessible sur cet appareil.",
                en: "Health is not available on this device.",
                es: "Salud no está disponible en este dispositivo."
            )
            return
        }

        let since = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let taken = store.importFromHealth(
            weights: await reader.weights(since: since),
            nights: await reader.nights(since: since),
            workouts: await reader.workouts(since: since),
            ourSourceNames: HealthReader.ourSources
        )

        // Zéro n'est pas un échec : c'est souvent que tout y était déjà. Le
        // dire évite de laisser croire que le bouton n'a rien fait — et
        // Apple ne révèle jamais si la lecture a été refusée, donc on ne
        // peut pas promettre plus que ce qu'on a vu.
        if taken.weights == 0 && taken.activities == 0 {
            healthOutcome = LocalizedText(
                fr: "Rien de nouveau. Soit tout y était déjà, soit Santé n'a rien à partager — Apple ne dit pas lequel des deux.",
                en: "Nothing new. Either it was all here already, or Health has nothing to share — Apple does not say which.",
                es: "Nada nuevo. O ya estaba todo, o Salud no tiene nada que compartir; Apple no dice cuál de los dos."
            )
        } else {
            healthOutcome = LocalizedText(
                fr: "\(taken.weights) pesée\(taken.weights > 1 ? "s" : "") et \(taken.activities) séance\(taken.activities > 1 ? "s" : "") ajoutées.",
                en: "\(taken.weights) weigh-in\(taken.weights > 1 ? "s" : "") and \(taken.activities) session\(taken.activities > 1 ? "s" : "") added.",
                es: "\(taken.weights) pesaje\(taken.weights > 1 ? "s" : "") y \(taken.activities) sesi\(taken.activities > 1 ? "ones" : "ón") añadidos."
            )
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
            Text(LocalizedText(fr: "Stride — conçu et développé par Maxime Nathan Lestage", en: "Stride — designed and developed by Maxime Nathan Lestage", es: "Stride — diseñado y desarrollado por Maxime Nathan Lestage")[language])
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
            fr: "Cartes : Apple Plans (MapKit), fourni par iOS. Aucune bibliothèque tierce n'est embarquée dans l'application.",
            en: "Maps: Apple Maps (MapKit), provided by iOS. No third-party library is bundled in the app.",
            es: "Mapas: Apple Plans (MapKit), incluido en iOS. La aplicación no incorpora ninguna biblioteca de terceros."
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

/// Un libellé à gauche, sa valeur à droite.
///
/// Les deux textes sont bridés, et c'est le fond du problème qu'ils ont
/// causé : une ligne qui réclame plus large que la carte rend toute la
/// vue défilable horizontalement, et l'écran entier part alors sur le
/// côté — les titres et les libellés sortent par la gauche pendant que
/// les valeurs restent visibles à droite. Une seule ligne trop longue
/// suffit ; ici c'était « Sédentaire (bureau, peu de marche) ».
///
/// Le libellé garde donc la priorité et tient sur une ligne ; la valeur
/// se replie sur deux lignes plutôt que de pousser, et rétrécit un peu
/// avant de se couper.
struct LabeledRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(label)
                .font(Theme.captionFont)
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(1)
                .layoutPriority(1)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Theme.primaryText)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
