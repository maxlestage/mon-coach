import Foundation
import Observation

/// Everything the app persists between launches.
///
/// Derived numbers — metrics, macros, load suggestions — are deliberately
/// absent: they are recomputed from the profile on every launch so they can
/// never drift from the formulas. The mesocycle *is* stored, because the
/// training log points at its session identifiers.
public struct PersistedState: Codable, Sendable {
    public var profile: UserProfile?
    public var plan: Mesocycle?
    public var history: TrainingHistory
    /// Les segments découpés par l'athlète.
    public var segments: [Segment]
    /// Les parcours préparés à l'avance.
    public var routes: [PlannedRoute]
    /// Le jour de la première ouverture, qui fait courir l'essai.
    ///
    /// Gardé dans l'état plutôt que dans les réglages de l'appareil : c'est
    /// une date qui engage, et elle doit voyager avec l'export comme le
    /// reste. Absente des fichiers écrits avant l'abonnement — ceux-là
    /// commencent leur essai à la première ouverture qui suit.
    public var trialStartedAt: Date?
    /// Ce que l'athlète a appris à l'application sur les mots du
    /// classificateur : « pastry » est chez lui une viennoiserie, « curry »
    /// du riz basmati. Une table personnelle, qui passe devant la table
    /// commune et qui voyage avec l'export.
    public var plateCorrections: [String: String]
    /// Ce que l'athlète a accepté d'entendre, et à quelle heure.
    ///
    /// Gardé dans l'état plutôt que dans les réglages de l'appareil : c'est
    /// un choix qui lui appartient, et il doit partir avec l'export comme le
    /// reste. Absent des fichiers écrits avant les rappels — ceux-là
    /// repartent silencieux, ce qui est la seule valeur par défaut honnête
    /// pour une notification.
    public var reminders: ReminderSettings

    public init(
        profile: UserProfile?,
        plan: Mesocycle?,
        history: TrainingHistory,
        segments: [Segment] = [],
        routes: [PlannedRoute] = [],
        trialStartedAt: Date? = nil,
        plateCorrections: [String: String] = [:],
        reminders: ReminderSettings = .off
    ) {
        self.profile = profile
        self.plan = plan
        self.history = history
        self.segments = segments
        self.routes = routes
        self.trialStartedAt = trialStartedAt
        self.plateCorrections = plateCorrections
        self.reminders = reminders
    }

    /// Les segments sont arrivés après coup : un fichier écrit avant eux
    /// n'a pas la clé, et exiger sa présence rendrait tout l'historique
    /// illisible d'un coup.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decodeIfPresent(UserProfile.self, forKey: .profile)
        plan = try container.decodeIfPresent(Mesocycle.self, forKey: .plan)
        history = try container.decode(TrainingHistory.self, forKey: .history)
        segments = try container.decodeIfPresent([Segment].self, forKey: .segments) ?? []
        routes = try container.decodeIfPresent([PlannedRoute].self, forKey: .routes) ?? []
        trialStartedAt = try container.decodeIfPresent(Date.self, forKey: .trialStartedAt)
        plateCorrections = try container.decodeIfPresent([String: String].self, forKey: .plateCorrections) ?? [:]
        reminders = try container.decodeIfPresent(ReminderSettings.self, forKey: .reminders) ?? .off
    }

    public static let empty = PersistedState(profile: nil, plan: nil, history: .empty)
}

/// The app's single source of truth.
///
/// It owns the athlete's profile, the current block and the training log, and
/// it is the only place that talks to `MonCoachKit`. Views read from it and
/// call intents on it; they never run coaching logic themselves.
@MainActor
@Observable
public final class CoachStore {

    public private(set) var profile: UserProfile?
    public private(set) var plan: Mesocycle?
    public private(set) var history: TrainingHistory = .empty
    /// Les mots du classificateur que l'athlète a lui-même traduits.
    ///
    /// C'est la seule partie du détecteur qui apprend, et elle n'apprend
    /// que ce qu'on lui dit explicitement : deviner une traduction à partir
    /// d'une correction de portion reviendrait à inventer une règle sur un
    /// geste qui voulait dire autre chose.
    public private(set) var plateCorrections: [String: String] = [:]
    /// Les segments que l'athlète a découpés, du plus récent au plus ancien.
    public private(set) var segments: [Segment] = []
    /// Les parcours préparés, du plus récent au plus ancien.
    public private(set) var routes: [PlannedRoute] = []

    /// The session the athlete is currently performing, if any.
    public var activeSession: ActiveSession?

    /// Surfaces a write failure to the UI instead of swallowing it — losing a
    /// training log silently is the one thing this app must not do.
    public private(set) var saveError: LocalizedText?

    /// Le jour de la première ouverture. Voir `startTrialIfNeeded`.
    public private(set) var trialStartedAt: Date?

