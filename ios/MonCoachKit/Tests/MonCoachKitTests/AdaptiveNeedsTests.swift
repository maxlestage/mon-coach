import Foundation
import Testing
@testable import MonCoachKit

/// La déclaration de situation, et ce qu'elle change au programme.
///
/// Ce qui se vérifie ici est de la même famille que le reste : silencieux.
/// Un exercice impossible proposé ne plante pas l'application — il déçoit
/// quelqu'un devant une machine, une fois, et il ne revient pas. Un muscle
/// sans mouvement disponible ne lève aucune erreur : il produit une séance
/// vide, ce qui ressemble beaucoup à un jour de repos.
@Suite("Situation déclarée")
struct AdaptiveNeedsTests {

    // MARK: - Le modèle des exigences

    /// La fermeture est ce qui évite de répéter la liste complète dans
    /// chaque situation. Sans elle, il aurait suffi qu'une seule oublie
    /// `.bothLegs` pour proposer un squat barre à quelqu'un qui ne se lève
    /// pas.
    @Test("Aucune jambe implique pas deux jambes, aucun bras implique pas de barre")
    func implicationsClose() {
        let noLeg = AdaptiveNeeds.closed([.oneLeg])
        #expect(noLeg.contains(.bothLegs))

        let noArm = AdaptiveNeeds.closed([.oneArm])
        #expect(noArm.contains(.bothArms))
        #expect(noArm.contains(.gripBothHands))

        // L'inverse ne vaut pas : ne pas pouvoir fournir des deux jambes
        // ne dit rien de la jambe valide.
        let noPair = AdaptiveNeeds.closed([.bothLegs])
        #expect(!noPair.contains(.oneLeg))
    }

    @Test("Deux situations déclarées cumulent leurs impossibilités")
    func situationsAccumulate() {
        let both = AdaptiveNeeds(situations: [.hemiplegia, .limitedMobility])
        #expect(both.unavailableDemands.contains(.bothArms))   // de l'hémiplégie
        #expect(both.unavailableDemands.contains(.standing))   // de la mobilité réduite
    }

