import Foundation

/// Une semaine d'entraînement, telle qu'un graphique la demande.
///
/// Les semaines sans séance en font partie, et c'est tout l'intérêt : une
/// série de barres qui ne contient que les semaines travaillées n'a plus
/// d'axe du temps. Deux séances espacées d'un mois y donnent deux barres
/// côte à côte, aussi larges que l'écran, et on ne voit ni le trou ni la
/// tendance — on ne voit rien du tout.
public struct VolumeWeek: Sendable, Equatable, Identifiable {
    /// Le lundi de la semaine.
    public var start: Date
    public var sets: Int
    public var tonnageKg: Double
    public var sessions: Int

    public var id: Date { start }
    public var isEmpty: Bool { sessions == 0 }

    public init(start: Date, sets: Int = 0, tonnageKg: Double = 0, sessions: Int = 0) {
        self.start = start
        self.sets = sets
        self.tonnageKg = tonnageKg
        self.sessions = sessions
    }
}

/// Ce qu'on mesure d'une semaine d'entraînement.
///
/// Trois lectures d'une même réalité, et elles ne mentent pas au même
/// endroit : le tonnage ignore tout ce qui se fait au poids du corps, les
/// séries ne disent rien de la charge, et le nombre de séances ne dit rien
/// du travail fait dedans. Les trois ensemble ne laissent pas de trou.
public enum VolumeMeasure: String, Sendable, CaseIterable, Identifiable {
    case sets
    case tonnage
    case sessions

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .sets: LocalizedText(fr: "Séries", en: "Sets", es: "Series")
        case .tonnage: LocalizedText(fr: "Tonnage", en: "Tonnage", es: "Tonelaje")
        case .sessions: LocalizedText(fr: "Séances", en: "Sessions", es: "Sesiones")
        }
    }

    /// Ce que la mesure vaut pour une semaine.
    public func value(of week: VolumeWeek) -> Double {
        switch self {
        case .sets: Double(week.sets)
        case .tonnage: week.tonnageKg
        case .sessions: Double(week.sessions)
        }
    }

    /// Ce que la mesure explique, dit en une phrase sous le titre.
    public var explanation: LocalizedText {
        switch self {
        case .sets:
            LocalizedText(
                fr: "Une série faite est une série faite : c'est la mesure la plus honnête du travail, y compris au poids du corps.",
                en: "A set done is a set done: the most honest measure of the work, bodyweight movements included.",
                es: "Una serie hecha es una serie hecha: la medida más honesta del trabajo, incluidos los movimientos con peso corporal."
            )
        case .tonnage:
            LocalizedText(
                fr: "Le poids total déplacé. Il monte quand tu charges plus lourd — et il ignore tout ce que tu fais au poids du corps.",
                en: "Total weight moved. It rises as you load heavier — and it ignores everything you do with bodyweight.",
                es: "El peso total desplazado. Sube cuando cargas más — e ignora todo lo que haces con el peso corporal."
            )
        case .sessions:
            LocalizedText(
                fr: "Le nombre de fois où tu y es allé. C'est ce qui décide de tout le reste, et c'est la seule colonne qu'on ne rattrape jamais.",
                en: "How many times you turned up. It decides everything else, and it is the one column you never catch up on.",
                es: "Cuántas veces fuiste. Decide todo lo demás, y es la única columna que nunca se recupera."
            )
        }
    }
}

/// Le volume d'entraînement, semaine par semaine.
public enum TrainingVolume {