    /// Ce que l'athlète a accepté d'entendre. Silencieux tant qu'il n'a rien
    /// dit : une notification qu'on n'a pas demandée est une notification de
    /// trop, et la première coupe le son pour toutes les suivantes.
    public private(set) var reminders: ReminderSettings = .off
    /// Ce que l'App Store a constaté au dernier passage. Jamais persisté :
    /// un droit d'accès qu'on garderait sur le disque serait un droit qu'on
    /// pourrait s'accorder soi-même, et il se relit de toute façon en une
    /// fraction de seconde au lancement.
    public private(set) var isSubscribed = false

    private let storage: StateStorage
    /// Les photos des sorties, en fichiers à côté de l'état.
    public let photos: PhotoStore

    public init(
        storage: StateStorage = .applicationSupport(),
        photos: PhotoStore = .applicationSupport()
    ) {
        self.storage = storage
        self.photos = photos
        let state = storage.load()
        profile = state.profile
        plan = state.plan
        history = state.history
        segments = state.segments
        routes = state.routes
        trialStartedAt = state.trialStartedAt
        plateCorrections = state.plateCorrections
        reminders = state.reminders
    }

    /// Change les rappels, et les réécrit aussitôt.
    ///
    /// Rien n'est posé ici : le magasin ne connaît pas les notifications du
    /// système, et il ne doit pas les connaître — c'est ce qui permet de le
    /// tester sur n'importe quelle machine. Il rend la liste, l'application
    /// la pose.
    public func setReminders(_ settings: ReminderSettings) {
        reminders = settings
        save()
    }

    /// Attache une photo à la pesée d'un jour, et rend son identifiant.
    ///
    /// Elle rejoint la pesée du jour si elle existe ; sinon on en crée une,
    /// au poids connu. Photographier sans se peser doit rester possible :
    /// quelqu'un qui suit son corps à l'œil n'a pas à monter sur une balance
    /// pour que l'application accepte son image.
    @discardableResult
    public func addBodyPhoto(
        _ data: Data, on date: Date = Date(), calendar: Calendar = .current
    ) -> String? {
        guard let identifier = try? photos.save(data) else { return nil }
        if let index = history.bodyLogs.firstIndex(where: {
            calendar.isDate($0.date, inSameDayAs: date)
        }) {
            history.bodyLogs[index].photoIDs.append(identifier)
        } else {
            history.bodyLogs.append(
                BodyLog(
                    date: date,
                    weightKg: profile?.weightKg ?? 0,
                    photoIDs: [identifier]
                )
            )
            history.bodyLogs.sort { $0.date < $1.date }
        }
        save()
        return identifier
    }

    /// Retire une photo de progression, du disque comme du journal.
    public func removeBodyPhoto(_ identifier: String) {
        for index in history.bodyLogs.indices {
            history.bodyLogs[index].photoIDs.removeAll { $0 == identifier }
        }
        photos.delete(identifier)
        save()
    }

    /// Les deux photos qui montrent quelque chose, s'il y en a.
    public func bodyComparison(on date: Date = Date()) -> BodyComparison? {
        BodyProgress.comparison(in: history.bodyLogs, on: date)
    }

    /// Toutes les photos de progression, de la plus récente à la plus
    /// ancienne, avec la pesée qui les porte.
    public var bodyPhotos: [(log: BodyLog, photoID: String)] {
        history.bodyLogs
            .sorted { $0.date > $1.date }
            .flatMap { log in log.photoIDs.map { (log, $0) } }
    }

    /// Comment reprendre, si l'athlète revient d'un arrêt.
    ///
    /// Nil quand il n'y a rien à signaler — c'est le cas le plus fréquent, et
    /// une carte « tu reviens de loin » affichée à quelqu'un qui s'entraîne
    /// tous les mardis serait la meilleure façon de lui apprendre à ignorer
    /// les cartes.
    public func returnPlan(on date: Date = Date()) -> ReturnToTraining? {
        ReturnPlanner.plan(history: history, on: date)
    }

    /// Les rappels à poser en l'état actuel des choses.
    public func plannedReminders(from now: Date = Date()) -> [Reminder] {
        ReminderPlanner.plan(
            program: program, history: history, settings: reminders, from: now
        )
    }

    /// Fait courir l'essai à partir d'aujourd'hui, une seule fois.
    ///
    /// Appelé au lancement. La date n'est jamais réécrite : réinstaller
    /// l'application ne redonne pas quatorze jours, et une horloge avancée
    /// puis remise à l'heure ne les reprend pas non plus.
    @discardableResult
    public func startTrialIfNeeded(on date: Date = Date()) -> Date {
        if let trialStartedAt { return trialStartedAt }
        trialStartedAt = date
        save()
        return date
    }

    /// Enregistre ce que l'App Store dit de l'abonnement.
    ///
    /// Le magasin ne décide de rien : il constate. L'entitlement vient de
    /// StoreKit, qui vit dans l'application parce qu'il n'existe pas
    /// ailleurs, et il est simplement déposé ici pour que tous les écrans
    /// lisent la même réponse.
    public func setSubscribed(_ subscribed: Bool) {
        isSubscribed = subscribed
    }

