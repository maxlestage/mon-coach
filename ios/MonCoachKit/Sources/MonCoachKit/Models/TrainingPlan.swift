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
    public var note: LocalizedText?

    public init(
        id: UUID = UUID(),
        exerciseID: String,
        order: Int,
        sets: [SetPrescription],
        restSeconds: Int,
        note: LocalizedText? = nil
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
    public var title: LocalizedText
    public var focus: [MuscleGroup]
    public var exercises: [ExercisePrescription]
    public var isDeload: Bool

    public init(
        id: UUID = UUID(),
        dayIndex: Int,
        title: LocalizedText,
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

    public var label: LocalizedText {
        switch self {
        case .fullBody: LocalizedText(fr: "Full body", en: "Full body", es: "Full body")
        case .upperLower: LocalizedText(fr: "Haut / Bas", en: "Upper / Lower", es: "Superior / Inferior")
        case .pushPullLegs: LocalizedText(fr: "Push / Pull / Legs", en: "Push / Pull / Legs", es: "Empuje / Tirón / Pierna")
        case .pushPullLegsUpperLower: LocalizedText(fr: "PPL + Haut / Bas", en: "PPL + Upper / Lower", es: "PPL + Superior / Inferior")
        case .arnold: LocalizedText(fr: "Arnold split", en: "Arnold split", es: "Rutina Arnold")
        }
    }

    public var rationale: LocalizedText {
        switch self {
        case .fullBody:
            LocalizedText(
                fr: "Chaque muscle est stimulé à chaque séance : c'est la structure la plus rentable quand le temps de salle est limité.",
                en: "Every muscle is stimulated in every session: the best return on time when gym hours are scarce.",
                es: "Cada músculo se estimula en cada sesión: la estructura más rentable cuando el tiempo de gimnasio es escaso."
            )
        case .upperLower:
            LocalizedText(
                fr: "Deux fois par semaine sur chaque muscle, avec assez de volume par séance pour progresser sans y passer la soirée.",
                en: "Twice a week on every muscle, with enough volume per session to progress without spending the evening there.",
                es: "Dos veces por semana en cada músculo, con volumen suficiente por sesión para progresar sin pasar la tarde allí."
            )
        case .pushPullLegs:
            LocalizedText(
                fr: "Les groupes musculaires qui travaillent ensemble sont regroupés, ce qui limite la fatigue croisée entre séances.",
                en: "Muscle groups that work together are grouped together, which limits cross-fatigue between sessions.",
                es: "Los grupos musculares que trabajan juntos se agrupan, lo que limita la fatiga cruzada entre sesiones."
            )
        case .pushPullLegsUpperLower:
            LocalizedText(
                fr: "Trois jours PPL pour le volume, complétés par des haut/bas pour garder au moins deux passages par semaine sur chaque muscle.",
                en: "Three PPL days for volume, completed by upper/lower days to keep every muscle trained at least twice a week.",
                es: "Tres días PPL para el volumen, completados con superior/inferior para mantener cada músculo entrenado al menos dos veces por semana."
            )
        case .arnold:
            LocalizedText(
                fr: "Six séances courtes, fréquence élevée : réservé aux pratiquants avancés qui récupèrent bien.",
                en: "Six short sessions at high frequency: for advanced lifters who recover well, and nobody else.",
                es: "Seis sesiones cortas y alta frecuencia: reservado a avanzados que recuperan bien."
            )
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
    public var rationale: [LocalizedText]

    public init(
        id: UUID = UUID(),
        startDate: Date,
        goal: PrimaryGoal,
        split: SplitTemplate,
        weeks: [PlannedWeek],
        weeklyVolumeTarget: [MuscleGroup: Int],
        rationale: [LocalizedText]
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
