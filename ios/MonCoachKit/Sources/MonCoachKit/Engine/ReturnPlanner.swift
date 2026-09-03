import Foundation

/// Ce qu'on change à la reprise, après un arrêt.
public struct ReturnToTraining: Sendable, Equatable {
    /// Jours écoulés depuis la dernière séance de renforcement.
    public var daysAway: Int
    /// La part retirée aux charges, de 0 à 1.
    public var loadReduction: Double
    /// La part retirée au volume — séries et répétitions.
    public var volumeReduction: Double
    /// Combien de semaines pour retrouver le niveau d'avant.
    public var rampWeeks: Int
    /// L'athlète a-t-il bougé pendant l'arrêt, autrement qu'en salle ?
    public var stayedActive: Bool
    /// Faut-il reconstruire le bloc plutôt que reprendre le fil ?
    public var rebuildsBlock: Bool

    public var headline: LocalizedText
    public var message: LocalizedText

    public init(
        daysAway: Int,
        loadReduction: Double,
        volumeReduction: Double,
        rampWeeks: Int,
        stayedActive: Bool,
        rebuildsBlock: Bool,
        headline: LocalizedText,
        message: LocalizedText
    ) {
        self.daysAway = daysAway
        self.loadReduction = loadReduction
        self.volumeReduction = volumeReduction
        self.rampWeeks = rampWeeks
        self.stayedActive = stayedActive
        self.rebuildsBlock = rebuildsBlock
        self.headline = headline
        self.message = message
    }
}

/// Décide comment reprendre après un arrêt.
///
/// Pourquoi ce type existe
/// -----------------------
/// Rien, dans tout le moteur, ne demandait depuis combien de temps l'athlète
/// n'avait pas soulevé. Deux semaines de grippe, trois semaines de vacances,
/// et l'application tendait **exactement les mêmes charges qu'avant** — celles
/// calculées sur une progression interrompue.
///
/// C'est le moment précis où un coach sert à quelque chose, et celui où les
/// applications décrochent. Deux issues, toutes deux mauvaises : on se blesse,
/// ou on échoue à la première série et on décide que ce n'est plus pour soi.
///
/// La distinction qui commande tout le reste
/// -----------------------------------------
/// **La force se perd lentement ; la tolérance au volume se perd vite.**
///
/// Après trois semaines d'arrêt, on soulève encore presque autant qu'avant —
/// mais on ne supporte plus vingt séries de jambes dans la semaine. Les
/// courbatures de la reprise ne viennent pas de la charge, elles viennent du
/// volume. C'est pour cela que le volume est toujours coupé plus fort que la
/// charge, et jamais l'inverse.
///
/// Ce qu'une autre activité change, et ce qu'elle ne change pas
/// ------------------------------------------------------------
/// Quelqu'un qui a couru pendant son arrêt de salle a gardé une partie de sa
/// capacité de travail : sa reprise pique moins, et on lui coupe moins de
/// volume. En revanche il n'a rien gardé de son développé couché : la force
/// est spécifique, et courir ne fait pas pousser. La charge est donc réduite
/// pareil, qu'il ait bougé ou non.
///
/// Une remarque sur les seuils
/// ---------------------------
/// Ils sont peu nombreux et grossiers, à dessein. Personne ne connaît le
/// pourcentage juste — il dépend de l'âge, de l'ancienneté, de ce qui a causé
/// l'arrêt. Un chiffre à la décimale serait une précision inventée. Ce qui
/// compte est le sens : redescendre franchement, remonter vite, et le dire.
public enum ReturnPlanner {

    /// En dessous, il ne s'est rien passé.
    ///
    /// Une semaine sans salle est une semaine ordinaire : quatre séances
    /// prévues, des jours de repos entre elles, un week-end chargé. Traiter
    /// dix jours comme un désentraînement serait insultant, et surtout faux.
    public static let graceDays = 10

    /// Les paliers, du plus court au plus long.
    ///
    /// Chaque palier porte ses deux nombres et le temps qu'il faut pour
    /// revenir. Le volume est toujours coupé plus fort que la charge — voir
    /// la note du type.
    struct Tier {
        var fromDays: Int
        var load: Double
        var volume: Double
        var rampWeeks: Int
        var rebuilds: Bool
    }

    static let tiers: [Tier] = [
        // Dix jours à trois semaines : à peine un accroc.
        Tier(fromDays: 10, load: 0.05, volume: 0.20, rampWeeks: 1, rebuilds: false),
        // Trois à six semaines : la capacité de travail a nettement baissé.
        Tier(fromDays: 21, load: 0.10, volume: 0.35, rampWeeks: 2, rebuilds: false),
        // Six semaines à trois mois : il faut reconstruire, pas reprendre.
        Tier(fromDays: 42, load: 0.20, volume: 0.50, rampWeeks: 3, rebuilds: true),
        // Au-delà de trois mois : c'est un recommencement, et le dire
        // honnêtement vaut mieux que de faire semblant de continuer.
        Tier(fromDays: 90, load: 0.30, volume: 0.60, rampWeeks: 4, rebuilds: true),
    ]

    /// Le plan de reprise, ou nil s'il n'y a rien à signaler.
    public static func plan(
        history: TrainingHistory,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> ReturnToTraining? {
        guard let last = lastStrengthSession(history) else { return nil }
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: last), to: calendar.startOfDay(for: date)
        ).day ?? 0
        guard days >= graceDays else { return nil }

