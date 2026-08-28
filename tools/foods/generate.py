# -*- coding: utf-8 -*-
"""Écrit les extensions du catalogue d'aliments à partir des tables.

Le générateur vérifie avant d'écrire : identifiants uniques (fichier
d'origine compris), calories cohérentes avec les macros (facteurs
d'Atwater, tolérance −20 % / +30 % — les fibres comptent moins de
4 kcal/g), régimes cohérents (ce qui convient à un végétalien convient à
un végétarien), textes complets dans les trois langues. Une table fausse
échoue ici, pas dans Xcode.

    python3 tools/foods/generate.py
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from data_animal import MEATS, SEA, DAIRY_EGGS
from data_plant import PLANT_PROTEINS, GRAINS
from data_produce import VEGETABLES, FRUITS
from data_extra import FATS, DRINKS, EXTRAS

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
NUTRITION = os.path.join(ROOT, "ios", "MonCoachKit", "Sources", "MonCoachKit", "Nutrition")

GROUPS = [
    # (nom Swift, fichier, table, en-tête)
    ("moreMeats", "FoodCatalog+Meats.swift", MEATS, "Viandes et volailles."),
    ("moreSea", "FoodCatalog+Sea.swift", SEA, "Poissons et produits de la mer."),
    ("moreDairy", "FoodCatalog+Dairy.swift", DAIRY_EGGS, "Laitages et œufs."),
    ("morePlantProteins", "FoodCatalog+PlantProteins.swift", PLANT_PROTEINS, "Protéines végétales."),
    ("moreGrains", "FoodCatalog+Grains.swift", GRAINS, "Féculents, pesés cuits comme le reste du rayon."),
    ("moreVegetables", "FoodCatalog+Vegetables.swift", VEGETABLES, "Légumes."),
    ("moreFruits", "FoodCatalog+Fruits.swift", FRUITS, "Fruits, frais et séchés."),
    ("moreFats", "FoodCatalog+Fats.swift", FATS, "Matières grasses et oléagineux."),
    ("moreDrinks", "FoodCatalog+Drinks.swift", DRINKS, "Boissons."),
    ("moreExtras", "FoodCatalog+Extras.swift", EXTRAS, "Condiments et plaisirs."),
]

VALID_DIETS = {"omnivore", "vegetarian", "vegan", "pescatarian", "halal", "glutenFree"}
VALID_ROLES = {"protein", "carb", "vegetable", "fruit", "fat", "dairy", "drink", "treat"}
VALID_TIERS = {"base", "moderate", "occasional"}


def existing_ids():
    path = os.path.join(NUTRITION, "FoodCatalog.swift")
    with io.open(path, encoding="utf-8") as handle:
        return set(re.findall(r'id: "([a-z0-9-]+)"', handle.read()))


def check(rows):
    problems = []
    seen = existing_ids()
    for row in rows:
        (fid, fr, en, es, role, tier, kcal, prot, carbs, fat, fiber, alc,
         portion, diets, rfr, ren, res) = row
        if fid in seen:
            problems.append(f"{fid} : identifiant déjà pris")
        seen.add(fid)
        if role not in VALID_ROLES:
            problems.append(f"{fid} : rôle inconnu {role}")
        if tier not in VALID_TIERS:
            problems.append(f"{fid} : rang inconnu {tier}")
        if not set(diets) <= VALID_DIETS:
            problems.append(f"{fid} : régime inconnu {set(diets) - VALID_DIETS}")
        if "vegan" in diets and not {"vegetarian", "pescatarian", "omnivore"} <= set(diets):
            problems.append(f"{fid} : végétalien doit convenir aux régimes moins stricts")
        if "vegetarian" in diets and not {"pescatarian", "omnivore"} <= set(diets):
            problems.append(f"{fid} : végétarien doit convenir au pescétarien et à l'omnivore")
        if kcal > 20:
            atwater = prot * 4 + carbs * 4 + fat * 9 + alc * 7
            drift = (atwater - kcal) / kcal
            if not (-0.20 < drift < 0.30):
                problems.append(f"{fid} : écart d'Atwater {drift:+.0%} ({atwater:.0f} vs {kcal})")
        if portion <= 0:
            problems.append(f"{fid} : portion nulle")
        for text in (fr, en, es, rfr, ren, res):
            if not text.strip():
                problems.append(f"{fid} : texte vide")
    return problems


def swift_number(value):
    return str(int(value)) if float(value) == int(value) else f"{value}"


def swift_text(text):
    return text.replace("\\", "\\\\").replace('"', '\\"')


def entry(row):
    (fid, fr, en, es, role, tier, kcal, prot, carbs, fat, fiber, alc,
     portion, diets, rfr, ren, res) = row
    diet_list = ", ".join(f".{d}" for d in diets)
    alcohol = "" if alc == 0 else f", alcoholG: {swift_number(alc)}"
    return f'''        Food(
            id: "{fid}",
            name: LocalizedText(fr: "{swift_text(fr)}", en: "{swift_text(en)}", es: "{swift_text(es)}"),
            role: .{role}, tier: .{tier},
            kcal: {swift_number(kcal)}, proteinG: {swift_number(prot)}, carbsG: {swift_number(carbs)}, fatG: {swift_number(fat)}, fiberG: {swift_number(fiber)}{alcohol},
            portionG: {swift_number(portion)},
            diets: [{diet_list}],
            reason: LocalizedText(
                fr: "{swift_text(rfr)}",
                en: "{swift_text(ren)}",
                es: "{swift_text(res)}"
            )
        )'''


def main():
    rows = [row for _, _, table, _ in GROUPS for row in table]
    problems = check(rows)
    if problems:
        for problem in problems:
            print("ERREUR :", problem)
        raise SystemExit(1)

    written = []
    for name, filename, table, header in GROUPS:
        body = ",\n".join(entry(row) for row in table)
        content = f'''import Foundation

// Généré par tools/foods/generate.py — ne pas éditer à la main : la table
// source vit dans tools/foods/, avec les vérifications qui vont avec.
// {header}
extension FoodCatalog {{
    static let {name}: [Food] = [
{body},
    ]
}}
'''
        path = os.path.join(NUTRITION, filename)
        with io.open(path, "w", encoding="utf-8") as handle:
            handle.write(content)
        written.append((filename, len(table)))

    total = sum(count for _, count in written)
    for filename, count in written:
        print(f"  {filename}: {count}")
    print(f"{total} aliments générés")


if __name__ == "__main__":
    main()
