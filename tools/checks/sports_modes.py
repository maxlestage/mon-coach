#!/usr/bin/env python3
"""Chaque mode de déplacement est réglé côté CoreLocation.

Pourquoi ce contrôle existe
---------------------------
`LocationTracker.swift` vit derrière `#if canImport(CoreLocation)`. Sur
Linux — donc dans toute la CI Swift, donc dans les sept cents tests — il
n'est **jamais compilé**. Son `switch` sur le mode de déplacement n'est lu
que par le compilateur macOS, deux minutes plus tard, ou par celui de
l'archive TestFlight, un quart d'heure plus tard.

C'est exactement ce qui est arrivé en ajoutant le mode motorisé : le paquet
compilait, les tests passaient, et le job macOS a refusé le build sur un
`switch must be exhaustive`. Le même défaut que celui qui avait coûté le
build 68 sur la table Santé, dans le même angle mort.

Ce contrôle relit la liste des modes et vérifie que chacun est nommé dans le
réglage de CoreLocation. Il ne remplace pas le compilateur : il attrape en
quinze secondes la seule erreur qui se produit vraiment ici, l'oubli d'un
cas dans un fichier qu'aucun test ne lit.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPORT = ROOT / "ios/MonCoachKit/Sources/MonCoachKit/Activity/Sport.swift"
TRACKER = ROOT / "ios/MonCoachKit/Sources/MonCoachKit/Activity/LocationTracker.swift"


def modes(source: str) -> set[str]:
    """Les cas de `SportMode`, et rien d'autre."""
    match = re.search(r"public enum SportMode\s*:", source)
    if match is None:
        raise SystemExit(f"{SPORT} : énumération SportMode introuvable.")
    # Le saut de ligne ajouté n'est pas cosmétique : sans lui, le dernier
    # cas de l'énumération — collé à l'accolade fermante — échappe au
    # lookahead, et le contrôle serait aveugle à celui qu'on vient d'ajouter.
    block = source[match.start():source.index("\n}", match.start())] + "\n"
    return {m.group(1) for m in re.finditer(r"\n\s*case ([a-zA-Z]+)\s*(?=\n)", block)}


def configured(source: str) -> set[str]:
    """Les modes nommés dans le réglage de CoreLocation."""
    start = source.index("private func configure(for sport: Sport)")
    body = source[start:]
    body = body[: body.index("\n    }")]
    return {m.group(1) for m in re.finditer(r"case ([^:\n]+):", body)
            for m in re.finditer(r"\.([a-zA-Z]+)", m.group(1))}


def main() -> int:
    known = modes(SPORT.read_text(encoding="utf-8"))
    seen = configured(TRACKER.read_text(encoding="utf-8"))

    missing = sorted(known - seen)
    if missing:
        print(f"::error::{TRACKER.name} ne règle pas CoreLocation pour :"
              f" {', '.join(missing)}")
        print("Ce fichier n'est pas compilé sur Linux : l'erreur n'apparaîtrait")
        print("qu'au job macOS, deux minutes plus tard.")
        return 1

    unknown = sorted(seen - known)
    if unknown:
        print(f"::error::{TRACKER.name} nomme des modes qui n'existent pas :"
              f" {', '.join(unknown)}")
        return 1

    print(f"{len(known)} modes de déplacement, tous réglés côté CoreLocation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
