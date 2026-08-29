import type { SimulatorResult } from "../coach/types.ts";
import { splitLabels } from "../coach/labels.ts";
import { useCopy, useLanguage } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Application iOS native",
    titleStart: "Un coach de musculation et de course qui s'adapte à toi,",
    titleEm: "pas l'inverse",
    lede: "Stride part de ton corps, de ton matériel, de tes articulations fragiles et du temps que tu as vraiment. Il en tire un programme complet — séries, exercices, charges, sorties, repas — puis le réécrit chaque semaine à partir de ce que tu as réellement fait.",
    ctaPrimary: "Voir mon programme en 10 secondes",
    ctaGhost: "Comment ça marche",
    note: "Aucun compte. Aucun serveur. Tout est calculé sur ton téléphone.",
    screenAria: "Aperçu de l'écran du jour dans l'application Stride",
    day: "Aujourd'hui · semaine 2",
    session: "Haut du corps",
    readiness: "Forme du jour",
    sessionRow: "Séance",
    scheduled: "Au programme",
    calories: "Calories",
    protein: "Protéines",
    structure: "Structure",
    start: "Démarrer la séance",
    exercises: ["Développé couché", "Traction supination", "Développé militaire", "Écarté à la poulie", "Face pull"],
  },
  en: {
    eyebrow: "Native iOS app",
    titleStart: "A strength and running coach that adapts to you,",
    titleEm: "not the other way round",
    lede: "Stride starts from your body, your equipment, your fragile joints and the time you actually have. It builds a complete programme from that — sets, exercises, loads, runs, meals — then rewrites it every week from what you really did.",
    ctaPrimary: "See my programme in 10 seconds",
    ctaGhost: "How it works",
    note: "No account. No server. Everything is computed on your phone.",
    screenAria: "Preview of the today screen in the Stride app",
    day: "Today · week 2",
    session: "Upper body",
    readiness: "Readiness",
    sessionRow: "Session",
    scheduled: "Scheduled",
    calories: "Calories",
    protein: "Protein",
    structure: "Structure",
    start: "Start the session",
    exercises: ["Bench press", "Chin-up", "Overhead press", "Cable fly", "Face pull"],
  },
  es: {
    eyebrow: "Aplicación iOS nativa",
    titleStart: "Un entrenador de fuerza y carrera que se adapta a ti,",
    titleEm: "no al revés",
    lede: "Stride parte de tu cuerpo, tu material, tus articulaciones frágiles y el tiempo que tienes de verdad. Con eso construye un programa completo —series, ejercicios, cargas, rodajes, comidas— y lo reescribe cada semana a partir de lo que has hecho realmente.",
    ctaPrimary: "Ver mi programa en 10 segundos",
    ctaGhost: "Cómo funciona",
    note: "Sin cuenta. Sin servidor. Todo se calcula en tu teléfono.",
    screenAria: "Vista previa de la pantalla del día en la aplicación Stride",
    day: "Hoy · semana 2",
    session: "Tren superior",
    readiness: "Forma del día",
    sessionRow: "Sesión",
    scheduled: "Programada",
    calories: "Calorías",
    protein: "Proteína",
    structure: "Estructura",
    start: "Empezar la sesión",
    exercises: ["Press de banca", "Dominada supina", "Press militar", "Aperturas en polea", "Face pull"],
  },
} as const;

interface HeroProps {
  preview: SimulatorResult;
}

export function Hero({ preview }: HeroProps) {
  const t = useCopy(copy);
  const language = useLanguage();

  return (
    <section className="hero" id="top">
      <div className="shell hero__grid">
        <div>
          <span className="section__eyebrow">{t.eyebrow}</span>
          <h1 className="hero__title">
            {t.titleStart} <em>{t.titleEm}</em>.
          </h1>
          <p className="hero__lede">{t.lede}</p>
          <div className="hero__actions">
            <a className="button button--primary" href="#simulateur">
              {t.ctaPrimary}
            </a>
            <a className="button button--ghost" href="#moteur">
              {t.ctaGhost}
            </a>
          </div>
          <p className="hero__note">{t.note}</p>
        </div>

        <div className="phone" role="img" aria-label={t.screenAria}>
          <div className="phone__screen">
            <span className="phone__label">{t.day}</span>
            <span className="phone__title">{t.session}</span>

            <div className="phone__card">
              <div className="phone__row">
                <span>{t.readiness}</span>
                <span>78 / 100</span>
              </div>
              <div className="phone__row">
                <span>{t.sessionRow}</span>
                <span>{t.scheduled}</span>
              </div>
            </div>

            <div className="phone__card">
              {t.exercises.map((name, index) => (
                <div className="phone__row" key={name}>
                  <span>{name}</span>
                  <span>{["4 × 6–12", "4 × 6–12", "3 × 6–10", "2 × 10–12", "2 × 12"][index]}</span>
                </div>
              ))}
            </div>

            <div className="phone__card">
              <div className="phone__row">
                <span>{t.calories}</span>
                <span>{preview.nutrition.calories} kcal</span>
              </div>
              <div className="phone__row">
                <span>{t.protein}</span>
                <span>{preview.nutrition.proteinG} g</span>
              </div>
              <div className="phone__row">
                <span>{t.structure}</span>
                <span>{splitLabels[language][preview.split]}</span>
              </div>
            </div>

            <div className="phone__cta">{t.start}</div>
          </div>
        </div>
      </div>
    </section>
  );
}
