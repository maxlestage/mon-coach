import { describe, expect, test } from "bun:test";
import { adaptations, faq, inputGroups, pipeline } from "../data/content.ts";
import {
  activityLabels,
  experienceLabels,
  goalLabels,
  muscleLabels,
  sexLabels,
  splitLabels,
  splitRationale,
} from "../coach/labels.ts";
import { simulate } from "../coach/engine.ts";
import { defaultInput } from "../components/Simulator.tsx";
import { languages, type Language } from "./language.tsx";

/**
 * La garantie de traduction du site.
 *
 * Le système de types refuse déjà une clé absente d'une langue ; ces tests
 * couvrent ce qu'il ne voit pas : une version copiée-collée depuis le
 * français, une liste plus courte dans une langue, une justification du
 * moteur restée monolingue.
 */

const accented = /[éèêëàâçîïôùûœ]/i;

describe("Contenu éditorial", () => {
  test("chaque bloc existe dans les trois langues, avec le même nombre d'entrées", () => {
    for (const block of [inputGroups, pipeline, adaptations, faq]) {
      const counts = languages.map((language) => block[language].length);
      expect(new Set(counts).size).toBe(1);
      expect(counts[0]).toBeGreaterThan(0);
    }
  });

  test("les versions anglaise et espagnole ne sont pas le texte français recopié", () => {
    for (const group of inputGroups.fr) {
      const twin = inputGroups.en.find((candidate) => candidate.items.length === group.items.length);
      expect(twin?.body).not.toBe(group.body);
    }
    for (let index = 0; index < faq.fr.length; index += 1) {
      expect(faq.en[index]!.answer).not.toBe(faq.fr[index]!.answer);
      expect(faq.es[index]!.answer).not.toBe(faq.fr[index]!.answer);
    }
  });

  test("l'anglais ne traîne pas d'accents français oubliés", () => {
    // Un accent dans la version anglaise trahit presque toujours une phrase
    // laissée telle quelle. Les noms propres n'en portent pas ici.
    for (const entry of faq.en) {
      expect(accented.test(entry.question)).toBe(false);
      expect(accented.test(entry.answer)).toBe(false);
    }
    for (const stage of pipeline.en) {
      expect(accented.test(stage.title)).toBe(false);
      expect(accented.test(stage.body)).toBe(false);
    }
  });
});

describe("Libellés du moteur", () => {
  test("chaque libellé couvre les trois langues et toutes les valeurs", () => {
    const tables = [
      sexLabels,
      experienceLabels,
      goalLabels,
      activityLabels,
      splitLabels,
      splitRationale,
      muscleLabels,
    ];
    for (const table of tables) {
      const keys = Object.keys(table.fr).sort();
      for (const language of languages) {
        expect(Object.keys(table[language]).sort()).toEqual(keys);
        for (const key of keys) {
          const value = (table[language] as Record<string, string | undefined>)[key];
          expect(value?.length ?? 0).toBeGreaterThan(0);
        }
      }
    }
  });

  test("les justifications de structure sont réellement traduites", () => {
    for (const key of Object.keys(splitRationale.fr) as (keyof typeof splitRationale.fr)[]) {
      expect(splitRationale.en[key]).not.toBe(splitRationale.fr[key]);
      expect(splitRationale.es[key]).not.toBe(splitRationale.fr[key]);
    }
  });
});

describe("Justifications du simulateur", () => {
  test("chaque justification produite est disponible dans les trois langues", () => {
    const result = simulate(defaultInput);
    const lines = [...result.nutrition.rationale, ...result.volume.rationale];
    expect(lines.length).toBeGreaterThan(0);
    for (const line of lines) {
      for (const language of languages as readonly Language[]) {
        expect(line[language].length).toBeGreaterThan(10);
      }
      expect(line.en).not.toBe(line.fr);
      expect(line.es).not.toBe(line.fr);
    }
  });

  test("les nombres suivent la langue : virgule en français, point en anglais", () => {
    const cut = simulate({ ...defaultInput, goal: "fatLoss" });
    const deficit = cut.nutrition.rationale[0]!;
    expect(deficit.fr).toMatch(/\d,\d/);
    expect(deficit.en).toMatch(/\d\.\d/);
  });
});