    /// L'état d'accès, tel que les écrans doivent le lire.
    public var subscription: SubscriptionStatus {
        SubscriptionStatus(trialStartedAt: trialStartedAt, isSubscribed: isSubscribed)
    }

    /// Cette fonctionnalité est-elle ouverte aujourd'hui ?
    public func isUnlocked(_ feature: PlusFeature, on date: Date = Date()) -> Bool {
        subscription.isUnlocked(feature, on: date)
    }

    // MARK: - Derived state

    public var isOnboarded: Bool { profile != nil && plan != nil }

    /// La langue dans laquelle tout le texte du coach est rendu.
    ///
    /// Le profil peut la fixer explicitement ; sinon on suit le système. Un
    /// athlète qui n'a jamais touché au réglage doit voir l'application
    /// changer de langue quand il change celle de son téléphone.
    public var language: Language {
        profile?.language ?? CoachStore.systemLanguage
    }

    /// La langue du système, résolue une fois.
    public static let systemLanguage: Language = Language.best(matching: Locale.preferredLanguages)

    /// Fixe la langue, ou revient à celle du système avec `nil`.
    public func setLanguage(_ language: Language?) {
        guard var profile else { return }
        profile.language = language
        self.profile = profile
        save()
    }

    public var program: CoachingProgram? {
        guard let profile, let plan else { return nil }
        return CoachEngine.program(profile: profile, plan: plan)
    }

    public func briefing(on date: Date = Date()) -> TodayBriefing? {
        guard let program else { return nil }
        return CoachEngine.briefing(for: program, history: history, on: date)
    }

    /// The week the athlete is currently in, 1-based, or nil once the block is over.
    public func currentWeekIndex(on date: Date = Date()) -> Int? {
        plan?.weekIndex(for: date)
    }

    public func review(weekIndex: Int) -> WeeklyReview? {
        guard let program else { return nil }
        return CoachEngine.weeklyReview(program: program, history: history, weekIndex: weekIndex)
    }

    /// Insights for the most recently completed week, which is what the Today
    /// screen shows — reviewing the week you are still in says nothing useful.
    public func latestInsights(on date: Date = Date()) -> [CoachInsight] {
        guard let current = currentWeekIndex(on: date), current > 1 else { return [] }
        return review(weekIndex: current - 1)?.insights ?? []
    }

    // MARK: - Intents

    public func completeOnboarding(with profile: UserProfile, startingOn date: Date = Date()) {
        let program = CoachEngine.buildProgram(for: profile, startingOn: date)
        self.profile = program.profile
        self.plan = program.plan
        history = .empty
        save()
    }

    /// Applies a profile edit and rebuilds the block around it.
    ///
    /// The training log is kept: it belongs to the athlete, not to the plan,
    /// and progression on every movement that survives the rebuild carries over.
    public func updateProfile(_ updated: UserProfile, rebuildingFrom date: Date = Date()) {
        let program = CoachEngine.buildProgram(for: updated, startingOn: date)
        profile = program.profile
        plan = program.plan
        save()
    }

    /// Écarte un aliment des repas à venir, ou le rétablit.
    ///
    /// Ne passe pas par `updateProfile`, et c'est le point important : celui-là
    /// reconstruit le mésocycle, ce qui effacerait les séances déjà planifiées
    /// et les charges déjà atteintes. Un dégoût alimentaire n'a aucune raison
    /// de coûter un bloc d'entraînement. Le plan de repas, lui, se recalcule à
    /// chaque lecture depuis le profil : écrire le profil suffit.
    ///
    /// Rend `false` quand le refus est écarté parce qu'il viderait le rôle —
    /// l'écran doit le dire plutôt que laisser une journée impossible à
    /// construire.
    @discardableResult
    public func refuseFood(_ foodID: String) -> Bool {
        guard var profile else { return false }
        var refused = profile.dislikedFoodIDs ?? []
        guard !refused.contains(foodID) else { return true }
        guard FoodSubstitutions.canRefuse(
            foodID,
            diet: profile.dietPreference,
            alreadyExcluded: refused
        ) else { return false }
        refused.insert(foodID)
        profile.dislikedFoodIDs = refused
        self.profile = profile
        save()
        return true
    }

    /// Rétablit un aliment refusé. Le goût change, et se dédire doit coûter
    /// un seul geste.
    public func allowFood(_ foodID: String) {
        guard var profile, var refused = profile.dislikedFoodIDs, refused.contains(foodID)
        else { return }
        refused.remove(foodID)
        profile.dislikedFoodIDs = refused
        self.profile = profile
        save()
    }

    public func recordReadiness(_ check: ReadinessCheck) {
        history.readiness.removeAll { Calendar.current.isDate($0.date, inSameDayAs: check.date) }
        history.readiness.append(check)
        save()
    }

