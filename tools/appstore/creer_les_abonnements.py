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

# Poser les prix, ou s'en abstenir.
#
# Tant que le contrat « Paid Applications » n'est pas actif, Apple refuse
# toute tarification par un message qui n'en dit pas la cause. Réessayer à
# chaque passage ne coûte pas cher, mais remplit le journal d'erreurs rouges
# qui ne sont pas des régressions — et une erreur qu'on apprend à ignorer est
# une erreur qu'on ignorera le jour où elle compte.
POSE_LES_PRIX = os.environ.get("POSER_LES_PRIX", "true").lower() != "false"

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
# Les deux offres.
#
# La description tient en 55 caractères — Apple l'a dit en refusant les
# paragraphes du premier essai : « the field (DESCRIPTION) is too long, max
# number of characters is (55) ». Ce n'est pas la description de
# l'application, c'est la ligne que l'App Store affiche sous le prix.
OFFERS = [
    {
        "productId": "com.maxlestage.fitnesscoach.plus.monthly",
        "reference": "Stride+ mensuel",
        "period": "ONE_MONTH",
        "price": 14.99,
        "texts": {
            "fr-FR": ("Stride+ mensuel", "Le coach complet, mois par mois."),
            "en-US": ("Stride+ monthly", "The full coach, month by month."),
            "es-ES": ("Stride+ mensual", "El entrenador completo, mes a mes."),
        },
    },
    {
        "productId": "com.maxlestage.fitnesscoach.plus.yearly",
        "reference": "Stride+ annuel",
        "period": "ONE_YEAR",
        "price": 119.99,
        "texts": {
            "fr-FR": ("Stride+ annuel", "Douze mois de coach, un tiers de moins."),
            "en-US": ("Stride+ yearly", "Twelve months of coach, a third less."),
            "es-ES": ("Stride+ anual", "Doce meses de entrenador, un tercio menos."),
        },
    },
]

# Ce qu'Apple accepte comme description d'abonnement. Vérifié avant d'écrire
# plutôt qu'après avoir été refusé : un texte trop long ne se voit pas à
# l'œil, et le refus arrive une requête trop tard.
DESCRIPTION_LIMIT = 55

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


def all_pages(client: Client, path: str) -> list[dict]:
    """Toutes les pages, et non la première.

    Apple plafonne une page à deux cents entrées, et la grille des prix en
    compte largement plus. Le premier essai s'est arrêté à la première page,
    et a conclu que le point le plus proche de 119,99 € était 24,90 € — ce
    qui n'était pas faux dans ce qu'il avait lu, et complètement faux dans
    la réalité. Un « plus proche » calculé sur une liste tronquée est le
    genre d'erreur qui ne se signale pas toute seule.
    """
    items: list[dict] = []
    page = client.call(path)
    while True:
        items.extend(page.get("data", []))
        following = (page.get("links") or {}).get("next")
        if not following:
            return items
        # Le lien rendu est absolu ; le client, lui, préfixe. On lui repasse
        # ce qui suit /v1/.
        page = client.call(following.split("/v1/", 1)[-1])


def territory_of(point: dict) -> str:
    relationship = (point.get("relationships") or {}).get("territory") or {}
    return ((relationship.get("data") or {}).get("id")) or ""


def ensure_price(client: Client, subscription_id: str, wanted: float) -> None:
    existing = client.call(
        f"subscriptions/{subscription_id}/prices?limit=50"
    ).get("data", [])
    if existing:
        print(f"    prix déjà posé ({len(existing)})")
        return

    points = [
        point
        for point in all_pages(
            client,
            f"subscriptions/{subscription_id}/pricePoints"
            f"?filter[territory]={TERRITORY}&limit=200",
        )
        # Le filtre est passé à Apple, et vérifié au retour : un point d'un
        # autre territoire porte un prix dans une autre monnaie, et « 14,99 »
        # y désigne autre chose. Posé tel quel, il fait échouer la tarification
        # sans dire pourquoi.
        if territory_of(point) in ("", TERRITORY)
    ]
    if not points:
        print(f"::error::Aucun point de prix pour {TERRITORY}.")
        return

    def price_of(point: dict) -> float:
        try:
            return float(point["attributes"]["customerPrice"])
        except (KeyError, TypeError, ValueError):
            return float("inf")

    exact = [point for point in points if abs(price_of(point) - wanted) < 0.005]
    chosen = exact[0] if exact else min(points, key=lambda p: abs(price_of(p) - wanted))
    if not exact:
        print(
            f"::warning::Pas de point à {wanted} € parmi {len(points)} —"
            f" le plus proche est {price_of(chosen)} €."
        )

    post_price(client, subscription_id, chosen, price_of(chosen))


