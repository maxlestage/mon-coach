import { ContentPage } from "../components/SiteChrome.tsx";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Légal",
    title: "Mentions légales",
    publisher: "Éditeur du site",
    publisherBody: "Ce site et l'application Stride sont édités par Maxime Nathan Lestage, qui en est également le directeur de la publication.",
    contact: "Contact :",
    hosting: "Hébergement",
    hostingBody: "Le site est hébergé par Heroku, un service de Salesforce, Inc. — 415 Mission Street, Suite 300, San Francisco, CA 94105, États-Unis",
    ip: "Propriété intellectuelle",
    ipBody: "L'ensemble du site, de l'application et de leur contenu — textes, interfaces, code, marques et logos — est la propriété exclusive de Maxime Nathan Lestage. Tous droits réservés. Toute reproduction ou réutilisation, totale ou partielle, sans autorisation écrite préalable est interdite.",
    map: "Données cartographiques",
    mapBody: "Les fonds de carte affichés dans l'application et sur ce site proviennent d'OpenStreetMap et de ses contributeurs, publiés sous licence ODbL. Le tracé de tes sorties, lui, t'appartient et reste sur ton appareil.",
    oss: "Composants tiers",
    ossBody: "Ce site et l'application embarquent des composants libres, reproduits ici avec leurs notices — la minification du code retire les commentaires, elle ne retire pas les obligations :",
    report: "Signaler un problème",
    reportBody: "Pour signaler un contenu, un bug ou une question relative à ces mentions, écris à l'adresse de contact ci-dessus.",
  },
  en: {
    eyebrow: "Legal",
    title: "Legal notice",
    publisher: "Site publisher",
    publisherBody: "This site and the Stride app are published by Maxime Nathan Lestage, who is also the publication director.",
    contact: "Contact:",
    hosting: "Hosting",
    hostingBody: "The site is hosted by Heroku, a Salesforce, Inc. service — 415 Mission Street, Suite 300, San Francisco, CA 94105, United States",
    ip: "Intellectual property",
    ipBody: "The whole of this site, the app and their content — text, interfaces, code, trademarks and logos — is the exclusive property of Maxime Nathan Lestage. All rights reserved. Any reproduction or reuse, in whole or in part, without prior written permission is prohibited.",
    map: "Map data",
    mapBody: "The map backgrounds shown in the app and on this site come from OpenStreetMap and its contributors, published under the ODbL licence. The trace of your runs, on the other hand, belongs to you and stays on your device.",
    oss: "Third-party components",
    ossBody: "This site and the app ship open-source components, whose notices are reproduced here — minification strips comments, not obligations:",
    report: "Reporting a problem",
    reportBody: "To report content, a bug or a question about this notice, write to the contact address above.",
  },
  es: {
    eyebrow: "Legal",
    title: "Aviso legal",
    publisher: "Editor del sitio",
    publisherBody: "Este sitio y la aplicación Stride están editados por Maxime Nathan Lestage, que es también el director de publicación.",
    contact: "Contacto:",
    hosting: "Alojamiento",
    hostingBody: "El sitio está alojado por Heroku, un servicio de Salesforce, Inc. — 415 Mission Street, Suite 300, San Francisco, CA 94105, Estados Unidos",
    ip: "Propiedad intelectual",
    ipBody: "La totalidad del sitio, de la aplicación y de su contenido —textos, interfaces, código, marcas y logotipos— es propiedad exclusiva de Maxime Nathan Lestage. Todos los derechos reservados. Queda prohibida cualquier reproducción o reutilización, total o parcial, sin autorización escrita previa.",
    map: "Datos cartográficos",
    mapBody: "Los fondos de mapa mostrados en la aplicación y en este sitio provienen de OpenStreetMap y sus colaboradores, publicados bajo licencia ODbL. La traza de tus rodajes, en cambio, te pertenece y permanece en tu dispositivo.",
    oss: "Componentes de terceros",
    ossBody: "Este sitio y la aplicación incluyen componentes libres, cuyas notas se reproducen aquí — la minificación elimina comentarios, no obligaciones:",
    report: "Señalar un problema",
    reportBody: "Para señalar un contenido, un error o una duda sobre este aviso, escribe a la dirección de contacto de arriba.",
  },
} as const;

export function MentionsLegales() {
  const t = useCopy(copy);

  return (
    <ContentPage eyebrow={t.eyebrow} title={t.title} updated="28.08.2026" legallyBinding>
      <h2>{t.publisher}</h2>
      <p>{t.publisherBody}</p>
      <p>
        {t.contact} <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>
      </p>

      <h2>{t.hosting}</h2>
      <p>
        {t.hostingBody} (
        <a href="https://www.heroku.com" rel="noopener noreferrer">
          heroku.com
        </a>
        ).
      </p>

      <h2>{t.ip}</h2>
      <p>{t.ipBody}</p>

      <h2>{t.map}</h2>
      <p>{t.mapBody}</p>

      <h2>{t.oss}</h2>
      <p>{t.ossBody}</p>
      <ul>
        <li>
          MapLibre GL JS — © 2023 MapLibre contributors, © 2020 Mapbox —{" "}
          <a href="https://github.com/maplibre/maplibre-gl-js/blob/main/LICENSE.txt" rel="noopener noreferrer">
            3-Clause BSD License
          </a>
        </li>
        <li>
          MapLibre Native (iOS) — © MapLibre contributors —{" "}
          <a href="https://github.com/maplibre/maplibre-native/blob/main/LICENSES.md" rel="noopener noreferrer">
            BSD License
          </a>
        </li>
        <li>
          React, React DOM — © Meta Platforms, Inc. and affiliates —{" "}
          <a href="https://github.com/facebook/react/blob/main/LICENSE" rel="noopener noreferrer">
            MIT License
          </a>
        </li>
        <li>
          OpenStreetMap — © OpenStreetMap contributors —{" "}
          <a href="https://www.openstreetmap.org/copyright" rel="noopener noreferrer">
            ODbL
          </a>
        </li>
      </ul>

      <h2>{t.report}</h2>
      <p>{t.reportBody}</p>
    </ContentPage>
  );
}
