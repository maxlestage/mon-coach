import { useMemo, useState } from "react";
import { simulate } from "../coach/engine.ts";
import {
  activityLabels,
  allMuscles,
  experienceLabels,
  goalLabels,
  muscleLabels,
  sexLabels,
  splitLabels,
  splitRationale,
} from "../coach/labels.ts";
import type {
  ActivityLevel,
  ExperienceLevel,
  PrimaryGoal,
  Sex,
  SimulatorInput,
} from "../coach/types.ts";

export const defaultInput: SimulatorInput = {
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

const number = (value: number, decimals = 0): string =>
  value.toFixed(decimals).replace(".", ",");

const signed = (value: number, decimals = 2): string =>
  `${value > 0 ? "+" : ""}${number(value, decimals)}`;

export function Simulator() {
  const [input, setInput] = useState<SimulatorInput>(defaultInput);
  const result = useMemo(() => simulate(input), [input]);

  const set = <K extends keyof SimulatorInput>(
    key: K,
    value: SimulatorInput[K],
  ): void => {
    setInput((current) => ({ ...current, [key]: value }));
  };

  const bars = allMuscles
    .map((muscle) => ({ muscle, sets: result.volume.weeklySets[muscle] }))
    .filter((entry) => entry.sets > 0)
    .sort((a, b) => b.sets - a.sets);
  const maxSets = bars.reduce((max, entry) => Math.max(max, entry.sets), 1);

  return (
    <section className="section" id="simulateur">
      <div className="shell">
        <span className="section__eyebrow">Simulateur</span>
        <h2 className="section__title">
          Le vrai moteur, dans ton navigateur
        </h2>
        <p className="section__lede">
          Ce simulateur exécute le portage exact des calculs de l'application :
          mêmes formules, mêmes seuils, mêmes arrondis. Un test automatique
          compare les deux à chaque modification, et échoue à la moindre
          divergence. Il s'arrête là où l'application a besoin de ton
          historique : le choix des exercices et la progression des charges.
        </p>

        <div className="simulator">
          <div className="panel">
            <Segmented
              label="Sexe"
              options={(["male", "female"] as Sex[]).map((value) => ({
                value,
                label: sexLabels[value],
              }))}
              value={input.sex}
              onChange={(value) => set("sex", value)}
            />

            <Slider
              label="Âge"
              value={input.age}
              min={16}
              max={80}
              step={1}
              format={(value) => `${value} ans`}
              onChange={(value) => set("age", value)}
            />

            <Slider
              label="Taille"
              value={input.heightCm}
              min={140}
              max={210}
              step={1}
              format={(value) => `${value} cm`}
              onChange={(value) => set("heightCm", value)}
            />

            <Slider
              label="Poids"
              value={input.weightKg}
              min={40}
              max={160}
              step={0.5}
              format={(value) => `${number(value, 1)} kg`}
              onChange={(value) => set("weightKg", value)}
            />

            <div className="field">
              <div className="field__head">
                <span className="field__label">Masse grasse</span>
                <span className="field__value">
                  {input.bodyFatPercent === null
                    ? "inconnue"
                    : `${number(input.bodyFatPercent, 1)} %`}
                </span>
              </div>
              <div className="segmented">
                <button
                  type="button"
                  aria-pressed={input.bodyFatPercent === null}
                  onClick={() => set("bodyFatPercent", null)}
                >
                  Je ne sais pas
                </button>
                <button
                  type="button"
                  aria-pressed={input.bodyFatPercent !== null}
                  onClick={() => set("bodyFatPercent", input.bodyFatPercent ?? 16)}
                >
                  Je la connais
                </button>
              </div>
              {input.bodyFatPercent !== null && (
                <input
                  type="range"
                  min={5}
                  max={45}
                  step={0.5}
                  value={input.bodyFatPercent}
                  aria-label="Taux de masse grasse"
                  onChange={(event) =>
                    set("bodyFatPercent", Number(event.target.value))
                  }
                />
              )}
              <p className="field__hint">
                {result.metrics.leanMassIsEstimated
                  ? "Masse maigre estimée par la formule de Boer. Renseigner ton taux fait passer le calcul sur Katch-McArdle, nettement plus fiable."
                  : `Masse maigre mesurée : ${number(result.metrics.leanBodyMassKg, 1)} kg. Les protéines sont calculées dessus.`}
              </p>
            </div>

            <Segmented
              label="Niveau"
              options={(
                ["beginner", "intermediate", "advanced"] as ExperienceLevel[]
              ).map((value) => ({ value, label: experienceLabels[value] }))}
              value={input.experience}
              onChange={(value) => set("experience", value)}
            />

            <Segmented
              label="Objectif"
              options={(
                [
                  "hypertrophy",
                  "strength",
                  "fatLoss",
                  "recomposition",
                  "generalHealth",
                ] as PrimaryGoal[]
              ).map((value) => ({ value, label: goalLabels[value] }))}
              value={input.goal}
              onChange={(value) => set("goal", value)}
            />

            <Slider
              label="Séances par semaine"
              value={input.daysPerWeek}
              min={2}
              max={6}
              step={1}
              format={(value) => `${value} séances`}
              onChange={(value) => set("daysPerWeek", value)}
            />

            <Slider
              label="Durée d'une séance"
              value={input.sessionMinutes}
              min={25}
              max={120}
              step={5}
              format={(value) => `${value} min`}
              onChange={(value) => set("sessionMinutes", value)}
            />

            <Segmented
              label="Activité hors salle"
              options={(
                [
                  "sedentary",
                  "light",
                  "moderate",
                  "high",
                  "veryHigh",
                ] as ActivityLevel[]
              ).map((value) => ({ value, label: activityLabels[value] }))}
              value={input.activityLevel}
              onChange={(value) => set("activityLevel", value)}
            />

            <Slider
              label="Sommeil moyen"
              value={input.sleepHours}
              min={4}
              max={10}
              step={0.5}
              format={(value) => `${number(value, 1)} h`}
              onChange={(value) => set("sleepHours", value)}
            />

            <Slider
              label="Stress habituel"
              value={input.stressLevel}
              min={1}
              max={5}
              step={1}
              format={(value) => `${value} / 5`}
              onChange={(value) => set("stressLevel", value)}
            />
          </div>

          <div className="panel panel--result">
            <div className="readout">
              <Readout value={`${result.nutrition.calories}`} label="kcal par jour" />
              <Readout value={`${result.nutrition.proteinG} g`} label="protéines" />
              <Readout value={`${result.nutrition.carbsG} g`} label="glucides" />
              <Readout value={`${result.nutrition.fatG} g`} label="lipides" />
            </div>

            <div className="readout" style={{ marginTop: 12 }}>
              <Readout
                value={`${result.volume.total}`}
                label="séries dures par semaine"
              />
              <Readout value={`${result.weekCount}`} label="semaines de bloc" />
              <Readout
                value={`${result.nutrition.maintenanceCalories}`}
                label="maintien estimé"
              />
              <Readout
                value={`${signed(result.nutrition.weeklyWeightChangeKg)} kg`}
                label="objectif hebdomadaire"
              />
            </div>

            <p className="field__hint" style={{ marginTop: 18 }}>
              <strong style={{ color: "var(--text)" }}>
                {splitLabels[result.split]}
              </strong>{" "}
              — {splitRationale[result.split]}
            </p>

            <div className="bars">
              {bars.map((entry) => (
                <div className="bar" key={entry.muscle}>
                  <span className="bar__name">{muscleLabels[entry.muscle]}</span>
                  <span className="bar__track">
                    <span
                      className="bar__fill"
                      style={{ width: `${(entry.sets / maxSets) * 100}%` }}
                    />
                  </span>
                  <span className="bar__value">{entry.sets}</span>
                </div>
              ))}
            </div>

            <ul className="rationale">
              {[...result.nutrition.rationale, ...result.volume.rationale].map(
                (line) => (
                  <li key={line}>{line}</li>
                ),
              )}
            </ul>
          </div>
        </div>

        <p className="disclaimer">
          Ces chiffres sont des estimations issues de formules publiées
          (Mifflin-St Jeor, Katch-McArdle, Boer) et de repères de volume
          couramment utilisés. Ils constituent un point de départ à ajuster
          d'après ce que la balance et la salle te montrent réellement — ce que
          l'application fait automatiquement. Ils ne remplacent pas l'avis d'un
          professionnel de santé.
        </p>
      </div>
    </section>
  );
}

interface SliderProps {
  label: string;
  value: number;
  min: number;
  max: number;
  step: number;
  format: (value: number) => string;
  onChange: (value: number) => void;
}

function Slider({ label, value, min, max, step, format, onChange }: SliderProps) {
  return (
    <div className="field">
      <div className="field__head">
        <span className="field__label">{label}</span>
        <span className="field__value">{format(value)}</span>
      </div>
      <input
        type="range"
        min={min}
        max={max}
        step={step}
        value={value}
        aria-label={label}
        onChange={(event) => onChange(Number(event.target.value))}
      />
    </div>
  );
}

interface SegmentedProps<T extends string> {
  label: string;
  options: Array<{ value: T; label: string }>;
  value: T;
  onChange: (value: T) => void;
}

function Segmented<T extends string>({
  label,
  options,
  value,
  onChange,
}: SegmentedProps<T>) {
  return (
    <div className="field">
      <div className="field__head">
        <span className="field__label">{label}</span>
      </div>
      <div className="segmented" role="group" aria-label={label}>
        {options.map((option) => (
          <button
            type="button"
            key={option.value}
            aria-pressed={option.value === value}
            onClick={() => onChange(option.value)}
          >
            {option.label}
          </button>
        ))}
      </div>
    </div>
  );
}

function Readout({ value, label }: { value: string; label: string }) {
  return (
    <div className="readout__item">
      <div className="readout__value">{value}</div>
      <div className="readout__label">{label}</div>
    </div>
  );
}
