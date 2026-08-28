import Foundation

/// How the day's session should be scaled, based on the pre-training check-in.
public struct ReadinessVerdict: Sendable, Equatable {
    /// 0–100. Above 70 the session runs as written.
    public let score: Int
    /// Multiplier applied to prescribed loads.
    public let loadMultiplier: Double
    /// Working sets to drop from the session, applied to the last exercises first.
    public let setsToDrop: Int
    public let headline: LocalizedText
    public let advice: LocalizedText

    public var isGreenLight: Bool { loadMultiplier >= 1.0 && setsToDrop == 0 }
}

/// Reads the daily check-in and decides whether to run the session as planned.
///
/// The point is not to give the athlete permission to skip. It is to keep a
/// bad day from turning into a bad week: a reduced session that gets done
/// beats a full session that gets abandoned halfway.
public enum ReadinessEngine {

    public static func verdict(
        for check: ReadinessCheck?,
        profile: UserProfile
    ) -> ReadinessVerdict {
        guard let check else {
            return ReadinessVerdict(
                score: 70,
                loadMultiplier: 1.0,
                setsToDrop: 0,
                headline: LocalizedText(fr: "Séance au programme", en: "Session as planned", es: "Sesión según el plan"),
                advice: LocalizedText(
                    fr: "Pas de check-in aujourd'hui : la séance est prescrite telle quelle. Trente secondes de questionnaire et je peux l'ajuster.",
                    en: "No check-in today, so the session stands as written. Thirty seconds of questions and I can adjust it.",
                    es: "Hoy no hay check-in, así que la sesión queda tal cual. Treinta segundos de preguntas y puedo ajustarla."
                )
            )
        }

        // Sleep and stress carry the most weight; soreness matters but a
        // sore muscle is not an injured one.
        var score = 0.0
        score += Double(check.sleepQuality) * 8       // 8–40
        score += Double(6 - check.soreness) * 5       // 5–25
        score += Double(check.motivation) * 4         // 4–20
        score += Double(6 - check.stress) * 3         // 3–15

        if let hours = check.sleepHours {
            if hours < 5 { score -= 12 }
            else if hours < 6.5 { score -= 6 }
            else if hours >= 8 { score += 4 }
        }
        // Someone who habitually sleeps little should not be penalised twice.
        if profile.averageSleepHours < 6.5 { score += 4 }

        let clamped = Int(score.clamped(to: 0...100).rounded())

        switch clamped {
        case 80...:
            return ReadinessVerdict(
                score: clamped,
                loadMultiplier: 1.0,
                setsToDrop: 0,
                headline: LocalizedText(fr: "Feu vert", en: "Green light", es: "Luz verde"),
                advice: LocalizedText(
                    fr: "Tu es frais. C'est le jour pour tenter la charge du haut de la fourchette sur le premier exercice.",
                    en: "You are fresh. Today is the day to try the top of the range on the first exercise.",
                    es: "Estás fresco. Hoy es el día para intentar la parte alta del rango en el primer ejercicio."
                )
            )
        case 65..<80:
            return ReadinessVerdict(
                score: clamped,
                loadMultiplier: 1.0,
                setsToDrop: 0,
                headline: LocalizedText(fr: "Séance normale", en: "Normal session", es: "Sesión normal"),
                advice: LocalizedText(
                    fr: "Rien à signaler : suis le programme tel quel.",
                    en: "Nothing to report: follow the programme as written.",
                    es: "Nada que señalar: sigue el programa tal cual."
                )
            )
        case 50..<65:
            return ReadinessVerdict(
                score: clamped,
                loadMultiplier: 0.93,
                setsToDrop: 2,
                headline: LocalizedText(fr: "Séance allégée", en: "Lighter session", es: "Sesión aligerada"),
                advice: LocalizedText(
                    fr: "Journée moyenne : −7 % sur les charges et deux séries en moins sur la fin. Tu gardes le stimulus sans creuser la fatigue.",
                    en: "An average day: −7 % on loads and two fewer sets at the end. You keep the stimulus without digging into fatigue.",
                    es: "Día regular: −7 % en las cargas y dos series menos al final. Mantienes el estímulo sin cavar en la fatiga."
                )
            )
        case 35..<50:
            return ReadinessVerdict(
                score: clamped,
                loadMultiplier: 0.85,
                setsToDrop: 4,
                headline: LocalizedText(fr: "Version courte", en: "Short version", es: "Versión corta"),
                advice: LocalizedText(
                    fr: "On garde les exercices principaux à −15 % et on coupe les accessoires. Une séance courte reste une séance.",
                    en: "We keep the main lifts at −15 % and cut the accessories. A short session is still a session.",
                    es: "Mantenemos los básicos al −15 % y quitamos los accesorios. Una sesión corta sigue siendo una sesión."
                )
            )
        default:
            return ReadinessVerdict(
                score: clamped,
                loadMultiplier: 0.75,
                setsToDrop: 6,
                headline: LocalizedText(fr: "Récupération active", en: "Active recovery", es: "Recuperación activa"),
                advice: LocalizedText(
                    fr: "Tous les voyants sont au rouge. Fais les deux premiers exercices en technique pure, ou marche 30 minutes et reviens demain.",
                    en: "Every signal is red. Do the first two exercises as pure technique work, or walk for 30 minutes and come back tomorrow.",
                    es: "Todos los indicadores están en rojo. Haz los dos primeros ejercicios como técnica pura, o camina 30 minutos y vuelve mañana."
                )
            )
        }
    }

    /// Applies a verdict to a session: scales loads, then trims sets from the
    /// end, where the accessories live.
    public static func apply(_ verdict: ReadinessVerdict, to session: PlannedSession, increment: LoadIncrement) -> PlannedSession {
        guard !verdict.isGreenLight else { return session }

        var exercises = session.exercises.map { prescription -> ExercisePrescription in
            var copy = prescription
            copy.sets = prescription.sets.map { set in
                var scaled = set
                if let load = set.suggestedLoadKg {
                    scaled.suggestedLoadKg = StrengthMath.round(load * verdict.loadMultiplier, to: increment)
                }
                return scaled
            }
            return copy
        }

        var toDrop = verdict.setsToDrop
        var index = exercises.count - 1
        while toDrop > 0 && index >= 0 {
            // Never take a movement below two working sets — one set is noise.
            let removable = max(0, exercises[index].sets.count - 2)
            let removing = min(removable, toDrop)
            if removing > 0 {
                exercises[index].sets.removeLast(removing)
                toDrop -= removing
            }
            index -= 1
        }

        var trimmed = session
        trimmed.exercises = exercises
        return trimmed
    }
}