    /// Les `window` dernières semaines, de la plus ancienne à la plus
    /// récente, trous compris.
    ///
    /// La fenêtre est fixe et se termine sur la semaine en cours : c'est ce
    /// qui donne au graphique un axe du temps réel, où une barre haute
    /// signifie une grosse semaine et un vide signifie une semaine sautée.
    /// Sans ça, deux semaines de données remplissent tout l'écran et ne
    /// disent rien.
    public static func weeks(
        from sessions: [SessionLog],
        window: Int = 12,
        endingOn day: Date = Date(),
        calendar: Calendar = .current
    ) -> [VolumeWeek] {
        guard window > 0,
              let thisWeek = calendar.dateInterval(of: .weekOfYear, for: day)?.start
        else { return [] }

        var byWeek: [Date: VolumeWeek] = [:]
        for session in sessions where !session.skipped {
            guard let start = calendar.dateInterval(of: .weekOfYear, for: session.date)?.start
            else { continue }
            var week = byWeek[start] ?? VolumeWeek(start: start)
            week.sets += session.sets.count
            week.tonnageKg += session.totalVolumeKg
            week.sessions += 1
            byWeek[start] = week
        }

        return (0..<window).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: .weekOfYear, value: -offset, to: thisWeek)
            else { return nil }
            return byWeek[start] ?? VolumeWeek(start: start)
        }
    }

    /// La moyenne d'une mesure sur les semaines réellement travaillées.
    ///
    /// Les semaines vides sont écartées du calcul : inclure les six semaines
    /// d'avant l'inscription tirerait la moyenne vers zéro et donnerait une
    /// ligne de référence qui ne veut rien dire. C'est une moyenne de ce
    /// qu'on fait quand on y va, pas une moyenne de la vie entière.
    public static func average(of weeks: [VolumeWeek], measure: VolumeMeasure) -> Double? {
        let worked = weeks.filter { !$0.isEmpty }
        guard !worked.isEmpty else { return nil }
        return worked.map { measure.value(of: $0) }.reduce(0, +) / Double(worked.count)
    }

    /// La meilleure semaine de la fenêtre, pour cette mesure.
    public static func best(of weeks: [VolumeWeek], measure: VolumeMeasure) -> VolumeWeek? {
        weeks.filter { !$0.isEmpty }.max { measure.value(of: $0) < measure.value(of: $1) }
    }

    /// Ce que la semaine en cours vaut par rapport aux précédentes.
    ///
    /// C'est la seule lecture qui fait agir : « quatre séries de moins que
    /// d'habitude, et il reste trois jours » dit quoi faire, là où une barre
    /// isolée ne dit rien.
    public static func standing(
        of weeks: [VolumeWeek],
        measure: VolumeMeasure
    ) -> (current: Double, average: Double, difference: Double)? {
        guard let current = weeks.last else { return nil }
        // La moyenne se calcule sans la semaine en cours : se comparer à
        // soi-même en s'incluant dans la référence adoucit toujours l'écart,
        // et c'est précisément l'écart qu'on veut voir.
        guard let average = average(of: weeks.dropLast(), measure: measure) else { return nil }
        let value = measure.value(of: current)
        return (value, average, value - average)
    }

    /// Le nombre de semaines d'affilée avec au moins une séance, en
    /// remontant depuis la semaine en cours.
    ///
    /// La semaine en cours ne casse pas la série tant qu'elle n'est pas
    /// finie : on est mercredi, on n'a pas encore été à la salle, et
    /// annoncer que la série est cassée serait faux — et décourageant au
    /// pire moment.
    public static func streak(
        from sessions: [SessionLog],
        endingOn day: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        guard let thisWeek = calendar.dateInterval(of: .weekOfYear, for: day)?.start
        else { return 0 }
        var worked = Set<Date>()
        for session in sessions where !session.skipped {
            if let start = calendar.dateInterval(of: .weekOfYear, for: session.date)?.start {
                worked.insert(start)
            }
        }

        var streak = 0
        var cursor = thisWeek
        // La semaine en cours compte si elle a déjà une séance ; sinon on
        // commence à compter la semaine d'avant, sans la casser.
        if !worked.contains(cursor) {
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor)
            else { return 0 }
            cursor = previous
        }
        while worked.contains(cursor), streak < 520 {
            streak += 1
            guard let previous = calendar.date(byAdding: .weekOfYear, value: -1, to: cursor)
            else { break }
            cursor = previous
        }
        return streak
    }
}
