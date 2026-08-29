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
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

API = "https://api.appstoreconnect.apple.com/v1"
# Le type que veut TestFlight. « DISTRIBUTION » est le nom actuel de ce que
# l'interface d'Apple appelle « Apple Distribution » — un seul certificat pour
# iOS, watchOS et le reste, là où l'ancien IOS_DISTRIBUTION ne couvrait qu'iOS.
CERTIFICATE_TYPE = "DISTRIBUTION"


def b64url(raw: bytes) -> str:
    """base64 sans remplissage, alphabet URL : l'encodage des jetons JWT."""
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def der_to_raw_signature(der: bytes) -> bytes:
    """Convertit une signature ECDSA DER en la paire (r, s) brute du JWT.

    `openssl dgst -sign` rend du DER : une séquence de deux entiers de
    longueur variable. ES256 veut exactement soixante-quatre octets, r et s
    complétés à trente-deux chacun. Sans cette conversion, Apple répond 401 à
    une signature pourtant valide — l'erreur la plus coûteuse de tout ce
    fichier, parce qu'elle ressemble à une mauvaise clé.
    """
    if not der or der[0] != 0x30:
        raise ValueError("signature DER attendue (séquence)")

    index = 2
    if der[1] & 0x80:  # longueur sur plusieurs octets
        index = 2 + (der[1] & 0x7F)

    def read_integer(pos: int) -> tuple[int, int]:
        if der[pos] != 0x02:
            raise ValueError("entier DER attendu")
        length = der[pos + 1]
        start = pos + 2
        value = der[start : start + length]
        # DER préfixe un zéro quand le bit de poids fort est à 1, pour que
        # l'entier reste positif. Ce zéro n'appartient pas au nombre.
        return int.from_bytes(value, "big"), start + length

    r, next_pos = read_integer(index)
    s, _ = read_integer(next_pos)
    return r.to_bytes(32, "big") + s.to_bytes(32, "big")


def jwt(key_path: str, key_id: str, issuer_id: str) -> str:
    """Le jeton d'authentification App Store Connect, signé par la clé .p8."""
    header = {"alg": "ES256", "kid": key_id, "typ": "JWT"}
    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        # Apple refuse au-delà de vingt minutes. Dix suffisent largement et
        # laissent la marge d'une horloge d'exécuteur mal réglée.
        "exp": now + 600,
        "aud": "appstoreconnect-v1",
    }
    signing_input = f"{b64url(json.dumps(header).encode())}.{b64url(json.dumps(payload).encode())}"

    der = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path, "-binary"],
        input=signing_input.encode(),
        capture_output=True,
        check=True,
    ).stdout

    return f"{signing_input}.{b64url(der_to_raw_signature(der))}"


