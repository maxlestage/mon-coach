import { useState } from "react";
import { examples } from "../data/examples.ts";
import { useCopy, useLanguage } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Fiche exemple",
    title: "Une fiche technique, en entier",
    lede: "Voici exactement ce que l'application affiche quand on ouvre le mode guidé sur un squat barre. Rien n'a été raccourci pour la page : les étapes, les repères et les erreurs sont ceux du produit, exportés du même catalogue.",
    oneThing: "L'essentiel",
    step: "Étape",
    of: "sur",
    checkpoint: "Ce que tu peux vérifier seul",
    previous: "Précédente",
    next: "Suivante",
    breathing: "Respiration",
    tempo: "Tempo",
    easier: "Plus facile",
    harder: "Plus dur",
    mistakes: "Si quelque chose ne va pas",
    cause: "Pourquoi",
    fix: "Ce que tu changes",
  },
  en: {
    eyebrow: "Example sheet",
    title: "A technique sheet, in full",
    lede: "This is exactly what the app shows when you open guided mode on a back squat. Nothing was shortened for the page: the steps, the checkpoints and the mistakes are the product's, exported from the same catalogue.",
    oneThing: "The one thing",
    step: "Step",
    of: "of",
    checkpoint: "What you can verify on your own",
    previous: "Previous",
    next: "Next",
    breathing: "Breathing",
    tempo: "Tempo",
    easier: "Easier",
    harder: "Harder",
    mistakes: "If something feels wrong",
    cause: "Why",
    fix: "What you change",
  },
  es: {
    eyebrow: "Ficha de ejemplo",
    title: "Una ficha técnica, entera",
    lede: "Esto es exactamente lo que muestra la aplicación al abrir el modo guiado en una sentadilla trasera. No se ha acortado nada para la página: los pasos, las referencias y los errores son los del producto, exportados del mismo catálogo.",
    oneThing: "Lo esencial",
    step: "Paso",
    of: "de",
    checkpoint: "Lo que puedes comprobar tú mismo",
    previous: "Anterior",
    next: "Siguiente",
    breathing: "Respiración",
    tempo: "Tempo",
    easier: "Más fácil",
    harder: "Más difícil",
    mistakes: "Si algo no va bien",
    cause: "Por qué",
    fix: "Qué cambias",
  },
} as const;

/**
 * La fiche technique du mode guidé, déroulée comme dans l'application.
 *
 * Le va-et-vient entre les étapes est le geste du produit : on n'avance pas
 * parce qu'une vidéo se termine, on avance quand l'étape est comprise.
 */
export function TechniqueSection() {
  const t = useCopy(copy);
  const language = useLanguage();
  const { technique } = examples;
  const [index, setIndex] = useState(0);

  const step = technique.steps[Math.min(index, technique.steps.length - 1)]!;

  return (
    <section className="section" id="fiche">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="sheet">
          <div className="sheet__main">
            <p className="sheet__eyebrow">{t.oneThing}</p>
            <p className="sheet__one-thing">{technique.oneThing[language]}</p>

            <div className="sheet__step">
              <p className="sheet__step-count">
                {t.step} {step.index} {t.of} {technique.steps.length} — {technique.exercise[language]}
              </p>
              <h3 className="sheet__step-title">{step.title[language]}</h3>
              <p className="sheet__step-detail">{step.detail[language]}</p>

              {step.checkpoint && (
                <div className="sheet__checkpoint">
                  <span className="sheet__checkpoint-label">{t.checkpoint}</span>
                  <p>{step.checkpoint[language]}</p>
                </div>
              )}

              <div className="sheet__nav">
                <button
                  type="button"
                  className="button button--ghost button--small"
                  onClick={() => setIndex((current) => Math.max(0, current - 1))}
                  disabled={index === 0}
                >
                  {t.previous}
                </button>
                <div className="sheet__dots" aria-hidden="true">
                  {technique.steps.map((item, position) => (
                    <span
                      key={item.index}
                      className={position === index ? "sheet__dot sheet__dot--active" : "sheet__dot"}
                    />
                  ))}
                </div>
                <button
                  type="button"
                  className="button button--primary button--small"
                  onClick={() =>
                    setIndex((current) => Math.min(technique.steps.length - 1, current + 1))
                  }
                  disabled={index >= technique.steps.length - 1}
                >
                  {t.next}
                </button>
              </div>
            </div>
          </div>

          <div className="sheet__aside">
            <article className="card">
              <h3 className="card__title">{t.breathing}</h3>
              <p className="card__body">{technique.breathing[language]}</p>
            </article>
            <article className="card">
              <h3 className="card__title">{t.tempo}</h3>
              <p className="card__body">{technique.tempo[language]}</p>
            </article>
            {technique.easier && (
              <article className="card">
                <h3 className="card__title">{t.easier}</h3>
                <p className="card__body">{technique.easier[language]}</p>
              </article>
            )}
            {technique.harder && (
              <article className="card">
                <h3 className="card__title">{t.harder}</h3>
                <p className="card__body">{technique.harder[language]}</p>
              </article>
            )}
          </div>
        </div>

        <h3 className="section__subtitle">{t.mistakes}</h3>
        <div className="grid grid--3">
          {technique.mistakes.map((mistake) => (
            <article className="card card--mistake" key={mistake.symptom.fr}>
              <h4 className="mistake__symptom">{mistake.symptom[language]}</h4>
              <p className="mistake__line">
                <span className="mistake__label">{t.cause}</span> {mistake.cause[language]}
              </p>
              <p className="mistake__line mistake__line--fix">
                <span className="mistake__label">{t.fix}</span> {mistake.fix[language]}
              </p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
