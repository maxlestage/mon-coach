import Foundation
import Observation
import MonCoachKit

/// Everything the app persists between launches.
///
/// Derived numbers — metrics, macros, load suggestions — are deliberately
/// absent: they are recomputed from the profile on every launch so they can
/// never drift from the formulas. The mesocycle *is* stored, because the
/// training log points at its session identifiers.
struct PersistedState: Codable {
    var profile: UserProfile?
    var plan: Mesocycle?
    var history: TrainingHistory

    static let empty = PersistedState(profile: nil, plan: nil, history: .empty)
}

/// The app's single source of truth.
///
/// It owns the athlete's profile, the current block and the training log, and
/// it is the only place that talks to `MonCoachKit`. Views read from it and
/// call intents on it; they never run coaching logic themselves.
@MainActor
@Observable
final class CoachStore {

    private(set) var profile: UserProfile?
    private(set) var plan: Mesocycle?
    private(set) var history: TrainingHistory = .empty

    /// The session the athlete is currently performing, if any.
    var activeSession: ActiveSession?

    /// Surfaces a write failure to the UI instead of swallowing it — losing a
    /// training log silently is the one thing this app must not do.
    private(set) var saveError: String?

    private let storage: StateStorage

    init(storage: StateStorage = .applicationSupport()) {
        self.storage = storage
        let state = storage.load()
        profile = state.profile
        plan = state.plan
        history = state.history
    }

    // MARK: - Derived state

    var isOnboarded: Bool { profile != nil && plan != nil }

    var program: CoachingProgram? {
        guard let profile, let plan else { return nil }
        return CoachEngine.program(profile: profile, plan: plan)
    }

    func briefing(on date: Date = Date()) -> TodayBriefing? {
        guard let program else { return nil }
        return CoachEngine.briefing(for: program, history: history, on: date)
    }

    /// The week the athlete is currently in, 1-based, or nil once the block is over.
    func currentWeekIndex(on date: Date = Date()) -> Int? {
        plan?.weekIndex(for: date)
    }

    func review(weekIndex: Int) -> WeeklyReview? {
        guard let program else { return nil }
        return CoachEngine.weeklyReview(program: program, history: history, weekIndex: weekIndex)
    }

    /// Insights for the most recently completed week, which is what the Today
    /// screen shows — reviewing the week you are still in says nothing useful.
    func latestInsights(on date: Date = Date()) -> [CoachInsight] {
        guard let current = currentWeekIndex(on: date), current > 1 else { return [] }
        return review(weekIndex: current - 1)?.insights ?? []
    }

    // MARK: - Intents

    func completeOnboarding(with profile: UserProfile, startingOn date: Date = Date()) {
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
    func updateProfile(_ updated: UserProfile, rebuildingFrom date: Date = Date()) {
        let program = CoachEngine.buildProgram(for: updated, startingOn: date)
        profile = program.profile
        plan = program.plan
        save()
    }

    func recordReadiness(_ check: ReadinessCheck) {
        history.readiness.removeAll { Calendar.current.isDate($0.date, inSameDayAs: check.date) }
        history.readiness.append(check)
        save()
    }

    func recordBodyLog(_ log: BodyLog) {
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

    func startSession(_ session: PlannedSession) {
        activeSession = ActiveSession(session: session)
    }

    func finishActiveSession(at date: Date = Date()) {
        guard let active = activeSession else { return }
        let log = active.log(finishedAt: date)
        // An abandoned session with nothing logged is not worth recording.
        if !log.sets.isEmpty {
            history.sessions.append(log)
            save()
        }
        activeSession = nil
    }

    func skipTodaySession(at date: Date = Date()) {
        guard let session = briefing(on: date)?.session else { return }
        history.sessions.append(
            SessionLog(plannedSessionID: session.id, date: date, skipped: true)
        )
        save()
    }

    /// Ends the current block and builds the next one from what the last week
    /// actually showed.
    func startNextBlock(on date: Date = Date()) {
        guard let program, let weekIndex = currentWeekIndex(on: date) ?? plan?.weekCount else { return }
        let review = CoachEngine.weeklyReview(program: program, history: history, weekIndex: weekIndex)
        let next = CoachEngine.nextBlock(after: program, review: review, startingOn: date)
        profile = next.profile
        plan = next.plan
        save()
    }

    func resetEverything() {
        profile = nil
        plan = nil
        history = .empty
        activeSession = nil
        save()
    }

    // MARK: - Persistence

    private func save() {
        let state = PersistedState(profile: profile, plan: plan, history: history)
        do {
            try storage.save(state)
            saveError = nil
        } catch {
            saveError = "Impossible d'enregistrer tes données : \(error.localizedDescription)"
        }
    }

    /// Everything the athlete has entered, as JSON, for export.
    func exportJSON() throws -> Data {
        try StateStorage.encoder.encode(PersistedState(profile: profile, plan: plan, history: history))
    }
}
