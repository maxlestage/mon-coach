import {
  demoDistanceMeters,
  demoElevationGain,
  demoSeconds,
  demoSplits,
} from "../data/demo-run.ts";
import { useCopy, useLanguage } from "../i18n/language.tsx";
import { RunMap } from "./RunMap.tsx";

const copy = {
  fr: {
    eyebrow: "Course à pied",
    title: "Le même coach, en dehors de la salle",
    lede: "Si tu cours, Stride construit un bloc de course en même temps que le bloc de musculation — et les fait tenir ensemble. Le volume monte semaine après semaine vers un pic plafonné à 1,6 fois ton point de départ — au-delà, on promettrait une progression que le tendon ne suit pas — une semaine sur quatre redescend, et les sorties dures sont écartées de tes jours de jambes. Le GPS mesure la sortie ; toute la mesure est faite sur le téléphone.",
    distance: "Distance",
    duration: "Durée",
    pace: "Allure moyenne",
    elevation: "Dénivelé +",
    splitsTitle: "Chaque kilomètre",
    splitsNote: "La barre est pleine pour le kilomètre le plus rapide : comparer les kilomètres entre eux dit bien plus que les comparer à une allure absolue.",
    points: [
      {
        title: "Une trace qui garde ce qu'elle peut, et dit le reste",
        body: "Un point flou n'est pas un point faux. En ville entre les immeubles, le téléphone annonce couramment quarante mètres de précision sur des points parfaitement corrects : les jeter effaçait des tronçons entiers de sortie réelle. Ils sont maintenant gardés et comptés, et signalés quand ils portent plus d'un cinquième de la mesure. Au-delà de cent mètres, ou sur un saut impossible, le point part — et il est compté, pour qu'une sortie qui annonce 8,2 km au lieu de 9 te dise pourquoi au lieu de te laisser croire que tu as ralenti.",
      },
      {
        title: "Un dénivelé qui n'invente rien",
        body: "L'altitude est lissée, puis le dénivelé s'accumule par hystérésis. Un cumul naïf transformerait un bruit de ±1 m en plusieurs centaines de mètres de D+ imaginaires sur une heure de course.",
      },
      {
        title: "L'allure de seuil se recale seule",
        body: "Un tempo, un fractionné ou une course chronométrée plus rapide que ta référence la remplace, et toutes les allures prescrites sont recalculées dessus. Un footing lent, lui, ne compte pas : il ne dit rien de ton plafond.",
      },
      {
        title: "Une projection, pas une promesse",
        body: "Le modèle de Riegel donne un temps de course probable à partir de ton allure de seuil. Il ne connaît ni le vent, ni le dénivelé, ni ton sommeil de la veille, et l'application le dit à côté du chiffre.",
      },
    ],
  },
  en: {
    eyebrow: "Running",
    title: "The same coach, outside the gym",
    lede: "If you run, Stride builds a running block alongside the lifting block — and makes the two fit together. Volume climbs week after week towards a peak capped at 1.6 times your starting point — beyond that you would be promising progress the tendon cannot follow — one week in four steps back, and hard runs are kept off your leg days. GPS measures the run; all of the measuring happens on the phone.",
    distance: "Distance",
    duration: "Duration",
    pace: "Average pace",
    elevation: "Elevation +",
    splitsTitle: "Every kilometre",
    splitsNote: "The bar is full for the fastest kilometre: comparing the splits to each other says far more than comparing them to an absolute pace.",
    points: [
      {
        title: "A trace that keeps what it can, and says the rest",
        body: "A fuzzy point is not a false one. In a city, between buildings, the phone routinely reports forty metres of accuracy on perfectly correct points: throwing them away erased whole stretches of a real run. They are now kept and counted, and flagged when they carry more than a fifth of the measurement. Past a hundred metres, or on an impossible jump, the point goes — and it is counted, so that a run reading 8.2 km instead of 9 tells you why rather than letting you believe you slowed down.",
      },
      {
        title: "Elevation that invents nothing",
        body: "Altitude is smoothed, then gain accumulates through hysteresis. A naive sum would turn ±1 m of noise into several hundred imaginary metres of climbing over an hour of running.",
      },
      {
        title: "Threshold pace recalibrates itself",
        body: "A tempo, an interval session or a timed race faster than your reference replaces it, and every prescribed pace is recalculated from there. A slow easy run does not count: it says nothing about your ceiling.",
      },
      {
        title: "A projection, not a promise",
        body: "Riegel's model gives a likely race time from your threshold pace. It knows nothing about wind, elevation or how you slept the night before, and the app says so next to the number.",
      },
    ],
  },
  es: {
    eyebrow: "Carrera a pie",
    title: "El mismo entrenador, fuera del gimnasio",
    lede: "Si corres, Stride construye un bloque de carrera junto al de fuerza, y hace que encajen. El volumen sube semana tras semana hacia un pico limitado a 1,6 veces tu punto de partida —más allá se prometería un progreso que el tendón no sigue—, una semana de cada cuatro baja, y las sesiones duras se apartan de tus días de pierna. El GPS mide el rodaje; toda la medición ocurre en el teléfono.",
    distance: "Distancia",
    duration: "Duración",
    pace: "Ritmo medio",
    elevation: "Desnivel +",
    splitsTitle: "Cada kilómetro",
    splitsNote: "La barra está llena en el kilómetro más rápido: comparar los parciales entre sí dice mucho más que compararlos con un ritmo absoluto.",
    points: [
      {
        title: "Una traza que conserva lo que puede, y dice el resto",
        body: "Un punto borroso no es un punto falso. En ciudad, entre edificios, el teléfono anuncia habitualmente cuarenta metros de precisión sobre puntos perfectamente correctos: descartarlos borraba tramos enteros de un rodaje real. Ahora se conservan y se cuentan, y se señalan cuando sostienen más de una quinta parte de la medición. Más allá de cien metros, o ante un salto imposible, el punto se va — y se cuenta, para que un rodaje que marca 8,2 km en lugar de 9 te diga por qué en vez de dejarte creer que has ido más lento.",
      },
      {
        title: "Un desnivel que no se inventa nada",
        body: "La altitud se suaviza y luego el desnivel se acumula por histéresis. Una suma ingenua convertiría un ruido de ±1 m en varios cientos de metros de desnivel imaginario en una hora de carrera.",
      },
      {
        title: "El ritmo de umbral se recalibra solo",
        body: "Un tempo, unas series o una carrera cronometrada más rápida que tu referencia la sustituye, y todos los ritmos prescritos se recalculan a partir de ahí. Un rodaje suave no cuenta: no dice nada de tu techo.",
      },
      {
        title: "Una proyección, no una promesa",
        body: "El modelo de Riegel da un tiempo probable de carrera a partir de tu ritmo de umbral. No sabe nada del viento, del desnivel ni de cómo dormiste la víspera, y la aplicación lo dice junto a la cifra.",
      },
    ],
  },
} as const;

