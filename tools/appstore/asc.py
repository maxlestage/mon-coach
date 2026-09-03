"""Le strict nécessaire pour parler à l'API App Store Connect.

Partagé par les outils du dossier. Aucune dépendance hors bibliothèque
standard : `openssl` fait la cryptographie, Python assemble. Sur un exécuteur
de build, chaque paquet qu'on installe est une façon de plus d'échouer.
"""

from __future__ import annotations

import base64
import json
import os
import subprocess
import time
import urllib.error
import urllib.request

API = "https://api.appstoreconnect.apple.com/v1"


def b64url(raw: bytes) -> str:
    """base64 sans remplissage, alphabet URL : l'encodage des jetons JWT."""
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode("ascii")


def der_to_raw_signature(der: bytes) -> bytes:
    """Convertit une signature ECDSA DER en la paire (r, s) brute du JWT.

    `openssl dgst -sign` rend du DER : une séquence de deux entiers de
    longueur variable. ES256 veut exactement soixante-quatre octets, r et s
    complétés à trente-deux chacun. Sans cette conversion, Apple répond 401 à
    une signature pourtant valide — l'erreur la plus coûteuse de ce dossier,
    parce qu'elle ressemble à une mauvaise clé.
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
        # DER préfixe un zéro quand le bit de poids fort est à 1, pour que
        # l'entier reste positif. Ce zéro n'appartient pas au nombre.
        return int.from_bytes(der[start : start + length], "big"), start + length

    r, next_pos = read_integer(index)
    s, _ = read_integer(next_pos)
    return r.to_bytes(32, "big") + s.to_bytes(32, "big")


class AppleRefused(Exception):
    def __init__(self, status: int, body: str):
        super().__init__(f"HTTP {status}")
        self.status = status
        self.body = body

    @property
    def detail(self) -> str:
        try:
            errors = json.loads(self.body).get("errors", [])
            return "; ".join(
                f"{e.get('title', '')} — {e.get('detail', '')}".strip(" —")
                for e in errors
            )
        except (ValueError, AttributeError):
            return self.body[:400]

    def explain(self) -> str:
        """Traduit le refus en ce qu'il faut faire, pas en ce qu'Apple a dit."""
        if self.status == 401:
            # Un 401 n'est pas un problème de droits : Apple n'a pas reconnu
            # le jeton. Renvoyer la personne vers le rôle de la clé lui ferait
            # refaire une clé qui ne changerait rien.
            return (
                f"Apple ne reconnaît pas la clé d'API ({self.status}). {self.detail}\n"
                "\nCe n'est pas une question de droits : le jeton lui-même est"
                " rejeté.\nVérifie que ASC_KEY_ID est bien le Key ID de la clé,"
                " que ASC_ISSUER_ID\nest l'Issuer ID du compte, et que ASC_KEY_P8"
                " contient le fichier .p8\ncorrespondant. Une clé révoquée donne"
                " aussi cette réponse."
            )
        if self.status == 403:
            return (
                f"Apple refuse la demande ({self.status}). {self.detail}\n"
                "\nLa cause la plus fréquente : la clé d'API n'a pas le rôle"
                " Admin.\nUne clé « App Manager » lit tout mais ne crée rien. Le"
                " rôle d'une clé ne\nse change pas après coup — il faut en créer"
                " une nouvelle dans App Store\nConnect → Users and Access →"
                " Integrations, puis reposer les trois secrets."
            )
        return f"Apple refuse la demande ({self.status}). {self.detail}"


class Client:
    """Une session authentifiée, qui renouvelle son jeton quand il vieillit."""

    def __init__(self, key_path: str, key_id: str, issuer_id: str):
        self.key_path = key_path
        self.key_id = key_id
        self.issuer_id = issuer_id
        self._token = ""
        self._minted = 0.0

    @classmethod
    def from_environment(cls) -> "Client":
        return cls(
            os.environ["ASC_KEY_PATH"],
            os.environ["ASC_KEY_ID"],
            os.environ["ASC_ISSUER_ID"],
        )

    @property
    def token(self) -> str:
        # Apple refuse un jeton de plus de vingt minutes. On en refait un bien
        # avant, pour qu'une suite d'appels un peu longue ne meure pas en
        # chemin sur une expiration.
        if not self._token or time.time() - self._minted > 300:
            self._token = self._mint()
            self._minted = time.time()
        return self._token

    def _mint(self) -> str:
        header = {"alg": "ES256", "kid": self.key_id, "typ": "JWT"}
        now = int(time.time())
        payload = {
            "iss": self.issuer_id,
            "iat": now,
            "exp": now + 600,
            "aud": "appstoreconnect-v1",
        }
        signing_input = (
            f"{b64url(json.dumps(header).encode())}."
            f"{b64url(json.dumps(payload).encode())}"
        )
        der = subprocess.run(
            ["openssl", "dgst", "-sha256", "-sign", self.key_path, "-binary"],
            input=signing_input.encode(),
            capture_output=True,
            check=True,
        ).stdout
        return f"{signing_input}.{b64url(der_to_raw_signature(der))}"

    # Les codes qu'Apple rend quand la panne est chez lui, et qu'un second
    # essai suffit souvent. Le 429 y est joint : c'est un « plus tard », pas
    # un « non ».
    TRANSIENT = {429, 500, 502, 503, 504}
    ATTEMPTS = 3

    def call(self, path: str, method: str = "GET", body: dict | None = None) -> dict:
        """Un appel, réessayé quand la panne vient d'en face.

        Apple rend des 500 passagers — « an unexpected error occurred on the
        server side » — au milieu d'une suite d'appels par ailleurs valides.
        Un seul a suffi à interrompre la création des abonnements après le
        groupe et avant les offres, laissant le travail à moitié fait.

        Trois tentatives, espacées d'une puis deux secondes. Au-delà, ce n'est
        plus un hoquet, et insister masquerait un vrai problème.
        """
        for attempt in range(1, self.ATTEMPTS + 1):
            try:
                return self._call_once(path, method, body)
            except AppleRefused as refusal:
                if refusal.status not in self.TRANSIENT or attempt == self.ATTEMPTS:
                    raise
                print(
                    f"  Apple a répondu {refusal.status} ; nouvel essai"
                    f" ({attempt}/{self.ATTEMPTS - 1})"
                )
                time.sleep(attempt)
        raise AssertionError("inatteignable")

    def _call_once(self, path: str, method: str, body: dict | None) -> dict:
        request = urllib.request.Request(
            f"{API}/{path}",
            method=method,
            data=json.dumps(body).encode() if body else None,
            headers={
                "Authorization": f"Bearer {self.token}",
                "Content-Type": "application/json",
            },
        )
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                return json.loads(response.read() or b"{}")
        except urllib.error.HTTPError as error:
            raise AppleRefused(
                error.code, error.read().decode("utf-8", "replace")
            ) from None
