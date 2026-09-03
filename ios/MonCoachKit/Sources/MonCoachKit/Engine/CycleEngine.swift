import Foundation

/// Où l'on en est du cycle.
public enum CyclePhase: String, Codable, Sendable, CaseIterable, Hashable {
    case menstrual
    case follicular
    case ovulatory
    case luteal

    public var label: LocalizedText {
        switch self {
        case .menstrual: LocalizedText(fr: "Règles", en: "Period", es: "Regla")
        case .follicular: LocalizedText(fr: "Phase folliculaire", en: "Follicular phase", es: "Fase folicular")
        case .ovulatory: LocalizedText(fr: "Autour de l'ovulation", en: "Around ovulation", es: "Alrededor de la ovulación")
        case .luteal: LocalizedText(fr: "Phase lutéale", en: "Luteal phase", es: "Fase lútea")
        }
    }
}

/// Ce que le cycle de l'athlète, et lui seul, permet de dire.
public struct CyclePattern: Sendable, Equatable {
    public var phase: CyclePhase
    public var dayOfCycle: Int
    /// Le score de forme moyen de cette athlète dans cette phase.
    public var averageReadiness: Int?
    /// Son score moyen toutes phases confondues, pour comparer.
    public var overallReadiness: Int?
    /// Combien de bilans nourrissent la moyenne de la phase.
    public var samples: Int
    /// Vrai quand l'écart entre la phase et le reste est assez net et assez
    /// nourri pour valoir la peine d'être dit.
    public var isMeaningful: Bool

    public var message: LocalizedText
}

/// Situe la journée dans le cycle, et n'en tire que ce qui est mesuré.
///
/// Pourquoi ce moteur ne prescrit rien
/// -----------------------------------
/// La tentation est grande, et beaucoup d'applications y cèdent : baisser
/// l'intensité en phase lutéale, la monter en phase folliculaire, selon un
/// tableau tiré de la littérature. Le problème est que cette littérature ne
/// le permet pas. Les effets mesurés sur la force et la performance sont
/// petits, contradictoires d'une étude à l'autre, et surtout **écrasés par
/// la variation entre personnes** : deux athlètes au même jour de cycle ne
/// se ressemblent pas.
///
/// Appliquer une règle de population à une personne, c'est se tromper la
/// plupart du temps avec l'assurance d'un chiffre. Une athlète qui se sent
/// très bien pendant ses règles et à qui l'application enlèverait dix pour
/// cent de charge conclurait, à raison, que l'application ne la connaît pas.
///
/// Ce que ce moteur fait à la place
/// --------------------------------
/// Il situe la journée, et il **apprend le motif propre à l'athlète** à
/// partir de ses propres bilans de forme. Au bout de deux cycles, il peut
/// dire : « tes bilans sont en moyenne plus bas ces jours-ci, chez toi ».
/// C'est une observation sur elle, pas une règle sur les femmes.
///
/// Et tant qu'il n'a pas assez de bilans, il se tait. Une moyenne sur trois
/// mesures n'est pas une moyenne, c'est une anecdote avec une décimale.
public enum CycleEngine {

    /// La durée par défaut, quand l'athlète n'a rien précisé.
    public static let defaultLength = 28

    /// La phase lutéale dure à peu près quatorze jours quelle que soit la
    /// longueur du cycle : c'est la phase folliculaire qui s'allonge ou se
    /// raccourcit. On situe donc l'ovulation en comptant depuis la fin, pas
    /// depuis le début — compter depuis le début placerait l'ovulation au
    /// mauvais jour pour tout cycle qui ne fait pas vingt-huit jours.
    static let lutealDays = 14

