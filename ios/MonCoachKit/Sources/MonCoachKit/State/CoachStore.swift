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

    public init(
        profile: UserProfile?,
        plan: Mesocycle?,
        history: TrainingHistory,
        segments: [Segment] = [],
        routes: [PlannedRoute] = []
    ) {
        self.profile = profile
        self.plan = plan
        self.history = history
        self.segments = segments
        self.routes = routes
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
    /// Les segments que l'athlète a découpés, du plus récent au plus ancien.
    public private(set) var segments: [Segment] = []
    /// Les parcours préparés, du plus récent au plus ancien.
    public private(set) var routes: [PlannedRoute] = []

    /// The session the athlete is currently performing, if any.
    public var activeSession: ActiveSession?

    /// Surfaces a write failure to the UI instead of swallowing it — losing a
    /// training log silently is the one thing this app must not do.
    public private(set) var saveError: LocalizedText?

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

    /// Files a finished activity, and lets it teach the coach something.
    ///
    /// A tempo run, an interval session or a race says where the threshold
    /// actually sits. When the new evidence is better than what the profile
    /// holds, the profile is updated and the block is rebuilt around the real
    /// pace — otherwise every prescribed pace would stay wrong all block.
    /// Une sortie vélo ou une randonnée est archivée comme les autres, mais
    /// `demonstratedThresholdPace` ne la regarde pas.
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
        history.activities.removeAll { $0.id == run.id }
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

    /// Efface les fichiers d'image que plus aucune sortie ne réclame.
    ///
    /// Appelé au lancement : une suppression interrompue — l'application
    /// tuée entre l'écriture de l'état et celle du disque — laisserait
    /// sinon des images orphelines que rien ne pourrait plus atteindre.
    @discardableResult
    public func prunePhotos() -> Int {
        photos.prune(keeping: Set(history.activities.flatMap(\.photoIDs)))
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

    /// Importe un fichier GPX dans l'historique.
    ///
    /// Le sport vient du fichier quand il en déclare un, du choix de
    /// l'athlète sinon. La trace est analysée comme une sortie enregistrée
    /// ici : mêmes filtres, mêmes records — un 5 km couru l'an dernier
    /// ailleurs compte dans l'histoire, c'est le but de l'import.
    @discardableResult
    public func importGPX(_ text: String, fallbackSport: Sport = .run) throws -> ActivityLog {
        let imported = try GPX.read(text)
        let sport = imported.sport ?? fallbackSport
        var log = TraceAnalysis.summarise(rawPoints: imported.points, sport: sport, type: .easy)
        log.heartRate = imported.heartRate
        log.note = imported.name
        recordRun(log)
        return log
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
    public func startNextBlock(on date: Date = Date()) {
        guard let program, let weekIndex = currentWeekIndex(on: date) ?? plan?.weekCount else { return }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: weekIndex)
        let next = CoachEngine.nextBlock(after: program, review: review, startingOn: date)
        profile = next.profile
        plan = next.plan
        save()
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
            profile: profile, plan: plan, history: history, segments: segments, routes: routes
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
                profile: profile, plan: plan, history: history, segments: segments, routes: routes
            )
        )
    }
}
