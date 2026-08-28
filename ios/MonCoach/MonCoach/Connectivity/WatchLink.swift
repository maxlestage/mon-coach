import Foundation
import WatchConnectivity
import MonCoachKit

/// Le canal téléphone → montre, côté téléphone.
///
/// Symétrique de `PhoneLink` sur la montre : l'instantané du jour part par
/// `applicationContext` (le système ne garde que le plus récent), et les
/// séances menées au poignet arrivent par `userInfo` (file persistante,
/// livrée même si l'application était fermée au moment de l'envoi).
@MainActor
final class WatchLink: NSObject {

    private weak var store: CoachStore?

    func activate(store: CoachStore) {
        self.store = store
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    /// Envoie l'état du jour à la montre. Sans montre appairée, sans effet.
    func push() {
        guard let store,
              WCSession.isSupported(),
              WCSession.default.activationState == .activated,
              WCSession.default.isPaired,
              WCSession.default.isWatchAppInstalled,
              let snapshot = store.watchSnapshot(),
              let data = try? WatchSyncCodec.encode(snapshot)
        else { return }
        try? WCSession.default.updateApplicationContext([WatchSyncCodec.snapshotKey: data])
    }
}

extension WatchLink: WCSessionDelegate {

    nonisolated func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        Task { @MainActor in self.push() }
    }

    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        // Changement de montre appairée : on réactive pour la nouvelle.
        session.activate()
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        if let data = userInfo[WatchSyncCodec.sessionLogKey] as? Data,
           let log = try? WatchSyncCodec.decodeSessionLog(data) {
            Task { @MainActor in
                self.store?.receiveFromWatch(log)
                // L'historique vient de changer : la montre reçoit l'état à
                // jour, notamment la séance marquée faite.
                self.push()
            }
        }
        if let data = userInfo[WatchSyncCodec.runLogKey] as? Data,
           let log = try? WatchSyncCodec.decodeRunLog(data) {
            Task { @MainActor in
                // Une sortie remontée peut faire bouger l'allure de seuil, et
                // donc toutes les allures prescrites : le magasin s'en charge.
                self.store?.receiveFromWatch(log)
                self.push()
            }
        }
    }
}
