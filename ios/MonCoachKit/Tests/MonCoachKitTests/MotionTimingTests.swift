import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le minutage des animations d'arrivée")
struct MotionTimingTests {

    @Test("La première carte n'attend pas")
    func firstCardIsImmediate() {
        #expect(MotionTiming.delay(forCardAt: 0) == 0)
    }

    @Test("Les cartes arrivent dans l'ordre")
    func delaysIncrease() {
        let delays = (0...5).map { MotionTiming.delay(forCardAt: $0) }
        let sorted = delays.sorted()
        #expect(delays == sorted)
        #expect(Set(delays).count == delays.count)
    }

    @Test("Un écran long ne met pas plus longtemps qu'un écran court")
    func delayIsCapped() {
        // Le profil a douze cartes, le plan peut en avoir quatorze. Sans
        // plafond, la dernière attendrait presque une seconde — et c'est
        // exactement le bug qu'on ne voit jamais en développant, parce
        // qu'on regarde toujours le haut de l'écran.
        for index in MotionTiming.visibleCards...200 {
            #expect(MotionTiming.delay(forCardAt: index) == MotionTiming.ceiling)
        }
    }

    @Test("Un indice négatif ne fait pas reculer une carte dans le temps")
    func negativeIndexIsClamped() {
        // Un indice négatif ne devrait jamais arriver, mais un délai négatif
        // passé à une animation démarre l'animation déjà finie : la carte
        // apparaît d'un coup, et on chercherait longtemps pourquoi celle-là.
        #expect(MotionTiming.delay(forCardAt: -1) == 0)
        #expect(MotionTiming.delay(forCardAt: -99) == 0)
    }

    @Test("Un écran entier est posé en moins d'un demi-tiers de seconde")
    func aScreenSettlesQuickly() {
        // Au-delà de 400 ms, l'arrivée cesse d'être une mise en scène et
        // devient une attente — on appuie avant que ce soit fini, et
        // l'application paraît lente alors qu'elle ne fait rien.
        #expect(MotionTiming.ceiling < 0.4)
        #expect(MotionTiming.settlingTime(cards: 30) <= MotionTiming.ceiling)
    }

    @Test("Une pile vide ou d'une seule carte n'attend rien")
    func shortStacksAreInstant() {
        #expect(MotionTiming.settlingTime(cards: 0) == 0)
        #expect(MotionTiming.settlingTime(cards: 1) == 0)
    }

    @Test("L'écart entre deux cartes se perçoit sans se subir")
    func stepStaysInTheReadableBand() {
        // En dessous de 40 ms la cascade se lit comme un seul mouvement et
        // ne sert plus à rien ; au-dessus de 80 ms elle se lit comme une
        // lenteur. La valeur n'a pas à être exacte, elle a à rester là.
        #expect(MotionTiming.step >= 0.04)
        #expect(MotionTiming.step <= 0.08)
    }

    @Test("Le plafond est bien le produit annoncé")
    func ceilingMatchesTheRule() {
        #expect(MotionTiming.ceiling == Double(MotionTiming.visibleCards) * MotionTiming.step)
        #expect(MotionTiming.delay(forCardAt: MotionTiming.visibleCards) == MotionTiming.ceiling)
    }
}
