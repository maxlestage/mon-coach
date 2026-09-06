import Foundation
import Testing
@testable import MonCoachKit

/// Situer la journée dans le cycle, sans rien inventer.
///
/// Ce qui se joue ici
/// ------------------
/// La tentation est de baisser l'intensité en phase lutéale d'après un
/// tableau de la littérature. Cette littérature ne le permet pas : les effets
/// mesurés sont petits, contradictoires, et écrasés par la variation entre
/// personnes. Ces tests gardent surtout le silence du moteur tant qu'il n'a
/// pas mesuré le motif de **cette** athlète.
@Suite("Le cycle, mesuré chez elle et pas dans un tableau")
struct CycleEngineTests {

    static let calendar = Fixtures.calendar
    static let profile = Fixtures.intermediate()

    static func check(_ day: Int, sleep: Int, soreness: Int, stress: Int) -> ReadinessCheck {
        ReadinessCheck(
            date: Fixtures.date(2026, 9, day),
            sleepQuality: sleep, soreness: soreness, motivation: 3, stress: stress
        )
    }

    // MARK: - Situer la journée

    @Test("Le premier jour des règles est le jour un")
    func theFirstDayIsDayOne() {
        let start = Fixtures.date(2026, 9, 1)
        #expect(CycleEngine.dayOfCycle(on: start, lastPeriodStart: start, calendar: Self.calendar) == 1)
        #expect(CycleEngine.dayOfCycle(on: Fixtures.date(2026, 9, 5), lastPeriodStart: start, calendar: Self.calendar) == 5)
    }

    @Test("Le cycle se répète sans qu'on ait à ressaisir la date")
    func theCycleRepeats() {
        // Quelqu'un qui note ses règles une fois puis oublie ne doit pas se
        // retrouver au jour cent quarante.
        let start = Fixtures.date(2026, 9, 1)
        let day = CycleEngine.dayOfCycle(
            on: Fixtures.date(2026, 11, 12), lastPeriodStart: start, length: 28, calendar: Self.calendar
        )
        #expect(day >= 1 && day <= 28)
    }

    @Test("L'ovulation se compte depuis la fin, pas depuis le début")
    func ovulationIsCountedFromTheEnd() {
        // La phase lutéale dure environ quatorze jours quelle que soit la
        // longueur du cycle ; c'est la phase folliculaire qui s'étire.
        // Compter depuis le début placerait l'ovulation au mauvais jour pour
        // tout cycle qui ne fait pas vingt-huit jours.
        #expect(CycleEngine.phase(dayOfCycle: 14, length: 28) == .ovulatory)
        #expect(CycleEngine.phase(dayOfCycle: 21, length: 35) == .ovulatory)
        #expect(CycleEngine.phase(dayOfCycle: 14, length: 35) == .follicular)
    }

    @Test("Les quatre phases se suivent dans l'ordre")
    func thePhasesFollowEachOther() {
        let phases = (1...28).map { CycleEngine.phase(dayOfCycle: $0, length: 28) }
        #expect(phases.first == .menstrual)
        #expect(phases.last == .luteal)
        #expect(Set(phases) == Set(CyclePhase.allCases))
    }

    @Test("Un cycle aberrant ne casse rien")
    func absurdLengthsAreClamped() {
        // Une saisie à 3 ou à 200 ne doit pas produire une phase impossible
        // ni une division par zéro.
        for length in [1, 3, 200, 400] {
            let day = CycleEngine.dayOfCycle(
                on: Fixtures.date(2026, 9, 20), lastPeriodStart: Fixtures.date(2026, 9, 1),
                length: length, calendar: Self.calendar
            )
            #expect(day >= 1)
            _ = CycleEngine.phase(dayOfCycle: day, length: length)
        }
    }

    // MARK: - Le silence, tant qu'on n'a pas mesuré

    @Test("Sans assez de bilans, le moteur ne conclut rien")
    func itSaysNothingWithoutEnoughData() {
        // Une moyenne sur trois mesures n'est pas une moyenne, c'est une
        // anecdote avec une décimale.
        let start = Fixtures.date(2026, 9, 1)
        let pattern = CycleEngine.pattern(
            on: Fixtures.date(2026, 9, 3), lastPeriodStart: start,
            checks: [Self.check(1, sleep: 2, soreness: 4, stress: 4)],
            profile: Self.profile, calendar: Self.calendar
        )
        #expect(!pattern.isMeaningful)
        #expect(pattern.phase == .menstrual)
        #expect(pattern.message.fr.contains("Encore"))
    }

