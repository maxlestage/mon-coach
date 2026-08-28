import { allMuscles, primaryMuscles } from "./labels.ts";
import type {
  ActivityLevel,
  BodyMetrics,
  ExperienceLevel,
  MuscleGroup,
  NutritionTarget,
  PrimaryGoal,
  SimulatorInput,
  SimulatorResult,
  SplitTemplate,
  VolumePrescription,
} from "./types.ts";
import type { Localized } from "./types.ts";

/**
 * Port TypeScript du moteur de MonCoachKit.
 *
 * C'est volontairement un portage littéral, formule pour formule : le
 * simulateur du site n'a d'intérêt que s'il renvoie exactement ce que
 * l'application renverrait. Toute divergence est un bug, pas une adaptation.
 *
 * Ce que ce portage ne fait PAS, et que l'application fait : le choix des
 * exercices, la progression des charges, l'autorégulation quotidienne et le
 * bilan hebdomadaire. Ces parties ont besoin d'un historique d'entraînement.
 */

const clamp = (value: number, low: number, high: number): number =>
  Math.min(Math.max(value, low), high);

// ---------------------------------------------------------------- métriques

const activityMultipliers: Record<ActivityLevel, number> = {
  sedentary: 1.2,
  light: 1.32,
  moderate: 1.42,
  high: 1.55,
  veryHigh: 1.7,
};

/** Mifflin-St Jeor, la référence quand le taux de masse grasse est inconnu. */
export function mifflinStJeor(input: SimulatorInput): number {
  const base = 10 * input.weightKg + 6.25 * input.heightCm - 5 * input.age;
  return input.sex === "male" ? base + 5 : base - 161;
}

/** Estimation de Boer, utilisée à défaut de mesure. */
export function boerLeanMass(input: SimulatorInput): number {
  return input.sex === "male"
    ? 0.407 * input.weightKg + 0.267 * input.heightCm - 19.2
    : 0.252 * input.weightKg + 0.473 * input.heightCm - 48.3;
}

/** L'entraînement brûle environ 6 kcal/min, amorti sur la semaine. */
export function trainingExpenditure(input: SimulatorInput): number {
  return (input.sessionMinutes * 6 * input.daysPerWeek) / 7;
}

export function bodyMetrics(input: SimulatorInput): BodyMetrics {
  const heightM = input.heightCm / 100;
  const bmi = heightM > 0 ? input.weightKg / (heightM * heightM) : 0;

  const measuredLean =
    input.bodyFatPercent === null
      ? null
      : input.weightKg * (1 - clamp(input.bodyFatPercent, 3, 60) / 100);
  const lean = measuredLean ?? boerLeanMass(input);

  // Katch-McArdle dès que la masse maigre est connue, sinon Mifflin-St Jeor.
  const bmr = measuredLean !== null ? 370 + 21.6 * lean : mifflinStJeor(input);
  const tdee = bmr * activityMultipliers[input.activityLevel] + trainingExpenditure(input);

  return {
    bmi,
    leanBodyMassKg: lean,
    leanMassIsEstimated: measuredLean === null,
    bmr,
    tdee,
  };
}

// ---------------------------------------------------------------- nutrition

