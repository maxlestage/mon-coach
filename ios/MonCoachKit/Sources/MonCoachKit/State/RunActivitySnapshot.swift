import Foundation

/// L'état d'une sortie en cours, tel que la Live Activity l'affiche.
///
/// Comme pour la séance, l'état vit ici plutôt que dans l'extension : c'est
/// du calcul, et le calcul se teste. Les textes traversent déjà rendus, la
/// Live Activity n'ayant pas accès au magasin ni à la langue choisie.
public struct RunActivitySnapshot: Codable, Sendable, Hashable {
    /// Type de la sortie, déjà traduit.
    public var typeLabel: String
    /// Distance parcourue, formatée dans l'unité de l'athlète.
    public var distance: String
    /// Allure récente, formatée.
    public var pace: String
    /// Dénivelé positif, en mètres.
    public var elevationGain: Int
    /// Instant de départ, pour que le système anime le chrono sans réveiller
    /// l'application — la même mécanique que le repos entre les séries.
    public var startedAt: Date
    /// Temps déjà écoulé en mouvement, hors pauses.
    public var movingSeconds: TimeInterval
    public var isPaused: Bool
    /// Vrai quand le signal ne permet pas de garantir les chiffres affichés.
    public var hasWeakSignal: Bool

    public init(
        typeLabel: String,
        distance: String,
        pace: String,
        elevationGain: Int,
        startedAt: Date,
        movingSeconds: TimeInterval,
        isPaused: Bool,
        hasWeakSignal: Bool
    ) {
        self.typeLabel = typeLabel
        self.distance = distance
        self.pace = pace
        self.elevationGain = elevationGain
        self.startedAt = startedAt
        self.movingSeconds = movingSeconds
        self.isPaused = isPaused
        self.hasWeakSignal = hasWeakSignal
    }
}

#if canImport(CoreLocation)

extension LocationTracker {

    /// L'état de la Live Activité pour l'instant présent de la sortie.
    public func activitySnapshot(unit: UnitSystem, language: Language) -> RunActivitySnapshot {
        RunActivitySnapshot(
            typeLabel: type.label[language],
            distance: Format.distance(meters: meters, unit: unit, language: language),
            pace: Format.pace(secondsPerKm: recentPaceSecondsPerKm, unit: unit),
            elevationGain: Int(elevationGain.rounded()),
            startedAt: startedAt ?? Date(),
            movingSeconds: movingDuration,
            isPaused: state == .paused,
            hasWeakSignal: !hasUsableSignal
        )
    }
}

#endif
