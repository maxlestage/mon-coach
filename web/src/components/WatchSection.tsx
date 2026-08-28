/**
 * La séance sans le téléphone : application montre et Live Activity.
 *
 * Les deux maquettes sont dessinées en CSS, comme celle du téléphone dans le
 * héros : aucune image, aucune ressource externe, et le contenu affiché est
 * réaliste — ce sont les vrais libellés de l'application.
 */
export function WatchSection() {
  return (
    <section className="section" id="montre">
      <div className="shell">
        <span className="section__eyebrow">Au poignet</span>
        <h2 className="section__title">
          Le téléphone reste au vestiaire
        </h2>
        <p className="section__lede">
          La séance complète se mène depuis l'Apple Watch : chaque série se
          règle à la couronne et se valide d'un geste, le chrono de repos vibre
          au poignet. Et si le téléphone est à portée, la Live Activity affiche
          la série en cours et le repos sur l'écran verrouillé — sans
          déverrouiller quoi que ce soit.
        </p>

        <div className="wearables">
          <div className="wearables__device">
            <div className="watch" role="img" aria-label="Aperçu d'une série en cours sur l'application Apple Watch">
              <span className="watch__crown" aria-hidden="true" />
              <span className="watch__button" aria-hidden="true" />
              <div className="watch__screen">
                <span className="watch__time">10:24</span>
                <span className="watch__title">Développé couché</span>
                <span className="watch__detail">Série 3/4 · 6–12 rép · RPE 8</span>
                <span className="watch__value">62,5 kg</span>
                <div className="watch__segments" aria-hidden="true">
                  <span data-active="true">Charge</span>
                  <span>Rép</span>
                  <span>RPE</span>
                </div>
                <span className="watch__cta">✓ Valider la série</span>
              </div>
            </div>
            <h3 className="wearables__name">Application watchOS</h3>
            <ul className="wearables__points">
              <li>La séance du jour arrive toute prescrite : exercices, fourchettes, charges.</li>
              <li>Charge, répétitions et RPE se règlent à la couronne, pré-remplis à la consigne.</li>
              <li>Hors de portée du téléphone, la montre continue : le journal se synchronise au retour, sans rien perdre.</li>
            </ul>
          </div>

          <div className="wearables__device">
            <div className="lockscreen" role="img" aria-label="Aperçu de la Live Activity sur l'écran verrouillé">
              <div className="island">
                <span className="island__icon" aria-hidden="true">🏋</span>
                <span className="island__timer">1:47</span>
              </div>
              <div className="activity">
                <div className="activity__row">
                  <span className="activity__session">Haut du corps</span>
                  <span className="activity__count">9/16 séries</span>
                </div>
                <div className="activity__row">
                  <div>
                    <div className="activity__exercise">Traction supination</div>
                    <div className="activity__set">Série 2 sur 4 · 6–12 rép</div>
                  </div>
                  <span className="activity__load">au poids du corps</span>
                </div>
                <div className="activity__rest">
                  <span>Repos</span>
                  <span className="activity__countdown">1:47</span>
                  <span className="activity__bar" aria-hidden="true" />
                </div>
              </div>
            </div>
            <h3 className="wearables__name">Live Activity</h3>
            <ul className="wearables__points">
              <li>Série en cours, charge et repos, lisibles sur l'écran verrouillé.</li>
              <li>Le compte à rebours vit dans la Dynamic Island, même en musique ou au téléphone.</li>
              <li>Piloté par une date, pas par des notifications : rien à recevoir, rien qui traîne quand la séance est finie.</li>
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
