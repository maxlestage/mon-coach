import Foundation

/// Ce qui demande un abonnement, et ce qui n'en demandera jamais.
///
/// Pourquoi cette liste est écrite ici
/// -----------------------------------
/// Une frontière payante éparpillée dans les écrans devient incohérente en
/// trois semaines : un bouton oublié ici, une carte gratuite là, et
/// personne ne sait plus ce qui est offert. Elle est donc déclarée une
/// fois, dans le moteur, où elle se teste — et où l'on peut vérifier d'un
/// coup d'œil ce qu'un athlète garde le jour où il ne paie plus.
public enum PlusFeature: String, CaseIterable, Sendable, Identifiable {
    /// Reconstruire un bloc à partir des séances réellement faites.
    case nextBlocks
    /// Le bilan hebdomadaire : volume, calories, décharge anticipée.
    case weeklyReview
    /// Le plan de course complet.
    case runningPlan
    /// La liste de courses de la semaine.
    case shoppingList
    /// L'application Apple Watch.
    case watchApp
    /// Les Live Activity de séance et de sortie.
    case liveActivities
    /// Les courbes de progression : poids, 1RM estimé, allure, statistiques.
    case progressCurves

    public var id: String { rawValue }

    public var label: LocalizedText {
        switch self {
        case .nextBlocks:
            LocalizedText(
                fr: "Les blocs suivants",
                en: "The blocks that follow",
                es: "Los bloques siguientes"
            )
        case .weeklyReview:
            LocalizedText(fr: "Le bilan hebdomadaire", en: "The weekly review", es: "El balance semanal")
        case .runningPlan:
            LocalizedText(fr: "Le plan de course", en: "The running plan", es: "El plan de carrera")
        case .shoppingList:
            LocalizedText(fr: "La liste de courses", en: "The shopping list", es: "La lista de la compra")
        case .watchApp:
            LocalizedText(fr: "L'application Apple Watch", en: "The Apple Watch app", es: "La aplicación Apple Watch")
        case .liveActivities:
            LocalizedText(fr: "Les Live Activity", en: "Live Activities", es: "Las Live Activity")
        case .progressCurves:
            LocalizedText(fr: "Les courbes de progression", en: "The progress curves", es: "Las curvas de progreso")
        }
    }

    /// Ce qu'on perd concrètement, dit sans détour.
    public var detail: LocalizedText {
        switch self {
        case .nextBlocks:
            LocalizedText(
                fr: "Ton bloc en cours va jusqu'au bout, toujours. C'est le suivant — reconstruit d'après ce que tu as réellement fait — qui demande Stride+.",
                en: "Your current block always runs to its end. It is the next one — rebuilt from what you actually did — that needs Stride+.",
                es: "Tu bloque actual siempre llega hasta el final. Es el siguiente —reconstruido según lo que realmente hiciste— el que necesita Stride+."
            )
        case .weeklyReview:
            LocalizedText(
                fr: "Ce que la semaine a donné face à ce qui était prévu, et ce que le coach en déduit.",
                en: "What the week produced against what was planned, and what the coach concludes from it.",
                es: "Lo que dio la semana frente a lo previsto, y lo que el entrenador deduce."
            )
        case .runningPlan:
            LocalizedText(
                fr: "Enregistrer tes sorties reste gratuit, pour toujours. C'est le plan qui les prescrit qui demande Stride+.",
                en: "Recording your runs stays free, forever. It is the plan that prescribes them that needs Stride+.",
                es: "Registrar tus salidas sigue siendo gratis, para siempre. Es el plan que las prescribe el que necesita Stride+."
            )
        case .shoppingList:
            LocalizedText(
                fr: "Tes repas du jour et tes cibles restent gratuits. C'est la liste agrégée de la semaine qui demande Stride+.",
                en: "Your daily meals and targets stay free. It is the aggregated weekly list that needs Stride+.",
                es: "Tus comidas del día y tus objetivos siguen siendo gratis. Es la lista semanal agregada la que necesita Stride+."
            )
        case .watchApp:
            LocalizedText(
                fr: "La séance et les sorties menées depuis le poignet, sans téléphone.",
                en: "Sessions and activities run from the wrist, without the phone.",
                es: "Las sesiones y salidas desde la muñeca, sin teléfono."
            )
        case .liveActivities:
            LocalizedText(
                fr: "La série en cours et le chrono sur l'écran verrouillé et dans la Dynamic Island.",
                en: "The current set and the timer on the lock screen and in the Dynamic Island.",
                es: "La serie en curso y el crono en la pantalla bloqueada y en la Dynamic Island."
            )
        case .progressCurves:
            LocalizedText(
                fr: "Poids, 1RM estimé, allure de seuil, volume par semaine, zones cardiaques.",
                en: "Weight, estimated 1RM, threshold pace, weekly volume, heart-rate zones.",
                es: "Peso, 1RM estimado, ritmo de umbral, volumen semanal, zonas cardíacas."
            )
        }
    }
}

