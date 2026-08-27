import { describe, expect, test } from "bun:test";
import reference from "./__fixtures__/engine-reference.json" with { type: "json" };
import {
  bodyMetrics,
  mifflinStJeor,
  nutritionTarget,
  simulate,
  splitFor,
  volumePrescription,
  weeklySetCapacity,
} from "./engine.ts";
import { allMuscles, primaryMuscles } from "./labels.ts";
import type {
  ActivityLevel,
  ExperienceLevel,
  MuscleGroup,
  PrimaryGoal,
  Sex,
  SimulatorInput,
  SplitTemplate,
} from "./types.ts";

interface ReferenceCase {
  name: string;
  input: {
    sex: string;
    age: number;
    heightCm: number;
    weightKg: number;
    bodyFatPercent: number | null;
    experience: string;
    goal: string;
    daysPerWeek: number;
    sessionMinutes: number;
    activityLevel: string;
    sleepHours: number;
    stressLevel: number;
  };
  expected: {
    bmr: number;
    tdee: number;
    leanBodyMassKg: number;
    leanMassIsEstimated: boolean;
    calories: number;
    proteinG: number;
    fatG: number;
    carbsG: number;
    maintenanceCalories: number;
    weeklyWeightChangeKg: number;
    weeklySets: Record<string, number>;
    volumeTotal: number;
    recoveryFactor: number;
    split: string;
    weekCount: number;
  };
}

const cases = reference as unknown as ReferenceCase[];

const toInput = (raw: ReferenceCase["input"]): SimulatorInput => ({
  sex: raw.sex as Sex,
  age: raw.age,
  heightCm: raw.heightCm,
  weightKg: raw.weightKg,
  bodyFatPercent: raw.bodyFatPercent ?? null,
  experience: raw.experience as ExperienceLevel,
  goal: raw.goal as PrimaryGoal,
  daysPerWeek: raw.daysPerWeek,
  sessionMinutes: raw.sessionMinutes,
  activityLevel: raw.activityLevel as ActivityLevel,
  sleepHours: raw.sleepHours,
  stressLevel: raw.stressLevel,
});

const sample: SimulatorInput = {
  sex: "male",
  age: 30,
  heightCm: 178,
  weightKg: 78,
  bodyFatPercent: 16,
  experience: "intermediate",
  goal: "hypertrophy",
  daysPerWeek: 4,
  sessionMinutes: 70,
  activityLevel: "light",
  sleepHours: 7.5,
  stressLevel: 3,
};

describe("le simulateur reproduit le moteur de l'application", () => {
  test("le fichier de référence n'est pas vide", () => {
    expect(cases.length).toBeGreaterThan(0);
  });

  for (const scenario of cases) {
    test(scenario.name, () => {
      const input = toInput(scenario.input);
      const result = simulate(input);
      const expected = scenario.expected;

      expect(result.metrics.bmr).toBeCloseTo(expected.bmr, 6);
      expect(result.metrics.tdee).toBeCloseTo(expected.tdee, 6);
      expect(result.metrics.leanBodyMassKg).toBeCloseTo(expected.leanBodyMassKg, 6);
      expect(result.metrics.leanMassIsEstimated).toBe(expected.leanMassIsEstimated);

      expect(result.nutrition.calories).toBe(expected.calories);
      expect(result.nutrition.proteinG).toBe(expected.proteinG);
      expect(result.nutrition.fatG).toBe(expected.fatG);
      expect(result.nutrition.carbsG).toBe(expected.carbsG);
      expect(result.nutrition.maintenanceCalories).toBe(expected.maintenanceCalories);
      expect(result.nutrition.weeklyWeightChangeKg).toBeCloseTo(
        expected.weeklyWeightChangeKg,
        6,
      );

      expect(result.volume.recoveryFactor).toBeCloseTo(expected.recoveryFactor, 6);
      expect(result.volume.total).toBe(expected.volumeTotal);
      for (const muscle of allMuscles) {
        expect(result.volume.weeklySets[muscle]).toBe(expected.weeklySets[muscle] ?? 0);
      }

      expect(result.split).toBe(expected.split as SplitTemplate);
      expect(result.weekCount).toBe(expected.weekCount);
    });
  }
});

describe("métriques corporelles", () => {
  test("Mifflin-St Jeor tombe sur la valeur de référence", () => {
    // 10 × 78 + 6,25 × 178 − 5 × 30 + 5
    expect(mifflinStJeor(sample)).toBeCloseTo(1747.5, 6);
  });

  test("Katch-McArdle prend le relais dès que le taux de gras est connu", () => {
    const metrics = bodyMetrics(sample);
    expect(metrics.leanMassIsEstimated).toBe(false);
    expect(metrics.leanBodyMassKg).toBeCloseTo(65.52, 6);
    expect(metrics.bmr).toBeCloseTo(370 + 21.6 * 65.52, 6);
  });

  test("plus de séances par semaine augmente la dépense totale", () => {
    const three = bodyMetrics({ ...sample, daysPerWeek: 3 });
    const six = bodyMetrics({ ...sample, daysPerWeek: 6 });
    expect(six.tdee).toBeGreaterThan(three.tdee);
  });
});

