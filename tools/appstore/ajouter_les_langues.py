#!/usr/bin/env python3
"""Ajoute l'anglais et l'espagnol à la fiche App Store.

Pourquoi ce script existe
-------------------------
L'application est entièrement traduite en trois langues — chaque texte du
coach, chaque exercice, chaque recette. Sa fiche, elle, n'existe qu'en
français : un anglophone la voit en français, ne comprend pas ce qu'elle fait,
et passe. Tout le travail de traduction est invisible depuis la boutique.

Deux endroits portent des textes, et on les confond facilement :

  - `appInfoLocalizations` : le nom, le sous-titre, la catégorie. Ce qui ne
    change pas d'une version à l'autre.
  - `appStoreVersionLocalizations` : la description, les mots-clés, les
    nouveautés. Ce qui appartient à la version 1.0.

Ce script remplit les deux, et ne touche jamais à une langue déjà écrite : la
version française a peut-être été relue à la main, et l'écraser serait le
genre de service qu'on ne rend qu'une fois.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.maxlestage.fitnesscoach")

SUBTITLES = {
    "en-US": "Coach, meals, running",
    "es-ES": "Entrenador, comidas, carrera",
}

# La description. Elle dit ce que l'application fait et ce qu'elle ne fait
# pas — l'absence de serveur est un argument, pas une note de bas de page.
DESCRIPTIONS = {
    "en-US": """A coach that adapts, not a logbook.

Stride builds your training block from what you can actually do — your gym, your days, your injuries — then rewrites it every week from what you logged. Loads go up when you handle them and down when you don't.

WHAT IT DOES

• Strength blocks that adapt week by week, with a load suggested for every set
• Meal planning built on the same numbers as your training, with recipes and a shopping list
• Running and 48 sports, GPS-tracked, with personal segments and records
• Apple Watch: run the whole session from your wrist, heart rate included
• Bluetooth sensors: heart rate belts, power meters, cadence
• Reads Health for your weight, sleep and sessions logged elsewhere
• Comes back after a break, and lightens the load rather than pretending nothing happened

NOTHING LEAVES YOUR PHONE

No account, no server, no analytics. Your training, your weight, your photos and your meals stay on your device. There is nowhere for us to look, which is the only privacy promise worth making.

STRIDE+

Fourteen days free, then €14.99 per month or €119.99 per year. Cancel any time from your Apple account.

Designed and built by Maxime Nathan Lestage.""",
    "es-ES": """Un entrenador que se adapta, no un cuaderno.

Stride construye tu bloque de entrenamiento a partir de lo que realmente puedes hacer — tu gimnasio, tus días, tus lesiones — y lo reescribe cada semana según lo que registras. Las cargas suben cuando las aguantas y bajan cuando no.

QUÉ HACE

• Bloques de fuerza que se adaptan semana a semana, con una carga sugerida para cada serie
• Plan de comidas construido sobre los mismos números que tu entrenamiento, con recetas y lista de la compra
• Carrera y 48 deportes, con GPS, segmentos personales y récords
• Apple Watch: haz la sesión entera desde la muñeca, con frecuencia cardíaca
• Sensores Bluetooth: bandas de pulso, potenciómetros, cadencia
• Lee Salud para tu peso, tu sueño y las sesiones registradas en otras apps
• Vuelve después de una parada, y aligera la carga en vez de fingir que no pasó nada

NADA SALE DE TU TELÉFONO

Sin cuenta, sin servidor, sin analítica. Tu entrenamiento, tu peso, tus fotos y tus comidas se quedan en tu dispositivo. No hay ningún sitio donde podamos mirar, que es la única promesa de privacidad que vale la pena hacer.

STRIDE+

Catorce días gratis, luego 14,99 € al mes o 119,99 € al año. Cancela cuando quieras desde tu cuenta de Apple.

