#!/usr/bin/env python3
"""Dit ce qui manque encore pour que l'application puisse être vendue.

Pourquoi ce script existe
-------------------------
La question « il manque quoi ? » revient à chaque fois qu'un build part, et
elle se répondait de mémoire. De mémoire, c'est une liste qui vieillit : elle
garde des cases déjà cochées et rate celles qu'Apple vient d'ajouter. Une
liste fausse coûte plus cher que pas de liste, parce qu'on la croit.

Apple connaît l'état réel. Ce script le lui demande et le rend en clair : ce
qui bloque la vente, ce qui bloque l'examen, et ce qui n'est qu'un confort.

Il ne modifie rien. C'est un état des lieux, pas une correction.
"""

from __future__ import annotations

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

# Les deux abonnements que l'application demande au lancement. S'ils
# n'existent pas chez Apple, StoreKit rend une liste vide et le mur de
# paiement s'affiche sans aucun prix : l'application est installable et
# invendable, ce qui est le pire des deux mondes.
OFFERS = {
    "com.maxlestage.fitnesscoach.plus.monthly": "Stride+ mensuel · 14,99 €",
    "com.maxlestage.fitnesscoach.plus.yearly": "Stride+ annuel · 119,99 €",
}

# Ce qu'Apple répond dans appStoreState, et ce que ça veut dire pour nous.
LIVE_STATES = {"READY_FOR_SALE", "PROCESSING_FOR_APP_STORE", "IN_REVIEW",
               "PENDING_DEVELOPER_RELEASE", "PENDING_APPLE_RELEASE"}


class Report:
    """Trois seaux : ce qui bloque la vente, l'examen, et le reste."""

    def __init__(self) -> None:
        self.blocking: list[str] = []
        self.review: list[str] = []
        self.comfort: list[str] = []
        self.done: list[str] = []


def app(client: Client, bundle_id: str) -> tuple[str, str]:
    apps = client.call(f"apps?filter[bundleId]={bundle_id}&limit=10").get("data", [])
    for entry in apps:
        if entry["attributes"].get("bundleId") == bundle_id:
            return entry["id"], entry["attributes"].get("name", "?")
    raise SystemExit(
        f"Aucune fiche pour {bundle_id}.\n"
        "Soit le bundle est faux, soit la clé d'API ne voit pas cette équipe."
    )


def subscriptions(client: Client, identifier: str, report: Report) -> None:
    """Les abonnements existent-ils, et sont-ils prêts à être vendus ?"""
    try:
        groups = client.call(
            f"apps/{identifier}/subscriptionGroups?limit=50"
        ).get("data", [])
    except AppleRefused as refusal:
        report.blocking.append(
            "Impossible de lire les abonnements : " + refusal.detail
        )
        return

    found: dict[str, dict] = {}
    for group in groups:
        offers = client.call(
            f"subscriptionGroups/{group['id']}/subscriptions?limit=50"
        ).get("data", [])
        for offer in offers:
            found[offer["attributes"].get("productId", "")] = offer["attributes"]

    if not groups:
        report.blocking.append(
            "Aucun groupe d'abonnement. Les deux offres de Stride+ n'existent\n"
            "     pas chez Apple : le mur de paiement s'affichera sans prix."
        )

    for product, label in OFFERS.items():
        attributes = found.get(product)
        if attributes is None:
            report.blocking.append(
                f"L'abonnement « {label} » n'existe pas ({product}).\n"
                "     À créer dans App Store Connect → Monétisation → Abonnements."
            )
            continue
        state = attributes.get("state", "?")
        if state == "APPROVED":
            report.done.append(f"« {label} » approuvé.")
        elif state in ("READY_TO_SUBMIT", "WAITING_FOR_REVIEW", "IN_REVIEW"):
            report.review.append(
                f"« {label} » existe mais n'est pas encore approuvé ({state})."
            )
        else:
            report.blocking.append(
                f"« {label} » est en état {state} : il ne se vendra pas."
            )


def versions(client: Client, identifier: str, report: Report) -> None:
    """Y a-t-il une version prête pour l'App Store, et que lui manque-t-il ?"""
    entries = client.call(
        f"apps/{identifier}/appStoreVersions?limit=5"
        "&fields[appStoreVersions]=versionString,appStoreState,platform"
    ).get("data", [])

    if not entries:
        report.blocking.append(
            "Aucune version App Store créée. TestFlight ne suffit pas :\n"
            "     la vente passe par une version soumise à l'examen."
        )
        return

    for entry in entries[:1]:
        attributes = entry["attributes"]
        version = attributes.get("versionString", "?")
        state = attributes.get("appStoreState", "?")
        if state == "READY_FOR_SALE":
            report.done.append(f"Version {version} en vente.")
        elif state in LIVE_STATES:
            report.review.append(f"Version {version} chez Apple ({state}).")
        else:
            report.review.append(
                f"Version {version} en préparation ({state}) — pas encore soumise."
            )
            localisations(client, entry["id"], report)


def localisations(client: Client, version_id: str, report: Report) -> None:
    """La description, les mots-clés et les captures d'écran sont-ils là ?"""
    try:
        entries = client.call(
            f"appStoreVersions/{version_id}/appStoreVersionLocalizations?limit=20"
        ).get("data", [])
    except AppleRefused:
        return

    if not entries:
        report.review.append("Aucune fiche rédigée : ni description ni mots-clés.")
        return

    for entry in entries:
        attributes = entry["attributes"]
        locale = attributes.get("locale", "?")
        if not (attributes.get("description") or "").strip():
            report.review.append(f"Description vide en {locale}.")
        if not (attributes.get("keywords") or "").strip():
            report.review.append(f"Mots-clés vides en {locale}.")
        shots = client.call(
            f"appStoreVersionLocalizations/{entry['id']}"
            "/appScreenshotSets?limit=10"
        ).get("data", [])
        if not shots:
            report.review.append(f"Aucune capture d'écran en {locale}.")


def agreements(client: Client, report: Report) -> None:
    """Les informations bancaires et fiscales : le blocage le plus discret."""
    # Apple n'expose pas les contrats par l'API. Le dire est plus honnête que
    # de laisser croire que le script a tout vérifié.
    report.comfort.append(
        "Contrat payant, coordonnées bancaires et informations fiscales :\n"
        "     invisibles par l'API. À vérifier une fois dans App Store Connect\n"
        "     → Accords, taxes et banque. Sans eux, rien ne se vend, même\n"
        "     approuvé."
    )


def show(title: str, rows: list[str], marker: str) -> None:
    if not rows:
        return
    print(f"\n{title}")
    for row in rows:
        print(f"  {marker} {row}")


def main() -> int:
    bundle_id = os.environ.get("BUNDLE_ID", "com.maxlestage.fitnesscoach")
    try:
        client = Client.from_environment()
        identifier, name = app(client, bundle_id)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    print(f"Fiche : « {name} » ({bundle_id})")

    report = Report()
    try:
        subscriptions(client, identifier, report)
        versions(client, identifier, report)
        agreements(client, report)
    except AppleRefused as refusal:
        print(refusal.explain(), file=sys.stderr)
        return 1

    show("Bloque la vente :", report.blocking, "::error::")
    show("Bloque l'examen :", report.review, "-")
    show("À vérifier à la main :", report.comfort, "-")
    show("Déjà fait :", report.done, "✓")

    if not report.blocking and not report.review:
        print("\nRien ne bloque du côté d'Apple.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