describe("nutrition", () => {
  test("les macros couvrent le total calorique", () => {
    const goals: PrimaryGoal[] = [
      "hypertrophy",
      "strength",
      "fatLoss",
      "recomposition",
      "generalHealth",
    ];
    for (const goal of goals) {
      const input = { ...sample, goal };
      const target = nutritionTarget(input, bodyMetrics(input));
      const sum = target.proteinG * 4 + target.fatG * 9 + target.carbsG * 4;
      expect(Math.abs(sum - target.calories)).toBeLessThanOrEqual(15);
    }
  });

  test("la sèche est en déficit, la prise de muscle en surplus", () => {
    const cut = { ...sample, goal: "fatLoss" as const };
    const bulk = { ...sample, goal: "hypertrophy" as const };
    const cutTarget = nutritionTarget(cut, bodyMetrics(cut));
    const bulkTarget = nutritionTarget(bulk, bodyMetrics(bulk));
    expect(cutTarget.calories).toBeLessThan(cutTarget.maintenanceCalories - 100);
    expect(bulkTarget.calories).toBeGreaterThan(bulkTarget.maintenanceCalories + 50);
    expect(cutTarget.proteinG).toBeGreaterThan(bulkTarget.proteinG);
  });

  test("un plancher calorique protège les régimes trop agressifs", () => {
    const tiny: SimulatorInput = {
      ...sample,
      sex: "female",
      goal: "fatLoss",
      weightKg: 45,
      heightCm: 150,
      bodyFatPercent: 10,
      activityLevel: "sedentary",
      daysPerWeek: 2,
      sessionMinutes: 30,
    };
    const target = nutritionTarget(tiny, bodyMetrics(tiny));
    expect(target.calories).toBeGreaterThanOrEqual(1200);
    expect(target.carbsG).toBeGreaterThanOrEqual(30);
  });
});

describe("volume et structure", () => {
  test("le débutant reçoit moins de volume que l'avancé", () => {
    const low = volumePrescription({ ...sample, experience: "beginner" }).total;
    const high = volumePrescription({ ...sample, experience: "advanced" }).total;
    expect(low).toBeLessThan(high);
  });

  test("des séances courtes plafonnent le volume", () => {
    const short = volumePrescription({ ...sample, sessionMinutes: 30 });
    const long = volumePrescription({ ...sample, sessionMinutes: 90 });
    expect(short.total).toBeLessThan(long.total);
    expect(short.total).toBeLessThanOrEqual(
      weeklySetCapacity({ ...sample, sessionMinutes: 30 }) + allMuscles.length,
    );
  });

  test("aucun groupe principal n'est abandonné", () => {
    const prescription = volumePrescription({
      ...sample,
      daysPerWeek: 2,
      sessionMinutes: 30,
    });
    for (const muscle of primaryMuscles) {
      expect(prescription.weeklySets[muscle]).toBeGreaterThanOrEqual(2);
    }
  });

  test("le manque de sommeil réduit la capacité de récupération", () => {
    const rested = volumePrescription({ ...sample, sleepHours: 8.5 });
    const tired = volumePrescription({ ...sample, sleepHours: 5 });
    expect(tired.recoveryFactor).toBeLessThan(rested.recoveryFactor);
  });

  test("le découpage suit le nombre de séances", () => {
    const expectations: Array<[number, SplitTemplate]> = [
      [2, "fullBody"],
      [3, "fullBody"],
      [4, "upperLower"],
      [5, "pushPullLegsUpperLower"],
      [6, "pushPullLegs"],
    ];
    for (const [days, split] of expectations) {
      expect(splitFor({ ...sample, daysPerWeek: days })).toBe(split);
    }
    expect(splitFor({ ...sample, daysPerWeek: 6, experience: "advanced" })).toBe("arnold");
  });
});

describe("robustesse des entrées", () => {
  test("des valeurs absurdes sont ramenées dans le domaine du possible", () => {
    const absurd: SimulatorInput = {
      ...sample,
      age: 300,
      heightCm: 0,
      weightKg: -10,
      daysPerWeek: 42,
      sessionMinutes: 1,
      sleepHours: 40,
      stressLevel: 99,
      bodyFatPercent: 900,
    };
    const result = simulate(absurd);
    expect(Number.isFinite(result.nutrition.calories)).toBe(true);
    expect(result.nutrition.calories).toBeGreaterThanOrEqual(1200);
    expect(result.volume.total).toBeGreaterThan(0);
    for (const muscle of allMuscles as MuscleGroup[]) {
      expect(Number.isFinite(result.volume.weeklySets[muscle])).toBe(true);
    }
  });
});
