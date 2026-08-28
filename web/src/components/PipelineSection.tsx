import { pipeline } from "../data/content.ts";

export function PipelineSection() {
  return (
    <section className="section" id="moteur">
      <div className="shell">
        <span className="section__eyebrow">Le moteur</span>
        <h2 className="section__title">Six étapes, aucune boîte noire</h2>
        <p className="section__lede">
          Le programme n'est pas pioché dans une bibliothèque de modèles. Il
          est construit à chaque fois, par une suite de décisions dont chacune
          est explicable — et t'est effectivement expliquée dans l'application.
        </p>

        <div className="pipeline">
          {pipeline.map((stage) => (
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