Diseñado y desarrollado por Maxime Nathan Lestage.""",
}

KEYWORDS = {
    "en-US": "gym,workout,strength,running,coach,nutrition,meal plan,gps,watch,offline",
    "es-ES": "gimnasio,fuerza,entrenamiento,carrera,entrenador,nutrición,dieta,gps,reloj",
}

PROMOTIONAL = {
    "en-US": "Your plan rewrites itself every week, from what you actually lifted.",
    "es-ES": "Tu plan se reescribe cada semana, a partir de lo que realmente levantaste.",
}


def app_identifier(client: Client) -> tuple[str, str]:
    apps = client.call(f"apps?filter[bundleId]={BUNDLE_ID}&limit=10").get("data", [])
    for entry in apps:
        if entry["attributes"].get("bundleId") == BUNDLE_ID:
            return entry["id"], entry["attributes"].get("name", "?")
    raise SystemExit(f"Aucune fiche pour {BUNDLE_ID}.")


def editable_app_info(client: Client, app_id: str) -> str | None:
    """La fiche modifiable — celle qui n'est pas déjà en vente.

    Apple en garde plusieurs : celle qui est publiée, et celle qu'on prépare.
    Écrire dans la mauvaise est refusé, et le message ne dit pas laquelle.
    """
    infos = client.call(f"apps/{app_id}/appInfos?limit=10").get("data", [])
    for info in infos:
        state = info["attributes"].get("appStoreState") or info["attributes"].get(
            "state", ""
        )
        if state not in ("READY_FOR_SALE", "REPLACED_WITH_NEW_INFO"):
            return info["id"]
    return infos[0]["id"] if infos else None


def editable_version(client: Client, app_id: str) -> str | None:
    versions = client.call(f"apps/{app_id}/appStoreVersions?limit=10").get("data", [])
    for version in versions:
        if version["attributes"].get("appStoreState") not in (
            "READY_FOR_SALE",
            "REPLACED_WITH_NEW_VERSION",
        ):
            return version["id"]
    return versions[0]["id"] if versions else None


def add_names(client: Client, info_id: str, app_name: str) -> None:
    present = {
        item["attributes"].get("locale")
        for item in client.call(
            f"appInfos/{info_id}/appInfoLocalizations?limit=50"
        ).get("data", [])
    }
    for locale, subtitle in SUBTITLES.items():
        if locale in present:
            print(f"  nom déjà là : {locale}")
            continue
        try:
            client.call(
                "appInfoLocalizations",
                method="POST",
                body={
                    "data": {
                        "type": "appInfoLocalizations",
                        "attributes": {
                            "locale": locale,
                            "name": app_name,
                            "subtitle": subtitle,
                        },
                        "relationships": {
                            "appInfo": {"data": {"type": "appInfos", "id": info_id}}
                        },
                    }
                },
            )
            print(f"  nom et sous-titre ajoutés : {locale}")
        except AppleRefused as refusal:
            print(f"::warning::Nom {locale} refusé : {refusal.detail}")


def add_descriptions(client: Client, version_id: str) -> None:
    present = {
        item["attributes"].get("locale")
        for item in client.call(
            f"appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=50"
        ).get("data", [])
    }
    for locale, description in DESCRIPTIONS.items():
        if locale in present:
            print(f"  description déjà là : {locale}")
            continue
        try:
            client.call(
                "appStoreVersionLocalizations",
                method="POST",
                body={
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "attributes": {
                            "locale": locale,
                            "description": description,
                            "keywords": KEYWORDS[locale],
                            "promotionalText": PROMOTIONAL[locale],
                        },
                        "relationships": {
                            "appStoreVersion": {
                                "data": {
                                    "type": "appStoreVersions",
                                    "id": version_id,
                                }
                            }
                        },
                    }
                },
            )
            print(f"  description ajoutée : {locale}")
        except AppleRefused as refusal:
            print(f"::warning::Description {locale} refusée : {refusal.detail}")


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
            add_names(client, info_id, name)
        else:
            print("::warning::Aucune fiche modifiable.")

        version_id = editable_version(client, app_id)
        if version_id:
            add_descriptions(client, version_id)
        else:
            print("::warning::Aucune version modifiable.")
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(
        "\nCe qu'il reste : les captures d'écran, une série par langue. L'API"
        "\nsait les recevoir, mais il faut d'abord les prendre."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
