import Foundation
import WatchConnectivity
import MonCoachKit

/// Le canal montre → téléphone, côté montre.
///
/// Deux flux, deux mécanismes, choisis pour leurs garanties :
/// - l'instantané du jour arrive par `applicationContext` — le système ne
///   garde que le plus récent, exactement la sémantique voulue ;
/// - les séances terminées et les sorties de course partent par
///   `transferUserInfo` — file persistante, livrée même si le téléphone est
///   hors de portée au moment de l'envoi. C'est exactement le cas d'une
///   sortie faite sans téléphone, qui est tout l'intérêt du GPS au poignet.
final class PhoneLink: NSObject, WCSessionDelegate {

    var onSnapshot: ((WatchSnapshot) -> Void)?
    var onQueueDrained: (() -> Void)?

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }

    func send(_ log: SessionLog) {
        guard let data = try? WatchSyncCodec.encode(log) else { return }
        WCSession.default.transferUserInfo([WatchSyncCodec.sessionLogKey: data])
    }

    func send(_ log: ActivityLog) {
        guard let data = try? WatchSyncCodec.encode(log) else { return }
        WCSession.default.transferUserInfo([WatchSyncCodec.runLogKey: data])
    }

    // MARK: - WCSessionDelegate

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: (any Error)?
    ) {
        // Le contexte reçu pendant que la montre dormait est déjà disponible.
        let context = session.receivedApplicationContext
        if let data = context[WatchSyncCodec.snapshotKey] as? Data,
           let snapshot = try? WatchSyncCodec.decodeSnapshot(data) {
            onSnapshot?(snapshot)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        guard let data = applicationContext[WatchSyncCodec.snapshotKey] as? Data,
              let snapshot = try? WatchSyncCodec.decodeSnapshot(data)
        else { return }
        onSnapshot?(snapshot)
    }

    func session(
        _ session: WCSession,
        didFinish userInfoTransfer: WCSessionUserInfoTransfer,
        error: (any Error)?
    ) {
        if session.outstandingUserInfoTransfers.isEmpty {
            onQueueDrained?()
        }
    }
}
