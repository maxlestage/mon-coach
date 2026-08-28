import { useCopy } from "../i18n/language.tsx";

interface Row {
  readonly feature: string;
  readonly detail: string;
  readonly included: boolean;
}

const copy = {
  fr: {
    eyebrow: "Analyse",
    title: "L'analyse de Strava. Sans le compte, sans le serveur.",
    lede: "Records personnels, segments, allure corrigée du dénivelé, zones cardiaques, carte de chaleur, journal, GPX : tout ce qu'un athlète seul demande à Strava se calcule très bien sur un téléphone. La partie sociale, elle, exige un serveur — alors elle n'existe pas ici, et c'est un choix, pas un manque de temps.",
    hasTitle: "Ce que l'application fait",
    has: [
      { feature: "Records personnels", detail: "Meilleurs 400 m, 1 km, mile, 5 km, 10 km, semi et marathon — cherchés à l'intérieur de chaque sortie : ton meilleur 5 km est presque toujours un morceau d'un 10 km.", included: true },
      { feature: "Segments — toi contre toi", detail: "Découpe ta côte dans une sortie passée ; chaque passage suivant est reconnu, chronométré et classé. Le même terrain, c'est la seule comparaison honnête.", included: true },
      { feature: "Allure corrigée du dénivelé", detail: "Ce que ta sortie vallonnée vaut sur du plat, d'après les mesures de référence du coût de la pente (Minetti 2002).", included: true },
      { feature: "Cardio et zones", detail: "Fréquence en direct au poignet, cinq zones, temps par zone et charge d'entraînement — avec les trous de capteur traités comme des trous, pas comme des données.", included: true },
      { feature: "Multi-sport", detail: "Course, trail, vélo, marche, randonnée — chacun avec ses propres seuils GPS. Une sortie vélo n'a jamais le droit de gonfler ton plan de course.", included: true },
      { feature: "Carte de chaleur et journal", detail: "Tous tes parcours en une image, tes semaines, ta série, ton bilan annuel — calculés sur l'appareil. L'agrégat de tes trajets, c'est ton domicile et tes habitudes : il ne part nulle part.", included: true },
      { feature: "Import et export GPX", detail: "Ton historique entre et sort dans le format que tout le monde parle. Un produit sans compte qui enfermerait tes données serait une prison avec de beaux principes.", included: true },
    ],
    hasNotTitle: "Ce qu'elle ne fera pas",
    hasNot: [
      { feature: "Flux, abonnés, kudos", detail: "Un fil social exige un serveur qui voit tes sorties. La promesse d'ici — rien ne quitte ton appareil — pèse plus lourd qu'un pouce levé.", included: false },
      { feature: "Classements mondiaux de segments", detail: "Se comparer au monde entier demande d'envoyer tes traces au monde entier. Tu te compares à la seule personne qui court sur ton terrain avec tes jambes : toi.", included: false },
    ],
    verdict: "Si le fil social est ce que tu cherches, Strava le fait très bien. Si c'est l'analyse — et tes trajets qui restent chez toi — elle est ici, en entier.",
  },
  en: {
    eyebrow: "Analysis",
    title: "Strava's analysis. Without the account, without the server.",
    lede: "Personal records, segments, grade-adjusted pace, heart-rate zones, heatmap, training log, GPX: everything a solo athlete asks of Strava computes perfectly well on a phone. The social half requires a server — so it does not exist here, and that is a choice, not a lack of time.",
    hasTitle: "What the app does",
    has: [
      { feature: "Personal records", detail: "Best 400 m, 1 km, mile, 5K, 10K, half and marathon — found inside each activity: your best 5K is almost always a slice of a 10K.", included: true },
      { feature: "Segments — you against you", detail: "Carve your climb out of a past run; every later attempt is recognised, timed and ranked. The same terrain is the only honest comparison.", included: true },
      { feature: "Grade-adjusted pace", detail: "What your hilly run is worth on the flat, from the reference measurements of the cost of slope (Minetti 2002).", included: true },
      { feature: "Heart rate and zones", detail: "Live heart rate at the wrist, five zones, time in zone and training load — with sensor gaps treated as gaps, not as data.", included: true },
      { feature: "Multi-sport", detail: "Run, trail, ride, walk, hike — each with its own GPS thresholds. A bike ride is never allowed to inflate your running plan.", included: true },
      { feature: "Heatmap and log", detail: "All your routes in one image, your weeks, your streak, your yearly totals — computed on the device. The aggregate of your routes is your home and your habits: it goes nowhere.", included: true },
      { feature: "GPX import and export", detail: "Your history comes in and goes out in the format everyone speaks. A product with no account that locked your data in would be a prison with fine principles.", included: true },
    ],
    hasNotTitle: "What it will not do",
    hasNot: [
      { feature: "Feed, followers, kudos", detail: "A social feed requires a server that sees your activities. The promise here — nothing leaves your device — weighs more than a thumbs-up.", included: false },
      { feature: "Global segment leaderboards", detail: "Comparing yourself to the world means sending your traces to the world. You compare against the only person who runs your terrain with your legs: you.", included: false },
    ],
    verdict: "If the social feed is what you want, Strava does it very well. If it's the analysis — and routes that stay home — it is all here.",
  },
  es: {
    eyebrow: "Análisis",
    title: "El análisis de Strava. Sin la cuenta, sin el servidor.",
    lede: "Récords personales, segmentos, ritmo ajustado al desnivel, zonas de pulso, mapa de calor, diario, GPX: todo lo que un atleta solo le pide a Strava se calcula perfectamente en un teléfono. La mitad social exige un servidor — así que aquí no existe, y es una elección, no falta de tiempo.",
    hasTitle: "Lo que hace la aplicación",
    has: [
      { feature: "Récords personales", detail: "Mejores 400 m, 1 km, milla, 5 km, 10 km, media y maratón — buscados dentro de cada salida: tu mejor 5 km casi siempre es un trozo de un 10 km.", included: true },
      { feature: "Segmentos: tú contra ti", detail: "Recorta tu cuesta de una salida pasada; cada intento posterior se reconoce, se cronometra y se clasifica. El mismo terreno es la única comparación honesta.", included: true },
      { feature: "Ritmo ajustado al desnivel", detail: "Lo que vale tu salida con cuestas en llano, según las mediciones de referencia del coste de la pendiente (Minetti 2002).", included: true },
      { feature: "Pulso y zonas", detail: "Pulso en directo en la muñeca, cinco zonas, tiempo por zona y carga de entrenamiento — con los huecos del sensor tratados como huecos, no como datos.", included: true },
      { feature: "Multideporte", detail: "Carrera, trail, bici, caminata, senderismo — cada uno con sus propios umbrales GPS. Una salida en bici nunca puede inflar tu plan de carrera.", included: true },
      { feature: "Mapa de calor y diario", detail: "Todos tus recorridos en una imagen, tus semanas, tu racha, tu balance anual — calculados en el dispositivo. El agregado de tus rutas es tu casa y tus costumbres: no va a ninguna parte.", included: true },
      { feature: "Importar y exportar GPX", detail: "Tu historial entra y sale en el formato que todos hablan. Un producto sin cuenta que encerrara tus datos sería una cárcel con bonitos principios.", included: true },
    ],
    hasNotTitle: "Lo que no hará",
    hasNot: [
      { feature: "Muro, seguidores, kudos", detail: "Un muro social exige un servidor que ve tus salidas. La promesa de aquí — nada sale de tu dispositivo — pesa más que un pulgar arriba.", included: false },
      { feature: "Clasificaciones mundiales de segmentos", detail: "Compararte con el mundo implica enviar tus trazas al mundo. Te comparas con la única persona que corre tu terreno con tus piernas: tú.", included: false },
    ],
    verdict: "Si lo que buscas es el muro social, Strava lo hace muy bien. Si es el análisis — y rutas que se quedan en casa — está todo aquí.",
  },
} as const;

/** La comparaison à Strava, dite franchement dans les deux sens. */
export function AnalysisSection() {
  const t = useCopy(copy);

  return (
    <section className="section" id="analyse">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <h3 className="section__subtitle">{t.hasTitle}</h3>
        <div className="grid grid--2">
          {t.has.map((row: Row) => (
            <article key={row.feature} className="analysis__row analysis__row--has">
              <h4>{row.feature}</h4>
              <p>{row.detail}</p>
            </article>
          ))}
        </div>

        <h3 className="section__subtitle">{t.hasNotTitle}</h3>
        <div className="grid grid--2">
          {t.hasNot.map((row: Row) => (
            <article key={row.feature} className="analysis__row analysis__row--not">
              <h4>{row.feature}</h4>
              <p>{row.detail}</p>
            </article>
          ))}
        </div>

        <p className="analysis__verdict">{t.verdict}</p>
      </div>
    </section>
  );
}
