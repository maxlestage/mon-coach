import SwiftUI
import MonCoachKit

extension EnvironmentValues {
    /// La langue dans laquelle toute l'interface se rend.
    ///
    /// Elle descend de la vue racine, qui la lit sur le magasin. Passer par
    /// l'environnement plutôt que par une variable globale a une conséquence
    /// concrète : changer de langue dans le profil rafraîchit tout l'écran
    /// immédiatement, sans redémarrer l'application.
    @Entry var language: Language = .french
}

extension View {
    /// Rend cette vue, et tout ce qu'elle contient, dans une langue donnée.
    func language(_ language: Language) -> some View {
        environment(\.language, language)
    }
}

/// Un texte du coach, rendu dans la langue de l'environnement.
///
/// Évite d'avoir à écrire `@Environment(\.language)` dans chaque petite vue
/// qui n'affiche qu'une phrase.
struct CoachText: View {
    var text: LocalizedText
    var font: Font = Theme.bodyFont
    var color: Color = Theme.secondaryText

    @Environment(\.language) private var language

    init(_ text: LocalizedText, font: Font = Theme.bodyFont, color: Color = Theme.secondaryText) {
        self.text = text
        self.font = font
        self.color = color
    }

    var body: some View {
        Text(text[language])
            .font(font)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// Les libellés de l'interface elle-même — boutons, titres d'écran, unités.
///
/// Le contenu de coaching vit dans le paquet, sous forme de `LocalizedText` ;
/// ce qui suit est la coquille de l'application, qui n'a rien à faire dans le
/// moteur. Même principe : trois champs, pas de clé, pas d'oubli possible.
enum UI {
    static let today = LocalizedText(fr: "Aujourd'hui", en: "Today", es: "Hoy")
    static let plan = LocalizedText(fr: "Plan", en: "Plan", es: "Plan")
    static let progress = LocalizedText(fr: "Progression", en: "Progress", es: "Progreso")
    static let profile = LocalizedText(fr: "Profil", en: "Profile", es: "Perfil")
    static let running = LocalizedText(fr: "Course", en: "Running", es: "Carrera")
    /// Le titre de l'onglet, depuis qu'il porte quarante-huit sports :
    /// « Course » y était devenu faux pour tous ceux qui ne courent pas.
    static let activities = LocalizedText(fr: "Activités", en: "Activities", es: "Actividades")
    static let stats = LocalizedText(fr: "Stats", en: "Stats", es: "Datos")
    static let food = LocalizedText(fr: "Alimentation", en: "Food", es: "Alimentación")

    static let start = LocalizedText(fr: "Démarrer", en: "Start", es: "Empezar")
    static let pause = LocalizedText(fr: "Pause", en: "Pause", es: "Pausa")
    static let resume = LocalizedText(fr: "Reprendre", en: "Resume", es: "Reanudar")
    static let finish = LocalizedText(fr: "Terminer", en: "Finish", es: "Terminar")
    static let cancel = LocalizedText(fr: "Annuler", en: "Cancel", es: "Cancelar")
    static let save = LocalizedText(fr: "Enregistrer", en: "Save", es: "Guardar")
    static let close = LocalizedText(fr: "Fermer", en: "Close", es: "Cerrar")
    static let delete = LocalizedText(fr: "Supprimer", en: "Delete", es: "Eliminar")

    static let distance = LocalizedText(fr: "Distance", en: "Distance", es: "Distancia")
    static let duration = LocalizedText(fr: "Durée", en: "Duration", es: "Duración")
    static let pace = LocalizedText(fr: "Allure", en: "Pace", es: "Ritmo")
    static let elevation = LocalizedText(fr: "Dénivelé +", en: "Elevation +", es: "Desnivel +")
    static let calories = LocalizedText(fr: "Calories", en: "Calories", es: "Calorías")
    static let splits = LocalizedText(fr: "Kilomètres", en: "Splits", es: "Parciales")
    static let language = LocalizedText(fr: "Langue", en: "Language", es: "Idioma")
    static let systemLanguage = LocalizedText(
        fr: "Suivre le système",
        en: "Follow the system",
        es: "Seguir el sistema"
    )
}
