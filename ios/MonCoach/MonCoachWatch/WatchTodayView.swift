import SwiftUI
import MonCoachKit

/// L'écran d'ouverture de la montre.
///
/// Ce qui change, et pourquoi
/// ..........................
/// L'accueil était un long défilement de cartes empilées : la forme, la
/// séance, la sortie, un bouton « Démarrer une activité », l'alimentation,
/// la synchronisation, le crédit. C'était l'écran du téléphone rétréci, et
/// il en gardait le défaut — sur un écran de quatre centimètres, tout y
/// était petit et rien n'y était premier. Partir courir demandait de lever
/// le poignet, faire défiler, viser un bouton, attendre un écran, puis
/// choisir. Cinq gestes pour la seule chose qu'on venait faire.
///
/// L'application s'ouvre maintenant sur la liste des activités elle-même :
/// on tourne la couronne, on appuie, on part. C'est la disposition de
/// l'application Exercice d'Apple, et ce n'est pas un hasard — au poignet,
/// ce qu'on fait souvent doit être ce qui coûte le moins.
///
/// Ce qui se lit plutôt que se fait — la forme du jour, l'assiette, le
/// bilan de la journée — se range derrière la première ligne de cette même
/// liste, à un appui. Rien n'a disparu ; ce qui se lit a cessé d'occuper la
/// place de ce qui se fait.
///
/// Cette vue ne dessine donc plus grand-chose : elle aiguille, tient la
/// navigation, et réveille la montre une fois la première image affichée.
struct WatchTodayView: View {
    @Environment(WatchStore.self) private var store

    var body: some View {
        Group {
            if store.snapshot == nil {
                WatchWaitingView()
            } else if !store.isUnlocked {
                WatchLockedView()
            } else {
                WatchStartView()
            }
        }
        // Démarrer pousse l'écran de l'effort ; le quitter d'un glissement
        // ramène ici, où il attend d'être repris. Ce qu'on pousse vient du
        // magasin et non d'un drapeau local : démarrer une sortie et
        // rouvrir celle qui tourne déjà empruntent alors le même chemin.
        .navigationDestination(isPresented: door(.activity)) { WatchRunView() }
        .navigationDestination(isPresented: door(.session)) { WatchSessionView() }
        // Le réveil de la montre a lieu ici, après la première image, et
        // non dans l'init du magasin. Ce qui échoue en se reliant au
        // téléphone coûte alors une fonction en moins, pas le lancement.
        .task { store.wakeUp() }
    }

    /// La porte d'un écran : ouverte quand la route y mène, et refermée
    /// dès qu'on en revient — d'un glissement comme d'un bouton.
    private func door(_ route: WatchStore.Route) -> Binding<Bool> {
        Binding(
            get: { store.route == route },
            set: { open in
                if !open, store.route == route { store.route = nil }
            }
        )
    }
}

/// Avant la première synchronisation : la montre ne sait rien, et le dit.
struct WatchWaitingView: View {
    @Environment(\.language) private var language

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "iphone.radiowaves.left.and.right")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text(WatchUI.waiting[language])
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(WatchUI.waitingDetail[language])
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Stride")
    }
}

/// L'essai fini, l'abonnement absent.
///
/// Pas un écran vide, et surtout pas une porte muette : il dit ce qu'il
/// manque et où le régler, puisque l'achat se fait sur le téléphone.
struct WatchLockedView: View {
    @Environment(\.language) private var language

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.green)
                Text(WatchUI.plusNeeded[language])
                    .font(.system(.headline, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(WatchUI.plusNeededDetail[language])
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .navigationTitle("Stride")
    }
}
