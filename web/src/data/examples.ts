import type { Language } from "../i18n/language.tsx";
import raw from "./examples.json" with { type: "json" };

/**
 * Les exemples affichés par le site, produits par le moteur Swift.
 *
 * Le fichier JSON est régénéré par `swift run --package-path
 * tools/FixtureGenerator exemples`, et la CI échoue s'il diffère de la
 * version commitée. Écrire ces exemples à la main aurait été plus rapide, et
 * faux dès la première modification du moteur : une page qui promet un plan
 * que l'application ne produit plus est pire qu'une page vide.
 */

export type Localized = Record<Language, string>;

export interface ExampleItem {
  name: Localized;
  grams: number;
  tier: string;
  reason: Localized;
}

export interface ExampleMeal {
  slot: Localized;
  kcal: number;
  proteinG: number;
  note: Localized | null;
  items: ExampleItem[];
}

export interface ExampleStep {
  index: number;
  title: Localized;
  detail: Localized;
  checkpoint: Localized | null;
}

export interface ExampleMistake {
  symptom: Localized;
  cause: Localized;
  fix: Localized;
}

export interface ExampleOption {
  name: Localized;
  equipment: Localized[];
  closeness: number;
  reason: Localized;
}

export interface Examples {
  athlete: {
    sex: string;
    age: number;
    heightCm: number;
    weightKg: number;
    bodyFatPercent: number;
    goal: Localized;
    daysPerWeek: number;
    diet: Localized;
  };
  nutrition: { calories: number; proteinG: number; carbsG: number; fatG: number };
  day: {
    meals: ExampleMeal[];
    notes: Localized[];
    totalKcal: number;
    totalProteinG: number;
    totalFiberG: number;
  };
  technique: {
    exercise: Localized;
    title: Localized;
    oneThing: Localized;
    breathing: Localized;
    tempo: Localized;
    easier: Localized | null;
    harder: Localized | null;
    steps: ExampleStep[];
    mistakes: ExampleMistake[];
  };
  substitution: {
    exercise: Localized;
    muscle: Localized;
    busyEquipment: Localized[];
    headline: Localized;
    detail: Localized;
    options: ExampleOption[];
  };
}

export const examples = raw as unknown as Examples;
