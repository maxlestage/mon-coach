import { ContentPage } from "../components/SiteChrome.tsx";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Légal",
    title: "Conditions d'utilisation",
    isTitle: "Ce que Stride est",
    isBody: "Stride est un programmeur d'entraînement : il construit un programme de musculation, un plan de course et des repères nutritionnels à partir des informations que tu fournis, puis les ajuste d'après tes séances et tes sorties. C'est un outil d'aide à l'entraînement, pas un service médical.",
    isNotTitle: "Ce que Stride n'est pas",
    isNotBody1: "L'application ne remplace ni un médecin, ni un kinésithérapeute, ni un diététicien. Ses calculs reposent sur des formules publiées qui produisent des estimations, pas des prescriptions. En cas de douleur persistante, de pathologie, de grossesse ou de traitement en cours, demande un avis professionnel avant de suivre un programme.",
    isNotBody2: "La musculation et la course à pied comportent des risques inhérents. Tu restes seul juge de ce que tu soulèves et de la distance que tu parcours : une charge ou une allure suggérée est une suggestion, et la responsabilité de l'éditeur ne saurait être engagée pour une blessure survenue à l'entraînement.",
    gpsTitle: "Le GPS et la mesure",
    gpsBody: "Les distances, allures et dénivelés sont mesurés à partir du GPS de ton appareil. Leur précision dépend de conditions que l'application ne contrôle pas — couvert végétal, bâtiments, tunnels, matériel. Elle indique les points qu'elle a dû écarter plutôt que de laisser croire à une mesure parfaite, mais ces valeurs restent des estimations et ne conviennent à aucun usage officiel ou compétitif. Il en va de même de la fréquence cardiaque et des zones d'effort : ce sont des repères d'entraînement calculés à partir d'un capteur de poignet et d'une formule d'estimation, pas des mesures médicales.",
    plansTitle: "Formule gratuite et Stride+",
    plansBody1: "La formule gratuite comprend le questionnaire complet, un premier bloc d'entraînement entier — séances, charges et mode guidé compris — et l'enregistrement illimité de tes séances et de tes sorties. La formule Stride+ débloque la suite : adaptation continue, plan de course complet, application montre, Live Activity, courbes de progression. Les achats passent par l'App Store et sont soumis à ses conditions ; gestion et résiliation se font dans les réglages de ton compte Apple, à tout moment.",
    plansBody2: "Tes données ne sont jamais un otage : l'enregistrement des séances, l'historique et l'export complet restent gratuits, formule ou pas.",
    availabilityTitle: "Disponibilité",
    availabilityBody: "L'application fonctionne entièrement hors ligne, à l'exception du fond de carte des sorties. Le site et sa version installable sont fournis « en l'état », sans garantie de disponibilité continue.",
    lawTitle: "Droit applicable",
    lawBody: "Ces conditions sont régies par le droit français. Tout litige relève des tribunaux français compétents, après recherche d'une solution amiable via",
  },
  en: {
    eyebrow: "Legal",
    title: "Terms of use",
    isTitle: "What Stride is",
    isBody: "Stride is a training programmer: it builds a strength programme, a running plan and nutritional targets from the information you provide, then adjusts them from your sessions and your runs. It is a training aid, not a medical service.",
    isNotTitle: "What Stride is not",
    isNotBody1: "The app replaces neither a doctor, nor a physiotherapist, nor a dietitian. Its calculations rest on published formulas that produce estimates, not prescriptions. In case of persistent pain, a condition, pregnancy or ongoing treatment, seek professional advice before following a programme.",
    isNotBody2: "Lifting and running carry inherent risks. You remain the sole judge of what you lift and how far you run: a suggested load or pace is a suggestion, and the publisher cannot be held liable for an injury occurring during training.",
    gpsTitle: "GPS and measurement",
    gpsBody: "Distances, paces and elevation are measured from your device's GPS. Their accuracy depends on conditions the app does not control — tree cover, buildings, tunnels, hardware. It reports the points it had to discard rather than implying a perfect measurement, but these values remain estimates and are not suitable for any official or competitive use. The same goes for heart rate and effort zones: they are training references computed from a wrist sensor and an estimation formula, not medical measurements.",
    plansTitle: "Free plan and Stride+",
    plansBody1: "The free plan includes the full questionnaire, a complete first training block — sessions, loads and guided mode included — and unlimited logging of your sessions and runs. Stride+ unlocks what follows: continuous adaptation, the full running plan, the watch app, Live Activities, progress curves. Purchases go through the App Store and are subject to its terms; management and cancellation happen in your Apple account settings, at any time.",
    plansBody2: "Your data is never a hostage: logging sessions, history and full export stay free, plan or no plan.",
    availabilityTitle: "Availability",
    availabilityBody: "The app works entirely offline, apart from the map background for runs. The site and its installable version are provided \"as is\", with no guarantee of continuous availability.",
    lawTitle: "Governing law",
    lawBody: "These terms are governed by French law. Any dispute falls to the competent French courts, after seeking an amicable solution through",
  },
  es: {
    eyebrow: "Legal",
    title: "Condiciones de uso",
    isTitle: "Lo que Stride es",
    isBody: "Stride es un programador de entrenamiento: construye un programa de fuerza, un plan de carrera y referencias nutricionales a partir de la información que le das, y luego los ajusta según tus sesiones y tus rodajes. Es una herramienta de ayuda al entrenamiento, no un servicio médico.",
    isNotTitle: "Lo que Stride no es",
    isNotBody1: "La aplicación no sustituye a un médico, un fisioterapeuta ni un dietista. Sus cálculos se basan en fórmulas publicadas que producen estimaciones, no prescripciones. En caso de dolor persistente, patología, embarazo o tratamiento en curso, pide consejo profesional antes de seguir un programa.",
    isNotBody2: "La fuerza y la carrera conllevan riesgos inherentes. Tú sigues siendo el único juez de lo que levantas y de la distancia que recorres: una carga o un ritmo sugeridos son una sugerencia, y el editor no puede ser considerado responsable de una lesión ocurrida durante el entrenamiento.",
    gpsTitle: "El GPS y la medición",
    gpsBody: "Las distancias, los ritmos y los desniveles se miden con el GPS de tu dispositivo. Su precisión depende de condiciones que la aplicación no controla: vegetación, edificios, túneles, hardware. Indica los puntos que ha tenido que descartar en lugar de hacer creer en una medición perfecta, pero estos valores siguen siendo estimaciones y no sirven para ningún uso oficial o competitivo. Lo mismo vale para el pulso y las zonas de esfuerzo: son referencias de entrenamiento calculadas a partir de un sensor de muñeca y una fórmula de estimación, no mediciones médicas.",
    plansTitle: "Plan gratuito y Stride+",
    plansBody1: "El plan gratuito incluye el cuestionario completo, un primer bloque de entrenamiento entero —sesiones, cargas y modo guiado incluidos— y el registro ilimitado de tus sesiones y rodajes. Stride+ desbloquea lo que sigue: adaptación continua, plan de carrera completo, aplicación de reloj, Live Activity, curvas de progreso. Las compras pasan por la App Store y están sujetas a sus condiciones; la gestión y la cancelación se hacen en los ajustes de tu cuenta de Apple, en cualquier momento.",
    plansBody2: "Tus datos nunca son un rehén: el registro de sesiones, el historial y la exportación completa siguen siendo gratuitos, con plan o sin él.",
    availabilityTitle: "Disponibilidad",
    availabilityBody: "La aplicación funciona enteramente sin conexión, salvo el fondo de mapa de los rodajes. El sitio y su versión instalable se ofrecen «tal cual», sin garantía de disponibilidad continua.",
    lawTitle: "Derecho aplicable",
    lawBody: "Estas condiciones se rigen por el derecho francés. Cualquier litigio corresponde a los tribunales franceses competentes, tras buscar una solución amistosa a través de",
  },
} as const;

export function Conditions() {
  const t = useCopy(copy);

  return (
    <ContentPage eyebrow={t.eyebrow} title={t.title} updated="28.08.2026" legallyBinding>
      <h2>{t.isTitle}</h2>
      <p>{t.isBody}</p>

      <h2>{t.isNotTitle}</h2>
      <p>{t.isNotBody1}</p>
      <p>{t.isNotBody2}</p>

      <h2>{t.gpsTitle}</h2>
      <p>{t.gpsBody}</p>

      <h2>{t.plansTitle}</h2>
      <p>{t.plansBody1}</p>
      <p>{t.plansBody2}</p>

      <h2>{t.availabilityTitle}</h2>
      <p>{t.availabilityBody}</p>

      <h2>{t.lawTitle}</h2>
      <p>
        {t.lawBody} <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>.
      </p>
    </ContentPage>
  );
}