    /// La partie qu'il ne faut pas rater. Retirer des exercices « par
    /// prudence » à quelqu'un qui n'entend pas serait une façon polie de
    /// décider à sa place.
    @Test(
        "Une déficience sensorielle ou mentale ne retire aucun mouvement",
        arguments: [AdaptiveSituation.visualImpairment, .hearingImpairment, .intellectual]
    )
    func sensoryRemovesNothing(situation: AdaptiveSituation) {
        let needs = AdaptiveNeeds(situations: [situation])
        #expect(needs.unavailableDemands.isEmpty)
        #expect(needs.filtersNothing)

        let profile = Fixtures.intermediate(adaptive: needs)
        let plain = Fixtures.intermediate()
        #expect(
            Set(ExerciseCatalog.available(for: profile).map(\.id))
                .isSuperset(of: Set(ExerciseCatalog.available(for: plain).map(\.id)))
        )
    }

    @Test("Le fauteuil dit où se passe la séance, pas ce que les jambes valent")
    func wheelchairSaysNothingAboutLegs() {
        let needs = AdaptiveNeeds(usesWheelchair: true)
        #expect(needs.isActive)
        #expect(needs.unavailableDemands.contains(.standing))
        #expect(!needs.unavailableDemands.contains(.oneLeg))
        #expect(!needs.unavailableDemands.contains(.bothLegs))
    }

    @Test("Le côté qui travaille est l'opposé du côté atteint")
    func workingSideIsTheOtherOne() {
        let left = AdaptiveNeeds(situations: [.hemiplegia], affectedSide: .left)
        #expect(left.workingSide == .right)

        // Sans situation latéralisée, la question n'a pas de réponse — et
        // l'écran ne doit pas en inventer une.
        let seated = AdaptiveNeeds(situations: [.paraplegia], affectedSide: .left)
        #expect(seated.workingSide == nil)
    }

    // MARK: - Le catalogue

    /// Le test qui a justifié vingt-sept mouvements de plus, en deux fois.
    ///
    /// Écrit d'abord comme une vérification de routine, il a échoué sur
    /// cinq muscles à la fois : pectoraux, triceps, deltoïdes postérieurs,
    /// ischio-jambiers et mollets n'étaient servis, dans tout le catalogue
    /// commun, que par des mouvements à deux bras ou à deux jambes.
    ///
    /// Puis il a menti pendant une journée entière, parce qu'il ne mesurait
    /// qu'une salle complète. Chez quelqu'un qui s'entraîne avec deux
    /// élastiques, l'application annonçait n'avoir rien pour onze muscles
    /// sur quatorze — les mouvements ajoutés étaient tous à la machine ou à
    /// la poulie. C'est un utilisateur qui l'a vu, sur une capture d'écran,
    /// pas ce test. D'où la boucle sur les trois lots de matériel : une
    /// vérification qui n'essaie qu'une configuration ne vérifie que
    /// celle-là.
    @Test(
        "Un seul côté qui travaille garde de quoi entraîner tout le corps, avec ou sans salle",
        arguments: [Equipment.fullGym, Equipment.homeGym, Equipment.minimal]
    )
    func oneSideStillTrainsEverything(kit: Set<Equipment>) {
        let needs = AdaptiveNeeds(situations: [.hemiplegia], affectedSide: .left)
        let profile = Fixtures.intermediate(equipment: kit, adaptive: needs)
        let trainable = ExerciseCatalog.trainableMuscles(for: profile)

        for muscle in MuscleGroup.allCases {
            #expect(trainable.contains(muscle), "aucun mouvement pour \(muscle.rawValue)")
        }
    }

    /// La même exigence pour toutes les situations qui ne retirent pas les
    /// jambes, et pour tous les lots de matériel.
    ///
    /// Ce que ce test accepte de laisser passer est nommé plutôt que
    /// contourné : quand les jambes ne fournissent pas, aucun élastique n'y
    /// changera rien, et prétendre le contraire aurait été le seul vrai
    /// mensonge possible ici.
    @Test("Chaque situation garde tout ce que le corps peut encore travailler")
    func everySituationKeepsWhatTheBodyCanDo() {
        let seated: Set<AdaptiveSituation> = [.paraplegia, .tetraplegia]
        let legs: Set<MuscleGroup> = [.quads, .hamstrings, .glutes, .calves]

        for kit in [Equipment.fullGym, Equipment.homeGym, Equipment.minimal] {
            for situation in AdaptiveSituation.allCases {
                let profile = Fixtures.intermediate(
                    equipment: kit,
                    adaptive: AdaptiveNeeds(situations: [situation], affectedSide: .right)
                )
                let trainable = ExerciseCatalog.trainableMuscles(for: profile)
                let expected = seated.contains(situation)
                    ? MuscleGroup.allCases.filter { !legs.contains($0) }
                    : MuscleGroup.allCases

                for muscle in expected {
                    #expect(
                        trainable.contains(muscle),
                        "\(situation.rawValue) : rien pour \(muscle.rawValue)"
                    )
                }
            }
        }
    }

    /// Un fauteuil ne dit rien des jambes : quelqu'un qui roule avec des
    /// jambes qui fonctionnent doit garder ses quadriceps.
    @Test("Le fauteuil seul ne retire pas le travail des jambes")
    func wheelchairAloneKeepsLegs() {
        for kit in [Equipment.fullGym, Equipment.homeGym, Equipment.minimal] {
            let profile = Fixtures.intermediate(
                equipment: kit, adaptive: AdaptiveNeeds(usesWheelchair: true)
            )
            let trainable = ExerciseCatalog.trainableMuscles(for: profile)
            for muscle in MuscleGroup.allCases {
                #expect(trainable.contains(muscle), "rien pour \(muscle.rawValue)")
            }
        }
    }

    @Test("Rien de ce qui est proposé n'exige ce que le corps ne fournit pas")
    func nothingImpossibleIsOffered() {
        for situation in AdaptiveSituation.allCases {
            let needs = AdaptiveNeeds(situations: [situation], affectedSide: .left)
            let profile = Fixtures.intermediate(adaptive: needs)
            let unavailable = needs.unavailableDemands
            for exercise in ExerciseCatalog.available(for: profile) {
                #expect(
                    exercise.demands.isDisjoint(with: unavailable),
                    "\(exercise.id) proposé à \(situation.rawValue)"
                )
            }
        }
    }

    /// Le squat barre est le cas d'école, et il tombe par la fermeture :
    /// il déclare `.bothLegs`, la paraplégie retire `.oneLeg`.
    @Test("Un squat barre n'est jamais proposé à quelqu'un qui ne se lève pas")
    func noBarbellSquatSeated() {
        let profile = Fixtures.intermediate(adaptive: AdaptiveNeeds(situations: [.paraplegia]))
        let ids = Set(ExerciseCatalog.available(for: profile).map(\.id))
        #expect(!ids.contains("back-squat"))
        #expect(!ids.contains("leg-press"))
        #expect(!ids.contains("single-leg-press"))
        // Le haut du corps garde son programme entier : c'est la moitié de
        // la promesse, et la plus facile à casser en filtrant trop large.
        #expect(ids.contains("lat-pulldown"))
        #expect(ids.contains("machine-chest-press"))
    }

    /// Les mouvements adaptés ne doivent pas fuir dans le catalogue commun :
    /// ils changeraient les séances de tout le monde, le sélecteur
    /// départageant les égalités sur l'identifiant.
    @Test("Les mouvements adaptés n'existent que pour qui les a demandés")
    func adaptiveMovesStayOut() {
        let plain = Set(ExerciseCatalog.available(for: Fixtures.intermediate()).map(\.id))
        for exercise in ExerciseCatalog.adaptive {
            #expect(!plain.contains(exercise.id))
            #expect(!ExerciseCatalog.all.contains { $0.id == exercise.id })
            // Mais ils restent retrouvables : un historique enregistré doit
            // rester lisible même si la déclaration change ensuite.
            #expect(ExerciseCatalog.exercise(id: exercise.id) != nil)
        }
    }

    @Test("Tout mouvement du catalogue déclare ce qu'il exige du corps")
    func everyMovementDeclaresItsDemands() {
        for exercise in ExerciseCatalog.all + ExerciseCatalog.adaptive {
            // Une barre tenue à deux mains exige les deux bras : l'inverse
            // se serait glissé sans bruit dans une déclaration bâclée.
            if exercise.demands.contains(.gripBothHands) {
                #expect(exercise.demands.contains(.bothArms), "\(exercise.id)")
            }
            // Ce qui se fait debout sous charge, avec les deux jambes ou une
            // seule, doit le dire.
            if [.squat, .lunge, .hinge, .carry].contains(exercise.pattern) {
                #expect(!exercise.demands.isEmpty, "\(exercise.id)")
            }
            // « Un bras » et « les deux bras » sont exclusifs, sinon la
            // déclaration ne veut plus rien dire. `isUnilateral` ne suffit
            // pas à trancher : la fente à la barre guidée travaille une
            // jambe à la fois, les deux mains sur la barre.
            if exercise.demands.contains(.oneArm) {
                #expect(!exercise.demands.contains(.bothArms), "\(exercise.id)")
            }
            if exercise.demands.contains(.oneLeg) {
                #expect(!exercise.demands.contains(.bothLegs), "\(exercise.id)")
            }
        }
    }

    // MARK: - Ce que l'athlète rend au catalogue

    /// Le filtrage est un défaut, pas un verdict : deux hémiplégies ne se
    /// ressemblent pas, et celle qui lève le bras moins fort a de bonnes
    /// raisons de vouloir continuer à travailler les deux côtés.
    ///
    /// Ce test attendait d'abord le squat barre, et il avait tort : un squat
    /// exige aussi l'équilibre sous charge, que l'hémiplégie retire pour une
    /// raison qui n'a rien à voir avec la symétrie. Les deux questions sont
    /// posées séparément dans l'écran, et c'est juste — répondre « je
    /// travaille des deux côtés » ne répond pas « je tiens en équilibre sous
    /// une barre ».
    @Test("Réautoriser les deux côtés fait revenir le développé couché")
    func bothSidesComesBack() {
        var needs = AdaptiveNeeds(situations: [.hemiplegia], affectedSide: .right)
        let filtered = Set(
            ExerciseCatalog.available(for: Fixtures.intermediate(adaptive: needs)).map(\.id)
        )
        #expect(!filtered.contains("bench-press"))
        #expect(!filtered.contains("back-squat"))

        needs.allowedAnyway = AdaptiveNeeds.pairedDemands
        #expect(needs.trainsBothSides)
        let opened = Set(
            ExerciseCatalog.available(for: Fixtures.intermediate(adaptive: needs)).map(\.id)
        )
        #expect(opened.contains("bench-press"))
        #expect(opened.contains("barbell-curl"))
        #expect(opened.contains("leg-press"))
        // Le squat attend la seconde réponse : il demande l'équilibre.
        #expect(!opened.contains("back-squat"))

        // Et rien n'est perdu au passage : le travail à un seul côté reste
        // disponible, c'est un ajout et non un basculement.
        #expect(opened.isSuperset(of: filtered))

        needs.allowedAnyway.insert(.balance)
        let everything = Set(
            ExerciseCatalog.available(for: Fixtures.intermediate(adaptive: needs)).map(\.id)
        )
        #expect(everything.contains("back-squat"))
    }

    /// Réautoriser une exigence n'en rouvre aucune autre. Rendre « les deux
    /// bras » ne doit pas rendre la prise à deux mains, qui n'a pas été
    /// cochée.
    @Test("Une réautorisation ne rend que ce qui est coché")
    func overrideIsExact() {
        var needs = AdaptiveNeeds(situations: [.hemiplegia], affectedSide: .right)
        needs.allowedAnyway = [.bothArms]
        #expect(!needs.unavailableDemands.contains(.bothArms))
        #expect(needs.unavailableDemands.contains(.gripBothHands))
        #expect(needs.unavailableDemands.contains(.bothLegs))
        #expect(!needs.trainsBothSides)
    }

    @Test("Ce qui n'est pas retiré ne se propose pas à réautoriser")
    func nothingToOverrideWhenNothingRemoved() {
        let sensory = AdaptiveNeeds(situations: [.hearingImpairment])
        #expect(sensory.overridable.isEmpty)

        let seated = AdaptiveNeeds(situations: [.paraplegia])
        #expect(seated.overridable.contains(.standing))
        #expect(!seated.overridable.contains(.oneArm))
    }

    /// Tout réautoriser revient à ne rien filtrer — et l'écran doit alors
    /// le dire, au lieu de laisser croire à un tri silencieux.
    @Test("Tout réautoriser rend le programme complet")
    func fullOverrideRestoresEverything() {
        var needs = AdaptiveNeeds(situations: [.tetraplegia])
        needs.allowedAnyway = needs.closedDemands
        #expect(needs.unavailableDemands.isEmpty)
        #expect(needs.filtersNothing)

        let restored = Set(
            ExerciseCatalog.available(for: Fixtures.intermediate(adaptive: needs)).map(\.id)
        )
        let plain = Set(ExerciseCatalog.available(for: Fixtures.intermediate()).map(\.id))
        #expect(restored.isSuperset(of: plain))
    }

    /// Le piège de compatibilité : `allowedAnyway` n'existait pas dans les
    /// profils enregistrés par les premières versions, et un décodage
    /// synthétisé aurait refusé la clé absente — rendant leur profil
    /// illisible, pas « sans réautorisation ».
    @Test("Une déclaration enregistrée avant ce réglage se relit")
    func olderDeclarationsStillDecode() throws {
        let json = Data(#"{"situations":["hemiplegia"],"affectedSide":"right","usesWheelchair":false}"#.utf8)
        let decoded = try JSONDecoder().decode(AdaptiveNeeds.self, from: json)

        #expect(decoded.situations == [.hemiplegia])
        #expect(decoded.affectedSide == .right)
        #expect(decoded.allowedAnyway.isEmpty)
        #expect(decoded.unavailableDemands.contains(.bothArms))
    }

    // MARK: - Le programme

    @Test("Une journée sans un seul mouvement disponible disparaît au lieu de rester vide")
    func emptyDaysAreDropped() {
        let needs = AdaptiveNeeds(situations: [.paraplegia])
        let profile = Fixtures.intermediate(daysPerWeek: 4, adaptive: needs)
        let trainable = ExerciseCatalog.trainableMuscles(for: profile)
        let days = SplitPlanner.days(for: .upperLower, daysPerWeek: 4, trainable: trainable)

        #expect(days.count == 4, "les quatre séances demandées sont rendues")
        for day in days {
            #expect(!day.muscles.isEmpty)
            #expect(day.muscles.allSatisfy(trainable.contains))
        }
    }

    /// La garantie qui protège tous les autres : sans déclaration, rien ne
    /// bouge. Elle vaut plus que ce qu'elle vérifie — c'est elle qui permet
    /// de laisser la section visible en permanence.
    @Test("Sans rien de déclaré, le programme est exactement celui d'avant")
    func nothingChangesWithoutADeclaration() {
        let plain = PlanBuilder.build(for: Fixtures.intermediate(), startingOn: Fixtures.start)
        let empty = PlanBuilder.build(
            for: Fixtures.intermediate(adaptive: AdaptiveNeeds()),
            startingOn: Fixtures.start
        )
        // Comparer les blocs directement ne teste rien : chaque semaine et
        // chaque séance portent un UUID neuf. Ce qui doit coïncider, c'est
        // ce que l'athlète voit.
        func shape(_ plan: Mesocycle) -> [[[String]]] {
            plan.weeks.map { week in
                week.sessions.map { session in session.exercises.map(\.exerciseID) }
            }
        }
        #expect(shape(plain) == shape(empty))
        #expect(plain.weeklyVolumeTarget == empty.weeklyVolumeTarget)
        #expect(plain.rationale.map { $0[.french] } == empty.rationale.map { $0[.french] })
    }

    @Test("Le programme d'un paraplégique tient debout : des séances pleines, sans jambes")
    func aSeatedProgrammeIsComplete() {
        let profile = Fixtures.intermediate(
            daysPerWeek: 4, adaptive: AdaptiveNeeds(situations: [.paraplegia])
        )
        let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start)

        for week in plan.weeks {
            for session in week.sessions {
                #expect(!session.exercises.isEmpty, "séance vide dans le bloc")
            }
        }
        // Les jambes sortent du budget plutôt que d'y figurer à zéro.
        #expect(plan.weeklyVolumeTarget[.quads] == nil)
        #expect(plan.weeklyVolumeTarget[.hamstrings] == nil)
        #expect((plan.weeklyVolumeTarget[.chest] ?? 0) > 0)
    }

    /// Taire les muscles que le catalogue ne sait pas servir laisserait
    /// quelqu'un chercher pendant des semaines pourquoi ils n'apparaissent
    /// jamais.
    @Test("Le programme dit quels muscles il ne sait pas servir")
    func theProgrammeSaysWhatItCannotDo() {
        let profile = Fixtures.intermediate(
            adaptive: AdaptiveNeeds(situations: [.paraplegia])
        )
        let plan = PlanBuilder.build(for: profile, startingOn: Fixtures.start)
        let text = plan.rationale.map { $0[.french] }.joined(separator: " ")

        #expect(text.contains("Paraplégie"))
        #expect(text.contains(MuscleGroup.quads.label[.french]))
    }

    // MARK: - Les sports

    @Test("Chaque situation met devant des sports qui existent au catalogue")
    func suggestedSportsAreReal() {
        for situation in AdaptiveSituation.allCases {
            let sports = situation.suggestedSports
            #expect(!sports.isEmpty, "\(situation.rawValue)")
            for sport in sports {
                #expect(Sport.allCases.contains(sport))
            }
        }
    }

    /// Proposer la course à pied à quelqu'un en fauteuil serait pire que ne
    /// rien proposer du tout.
    ///
    /// Écrit d'abord contre `sport.mode`, ce test accusait le fauteuil
    /// poussé — qui est filtré comme une marche, délibérément, parce qu'il
    /// avance à l'allure d'un marcheur. Le mode dit comment la trace est
    /// nettoyée, pas si les jambes servent. Ce qu'il fallait nommer, ce sont
    /// les sports qui se font debout.
    @Test("Ce qui se fait assis ne propose rien qui se fasse debout")
    func seatedSituationsDoNotSuggestRunning() {
        let onFoot: Set<Sport> = [.run, .trail, .walk, .hike, .treadmill, .adaptiveWalk]
        for situation in [AdaptiveSituation.paraplegia, .tetraplegia] {
            for sport in situation.suggestedSports {
                #expect(!onFoot.contains(sport), "\(sport.rawValue) proposé à \(situation.rawValue)")
            }
        }
    }

    @Test("Deux situations déclarées ne proposent pas deux fois le même sport")
    func suggestionsAreDeduplicated() {
        let needs = AdaptiveNeeds(situations: [.paraplegia, .tetraplegia], usesWheelchair: true)
        let sports = needs.suggestedSports
        #expect(Set(sports).count == sports.count)
        #expect(sports.contains(.wheelchairPush))
    }

    // MARK: - Ce qui se relit

    /// Un profil enregistré avant que la section existe doit se relire sans
    /// migration, et se comporter comme avant.
    @Test("Un profil sans la section se relit et n'adapte rien")
    func oldProfilesStillDecode() throws {
        var profile = Fixtures.intermediate()
        profile.adaptive = nil
        let data = try JSONEncoder().encode(profile)

        var object = try #require(
            try JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        object.removeValue(forKey: "adaptive")
        let trimmed = try JSONSerialization.data(withJSONObject: object)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: trimmed)

        #expect(decoded.adaptive == nil)
        #expect(!decoded.hasAdaptiveNeeds)
        #expect(decoded.unavailableDemands.isEmpty)
    }

    /// Le bug trouvé en écrivant ce qui précède : le formulaire ne demande
    /// pas la situation — elle a son propre écran — et reconstruisait donc
    /// un profil sans elle. Corriger un poids effaçait la déclaration.
    /// La même ligne effaçait déjà les données de cycle.
    @Test("Modifier son poids n'efface ni la situation ni le cycle")
    func editingKeepsWhatTheFormDoesNotAsk() {
        var profile = Fixtures.intermediate()
        profile.adaptive = AdaptiveNeeds(situations: [.hemiplegia], affectedSide: .right)
        profile.lastPeriodStart = Fixtures.date(2026, 8, 20)
        profile.cycleLength = 31

        var draft = ProfileDraft(profile: profile)
        draft.weightKg = 80
        let updated = draft.makeProfile()

        #expect(updated.weightKg == 80)
        #expect(updated.adaptive?.situations == [.hemiplegia])
        #expect(updated.adaptive?.affectedSide == .right)
        #expect(updated.lastPeriodStart == profile.lastPeriodStart)
        #expect(updated.cycleLength == 31)
    }
}
