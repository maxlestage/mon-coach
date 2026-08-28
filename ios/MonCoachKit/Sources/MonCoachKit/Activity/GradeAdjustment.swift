import Foundation

/// L'allure corrigée du dénivelé : ce que la sortie aurait valu sur du plat.
///
/// Sans elle, toute sortie vallonnée paraît lente et tout parcours descendant
/// paraît rapide — et l'athlète apprend à éviter les côtes pour ne pas
/// « abîmer » ses moyennes, ce qui est l'inverse d'un entraînement. La
/// correction rapporte chaque segment à son coût énergétique sur le plat.
public enum GradeAdjustment {

    /// Coût énergétique relatif d'une pente, 1 sur le plat.
    ///
    /// Polynôme ajusté sur les mesures de Minetti et al. (2002), le jeu de
    /// données de référence du coût métabolique de la course en pente,
    /// mesuré de −45 % à +45 %. Deux propriétés comptent : le minimum n'est
    /// pas à 0 % mais vers −10 % — une descente douce aide, une descente
    /// raide se paie en freinage — et la montée coûte vite très cher, un
    /// +10 % doublant presque le coût du kilomètre.
    public static func energyCostFactor(gradePercent: Double) -> Double {
        // Le domaine de validité des mesures. Au-delà, le polynôme diverge
        // sans données pour le soutenir : on borne, on n'extrapole pas.
        let grade = (gradePercent / 100).clamped(to: -0.45...0.45)
        // Minetti 2002, coût en J/kg/m rapporté au coût sur plat (~3,6).
        let cost = 155.4 * pow(grade, 5) - 30.4 * pow(grade, 4) - 43.3 * pow(grade, 3)
            + 46.3 * pow(grade, 2) + 19.5 * grade + 3.6
        return max(0.5, cost / 3.6)
    }

    /// L'allure équivalente sur plat d'un segment couru en pente.
    ///
    /// Diviser plutôt que multiplier : un kilomètre à 6:00 dans une côte qui
    /// coûte 1,5 fois le plat vaut un kilomètre à 4:00 sur du plat.
    public static func flatEquivalentPace(
        paceSecondsPerKm pace: Double,
        gradePercent: Double
    ) -> Double {
        guard pace > 0 else { return 0 }
        return pace / energyCostFactor(gradePercent: gradePercent)
    }

    /// L'allure corrigée d'une trace entière, segment par segment.
    ///
    /// La correction se fait par tronçon et non sur la pente moyenne : une
    /// boucle qui monte puis descend a une pente moyenne nulle mais un coût
    /// bien réel — le polynôme n'est pas symétrique, c'est tout son sujet.
    public static func flatEquivalentPace(of trace: CleanTrace) -> Double? {
        guard trace.meters > 100, trace.movingDuration > 0 else { return nil }
        let samples = trace.samples
        var equivalentSeconds = 0.0
        var meters = 0.0
        for index in 1..<samples.count {
            let previous = samples[index - 1]
            let sample = samples[index]
            let distance = sample.cumulativeMeters - previous.cumulativeMeters
            let seconds = sample.cumulativeMovingSeconds - previous.cumulativeMovingSeconds
            guard distance > 0, seconds > 0 else { continue }
            let grade = (sample.smoothedAltitude - previous.smoothedAltitude) / distance * 100
            equivalentSeconds += seconds / energyCostFactor(gradePercent: grade)
            meters += distance
        }
        guard meters > 0 else { return nil }
        return equivalentSeconds / (meters / 1_000)
    }
}
