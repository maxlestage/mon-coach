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

## 3. Le certificat de distribution

Un certificat de distribution est une paire de clés. Sa partie privée se
génère **sur une machine**, jamais par un site web : il n'existe donc nulle
part avant que tu ne le crées, et son mot de passe n'est pas donné par Apple
— c'est toi qui l'inventes au moment de l'export.

Deux chemins, selon que tu as un Mac sous la main.

### Chemin A — sans Mac (dépannage)

**Ne pose simplement pas** `APPLE_DISTRIBUTION_CERT_P12` ni
`APPLE_DISTRIBUTION_CERT_PASSWORD`. Xcode créera le certificat lui-même sur
la machine de build, via ta clé d'API.

Deux réserves, à connaître avant de compter dessus :

- la clé d'API doit avoir le rôle **Admin**, pas seulement App Manager —
  créer un certificat est une opération d'administration ;
- un compte n'a droit qu'à **deux certificats de distribution**, et la
  machine de build est détruite après chaque exécution : chaque build en
  consomme donc un. Au troisième, il faudra révoquer les précédents dans
  [Certificates](https://developer.apple.com/account/resources/certificates/list).

C'est de quoi obtenir un premier build sans Mac. Ce n'est pas un régime de
croisière.

### Chemin B — avec un Mac (recommandé)

Sur un Mac, **une seule fois**, et le certificat vaut ensuite un an :

1. Xcode → **Settings** → **Accounts** → ton compte → **Manage
   Certificates** → **+** → **Apple Distribution**.
2. Ouvre **Trousseau d'accès** → catégorie **Mes certificats** → clic droit
   sur *Apple Distribution* → **Exporter**.
3. Format **`.p12`**, et **choisis un mot de passe** à ce moment-là : c'est
   lui qui deviendra `APPLE_DISTRIBUTION_CERT_PASSWORD`. Il n'existe pas
   avant, personne ne te le donne, et il n'est récupérable nulle part si tu
   l'oublies — il faudra réexporter.

Le fichier `.p12` obtenu devient `APPLE_DISTRIBUTION_CERT_P12`, encodé en
base64.

## 4. Poser les secrets dans GitHub

Dépôt → **Settings** → **Secrets and variables** → onglet **Actions** →
**New repository secret**. Attention à l'onglet : *Secrets*, pas *Variables*.

**Les quatre obligatoires**, tous récupérables depuis un téléphone :

| Nom | Contenu |
| --- | --- |
| `APPLE_TEAM_ID` | Ton Team ID, dans [Membership](https://developer.apple.com/account) — dix caractères |
| `ASC_ISSUER_ID` | L'Issuer ID de l'étape 2 |
| `ASC_KEY_ID` | Le Key ID de l'étape 2 |
| `ASC_KEY_P8` | Le contenu du fichier `.p8` — collé tel quel, ou encodé en base64 |

Les anciens noms `APPSTORE_ISSUER_ID`, `APPSTORE_KEY_ID` et
`APPSTORE_PRIVATE_KEY` restent acceptés : le workflow prend les `ASC_*` en
priorité et retombe sur les autres. Rien à renommer si les secrets sont
déjà posés — un secret ne se renomme pas, il se supprime et se repose.

**Les deux facultatifs** — le chemin B ci-dessus. Posés ensemble ou pas du
tout ; n'en poser qu'un fait échouer le build dès la première étape, ce qui
vaut mieux que de le découvrir à la signature :

| Nom | Contenu |
| --- | --- |
| `APPLE_DISTRIBUTION_CERT_P12` | Le fichier `.p12`, **encodé en base64** |
| `APPLE_DISTRIBUTION_CERT_PASSWORD` | Le mot de passe choisi à l'export |

Le `.p8` n'a pas besoin d'être encodé : le workflow reconnaît un PEM en
clair comme une valeur base64. Le `.p12`, lui, est binaire et doit être
encodé. Sur un Mac, dans le Terminal :

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
