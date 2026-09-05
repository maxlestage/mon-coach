import Foundation

/// Ce que la trace a jeté, dit à l'athlète.
///
/// Pourquoi ce type existe
/// -----------------------
/// Le nettoyage compte déjà ce qu'il écarte — points imprécis, sauts
/// impossibles, horodatages qui reculent — et personne ne le lui demandait.
/// Or c'est exactement l'information qui manque au moment où elle compte :
/// une sortie qui annonce 8,2 km au lieu des 9 attendus laisse croire qu'on
/// a ralenti, ou que l'application compte mal. La vérité — « quarante points
/// ont été écartés parce que le GPS annonçait plus de vingt-cinq mètres
/// d'erreur » — est à la fois moins flatteuse et beaucoup plus utile.
///
/// Le silence, ici, est une forme de mensonge : l'application sait pourquoi
/// le chiffre est court, et se tait.
public struct TraceQualityNote: Sendable, Equatable {
    /// Le nombre total de points écartés.
    public var rejectedTotal: Int
    /// La part de la trace d'origine effectivement retenue, 0 à 1.
    public var retention: Double
    /// Ce qu'il faut retenir, en une phrase.
    public var headline: LocalizedText
    /// Le détail, une ligne par raison rencontrée.
    public var reasons: [LocalizedText]

    /// Vrai quand il manque assez de trace pour que la distance en pâtisse.
    public var isSevere: Bool { retention < 0.85 }
}

public extension TraceAnalysis {

    /// En dessous de ce nombre de points écartés, on ne dit rien.
    ///
    /// Un GPS jette toujours deux ou trois points au démarrage, le temps de
    /// se fixer. Les signaler ferait une alerte à chaque sortie, et une
    /// alerte qu'on voit à chaque sortie n'est plus une alerte.
    static let quietRejectionCount = 5

