import Foundation

/// Une paire de chaussures ou un vélo, et ce qu'on leur a fait subir.
///
/// Pourquoi ce type existe
/// -----------------------
/// Une paire de chaussures de course meurt vers 600 à 800 kilomètres, et
/// elle meurt en silence : la mousse rend l'âme bien avant la semelle, et
/// les douleurs arrivent avant qu'on pense à regarder. La seule défense est
/// de compter — et le téléphone compte déjà chaque sortie.
///
/// Le kilométrage n'est jamais stocké sur le matériel : il se recalcule à
/// chaque lecture depuis les activités qui portent son identifiant. Un
/// compteur stocké finirait par mentir — une sortie supprimée, un import en
/// double — alors que la somme des sorties est vraie par construction.
public struct Gear: Codable, Sendable, Equatable, Identifiable, Hashable {
    public enum Kind: String, Codable, Sendable, CaseIterable {
        case shoes
        case bike

        public var label: LocalizedText {
            switch self {
            case .shoes: LocalizedText(fr: "Chaussures", en: "Shoes", es: "Zapatillas")
            case .bike: LocalizedText(fr: "Vélo", en: "Bike", es: "Bicicleta")
            }
        }

        /// Les sports que ce matériel équipe. C'est lui qui décide quel
        /// matériel se propose au bout d'une sortie.
        /// Déduit du catalogue des sports plutôt qu'écrit ici : deux
        /// listes tenues séparément finiraient par ne plus s'accorder, et
        /// un vélo de gravel ne se proposerait jamais au bout d'un gravel.
        public var sports: Set<Sport> {
            Set(Sport.allCases.filter { $0.gearKinds.contains(self) })
        }

        /// Le seuil d'usure au-delà duquel on prévient, en mètres.
        ///
        /// 650 km pour des chaussures : le milieu de la fourchette où la
        /// mousse cesse d'amortir. Rien pour un vélo — il s'entretient, il
        /// ne s'use pas à date fixe.
        public var wearThresholdMeters: Double? {
            switch self {
            case .shoes: 650_000
            case .bike: nil
            }
        }
    }

    public var id: UUID
    public var name: String
    public var kind: Kind
    /// La date de mise à la retraite. Un matériel retraité garde son
    /// histoire — les sorties faites avec ne changent pas de chaussures —
    /// mais ne se propose plus pour les suivantes.
    public var retiredAt: Date?

    public init(id: UUID = UUID(), name: String, kind: Kind, retiredAt: Date? = nil) {
        self.id = id
        self.name = name
        self.kind = kind
        self.retiredAt = retiredAt
    }

    public var isRetired: Bool { retiredAt != nil }

    public func suits(_ sport: Sport) -> Bool {
        kind.sports.contains(sport)
    }
}

/// Les questions qu'on pose au matériel, résolues depuis l'historique.
public enum GearTracker {

    /// Les mètres parcourus avec ce matériel, recalculés depuis les sorties.
    public static func meters(for gearID: UUID, in activities: [ActivityLog]) -> Double {
        activities.filter { $0.gearID == gearID }.reduce(0) { $0 + $1.meters }
    }

    /// Le nombre de sorties faites avec ce matériel.
    public static func activityCount(for gearID: UUID, in activities: [ActivityLog]) -> Int {
        activities.count { $0.gearID == gearID }
    }

    /// Le matériel usé au-delà de son seuil, à remplacer bientôt.
    public static func isWorn(_ gear: Gear, in activities: [ActivityLog]) -> Bool {
        guard let threshold = gear.kind.wearThresholdMeters else { return false }
        return meters(for: gear.id, in: activities) >= threshold
    }

    /// Le matériel à proposer pour une sortie de ce sport : le plus
    /// récemment utilisé parmi les actifs qui conviennent, ou le plus
    /// récemment créé si aucun n'a encore servi.
    ///
    /// « Le dernier utilisé » plutôt qu'un réglage « par défaut » : c'est ce
    /// que l'athlète fait déjà — on court presque toujours avec les mêmes
    /// chaussures, jusqu'au jour où on change, et ce jour-là le choix suit
    /// tout seul.
    public static func suggested(
        for sport: Sport,
        among gear: [Gear],
        activities: [ActivityLog]
    ) -> Gear? {
        let candidates = gear.filter { !$0.isRetired && $0.suits(sport) }
        guard !candidates.isEmpty else { return nil }

        let lastUse = Dictionary(
            grouping: activities.filter { $0.gearID != nil },
            by: { $0.gearID! }
        ).mapValues { $0.map(\.startedAt).max() ?? .distantPast }

        return candidates.max { left, right in
            let l = lastUse[left.id] ?? .distantPast
            let r = lastUse[right.id] ?? .distantPast
            return l == r ? left.name > right.name : l < r
        }
    }
}