function formatPace(secondsPerKm: number): string {
  const total = Math.round(secondsPerKm);
  const minutes = Math.floor(total / 60);
  const rest = total % 60;
  return `${minutes}:${String(rest).padStart(2, "0")} /km`;
}

function formatDuration(seconds: number): string {
  const total = Math.round(seconds);
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const rest = total % 60;
  return hours > 0
    ? `${hours}:${String(minutes).padStart(2, "0")}:${String(rest).padStart(2, "0")}`
    : `${minutes}:${String(rest).padStart(2, "0")}`;
}

export function RunningSection() {
  const t = useCopy(copy);
  const language = useLanguage();

  const km = demoDistanceMeters / 1000;
  const decimal = language === "en" ? "." : ",";
  const distance = `${km.toFixed(2).replace(".", decimal)} km`;
  const averagePace = demoSeconds / km;
  const fastest = Math.min(...demoSplits);
  const slowest = Math.max(...demoSplits);

  return (
    <section className="section" id="course">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="running">
          <RunMap />

          <div className="running__panel">
            <div className="readout">
              <div className="readout__item">
                <div className="readout__value">{distance}</div>
                <div className="readout__label">{t.distance}</div>
              </div>
              <div className="readout__item">
                <div className="readout__value">{formatDuration(demoSeconds)}</div>
                <div className="readout__label">{t.duration}</div>
              </div>
              <div className="readout__item">
                <div className="readout__value">{formatPace(averagePace)}</div>
                <div className="readout__label">{t.pace}</div>
              </div>
              <div className="readout__item">
                <div className="readout__value">{demoElevationGain} m</div>
                <div className="readout__label">{t.elevation}</div>
              </div>
            </div>

            <h3 className="running__splits-title">{t.splitsTitle}</h3>
            <div className="bars">
              {demoSplits.map((pace, index) => (
                <div className="bar" key={index}>
                  <span className="bar__name">{index + 1}</span>
                  <span className="bar__track">
                    <span
                      className="bar__fill"
                      style={{
                        width: `${
                          slowest === fastest
                            ? 100
                            : (1 - ((pace - fastest) / (slowest - fastest)) * 0.7) * 100
                        }%`,
                      }}
                    />
                  </span>
                  <span className="bar__value">{formatPace(pace)}</span>
                </div>
              ))}
            </div>
            <p className="field__hint">{t.splitsNote}</p>
          </div>
        </div>

        <div className="grid grid--4" style={{ marginTop: 28 }}>
          {t.points.map((point) => (
            <article className="card" key={point.title}>
              <h3 className="card__title">{point.title}</h3>
              <p className="card__body">{point.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