def post_price(
    client: Client, subscription_id: str, point: dict, price: float
) -> None:
    """Pose le prix, et explique le refus quand il vient.

    Ce qu'on a appris en essayant
    -----------------------------
    Cinq formes de requête ont été soumises dans un même passage — sans
    attribut, avec `preserveCurrentPrice`, avec ou sans relation de
    territoire, avec une date de début nulle. **Les cinq ont été refusées
    avec exactement le même message** :

        An error occurred while processing the pricing information.

    Cinq refus identiques sur cinq corps différents ne désignent pas le
    corps. Le point de prix est le bon — il vient de la relation propre à
    cet abonnement, filtré sur le territoire et vérifié au retour. Les
    localisations, elles, passent sur le même objet par les mêmes appels.

    Ce qui reste est le compte : Apple ne laisse fixer aucun prix tant que
    le contrat « Paid Applications » n'est pas actif, et le refus qu'il
    rend alors ne nomme pas la cause. Le contrat, lui, n'est pas visible
    par l'API — d'où cette explication écrite ici plutôt qu'un sixième
    essai.
    """
    try:
        client.call(
            "subscriptionPrices",
            method="POST",
            body={
                "data": {
                    "type": "subscriptionPrices",
                    "relationships": {
                        "subscription": {
                            "data": {"type": "subscriptions", "id": subscription_id}
                        },
                        "subscriptionPricePoint": {
                            "data": {
                                "type": "subscriptionPricePoints",
                                "id": point["id"],
                            }
                        },
                    },
                }
            },
        )
    except AppleRefused as refusal:
        print(f"::error::Prix {price} € refusé : {refusal.detail}")
        print(
            "::error::  Cause la plus probable : le contrat « Paid"
            " Applications » n'est pas actif. Apple refuse alors toute"
            " tarification, sans le dire. App Store Connect → Accords, taxes"
            " et banque."
        )
        return
    print(f"    prix posé : {price} € ({TERRITORY})")


def main() -> int:
    try:
        client = Client.from_environment()
        app_id, name = app_identifier(client)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(f"Fiche : « {name} » ({BUNDLE_ID})\n")

    too_long = [
        (offer["productId"], locale, len(description))
        for offer in OFFERS
        for locale, (_, description) in offer["texts"].items()
        if len(description) > DESCRIPTION_LIMIT
    ]
    for product, locale, length in too_long:
        print(
            f"::error::{product} {locale} : description de {length} caractères,"
            f" la limite est {DESCRIPTION_LIMIT}."
        )
    if too_long:
        return 1

    try:
        group_id = ensure_group(client, app_id)
        ensure_group_names(client, group_id)
        known = existing_offers(client, group_id)
        for offer in OFFERS:
            subscription_id = ensure_offer(client, group_id, offer, known)
            if not subscription_id:
                continue
            ensure_offer_texts(client, subscription_id, offer["texts"])
            if POSE_LES_PRIX:
                ensure_price(client, subscription_id, offer["price"])
            else:
                print(f"    prix laissé de côté ({offer['price']} €)")
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    if POSE_LES_PRIX:
        print(
            "\nCe qu'il reste, et que l'API ne sait pas faire : la capture"
            "\nd'écran d'examen du premier abonnement, demandée au moment de la"
            "\nsoumission."
        )
    else:
        print(
            "\nLes prix n'ont pas été posés, à la demande. Ils le seront quand"
            "\nle contrat « Paid Applications » sera actif : relancer ce"
            "\nworkflow avec l'option cochée suffira."
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
