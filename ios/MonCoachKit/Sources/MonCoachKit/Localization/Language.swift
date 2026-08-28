import Foundation

/// Les langues dans lesquelles Mon Coach parle.
///
/// Trois langues, pas une de plus tant qu'on ne peut pas les relire :
/// un texte de coaching mal traduit fait plus de dégâts qu'un texte absent,
/// parce qu'il donne des consignes techniques que l'athlète va suivre.
public enum Language: String, Codable, CaseIterable, Sendable, Identifiable, Hashable {
    case french = "fr"
    case english = "en"
    case spanish = "es"

    public var id: String { rawValue }

    /// Le nom de la langue, dans cette langue. Jamais un drapeau : un drapeau
    /// est un pays, pas une langue, et l'espagnol n'appartient pas à l'Espagne.
    public var endonym: String {
        switch self {
        case .french: "Français"
        case .english: "English"
        case .spanish: "Español"
        }
    }

    /// Le code BCP 47 utilisé par le système et par le site.
    public var code: String { rawValue }

    /// La langue par défaut quand rien n'est connu de l'utilisateur.
    public static let fallback: Language = .english

    /// Choisit la meilleure langue à partir des préférences du système.
    ///
    /// On accepte les étiquettes complètes (`fr-CA`, `es-419`) en ne
    /// regardant que la sous-étiquette primaire, et on renvoie la première
    /// langue reconnue plutôt que la première langue tout court : un
    /// utilisateur qui a `de` puis `es` doit obtenir l'espagnol.
    public static func best(matching preferred: [String]) -> Language {
        for tag in preferred {
            let primary = tag
                .lowercased()
                .split(whereSeparator: { $0 == "-" || $0 == "_" })
                .first
                .map(String.init) ?? ""
            if let match = Language(rawValue: primary) { return match }
        }
        return fallback
    }
}

/// Un texte destiné à l'utilisateur, écrit dans les trois langues.
///
/// Le choix d'une structure à trois champs plutôt que d'un dictionnaire est
/// délibéré : le compilateur refuse une traduction manquante, là où un
/// dictionnaire l'aurait laissée passer jusqu'à l'écran.
public struct LocalizedText: Codable, Sendable, Equatable, Hashable {
    public var fr: String
    public var en: String
    public var es: String

    public init(fr: String, en: String, es: String) {
        self.fr = fr
        self.en = en
        self.es = es
    }

    /// Un texte identique dans les trois langues : un nombre, un nom propre,
    /// un terme technique qui ne se traduit pas.
    public static func constant(_ value: String) -> LocalizedText {
        LocalizedText(fr: value, en: value, es: value)
    }

    public subscript(language: Language) -> String {
        switch language {
        case .french: fr
        case .english: en
        case .spanish: es
        }
    }

    /// `text(.spanish)` se lit mieux que `text[.spanish]` au milieu d'une vue.
    public func callAsFunction(_ language: Language) -> String { self[language] }

    /// Vrai quand aucune des trois versions n'est vide. Vérifié par les tests
    /// sur l'intégralité des catalogues.
    public var isComplete: Bool {
        !fr.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !en.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !es.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Concaténation, utile pour composer une phrase à partir de fragments.
    public static func + (lhs: LocalizedText, rhs: LocalizedText) -> LocalizedText {
        LocalizedText(fr: lhs.fr + rhs.fr, en: lhs.en + rhs.en, es: lhs.es + rhs.es)
    }
}

extension Array where Element == LocalizedText {
    /// Rend une liste de textes dans une langue donnée.
    public func rendered(in language: Language) -> [String] {
        map { $0[language] }
    }

    /// Assemble une liste en un seul texte, langue par langue.
    public func joined(separator: String) -> LocalizedText {
        LocalizedText(
            fr: map(\.fr).joined(separator: separator),
            en: map(\.en).joined(separator: separator),
            es: map(\.es).joined(separator: separator)
        )
    }

    /// Trie sur la version française, pour que l'ordre d'une énumération soit
    /// le même dans les trois langues : un athlète bilingue qui change de
    /// langue ne doit pas voir sa liste se réorganiser.
    public func sortedStably() -> [LocalizedText] {
        sorted { $0.fr < $1.fr }
    }
}
