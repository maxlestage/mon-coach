import Foundation

/// Ce qu'on sert à la place d'un aliment qu'on n'aime pas.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le planificateur savait déjà écarter des aliments : `excludedFoods` est
/// lu à chaque construction de journée. Ce qu'il ne savait pas faire, c'est
/// répondre à la seule question que se pose quelqu'un qui refuse un
/// aliment — « et à la place, j'ai quoi ? ». Sans réponse, refuser fait
/// peur : on ne sait pas ce qu'on perd.
///
/// Le remplaçant se cherche dans le même rôle, parce que c'est le rôle qui
/// décide de la place dans l'assiette : une protéine remplace une protéine,
/// jamais un féculent. Le classement va au plus proche par les macros —
/// celui qui changera le moins la journée.
public enum FoodSubstitutions {

    /// Ce qui pourrait prendre la place de cet aliment, du plus proche au
    /// moins proche.
    ///
    /// Rendu vide quand l'aliment est inconnu : mieux vaut ne rien proposer
    /// qu'inventer un remplaçant à un aliment qui n'existe pas.
    public static func alternatives(
        to foodID: String,
        diet: DietPreference,
        excluding excluded: Set<String> = [],
        limit: Int = 3
    ) -> [Food] {
        guard let refused = FoodCatalog.food(id: foodID) else { return [] }
        return candidates(role: refused.role, diet: diet, excluding: excluded.union([foodID]))
            .sorted { left, right in
                let dl = distance(from: refused, to: left)
                let dr = distance(from: refused, to: right)
                if dl != dr { return dl < dr }
                // À distance égale, le meilleur rang d'abord : remplacer un
                // aliment par un moins bon serait une régression déguisée.
                if left.tier != right.tier { return left.tier < right.tier }
                return left.id < right.id
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Peut-on refuser cet aliment sans vider son rôle ?
    ///
    /// Un régime végétarien qui refuse ses dernières protéines ne donne pas
    /// une journée dégradée : il donne une journée impossible à construire,
    /// et l'écran resterait vide sans dire pourquoi. Deux aliments restants
    /// est le minimum — un seul, et toute la semaine servirait le même.
    public static func canRefuse(
        _ foodID: String,
        diet: DietPreference,
        alreadyExcluded excluded: Set<String>
    ) -> Bool {
        guard let food = FoodCatalog.food(id: foodID) else { return false }
        let remaining = candidates(
            role: food.role,
            diet: diet,
            excluding: excluded.union([foodID])
        )
        return remaining.count >= 2
    }

    // MARK: - Le détail

    static func candidates(
        role: FoodRole,
        diet: DietPreference,
        excluding excluded: Set<String>
    ) -> [Food] {
        FoodCatalog.all.filter {
            $0.role == role && $0.suits(diet) && !excluded.contains($0.id)
        }
    }

    /// L'écart entre deux aliments, pour 100 g.
    ///
    /// Chaque macro est ramenée à une échelle où un écart de 1 compte
    /// pareil : dix grammes de protéines pèsent autant que vingt grammes de
    /// glucides ou cent calories. Sans cette mise à l'échelle, les calories
    /// écraseraient tout et le riz remplacerait le brocoli.
    static func distance(from refused: Food, to candidate: Food) -> Double {
        abs(refused.proteinG - candidate.proteinG) / 10
            + abs(refused.carbsG - candidate.carbsG) / 20
            + abs(refused.fatG - candidate.fatG) / 10
            + abs(refused.kcal - candidate.kcal) / 100
    }
}
