import { useCopy } from "../i18n/language.tsx";

interface Point {
  readonly title: string;
  readonly body: string;
}

const copy = {
  fr: {
    eyebrow: "Confidentialité",
    title: "Rien ne quitte ton téléphone",
    lede: "Ton poids, ton taux de masse grasse, tes blessures, ton sommeil et le tracé de tes sorties font partie des données les plus intimes qu'une application puisse collecter. La façon la plus sûre de les protéger est de ne jamais les envoyer nulle part.",
    points: [
      { title: "Aucun compte", body: "Pas d'adresse e-mail, pas de mot de passe, pas de connexion sociale. L'application s'ouvre et fonctionne, hors ligne compris." },
      { title: "Aucun serveur", body: "Le moteur de coaching s'exécute entièrement sur l'appareil. Il n'y a pas d'API à appeler, donc rien à intercepter, à revendre ou à faire fuiter." },
      { title: "Une seule exception, dite", body: "Le fond de carte de tes sorties charge des tuiles OpenStreetMap. C'est la seule requête que l'application émette, elle ne part que sur les écrans de course, et elle se coupe en un geste depuis le profil — ton tracé reste alors dessiné sur le téléphone, à partir de tes propres points." },
      { title: "Aucun traceur", body: "Ni analytique, ni régie publicitaire, ni SDK tiers. Ce site ne dépose aucun cookie, et il ne charge de ressource externe que si tu ouvres toi-même la carte plus haut." },
      { title: "Export intégral", body: "Un bouton exporte l'ensemble de ton profil, de ton programme, de tes sorties et de ton historique en JSON lisible. Tes données t'appartiennent, y compris le jour où tu pars." },
      { title: "Suppression immédiate", body: "« Tout effacer » supprime réellement tout, tout de suite, sans copie de sauvegarde ailleurs et sans période de rétention." },
    ],
  },
  en: {
    eyebrow: "Privacy",
    title: "Nothing leaves your phone",
    lede: "Your weight, your body-fat percentage, your injuries, your sleep and the trace of your runs are among the most intimate data an app can collect. The safest way to protect them is never to send them anywhere.",
    points: [
      { title: "No account", body: "No email address, no password, no social login. The app opens and works, offline included." },
      { title: "No server", body: "The coaching engine runs entirely on the device. There is no API to call, so nothing to intercept, resell or leak." },
      { title: "One exception, stated", body: "The map background for your runs loads OpenStreetMap tiles. It is the only request the app makes, it only happens on the running screens, and it can be switched off from the profile in one tap — your route is then still drawn on the phone, from your own points." },
      { title: "No trackers", body: "No analytics, no ad network, no third-party SDK. This site sets no cookie, and loads an external resource only if you open the map above yourself." },
      { title: "Full export", body: "One button exports your whole profile, programme, runs and history as readable JSON. Your data is yours, including on the day you leave." },
      { title: "Immediate deletion", body: "\"Erase everything\" really does erase everything, right away, with no backup elsewhere and no retention period." },
    ],
  },
  es: {
    eyebrow: "Privacidad",
    title: "Nada sale de tu teléfono",
    lede: "Tu peso, tu porcentaje de grasa, tus lesiones, tu sueño y la traza de tus rodajes están entre los datos más íntimos que puede recoger una aplicación. La forma más segura de protegerlos es no enviarlos nunca a ninguna parte.",
    points: [
      { title: "Sin cuenta", body: "Sin correo, sin contraseña, sin inicio de sesión social. La aplicación se abre y funciona, también sin conexión." },
      { title: "Sin servidor", body: "El motor de entrenamiento se ejecuta enteramente en el dispositivo. No hay API que llamar, así que no hay nada que interceptar, revender o filtrar." },
      { title: "Una sola excepción, dicha", body: "El fondo de mapa de tus rodajes carga teselas de OpenStreetMap. Es la única petición que hace la aplicación, solo ocurre en las pantallas de carrera y se desactiva con un gesto desde el perfil: entonces tu traza se sigue dibujando en el teléfono con tus propios puntos." },
      { title: "Sin rastreadores", body: "Sin analítica, sin red publicitaria, sin SDK de terceros. Este sitio no deja ninguna cookie y solo carga un recurso externo si abres tú mismo el mapa de más arriba." },
      { title: "Exportación íntegra", body: "Un botón exporta todo tu perfil, tu programa, tus rodajes y tu historial en JSON legible. Tus datos son tuyos, también el día en que te vayas." },
      { title: "Borrado inmediato", body: "«Borrarlo todo» borra de verdad todo, al instante, sin copia de seguridad en otro sitio y sin periodo de retención." },
    ],
  },
} as const;

export function PrivacySection() {
  const t = useCopy(copy);

  return (
    <section className="section" id="confidentialite-produit">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <div className="grid grid--3">
          {(t.points as readonly Point[]).map((point) => (
            <article className="card" key={point.title}>
              <h3 className="card__title">{point.title}</h3>
              <p className="card__body">{point.body}</p>
            </article>
          ))}
        </div>
      </div>
    </section>
  );
}
