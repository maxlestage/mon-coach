import type { ReactNode } from "react";
import { Footer } from "./Footer.tsx";
import { Header } from "./Header.tsx";

/**
 * L'habillage commun à toutes les pages : en-tête, contenu, pied de page.
 * Les pages légales et la page d'accueil partagent exactement le même cadre,
 * pour que quitter l'accueil ne donne jamais l'impression de changer de site.
 */
export function SiteChrome({ children }: { children: ReactNode }) {
  return (
    <>
      <Header />
      <main>{children}</main>
      <Footer />
    </>
  );
}

/** Gabarit d'une page de contenu : titre, date, prose. */
export function ContentPage({
  eyebrow,
  title,
  updated,
  children,
}: {
  eyebrow: string;
  title: string;
  updated: string;
  children: ReactNode;
}) {
  return (
    <section className="section section--flush legal">
      <div className="shell">
        <span className="section__eyebrow">{eyebrow}</span>
        <h1 className="section__title">{title}</h1>
        <p className="legal__updated">Dernière mise à jour : {updated}</p>
        <div className="legal__body">{children}</div>
      </div>
    </section>
  );
}
