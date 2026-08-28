import { adaptations } from "../data/content.ts";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Ce qui change chaque semaine",
    title: "Un programme figé cesse d'être bon au bout de trois semaines",
    lede: "Chaque semaine, le coach compare ce qui était prévu à ce que tu as réellement fait : séances terminées, séries bouclées, difficulté ressentie, courbe de poids, douleurs signalées, sorties enregistrées. Puis il change le plan — pour de vrai, pas dans un message d'encouragement.",
  },
  en: {
    eyebrow: "What changes every week",
    title: "A frozen programme stops being good after three weeks",
    lede: "Every week the coach compares what was planned to what you actually did: sessions finished, sets completed, perceived effort, weight trend, reported pain, runs recorded. Then it changes the plan — for real, not in an encouraging message.",
  },
  es: {
    eyebrow: "Lo que cambia cada semana",
    title: "Un programa congelado deja de ser bueno a las tres semanas",
    lede: "Cada semana el entrenador compara lo previsto con lo que has hecho de verdad: sesiones terminadas, series completadas, esfuerzo percibido, curva de peso, dolores señalados, rodajes registrados. Y entonces cambia el plan, de verdad, no en un mensaje de ánimo.",
  },
} as const;

export function AdaptationSection() {
  const t = useCopy(copy);
  const items = useCopy(adaptations);

  return (
    <section className="section" id="adaptation">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="grid grid--3">
          {items.map((item) => (
            <article className="card" key={item.title}>
              <h3 className="card__title">{item.title}</h3>
              <p className="card__body">{item.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
