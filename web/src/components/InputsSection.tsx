import { inputGroups } from "../data/content.ts";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Ce qu'il sait de toi",
    title: "Chaque question change quelque chose de concret",
    lede: "Le questionnaire d'inscription ne collecte rien « au cas où ». Chaque réponse entre dans un calcul précis, et l'application te dit lequel au moment où elle te la pose.",
  },
  en: {
    eyebrow: "What it knows about you",
    title: "Every question changes something concrete",
    lede: "The onboarding questionnaire collects nothing \"just in case\". Every answer feeds a specific calculation, and the app tells you which one at the moment it asks.",
  },
  es: {
    eyebrow: "Lo que sabe de ti",
    title: "Cada pregunta cambia algo concreto",
    lede: "El cuestionario de registro no recoge nada «por si acaso». Cada respuesta entra en un cálculo preciso, y la aplicación te dice cuál en el momento en que te la hace.",
  },
} as const;

export function InputsSection() {
  const t = useCopy(copy);
  const groups = useCopy(inputGroups);

  return (
    <section className="section" id="profil">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="grid grid--4">
          {groups.map((group) => (
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
