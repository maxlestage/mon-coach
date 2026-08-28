import Foundation
import Testing
@testable import MonCoachKit

@Suite("Construction du bloc")
struct PlanBuilderTests {

    @Test("Chaque semaine contient le nombre de séances promis")
    func sessionCount() {
        for days in 2...6 {
            let plan = PlanBuilder.build(
                for: Fixtures.intermediate(daysPerWeek: days),
                startingOn: Fixtures.start,
                calendar: Fixtures.calendar
            )
            for week in plan.weeks {
                #expect(week.sessions.count == days, "semaine \(week.index) : \(week.sessions.count) séances pour \(days) prévues")
            }
        }
    }

    @Test("Le bloc se termine par une semaine de décharge, et une seule")
    func exactlyOneDeload() {
        for experience in ExperienceLevel.allCases {
            var profile = Fixtures.intermediate()
            profile.experience = experience
            let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
            let deloads = plan.weeks.filter(\.isDeload)
            #expect(deloads.count == 1)
            #expect(deloads.first?.index == plan.weekCount)
            #expect(plan.weeks.allSatisfy { $0.isDeload == $0.sessions.allSatisfy(\.isDeload) })
        }
    }

    @Test("La décharge retire du volume et de l'intensité")
    func deloadIsLighter() {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let lastHard = plan.weeks[plan.weekCount - 2]
        let deload = plan.weeks[plan.weekCount - 1]
        #expect(deload.totalSets < lastHard.totalSets)

        let hardRPE = lastHard.sessions[0].exercises[0].sets[0].targetRPE
        let deloadRPE = deload.sessions[0].exercises[0].sets[0].targetRPE
        #expect(deloadRPE < hardRPE)
    }

    @Test("Le volume monte d'une semaine à l'autre pendant l'accumulation")
    func volumeRamps() {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let accumulation = plan.weeks.filter { !$0.isDeload }
        for (previous, next) in zip(accumulation, accumulation.dropFirst()) {
            #expect(next.totalSets >= previous.totalSets, "semaine \(next.index) : \(next.totalSets) après \(previous.totalSets)")
        }
        #expect(accumulation.last!.totalSets > accumulation.first!.totalSets)
    }

    @Test("Les mêmes exercices reviennent chaque semaine, sinon la progression est illisible")
    func exercisesAreStableAcrossWeeks() {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let reference = plan.weeks[0].sessions.map { $0.exercises.map(\.exerciseID) }
        for week in plan.weeks.dropFirst() where !week.isDeload {
            let ids = week.sessions.map { $0.exercises.map(\.exerciseID) }
            #expect(ids == reference, "la semaine \(week.index) change d'exercices")
        }
    }

