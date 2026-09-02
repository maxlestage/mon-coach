import SwiftUI
import MonCoachKit

/// Le vocabulaire du mouvement, au même endroit que celui des couleurs.
///
/// À quoi sert une animation ici
/// -----------------------------
/// Pas à décorer. Une application d'entraînement affiche des chiffres qui
/// changent — un score de forme, un tonnage, un poids de corps — et un
/// chiffre qui change d'un coup ne se remarque pas. Le mouvement est ce qui
/// dit « ça, ça vient de bouger », et il n'a aucune autre raison d'exister.
///
/// D'où trois règles tenues partout dans le fichier :
///
/// 1. **Une animation d'arrivée se joue quand on arrive.** Quand on choisit
///    l'onglet, donc, et pas quand on revient d'une feuille posée dessus :
///    la première est une navigation, la seconde un retour au même endroit,
///    et une carte qui refait son entrée à chaque aller-retour est une
///    carte qui clignote.
/// 2. **Une animation d'état se joue quand l'état change**, jamais « en
///    boucle pour faire joli ». Une pastille qui pulse en permanence apprend
///    surtout à ne plus la regarder.
/// 3. **Tout se coupe si le téléphone demande moins de mouvement.** Ce n'est
///    pas une politesse : pour une partie des gens, le glissement qui nous
///    plaît donne mal au cœur. Le réglage existe, on le respecte, et la
///    version sans mouvement reste lisible — elle n'est pas une version
///    dégradée.
enum Motion {

    // MARK: Les courbes

    /// L'arrivée d'une carte : ferme, à peine rebondie.
    static let entrance = Animation.spring(duration: 0.42, bounce: 0.16)

    /// Un chiffre ou une barre qui se met à jour. Plus longue, sans rebond :
    /// on veut lire la valeur d'arrivée, pas la regarder osciller.
    static let settle = Animation.spring(duration: 0.55, bounce: 0.05)

    /// Une réponse au doigt : ouverture, bascule, sélection.
    static let snap = Animation.spring(duration: 0.26, bounce: 0.28)

    /// Le repli sans mouvement, quand le téléphone demande moins d'animation.
    /// Un fondu reste : il dit que quelque chose a changé sans rien déplacer.
    static let plain = Animation.easeInOut(duration: 0.22)

    // MARK: La fiche entre deux onglets

    /// Le temps pendant lequel la fiche d'un onglet reste posée avant de se
    /// retirer. Les cartes de l'écran attendent ce délai avant d'arriver :
    /// elles entrent pendant que la fiche s'efface, pas derrière elle.
    static let splashHold: Double = 0.55

    // MARK: La cascade

    /// Le délai de la carte à cette position, borné par le moteur.
    static func delay(forCardAt index: Int) -> Double {
        MotionTiming.delay(forCardAt: index)
    }

    /// Remet une vue à son état de départ sans animation, puis la fait
    /// repartir au tour de boucle suivant.
    ///
    /// Les deux changements ne peuvent pas se faire dans la même passe :
    /// SwiftUI ne rend que l'état final, et « faux puis vrai » dans une
    /// même passe est « vrai », sans rien à animer. Le retour à zéro doit
    /// être dessiné une image avant le départ.
    @MainActor
    static func replay(_ reset: () -> Void, then restart: @escaping @MainActor () -> Void) {
        var still = Transaction()
        still.disablesAnimations = true
        withTransaction(still) { reset() }
        // Le bloc part après le passage de rendu en cours : la vue est
        // dessinée à zéro, puis l'animation la ramène. Un `Task` ferait
        // pareil ; la file principale est simplement plus explicite sur le
        // moment où ça part.
        DispatchQueue.main.async {
            MainActor.assumeIsolated { restart() }
        }
    }
}

// MARK: - Savoir quand on arrive sur un onglet

/// L'onglet auquel une vue appartient, posé par `.sectionGuide(_:)`.
private struct AppSectionKey: EnvironmentKey {
    static let defaultValue: AppSection? = nil
}

