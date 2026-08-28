import Foundation
@testable import MonCoachKit

enum Fixtures {
    static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    static let start = date(2026, 9, 1)

    /// 30-year-old intermediate male, full gym, four sessions a week.
    static func intermediate(
        goal: PrimaryGoal = .hypertrophy,
        daysPerWeek: Int = 4,
        sessionMinutes: Int = 70,
        equipment: Set<Equipment> = Equipment.fullGym,
        limitations: Set<Limitation> = []
    ) -> UserProfile {
        UserProfile(
            firstName: "Max",
            birthDate: date(1996, 3, 12),
            sex: .male,
            heightCm: 178,
            weightKg: 78,
            bodyFatPercent: 16,
            trainingMonths: 24,
            goal: goal,
            daysPerWeek: daysPerWeek,
            sessionMinutes: sessionMinutes,
            equipment: equipment,
            limitations: limitations,
            activityLevel: .light,
            averageSleepHours: 7.5,
            stressLevel: 3,
            knownOneRepMax: ["back-squat": 120, "bench-press": 90, "conventional-deadlift": 150]
        )
    }

    /// Complete beginner, dumbbells at home, three sessions a week.
    static func beginner(daysPerWeek: Int = 3) -> UserProfile {
        UserProfile(
            firstName: "Léa",
            birthDate: date(2000, 7, 4),
            sex: .female,
            heightCm: 165,
            weightKg: 60,
            trainingMonths: 0,
            goal: .generalHealth,
            daysPerWeek: daysPerWeek,
            sessionMinutes: 45,
            equipment: Equipment.homeGym,
            activityLevel: .moderate
        )
    }

    /// Seasoned lifter and runner, six years in, full gym.
    static func advanced(daysPerWeek: Int = 5) -> UserProfile {
        UserProfile(
            firstName: "Sofia",
            birthDate: date(1992, 2, 18),
            sex: .male,
            heightCm: 182,
            weightKg: 80,
            bodyFatPercent: 11,
            trainingMonths: 72,
            goal: .strength,
            daysPerWeek: daysPerWeek,
            sessionMinutes: 80,
            equipment: Equipment.fullGym,
            activityLevel: .moderate
        )
    }

    /// Logs a session where every set hit the top of its rep range at the
    /// target RPE — the textbook case for adding load.
    static func perfectSession(
        _ session: PlannedSession,
        on date: Date,
        loads: [String: Double] = [:]
    ) -> SessionLog {
        var sets: [SetLog] = []
        for prescription in session.exercises {
            for set in prescription.sets {
                sets.append(
                    SetLog(
                        date: date,
                        exerciseID: prescription.exerciseID,
                        setIndex: set.index,
                        weightKg: loads[prescription.exerciseID] ?? set.suggestedLoadKg ?? 40,
                        reps: set.repUpperBound,
                        rpe: set.targetRPE
                    )
                )
            }
        }
        return SessionLog(
            plannedSessionID: session.id,
            date: date,
            sets: sets,
            durationMinutes: session.estimatedMinutes
        )
    }
}