    /// Ce qu'il y a à dire de la qualité d'une trace, ou rien.
    ///
    /// Rend `nil` quand la trace est propre : un écran qui rassure sur
    /// quelque chose que personne n'a mis en doute n'apprend rien et occupe
    /// la place de ce qui compte.
    static func quality(of trace: CleanTrace) -> TraceQualityNote? {
        let total = trace.rejectedForAccuracy + trace.rejectedForSpeed + trace.rejectedForOrder
        // Deux portes plutôt qu'une : ce qui a été jeté, et ce qui a été
        // gardé de justesse.
        //
        // La seconde est nouvelle, et elle est la contrepartie de la
        // tolérance. Les points au signal médiocre ne sont plus jetés — ils
        // comptent — mais quand ils portent plus d'un cinquième de la
        // mesure, la distance affichée n'a plus la précision qu'elle
        // laisse croire, et le taire serait remplacer un défaut par un
        // autre.
        //
        // En dessous de ce cinquième, on se tait : quelques points flous
        // sur une sortie en ville sont l'ordinaire, et une remarque à
        // chaque sortie est une remarque qu'on apprend à ne plus lire.
        let worthSaying = (total >= quietRejectionCount || trace.retention < 0.97) && total > 0
        guard worthSaying || trace.leansOnPoorSignal else { return nil }

        var reasons: [LocalizedText] = []
        if trace.rejectedForAccuracy > 0 {
            let count = trace.rejectedForAccuracy
            reasons.append(
                LocalizedText(
                    fr: "\(count) point\(count > 1 ? "s" : "") écarté\(count > 1 ? "s" : "") pour imprécision : le GPS annonçait lui-même une erreur trop grande — sous les arbres, entre des immeubles, ou au démarrage.",
                    en: "\(count) point\(count > 1 ? "s" : "") dropped for accuracy: the GPS reported too large an error itself — under trees, between buildings, or while it was still fixing.",
                    es: "\(count) punto\(count > 1 ? "s" : "") descartado\(count > 1 ? "s" : "") por imprecisión: el propio GPS declaraba un error demasiado grande: bajo árboles, entre edificios o al arrancar."
                )
            )
        }
        // Ce qui a été gardé malgré un signal médiocre se dit aussi.
        //
        // Ces points-là ne sont plus jetés — c'était le défaut : en ville ou
        // sous les arbres, des tronçons entiers de sortie réelle
        // disparaissaient. Ils comptent donc dans la distance. Mais compter
        // sans le dire serait l'autre moitié du même défaut : l'athlète a le
        // droit de savoir que ses kilomètres reposent en partie sur des
        // points à quarante mètres près.
        if trace.keptWithPoorAccuracy > 0 {
            let count = trace.keptWithPoorAccuracy
            reasons.append(
                LocalizedText(
                    fr: "\(count) points gardés malgré un signal faible : la distance est comptée, à quelques dizaines de mètres près.",
                    en: "\(count) points kept despite a weak signal: the distance counts, to within a few dozen metres.",
                    es: "\(count) puntos conservados pese a una señal débil: la distancia cuenta, con unas decenas de metros de margen."
                )
            )
        }

        if trace.rejectedForSpeed > 0 {
            let count = trace.rejectedForSpeed
            reasons.append(
                LocalizedText(
                    fr: "\(count) point\(count > 1 ? "s impliquaient" : " impliquait") un déplacement impossible : un saut de GPS, pas une accélération. Le compter aurait ajouté des mètres que tu n'as pas parcourus.",
                    en: "\(count) point\(count > 1 ? "s implied" : " implied") an impossible move: a GPS jump, not a sprint. Counting it would have added metres you never covered.",
                    es: "\(count) punto\(count > 1 ? "s implicaban" : " implicaba") un desplazamiento imposible: un salto del GPS, no una aceleración. Contarlo habría añadido metros que no recorriste."
                )
            )
        }
        if trace.rejectedForOrder > 0 {
            let count = trace.rejectedForOrder
            reasons.append(
                LocalizedText(
                    fr: "\(count) point\(count > 1 ? "s revenaient" : " revenait") en arrière dans le temps. Un horodatage qui recule ne se corrige pas, il se jette.",
                    en: "\(count) point\(count > 1 ? "s went" : " went") backwards in time. A timestamp that moves backwards cannot be corrected, only discarded.",
                    es: "\(count) punto\(count > 1 ? "s retrocedían" : " retrocedía") en el tiempo. Una marca temporal que retrocede no se corrige, se descarta."
                )
            )
        }

        let percent = Int((trace.retention * 100).rounded())
        let headline: LocalizedText = trace.retention < 0.85
            ? LocalizedText(
                fr: "Il ne reste que \(percent) % de la trace d'origine : la distance ci-dessus est plus courte que ce que tu as réellement parcouru. Ce n'est pas toi qui as ralenti.",
                en: "Only \(percent) % of the original trace is left: the distance above is shorter than what you actually covered. You did not slow down.",
                es: "Solo queda el \(percent) % de la traza original: la distancia de arriba es más corta de lo que realmente recorriste. No has bajado el ritmo."
            )
            : LocalizedText(
                fr: "\(percent) % de la trace a été retenue. Ce qui a été jeté l'a été parce que c'était faux, pas parce que ça arrangeait le chiffre.",
                en: "\(percent) % of the trace was kept. What was thrown away went because it was wrong, not because it flattered the number.",
                es: "Se ha conservado el \(percent) % de la traza. Lo descartado se fue por ser falso, no por mejorar la cifra."
            )

        return TraceQualityNote(
            rejectedTotal: total,
            retention: trace.retention,
            headline: headline,
            reasons: reasons
        )
    }

    /// La même lecture à partir d'une activité enregistrée.
    ///
    /// La trace brute est conservée dans le journal : le nettoyage se refait
    /// à la lecture plutôt que de stocker des compteurs qui deviendraient
    /// faux le jour où les filtres changent.
    static func quality(of activity: ActivityLog) -> TraceQualityNote? {
        guard activity.sport.tracksLocation, activity.points.count > 2 else { return nil }
        return quality(of: clean(activity.points, filter: activity.sport.filter))
    }
}
