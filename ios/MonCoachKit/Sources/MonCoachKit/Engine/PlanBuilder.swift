import Foundation

/// Assembles a full mesocycle from a profile.
///
/// The block is an accumulation ramp followed by a deload: volume climbs
/// week over week, target RPE climbs with it, then everything drops so the
/// athlete can absorb the work before the next block starts harder.
public enum PlanBuilder {

    /// Block length, deload included.
    static func weekCount(for profile: UserProfile) -> Int {
        switch profile.experience {
        case .beginner: 6      // 5 accumulation + 1 deload
        case .intermediate: 5  // 4 + 1
        case .advanced: 4      // 3 + 1
        }
    }

    public static func build(
        for profile: UserProfile,
        startingOn startDate: Date = Date(),
        calendar: Calendar = .current
    ) -> Mesocycle {
        let split = SplitPlanner.split(for: profile)
        let available = ExerciseCatalog.available(for: profile)

        // Le budget et la structure sont ramenés à ce que ce corps peut
        // travailler, et seulement lorsqu'une situation est déclarée.
        //
        // Le même trou existe sans déclaration — deux élastiques et un genou
        // douloureux suffisent à produire une journée « jambes » vide — et il
        // n'est pas comblé ici : le faire réécrirait le mésocycle en cours de
        // tous ceux qui en ont un, pour un manque qui se répare en achetant
        // un haltère. Une situation déclarée, elle, ne se répare pas ; le
        // programme doit en tenir compte dès la première séance.
        var volume = VolumeEngine.prescription(for: profile)
        var dayTemplates = SplitPlanner.days(for: split, daysPerWeek: profile.daysPerWeek)
        let trainable = profile.hasAdaptiveNeeds
            ? ExerciseCatalog.trainableMuscles(for: profile)
            : Set(MuscleGroup.allCases)
        if profile.hasAdaptiveNeeds {
            volume = volume.limited(to: trainable)
            dayTemplates = SplitPlanner.days(
                for: split, daysPerWeek: profile.daysPerWeek, trainable: trainable
            )
        }
        let dailyBudget = SplitPlanner.distribute(volume: volume, across: dayTemplates)
        let totalWeeks = weekCount(for: profile)

        // The movements are chosen once and kept for the whole block. Swapping
        // exercises week to week would make progression impossible to read:
        // you cannot tell whether a heavier bar is progress or a different lift.
        let baseSessions = dayTemplates.enumerated().map { dayIndex, template in
            baseSession(
                dayIndex: dayIndex,
                template: template,
                budget: dailyBudget[dayIndex],
                available: available,
                profile: profile
            )
        }

        var weeks: [PlannedWeek] = []
        for weekIndex in 1...totalWeeks {
            let isDeload = weekIndex == totalWeeks
            let sessions = baseSessions.map {
                apply(
                    week: weekIndex,
                    totalWeeks: totalWeeks,
                    isDeload: isDeload,
                    to: $0,
                    profile: profile
                )
            }
            weeks.append(PlannedWeek(index: weekIndex, isDeload: isDeload, sessions: sessions))
        }

        var rationale = volume.rationale
        rationale.insert(split.rationale, at: 0)
        rationale.append(
            LocalizedText(
                fr: "Bloc de \(totalWeeks) semaines : \(totalWeeks - 1) semaines où le volume augmente, puis une semaine de décharge pour absorber le travail.",
                en: "A \(totalWeeks)-week block: \(totalWeeks - 1) weeks of rising volume, then a deload week to absorb the work.",
                es: "Bloque de \(totalWeeks) semanas: \(totalWeeks - 1) semanas en las que sube el volumen y una semana de descarga para asimilar el trabajo."
            )
        )
        if !profile.limitations.isEmpty {
            func names(in language: Language) -> String {
                profile.limitations.map { $0.label[language] }.sorted().joined(separator: ", ")
            }
            rationale.append(
                LocalizedText(
                    fr: "Exercices écartés à cause de tes zones sensibles (\(names(in: .french))) : le programme ne contient que des mouvements qui ne les sollicitent pas directement.",
                    en: "Exercises removed because of the areas you flagged (\(names(in: .english))): the programme only contains movements that do not load them directly.",
                    es: "Ejercicios descartados por las zonas que has señalado (\(names(in: .spanish))): el programa solo contiene movimientos que no las cargan directamente."
                )
            )
        }

        if let needs = profile.adaptive, needs.isActive {
            rationale.append(adaptiveRationale(needs: needs, trainable: trainable))
        }

        return Mesocycle(
            startDate: calendar.startOfDay(for: startDate),
            goal: profile.goal,
            split: split,
            weeks: weeks,
            weeklyVolumeTarget: volume.weeklySets,
            rationale: rationale
        )
    }

