import type {
  ActivityLevel,
  ExperienceLevel,
  MuscleGroup,
  PrimaryGoal,
  Sex,
  SplitTemplate,
} from "./types.ts";

export const sexLabels: Record<Sex, string> = {
  male: "Homme",
  female: "Femme",
};

export const experienceLabels: Record<ExperienceLevel, string> = {
  beginner: "Débutant",
  intermediate: "Intermédiaire",
  advanced: "Avancé",
};

export const goalLabels: Record<PrimaryGoal, string> = {
  hypertrophy: "Prise de muscle",
  strength: "Force maximale",
  fatLoss: "Perte de gras",
  recomposition: "Recomposition",
  generalHealth: "Forme générale",
};

export const activityLabels: Record<ActivityLevel, string> = {
  sedentary: "Sédentaire",
  light: "Légèrement actif",
  moderate: "Modérément actif",
  high: "Très actif",
  veryHigh: "Métier physique",
};

export const splitLabels: Record<SplitTemplate, string> = {
  fullBody: "Full body",
  upperLower: "Haut / Bas",
  pushPullLegs: "Push / Pull / Legs",
  pushPullLegsUpperLower: "PPL + Haut / Bas",
  arnold: "Arnold split",
};

export const splitRationale: Record<SplitTemplate, string> = {
  fullBody:
    "Chaque muscle est stimulé à chaque séance : la structure la plus rentable quand le temps de salle est limité.",
  upperLower:
    "Deux fois par semaine sur chaque muscle, avec assez de volume par séance pour progresser sans y passer la soirée.",
  pushPullLegs:
    "Les groupes musculaires qui travaillent ensemble sont regroupés, ce qui limite la fatigue croisée entre séances.",
  pushPullLegsUpperLower:
    "Cinq séances : trois PPL pour le volume, deux haut/bas pour ramener la fréquence à deux fois par semaine partout.",
  arnold:
    "Six séances courtes, fréquence élevée : réservé aux pratiquants avancés qui récupèrent bien.",
};

export const muscleLabels: Record<MuscleGroup, string> = {
  chest: "Pectoraux",
  back: "Dos (épaisseur)",
  lats: "Dorsaux (largeur)",
  traps: "Trapèzes",
  shoulders: "Épaules",
  rearDelts: "Deltoïdes postérieurs",
  biceps: "Biceps",
  triceps: "Triceps",
  forearms: "Avant-bras",
  quads: "Quadriceps",
  hamstrings: "Ischio-jambiers",
  glutes: "Fessiers",
  calves: "Mollets",
  core: "Gainage",
};

/** Les groupes qui portent l'essentiel du budget de séries d'un programme. */
export const primaryMuscles: MuscleGroup[] = [
  "chest",
  "back",
  "lats",
  "shoulders",
  "quads",
  "hamstrings",
  "glutes",
  "biceps",
  "triceps",
];

export const allMuscles: MuscleGroup[] = [
  "chest",
  "back",
  "lats",
  "traps",
  "shoulders",
  "rearDelts",
  "biceps",
  "triceps",
  "forearms",
  "quads",
  "hamstrings",
  "glutes",
  "calves",
  "core",
];
