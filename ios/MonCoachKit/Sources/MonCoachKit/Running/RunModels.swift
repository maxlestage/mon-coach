import Foundation

/// Le type d'une sortie, qui détermine l'allure visée et l'effort.
public enum RunType: String, Codable, CaseIterable, Sendable {
    case easy
    case long
    case tempo
    case intervals
    case recovery
    case race

    public var label: LocalizedText {
        switch self {
        case .easy:
            LocalizedText(fr: "Endurance fondamentale", en: "Easy run", es: "Rodaje suave")
        case .long:
            LocalizedText(fr: "Sortie longue", en: "Long run", es: "Tirada larga")
        case .tempo:
            LocalizedText(fr: "Tempo", en: "Tempo", es: "Tempo")
        case .intervals:
            LocalizedText(fr: "Fractionné", en: "Intervals", es: "Series")
        case .recovery:
            LocalizedText(fr: "Footing de récupération", en: "Recovery run", es: "Trote regenerativo")
        case .race:
            LocalizedText(fr: "Course", en: "Race", es: "Carrera")
        }
    }

    /// Ce que la séance cherche à produire, dit en une phrase.
    public var purpose: LocalizedText {
        switch self {
        case .easy:
            LocalizedText(
                fr: "Construire le moteur aérobie sans coût de récupération. C'est la sortie qu'on bâcle le plus souvent en la courant trop vite.",
                en: "Builds the aerobic engine at no recovery cost. It is the run most often ruined by running it too fast.",
                es: "Construye el motor aeróbico sin coste de recuperación. Es el rodaje que más se estropea por correrlo demasiado rápido."
            )
        case .long:
            LocalizedText(
                fr: "Habituer le corps à durer : c'est la durée qui compte, pas l'allure.",
                en: "Teaches the body to last: duration is what counts here, not pace.",
                es: "Acostumbra al cuerpo a durar: aquí cuenta el tiempo, no el ritmo."
            )
        case .tempo:
            LocalizedText(
                fr: "Courir au seuil, là où l'effort devient soutenu mais tenable. Le levier le plus direct sur ton chrono.",
                en: "Running at threshold, where the effort turns hard but stays sustainable. The most direct lever on your finishing time.",
                es: "Correr en umbral, donde el esfuerzo se vuelve exigente pero sostenible. La palanca más directa sobre tu marca."
            )
        case .intervals:
            LocalizedText(
                fr: "Travailler la vitesse et la VO2max sur des efforts courts et répétés, avec de vraies récupérations.",
                en: "Speed and VO2max work through short repeated efforts, with recoveries that are actually recoveries.",
                es: "Trabaja la velocidad y el VO2máx con esfuerzos cortos repetidos y recuperaciones de verdad."
            )
        case .recovery:
            LocalizedText(
                fr: "Faire circuler le sang sans ajouter de fatigue. Trop vite, cette sortie ne sert plus à rien.",
                en: "Moves blood without adding fatigue. Run it fast and it stops doing anything at all.",
                es: "Mueve la sangre sin añadir fatiga. Si lo corres rápido, deja de servir para nada."
            )
        case .race:
            LocalizedText(
                fr: "Le jour J, ou un test chronométré.",
                en: "Race day, or a timed test.",
                es: "El día de la carrera, o un test cronometrado."
            )
        }
    }

    /// Part de l'allure de seuil visée, pour dériver une allure cible.
    /// 1,0 = allure de seuil ; au-dessus de 1, plus lent.
    var paceFactor: ClosedRange<Double> {
        switch self {
        case .easy: 1.20...1.35
        case .long: 1.18...1.32
        case .tempo: 0.98...1.04
        case .intervals: 0.88...0.95
        case .recovery: 1.32...1.45
        case .race: 0.95...1.05
        }
    }
}

/// L'objectif de course de l'athlète, quand il en a un.
public enum RunningGoal: String, Codable, CaseIterable, Sendable {
    case firstFiveK
    case tenK
    case halfMarathon
    case marathon
    case endurance

    public var label: LocalizedText {
        switch self {
        case .firstFiveK:
            LocalizedText(fr: "Mon premier 5 km", en: "My first 5K", es: "Mis primeros 5 km")
        case .tenK:
            LocalizedText(fr: "10 km", en: "10K", es: "10 km")
        case .halfMarathon:
            LocalizedText(fr: "Semi-marathon", en: "Half marathon", es: "Media maratón")
        case .marathon:
            LocalizedText(fr: "Marathon", en: "Marathon", es: "Maratón")
        case .endurance:
            LocalizedText(fr: "Endurance générale", en: "General endurance", es: "Resistencia general")
        }
    }

