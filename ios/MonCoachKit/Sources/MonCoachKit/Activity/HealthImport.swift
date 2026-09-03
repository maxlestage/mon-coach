import Foundation

/// Une mesure lue dans Santé, réduite à ce qui nous sert.
///
/// Pourquoi ces types existent plutôt que les types d'Apple
/// --------------------------------------------------------
/// `HKQuantitySample` ne se construit pas sur une machine sans HealthKit,
/// donc rien de ce qui le touche ne se teste. La règle qui compte — ce qu'on
/// adopte, ce qu'on écarte, ce qu'on ne touche jamais — n'a pourtant besoin
/// que d'une date et d'un nombre. On la sort donc de HealthKit : l'app
/// traduit, le moteur décide.
public struct HealthWeight: Sendable, Equatable, Hashable {
    public var date: Date
    public var kilograms: Double

    public init(date: Date, kilograms: Double) {
        self.date = date
        self.kilograms = kilograms
    }
}

/// Une nuit, telle que Santé l'a mesurée.
public struct HealthSleep: Sendable, Equatable, Hashable {
    /// Le jour du réveil : c'est celui dont la séance dépend.
    public var wakeDate: Date
    public var hours: Double

    public init(wakeDate: Date, hours: Double) {
        self.wakeDate = wakeDate
        self.hours = hours
    }
}

/// Une séance enregistrée par une autre application.
public struct HealthWorkout: Sendable, Equatable, Hashable {
    public var startedAt: Date
    public var duration: TimeInterval
    public var meters: Double
    public var kilocalories: Double?
    public var sport: Sport
    /// Le nom de l'application qui l'a écrite, tel que Santé le donne.
    public var source: String

    public init(
        startedAt: Date,
        duration: TimeInterval,
        meters: Double,
        kilocalories: Double? = nil,
        sport: Sport,
        source: String
    ) {
        self.startedAt = startedAt
        self.duration = duration
        self.meters = meters
        self.kilocalories = kilocalories
        self.sport = sport
        self.source = source
    }
}

/// Ce que le téléphone adopte de Santé, et ce qu'il laisse.
///
/// Pourquoi ce type existe
/// -----------------------
/// La montre écrivait dans Santé ; le téléphone n'y lisait rien. La lecture
/// manquait à sens unique, et cela se voyait à trois endroits : on tapait ses
/// heures de sommeil à la main alors que la montre les connaissait, un poids
/// noté dans une balance connectée restait invisible, et une sortie faite
/// avec une autre application n'existait pas.
///
/// Les trois règles qui tiennent tout
/// ----------------------------------
/// 1. **Ce que l'athlète a saisi gagne toujours.** Santé complète les trous,
///    elle n'écrase rien. Quelqu'un qui a pesé 82,4 sur sa balance de salle
///    de bain et l'a noté ne doit pas voir son chiffre remplacé par celui
///    d'un pèse-personne oublié.
/// 2. **On n'importe jamais ce qu'on a écrit soi-même.** La montre enregistre
///    ses séances dans Santé : les relire les compterait deux fois, et une
///    semaine à quatre sorties en afficherait huit.
/// 3. **Deux enregistrements qui commencent à la même minute sont le même
///    effort.** Deux applications qui suivent la même course la datent à
///    quelques secondes près ; exiger l'égalité stricte laisserait passer le
///    doublon que la règle 2 essayait d'éviter.
public enum HealthImport {

    /// L'écart en dessous duquel deux enregistrements sont le même effort.
    ///
    /// Trois minutes : deux applications lancées l'une après l'autre au
    /// départ d'une même sortie tiennent largement dedans, et deux vraies
    /// séances distinctes ne commencent pas à trois minutes d'intervalle.
    public static let sameEffortWindow: TimeInterval = 180

    /// Les pesées à ajouter — celles des jours où l'athlète n'a rien noté.
    ///
    /// Une seule par jour, la plus récente : Santé peut en porter trois pour
    /// un même matin si la balance a hésité, et les trois donneraient une
    /// courbe de poids en dents de scie qui ne veut rien dire.
    public static func newBodyLogs(
        from samples: [HealthWeight],
        existing: [BodyLog],
        calendar: Calendar = .current
    ) -> [BodyLog] {
        let taken = Set(existing.map { calendar.startOfDay(for: $0.date) })
        var best: [Date: HealthWeight] = [:]
        for sample in samples {
            let day = calendar.startOfDay(for: sample.date)
            guard !taken.contains(day) else { continue }
            if let already = best[day], already.date >= sample.date { continue }
            best[day] = sample
        }
        return best.values
            .sorted { $0.date < $1.date }
            .map { BodyLog(date: $0.date, weightKg: $0.kilograms) }
    }

    /// Les heures dormies la nuit précédant un jour donné, s'il y en a.
    ///
    /// Sert à pré-remplir le bilan de forme au lieu de le demander. Le
    /// chiffre reste modifiable : une montre qui a passé la nuit sur la
    /// table de chevet a mesuré le sommeil de la table de chevet.
    public static func sleepHours(
        on day: Date,
        from nights: [HealthSleep],
        calendar: Calendar = .current
    ) -> Double? {
        nights
            .filter { calendar.isDate($0.wakeDate, inSameDayAs: day) }
            .map(\.hours)
            .max()
    }

    /// Les sorties à ajouter au journal.
    ///
    /// Sont écartées : celles que nous avons écrites nous-mêmes, celles qui
    /// doublent une sortie déjà enregistrée, et celles qui durent moins d'une
    /// minute — Santé en porte beaucoup, laissées par un lancement raté, et
    /// elles ne feraient qu'encombrer le journal.
    public static func newActivities(
        from workouts: [HealthWorkout],
        existing: [ActivityLog],
        ourSourceNames: Set<String>
    ) -> [ActivityLog] {
        let starts = existing.map(\.startedAt).sorted()
        var adopted: [Date] = []

        return workouts
            .sorted { $0.startedAt < $1.startedAt }
            .filter { workout in
                guard workout.duration >= 60 else { return false }
                guard !ourSourceNames.contains(workout.source) else { return false }
                let clash = (starts + adopted).contains {
                    abs($0.timeIntervalSince(workout.startedAt)) < sameEffortWindow
                }
                guard !clash else { return false }
                adopted.append(workout.startedAt)
                return true
            }
            .map { workout in
                ActivityLog(
                    startedAt: workout.startedAt,
                    sport: workout.sport,
                    type: .easy,
                    meters: workout.meters,
                    duration: workout.duration,
                    elevationGain: 0,
                    kilocalories: workout.kilocalories,
                    note: importNote(workout.source)[.french]
                )
            }
    }

    /// D'où vient une sortie importée. Écrit dans la note plutôt que deviné
    /// plus tard : une sortie sans tracé qui apparaît sans explication passe
    /// pour un bogue.
    static func importNote(_ source: String) -> LocalizedText {
        LocalizedText(
            fr: "Importée depuis Santé (\(source)). Pas de tracé : seuls la durée et la distance ont été enregistrés.",
            en: "Imported from Health (\(source)). No route: only duration and distance were recorded.",
            es: "Importada desde Salud (\(source)). Sin traza: solo se registraron duración y distancia."
        )
    }
}
