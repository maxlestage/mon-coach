import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Tarifs",
    title: "Le premier bloc est complet, et gratuit",
    lede: "Pas de démo bridée : la formule gratuite est le vrai coach, pendant tout un bloc d'entraînement. Stride+ débloque la suite — la continuité, le poignet, l'écran verrouillé. Et tes données ne sont jamais un otage : l'historique et l'export restent gratuits, pour toujours.",
    freeName: "Gratuit",
    freePrice: "0 €",
    freePeriod: "pour toujours",
    freeFeatures: [
      "Le questionnaire complet et ton profil",
      "Un premier bloc entier (5 à 6 semaines) : séances, charges autorégulées, décharge",
      "Le mode guidé sur les quatre-vingt-douze mouvements du catalogue",
      "Check-in du jour et séance ajustée à ta forme",
      "Cibles caloriques et macros, expliquées",
      "Enregistrement des séances, des sorties et des pesées, sans limite",
      "Export JSON intégral et effacement — à vie",
    ],
    badge: "Recommandé",
    plusName: "Stride+",
    plusPrice: "14,99 €",
    plusPer: " / mois",
    plusPeriod: "ou 119,99 € par an, soit quatre mois offerts",
    plusFeatures: [
      "Tout le gratuit, évidemment",
      "Les blocs suivants, reconstruits d'après tes séances réelles",
      "Le bilan hebdomadaire : volume, calories, décharge anticipée",
      "Le plan de course complet et la liste de courses de la semaine",
      "L'application Apple Watch, autonome au poignet",
      "Les Live Activity de séance et de sortie",
      "Les courbes de progression : poids, 1RM estimé, allure de seuil",
    ],
    plusNote: "Achat via l'App Store, sans compte à créer. Résiliable à tout moment dans les réglages Apple. À titre de comparaison : une seule séance avec un coach humain coûte plus cher que l'année entière. Jamais de publicité.",
  },
  en: {
    eyebrow: "Pricing",
    title: "The first block is complete, and free",
    lede: "No crippled demo: the free tier is the real coach, for a whole training block. Stride+ unlocks what comes next — continuity, the wrist, the lock screen. And your data is never a hostage: history and export stay free, forever.",
    freeName: "Free",
    freePrice: "€0",
    freePeriod: "forever",
    freeFeatures: [
      "The full questionnaire and your profile",
      "A complete first block (5 to 6 weeks): sessions, autoregulated loads, deload",
      "Guided mode on all ninety-two movements in the catalogue",
      "Daily check-in and a session adjusted to your readiness",
      "Calorie and macro targets, explained",
      "Logging sessions, runs and weigh-ins, without limit",
      "Full JSON export and erasure — for life",
    ],
    badge: "Recommended",
    plusName: "Stride+",
    plusPrice: "€14.99",
    plusPer: " / month",
    plusPeriod: "or €119.99 a year, four months free",
    plusFeatures: [
      "Everything in free, obviously",
      "The following blocks, rebuilt from the sessions you actually did",
      "The weekly review: volume, calories, deload brought forward",
      "The full running plan and the week's shopping list",
      "The Apple Watch app, standalone at the wrist",
      "Session and run Live Activities",
      "Progress curves: weight, estimated 1RM, threshold pace",
    ],
    plusNote: "Purchased through the App Store, with no account to create. Cancel any time in your Apple settings. For comparison: a single session with a human coach costs more than the entire year. Never any advertising.",
  },
  es: {
    eyebrow: "Precios",
    title: "El primer bloque es completo, y gratuito",
    lede: "Nada de demos recortadas: el plan gratuito es el entrenador de verdad, durante un bloque entero. Stride+ desbloquea lo que viene después: la continuidad, la muñeca, la pantalla bloqueada. Y tus datos nunca son un rehén: el historial y la exportación siguen siendo gratis, para siempre.",
    freeName: "Gratis",
    freePrice: "0 €",
    freePeriod: "para siempre",
    freeFeatures: [
      "El cuestionario completo y tu perfil",
      "Un primer bloque entero (5 a 6 semanas): sesiones, cargas autorreguladas, descarga",
      "El modo guiado en los noventa y dos movimientos del catálogo",
      "Check-in del día y sesión ajustada a tu forma",
      "Objetivos de calorías y macros, explicados",
      "Registro de sesiones, rodajes y pesajes, sin límite",
      "Exportación JSON íntegra y borrado — de por vida",
    ],
    badge: "Recomendado",
    plusName: "Stride+",
    plusPrice: "14,99 €",
    plusPer: " / mes",
    plusPeriod: "o 119,99 € al año, cuatro meses de regalo",
    plusFeatures: [
      "Todo lo gratuito, por supuesto",
      "Los bloques siguientes, reconstruidos con tus sesiones reales",
      "El balance semanal: volumen, calorías, descarga adelantada",
      "El plan de carrera completo y la lista de la compra de la semana",
      "La aplicación de Apple Watch, autónoma en la muñeca",
      "Las Live Activity de sesión y de rodaje",
      "Las curvas de progreso: peso, 1RM estimado, ritmo de umbral",
    ],
    plusNote: "Compra a través de la App Store, sin crear cuenta. Cancelable en cualquier momento desde los ajustes de Apple. Como comparación: una sola sesión con un entrenador humano cuesta más que el año entero. Nunca publicidad.",
  },
} as const;

/**
 * La section tarifs : le modèle freemium, énoncé sans détour.
 *
 * Le principe est documenté dans docs/MODELE-ECONOMIQUE.md : le premier bloc
 * complet est gratuit — un vrai coach pendant cinq semaines, pas une démo —
 * et Stride+ débloque la continuité. Les données restent gratuites à vie,
 * parce qu'un export payant contredirait tout ce que la page promet.
 */
export function PricingSection() {
  const t = useCopy(copy);

  return (
    <section className="section" id="tarifs">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="pricing">
          <article className="plan">
            <h3 className="plan__name">{t.freeName}</h3>
            <p className="plan__price">{t.freePrice}</p>
            <p className="plan__period">{t.freePeriod}</p>
            <ul className="plan__features">
              {t.freeFeatures.map((feature) => (
                <li key={feature}>{feature}</li>
              ))}
            </ul>
          </article>

          <article className="plan plan--plus">
            <span className="plan__badge">{t.badge}</span>
            <h3 className="plan__name">{t.plusName}</h3>
            <p className="plan__price">
              {t.plusPrice}
              <span>{t.plusPer}</span>
            </p>
            <p className="plan__period">{t.plusPeriod}</p>
            <ul className="plan__features">
              {t.plusFeatures.map((feature) => (
                <li key={feature}>{feature}</li>
              ))}
            </ul>
            <p className="plan__note">{t.plusNote}</p>
          </article>
        </div>
      </div>
    </section>
  );
}
