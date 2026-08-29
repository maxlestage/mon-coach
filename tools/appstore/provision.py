#!/usr/bin/env python3
"""Prépare chez Apple tout ce qu'un envoi TestFlight suppose déjà en place.

Trois choses doivent exister avant qu'un build puisse partir, et aucune ne se
crée pendant la compilation :

1. un **identifiant** (App ID) par cible — application, montre, widget ;
2. les **capacités** que ces identifiants déclarent, ici HealthKit pour la
   montre, qui lit la fréquence cardiaque ;
3. une **fiche d'application** dans App Store Connect, que Xcode interroge
   avant de téléverser.

Les deux premières se créent par l'API, et ce script les crée. La troisième
est tentée, et ce que répond Apple est rapporté tel quel : cela vaut mieux
qu'une affirmation de mémoire sur ce que l'API permet ou non.

Le script est **idempotent**. Ce qui existe déjà est laissé tel quel et dit
comme tel : le relancer ne crée pas de doublon et ne casse rien.
"""

from __future__ import annotations

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

# Les capacités à déclarer, par identifiant. Un App ID sans la capacité qu'un
# droit réclame fait échouer la signature, tard et sans nommer la capacité.
CAPABILITIES = {
    "watchkitapp": ["HEALTHKIT"],
}


def bundle_identifiers(pbxproj: str) -> list[str]:
    """Les identifiants du projet, dans l'ordre où Apple veut les voir.

    L'application d'abord : les identifiants de la montre et du widget en
    dérivent par préfixe, et Apple refuse un identifiant dont le parent
    n'existe pas encore.
    """
    with open(pbxproj, "r", encoding="utf-8") as handle:
        found = set(
            re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = (com\.[^;]+);", handle.read())
        )
    return sorted(found, key=len)


def readable_name(identifier: str) -> str:
    """Apple n'accepte que lettres, chiffres, espaces et tirets dans le nom."""
    return re.sub(r"[^A-Za-z0-9 ]+", " ", identifier).strip()


def existing_bundle_ids(client: Client) -> dict[str, str]:
    found = {}
    url = "bundleIds?limit=200"
    while url:
        page = client.call(url)
        for item in page.get("data", []):
            found[item["attributes"]["identifier"]] = item["id"]
        nxt = page.get("links", {}).get("next", "")
        url = nxt.split("/v1/", 1)[1] if "/v1/" in nxt else ""
    return found


def ensure_bundle_id(client: Client, identifier: str, known: dict[str, str]) -> str:
    if identifier in known:
        print(f"  identifiant déjà là : {identifier}")
        return known[identifier]

    created = client.call(
        "bundleIds",
        method="POST",
        body={
            "data": {
                "type": "bundleIds",
                "attributes": {
                    "identifier": identifier,
                    "name": readable_name(identifier),
                    # Les cibles watchOS se déclarent sous la plateforme IOS :
                    # c'est ainsi qu'Apple range les identifiants d'un même
                    # appareil couplé.
                    "platform": "IOS",
                },
            }
        },
    )
    print(f"  identifiant créé : {identifier}")
    return created["data"]["id"]


def ensure_capabilities(client: Client, identifier: str, bundle_key: str) -> None:
    wanted = []
    for suffix, capabilities in CAPABILITIES.items():
        if identifier.endswith(suffix):
            wanted = capabilities
    if not wanted:
        return

    # Sans « limit » : Apple refuse ce paramètre sur cette relation-là, par un
    # 400 qui ne dit pas quelle requête est en cause. La liste est de toute
    # façon courte — un identifiant n'a qu'une poignée de capacités.
    present = {
        item["attributes"]["capabilityType"]
        for item in client.call(
            f"bundleIds/{bundle_key}/bundleIdCapabilities"
        ).get("data", [])
    }

    for capability in wanted:
        if capability in present:
            print(f"    capacité déjà là : {capability}")
            continue
        try:
            client.call(
                "bundleIdCapabilities",
                method="POST",
                body={
                    "data": {
                        "type": "bundleIdCapabilities",
                        "attributes": {"capabilityType": capability},
                        "relationships": {
                            "bundleId": {
                                "data": {"type": "bundleIds", "id": bundle_key}
                            }
                        },
                    }
                },
            )
            print(f"    capacité ajoutée : {capability}")
        except AppleRefused as refusal:
            print(f"::warning::Capacité {capability} refusée : {refusal.detail}")


