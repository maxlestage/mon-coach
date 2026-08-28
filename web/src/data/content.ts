/** Contenu éditorial du site, séparé des composants qui l'affichent. */

export interface InputGroup {
  title: string;
  body: string;
  items: string[];
}

/** Ce que le questionnaire d'inscription collecte, et pourquoi. */
export const inputGroups: InputGroup[] = [
  {
    title: "Ton corps",
    body: "Sert au métabolisme de base, à la masse maigre et aux charges de départ. Le taux de masse grasse est facultatif : s'il est renseigné, le coach passe sur des formules plus précises.",
    items: ["Âge", "Sexe", "Taille", "Poids", "Masse grasse", "Tour de taille"],
  },
  {
    title: "Ton passé",
    body: "Un débutant progresse sur bien moins de séries qu'un pratiquant confirmé. Le niveau détermine le volume de départ, le modèle de progression et la longueur des blocs.",
    items: ["Mois d'entraînement", "Niveau", "Maximums connus"],
  },
  {
    title: "Ton objectif",
    body: "Un seul objectif à la fois. Il fixe les calories, les fourchettes de répétitions, les temps de repos et l'ordre de priorité des exercices.",
    items: [
      "Prise de muscle",
      "Force",
      "Perte de gras",
      "Recomposition",
      "Forme générale",
      "Poids cible",
      "Échéance",
    ],
  },
  {
    title: "Ta disponibilité",
    body: "Le nombre de séances décide de la structure de la semaine. La durée plafonne le volume : le coach ne prescrit jamais une séance plus longue que le temps annoncé.",
    items: ["Séances par semaine", "Minutes par séance"],
  },
  {
    title: "Ton matériel",
    body: "Un mouvement n'est proposé que si tu as tout ce qu'il demande. Le plus petit incrément de charge disponible sert à arrondir chaque suggestion.",
    items: [
      "Barre",
      "Haltères",
      "Machines",
      "Poulies",
      "Élastiques",
      "Barre de traction",
      "Banc",
      "Poids du corps",
    ],
  },
  {
    title: "Tes limites",
    body: "Toute zone déclarée sensible retire du catalogue les mouvements qui la sollicitent directement. Ils sont remplacés, pas « adaptés ».",
    items: [
      "Épaule",
      "Bas du dos",
      "Genou",
      "Hanche",
      "Coude",
      "Poignet",
      "Nuque",
      "Cheville",
      "Exercices refusés",
    ],
  },
  {
    title: "Ton quotidien",
    body: "Le sommeil et le stress fixent ta capacité de récupération, donc le volume que tu peux réellement absorber. En dessous de six heures de sommeil, le coach retire 15 % de séries.",
    items: ["Activité hors salle", "Sommeil", "Stress", "Alimentation"],
  },
  {
    title: "Chaque jour, chaque série",
    body: "Après l'inscription, le coach continue d'apprendre : c'est ce qui sépare un programme d'un fichier PDF.",
    items: [
      "Check-in de forme",
      "Charge et répétitions",
      "Difficulté ressentie",
      "Douleur signalée",
      "Pesées",
    ],
  },
];

export interface Stage {
  index: string;
  title: string;
  body: string;
  detail: string;
}

/** Les six étapes que le moteur enchaîne pour produire un bloc. */
export const pipeline: Stage[] = [
  {
    index: "01",
    title: "Métabolisme et composition corporelle",
    body: "Mifflin-St Jeor quand la masse grasse est inconnue, Katch-McArdle dès qu'elle est renseignée. La dépense liée à l'entraînement est ajoutée séparément, pour que le nombre de séances pèse réellement sur le total.",
    detail:
      "TDEE = métabolisme de base × facteur d'activité + (minutes × 6 kcal × séances) ÷ 7",
  },
  {
    index: "02",
    title: "Calories et macronutriments",
    body: "Le rythme visé est exprimé en part du poids de corps, pas en kilos fixes : la même règle reste sensée à 55 kg et à 110 kg. Un plancher calorique empêche les déficits qui coûteraient du muscle.",
    detail:
      "Sèche : −0,50 à −0,75 % du poids par semaine · Prise de masse : +0,20 à +0,35 %\nProtéines : 1,8 à 2,6 g par kg de masse maigre selon l'objectif",
  },
  {
    index: "03",
    title: "Budget de séries hebdomadaire",
    body: "Des repères de volume par groupe musculaire, pondérés par le niveau, l'objectif, le sommeil, le stress et l'âge, puis plafonnés par le temps réellement disponible dans la semaine.",
    detail:
      "séries = repère × niveau × objectif × récupération, plafonné à\n((minutes − 8) ÷ 2) × séances",
  },
  {
    index: "04",
    title: "Structure de la semaine",
    body: "Deux ou trois séances donnent un full body, quatre un haut/bas, cinq un PPL complété, six un découpage à haute fréquence. Le budget de séries est ensuite réparti sur les jours les moins chargés.",
    detail:
      "2–3 j → full body · 4 j → haut/bas · 5 j → PPL + haut/bas · 6 j → PPL ×2",
  },
  {
    index: "05",
    title: "Choix des exercices",
    body: "Filtrage par matériel et par zones sensibles, puis un mouvement polyarticulaire en ouverture de chaque muscle, de l'isolation ensuite. Le travail indirect des polyarticulaires est décompté du budget, et tout muscle dont le jour a la charge garde un exercice qui lui est propre.",
    detail:
      "Une série compte 1,0 pour le muscle principal et 0,5 pour chaque muscle secondaire",
  },
  {
    index: "06",
    title: "Charges et progression",
    body: "Double progression autorégulée par le RPE : toutes les séries au sommet de la fourchette au RPE prévu, la charge monte ; des répétitions sous la fourchette, elle recule. Une douleur signalée l'emporte sur tout le reste.",
    detail:
      "1RM estimé = charge ÷ (1 ÷ (1 + (répétitions + réserve − 1) ÷ 30))\nCharges arrondies au plus petit incrément que tu possèdes",
  },
];

