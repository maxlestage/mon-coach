import type {
  ActivityLevel,
  ExperienceLevel,
  MuscleGroup,
  PrimaryGoal,
  Sex,
  SplitTemplate,
} from "./types.ts";
import type { Language } from "../i18n/language.tsx";

type Labels<T extends string> = Record<Language, Record<T, string>>;

export const sexLabels: Labels<Sex> = {
  fr: { male: "Homme", female: "Femme" },
  en: { male: "Male", female: "Female" },
  es: { male: "Hombre", female: "Mujer" },
};

export const experienceLabels: Labels<ExperienceLevel> = {
  fr: { beginner: "Débutant", intermediate: "Intermédiaire", advanced: "Avancé" },
  en: { beginner: "Beginner", intermediate: "Intermediate", advanced: "Advanced" },
  es: { beginner: "Principiante", intermediate: "Intermedio", advanced: "Avanzado" },
};

export const goalLabels: Labels<PrimaryGoal> = {
  fr: {
    hypertrophy: "Prise de muscle",
    strength: "Force maximale",
    fatLoss: "Perte de gras",
    recomposition: "Recomposition",
    generalHealth: "Forme générale",
  },
  en: {
    hypertrophy: "Build muscle",
    strength: "Maximal strength",
    fatLoss: "Fat loss",
    recomposition: "Recomposition",
    generalHealth: "General fitness",
  },
  es: {
    hypertrophy: "Ganar músculo",
    strength: "Fuerza máxima",
    fatLoss: "Pérdida de grasa",
    recomposition: "Recomposición",
    generalHealth: "Forma general",
  },
};

export const activityLabels: Labels<ActivityLevel> = {
  fr: {
    sedentary: "Sédentaire",
    light: "Légèrement actif",
    moderate: "Modérément actif",
    high: "Très actif",
    veryHigh: "Métier physique",
  },
  en: {
    sedentary: "Sedentary",
    light: "Lightly active",
    moderate: "Moderately active",
    high: "Very active",
    veryHigh: "Physical job",
  },
  es: {
    sedentary: "Sedentario",
    light: "Ligeramente activo",
    moderate: "Moderadamente activo",
    high: "Muy activo",
    veryHigh: "Trabajo físico",
  },
};

export const splitLabels: Labels<SplitTemplate> = {
  fr: {
    fullBody: "Full body",
    upperLower: "Haut / Bas",
    pushPullLegs: "Push / Pull / Legs",
    pushPullLegsUpperLower: "PPL + Haut / Bas",
    arnold: "Arnold split",
  },
  en: {
    fullBody: "Full body",
    upperLower: "Upper / Lower",
    pushPullLegs: "Push / Pull / Legs",
    pushPullLegsUpperLower: "PPL + Upper / Lower",
    arnold: "Arnold split",
  },
  es: {
    fullBody: "Full body",
    upperLower: "Superior / Inferior",
    pushPullLegs: "Empuje / Tirón / Pierna",
    pushPullLegsUpperLower: "PPL + Superior / Inferior",
    arnold: "Rutina Arnold",
  },
};

export const splitRationale: Labels<SplitTemplate> = {
  fr: {
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
  },
  en: {
    fullBody:
      "Every muscle is stimulated in every session: the best return on time when gym hours are scarce.",
    upperLower:
      "Twice a week on every muscle, with enough volume per session to progress without spending the evening there.",
    pushPullLegs:
      "Muscle groups that work together are grouped together, which limits cross-fatigue between sessions.",
    pushPullLegsUpperLower:
      "Five sessions: three PPL for volume, two upper/lower to bring frequency back to twice a week everywhere.",
    arnold:
      "Six short sessions at high frequency: for advanced lifters who recover well, and nobody else.",
  },
  es: {
    fullBody:
      "Cada músculo se estimula en cada sesión: la estructura más rentable cuando el tiempo de gimnasio es escaso.",
    upperLower:
      "Dos veces por semana en cada músculo, con volumen suficiente por sesión para progresar sin pasar la tarde allí.",
    pushPullLegs:
      "Los grupos musculares que trabajan juntos se agrupan, lo que limita la fatiga cruzada entre sesiones.",
    pushPullLegsUpperLower:
      "Cinco sesiones: tres PPL para el volumen y dos superior/inferior para devolver la frecuencia a dos veces por semana en todo.",
    arnold:
      "Seis sesiones cortas y alta frecuencia: reservado a avanzados que recuperan bien.",
  },
};

export const muscleLabels: Labels<MuscleGroup> = {
  fr: {
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
  },
  en: {
    chest: "Chest",
    back: "Back (thickness)",
    lats: "Lats (width)",
    traps: "Traps",
    shoulders: "Shoulders",
    rearDelts: "Rear delts",
    biceps: "Biceps",
    triceps: "Triceps",
    forearms: "Forearms",
    quads: "Quads",
    hamstrings: "Hamstrings",
    glutes: "Glutes",
    calves: "Calves",
    core: "Core",
  },
  es: {
    chest: "Pectorales",
    back: "Espalda (grosor)",
    lats: "Dorsales (anchura)",
    traps: "Trapecios",
    shoulders: "Hombros",
    rearDelts: "Deltoides posteriores",
    biceps: "Bíceps",
    triceps: "Tríceps",
    forearms: "Antebrazos",
    quads: "Cuádriceps",
    hamstrings: "Isquiotibiales",
    glutes: "Glúteos",
    calves: "Gemelos",
    core: "Core",
  },
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
