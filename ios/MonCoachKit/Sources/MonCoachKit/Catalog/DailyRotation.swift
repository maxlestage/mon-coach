import Foundation

/// Une liste d'exercices qui change tous les jours, sans rien stocker.
///
/// Pourquoi ce type existe
/// -----------------------
/// Deux écrans posent la même question — « qu'est-ce que je fais
/// aujourd'hui ? » — et attendent la même garantie : une réponse stable
/// toute la journée, différente demain, et jamais deux jours de suite la
/// même chose. Écrire deux fois cette mécanique, c'est se condamner à ce
/// qu'une des deux dérive.
///
/// La sélection se déduit de la date. Trois conséquences voulues : elle ne
/// bouge pas dans la journée, elle change à minuit, et deux appareils du
/// même athlète montrent la même chose sans jamais se parler.
enum DailyRotation {

    /// Le numéro du jour, compté depuis une date fixe.
    ///
    /// Une origine absolue plutôt que « jours depuis la première ouverture » :
    /// la sélection ne doit pas dépendre du moment où l'application a été
    /// installée, sinon deux athlètes du même jour ne verraient pas la même
    /// chose et un test ne pourrait rien affirmer.
    static func dayIndex(of date: Date, calendar: Calendar = .current) -> Int {
        let origin = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        let day = calendar.startOfDay(for: date)
        return calendar.dateComponents([.day], from: origin, to: day).day ?? 0
    }

    /// Découpe un vivier en journées qui ne se ressemblent pas.
    ///
    /// Le vivier est mélangé une fois pour toutes — le même ordre partout et
    /// pour toujours — puis lu par une fenêtre glissante qui avance de
    /// `count` chaque jour et repart au début en fin de liste. Tant que le
    /// vivier fait au moins deux journées, deux jours consécutifs ne peuvent
    /// pas partager un exercice : leurs fenêtres ne se recouvrent jamais.
    ///
    /// Un tirage au hasard chaque jour n'aurait pas cette garantie — il
    /// redonnerait le même mouvement deux jours de suite bien plus souvent
    /// qu'on ne l'imagine.
    static func selection(
        from pool: [Exercise],
        dayIndex: Int,
        count: Int,
        seed: UInt64
    ) -> [Exercise] {
        let ordered = shuffled(pool, seed: seed)
        let perDay = Swift.min(count, ordered.count)
        guard perDay > 0 else { return [] }
        // Le modulo de Swift garde le signe : sans cette correction, une date
        // antérieure à 1970 donnerait un index négatif et planterait.
        let start = ((dayIndex * perDay) % ordered.count + ordered.count) % ordered.count
        return (0..<perDay).map { ordered[(start + $0) % ordered.count] }
    }

    /// Un mélange reproductible : la même graine donne toujours le même
    /// ordre, sur tout appareil et à toute date.
    ///
    /// Le générateur du système est délibérément imprévisible — c'est sa
    /// qualité, et c'est ce qui le rend inutilisable ici : la sélection doit
    /// pouvoir être recalculée à l'identique demain matin, et sur un autre
    /// téléphone, sans que rien ne soit stocké.
    static func shuffled(_ pool: [Exercise], seed: UInt64) -> [Exercise] {
        var state = seed == 0 ? 0x4D59_5DF4_D0F3_3173 : seed
        func next() -> UInt64 {
            // xorshift64* : quelques lignes, une période largement suffisante
            // pour mélanger quelques dizaines d'exercices.
            state ^= state >> 12
            state ^= state << 25
            state ^= state >> 27
            return state &* 0x2545_F491_4F6C_DD1D
        }
        var result = pool
        guard result.count > 1 else { return result }
        for index in stride(from: result.count - 1, to: 0, by: -1) {
            let pick = Int(next() % UInt64(index + 1))
            result.swapAt(index, pick)
        }
        return result
    }
}