export function nutritionTarget(
  input: SimulatorInput,
  metrics: BodyMetrics,
): NutritionTarget {
  const maintenance = metrics.tdee;
  const rationale: Localized<string>[] = [];

  // Le rythme est exprimé en part du poids de corps : il reste sensé à 55 kg
  // comme à 110 kg.
  let weeklyChangeKg: number;
  switch (input.goal) {
    case "fatLoss": {
      const rate = (input.bodyFatPercent ?? 22) < 15 ? 0.005 : 0.0075;
      weeklyChangeKg = -input.weightKg * rate;
      rationale.push(
        {
          fr: `Déficit calibré pour perdre environ ${Math.abs(weeklyChangeKg).toFixed(1).replace(".", ",")} kg par semaine, le rythme qui préserve le mieux la masse musculaire.`,
          en: `Deficit set to lose about ${Math.abs(weeklyChangeKg).toFixed(1)} kg a week, the rate that best preserves muscle.`,
          es: `Déficit calibrado para perder unos ${Math.abs(weeklyChangeKg).toFixed(1).replace(".", ",")} kg por semana, el ritmo que mejor preserva el músculo.`,
        },
      );
      break;
    }
    case "hypertrophy": {
      const rate = input.experience === "beginner" ? 0.0035 : 0.002;
      weeklyChangeKg = input.weightKg * rate;
      rationale.push(
        {
          fr: `Léger surplus : viser plus de ${weeklyChangeKg.toFixed(1).replace(".", ",")} kg par semaine ferait surtout gagner du gras.`,
          en: `A small surplus: aiming for more than ${weeklyChangeKg.toFixed(1)} kg a week would mostly add fat.`,
          es: `Superávit ligero: buscar más de ${weeklyChangeKg.toFixed(1).replace(".", ",")} kg por semana añadiría sobre todo grasa.`,
        },
      );
      break;
    }
    case "strength":
      weeklyChangeKg = input.weightKg * 0.0015;
      rationale.push(
        {
          fr: "Surplus minime : assez pour soutenir la récupération sans alourdir les mouvements au poids de corps.",
          en: "A minimal surplus: enough to support recovery without weighing down your bodyweight work.",
          es: "Superávit mínimo: suficiente para sostener la recuperación sin lastrar los movimientos con peso corporal.",
        },
      );
      break;
    case "recomposition":
      weeklyChangeKg = 0;
      rationale.push(
        {
          fr: "Calories de maintien : la recomposition se joue sur les protéines et la progression à l'entraînement, pas sur le déficit.",
          en: "Maintenance calories: recomposition is won on protein and training progress, not on a deficit.",
          es: "Calorías de mantenimiento: la recomposición se juega en la proteína y en la progresión del entrenamiento, no en el déficit.",
        },
      );
      break;
    case "generalHealth":
      weeklyChangeKg = 0;
      rationale.push(
        {
          fr: "Calories de maintien, l'objectif étant la régularité plutôt qu'une variation de poids.",
          en: "Maintenance calories, since the goal is consistency rather than a change in weight.",
          es: "Calorías de mantenimiento, ya que el objetivo es la constancia y no un cambio de peso.",
        },
      );
      break;
  }

  // 7 700 kcal ≈ 1 kg de masse corporelle.
  let calories = maintenance + (weeklyChangeKg * 7700) / 7;

  const floor = Math.max(1200, metrics.leanBodyMassKg * 22);
  if (calories < floor) {
    calories = floor;
    rationale.push(
      {
        fr: "Le déficit a été plafonné : descendre plus bas compromettrait la récupération et les apports en micronutriments.",
        en: "The deficit was capped: going lower would compromise recovery and micronutrient intake.",
        es: "El déficit se ha limitado: bajar más comprometería la recuperación y el aporte de micronutrientes.",
      },
    );
  }

  const proteinPerKgLean =
    input.goal === "fatLoss"
      ? 2.6
      : input.goal === "recomposition"
        ? 2.4
        : input.goal === "generalHealth"
          ? 1.8
          : 2.2;
  const proteinG = metrics.leanBodyMassKg * proteinPerKgLean;

  let fatG = Math.max(input.weightKg * 0.8, (calories * 0.2) / 9);
  let carbsG = (calories - proteinG * 4 - fatG * 9) / 4;
  if (carbsG < 50) {
    const deficit = (50 - carbsG) * 4;
    fatG = Math.max(input.weightKg * 0.5, fatG - deficit / 9);
    carbsG = (calories - proteinG * 4 - fatG * 9) / 4;
    rationale.push(
      {
        fr: "Les lipides ont été réduits au minimum physiologique pour garder assez de glucides autour des séances.",
        en: "Fat was cut to the physiological minimum to keep enough carbohydrate around training.",
        es: "Las grasas se han reducido al mínimo fisiológico para mantener hidratos suficientes alrededor del entrenamiento.",
      },
    );
  }
  carbsG = Math.max(carbsG, 30);

  rationale.push(
    {
      fr: `${Math.round(proteinG)} g de protéines, soit ${proteinPerKgLean.toFixed(1).replace(".", ",")} g par kg de masse maigre : c'est le levier numéro un, avant même le total calorique.`,
      en: `${Math.round(proteinG)} g of protein, or ${proteinPerKgLean.toFixed(1)} g per kg of lean mass: the number-one lever, ahead of the calorie total itself.`,
      es: `${Math.round(proteinG)} g de proteína, es decir ${proteinPerKgLean.toFixed(1).replace(".", ",")} g por kg de masa magra: la palanca número uno, por delante del total calórico.`,
    },
  );

  return {
    calories: Math.round(calories),
    proteinG: Math.round(proteinG),
    fatG: Math.round(fatG),
    carbsG: Math.round(carbsG),
    maintenanceCalories: Math.round(maintenance),
    weeklyWeightChangeKg: weeklyChangeKg,
    rationale,
  };
}

