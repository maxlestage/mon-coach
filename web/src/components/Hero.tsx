import type { SimulatorResult } from "../coach/types.ts";
import { splitLabels } from "../coach/labels.ts";

interface HeroProps {
  preview: SimulatorResult;
}

export function Hero({ preview }: HeroProps) {
  return (
    <section className="hero" id="top">
      <div className="shell hero__grid">
        <div>
          <span className="section__eyebrow">Application iOS native</span>
          <h1 className="hero__title">
            Un coach de musculation qui s'adapte à toi,{" "}
            <em>pas l'inverse</em>.
          </h1>
          <p className="hero__lede">
            Mon Coach part de ton corps, de ton matériel, de tes articulations
            fragiles et du temps que tu as vraiment. Il en tire un programme
            complet — séries, exercices, charges, calories — puis le réécrit
            chaque semaine à partir de ce que tu as réellement fait en salle.
          </p>
          <div className="hero__actions">
            <a className="button button--primary" href="#simulateur">
              Voir mon programme en 10 secondes
            </a>
            <a className="button button--ghost" href="#moteur">
              Comment ça marche
            </a>
          </div>
          <p className="hero__note">
            Aucun compte. Aucun serveur. Tout est calculé sur ton téléphone.
          </p>
        </div>

        <div className="phone" role="img" aria-label="Aperçu de l'écran du jour dans l'application Mon Coach">
          <div className="phone__screen">
            <span className="phone__label">Aujourd'hui · semaine 2</span>
            <span className="phone__title">Haut du corps</span>

            <div className="phone__card">
              <div className="phone__row">
                <span>Forme du jour</span>
                <span>78 / 100</span>
              </div>
              <div className="phone__row">
                <span>Séance</span>
                <span>Au programme</span>
              </div>
            </div>

            <div className="phone__card">
              <div className="phone__row">
                <span>Développé couché</span>
                <span>4 × 6–12</span>
              </div>
              <div className="phone__row">
                <span>Traction supination</span>
                <span>4 × 6–12</span>
              </div>
              <div className="phone__row">
                <span>Développé militaire</span>
                <span>3 × 6–10</span>
              </div>
              <div className="phone__row">
                <span>Écarté à la poulie</span>
                <span>2 × 10–12</span>
              </div>
              <div className="phone__row">
                <span>Face pull</span>
                <span>2 × 12</span>
              </div>
            </div>

            <div className="phone__card">
              <div className="phone__row">
                <span>Calories</span>
                <span>{preview.nutrition.calories} kcal</span>
              </div>
              <div className="phone__row">
                <span>Protéines</span>
                <span>{preview.nutrition.proteinG} g</span>
              </div>
              <div className="phone__row">
                <span>Structure</span>
                <span>{splitLabels[preview.split]}</span>
              </div>
            </div>

            <div className="phone__cta">Démarrer la séance</div>
          </div>
        </div>
      </div>
    </section>
  );
}
