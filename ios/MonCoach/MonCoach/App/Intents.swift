import AppIntents
import SwiftUI
import MonCoachKit

/// Ce qu'une intention a demandé, en attendant que l'écran s'ouvre.
///
/// Pourquoi ce détour
/// ------------------
/// Une intention qui démarre une sortie ne peut pas suivre le GPS elle-même :
/// elle s'exécute le temps d'un geste, et l'enregistrement dure une heure.
/// Elle ouvre donc l'application et lui laisse une consigne, que la racine lit
/// dès qu'elle apparaît. C'est le seul chemin fiable, et il a l'avantage de
/// n'avoir qu'un seul code d'enregistrement — celui qui marche déjà.
@MainActor
@Observable
final class IntentRouter {
    static let shared = IntentRouter()

    /// Le sport à lancer dès l'ouverture, s'il y en a un.
    var requestedSport: Sport?

    /// Le magasin de l'application, quand elle tourne.
    ///
    /// Sans lui, une intention qui note un poids ouvrirait son propre
    /// `CoachStore`, écrirait sur le disque, et l'application — restée en
    /// mémoire avec son état d'avant — réécrirait le fichier au geste
    /// suivant. La pesée disparaîtrait sans que personne ne voie d'erreur.
    /// La racine se présente ici à son apparition ; la référence est faible
    /// pour que la fermeture de l'application ne laisse rien derrière.
    @ObservationIgnored
    weak var live: CoachStore?

    /// Le magasin sur lequel écrire : celui de l'application si elle tourne,
    /// sinon un magasin neuf lu sur le disque — le cas d'une intention
    /// exécutée alors que l'application est fermée.
    var store: CoachStore { live ?? CoachStore() }

    private init() {}
}

/// La langue à utiliser dans les intentions.
///
/// Le réglage du coach vit dans l'état de l'application, que le système ne
/// consulte pas quand il affiche la liste des raccourcis. On se rabat donc
/// sur la langue du téléphone : c'est celle dans laquelle il pose la question.
private var intentLanguage: Language {
    Language.best(matching: Locale.preferredLanguages)
}

// MARK: - Le sport, tel que Siri le propose

extension Sport: @retroactive AppEnum {
    public static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(
            name: LocalizedStringResource("Sport")
        )
    }

    /// Construite depuis le catalogue plutôt qu'écrite à la main : un sport
    /// ajouté apparaît chez Siri sans qu'on ait à y penser, et surtout sans
    /// qu'on puisse l'oublier.
    public static var caseDisplayRepresentations: [Sport: DisplayRepresentation] {
        var table: [Sport: DisplayRepresentation] = [:]
        for sport in Sport.allCases {
            table[sport] = DisplayRepresentation(
                title: LocalizedStringResource(stringLiteral: sport.label[intentLanguage])
            )
        }
        return table
    }
}

// MARK: - Démarrer une sortie

/// « Dis à Stride de démarrer une sortie vélo. »
struct StartActivityIntent: AppIntent {
    static var title: LocalizedStringResource { "Démarrer une sortie" }
    static var description: IntentDescription {
        IntentDescription("Ouvre Stride et lance l'enregistrement du sport choisi.")
    }

    /// L'application s'ouvre : c'est elle qui tient le GPS pendant une heure,
    /// pas l'intention, qui ne vit que le temps d'un geste.
    static var openAppWhenRun: Bool { true }

    @Parameter(title: "Sport")
    var sport: Sport

    @MainActor
    func perform() async throws -> some IntentResult {
        IntentRouter.shared.requestedSport = sport
        return .result()
    }
}

// MARK: - Noter son poids

/// « Note quatre-vingt-deux kilos dans Stride. »
///
/// Celle-ci n'ouvre rien : noter un poids est un geste d'une seconde, et
/// ouvrir l'application pour cela coûterait plus cher que de le taper.
struct LogWeightIntent: AppIntent {
    static var title: LocalizedStringResource { "Noter mon poids" }
    static var description: IntentDescription {
        IntentDescription("Enregistre une pesée sans ouvrir l'application.")
    }

    @Parameter(title: "Poids en kilos", inclusiveRange: (30, 300))
    var kilograms: Double

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = IntentRouter.shared.store
        store.recordBodyLog(BodyLog(date: Date(), weightKg: kilograms))
        let text = LocalizedText(
            fr: "\(Format.number(kilograms, decimals: 1, language: .french)) kg, c'est noté.",
            en: "\(Format.number(kilograms, decimals: 1, language: .english)) kg, logged.",
            es: "\(Format.number(kilograms, decimals: 1, language: .spanish)) kg, anotado."
        )
        return .result(dialog: IntentDialog(stringLiteral: text[intentLanguage]))
    }
}

