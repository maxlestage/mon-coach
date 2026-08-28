import Foundation

/// A session in progress.
///
/// It holds the prescription plus whatever the athlete has actually done so
/// far, so the player can show "3 × 8 @ 60 kg prescribed, 2 sets logged"
/// without recomputing anything.
public struct ActiveSession: Identifiable, Equatable, Sendable {
    public let id: UUID
    public private(set) var session: PlannedSession
    public let startedAt: Date
    /// Logged sets, keyed by exercise prescription id.
    public var completed: [UUID: [SetLog]]

    public init(session: PlannedSession, startedAt: Date = Date()) {
        id = session.id
        self.session = session
        self.startedAt = startedAt
        completed = [:]
    }

    /// Remplace un exercice en cours de séance par un autre.
    ///
    /// Les séries déjà enregistrées ne bougent pas : elles portent leur
    /// propre identifiant d'exercice et racontent ce qui a réellement été
    /// fait. Les charges suggérées, elles, sont effacées — elles avaient été
    /// calculées pour l'autre mouvement, et proposer 80 kg au développé
    /// machine parce que c'était la charge de la barre serait un mensonge
    /// que l'athlète paierait à la première série.
    ///
    /// - Returns: vrai si le remplacement a eu lieu.
    @discardableResult
    public mutating func substitute(
        prescription id: UUID,
        with exercise: Exercise
    ) -> Bool {
        guard let index = session.exercises.firstIndex(where: { $0.id == id }) else { return false }
        var replaced = session.exercises[index]
        replaced.exerciseID = exercise.id
        replaced.sets = replaced.sets.map { set in
            var copy = set
            copy.suggestedLoadKg = nil
            return copy
        }
        replaced.note = exercise.cue
        session.exercises[index] = replaced
        return true
    }

    public func logs(for prescription: ExercisePrescription) -> [SetLog] {
        completed[prescription.id] ?? []
    }

    public func isComplete(_ prescription: ExercisePrescription) -> Bool {
        logs(for: prescription).count >= prescription.sets.count
    }

    /// The next set the athlete owes on this movement, or nil once it is done.
    public func nextSet(of prescription: ExercisePrescription) -> SetPrescription? {
        let done = logs(for: prescription).count
        return done < prescription.sets.count ? prescription.sets[done] : nil
    }

    /// The first movement that still has sets outstanding.
    public var currentExercise: ExercisePrescription? {
        session.exercises.first { !isComplete($0) }
    }

    public var loggedSetCount: Int {
        completed.values.reduce(0) { $0 + $1.count }
    }

    public var progress: Double {
        let total = session.totalSets
        guard total > 0 else { return 1 }
        return Double(loggedSetCount) / Double(total)
    }

    public mutating func log(
        _ set: SetPrescription,
        of prescription: ExercisePrescription,
        weightKg: Double,
        reps: Int,
        rpe: Double,
        painFlag: Bool,
        at date: Date = Date()
    ) {
        var sets = completed[prescription.id] ?? []
        sets.append(
            SetLog(
                date: date,
                exerciseID: prescription.exerciseID,
                setIndex: set.index,
                weightKg: weightKg,
                reps: reps,
                rpe: rpe,
                painFlag: painFlag
            )
        )
        completed[prescription.id] = sets
    }

    public mutating func undoLastSet(of prescription: ExercisePrescription) {
        guard var sets = completed[prescription.id], !sets.isEmpty else { return }
        sets.removeLast()
        completed[prescription.id] = sets
    }

    public func log(finishedAt date: Date) -> SessionLog {
        let sets = session.exercises.flatMap { logs(for: $0) }
        return SessionLog(
            plannedSessionID: session.id,
            date: startedAt,
            sets: sets,
            durationMinutes: max(1, Int(date.timeIntervalSince(startedAt) / 60)),
            skipped: false
        )
    }
}
