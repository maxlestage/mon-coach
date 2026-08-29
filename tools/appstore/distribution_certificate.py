#!/usr/bin/env python3
"""Crée un certificat de distribution Apple depuis une machine sans Mac.

Pourquoi ce script existe
-------------------------
Un envoi vers TestFlight doit être signé par un certificat *Apple
Distribution*. Ce certificat n'est pas un fichier qu'on télécharge : c'est la
signature, par Apple, d'une clé privée qui doit naître sur la machine qui
signera. C'est ce qui impose habituellement un Mac — et c'est exactement ce
qu'on n'a pas ici.

Xcode sait le faire seul avec `-allowProvisioningUpdates`, mais il le fait en
silence : quand Apple refuse, il retombe sur un certificat de *développement*
sans rien dire, et l'archive part signée pour le débogage. Le build meurt
alors bien plus loin, sur un profil introuvable, sans qu'aucune ligne ne parle
de certificat. C'est précisément ce qui est arrivé.

Ce script fait donc les trois gestes à découvert :

1. il fabrique une clé privée RSA et sa demande de signature (CSR) ;
2. il demande à Apple de la signer, via l'API App Store Connect ;
3. il rend le certificat et la clé, prêts à devenir un .p12.

Aucune dépendance hors bibliothèque standard : `openssl` fait la
cryptographie, Python assemble. Sur un exécuteur de build, chaque paquet
qu'on installe est une façon de plus d'échouer.
"""

from __future__ import annotations

import base64
import datetime
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from asc import AppleRefused, Client  # noqa: E402

# Le type que veut TestFlight. « DISTRIBUTION » est le nom actuel de ce que
# l'interface d'Apple appelle « Apple Distribution » — un seul certificat pour
# iOS, watchOS et le reste, là où l'ancien IOS_DISTRIBUTION ne couvrait qu'iOS.
CERTIFICATE_TYPE = "DISTRIBUTION"

# Les types dont cette automatisation laisse des traces. Xcode crée aussi des
# certificats de *développement* pendant l'archivage, sans qu'on les demande :
# ils comptent dans le quota du compte, et deux exécutions suffisent à le
# saturer. Un « maximum number of certificates » tombe alors à l'archivage,
# sur une cible au hasard, sans jamais dire que la place manque.
CLEANABLE_TYPES = ("DISTRIBUTION", "DEVELOPMENT")


def certificates(client: Client, types: tuple[str, ...]) -> list[dict]:
    response = client.call("certificates?limit=200")
    return [
        item
        for item in response.get("data", [])
        if item["attributes"].get("certificateType") in types
    ]


def created_within_days(attributes: dict, days: int) -> bool:
    """Le certificat a-t-il été créé dans les `days` derniers jours ?

    Apple ne rend pas la date de création, seulement l'expiration. Un
    certificat de distribution vaut un an : reculer d'un an sur l'expiration
    donne la création à un cheveu près, ce qui suffit largement à distinguer
    « créé tout à l'heure par cette automatisation » de « créé un autre jour
    par quelqu'un ».
    """
    raw = attributes.get("expirationDate", "")[:10]
    try:
        expires = datetime.date.fromisoformat(raw)
    except ValueError:
        return False
    created = expires - datetime.timedelta(days=365)
    return 0 <= (datetime.date.today() - created).days <= days


def revoke(client: Client, identifier: str) -> None:
    client.call(f"certificates/{identifier}", method="DELETE")


def revoke_stale(client: Client, days: int) -> int:
    """Libère la place prise par les certificats de cette automatisation.

    Un compte a un quota par type de certificat. Chaque exécution en crée un
    de distribution, et Xcode en crée un de développement pendant l'archivage
    sans qu'on le demande — leur clé privée meurt avec l'exécuteur. Deux
    builds suffisent donc à saturer le compte avec des certificats que plus
    personne ne peut utiliser, y compris celui qui les a créés. La saturation
    du côté développement ne se voit qu'à l'archivage, sur une cible au
    hasard, par un message qui ne parle pas de quota.

    La règle est volontairement étroite. Seuls partent les certificats créés
    dans les tout derniers jours — ceux d'ici. Un certificat plus ancien peut
    avoir sa clé privée sur le Mac de quelqu'un, et le révoquer casserait sa
    signature : celui-là n'est jamais touché, et le refus d'Apple est alors
    rapporté tel quel.
    """
    stale = [
        item
        for item in certificates(client, CLEANABLE_TYPES)
        if created_within_days(item["attributes"], days)
    ]
    if not stale:
        print(
            "Aucun certificat récent à libérer : ceux qui occupent la place "
            "datent d'avant, et ne sont pas à cette automatisation."
        )
        return 0

    for item in stale:
        attributes = item["attributes"]
        print(
            f"Révocation de {attributes.get('displayName', '?')} "
            f"[{attributes.get('certificateType', '?')}] "
            f"(série {attributes.get('serialNumber', '?')}, "
            f"expirait le {attributes.get('expirationDate', '?')[:10]})"
        )
        revoke(client, item["id"])
    return len(stale)


