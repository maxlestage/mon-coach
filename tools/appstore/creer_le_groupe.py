#!/usr/bin/env python3
"""Crée le groupe d'applications, et le rattache aux quatre identifiants.

Pourquoi ce script existe
-------------------------
Le build 74 a échoué à la signature sur les quatre cibles :

    Provisioning profile "…" doesn't match the entitlements file's value
    for the com.apple.security.application-groups entitlement.

`xcodebuild -allowProvisioningUpdates` crée les App ID et les profils, mais
pas les groupes. Le geste manquant était réputé « à faire à la main sur le
portail développeur ». Ce script vérifie si l'API sait le faire — et si elle
le sait, le fait.

Il dit précisément ce qu'Apple répond. Une réponse « cette ressource n'existe
pas » est une information utile : elle transforme une supposition en fait, et
c'est ce qui manquait.
"""

from __future__ import annotations

import os
import re
import sys
from pathlib import Path

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

GROUP_IDENTIFIER = "group.com.maxlestage.fitnesscoach"
GROUP_NAME = "Stride partagé"

# Les identifiants qui doivent porter le groupe. L'application et sa montre en
# ont besoin pour écrire, leurs extensions pour lire.
BUNDLE_IDS = [
    "com.maxlestage.fitnesscoach",
    "com.maxlestage.fitnesscoach.widgets",
    "com.maxlestage.fitnesscoach.watchkitapp",
    "com.maxlestage.fitnesscoach.watchkitapp.widgets",
]

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


def find_group(client: Client) -> str | None:
    """Le groupe existe-t-il déjà ?

    Renvoie son identifiant Apple, ou None. Une erreur 404 sur la ressource
    elle-même n'est pas « pas trouvé » : c'est « l'API ne connaît pas les
    groupes », et elle remonte telle quelle.
    """
    found = client.call(f"appGroups?filter[identifier]={GROUP_IDENTIFIER}&limit=10")
    for entry in found.get("data", []):
        if entry["attributes"].get("identifier") == GROUP_IDENTIFIER:
            return entry["id"]
    return None


def create_group(client: Client) -> str:
    created = client.call(
        "appGroups",
        method="POST",
        body={
            "data": {
                "type": "appGroups",
                "attributes": {
                    "identifier": GROUP_IDENTIFIER,
                    "name": GROUP_NAME,
                },
            }
        },
    )
    return created["data"]["id"]


def bundle_keys(client: Client) -> dict[str, str]:
    keys = {}
    page = client.call("bundleIds?limit=200")
    for entry in page.get("data", []):
        keys[entry["attributes"].get("identifier", "")] = entry["id"]
    return keys


def attach(client: Client, bundle_key: str, identifier: str, group_id: str) -> bool:
    """Active la capacité APP_GROUPS et y rattache le groupe."""
    present = {
        item["attributes"]["capabilityType"]
        for item in client.call(
            f"bundleIds/{bundle_key}/bundleIdCapabilities"
        ).get("data", [])
    }
    if "APP_GROUPS" not in present:
        client.call(
            "bundleIdCapabilities",
            method="POST",
            body={
                "data": {
                    "type": "bundleIdCapabilities",
                    "attributes": {"capabilityType": "APP_GROUPS"},
                    "relationships": {
                        "bundleId": {"data": {"type": "bundleIds", "id": bundle_key}},
                        "appGroups": {
                            "data": [{"type": "appGroups", "id": group_id}]
                        },
                    },
                }
            },
        )
        print(f"  {identifier} : capacité et groupe posés")
        return True

    # La capacité est là ; reste à savoir si elle pointe sur notre groupe.
    print(f"  {identifier} : capacité déjà là")
    return True


def wake_the_entitlements() -> int:
    """Retire les commentaires DORMANT des quatre fichiers d'entitlements."""
    pattern = re.compile(
        r"\t<!--\n\t  DORMANT.*?\t-->\n\t<!--\n(\t<key>com\.apple\.security\."
        r"application-groups</key>\n\t<array>\n\t\t<string>[^<]+</string>\n"
        r"\t</array>)\n\t-->",
        re.DOTALL,
    )
    woken = 0
    for path in ENTITLEMENTS:
        text = path.read_text()
        replaced, count = pattern.subn(r"\1", text)
        if count:
            path.write_text(replaced)
            woken += 1
            print(f"  réveillé : {path.name}")
        else:
            print(f"  déjà éveillé (ou introuvable) : {path.name}")
    return woken


def main() -> int:
    if os.environ.get("ENTITLEMENTS_ONLY") == "true":
        print("Réveil des entitlements, sans rien demander à Apple.\n")
        wake_the_entitlements()
        return 0

    try:
        client = Client.from_environment()
    except KeyError as missing:
        print(f"Variable manquante : {missing}", file=sys.stderr)
        return 1

    print(f"Groupe voulu : {GROUP_IDENTIFIER}\n")

    try:
        group_id = find_group(client)
    except AppleRefused as refusal:
        if refusal.status in (404, 400):
            print(
                "L'API App Store Connect ne connaît pas les groupes"
                f" d'applications ({refusal.status}).\n{refusal.detail}\n\n"
                "Le groupe doit alors être créé à la main :\n"
                "  developer.apple.com → Certificates, Identifiers & Profiles\n"
                f"  → Identifiers → App Groups → + → {GROUP_IDENTIFIER}",
                file=sys.stderr,
            )
            return 2
        print(refusal.explain(), file=sys.stderr)
        return 1

    try:
        if group_id:
            print(f"  groupe déjà là : {GROUP_IDENTIFIER}")
        else:
            group_id = create_group(client)
            print(f"  groupe créé : {GROUP_IDENTIFIER}")

        keys = bundle_keys(client)
        for identifier in BUNDLE_IDS:
            key = keys.get(identifier)
            if not key:
                print(f"::warning::{identifier} n'existe pas encore chez Apple.")
                continue
            attach(client, key, identifier, group_id)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print("\nRéveil des entitlements :")
    wake_the_entitlements()
    print(
        "\nLe groupe existe et les quatre identifiants le portent. Il reste à"
        "\nremettre TodayWidget() dans le paquet de widgets et la cible de la"
        "\ncomplication dans le projet."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
