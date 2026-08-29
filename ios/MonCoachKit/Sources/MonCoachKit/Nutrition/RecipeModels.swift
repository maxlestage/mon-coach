import Foundation

/// Un plat : le nom, les aliments qui le composent, et comment le faire.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le planificateur savait déjà construire une assiette juste — une protéine,
/// un féculent, deux légumes, une matière grasse, aux grammes près. Ce qu'il
/// ne savait pas faire, c'est dire quoi cuisiner. « 150 g de blanc de poulet,
/// 90 g de riz, 150 g de brocolis » est une prescription exacte et une idée de
/// repas nulle : personne ne cuisine des grammes.
///
/// Une recette ne remplace pas ce calcul, elle le nomme. Elle choisit *quels*
/// aliments occupent les quatre places du squelette, et le solveur garde le
/// dernier mot sur les quantités. Toutes les garanties de la journée tiennent
/// donc telles quelles : les macros dans leur budget d'écart, les deux
/// légumes du repas principal, le minimum de protéines, le régime respecté,
/// les aliments refusés écartés.
///
/// C'est aussi pourquoi une recette ne porte pas ses propres quantités. Deux
/// personnes qui font le même plat n'en mangent pas la même assiette, et une
/// recette figée à 400 g obligerait soit à mentir sur les macros, soit à
/// renoncer au plat. Ici le plat est fixe et l'assiette s'ajuste.
public struct Recipe: Codable, Sendable, Equatable, Identifiable, Hashable {
    public var id: String
    public var name: LocalizedText
    /// Les moments où ce plat a sa place. Un dahl ne se mange pas au réveil.
    public var slots: Set<MealSlot>

    /// Les trois places que le solveur ajuste librement.
    public var proteinID: String
    public var carbID: String
    public var fatID: String

    /// Les aliments servis en quantité fixe : les deux légumes d'un vrai
    /// repas, le fruit du matin. Le solveur ne les étire pas — c'est ce qui
    /// donne son volume à l'assiette, et le volume ne se négocie pas.
    public var extraIDs: [String]

    /// Temps de préparation en minutes, cuisson comprise. Un chiffre honnête
    /// vaut mieux qu'un chiffre flatteur : c'est lui qui décide si le plat se
    /// fait un mardi soir.
    public var minutes: Int

    /// Comment faire, en quelques lignes. Pas une fiche de cuisine : de quoi
    /// s'y mettre sans chercher ailleurs.
    public var steps: [LocalizedText]

    public init(
        id: String,
        name: LocalizedText,
        slots: Set<MealSlot>,
        proteinID: String,
        carbID: String,
        fatID: String,
        extraIDs: [String],
        minutes: Int,
        steps: [LocalizedText]
    ) {
        self.id = id
        self.name = name
        self.slots = slots
        self.proteinID = proteinID
        self.carbID = carbID
        self.fatID = fatID
        self.extraIDs = extraIDs
        self.minutes = minutes
        self.steps = steps
    }

    /// Tous les aliments cités, dans l'ordre où ils comptent.
    public var foodIDs: [String] { [proteinID, carbID] + extraIDs + [fatID] }

    /// Les aliments résolus, ou nil si l'un d'eux n'existe pas au catalogue.
    ///
    /// Le nil est délibéré plutôt qu'un silence : une recette qui cite un
    /// identifiant disparu doit être écartée entièrement, pas servie amputée
    /// de sa protéine.
    public var foods: [Food]? {
        let resolved = foodIDs.compactMap { FoodCatalog.food(id: $0) }
        return resolved.count == foodIDs.count ? resolved : nil
    }

    /// Le plat convient-il à ce régime ?
    ///
    /// Dérivé des aliments plutôt que déclaré sur la recette : un champ à
    /// tenir à jour à la main finit par mentir, et il mentirait ici sur un
    /// régime — c'est-à-dire sur ce que quelqu'un s'interdit de manger.
    public func suits(_ diet: DietPreference) -> Bool {
        guard let foods else { return false }
        return foods.allSatisfy { $0.suits(diet) }
    }

    /// Le rang le plus permissif parmi les aliments du plat.
    ///
    /// Un plat vaut son pire ingrédient : un poisson irréprochable servi dans
    /// la crème n'est pas un plat de base.
    public var tier: FoodTier {
        foods?.map(\.tier).max() ?? .occasional
    }

    public func excludes(_ excluded: Set<String>) -> Bool {
        !excluded.isDisjoint(with: foodIDs)
    }
}
