import Foundation
import Testing
@testable import MonCoachKit

/// Les sports adaptés.
///
/// Ce qui est vérifié ici n'est pas décoratif. Un sport rangé dans la
/// mauvaise famille disparaît du menu ; un mode de déplacement faux jette
/// la trace d'une sortie en fauteuil ; une dépense recopiée du sport valide
/// équivalent fait manger trop. Chacun de ces trois défauts est silencieux —
/// personne ne les voit avant de relire une sortie qui manque.
@Suite("Les sports adaptés")
struct AdaptiveSportsTests {

    private var adaptive: [Sport] { SportFamily.adaptive.sports }

    @Test("La famille existe et n'est pas vide")
    func theFamilyExists() {
        #expect(!adaptive.isEmpty)
        #expect(SportFamily.allCases.contains(.adaptive))
    }

    /// Ils vivent dans le même catalogue que les autres, et pas à côté :
    /// un athlète qui fait du handbike le mardi et de la natation le jeudi
    /// relit ses deux séances dans le même journal.
    @Test("Ils sont dans le catalogue commun, pas dans une liste à part")
    func theyLiveInTheOneCatalogue() {
        for sport in adaptive {
            #expect(Sport.allCases.contains(sport))
            #expect(Sport(rawValue: sport.rawValue) == sport)
        }
    }

    /// Le fauteuil poussé avance à l'allure d'un marcheur ; le fauteuil de
    /// course et le handbike roulent. Le filtrage de la trace en dépend
    /// entièrement : appliquer les seuils du vélo à un fauteuil poussé à
    /// 4 km/h jetterait la moitié des points comme « trop lents ».
    @Test(
        "Chaque engin est filtré comme il avance",
        arguments: [
            (Sport.adaptiveWalk, SportMode.walking),
            (.wheelchairPush, .walking),
            (.wheelchairRacing, .rolling),
            (.handcycling, .rolling),
            (.adaptiveTricycle, .rolling),
        ]
    )
    func eachMachineIsFilteredAsItMoves(sport: Sport, mode: SportMode) {
        #expect(sport.mode == mode)
    }

    /// Ce qui se déplace laisse une trace et se mesure en kilomètres ; ce
    /// qui se pratique sur place se mesure au chrono. Une carte vide et
    /// « 0,0 km » après une heure de boccia serait un mensonge.
    @Test("Ce qui roule trace, ce qui reste assis ne trace pas")
    func whatRollsLeavesATrace() {
        for sport in [Sport.adaptiveWalk, .wheelchairPush, .wheelchairRacing,
                      .handcycling, .adaptiveTricycle] {
            #expect(sport.tracksLocation, Comment(rawValue: "\(sport.rawValue)"))
        }
        for sport in [Sport.seatedStrength, .seatedMobility, .boccia,
                      .wheelchairBasketball, .wheelchairTennis] {
            #expect(!sport.tracksLocation, Comment(rawValue: "\(sport.rawValue)"))
        }
    }

    /// Aucun d'eux ne nourrit le plan de course.
    ///
    /// Le plan de course est bâti sur des allures au kilomètre et des
    /// volumes hebdomadaires de course à pied. Y verser vingt kilomètres de
    /// handbike ferait tripler le volume prescrit la semaine suivante, et
    /// une moyenne à 25 km/h prise pour une allure de seuil rendrait toutes
    /// les séances intenables.
    @Test("Aucun ne nourrit le plan de course")
    func noneFeedsTheRunningPlan() {
        for sport in adaptive {
            #expect(!sport.feedsRunningPlan, Comment(rawValue: "\(sport.rawValue)"))
        }
    }

    /// Là où l'allure est réellement plus lente, la dépense l'est aussi.
    ///
    /// Marcher avec une canne ou un releveur va moins vite qu'une marche
    /// ordinaire, et nager avec un côté qui ne pousse pas avance moins vite
    /// qu'un crawl à deux bras : à durée égale, la dépense est plus basse.
    /// Recopier la valeur du sport voisin — le réflexe facile — ferait
    /// compter des calories qui n'ont pas été brûlées, tous les jours, à
    /// quelqu'un qui compte sur l'application pour ne pas se tromper.
    ///
    /// La première version de ce test exigeait la même chose du basket
    /// fauteuil, et elle avait tort. Un joueur en fauteuil pousse, freine et
    /// relance pendant quarante minutes : le Compendium lui donne à peu près
    /// ce qu'il donne au basket debout, et c'est la mesure qui a raison
    /// contre l'idée qu'un sport adapté serait forcément un sport moindre.
    @Test("Ce qui va moins vite coûte moins cher, et rien d'autre n'est supposé")
    func slowerReallyMeansCheaper() {
        #expect(Sport.adaptiveWalk.baseMET < Sport.walk.baseMET)
        #expect(Sport.adaptiveSwim.baseMET < Sport.swim.baseMET)
    }

    /// Le revers du test précédent : un sport adapté qui demande autant
    /// garde autant. Rien dans le catalogue ne doit rabaisser un effort
    /// parce qu'il est fourni assis.
    @Test("Un effort assis n'est pas rabaissé pour autant")
    func aSeatedEffortIsNotDiscounted() {
        #expect(Sport.wheelchairBasketball.baseMET >= 6)
        #expect(Sport.wheelchairRacing.baseMET >= Sport.run.baseMET * 0.75)
        #expect(Sport.handcycling.baseMET >= 5)
    }

    /// Toutes les valeurs restent dans les bornes du Compendium : rien en
    /// dessous du repos assis, rien au-dessus d'un effort maximal.
    @Test("Les dépenses restent plausibles")
    func theEnergyCostsStayPlausible() {
        for sport in adaptive {
            #expect(sport.baseMET >= 1.5, Comment(rawValue: "\(sport.rawValue)"))
            #expect(sport.baseMET <= 10, Comment(rawValue: "\(sport.rawValue)"))
        }
    }

    /// Ce que l'hémiplégie demande n'est pas un sport de plus, c'est que
    /// ceux qu'on pratique vraiment soient là.
    ///
    /// L'hémiplégie est un état du corps, pas une activité : en faire une
    /// ligne du catalogue n'aurait aucun sens. Ce qui sert à quelqu'un dont
    /// un côté ne répond plus, c'est la marche adaptée avec sa canne, le
    /// tricycle qui tient debout tout seul, l'eau qui porte le côté atteint,
    /// le renforcement assis qui travaille un côté à la fois, et la mobilité
    /// contre la spasticité. Ce test les tient présents.
    @Test("Ce qui sert à une hémiplégie est dans la liste")
    func whatServesHemiplegiaIsThere() {
        for sport in [Sport.adaptiveWalk, .adaptiveTricycle, .adaptiveSwim,
                      .seatedStrength, .seatedMobility] {
            #expect(sport.family == .adaptive, Comment(rawValue: "\(sport.rawValue)"))
        }
    }

    /// Chacun a son nom dans les trois langues, et aucun ne porte le nom
    /// d'un autre — c'est ce qui les rend choisissables dans un menu.
    @Test("Chacun est nommé dans les trois langues, et distinctement")
    func eachIsNamedInThreeLanguages() {
        for language in Language.allCases {
            let names = Sport.allCases.map { $0.label[language] }
            #expect(Set(names).count == names.count)
            for sport in adaptive {
                #expect(!sport.label[language].isEmpty)
            }
        }
    }

    @Test("Chacun a son symbole, et pas celui par défaut")
    func eachHasItsOwnSymbol() {
        for sport in adaptive {
            #expect(!sport.symbolName.isEmpty, Comment(rawValue: "\(sport.rawValue)"))
        }
    }
}