def call(token: str, path: str, method: str = "GET", body: dict | None = None) -> dict:
    request = urllib.request.Request(
        f"{API}/{path}",
        method=method,
        data=json.dumps(body).encode() if body else None,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            return json.loads(response.read() or b"{}")
    except urllib.error.HTTPError as error:
        detail = error.read().decode("utf-8", "replace")
        raise AppleRefused(error.code, detail) from None


class AppleRefused(Exception):
    def __init__(self, status: int, body: str):
        super().__init__(f"HTTP {status}")
        self.status = status
        self.body = body

    def explain(self) -> str:
        """Traduit le refus en ce qu'il faut faire, pas en ce qu'Apple a dit."""
        try:
            errors = json.loads(self.body).get("errors", [])
            detail = "; ".join(
                f"{e.get('title', '')} — {e.get('detail', '')}".strip(" —")
                for e in errors
            )
        except (ValueError, AttributeError):
            detail = self.body[:400]

        if self.status == 401:
            # Un 401 n'est pas un problème de droits : Apple n'a pas reconnu
            # le jeton. Renvoyer la personne vers le rôle de la clé lui ferait
            # refaire une clé qui ne changerait rien.
            return (
                f"Apple ne reconnaît pas la clé d'API ({self.status}). {detail}\n"
                "\n"
                "Ce n'est pas une question de droits : le jeton lui-même est "
                "rejeté.\n"
                "Vérifie que ASC_KEY_ID est bien le Key ID de la clé (dix "
                "caractères),\n"
                "que ASC_ISSUER_ID est l'Issuer ID du compte, et que "
                "ASC_KEY_P8 contient\n"
                "le fichier .p8 correspondant à ce Key ID. Une clé révoquée "
                "donne aussi\n"
                "cette réponse."
            )
        if self.status == 403:
            return (
                f"Apple refuse la demande ({self.status}). {detail}\n"
                "\n"
                "La cause la plus fréquente : la clé d'API n'a pas le rôle "
                "Admin.\n"
                "Créer un certificat de distribution est réservé à ce rôle ; "
                "une clé\n"
                "« App Manager » lit tout mais ne signe rien. Le rôle d'une "
                "clé ne se\n"
                "change pas après coup — il faut en créer une nouvelle dans "
                "App Store\n"
                "Connect → Users and Access → Integrations, avec le rôle "
                "Admin, puis\n"
                "reposer ASC_KEY_ID, ASC_ISSUER_ID et ASC_KEY_P8."
            )
        if self.status == 409:
            return (
                f"Apple refuse la demande ({self.status}). {detail}\n"
                "\n"
                "Un compte n'a droit qu'à deux certificats de distribution, et "
                "les deux\n"
                "sont pris. Chaque exécution en consomme un, puisque "
                "l'exécuteur est\n"
                "détruit ensuite avec la clé privée. Révoque les anciens dans "
                "le portail\n"
                "développeur (Certificates), ou fournis un .p12 par les "
                "secrets pour ne\n"
                "plus en créer du tout."
            )
        return f"Apple refuse la demande ({self.status}). {detail}"


def distribution_certificates(token: str) -> list[dict]:
    response = call(token, "certificates?limit=200")
    return [
        item
        for item in response.get("data", [])
        if item["attributes"].get("certificateType") == CERTIFICATE_TYPE
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


def revoke(token: str, identifier: str) -> None:
    call(token, f"certificates/{identifier}", method="DELETE")


def revoke_stale(key_path: str, key_id: str, issuer_id: str, days: int) -> int:
    """Libère la place prise par les certificats de cette automatisation.

    Un compte n'a droit qu'à deux certificats de distribution. Chaque
    exécution en crée un dont la clé privée meurt avec l'exécuteur : deux
    builds suffisent à saturer le compte avec des certificats que plus
    personne ne peut utiliser, y compris celui qui les a créés.

    La règle est volontairement étroite. Seuls partent les certificats de
    distribution créés dans les tout derniers jours — ceux d'ici. Un
    certificat plus ancien peut avoir sa clé privée sur le Mac de quelqu'un,
    et le révoquer casserait sa signature : celui-là n'est jamais touché, et
    le refus d'Apple est alors rapporté tel quel.
    """
    token = jwt(key_path, key_id, issuer_id)
    stale = [
        item
        for item in distribution_certificates(token)
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
            f"(série {attributes.get('serialNumber', '?')}, "
            f"expirait le {attributes.get('expirationDate', '?')[:10]})"
        )
        revoke(token, item["id"])
    return len(stale)


def main() -> int:
    key_path = os.environ["ASC_KEY_PATH"]
    key_id = os.environ["ASC_KEY_ID"]
    issuer_id = os.environ["ASC_ISSUER_ID"]
    out_dir = os.environ.get("OUT_DIR", ".")

    # Deux modes annexes, appelés par le workflow autour du mode principal.
    if len(sys.argv) > 1 and sys.argv[1] == "--revoke":
        revoke(jwt(key_path, key_id, issuer_id), sys.argv[2])
        print(f"Certificat {sys.argv[2]} révoqué.")
        return 0
    if len(sys.argv) > 1 and sys.argv[1] == "--revoke-stale":
        revoke_stale(key_path, key_id, issuer_id, days=3)
        return 0

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

    token = jwt(key_path, key_id, issuer_id)

    with open(csr, "r", encoding="ascii") as handle:
        csr_content = handle.read()

    print("Demande d'un certificat de distribution à Apple…")
    try:
        response = call(
            token,
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
            existing = call(jwt(key_path, key_id, issuer_id), "certificates?limit=200")
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
