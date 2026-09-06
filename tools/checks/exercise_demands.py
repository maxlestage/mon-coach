#!/usr/bin/env python3
"""Chaque mouvement du catalogue dit ce qu'il exige du corps.

Pourquoi ce contrôle existe
---------------------------
`Exercise.demands` a une valeur par défaut vide, et il le faut : sans elle,
ajouter une exigence au modèle aurait cassé les quatre-vingt-douze appels
d'un coup. Mais cette commodité a un prix exact — un exercice ajouté sans
y penser déclare « je n'exige rien du corps », donc reste proposé à tout le
monde, y compris à quelqu'un qui ne peut pas l'exécuter.

Ce défaut-là ne lève aucune erreur. Il ne fait pas échouer un test, ne
plante pas l'application, ne rougit aucun job : il propose un squat barre à
quelqu'un qui ne se lève pas, une fois, et cette personne n'ouvre plus
l'onglet. C'est la définition d'un défaut qu'il faut attraper à l'écriture.

Le contrôle relit les deux fichiers du catalogue et vérifie que chaque
`Exercise(` déclare `demands:`. Il ne juge pas la valeur — un humain seul
sait si une fente exige l'équilibre — il vérifie que la question a été
posée. Les tests Swift, eux, vérifient la cohérence de ce qui est déclaré :
une barre à deux mains qui n'exigerait pas les deux bras, « un bras » et
« les deux bras » déclarés ensemble.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOGUE = ROOT / "ios/MonCoachKit/Sources/MonCoachKit/Catalog"
FILES = ["ExerciseCatalog.swift", "GymExercises.swift", "AdaptiveExercises.swift"]

BLOCK = re.compile(r"Exercise\(\s*\n(.*?)\n        \)", re.S)


def main() -> int:
    silent: list[str] = []
    total = 0

    for name in FILES:
        path = CATALOGUE / name
        if not path.exists():
            print(f"::error::{name} est introuvable : le catalogue a bougé.")
            return 1
        source = path.read_text(encoding="utf-8")
        blocks = BLOCK.findall(source)
        if not blocks:
            print(f"::error::aucun exercice lu dans {name} :"
                  " la forme du fichier a changé et ce contrôle est devenu aveugle.")
            return 1
        for body in blocks:
            total += 1
            found = re.search(r'id: "([^"]+)"', body)
            identifier = found.group(1) if found else "sans identifiant"
            if "demands:" not in body:
                silent.append(f"{name} : {identifier}")

    if silent:
        print("::error::des mouvements ne disent pas ce qu'ils exigent du corps :")
        for entry in silent:
            print(f"  {entry}")
        print("Ajoute `demands:` — la liste vide se déclare explicitement,")
        print("elle veut dire « ce mouvement n'exige rien », pas « je n'ai pas regardé ».")
        return 1

    print(f"{total} mouvements, tous déclarent ce qu'ils exigent du corps.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
