#!/usr/bin/env python3
"""Réveille les entitlements du groupe d'applications, une fois qu'il existe.

Ce qu'on sait maintenant, et qu'on supposait avant
--------------------------------------------------
Le groupe d'applications ne peut pas être créé par un programme. Deux voies
ont été essayées, et les deux sont fermées :

  - `xcodebuild -allowProvisioningUpdates` crée les App ID et les profils,
    mais pas les groupes. Le build 74 a échoué là-dessus, sur les quatre
    cibles à la fois.
  - L'API App Store Connect ne connaît pas la ressource. Interrogée le
    3 septembre 2026, elle répond :

        404 — The specified resource does not exist. The path provided does
        not match a defined resource type.

C'est donc une action humaine, faite une fois, sur le portail développeur :

    developer.apple.com → Certificates, Identifiers & Profiles
    → Identifiers → App Groups → + → group.com.maxlestage.fitnesscoach

Ce script ne prétend pas la remplacer. Il fait la suite, qui est mécanique et
qu'on ferait mal à la main : retirer les quatre commentaires DORMANT, tous les
quatre, sans en oublier un. Un seul oublié et la signature casse — l'état à
moitié activé est le seul qui échoue, et il ne se voit qu'à l'archive.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

GROUP_IDENTIFIER = "group.com.maxlestage.fitnesscoach"

ROOT = Path(__file__).resolve().parents[2]
ENTITLEMENTS = [
    ROOT / "ios/MonCoach" / name
    for name in (
        "MonCoach.entitlements",
        "MonCoachWidgets.entitlements",
        "MonCoachWatch.entitlements",
        "MonCoachWatchWidgets.entitlements",
    )
]

# Le bloc endormi : le pavé d'explication, puis la déclaration commentée. On
# garde la déclaration et on jette les deux commentaires qui l'entourent.
DORMANT = re.compile(
    r"\t<!--\n\t  DORMANT.*?\t-->\n\t<!--\n"
    r"(\t<key>com\.apple\.security\.application-groups</key>\n"
    r"\t<array>\n\t\t<string>[^<]+</string>\n\t</array>)\n\t-->",
    re.DOTALL,
)


def main() -> int:
    woken, already, missing = [], [], []

    for path in ENTITLEMENTS:
        if not path.exists():
            missing.append(path.name)
            continue
        text = path.read_text()
        replaced, count = DORMANT.subn(r"\1", text)
        if count:
            path.write_text(replaced)
            woken.append(path.name)
        elif GROUP_IDENTIFIER in re.sub(r"<!--.*?-->", "", text, flags=re.DOTALL):
            already.append(path.name)
        else:
            missing.append(path.name)

    for name in woken:
        print(f"  réveillé : {name}")
    for name in already:
        print(f"  déjà éveillé : {name}")
    for name in missing:
        print(f"::error::{name} ne porte pas le groupe, ni endormi ni éveillé.")

    if missing:
        print(
            "\nÀ moitié activé, la signature échoue sur les quatre cibles."
            "\nCorrige la main avant d'archiver.",
            file=sys.stderr,
        )
        return 1

    print(
        f"\nLes quatre entitlements déclarent {GROUP_IDENTIFIER}."
        "\n\nIl reste deux gestes dans le code, que git sait faire :"
        "\n  1. décommenter TodayWidget() dans MonCoachWidgets.swift"
        "\n  2. remettre la cible MonCoachWatchWidgets dans le projet"
        "\n     (elle a été retirée par le commit « Les widgets sortent du"
        "\n     build tant qu'ils ne peuvent rien afficher »)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
