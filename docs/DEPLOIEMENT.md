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

### ⚠️ Ne connecte pas GitHub depuis Heroku

Sur la page de l'application, l'onglet **Deploy** propose *Connect to GitHub*.
**Ne l'utilise pas.** C'est le piège le plus facile à tomber dedans, parce que
c'est le bouton le plus visible.

Si tu le fais, Heroku construit le dépôt lui-même, avec ses buildpacks, depuis
la racine — où il n'y a pas de `package.json`, puisque le site vit dans
`web/`. La construction échoue avec ce message :

```
ERROR: Application not supported by 'heroku/nodejs' buildpack
The 'heroku/nodejs' buildpack is set on this application, but was
unable to detect a Node.js codebase.
```

C'est GitHub Actions qui déploie, et lui sait où chercher.

**Si tu l'as déjà connecté** : onglet **Deploy** → section *App connected to
GitHub* → **Disconnect**. Sinon les deux systèmes déploieront en parallèle, et
celui de Heroku échouera à chaque fois.

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
3. Onglet **Variables** → **New repository variable** :
   - **Name** : `HEROKU_APP_NAME`
   - **Value** : le nom choisi à l'étape 1, par exemple `mon-coach-site`
   - **Add variable**

Le nom de l'application est une *variable* et non un secret : il est public de
toute façon, il apparaît dans l'adresse du site.

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

## Quand ça se passe mal

**« Application not supported by 'heroku/nodejs' buildpack »**
Heroku construit le dépôt lui-même au lieu de laisser GitHub Actions le faire.
Va dans l'onglet **Deploy** de l'application et fais **Disconnect** sur la
connexion GitHub. Si le log mentionne aussi `This directory has the following
files: README.md`, c'est que `master` est encore vide : la pull request n'a
pas été fusionnée.

**Le workflow « Déploiement » n'apparaît pas dans l'onglet Actions**
Il n'est pas encore sur `master`. Fusionne la pull request.

**Le job s'affiche en vert mais rien n'est déployé**
Regarde la première étape : si elle affiche « Déploiement non configuré », le
secret `HEROKU_API_KEY` ou la variable `HEROKU_APP_NAME` manque. Le workflow
s'arrête volontairement là plutôt que de faire échouer `master`.

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
