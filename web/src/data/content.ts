/**
 * Contenu éditorial du site, séparé des composants qui l'affichent, et donné
 * dans les trois langues du produit.
 *
 * Le type `Localized<T>` force les trois versions : une langue oubliée ne
 * compile pas. C'est la même garantie que côté application, obtenue par le
 * système de types plutôt que par une relecture.
 */

import type { Language } from "../i18n/language.tsx";

export type Localized<T> = Record<Language, T>;

export interface InputGroup {
  title: string;
  body: string;
  items: string[];
}

/** Ce que le questionnaire d'inscription collecte, et pourquoi. */
export const inputGroups: Localized<InputGroup[]> = {
  fr: [
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
      items: ["Prise de muscle", "Force", "Perte de gras", "Recomposition", "Forme générale", "Poids cible", "Échéance"],
    },
    {
      title: "Ta disponibilité",
      body: "Le nombre de séances décide de la structure de la semaine. La durée plafonne le volume : le coach ne prescrit jamais une séance plus longue que le temps annoncé.",
      items: ["Séances par semaine", "Minutes par séance"],
    },
    {
      title: "Ta course",
      body: "Si tu cours, le coach construit un bloc de course en même temps que le bloc de musculation, et écarte les sorties dures des jours de jambes.",
      items: ["Objectif de course", "Sorties par semaine", "Kilométrage actuel", "Date de course"],
    },
    {
      title: "Ton matériel",
      body: "Un mouvement n'est proposé que si tu as tout ce qu'il demande. Le plus petit incrément de charge disponible sert à arrondir chaque suggestion.",
      items: ["Barre", "Haltères", "Machines", "Poulies", "Élastiques", "Barre de traction", "Banc", "Poids du corps"],
    },
    {
      title: "Tes limites",
      body: "Toute zone déclarée sensible retire du catalogue les mouvements qui la sollicitent directement. Ils sont remplacés, pas « adaptés ».",
      items: ["Épaule", "Bas du dos", "Genou", "Hanche", "Coude", "Poignet", "Nuque", "Cheville", "Exercices refusés"],
    },
    {
      title: "Ton assiette",
      body: "Ton régime et les aliments que tu refuses filtrent le catalogue alimentaire. Le programme de la journée est construit avec ce qui reste, pas avec des substitutions génériques.",
      items: ["Régime", "Repas par jour", "Aliments refusés"],
    },
    {
      title: "Ton quotidien",
      body: "Le sommeil et le stress fixent ta capacité de récupération, donc le volume que tu peux réellement absorber. En dessous de six heures de sommeil, le coach retire 15 % de séries.",
      items: ["Activité hors salle", "Sommeil", "Stress", "Alimentation"],
    },
    {
      title: "Chaque jour, chaque série",
      body: "Après l'inscription, le coach continue d'apprendre : c'est ce qui sépare un programme d'un fichier PDF.",
      items: ["Check-in de forme", "Charge et répétitions", "Difficulté ressentie", "Douleur signalée", "Pesées", "Sorties GPS"],
    },
  ],
  en: [
    {
      title: "Your body",
      body: "Feeds basal metabolism, lean mass and starting loads. Body-fat percentage is optional: give it and the coach switches to more accurate formulas.",
      items: ["Age", "Sex", "Height", "Weight", "Body fat", "Waist"],
    },
    {
      title: "Your history",
      body: "A beginner progresses on far fewer sets than a seasoned lifter. Your level sets the starting volume, the progression model and the length of the blocks.",
      items: ["Months training", "Level", "Known maxes"],
    },
    {
      title: "Your goal",
      body: "One goal at a time. It fixes the calories, the rep ranges, the rest times and the order exercises are prioritised in.",
      items: ["Build muscle", "Strength", "Fat loss", "Recomposition", "General fitness", "Target weight", "Deadline"],
    },
    {
      title: "Your availability",
      body: "The number of sessions decides the shape of the week. The duration caps the volume: the coach never prescribes a session longer than the time you gave it.",
      items: ["Sessions per week", "Minutes per session"],
    },
    {
      title: "Your running",
      body: "If you run, the coach builds a running block alongside the lifting block, and keeps hard runs off your leg days.",
      items: ["Running goal", "Runs per week", "Current mileage", "Race date"],
    },
    {
      title: "Your equipment",
      body: "A movement is only offered if you have everything it needs. The smallest load increment you own is used to round every suggestion.",
      items: ["Barbell", "Dumbbells", "Machines", "Cables", "Bands", "Pull-up bar", "Bench", "Bodyweight"],
    },
    {
      title: "Your limits",
      body: "Any area you flag as sensitive removes from the catalogue the movements that load it directly. They are replaced, not \"adapted\".",
      items: ["Shoulder", "Low back", "Knee", "Hip", "Elbow", "Wrist", "Neck", "Ankle", "Refused exercises"],
    },
    {
      title: "Your plate",
      body: "Your diet and the foods you refuse filter the food catalogue. The day's plan is built from what is left, not from generic substitutions.",
      items: ["Diet", "Meals per day", "Refused foods"],
    },
    {
      title: "Your daily life",
      body: "Sleep and stress set your recovery capacity, and therefore the volume you can actually absorb. Under six hours of sleep, the coach removes 15 % of the sets.",
      items: ["Activity outside the gym", "Sleep", "Stress", "Diet"],
    },
    {
      title: "Every day, every set",
      body: "After onboarding the coach keeps learning: that is what separates a programme from a PDF.",
      items: ["Readiness check-in", "Load and reps", "Perceived effort", "Reported pain", "Weigh-ins", "GPS runs"],
    },
  ],
  es: [
    {
      title: "Tu cuerpo",
      body: "Alimenta el metabolismo basal, la masa magra y las cargas iniciales. El porcentaje de grasa es opcional: si lo indicas, el entrenador pasa a fórmulas más precisas.",
      items: ["Edad", "Sexo", "Altura", "Peso", "Grasa corporal", "Cintura"],
    },
    {
      title: "Tu historial",
      body: "Un principiante progresa con muchas menos series que un practicante experimentado. El nivel fija el volumen inicial, el modelo de progresión y la duración de los bloques.",
      items: ["Meses entrenando", "Nivel", "Máximos conocidos"],
    },
    {
      title: "Tu objetivo",
      body: "Un solo objetivo cada vez. Fija las calorías, los rangos de repeticiones, los descansos y el orden de prioridad de los ejercicios.",
      items: ["Ganar músculo", "Fuerza", "Pérdida de grasa", "Recomposición", "Forma general", "Peso objetivo", "Fecha límite"],
    },
    {
      title: "Tu disponibilidad",
      body: "El número de sesiones decide la estructura de la semana. La duración limita el volumen: el entrenador nunca prescribe una sesión más larga que el tiempo que has indicado.",
      items: ["Sesiones por semana", "Minutos por sesión"],
    },
    {
      title: "Tu carrera",
      body: "Si corres, el entrenador construye un bloque de carrera junto al de fuerza y mantiene las sesiones duras fuera de los días de pierna.",
      items: ["Objetivo de carrera", "Rodajes por semana", "Kilometraje actual", "Fecha de carrera"],
    },
    {
      title: "Tu material",
      body: "Un movimiento solo se propone si tienes todo lo que necesita. El menor incremento de carga disponible sirve para redondear cada sugerencia.",
      items: ["Barra", "Mancuernas", "Máquinas", "Poleas", "Bandas", "Barra de dominadas", "Banco", "Peso corporal"],
    },
    {
      title: "Tus límites",
      body: "Cualquier zona que marques como sensible retira del catálogo los movimientos que la cargan directamente. Se sustituyen, no se «adaptan».",
      items: ["Hombro", "Zona lumbar", "Rodilla", "Cadera", "Codo", "Muñeca", "Cuello", "Tobillo", "Ejercicios rechazados"],
    },
    {
      title: "Tu plato",
      body: "Tu dieta y los alimentos que rechazas filtran el catálogo alimentario. El plan del día se construye con lo que queda, no con sustituciones genéricas.",
      items: ["Dieta", "Comidas al día", "Alimentos rechazados"],
    },
    {
      title: "Tu día a día",
      body: "El sueño y el estrés fijan tu capacidad de recuperación y, por tanto, el volumen que puedes asimilar. Por debajo de seis horas de sueño, el entrenador quita un 15 % de las series.",
      items: ["Actividad fuera del gimnasio", "Sueño", "Estrés", "Alimentación"],
    },
    {
      title: "Cada día, cada serie",
      body: "Tras el registro el entrenador sigue aprendiendo: eso es lo que separa un programa de un PDF.",
      items: ["Check-in de forma", "Carga y repeticiones", "Esfuerzo percibido", "Dolor señalado", "Pesajes", "Rodajes con GPS"],
    },
  ],
};

