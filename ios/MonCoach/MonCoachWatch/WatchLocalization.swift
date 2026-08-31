import SwiftUI
import MonCoachKit

extension EnvironmentValues {
    /// La langue de la montre, reçue du téléphone.
    @Entry var language: Language = .french
}

extension View {
    func language(_ language: Language) -> some View {
        environment(\.language, language)
    }
}

/// Les libellés de l'interface de la montre.
///
/// Un jeu à part de celui du téléphone, et volontairement plus court : au
/// poignet, une phrase de plus de six mots ne se lit pas en courant.
enum WatchUI {
    static let waiting = LocalizedText(
        fr: "En attente du téléphone",
        en: "Waiting for the phone",
        es: "Esperando al teléfono"
    )
    static let waitingDetail = LocalizedText(
        fr: "Ouvre Stride sur ton iPhone une première fois : la montre recevra la séance du jour et pourra ensuite fonctionner seule.",
        en: "Open Stride on your iPhone once: the watch will receive today's session and can then work on its own.",
        es: "Abre Stride en tu iPhone una vez: el reloj recibirá la sesión del día y luego podrá funcionar solo."
    )
    static let start = LocalizedText(fr: "Démarrer", en: "Start", es: "Empezar")
    static let rest = LocalizedText(fr: "Repos", en: "Rest day", es: "Descanso")
    static let syncing = LocalizedText(
        fr: "Synchronisation en attente",
        en: "Sync pending",
        es: "Sincronización pendiente"
    )
    static let run = LocalizedText(fr: "Sortie", en: "Run", es: "Rodaje")
    static let done = LocalizedText(fr: "Fait", en: "Done", es: "Hecho")
    static let pause = LocalizedText(fr: "Pause", en: "Pause", es: "Pausa")
    static let resume = LocalizedText(fr: "Reprendre", en: "Resume", es: "Reanudar")
    static let finish = LocalizedText(fr: "Terminer", en: "Finish", es: "Terminar")
    static let searchingGPS = LocalizedText(
        fr: "Recherche GPS…",
        en: "Finding GPS…",
        es: "Buscando GPS…"
    )
    static let weakSignal = LocalizedText(
        fr: "Signal faible",
        en: "Weak signal",
        es: "Señal débil"
    )
    static let food = LocalizedText(fr: "À manger", en: "To eat", es: "Para comer")
    /// Le raccourci d'une sortie libre, hors plan.
    static let freeRun = LocalizedText(fr: "Courir", en: "Go for a run", es: "Salir a correr")
    static let freeRunDetail = LocalizedText(
        fr: "Hors plan, sans le téléphone",
        en: "Off plan, phone left behind",
        es: "Fuera de plan, sin el teléfono"
    )
    /// Le menu de départ : c'est l'athlète qui décide, pas le plan.
    static let chooseActivity = LocalizedText(
        fr: "Tu fais quoi ?",
        en: "What are you doing?",
        es: "¿Qué vas a hacer?"
    )
    static let lastTime = LocalizedText(
        fr: "La dernière fois",
        en: "Last time",
        es: "La última vez"
    )
    static let planned = LocalizedText(fr: "Au plan", en: "On plan", es: "En el plan")
    static let runAgain = LocalizedText(
        fr: "Sortie du jour enregistrée",
        en: "Today's run is logged",
        es: "Rodaje de hoy registrado"
    )
    static let credit = LocalizedText(
        fr: "Conçu et développé par Maxime Nathan Lestage",
        en: "Designed and developed by Maxime Nathan Lestage",
        es: "Diseñado y desarrollado por Maxime Nathan Lestage"
    )

    static func week(_ index: Int, deload: Bool) -> LocalizedText {
        deload
            ? LocalizedText(
                fr: "Semaine \(index) · décharge",
                en: "Week \(index) · deload",
                es: "Semana \(index) · descarga"
            )
            : LocalizedText(fr: "Semaine \(index)", en: "Week \(index)", es: "Semana \(index)")
    }

    static func sessionSummary(exercises: Int, sets: Int, minutes: Int) -> LocalizedText {
        LocalizedText(
            fr: "\(exercises) exercices · \(sets) séries · ~\(minutes) min",
            en: "\(exercises) exercises · \(sets) sets · ~\(minutes) min",
            es: "\(exercises) ejercicios · \(sets) series · ~\(minutes) min"
        )
    }

    static func restDay(proteinG: Int) -> LocalizedText {
        LocalizedText(
            fr: "Rien de prévu aujourd'hui. \(proteinG) g de protéines, et du sommeil.",
            en: "Nothing planned today. \(proteinG) g of protein, and sleep.",
            es: "Nada previsto hoy. \(proteinG) g de proteína, y dormir."
        )
    }
}
