import SwiftUI
import MonCoachKit

/// La fiche qui s'affiche entre deux onglets.
///
/// Ce qu'elle fait
/// ---------------
/// Changer d'onglet est le geste le plus fréquent de l'application, et le
/// seul que le système ne mette pas en scène : l'écran est remplacé d'un
/// coup, sans dire par quoi. La fiche le dit — le symbole, le nom, et la
/// phrase qui résume ce que l'écran fait — le temps d'une demi-seconde,
/// puis se retire pendant que les cartes arrivent en cascade derrière elle.
///
/// Pourquoi elle est courte, et pourquoi elle s'écarte au doigt
/// ------------------------------------------------------------
/// Une fiche de deux secondes serait une punition à chaque changement
/// d'onglet, et c'est précisément le genre d'écran qu'on finit par haïr.
/// Une demi-seconde suffit pour lire trois mots ; et celui qui a déjà lu
/// l'écarte d'un appui, où qu'il touche.
struct SectionSplashView: View {
    var section: AppSection
    var dismiss: () -> Void

    @Environment(\.language) private var language
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var shown = false
    @State private var bounced = false

    private var guide: SectionGuide { SectionGuides.guide(for: section) }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: section.symbol)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 96, height: 96)
                    .background(Theme.accentMuted, in: Circle())
                    .symbolEffect(.bounce, value: bounced)

                Text(section.title[language])
                    .font(Theme.titleFont)
                    .foregroundStyle(Theme.primaryText)

                Text(guide.tagline[language])
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: 300)
            }
            .padding(.horizontal, 32)
            .opacity(shown ? 1 : 0)
            .scaleEffect(shown || reduceMotion ? 1 : 0.94)
        }
        .contentShape(Rectangle())
        .onTapGesture { dismiss() }
        .onAppear {
            withAnimation(reduceMotion ? Motion.plain : Motion.snap) { shown = true }
            // Le rebond part une fois la fiche posée, pas pendant qu'elle
            // arrive : deux mouvements en même temps s'annulent à l'œil.
            if !reduceMotion {
                Task {
                    try? await Task.sleep(for: .milliseconds(120))
                    bounced = true
                }
            }
        }
        .accessibilityAddTraits(.isModal)
    }
}