export interface Stage {
  index: string;
  title: string;
  body: string;
  detail: string;
}

/** Les six étapes que le moteur enchaîne pour produire un bloc. */
export const pipeline: Localized<Stage[]> = {
  fr: [
    {
      index: "01",
      title: "Métabolisme et composition corporelle",
      body: "Mifflin-St Jeor quand la masse grasse est inconnue, Katch-McArdle dès qu'elle est renseignée. La dépense liée à l'entraînement est ajoutée séparément, pour que le nombre de séances pèse réellement sur le total.",
      detail: "TDEE = métabolisme de base × facteur d'activité + (minutes × 6 kcal × séances) ÷ 7",
    },
    {
      index: "02",
      title: "Calories et macronutriments",
      body: "Le rythme visé est exprimé en part du poids de corps, pas en kilos fixes : la même règle reste sensée à 55 kg et à 110 kg. Un plancher calorique empêche les déficits qui coûteraient du muscle.",
      detail: "Sèche : −0,50 à −0,75 % du poids par semaine · Prise de masse : +0,20 à +0,35 %\nProtéines : 1,8 à 2,6 g par kg de masse maigre selon l'objectif",
    },
    {
      index: "03",
      title: "Budget de séries hebdomadaire",
      body: "Des repères de volume par groupe musculaire, pondérés par le niveau, l'objectif, le sommeil, le stress et l'âge, puis plafonnés par le temps réellement disponible dans la semaine.",
      detail: "séries = repère × niveau × objectif × récupération, plafonné à\n((minutes − 8) ÷ 2) × séances",
    },
    {
      index: "04",
      title: "Structure de la semaine",
      body: "Deux ou trois séances donnent un full body, quatre un haut/bas, cinq un PPL complété, six un découpage à haute fréquence. Le budget de séries est ensuite réparti sur les jours les moins chargés.",
      detail: "2–3 j → full body · 4 j → haut/bas · 5 j → PPL + haut/bas · 6 j → PPL ×2",
    },
    {
      index: "05",
      title: "Choix des exercices",
      body: "Filtrage par matériel et par zones sensibles, puis un mouvement polyarticulaire en ouverture de chaque muscle, de l'isolation ensuite. Le travail indirect des polyarticulaires est décompté du budget, et tout muscle dont le jour a la charge garde un exercice qui lui est propre.",
      detail: "Une série compte 1,0 pour le muscle principal et 0,5 pour chaque muscle secondaire",
    },
    {
      index: "06",
      title: "Charges et progression",
      body: "Double progression autorégulée par le RPE : toutes les séries au sommet de la fourchette au RPE prévu, la charge monte ; des répétitions sous la fourchette, elle recule. Une douleur signalée l'emporte sur tout le reste.",
      detail: "1RM estimé = charge ÷ (1 ÷ (1 + (répétitions + réserve − 1) ÷ 30))\nCharges arrondies au plus petit incrément que tu possèdes",
    },
  ],
  en: [
    {
      index: "01",
      title: "Metabolism and body composition",
      body: "Mifflin-St Jeor when body fat is unknown, Katch-McArdle as soon as it is given. Training expenditure is added separately, so the number of sessions genuinely weighs on the total.",
      detail: "TDEE = basal metabolic rate × activity factor + (minutes × 6 kcal × sessions) ÷ 7",
    },
    {
      index: "02",
      title: "Calories and macronutrients",
      body: "The target rate is a share of body weight, not a fixed number of kilos: the same rule stays sensible at 55 kg and at 110 kg. A calorie floor prevents deficits that would cost muscle.",
      detail: "Cutting: −0.50 to −0.75 % of body weight per week · Gaining: +0.20 to +0.35 %\nProtein: 1.8 to 2.6 g per kg of lean mass depending on the goal",
    },
    {
      index: "03",
      title: "Weekly set budget",
      body: "Volume landmarks per muscle group, weighted by level, goal, sleep, stress and age, then capped by the time genuinely available in the week.",
      detail: "sets = landmark × level × goal × recovery, capped at\n((minutes − 8) ÷ 2) × sessions",
    },
    {
      index: "04",
      title: "Shape of the week",
      body: "Two or three sessions give a full body, four an upper/lower, five a completed PPL, six a high-frequency split. The set budget is then spread over the least loaded days.",
      detail: "2–3 d → full body · 4 d → upper/lower · 5 d → PPL + upper/lower · 6 d → PPL ×2",
    },
    {
      index: "05",
      title: "Exercise selection",
      body: "Filtered by equipment and by flagged areas, then a compound opens every muscle and isolation follows. The indirect work compounds provide is deducted from the budget, and every muscle a day owns keeps an exercise of its own.",
      detail: "A set counts 1.0 for the primary muscle and 0.5 for each secondary muscle",
    },
    {
      index: "06",
      title: "Loads and progression",
      body: "Double progression autoregulated by RPE: every set at the top of the range at the target RPE and the load goes up; reps under the range and it steps back. Reported pain overrides everything else.",
      detail: "Estimated 1RM = load ÷ (1 ÷ (1 + (reps + reps in reserve − 1) ÷ 30))\nLoads rounded to the smallest increment you own",
    },
  ],
  es: [
    {
      index: "01",
      title: "Metabolismo y composición corporal",
      body: "Mifflin-St Jeor cuando se desconoce la grasa corporal, Katch-McArdle en cuanto se indica. El gasto del entrenamiento se suma aparte, para que el número de sesiones pese de verdad en el total.",
      detail: "TDEE = metabolismo basal × factor de actividad + (minutos × 6 kcal × sesiones) ÷ 7",
    },
    {
      index: "02",
      title: "Calorías y macronutrientes",
      body: "El ritmo objetivo se expresa como parte del peso corporal, no en kilos fijos: la misma regla sigue teniendo sentido a 55 kg y a 110 kg. Un suelo calórico evita los déficits que costarían músculo.",
      detail: "Definición: −0,50 a −0,75 % del peso por semana · Volumen: +0,20 a +0,35 %\nProteína: 1,8 a 2,6 g por kg de masa magra según el objetivo",
    },
    {
      index: "03",
      title: "Presupuesto semanal de series",
      body: "Referencias de volumen por grupo muscular, ponderadas por nivel, objetivo, sueño, estrés y edad, y luego limitadas por el tiempo realmente disponible en la semana.",
      detail: "series = referencia × nivel × objetivo × recuperación, con tope de\n((minutos − 8) ÷ 2) × sesiones",
    },
    {
      index: "04",
      title: "Estructura de la semana",
      body: "Dos o tres sesiones dan un full body, cuatro un superior/inferior, cinco un PPL completado, seis un reparto de alta frecuencia. El presupuesto de series se reparte después en los días menos cargados.",
      detail: "2–3 d → full body · 4 d → superior/inferior · 5 d → PPL + superior/inferior · 6 d → PPL ×2",
    },
    {
      index: "05",
      title: "Elección de ejercicios",
      body: "Filtrado por material y por zonas sensibles; después un básico abre cada músculo y el aislamiento va detrás. El trabajo indirecto de los básicos se descuenta del presupuesto, y todo músculo del que un día se hace cargo conserva un ejercicio propio.",
      detail: "Una serie cuenta 1,0 para el músculo principal y 0,5 para cada músculo secundario",
    },
    {
      index: "06",
      title: "Cargas y progresión",
      body: "Doble progresión autorregulada por el RPE: todas las series en la parte alta del rango al RPE previsto y la carga sube; repeticiones por debajo del rango y retrocede. Un dolor señalado se impone a todo lo demás.",
      detail: "1RM estimado = carga ÷ (1 ÷ (1 + (repeticiones + reserva − 1) ÷ 30))\nCargas redondeadas al menor incremento que tengas",
    },
  ],
};

