import Foundation
import Observation
import MonCoachKit

/// L'état de l'application montre.
///
/// La montre ne recalcule rien : elle reçoit du téléphone un instantané du
/// jour — séance prescrite, charges, forme — et ne produit qu'une chose en
/// retour, le journal de la séance menée au poignet. Le dernier instantané
/// est gardé sur disque pour que la montre reste utilisable téléphone
/// éteint ou resté au vestiaire.
@MainActor
@Observable
final class WatchStore {

    private(set) var snapshot: WatchSnapshot?
    var activeSession: ActiveSession?

    /// La session d'entraînement HealthKit, pour la séance comme pour les
    /// sorties. Une seule, tenue ici : c'est elle qui garde l'application
    /// éveillée, et elle doit survivre à l'écran qui l'a lancée.
    let workout = WatchWorkout()

    /// Le GPS d'une sortie. Tenu ici et non dans l'écran de course : une
    /// vue qu'on quitte d'un glissement détruit son état, et un tracker
    /// détruit est une sortie perdue. L'accueil montre la sortie en cours
    /// et permet d'y revenir, comme pour la séance.
    let tracker = LocationTracker()
    /// Séances terminées sur la montre, en attente de confirmation de départ
    /// vers le téléphone. WatchConnectivity garde sa propre file ; ceci ne
    /// sert qu'à l'affichage « en attente de synchronisation ».
    private(set) var pendingUploads: Int = 0

    private let link: PhoneLink
    private let cacheURL: URL

    init() {
        cacheURL = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ))?.appending(path: "watch-snapshot.json") ?? URL.temporaryDirectory.appending(path: "watch-snapshot.json")

        link = PhoneLink()
        snapshot = Self.loadCache(from: cacheURL)
        link.onSnapshot = { [weak self] fresh in
            Task { @MainActor in self?.apply(fresh) }
        }
        link.onQueueDrained = { [weak self] in
            Task { @MainActor in self?.pendingUploads = 0 }
        }
        link.activate()
    }

    // MARK: - Instantané

    private func apply(_ fresh: WatchSnapshot) {
        // Latest-wins : un instantané retardataire ne doit pas écraser un
        // plus récent arrivé par un autre canal.
        if let current = snapshot, current.generatedAt > fresh.generatedAt { return }
        snapshot = fresh
        try? WatchSyncCodec.encode(fresh).write(to: cacheURL, options: [.atomic])
    }

    private static func loadCache(from url: URL) -> WatchSnapshot? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? WatchSyncCodec.decodeSnapshot(data)
    }

    /// La séance du jour, si elle n'a pas déjà été faite côté téléphone.
    var todaySession: PlannedSession? {
        guard let snapshot, let session = snapshot.session else { return nil }
        return snapshot.completedSessionIDs.contains(session.id) ? nil : session
    }

    var unit: UnitSystem { snapshot?.unit ?? .metric }
    var loadStepKg: Double { snapshot?.loadIncrement.stepKg ?? 2.5 }

    /// La langue du téléphone. La montre n'a pas de réglage propre.
    var language: Language { snapshot?.language ?? .french }

    /// La sortie du jour, si elle n'a pas déjà été enregistrée.
    var todayRun: PlannedRun? {
        guard let snapshot, !snapshot.runDone else { return nil }
        return snapshot.plannedRun
    }

    /// La sortie du jour a-t-elle déjà été enregistrée ?
    var runDone: Bool { snapshot?.runDone ?? false }

    // MARK: - Séance

    /// L'application de la montre est-elle ouverte ?
    ///
    /// Lue dans l'instantané, jamais décidée ici : la montre n'a pas de
    /// StoreKit à interroger, et deux appareils qui décideraient chacun de
    /// leur côté finiraient par ne pas dire la même chose. Un instantané
    /// écrit avant l'abonnement — ou aucun instantané du tout — laisse tout
    /// ouvert : un poignet qui se verrouille faute de champ est le pire des
    /// accueils.
    var isUnlocked: Bool { snapshot?.plus ?? true }

    func startSession() {
        guard let session = todaySession else { return }
        activeSession = ActiveSession(session: session)
        // La séance de salle ouvre aussi sa session d'entraînement : c'est
        // ce qui fait vibrer le poignet à la fin du repos même écran
        // éteint, mesure le cardio entre les séries, et ferme les anneaux.
        Task { await workout.start(sport: .weightTraining) }
    }

    func finishActiveSession(at date: Date = Date()) {
        guard let active = activeSession else { return }
        Task { await workout.finish() }
        let log = active.log(finishedAt: date)
        if !log.sets.isEmpty {
            pendingUploads += 1
            link.send(log)
            // La séance est marquée faite localement sans attendre le
            // téléphone : l'instantané ne se régénère qu'à la prochaine
            // synchronisation.
            if var current = snapshot {
                current.completedSessionIDs.append(active.session.id)
                apply(currentWithNewerDate(current))
            }
        }
        activeSession = nil
    }

    /// Abandonne la séance en cours sans rien enregistrer.
    ///
    /// Une séance ouverte par erreur — ou qu'on décide de ne pas faire —
    /// ne doit pas obliger à enregistrer un entraînement qui n'a pas eu
    /// lieu. Les séries déjà validées sont perdues, et c'est le sens du
    /// mot « abandonner » : l'écran le demande deux fois avant.
    func discardActiveSession() {
        activeSession = nil
        workout.discard()
    }

    /// Remplace un exercice de la séance en cours au poignet.
    ///
    /// Le remplacement ne remonte pas au téléphone comme un changement de
    /// programme : c'est un incident de salle, pas une décision de bloc. Le
    /// journal, lui, portera le mouvement réellement exécuté.
    func substituteInActiveSession(prescription id: UUID, with exercise: Exercise) {
        guard var active = activeSession else { return }
        active.substitute(prescription: id, with: exercise)
        activeSession = active
    }

    // MARK: - Course

    /// Lance une sortie : la session d'entraînement, puis le GPS.
    ///
    /// La session d'abord, parce que c'est elle qui donne au GPS le droit
    /// de continuer écran éteint ; le GPS ensuite, et seulement pour ce qui
    /// se déplace — le tracker sait déjà ne rien allumer pour un rameur.
    func startActivity(sport: Sport, type: RunType) {
        tracker.start(sport: sport, type: type)
        Task { await workout.start(sport: sport) }
    }

    /// Une sortie est-elle en cours, écran de course quitté ou non ?
    var activityInProgress: Bool { tracker.isActive }

    /// Enregistre une sortie menée au poignet et la fait remonter.
    ///
    /// La trace complète part vers le téléphone : c'est lui qui tient
    /// l'historique, recalcule l'allure de seuil et reconstruit le bloc. La
    /// montre marque simplement la sortie faite pour ne pas la reproposer.
    func recordRun(_ log: ActivityLog) {
        pendingUploads += 1
        link.send(log)
        if var current = snapshot {
            current.runDone = true
            apply(currentWithNewerDate(current))
        }
    }

    private func currentWithNewerDate(_ snapshot: WatchSnapshot) -> WatchSnapshot {
        var copy = snapshot
        copy.generatedAt = Date()
        return copy
    }
}
