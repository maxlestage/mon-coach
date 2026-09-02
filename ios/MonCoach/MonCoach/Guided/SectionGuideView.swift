import SwiftUI
import MonCoachKit

/// Le mode d'emploi d'un écran, ouvert depuis cet écran.
///
/// Pourquoi il existe
/// ------------------
/// Une application d'entraînement est une suite d'écrans qui prescrivent des
/// chiffres. Un chiffre prescrit sans qu'on sache d'où il vient ne se suit
/// pas longtemps : à la première séance qui pique, on décide que le coach
/// s'est trompé — et on a raison de le décider si personne n'a jamais
/// expliqué le calcul.
///
/// Le guide est donc à un appui de l'écran qu'il explique, jamais dans un
/// menu d'aide séparé. Une explication qu'il faut aller chercher n'est pas
/// lue, et c'est exactement au moment où l'on ne comprend pas un écran qu'on
/// a besoin de savoir ce qu'il fait.
struct SectionGuideView: View {
    var section: AppSection

    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    private var guide: SectionGuide { SectionGuides.guide(for: section) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    headerCard
                    stepsCard
                    engineCard
                    limitsCard
                    benefitsLink
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(guide.section.title[language])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }

    private var headerCard: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: guide.section.symbol)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.accent)
                CoachText(guide.tagline, font: Theme.headlineFont, color: Theme.primaryText)
            }
        }
    }

    /// Ce qu'on fait, et ce que ça déclenche.
    ///
    /// Le geste et sa conséquence sur la même ligne : « réponds au check-in »
    /// ne dit rien, « réponds au check-in et la séance est réajustée avant
    /// que tu la commences » dit pourquoi ça vaut trente secondes.
    private var stepsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce qu'on y fait", en: "What you do here", es: "Qué se hace aquí"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(guide.steps) { step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(step.index)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.background)
                            .frame(width: 22, height: 22)
                            .background(Theme.accent, in: Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            CoachText(step.action, font: Theme.bodyFont, color: Theme.primaryText)
                            CoachText(step.result, font: .system(size: 13))
                        }
                    }
                }
            }
        }
    }

    /// Ce qui tourne derrière, sans métaphore.
    private var engineCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce qui tourne derrière",
                en: "What runs behind it",
                es: "Lo que funciona detrás"
            )[language],
            subtitle: LocalizedText(
                fr: "La règle exacte, pas une image.",
                en: "The exact rule, not a metaphor.",
                es: "La regla exacta, no una metáfora."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(guide.engine.enumerated()), id: \.offset) { _, text in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.accent)
                            .frame(width: 16)
                        CoachText(text, font: .system(size: 13), color: Theme.primaryText)
                    }
                }
            }
        }
    }

    /// Ce que la section ne fait pas.
    ///
    /// C'est la carte qu'aucune application ne met, et c'est celle qui évite
    /// qu'on reproche plus tard une promesse jamais faite.
    private var limitsCard: some View {
        Card(
            title: LocalizedText(
                fr: "Ce que ça ne fait pas",
                en: "What it does not do",
                es: "Lo que no hace"
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(guide.limits.enumerated()), id: \.offset) { _, text in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "minus.circle")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.warning)
                            .frame(width: 16)
                        CoachText(text, font: .system(size: 13), color: Theme.primaryText)
                    }
                }
            }
        }
    }

    private var benefitsLink: some View {
        NavigationLink {
            BenefitsView(embedded: true)
        } label: {
            Card {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.accent)
                    Text(
                        LocalizedText(
                            fr: "Tout ce que l'application apporte",
                            en: "Everything the app brings you",
                            es: "Todo lo que aporta la aplicación"
                        )[language]
                    )
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// Le point d'interrogation qui ouvre le guide d'une section.
struct SectionGuideButton: View {
    var section: AppSection

    @State private var showsGuide = false

    var body: some View {
        Button {
            showsGuide = true
        } label: {
            Image(systemName: "questionmark.circle")
        }
        .sheet(isPresented: $showsGuide) {
            SectionGuideView(section: section)
        }
    }
}

extension View {
    /// Pose le guide de la section dans la barre du haut.
    ///
    /// Un modificateur plutôt que six copies du même bouton : six copies
    /// finissent par diverger, et c'est toujours celle qu'on oublie qui
    /// manque à l'écran où l'on comprend le moins.
    func sectionGuide(_ section: AppSection) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                SectionGuideButton(section: section)
            }
        }
        // Le même appel dit aussi aux cartes de l'écran à quel onglet elles
        // appartiennent, pour qu'elles rejouent leur arrivée quand on le
        // choisit. Un seul endroit à écrire par écran, donc un seul à
        // oublier — et il est déjà là.
        .appSection(section)
    }
}