    public func recordBodyLog(_ log: BodyLog) {
        history.bodyLogs.removeAll { Calendar.current.isDate($0.date, inSameDayAs: log.date) }
        history.bodyLogs.append(log)
        // The profile's weight is what every calorie and load estimate reads,
        // so a fresh weigh-in updates it too.
        if var profile, Calendar.current.isDateInToday(log.date) {
            profile.weightKg = log.weightKg
            profile.bodyFatPercent = log.bodyFatPercent ?? profile.bodyFatPercent
            self.profile = profile
        }
        save()
    }

    /// Adopte ce que Santé sait et que le journal ignore.
    ///
    /// Rend ce qui a été pris, pour que l'écran puisse le dire. Un import
    /// muet qui ajoute quatorze lignes au journal est indiscernable d'un
    /// bogue — et un import qui n'ajoute rien parce que tout y était déjà
    /// doit le dire aussi, sinon il ressemble à un échec.
    @discardableResult
    public func importFromHealth(
        weights: [HealthWeight],
        nights: [HealthSleep],
        workouts: [HealthWorkout],
        ourSourceNames: Set<String>,
        calendar: Calendar = .current
    ) -> (weights: Int, activities: Int) {
        let bodyLogs = HealthImport.newBodyLogs(
            from: weights, existing: history.bodyLogs, calendar: calendar
        )
        let activities = HealthImport.newActivities(
            from: workouts, existing: history.activities, ourSourceNames: ourSourceNames
        )
        guard !bodyLogs.isEmpty || !activities.isEmpty else { return (0, 0) }

        history.bodyLogs.append(contentsOf: bodyLogs)
        history.bodyLogs.sort { $0.date < $1.date }
        history.activities.append(contentsOf: activities)
        history.activities.sort { $0.startedAt > $1.startedAt }
        healthNights = nights
        save()
        return (bodyLogs.count, activities.count)
    }

    /// Les nuits lues au dernier import, gardées en mémoire seulement.
    ///
    /// Elles servent à pré-remplir le bilan de forme du jour, et rien de
    /// plus. Les écrire sur le disque ferait une deuxième copie d'une donnée
    /// de santé qui vit déjà dans Santé, où elle est mieux protégée que
    /// partout ailleurs — et l'export en porterait une troisième.
    public private(set) var healthNights: [HealthSleep] = []

    /// Les heures dormies cette nuit, si Santé les connaît.
    public func measuredSleepHours(
        on day: Date = Date(), calendar: Calendar = .current
    ) -> Double? {
        HealthImport.sleepHours(on: day, from: healthNights, calendar: calendar)
    }

    /// Fusionne les doublons déjà enregistrés, et rend combien ont disparu.
    ///
    /// Appelé au lancement. La règle est celle de l'enregistrement, appliquée
    /// à ce qui est déjà là : un journal constitué avant qu'elle existe porte
    /// les doublons qu'elle empêche désormais — et ces doublons-là comptent
    /// leurs kilomètres deux fois dans le volume de la semaine et dans la
    /// charge, donc ils faussent le plan, pas seulement l'affichage.
    ///
    /// Rien ne se perd : la fusion garde la mesure la plus riche et reprend
    /// sur elle ce que l'autre portait — note, ressenti, photos, matériel.
    /// Files a finished activity, and lets it teach the coach something.
    ///
    /// A tempo run, an interval session or a race says where the threshold
    /// actually sits. When the new evidence is better than what the profile
    /// holds, the profile is updated and the block is rebuilt around the real
    /// pace — otherwise every prescribed pace would stay wrong all block.
    /// Une sortie vélo ou une randonnée est archivée comme les autres, mais
    /// `demonstratedThresholdPace` ne la regarde pas.
    @discardableResult
    public func mergeDuplicateActivities() -> Int {
        let sorted = history.activities.sorted { $0.startedAt < $1.startedAt }
        var kept: [ActivityLog] = []
        var merged = 0
        for activity in sorted {
            if let index = kept.firstIndex(where: { $0.describesSameOuting(as: activity) }) {
                let winner = kept[index].measurementRichness >= activity.measurementRichness
                    ? Self.merged(keeping: kept[index], from: activity)
                    : Self.merged(keeping: activity, from: kept[index])
                kept[index] = winner
                merged += 1
            } else {
                kept.append(activity)
            }
        }
        guard merged > 0 else { return 0 }
        history.activities = kept
        save()
        return merged
    }

    /// Reprend, sur l'enregistrement gardé, ce que le doublon portait en
    /// plus. Rien n'est écrasé : ce qui est déjà renseigné gagne.
    static func merged(keeping kept: ActivityLog, from other: ActivityLog) -> ActivityLog {
        var result = kept
        if result.note == nil { result.note = other.note }
        if result.perceivedEffort == nil { result.perceivedEffort = other.perceivedEffort }
        if result.gearID == nil { result.gearID = other.gearID }
        if result.heartRate.isEmpty { result.heartRate = other.heartRate }
        if result.bestEfforts == nil { result.bestEfforts = other.bestEfforts }
        // Les photos des deux, sans doublon : elles sont sur le disque, et
        // en perdre une la rendrait introuvable pour toujours.
        for photoID in other.photoIDs where !result.photoIDs.contains(photoID) {
            result.photoIDs.append(photoID)
        }
        // Une distance mesurée l'emporte sur une absence de distance : une
        // séance de tapis remontée sans distance ne doit pas effacer celle
        // que l'athlète avait recopiée.
        if result.meters == 0, other.meters > 0 {
            result.meters = other.meters
            result.duration = Swift.max(result.duration, other.duration)
        }
        return result
    }

