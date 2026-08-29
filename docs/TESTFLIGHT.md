# Envoyer une version à TestFlight

Ce guide se suit **entièrement depuis un téléphone**, sauf une étape qui
demande un Mac une seule fois (le certificat). Une fois la configuration
faite, un build part en trois tapes depuis l'onglet Actions de GitHub.

---

## Ce qu'il faut avant de commencer

**Un compte Apple Developer payant** — 99 $ ou 99 € par an. C'est la seule
dépense obligatoire, et il n'existe aucun contournement : sans lui, aucune
application ne peut être installée sur un iPhone qui n'est pas branché à
ton Mac, TestFlight compris.

Inscription : [developer.apple.com/programs](https://developer.apple.com/programs/).
Compter jusqu'à 48 h de vérification.

---

## 1. Créer la fiche de l'application

Dans [App Store Connect](https://appstoreconnect.apple.com) → **Mes apps** →
**+** → **Nouvelle app** :

- **Plateformes** : iOS
- **Nom** : Mon Coach
- **Langue principale** : Français
- **Identifiant de bundle** : `com.moncoach.MonCoach`
  S'il n'apparaît pas dans la liste, il faut d'abord le créer dans
  [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list)
  → **Identifiers** → **+** → App IDs → App, avec les capacités
  **HealthKit**, **Live Activities** et **App Groups** si tu veux la montre.
- **SKU** : `moncoach` (usage interne, invisible)

Il faut trois identifiants au total, un par cible :

| Cible | Identifiant |
| --- | --- |
| Application | `com.moncoach.MonCoach` |
| Montre | `com.moncoach.MonCoach.watchkitapp` |
| Widgets | `com.moncoach.MonCoach.MonCoachWidgets` |

---

## 2. Créer la clé d'API App Store Connect

C'est elle qui autorise GitHub à déposer un build, sans jamais lui confier
ton mot de passe Apple.

App Store Connect → **Utilisateurs et accès** → onglet **Intégrations** →
**Clés d'API App Store Connect** → **+** :

- **Nom** : `GitHub Actions`
- **Accès** : **App Manager**

Après validation, note :

- l'**Issuer ID** (en haut de la page, un long identifiant) ;
- le **Key ID** (colonne de la ligne créée) ;
- et **télécharge le fichier `.p8`** — Apple ne le propose **qu'une seule
  fois**. Perdu, il faut refaire une clé.

---

## 3. Le certificat de distribution — l'étape qui demande un Mac

Un certificat de distribution est une paire de clés dont la partie privée
ne peut pas être générée par un site web. Il faut donc un Mac **une fois**,
pour le créer et l'exporter. Ensuite, il vit dans les secrets GitHub et
reste valable un an.

Sur un Mac, dans Xcode → **Settings** → **Accounts** → ton compte →
**Manage Certificates** → **+** → **Apple Distribution**. Puis, dans
**Trousseau d'accès** → Mes certificats → clic droit sur le certificat →
**Exporter** → format `.p12`, avec un mot de passe que tu retiens.

> **Sans aucun Mac accessible ?** L'automatisation ne peut pas être mise en
> route, et aucun service en ligne sérieux ne contourne cette étape. La
> solution est d'emprunter un Mac une heure, ou de passer par un service de
> Mac à distance (MacStadium, MacinCloud) le temps de l'export.

---

## 4. Poser les six secrets dans GitHub

Dépôt → **Settings** → **Secrets and variables** → **Actions** → **New
repository secret**, six fois :

| Nom | Contenu |
| --- | --- |
| `APPLE_TEAM_ID` | Ton Team ID, dans [Membership](https://developer.apple.com/account) — dix caractères |
| `APPSTORE_ISSUER_ID` | L'Issuer ID de l'étape 2 |
| `APPSTORE_KEY_ID` | Le Key ID de l'étape 2 |
| `APPSTORE_PRIVATE_KEY` | Le fichier `.p8`, **encodé en base64** |
| `APPLE_DISTRIBUTION_CERT_P12` | Le fichier `.p12`, **encodé en base64** |
| `APPLE_DISTRIBUTION_CERT_PASSWORD` | Le mot de passe choisi à l'export |

Pour encoder un fichier en base64 sur un Mac, dans le Terminal :

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy   # colle ensuite dans le secret
base64 -i certificat.p12 | pbcopy
```

Sur iPhone, l'app **Raccourcis** sait le faire : action *Encoder en base64*
sur un fichier, puis *Copier dans le presse-papiers*.

---

## 5. Lancer le build

Dépôt → onglet **Actions** → workflow **TestFlight** → bouton **Run
workflow** :

- **Version affichée** : laisser vide pour garder celle du projet, ou saisir
  `1.0.1` pour la changer.
- **Nouveautés pour les testeurs** : ce que tu veux qu'ils lisent.

Le build prend entre quinze et trente minutes. Le numéro de build est
automatique — c'est le compteur d'exécutions, qui ne recule jamais, ce
qu'App Store Connect exige.

Ensuite, Apple traite le build pendant cinq à quinze minutes, puis il
apparaît dans **App Store Connect → TestFlight**. Tu peux alors t'ajouter
comme testeur interne et l'installer sur ton iPhone.

---

## Si ça échoue

Le workflow s'arrête franchement et nomme la cause. Les échecs les plus
courants :

**« Secrets manquants »** — l'un des six n'est pas posé, le journal dit
lequel.

**« No signing certificate found »** — le `.p12` a été encodé de travers,
ou son mot de passe ne correspond pas. Refaire l'encodage base64 sans
espace ni retour à la ligne parasite.

**« No profiles for 'com.moncoach.…' were found »** — un des trois
identifiants de bundle n'existe pas encore côté Apple. Les créer tous les
trois (étape 1).

**« Provisioning profile doesn't include the HealthKit entitlement »** — la
capacité **HealthKit** n'est pas cochée sur l'App ID de l'application, dans
Certificates, Identifiers & Profiles.

**« The bundle version must be higher »** — ne devrait pas arriver, le
numéro venant du compteur d'exécutions ; si le dépôt a été recréé, relancer
suffit.

En cas d'échec, les journaux détaillés sont attachés à l'exécution pendant
sept jours (**journaux-xcodebuild** en bas de la page).

---

## Ce qui reste à faire une fois dans TestFlight

- **Renseigner la confidentialité** : App Store Connect demande l'URL de la
  politique — celle du site, `/confidentialite` — et les étiquettes de
  confidentialité. Réponse honnête pour ce produit : aucune donnée
  collectée, aucune donnée liée à l'utilisateur.
- **Les testeurs externes** (au-delà de ton propre appareil) passent par une
  revue d'Apple, généralement sous 24 h.
