# Mettre le site en ligne sur Heroku

Ce guide se suit **entièrement depuis un téléphone**, dans le navigateur.
Aucun ordinateur, aucune ligne de commande, aucune installation.

Une fois la configuration faite, tu n'y reviens plus : chaque fusion sur
`master` qui touche à `web/` redéploie le site toute seule.

---

## Étape 0 — fusionner la pull request

**Rien ne peut être déployé tant que `master` ne contient pas le site.**

Tant que la PR est ouverte, `master` ne contient que le `README.md` du dépôt
vide. Toute tentative de déploiement construira ce dépôt vide et échouera.

Le workflow de déploiement lui-même n'existe pour GitHub Actions qu'une fois
présent sur la branche par défaut : avant la fusion, l'onglet **Actions**
n'affiche pas **Déploiement**, et le bouton *Run workflow* n'existe pas.

Donc : fusionne d'abord, configure ensuite.

---

## Avant de commencer

Heroku n'a plus d'offre gratuite. Un dyno **Eco** coûte environ **5 $ par
mois** pour un forfait couvrant plusieurs applications, et une carte bancaire
est demandée à l'inscription. Le site est un fichier HTML et deux fichiers
statiques : n'importe quelle taille de dyno suffit largement.

---

## 1. Créer l'application Heroku

1. Ouvre **heroku.com** et connecte-toi (ou crée un compte).
2. En haut à droite : **New** → **Create new app**.
3. **App name** : choisis un nom, par exemple `mon-coach-site`. Il doit être
   libre à l'échelle de Heroku, et il apparaîtra dans l'adresse du site.
4. **Region** : *Europe*.
5. **Create app**.

### Choisis un chemin, et un seul

Deux façons de déployer coexistent dans ce dépôt. **N'en active qu'une** :
sinon chaque fusion déclenche deux déploiements concurrents.

> **Où se lit l'état d'un déploiement.** Chemin A : onglet **Actions** de
> GitHub. Chemin B : tableau de bord Heroku → application → **Activity**.
> Attention au faux ami : avec le chemin B branché et le chemin A non
> configuré, l'onglet Actions affiche un « Déploiement » **vert qui n'a rien
> déployé** — toutes ses étapes sont sautées, et il le dit dans son journal.
> Le vert d'Actions ne prouve un déploiement que si le secret
> `HEROKU_API_KEY` existe.

| | Chemin A — GitHub Actions | Chemin B — Heroku |
| --- | --- | --- |
| Qui construit | GitHub, en image Docker | Heroku, avec un buildpack Bun |
| À configurer | un secret `HEROKU_API_KEY` | un buildpack, dans le tableau de bord |
| Version de Bun | épinglée par le `Dockerfile` | celle du buildpack |
| Connexion GitHub côté Heroku | **débranchée** | branchée |

