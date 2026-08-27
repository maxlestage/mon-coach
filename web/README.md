# Site produit de Mon Coach

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
├── index.html          point d'entrée : Bun suit les <script> et <link>
├── main.tsx            montage React
├── App.tsx             assemblage des sections
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
swift run --package-path tools/FixtureGenerator \
  > web/src/coach/__fixtures__/engine-reference.json
```

Le portage ne couvre pas le choix des exercices, la progression des charges,
l'autorégulation quotidienne ni le bilan hebdomadaire : ces parties ont besoin
d'un historique d'entraînement, qui n'existe que dans l'application.

## Choix techniques

- **Pas de framework CSS.** Un seul fichier de tokens, repris des couleurs de
  l'application. La page pèse moins qu'une feuille de style utilitaire.
- **Pas de ressource externe.** Aucune police distante, aucun script tiers,
  aucun cookie. Une page qui parle de vie privée doit se tenir à sa parole.
- **Contenu séparé de l'affichage.** `data/content.ts` se relit sans lire une
  seule ligne de JSX.