export interface Adaptation {
  title: string;
  body: string;
}

/** Ce que le bilan hebdomadaire modifie réellement. */
export const adaptations: Localized<Adaptation[]> = {
  fr: [
    { title: "Le volume suit ta récupération", body: "Une semaine terminée à plus de 90 % avec une forme correcte ajoute deux séries par semaine sur les gros groupes au bloc suivant. Une semaine mal absorbée en retire deux." },
    { title: "Les calories suivent la balance", body: "Le coach compare la tendance de ton poids sur quatre semaines au rythme visé, et propose un ajustement de 25 à 400 kcal. Une seule pesée ne déclenche jamais rien : c'est de l'eau, pas du gras." },
    { title: "La décharge peut être avancée", body: "Si ta forme moyenne descend sous 50 sur 100 pendant une semaine, la décharge est avancée. Ce n'est pas un recul : c'est ce qui permet à la progression de reprendre." },
    { title: "Ce qui fait mal disparaît", body: "Un mouvement sur lequel tu as signalé une douleur passe d'abord en charge réduite, puis sort du programme s'il revient. Il n'est jamais simplement répété." },
    { title: "L'allure de course se recale seule", body: "Un tempo, un fractionné ou une course chronométrée plus rapide que ton allure de seuil connue la remplace, et toutes les allures prescrites sont recalculées dessus." },
    { title: "Une séance ratée ne casse rien", body: "Les séances ne sont pas clouées à des jours fixes : tu reçois la prochaine que tu n'as pas faite, répartie sur les jours qui restent dans la semaine." },
  ],
  en: [
    { title: "Volume follows your recovery", body: "A week finished above 90 % with decent readiness adds two sets a week on the big groups in the next block. A week that was not absorbed removes two." },
    { title: "Calories follow the scale", body: "The coach compares your four-week weight trend to the target rate and proposes an adjustment of 25 to 400 kcal. A single weigh-in never triggers anything: that is water, not fat." },
    { title: "The deload can be brought forward", body: "If your average readiness drops below 50 out of 100 for a week, the deload is moved up. That is not a step back: it is what lets progress restart." },
    { title: "What hurts goes away", body: "A movement you flagged as painful first moves to reduced load, then leaves the programme if it comes back. It is never simply repeated." },
    { title: "Running pace recalibrates itself", body: "A tempo, an interval session or a timed race faster than your known threshold pace replaces it, and every prescribed pace is recalculated from there." },
    { title: "A missed session breaks nothing", body: "Sessions are not nailed to fixed days: you get the next one you have not done, spread over the days left in the week." },
  ],
  es: [
    { title: "El volumen sigue a tu recuperación", body: "Una semana completada por encima del 90 % con buena forma añade dos series semanales en los grupos grandes del siguiente bloque. Una semana mal asimilada quita dos." },
    { title: "Las calorías siguen a la báscula", body: "El entrenador compara la tendencia de tu peso en cuatro semanas con el ritmo objetivo y propone un ajuste de 25 a 400 kcal. Un solo pesaje nunca desencadena nada: eso es agua, no grasa." },
    { title: "La descarga puede adelantarse", body: "Si tu forma media baja de 50 sobre 100 durante una semana, la descarga se adelanta. No es un retroceso: es lo que permite que la progresión se reanude." },
    { title: "Lo que duele desaparece", body: "Un movimiento en el que has señalado dolor pasa primero a carga reducida y sale del programa si vuelve. Nunca se repite sin más." },
    { title: "El ritmo de carrera se recalibra solo", body: "Un tempo, unas series o una carrera cronometrada más rápida que tu ritmo de umbral conocido lo sustituye, y todos los ritmos prescritos se recalculan a partir de ahí." },
    { title: "Una sesión perdida no rompe nada", body: "Las sesiones no están clavadas a días fijos: recibes la siguiente que no has hecho, repartida en los días que quedan de la semana." },
  ],
};

