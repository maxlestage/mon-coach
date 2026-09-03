#!/usr/bin/env python3
"""Le catalogue des sports et la liste que Siri propose disent la même chose.

Pourquoi ce contrôle existe
---------------------------
`Sport` vit dans MonCoachKit. App Intents refuse d'en faire un `AppEnum` :
son processeur de métadonnées ne lit pas les enums d'une bibliothèque
importée, et n'accepte que des noms écrits littéralement, qu'il puisse
extraire sans exécuter de code. L'application porte donc une seconde liste,
`ActivitySport`.

Deux listes qui doivent rester identiques et que rien ne relie, c'est une
divergence qui finit par arriver. Elle ne casserait rien au compilateur :
elle se verrait le jour où quelqu'un demanderait à Siri un sport ajouté
depuis, et s'entendrait répondre non.

Le contrôle compare donc les identifiants bruts des deux côtés, et exige que
chaque sport de la liste des intentions porte un nom affichable.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOGUE = ROOT / "ios/MonCoachKit/Sources/MonCoachKit/Activity/Sport.swift"
INTENTS = ROOT / "ios/MonCoach/MonCoach/App/ActivitySport.swift"


def catalogue_sports(source: str) -> list[str]:
    """Les cas de `Sport`, et d'aucun autre enum du fichier.

    L'ancre porte le deux-points : sans lui, `public enum SportFamily`
    correspond d'abord, et le contrôle déclare tout le catalogue absent —
    ce qui est déjà arrivé.
    """
    match = re.search(r"public enum Sport\s*:", source)
    if not match:
        sys.exit("Sport introuvable dans le catalogue.")
    body = source[match.end():]
    body = body[: body.index("\n    public var id")]
    return re.findall(r"^\s*case (\w+)$", body, re.MULTILINE)


def intent_sports(source: str) -> list[str]:
    match = re.search(r"enum ActivitySport\s*:", source)
    if not match:
        sys.exit("ActivitySport introuvable.")
    body = source[match.end():]
    body = body[: body.index("typeDisplayRepresentation")]
    return re.findall(r"^\s*case (\w+)$", body, re.MULTILINE)


def named(source: str) -> set[str]:
    return set(re.findall(r"\.(\w+): DisplayRepresentation\(title:", source))


def main() -> int:
    catalogue = catalogue_sports(CATALOGUE.read_text())
    intents_source = INTENTS.read_text()
    intents = intent_sports(intents_source)
    titles = named(intents_source)

    problems = []
    missing = [s for s in catalogue if s not in intents]
    extra = [s for s in intents if s not in catalogue]
    unnamed = [s for s in intents if s not in titles]

    if missing:
        problems.append(
            f"absents de ActivitySport, donc impossibles à demander à Siri : {', '.join(missing)}"
        )
    if extra:
        problems.append(
            f"proposés par Siri mais absents du catalogue : {', '.join(extra)}"
        )
    if unnamed:
        problems.append(f"sans nom affichable : {', '.join(unnamed)}")

    if problems:
        for problem in problems:
            print(f"::error::{problem}")
        return 1

    print(f"{len(catalogue)} sports, tous proposés par Siri et tous nommés.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
