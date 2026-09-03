import SwiftUI
import MonCoachKit

/// Decides between onboarding and the app, and hosts the session player.
struct RootView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    /// Le pont vers la montre vit ici : la vue racine est le seul endroit qui
    /// voit à la fois le magasin et le cycle de vie de l'application.
    @State private var watchLink = WatchLink()

    /// L'onglet affiché. Tenu ici plutôt que laissé à la barre d'onglets
    /// pour une raison : les écrans ont besoin de savoir quand on arrive
    /// sur eux. La barre le sait, mais ne le dit à personne ; on le lui
    /// demande, et on le passe dans l'environnement pour que chaque carte
    /// rejoue son arrivée au moment où son onglet est choisi.
    @State private var section: AppSection = .today

    /// La fiche affichée entre deux onglets, et la tâche qui la retire.
    ///
    /// Elle n'apparaît qu'au changement, jamais à l'ouverture : l'écran de
    /// lancement a déjà dit le nom de l'application, et une fiche
    /// « Aujourd'hui » par-dessus serait deux portes pour la même entrée.
    @State private var splash: AppSection?
    @State private var splashTask: Task<Void, Never>?

    /// Ce que Siri, le bouton Action ou un raccourci ont demandé.
    ///
    /// Lu ici et nulle part ailleurs : l'écran d'enregistrement n'est
    /// aujourd'hui accessible qu'en fiche depuis deux onglets, et une
    /// intention ne peut pas savoir lequel est affiché. La racine, elle,
    /// est toujours là.
    @State private var router = IntentRouter.shared

    private var showsActivities: Bool {
        // L'onglet n'apparaît que s'il a quelque chose à dire : un plan de
        // course, ou des activités déjà enregistrées. Un onglet vide en
        // permanence apprend surtout à ne plus regarder la barre d'onglets.
        store.profile?.runs == true || !store.history.activities.isEmpty
    }

    var body: some View {
        @Bindable var store = store

        Group {
            if store.isOnboarded {
                TabView(selection: $section) {
                    Tab(UI.today[store.language], systemImage: "bolt.fill", value: AppSection.today) {
                        TodayView()
                    }
                    Tab(UI.plan[store.language], systemImage: "list.bullet.rectangle", value: AppSection.plan) {
                        PlanView()
                    }
                    if showsActivities {
                        Tab(UI.running[store.language], systemImage: "figure.run", value: AppSection.running) {
                            ActivitiesHomeView()
                        }
                    }
                    Tab(UI.food[store.language], systemImage: "fork.knife", value: AppSection.food) {
                        FoodView()
                    }
                    Tab(UI.progress[store.language], systemImage: "chart.line.uptrend.xyaxis", value: AppSection.progress) {
                        ProgressDashboardView()
                    }
                    // Le profil n'est pas un onglet, et c'est réfléchi.
                    //
                    // Une barre d'onglets n'en montre que cinq. Au sixième,
                    // iOS range le surplus derrière un menu « Autre » qui a
                    // sa propre pile de navigation : le profil s'ouvrait
                    // alors avec un bouton de retour au-dessus de sa propre
                    // barre, deux bandeaux empilés pour un seul écran, et
                    // la progression se retrouvait cachée derrière trois
                    // petits points.
                    //
                    // Cinq onglets tiennent, tous visibles. Le profil vit
                    // derrière un bouton sur « Aujourd'hui » — c'est un
                    // écran qu'on visite pour changer quelque chose, pas un
                    // écran où l'on passe sa séance.
                }
                .environment(\.selectedSection, section)
                // Si l'onglet des activités disparaît pendant qu'on est
                // dessus — profil modifié, dernière sortie supprimée — la
                // sélection pointerait sur un onglet qui n'existe plus.
                .onChange(of: showsActivities) { _, shown in
                    if !shown, section == .running { section = .today }
                }
                // Le profil n'a plus d'onglet : si la sélection y pointait
                // encore — état restauré d'une version précédente — elle
                // désignerait un onglet qui n'existe pas.
                .onAppear { if section == .profile { section = .today } }
                .onChange(of: section) { _, now in
                    present(now)
                }
            } else {
                OnboardingView { profile in
                    store.completeOnboarding(with: profile)
                }
            }
        }
        // La fiche d'onglet est posée par-dessus toute l'application, et
        // non en surcouche de la barre d'onglets : la barre héberge sa
        // propre navigation — le menu « Autre » pousse ses écrans dans une
        // pile à elle — et lui greffer une surcouche revenait à se mêler
        // d'une hiérarchie qui n'est pas la nôtre.
        .overlay {
            if let splash {
                SectionSplashView(section: splash) { dismissSplash() }
                    .transition(.opacity)
            }
        }
        // Toute l'interface est rendue dans la langue du magasin : changer
        // de langue dans le profil rafraîchit l'écran sur-le-champ.
        .language(store.language)
        .fullScreenCover(item: $store.activeSession) { _ in
            SessionPlayerView()
        }
        // La sortie demandée par la voix s'ouvre par-dessus tout le reste,
        // sans changer d'onglet : on a demandé à courir, pas à visiter
        // l'application.
        .fullScreenCover(item: requestedSport) { sport in
            RunTrackerView(plannedRun: store.briefing()?.plannedRun, requestedSport: sport)
        }
        .onAppear {
            watchLink.activate(store: store)
            // Les intentions écrivent alors dans le magasin affiché, et non
            // dans une copie qui serait écrasée au geste suivant.
            router.live = store
        }
        // L'instantané part vers la montre à chaque changement qui la
        // concerne : nouvelle séance enregistrée, nouveau bloc, retour au
        // premier plan après une nuit.
        .onChange(of: store.history) { _, _ in watchLink.push() }
        .onChange(of: store.plan) { _, _ in watchLink.push() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { watchLink.push() }
        }
    }

    /// La sortie demandée, tant qu'il y a une application pour l'accueillir.
    ///
    /// Retenue pendant l'inscription plutôt qu'effacée : quelqu'un qui a
    /// demandé une sortie avant d'avoir rempli son profil la verra s'ouvrir
    /// en sortant de l'inscription, ce qui est ce qu'il avait demandé.
    private var requestedSport: Binding<Sport?> {
        Binding(
            get: { store.isOnboarded ? router.requestedSport : nil },
            set: { router.requestedSport = $0 }
        )
    }

    /// Pose la fiche de l'onglet choisi, et programme son retrait.
    private func present(_ section: AppSection) {
        splashTask?.cancel()
        withAnimation(.easeOut(duration: 0.12)) { splash = section }
        splashTask = Task {
            try? await Task.sleep(for: .seconds(Motion.splashHold))
            guard !Task.isCancelled else { return }
            dismissSplash()
        }
    }

    private func dismissSplash() {
        splashTask?.cancel()
        withAnimation(.easeInOut(duration: 0.32)) { splash = nil }
    }
}