def find_app(client: Client, bundle_id: str) -> int:
    """La fiche de l'application existe-t-elle dans App Store Connect ?

    L'envoi vers TestFlight suppose une fiche déjà créée : Xcode va y chercher
    les informations de l'application avant de téléverser. Quand elle manque,
    il échoue sur « Error Downloading App Information » — une phrase qui ne
    nomme ni l'application, ni l'identifiant, ni ce qu'il faut faire, et qui
    tombe après le quart d'heure qu'a duré l'archivage.

    Cette vérification coûte une requête et tombe avant tout le reste.
    """
    try:
        response = client.call(f"apps?filter[bundleId]={bundle_id}&limit=10")
    except AppleRefused as refusal:
        print(f"::warning::Impossible de vérifier la fiche : {refusal.explain()}")
        # Ne pas bloquer sur un doute : c'est une vérification de confort, et
        # l'export dira la vérité de toute façon.
        return 0

    apps = response.get("data", [])
    exact = [a for a in apps if a["attributes"].get("bundleId") == bundle_id]
    if exact:
        attributes = exact[0]["attributes"]
        print(
            f"Fiche trouvée : « {attributes.get('name', '?')} » "
            f"({bundle_id})"
        )
        return 0

    print(
        f"::error::Aucune fiche d'application pour {bundle_id} dans App Store Connect."
    )
    print()
    print("L'envoi vers TestFlight suppose une fiche déjà créée : Xcode y lit")
    print("les informations de l'application avant de téléverser. Sans elle, il")
    print("échoue sur « Error Downloading App Information », après l'archivage.")
    print()
    print("À faire une fois, depuis un téléphone :")
    print("  App Store Connect → Apps → +  → New App")
    print("    Plateformes : iOS")
    print(f"    Bundle ID   : {bundle_id}")
    print("    Nom         : unique sur tout l'App Store — un nom déjà pris est")
    print("                  refusé, et c'est le cas de la plupart des noms")
    print("                  génériques. Il pourra être changé plus tard.")
    print("    SKU         : n'importe quel identifiant interne, par exemple")
    print(f"                  {bundle_id}")
    print()
    print("Si le Bundle ID n'apparaît pas dans la liste, il faut d'abord le")
    print("déclarer : developer.apple.com → Certificates, Identifiers &")
    print("Profiles → Identifiers → +.")
    return 1


def main() -> int:
    key_path = os.environ["ASC_KEY_PATH"]
    out_dir = os.environ.get("OUT_DIR", ".")
    client = Client.from_environment()

    # Deux modes annexes, appelés par le workflow autour du mode principal.
    if len(sys.argv) > 1 and sys.argv[1] == "--revoke":
        revoke(client, sys.argv[2])
        print(f"Certificat {sys.argv[2]} révoqué.")
        return 0
    if len(sys.argv) > 1 and sys.argv[1] == "--revoke-stale":
        revoke_stale(client, days=3)
        return 0
    if len(sys.argv) > 1 and sys.argv[1] == "--find-app":
        return find_app(client, sys.argv[2])

    os.makedirs(out_dir, exist_ok=True)
    private_key = os.path.join(out_dir, "distribution.key")
    csr = os.path.join(out_dir, "distribution.csr")
    certificate = os.path.join(out_dir, "distribution.pem")

    # Apple n'accepte que RSA 2048 pour un certificat de signature.
    subprocess.run(
        [
            "openssl", "req", "-new", "-nodes",
            "-newkey", "rsa:2048",
            "-keyout", private_key,
            "-out", csr,
            "-subj", "/CN=MonCoach Distribution/O=MonCoach/C=FR",
        ],
        check=True,
        capture_output=True,
    )
    os.chmod(private_key, 0o600)

    with open(csr, "r", encoding="ascii") as handle:
        csr_content = handle.read()

    print("Demande d'un certificat de distribution à Apple…")
    try:
        response = client.call(
            "certificates",
            method="POST",
            body={
                "data": {
                    "type": "certificates",
                    "attributes": {
                        "certificateType": CERTIFICATE_TYPE,
                        "csrContent": csr_content,
                    },
                }
            },
        )
    except AppleRefused as refusal:
        print(f"::error::{refusal.explain()}", file=sys.stderr)
        # Ce que le compte a déjà, quand on a le droit de le lire : sans cette
        # liste, « deux certificats sur deux » reste une affirmation.
        try:
            existing = client.call("certificates?limit=200")
            rows = [
                item["attributes"]
                for item in existing.get("data", [])
                if item["attributes"].get("certificateType") == CERTIFICATE_TYPE
            ]
            if rows:
                print("\nCertificats de distribution déjà existants :")
                for row in rows:
                    print(
                        f"  - {row.get('displayName', '?')} "
                        f"(expire le {row.get('expirationDate', '?')[:10]})"
                    )
        except AppleRefused:
            pass
        # Un code distinct pour « plus de place » : c'est le seul refus dont
        # cette automatisation sache se relever seule, en libérant ce qu'elle
        # a elle-même laissé. Tous les autres demandent une décision humaine.
        return 9 if refusal.status == 409 else 1

    attributes = response["data"]["attributes"]

    # L'identifiant est écrit tout de suite, avant même d'écrire le
    # certificat : c'est lui qui permettra de rendre la place en fin de build.
    # S'il se perdait, le compte garderait un certificat que personne ne peut
    # plus utiliser, et deux builds suffisent à le saturer.
    with open(os.path.join(out_dir, "certificate-id.txt"), "w", encoding="ascii") as handle:
        handle.write(response["data"]["id"])

    der = base64.b64decode(attributes["certificateContent"])
    with open(os.path.join(out_dir, "distribution.cer"), "wb") as handle:
        handle.write(der)

    subprocess.run(
        [
            "openssl", "x509",
            "-inform", "DER",
            "-in", os.path.join(out_dir, "distribution.cer"),
            "-out", certificate,
        ],
        check=True,
        capture_output=True,
    )

    print(
        f"Certificat obtenu : {attributes.get('displayName', '?')} "
        f"(expire le {attributes.get('expirationDate', '?')[:10]})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