// ------------------------------------------------------------------- volume

const volumeBaseline: Record<MuscleGroup, number> = {
  chest: 14,
  back: 14,
  lats: 12,
  quads: 14,
  hamstrings: 12,
  glutes: 10,
  shoulders: 12,
  rearDelts: 8,
  biceps: 10,
  triceps: 10,
  traps: 6,
  calves: 8,
  forearms: 4,
  core: 6,
};

const experienceFactors: Record<ExperienceLevel, number> = {
  beginner: 0.65,
  intermediate: 1.0,
  advanced: 1.2,
};

const goalVolumeFactors: Record<PrimaryGoal, number> = {
  hypertrophy: 1.0,
  recomposition: 0.95,
  strength: 0.8,
  fatLoss: 0.9,
  generalHealth: 0.75,
};

/** Combien de séries tiennent réellement dans la semaine de l'athlète. */
export function weeklySetCapacity(input: SimulatorInput): number {
  const usableMinutes = Math.max(0, input.sessionMinutes - 8);
  return Math.round((usableMinutes / 2) * input.daysPerWeek);
}

export function volumePrescription(input: SimulatorInput): VolumePrescription {
  const rationale: Localized<string>[] = [];

  if (input.experience === "beginner") {
    rationale.push(
      {
        fr: "Volume volontairement bas : à ce niveau, la technique et la régularité comptent bien plus que le nombre de séries.",
        en: "Volume deliberately low: at this level, technique and consistency matter far more than set count.",
        es: "Volumen deliberadamente bajo: a este nivel, la técnica y la constancia importan mucho más que el número de series.",
      },
    );
  }
  if (input.goal === "strength") {
    rationale.push(
      {
        fr: "Moins de séries mais plus lourdes : la force se construit sur l'intensité, pas sur le tonnage.",
        en: "Fewer sets, heavier ones: strength is built on intensity, not on tonnage.",
        es: "Menos series pero más pesadas: la fuerza se construye con intensidad, no con tonelaje.",
      },
    );
  }
  if (input.goal === "fatLoss") {
    rationale.push(
      {
        fr: "Volume légèrement réduit : en déficit, la récupération est le facteur limitant.",
        en: "Volume slightly reduced: in a deficit, recovery is the limiting factor.",
        es: "Volumen ligeramente reducido: en déficit, la recuperación es el factor limitante.",
      },
    );
  }

  let recovery = 1;
  if (input.sleepHours < 6) {
    recovery -= 0.15;
    rationale.push(
      {
        fr: "Moins de 6 h de sommeil : le volume est réduit de 15 % tant que ça ne bouge pas, sinon la fatigue s'accumule sans progression.",
        en: "Under 6 h of sleep: volume is cut by 15 % until that changes, otherwise fatigue banks up without progress.",
        es: "Menos de 6 h de sueño: el volumen baja un 15 % mientras eso no cambie, o la fatiga se acumula sin progreso.",
      },
    );
  } else if (input.sleepHours < 7) {
    recovery -= 0.07;
  } else if (input.sleepHours >= 8) {
    recovery += 0.05;
  }
  if (input.stressLevel >= 4) {
    recovery -= 0.1;
    rationale.push(
      {
        fr: "Niveau de stress élevé : on garde de la marge pour éviter de transformer chaque séance en dette de récupération.",
        en: "High stress: we keep some room so every session does not turn into recovery debt.",
        es: "Estrés alto: dejamos margen para que cada sesión no se convierta en deuda de recuperación.",
      },
    );
  }
  if (input.age >= 45) {
    recovery -= 0.08;
  }
  recovery = clamp(recovery, 0.6, 1.15);

  const capacity = weeklySetCapacity(input);
  const raw = {} as Record<MuscleGroup, number>;
  for (const muscle of allMuscles) {
    raw[muscle] =
      volumeBaseline[muscle] *
      experienceFactors[input.experience] *
      goalVolumeFactors[input.goal] *
      recovery;
  }

  const rawTotal = allMuscles.reduce((sum, muscle) => sum + raw[muscle], 0);
  let scale = 1;
  if (rawTotal > capacity) {
    scale = capacity / rawTotal;
    rationale.push(
      {
        fr: `Le volume a été ajusté à ${input.daysPerWeek} séances de ${input.sessionMinutes} min : mieux vaut un plan terminé qu'un plan idéal abandonné.`,
        en: `Volume was fitted to ${input.daysPerWeek} sessions of ${input.sessionMinutes} min: a plan you finish beats an ideal plan you abandon.`,
        es: `El volumen se ha ajustado a ${input.daysPerWeek} sesiones de ${input.sessionMinutes} min: vale más un plan que terminas que un plan ideal que abandonas.`,
      },
    );
  }

  const weeklySets = {} as Record<MuscleGroup, number>;
  for (const muscle of allMuscles) {
    const scaled = Math.round(raw[muscle] * scale);
    weeklySets[muscle] =
      scaled >= 2 ? scaled : primaryMuscles.includes(muscle) ? 2 : 0;
  }

  const total = allMuscles.reduce((sum, muscle) => sum + weeklySets[muscle], 0);
  return { weeklySets, recoveryFactor: recovery, total, rationale };
}