    @Test("Un écart faible n'est pas une tendance")
    func aSmallGapIsNotAPattern() {
        // Six bilans identiques à la moyenne : rien à signaler, et le dire
        // est utile — cela veut dire que l'entraînement n'a pas à en tenir
        // compte.
        let start = Fixtures.date(2026, 9, 1)
        var checks: [ReadinessCheck] = []
        // Les règles couvrent les jours 1 à 5 : pour en réunir six, il faut
        // deux cycles. Les 29 et 30 septembre sont les jours 1 et 2 du
        // suivant — c'est exactement la répétition qui donne un motif.
        for day in [1, 2, 3, 4, 5, 29, 30] {
            checks.append(Self.check(day, sleep: 3, soreness: 3, stress: 3))
        }
        let pattern = CycleEngine.pattern(
            on: Fixtures.date(2026, 9, 2), lastPeriodStart: start,
            checks: checks, profile: Self.profile, calendar: Self.calendar
        )
        #expect(pattern.samples >= CycleEngine.minimumSamples)
        #expect(!pattern.isMeaningful)
        #expect(pattern.message.fr.contains("ne change rien"))
    }

    @Test("Un écart net et nourri se dit, et se dit comme le sien")
    func aRealGapIsReported() {
        let start = Fixtures.date(2026, 9, 1)
        var checks: [ReadinessCheck] = []
        // Sept journées de règles nettement plus dures, sur deux cycles.
        for day in [1, 2, 3, 4, 5, 29, 30] {
            checks.append(Self.check(day, sleep: 1, soreness: 5, stress: 5))
        }
        // Et douze journées ordinaires ailleurs dans le cycle.
        for day in 8...19 {
            checks.append(Self.check(day, sleep: 4, soreness: 2, stress: 2))
        }
        let pattern = CycleEngine.pattern(
            on: Fixtures.date(2026, 9, 2), lastPeriodStart: start,
            checks: checks, profile: Self.profile, calendar: Self.calendar
        )
        #expect(pattern.isMeaningful)
        #expect((pattern.averageReadiness ?? 100) < (pattern.overallReadiness ?? 0))
        // Le texte parle d'elle et de ses bilans, jamais des femmes.
        #expect(pattern.message.fr.contains("chez toi") || pattern.message.fr.contains("tes journées"))
        #expect(!pattern.message.fr.lowercased().contains("les femmes"))
    }

    @Test("Le moteur ne rend aucun multiplicateur de charge")
    func itPrescribesNothing() {
        // C'est le cœur de la conception : appliquer une règle de population
        // à une personne, c'est se tromper la plupart du temps avec
        // l'assurance d'un chiffre. L'ajustement du jour reste celui du bilan
        // de forme, qui mesure la personne et pas le calendrier.
        let mirror = Mirror(reflecting: CycleEngine.pattern(
            on: Fixtures.date(2026, 9, 10), lastPeriodStart: Fixtures.date(2026, 9, 1),
            checks: [], profile: Self.profile, calendar: Self.calendar
        ))
        let names = mirror.children.compactMap(\.label)
        #expect(!names.contains { $0.lowercased().contains("multiplier") })
        #expect(!names.contains { $0.lowercased().contains("load") })
    }

    @Test("Tout ce qui s'affiche est écrit dans les trois langues")
    func everythingIsTranslated() {
        let start = Fixtures.date(2026, 9, 1)
        for day in [1, 8, 14, 22] {
            let pattern = CycleEngine.pattern(
                on: Fixtures.date(2026, 9, day), lastPeriodStart: start,
                checks: [], profile: Self.profile, calendar: Self.calendar
            )
            for language in Language.allCases {
                #expect(!pattern.message[language].isEmpty)
                #expect(!pattern.phase.label[language].isEmpty)
            }
        }
    }
}

private func cycleStorage() -> StateStorage {
    StateStorage(url: URL.temporaryDirectory.appending(path: "cycle-\(UUID().uuidString).json"))
}

/// Renseigner son cycle, de l'inscription jusqu'au moteur.
///
/// Le défaut que cette suite ferme n'était pas un manque d'écran : la
/// longueur du cycle était lue par le moteur et ne pouvait être saisie nulle
/// part. Tout le monde restait à vingt-huit jours, et comme l'ovulation se
/// compte quatorze jours avant la fin, un cycle de trente-deux voyait la
/// sienne placée quatre jours trop tôt, tous les mois, sans recours.
@MainActor
@Suite("Renseigner son cycle")
struct CycleInputTests {

    @Test("La longueur déclarée déplace vraiment l'ovulation")
    func lengthMovesOvulation() {
        // À vingt-quatre jours, le quatorzième est déjà passé après
        // l'ovulation ; à vingt-huit il est dessus ; à trente-deux elle
        // n'est pas encore arrivée.
        #expect(CycleEngine.phase(dayOfCycle: 14, length: 24) == .luteal)
        #expect(CycleEngine.phase(dayOfCycle: 14, length: 28) == .ovulatory)
        #expect(CycleEngine.phase(dayOfCycle: 14, length: 32) == .follicular)
    }

