#!/usr/bin/env python3
"""Crée les deux abonnements Stride+ chez Apple, s'ils n'existent pas.

Pourquoi ce script existe
-------------------------
C'est le blocage numéro un de la mise en vente, et il se réglait « à la main
dans App Store Connect » — c'est-à-dire jamais, parce que la personne qui
doit le faire travaille depuis son téléphone et que l'écran des abonnements
n'y est pas praticable.

Or l'API sait tout faire : le groupe, les deux offres, leurs textes dans les
trois langues, et leurs prix. Ce qu'elle ne sait pas faire est la capture
d'écran d'examen, qui ne se demande qu'au moment de soumettre.

Ce que ce script garantit
-------------------------
Il est *idempotent* : relancé, il ne crée rien deux fois. Chaque étape
regarde d'abord ce qui existe. Un abonnement à moitié créé — le produit sans
ses textes, ou sans prix — est le cas le plus probable d'un premier essai
interrompu, et c'est précisément celui que la reprise doit savoir finir.

Il ne soumet rien à l'examen. Créer et soumettre sont deux gestes, et le
second appartient à celui dont c'est le compte.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

BUNDLE_ID = os.environ.get("BUNDLE_ID", "com.maxlestage.fitnesscoach")

# Le groupe. Un seul, et c'est voulu : deux abonnements dans le même groupe
# s'excluent l'un l'autre et se remplacent sans double facturation. Dans deux
# groupes séparés, quelqu'un peut payer le mensuel et l'annuel en même temps.
GROUP_REFERENCE = "Stride+"

# Le nom du groupe tel que l'App Store l'affiche, par langue.
GROUP_NAMES = {
    "fr-FR": "Stride+",
    "en-US": "Stride+",
    "es-ES": "Stride+",
}

# Les deux offres. Le prix est en euros, tel qu'on veut le voir sur la fiche ;
# le point de prix exact est choisi plus bas parmi ceux qu'Apple propose.
OFFERS = [
    {
        "productId": "com.maxlestage.fitnesscoach.plus.monthly",
        "reference": "Stride+ mensuel",
        "period": "ONE_MONTH",
        "price": 14.99,
        "texts": {
            "fr-FR": (
                "Stride+ mensuel",
                "Le coach complet : plan qui s'adapte chaque semaine, "
                "programme alimentaire, course et multi-sport, montre et "
                "capteurs. Tout reste sur ton téléphone.",
            ),
            "en-US": (
                "Stride+ monthly",
                "The full coach: a plan that adapts every week, meal "
                "planning, running and multi-sport, watch and sensors. "
                "Everything stays on your phone.",
            ),
            "es-ES": (
                "Stride+ mensual",
                "El entrenador completo: un plan que se adapta cada semana, "
                "plan de comidas, carrera y multideporte, reloj y sensores. "
                "Todo se queda en tu teléfono.",
            ),
        },
    },
    {
        "productId": "com.maxlestage.fitnesscoach.plus.yearly",
        "reference": "Stride+ annuel",
        "period": "ONE_YEAR",
        "price": 119.99,
        "texts": {
            "fr-FR": (
                "Stride+ annuel",
                "Douze mois de coach complet, à un tiers de moins que le "
                "mois par mois. Plan adaptatif, alimentation, course, "
                "montre et capteurs. Tout reste sur ton téléphone.",
            ),
            "en-US": (
                "Stride+ yearly",
                "Twelve months of the full coach, a third less than paying "
                "monthly. Adaptive plan, nutrition, running, watch and "
                "sensors. Everything stays on your phone.",
            ),
            "es-ES": (
                "Stride+ anual",
                "Doce meses del entrenador completo, un tercio menos que "
                "mes a mes. Plan adaptativo, nutrición, carrera, reloj y "
                "sensores. Todo se queda en tu teléfono.",
            ),
        },
    },
]

# Le territoire dont le prix commande tous les autres. Apple convertit le
# reste du monde à partir de celui-là.
TERRITORY = "FRA"


def app_identifier(client: Client) -> tuple[str, str]:
    apps = client.call(f"apps?filter[bundleId]={BUNDLE_ID}&limit=10").get("data", [])
    for entry in apps:
        if entry["attributes"].get("bundleId") == BUNDLE_ID:
            return entry["id"], entry["attributes"].get("name", "?")
    raise SystemExit(f"Aucune fiche pour {BUNDLE_ID}.")


def ensure_group(client: Client, app_id: str) -> str:
    groups = client.call(f"apps/{app_id}/subscriptionGroups?limit=50").get("data", [])
    for group in groups:
        if group["attributes"].get("referenceName") == GROUP_REFERENCE:
            print(f"  groupe déjà là : {GROUP_REFERENCE}")
            return group["id"]

    # Un groupe existant sous un autre nom est réutilisé plutôt que doublé :
    # deux groupes feraient coexister deux abonnements payables ensemble.
    if groups:
        existing = groups[0]
        print(
            "  groupe existant réutilisé : "
            f"« {existing['attributes'].get('referenceName')} »"
        )
        return existing["id"]

    created = client.call(
        "subscriptionGroups",
        method="POST",
        body={
            "data": {
                "type": "subscriptionGroups",
                "attributes": {"referenceName": GROUP_REFERENCE},
                "relationships": {"app": {"data": {"type": "apps", "id": app_id}}},
            }
        },
    )
    print(f"  groupe créé : {GROUP_REFERENCE}")
    return created["data"]["id"]


def ensure_group_names(client: Client, group_id: str) -> None:
    present = {
        item["attributes"].get("locale")
        for item in client.call(
            f"subscriptionGroups/{group_id}/subscriptionGroupLocalizations?limit=50"
        ).get("data", [])
    }
    for locale, name in GROUP_NAMES.items():
        if locale in present:
            print(f"    nom du groupe déjà là : {locale}")
            continue
        try:
            client.call(
                "subscriptionGroupLocalizations",
                method="POST",
                body={
                    "data": {
                        "type": "subscriptionGroupLocalizations",
                        "attributes": {"name": name, "locale": locale},
                        "relationships": {
                            "subscriptionGroup": {
                                "data": {
                                    "type": "subscriptionGroups",
                                    "id": group_id,
                                }
                            }
                        },
                    }
                },
            )
            print(f"    nom du groupe ajouté : {locale}")
        except AppleRefused as refusal:
            print(f"::warning::Nom de groupe {locale} refusé : {refusal.detail}")


def existing_offers(client: Client, group_id: str) -> dict[str, dict]:
    found = {}
    for offer in client.call(
        f"subscriptionGroups/{group_id}/subscriptions?limit=100"
    ).get("data", []):
        found[offer["attributes"].get("productId", "")] = offer
    return found


def ensure_offer(client: Client, group_id: str, offer: dict, known: dict) -> str | None:
    product = offer["productId"]
    if product in known:
        print(f"  offre déjà là : {product} ({known[product]['attributes'].get('state')})")
        return known[product]["id"]

    try:
        created = client.call(
            "subscriptions",
            method="POST",
            body={
                "data": {
                    "type": "subscriptions",
                    "attributes": {
                        "name": offer["reference"],
                        "productId": product,
                        "subscriptionPeriod": offer["period"],
                        # Le partage familial est refusé : le coach s'appuie
                        # sur un profil unique — poids, charges, historique.
                        # Partagé, il donnerait à deux corps le même plan.
                        "familySharable": False,
                    },
                    "relationships": {
                        # « group », et non « subscriptionGroup » : la
                        # relation ne porte pas le nom de la ressource
                        # qu'elle pointe. Apple l'avait dit clairement —
                        # « 'subscriptionGroup' is not a relationship on the
                        # resource 'subscriptions' » — ce qui vaut d'être
                        # noté, parce que le voisin `subscriptionGroup-
                        # Localizations` emploie bien l'autre nom.
                        "group": {
                            "data": {"type": "subscriptionGroups", "id": group_id}
                        }
                    },
                }
            },
        )
    except AppleRefused as refusal:
        print(f"::error::Offre {product} refusée : {refusal.detail}")
        return None
    print(f"  offre créée : {product}")
    return created["data"]["id"]


def ensure_offer_texts(client: Client, subscription_id: str, texts: dict) -> None:
    present = {
        item["attributes"].get("locale")
        for item in client.call(
            f"subscriptions/{subscription_id}/subscriptionLocalizations?limit=50"
        ).get("data", [])
    }
    for locale, (name, description) in texts.items():
        if locale in present:
            print(f"    texte déjà là : {locale}")
            continue
        try:
            client.call(
                "subscriptionLocalizations",
                method="POST",
                body={
                    "data": {
                        "type": "subscriptionLocalizations",
                        "attributes": {
                            "name": name,
                            "description": description,
                            "locale": locale,
                        },
                        "relationships": {
                            "subscription": {
                                "data": {
                                    "type": "subscriptions",
                                    "id": subscription_id,
                                }
                            }
                        },
                    }
                },
            )
            print(f"    texte ajouté : {locale}")
        except AppleRefused as refusal:
            print(f"::warning::Texte {locale} refusé : {refusal.detail}")


def ensure_price(client: Client, subscription_id: str, wanted: float) -> None:
    existing = client.call(
        f"subscriptions/{subscription_id}/prices"
        f"?filter[territory]={TERRITORY}&limit=50"
    ).get("data", [])
    if existing:
        print(f"    prix déjà posé ({len(existing)})")
        return

    points = client.call(
        f"subscriptions/{subscription_id}/pricePoints"
        f"?filter[territory]={TERRITORY}&limit=200"
    ).get("data", [])
    if not points:
        print("::warning::Apple ne propose aucun point de prix pour ce territoire.")
        return

    # Le point le plus proche du prix voulu. Apple n'accepte pas n'importe
    # quelle valeur : la grille est fixe, et 14,99 € en fait partie — mais on
    # ne le suppose pas, on cherche.
    def distance(point: dict) -> float:
        try:
            return abs(float(point["attributes"]["customerPrice"]) - wanted)
        except (KeyError, TypeError, ValueError):
            return float("inf")

    best = min(points, key=distance)
    price = best["attributes"].get("customerPrice")
    if distance(best) > 0.01:
        print(
            f"::warning::Pas de point à {wanted} € — le plus proche est {price} €."
        )

    try:
        client.call(
            "subscriptionPrices",
            method="POST",
            body={
                "data": {
                    "type": "subscriptionPrices",
                    "attributes": {"preserveCurrentPrice": False},
                    "relationships": {
                        "subscription": {
                            "data": {"type": "subscriptions", "id": subscription_id}
                        },
                        "subscriptionPricePoint": {
                            "data": {
                                "type": "subscriptionPricePoints",
                                "id": best["id"],
                            }
                        },
                    },
                }
            },
        )
        print(f"    prix posé : {price} € ({TERRITORY})")
    except AppleRefused as refusal:
        print(f"::error::Prix refusé : {refusal.detail}")


def main() -> int:
    try:
        client = Client.from_environment()
        app_id, name = app_identifier(client)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(f"Fiche : « {name} » ({BUNDLE_ID})\n")

    try:
        group_id = ensure_group(client, app_id)
        ensure_group_names(client, group_id)
        known = existing_offers(client, group_id)
        for offer in OFFERS:
            subscription_id = ensure_offer(client, group_id, offer, known)
            if not subscription_id:
                continue
            ensure_offer_texts(client, subscription_id, offer["texts"])
            ensure_price(client, subscription_id, offer["price"])
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(
        "\nCe qu'il reste, et que l'API ne sait pas faire : la capture d'écran"
        "\nd'examen du premier abonnement, demandée au moment de la soumission."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