/// L'onglet affiché en ce moment, posé par la vue racine.
private struct SelectedSectionKey: EnvironmentKey {
    static let defaultValue: AppSection? = nil
}

extension EnvironmentValues {
    var appSection: AppSection? {
        get { self[AppSectionKey.self] }
        set { self[AppSectionKey.self] = newValue }
    }

    var selectedSection: AppSection? {
        get { self[SelectedSectionKey.self] }
        set { self[SelectedSectionKey.self] = newValue }
    }
}

/// Appelle l'action chaque fois que l'onglet de la vue est choisi.
///
/// Pourquoi ce n'est pas `onAppear` : dans une barre d'onglets, les écrans
/// restent vivants une fois visités. Revenir dessus ne les recrée pas, et
/// selon la version du système `onAppear` se rappelle ou non. La sélection
/// de l'onglet, elle, change à coup sûr — c'est le seul signal fiable pour
/// dire « on vient d'arriver ici ».
private struct OnTabSelected: ViewModifier {
    var action: () -> Void

    @Environment(\.appSection) private var section
    @Environment(\.selectedSection) private var selected

    func body(content: Content) -> some View {
        content.onChange(of: selected) { _, now in
            guard let section, now == section else { return }
            action()
        }
    }
}

extension View {
    /// Déclare à quel onglet la vue appartient.
    func appSection(_ section: AppSection) -> some View {
        environment(\.appSection, section)
    }

    /// Rejoue quelque chose chaque fois qu'on arrive sur l'onglet.
    func onTabSelected(_ action: @escaping () -> Void) -> some View {
        modifier(OnTabSelected(action: action))
    }
}

// MARK: - L'arrivée d'une carte

/// Fait arriver une vue en fondu, légèrement soulevée, à son tour.
///
/// Le décalage vertical est petit exprès (12 points). Une carte qui monte de
/// cinquante points donne l'impression que l'écran se construit devant soi ;
/// une carte qui monte de douze donne l'impression qu'elle était déjà là et
/// qu'on vient de la voir. C'est la seconde qu'on veut.
private struct Appears: ViewModifier {
    var index: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            // Le décalage et l'échelle ne s'appliquent jamais en mouvement
            // réduit : il ne reste que le fondu.
            .offset(y: shown || reduceMotion ? 0 : 12)
            .scaleEffect(shown || reduceMotion ? 1 : 0.985, anchor: .top)
            .onAppear {
                // Pas au retour d'une feuille : `onAppear` se rappelle
                // alors, et une carte qui réapparaît en fondu à chaque
                // aller-retour est une carte qui clignote.
                guard !shown else { return }
                enter()
            }
            // Mais bien à chaque fois qu'on choisit l'onglet : c'est là
            // qu'on « navigue », et c'est là qu'une arrivée se lit comme
            // une arrivée.
            .onTabSelected {
                guard shown else { return }
                Motion.replay { shown = false } then: { enter(after: Motion.splashHold) }
            }
    }

    /// - Parameter lead: un temps mort avant la cascade — celui de la fiche
    ///   d'onglet, quand on arrive par la barre du bas.
    private func enter(after lead: Double = 0) {
        withAnimation(
            (reduceMotion ? Motion.plain : Motion.entrance)
                .delay(lead + Motion.delay(forCardAt: index))
        ) {
            shown = true
        }
    }
}

/// Fait entrer et sortir une vue du champ pendant qu'on défile.
///
/// Ce que ça remplace : rien. Sans elle, une liste longue est une liste
/// plate, et rien ne distingue la carte qu'on regarde de celle qui sort par
/// le bas. Le fondu léger des bords donne la profondeur qu'un écran de
/// téléphone n'a pas.
private struct RevealsOnScroll: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            // Interactif : la carte suit le doigt, elle ne part pas toute
            // seule une fois le seuil franchi. C'est ce qui la fait sentir
            // posée sur l'écran plutôt que projetée dessus.
            content.scrollTransition(.interactive) { view, phase in
                view
                    .opacity(phase.isIdentity ? 1 : 0.35)
                    .scaleEffect(phase.isIdentity ? 1 : 0.96, anchor: .center)
            }
        }
    }
}

