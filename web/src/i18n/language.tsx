import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from "react";

export type Language = "fr" | "en" | "es";

export const languages: readonly Language[] = ["fr", "en", "es"] as const;

/** Le nom de chaque langue, dans cette langue. Jamais un drapeau : un
 *  drapeau est un pays, pas une langue, et l'espagnol n'appartient pas à
 *  l'Espagne. */
export const endonyms: Record<Language, string> = {
  fr: "Français",
  en: "English",
  es: "Español",
};

/** Le français est la langue d'origine du produit : c'est elle qui sert de
 *  repli quand rien d'autre ne correspond. */
export const defaultLanguage: Language = "fr";

const STORAGE_KEY = "mon-coach.language";

function isLanguage(value: string | null | undefined): value is Language {
  return value === "fr" || value === "en" || value === "es";
}

/** Ne garde que la sous-étiquette primaire : `fr-CA` et `es-419` comptent. */
function primary(tag: string): string {
  return tag.toLowerCase().split(/[-_]/)[0] ?? "";
}

/**
 * La langue à afficher, dans l'ordre des intentions les plus explicites :
 * un paramètre d'URL (un lien partagé), puis un choix déjà fait, puis les
 * préférences du navigateur.
 */
export function detectLanguage(): Language {
  if (typeof window === "undefined") return defaultLanguage;

  const fromQuery = new URLSearchParams(window.location.search).get("lang");
  if (isLanguage(fromQuery)) return fromQuery;

  try {
    const stored = window.localStorage.getItem(STORAGE_KEY);
    if (isLanguage(stored)) return stored;
  } catch {
    // Navigation privée, stockage refusé : on continue sans.
  }

  for (const tag of navigator.languages ?? [navigator.language]) {
    const code = primary(tag);
    if (isLanguage(code)) return code;
  }
  return defaultLanguage;
}

interface LanguageState {
  language: Language;
  setLanguage: (next: Language) => void;
}

const LanguageContext = createContext<LanguageState>({
  language: defaultLanguage,
  setLanguage: () => {},
});

export function LanguageProvider({ children }: { children: ReactNode }) {
  const [language, setLanguageState] = useState<Language>(defaultLanguage);

  // La détection se fait après le premier rendu : le HTML servi est en
  // français, et basculer avant l'hydratation ferait clignoter la page.
  useEffect(() => {
    setLanguageState(detectLanguage());
  }, []);

  useEffect(() => {
    document.documentElement.lang = language;
  }, [language]);

  const setLanguage = useCallback((next: Language) => {
    setLanguageState(next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // Le choix vaudra pour cette visite seulement.
    }
    // L'URL reflète la langue pour que la page reste partageable telle
    // qu'elle est lue, sans ajouter une entrée dans l'historique à chaque
    // bascule.
    const url = new URL(window.location.href);
    if (next === defaultLanguage) {
      url.searchParams.delete("lang");
    } else {
      url.searchParams.set("lang", next);
    }
    window.history.replaceState(null, "", url);
  }, []);

  const value = useMemo(() => ({ language, setLanguage }), [language, setLanguage]);
  return <LanguageContext value={value}>{children}</LanguageContext>;
}

export function useLanguage(): Language {
  return useContext(LanguageContext).language;
}

export function useSetLanguage(): (next: Language) => void {
  return useContext(LanguageContext).setLanguage;
}

/** Un texte du site dans les trois langues. */
export type Translated<T> = Record<Language, T>;

/**
 * Rend le bloc de textes correspondant à la langue courante.
 *
 * Chaque composant garde ses traductions à côté de son balisage plutôt que
 * dans un fichier central : quand on modifie une phrase, les trois versions
 * sont sous les yeux, et il devient difficile d'en oublier une.
 *
 * Le type renvoyé est l'union des trois blocs : une clé oubliée dans une
 * seule langue disparaît de l'union, et le composant refuse de compiler.
 * C'est la même garantie que côté Swift, obtenue autrement.
 */
export function useCopy<T extends Translated<unknown>>(copy: T): T[Language] {
  return copy[useLanguage()];
}
