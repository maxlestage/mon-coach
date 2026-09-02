import Foundation

/// Le minutage des animations d'arrivée d'un écran.
///
/// Pourquoi ce calcul est ici et pas dans la vue
/// ---------------------------------------------
/// Une cascade est une addition : la carte numéro *n* attend *n* fois un
/// petit délai avant de se montrer. Écrite telle quelle dans une vue, cette
/// addition n'a aucune borne — et un écran à vingt cartes met alors plus
/// d'une seconde à finir de s'afficher, ce que l'on ne voit jamais en
/// développant parce qu'on regarde toujours des écrans courts.
///
/// C'est un bug d'arithmétique, pas de dessin : il se teste sans écran, et
/// il vaut mieux qu'un test le tienne que l'œil de celui qui relit.
///
/// La borne
/// --------
/// Passé `visibleCards` cartes, le délai ne bouge plus. Ce n'est pas une
/// approximation : au-delà, les cartes sont sous le pli, personne ne les
/// regarde arriver, et les faire attendre ne fait que retarder le moment où
/// l'écran est utilisable.
public enum MotionTiming: Sendable {

    /// L'écart entre deux cartes voisines, en secondes.
    ///
    /// Assez pour qu'on perçoive un ordre, assez peu pour qu'on ne
    /// l'attende pas. En dessous de 40 ms la cascade se lit comme un seul
    /// mouvement ; au-dessus de 80 ms elle se lit comme une lenteur.
    public static let step: Double = 0.055

    /// Le nombre de cartes qu'un écran de téléphone montre avant le pli.
    public static let visibleCards = 7

    /// Le délai avant que la carte à cette position se montre.
    ///
    /// - Parameter index: la position de la carte dans la pile, à partir de zéro.
    /// - Returns: un délai en secondes, jamais négatif, jamais au-delà du plafond.
    public static func delay(forCardAt index: Int) -> Double {
        Double(min(max(index, 0), visibleCards)) * step
    }

    /// Le temps total avant que la dernière carte d'une pile soit posée.
    ///
    /// Sert à ce qu'un test puisse dire « et cet écran, il met combien de
    /// temps à s'ouvrir ? » sans lancer l'application.
    public static func settlingTime(cards: Int) -> Double {
        guard cards > 0 else { return 0 }
        return delay(forCardAt: cards - 1)
    }

    /// Le plafond, quel que soit le nombre de cartes.
    ///
    /// Un écran ne doit jamais mettre plus de ça à finir d'arriver : au-delà,
    /// l'animation cesse d'être une mise en scène et devient une attente.
    public static let ceiling: Double = Double(visibleCards) * step
}
