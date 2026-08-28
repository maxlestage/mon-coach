import Foundation

/// Une mesure de fréquence cardiaque, telle que la montre la donne.
public struct HeartRateSample: Codable, Sendable, Equatable, Hashable {
    public var timestamp: Date
    /// Battements par minute.
    public var bpm: Double

    public init(timestamp: Date, bpm: Double) {
        self.timestamp = timestamp
        self.bpm = bpm
    }
}

/// Une zone de fréquence cardiaque, 1 (très facile) à 5 (maximal).
public struct HeartRateZone: Sendable, Equatable, Identifiable {
    public var id: Int { index }
    public var index: Int
    /// Bornes en battements par minute, la borne haute exclue.
    public var range: Range<Double>
    public var label: LocalizedText
    public var purpose: LocalizedText
}

/// Le travail cardiaque d'une sortie : zones, temps par zone, charge.
public enum HeartRateAnalysis {

    /// Fréquence cardiaque maximale estimée, à défaut d'un test réel.
    ///
    /// Tanaka (208 − 0,7 × âge) plutôt que le folklorique « 220 − âge »,
    /// dont l'origine est une moyenne de moyennes jamais validée. L'écart
    /// type reste d'environ 10 bpm : c'est une estimation, l'application le
    /// dit, et une valeur mesurée la remplace dès qu'elle existe.
    public static func estimatedMaximum(age: Int) -> Double {
        208 - 0.7 * Double(age.clamped(to: 10...100))
    }

    /// Les cinq zones, en pourcentage de la fréquence maximale.
    ///
    /// Le découpage classique 50-60-70-80-90-100. Des zones par fréquence de
    /// réserve (Karvonen) seraient un peu plus justes mais exigent la
    /// fréquence de repos, que l'athlète ne connaît en général pas ; des
    /// zones fausses par surestimation valent moins que des zones simples
    /// que l'athlète comprend.
    public static func zones(maximumBpm: Double) -> [HeartRateZone] {
        let bounds = [0.5, 0.6, 0.7, 0.8, 0.9, 10.0]
        let labels: [(LocalizedText, LocalizedText)] = [
            (
                LocalizedText(fr: "Très facile", en: "Very easy", es: "Muy fácil"),
                LocalizedText(
                    fr: "Échauffement, récupération active. On peut chanter.",
                    en: "Warm-up, active recovery. You could sing.",
                    es: "Calentamiento, recuperación activa. Podrías cantar."
                )
            ),
            (
                LocalizedText(fr: "Endurance", en: "Endurance", es: "Resistencia"),
                LocalizedText(
                    fr: "La zone où se construit le moteur aérobie. On tient une conversation.",
                    en: "Where the aerobic engine is built. You can hold a conversation.",
                    es: "Donde se construye el motor aeróbico. Mantienes una conversación."
                )
            ),
            (
                LocalizedText(fr: "Tempo", en: "Tempo", es: "Tempo"),
                LocalizedText(
                    fr: "Soutenu mais tenable. Des phrases courtes, pas des paragraphes.",
                    en: "Hard but sustainable. Short sentences, not paragraphs.",
                    es: "Exigente pero sostenible. Frases cortas, no párrafos."
                )
            ),
            (
                LocalizedText(fr: "Seuil", en: "Threshold", es: "Umbral"),
                LocalizedText(
                    fr: "À la frontière : au-delà, l'effort ne s'équilibre plus.",
                    en: "At the edge: past this, the effort stops balancing out.",
                    es: "En la frontera: más allá, el esfuerzo deja de equilibrarse."
                )
            ),
            (
                LocalizedText(fr: "Maximal", en: "Maximal", es: "Máximo"),
                LocalizedText(
                    fr: "Réservé au fractionné court. Quelques mots, au mieux.",
                    en: "For short intervals only. A few words, at best.",
                    es: "Solo para series cortas. Unas palabras, como mucho."
                )
            ),
        ]
        return (0..<5).map { index in
            HeartRateZone(
                index: index + 1,
                range: (maximumBpm * bounds[index])..<(maximumBpm * bounds[index + 1]),
                label: labels[index].0,
                purpose: labels[index].1
            )
        }
    }

    /// Temps passé dans chaque zone, en secondes, zones 1 à 5.
    ///
    /// Chaque échantillon vaut jusqu'au suivant, plafonné : un trou de
    /// capteur de dix minutes ne doit pas verser dix minutes dans la zone du
    /// dernier battement vu avant le trou.
    public static func secondsPerZone(
        samples: [HeartRateSample],
        maximumBpm: Double,
        maxSampleGap: TimeInterval = 15
    ) -> [Int: TimeInterval] {
        let zones = zones(maximumBpm: maximumBpm)
        let ordered = samples.sorted { $0.timestamp < $1.timestamp }
        var result: [Int: TimeInterval] = [:]
        for index in 0..<ordered.count {
            let sample = ordered[index]
            let span: TimeInterval
            if index + 1 < ordered.count {
                span = min(maxSampleGap, ordered[index + 1].timestamp.timeIntervalSince(sample.timestamp))
            } else {
                span = min(maxSampleGap, 5)
            }
            guard span > 0, sample.bpm > 0 else { continue }
            let zone = zones.last { $0.range.lowerBound <= sample.bpm }?.index
                ?? (sample.bpm < zones[0].range.lowerBound ? 1 : 5)
            result[zone, default: 0] += span
        }
        return result
    }

    /// La charge d'entraînement de la sortie (TRIMP d'Edwards) : le temps en
    /// zone pondéré par la zone. Un nombre sans unité qui n'a de sens que
    /// comparé à soi-même — c'est précisément ce qu'on lui demande.
    public static func trainingLoad(secondsPerZone: [Int: TimeInterval]) -> Double {
        secondsPerZone.reduce(0) { total, entry in
            total + entry.value / 60 * Double(entry.key)
        }
    }

    /// Moyenne, plafonnée aux valeurs plausibles.
    public static func average(samples: [HeartRateSample]) -> Double? {
        let valid = samples.map(\.bpm).filter { $0 > 25 && $0 < 250 }
        guard !valid.isEmpty else { return nil }
        return valid.reduce(0, +) / Double(valid.count)
    }
}