    public func recordRun(_ run: ActivityLog) {
        var run = run
        // Le matériel suit tout seul : la sortie prend le dernier matériel
        // utilisé pour ce sport, sauf si elle en déclare déjà un. Personne
        // ne choisit ses chaussures dans un menu après chaque footing.
        if run.gearID == nil {
            run.gearID = GearTracker.suggested(
                for: run.sport,
                among: history.gear,
                activities: history.activities
            )?.id
        }
        // La même sortie ne rentre pas deux fois.
        //
        // L'identifiant ne suffisait pas : un GPX réimporté en reçoit un
        // neuf, et le journal affichait la sortie en double — kilomètres
        // comptés deux fois dans le volume de la semaine, et dans la charge.
        // On écarte donc aussi ce qui décrit la même sortie, en gardant
        // l'enregistrement le mieux mesuré des deux et ce que l'autre
        // portait en plus : une note, un ressenti, des photos se perdraient
        // sans ça.
        let twins = history.activities.filter { $0.id != run.id && $0.describesSameOuting(as: run) }
        if let best = twins.max(by: { $0.measurementRichness < $1.measurementRichness }),
           best.measurementRichness > run.measurementRichness {
            run = Self.merged(keeping: best, from: run)
        } else {
            for twin in twins { run = Self.merged(keeping: run, from: twin) }
        }
        let twinIDs = Set(twins.map(\.id))
        history.activities.removeAll { $0.id == run.id || twinIDs.contains($0.id) }
        history.activities.append(run)
        history.activities.sort { $0.startedAt < $1.startedAt }

        if var profile, var running = profile.running,
           let demonstrated = history.demonstratedThresholdPace() {
            let known = running.thresholdPaceSecondsPerKm
            // Lower is faster: only a genuinely better performance moves it.
            if known == nil || demonstrated < (known ?? .greatestFiniteMagnitude) {
                running.thresholdPaceSecondsPerKm = demonstrated
                profile.running = running
                self.profile = profile
            }
        }
        save()
    }

    /// Removes an activity the athlete decided was not theirs — a phantom
    /// trace, a forgotten stop, a ride recorded by mistake.
    public func deleteRun(_ id: UUID) {
        // Les photos partent avec la sortie : elles n'ont plus rien à
        // désigner, et personne ne pourrait plus les atteindre pour les
        // effacer.
        for photoID in history.activities.first(where: { $0.id == id })?.photoIDs ?? [] {
            photos.delete(photoID)
        }
        history.activities.removeAll { $0.id == id }
        save()
    }

    // MARK: - Matériel

    /// Ajoute un matériel au parc et le rend, prêt à être proposé.
    @discardableResult
    public func addGear(name: String, kind: Gear.Kind) -> Gear {
        let gear = Gear(name: name, kind: kind)
        history.gear.append(gear)
        save()
        return gear
    }

    /// Met un matériel à la retraite. Son histoire reste : les sorties
    /// faites avec ne changent pas de chaussures.
    public func retireGear(_ id: UUID) {
        guard let index = history.gear.firstIndex(where: { $0.id == id }) else { return }
        history.gear[index].retiredAt = Date()
        save()
    }

    /// Change le matériel d'une sortie déjà enregistrée — ou le retire
    /// avec nil. C'est le geste de rattrapage : « ah non, ce jour-là
    /// j'avais les autres ».
    public func assignGear(_ gearID: UUID?, toActivity activityID: UUID) {
        guard let index = history.activities.firstIndex(where: { $0.id == activityID }) else { return }
        history.activities[index].gearID = gearID
        save()
    }

    // MARK: - Photos

    /// Attache une photo à une sortie et rend son identifiant.
    ///
    /// Les octets arrivent déjà compressés : la compression a besoin
    /// d'UIKit, qui n'a rien à faire dans le moteur. L'ordre compte —
    /// le fichier est écrit avant que l'identifiant entre dans l'état, faute
    /// de quoi un échec d'écriture laisserait une sortie qui réclame une
    /// photo introuvable.
    @discardableResult
    public func addPhoto(_ data: Data, to activityID: UUID) -> String? {
        guard let index = history.activities.firstIndex(where: { $0.id == activityID }),
              let photoID = try? photos.save(data)
        else { return nil }
        history.activities[index].photoIDs.append(photoID)
        save()
        return photoID
    }

    /// Retire une photo d'une sortie, et l'efface du disque.
    public func removePhoto(_ photoID: String, from activityID: UUID) {
        guard let index = history.activities.firstIndex(where: { $0.id == activityID })
        else { return }
        history.activities[index].photoIDs.removeAll { $0 == photoID }
        photos.delete(photoID)
        save()
    }

