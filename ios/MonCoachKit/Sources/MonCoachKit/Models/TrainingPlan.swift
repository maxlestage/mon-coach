import Foundation

/// A single prescribed set.
public struct SetPrescription: Codable, Sendable, Equatable, Hashable {
    public var index: Int
    public var repLowerBound: Int
    public var repUpperBound: Int
    /// Target RPE (reps in reserve = 10 − RPE).
    public var targetRPE: Double
    /// Suggested working load in kg. Nil when the coach has no basis yet and
    /// wants the athlete to find it by feel on the first exposure.
    public var suggestedLoadKg: Double?
    /// Marks a lighter top-set/back-off structure for strength work.
    public var isBackOff: Bool

    public init(
        index: Int,
        repLowerBound: Int,
        repUpperBound: Int,
        targetRPE: Double,
        suggestedLoadKg: Double? = nil,
        isBackOff: Bool = false
    ) {
        self.index = index
        self.repLowerBound = repLowerBound
        self.repUpperBound = repUpperBound
        self.targetRPE = targetRPE
        self.suggestedLoadKg = suggestedLoadKg
        self.isBackOff = isBackOff
    }

    public var repRange: ClosedRange<Int> { repLowerBound...repUpperBound }

    public var repsLabel: String {
        repLowerBound == repUpperBound ? "\(repLowerBound)" : "\(repLowerBound)–\(repUpperBound)"
    }
}

/// One exercise slot inside a session, with its sets.
public struct ExercisePrescription: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var exerciseID: String
    public var order: Int
    public var sets: [SetPrescription]
    public var restSeconds: Int
    /// Free-text coaching note attached to this slot ("garde les coudes serrés").
    public var note: String?

    public init(
        id: UUID = UUID(),
        exerciseID: String,
        order: Int,
        sets: [SetPrescription],
        restSeconds: Int,
        note: String? = nil
    ) {
        self.id = id
        self.exerciseID = exerciseID
        self.order = order
        self.sets = sets
        self.restSeconds = restSeconds
        self.note = note
    }

    public var workingSetCount: Int { sets.count }
}

/// One training day.
public struct PlannedSession: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    /// 0-based index of the session inside its week.
    public var dayIndex: Int
    public var title: String
    public var focus: [MuscleGroup]
    public var exercises: [ExercisePrescription]
    public var isDeload: Bool

    public init(
        id: UUID = UUID(),
        dayIndex: Int,
        title: String,
        focus: [MuscleGroup],
        exercises: [ExercisePrescription],
        isDeload: Bool = false
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.title = title
        self.focus = focus
        self.exercises = exercises
        self.isDeload = isDeload
    }

    public var totalSets: Int { exercises.reduce(0) { $0 + $1.workingSetCount } }

    /// Rough duration: working sets × (rest + 45 s under tension) + 8 min warm-up.
    public var estimatedMinutes: Int {
        let seconds = exercises.reduce(0.0) { partial, prescription in
            partial + Double(prescription.workingSetCount) * (Double(prescription.restSeconds) + 45)
        }
        return Int((seconds / 60).rounded()) + 8
    }
}

/// One week of the mesocycle.
public struct PlannedWeek: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    /// 1-based week number inside the mesocycle.
    public var index: Int
    public var isDeload: Bool
    public var sessions: [PlannedSession]

    public init(id: UUID = UUID(), index: Int, isDeload: Bool, sessions: [PlannedSession]) {
        self.id = id
        self.index = index
        self.isDeload = isDeload
        self.sessions = sessions
    }

    public var totalSets: Int { sessions.reduce(0) { $0 + $1.totalSets } }
}

/// Which weekly structure the plan uses.
public enum SplitTemplate: String, Codable, CaseIterable, Sendable {
    case fullBody
    case upperLower
    case pushPullLegs
    case pushPullLegsUpperLower
    case arnold

    public var label: String {
        switch self {
        case .fullBody: "Full body"
        case .upperLower: "Haut / Bas"
        case .pushPullLegs: "Push / Pull / Legs"
        case .pushPullLegsUpperLower: "PPL + Haut / Bas"
        case .arnold: "Arnold split"
        }
    }

    public var rationale: String {
        switch self {
        case .fullBody:
            "Chaque muscle est stimulé à chaque séance : c'est la structure la plus rentable quand le temps de salle est limité."
        case .upperLower:
            "Deux fois par semaine sur chaque muscle, avec assez de volume par séance pour progresser sans y passer la soirée."
        case .pushPullLegs:
            "Les groupes musculaires qui travaillent ensemble sont regroupés, ce qui limite la fatigue croisée entre séances."
        case .pushPullLegsUpperLower:
            "Cinq séances : trois PPL pour le volume, deux haut/bas pour ramener la fréquence à deux fois par semaine partout."
        case .arnold:
            "Six séances courtes, fréquence élevée : réservé aux pratiquants avancés qui récupèrent bien."
        }
    }
}

/// A complete training block. Rebuilt whenever the profile changes materially
/// or when the previous block ends.
public struct Mesocycle: Codable, Sendable, Equatable, Identifiable {
    public var id: UUID
    public var startDate: Date
    public var goal: PrimaryGoal
    public var split: SplitTemplate
    public var weeks: [PlannedWeek]
    /// Weekly set target per muscle that the block was built to hit.
    public var weeklyVolumeTarget: [MuscleGroup: Int]
    /// Human-readable summary of why this block looks the way it does.
    public var rationale: [String]

    public init(
        id: UUID = UUID(),
        startDate: Date,
        goal: PrimaryGoal,
        split: SplitTemplate,
        weeks: [PlannedWeek],
        weeklyVolumeTarget: [MuscleGroup: Int],
        rationale: [String]
    ) {
        self.id = id
        self.startDate = startDate
        self.goal = goal
        self.split = split
        self.weeks = weeks
        self.weeklyVolumeTarget = weeklyVolumeTarget
        self.rationale = rationale
    }

    public var weekCount: Int { weeks.count }

    public func week(at index: Int) -> PlannedWeek? {
        weeks.first { $0.index == index }
    }

    /// Which week of the block a given date falls in, 1-based.
    /// Returns nil once the block is over.
    public func weekIndex(for date: Date, calendar: Calendar = .current) -> Int? {
        let startDay = calendar.startOfDay(for: startDate)
        let day = calendar.startOfDay(for: date)
        guard day >= startDay else { return nil }
        let days = calendar.dateComponents([.day], from: startDay, to: day).day ?? 0
        let index = days / 7 + 1
        return index <= weekCount ? index : nil
    }

    public var endDate: Date {
        Calendar.current.date(byAdding: .day, value: weekCount * 7 - 1, to: startDate) ?? startDate
    }
}