Le chemin A est décrit ci-dessous. Pour le chemin B, saute à
[Chemin B](#chemin-b--laisser-heroku-construire).

## 2. Récupérer la clé d'API Heroku

1. Menu du compte (avatar, en haut à droite) → **Account settings**.
2. Onglet **Applications**, tout en bas : **API Key** → **Reveal**.
3. Copie la clé.

Cette clé donne un accès complet à ton compte Heroku. Elle ne va que dans les
secrets GitHub, jamais dans un fichier du dépôt. Si tu penses l'avoir exposée,
reviens sur cette page et fais **Regenerate API Key**.

## 3. Donner la clé à GitHub

Sur **github.com/maxlestage/mon-coach** (le site web mobile fonctionne ;
l'application GitHub, elle, ne donne pas accès aux réglages) :

1. **Settings** → menu de gauche → **Secrets and variables** → **Actions**.
2. Onglet **Secrets** → **New repository secret** :
   - **Name** : `HEROKU_API_KEY`
   - **Secret** : la clé copiée à l'étape 2
   - **Add secret**

C'est tout : une seule chose à saisir.

Le nom de l'application, lui, est écrit dans
[`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml) — il n'a
rien de secret, il apparaît dans l'adresse du site. Si tu renommes
l'application un jour, tu peux le remplacer sans toucher au code : onglet
**Variables** → **New repository variable** → `HEROKU_APP_NAME` avec le
nouveau nom. La variable l'emporte sur la valeur inscrite dans le workflow.

## 4. Déclencher le déploiement

Si la PR a été fusionnée après avoir renseigné le secret et la variable, le
déploiement est déjà parti tout seul. Sinon, deux façons :

- **fusionner une pull request sur `master`** qui touche à `web/` ;
- ou, à la demande : onglet **Actions** → workflow **Déploiement** →
  **Run workflow** → branche `master` → **Run workflow**.

Le workflow **Déploiement** n'apparaît dans l'onglet Actions qu'une fois
présent sur `master` : avant la première fusion, il est normal de ne pas le
voir.

## 5. Vérifier

Ouvre l'onglet **Actions**, puis le job **Site → Heroku**. La dernière étape,
*Vérifier que le site répond*, affiche l'adresse du site et échoue si la page
ne se charge pas. En cas d'échec, l'erreur pointe vers les logs du dyno, que
tu peux lire depuis le tableau de bord Heroku : **More** → **View logs**.

---

## Ce que fait le workflow

Tout est dans [`.github/workflows/deploy.yml`](../.github/workflows/deploy.yml) :

1. Bascule l'application sur la pile `container` (sans effet si c'est déjà le
   cas) — c'est ce qui permet de déployer une image Docker sans passer par la
   ligne de commande Heroku.
2. Construit l'image depuis [`web/Dockerfile`](../web/Dockerfile) : Bun 1.4.0
   installe les dépendances depuis le lockfile, produit le site statique, et
   l'image finale ne contient que le résultat et le serveur.
3. Pousse l'image sur le registre Heroku et la met en production.
4. S'assure qu'un dyno tourne réellement — une mise en production sur zéro
   dyno est un déploiement qui n'a servi à rien.
5. Interroge le site jusqu'à ce qu'il réponde, et échoue sinon.

Tant que le secret ou la variable manquent, le workflow s'arrête à la
première étape sans rien casser : `master` ne devient pas rouge parce que le
déploiement n'est pas encore configuré.

Le `Dockerfile` n'est pas seulement relu : le job **Image de déploiement** de
la CI le construit à chaque pull request, lance le conteneur et vérifie qu'il
sert bien la page, que les fichiers versionnés sont mis en cache un an, et
qu'une route inconnue retombe sur la page d'accueil.

## Chemin B — laisser Heroku construire

Si tu préfères ne rien saisir dans GitHub, Heroku peut construire lui-même. Il
lui faut un buildpack qui connaisse Bun, parce que le sien ne le connaît pas.

1. Tableau de bord → ton application → **Settings** → section **Buildpacks** →
   **Add buildpack** → colle l'URL d'un buildpack Bun → **Save changes**.
   Retire le buildpack `heroku/nodejs` s'il est présent : il ne sait pas
   construire ce dépôt.
2. Onglet **Deploy** → *Deployment method* → **GitHub** → connecte le dépôt →
   **Enable Automatic Deploys** sur `master`.
3. Ne renseigne **pas** le secret `HEROKU_API_KEY` : le workflow de GitHub
   Actions resterait au repos, mais autant ne pas armer deux systèmes.

Le `package.json` à la racine du dépôt existe pour ce chemin, et rien d'autre :
le buildpack cherche un `package.json` à la racine et lance `bun start`. Ce
script entre dans `web/`, installe les dépendances et construit le site s'il ne
l'est pas déjà, puis le sert. Un job de CI (**Démarrage Heroku**) exécute cette
commande exacte depuis un dépôt fraîchement cloné à chaque pull request, pour
qu'elle ne casse pas sans qu'on le sache.

## Quand ça se passe mal

**« Application not supported by 'heroku/nodejs' buildpack »**
Heroku construit le dépôt avec son buildpack Node, qui ne sait pas faire.
Soit tu passes au chemin A (**Deploy** → **Disconnect**), soit tu remplaces le
buildpack par un buildpack Bun (chemin B). Si le log mentionne aussi
`This directory has the following files: README.md`, c'est que `master` est
encore vide : la pull request n'a pas été fusionnée.

**« error: Script not found "start" »**
Le buildpack Bun a construit l'application mais n'a trouvé aucun script à
lancer. C'est que le `package.json` de la racine est absent de la branche
déployée : vérifie que `master` est bien à jour.

**Le workflow « Déploiement » n'apparaît pas dans l'onglet Actions**
Il n'est pas encore sur `master`. Fusionne la pull request.

**Le job s'affiche en vert mais rien n'est déployé**
Regarde la première étape : si elle affiche « Déploiement non configuré », le
secret `HEROKU_API_KEY` manque. Le workflow s'arrête volontairement là plutôt
que de faire échouer `master`.

**« L'application est introuvable, ou la clé d'API est invalide »**
Le nom inscrit dans le workflow ne correspond à aucune application de ton
compte, ou la clé a été régénérée depuis. Corrige la variable de dépôt
`HEROKU_APP_NAME`, ou recopie la clé.

**L'adresse du site n'est pas `<nom-de-l-app>.herokuapp.com`**
C'est normal : Heroku ajoute un suffixe aléatoire à l'adresse des
applications récentes. Le workflow ne la devine pas, il la demande à l'API et
l'affiche à la dernière étape.

## Questions courantes

**Le site est-il en veille ?** Un dyno Eco s'endort après trente minutes sans
visite et met quelques secondes à se réveiller. Un dyno Basic ne dort pas.
Le changement se fait dans **Resources** sur le tableau de bord.

**Comment mettre un nom de domaine ?** Tableau de bord Heroku →
**Settings** → **Domains** → **Add domain**, puis crée l'enregistrement DNS
indiqué chez ton registrar. Le certificat TLS est automatique.

**Comment revenir en arrière ?** Tableau de bord → **Activity** → sur la
version précédente : **Roll back to here**. Rien à faire côté dépôt.

**Comment arrêter les frais ?** **Resources** → passe le dyno `web` à zéro,
ou supprime l'application dans **Settings** → **Delete app**.
