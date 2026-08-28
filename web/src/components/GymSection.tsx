import { examples } from "../data/examples.ts";
import { useCopy, useLanguage } from "../i18n/language.tsx";

interface Situation {
  readonly title: string;
  readonly body: string;
}

const copy = {
  fr: {
    eyebrow: "Coach de salle",
    title: "Le programme suppose une salle vide. La salle, elle, est pleine.",
    lede: "Un rack occupé, une machine en panne, dix-huit heures un mardi : c'est ce qui fait rater une séance, bien plus souvent qu'un mauvais programme. Le coach de salle ne réécrit rien — il dit quoi faire à la place, maintenant.",
    exampleTitle: "Le développé couché est pris. Voilà ce que dit l'application.",
    busy: "Occupé",
    closeness: "Proximité",
    situationsTitle: "Ce que personne ne t'explique en entrant",
    situations: [
      { title: "Fais un tour complet avant de toucher quoi que ce soit", body: "Cinq minutes à repérer où sont les haltères, les racks et les machines de ta séance. Chercher un appareil essoufflé entre deux séries est la meilleure façon de bâcler la suivante." },
      { title: "Personne ne te regarde", body: "C'est la peur qui fait arrêter le plus de gens, et la plus infondée : tout le monde compte ses répétitions ou regarde son téléphone. Un débutant appliqué qui charge léger passe complètement inaperçu." },
      { title: "Partager un poste double sa disponibilité", body: "Deux personnes qui alternent sur le même appareil tiennent exactement dans le temps de repos l'une de l'autre. C'est la solution la plus simple aux heures de pointe, et celle à laquelle on pense le moins." },
      { title: "Savoir rater une répétition avant d'en tenter une", body: "Au squat, les barres de sécurité se règlent juste sous ton point bas : rater devient poser la barre. Au développé couché sans pareur, prends des haltères. Sur une machine, une répétition ratée est sans danger." },
      { title: "Les deux heures à éviter", body: "Entre 17 h et 20 h en semaine, une salle reçoit l'essentiel de sa fréquentation. Décaler d'une heure change complètement l'expérience, et le samedi matin est plus calme qu'on ne le croit." },
      { title: "Les chaussures de running sont le mauvais choix pour les jambes", body: "Une semelle amortissante est faite pour absorber un impact ; sous un squat, elle se compresse de façon irrégulière et te fait perdre l'équilibre. N'importe quelle semelle plate fait mieux." },
    ],
  },
  en: {
    eyebrow: "Gym coach",
    title: "The programme assumes an empty gym. The gym is full.",
    lede: "A busy rack, a broken machine, six p.m. on a Tuesday: that is what makes people miss a session, far more often than a bad programme. The gym coach rewrites nothing — it tells you what to do instead, right now.",
    exampleTitle: "The bench is taken. Here is what the app says.",
    busy: "Taken",
    closeness: "Closeness",
    situationsTitle: "What nobody explains when you walk in",
    situations: [
      { title: "Walk the whole room before you touch anything", body: "Five minutes finding the dumbbells, the racks and the machines your session needs. Hunting for a machine while out of breath between sets is the surest way to rush the next one." },
      { title: "Nobody is watching you", body: "This is the fear that stops the most people, and the least founded: everyone is counting their reps or looking at their phone. A careful beginner lifting light goes completely unnoticed." },
      { title: "Sharing a station doubles its availability", body: "Two people alternating on the same machine fit exactly inside each other's rest. It is the simplest answer to peak hours, and the one nobody thinks of." },
      { title: "Know how to fail a rep before you try one", body: "On the squat, the safety pins sit just below your bottom position: failing becomes setting the bar down. Bench pressing without a spotter, use dumbbells. On a machine, a failed rep is harmless." },
      { title: "The two hours to avoid", body: "Between 5 and 8 p.m. on weekdays a gym takes most of its traffic. Shifting by an hour changes the experience completely, and Saturday morning is quieter than people expect." },
      { title: "Running shoes are the wrong choice for leg day", body: "A cushioned sole is made to absorb impact; under a squat it compresses unevenly and takes your balance with it. Any flat sole does better." },
    ],
  },
  es: {
    eyebrow: "Entrenador de sala",
    title: "El programa supone un gimnasio vacío. El gimnasio está lleno.",
    lede: "Un rack ocupado, una máquina averiada, las seis de la tarde de un martes: eso es lo que hace perder una sesión, mucho más que un mal programa. El entrenador de sala no reescribe nada: dice qué hacer en su lugar, ahora mismo.",
    exampleTitle: "El press de banca está ocupado. Esto es lo que dice la aplicación.",
    busy: "Ocupado",
    closeness: "Cercanía",
    situationsTitle: "Lo que nadie te explica al entrar",
    situations: [
      { title: "Da una vuelta completa antes de tocar nada", body: "Cinco minutos localizando mancuernas, racks y máquinas de tu sesión. Buscar un aparato sin aire entre series es la mejor forma de estropear la siguiente." },
      { title: "Nadie te está mirando", body: "Es el miedo que más gente abandona, y el menos fundado: todos cuentan repeticiones o miran el móvil. Un principiante aplicado que carga ligero pasa totalmente desapercibido." },
      { title: "Compartir un puesto duplica su disponibilidad", body: "Dos personas alternando en la misma máquina caben justo en el descanso de la otra. Es la solución más simple a las horas punta y la que menos se piensa." },
      { title: "Saber fallar una repetición antes de intentarla", body: "En sentadilla, los seguros van justo bajo tu punto más bajo: fallar se convierte en dejar la barra. En press de banca sin ayudante, usa mancuernas. En una máquina, fallar es inofensivo." },
      { title: "Las dos horas que hay que evitar", body: "Entre las 17 y las 20 h entre semana un gimnasio recibe la mayor parte de su afluencia. Desplazarse una hora cambia por completo la experiencia, y el sábado por la mañana está más tranquilo de lo que se cree." },
      { title: "Las zapatillas de running son mala elección para las piernas", body: "Una suela amortiguada está hecha para absorber impactos; bajo una sentadilla se comprime de forma irregular y te quita el equilibrio. Cualquier suela plana funciona mejor." },
    ],
  },
} as const;

export function GymSection() {
  const t = useCopy(copy);
  const language = useLanguage();
  const { substitution } = examples;

  return (
    <section className="section" id="salle">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="obstacle">
          <div className="obstacle__head">
            <h3 className="obstacle__exercise">{substitution.exercise[language]}</h3>
            <span className="obstacle__busy">
              {t.busy} : {substitution.busyEquipment.map((item) => item[language]).join(" + ")}
            </span>
          </div>
          <p className="obstacle__headline">{substitution.headline[language]}</p>
          <p className="obstacle__detail">{substitution.detail[language]}</p>

          <div className="options">
            {substitution.options.map((option) => (
              <article className="option" key={option.name.fr}>
                <div className="option__head">
                  <span className="option__name">{option.name[language]}</span>
                  <span className="option__score" title={t.closeness}>
                    {option.closeness}
                  </span>
                </div>
                <span className="option__equipment">
                  {option.equipment.map((item) => item[language]).join(" + ")}
                </span>
                <p className="option__reason">{option.reason[language]}</p>
              </article>
            ))}
          </div>
        </div>

        <h3 className="section__subtitle">{t.situationsTitle}</h3>
        <div className="grid grid--3">
          {(t.situations as readonly Situation[]).map((situation) => (
            <article className="card" key={situation.title}>
              <h4 className="card__title">{situation.title}</h4>
              <p className="card__body">{situation.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