export interface Adaptation {
  title: string;
  body: string;
}

/** Ce que le bilan hebdomadaire modifie réellement. */
export const adaptations: Adaptation[] = [
  {
    title: "Le volume suit ta récupération",
    body: "Une semaine terminée à plus de 90 % avec une forme correcte ajoute deux séries par semaine sur les gros groupes au bloc suivant. Une semaine mal absorbée en retire deux.",
  },
  {
    title: "Les calories suivent la balance",
    body: "Le coach compare la tendance de ton poids sur quatre semaines au rythme visé, et propose un ajustement de 25 à 400 kcal. Une seule pesée ne déclenche jamais rien : c'est de l'eau, pas du gras.",
  },
  {
    title: "La décharge peut être avancée",
    body: "Si ta forme moyenne descend sous 50 sur 100 pendant une semaine, la décharge est avancée. Ce n'est pas un recul : c'est ce qui permet à la progression de reprendre.",
  },
  {
    title: "Ce qui fait mal disparaît",
    body: "Un mouvement sur lequel tu as signalé une douleur passe d'abord en charge réduite, puis sort du programme s'il revient. Il n'est jamais simplement répété.",
  },
  {
    title: "La séance du jour s'ajuste",
    body: "Quatre curseurs avant de commencer — sommeil, courbatures, motivation, stress — et le coach garde la séance telle quelle, retire des séries, ou baisse les charges de 7 à 25 %.",
  },
  {
    title: "Une séance ratée ne casse rien",
    body: "Les séances ne sont pas clouées à des jours fixes : tu reçois la prochaine que tu n'as pas faite, répartie sur les jours qui restent dans la semaine.",
  },
];

export interface FaqEntry {
  question: string;
  answer: string;
}

export const faq: FaqEntry[] = [
  {
    question: "Est-ce que mes données partent quelque part ?",
    answer:
      "Non. Tout est calculé sur l'appareil et stocké dans un fichier unique, sur le téléphone. Il n'y a pas de compte, pas de serveur, pas d'analytique. Tu peux exporter l'intégralité de tes données en JSON, ou tout effacer, depuis l'écran Profil.",
  },
  {
    question: "Faut-il une salle de sport ?",
    answer:
      "Non. Le catalogue couvre la barre, les haltères, les machines, les poulies, les élastiques, la barre de traction et le poids du corps. Tu coches ce que tu as, et le coach ne prescrit que ce que tu peux réellement faire. Avec deux élastiques et un tapis, le programme est plus modeste, mais il existe.",
  },
  {
    question: "Que se passe-t-il si je saute une séance ?",
    answer:
      "Rien de dramatique. Les séances ne sont pas attachées à des jours fixes : tu reçois la prochaine séance non faite, étalée sur les jours restants. Si la semaine est vraiment incomplète, le bilan te le dit et te propose de descendre d'une séance plutôt que de te culpabiliser.",
  },
  {
    question: "Pourquoi le coach me demande mon sommeil et mon stress ?",
    answer:
      "Parce que le volume que tu peux absorber en dépend directement. En dessous de six heures de sommeil, le coach retire 15 % de séries ; au-delà de huit, il en ajoute. Un stress chronique élevé coûte 10 % de plus. Prescrire le même volume à tout le monde revient à ignorer la moitié de l'équation.",
  },
  {
    question: "Comment le coach connaît mes charges à la première séance ?",
    answer:
      "Si tu renseignes un maximum, il en déduit la charge exacte pour la fourchette de répétitions et le RPE prévus. Sinon, il part des repères de force publiés pour ton poids, ton sexe, ton âge et ton niveau — puis corrige dès la première série que tu enregistres.",
  },
  {
    question: "C'est encore une application qui compte les calories ?",
    answer:
      "Non. Le coach donne une cible quotidienne et t'explique d'où elle vient, mais il n'y a pas de journal alimentaire à remplir. La seule donnée nutritionnelle qu'il te demande est ton poids sur la balance, parce que c'est la seule qui permette de vérifier si la cible est juste.",
  },
  {
    question: "Le simulateur de cette page donne-t-il les mêmes chiffres que l'app ?",
    answer:
      "Oui, et c'est vérifié automatiquement. Le moteur Swift produit un fichier de valeurs de référence, et les tests du site échouent si le portage TypeScript s'en écarte, ne serait-ce que d'une calorie.",
  },
  {
    question: "Est-ce que ça remplace un coach humain ou un médecin ?",
    answer:
      "Non. C'est un programmeur d'entraînement rigoureux, pas un professionnel de santé. Une douleur qui dure, une pathologie connue ou une grossesse relèvent d'un médecin ou d'un kinésithérapeute, pas d'une application.",
  },
];
