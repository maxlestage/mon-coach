# Site produit de Stride

Bun 1.4 + TypeScript 7 + React 19, sans framework de build supplémentaire.

## Commandes

```bash
bun install
bun run dev        # http://localhost:3000, rechargement à chaud
bun run test       # tests du moteur porté
bun run typecheck  # TypeScript strict, sans émission
bun run build      # site statique dans dist/
bun run preview    # sert dist/ tel qu'il partira en production
```

## Structure

```
src/
├── index.html          l'accueil ; Bun suit les <script> et <link>
├── mentions-legales.html, confidentialite.html, conditions.html
│                       les pages légales — chacune est un point d'entrée
├── main.tsx            montage React de l'accueil
├── App.tsx             assemblage des sections
├── pages/              contenu des pages légales
├── pwa.ts              manifeste + enregistrement du service worker
├── manifest.webmanifest, icons/
│                       l'identité de la PWA, copiée telle quelle au build
├── styles.css          système de tokens, aucune dépendance CSS
├── coach/              portage TypeScript du moteur Swift
│   ├── engine.ts       les formules, portées à l'identique
│   ├── engine.test.ts  tests + comparaison aux valeurs de référence Swift
│   └── __fixtures__/   sortie du moteur Swift, versionnée
├── components/         sections de la page
└── data/content.ts     contenu éditorial, séparé de l'affichage
```

## Le portage du moteur

`src/coach/engine.ts` reprend, formule pour formule, ce que fait
`ios/MonCoachKit`. C'est volontairement littéral : toute divergence est un
bug, pas une adaptation.

Le fichier `src/coach/__fixtures__/engine-reference.json` est produit par le
moteur Swift lui-même. Après toute modification du moteur, il faut le
régénérer depuis la racine du dépôt :

```bash
swift run --package-path tools/FixtureGenerator FixtureGenerator moteur \
  > web/src/coach/__fixtures__/engine-reference.json
```

Le nom répété n'est pas une coquille : le premier est le produit à lancer, le
second l'argument qu'il reçoit. Les exemples affichés sur le site sortent du
même outil :

```bash
swift run --package-path tools/FixtureGenerator FixtureGenerator exemples \
  > web/src/data/examples.json
```

Le portage ne couvre pas le choix des exercices, la progression des charges,
l'autorégulation quotidienne ni le bilan hebdomadaire : ces parties ont besoin
d'un historique d'entraînement, qui n'existe que dans l'application.

## Mise en ligne

`Dockerfile` construit le site avec Bun puis ne garde, dans l'image finale,
que `dist/` et `serve.ts`. `serve.ts` lit `PORT` et écoute sur `0.0.0.0`,
ce qu'impose un hébergeur qui place un routeur devant le conteneur.

```bash
docker build -t mon-coach-web ./web
docker run --rm -e PORT=8080 -p 8080:8080 mon-coach-web
```

Le déploiement lui-même est décrit dans
[`docs/DEPLOIEMENT.md`](../docs/DEPLOIEMENT.md).

## PWA

Le site s'installe comme une application et fonctionne hors ligne. Le
service worker est généré par `build.ts` — sa liste de précache contient les
noms hachés que seul le build connaît, et sa version est le condensat de
cette liste : un déploiement sans changement ne réinstalle rien.

Stratégies : réseau d'abord pour les pages (les mises à jour se voient),
cache d'abord pour les assets condensés (ils ne changent jamais sous le même
nom). Vérifié par Playwright : hors ligne, l'accueil, les pages légales et le
simulateur — interactif — se chargent depuis le cache.

## Choix techniques

- **Pas de framework CSS.** Un seul fichier de tokens, repris des couleurs de
  l'application. La page pèse moins qu'une feuille de style utilitaire.
- **Pas de ressource externe.** Aucune police distante, aucun script tiers,
  aucun cookie. Une page qui parle de vie privée doit se tenir à sa parole.
- **Contenu séparé de l'affichage.** `data/content.ts` se relit sans lire une
  seule ligne de JSX.
