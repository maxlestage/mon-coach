#!/usr/bin/env python3
"""Dit où en est un build chez Apple, et ce qui empêche de l'installer.

Pourquoi ce script existe
-------------------------
« Le build est envoyé » et « le build est installable » sont deux choses
différentes, séparées par trois étapes qu'aucun journal de build ne montre :

1. Apple **traite** le binaire — quelques minutes, parfois davantage. Tant
   que le traitement dure, le build n'apparaît nulle part.
2. Le traitement peut **échouer**, et le refus arrive par courriel. Vu du
   dépôt, un build refusé et un build en cours de traitement se ressemblent
   exactement : dans les deux cas, rien ne s'affiche.
3. Un build traité n'est visible dans l'application TestFlight que s'il est
   **attribué à un groupe de testeurs** dont on fait partie. Sans groupe, la
   page d'App Store Connect le montre et le téléphone non — ce qui ressemble
   à s'y méprendre à un envoi qui n'a pas eu lieu.

Ce script lit les trois d'un coup et le dit en clair. Il ne modifie rien.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

# Ce qu'Apple répond dans processingState, traduit en ce que ça implique.
STATES = {
    "PROCESSING": "en cours de traitement chez Apple — rien à faire, attendre.",
    "FAILED": "refusé par Apple. Le motif est parti par courriel.",
    "INVALID": "invalide : Apple l'a écarté après traitement.",
    "VALID": "traité et bon pour l'installation.",
}


def app_id(client: Client, bundle_id: str) -> tuple[str, str] | None:
    apps = client.call(f"apps?filter[bundleId]={bundle_id}&limit=10").get("data", [])
    for app in apps:
        if app["attributes"].get("bundleId") == bundle_id:
            return app["id"], app["attributes"].get("name", "?")
    return None


def builds(client: Client, identifier: str) -> list[dict]:
    response = client.call(
        f"builds?filter[app]={identifier}&limit=10&sort=-version"
    )
    return response.get("data", [])


def groups(client: Client, identifier: str) -> list[dict]:
    return client.call(f"apps/{identifier}/betaGroups").get("data", [])


def build_groups(client: Client, build_id: str) -> list[str]:
    """Les groupes auxquels ce build est attribué, s'il l'est.

    C'est le maillon qu'on oublie : un build parfaitement traité reste
    invisible sur le téléphone tant qu'aucun groupe ne le porte.
    """
    try:
        found = client.call(f"builds/{build_id}/betaGroups").get("data", [])
    except AppleRefused:
        return []
    return [item["attributes"].get("name", "?") for item in found]


def main() -> int:
    bundle_id = os.environ.get("BUNDLE_ID", "com.maxlestage.fitnesscoach")
    client = Client.from_environment()

    found = app_id(client, bundle_id)
    if not found:
        print(f"::error::Aucune fiche pour {bundle_id}.")
        return 1
    identifier, name = found
    print(f"Fiche : « {name} » ({bundle_id})\n")

    rows = builds(client, identifier)
    if not rows:
        print("Aucun build chez Apple. Si l'envoi vient d'avoir lieu, il faut")
        print("parfois quelques minutes avant que le build apparaisse ici.")
        return 0

    print("Builds, du plus récent au plus ancien :")
    for row in rows:
        attributes = row["attributes"]
        number = attributes.get("version", "?")
        state = attributes.get("processingState", "?")
        explanation = STATES.get(state, state)
        expired = " [expiré]" if attributes.get("expired") else ""
        print(f"\n  Build {number}{expired} — {explanation}")
        print(f"    envoyé le {attributes.get('uploadedDate', '?')[:16].replace('T', ' à ')}")

        if state != "VALID":
            continue
        attributed = build_groups(client, row["id"])
        if attributed:
            print(f"    attribué à : {', '.join(attributed)}")
        else:
            print("    ::warning:: attribué à aucun groupe de testeurs.")
            print("    Il est visible dans App Store Connect, mais pas dans")
            print("    l'application TestFlight du téléphone.")

    existing = groups(client, identifier)
    print("\nGroupes de testeurs :")
    if not existing:
        print("  Aucun. C'est ce qui manque le plus souvent : sans groupe, et")
        print("  sans y être soi-même, un build traité n'apparaît jamais sur le")
        print("  téléphone.")
        print()
        print("  App Store Connect → l'app → TestFlight → Testeurs internes")
        print("  → + → s'ajouter, puis attribuer le build au groupe.")
    else:
        for group in existing:
            attributes = group["attributes"]
            kind = "interne" if attributes.get("isInternalGroup") else "externe"
            print(f"  - « {attributes.get('name', '?')} » ({kind})")

    return 0


if __name__ == "__main__":
    sys.exit(main())