/// Ce qui reste gratuit, quoi qu'il arrive.
///
/// Écrit comme une liste plutôt que déduit par l'absence : quelqu'un qui
/// ajoute un écran demain doit trouver ici la règle, et pas avoir à la
/// reconstituer en lisant tous les `if`.
public enum AlwaysFree {
    public static let promises: [LocalizedText] = [
        LocalizedText(
            fr: "Ton historique entier : séances, sorties, pesées, photos.",
            en: "Your whole history: sessions, activities, weigh-ins, photos.",
            es: "Todo tu historial: sesiones, salidas, pesajes, fotos."
        ),
        LocalizedText(
            fr: "L'export JSON intégral et l'effacement, à vie.",
            en: "Full JSON export and erasure, for life.",
            es: "La exportación JSON completa y el borrado, de por vida."
        ),
        LocalizedText(
            fr: "Le bloc que tu as commencé, jusqu'à sa dernière séance.",
            en: "The block you started, down to its last session.",
            es: "El bloque que empezaste, hasta su última sesión."
        ),
        LocalizedText(
            fr: "Le mode guidé sur les quatre-vingt-douze mouvements.",
            en: "Guided mode on all ninety-two movements.",
            es: "El modo guiado en los noventa y dos movimientos."
        ),
        LocalizedText(
            fr: "Le check-in du jour et la séance ajustée à ta forme.",
            en: "The daily check-in and the session adjusted to your readiness.",
            es: "El check-in diario y la sesión ajustada a tu forma."
        ),
        LocalizedText(
            fr: "Tes cibles caloriques, tes macros et tes repas du jour.",
            en: "Your calorie targets, your macros and your meals for the day.",
            es: "Tus objetivos calóricos, tus macros y tus comidas del día."
        ),
        LocalizedText(
            fr: "L'enregistrement de tout ce que tu fais, sans limite.",
            en: "Logging everything you do, without limit.",
            es: "El registro de todo lo que haces, sin límite."
        ),
    ]

    /// La phrase qui tient tout ensemble.
    public static let hostageClause = LocalizedText(
        fr: "Tes données ne sont jamais un otage : l'historique et l'export restent gratuits, y compris le jour où tu arrêtes de payer.",
        en: "Your data is never a hostage: history and export stay free, including the day you stop paying.",
        es: "Tus datos nunca son un rehén: el historial y la exportación siguen siendo gratis, incluso el día que dejes de pagar."
    )
}

/// Où en est l'athlète : à l'essai, abonné, ou sur la formule gratuite.
public struct SubscriptionStatus: Sendable, Equatable {
    /// Le jour de la première ouverture, qui fait courir l'essai.
    public var trialStartedAt: Date?
    /// Vrai quand un abonnement actif a été constaté par l'App Store.
    public var isSubscribed: Bool

    public init(trialStartedAt: Date? = nil, isSubscribed: Bool = false) {
        self.trialStartedAt = trialStartedAt
        self.isSubscribed = isSubscribed
    }

    /// La durée de l'essai. Quatorze jours : deux semaines pleines, donc
    /// deux fois toutes les séances de la semaine, et un week-end de plus
    /// pour ceux qui ne s'entraînent que le samedi.
    public static let trialDays = 14

    /// Les jours d'essai restants, zéro une fois qu'il est fini.
    public func trialDaysLeft(on date: Date = Date(), calendar: Calendar = .current) -> Int {
        guard let trialStartedAt else { return Self.trialDays }
        let elapsed = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: trialStartedAt),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        // Une horloge reculée ne rallonge pas l'essai au-delà de sa durée,
        // et ne le raccourcit pas non plus : on borne des deux côtés.
        return max(0, Self.trialDays - max(0, elapsed))
    }

    public func isInTrial(on date: Date = Date(), calendar: Calendar = .current) -> Bool {
        !isSubscribed && trialDaysLeft(on: date, calendar: calendar) > 0
    }

    /// Cette fonctionnalité est-elle ouverte aujourd'hui ?
    ///
    /// Pendant l'essai, tout l'est. C'est le sens du mot « essai » : juger
    /// sur le produit entier, pas sur une démonstration amputée.
    public func isUnlocked(
        _ feature: PlusFeature,
        on date: Date = Date(),
        calendar: Calendar = .current
    ) -> Bool {
        isSubscribed || isInTrial(on: date, calendar: calendar)
    }

    /// Ce qu'on affiche en haut de l'écran, quand il y a quelque chose à dire.
    public func banner(on date: Date = Date(), calendar: Calendar = .current) -> LocalizedText? {
        guard !isSubscribed else { return nil }
        let left = trialDaysLeft(on: date, calendar: calendar)
        guard left > 0 else { return nil }
        if left == 1 {
            return LocalizedText(
                fr: "Dernier jour de ton essai. Ensuite, tu gardes ton historique, ton bloc en cours et tes repas — le reste demande Stride+.",
                en: "Last day of your trial. After that you keep your history, your current block and your meals — the rest needs Stride+.",
                es: "Último día de prueba. Después conservas tu historial, tu bloque actual y tus comidas; el resto necesita Stride+."
            )
        }
        return LocalizedText(
            fr: "Essai en cours : \(left) jours, tout est ouvert.",
            en: "Trial running: \(left) days, everything is unlocked.",
            es: "Prueba en curso: \(left) días, todo está abierto."
        )
    }
}
