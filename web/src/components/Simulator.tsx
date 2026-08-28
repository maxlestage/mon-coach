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
import { useCopy, useLanguage } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Simulateur",
    title: "Le vrai moteur, dans ton navigateur",
    lede: "Ce simulateur exécute le portage exact des calculs de l'application : mêmes formules, mêmes seuils, mêmes arrondis. Un test automatique compare les deux à chaque modification, et échoue à la moindre divergence. Il s'arrête là où l'application a besoin de ton historique : le choix des exercices et la progression des charges.",
    sex: "Sexe",
    age: "Âge",
    years: "ans",
    height: "Taille",
    weight: "Poids",
    bodyFat: "Masse grasse",
    unknown: "inconnue",
    dontKnow: "Je ne sais pas",
    doKnow: "Je la connais",
    bodyFatLabel: "Taux de masse grasse",
    estimated: "Masse maigre estimée par la formule de Boer. Renseigner ton taux fait passer le calcul sur Katch-McArdle, nettement plus fiable.",
    measured: "Masse maigre mesurée",
    proteinNote: "Les protéines sont calculées dessus.",
    level: "Niveau",
    goal: "Objectif",
    sessions: "Séances par semaine",
    sessionsUnit: "séances",
    duration: "Durée d'une séance",
    activity: "Activité hors salle",
    sleep: "Sommeil moyen",
    stress: "Stress habituel",
    kcal: "kcal par jour",
    protein: "protéines",
    carbs: "glucides",
    fat: "lipides",
    hardSets: "séries dures par semaine",
    blockWeeks: "semaines de bloc",
    maintenance: "maintien estimé",
    weeklyGoal: "objectif hebdomadaire",
  },
  en: {
    eyebrow: "Simulator",
    title: "The real engine, in your browser",
    lede: "This simulator runs an exact port of the app's calculations: same formulas, same thresholds, same rounding. An automated test compares the two on every change and fails on the smallest divergence. It stops where the app needs your history: exercise selection and load progression.",
    sex: "Sex",
    age: "Age",
    years: "years",
    height: "Height",
    weight: "Weight",
    bodyFat: "Body fat",
    unknown: "unknown",
    dontKnow: "I don't know",
    doKnow: "I know it",
    bodyFatLabel: "Body-fat percentage",
    estimated: "Lean mass estimated with the Boer formula. Giving your percentage switches the calculation to Katch-McArdle, which is considerably more reliable.",
    measured: "Measured lean mass",
    proteinNote: "Protein is calculated from it.",
    level: "Level",
    goal: "Goal",
    sessions: "Sessions per week",
    sessionsUnit: "sessions",
    duration: "Session length",
    activity: "Activity outside the gym",
    sleep: "Average sleep",
    stress: "Usual stress",
    kcal: "kcal per day",
    protein: "protein",
    carbs: "carbs",
    fat: "fat",
    hardSets: "hard sets per week",
    blockWeeks: "weeks in the block",
    maintenance: "estimated maintenance",
    weeklyGoal: "weekly target",
  },
  es: {
    eyebrow: "Simulador",
    title: "El motor de verdad, en tu navegador",
    lede: "Este simulador ejecuta el port exacto de los cálculos de la aplicación: mismas fórmulas, mismos umbrales, mismos redondeos. Un test automático compara ambos en cada cambio y falla ante la mínima divergencia. Se detiene donde la aplicación necesita tu historial: la elección de ejercicios y la progresión de cargas.",
    sex: "Sexo",
    age: "Edad",
    years: "años",
    height: "Altura",
    weight: "Peso",
    bodyFat: "Grasa corporal",
    unknown: "desconocida",
    dontKnow: "No lo sé",
    doKnow: "La conozco",
    bodyFatLabel: "Porcentaje de grasa corporal",
    estimated: "Masa magra estimada con la fórmula de Boer. Indicar tu porcentaje cambia el cálculo a Katch-McArdle, bastante más fiable.",
    measured: "Masa magra medida",
    proteinNote: "La proteína se calcula sobre ella.",
    level: "Nivel",
    goal: "Objetivo",
    sessions: "Sesiones por semana",
    sessionsUnit: "sesiones",
    duration: "Duración de una sesión",
    activity: "Actividad fuera del gimnasio",
    sleep: "Sueño medio",
    stress: "Estrés habitual",
    kcal: "kcal al día",
    protein: "proteína",
    carbs: "hidratos",
    fat: "grasas",
    hardSets: "series duras por semana",
    blockWeeks: "semanas de bloque",
    maintenance: "mantenimiento estimado",
    weeklyGoal: "objetivo semanal",
  },
} as const;

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
  const t = useCopy(copy);
  const language = useLanguage();

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
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="simulator">
          <div className="panel">
            <Segmented
              label={t.sex}
              options={(["male", "female"] as Sex[]).map((value) => ({
                value,
                label: sexLabels[language][value],
              }))}
              value={input.sex}
              onChange={(value) => set("sex", value)}
            />

            <Slider
              label={t.age}
              value={input.age}
              min={16}
              max={80}
              step={1}
              format={(value) => `${value} ${t.years}`}
              onChange={(value) => set("age", value)}
            />

            <Slider
              label={t.height}
              value={input.heightCm}
              min={140}
              max={210}
              step={1}
              format={(value) => `${value} cm`}
              onChange={(value) => set("heightCm", value)}
            />

            <Slider
              label={t.weight}
              value={input.weightKg}
              min={40}
              max={160}
              step={0.5}
              format={(value) => `${number(value, 1)} kg`}
              onChange={(value) => set("weightKg", value)}
            />

            <div className="field">
              <div className="field__head">
                <span className="field__label">{t.bodyFat}</span>
                <span className="field__value">
                  {input.bodyFatPercent === null
                    ? t.unknown
                    : `${number(input.bodyFatPercent, 1)} %`}
                </span>
              </div>
              <div className="segmented">
                <button
                  type="button"
                  aria-pressed={input.bodyFatPercent === null}
                  onClick={() => set("bodyFatPercent", null)}
                >
                  {t.dontKnow}
                </button>
                <button
                  type="button"
                  aria-pressed={input.bodyFatPercent !== null}
                  onClick={() => set("bodyFatPercent", input.bodyFatPercent ?? 16)}
                >
                  {t.doKnow}
                </button>
              </div>
              {input.bodyFatPercent !== null && (
                <input
                  type="range"
                  min={5}
                  max={45}
                  step={0.5}
                  value={input.bodyFatPercent}
                  aria-label={t.bodyFatLabel}
                  onChange={(event) =>
                    set("bodyFatPercent", Number(event.target.value))
                  }
                />
              )}
              <p className="field__hint">
                {result.metrics.leanMassIsEstimated
                  ? t.estimated
                  : `${t.measured} : ${number(result.metrics.leanBodyMassKg, 1)} kg. ${t.proteinNote}`}
              </p>
            </div>

            <Segmented
              label={t.level}
              options={(
                ["beginner", "intermediate", "advanced"] as ExperienceLevel[]
              ).map((value) => ({ value, label: experienceLabels[language][value] }))}
              value={input.experience}
              onChange={(value) => set("experience", value)}
            />

            <Segmented
              label={t.goal}
              options={(
                [
                  "hypertrophy",
                  "strength",
                  "fatLoss",
                  "recomposition",
                  "generalHealth",
                ] as PrimaryGoal[]
              ).map((value) => ({ value, label: goalLabels[language][value] }))}
              value={input.goal}
              onChange={(value) => set("goal", value)}
            />

            <Slider
              label={t.sessions}
              value={input.daysPerWeek}
              min={2}
              max={6}
              step={1}
              format={(value) => `${value} ${t.sessionsUnit}`}
              onChange={(value) => set("daysPerWeek", value)}
            />

            <Slider
              label={t.duration}
              value={input.sessionMinutes}
              min={25}
              max={120}
              step={5}
              format={(value) => `${value} min`}
              onChange={(value) => set("sessionMinutes", value)}
            />

            <Segmented
              label={t.activity}
              options={(
                [
                  "sedentary",
                  "light",
                  "moderate",
                  "high",
                  "veryHigh",
                ] as ActivityLevel[]
              ).map((value) => ({ value, label: activityLabels[language][value] }))}
              value={input.activityLevel}
              onChange={(value) => set("activityLevel", value)}
            />

            <Slider
              label={t.sleep}
              value={input.sleepHours}
              min={4}
              max={10}
              step={0.5}
              format={(value) => `${number(value, 1)} h`}
              onChange={(value) => set("sleepHours", value)}
            />

            <Slider
              label={t.stress}
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
              <Readout value={`${result.nutrition.calories}`} label={t.kcal} />
              <Readout value={`${result.nutrition.proteinG} g`} label={t.protein} />
              <Readout value={`${result.nutrition.carbsG} g`} label={t.carbs} />
              <Readout value={`${result.nutrition.fatG} g`} label={t.fat} />
            </div>

            <div className="readout" style={{ marginTop: 12 }}>
              <Readout
                value={`${result.volume.total}`}
                label={t.hardSets}
              />
              <Readout value={`${result.weekCount}`} label={t.blockWeeks} />
              <Readout
                value={`${result.nutrition.maintenanceCalories}`}
                label={t.maintenance}
              />
              <Readout
                value={`${signed(result.nutrition.weeklyWeightChangeKg)} kg`}
                label={t.weeklyGoal}
              />
            </div>

            <p className="field__hint" style={{ marginTop: 18 }}>
              <strong style={{ color: "var(--text)" }}>
                {splitLabels[language][result.split]}
              </strong>{" "}
              — {splitRationale[language][result.split]}
            </p>

            <div className="bars">
              {bars.map((entry) => (
                <div className="bar" key={entry.muscle}>
                  <span className="bar__name">{muscleLabels[language][entry.muscle]}</span>
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
                  <li key={line.fr}>{line[language]}</li>
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