    // MARK: - Les assiettes

    /// Enregistre une assiette estimée, photo comprise.
    ///
    /// Le fichier est écrit avant que l'estimation entre dans l'état, pour
    /// la même raison que les photos de sortie : une estimation qui réclame
    /// une image introuvable est un écran cassé.
    @discardableResult
    public func recordPlate(_ estimate: PlateEstimate, photo: Data? = nil) -> PlateEstimate {
        var stored = estimate
        if let photo, let photoID = try? photos.save(photo) {
            stored.photoID = photoID
        }
        history.plates.append(stored)
        save()
        return stored
    }

    /// Oublie une assiette, et efface sa photo.
    public func deletePlate(at date: Date) {
        for plate in history.plates where plate.date == date {
            if let photoID = plate.photoID { photos.delete(photoID) }
        }
        history.plates.removeAll { $0.date == date }
        save()
    }

    /// Les assiettes d'un jour, de la plus ancienne à la plus récente.
    public func plates(on day: Date, calendar: Calendar = .current) -> [PlateEstimate] {
        history.plates
            .filter { calendar.isDate($0.date, inSameDayAs: day) }
            .sorted { $0.date < $1.date }
    }

    /// Ce qu'on a réellement mangé aujourd'hui, d'après les assiettes
    /// photographiées. Nul quand aucune n'a été prise — et c'est alors
    /// « rien de mesuré », pas « rien de mangé ».
    public func eatenToday(on day: Date = Date(), calendar: Calendar = .current) -> Macros? {
        let today = plates(on: day, calendar: calendar)
        guard !today.isEmpty else { return nil }
        return today.map(\.macros).reduce(Macros.zero, +)
    }

    /// Remplace les aliments d'une assiette déjà enregistrée.
    ///
    /// Une assiette se corrige après coup : on se souvient à 22 h qu'il y
    /// avait aussi du fromage. Sans cela, il fallait la supprimer et la
    /// refaire, photo comprise — et la photo, elle, ne se refait pas.
    public func updatePlate(at date: Date, items: [PlateItem]) {
        guard let index = history.plates.firstIndex(where: { $0.date == date }) else { return }
        history.plates[index].items = items
        save()
    }

    /// Les assiettes des `days` derniers jours, de la plus récente à la plus
    /// ancienne.
    public func recentPlates(days: Int = 30, from day: Date = Date(), calendar: Calendar = .current) -> [PlateEstimate] {
        guard let start = calendar.date(byAdding: .day, value: -(days - 1), to: calendar.startOfDay(for: day))
        else { return [] }
        return history.plates
            .filter { $0.date >= start }
            .sorted { $0.date > $1.date }
    }

    /// Retient qu'une étiquette du système désigne cet aliment-là.
    ///
    /// C'est ce qui rend le détecteur meilleur avec le temps sans qu'aucune
    /// donnée ne quitte le téléphone : le mot appris passe devant la table
    /// commune, pour toutes les photos suivantes.
    public func learnPlateLabel(_ label: String, as foodID: String) {
        let key = PlateVision.normalised(label)
        guard !key.isEmpty, FoodCatalog.food(id: foodID) != nil else { return }
        plateCorrections[key] = foodID
        save()
    }

    /// Oublie une traduction apprise — on se trompe aussi en apprenant.
    public func forgetPlateLabel(_ label: String) {
        plateCorrections.removeValue(forKey: PlateVision.normalised(label))
        save()
    }

    /// Tout ce qu'une photo a donné, avec ce que le magasin sait en plus :
    /// les aliments écartés du plan, les traductions apprises et les
    /// portions habituelles.
    ///
    /// Les vues ne rassemblent pas ces trois-là elles-mêmes : elles
    /// oublieraient l'une des trois un jour, et la reconnaissance serait
    /// bonne à un endroit et médiocre à un autre.
    public func analysePlate(_ readings: [PlateReading], on date: Date = Date()) -> PlateAnalysis {
        PlateVision.analyse(
            readings,
            excluding: profile?.excludedFoods ?? [],
            corrections: plateCorrections,
            history: recentPlates(days: 90),
            expected: expectedFoods(on: date)
        )
    }

    /// Les aliments que le plan du jour a prescrits : l'a priori de la
    /// reconnaissance d'assiette. On mange le plus souvent ce qui était
    /// prévu, et le classificateur a le droit de le savoir.
    public func expectedFoods(on date: Date = Date()) -> Set<String> {
        guard let day = briefing(on: date)?.food else { return [] }
        return Set(day.meals.flatMap { meal in meal.items.map(\.foodID) })
    }

