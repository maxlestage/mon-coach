import { inputGroups } from "../data/content.ts";

export function InputsSection() {
  return (
    <section className="section" id="profil">
      <div className="shell">
        <span className="section__eyebrow">Ce qu'il sait de toi</span>
        <h2 className="section__title">
          Chaque question change quelque chose de concret
        </h2>
        <p className="section__lede">
          Le questionnaire d'inscription ne collecte rien « au cas où ». Chaque
          réponse entre dans un calcul précis, et l'application te dit lequel
          au moment où elle te la pose.
        </p>

        <div className="grid grid--4">
          {inputGroups.map((group) => (
            <article className="card" key={group.title}>
              <h3 className="card__title">{group.title}</h3>
              <p className="card__body">{group.body}</p>
              <ul className="card__list">
                {group.items.map((item) => (
                  <li className="chip" key={item}>
                    {item}
                  </li>
                ))}
              </ul>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