    /// Distance de l'objectif en mètres. Nil quand il n'y a pas de course.
    public var raceDistanceMeters: Double? {
        switch self {
        case .firstFiveK: 5_000
        case .tenK: 10_000
        case .halfMarathon: 21_097.5
        case .marathon: 42_195
        case .endurance: nil
        }
    }

    /// Distance de la sortie longue en fin de préparation, en mètres.
    var peakLongRunMeters: Double {
        switch self {
        case .firstFiveK: 8_000
        case .tenK: 14_000
        case .halfMarathon: 20_000
        case .marathon: 32_000
        case .endurance: 12_000
        }
    }
}

/// Le profil de coureur, greffé au profil principal quand l'athlète court.
public struct RunningProfile: Codable, Sendable, Equatable {
    public var goal: RunningGoal
    /// Sorties par semaine, 1 à 6.
    public var runsPerWeek: Int
    /// Kilométrage hebdomadaire actuel, en mètres.
    public var currentWeeklyMeters: Double
    /// Date de la course visée, si elle existe.
    public var raceDate: Date?
    /// Meilleure allure de seuil connue, en secondes par kilomètre.
    /// Nil tant que l'athlète n'a pas couru assez pour l'estimer.
    public var thresholdPaceSecondsPerKm: Double?

    public init(
        goal: RunningGoal = .endurance,
        runsPerWeek: Int = 3,
        currentWeeklyMeters: Double = 15_000,
        raceDate: Date? = nil,
        thresholdPaceSecondsPerKm: Double? = nil
    ) {
        self.goal = goal
        self.runsPerWeek = runsPerWeek.clamped(to: 1...6)
        self.currentWeeklyMeters = max(0, currentWeeklyMeters)
        self.raceDate = raceDate
        self.thresholdPaceSecondsPerKm = thresholdPaceSecondsPerKm
    }
}

/// Une sortie prescrite par le coach.
public struct PlannedRun: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: UUID
    public var dayIndex: Int
    public var type: RunType
    /// Distance visée en mètres. Nil pour une séance définie par sa durée.
    public var targetMeters: Double?
    /// Durée visée. Nil pour une séance définie par sa distance.
    public var targetDuration: TimeInterval?
    /// Fourchette d'allure visée, en secondes par kilomètre.
    public var paceRangeSecondsPerKm: ClosedRange<Double>?
    /// Structure d'un fractionné, vide pour les sorties continues.
    public var intervals: [RunInterval]
    /// La consigne du coach. Traduite, contrairement à la note que
    /// l'athlète écrit lui-même après la sortie.
    public var note: LocalizedText

    public init(
        id: UUID = UUID(),
        dayIndex: Int,
        type: RunType,
        targetMeters: Double? = nil,
        targetDuration: TimeInterval? = nil,
        paceRangeSecondsPerKm: ClosedRange<Double>? = nil,
        intervals: [RunInterval] = [],
        note: LocalizedText
    ) {
        self.id = id
        self.dayIndex = dayIndex
        self.type = type
        self.targetMeters = targetMeters
        self.targetDuration = targetDuration
        self.paceRangeSecondsPerKm = paceRangeSecondsPerKm
        self.intervals = intervals
        self.note = note
    }
}

extension PlannedRun {

    /// Ce que la sortie demande, en une ligne.
    ///
    /// Une sortie prescrite se définit par sa distance, par sa durée, ou par
    /// ses répétitions — jamais par les trois. Chaque écran qui l'affichait
    /// choisissait jusqu'ici la distance et laissait les autres muettes :
    /// une séance de quarante-cinq minutes s'affichait sans rien du tout.
    public func summary(unit: UnitSystem, language: Language = .french) -> String? {
        // Un fractionné se dit par ses répétitions : « 6 × 400 m » porte
        // toute la séance, là où « 2,40 km » n'en dit rien.
        if intervals.count == 1, let block = intervals.first, block.repetitions > 0 {
            let leg = Format.distance(meters: block.meters, unit: unit, language: language)
            return "\(block.repetitions) × \(leg)"
        }
        if let targetMeters, targetMeters > 0 {
            return Format.distance(meters: targetMeters, unit: unit, language: language)
        }
        if let targetDuration, targetDuration > 0 {
            return Format.duration(minutes: Int((targetDuration / 60).rounded()), language: language)
        }
        return nil
    }
}

/// Une répétition d'un fractionné.
public struct RunInterval: Codable, Sendable, Equatable, Hashable {
    public var repetitions: Int
    public var meters: Double
    public var recoverySeconds: TimeInterval
    public var paceSecondsPerKm: Double

    public init(repetitions: Int, meters: Double, recoverySeconds: TimeInterval, paceSecondsPerKm: Double) {
        self.repetitions = repetitions
        self.meters = meters
        self.recoverySeconds = recoverySeconds
        self.paceSecondsPerKm = paceSecondsPerKm
    }
}
