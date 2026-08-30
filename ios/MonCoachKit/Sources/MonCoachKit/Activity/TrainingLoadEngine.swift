import Foundation

/// Un jour sur la courbe de forme : la condition, la fatigue, et leur solde.
public struct FitnessPoint: Sendable, Equatable, Identifiable {
    public var date: Date
    /// La condition : la charge des six dernières semaines, lissée. Elle
    /// monte lentement — c'est l'entraînement qui s'accumule.
    public var fitness: Double
    /// La fatigue : la charge des sept derniers jours, lissée. Elle monte
    /// vite et redescend vite — c'est le prix immédiat des séances.
    public var fatigue: Double
    /// La forme : condition moins fatigue. Négative en pleine charge,
    /// positive après quelques jours calmes — c'est le solde qu'on amène
    /// sur une ligne de départ.
    public var form: Double { fitness - fatigue }

    public var id: Date { date }
}

/// La charge d'entraînement dans le temps : condition, fatigue, forme.
///
/// Pourquoi ce moteur existe
/// -------------------------
/// Chaque sortie est déjà mesurée une par une. Ce qu'aucun écran ne disait,
/// c'est ce qu'elles font *ensemble* : s'entraîner dur trois semaines puis
/// lever le pied une, c'est exactement comme ça qu'on arrive en forme — et
/// sans cette courbe, ça ressemble juste à une semaine paresseuse.
///
/// Le modèle est celui que tout le monde utilise (Banister, puis Coggan) :
/// deux moyennes exponentielles de la même charge quotidienne, une lente à
/// 42 jours pour la condition, une rapide à 7 jours pour la fatigue. Aucun
/// des trois chiffres n'a d'unité ni de sens absolu : ils ne se comparent
/// qu'à soi-même, et c'est précisément ce qu'on leur demande.
public enum TrainingLoadEngine {

    /// La constante lente : six semaines pour construire une condition.
    static let fitnessDays = 42.0
    /// La constante rapide : une semaine pour absorber une fatigue.
    static let fatigueDays = 7.0

    // MARK: - L'effort d'une sortie

    /// La charge d'une activité, en points d'effort.
    ///
    /// Trois sources, de la meilleure à la moins bonne, et une seule échelle :
    ///
    /// 1. Le cardio, quand un capteur était là — le TRIMP d'Edwards, minutes
    ///    pondérées par la zone (1 à 5).
    /// 2. L'effort ressenti, saisi après la sortie — minutes × RPE/2, ce qui
    ///    ramène le RPE (1–10) sur la même échelle que les zones (1–5).
    /// 3. L'intention de la séance, sinon — un tempo coûte plus qu'un footing,
    ///    même sans capteur ni saisie.
    ///
    /// Les trois estiment la même chose et se mélangent donc dans une seule
    /// courbe : une sortie au capteur et une sortie au ressenti s'additionnent.
    public static func effort(for activity: ActivityLog, maximumBpm: Double) -> Double {
        if !activity.heartRate.isEmpty {
            let perZone = HeartRateAnalysis.secondsPerZone(
                samples: activity.heartRate,
                maximumBpm: maximumBpm
            )
            let load = HeartRateAnalysis.trainingLoad(secondsPerZone: perZone)
            if load > 0 { return load }
        }

        let minutes = activity.duration / 60
        if let rpe = activity.perceivedEffort {
            return minutes * Double(rpe) / 2
        }
        return minutes * intensityWeight(for: activity) / 2
    }

    /// Le poids d'intensité par défaut, sur l'échelle du RPE (1–10).
    ///
    /// Volontairement prudent : surestimer la charge d'un footing gonflerait
    /// la condition affichée, et une condition flatteuse est une condition
    /// qui ment le jour où on s'appuie dessus.
    static func intensityWeight(for activity: ActivityLog) -> Double {
        switch activity.sport {
        case .walk: return 2
        case .hike: return 4
        case .ride: return 5
        case .run, .trail:
            switch activity.type {
            case .recovery: return 3
            case .easy: return 4
            case .long: return 5
            case .tempo: return 6
            case .intervals: return 8
            case .race: return 9
            }
        }
    }

    // MARK: - La courbe

    /// La courbe jour par jour, terminée sur `endingOn`.
    ///
    /// Le calcul démarre à la première activité, pas au début de la fenêtre
    /// affichée : une moyenne à 42 jours qui commencerait au bord de l'écran
    /// serait fausse sur tout son premier tiers. On calcule tout, on ne rend
    /// que la fenêtre.
    public static func series(
        activities: [ActivityLog],
        maximumBpm: Double,
        endingOn end: Date = Date(),
        days: Int = 90,
        calendar: Calendar = .current
    ) -> [FitnessPoint] {
        let endDay = calendar.startOfDay(for: end)
        guard let windowStart = calendar.date(byAdding: .day, value: -(days - 1), to: endDay)
        else { return [] }

        // La charge de chaque jour : la somme des sorties du jour.
        var dailyLoad: [Date: Double] = [:]
        for activity in activities where activity.startedAt <= end {
            let day = calendar.startOfDay(for: activity.startedAt)
            dailyLoad[day, default: 0] += effort(for: activity, maximumBpm: maximumBpm)
        }
        guard let firstDay = dailyLoad.keys.min() else { return [] }

        let start = min(firstDay, windowStart)
        var fitness = 0.0
        var fatigue = 0.0
        var points: [FitnessPoint] = []
        var cursor = start
        while cursor <= endDay {
            let load = dailyLoad[cursor] ?? 0
            fitness += (load - fitness) / fitnessDays
            fatigue += (load - fatigue) / fatigueDays
            if cursor >= windowStart {
                points.append(FitnessPoint(date: cursor, fitness: fitness, fatigue: fatigue))
            }
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return points
    }

    // MARK: - Ce que ça veut dire

    /// La lecture du jour, en une phrase — ou rien.
    ///
    /// Rien tant que la condition est trop maigre pour porter un verdict :
    /// trois sorties ne font pas une tendance, et un conseil rendu sur du
    /// bruit vaut moins que pas de conseil.
    public static func verdict(for point: FitnessPoint) -> LocalizedText? {
        guard point.fitness >= 10 else { return nil }
        switch point.form {
        case 5...:
            return LocalizedText(
                fr: "Frais. C'est le moment d'une belle séance ou d'un objectif — la forme redescend si elle ne sert à rien.",
                en: "Fresh. This is the moment for a big session or a goal — form fades if it goes unused.",
                es: "Fresco. Es el momento de una buena sesión o un objetivo: la forma se pierde si no se usa."
            )
        case -10..<5:
            return LocalizedText(
                fr: "Équilibre : la charge et la récupération se répondent. Continue comme ça.",
                en: "Balanced: load and recovery are answering each other. Keep going.",
                es: "Equilibrio: la carga y la recuperación se responden. Sigue así."
            )
        case -30..<(-10):
            return LocalizedText(
                fr: "Charge productive : tu construis. Garde un œil sur le sommeil, c'est lui qui encaisse.",
                en: "Productive load: you are building. Keep an eye on sleep — it takes the hit.",
                es: "Carga productiva: estás construyendo. Vigila el sueño, es quien lo encaja."
            )
        default:
            return LocalizedText(
                fr: "Fatigue lourde : lève le pied quelques jours. S'entêter ici coûte plus qu'il ne rapporte.",
                en: "Heavy fatigue: back off for a few days. Pushing through here costs more than it pays.",
                es: "Fatiga alta: afloja unos días. Insistir aquí cuesta más de lo que aporta."
            )
        }
    }
}
