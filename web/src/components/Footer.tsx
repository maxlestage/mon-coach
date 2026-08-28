import { useCopy } from "../i18n/language.tsx";
import { LanguageSwitcher } from "./LanguageSwitcher.tsx";

const copy = {
  fr: {
    tagline:
      "Un coach de musculation et de course qui s'adapte à toi, pas l'inverse. Calculé sur ton appareil, jamais sur un serveur.",
    credit: "Créé et fait par",
    product: "Produit",
    profile: "Ce qu'il sait de toi",
    engine: "Le moteur",
    simulator: "Simulateur",
    running: "Course à pied",
    food: "Alimentation",
    watch: "Apple Watch",
    pricing: "Tarifs",
    app: "Application",
    soonPhone: "iPhone — bientôt sur l'App Store",
    soonWatch: "Apple Watch et Live Activity incluses",
    privacyProduct: "Confidentialité du produit",
    legal: "Légal",
    legalNotice: "Mentions légales",
    privacy: "Politique de confidentialité",
    terms: "Conditions d'utilisation",
    rights: "© 2026 Maxime Nathan Lestage — Tous droits réservés.",
    noCookies:
      "Ce site n'utilise aucun cookie et ne charge aucune ressource externe tant que tu n'ouvres pas la carte de la section course. Il s'installe comme une application et fonctionne hors ligne.",
    disclaimer:
      "Mon Coach n'est pas un dispositif médical et ne remplace ni un médecin, ni un kinésithérapeute, ni un diététicien. En cas de douleur persistante, de pathologie connue, de grossesse ou de traitement en cours, demande un avis professionnel avant de suivre un programme.",
  },
  en: {
    tagline:
      "A strength and running coach that adapts to you, not the other way round. Computed on your device, never on a server.",
    credit: "Created and built by",
    product: "Product",
    profile: "What it knows about you",
    engine: "The engine",
    simulator: "Simulator",
    running: "Running",
    food: "Food",
    watch: "Apple Watch",
    pricing: "Pricing",
    app: "App",
    soonPhone: "iPhone — coming to the App Store",
    soonWatch: "Apple Watch and Live Activity included",
    privacyProduct: "Product privacy",
    legal: "Legal",
    legalNotice: "Legal notice",
    privacy: "Privacy policy",
    terms: "Terms of use",
    rights: "© 2026 Maxime Nathan Lestage — All rights reserved.",
    noCookies:
      "This site uses no cookies and loads no external resource until you open the map in the running section. It installs like an app and works offline.",
    disclaimer:
      "Mon Coach is not a medical device and replaces neither a doctor, nor a physiotherapist, nor a dietitian. In case of persistent pain, a known condition, pregnancy or ongoing treatment, seek professional advice before following a programme.",
  },
  es: {
    tagline:
      "Un entrenador de fuerza y carrera que se adapta a ti, no al revés. Calculado en tu dispositivo, nunca en un servidor.",
    credit: "Creado y hecho por",
    product: "Producto",
    profile: "Lo que sabe de ti",
    engine: "El motor",
    simulator: "Simulador",
    running: "Carrera a pie",
    food: "Alimentación",
    watch: "Apple Watch",
    pricing: "Precios",
    app: "Aplicación",
    soonPhone: "iPhone — próximamente en la App Store",
    soonWatch: "Apple Watch y Live Activity incluidos",
    privacyProduct: "Privacidad del producto",
    legal: "Legal",
    legalNotice: "Aviso legal",
    privacy: "Política de privacidad",
    terms: "Condiciones de uso",
    rights: "© 2026 Maxime Nathan Lestage — Todos los derechos reservados.",
    noCookies:
      "Este sitio no usa cookies ni carga ningún recurso externo hasta que abres el mapa de la sección de carrera. Se instala como una aplicación y funciona sin conexión.",
    disclaimer:
      "Mon Coach no es un dispositivo médico y no sustituye a un médico, un fisioterapeuta ni un dietista. En caso de dolor persistente, patología conocida, embarazo o tratamiento en curso, pide consejo profesional antes de seguir un programa.",
  },
} as const;

/**
 * Le pied de page : la fin de page d'un produit, pas d'une maquette.
 * Quatre colonnes — marque, produit, application, légal — puis la ligne
 * d'auteur, le sélecteur de langue et l'avertissement santé.
 */
export function Footer() {
  const t = useCopy(copy);

  return (
    <footer className="site-footer">
      <div className="shell">
        <div className="site-footer__grid">
          <div className="site-footer__brand">
            <a className="brand" href="/">
              <span className="brand__mark" aria-hidden="true">M</span>
              Mon&nbsp;Coach
            </a>
            <p className="site-footer__tagline">{t.tagline}</p>
            <p className="credit">
              {t.credit} <strong>Maxime Nathan Lestage</strong>
            </p>
            <LanguageSwitcher />
          </div>

          <nav className="site-footer__col" aria-label={t.product}>
            <h3>{t.product}</h3>
            <a href="/#profil">{t.profile}</a>
            <a href="/#moteur">{t.engine}</a>
            <a href="/#simulateur">{t.simulator}</a>
            <a href="/#course">{t.running}</a>
            <a href="/#alimentation">{t.food}</a>
            <a href="/#montre">{t.watch}</a>
            <a href="/#tarifs">{t.pricing}</a>
          </nav>

          <nav className="site-footer__col" aria-label={t.app}>
            <h3>{t.app}</h3>
            <span className="site-footer__soon">{t.soonPhone}</span>
            <span className="site-footer__soon">{t.soonWatch}</span>
            <a href="/#confidentialite-produit">{t.privacyProduct}</a>
          </nav>

          <nav className="site-footer__col" aria-label={t.legal}>
            <h3>{t.legal}</h3>
            <a href="/mentions-legales">{t.legalNotice}</a>
            <a href="/confidentialite">{t.privacy}</a>
            <a href="/conditions">{t.terms}</a>
          </nav>
        </div>

        <div className="site-footer__bottom">
          <span>{t.rights}</span>
          <span>{t.noCookies}</span>
        </div>

        <p className="disclaimer">{t.disclaimer}</p>
      </div>
    </footer>
  );
}