    /// Ce que la situation déclarée a changé au programme, dit à l'athlète.
    ///
    /// Deux phrases séparées parce qu'elles répondent à deux questions
    /// différentes, et que la seconde est la seule qui compte vraiment quand
    /// elle s'applique : quels muscles le catalogue ne sait pas servir. La
    /// taire aurait laissé quelqu'un chercher pendant des semaines pourquoi
    /// ses ischio-jambiers n'apparaissent jamais.
    static func adaptiveRationale(
        needs: AdaptiveNeeds,
        trainable: Set<MuscleGroup>
    ) -> LocalizedText {
        let untrainable = MuscleGroup.allCases.filter { !trainable.contains($0) }

        func sentence(_ language: Language) -> String {
            let declared = AdaptiveSituation.allCases
                .filter { needs.situations.contains($0) }
                .map { $0.label[language] }
                .joined(separator: ", ")

            var text: String
            switch language {
            case .french:
                text = declared.isEmpty
                    ? "Programme construit pour un entraînement assis."
                    : "Programme construit pour ta situation (\(declared)) : seuls les mouvements que ton corps peut exécuter sont proposés, et les séances se répartissent sur ce qui reste."
            case .english:
                text = declared.isEmpty
                    ? "Programme built for seated training."
                    : "Programme built for your situation (\(declared)): only movements your body can perform are offered, and the sessions spread over what remains."
            case .spanish:
                text = declared.isEmpty
                    ? "Programa construido para entrenar sentado."
                    : "Programa construido para tu situación (\(declared)): solo se proponen movimientos que tu cuerpo puede ejecutar, y las sesiones se reparten sobre lo que queda."
            }

            guard !untrainable.isEmpty else { return text }
            let names = untrainable.map { $0.label[language] }.joined(separator: ", ")
            switch language {
            case .french:
                text += " Le catalogue n'a aucun mouvement pour \(names) dans cette configuration : ces muscles sortent du calcul plutôt que d'apparaître à zéro."
            case .english:
                text += " The catalogue has no movement for \(names) in this configuration: those muscles leave the budget rather than showing up at zero."
            case .spanish:
                text += " El catálogo no tiene ningún movimiento para \(names) en esta configuración: esos músculos salen del cálculo en lugar de aparecer a cero."
            }
            return text
        }

        return LocalizedText(
            fr: sentence(.french), en: sentence(.english), es: sentence(.spanish)
        )
    }

    // MARK: - One session

    /// Week 1 of the block: chooses the movements and fits them in the time
    /// the athlete actually has.
    static func baseSession(
        dayIndex: Int,
        template: DayTemplate,
        budget: [MuscleGroup: Int],
        available: [Exercise],
        profile: UserProfile
    ) -> PlannedSession {
        let selections = ExerciseSelector.select(
            budget: budget,
            order: template.muscles,
            available: available,
            // Rotating by day keeps the two upper-body days of an upper/lower
            // split from being carbon copies of each other.
            rotation: dayIndex
        )

        let rpe = targetRPE(profile: profile, weekIndex: 1, totalWeeks: weekCount(for: profile), isDeload: false)
        let exercises = selections.enumerated().map { order, selection in
            prescription(for: selection, order: order, profile: profile, targetRPE: rpe, isDeload: false)
        }

        var session = PlannedSession(
            dayIndex: dayIndex,
            title: template.title,
            focus: template.muscles.filter { (budget[$0] ?? 0) > 0 },
            exercises: exercises,
            isDeload: false
        )
        // Leave 12 % of headroom so the volume ramp has somewhere to go.
        session = trim(session, toMinutes: Int(Double(profile.sessionMinutes) * 0.88))
        return session
    }

    /// Turns the base session into the version for a given week: volume ramps
    /// up across the block, then everything drops for the deload.
    static func apply(
        week: Int,
        totalWeeks: Int,
        isDeload: Bool,
        to base: PlannedSession,
        profile: UserProfile
    ) -> PlannedSession {
        var session = base
        session.isDeload = isDeload
        session.title = isDeload
            ? base.title + LocalizedText(fr: " — décharge", en: " — deload", es: " — descarga")
            : base.title

        let rpe = targetRPE(profile: profile, weekIndex: week, totalWeeks: totalWeeks, isDeload: isDeload)

        if isDeload {
            session.exercises = base.exercises.map { prescription in
                var copy = prescription
                let keep = max(2, Int((Double(prescription.sets.count) * 0.5).rounded()))
                copy.sets = Array(prescription.sets.prefix(keep)).map { set in
                    var updated = set
                    updated.targetRPE = rpe
                    return updated
                }
                return copy
            }
            return session
        }

        // One added set per exercise per week, round-robin from the top of the
        // session, stopping as soon as the session would overrun.
        var exercises = base.exercises
        var toAdd = week - 1
        var cursor = 0
        var guardRail = 0
        while toAdd > 0 && guardRail < exercises.count * 4 {
            guardRail += 1
            let index = cursor % max(1, exercises.count)
            cursor += 1
            guard let template = exercises[index].sets.first,
                  exercises[index].sets.count < maxSets(for: exercises[index])
            else { continue }

            var candidate = exercises
            var added = template
            added.index = candidate[index].sets.count
            added.isBackOff = candidate[index].sets.last?.isBackOff ?? false
            candidate[index].sets.append(added)

            var probe = session
            probe.exercises = candidate
            guard probe.estimatedMinutes <= profile.sessionMinutes else { break }

            exercises = candidate
            toAdd -= 1
        }

        session.exercises = exercises.map { prescription in
            var copy = prescription
            copy.sets = prescription.sets.map { set in
                var updated = set
                updated.targetRPE = set.isBackOff ? rpe - 1 : rpe
                return updated
            }
            return copy
        }
        return session
    }

