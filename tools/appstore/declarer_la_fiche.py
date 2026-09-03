#!/usr/bin/env python3
"""Déclare la classification d'âge et la confidentialité.

Pourquoi ce script existe
-------------------------
Ce sont deux formulaires d'App Store Connect, longs, à cases à cocher, et
sans lesquels l'examen ne démarre pas. Les remplir à la main depuis un
téléphone est une épreuve ; les remplir de mémoire tous les six mois est une
source d'erreurs.

Or les deux réponses sont déjà connues, et elles ne bougeront pas :

  - **Classification d'âge** : Stride n'a ni violence, ni jeu d'argent, ni
    contenu d'utilisateur, ni navigateur. Tout est à zéro, et le résultat est
    4+. Le seul point qui demande à réfléchir est le contenu médical : le
    coach prescrit des charges et des calories. Il est déclaré, honnêtement,
    à sa valeur la plus basse — c'est un programme d'entraînement, pas un
    traitement, et ne rien déclarer serait faux dans l'autre sens.

  - **Confidentialité** : rien n'est collecté. C'est la position du produit
    depuis le premier jour, elle est vraie, et elle se déclare en un seul
    drapeau. La plupart des applications passent des heures sur ce
    formulaire parce qu'elles ont quelque chose à y mettre.

Une déclaration fausse coûte un rejet et, pour la confidentialité, bien pire.
Celles-ci sont écrites une fois, relues, et posées par un programme qui ne se
trompe pas de case.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.maxlestage.fitnesscoach")

# La classification d'âge. Tout ce qui n'est pas nommé ici reste à la valeur
# qu'Apple donne par défaut, qui est l'absence.
#
# `medicalOrTreatmentInformation` mérite son mot : le coach prescrit des
# charges, des calories et des macros. Ce n'est pas un traitement, mais ce
# n'est pas rien non plus — le déclarer coûte une mention « 12+ » possible,
# le taire coûterait un rejet et serait malhonnête.
AGE_RATING = {
    "alcoholTobaccoOrDrugUseOrReferences": "NONE",
    "contests": "NONE",
    "gambling": False,
    "gamblingSimulated": "NONE",
    "horrorOrFearThemes": "NONE",
    "matureOrSuggestiveThemes": "NONE",
    "medicalOrTreatmentInformation": "INFREQUENT_OR_MILD",
    "profanityOrCrudeHumor": "NONE",
    "sexualContentGraphicAndNudity": "NONE",
    "sexualContentOrNudity": "NONE",
    "violenceCartoonOrFantasy": "NONE",
    "violenceRealistic": "NONE",
    "violenceRealisticProlongedGraphicOrSadistic": "NONE",
    "unrestrictedWebAccess": False,
    "kidsAgeBand": None,
}


def app_identifier(client: Client) -> tuple[str, str]:
    apps = client.call(f"apps?filter[bundleId]={BUNDLE_ID}&limit=10").get("data", [])
    for entry in apps:
        if entry["attributes"].get("bundleId") == BUNDLE_ID:
            return entry["id"], entry["attributes"].get("name", "?")
    raise SystemExit(f"Aucune fiche pour {BUNDLE_ID}.")


def editable_app_info(client: Client, app_id: str) -> str | None:
    infos = client.call(f"apps/{app_id}/appInfos?limit=10").get("data", [])
    for info in infos:
        state = info["attributes"].get("appStoreState") or info["attributes"].get(
            "state", ""
        )
        if state not in ("READY_FOR_SALE", "REPLACED_WITH_NEW_INFO"):
            return info["id"]
    return infos[0]["id"] if infos else None


def declare_age(client: Client, info_id: str) -> None:
    """Pose la classification d'âge sur la fiche modifiable."""
    try:
        declaration = client.call(f"appInfos/{info_id}/ageRatingDeclaration")
    except AppleRefused as refusal:
        print(f"::warning::Classification d'âge illisible : {refusal.detail}")
        return

    entry = declaration.get("data")
    if not entry:
        print("::warning::Aucune classification d'âge à modifier.")
        return

    try:
        client.call(
            f"ageRatingDeclarations/{entry['id']}",
            method="PATCH",
            body={
                "data": {
                    "type": "ageRatingDeclarations",
                    "id": entry["id"],
                    "attributes": AGE_RATING,
                }
            },
        )
        print("  classification d'âge déclarée")
    except AppleRefused as refusal:
        print(f"::error::Classification d'âge refusée : {refusal.detail}")


def declare_privacy(client: Client, app_id: str) -> None:
    """Déclare qu'aucune donnée n'est collectée.

    Apple attend une ligne par catégorie de donnée, ou une seule déclaration
    globale disant qu'il n'y en a aucune. C'est la seconde qui s'applique
    ici, et elle a l'avantage d'être vérifiable : l'application n'a pas de
    serveur à qui envoyer quoi que ce soit.
    """
    try:
        existing = client.call(
            f"apps/{app_id}/appDataUsages?limit=200"
        ).get("data", [])
    except AppleRefused as refusal:
        if refusal.status == 404:
            print(
                "::warning::L'API n'expose pas les étiquettes de"
                " confidentialité. À remplir dans App Store Connect →"
                " Confidentialité de l'app : cocher « Aucune donnée collectée »."
            )
            return
        print(f"::warning::Confidentialité illisible : {refusal.detail}")
        return

    if existing:
        print(f"  confidentialité déjà déclarée ({len(existing)} entrées)")
        return

    # La catégorie « pas de collecte » est une valeur du même vocabulaire que
    # les autres : on la pose comme une déclaration parmi les déclarations.
    try:
        client.call(
            "appDataUsages",
            method="POST",
            body={
                "data": {
                    "type": "appDataUsages",
                    "relationships": {
                        "app": {"data": {"type": "apps", "id": app_id}},
                        "dataProtection": {
                            "data": {
                                "type": "appDataUsageDataProtections",
                                "id": "DATA_NOT_COLLECTED",
                            }
                        },
                    },
                }
            },
        )
        print("  confidentialité déclarée : aucune donnée collectée")
    except AppleRefused as refusal:
        print(f"::error::Confidentialité refusée : {refusal.detail}")
        print(
            "::error::  À cocher à la main : App Store Connect →"
            " Confidentialité de l'app → « Aucune donnée collectée »."
        )


def main() -> int:
    try:
        client = Client.from_environment()
        app_id, name = app_identifier(client)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(f"Fiche : « {name} » ({BUNDLE_ID})\n")

    try:
        info_id = editable_app_info(client, app_id)
        if info_id:
            declare_age(client, info_id)
        else:
            print("::warning::Aucune fiche modifiable.")
        declare_privacy(client, app_id)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
