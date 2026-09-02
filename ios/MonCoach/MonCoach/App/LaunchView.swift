import SwiftUI
import MonCoachKit

/// L'écran de lancement : le nom, un mouvement, et qui l'a fait.
///
/// Ce qu'il couvre
/// ---------------
/// Au démarrage, l'application fait un vrai travail avant d'être utilisable :
/// elle ferme les Live Activities orphelines, nettoie les doublons et les
/// photos sans propriétaire, et surtout demande à l'App Store où en est
/// l'abonnement — ce dernier appel prend le temps qu'il prend. Sans cet
/// écran, ce temps se passe devant un « Aujourd'hui » figé, ou pire, devant
/// un paywall qui s'affiche puis disparaît quand la réponse arrive.
///
/// Pourquoi il dure au moins une seconde et demie
/// ----------------------------------------------
/// Un écran de lancement qui clignote 200 ms est plus désagréable que pas
/// d'écran du tout : on a vu quelque chose sans avoir le temps de le lire.
/// Le minimum est fixé pour qu'on lise le nom et qu'on voie le mouvement,
/// et le maximum est le temps réel du travail — l'écran n'attend jamais
/// plus longtemps que nécessaire.
struct LaunchView: View {
    var language: Language

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var wordmarkShown = false
    @State private var creditShown = false

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                StrideLoader()
                    .padding(.bottom, 34)

                VStack(spacing: 8) {
                    Text("Stride")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .kerning(1.2)
                        .foregroundStyle(Theme.primaryText)
                    Text(
                        LocalizedText(fr: "ENTRAÎNEMENT", en: "TRAINING", es: "ENTRENAMIENTO")[language]
                    )
                    .font(.system(size: 11, weight: .semibold))
                    .kerning(3.5)
                    .foregroundStyle(Theme.secondaryText)
                }
                .opacity(wordmarkShown ? 1 : 0)
                .offset(y: wordmarkShown || reduceMotion ? 0 : 10)

                Spacer()
                Spacer()

                credit
                    .opacity(creditShown ? 1 : 0)
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            // Le nom d'abord, l'auteur ensuite : deux temps, sinon tout
            // arrive en bloc et rien ne se lit.
            withAnimation((reduceMotion ? Motion.plain : Motion.entrance).delay(0.15)) {
                wordmarkShown = true
            }
            withAnimation(Motion.plain.delay(0.55)) {
                creditShown = true
            }
        }
    }

    /// Qui a fait l'application, en toutes lettres.
    ///
    /// Une application sans auteur est une application faite par personne,
    /// et on ne fait pas confiance à un coach qui n'a pas de nom.
    private var credit: some View {
        VStack(spacing: 5) {
            Text(
                LocalizedText(
                    fr: "Conçu et développé par",
                    en: "Designed and developed by",
                    es: "Diseñado y desarrollado por"
                )[language]
            )
            .font(.system(size: 12))
            .foregroundStyle(Theme.secondaryText)
            Text("Maxime Nathan Lestage")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.primaryText)
            if let version = Self.version {
                Text(version)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Theme.secondaryText.opacity(0.7))
                    .padding(.top, 6)
            }
        }
        .multilineTextAlignment(.center)
    }

    /// « 1.0 (56) » — le numéro qu'on lit à voix haute quand quelque chose
    /// ne va pas, au seul endroit où il ne gêne personne.
    private static var version: String? {
        let info = Bundle.main.infoDictionary
        guard let short = info?["CFBundleShortVersionString"] as? String else { return nil }
        if let build = info?["CFBundleVersion"] as? String, build != short {
            return "\(short) (\(build))"
        }
        return short
    }
}

/// Le chargeur de l'application : un éclair au centre, et deux foulées
/// qui tournent autour à des vitesses différentes.
///
/// Deux arcs plutôt qu'un : un seul arc qui tourne est le chargeur de
/// tout le monde. Deux, de longueurs et de vitesses différentes, se
/// rattrapent et se dépassent — c'est une cadence, pas une attente, et
/// c'est celle d'un pied qui passe devant l'autre.
///
/// Réutilisable partout où l'application fait attendre : la reconnaissance
/// d'une assiette, l'import d'une trace GPX, la réponse de l'App Store.
struct StrideLoader: View {
    var size: CGFloat = 92
    var lineWidth: CGFloat = 6

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var turning = false

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.surfaceRaised, lineWidth: lineWidth)

            // La foulée longue : un tiers de tour, un tour par 1,1 s.
            stride(length: 0.30, opacity: 1, secondsPerTurn: 1.1)

            // La foulée courte, partie du côté opposé et plus rapide, pour
            // qu'elles ne restent jamais alignées.
            stride(length: 0.14, opacity: 0.5, secondsPerTurn: 0.7)
                .rotationEffect(.degrees(180))

            Image(systemName: "bolt.fill")
                .font(.system(size: size * 0.30, weight: .bold))
                .foregroundStyle(Theme.accent)
                .symbolEffect(.pulse, isActive: !reduceMotion)
        }
        .frame(width: size, height: size)
        .onAppear {
            guard !reduceMotion else { return }
            turning = true
        }
        .accessibilityLabel(Text("Chargement"))
    }

    private func stride(length: Double, opacity: Double, secondsPerTurn: Double) -> some View {
        Circle()
            .trim(from: 0, to: length)
            .stroke(
                Theme.accent.opacity(opacity),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .rotationEffect(.degrees(turning ? 360 : 0))
            // En mouvement réduit, l'arc reste posé : le chargeur se lit
            // encore comme un chargeur, sans rien qui tourne.
            .animation(
                reduceMotion ? nil : .linear(duration: secondsPerTurn).repeatForever(autoreverses: false),
                value: turning
            )
    }
}
