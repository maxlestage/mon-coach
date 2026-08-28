import { ContentPage } from "../components/SiteChrome.tsx";

export function Confidentialite() {
  return (
    <ContentPage eyebrow="Légal" title="Politique de confidentialité" updated="28 août 2026">
      <p className="legal__lede">
        La politique tient en une phrase : <strong>nous ne collectons rien,
        parce que rien ne quitte ton appareil.</strong> Le reste de cette page
        détaille ce que cela veut dire, service par service.
      </p>

      <h2>L'application</h2>
      <p>
        Ton profil, tes séances, tes pesées et ta forme du jour sont stockés
        dans un fichier unique, sur ton appareil, et n'en sortent jamais.
        L'application n'a pas de compte, pas de serveur, pas d'analytique, pas
        de SDK publicitaire. Le moteur de coaching s'exécute entièrement en
        local : il fonctionne en avion.
      </p>
      <p>
        Tu peux exporter l'intégralité de tes données (format JSON lisible) ou
        tout effacer, à tout moment, depuis l'écran Profil. La suppression est
        immédiate et définitive — il n'existe aucune copie ailleurs.
      </p>

      <h2>L'Apple Watch</h2>
      <p>
        La synchronisation entre ton iPhone et ta montre passe par le canal
        chiffré d'Apple (WatchConnectivity), directement d'un appareil à
        l'autre. Aucun serveur tiers n'intervient.
      </p>

      <h2>Les achats</h2>
      <p>
        Les achats de la formule Mon Coach+ sont traités par l'App Store
        d'Apple. Nous ne voyons ni ton identité, ni ton moyen de paiement —
        seulement, localement, le fait que la formule est active.
      </p>

      <h2>Ce site</h2>
      <p>
        Ce site ne dépose aucun cookie, ne charge aucune ressource externe et
        n'embarque aucun traceur. Le simulateur s'exécute dans ton navigateur :
        les valeurs que tu y règles ne sont transmises nulle part.
      </p>
      <p>
        Comme tout hébergeur, Heroku produit des journaux techniques de
        connexion (adresse IP, horodatage) nécessaires au fonctionnement et à
        la sécurité du service. Nous ne les exploitons pas.
      </p>

      <h2>Tes droits</h2>
      <p>
        Le règlement général sur la protection des données (RGPD) prévoit des
        droits d'accès, de rectification et d'effacement. Ici, ils s'exercent
        directement : tes données sont sur ton appareil, sous ton seul
        contrôle. Pour toute question :{" "}
        <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>.
      </p>
    </ContentPage>
  );
}