    /// Le jour du cycle, à partir du premier jour des dernières règles.
    /// Rend 1 le premier jour.
    public static func dayOfCycle(
        on date: Date, lastPeriodStart: Date, length: Int = defaultLength,
        calendar: Calendar = .current
    ) -> Int {
        let days = calendar.dateComponents(
            [.day], from: calendar.startOfDay(for: lastPeriodStart),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        guard days >= 0 else { return 1 }
        let span = max(21, min(45, length))
        return days % span + 1
    }

    /// La phase, pour un jour donné.
    public static func phase(dayOfCycle day: Int, length: Int = defaultLength) -> CyclePhase {
        let span = max(21, min(45, length))
        let ovulation = max(8, span - lutealDays)

        if day <= 5 { return .menstrual }
        if day >= ovulation - 1 && day <= ovulation + 1 { return .ovulatory }
        if day < ovulation { return .follicular }
        return .luteal
    }

    // MARK: - Ce que ses propres bilans disent

    /// Le nombre de bilans en dessous duquel on ne dit rien d'une phase.
    ///
    /// Six : deux cycles environ, à trois bilans par phase. En dessous, la
    /// moyenne bouge de dix points quand on ajoute une mesure, et annoncer
    /// une tendance serait annoncer du bruit.
    public static let minimumSamples = 6

    /// L'écart de score en dessous duquel une différence ne mérite pas d'être
    /// signalée. Sept points sur cent : moins, c'est l'humeur du jour.
    public static let meaningfulGap = 7

    /// Le motif de l'athlète pour la journée en cours.
    public static func pattern(
        on date: Date,
        lastPeriodStart: Date,
        length: Int = defaultLength,
        checks: [ReadinessCheck],
        profile: UserProfile,
        calendar: Calendar = .current
    ) -> CyclePattern {
        let day = dayOfCycle(on: date, lastPeriodStart: lastPeriodStart, length: length, calendar: calendar)
        let today = phase(dayOfCycle: day, length: length)

        // Chaque bilan passé est replacé dans sa phase. Les bilans antérieurs
        // aux dernières règles connues comptent aussi : le cycle se répète, et
        // c'est justement la répétition qui donne un motif.
        var byPhase: [CyclePhase: [Int]] = [:]
        var all: [Int] = []
        for check in checks {
            let checkDay = dayOfCycle(
                on: check.date, lastPeriodStart: lastPeriodStart, length: length, calendar: calendar
            )
            let score = ReadinessEngine.verdict(for: check, profile: profile).score
            byPhase[phase(dayOfCycle: checkDay, length: length), default: []].append(score)
            all.append(score)
        }

        let here = byPhase[today] ?? []
        let average = here.isEmpty ? nil : Int((Double(here.reduce(0, +)) / Double(here.count)).rounded())
        let overall = all.isEmpty ? nil : Int((Double(all.reduce(0, +)) / Double(all.count)).rounded())

        let enough = here.count >= minimumSamples
        let gap = (average ?? 0) - (overall ?? 0)
        let meaningful = enough && abs(gap) >= meaningfulGap

        return CyclePattern(
            phase: today,
            dayOfCycle: day,
            averageReadiness: average,
            overallReadiness: overall,
            samples: here.count,
            isMeaningful: meaningful,
            message: message(phase: today, day: day, gap: gap, samples: here.count, meaningful: meaningful)
        )
    }

    // MARK: - Ce qu'on lui dit

    static func message(
        phase: CyclePhase, day: Int, gap: Int, samples: Int, meaningful: Bool
    ) -> LocalizedText {
        guard meaningful else {
            // Le cas le plus fréquent, et de loin. On situe la journée, on
            // annonce ce qu'il manque pour en dire plus, et on s'arrête là.
            let missing = max(0, minimumSamples - samples)
            if missing > 0 {
                return LocalizedText(
                    fr: "Jour \(day). Encore \(missing) bilan\(missing > 1 ? "s" : "") dans cette phase et je pourrai te dire si elle change quelque chose pour toi — je ne te dirai rien tant que je ne l'aurai pas mesuré chez toi.",
                    en: "Day \(day). \(missing) more check-in\(missing > 1 ? "s" : "") in this phase and I can tell you whether it changes anything for you — I will say nothing until I have measured it on you.",
                    es: "Día \(day). \(missing) balance\(missing > 1 ? "s" : "") más en esta fase y podré decirte si cambia algo para ti; no diré nada hasta haberlo medido en ti."
                )
            }
            return LocalizedText(
                fr: "Jour \(day). Sur \(samples) bilans, cette phase ne change rien de net chez toi. C'est une information utile : ton entraînement n'a pas à en tenir compte.",
                en: "Day \(day). Across \(samples) check-ins, this phase changes nothing clear for you. That is useful to know: your training does not need to account for it.",
                es: "Día \(day). En \(samples) balances, esta fase no cambia nada claro en ti. Es útil saberlo: tu entrenamiento no tiene por qué tenerlo en cuenta."
            )
        }

        let lower = gap < 0
        return LocalizedText(
            fr: "Jour \(day). Sur \(samples) bilans, tes journées de cette phase sortent \(abs(gap)) points \(lower ? "en dessous" : "au-dessus") de ta moyenne. \(lower ? "Si la séance pique aujourd'hui, c'est une information, pas un échec : remplis ton bilan et elle s'ajustera." : "C'est souvent le bon moment pour tenter la série qui te résiste.")",
            en: "Day \(day). Across \(samples) check-ins, your days in this phase land \(abs(gap)) points \(lower ? "below" : "above") your average. \(lower ? "If today's session bites, that is information, not failure: fill in your check-in and it will adjust." : "This is often the right time to attempt the set that has been resisting you.")",
            es: "Día \(day). En \(samples) balances, tus días de esta fase quedan \(abs(gap)) puntos \(lower ? "por debajo" : "por encima") de tu media. \(lower ? "Si hoy la sesión cuesta, es información, no un fracaso: rellena tu balance y se ajustará." : "Suele ser el buen momento para intentar la serie que se te resiste.")"
        )
    }
}
