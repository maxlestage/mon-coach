import Foundation
import WidgetKit
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

    /// L'écran que l'accueil doit ouvrir, ou nul s'il n'a rien à ouvrir.
    ///
    /// L'intention vit ici plutôt que dans la vue, parce qu'elle naît à
    /// deux endroits qui ne se voient pas : la liste des activités, qui
    /// démarre, et la bannière du haut, qui rouvre ce qui tourne déjà. Un
    /// drapeau posé par la vue ne savait dire que le premier cas — « une
    /// sortie vient de commencer » — et une sortie déjà commencée ne le
    /// faisait plus changer : la bannière était morte au toucher.
    ///
    /// Une route, elle, se repose à l'identique autant de fois qu'on veut.
    var route: Route?

    enum Route: Hashable { case activity, session }

    /// La session d'entraînement HealthKit, pour la séance comme pour les
    /// sorties. Une seule, tenue ici : c'est elle qui garde l'application
    /// éveillée, et elle doit survivre à l'écran qui l'a lancée.
    let workout = WatchWorkout()

    /// Séances terminées sur la montre, en attente de confirmation de départ
    /// vers le téléphone. WatchConnectivity garde sa propre file ; ceci ne
    /// sert qu'à l'affichage « en attente de synchronisation ».
    private(set) var pendingUploads: Int = 0

    private let link = PhoneLink()
    private var cacheURL: URL?
    /// Le réveil a-t-il déjà eu lieu ? Le rejouer relierait la montre au
    /// téléphone une seconde fois pour rien.
    private var awake = false

    /// Le GPS d'une sortie.
    ///
    /// Il vit ici et non dans l'écran de course : une vue qu'on quitte d'un
    /// glissement détruit son état, et un tracker détruit est une sortie
    /// perdue. L'accueil montre la sortie en cours et permet d'y revenir,
    /// comme pour la séance.
    let tracker = LocationTracker()

    /// Une sortie est-elle en cours, écran de course quitté ou non ?
    var activityInProgress: Bool { tracker.isActive }

    /// Rien ici ne fait de travail.
    ///
    /// L'init ouvrait le lien WatchConnectivity, lisait un cache sur
    /// disque et écrivait dans le conteneur partagé du cadran — trois
    /// choses qui parlent au système, exécutées avant que la première
    /// image ne soit dessinée. Une seule qui échoue, et l'application
    /// meurt au lancement : écran noir, aucune trace, rien à lire. C'est
    /// la forme exacte du défaut qu'on cherchait, et même si ce n'était
    /// pas celui-là, c'est une forme qu'il ne faut pas garder.
    ///
    /// Le magasin se construit donc sans rien demander à personne, et
    /// l'application s'affiche. Le réveil vient après, depuis l'écran, où
    /// un échec ne coûte qu'une fonction en moins.
    init() {}

    /// Relie la montre au téléphone, après la première image.
    ///
    /// Appelé depuis la vue racine. Idempotent : watchOS peut redessiner
    /// la racine sans que la montre ait à se reconnecter.
    func wakeUp() {
        guard !awake else { return }
        awake = true

        cacheURL = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ))?.appending(path: "watch-snapshot.json")

        if let cacheURL, let cached = Self.loadCache(from: cacheURL) {
            snapshot = cached
            pushToComplication(cached)
        }

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
        if let cacheURL { try? WatchSyncCodec.encode(fresh).write(to: cacheURL, options: [.atomic]) }
        pushToComplication(fresh)
    }

    /// Réécrit ce que le cadran affiche.
    ///
    /// La complication vit dans une extension : elle ne voit ni cette
    /// mémoire ni ce cache, seulement le fichier du groupe partagé. Sans
    /// cette ligne, le cadran resterait vide quoi que le téléphone envoie.
    private func pushToComplication(_ fresh: WatchSnapshot) {
        let store = WidgetSnapshotStore.shared()
        if store.save(WidgetSnapshot.make(watch: fresh)) {
            WidgetCenter.shared.reloadAllTimelines()
        }
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
        route = .session
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
        route = nil
    }

    /// Abandonne la séance en cours sans rien enregistrer.
    ///
    /// Une séance ouverte par erreur — ou qu'on décide de ne pas faire —
    /// ne doit pas obliger à enregistrer un entraînement qui n'a pas eu
    /// lieu. Les séries déjà validées sont perdues, et c'est le sens du
    /// mot « abandonner » : l'écran le demande deux fois avant.
    func discardActiveSession() {
        activeSession = nil
        route = nil
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
        route = .activity
        // La session d'entraînement d'abord, le GPS ensuite — et cette
        // fois dans cet ordre pour de bon. Le commentaire l'annonçait déjà,
        // le code faisait l'inverse : `tracker.start` était appelé tout de
        // suite et la session partait dans une tâche, donc après.
        //
        // L'ordre compte parce que c'est la session qui garde
        // l'application éveillée. Un suivi lancé avant elle demande le
        // droit de continuer écran éteint à un moment où rien ne le lui
        // donne encore.
        //
        // `workout.start` ne jette jamais : Santé refusé ou absent, elle
        // se déclare indisponible et rend la main. La sortie part donc
        // dans tous les cas, au GPS et au chrono.
        Task {
            await workout.start(sport: sport)
            tracker.start(sport: sport, type: type)
        }
    }

    /// Rouvre l'écran de ce qui tourne déjà, sans rien redémarrer.
    func reopenActivity() { route = .activity }

    func reopenSession() { route = .session }

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
