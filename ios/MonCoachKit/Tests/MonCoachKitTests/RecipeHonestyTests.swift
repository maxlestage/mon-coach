import Foundation
import Testing
@testable import MonCoachKit

/// Un plat doit contenir ce que son nom annonce.
///
/// Pourquoi ce test existe
/// -----------------------
/// « Crevettes à l'ail, riz basmati » avec, en dessous, crevettes, riz,
/// poivrons, tomates et huile d'olive. Pas d'ail. Le plat n'est pas faux —
/// on met bien de l'ail dedans, l'étape le dit — mais la liste ment, et
/// c'est elle qui fabrique la liste de courses : on rentre sans ail.
///
/// Deux cents cinquante plats se relisent mal à l'œil, et se relisent une
/// fois. Un test les relit à chaque commit.
///
/// Comment il s'y prend
/// --------------------
/// Chaque mot du titre doit être couvert par quelque chose : un aliment du
/// plat, un aromate déclaré, ou un mot de cuisine — une cuisson, une forme,
/// une origine. Cette dernière liste est écrite ici en clair plutôt que
/// devinée : « brouillé » et « basquaise » ne sont pas des ingrédients, et
/// le seul moyen honnête de le dire est de le dire.
@Suite("Les plats contiennent ce que leur nom annonce")
struct RecipeHonestyTests {

    /// Les mots d'un titre qui ne nomment aucun aliment.
    ///
    /// Trois familles : la grammaire, la cuisson et la forme, l'origine. Un
    /// mot ajouté ici est une promesse en moins : on ne l'ajoute que s'il ne
    /// désigne vraiment rien qu'on puisse acheter.
    static let culinaryWords: Set<String> = [
        // Grammaire
        "a", "au", "aux", "avec", "de", "des", "du", "en", "et", "l", "la",
        "le", "les", "sur", "un", "une", "d", "sans",
        // Cuisson et température
        "grille", "grillee", "grillees", "grilles", "roti", "rotie", "roties",
        "rotis", "saute", "sautee", "sautees", "sautes", "poele", "poelee",
        "poelees", "vapeur", "four", "braise", "braisee", "braisees",
        "mijote", "mijotee", "mijotees", "confit", "confite", "poche",
        "pochee", "dur", "durs", "dure", "coque", "brouille", "brouillee",
        "brouilles", "ecrase", "ecrasee", "ecrasees", "fondu", "fondue",
        "froid", "froide", "froids", "froides", "chaud", "chaude", "tiede",
        "tiedes", "cru", "crue", "crus", "crues", "fume", "fumee", "fumes",
        "fumees", "marine", "marinee", "marinees", "pane", "panee", "panees",
        "laque", "laquee", "rapee", "rapees", "nouveaux", "nouvelles",
        // Forme et service
        "matin", "midi", "soir", "nuit", "veille", "lendemain",
        "maison", "express", "minute", "rapide", "simple", "facon", "style",
        "maniere", "bol", "assiette", "plat", "plateau", "bowl", "wrap",
        "sandwich", "tartine", "tartines", "toast", "toasts", "salade",
        "salades", "soupe", "veloute", "puree", "gratin", "gratine",
        "omelette", "crepes", "crepe", "galette", "galettes", "pancakes",
        "pancake", "porridge", "muesli", "smoothie", "compote", "boulettes",
        "boulette", "hachis", "mouillettes", "crudites", "legumes", "creme",
        "cremeuse", "cremeuses", "sauce", "jus", "bouillon", "marinade",
        "vinaigrette", "pesto", "risotto", "proteine", "proteines",
        "proteinee", "proteines", "entier", "entiere", "entiers", "entieres",
        "complet", "complete", "complets", "completes", "petit", "petite",
        "petits", "petites", "grand", "grande", "gros", "grosse", "sec",
        "seche", "secs", "seches", "frais", "fraiche", "fraiches",
        // Noms de plats et origines
        "basquaise", "cajun", "meuniere", "mariniere", "teriyaki",
        "bolognaise", "tandoori", "shakshuka", "tortilla", "chili", "dahl",
        "tajine", "wok", "poke", "curry", "epices", "epice", "herbes",
        "aigre", "doux", "corail",
    ]

