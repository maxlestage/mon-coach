import Foundation
import Testing
@testable import MonCoachKit

@Suite("Essai, abonnement, et ce qui reste gratuit")
struct SubscriptionTests {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    private let day0 = Date(timeIntervalSince1970: 1_780_000_000)

    private func day(_ offset: Int) -> Date {
        day0.addingTimeInterval(Double(offset) * 86_400)
    }

    @Test("Pendant l'essai, tout est ouvert")
    func trialUnlocksEverything() {
        let status = SubscriptionStatus(trialStartedAt: day0)
        for feature in PlusFeature.allCases {
            #expect(status.isUnlocked(feature, on: day(3), calendar: calendar), Comment(rawValue: feature.rawValue))
        }
        #expect(status.isInTrial(on: day(13), calendar: calendar), "le quatorzième jour est encore un jour d'essai")
        #expect(status.trialDaysLeft(on: day(0), calendar: calendar) == 14)
        #expect(status.trialDaysLeft(on: day(13), calendar: calendar) == 1)
    }

    @Test("Passé quatorze jours, l'essai est fini")
    func trialEnds() {
        let status = SubscriptionStatus(trialStartedAt: day0)
        #expect(!status.isInTrial(on: day(14), calendar: calendar))
        #expect(status.trialDaysLeft(on: day(14), calendar: calendar) == 0)
        #expect(status.trialDaysLeft(on: day(400), calendar: calendar) == 0)
        for feature in PlusFeature.allCases {
            #expect(!status.isUnlocked(feature, on: day(20), calendar: calendar), Comment(rawValue: feature.rawValue))
        }
    }

    @Test("Un abonnement rouvre tout, même l'essai terminé")
    func subscriptionUnlocks() {
        let status = SubscriptionStatus(trialStartedAt: day0, isSubscribed: true)
        for feature in PlusFeature.allCases {
            #expect(status.isUnlocked(feature, on: day(500), calendar: calendar))
        }
        #expect(status.banner(on: day(2), calendar: calendar) == nil, "un abonné n'a pas à lire un compte à rebours")
    }

    @Test("Reculer l'horloge ne rallonge pas l'essai")
    func clockTricksDoNotExtendTheTrial() {
        let status = SubscriptionStatus(trialStartedAt: day0)
        // Une date antérieure au départ : l'essai ne dépasse jamais sa durée.
        #expect(status.trialDaysLeft(on: day(-30), calendar: calendar) == 14)
        // Et il ne devient jamais négatif non plus.
        #expect(status.trialDaysLeft(on: day(9_999), calendar: calendar) == 0)
    }

    @Test("Le compte à rebours se dit, puis se tait")
    func bannerSpeaksThenStops() {
        let status = SubscriptionStatus(trialStartedAt: day0)
        #expect(status.banner(on: day(1), calendar: calendar)?.isComplete == true)
        #expect(status.banner(on: day(13), calendar: calendar)?.fr.contains("Dernier jour") == true)
        #expect(status.banner(on: day(14), calendar: calendar) == nil, "un essai fini n'a plus de compte à rebours")
    }

    @Test("Chaque fonctionnalité payante sait se nommer et se justifier")
    func featuresExplainThemselves() {
        for feature in PlusFeature.allCases {
            #expect(feature.label.isComplete, Comment(rawValue: feature.rawValue))
            #expect(feature.detail.isComplete, Comment(rawValue: feature.rawValue))
        }
        #expect(PlusFeature.allCases.count == 7)
        // Calculé hors de la macro : `allSatisfy` avec un chemin de clé
        // brouille son analyse des erreurs relancées.
        let promisesComplete = AlwaysFree.promises.filter { !$0.isComplete }
        #expect(promisesComplete.isEmpty, "une promesse n'est pas traduite partout")
        #expect(AlwaysFree.hostageClause.isComplete)
    }

    @MainActor
    @Test("L'essai part une fois, et ne se relance jamais")
    func trialStartsOnceAndSticks() {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-trial-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }

        let store = CoachStore(storage: storage)
        #expect(store.trialStartedAt == nil, "rien ne court avant la première ouverture")
        let started = store.startTrialIfNeeded(on: day0)
        #expect(store.trialStartedAt == day0)

        // Une deuxième ouverture ne redonne pas quatorze jours.
        #expect(store.startTrialIfNeeded(on: day(30)) == started)
        #expect(store.trialStartedAt == day0)

        // Et une réinstallation relit la date depuis le disque.
        let reopened = CoachStore(storage: storage)
        #expect(reopened.trialStartedAt == day0)
        #expect(!reopened.subscription.isInTrial(on: day(20), calendar: calendar))
    }

    @MainActor
    @Test("Le bloc suivant attend l'abonnement, le bloc en cours jamais")
    func nextBlockNeedsPlus() throws {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-block-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }
        let store = CoachStore(storage: storage)
        store.startTrialIfNeeded(on: day0)
        store.updateProfile(Fixtures.intermediate(), rebuildingFrom: day0)

        let firstPlan = store.plan
        #expect(firstPlan != nil, "le premier bloc est construit sans rien demander")
        // Le briefing du jour continue de répondre une fois l'essai fini :
        // c'est le bloc en cours, et il va jusqu'au bout.
        #expect(store.briefing(on: day(20)) != nil)

        // Essai terminé : le bloc suivant attend.
        #expect(store.startNextBlock(on: day(20)) == false)
        #expect(store.plan?.id == firstPlan?.id, "le plan a été reconstruit malgré tout")

        // Abonné : il part.
        store.setSubscribed(true)
        #expect(store.startNextBlock(on: day(20)))
    }

    @MainActor
    @Test("L'export intégral emporte la date d'essai")
    func exportCarriesTheTrialDate() throws {
        let storage = StateStorage(
            url: URL.temporaryDirectory.appending(path: "stride-export-\(UUID().uuidString).json")
        )
        defer { try? FileManager.default.removeItem(at: storage.url) }
        let store = CoachStore(storage: storage)
        store.startTrialIfNeeded(on: day0)

        let data = try store.exportJSON()
        let decoded = try StateStorage.decoder.decode(PersistedState.self, from: data)
        #expect(decoded.trialStartedAt == day0, "« intégral » veut dire tout")
    }
}
