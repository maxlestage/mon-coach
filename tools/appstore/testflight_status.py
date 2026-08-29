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

Ce script lit les trois d'un coup et le dit en clair.

Il ne modifie rien, sauf si on le lui demande explicitement : `ATTRIBUTE`
ouvre les groupes de testeurs **internes** à tous les builds, ce qu'Apple ne
fait pas tout seul et sans quoi le troisième cas ne se résout jamais. Lire un
état et changer une distribution sont deux gestes différents, et le second se
décide au lancement plutôt qu'à chaque coup d'œil.
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


def attribute(client: Client, rows: list[dict], existing: list[dict]) -> None:
    """Ouvre les groupes internes à tous les builds, présents et à venir.

    Le premier essai fut d'attribuer le build au groupe, un par un. Apple
    refuse, et le dit clairement :

        Builds cannot be assigned to this internal group.
        Cannot add internal group to a build.

    Un groupe interne ne se garnit pas build par build : il porte un
    interrupteur, `hasAccessToAllBuilds`, qui lui donne tout ce qui arrive —
    « Distribuer automatiquement les builds » dans l'interface. C'est le seul
    mécanisme qu'Apple offre, et il vaut mieux que l'autre : une fois posé,
    aucun build suivant ne demande de geste.

    Les groupes externes ne sont pas touchés. Les ouvrir déclencherait une
    revue d'Apple et enverrait le build à des gens qui ne l'attendent pas.
    """
    internal = [g for g in existing if g["attributes"].get("isInternalGroup")]
    if not internal:
        print("\nAucun groupe interne à ouvrir.")
        return

    valid = [r for r in rows if r["attributes"].get("processingState") == "VALID"]
    latest = valid[0]["attributes"].get("version", "?") if valid else "?"

    print("\nOuverture des groupes internes à tous les builds :")
    for group in internal:
        attributes = group["attributes"]
        name = attributes.get("name", "?")
        if attributes.get("hasAccessToAllBuilds"):
            print(f"  « {name} » les reçoit déjà tous.")
            continue
        try:
            client.call(
                f"betaGroups/{group['id']}",
                method="PATCH",
                body={
                    "data": {
                        "id": group["id"],
                        "type": "betaGroups",
                        "attributes": {"hasAccessToAllBuilds": True},
                    }
                },
            )
            print(f"  « {name} » reçoit désormais tous les builds, dont le {latest}.")
        except AppleRefused as refusal:
            print(f"::warning::« {name} » : {refusal.detail}")
            print("  À faire à la main : App Store Connect → TestFlight → ce")
            print("  groupe → « Distribuer automatiquement les builds ».")


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
        print("  → + → s'ajouter, puis cocher « Distribuer automatiquement les")
        print("  builds » sur le groupe.")
    else:
        for group in existing:
            attributes = group["attributes"]
            kind = "interne" if attributes.get("isInternalGroup") else "externe"
            print(f"  - « {attributes.get('name', '?')} » ({kind})")

    # L'attribution ne se fait que si on la demande. Lire l'état et changer la
    # distribution sont deux gestes différents, et le second doit se voir dans
    # l'historique des exécutions plutôt que se produire à chaque coup d'œil.
    if os.environ.get("ATTRIBUTE", "").strip().lower() in ("1", "true", "oui"):
        attribute(client, rows, existing)

    return 0


if __name__ == "__main__":
    sys.exit(main())
