import Foundation
import Testing
@testable import MonCoachKit

@Suite("Chaque exercice a sa fiche")
struct ExerciseBriefCoverageTests {

    @Test("Aucun mouvement du catalogue n'est laissé sans fiche")
    func everyExerciseHasABrief() {
        // C'est le verrou : un quatre-vingt-treizième exercice ajouté un
        // mardi sans fiche fait tomber ce test, et pas l'écran d'un athlète
        // qui découvre une machine.
        let missing = ExerciseCatalog.all
            .filter { ExerciseBriefs.brief(for: $0) == nil }
            .map(\.id)
            .sorted()
        #expect(missing.isEmpty, Comment(rawValue: "sans fiche : \(missing)"))
        #expect(ExerciseBriefs.all.count == ExerciseCatalog.all.count)
    }

    @Test("Aucune fiche ne décrit un exercice qui n'existe pas")
    func noOrphanBriefs() {
        let orphans = ExerciseBriefs.all.keys
            .filter { ExerciseCatalog.exercise(id: $0) == nil }
            .sorted()
        #expect(orphans.isEmpty, Comment(rawValue: "fiches orphelines : \(orphans)"))
    }

    @Test("Les trois langues sont remplies partout")
    func everyLanguageIsWritten() {
        var incomplete: [String] = []
        for brief in ExerciseBriefs.all.values {
            for language in Language.allCases {
                for (field, text) in [
                    ("what", brief.what), ("setup", brief.setup), ("watchOut", brief.watchOut),
                ] where text[language].trimmingCharacters(in: .whitespaces).isEmpty {
                    incomplete.append("\(brief.id).\(field).\(language.rawValue)")
                }
            }
        }
        #expect(incomplete.isEmpty, Comment(rawValue: "vides : \(incomplete.sorted())"))
    }

    @Test("Aucune fiche n'est une ébauche")
    func briefsSayEnough() {
        // Une phrase de trente signes n'explique rien, et c'est exactement la
        // forme que prend une fiche écrite à la va-vite pour faire passer le
        // test de couverture.
        var thin: [String] = []
        for brief in ExerciseBriefs.all.values {
            for (field, text) in [
                ("what", brief.what), ("setup", brief.setup), ("watchOut", brief.watchOut),
            ] where text.fr.count < 90 {
                thin.append("\(brief.id).\(field) (\(text.fr.count) signes)")
            }
        }
        #expect(thin.isEmpty, Comment(rawValue: "trop courtes : \(thin.sorted())"))
    }

    @Test("Deux exercices ne partagent jamais la même explication")
    func noCopyPaste() {
        // Le vrai risque d'un catalogue de quatre-vingt-douze fiches n'est pas
        // l'oubli — il se voit — mais le copier-coller, qui passe inaperçu et
        // vide l'exercice de tout ce qu'il avait de spécifique.
        var seen: [String: String] = [:]
        var duplicates: [String] = []
        for brief in ExerciseBriefs.all.values.sorted(by: { $0.id < $1.id }) {
            for (field, text) in [
                ("what", brief.what), ("setup", brief.setup), ("watchOut", brief.watchOut),
            ] {
                let key = "\(field)|\(text.fr)"
                if let first = seen[key] {
                    duplicates.append("\(field) : \(first) == \(brief.id)")
                } else {
                    seen[key] = brief.id
                }
            }
        }
        #expect(duplicates.isEmpty, Comment(rawValue: "recopiées : \(duplicates)"))
    }
}

@Suite("Ce que la fiche déduit du catalogue")
struct ExerciseBriefDerivationTests {

    private func exercise(_ id: String) throws -> Exercise {
        try #require(ExerciseCatalog.exercise(id: id))
    }

    @Test("Les muscles suivent la même règle que le volume hebdomadaire")
    func musclesMatchVolumeCredit() throws {
        let squat = try exercise("back-squat")
        let shares = ExerciseBriefs.muscles(of: squat)
        #expect(shares.first?.muscle == squat.primaryMuscle)
        #expect(shares.first?.percent == 100)
        // Un secondaire compte pour moitié, ici comme dans le tableau de
        // bord : deux endroits qui compteraient différemment finiraient par
        // se contredire à l'écran.
        #expect(shares.dropFirst().allSatisfy { $0.percent == 50 })
    }

    @Test("Les remplaçants partagent le schéma et le muscle principal")
    func alternativesStayInFamily() throws {
        let squat = try exercise("back-squat")
        let others = ExerciseBriefs.alternatives(to: squat)
        #expect(!others.isEmpty)
        #expect(others.allSatisfy { $0.id != squat.id })
        #expect(others.allSatisfy { $0.pattern == squat.pattern })
        #expect(others.allSatisfy { $0.primaryMuscle == squat.primaryMuscle })
    }

    @Test("Les remplaçants tiennent compte du matériel qu'on a")
    func alternativesRespectEquipment() throws {
        let squat = try exercise("back-squat")
        let athome = ExerciseBriefs.alternatives(to: squat, owning: [.bodyweight])
        #expect(athome.allSatisfy { $0.isAvailable(with: [.bodyweight]) })
        // Sans matériel, le squat au poids du corps doit rester proposé :
        // sinon la fiche envoie quelqu'un à la salle pour rien.
        #expect(athome.contains { $0.id == "bodyweight-squat" })
    }

    @Test("Le conseil de charge reprend la fourchette de l'exercice")
    func loadAdviceQuotesTheRange() throws {
        let raise = try exercise("lateral-raise")
        let text = ExerciseBriefs.loadAdvice(for: raise).fr
        #expect(text.contains("\(raise.viableRepRange.lowerBound)"))
        #expect(text.contains("\(raise.viableRepRange.upperBound)"))
    }

    @Test("Un mouvement à un côté à la fois le dit")
    func unilateralIsNamed() throws {
        let row = try exercise("one-arm-dumbbell-row")
        #expect(ExerciseBriefs.loadAdvice(for: row).fr.contains("de chaque côté"))
        #expect(!ExerciseBriefs.loadAdvice(for: try exercise("bench-press")).fr.contains("de chaque côté"))
    }

    @Test("Le repos se dit en minutes quand il dépasse la minute et demie")
    func restIsSpokenPlainly() throws {
        let squat = try exercise("back-squat")
        let raise = try exercise("lateral-raise")
        #expect(ExerciseBriefs.restAdvice(for: squat).fr.contains("minute"))
        #expect(ExerciseBriefs.restAdvice(for: raise).fr.contains("seconde"))
    }

    @Test("Le rôle dans la séance distingue les basiques des isolations")
    func roleSeparatesCompoundsFromIsolation() throws {
        let squat = try exercise("back-squat")
        let raise = try exercise("lateral-raise")
        #expect(ExerciseBriefs.role(of: squat).fr != ExerciseBriefs.role(of: raise).fr)
        #expect(ExerciseBriefs.role(of: raise).fr.contains("isolation"))
    }

    @Test("Le matériel annoncé est celui que l'exercice réclame")
    func equipmentIsTheRealOne() throws {
        let press = try exercise("leg-press")
        #expect(Set(ExerciseBriefs.equipmentNeeded(for: press)) == press.equipment)
    }
}
