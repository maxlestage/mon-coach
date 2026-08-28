import { ContentPage } from "../components/SiteChrome.tsx";

export function Conditions() {
  return (
    <ContentPage eyebrow="Légal" title="Conditions d'utilisation" updated="28 août 2026">
      <h2>Ce que Mon Coach est</h2>
      <p>
        Mon Coach est un programmeur d'entraînement : il construit un
        programme de musculation et des repères nutritionnels à partir des
        informations que tu fournis, puis les ajuste d'après tes séances.
        C'est un outil d'aide à l'entraînement, pas un service médical.
      </p>

      <h2>Ce que Mon Coach n'est pas</h2>
      <p>
        L'application ne remplace ni un médecin, ni un kinésithérapeute, ni un
        diététicien. Ses calculs reposent sur des formules publiées qui
        produisent des estimations, pas des prescriptions. En cas de douleur
        persistante, de pathologie, de grossesse ou de traitement en cours,
        demande un avis professionnel avant de suivre un programme.
      </p>
      <p>
        La musculation comporte des risques inhérents. Tu restes seul juge de
        ce que tu soulèves : une charge suggérée est une suggestion, et la
        responsabilité de l'éditeur ne saurait être engagée pour une blessure
        survenue à l'entraînement.
      </p>

      <h2>Formule gratuite et Mon Coach+</h2>
      <p>
        La formule gratuite comprend le questionnaire complet et un premier
        bloc d'entraînement entier, séances et charges comprises. La formule
        Mon Coach+ débloque la suite — adaptation continue, application
        montre, Live Activity, courbes de progression. Les achats passent par
        l'App Store et sont soumis à ses conditions ; gestion et résiliation
        se font dans les réglages de ton compte Apple, à tout moment.
      </p>
      <p>
        Tes données ne sont jamais un otage : l'enregistrement des séances,
        l'historique et l'export complet restent gratuits, formule ou pas.
      </p>

      <h2>Disponibilité</h2>
      <p>
        L'application fonctionne entièrement hors ligne ; le site et sa
        version installable sont fournis « en l'état », sans garantie de
        disponibilité continue.
      </p>

      <h2>Droit applicable</h2>
      <p>
        Ces conditions sont régies par le droit français. Tout litige relève
        des tribunaux français compétents, après recherche d'une solution
        amiable via{" "}
        <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>.
      </p>
    </ContentPage>
  );
}