    /// Efface les fichiers d'image que plus aucune sortie ne réclame.
    ///
    /// Appelé au lancement : une suppression interrompue — l'application
    /// tuée entre l'écriture de l'état et celle du disque — laisserait
    /// sinon des images orphelines que rien ne pourrait plus atteindre.
    @discardableResult
    public func prunePhotos() -> Int {
        // Les assiettes comptent autant que les sorties : les oublier ici
        // effacerait leurs photos au lancement suivant, silencieusement.
        var kept = Set(history.activities.flatMap(\.photoIDs))
        kept.formUnion(history.plates.compactMap(\.photoID))
        // Les photos de progression aussi. Les oublier ici les effacerait au
        // lancement suivant, en silence — et ce sont les seules qu'on ne peut
        // pas refaire : une photo d'il y a six mois ne se reprend pas.
        kept.formUnion(history.bodyLogs.flatMap(\.photoIDs))
        return photos.prune(keeping: kept)
    }

    // MARK: - Parcours

    /// Garde un parcours préparé.
    ///
    /// Rend `false` quand le tracé est trop court pour être un parcours :
    /// l'écran doit le dire plutôt que de faire semblant d'avoir enregistré
    /// deux points posés par erreur.
    @discardableResult
    public func saveRoute(_ route: PlannedRoute) -> Bool {
        guard route.meters >= RoutePlanner.minimumMeters else { return false }
        if let index = routes.firstIndex(where: { $0.id == route.id }) {
            routes[index] = route
        } else {
            routes.insert(route, at: 0)
        }
        save()
        return true
    }

    public func deleteRoute(_ id: UUID) {
        routes.removeAll { $0.id == id }
        save()
    }

    public func renameRoute(_ id: UUID, to name: String) {
        guard let index = routes.firstIndex(where: { $0.id == id }), !name.isEmpty else { return }
        routes[index].name = name
        save()
    }

    /// Les parcours utilisables pour un sport donné.
    ///
    /// Un tour de vélo de soixante kilomètres proposé avant un footing
    /// serait au mieux du bruit ; à pied, en revanche, tout ce qui se marche
    /// se court, donc course, trail, marche et randonnée se partagent leurs
    /// parcours.
    public func routes(for sport: Sport) -> [PlannedRoute] {
        // Un parcours dessiné pour la marche se court très bien, et
        // l'inverse aussi : ce qui se fait avec les pieds se partage. Un
        // itinéraire de vélo, non — trente kilomètres de départementale ne
        // sont pas une sortie à pied, et une piste de VTT n'est pas une
        // route. La famille du sport tranche, plutôt qu'une liste de cas
        // qu'il faudrait rallonger à chaque sport ajouté.
        routes.filter { $0.sport == sport || $0.sport.family == sport.family }
    }

    /// Importe un fichier GPX comme parcours à suivre, pas comme sortie
    /// faite.
    ///
    /// C'est la différence avec `importGPX` : celui-là fabrique une activité
    /// et exige des horodatages. Un parcours téléchargé n'en a pas — il n'a
    /// jamais été couru.
    @discardableResult
    public func importRouteGPX(
        _ text: String,
        named fallbackName: String,
        fallbackSport: Sport = .run
    ) throws -> PlannedRoute? {
        let read = try GPX.readRoute(text)
        let route = PlannedRoute(
            name: read.name?.isEmpty == false ? read.name! : fallbackName,
            sport: read.sport ?? fallbackSport,
            points: RoutePlanner.thinned(read.points)
        )
        return saveRoute(route) ? route : nil
    }

    public func exportRouteGPX(_ route: PlannedRoute) -> String {
        GPX.document(for: route)
    }

    // MARK: - Import et export

    /// Ce qu'un import a donné.
    ///
    /// Deux issues et non une : réimporter le même fichier n'est pas une
    /// erreur — c'est même naturel quand on ne se souvient plus de ce qu'on
    /// a déjà rentré — mais l'annoncer comme une sortie de plus serait un
    /// mensonge, et laisserait croire à un doublon perdu.
    public enum ImportOutcome: Sendable {
        case imported(ActivityLog)
        case alreadyKnown(ActivityLog)

        public var activity: ActivityLog {
            switch self {
            case .imported(let log), .alreadyKnown(let log): log
            }
        }
    }

    /// Importe un fichier GPX dans l'historique.
    ///
    /// Le sport vient du fichier quand il en déclare un, du choix de
    /// l'athlète sinon. La trace est analysée comme une sortie enregistrée
    /// ici : mêmes filtres, mêmes records — un 5 km couru l'an dernier
    /// ailleurs compte dans l'histoire, c'est le but de l'import.
    @discardableResult
    public func importGPX(_ text: String, fallbackSport: Sport = .run) throws -> ImportOutcome {
        let imported = try GPX.read(text)
        let sport = imported.sport ?? fallbackSport
        var log = TraceAnalysis.summarise(rawPoints: imported.points, sport: sport, type: .easy)
        log.heartRate = imported.heartRate
        log.note = imported.name
        let known = history.activities.contains { $0.describesSameOuting(as: log) }
        recordRun(log)
        // La sortie gardée après fusion, pas celle qu'on vient de lire : ce
        // sont ses photos et son ressenti que l'écran doit montrer.
        let stored = history.activities.first { $0.describesSameOuting(as: log) } ?? log
        return known ? .alreadyKnown(stored) : .imported(stored)
    }

