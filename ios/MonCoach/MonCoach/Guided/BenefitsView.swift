import SwiftUI
import MonCoachKit

/// Ce que l'application apporte, avec ce qui rend chaque promesse vraie.
///
/// Pourquoi une promesse ne suffit pas
/// -----------------------------------
/// « Un coach qui s'adapte à toi » ne veut rien dire : toutes les
/// applications l'écrivent, et la moitié se contente de multiplier un chiffre
/// par le poids de l'athlète. Chaque avantage porte donc son mécanisme,
/// chiffré quand il l'est, tel qu'il est écrit dans le moteur.
///
/// Et la moitié qu'aucune page de vente ne met est ici aussi : ce que
/// l'application refuse de faire. C'est ce qui évite qu'on lui reproche plus
/// tard une promesse qu'elle n'a jamais faite.
struct BenefitsView: View {
    /// Vrai quand l'écran est poussé depuis un guide : la barre du haut a
    /// déjà son bouton de retour, un « Fermer » en plus ferait deux portes
    /// pour le même geste.
    var embedded = false

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var showsPaywall = false

    var body: some View {
        Group {
            if embedded {
                content
            } else {
                NavigationStack { content }
            }
        }
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                introCard
                ForEach(Benefits.all) { benefit in
                    benefitCard(benefit)
                }
                freeCard
                plusCard
                refusalsCard
                creditCard
            }
            .padding(16)
        }
        .screenBackground()
        .navigationTitle(
            LocalizedText(
                fr: "Ce que ça t'apporte",
                en: "What it brings you",
                es: "Lo que te aporta"
            )[language]
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !embedded {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showsPaywall) {
            PaywallView()
        }
    }

    private var introCard: some View {
        Card {
            CoachText(
                LocalizedText(
                    fr: "Chaque promesse est suivie de ce qui la rend vraie. Une phrase sans mécanisme derrière est une phrase de publicité, et tu t'en apercevrais au premier écran qui ne suit pas.",
                    en: "Every promise is followed by what makes it true. A sentence with no mechanism behind it is an advertising line, and you would notice at the first screen that fell short.",
                    es: "Cada promesa va seguida de lo que la hace cierta. Una frase sin mecanismo detrás es publicidad, y lo notarías en la primera pantalla que no cumpliera."
                ),
                color: Theme.primaryText
            )
        }
    }

    private func benefitCard(_ benefit: Benefit) -> some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: benefit.symbol)
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 22)
                    Text(benefit.title[language])
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                }
                CoachText(benefit.promise, color: Theme.primaryText)

                // La preuve, visuellement en retrait : c'est le détail qu'on
                // lit quand on doute, pas la phrase qu'on lit en diagonale.
                HStack(alignment: .top, spacing: 8) {
                    Rectangle()
                        .fill(Theme.accent.opacity(0.4))
                        .frame(width: 2)
                    CoachText(benefit.proof, font: .system(size: 12))
                }

                if let section = benefit.section {
                    Text(
                        LocalizedText(
                            fr: "Ça se voit dans « \(section.title[.french]) »",
                            en: "You see it in “\(section.title[.english])”",
                            es: "Se ve en «\(section.title[.spanish])»"
                        )[language]
                    )
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.secondaryText)
                }
            }
        }
    }

    /// Ce qui reste gratuit, quoi qu'il arrive.
    private var freeCard: some View {
        Card(
            title: LocalizedText(
                fr: "Gratuit, à vie", en: "Free, for life", es: "Gratis, de por vida"
            )[language],
            subtitle: LocalizedText(
                fr: "Même le jour où tu arrêtes de payer.",
                en: "Even the day you stop paying.",
                es: "Incluso el día que dejes de pagar."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(AlwaysFree.promises.enumerated()), id: \.offset) { _, promise in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 14)
                        CoachText(promise, font: .system(size: 13), color: Theme.primaryText)
                    }
                }
            }
            CoachText(AlwaysFree.hostageClause, font: .system(size: 12))
        }
    }

    /// Ce que Stride+ ouvre, et où en est l'athlète.
    private var plusCard: some View {
        let status = store.subscription
        return Card(
            title: "Stride+",
            subtitle: status.banner()?[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(PlusFeature.allCases) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 14)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(feature.label[language])
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Theme.primaryText)
                            CoachText(feature.detail, font: .system(size: 12))
                        }
                    }
                }
            }
            // Le bouton n'apparaît qu'à quelqu'un qui n'a pas déjà tout :
            // proposer d'acheter à un abonné est le genre de détail qui fait
            // douter du reste de l'écran.
            if !status.isUnlocked(.weeklyReview) {
                PrimaryButton(
                    title: LocalizedText(
                        fr: "Voir les formules", en: "See the plans", es: "Ver los planes"
                    )[language],
                    systemImage: "sparkles"
                ) {
                    showsPaywall = true
                }
            }
        }
    }

    /// Ce que l'application refuse de faire.
    private var refusalsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce qu'elle ne fera pas",
                en: "What it will not do",
                es: "Lo que no hará"
            )[language],
            subtitle: LocalizedText(
                fr: "La moitié qu'aucune page de vente ne met.",
                en: "The half no sales page ever includes.",
                es: "La mitad que ninguna página de venta incluye."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(Benefits.refusals.enumerated()), id: \.offset) { _, refusal in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Theme.danger)
                            .frame(width: 14)
                        CoachText(refusal, font: .system(size: 13), color: Theme.primaryText)
                    }
                }
            }
        }
    }

    private var creditCard: some View {
        Card {
            Text(
                LocalizedText(
                    fr: "Conçu et développé par Maxime Nathan Lestage",
                    en: "Designed and developed by Maxime Nathan Lestage",
                    es: "Diseñado y desarrollado por Maxime Nathan Lestage"
                )[language]
            )
            .font(.system(size: 12))
            .foregroundStyle(Theme.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