    /// Compounds get fewer top-end sets than isolation: the fatigue cost of a
    /// sixth heavy squat set is not worth the extra stimulus.
    static func maxSets(for prescription: ExercisePrescription) -> Int {
        guard let exercise = ExerciseCatalog.exercise(id: prescription.exerciseID) else { return 4 }
        return exercise.isCompound ? 5 : 6
    }

    /// Drops sets from the end of the session until it fits the clock.
    /// An exercise is removed outright rather than left with a single set.
    static func trim(_ session: PlannedSession, toMinutes limit: Int) -> PlannedSession {
        var trimmed = session
        var guardRail = 0
        while trimmed.estimatedMinutes > limit && guardRail < 200 {
            guardRail += 1
            // Cutting a movement beats shaving every movement down to two
            // sets: eight exercises at two sets each is a warm-up, not a
            // session. The list is already ordered by importance, so the
            // accessories at the end go first.
            if trimmed.exercises.count > 6 {
                trimmed.exercises.removeLast()
                continue
            }
            if let index = trimmed.exercises.indices.reversed().first(where: {
                trimmed.exercises[$0].sets.count > 2
            }) {
                trimmed.exercises[index].sets.removeLast()
                continue
            }
            guard trimmed.exercises.count > 3 else { break }
            trimmed.exercises.removeLast()
        }
        // Re-number so the UI can trust `order`.
        trimmed.exercises = trimmed.exercises.enumerated().map { order, prescription in
            var copy = prescription
            copy.order = order
            copy.sets = copy.sets.enumerated().map { index, set in
                var updated = set
                updated.index = index
                return updated
            }
            return copy
        }
        return trimmed
    }

    static func prescription(
        for selection: ExerciseSelector.Selection,
        order: Int,
        profile: UserProfile,
        targetRPE: Double,
        isDeload: Bool
    ) -> ExercisePrescription {
        let exercise = selection.exercise
        let range = repRange(for: exercise, goal: profile.goal)
        let setCount = isDeload ? max(2, selection.sets - 1) : selection.sets

        var sets: [SetPrescription] = []
        for index in 0..<setCount {
            // Strength work uses a top set followed by back-offs; everything
            // else runs straight sets at a single target.
            let isBackOff = profile.goal == .strength && exercise.isCompound && index > 0
            sets.append(
                SetPrescription(
                    index: index,
                    repLowerBound: range.lowerBound,
                    repUpperBound: isBackOff ? range.upperBound + 2 : range.upperBound,
                    targetRPE: isBackOff ? targetRPE - 1 : targetRPE,
                    suggestedLoadKg: nil,
                    isBackOff: isBackOff
                )
            )
        }

        var rest = exercise.baseRestSeconds
        if profile.goal == .strength { rest += 30 }
        if profile.goal == .fatLoss { rest -= 20 }
        // Squeeze rest when the athlete has less time than the movement wants.
        if profile.sessionMinutes <= 45 { rest = min(rest, 120) }
        rest = max(45, rest)

        return ExercisePrescription(
            exerciseID: exercise.id,
            order: order,
            sets: sets,
            restSeconds: rest,
            note: exercise.cue
        )
    }

    /// Intersects the goal's rep range with what the movement can sensibly take.
    static func repRange(for exercise: Exercise, goal: PrimaryGoal) -> ClosedRange<Int> {
        let goalRange = goal.mainRepRange
        let viable = exercise.viableRepRange
        let lower = max(goalRange.lowerBound, viable.lowerBound)
        let upper = min(goalRange.upperBound, viable.upperBound)
        guard lower <= upper else {
            // No overlap — the movement wins, since a heavy triple on a
            // lateral raise is not a prescription anyone should follow.
            return viable
        }
        return lower...upper
    }

    /// RPE ramp: start with a rep in reserve to spare, finish the block at
    /// the goal's working RPE, drop hard on the deload.
    static func targetRPE(profile: UserProfile, weekIndex: Int, totalWeeks: Int, isDeload: Bool) -> Double {
        let working = profile.goal.workingRPE
        if isDeload { return max(5, working - 2.5) }
        let accumulationWeeks = max(1, totalWeeks - 1)
        let progress = Double(weekIndex - 1) / Double(max(1, accumulationWeeks - 1))
        let raw = (working - 1.0 + progress).clamped(to: 5...9.5)
        // RPE is a coarse instrument; 7,8333 would be false precision.
        return (raw * 2).rounded() / 2
    }
}