def rename_app(client: Client, app_id: str, name: str) -> bool:
    """Donne son nom à la fiche, si elle en porte encore un provisoire.

    Le nom ne vit pas sur la fiche elle-même mais sur ses localisations, une
    par langue. C'est pour ça qu'Apple autorise UPDATE sur « apps » sans
    qu'on puisse pour autant y écrire un nom.

    Le renommage n'a lieu que si le nom actuel est l'identifiant de bundle —
    ce que laisse une fiche créée en tapant l'identifiant dans le champ Nom.
    Un nom choisi n'est jamais écrasé : ce serait défaire, à chaque build, une
    décision prise à la main.
    """
    infos = client.call(f"apps/{app_id}/appInfos").get("data", [])
    for info in infos:
        localizations = client.call(
            f"appInfos/{info['id']}/appInfoLocalizations"
        ).get("data", [])
        for localization in localizations:
            current = localization["attributes"].get("name") or ""
            if not current.startswith("com."):
                continue
            try:
                client.call(
                    f"appInfoLocalizations/{localization['id']}",
                    method="PATCH",
                    body={
                        "data": {
                            "id": localization["id"],
                            "type": "appInfoLocalizations",
                            "attributes": {"name": name},
                        }
                    },
                )
                print(f"  fiche renommée : « {current} » → « {name} »")
                return True
            except AppleRefused as refusal:
                print(f"::warning::Renommage refusé : {refusal.detail}")
                print("  Un nom d'App Store doit être libre sur toute la boutique.")
                return False
    return False


def ensure_app_record(client: Client, identifier: str, name: str, sku: str) -> int:
    """Tente la fiche d'application, et rapporte ce qu'Apple répond.

    Apple ne documente pas de création de fiche par l'API. Plutôt que de
    l'affirmer, on essaie : un refus donne une réponse datée et vérifiable, là
    où une affirmation de mémoire enverrait quelqu'un chercher un endpoint qui
    n'existe pas — ou renoncerait à un qui existe.
    """
    apps = client.call(f"apps?filter[bundleId]={identifier}&limit=10").get("data", [])
    exact = [a for a in apps if a["attributes"].get("bundleId") == identifier]
    if exact:
        print(f"  fiche déjà là : « {exact[0]['attributes'].get('name', '?')} »")
        rename_app(client, exact[0]["id"], name)
        return 0

    try:
        created = client.call(
            "apps",
            method="POST",
            body={
                "data": {
                    "type": "apps",
                    "attributes": {
                        "bundleId": identifier,
                        "name": name,
                        "primaryLocale": "fr-FR",
                        "sku": sku,
                    },
                }
            },
        )
        print(f"  fiche créée : « {created['data']['attributes'].get('name', name)} »")
        return 0
    except AppleRefused as refusal:
        print(f"::error::Aucune fiche pour {identifier}, et l'API ne peut pas la créer.")
        print(f"Réponse d'Apple ({refusal.status}) : {refusal.detail}")
        print()

        # Ce que le compte contient vraiment. « Introuvable » et « rangée sous
        # un autre identifiant » se ressemblent beaucoup vues d'ici, et se
        # distinguent d'un coup d'œil sur cette liste. Une fiche créée à
        # l'instant peut aussi mettre quelques minutes à devenir visible.
        try:
            everything = client.call("apps?limit=200").get("data", [])
        except AppleRefused:
            everything = []
        if everything:
            print("Fiches présentes sur le compte :")
            for app in everything:
                attributes = app["attributes"]
                mark = "  ←  attendu ici" if attributes.get("bundleId") == identifier else ""
                print(
                    f"  - « {attributes.get('name', '?')} » "
                    f"→ {attributes.get('bundleId', '?')}{mark}"
                )
            print()
            print("Si la fiche est là sous un autre identifiant, c'est celui du")
            print("projet qu'il faut aligner, pas la fiche. Si elle vient d'être")
            print("créée, quelques minutes suffisent parfois à la rendre visible.")
        else:
            print("Le compte ne contient aucune fiche d'application.")
        print()
        print("C'est le seul geste de toute la chaîne qui reste manuel. Il se")
        print("fait une fois, depuis un téléphone :")
        print()
        print("  App Store Connect → Apps → +  → New App")
        print("    Plateformes : iOS")
        print(f"    Bundle ID   : {identifier}")
        print("    Nom         : unique sur tout l'App Store. Un nom déjà pris")
        print("                  est refusé, ce qui est le cas de la plupart")
        print("                  des noms génériques. Il se change plus tard,")
        print("                  et il est indépendant du nom sous l'icône.")
        print(f"    SKU         : {sku}")
        return 1


def main() -> int:
    project = os.environ.get(
        "PROJECT", "ios/MonCoach/MonCoach.xcodeproj"
    )
    identifiers = bundle_identifiers(os.path.join(project, "project.pbxproj"))
    if not identifiers:
        print("::error::Aucun identifiant trouvé dans le projet.")
        return 1

    client = Client.from_environment()

    print("Identifiants :")
    try:
        known = existing_bundle_ids(client)
        for identifier in identifiers:
            key = ensure_bundle_id(client, identifier, known)
            ensure_capabilities(client, identifier, key)
    except AppleRefused as refusal:
        # Une trace Python ne dit rien à qui n'a pas écrit ce fichier. Le refus
        # d'Apple, lui, dit ce qu'il faut changer.
        print(f"::error::{refusal.explain()}")
        return 1

    print("\nFiche d'application :")
    return ensure_app_record(
        client,
        identifiers[0],
        os.environ.get("APP_NAME", "Fitness Coach"),
        os.environ.get("APP_SKU", identifiers[0]),
    )


if __name__ == "__main__":
    sys.exit(main())