    /// L'activité au format GPX, prête à partir.
    public func exportGPX(_ activity: ActivityLog) -> String {
        GPX.document(for: activity)
    }

    // MARK: - Segments

    /// Découpe un segment dans une activité et le garde.
    ///
    /// Rend nil quand le morceau demandé est trop court pour vouloir dire
    /// quelque chose — l'écran doit le dire, pas faire semblant d'avoir créé
    /// un segment introuvable ensuite.
    @discardableResult
    public func createSegment(
        from activity: ActivityLog,
        name: String,
        startMeters: Double,
        endMeters: Double
    ) -> Segment? {
        guard let segment = SegmentMatching.carve(
            from: activity, name: name, startMeters: startMeters, endMeters: endMeters
        ) else { return nil }
        segments.insert(segment, at: 0)
        save()
        return segment
    }

    public func deleteSegment(_ id: UUID) {
        segments.removeAll { $0.id == id }
        save()
    }

    /// Le classement personnel d'un segment, du plus rapide au plus lent.
    public func leaderboard(for segment: Segment) -> [SegmentEffort] {
        SegmentMatching.leaderboard(of: segment, in: history.activities)
    }

    /// Les passages réalisés pendant une activité donnée.
    public func segmentEfforts(in activity: ActivityLog) -> [SegmentEffort] {
        SegmentMatching.efforts(of: segments, in: activity)
    }

    /// Les distinctions à annoncer après une sortie : records de distance
    /// d'abord, puis les segments où l'athlète vient de faire mieux.
    public func highlights(for activity: ActivityLog) -> [EffortRank] {
        BestEfforts.highlights(for: activity, against: history.activities)
    }

    public func startSession(_ session: PlannedSession) {
        activeSession = ActiveSession(session: session)
    }

    public func finishActiveSession(at date: Date = Date()) {
        guard let active = activeSession else { return }
        let log = active.log(finishedAt: date)
        // An abandoned session with nothing logged is not worth recording.
        if !log.sets.isEmpty {
            history.sessions.append(log)
            save()
        }
        activeSession = nil
    }

    /// Remplace ou ajoute un journal de séance, à l'identifiant près.
    ///
    /// C'est le point d'entrée des séances menées sur la montre :
    /// WatchConnectivity garantit la livraison mais pas l'unicité, et une
    /// même séance livrée deux fois doit écraser, jamais s'additionner.
    func mergeSession(_ log: SessionLog) {
        if let index = history.sessions.firstIndex(where: { $0.id == log.id }) {
            history.sessions[index] = log
        } else {
            history.sessions.append(log)
        }
        save()
    }

    public func skipTodaySession(at date: Date = Date()) {
        guard let session = briefing(on: date)?.session else { return }
        history.sessions.append(
            SessionLog(plannedSessionID: session.id, date: date, skipped: true)
        )
        save()
    }

    /// Ends the current block and builds the next one from what the last week
    /// actually showed.
    /// Rend `false` quand le bloc suivant demande un abonnement.
    ///
    /// Le bloc en cours n'est jamais interrompu : c'est le suivant qui
    /// attend. Laisser quelqu'un au milieu d'un bloc sans ses séances
    /// serait lui retirer un entraînement déjà commencé, ce qu'aucune
    /// frontière commerciale ne justifie.
    @discardableResult
    public func startNextBlock(on date: Date = Date()) -> Bool {
        guard isUnlocked(.nextBlocks, on: date) else { return false }
        guard let program, let weekIndex = currentWeekIndex(on: date) ?? plan?.weekCount
        else { return false }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: weekIndex)
        let next = CoachEngine.nextBlock(after: program, review: review, startingOn: date)
        profile = next.profile
        plan = next.plan
        save()
        return true
    }

    public func resetEverything() {
        profile = nil
        plan = nil
        history = .empty
        segments = []
        routes = []
        activeSession = nil
        photos.prune(keeping: [])
        save()
    }

    // MARK: - Persistence

    private func save() {
        let state = PersistedState(
            profile: profile, plan: plan, history: history, segments: segments, routes: routes,
            trialStartedAt: trialStartedAt, plateCorrections: plateCorrections,
            reminders: reminders
        )
        do {
            try storage.save(state)
            saveError = nil
        } catch {
            saveError = LocalizedText(
                fr: "Impossible d'enregistrer tes données : \(error.localizedDescription)",
                en: "Could not save your data: \(error.localizedDescription)",
                es: "No se han podido guardar tus datos: \(error.localizedDescription)"
            )
        }
    }

    /// Everything the athlete has entered, as JSON, for export.
    public func exportJSON() throws -> Data {
        try StateStorage.encoder.encode(
            PersistedState(
                profile: profile, plan: plan, history: history, segments: segments, routes: routes,
                trialStartedAt: trialStartedAt, plateCorrections: plateCorrections,
                reminders: reminders
            )
        )
    }
}
