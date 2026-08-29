#!/usr/bin/env python3
"""Vérifie, dans l'archive, les phrases qu'Apple exige avant de les exiger.

Pourquoi ce script existe
-------------------------
Certains droits (« entitlements ») obligent l'application à porter une phrase
expliquant à l'utilisateur pourquoi elle accède à des données sensibles. La
règle ne dépend pas de ce que le code fait : porter le droit HealthKit suffit
à devoir les deux phrases, celle de lecture et celle d'écriture, même si
l'application ne lit que la fréquence cardiaque et n'écrit jamais rien.

Rien ne le signale à la compilation. Ni Xcode, ni la signature, ni l'archive,
ni le téléversement : tout passe au vert. C'est le service de validation
d'Apple qui refuse, par courriel, un quart d'heure plus tard :

    ITMS-90683: Missing purpose string in Info.plist — The Info.plist file
    for the "MonCoach.app/Watch/MonCoachWatch.app" bundle should contain a
    NSHealthUpdateUsageDescription key…

Le refus est juste, et coûte un aller-retour complet. Or il est entièrement
vérifiable sur la machine de build : les droits sont lisibles dans le binaire
signé, les phrases dans l'Info.plist du même paquet. C'est ce que fait ce
script, avant l'export, sur chaque paquet de l'archive — application, montre,
extensions.
"""

from __future__ import annotations

import os
import plistlib
import subprocess
import sys

# Les droits qui obligent à une phrase, et lesquelles.
#
# La liste est courte et le restera : n'y entre qu'un couple vérifié contre un
# refus réel ou la documentation d'Apple. Un droit absent d'ici n'est pas
# vérifié — mieux vaut une vérification partielle et juste qu'exhaustive et
# fausse, qui ferait échouer des builds parfaitement livrables.
REQUIRED = {
    "com.apple.developer.healthkit": (
        "NSHealthShareUsageDescription",
        "NSHealthUpdateUsageDescription",
    ),
    "com.apple.developer.homekit": ("NSHomeKitUsageDescription",),
    "com.apple.developer.siri": ("NSSiriUsageDescription",),
}


def bundles(root: str) -> list[str]:
    """Tous les paquets exécutables de l'archive, imbrication comprise.

    L'application de la montre vit sous `MonCoach.app/Watch/`, les widgets
    sous `PlugIns/`. Chacun a son propre Info.plist et ses propres droits :
    c'est exactement pour ça qu'Apple nomme le paquet fautif dans son refus.
    """
    found = []
    for directory, subdirectories, _ in os.walk(root):
        for name in subdirectories:
            if name.endswith((".app", ".appex")):
                found.append(os.path.join(directory, name))
    return sorted(found)


def entitlements(bundle: str) -> dict:
    """Les droits réellement signés dans le binaire, pas ceux espérés.

    La signature automatique ajoute des droits que le projet ne déclare nulle
    part : ils viennent du profil, lui-même dérivé des capacités de
    l'identifiant. Les lire ici, c'est lire ce qu'Apple lira.
    """
    result = subprocess.run(
        ["codesign", "-d", "--entitlements", ":-", bundle],
        capture_output=True,
    )
    raw = result.stdout
    start = raw.find(b"<?xml")
    if start < 0:
        # Pas de droits du tout, ou une sortie que cette version de codesign
        # écrit autrement. Dans les deux cas, rien à vérifier ici : ce script
        # n'a pas à faire échouer un build sur sa propre incompréhension.
        return {}
    try:
        return plistlib.loads(raw[start:])
    except plistlib.InvalidFileException:
        return {}


def info_plist(bundle: str) -> dict:
    path = os.path.join(bundle, "Info.plist")
    if not os.path.exists(path):
        return {}
    with open(path, "rb") as handle:
        return plistlib.load(handle)


def check(bundle: str, root: str) -> list[str]:
    granted = entitlements(bundle)
    if not granted:
        return []
    info = info_plist(bundle)
    shown = os.path.relpath(bundle, os.path.dirname(root))

    missing = []
    for right, keys in REQUIRED.items():
        if right not in granted:
            continue
        for key in keys:
            if not str(info.get(key, "")).strip():
                missing.append(f"{shown} : {key} (exigé par {right})")
    return missing


def main() -> int:
    archive = os.environ.get("ARCHIVE", "")
    products = os.path.join(archive, "Products", "Applications")
    if not os.path.isdir(products):
        print(f"::warning::Aucun produit dans {archive} : vérification sautée.")
        return 0

    missing = []
    for bundle in bundles(products):
        missing.extend(check(bundle, products))

    if not missing:
        print("Phrases d'autorisation : rien ne manque.")
        return 0

    print("::error::Il manque des phrases d'autorisation qu'Apple exige.")
    print()
    for line in missing:
        print(f"  - {line}")
    print()
    print("Un droit oblige à sa phrase même quand le code ne s'en sert pas :")
    print("porter HealthKit impose les deux phrases, lecture et écriture, même")
    print("pour une application qui ne fait que lire.")
    print()
    print("À ajouter dans le projet, sur la cible nommée ci-dessus :")
    print("  INFOPLIST_KEY_<NomDeLaClé> = \"…\";")
    print()
    print("Sans cela, l'archive part, l'envoi réussit, et Apple refuse par")
    print("courriel un quart d'heure plus tard — c'est le refus ITMS-90683.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
