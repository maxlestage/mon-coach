import { useCopy } from "../i18n/language.tsx";
import { BrandMark } from "./BrandMark.tsx";
import { LanguageSwitcher } from "./LanguageSwitcher.tsx";

const copy = {
  fr: {
    nav: "Navigation principale",
    profile: "Ce qu'il sait de toi",
    engine: "Le moteur",
    simulator: "Simulateur",
    running: "Course",
    food: "Alimentation",
    gym: "Salle",
    watch: "Montre",
    pricing: "Tarifs",
    faq: "Questions",
    cta: "Essayer le moteur",
  },
  en: {
    nav: "Main navigation",
    profile: "What it knows about you",
    engine: "The engine",
    simulator: "Simulator",
    running: "Running",
    food: "Food",
    gym: "Gym",
    watch: "Watch",
    pricing: "Pricing",
    faq: "Questions",
    cta: "Try the engine",
  },
  es: {
    nav: "Navegación principal",
    profile: "Lo que sabe de ti",
    engine: "El motor",
    simulator: "Simulador",
    running: "Carrera",
    food: "Alimentación",
    gym: "Sala",
    watch: "Reloj",
    pricing: "Precios",
    faq: "Preguntas",
    cta: "Probar el motor",
  },
} as const;

export function Header() {
  const t = useCopy(copy);

  return (
    <header className="site-header">
      <div className="shell site-header__inner">
        <a className="brand" href="/">
          <BrandMark className="brand__mark" size={30} />
          Stride
        </a>
        <nav className="site-nav" aria-label={t.nav}>
          <a href="/#profil">{t.profile}</a>
          <a href="/#moteur">{t.engine}</a>
          <a href="/#simulateur">{t.simulator}</a>
          <a href="/#course">{t.running}</a>
          <a href="/#alimentation">{t.food}</a>
          <a href="/#salle">{t.gym}</a>
          <a href="/#montre">{t.watch}</a>
          <a href="/#tarifs">{t.pricing}</a>
        </nav>
        <div className="site-header__actions">
          <LanguageSwitcher compact />
          <a className="button button--primary button--small" href="/#simulateur">
            {t.cta}
          </a>
        </div>
      </div>
    </header>
  );
}
