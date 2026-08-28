/**
 * La section tarifs : le modèle freemium, énoncé sans détour.
 *
 * Le principe est documenté dans docs/MODELE-ECONOMIQUE.md : le premier bloc
 * complet est gratuit — un vrai coach pendant cinq semaines, pas une démo —
 * et Mon Coach+ débloque la continuité. Les données restent gratuites à vie,
 * parce qu'un export payant contredirait tout ce que la page promet.
 */
export function PricingSection() {
  return (
    <section className="section" id="tarifs">
      <div className="shell">
        <span className="section__eyebrow">Tarifs</span>
        <h2 className="section__title">Le premier bloc est complet, et gratuit</h2>
        <p className="section__lede">
          Pas de démo bridée : la formule gratuite est le vrai coach, pendant
          tout un bloc d'entraînement. Mon Coach+ débloque la suite — la
          continuité, le poignet, l'écran verrouillé. Et tes données ne sont
          jamais un otage : l'historique et l'export restent gratuits, pour
          toujours.
        </p>

        <div className="pricing">
          <article className="plan">
            <h3 className="plan__name">Gratuit</h3>
            <p className="plan__price">0 €</p>
            <p className="plan__period">pour toujours</p>
            <ul className="plan__features">
              <li>Le questionnaire complet et ton profil</li>
              <li>Un premier bloc entier (5 à 6 semaines) : séances, charges autorégulées, décharge</li>
              <li>Check-in du jour et séance ajustée à ta forme</li>
              <li>Cibles caloriques et macros, expliquées</li>
              <li>Enregistrement des séances et pesées, sans limite</li>
              <li>Export JSON intégral et effacement — à vie</li>
            </ul>
          </article>

          <article className="plan plan--plus">
            <span className="plan__badge">Recommandé</span>
            <h3 className="plan__name">Mon Coach+</h3>
            <p className="plan__price">14,99 €<span> / mois</span></p>
            <p className="plan__period">ou 119,99 € par an, soit quatre mois offerts</p>
            <ul className="plan__features">
              <li>Tout le gratuit, évidemment</li>
              <li>Les blocs suivants, reconstruits d'après tes séances réelles</li>
              <li>Le bilan hebdomadaire : volume, calories, décharge anticipée</li>
              <li>L'application Apple Watch, autonome au poignet</li>
              <li>La Live Activity sur l'écran verrouillé</li>
              <li>Les courbes de progression : poids, 1RM estimé</li>
            </ul>
            <p className="plan__note">
              Achat via l'App Store, sans compte à créer. Résiliable à tout
              moment dans les réglages Apple. À titre de comparaison : une
              seule séance avec un coach humain coûte plus cher que l'année
              entière. Jamais de publicité.
            </p>
          </article>
        </div>
      </div>
    </section>
  );
}
