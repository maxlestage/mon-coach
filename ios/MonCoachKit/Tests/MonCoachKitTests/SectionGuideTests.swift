import Foundation
import Testing
@testable import MonCoachKit

@Suite("Le guide de chaque section")
struct SectionGuideTests {

    @Test("Chaque section de l'application a son guide")
    func everySectionIsCovered() {
        let missing = AppSection.allCases
            .filter { section in !SectionGuides.all.contains { $0.section == section } }
            .map(\.rawValue)
        #expect(missing.isEmpty, Comment(rawValue: "sans guide : \(missing)"))
        #expect(SectionGuides.all.count == AppSection.allCases.count)
    }

    @Test("Aucune section n'est décrite deux fois")
    func noDuplicateSection() {
        let sections = SectionGuides.all.map(\.section)
        #expect(Set(sections).count == sections.count)
    }

    @Test("Chaque guide dit ce qu'on fait, ce qui tourne derrière, et ce qu'il ne fait pas")
    func everyGuideIsComplete() {
        var thin: [String] = []
        for guide in SectionGuides.all {
            if guide.steps.isEmpty { thin.append("\(guide.section.rawValue) : aucun geste") }
            if guide.engine.isEmpty { thin.append("\(guide.section.rawValue) : aucun mécanisme") }
            // Les limites sont la partie qu'aucune application ne met, et
            // c'est précisément celle qu'on tient à garder.
            if guide.limits.isEmpty { thin.append("\(guide.section.rawValue) : aucune limite") }
        }
        #expect(thin.isEmpty, Comment(rawValue: "incomplets : \(thin)"))
    }

    @Test("Les gestes sont numérotés dans l'ordre, à partir de un")
    func stepsAreNumbered() {
        for guide in SectionGuides.all {
            let indices = guide.steps.map(\.index)
            #expect(
                indices == Array(1...guide.steps.count),
                Comment(rawValue: "\(guide.section.rawValue) : \(indices)")
            )
        }
    }

    @Test("Les trois langues sont remplies partout")
    func everyLanguageIsWritten() {
        var empty: [String] = []
        for guide in SectionGuides.all {
            for language in Language.allCases {
                if guide.tagline[language].isEmpty {
                    empty.append("\(guide.section.rawValue).tagline.\(language.rawValue)")
                }
                for step in guide.steps {
                    if step.action[language].isEmpty || step.result[language].isEmpty {
                        empty.append("\(guide.section.rawValue).step\(step.index).\(language.rawValue)")
                    }
                }
                for (index, text) in guide.engine.enumerated() where text[language].isEmpty {
                    empty.append("\(guide.section.rawValue).engine\(index).\(language.rawValue)")
                }
                for (index, text) in guide.limits.enumerated() where text[language].isEmpty {
                    empty.append("\(guide.section.rawValue).limit\(index).\(language.rawValue)")
                }
            }
        }
        #expect(empty.isEmpty, Comment(rawValue: "vides : \(empty)"))
    }

    @Test("Deux sections ne partagent jamais la même phrase")
    func noCopyPasteBetweenSections() {
        var seen: [String: String] = [:]
        var duplicates: [String] = []
        for guide in SectionGuides.all {
            for text in [guide.tagline] + guide.engine + guide.limits {
                if let first = seen[text.fr] {
                    duplicates.append("\(first) == \(guide.section.rawValue)")
                } else {
                    seen[text.fr] = guide.section.rawValue
                }
            }
        }
        #expect(duplicates.isEmpty, Comment(rawValue: "recopiées : \(duplicates)"))
    }

    @Test("Une section inconnue ne fait pas tomber l'écran")
    func lookupNeverFails() {
        for section in AppSection.allCases {
            #expect(SectionGuides.guide(for: section).section == section)
        }
    }
}

@Suite("Les avantages, et leur preuve")
struct BenefitsTests {

    @Test("Chaque avantage porte son mécanisme")
    func everyBenefitHasItsProof() {
        var weak: [String] = []
        for benefit in Benefits.all {
            // Une promesse sans mécanisme est une phrase de publicité. Le
            // seuil est grossier exprès : il attrape la case laissée vide ou
            // remplie d'un adjectif, pas une formulation courte et juste.
            if benefit.proof.fr.count < 80 { weak.append("\(benefit.id) (\(benefit.proof.fr.count) signes)") }
            if benefit.promise.fr.isEmpty { weak.append("\(benefit.id) : promesse vide") }
        }
        #expect(weak.isEmpty, Comment(rawValue: "sans preuve : \(weak)"))
    }

    @Test("Les avantages ont des identifiants uniques")
    func identifiersAreUnique() {
        let ids = Benefits.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test("Les trois langues sont remplies")
    func everyLanguageIsWritten() {
        var empty: [String] = []
        for benefit in Benefits.all {
            for language in Language.allCases {
                for (field, text) in [
                    ("title", benefit.title), ("promise", benefit.promise), ("proof", benefit.proof),
                ] where text[language].isEmpty {
                    empty.append("\(benefit.id).\(field).\(language.rawValue)")
                }
            }
        }
        for (index, text) in Benefits.refusals.enumerated() {
            for language in Language.allCases where text[language].isEmpty {
                empty.append("refus\(index).\(language.rawValue)")
            }
        }
        #expect(empty.isEmpty, Comment(rawValue: "vides : \(empty)"))
    }

    @Test("Chaque section de l'application est représentée par au moins un avantage")
    func everySectionHasABenefit() {
        // Un onglet dont aucun avantage ne parle est un onglet dont on ne
        // sait pas quoi dire — c'est le signe qu'il manque quelque chose,
        // dans la liste ou dans le produit.
        let covered = Set(Benefits.all.compactMap(\.section))
        let missing = AppSection.allCases.filter { !covered.contains($0) }.map(\.rawValue)
        #expect(missing.isEmpty, Comment(rawValue: "sans avantage : \(missing)"))
    }

    @Test("Ce qui est promis gratuit et ce qui demande Stride+ ne se recouvrent pas")
    func freeAndPaidStaySeparate() {
        // Les deux listes sont écrites à la main dans deux fichiers : rien
        // n'empêche mécaniquement d'annoncer la même chose des deux côtés,
        // sauf ce test.
        let free = Set(AlwaysFree.promises.map(\.fr))
        let paid = Set(PlusFeature.allCases.map(\.label.fr))
        #expect(free.intersection(paid).isEmpty)
        #expect(!AlwaysFree.promises.isEmpty)
        #expect(!PlusFeature.allCases.isEmpty)
    }

    @Test("Les refus sont dits noir sur blanc")
    func refusalsAreStated() {
        #expect(Benefits.refusals.count >= 4)
        let distinct = Set(Benefits.refusals.map(\.fr)).count
        #expect(distinct == Benefits.refusals.count)
    }
}
