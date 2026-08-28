export function PrivacySection() {
  return (
    <section className="section" id="confidentialite">
      <div className="shell">
        <span className="section__eyebrow">Confidentialité</span>
        <h2 className="section__title">Rien ne quitte ton téléphone</h2>
        <p className="section__lede">
          Ton poids, ton taux de masse grasse, tes blessures et ton sommeil font
          partie des données les plus intimes qu'une application puisse
          collecter. La façon la plus sûre de les protéger est de ne jamais les
          envoyer nulle part.
        </p>

        <div className="grid grid--3">
          <article className="card">
            <h3 className="card__title">Aucun compte</h3>
            <p className="card__body">
              Pas d'adresse e-mail, pas de mot de passe, pas de connexion
              sociale. L'application s'ouvre et fonctionne, hors ligne compris.
            </p>
          </article>
          <article className="card">
            <h3 className="card__title">Aucun serveur</h3>
            <p className="card__body">
              Le moteur de coaching s'exécute entièrement sur l'appareil. Il n'y
              a pas d'API à appeler, donc rien à intercepter, à revendre ou à
              faire fuiter.
            </p>
          </article>
          <article className="card">
            <h3 className="card__title">Aucun traceur</h3>
            <p className="card__body">
              Ni analytique, ni régie publicitaire, ni SDK tiers. Ce site non
              plus ne dépose de cookie ni ne charge de ressource externe.
            </p>
          </article>
          <article className="card">
            <h3 className="card__title">Export intégral</h3>
            <p className="card__body">
              Un bouton exporte l'ensemble de ton profil, de ton programme et de
              ton historique en JSON lisible. Tes données t'appartiennent, y
              compris le jour où tu pars.
            </p>
          </article>
          <article className="card">
            <h3 className="card__title">Suppression immédiate</h3>
            <p className="card__body">
              « Tout effacer » supprime réellement tout, tout de suite, sans
              copie de sauvegarde ailleurs et sans période de rétention.
            </p>
          </article>
          <article className="card">
            <h3 className="card__title">Stockage transparent</h3>
            <p className="card__body">
              Un unique fichier JSON, écrit de façon atomique. Un fichier
              illisible est mis de côté plutôt que supprimé : un historique
              d'entraînement ne se détruit pas en silence.
            </p>
          </article>
        </div>
      </div>
    </section>
  );
}
