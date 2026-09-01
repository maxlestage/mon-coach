import StoreKit
import SwiftUI
import MonCoachKit

/// L'écran d'abonnement.
///
/// Pourquoi il est écrit comme ça
/// ------------------------------
/// Un paywall qui ne dit que ce qu'on gagne à payer est un argumentaire ;
/// celui-ci dit aussi, et avec la même taille de caractères, ce qu'on garde
/// en ne payant pas. C'est la seule façon de rendre le choix libre, et
/// c'est cohérent avec le reste du produit : l'historique et l'export
/// restent gratuits, y compris le jour où l'on part.
///
/// Aucun compte à créer, aucune adresse à donner : l'achat passe par
/// l'App Store, qui sait déjà qui paie. C'est la même promesse que le reste
/// de l'application — rien ne quitte le téléphone qui n'ait à en sortir.
struct PaywallView: View {
    /// La fonctionnalité qui a amené ici, quand on y arrive par une porte
    /// fermée plutôt que par les réglages.
    var reason: PlusFeature?

    @Environment(CoachStore.self) private var store
    @Environment(PlusStore.self) private var plus
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var showsError = false

    private var daysLeft: Int { store.subscription.trialDaysLeft() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    headerCard
                    if !plus.products.isEmpty { offersCard }
                    featuresCard
                    freeCard
                    footerCard
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle("Stride+")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .task { await plus.load() }
            .onChange(of: plus.isSubscribed) { _, subscribed in
                store.setSubscribed(subscribed)
                if subscribed { dismiss() }
            }
            .onChange(of: plus.lastError) { _, error in
                showsError = error != nil
            }
            .alert(
                LocalizedText(
                    fr: "L'achat n'a pas abouti",
                    en: "The purchase did not go through",
                    es: "La compra no se ha completado"
                )[language],
                isPresented: $showsError
            ) {
                Button("OK", role: .cancel) { plus.lastError = nil }
            } message: {
                Text(plus.lastError ?? "")
            }
        }
    }

    // MARK: - En-tête

    private var headerCard: some View {
        Card(
            title: reason?.label[language]
                ?? LocalizedText(fr: "Stride+", en: "Stride+", es: "Stride+")[language],
            subtitle: reason?.detail[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                if daysLeft > 0 && !store.subscription.isSubscribed {
                    // Pendant l'essai, on ne vend pas : on rappelle qu'il
                    // reste du temps. Presser quelqu'un qui a encore neuf
                    // jours devant lui est la meilleure façon de le faire
                    // partir avant.
                    Text(
                        LocalizedText(
                            fr: "Il te reste \(daysLeft) jour\(daysLeft > 1 ? "s" : "") d'essai. Tout est déjà ouvert : tu n'as rien à faire aujourd'hui.",
                            en: "You have \(daysLeft) day\(daysLeft > 1 ? "s" : "") of trial left. Everything is already unlocked: there is nothing to do today.",
                            es: "Te quedan \(daysLeft) día\(daysLeft > 1 ? "s" : "") de prueba. Todo está ya abierto: hoy no tienes que hacer nada."
                        )[language]
                    )
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.accent)
                } else {
                    CoachText(
                        LocalizedText(
                            fr: "Tes quatorze jours sont passés. Ton bloc en cours, ton historique et tes repas du jour continuent — Stride+ rouvre le reste.",
                            en: "Your fourteen days are up. Your current block, your history and your daily meals carry on — Stride+ reopens the rest.",
                            es: "Tus catorce días han terminado. Tu bloque actual, tu historial y tus comidas del día siguen — Stride+ reabre el resto."
                        )
                    )
                }
            }
        }
    }

    // MARK: - Les offres

    private var offersCard: some View {
        Card(
            subtitle: LocalizedText(
                fr: "Sans compte à créer. Résiliable à tout moment dans les réglages Apple.",
                en: "No account to create. Cancel any time in your Apple settings.",
                es: "Sin cuenta que crear. Cancelable en cualquier momento en los ajustes de Apple."
            )[language]
        ) {
            VStack(spacing: 10) {
                ForEach(plus.products, id: \.id) { product in
                    Button {
                        Task { await plus.purchase(product) }
                    } label: {
                        HStack(spacing: 10) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(product.displayName)
                                    .font(Theme.headlineFont)
                                    .foregroundStyle(Theme.primaryText)
                                if let perMonth = plus.monthlyEquivalent(of: product) {
                                    Text(
                                        LocalizedText(
                                            fr: "soit \(perMonth) par mois",
                                            en: "that is \(perMonth) a month",
                                            es: "es decir \(perMonth) al mes"
                                        )[language]
                                    )
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.accent)
                                }
                            }
                            Spacer()
                            Text(product.displayPrice)
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.primaryText)
                        }
                        .padding(14)
                        .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(Theme.accent.opacity(0.4), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(plus.isPurchasing)
                }

                Button {
                    Task { await plus.restore() }
                } label: {
                    Text(
                        LocalizedText(
                            fr: "Restaurer un achat",
                            en: "Restore a purchase",
                            es: "Restaurar una compra"
                        )[language]
                    )
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Ce que Stride+ ouvre

    private var featuresCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que Stride+ ouvre",
                en: "What Stride+ opens",
                es: "Lo que abre Stride+"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(PlusFeature.allCases) { feature in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Theme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.label[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Text(feature.detail[language])
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Ce qui reste gratuit

    private var freeCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce qui reste gratuit, quoi qu'il arrive",
                en: "What stays free, whatever happens",
                es: "Lo que sigue siendo gratis, pase lo que pase"
            )[language],
            subtitle: AlwaysFree.hostageClause[language]
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(AlwaysFree.promises, id: \.self) { promise in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "infinity")
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 16)
                        Text(promise[language])
                            .font(.system(size: 13))
                            .foregroundStyle(Theme.primaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var footerCard: some View {
        Card {
            CoachText(
                LocalizedText(
                    fr: "À titre de comparaison : une seule séance avec un coach humain coûte plus cher que l'année entière. Jamais de publicité, jamais de revente de données — il n'y a même pas de serveur pour les recevoir.",
                    en: "For comparison: a single session with a human coach costs more than the entire year. Never any advertising, never any data resale — there is not even a server to receive it.",
                    es: "A modo de comparación: una sola sesión con un entrenador humano cuesta más que el año entero. Nunca publicidad, nunca reventa de datos: ni siquiera hay un servidor que los reciba."
                ),
                font: .system(size: 12)
            )
        }
    }
}

/// La porte fermée : ce qu'on met à la place d'une fonctionnalité qui
/// demande Stride+.
///
/// Une carte, jamais un écran vide ni un bouton mort. Elle dit ce qui
/// manque, pourquoi, et ce qui continue de marcher sans payer.
struct PlusLockedCard: View {
    var feature: PlusFeature

    @Environment(\.language) private var language
    @State private var showsPaywall = false

    var body: some View {
        Card(title: feature.label[language]) {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(feature.detail)
                Button {
                    showsPaywall = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text(
                            LocalizedText(
                                fr: "Voir Stride+",
                                en: "See Stride+",
                                es: "Ver Stride+"
                            )[language]
                        )
                        .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Theme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(Theme.accent, in: RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showsPaywall) {
            PaywallView(reason: feature)
        }
    }
}
