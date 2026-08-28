/**
 * Le pied de page : la fin de page d'un produit, pas d'une maquette.
 * Quatre colonnes — marque, produit, application, légal — puis la ligne
 * d'auteur et l'avertissement santé.
 */
export function Footer() {
  return (
    <footer className="site-footer">
      <div className="shell">
        <div className="site-footer__grid">
          <div className="site-footer__brand">
            <a className="brand" href="/">
              <span className="brand__mark" aria-hidden="true">M</span>
              Mon&nbsp;Coach
            </a>
            <p className="site-footer__tagline">
              Un coach de musculation qui s'adapte à toi, pas l'inverse.
              Calculé sur ton appareil, jamais sur un serveur.
            </p>
            <p className="credit">
              Créé et fait par <strong>Maxime Nathan Lestage</strong>
            </p>
          </div>

          <nav className="site-footer__col" aria-label="Produit">
            <h3>Produit</h3>
            <a href="/#profil">Ce qu'il sait de toi</a>
            <a href="/#moteur">Le moteur</a>
            <a href="/#simulateur">Simulateur</a>
            <a href="/#montre">Apple Watch</a>
            <a href="/#tarifs">Tarifs</a>
          </nav>

          <nav className="site-footer__col" aria-label="Application">
            <h3>Application</h3>
            <span className="site-footer__soon">iPhone — bientôt sur l'App Store</span>
            <span className="site-footer__soon">Apple Watch et Live Activity incluses</span>
            <a href="/#confidentialite-produit">Confidentialité du produit</a>
            <a href="https://github.com/maxlestage/mon-coach" rel="noopener noreferrer">
              Code source sur GitHub
            </a>
          </nav>

          <nav className="site-footer__col" aria-label="Légal">
            <h3>Légal</h3>
            <a href="/mentions-legales">Mentions légales</a>
            <a href="/confidentialite">Politique de confidentialité</a>
            <a href="/conditions">Conditions d'utilisation</a>
          </nav>
        </div>

        <div className="site-footer__bottom">
          <span>© 2026 Maxime Nathan Lestage — Tous droits réservés.</span>
          <span>
            Ce site n'utilise aucun cookie et ne charge aucune ressource
            externe. Il s'installe comme une application et fonctionne hors
            ligne.
          </span>
        </div>

        <p className="disclaimer">
          Mon Coach n'est pas un dispositif médical et ne remplace ni un
          médecin, ni un kinésithérapeute, ni un diététicien. En cas de douleur
          persistante, de pathologie connue, de grossesse ou de traitement en
          cours, demande un avis professionnel avant de suivre un programme.
        </p>
      </div>
    </footer>
  );
}
