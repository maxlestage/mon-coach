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


def testers(client: Client, group_id: str) -> list[str]:
    """Qui reçoit vraiment les builds de ce groupe.

    Le dernier maillon de la chaîne, et le seul qui restait invérifié. Un
    groupe qui reçoit tous les builds mais ne contient personne laisse
    l'application TestFlight du téléphone aussi vide qu'un groupe absent.
    """
    try:
        found = client.call(f"betaGroups/{group_id}/betaTesters").get("data", [])
    except AppleRefused:
        return []
    names = []
    for item in found:
        attributes = item["attributes"]
        label = " ".join(
            part for part in (attributes.get("firstName"), attributes.get("lastName")) if part
        )
        names.append(label or attributes.get("email", "?"))
    return names


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


def crashes(client: Client, identifier: str) -> None:
    """Les plantages remontés depuis TestFlight, avec leur journal.

    Un plantage vu par le testeur est une capture d'écran et une phrase ;
    vu d'ici, c'est une pile d'appels qui nomme la ligne. Apple garde les
    deux, et la seconde ne demande qu'à être lue plutôt que devinée.

    Le journal est imprimé tel quel : il ne contient que des adresses et
    des noms de symboles de l'application, rien de l'appareil ni de son
    propriétaire au-delà du modèle et de la version d'iOS.
    """
    try:
        found = client.call(
            f"apps/{identifier}/betaFeedbackCrashSubmissions"
            "?limit=5&sort=-createdDate&include=build"
        )
    except AppleRefused as refusal:
        print(f"::warning::Plantages illisibles : {refusal.explain()}")
        return

    rows = found.get("data", [])
    if not rows:
        print("\nAucun plantage remonté depuis TestFlight.")
        print("Un plantage n'arrive ici que si le testeur a envoyé le retour")
        print("qu'iOS propose juste après — sinon il ne quitte pas l'appareil.")
        return

    print(f"\n{len(rows)} plantage(s) remonté(s) :")
    for row in rows:
        attributes = row["attributes"]
        print()
        print(f"  {attributes.get('createdDate', '?')[:19].replace('T', ' à ')}")
        print(f"    appareil : {attributes.get('deviceModel', '?')}"
              f" — {attributes.get('osVersion', '?')}")
        uptime = attributes.get("appUptimeInMilliseconds")
        if uptime is not None:
            # Le temps écoulé depuis le lancement situe le plantage mieux
            # qu'aucune description : deux secondes désignent le démarrage,
            # deux minutes désignent un écran qu'on a ouvert.
            print(f"    plantage après {uptime / 1000:.1f} s d'utilisation")
        for key in ("comment", "appPlatform", "devicePlatform", "buildBundleId"):
            if attributes.get(key):
                print(f"    {key} : {attributes[key]}")

        url = (attributes.get("crashLog") or {}).get("url") if isinstance(
            attributes.get("crashLog"), dict
        ) else attributes.get("crashLog")
        if not url:
            print("    (aucun journal joint)")
            continue
        try:
            import urllib.request

            with urllib.request.urlopen(url, timeout=60) as response:
                log = response.read().decode("utf-8", "replace")
        except Exception as error:  # noqa: BLE001
            print(f"    journal illisible : {error}")
            continue
        print("    --- journal ---")
        for line in log.splitlines()[:120]:
            print(f"    {line}")


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

    existing = groups(client, identifier)

    # Un groupe interne réglé sur « tous les builds » ne matérialise aucun
    # lien vers chacun d'eux : l'API rend une liste vide, et en déduire que
    # le build n'est distribué nulle part est faux. Cet outil a fait cette
    # erreur, et a envoyé quelqu'un cocher une case déjà cochée.
    automatic = [
        g["attributes"].get("name", "?")
        for g in existing
        if g["attributes"].get("isInternalGroup") and g["attributes"].get("hasAccessToAllBuilds")
    ]

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
        attributed = build_groups(client, row["id"]) + automatic
        if attributed:
            print(f"    distribué à : {', '.join(sorted(set(attributed)))}")
        else:
            print("    ::warning:: distribué à aucun groupe de testeurs.")
            print("    Il est visible dans App Store Connect, mais pas dans")
            print("    l'application TestFlight du téléphone.")

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
            reach = (
                ", reçoit tous les builds"
                if attributes.get("hasAccessToAllBuilds")
                else ", ne reçoit que les builds qu'on lui attribue"
            )
            print(f"  - « {attributes.get('name', '?')} » ({kind}{reach})")
            people = testers(client, group["id"])
            if people:
                print(f"      testeurs : {', '.join(people)}")
            else:
                print("      ::warning:: aucun testeur dans ce groupe.")
                print("      Un groupe vide ne fait rien apparaître sur aucun")
                print("      téléphone, quels que soient les builds qu'il reçoit.")

    # L'attribution ne se fait que si on la demande. Lire l'état et changer la
    # distribution sont deux gestes différents, et le second doit se voir dans
    # l'historique des exécutions plutôt que se produire à chaque coup d'œil.
    if os.environ.get("ATTRIBUTE", "").strip().lower() in ("1", "true", "oui"):
        attribute(client, rows, existing)

    if os.environ.get("CRASHES", "").strip().lower() in ("1", "true", "oui"):
        crashes(client, identifier)

    return 0


if __name__ == "__main__":
    sys.exit(main())
