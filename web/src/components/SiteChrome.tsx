import type { ReactNode } from "react";
import { LanguageProvider, useCopy } from "../i18n/language.tsx";
import { Footer } from "./Footer.tsx";
import { Header } from "./Header.tsx";

const copy = {
  fr: {
    updated: "Dernière mise à jour :",
    authoritative:
      "Cette page est traduite pour ta commodité. En cas de divergence, la version française fait foi : c'est elle qui engage l'éditeur.",
  },
  en: {
    updated: "Last updated:",
    authoritative:
      "This page is translated for your convenience. In case of divergence, the French version prevails: it is the one that binds the publisher.",
  },
  es: {
    updated: "Última actualización:",
    authoritative:
      "Esta página está traducida para tu comodidad. En caso de divergencia, prevalece la versión francesa: es la que vincula al editor.",
  },
} as const;

/**
 * L'habillage commun à toutes les pages : en-tête, contenu, pied de page.
 * Les pages légales et la page d'accueil partagent exactement le même cadre,
 * pour que quitter l'accueil ne donne jamais l'impression de changer de site.
 */
export function SiteChrome({ children }: { children: ReactNode }) {
  return (
    <LanguageProvider>
      <Header />
      <main>{children}</main>
      <Footer />
    </LanguageProvider>
  );
}

/** Gabarit d'une page de contenu : titre, date, prose. */
export function ContentPage({
  eyebrow,
  title,
  updated,
  legallyBinding = false,
  children,
}: {
  eyebrow: string;
  title: string;
  updated: string;
  /** Vrai pour une page dont la version française engage juridiquement. */
  legallyBinding?: boolean;
  children: ReactNode;
}) {
  const t = useCopy(copy);

  return (
    <section className="section section--flush legal">
      <div className="shell">
        <span className="section__eyebrow">{eyebrow}</span>
        <h1 className="section__title">{title}</h1>
        <p className="legal__updated">
          {t.updated} {updated}
        </p>
        {legallyBinding && <p className="legal__notice">{t.authoritative}</p>}
        <div className="legal__body">{children}</div>
      </div>
    </section>
  );
}