    /// Le titre, réduit à ses mots comparables.
    static func words(_ text: String) -> [String] {
        let folded = text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: Locale(identifier: "fr"))
            .replacingOccurrences(of: "œ", with: "oe")
        var current = ""
        var out: [String] = []
        for character in folded {
            if character.isLetter || character.isNumber {
                current.append(character)
            } else if !current.isEmpty {
                out.append(current)
                current = ""
            }
        }
        if !current.isEmpty { out.append(current) }
        return out
    }

    /// Deux mots désignent-ils la même chose ?
    ///
    /// Comparaison par le début, sur six lettres au plus : « tomate » et
    /// « tomates », « poulet » et « poulets » se rejoignent, sans que
    /// « poivron » n'attrape « poire ».
    static func sameThing(_ a: String, _ b: String) -> Bool {
        guard a.count >= 4, b.count >= 4 else { return a == b }
        let length = min(a.count, b.count, 6)
        return a.prefix(length) == b.prefix(length)
    }

    @Test("Chaque mot d'un titre nomme un aliment du plat, un aromate, ou une façon de le faire")
    func everyTitleWordIsCovered() {
        var wrong: [String] = []
        for recipe in RecipeCatalog.all {
            guard let foods = recipe.foods else { continue }
            var pool = foods.flatMap { Self.words($0.name.fr) }
            pool += recipe.seasonings.flatMap { Self.words($0.fr) }
            for word in Self.words(recipe.name.fr) where word.count >= 3 {
                if Self.culinaryWords.contains(word) { continue }
                if pool.contains(where: { Self.sameThing(word, $0) }) { continue }
                wrong.append("\(recipe.id) : « \(recipe.name.fr) » promet « \(word) », absent des ingrédients")
            }
        }
        #expect(wrong.isEmpty, Comment(rawValue: wrong.joined(separator: "\n")))
    }

    @Test("Un aromate déclaré est nommé dans les trois langues")
    func seasoningsAreTranslated() {
        var empty: [String] = []
        for recipe in RecipeCatalog.all {
            for (index, seasoning) in recipe.seasonings.enumerated() {
                for language in Language.allCases where seasoning[language].isEmpty {
                    empty.append("\(recipe.id).aromate\(index).\(language.rawValue)")
                }
            }
        }
        #expect(empty.isEmpty, Comment(rawValue: "vides : \(empty)"))
    }

    @Test("Un aromate ne cache pas un aliment qui pèse")
    func seasoningsHideNothingSubstantial() {
        // La liste des aromates ne doit pas devenir une porte de sortie pour
        // éviter de compter. La ligne est tracée là où elle est vérifiable :
        // une protéine, un féculent ou une matière grasse déplacent les
        // macros de la journée, et n'ont donc rien à faire ici — un blanc de
        // poulet « en assaisonnement » serait une journée fausse de deux
        // cents calories.
        //
        // Un citron pressé et une cuillère de moutarde sont au catalogue et
        // restent des aromates : ils s'achètent, ils se nomment, et la
        // quantité réellement mangée ne bouge rien. Prétendre les peser
        // serait une précision inventée, pas une précision de plus.
        let weighty: Set<FoodRole> = [.protein, .carb, .fat]
        var suspicious: [String] = []
        for recipe in RecipeCatalog.all {
            for seasoning in recipe.seasonings {
                let words = Self.words(seasoning.fr)
                for food in FoodCatalog.all where weighty.contains(food.role) {
                    if words == Self.words(food.name.fr) {
                        suspicious.append("\(recipe.id) : « \(seasoning.fr) » pèse dans la journée, il doit être un ingrédient")
                    }
                }
            }
        }
        #expect(suspicious.isEmpty, Comment(rawValue: suspicious.joined(separator: "\n")))
    }

    @Test("Un aromate s'achète : il ne se confond pas avec un ingrédient du plat")
    func seasoningsAreNotAlreadyInTheDish() {
        // Déclarer « tomate » en aromate d'un plat qui pèse déjà des tomates
        // ferait acheter deux fois la même chose, et laisserait croire que le
        // titre est couvert alors qu'il l'était déjà.
        var doubled: [String] = []
        for recipe in RecipeCatalog.all {
            let foods = (recipe.foods ?? []).flatMap { Self.words($0.name.fr) }
            for seasoning in recipe.seasonings {
                for word in Self.words(seasoning.fr) where word.count >= 4 {
                    if foods.contains(where: { Self.sameThing(word, $0) }) {
                        doubled.append("\(recipe.id) : « \(seasoning.fr) » est déjà un ingrédient")
                    }
                }
            }
        }
        #expect(doubled.isEmpty, Comment(rawValue: doubled.joined(separator: "\n")))
    }

    @Test("Chaque plat porte encore ses quatre places et ses étapes")
    func recipesStayComplete() {
        for recipe in RecipeCatalog.all {
            #expect(!recipe.steps.isEmpty, Comment(rawValue: "\(recipe.id) sans étapes"))
            #expect(recipe.foods != nil, Comment(rawValue: "\(recipe.id) cite un aliment inconnu"))
            #expect(recipe.minutes > 0, Comment(rawValue: "\(recipe.id) sans durée"))
        }
    }

    /// Les aromates qu'une étape peut nommer, et qui s'achètent.
    ///
    /// Le sel et le poivre n'y sont pas, volontairement : personne ne fait un
    /// détour pour eux, et les faire apparaître à chaque plat noierait la
    /// liste de courses sous du bruit. Tout le reste se trouve au rayon, se
    /// paie, et manque cruellement quand on rentre sans.
    static let buyableSeasonings: [String: [String]] = [
        "Ail": ["ail"],
        "Oignon": ["oignon", "oignons"],
        "Citron": ["citron", "citrons"],
        "Vinaigre": ["vinaigre"],
        "Cumin": ["cumin"],
        "Sauce soja": ["soja"],
        "Paprika": ["paprika"],
        "Gingembre": ["gingembre"],
        "Curry": ["curry"],
        "Miel": ["miel"],
        "Moutarde": ["moutarde"],
        "Coriandre": ["coriandre"],
        "Menthe": ["menthe"],
        "Basilic": ["basilic"],
        "Persil": ["persil"],
        "Estragon": ["estragon"],
        "Thym": ["thym"],
        "Romarin": ["romarin"],
        "Cannelle": ["cannelle"],
        "Curcuma": ["curcuma"],
        "Safran": ["safran"],
        "Miso": ["miso"],
        "Graines de sésame": ["sesame"],
        "Harissa": ["harissa"],
        "Cacao amer": ["cacao"],
        "Vanille": ["vanille"],
        "Laurier": ["laurier"],
        "Muscade": ["muscade"],
        "Origan": ["origan"],
        "Aneth": ["aneth"],
        "Ciboulette": ["ciboulette"],
        "Sriracha": ["sriracha"],
        "Tahini": ["tahini"],
        "Anchois": ["anchois"],
        "Câpres": ["capres", "capre"],
        "Cornichons": ["cornichon", "cornichons"],
    ]

    @Test("Ce qu'une étape demande d'ajouter se trouve dans la liste de courses")
    func stepsAskForNothingUnlisted() {
        // Le titre n'est pas le seul endroit où un plat promet quelque chose.
        // « Sauce soja, un peu de miel, gingembre râpé » est une instruction
        // parfaitement claire, et parfaitement inutile à qui fait ses courses
        // avec une liste qui n'en porte aucun des trois. Le défaut est le même
        // que celui du titre, une couche plus bas, et il se répare pareil :
        // ce que l'étape nomme, la liste le porte.
        var missing: [String] = []
        for recipe in RecipeCatalog.all {
            var known = (recipe.foods ?? []).flatMap { Self.words($0.name.fr) }
            known += recipe.seasonings.flatMap { Self.words($0.fr) }
            let spoken = Set(recipe.steps.flatMap { Self.words($0.fr) })
            for (seasoning, forms) in Self.buyableSeasonings {
                guard forms.contains(where: spoken.contains) else { continue }
                let covered = forms.contains { form in
                    known.contains { Self.sameThing(form, $0) }
                }
                if !covered {
                    missing.append("\(recipe.id) : une étape demande « \(seasoning) », absent de la liste")
                }
            }
        }
        #expect(missing.isEmpty, Comment(rawValue: missing.sorted().joined(separator: "\n")))
    }
}
