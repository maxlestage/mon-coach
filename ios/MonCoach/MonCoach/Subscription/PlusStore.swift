import Foundation
import StoreKit
import MonCoachKit

/// L'abonnement Stride+, vu depuis l'App Store.
///
/// Pourquoi ce type existe
/// -----------------------
/// C'est la seule partie du produit qui ne peut pas vivre dans le moteur :
/// StoreKit n'existe que dans l'application, et le droit d'accès ne se
/// décide ni dans un fichier local ni dans un réglage — il se constate
/// auprès d'Apple. Le magasin ne fait donc que constater, puis déposer sa
/// réponse dans `CoachStore`, où tous les écrans lisent la même chose.
///
/// Rien n'est stocké sur le disque. Un droit d'accès écrit dans l'état
/// serait un droit qu'on peut s'accorder soi-même en modifiant un fichier,
/// et l'application se vante par ailleurs de laisser l'athlète maître de
/// ses données : les deux ne tiennent pas ensemble. StoreKit répond en une
/// fraction de seconde au lancement, et hors ligne il rend le dernier état
/// connu de l'appareil, ce qui est exactement le comportement voulu.
@MainActor
@Observable
final class PlusStore {

    /// Les identifiants déclarés dans App Store Connect.
    enum Offer: String, CaseIterable {
        case monthly = "com.maxlestage.fitnesscoach.plus.monthly"
        case yearly = "com.maxlestage.fitnesscoach.plus.yearly"
    }

    /// Les offres chargées, dans l'ordre d'affichage : le mois d'abord,
    /// l'année ensuite — c'est l'ordre dans lequel on hésite.
    private(set) var products: [Product] = []
    /// Vrai quand un abonnement est actif, essai App Store compris.
    private(set) var isSubscribed = false
    /// Vrai pendant un achat, pour que le bouton cesse de répondre.
    private(set) var isPurchasing = false
    /// Le dernier échec, à montrer une fois puis à oublier.
    var lastError: String?

    private var updates: Task<Void, Never>?

    init() {
        // La file des transactions doit être écoutée dès le lancement, et
        // pour toute la vie de l'application : un renouvellement, un
        // remboursement ou un achat fait sur un autre appareil arrivent par
        // là, et jamais autrement.
        //
        // Rien ne l'annule au `deinit` : celui-ci s'exécute hors du main
        // actor et n'a donc pas le droit de toucher à cette propriété. La
        // boucle s'arrête d'elle-même — elle ne retient pas le magasin, et
        // la première transaction reçue après sa disparition la termine.
        updates = Task { [weak self] in
            for await update in Transaction.updates {
                guard let self else { return }
                if case .verified(let transaction) = update {
                    await transaction.finish()
                }
                await self.refresh()
            }
        }
    }

    /// Charge les offres et l'état de l'abonnement.
    func load() async {
        await refresh()
        do {
            let loaded = try await Product.products(for: Offer.allCases.map(\.rawValue))
            // L'ordre d'App Store Connect n'est pas garanti : on impose le
            // nôtre plutôt que d'afficher l'année avant le mois un jour sur
            // deux.
            products = Offer.allCases.compactMap { wanted in
                loaded.first { $0.id == wanted.rawValue }
            }
        } catch {
            // Sans réseau, il n'y a rien à afficher et rien à dire : le
            // paywall montre alors ce qui est offert, sans prix. Une erreur
            // technique à cet endroit n'apprendrait rien à personne.
            products = []
        }
    }

    /// Relit ce qu'Apple dit des droits en cours.
    func refresh() async {
        var active = false
        for await entitlement in Transaction.currentEntitlements {
            guard case .verified(let transaction) = entitlement else { continue }
            guard Offer(rawValue: transaction.productID) != nil else { continue }
            // Une transaction révoquée — remboursement, litige — ne donne
            // plus accès : `revocationDate` est la seule façon de le savoir.
            if transaction.revocationDate == nil { active = true }
        }
        isSubscribed = active
    }

    /// Achète, et rend vrai si l'abonnement est actif au bout.
    @discardableResult
    func purchase(_ product: Product) async -> Bool {
        guard !isPurchasing else { return false }
        isPurchasing = true
        lastError = nil
        defer { isPurchasing = false }
        do {
            switch try await product.purchase() {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                }
                await refresh()
                return isSubscribed
            case .userCancelled:
                // Renoncer n'est pas une erreur, et ne mérite pas d'alerte.
                return false
            case .pending:
                lastError = "L'achat attend une validation — celle d'un parent, le plus souvent. Il s'activera tout seul une fois accordée."
                return false
            @unknown default:
                return false
            }
        } catch {
            lastError = error.localizedDescription
            return false
        }
    }

    /// Rend les achats déjà faits, sur un nouvel appareil ou après une
    /// réinstallation.
    ///
    /// Apple l'exige, et c'est de toute façon la moindre des choses : un
    /// abonnement payé se retrouve sans avoir à repayer.
    func restore() async {
        do {
            try await AppStore.sync()
        } catch {
            lastError = error.localizedDescription
        }
        await refresh()
    }

    /// L'offre annuelle rapportée au mois, pour dire l'économie sans mentir.
    func monthlyEquivalent(of product: Product) -> String? {
        guard product.id == Offer.yearly.rawValue else { return nil }
        return product.priceFormatStyle.format(product.price / 12)
    }
}
