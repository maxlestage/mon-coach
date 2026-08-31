import Foundation

/// Ce qu'on propose un jour sans séance prescrite.
///
/// Pourquoi ce type existe
/// -----------------------
/// Un jour de repos, l'accueil disait « rien de prévu aujourd'hui » et
/// s'arrêtait là. C'est vrai du plan, et faux de la journée : quelqu'un qui
/// ouvre l'application un jour creux ne cherche pas une permission de ne
/// rien faire, il cherche quoi faire.
///
/// Ces mouvements ne sont pas une séance. Ils ne comptent pas dans le budget
/// hebdomadaire de séries, ils ne se cochent pas, et ne pas les faire ne met
/// aucun retard nulle part — c'est ce qui les sépare du plan. Le seul vrai
/// jour de repos, celui qui clôt la semaine, n'en reçoit aucun : la
/// récupération est la moitié du travail, et un écran qui propose quelque
/// chose sept jours sur sept ne la défend plus.
///
/// Le vivier est ce que l'athlète peut réellement faire — son matériel, ses
/// zones sensibles, ses refus. Proposer une presse à cuisses à quelqu'un qui
/// s'entraîne dans son salon serait une invitation à fermer l'application.
public enum DailyExtras {

    /// Quatre : de quoi remplir vingt minutes sans que ça ressemble à une
    /// séance déguisée.
    public static let dailyCount = 4

    /// La graine du mélange, propre à cette liste.
    static let seed: UInt64 = 0x4A6F_7572_4C69_6272

    /// Les mouvements du jour, pour cet athlète.
    ///
    /// Le catalogue est déjà filtré par `available(for:)` : matériel possédé,
    /// blessures déclarées, exercices écartés. Rien à refaire ici — deux
    /// filtres tenus séparément finiraient par ne plus dire la même chose.
    public static func ofTheDay(
        on date: Date = Date(),
        profile: UserProfile,
        count: Int = dailyCount,
        calendar: Calendar = .current
    ) -> [Exercise] {
        let pool = ExerciseCatalog.available(for: profile).sorted { $0.id < $1.id }
        guard !pool.isEmpty, count > 0 else { return [] }
        return DailyRotation.selection(
            from: pool,
            dayIndex: DailyRotation.dayIndex(of: date, calendar: calendar),
            count: count,
            seed: seed
        )
    }

    /// Ce que l'écran dit en les proposant.
    public static let invitation = LocalizedText(
        fr: "Rien d'obligatoire aujourd'hui. Si tu veux bouger quand même, ces quatre-là sont à ta portée — deux ou trois séries chacun, sans forcer.",
        en: "Nothing required today. If you want to move anyway, these four are within reach — two or three sets each, without pushing.",
        es: "Hoy no hay nada obligatorio. Si aun así quieres moverte, estos cuatro están a tu alcance: dos o tres series de cada uno, sin forzar."
    )

    /// Ce qu'il dit le dernier jour, quand il ne propose rien.
    public static let realRest = LocalizedText(
        fr: "Dernier jour de la semaine : c'est le vrai repos. Mange tes protéines, dors, et reviens en forme lundi.",
        en: "Last day of the week: this is the real rest. Eat your protein, sleep, and come back fresh on Monday.",
        es: "Último día de la semana: este es el descanso de verdad. Come tu proteína, duerme y vuelve en forma el lunes."
    )
}
