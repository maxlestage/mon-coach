import { ContentPage } from "../components/SiteChrome.tsx";

export function MentionsLegales() {
  return (
    <ContentPage eyebrow="Légal" title="Mentions légales" updated="28 août 2026">
      <h2>Éditeur du site</h2>
      <p>
        Ce site et l'application Mon Coach sont édités par{" "}
        <strong>Maxime Nathan Lestage</strong>, qui en est également le
        directeur de la publication.
      </p>
      <p>
        Contact :{" "}
        <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>
      </p>

      <h2>Hébergement</h2>
      <p>
        Le site est hébergé par Heroku, un service de Salesforce, Inc. —
        415 Mission Street, Suite 300, San Francisco, CA 94105, États-Unis
        (<a href="https://www.heroku.com" rel="noopener noreferrer">heroku.com</a>).
      </p>

      <h2>Propriété intellectuelle</h2>
      <p>
        L'ensemble du site, de l'application et de leur contenu — textes,
        interfaces, code, marques et logos — est la propriété exclusive de
        Maxime Nathan Lestage. Tous droits réservés. Toute reproduction ou
        réutilisation, totale ou partielle, sans autorisation écrite préalable
        est interdite.
      </p>

      <h2>Signaler un problème</h2>
      <p>
        Pour signaler un contenu, un bug ou une question relative à ces
        mentions, écris à l'adresse de contact ci-dessus.
      </p>
    </ContentPage>
  );
}
