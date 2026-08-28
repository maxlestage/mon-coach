export function Header() {
  return (
    <header className="site-header">
      <div className="shell site-header__inner">
        <a className="brand" href="#top">
          <span className="brand__mark" aria-hidden="true">
            M
          </span>
          Mon&nbsp;Coach
        </a>
        <nav className="site-nav" aria-label="Navigation principale">
          <a href="#profil">Ce qu'il sait de toi</a>
          <a href="#moteur">Le moteur</a>
          <a href="#simulateur">Simulateur</a>
          <a href="#montre">Montre</a>
          <a href="#adaptation">Adaptation</a>
          <a href="#faq">Questions</a>
        </nav>
        <a className="button button--primary button--small" href="#simulateur">
          Essayer le moteur
        </a>
      </div>
    </header>
  );
}