export interface FaqEntry {
  question: string;
  answer: string;
}

export const faq: Localized<FaqEntry[]> = {
  fr: [
    { question: "Est-ce que mes données partent quelque part ?", answer: "Non. Tout est calculé sur l'appareil et stocké dans un fichier unique, sur le téléphone. Il n'y a pas de compte, pas de serveur, pas d'analytique. La seule exception est le fond de carte de tes sorties, qui charge des tuiles OpenStreetMap — et il se coupe depuis le profil, auquel cas ton tracé reste dessiné sur le téléphone. Tu peux exporter l'intégralité de tes données en JSON, ou tout effacer, depuis l'écran Profil." },
    { question: "Faut-il une salle de sport ?", answer: "Non. Le catalogue couvre la barre, les haltères, les machines, les poulies, les élastiques, la barre de traction et le poids du corps. Tu coches ce que tu as, et le coach ne prescrit que ce que tu peux réellement faire. Avec deux élastiques et un tapis, le programme est plus modeste, mais il existe." },
    { question: "Je débute vraiment. Il y a des vidéos ?", answer: "Non, et c'est volontaire. Une vidéo montre un mouvement réussi ; elle ne dit pas ce que tu es en train de rater, ni ce que tu devrais sentir. Le mode guidé déroule chaque mouvement étape par étape, avec des repères que tu peux vérifier sur toi-même, sans miroir, sans caméra et sans réseau. Les erreurs fréquentes y sont décrites par la sensation qui les trahit, pas par ce qu'un observateur verrait." },
    { question: "Que se passe-t-il si je saute une séance ?", answer: "Rien de dramatique. Les séances ne sont pas attachées à des jours fixes : tu reçois la prochaine séance non faite, étalée sur les jours restants. Si la semaine est vraiment incomplète, le bilan te le dit et te propose de descendre d'une séance plutôt que de te culpabiliser." },
    { question: "Pourquoi le coach me demande mon sommeil et mon stress ?", answer: "Parce que le volume que tu peux absorber en dépend directement. En dessous de six heures de sommeil, le coach retire 15 % de séries ; au-delà de huit, il en ajoute. Un stress chronique élevé coûte 10 % de plus. Prescrire le même volume à tout le monde revient à ignorer la moitié de l'équation." },
    { question: "Comment le coach connaît mes charges à la première séance ?", answer: "Si tu renseignes un maximum, il en déduit la charge exacte pour la fourchette de répétitions et le RPE prévus. Sinon, il part des repères de force publiés pour ton poids, ton sexe, ton âge et ton niveau — puis corrige dès la première série que tu enregistres." },
    { question: "Je peux m'entraîner sans emporter mon téléphone ?", answer: "Oui, et courir aussi. L'application Apple Watch reçoit la séance du jour déjà prescrite et permet de tout enregistrer au poignet, couronne comprise. Elle mesure aussi une sortie avec son propre GPS, téléphone resté à la maison ; la trace remonte au prochain rapprochement des deux appareils. Sur l'iPhone, une Live Activity affiche la série en cours ou la distance parcourue sur l'écran verrouillé." },
    { question: "C'est encore une application qui compte les calories ?", answer: "Non. Le coach donne une cible quotidienne, explique d'où elle vient, et construit une journée de repas avec des quantités pesables — mais il n'y a aucun journal alimentaire à remplir. La seule donnée nutritionnelle qu'il te demande est ton poids sur la balance, parce que c'est la seule qui permette de vérifier si la cible est juste." },
    { question: "Le simulateur de cette page donne-t-il les mêmes chiffres que l'app ?", answer: "Oui, et c'est vérifié automatiquement. Le moteur Swift produit un fichier de valeurs de référence, et les tests du site échouent si le portage TypeScript s'en écarte, ne serait-ce que d'une calorie." },
    { question: "Est-ce que ça remplace un coach humain ou un médecin ?", answer: "Non. C'est un programmeur d'entraînement rigoureux, pas un professionnel de santé. Une douleur qui dure, une pathologie connue ou une grossesse relèvent d'un médecin ou d'un kinésithérapeute, pas d'une application." },
  ],
  en: [
    { question: "Does my data go anywhere?", answer: "No. Everything is computed on the device and stored in a single file on the phone. There is no account, no server, no analytics. The one exception is the map background for your runs, which loads OpenStreetMap tiles — and it can be turned off in the profile, in which case your route is still drawn on the phone. You can export all of your data as JSON, or erase everything, from the Profile screen." },
    { question: "Do I need a gym?", answer: "No. The catalogue covers barbell, dumbbells, machines, cables, bands, pull-up bar and bodyweight. You tick what you have, and the coach only prescribes what you can actually do. With two bands and a mat the programme is more modest, but it exists." },
    { question: "I am a complete beginner. Are there videos?", answer: "No, and that is deliberate. A video shows a movement done right; it does not tell you what you are getting wrong, or what you should be feeling. Guided mode walks through every movement step by step, with checkpoints you can verify on yourself — no mirror, no camera, no connection. Common mistakes are described by the sensation that gives them away, not by what an observer would see." },
    { question: "What happens if I skip a session?", answer: "Nothing dramatic. Sessions are not attached to fixed days: you get the next session you have not done, spread over the days that are left. If the week is genuinely incomplete, the review says so and offers to drop a session rather than making you feel guilty." },
    { question: "Why does the coach ask about my sleep and stress?", answer: "Because the volume you can absorb depends directly on them. Under six hours of sleep, the coach removes 15 % of the sets; above eight, it adds some. High chronic stress costs another 10 %. Prescribing the same volume to everybody means ignoring half the equation." },
    { question: "How does the coach know my loads on the first session?", answer: "If you give a max, it derives the exact load for the planned rep range and RPE. Otherwise it starts from published strength standards for your weight, sex, age and level — then corrects from the first set you log." },
    { question: "Can I train without carrying my phone?", answer: "Yes, and run too. The Apple Watch app receives the day's session already prescribed and lets you log everything at the wrist, digital crown included. It also measures a run with its own GPS, phone left at home; the trace comes back the next time the two devices are near each other. On the iPhone, a Live Activity shows the current set or the distance covered on the lock screen." },
    { question: "Is this another calorie-counting app?", answer: "No. The coach gives a daily target, explains where it comes from, and builds a day of meals with weighable amounts — but there is no food diary to fill in. The only nutritional figure it asks for is your weight on the scale, because it is the only one that can verify whether the target is right." },
    { question: "Does the simulator on this page give the same numbers as the app?", answer: "Yes, and that is checked automatically. The Swift engine produces a reference file, and the site's tests fail if the TypeScript port drifts from it, even by a single calorie." },
    { question: "Does this replace a human coach or a doctor?", answer: "No. It is a rigorous training programmer, not a health professional. Pain that lasts, a known condition or a pregnancy belong to a doctor or a physiotherapist, not to an app." },
  ],
  es: [
    { question: "¿Mis datos salen a algún sitio?", answer: "No. Todo se calcula en el dispositivo y se guarda en un único archivo del teléfono. No hay cuenta, ni servidor, ni analítica. La única excepción es el fondo de mapa de tus rodajes, que carga teselas de OpenStreetMap, y se puede desactivar desde el perfil: en ese caso tu traza se sigue dibujando en el teléfono. Puedes exportar todos tus datos en JSON, o borrarlo todo, desde la pantalla de Perfil." },
    { question: "¿Hace falta un gimnasio?", answer: "No. El catálogo cubre barra, mancuernas, máquinas, poleas, bandas, barra de dominadas y peso corporal. Marcas lo que tienes y el entrenador solo prescribe lo que puedes hacer de verdad. Con dos bandas y una esterilla el programa es más modesto, pero existe." },
    { question: "Empiezo de cero. ¿Hay vídeos?", answer: "No, y es a propósito. Un vídeo muestra un movimiento bien hecho; no te dice qué estás fallando ni qué deberías sentir. El modo guiado desglosa cada movimiento paso a paso, con referencias que puedes comprobar en ti mismo, sin espejo, sin cámara y sin conexión. Los errores frecuentes se describen por la sensación que los delata, no por lo que vería un observador." },
    { question: "¿Qué pasa si me salto una sesión?", answer: "Nada dramático. Las sesiones no están atadas a días fijos: recibes la siguiente que no has hecho, repartida en los días que quedan. Si la semana está realmente incompleta, el balance te lo dice y te propone bajar una sesión en lugar de culpabilizarte." },
    { question: "¿Por qué me pregunta por el sueño y el estrés?", answer: "Porque el volumen que puedes asimilar depende directamente de ellos. Por debajo de seis horas de sueño, el entrenador quita un 15 % de las series; por encima de ocho, añade. Un estrés crónico alto cuesta otro 10 %. Prescribir el mismo volumen a todo el mundo es ignorar la mitad de la ecuación." },
    { question: "¿Cómo sabe mis cargas en la primera sesión?", answer: "Si indicas un máximo, deduce la carga exacta para el rango de repeticiones y el RPE previstos. Si no, parte de las referencias de fuerza publicadas para tu peso, sexo, edad y nivel, y corrige desde la primera serie que registres." },
    { question: "¿Puedo entrenar sin llevar el teléfono?", answer: "Sí, y correr también. La aplicación de Apple Watch recibe la sesión del día ya prescrita y permite registrarlo todo en la muñeca, corona incluida. También mide un rodaje con su propio GPS, con el teléfono en casa; la traza sube la próxima vez que los dos dispositivos estén cerca. En el iPhone, una Live Activity muestra la serie en curso o la distancia recorrida en la pantalla bloqueada." },
    { question: "¿Es otra aplicación para contar calorías?", answer: "No. El entrenador da un objetivo diario, explica de dónde sale y construye un día de comidas con cantidades pesables, pero no hay ningún diario alimentario que rellenar. El único dato nutricional que te pide es tu peso en la báscula, porque es el único que permite comprobar si el objetivo es correcto." },
    { question: "¿El simulador de esta página da las mismas cifras que la app?", answer: "Sí, y se comprueba automáticamente. El motor Swift produce un archivo de valores de referencia, y los tests del sitio fallan si el port a TypeScript se desvía, aunque sea en una caloría." },
    { question: "¿Sustituye a un entrenador humano o a un médico?", answer: "No. Es un programador de entrenamiento riguroso, no un profesional sanitario. Un dolor que dura, una patología conocida o un embarazo son cosa de un médico o un fisioterapeuta, no de una aplicación." },
  ],
};
