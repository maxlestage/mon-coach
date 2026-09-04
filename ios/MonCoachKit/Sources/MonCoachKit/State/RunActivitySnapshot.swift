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
    /// Le dernier battement mesuré, ou nul si rien ne le mesure.
    ///
    /// Nul est un état normal et fréquent : sans ceinture cardio appairée,
    /// le téléphone n'a aucun moyen de connaître le pouls pendant l'effort.
    /// L'écran verrouillé n'affiche alors pas de case vide — il n'affiche
    /// rien, ce qui est la vérité.
    public var heartRateBpm: Int?
    /// La zone de ce battement, de 1 à 5, ou nulle si on ne connaît pas la
    /// fréquence maximale de l'athlète.
    ///
    /// C'est elle qui rend le chiffre utile en courant. Cent cinquante-deux
    /// battements ne veulent rien dire ; « zone 2 » dit de continuer, et
    /// « zone 4 » dit que la sortie facile ne l'est plus.
    public var heartRateZone: Int?
    /// La forme du parcours, dessinable telle quelle sur l'écran verrouillé.
    ///
    /// Vide tant qu'il n'y a rien à montrer — les cinquante premiers mètres,
    /// une machine sans GPS, un signal qui ne prend pas. La vue s'en sert
    /// comme d'une question : s'il y a une trace, elle la dessine.
    public var trace: TraceMiniature

    public init(
        typeLabel: String,
        distance: String,
        pace: String,
        elevationGain: Int,
        startedAt: Date,
        movingSeconds: TimeInterval,
        isPaused: Bool,
        hasWeakSignal: Bool,
        heartRateBpm: Int? = nil,
        heartRateZone: Int? = nil,
        trace: TraceMiniature = .empty
    ) {
        self.typeLabel = typeLabel
        self.distance = distance
        self.pace = pace
        self.elevationGain = elevationGain
        self.startedAt = startedAt
        self.movingSeconds = movingSeconds
        self.isPaused = isPaused
        self.hasWeakSignal = hasWeakSignal
        self.heartRateBpm = heartRateBpm
        self.heartRateZone = heartRateZone
        self.trace = trace
    }
}

#if canImport(CoreLocation)

extension LocationTracker {

    /// L'état de la Live Activité pour l'instant présent de la sortie.
    ///
    /// Le pouls arrive de l'extérieur : le suivi GPS ne mesure pas de
    /// cardio, et la fréquence maximale appartient au profil de l'athlète,
    /// que ce paquet ne connaît pas d'ici. Les deux sont donc passés par
    /// l'écran qui les a — et restent facultatifs, parce que courir sans
    /// ceinture est le cas ordinaire.
    public func activitySnapshot(
        unit: UnitSystem,
        language: Language,
        heartRateBpm: Int? = nil,
        maximumBpm: Double? = nil
    ) -> RunActivitySnapshot {
        RunActivitySnapshot(
            typeLabel: type.label[language],
            distance: Format.distance(meters: meters, unit: unit, language: language),
            pace: Format.pace(secondsPerKm: recentPaceSecondsPerKm, unit: unit),
            elevationGain: Int(elevationGain.rounded()),
            startedAt: startedAt ?? Date(),
            movingSeconds: movingDuration,
            isPaused: state == .paused,
            hasWeakSignal: !hasUsableSignal,
            heartRateBpm: heartRateBpm,
            heartRateZone: heartRateBpm.flatMap { bpm in
                maximumBpm.map { HeartRateAnalysis.zone(for: Double(bpm), maximumBpm: $0) }
            },
            // La trace nettoyée plutôt que les points bruts : c'est celle
            // dont les chiffres au-dessus sont tirés, et elle a déjà écarté
            // les points aberrants. Dessiner les points bruts montrerait des
            // écarts que la distance affichée ignore — deux versions de la
            // même sortie sur le même écran.
            trace: TraceMiniature.make(from: trace?.samples.map(\.point) ?? points)
        )
    }
}

#endif
