import { pipeline } from "../data/content.ts";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Le moteur",
    title: "Six étapes, aucune boîte noire",
    lede: "Le programme n'est pas pioché dans une bibliothèque de modèles. Il est construit à chaque fois, par une suite de décisions dont chacune est explicable — et t'est effectivement expliquée dans l'application.",
  },
  en: {
    eyebrow: "The engine",
    title: "Six steps, no black box",
    lede: "The programme is not pulled from a library of templates. It is built each time, through a series of decisions every one of which can be explained — and is in fact explained to you in the app.",
  },
  es: {
    eyebrow: "El motor",
    title: "Seis pasos, ninguna caja negra",
    lede: "El programa no se saca de una biblioteca de plantillas. Se construye cada vez, mediante una serie de decisiones que se pueden explicar una a una, y que la aplicación te explica de verdad.",
  },
} as const;

export function PipelineSection() {
  const t = useCopy(copy);
  const stages = useCopy(pipeline);

  return (
    <section className="section" id="moteur">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="pipeline">
          {stages.map((stage) => (
            <article className="stage" key={stage.index}>
              <div className="stage__index">{stage.index}</div>
              <div>
                <h3 className="stage__title">{stage.title}</h3>
                <p className="stage__body">{stage.body}</p>
                <pre className="stage__detail">{stage.detail}</pre>
              </div>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