// MARK: - Ce que le coach dit aujourd'hui

/// « Qu'est-ce que j'ai aujourd'hui ? »
///
/// Répond sans ouvrir l'application : c'est une question qu'on pose en
/// enfilant ses chaussures, et la réponse tient en une phrase.
struct TodaySummaryIntent: AppIntent {
    static var title: LocalizedStringResource { "Ma séance du jour" }
    static var description: IntentDescription {
        IntentDescription("Dit ce que le coach a prévu aujourd'hui.")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let store = IntentRouter.shared.store
        let language = store.language

        guard let briefing = store.briefing() else {
            return .result(dialog: IntentDialog(stringLiteral: LocalizedText(
                fr: "Le coach n'a pas encore de plan pour toi.",
                en: "The coach has no plan for you yet.",
                es: "El entrenador aún no tiene un plan para ti."
            )[language]))
        }

        // La reprise passe devant le reste : quelqu'un qui revient de trois
        // semaines d'arrêt doit l'entendre avant d'entendre sa séance.
        if let comeback = store.returnPlan() {
            return .result(dialog: IntentDialog(stringLiteral:
                "\(comeback.headline[language]). \(comeback.message[language])"
            ))
        }

        // Construite ici plutôt que lue quelque part : le briefing porte un
        // état et des prescriptions, pas une phrase. Siri en veut une.
        let sentence: LocalizedText
        switch briefing.state {
        case .training(let session):
            let sets = session.totalSets
            sentence = LocalizedText(
                fr: "\(session.title[.french]) : \(session.exercises.count) exercices, \(sets) séries.",
                en: "\(session.title[.english]): \(session.exercises.count) exercises, \(sets) sets.",
                es: "\(session.title[.spanish]): \(session.exercises.count) ejercicios, \(sets) series."
            )
        case .rest:
            sentence = LocalizedText(
                fr: "Repos aujourd'hui. C'est là que le travail des autres jours se transforme.",
                en: "Rest today. That is when the other days' work turns into something.",
                es: "Hoy descanso. Es cuando el trabajo de los otros días se convierte en algo."
            )
        case .blockFinished:
            sentence = LocalizedText(
                fr: "Ton bloc est terminé. Ouvre l'application pour lancer le suivant.",
                en: "Your block is done. Open the app to start the next one.",
                es: "Tu bloque ha terminado. Abre la aplicación para empezar el siguiente."
            )
        }

        // La sortie prévue s'ajoute quand il y en a une : un jour peut porter
        // une séance et une sortie, ce sont deux demandes, pas deux états.
        if let run = briefing.plannedRun,
           briefing.recordedRun == nil,
           let demand = run.summary(unit: store.profile?.unit ?? .metric, language: language) {
            return .result(dialog: IntentDialog(stringLiteral: LocalizedText(
                fr: "\(sentence.fr) Et \(demand) de course.",
                en: "\(sentence.en) Plus a \(demand) run.",
                es: "\(sentence.es) Y \(demand) de carrera."
            )[language]))
        }
        return .result(dialog: IntentDialog(stringLiteral: sentence[language]))
    }
}

// MARK: - Ce que Siri connaît sans qu'on lui apprenne

/// Les phrases toutes prêtes, dans les trois langues.
///
/// Sans elles, les intentions n'existent que dans l'application Raccourcis,
/// où personne ne va les chercher. Avec elles, Siri répond, le bouton Action
/// s'y branche, et les raccourcis se proposent tout seuls.
struct StrideShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: TodaySummaryIntent(),
            phrases: [
                "Ma séance du jour dans \(.applicationName)",
                "Qu'est-ce que j'ai aujourd'hui dans \(.applicationName)",
                "My session today in \(.applicationName)",
                "Mi sesión de hoy en \(.applicationName)",
            ],
            shortTitle: "Séance du jour",
            systemImageName: "bolt.fill"
        )
        AppShortcut(
            intent: StartActivityIntent(),
            phrases: [
                "Démarrer une sortie dans \(.applicationName)",
                "Start an activity in \(.applicationName)",
                "Empezar una salida en \(.applicationName)",
            ],
            shortTitle: "Démarrer une sortie",
            systemImageName: "figure.run"
        )
        AppShortcut(
            intent: LogWeightIntent(),
            phrases: [
                "Noter mon poids dans \(.applicationName)",
                "Log my weight in \(.applicationName)",
                "Anotar mi peso en \(.applicationName)",
            ],
            shortTitle: "Noter mon poids",
            systemImageName: "scalemass"
        )
    }
}
