import Foundation

/// La fiche d'un exercice précis : ce que c'est, comment on le règle, et
/// l'erreur qui lui est propre.
///
/// Pourquoi ce type existe à côté de `GuidedTechnique`
/// --------------------------------------------------
/// La fiche guidée décrit un **schéma moteur** — s'accroupir, pousser au-
/// dessus de la tête, tirer horizontalement — et elle a raison de le faire :
/// ce qui protège le bas du dos au squat barre le protège aussi au goblet
/// squat, et le répéter quatre-vingt-douze fois n'apprendrait rien de plus.
///
/// Mais un athlète devant une machine ne demande pas comment on s'accroupit.
/// Il demande **ce que cette machine-là lui veut** : où mettre les pieds sur
/// le plateau, à quel angle régler ce banc, pourquoi cet exercice est dans sa
/// séance plutôt qu'un autre, et ce qui va lui faire mal s'il s'y prend mal.
/// Ça, aucune fiche de famille ne peut le dire — et sans réponse, un
/// débutant fait le mouvement de travers en croyant bien faire, ce qui est
/// exactement la situation qu'on voulait éviter.
///
/// Ce type porte donc les trois choses qui **changent d'un exercice à
/// l'autre**. Tout le reste — les muscles travaillés, les séries, le repos,
/// le matériel, ce que ça peut remplacer — se déduit du catalogue et n'est
/// jamais recopié à la main : une donnée recopiée finit toujours par mentir.
public struct ExerciseBrief: Sendable, Equatable, Identifiable, Hashable {
    /// L'identifiant de l'exercice décrit.
    public var id: String
    /// Ce que c'est, et ce que ça donne. Une phrase, pas un paragraphe :
    /// elle se lit debout, entre deux séries.
    public var what: LocalizedText
    /// Les réglages propres à ce mouvement — angle, prise, hauteur, pieds.
    /// C'est la partie qu'aucune vidéo ne montre assez lentement.
    public var setup: LocalizedText
    /// L'erreur que fait précisément *cet* exercice, et ce qu'elle coûte.
    /// Décrite par ce qu'on ressent, pas par ce qu'un observateur verrait :
    /// personne ne se filme, mais tout le monde sait où ça tire.
    public var watchOut: LocalizedText

    public init(
        id: String,
        what: LocalizedText,
        setup: LocalizedText,
        watchOut: LocalizedText
    ) {
        self.id = id
        self.what = what
        self.setup = setup
        self.watchOut = watchOut
    }
}

/// Ce qu'un exercice travaille, et pour quelle part.
public struct MuscleShare: Sendable, Equatable, Identifiable, Hashable {
    public var id: MuscleGroup { muscle }
    public var muscle: MuscleGroup
    /// 1 pour le muscle principal, 0,5 pour un secondaire — la même règle
    /// que celle qui compte le volume hebdomadaire, pour que la fiche et le
    /// tableau de bord ne se contredisent jamais.
    public var credit: Double

    public var percent: Int { Int((credit * 100).rounded()) }
}

/// Les fiches d'exercice, et ce qui se déduit du catalogue autour d'elles.
public enum ExerciseBriefs {

    /// Toutes les fiches, rangées par identifiant d'exercice.
    ///
    /// Les familles vivent dans des fichiers séparés parce qu'un fichier de
    /// deux mille lignes ne se relit pas, et qu'une fiche qu'on ne relit pas
    /// finit fausse.
    public static let all: [String: ExerciseBrief] = Dictionary(
        uniqueKeysWithValues: (legs + push + pull + arms + core + machinesLower + machinesUpper)
            .map { ($0.id, $0) }
    )

    /// La fiche d'un exercice. Aucun exercice du catalogue n'en est privé —
    /// un test s'en assure, et c'est le seul moyen de garantir qu'un
    /// quatre-vingt-treizième mouvement ajouté un mardi ne partira pas nu.
    public static func brief(for exercise: Exercise) -> ExerciseBrief? {
        all[exercise.id]
    }

    public static func brief(forID id: String) -> ExerciseBrief? {
        all[id]
    }

    /// Ce que l'exercice travaille, du plus au moins sollicité.
    public static func muscles(of exercise: Exercise) -> [MuscleShare] {
        exercise.allMuscles.map {
            MuscleShare(muscle: $0, credit: exercise.volumeCredit(for: $0))
        }
    }

