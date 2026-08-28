import Foundation

/// Ce que l'iPhone envoie à la montre.
///
/// La montre embarque MonCoachKit — catalogue et logique compris — mais pas
/// l'historique complet : elle reçoit un instantané de la journée, suffisant
/// pour mener une séance entière au poignet, téléphone au vestiaire.
public struct WatchSnapshot: Codable, Sendable, Equatable {
    /// Horodatage de fabrication : la montre garde le plus récent, rien d'autre.
    public var generatedAt: Date
    public var firstName: String
    public var unit: UnitSystem
    public var loadIncrement: LoadIncrement
    public var weekIndex: Int?
    public var isDeloadWeek: Bool
    public var readinessScore: Int
    public var readinessHeadline: LocalizedText
    /// La langue choisie sur le téléphone. La montre n'a pas de réglage à
    /// elle : elle parle la langue de l'athlète, pas celle de son poignet.
    public var language: Language
    /// La séance du jour, charges prescrites et forme du jour déjà appliquées.
    /// Nil un jour de repos ou une fois le bloc terminé.
    public var session: PlannedSession?
    /// Identifiants des séances du jour déjà enregistrées côté téléphone,
    /// pour que la montre ne propose pas de refaire une séance faite.
    public var completedSessionIDs: [UUID]
    public var calories: Int
    public var proteinG: Int

    public init(
        generatedAt: Date,
        firstName: String,
        unit: UnitSystem,
        loadIncrement: LoadIncrement,
        weekIndex: Int?,
        isDeloadWeek: Bool,
        readinessScore: Int,
        readinessHeadline: LocalizedText,
        language: Language = .french,
        session: PlannedSession?,
        completedSessionIDs: [UUID],
        calories: Int,
        proteinG: Int
    ) {
        self.generatedAt = generatedAt
        self.firstName = firstName
        self.unit = unit
        self.loadIncrement = loadIncrement
        self.weekIndex = weekIndex
        self.isDeloadWeek = isDeloadWeek
        self.readinessScore = readinessScore
        self.readinessHeadline = readinessHeadline
        self.language = language
        self.session = session
        self.completedSessionIDs = completedSessionIDs
        self.calories = calories
        self.proteinG = proteinG
    }
}

/// Sérialisation des échanges téléphone ↔ montre.
///
/// WatchConnectivity ne transporte que des dictionnaires de types plist ;
/// tout passe donc en `Data` JSON sous une clé versionnée. Le codec vit dans
/// le paquet pour être testé — c'est le contrat entre les deux appareils, et
/// un contrat non testé finit toujours par se rompre en silence.
public enum WatchSyncCodec {
    /// Clé du dictionnaire WatchConnectivity portant un instantané.
    public static let snapshotKey = "moncoach.snapshot.v1"
    /// Clé portant une séance terminée remontée par la montre.
    public static let sessionLogKey = "moncoach.sessionlog.v1"

    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public static func encode(_ snapshot: WatchSnapshot) throws -> Data {
        try encoder.encode(snapshot)
    }

    public static func decodeSnapshot(_ data: Data) throws -> WatchSnapshot {
        try decoder.decode(WatchSnapshot.self, from: data)
    }

    public static func encode(_ log: SessionLog) throws -> Data {
        try encoder.encode(log)
    }

    public static func decodeSessionLog(_ data: Data) throws -> SessionLog {
        try decoder.decode(SessionLog.self, from: data)
    }
}

@MainActor
extension CoachStore {

    /// Fabrique l'instantané du jour pour la montre.
    public func watchSnapshot(on date: Date = Date(), calendar: Calendar = .current) -> WatchSnapshot? {
        guard let profile, let program else { return nil }
        let briefing = CoachEngine.briefing(for: program, history: history, on: date, calendar: calendar)

        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date
        let completedToday = history
            .sessions(in: DateInterval(start: dayStart, end: dayEnd))
            .compactMap(\.plannedSessionID)

        return WatchSnapshot(
            generatedAt: date,
            firstName: profile.firstName,
            unit: profile.unit,
            loadIncrement: profile.loadIncrement,
            weekIndex: briefing.weekIndex,
            isDeloadWeek: briefing.isDeloadWeek,
            readinessScore: briefing.readiness.score,
            readinessHeadline: briefing.readiness.headline,
            language: language,
            session: briefing.session,
            completedSessionIDs: completedToday,
            calories: briefing.nutrition.calories,
            proteinG: briefing.nutrition.proteinG
        )
    }

    /// Intègre une séance terminée au poignet.
    ///
    /// WatchConnectivity garantit la livraison mais pas l'unicité : une même
    /// séance peut arriver deux fois. L'identifiant du journal fait foi — la
    /// version la plus récente remplace l'ancienne, jamais ne s'y ajoute.
    public func receiveFromWatch(_ log: SessionLog) {
        // Une séance vide et non déclarée sautée n'apporte rien : c'est une
        // séance ouverte puis abandonnée sur la montre.
        guard !log.sets.isEmpty || log.skipped else { return }
        mergeSession(log)
    }
}
