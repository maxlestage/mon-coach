import AVFoundation
import MonCoachKit

/// La voix qui annonce chaque kilomètre, écouteurs dans les oreilles.
///
/// Pourquoi ce type existe
/// -----------------------
/// En courant, on ne regarde pas son téléphone : il est dans une poche ou
/// sur un brassard. Les chiffres de l'écran, aussi justes soient-ils, n'y
/// servent à rien. Ce qu'un coureur veut, c'est ce que Strava a rendu
/// familier : une voix qui dit, au passage de chaque kilomètre, où on en
/// est — et rien d'autre.
///
/// La synthèse est celle du système, entièrement sur l'appareil : aucune
/// requête ne sort du téléphone, ce qui est la règle de toute l'application.
@MainActor
final class VoiceAnnouncer {

    private let synthesizer = AVSpeechSynthesizer()

    /// La voix parle par-dessus la musique en la baissant le temps d'une
    /// phrase, plutôt qu'en la coupant : personne ne veut perdre son morceau
    /// pour entendre « kilomètre trois ».
    init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .playback,
            mode: .voicePrompt,
            options: [.duckOthers, .interruptSpokenAudioAndMixWithOthers]
        )
    }

    /// Annonce un kilomètre bouclé : le numéro, l'allure du kilomètre, le
    /// temps total. Trois faits, dans cet ordre, parce que c'est l'ordre
    /// des questions qu'on se pose en courant.
    func announce(split: Split, totalSeconds: TimeInterval, language: Language) {
        speak(
            phrase(split: split, totalSeconds: totalSeconds, language: language),
            language: language
        )
    }

    func speak(_ text: String, language: Language) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: voiceCode(language))
        try? AVAudioSession.sharedInstance().setActive(true)
        synthesizer.speak(utterance)
    }

    // MARK: - Les phrases

    /// La phrase est écrite pour l'oreille, pas pour l'écran : « 5 minutes
    /// 42 au kilomètre », jamais « 5:42/km » — une voix qui lit des symboles
    /// dit n'importe quoi.
    func phrase(split: Split, totalSeconds: TimeInterval, language: Language) -> String {
        let pace = spokenDuration(split.paceSecondsPerKm, language: language)
        let total = spokenDuration(totalSeconds, language: language)
        switch language {
        case .french:
            return "Kilomètre \(split.index). \(pace) au kilomètre. Temps total : \(total)."
        case .english:
            return "Kilometer \(split.index). \(pace) per kilometer. Total time: \(total)."
        case .spanish:
            return "Kilómetro \(split.index). \(pace) por kilómetro. Tiempo total: \(total)."
        }
    }

    func spokenDuration(_ seconds: TimeInterval, language: Language) -> String {
        let whole = Int(seconds.rounded())
        let hours = whole / 3600
        let minutes = (whole % 3600) / 60
        let secs = whole % 60
        let hourWord: String
        let minuteWord: String
        let secondWord: String
        switch language {
        case .french: (hourWord, minuteWord, secondWord) = ("heure", "minute", "seconde")
        case .english: (hourWord, minuteWord, secondWord) = ("hour", "minute", "second")
        case .spanish: (hourWord, minuteWord, secondWord) = ("hora", "minuto", "segundo")
        }
        var parts: [String] = []
        if hours > 0 { parts.append("\(hours) \(hourWord)\(hours > 1 ? "s" : "")") }
        if minutes > 0 { parts.append("\(minutes) \(minuteWord)\(minutes > 1 ? "s" : "")") }
        if secs > 0 || parts.isEmpty { parts.append("\(secs) \(secondWord)\(secs > 1 ? "s" : "")") }
        return parts.joined(separator: " ")
    }

    private func voiceCode(_ language: Language) -> String {
        switch language {
        case .french: "fr-FR"
        case .english: "en-US"
        case .spanish: "es-ES"
        }
    }
}
