export function Footer() {
  return (
    <footer className="site-footer">
      <div className="shell site-footer__inner">
        <span>
          Mon Coach — application iOS de coaching en musculation. Conçue pour
          fonctionner hors ligne.
        </span>
        <nav aria-label="Liens de pied de page">
          <a href="#confidentialite">Confidentialité</a>
          {" · "}
          <a href="#faq">Questions</a>
          {" · "}
          <a href="#top">Haut de page</a>
        </nav>
      </div>
      <div className="shell">
        <p className="credit">
          Créé et fait par <strong>Maxime Nathan Lestage</strong>
        </p>
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
