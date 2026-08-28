import { endonyms, languages, useLanguage, useSetLanguage } from "../i18n/language.tsx";

const label = {
  fr: "Choisir la langue",
  en: "Choose the language",
  es: "Elegir el idioma",
} as const;

/** Le sélecteur de langue, dans l'en-tête et dans le pied de page. */
export function LanguageSwitcher({ compact = false }: { compact?: boolean }) {
  const language = useLanguage();
  const setLanguage = useSetLanguage();

  return (
    <div
      className={compact ? "lang lang--compact" : "lang"}
      role="group"
      aria-label={label[language]}
    >
      {languages.map((code) => (
        <button
          key={code}
          type="button"
          className={code === language ? "lang__option lang__option--active" : "lang__option"}
          aria-pressed={code === language}
          lang={code}
          onClick={() => setLanguage(code)}
        >
          {compact ? code.toUpperCase() : endonyms[code]}
        </button>
      ))}
    </div>
  );
}