        let active = stayedActive(history, between: last, and: date, calendar: calendar)
        return plan(daysAway: days, stayedActive: active)
    }

    /// Le même calcul, à partir des seuls jours — c'est lui que les tests
    /// interrogent, et lui qui porte la règle.
    public static func plan(daysAway days: Int, stayedActive active: Bool) -> ReturnToTraining? {
        guard days >= graceDays else { return nil }
        guard let tier = tiers.last(where: { days >= $0.fromDays }) else { return nil }

        // Avoir bougé rend la reprise moins douloureuse, donc on coupe moins
        // de volume. La charge, elle, ne bouge pas : courir ne fait pas
        // pousser, et la force est spécifique au mouvement.
        let volume = active ? tier.volume * 0.6 : tier.volume

        return ReturnToTraining(
            daysAway: days,
            loadReduction: tier.load,
            volumeReduction: volume,
            rampWeeks: tier.rampWeeks,
            stayedActive: active,
            rebuildsBlock: tier.rebuilds,
            headline: headline(days: days),
            message: message(days: days, tier: tier, volume: volume, active: active)
        )
    }

    /// Ce qu'il reste de l'allègement après quelques semaines de reprise.
    ///
    /// L'allègement s'efface linéairement : à la moitié du chemin il en reste
    /// la moitié, à la fin il n'en reste rien. Une reprise qui garderait ses
    /// dix pour cent de moins pour toujours ne serait pas une reprise, ce
    /// serait une régression déguisée.
    public static func easing(
        _ plan: ReturnToTraining, weeksBack: Int
    ) -> (load: Double, volume: Double) {
        guard plan.rampWeeks > 0 else { return (0, 0) }
        guard weeksBack < plan.rampWeeks else { return (0, 0) }
        let remaining = Double(plan.rampWeeks - weeksBack) / Double(plan.rampWeeks)
        return (plan.loadReduction * remaining, plan.volumeReduction * remaining)
    }

    // MARK: - Ce que l'historique dit

    /// La dernière séance de salle réellement faite.
    ///
    /// Les séances sautées ne comptent pas : c'est bien pour cela qu'elles
    /// sont marquées, et une séance sautée est précisément un jour où on n'a
    /// rien soulevé.
    static func lastStrengthSession(_ history: TrainingHistory) -> Date? {
        history.sessions.filter { !$0.skipped }.map(\.date).max()
    }

    /// A-t-il bougé pendant l'arrêt, à un rythme qui compte ?
    ///
    /// Une sortie dans un arrêt de six semaines ne préserve rien. Le seuil
    /// est d'environ une par semaine — en dessous, c'est une exception, pas
    /// un entretien.
    static func stayedActive(
        _ history: TrainingHistory, between start: Date, and end: Date, calendar: Calendar
    ) -> Bool {
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: start), to: calendar.startOfDay(for: end)
        ).day ?? 0
        guard days > 0 else { return false }
        let during = history.activities.filter { $0.startedAt > start && $0.startedAt <= end }
        let weeks = max(1.0, Double(days) / 7)
        return Double(during.count) / weeks >= 1
    }

    // MARK: - Ce qu'on lui dit

    static func headline(days: Int) -> LocalizedText {
        let weeks = days / 7
        if weeks < 4 {
            return LocalizedText(
                fr: "\(weeks) semaine\(weeks > 1 ? "s" : "") sans salle",
                en: "\(weeks) week\(weeks > 1 ? "s" : "") away from the gym",
                es: "\(weeks) semana\(weeks > 1 ? "s" : "") sin gimnasio"
            )
        }
        let months = max(1, days / 30)
        return LocalizedText(
            fr: "\(months) mois sans salle",
            en: "\(months) month\(months > 1 ? "s" : "") away from the gym",
            es: "\(months) mes\(months > 1 ? "es" : "") sin gimnasio"
        )
    }

    static func message(
        days: Int, tier: Tier, volume: Double, active: Bool
    ) -> LocalizedText {
        let load = Int((tier.load * 100).rounded())
        let cut = Int((volume * 100).rounded())
        let weeks = tier.rampWeeks

        // Le point le plus utile à faire passer, et le moins intuitif : ce
        // qui a baissé, ce n'est pas tant la force que la capacité à encaisser
        // du volume. Quelqu'un qui l'ignore reprend à son ancien volume,
        // finit courbaturé trois jours, et en conclut qu'il a tout perdu.
        let physiology = LocalizedText(
            fr: "Ta force n'a presque pas bougé — c'est ta tolérance au volume qui a baissé. Les courbatures de la reprise viennent du nombre de séries, pas de la charge.",
            en: "Your strength has barely moved — it is your tolerance for volume that dropped. Comeback soreness comes from the number of sets, not the load.",
            es: "Tu fuerza apenas ha cambiado; lo que ha bajado es tu tolerancia al volumen. Las agujetas de la vuelta vienen del número de series, no de la carga."
        )

        let kept = active
            ? LocalizedText(
                fr: " Tu as continué à bouger, donc on coupe moins : ta capacité de travail a tenu. La charge baisse quand même — courir ne fait pas pousser.",
                en: " You kept moving, so we cut less: your work capacity held. The load still comes down — running does not build a bench press.",
                es: " Has seguido moviéndote, así que recortamos menos: tu capacidad de trabajo aguantó. La carga baja igual: correr no construye un press de banca."
            )
            : LocalizedText(fr: "", en: "", es: "")

        return LocalizedText(
            fr: "\(physiology.fr) On reprend à \(load) % de charge en moins et \(cut) % de volume en moins, et on remonte sur \(weeks) semaine\(weeks > 1 ? "s" : "").\(kept.fr)",
            en: "\(physiology.en) We restart \(load) % lighter with \(cut) % less volume, and climb back over \(weeks) week\(weeks > 1 ? "s" : "").\(kept.en)",
            es: "\(physiology.es) Volvemos con \(load) % menos de carga y \(cut) % menos de volumen, y subimos en \(weeks) semana\(weeks > 1 ? "s" : "").\(kept.es)"
        )
    }
}
