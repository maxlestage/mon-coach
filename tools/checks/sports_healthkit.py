#!/usr/bin/env python3
"""Vérifie que la table Santé ne nomme que des sports qui existent.

Pourquoi ce contrôle existe
---------------------------
`Sport+HealthKit.swift` vit entièrement derrière `#if canImport(HealthKit)`.
Sur Linux — donc dans toute la CI, donc dans les six cents tests — ce fichier
n'est **jamais compilé**. Le premier compilateur qui le lit est celui de
l'archive TestFlight, quinze minutes plus tard, après une signature et un
envoi.

C'est ce qui est arrivé au build 68 : la table renvoyait `.other` pour un
type d'entraînement inconnu. `Sport` n'a pas de cas « autre » — c'est
`SportFamily`, l'énumération juste au-dessus dans le même fichier, qui en a
un. Trois lignes d'erreur, un build perdu.

Ce contrôle-ci relit la table et compare chaque sport nommé à la liste réelle
des cas. Il ne remplace pas le compilateur : il ne vérifie ni les types
HealthKit, ni l'exhaustivité du `switch`. Il attrape la seule erreur qui a
réellement coûté un build, et il la trouve en une seconde au lieu de quinze
minutes.
"""

from __future__ import annotations

import re
import sys

SPORT = "ios/MonCoachKit/Sources/MonCoachKit/Activity/Sport.swift"
TABLE = "ios/MonCoachKit/Sources/MonCoachKit/Activity/Sport+HealthKit.swift"


def sport_cases(source: str) -> set[str]:
    """Les cas de `Sport`, et surtout pas ceux de `SportFamily`.

    L'ancre porte les deux-points de la déclaration : sans eux,
    « public enum Sport » attrape « public enum SportFamily », qui vient en
    premier dans le fichier. C'est exactement la confusion qui a produit le
    bogue — la reproduire dans le contrôle le rendrait aveugle à celui-ci.
    """
    match = re.search(r"public enum Sport\s*:", source)
    if match is None:
        raise SystemExit(f"{SPORT} : énumération Sport introuvable.")
    end = source.index("public var id: String", match.start())
    block = source[match.start():end]
    return {m.group(1) for m in re.finditer(r"\n\s*case ([a-zA-Z]+)\s*(?=\n)", block)}


def named_sports(source: str) -> set[str]:
    """Les sports que la table renvoie, membres abrégés du côté droit."""
    start = source.index("public static func from(")
    body = source[start:]
    body = body[: body.index("\n    }")]
    found = set()
    for line in body.split("\n"):
        if ":" not in line:
            continue
        right = line.split(":", 1)[1].strip()
        member = re.match(r"\.([a-zA-Z]+)$", right)
        if member:
            found.add(member.group(1))
    return found


def main() -> int:
    cases = sport_cases(open(SPORT, encoding="utf-8").read())
    used = named_sports(open(TABLE, encoding="utf-8").read())

    unknown = sorted(used - cases)
    if unknown:
        print(f"::error::{TABLE} nomme des sports qui n'existent pas : "
              f"{', '.join(unknown)}")
        print("Ce fichier n'est pas compilé sur Linux : l'erreur n'apparaîtrait")
        print("qu'à l'archive TestFlight, un quart d'heure plus tard.")
        return 1

    print(f"{len(used)} sports nommés, tous présents parmi les {len(cases)} du catalogue.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
