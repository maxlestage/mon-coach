import Foundation

/// Une étape d'une fiche technique.
public struct TechniqueStep: Sendable, Equatable, Identifiable, Hashable {
    public var id: Int { index }
    public var index: Int
    public var title: LocalizedText
    public var detail: LocalizedText
    /// Ce que l'athlète doit pouvoir vérifier sur lui-même à cette étape,
    /// sans miroir et sans personne pour le regarder.
    public var checkpoint: LocalizedText?

    public init(index: Int, title: LocalizedText, detail: LocalizedText, checkpoint: LocalizedText? = nil) {
        self.index = index
        self.title = title
        self.detail = detail
        self.checkpoint = checkpoint
    }
}

/// Une erreur fréquente, décrite par ce que l'athlète ressent plutôt que par
/// ce qu'un observateur verrait : personne ne se filme, mais tout le monde
/// sait où ça tire.
public struct CommonMistake: Sendable, Equatable, Identifiable, Hashable {
    public var id: String { symptom.fr }
    public var symptom: LocalizedText
    public var cause: LocalizedText
    public var fix: LocalizedText

    public init(symptom: LocalizedText, cause: LocalizedText, fix: LocalizedText) {
        self.symptom = symptom
        self.cause = cause
        self.fix = fix
    }
}

/// La fiche guidée d'un mouvement.
public struct GuidedTechnique: Sendable, Equatable, Identifiable {
    /// Identifiant de l'exercice, ou du schéma moteur quand la fiche vaut
    /// pour toute une famille.
    public var id: String
    public var title: LocalizedText
    public var setup: [TechniqueStep]
    public var execution: [TechniqueStep]
    public var breathing: LocalizedText
    public var tempo: LocalizedText
    public var mistakes: [CommonMistake]
    /// La version plus facile, pour la séance où le mouvement ne vient pas.
    public var easier: LocalizedText?
    /// Ce qu'on ajoute quand le mouvement est acquis.
    public var harder: LocalizedText?
    /// La seule chose à retenir si on ne retient qu'une chose.
    public var oneThing: LocalizedText

    public var steps: [TechniqueStep] { setup + execution }
}

/// L'étape d'un parcours de premières séances.
public struct FirstSessionsStep: Sendable, Equatable, Identifiable {
    public var id: Int { week }
    /// Semaine du parcours, à partir de 1.
    public var week: Int
    public var title: LocalizedText
    public var goal: LocalizedText
    public var instruction: LocalizedText
    /// Ce qui doit être vrai avant de passer à la suite.
    public var readyWhen: LocalizedText
}