    @Test("Aucune séance ne dépasse le temps disponible")
    func sessionsFitTheClock() {
        for minutes in [30, 45, 60, 75, 90] {
            let profile = Fixtures.intermediate(daysPerWeek: 4, sessionMinutes: minutes)
            let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
            for week in plan.weeks {
                for session in week.sessions {
                    #expect(
                        session.estimatedMinutes <= minutes,
                        "semaine \(week.index), \(session.title) : \(session.estimatedMinutes) min pour \(minutes) disponibles"
                    )
                }
            }
        }
    }

    @Test("Une séance contient toujours au moins trois exercices")
    func sessionsAreNotEmpty() {
        for minutes in [30, 45, 90] {
            for days in 2...6 {
                let profile = Fixtures.intermediate(daysPerWeek: days, sessionMinutes: minutes)
                let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
                for week in plan.weeks {
                    for session in week.sessions {
                        #expect(session.exercises.count >= 3, "\(days)j/\(minutes)min : \(session.title) n'a que \(session.exercises.count) exercices")
                        #expect(session.exercises.allSatisfy { $0.sets.count >= 2 })
                    }
                }
            }
        }
    }

    @Test("Le matériel disponible est respecté à la lettre")
    func equipmentIsRespected() {
        let profile = Fixtures.intermediate(equipment: Equipment.minimal)
        let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        for week in plan.weeks {
            for session in week.sessions {
                for prescription in session.exercises {
                    let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)
                    #expect(exercise != nil)
                    #expect(exercise!.isAvailable(with: profile.equipment), "\(exercise!.name) demande du matériel que Max n'a pas")
                }
            }
        }
    }

    @Test("Aucun exercice ne sollicite une zone déclarée sensible")
    func limitationsAreRespected() {
        let profile = Fixtures.intermediate(limitations: [.lowerBack, .shoulder])
        let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        for week in plan.weeks {
            for session in week.sessions {
                for prescription in session.exercises {
                    let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)!
                    #expect(!exercise.conflicts(with: profile.limitations), "\(exercise.name) sollicite une zone sensible")
                }
            }
        }
    }

    @Test("Un exercice explicitement refusé ne réapparaît jamais")
    func dislikedExercisesAreExcluded() {
        var profile = Fixtures.intermediate()
        profile.dislikedExerciseIDs = ["back-squat", "conventional-deadlift", "bench-press"]
        let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let ids = Set(plan.weeks.flatMap { $0.sessions.flatMap { $0.exercises.map(\.exerciseID) } })
        #expect(ids.isDisjoint(with: profile.dislikedExerciseIDs))
        #expect(!ids.isEmpty)
    }

    @Test("Un même exercice n'apparaît pas deux fois dans la même séance")
    func noDuplicatesWithinASession() {
        for days in 2...6 {
            let plan = PlanBuilder.build(
                for: Fixtures.intermediate(daysPerWeek: days),
                startingOn: Fixtures.start,
                calendar: Fixtures.calendar
            )
            for week in plan.weeks {
                for session in week.sessions {
                    let ids = session.exercises.map(\.exerciseID)
                    #expect(Set(ids).count == ids.count, "doublon dans \(session.title)")
                }
            }
        }
    }

    @Test("Les fourchettes de répétitions restent cohérentes avec le mouvement")
    func repRangesStayViable() {
        for goal in PrimaryGoal.allCases {
            let plan = PlanBuilder.build(
                for: Fixtures.intermediate(goal: goal),
                startingOn: Fixtures.start,
                calendar: Fixtures.calendar
            )
            for week in plan.weeks {
                for session in week.sessions {
                    for prescription in session.exercises {
                        let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID)!
                        for set in prescription.sets {
                            #expect(set.repLowerBound <= set.repUpperBound)
                            #expect(set.repLowerBound >= exercise.viableRepRange.lowerBound,
                                    "\(exercise.name) prescrit \(set.repsLabel) hors de \(exercise.viableRepRange)")
                        }
                    }
                }
            }
        }
    }

    @Test("Le bloc pour un débutant sans salle tient debout")
    func beginnerAtHome() {
        let profile = Fixtures.beginner()
        let program = CoachEngine.buildProgram(for: profile, startingOn: Fixtures.start, calendar: Fixtures.calendar)
        #expect(program.plan.split == .fullBody)
        #expect(program.plan.weekCount == 6)
        for week in program.plan.weeks {
            for session in week.sessions {
                #expect(!session.exercises.isEmpty)
                #expect(session.estimatedMinutes <= profile.sessionMinutes)
            }
        }
    }

    @Test("Un bloc se sérialise et se relit sans perte")
    func planRoundTrips() throws {
        let plan = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start, calendar: Fixtures.calendar)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let restored = try decoder.decode(Mesocycle.self, from: encoder.encode(plan))
        #expect(restored == plan)
    }

    @Test("Un profil se sérialise et se relit sans perte")
    func profileRoundTrips() throws {
        let profile = Fixtures.intermediate(limitations: [.knee])
        let restored = try JSONDecoder().decode(UserProfile.self, from: JSONEncoder().encode(profile))
        #expect(restored == profile)
    }
}
