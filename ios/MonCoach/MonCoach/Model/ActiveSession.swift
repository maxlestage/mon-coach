import Foundation
import MonCoachKit

/// A session in progress.
///
/// It holds the prescription plus whatever the athlete has actually done so
/// far, so the player can show "3 × 8 @ 60 kg prescribed, 2 sets logged"
/// without recomputing anything.
struct ActiveSession: Identifiable, Equatable {
    let id: UUID
    let session: PlannedSession
    let startedAt: Date
    /// Logged sets, keyed by exercise prescription id.
    var completed: [UUID: [SetLog]]

    init(session: PlannedSession, startedAt: Date = Date()) {
        id = session.id
        self.session = session
        self.startedAt = startedAt
        completed = [:]
    }

    func logs(for prescription: ExercisePrescription) -> [SetLog] {
        completed[prescription.id] ?? []
    }

    func isComplete(_ prescription: ExercisePrescription) -> Bool {
        logs(for: prescription).count >= prescription.sets.count
    }

    /// The next set the athlete owes on this movement, or nil once it is done.
    func nextSet(of prescription: ExercisePrescription) -> SetPrescription? {
        let done = logs(for: prescription).count
        return done < prescription.sets.count ? prescription.sets[done] : nil
    }

    /// The first movement that still has sets outstanding.
    var currentExercise: ExercisePrescription? {
        session.exercises.first { !isComplete($0) }
    }

    var loggedSetCount: Int {
        completed.values.reduce(0) { $0 + $1.count }
    }

    var progress: Double {
        let total = session.totalSets
        guard total > 0 else { return 1 }
        return Double(loggedSetCount) / Double(total)
    }

    mutating func log(
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

    mutating func undoLastSet(of prescription: ExercisePrescription) {
        guard var sets = completed[prescription.id], !sets.isEmpty else { return }
        sets.removeLast()
        completed[prescription.id] = sets
    }

    func log(finishedAt date: Date) -> SessionLog {
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
