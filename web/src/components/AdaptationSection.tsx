import { adaptations } from "../data/content.ts";

export function AdaptationSection() {
  return (
    <section className="section" id="adaptation">
      <div className="shell">
        <span className="section__eyebrow">Ce qui change chaque semaine</span>
        <h2 className="section__title">
          Un programme figé cesse d'être bon au bout de trois semaines
        </h2>
        <p className="section__lede">
          Chaque semaine, le coach compare ce qui était prévu à ce que tu as
          réellement fait : séances terminées, séries bouclées, difficulté
          ressentie, courbe de poids, douleurs signalées. Puis il change le
          plan — pour de vrai, pas dans un message d'encouragement.
        </p>

        <div className="grid grid--3">
          {adaptations.map((item) => (
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
