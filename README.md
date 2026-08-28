# Mon Coach

**Code propriétaire — tous droits réservés.** Ce projet n'est pas open
source et ne le sera pas : aucune licence n'est accordée, aucune
contribution n'est acceptée. Voir [LICENSE](LICENSE).

Coach de musculation natif iOS, et le site produit qui l'accompagne.

L'idée tient en une phrase : **un programme d'entraînement n'a de valeur que
s'il est construit pour un corps, un matériel et un emploi du temps précis, et
qu'il change quand ceux-ci changent.** Tout le dépôt découle de ça.

```
mon-coach/
├── ios/
│   ├── MonCoachKit/     paquet Swift : moteur + état + synchronisation, testé
│   └── MonCoach/        app iPhone, app Apple Watch, extension Live Activity
├── web/                 site produit — Bun + TypeScript + React
└── tools/
    └── FixtureGenerator  génère les valeurs de référence partagées
```

## Le moteur

`MonCoachKit` ne dépend ni de SwiftUI, ni d'un système de persistance, ni du
réseau. C'est une bibliothèque de fonctions pures : le même profil et le même
historique produisent toujours le même programme. C'est ce qui la rend
testable, et c'est ce qui permet à l'application de fonctionner entièrement
hors ligne.

Six étapes s'enchaînent :

| Étape | Ce qu'elle décide |
| --- | --- |
| `BodyMetricsEngine` | Masse maigre, métabolisme de base, dépense quotidienne |
| `NutritionEngine` | Calories et macronutriments, avec un plancher de sécurité |
| `VolumeEngine` | Séries hebdomadaires par groupe musculaire |
| `SplitPlanner` | Structure de la semaine et répartition du volume |
| `ExerciseSelector` | Choix des mouvements dans un catalogue de 60 exercices |
| `ProgressionEngine` | Charge de chaque série, en double progression autorégulée |

Deux moteurs travaillent ensuite en continu : `ReadinessEngine` ajuste la
séance du jour d'après un check-in de vingt secondes, et `AdaptationEngine`
compare chaque semaine le prévu au réalisé pour corriger volume, calories et
calendrier de décharge.

Le paquet contient aussi la couche d'état de l'application — `CoachStore`,
`StateStorage`, `ActiveSession`, `ProfileDraft` — parce qu'elle ne dépend que
de Foundation et d'`Observation`, et qu'elle est donc testable hors de Xcode.
C'est là que vivent la persistance, la reprise de séance et la logique
« quelle séance aujourd'hui » : les endroits où un bug coûte un historique
d'entraînement.

```bash
swift test --package-path ios/MonCoachKit   # 111 tests
```

## L'application

SwiftUI, iOS 18, Swift 6. Trois cibles dans le même projet Xcode :

- **MonCoach** — l'application iPhone. Des vues et la glue de plateforme
  (WatchConnectivity, ActivityKit), rien d'autre : toute la logique vit dans
  `MonCoachKit`.
- **MonCoachWatch** — l'application Apple Watch. Elle reçoit la séance du
  jour déjà prescrite, fait tout enregistrer au poignet (couronne comprise)
  et continue hors de portée du téléphone ; le journal se synchronise au
  retour, avec une fusion idempotente testée côté paquet.
- **MonCoachWidgets** — la Live Activity : série en cours, charge et chrono
  de repos sur l'écran verrouillé et dans la Dynamic Island. Le compte à
  rebours est piloté par une date, sans réveiller l'application.

Le contrat d'échange téléphone ↔ montre (`WatchSnapshot`, codec JSON,
fusion des journaux) et l'état affiché par la Live Activity
(`WorkoutActivitySnapshot`) sont définis et testés dans le paquet : les
cibles Apple ne font que les transporter et les afficher.

Ouvre `ios/MonCoach/MonCoach.xcodeproj` dans Xcode 16 ou supérieur. Le projet
référence `MonCoachKit` comme paquet local — il n'y a rien à installer.

L'état complet est stocké dans un unique fichier JSON écrit de façon atomique,
dans le conteneur de l'application. Aucun compte, aucun serveur, aucun
traceur.

## Le site

Bun sert de runtime, de bundler et de compilateur : le point d'entrée est le
HTML, et il n'y a pas d'autre outil de build.

```bash
cd web
bun install
bun run dev        # serveur de développement avec rechargement à chaud
bun run test       # tests du moteur porté
bun run typecheck  # TypeScript en mode strict
bun run build      # site statique dans web/dist
```

Le site est une PWA : il s'installe comme une application et fonctionne
hors ligne, simulateur compris. Pages légales, tarifs (modèle freemium
documenté dans `docs/MODELE-ECONOMIQUE.md`) et pied de page complet.

Le simulateur de la page d'accueil exécute un portage TypeScript du moteur
Swift. Pour que ce ne soit pas une promesse en l'air, le moteur Swift produit
un fichier de valeurs de référence que les tests du site rejouent :

```bash
swift run --package-path tools/FixtureGenerator \
  > web/src/coach/__fixtures__/engine-reference.json
```

La CI régénère ce fichier et échoue s'il diffère de la version commitée. Une
divergence d'une seule calorie entre l'application et le site casse le build.

## Mise en ligne

Le site part sur Heroku, en image Docker, poussée par GitHub Actions à chaque
fusion sur `master` qui touche à `web/`. La configuration se fait entièrement
depuis un navigateur — un téléphone suffit, il n'y a ni ligne de commande
Heroku ni installation : **[docs/DEPLOIEMENT.md](docs/DEPLOIEMENT.md)**.

Une seule chose à ne pas faire : connecter le dépôt à Heroku depuis l'onglet
*Deploy* du tableau de bord. Heroku construirait alors la racine du dépôt avec
ses buildpacks, où il n'y a pas de `package.json` — le site vit dans `web/`.
C'est GitHub Actions qui déploie, et lui sait où chercher.

Le `Dockerfile` est construit et testé par la CI à chaque pull request : le
conteneur est démarré, la page est demandée, et les en-têtes de cache sont
vérifiés. Ce qui part en production est ce qui a été testé.

## Versions

| Outil | Version |
| --- | --- |
| Swift | 6.2 (mode langage 6) |
| iOS | 18.0 minimum |
| Bun | 1.4.0 |
| Docker | image `oven/bun:1.4.0` |
| TypeScript | 7.0 |
| React | 19.2 |

## Avertissement

Mon Coach n'est pas un dispositif médical. Il ne remplace ni un médecin, ni un
kinésithérapeute, ni un diététicien.
