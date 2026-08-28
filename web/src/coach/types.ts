/**
 * Les types du simulateur.
 *
 * Ils reprennent ceux de MonCoachKit (l'application iOS) : le simulateur du
 * site doit donner exactement les mêmes chiffres que l'app, sinon la
 * démonstration ment.
 */

export type Sex = "male" | "female";

export type ExperienceLevel = "beginner" | "intermediate" | "advanced";

export type PrimaryGoal =
  | "hypertrophy"
  | "strength"
  | "fatLoss"
  | "recomposition"
  | "generalHealth";

export type ActivityLevel =
  | "sedentary"
  | "light"
  | "moderate"
  | "high"
  | "veryHigh";

export type SplitTemplate =
  | "fullBody"
  | "upperLower"
  | "pushPullLegs"
  | "pushPullLegsUpperLower"
  | "arnold";

export type MuscleGroup =
  | "chest"
  | "back"
  | "lats"
  | "traps"
  | "shoulders"
  | "rearDelts"
  | "biceps"
  | "triceps"
  | "forearms"
  | "quads"
  | "hamstrings"
  | "glutes"
  | "calves"
  | "core";

export interface SimulatorInput {
  sex: Sex;
  age: number;
  heightCm: number;
  weightKg: number;
  bodyFatPercent: number | null;
  experience: ExperienceLevel;
  goal: PrimaryGoal;
  daysPerWeek: number;
  sessionMinutes: number;
  activityLevel: ActivityLevel;
  sleepHours: number;
  stressLevel: number;
}

export interface BodyMetrics {
  bmi: number;
  leanBodyMassKg: number;
  leanMassIsEstimated: boolean;
  bmr: number;
  tdee: number;
}

export interface NutritionTarget {
  calories: number;
  proteinG: number;
  fatG: number;
  carbsG: number;
  maintenanceCalories: number;
  weeklyWeightChangeKg: number;
  rationale: string[];
}

export interface VolumePrescription {
  weeklySets: Record<MuscleGroup, number>;
  recoveryFactor: number;
  total: number;
  rationale: string[];
}

export interface SimulatorResult {
  metrics: BodyMetrics;
  nutrition: NutritionTarget;
  volume: VolumePrescription;
  split: SplitTemplate;
  weekCount: number;
}
