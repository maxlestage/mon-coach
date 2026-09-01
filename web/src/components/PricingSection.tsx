import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Tarifs",
    title: "Quatorze jours, tout ouvert",
    lede: "Pas de démo bridée : pendant deux semaines, tu as le produit entier, sans carte à donner et sans rien à demander. Ensuite, Stride+ garde la continuité, le poignet et l'écran verrouillé — et un socle reste gratuit à vie, dont ton bloc en cours. Tes données ne sont jamais un otage : l'historique et l'export restent gratuits, y compris le jour où tu arrêtes de payer.",
    freeName: "Essai puis gratuit",
    freePrice: "14 jours",
    freePeriod: "puis un socle gratuit à vie",
    freeFeatures: [
      "Ensuite et pour toujours : le questionnaire, ton profil et ton bloc en cours jusqu'à sa dernière séance",
      "Quatorze jours avec absolument tout, sans carte bancaire",
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
    title: "Fourteen days, everything open",
    lede: "No crippled demo: for two weeks you get the whole product, with no card to hand over and nothing to ask for. After that, Stride+ keeps continuity, the wrist and the lock screen — and a floor stays free for life, including the block you are in. Your data is never a hostage: history and export stay free, including the day you stop paying.",
    freeName: "Trial, then free",
    freePrice: "14 days",
    freePeriod: "then a free floor for life",
    freeFeatures: [
      "Then and forever: the questionnaire, your profile and your current block down to its last session",
      "Fourteen days with absolutely everything, no credit card",
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
    title: "Catorce días, todo abierto",
    lede: "Nada de demos recortadas: durante dos semanas tienes el producto entero, sin tarjeta y sin pedir nada. Después, Stride+ mantiene la continuidad, la muñeca y la pantalla bloqueada, y queda una base gratis de por vida, incluido el bloque que estás haciendo. Tus datos nunca son un rehén: el historial y la exportación siguen siendo gratis, incluso el día que dejes de pagar.",
    freeName: "Prueba y luego gratis",
    freePrice: "14 días",
    freePeriod: "y luego una base gratis de por vida",
    freeFeatures: [
      "Después y para siempre: el cuestionario, tu perfil y tu bloque actual hasta su última sesión",
      "Catorce días con absolutamente todo, sin tarjeta",
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
 * Quatorze jours avec le produit entier, sans carte bancaire : c'est assez
 * long pour deux semaines pleines d'entraînement, donc pour juger sur pièces
 * plutôt que sur une démonstration amputée. Ensuite Stride+ garde la
 * continuité, et un socle reste gratuit à vie — dont le bloc en cours, qui
 * n'est jamais interrompu au milieu. Les données restent gratuites quoi qu'il
 * arrive, parce qu'un export payant contredirait tout ce que la page promet.
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