    /// Les mouvements qui peuvent remplacer celui-là.
    ///
    /// Même schéma moteur et même muscle principal : c'est la définition
    /// stricte du remplaçant. Un rowing ne remplace pas un développé même
    /// s'il fait travailler les mêmes bras quelque part.
    ///
    /// Le tri met devant ce qui demande le moins de matériel : dans une
    /// salle vide un dimanche soir, la question n'est pas « quel est le
    /// meilleur » mais « lequel puis-je faire maintenant ».
    public static func alternatives(
        to exercise: Exercise,
        owning equipment: Set<Equipment>? = nil,
        limit: Int = 4
    ) -> [Exercise] {
        ExerciseCatalog.all
            .filter { candidate in
                candidate.id != exercise.id
                    && candidate.pattern == exercise.pattern
                    && candidate.primaryMuscle == exercise.primaryMuscle
                    && (equipment.map { candidate.isAvailable(with: $0) } ?? true)
            }
            .sorted { left, right in
                left.equipment.count == right.equipment.count
                    ? left.id < right.id
                    : left.equipment.count < right.equipment.count
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Comment savoir que la charge est juste, dit à partir des données de
    /// l'exercice plutôt qu'écrit à la main quatre-vingt-douze fois.
    ///
    /// La fourchette de répétitions vient du catalogue : elle est déjà celle
    /// qui a du sens pour ce mouvement — un triple lourd à l'élévation
    /// latérale n'est pas une prescription utile, et le catalogue le sait.
    public static func loadAdvice(for exercise: Exercise) -> LocalizedText {
        let low = exercise.viableRepRange.lowerBound
        let high = exercise.viableRepRange.upperBound
        let side = exercise.isUnilateral
        return LocalizedText(
            fr: "La charge est juste quand la dernière répétition propre tombe entre \(low) et \(high)"
                + (side ? " de chaque côté" : "")
                + ". S'il t'en reste trois en réserve à la dernière série, monte la fois d'après ; si la forme se casse avant \(low), descends.",
            en: "The load is right when the last clean rep lands between \(low) and \(high)"
                + (side ? " per side" : "")
                + ". If you still have three in reserve on the last set, go up next time; if form breaks before \(low), come down.",
            es: "La carga es correcta cuando la última repetición limpia cae entre \(low) y \(high)"
                + (side ? " por lado" : "")
                + ". Si te quedan tres en reserva en la última serie, sube la próxima vez; si la técnica se rompe antes de \(low), baja."
        )
    }

    /// Le repos entre les séries, dit en clair.
    public static func restAdvice(for exercise: Exercise) -> LocalizedText {
        let seconds = exercise.baseRestSeconds
        let minutes = Double(seconds) / 60
        let spoken = seconds >= 90
            ? String(format: "%.1f", minutes).replacingOccurrences(of: ".0", with: "")
            : "\(seconds)"
        let unitFR = seconds >= 90 ? "minutes" : "secondes"
        let unitEN = seconds >= 90 ? "minutes" : "seconds"
        let unitES = seconds >= 90 ? "minutos" : "segundos"
        return LocalizedText(
            fr: "\(spoken) \(unitFR) entre les séries"
                + (exercise.isCompound
                    ? " — un mouvement à plusieurs articulations a besoin que le système nerveux récupère, pas seulement le muscle."
                    : " — l'isolation récupère vite, et traîner ne rend pas la série suivante meilleure."),
            en: "\(spoken) \(unitEN) between sets"
                + (exercise.isCompound
                    ? " — a multi-joint movement needs the nervous system to recover, not just the muscle."
                    : " — isolation recovers fast, and dawdling does not make the next set better."),
            es: "\(spoken) \(unitES) entre series"
                + (exercise.isCompound
                    ? " — un movimiento multiarticular necesita que se recupere el sistema nervioso, no solo el músculo."
                    : " — el aislamiento se recupera rápido, y demorarse no mejora la serie siguiente.")
        )
    }

    /// Pourquoi ce mouvement est dans la séance, déduit de ce qu'il est.
    ///
    /// Un composé lourd, une isolation à fort rendement et un mouvement
    /// unilatéral n'y sont pas pour les mêmes raisons, et savoir laquelle
    /// change la façon de le faire : on ne se donne pas à fond sur un
    /// exercice dont le rôle est de préparer le suivant.
    public static func role(of exercise: Exercise) -> LocalizedText {
        if exercise.isCompound && exercise.stimulusRating >= 4 {
            return LocalizedText(
                fr: "Un mouvement de base à fort rendement : il porte la séance, et c'est sur lui qu'on met l'énergie du début.",
                en: "A high-yield compound: it carries the session, and it gets the energy you have at the start.",
                es: "Un movimiento básico de alto rendimiento: sostiene la sesión y se lleva la energía del principio."
            )
        }
        if exercise.isCompound {
            return LocalizedText(
                fr: "Un mouvement à plusieurs articulations : il ajoute du volume sans coûter aussi cher que les gros basiques.",
                en: "A multi-joint movement: it adds volume without costing as much as the big basics.",
                es: "Un movimiento multiarticular: añade volumen sin costar tanto como los básicos grandes."
            )
        }
        if exercise.isUnilateral {
            return LocalizedText(
                fr: "Un mouvement d'un côté à la fois : il rattrape les écarts droite-gauche qu'un mouvement à deux bras laisse s'installer.",
                en: "A one-side-at-a-time movement: it catches the left-right gaps a two-limb movement lets settle in.",
                es: "Un movimiento de un lado cada vez: corrige las diferencias derecha-izquierda que un movimiento a dos deja instalarse."
            )
        }
        return LocalizedText(
            fr: "Une isolation : elle cible un muscle précis, coûte peu en fatigue, et se place après les basiques.",
            en: "An isolation: it targets one muscle, costs little fatigue, and sits after the basics.",
            es: "Un aislamiento: apunta a un músculo concreto, cuesta poca fatiga y va después de los básicos."
        )
    }

    /// Le matériel nécessaire, nommé.
    public static func equipmentNeeded(for exercise: Exercise) -> [Equipment] {
        exercise.equipment.sorted { $0.rawValue < $1.rawValue }
    }
}