    @Test("Le magasin enregistre la longueur et la garde dans les bornes")
    func theStoreKeepsTheLength() {
        let store = CoachStore(storage: cycleStorage())
        store.completeOnboarding(with: Fixtures.intermediate())

        store.setCycleLength(32)
        #expect(store.profile?.cycleLength == 32)

        // Une valeur impossible est ramenée dans la plage plutôt que stockée
        // telle quelle : l'écran propose la bonne plage, mais un profil relu
        // d'ailleurs peut porter n'importe quoi.
        store.setCycleLength(3)
        #expect(store.profile?.cycleLength == CycleEngine.shortestLength)
        store.setCycleLength(400)
        #expect(store.profile?.cycleLength == CycleEngine.longestLength)
    }

    /// Corriger sa longueur ne doit pas coûter un bloc d'entraînement.
    @Test("Renseigner son cycle ne reconstruit pas le programme")
    func settingTheCycleKeepsThePlan() {
        let store = CoachStore(storage: cycleStorage())
        store.completeOnboarding(with: Fixtures.intermediate())

        func shape() -> [[String]] {
            guard let week = store.plan?.weeks.first else { return [] }
            return week.sessions.map { session in session.exercises.map { $0.exerciseID } }
        }
        let before = shape()

        store.setLastPeriodStart(Fixtures.date(2026, 9, 1))
        store.setCycleLength(31)

        #expect(shape() == before)
        #expect(store.cyclePattern(on: Fixtures.date(2026, 9, 10)) != nil)
    }

    /// Le chemin complet : ce que l'inscription recueille doit arriver
    /// jusqu'au moteur. Sans ce test, la réponse donnée au formulaire se
    /// perdait entre le brouillon et le profil, et il fallait la redonner
    /// dans un écran qu'on ne visite qu'en cherchant déjà quelque chose.
    @Test("Ce qui est renseigné à l'inscription arrive jusqu'au moteur")
    func theAnswerSurvivesOnboarding() {
        var draft = ProfileDraft()
        draft.firstName = "Lisa"
        draft.sex = .female
        draft.heightCm = 168
        draft.weightKg = 61
        draft.lastPeriodStart = Fixtures.date(2026, 9, 1)
        draft.cycleLength = 31

        let profile = draft.makeProfile()
        #expect(profile.lastPeriodStart == Fixtures.date(2026, 9, 1))
        #expect(profile.cycleLength == 31)

        let store = CoachStore(storage: cycleStorage())
        store.completeOnboarding(with: profile)
        let pattern = store.cyclePattern(on: Fixtures.date(2026, 9, 18))
        #expect(pattern?.dayOfCycle == 18)
        // Ovulation au dix-septième jour pour un cycle de trente et un : le
        // dix-huitième est le lendemain, donc encore ovulatoire.
        #expect(pattern?.phase == .ovulatory)
    }

    /// Décocher doit effacer, pas masquer. Une donnée intime qu'on croit
    /// retirée et qui reste enregistrée est le pire des deux mondes.
    @Test("Retirer son cycle efface la date")
    func clearingRemovesTheDate() {
        let store = CoachStore(storage: cycleStorage())
        store.completeOnboarding(with: Fixtures.intermediate())
        store.setLastPeriodStart(Fixtures.date(2026, 9, 1))
        #expect(store.cyclePattern(on: Fixtures.date(2026, 9, 10)) != nil)

        store.setLastPeriodStart(nil)
        #expect(store.profile?.lastPeriodStart == Date?.none)
        #expect(store.cyclePattern(on: Fixtures.date(2026, 9, 10)) == nil)
    }

    /// Le bug corrigé plus tôt, gardé ici parce que c'est cette suite qui
    /// perdrait le plus à le voir revenir : le formulaire ne demande pas le
    /// cycle, et reconstruisait donc un profil sans lui.
    @Test("Corriger son poids n'efface pas le cycle renseigné")
    func editingKeepsTheCycle() {
        var profile = Fixtures.intermediate()
        profile.lastPeriodStart = Fixtures.date(2026, 8, 20)
        profile.cycleLength = 33

        var draft = ProfileDraft(profile: profile)
        draft.weightKg = 80
        let updated = draft.makeProfile()

        #expect(updated.weightKg == 80)
        #expect(updated.lastPeriodStart == Fixtures.date(2026, 8, 20))
        #expect(updated.cycleLength == 33)
    }
}
