import Foundation

/// One movement the coach can prescribe.
///
/// Everything here is static reference data — the catalog is compiled in, not
/// downloaded — so a session can always be built offline.
public struct Exercise: Codable, Sendable, Equatable, Identifiable, Hashable {
    public let id: String
    public let name: LocalizedText
    /// Short cue shown while the set is running.
    public let cue: LocalizedText
    public let primaryMuscle: MuscleGroup
    public let secondaryMuscles: [MuscleGroup]
    public let pattern: MovementPattern
    /// Every piece of kit required. An exercise is available only when the
    /// athlete owns *all* of them.
    public let equipment: Set<Equipment>
    public let isCompound: Bool
    /// Body areas this movement loads hard. Matching a flagged limitation
    /// removes the exercise from selection.
    public let stressedAreas: Set<Limitation>
    /// Stimulus-to-fatigue ratio, 1–5. Ties in selection are broken by it.
    public let stimulusRating: Int
    /// Rep range that suits the movement regardless of goal — a heavy triple
    /// on a lateral raise is not a useful prescription.
    public let viableRepRange: ClosedRange<Int>
    /// Fraction of a 1RM-relevant load. Used to seed a starting weight for
    /// accessories from a known main-lift 1RM.
    public let loadFactor: Double
    /// Rest between sets in seconds, before goal adjustment.
    public let baseRestSeconds: Int
    /// Whether the load is per-side (dumbbells) — affects how weight is logged.
    public let isUnilateral: Bool

    public init(
        id: String,
        name: LocalizedText,
        cue: LocalizedText,
        primaryMuscle: MuscleGroup,
        secondaryMuscles: [MuscleGroup] = [],
        pattern: MovementPattern,
        equipment: Set<Equipment>,
        isCompound: Bool,
        stressedAreas: Set<Limitation> = [],
        stimulusRating: Int,
        viableRepRange: ClosedRange<Int>,
        loadFactor: Double,
        baseRestSeconds: Int,
        isUnilateral: Bool = false
    ) {
        self.id = id
        self.name = name
        self.cue = cue
        self.primaryMuscle = primaryMuscle
        self.secondaryMuscles = secondaryMuscles
        self.pattern = pattern
        self.equipment = equipment
        self.isCompound = isCompound
        self.stressedAreas = stressedAreas
        self.stimulusRating = stimulusRating
        self.viableRepRange = viableRepRange
        self.loadFactor = loadFactor
        self.baseRestSeconds = baseRestSeconds
        self.isUnilateral = isUnilateral
    }

    /// Whether the athlete owns everything this movement needs.
    public func isAvailable(with owned: Set<Equipment>) -> Bool {
        equipment.isSubset(of: owned)
    }

    /// Whether any flagged limitation overlaps what this movement stresses.
    public func conflicts(with limitations: Set<Limitation>) -> Bool {
        !stressedAreas.isDisjoint(with: limitations)
    }

    /// Every muscle that receives meaningful work, primary first.
    public var allMuscles: [MuscleGroup] {
        [primaryMuscle] + secondaryMuscles
    }

    /// Weekly-volume credit per set: a set counts fully for the primary
    /// muscle and half for each secondary one.
    public func volumeCredit(for muscle: MuscleGroup) -> Double {
        if muscle == primaryMuscle { return 1.0 }
        return secondaryMuscles.contains(muscle) ? 0.5 : 0.0
    }
}