// -------------------------------------------------------------------- bloc

export function splitFor(input: SimulatorInput): SplitTemplate {
  if (input.daysPerWeek <= 3) return "fullBody";
  if (input.daysPerWeek === 4) return "upperLower";
  if (input.daysPerWeek === 5) return "pushPullLegsUpperLower";
  return input.experience === "advanced" ? "arnold" : "pushPullLegs";
}

/** Longueur du bloc, semaine de décharge comprise. */
export function weekCount(experience: ExperienceLevel): number {
  switch (experience) {
    case "beginner":
      return 6;
    case "intermediate":
      return 5;
    case "advanced":
      return 4;
  }
}

export function simulate(input: SimulatorInput): SimulatorResult {
  const safe: SimulatorInput = {
    ...input,
    age: clamp(input.age, 14, 90),
    heightCm: clamp(input.heightCm, 130, 220),
    weightKg: clamp(input.weightKg, 35, 200),
    daysPerWeek: clamp(input.daysPerWeek, 2, 6),
    sessionMinutes: clamp(input.sessionMinutes, 20, 150),
    sleepHours: clamp(input.sleepHours, 3, 12),
    stressLevel: clamp(input.stressLevel, 1, 5),
    bodyFatPercent:
      input.bodyFatPercent === null ? null : clamp(input.bodyFatPercent, 3, 60),
  };

  const metrics = bodyMetrics(safe);
  return {
    metrics,
    nutrition: nutritionTarget(safe, metrics),
    volume: volumePrescription(safe),
    split: splitFor(safe),
    weekCount: weekCount(safe.experience),
  };
}
