import SwiftUI
import MonCoachKit

/// L'écran où l'on déclare sa situation, et où l'on voit ce qu'elle change.
///
/// Un écran plutôt qu'une case dans le formulaire du profil, pour une
/// raison simple : ce qui se déclare ici ne se range pas à côté du tour de
/// taille. Il faut la place de dire ce que ça change — sinon la déclaration
/// ressemble à une question administrative, et personne ne répond aux
/// questions administratives.
///
/// L'écran existe même quand rien n'est déclaré. Une fonction qu'il faut
/// deviner pour la découvrir n'existe pas.
struct AdaptiveView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language
    @Environment(\.dismiss) private var dismiss

    /// La déclaration se modifie en local et ne part qu'au bouton.
    ///
    /// Enregistrer à chaque bascule aurait été plus direct et franchement
    /// pire : écrire le profil reconstruit le mésocycle, donc efface les
    /// séances planifiées et les charges atteintes. Cocher une case pour
    /// voir ce qu'elle fait coûterait un bloc d'entraînement.
    @State private var needs = AdaptiveNeeds()
    @State private var loaded = false

    private var saved: AdaptiveNeeds { store.profile?.adaptive ?? AdaptiveNeeds() }
    private var hasChanges: Bool { needs != saved }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                introCard.appears(0)
                situationsCard.appears(1)
                if needs.situations.contains(where: \.hasSide) {
                    sideCard.appears(2)
                }
                if needs.isActive {
                    effectsCard.appears(3)
                    if !needs.overridable.isEmpty { overrideCard.appears(4) }
                    sportsCard.appears(5)
                }
                reserveCard.appears(6)
                if hasChanges { applyCard.appears(7) }
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle(
            LocalizedText(fr: "Handicap", en: "Disability", es: "Discapacidad")[language]
        )
        .navigationBarTitleDisplayMode(.inline)
        .tint(Theme.accent)
        .task {
            // Une seule fois : recharger à chaque retour d'un sous-écran
            // effacerait ce que l'on vient de cocher.
            guard !loaded else { return }
            needs = saved
            loaded = true
        }
    }

    // MARK: - Ce que fait cet écran

    private var introCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que tu déclares ici change le programme",
                en: "What you declare here changes the programme",
                es: "Lo que declaras aquí cambia el programa"
            )[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Le coach ne propose que des mouvements que ton corps peut exécuter, met devant les sports qui te correspondent, et répartit tes séances sur ce qui reste. Rien n'est déclaré tant que tu ne coches rien : dans ce cas l'application se comporte exactement comme avant.",
                    en: "The coach only offers movements your body can perform, puts the sports that suit you first, and spreads your sessions over what remains. Nothing is declared until you tick something: until then the app behaves exactly as before.",
                    es: "El entrenador solo propone movimientos que tu cuerpo puede ejecutar, pone delante los deportes que te corresponden y reparte tus sesiones sobre lo que queda. Nada está declarado mientras no marques nada: hasta entonces la aplicación se comporta igual que antes."
                )
            )
            CoachText(
                LocalizedText(
                    fr: "Comme le reste de ton profil, ça ne quitte pas ce téléphone. Aucun serveur, aucune statistique, aucun partage.",
                    en: "Like the rest of your profile, this never leaves this phone. No server, no analytics, no sharing.",
                    es: "Como el resto de tu perfil, esto no sale de este teléfono. Ningún servidor, ninguna estadística, ningún envío."
                ),
                font: Theme.captionFont
            )
        }
    }

    // MARK: - La déclaration

    private var situationsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ta situation", en: "Your situation", es: "Tu situación"
            )[language],
            subtitle: LocalizedText(
                fr: "Coche ce qui s'applique. Plusieurs réponses sont possibles.",
                en: "Tick what applies. More than one answer is possible.",
                es: "Marca lo que corresponda. Se pueden elegir varias."
            )[language]
        ) {
            VStack(spacing: 0) {
                ForEach(AdaptiveSituation.allCases) { situation in
                    Toggle(isOn: binding(for: situation)) {
                        Text(situation.label[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                    }
                    .toggleStyle(.switch)
                    .tint(Theme.accent)
                    .padding(.vertical, 9)

                    if situation != AdaptiveSituation.allCases.last {
                        Divider().overlay(Theme.separator)
                    }
                }
            }

            Divider().overlay(Theme.separator).padding(.vertical, 4)

            Toggle(isOn: $needs.usesWheelchair) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        LocalizedText(
                            fr: "Je me déplace en fauteuil",
                            en: "I use a wheelchair",
                            es: "Me desplazo en silla de ruedas"
                        )[language]
                    )
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.primaryText)
                    // Demandé à part parce que ce n'est pas déductible : on
                    // peut rouler sans être paraplégique, et être
                    // paraplégique en marchant appareillé.
                    Text(
                        LocalizedText(
                            fr: "Se déclare à part : le fauteuil dit où se passe la séance, pas ce que valent tes jambes.",
                            en: "Asked separately: the chair says where the session happens, not what your legs can do.",
                            es: "Se declara aparte: la silla dice dónde ocurre la sesión, no lo que pueden tus piernas."
                        )[language]
                    )
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .toggleStyle(.switch)
            .tint(Theme.accent)
        }
    }

    private var sideCard: some View {
        Card(
            title: LocalizedText(
                fr: "Le côté atteint", en: "The affected side", es: "El lado afectado"
            )[language]
        ) {
            Picker("", selection: $needs.affectedSide) {
                Text(LocalizedText(fr: "Non précisé", en: "Not specified", es: "Sin precisar")[language])
                    .tag(BodySide?.none)
                ForEach(BodySide.allCases) { side in
                    Text(side.label[language]).tag(BodySide?.some(side))
                }
            }
            .pickerStyle(.segmented)

            if let working = needs.workingSide {
                CoachText(
                    LocalizedText(
                        fr: "Les charges seront proposées pour le \(working.label[.french].lowercased()) — c'est lui qui travaille. Le côté atteint a sa place ailleurs : la mobilité assise, dans les sports proposés plus bas, est faite pour lui.",
                        en: "Loads will be prescribed for the \(working.label[.english].lowercased()) — that is the side that works. The affected side belongs elsewhere: seated mobility, in the sports below, is meant for it.",
                        es: "Las cargas se propondrán para el \(working.label[.spanish].lowercased()) — es el que trabaja. El lado afectado tiene su lugar en otra parte: la movilidad sentada, en los deportes de abajo, está hecha para él."
                    ),
                    font: Theme.captionFont
                )
            }
        }
    }

    // MARK: - Ce que ça change

    private var effectsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que ça change", en: "What changes", es: "Lo que cambia"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(declared) { situation in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(situation.label[language])
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.accent)
                        Text(situation.effect[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                // Les descriptions ci-dessus décrivent le réglage par
                // défaut. Une réautorisation les contredit en partie, et le
                // taire laisserait deux cartes se contredire à l'écran.
                if !needs.allowedAnyway.isEmpty {
                    CoachText(
                        LocalizedText(
                            fr: "Tu as réautorisé plus bas ce que ton corps sait faire malgré tout : ces descriptions valent pour le réglage par défaut, ton programme suit ce que tu as coché.",
                            en: "Below you re-enabled what your body can do anyway: these descriptions are the default setting, your programme follows what you ticked.",
                            es: "Más abajo has vuelto a permitir lo que tu cuerpo sabe hacer igualmente: estas descripciones son el ajuste por defecto, tu programa sigue lo que has marcado."
                        ),
                        font: Theme.captionFont
                    )
                }

                if needs.filtersNothing {
                    CoachText(
                        LocalizedText(
                            fr: "Aucun exercice n'est retiré de ton programme. C'est volontaire : rien de ce que tu as déclaré n'empêche un mouvement, et en écarter « par prudence » reviendrait à décider à ta place.",
                            en: "No exercise is removed from your programme. That is deliberate: nothing you declared prevents a movement, and removing some out of caution would be deciding for you.",
                            es: "No se retira ningún ejercicio de tu programa. Es deliberado: nada de lo que has declarado impide un movimiento, y quitarlos «por prudencia» sería decidir por ti."
                        ),
                        font: Theme.captionFont
                    )
                }

                if !untrainable.isEmpty {
                    // Dit avant que quelqu'un cherche pendant des semaines
                    // pourquoi un muscle n'apparaît jamais.
                    // Dit sans commentaire sur la cause. La phrase
                    // rassurante qui était ici — « ce n'est pas une limite
                    // de ton corps » — était vraie quand il manquait du
                    // matériel et fausse quand les jambes ne répondent pas.
                    // Une phrase réconfortante à moitié fausse ne réconforte
                    // personne.
                    CoachText(
                        LocalizedText(
                            fr: "Aucun mouvement disponible pour \(names(untrainable, .french)). Ces muscles sortent du calcul plutôt que d'apparaître à zéro. Avec plus de matériel — un élastique suffit souvent — certains reviennent.",
                            en: "No movement available for \(names(untrainable, .english)). Those muscles leave the budget rather than showing up at zero. With more equipment — a band is often enough — some come back.",
                            es: "Ningún movimiento disponible para \(names(untrainable, .spanish)). Esos músculos salen del cálculo en lugar de aparecer a cero. Con más material — a menudo basta una banda — algunos vuelven."
                        ),
                        font: Theme.captionFont,
                        color: Theme.warning
                    )
                }
            }
        }
    }

    // MARK: - Ce que l'athlète rend au catalogue

    /// Le dernier mot revient à celui qui s'entraîne.
    ///
    /// Le filtrage est un défaut, pas un verdict. Deux hémiplégies ne se
    /// ressemblent pas : l'une ne lève pas le bras, l'autre le lève moins
    /// fort, et la seconde a de très bonnes raisons de vouloir travailler
    /// les deux côtés — c'est même souvent ce qu'on lui demande de faire.
    /// Une application qui décide seule que c'est impossible se trompe de
    /// rôle.
    ///
    /// Les trois exigences qui disent « les deux côtés fournissent » sont
    /// derrière un seul interrupteur : les séparer obligerait à répondre
    /// trois fois à une seule question.
    private var overrideCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que tu peux quand même faire",
                en: "What you can do anyway",
                es: "Lo que puedes hacer de todos modos"
            )[language],
            subtitle: LocalizedText(
                fr: "Ce qui est retiré plus haut l'est par défaut. Si ton corps fait mieux que ça, dis-le : les mouvements reviennent dans ton programme.",
                en: "What is removed above is removed by default. If your body does better than that, say so: the movements come back into your programme.",
                es: "Lo que se retira arriba se retira por defecto. Si tu cuerpo hace más que eso, dilo: los movimientos vuelven a tu programa."
            )[language]
        ) {
            if !pairedRemoved.isEmpty {
                Toggle(isOn: bothSides) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(
                            LocalizedText(
                                fr: "Je m'entraîne quand même des deux côtés",
                                en: "Train both sides anyway",
                                es: "Entrenar de todos modos los dos lados"
                            )[language]
                        )
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.primaryText)
                        Text(
                            LocalizedText(
                                fr: "La barre, le développé à deux bras et les mouvements à deux jambes reviennent, en plus de ceux à un seul côté.",
                                en: "The barbell, two-armed presses and two-legged movements come back, on top of the single-side ones.",
                                es: "La barra, los press a dos brazos y los movimientos a dos piernas vuelven, además de los de un solo lado."
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .toggleStyle(.switch)
                .tint(Theme.accent)
            }

            // Les exigences restantes, une par une : tenir debout et
            // descendre au sol sont deux questions différentes, et personne
            // ne répond « oui » aux deux pour la même raison.
            ForEach(otherRemoved) { demand in
                Divider().overlay(Theme.separator)
                Toggle(isOn: allowing(demand)) {
                    Text(demand.label[language])
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.primaryText)
                }
                .toggleStyle(.switch)
                .tint(Theme.accent)
            }

            if !needs.allowedAnyway.isEmpty {
                Divider().overlay(Theme.separator)
                // La seule mise en garde, dite une fois. Les charges se
                // calculent sur ce que la série a réellement pesé : sur un
                // mouvement à deux côtés dont un fournit moins, c'est le
                // côté faible qui décide, et la progression s'y cale.
                CoachText(
                    LocalizedText(
                        fr: "Sur un mouvement à deux côtés, la charge se règle sur le côté le plus faible — c'est lui qui finit la série. Commence bas, monte lentement, et si un côté compense l'autre sans que tu le décides, repasse au travail à un seul côté.",
                        en: "On a two-sided movement, the load is set by the weaker side — it is the one that finishes the set. Start low, add slowly, and if one side takes over the other without you deciding it, go back to single-side work.",
                        es: "En un movimiento a dos lados, la carga la marca el lado más débil: es el que termina la serie. Empieza bajo, sube despacio, y si un lado compensa al otro sin que lo decidas, vuelve al trabajo a un solo lado."
                    ),
                    font: Theme.captionFont,
                    color: Theme.warning
                )
            }
        }
    }

    private var pairedRemoved: Set<BodyDemand> {
        AdaptiveNeeds.pairedDemands.intersection(needs.overridable)
    }

    private var otherRemoved: [BodyDemand] {
        needs.overridable.filter { !AdaptiveNeeds.pairedDemands.contains($0) }
    }

    private var bothSides: Binding<Bool> {
        Binding(
            get: { needs.trainsBothSides },
            set: { on in
                if on {
                    needs.allowedAnyway.formUnion(pairedRemoved)
                } else {
                    needs.allowedAnyway.subtract(AdaptiveNeeds.pairedDemands)
                }
            }
        )
    }

    private func allowing(_ demand: BodyDemand) -> Binding<Bool> {
        Binding(
            get: { needs.allowedAnyway.contains(demand) },
            set: { on in
                if on { needs.allowedAnyway.insert(demand) }
                else { needs.allowedAnyway.remove(demand) }
            }
        )
    }

    // MARK: - Les sports

    private var sportsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Des sports à démarrer maintenant",
                en: "Sports you can start now",
                es: "Deportes para empezar ahora"
            )[language],
            subtitle: LocalizedText(
                fr: "Chacun est mesuré comme les autres : distance, allure, dépense, historique.",
                en: "Each is measured like any other: distance, pace, spend, history.",
                es: "Cada uno se mide como los demás: distancia, ritmo, gasto, historial."
            )[language]
        ) {
            VStack(spacing: 8) {
                ForEach(needs.suggestedSports, id: \.self) { sport in
                    Button {
                        // Le même chemin que Siri et le bouton Action : la
                        // sortie s'ouvre par-dessus tout le reste, sans
                        // ramener l'athlète dans le profil ensuite.
                        IntentRouter.shared.requestedSport = sport
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: sport.symbolName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Theme.accent)
                                .frame(width: 26)
                            Text(sport.label[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Spacer()
                            Image(systemName: "play.circle.fill")
                                .foregroundStyle(Theme.accent)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(
                            Theme.surfaceRaised,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    // MARK: - La réserve

    private var reserveCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que cette application n'est pas",
                en: "What this app is not",
                es: "Lo que esta aplicación no es"
            )[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Stride mesure ce que tu fais et construit un programme d'entraînement. Elle n'encadre pas une rééducation, ne remplace pas un kinésithérapeute ni un médecin, et ne connaît pas ton dossier. Si une douleur, une spasticité ou une fatigue inhabituelle apparaît, c'est à eux qu'il faut le dire — pas à un écran.",
                    en: "Stride measures what you do and builds a training programme. It does not supervise rehabilitation, does not replace a physiotherapist or a doctor, and knows nothing of your medical file. If pain, spasticity or unusual fatigue appears, tell them — not a screen.",
                    es: "Stride mide lo que haces y construye un programa de entrenamiento. No dirige una rehabilitación, no sustituye a un fisioterapeuta ni a un médico, y no conoce tu historial. Si aparece dolor, espasticidad o un cansancio inhabitual, díselo a ellos, no a una pantalla."
                )
            )
        }
    }

    // MARK: - Appliquer

    private var applyCard: some View {
        Card {
            CoachText(
                LocalizedText(
                    fr: "Enregistrer reconstruit ton bloc d'entraînement avec les mouvements que tu peux faire. Les séances déjà planifiées de ce bloc sont remplacées ; ton historique, lui, ne bouge pas.",
                    en: "Saving rebuilds your training block with the movements you can do. The already-planned sessions of this block are replaced; your history does not move.",
                    es: "Guardar reconstruye tu bloque de entrenamiento con los movimientos que puedes hacer. Las sesiones ya planificadas de este bloque se sustituyen; tu historial no se toca."
                ),
                font: Theme.captionFont
            )
            PrimaryButton(title: UI.save[language], systemImage: "checkmark") {
                apply()
            }
            GhostButton(
                title: LocalizedText(fr: "Annuler les changements", en: "Discard changes", es: "Descartar los cambios")[language]
            ) {
                needs = saved
            }
        }
    }

    private func apply() {
        guard var profile = store.profile else { return }
        // Rangé à nil plutôt qu'à une déclaration vide : un profil qui n'a
        // rien déclaré et un profil qui a tout décoché doivent se relire de
        // la même façon.
        profile.adaptive = needs.isActive ? needs : nil
        store.updateProfile(profile)
        dismiss()
    }

    // MARK: - Outils

    private var declared: [AdaptiveSituation] {
        AdaptiveSituation.allCases.filter { needs.situations.contains($0) }
    }

    /// Les muscles que le catalogue ne sait pas servir dans cette
    /// configuration — calculés sur la déclaration en cours, pas sur celle
    /// qui est enregistrée : l'écran doit répondre à ce qu'on vient de
    /// cocher, avant d'avoir enregistré.
    ///
    /// Restreints à ceux que le programme travaillerait vraiment. Parcourir
    /// les quatorze groupes musculaires produisait une liste à faire peur,
    /// où figuraient des muscles qu'aucune séance de ce profil n'aurait
    /// budgétés de toute façon.
    private var untrainable: [MuscleGroup] {
        guard var profile = store.profile, needs.isActive else { return [] }
        profile.adaptive = needs
        let trainable = ExerciseCatalog.trainableMuscles(for: profile)
        let budgeted = VolumeEngine.prescription(for: profile).weeklySets
        return MuscleGroup.allCases.filter {
            (budgeted[$0] ?? 0) > 0 && !trainable.contains($0)
        }
    }

    private func names(_ muscles: [MuscleGroup], _ language: Language) -> String {
        muscles.map { $0.label[language].lowercased() }.joined(separator: ", ")
    }

    private func binding(for situation: AdaptiveSituation) -> Binding<Bool> {
        Binding(
            get: { needs.situations.contains(situation) },
            set: { on in
                if on {
                    needs.situations.insert(situation)
                } else {
                    needs.situations.remove(situation)
                    // La question du côté n'a plus de sens quand plus aucune
                    // situation n'en a un : la laisser renseignée ferait
                    // réapparaître une réponse à une question retirée.
                    if !needs.situations.contains(where: \.hasSide) {
                        needs.affectedSide = nil
                    }
                    // Une réautorisation qui ne correspond plus à rien de
                    // retiré n'a plus de sens : la garder ferait revenir une
                    // réponse à une question qui n'est plus posée.
                    needs.allowedAnyway.formIntersection(needs.closedDemands)
                }
            }
        )
    }
}
