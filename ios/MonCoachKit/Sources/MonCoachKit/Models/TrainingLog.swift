import Foundation

/// One set as it was actually performed.
public struct SetLog: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var date: Date
    public var exerciseID: String
    public var setIndex: Int
    public var weightKg: Double
    public var reps: Int
    /// Rate of perceived exertion, 5–10. 10 means no rep left in the tank.
    public var rpe: Double
    /// Raised when the athlete felt joint pain rather than muscular effort.
    public var painFlag: Bool

    public init(
        id: UUID = UUID(),
        date: Date,
        exerciseID: String,
        setIndex: Int,
        weightKg: Double,
        reps: Int,
        rpe: Double,
        painFlag: Bool = false
    ) {
        self.id = id
        self.date = date
        self.exerciseID = exerciseID
        self.setIndex = setIndex
        self.weightKg = weightKg
        self.reps = reps
        self.rpe = rpe.clamped(to: 5...10)
        self.painFlag = painFlag
    }

    /// Estimated 1RM for this set, RPE-aware.
    public var estimatedOneRepMax: Double {
        StrengthMath.estimatedOneRepMax(weightKg: weightKg, reps: reps, rpe: rpe)
    }
}

/// A session as it was actually performed. A session with no sets and
/// `skipped == true` is how a missed day is recorded.
public struct SessionLog: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var plannedSessionID: UUID?
    public var date: Date
    public var sets: [SetLog]
    public var durationMinutes: Int
    public var skipped: Bool
    public var note: String?

    public init(
        id: UUID = UUID(),
        plannedSessionID: UUID? = nil,
        date: Date,
        sets: [SetLog] = [],
        durationMinutes: Int = 0,
        skipped: Bool = false,
        note: String? = nil
    ) {
        self.id = id
        self.plannedSessionID = plannedSessionID
        self.date = date
        self.sets = sets
        self.durationMinutes = durationMinutes
        self.skipped = skipped
        self.note = note
    }

    public var totalVolumeKg: Double {
        sets.reduce(0) { $0 + $1.weightKg * Double($1.reps) }
    }

    public var hasPainFlag: Bool { sets.contains { $0.painFlag } }
}

/// A body-composition data point.
public struct BodyLog: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    public var weightKg: Double
    public var bodyFatPercent: Double?
    public var waistCm: Double?

    public init(
        id: UUID = UUID(),
        date: Date,
        weightKg: Double,
        bodyFatPercent: Double? = nil,
        waistCm: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.bodyFatPercent = bodyFatPercent
        self.waistCm = waistCm
    }
}

/// The 20-second questionnaire the athlete answers before training.
/// Feeds the daily load modifier.
public struct ReadinessCheck: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var date: Date
    /// 1 (horrible) – 5 (excellent)
    public var sleepQuality: Int
    /// 1 (aucune courbature) – 5 (très courbaturé)
    public var soreness: Int
    /// 1 (aucune envie) – 5 (à fond)
    public var motivation: Int
    /// 1 (serein) – 5 (sous l'eau)
    public var stress: Int
    public var sleepHours: Double?

    public init(
        id: UUID = UUID(),
        date: Date,
        sleepQuality: Int,
        soreness: Int,
        motivation: Int,
        stress: Int,
        sleepHours: Double? = nil
    ) {
        self.id = id
        self.date = date
        self.sleepQuality = sleepQuality.clamped(to: 1...5)
        self.soreness = soreness.clamped(to: 1...5)
        self.motivation = motivation.clamped(to: 1...5)
        self.stress = stress.clamped(to: 1...5)
        self.sleepHours = sleepHours
    }
}

/// Everything the adaptation engine reads. Kept as one value so the whole
/// review is a pure function of its input.
public struct TrainingHistory: Codable, Sendable, Equatable {
    public var sessions: [SessionLog]
    public var bodyLogs: [BodyLog]
    public var readiness: [ReadinessCheck]
    public var runs: [RunLog]

    public init(
        sessions: [SessionLog] = [],
        bodyLogs: [BodyLog] = [],
        readiness: [ReadinessCheck] = [],
        runs: [RunLog] = []
    ) {
        self.sessions = sessions
        self.bodyLogs = bodyLogs
        self.readiness = readiness
        self.runs = runs
    }

    public static let empty = TrainingHistory()

    public func sessions(in interval: DateInterval) -> [SessionLog] {
        sessions.filter { interval.contains($0.date) }
    }

    public func bodyLogs(in interval: DateInterval) -> [BodyLog] {
        bodyLogs.filter { interval.contains($0.date) }
    }

    public func runs(in interval: DateInterval) -> [RunLog] {
        runs.filter { interval.contains($0.startedAt) }
    }

    /// The run recorded on a given day, if there is one.
    public func run(on date: Date, calendar: Calendar = .current) -> RunLog? {
        runs
            .filter { calendar.isDate($0.startedAt, inSameDayAs: date) }
            .max { $0.startedAt < $1.startedAt }
    }

    /// Distance run over the seven days ending on `date`, in metres.
    public func weeklyRunMeters(endingOn date: Date, calendar: Calendar = .current) -> Double {
        guard let start = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: date)),
              let end = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))
        else { return 0 }
        return runs(in: DateInterval(start: start, end: end)).reduce(0) { $0 + $1.meters }
    }

    /// Best threshold pace the athlete has demonstrated, in seconds per km.
    ///
    /// Only tempo runs, intervals and races count: an easy run says nothing
    /// about the ceiling, and letting it in would make the estimate drift
    /// slower every week the athlete trains correctly.
    public func demonstratedThresholdPace() -> Double? {
        runs
            .filter { $0.meters >= 2_000 && [.tempo, .intervals, .race].contains($0.type) }
            .compactMap { RunMath.thresholdPace(fromDistance: $0.meters, time: $0.duration) }
            .min()
    }

    /// All logged sets for an exercise, oldest first.
    public func sets(for exerciseID: String) -> [SetLog] {
        sessions
            .flatMap(\.sets)
            .filter { $0.exerciseID == exerciseID }
            .sorted { $0.date < $1.date }
    }

    /// Best estimated 1RM ever recorded for an exercise.
    public func bestEstimatedOneRepMax(for exerciseID: String) -> Double? {
        sets(for: exerciseID).map(\.estimatedOneRepMax).max()
    }

    /// Most recent readiness check on a given day, if the athlete filled one in.
    public func readiness(on date: Date, calendar: Calendar = .current) -> ReadinessCheck? {
        readiness
            .filter { calendar.isDate($0.date, inSameDayAs: date) }
            .max { $0.date < $1.date }
    }
}