extension View {
    /// Pose l'arrivée en cascade sur une carte, à sa place dans la pile.
    ///
    /// L'indice est écrit à la main plutôt que deviné : une pile de cartes
    /// n'est pas une liste, elle est une suite de vues différentes, et rien
    /// dans SwiftUI ne permet de les compter de l'extérieur. Le déclarer
    /// coûte un chiffre par carte et rend l'ordre lisible dans le corps de
    /// l'écran, ce qui vaut mieux qu'une magie qui se trompe.
    func appears(_ index: Int) -> some View {
        modifier(Appears(index: index))
    }

    /// Fait respirer la vue quand elle traverse le champ pendant le défilement.
    func revealsOnScroll() -> some View {
        modifier(RevealsOnScroll())
    }
}

// MARK: - Un chiffre qui bouge

/// Un nombre qui roule vers sa nouvelle valeur au lieu de la remplacer.
///
/// `contentTransition(.numericText)` fait défiler les chiffres comme un
/// compteur mécanique. C'est exactement le geste qu'on veut pour un tonnage
/// ou un poids : on voit *dans quel sens* ça a bougé, ce qu'un remplacement
/// sec ne dit pas.
struct RollingNumber: View {
    var value: Double
    var text: String
    var font: Font = .system(size: 22, weight: .bold, design: .rounded)
    var color: Color = Theme.accent

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(color)
            .contentTransition(reduceMotion ? .identity : .numericText(value: value))
            .animation(reduceMotion ? nil : Motion.settle, value: value)
    }
}

// MARK: - Un anneau qui se dessine

/// L'anneau du score de forme, qui se trace au lieu d'apparaître plein.
///
/// Un anneau déjà rempli à l'ouverture est un dessin. Un anneau qui se trace
/// est une mesure : on suit le trait, donc on lit la proportion, et c'est
/// tout l'intérêt d'un anneau par rapport à un chiffre — qu'il en existe
/// déjà un au centre.
struct ScoreRing: View {
    var score: Int
    var tint: Color
    var lineWidth: CGFloat = 8

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drawn = false

    private var fraction: Double { min(1, max(0, Double(score) / 100)) }

    var body: some View {
        ZStack {
            Circle().stroke(Theme.surfaceRaised, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: drawn ? fraction : 0)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            RollingNumber(
                value: Double(score),
                text: "\(score)",
                font: .system(size: 20, weight: .bold, design: .rounded),
                color: Theme.primaryText
            )
        }
        .onAppear {
            guard !drawn else { return }
            draw()
        }
        .onTabSelected {
            guard drawn, !reduceMotion else { return }
            Motion.replay { drawn = false } then: { draw(after: Motion.splashHold) }
        }
        // Le score change quand on refait le check-in du jour : l'anneau
        // suit, sans se retracer depuis zéro.
        .animation(reduceMotion ? nil : Motion.settle, value: score)
    }

    private func draw(after lead: Double = 0) {
        if reduceMotion {
            drawn = true
        } else {
            // Un temps mort avant le tracé : la carte finit d'arriver,
            // puis l'anneau se dessine. Les deux en même temps se
            // brouillent et on ne regarde ni l'un ni l'autre.
            withAnimation(Motion.settle.delay(lead + 0.12)) { drawn = true }
        }
    }
}

// MARK: - Le doigt qui appuie

/// Enfonce légèrement un bouton sous le doigt.
///
/// Les boutons de l'application sont en `.buttonStyle(.plain)` pour garder
/// leur dessin — ce qui supprime aussi tout retour au toucher. Dans une
/// salle, avec les mains moites et le téléphone posé de travers, un bouton
/// qui ne réagit pas est un bouton qu'on appuie deux fois.
struct PressableStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.86 : 1)
            .animation(Motion.snap, value: configuration.isPressed)
    }
}
