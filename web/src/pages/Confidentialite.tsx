import { ContentPage } from "../components/SiteChrome.tsx";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    eyebrow: "Légal",
    title: "Politique de confidentialité",
    ledeStart: "La politique tient en une phrase :",
    ledeStrong: "nous ne collectons rien, parce que rien ne quitte ton appareil.",
    ledeEnd: "Le reste de cette page détaille ce que cela veut dire, service par service.",
    app: "L'application",
    appBody1: "Ton profil, tes séances, tes sorties, tes pesées et ta forme du jour sont stockés dans un fichier unique, sur ton appareil, et n'en sortent jamais. L'application n'a pas de compte, pas de serveur, pas d'analytique, pas de SDK publicitaire. Le moteur de coaching s'exécute entièrement en local : il fonctionne en avion.",
    appBody2: "Tu peux exporter l'intégralité de tes données (format JSON lisible) ou tout effacer, à tout moment, depuis l'écran Profil. La suppression est immédiate et définitive — il n'existe aucune copie ailleurs.",
    location: "La localisation et les cartes",
    locationBody1: "Quand tu enregistres une sortie, l'application lit ta position via le GPS de l'appareil. Les points restent sur le téléphone : distance, allure, dénivelé et découpage en kilomètres sont calculés en local, sans qu'aucune coordonnée ne soit transmise.",
    locationBody2: "Le fond de carte, lui, est chargé depuis un serveur de tuiles OpenStreetMap. C'est la seule requête réseau que l'application émette, elle n'a lieu que sur les écrans de course, et elle transmet la zone géographique affichée — pas ton identité, pas ton tracé. Tu peux la désactiver dans le profil : la carte affiche alors ton parcours seul, dessiné sur l'appareil.",
    watch: "L'Apple Watch",
    watchBody: "La synchronisation entre ton iPhone et ta montre passe par le canal chiffré d'Apple (WatchConnectivity), directement d'un appareil à l'autre. Aucun serveur tiers n'intervient, y compris pour les sorties mesurées au poignet.",
    health: "Santé et la fréquence cardiaque",
    healthBody: "Pendant une activité menée au poignet, la montre ouvre une session d'entraînement HealthKit : elle lit ta fréquence cardiaque, ta dépense active et la distance qu'elle estime elle-même, et rien d'autre. À la fin, l'entraînement est enregistré dans Santé pour que tes anneaux se ferment — c'est la seule chose que l'application y écrit. Les mesures rejoignent le journal de la sortie, sur tes appareils, et ne servent qu'à afficher ton effort et ta charge d'entraînement. Elles ne sont jamais transmises à un tiers ni utilisées à aucune autre fin.",
    files: "L'import et l'export",
    filesBody: "Importer un fichier GPX le lit sur ton appareil ; exporter une sortie fabrique un fichier que toi seul décides de partager, et avec qui. Aucun de ces gestes ne déclenche de transmission : le fichier ne bouge que par ta main.",
    purchases: "Les achats",
    purchasesBody: "Les achats de la formule Stride+ sont traités par l'App Store d'Apple. Nous ne voyons ni ton identité, ni ton moyen de paiement — seulement, localement, le fait que la formule est active.",
    site: "Ce site",
    siteBody1: "Ce site ne dépose aucun cookie et n'embarque aucun traceur. Il ne charge aucune ressource externe tant que tu n'ouvres pas toi-même la carte de la section course : à ce moment-là, et à ce moment-là seulement, MapLibre et les tuiles OpenStreetMap sont téléchargés. La langue que tu choisis est conservée dans le stockage local de ton navigateur, sur ton appareil.",
    siteBody2: "Le simulateur s'exécute dans ton navigateur : les valeurs que tu y règles ne sont transmises nulle part.",
    siteBody3: "Comme tout hébergeur, Heroku produit des journaux techniques de connexion (adresse IP, horodatage) nécessaires au fonctionnement et à la sécurité du service. Nous ne les exploitons pas.",
    rights: "Tes droits",
    rightsBody: "Le règlement général sur la protection des données (RGPD) prévoit des droits d'accès, de rectification et d'effacement. Ici, ils s'exercent directement : tes données sont sur ton appareil, sous ton seul contrôle. Pour toute question :",
  },
  en: {
    eyebrow: "Legal",
    title: "Privacy policy",
    ledeStart: "The policy fits in one sentence:",
    ledeStrong: "we collect nothing, because nothing leaves your device.",
    ledeEnd: "The rest of this page spells out what that means, service by service.",
    app: "The app",
    appBody1: "Your profile, your sessions, your runs, your weigh-ins and your daily readiness are stored in a single file on your device, and never leave it. The app has no account, no server, no analytics, no advertising SDK. The coaching engine runs entirely locally: it works in aeroplane mode.",
    appBody2: "You can export all of your data (readable JSON) or erase everything, at any time, from the Profile screen. Deletion is immediate and final — there is no copy anywhere else.",
    location: "Location and maps",
    locationBody1: "When you record a run, the app reads your position through the device's GPS. The points stay on the phone: distance, pace, elevation and splits are all computed locally, without a single coordinate being transmitted.",
    locationBody2: "The map background, however, is loaded from an OpenStreetMap tile server. It is the only network request the app makes, it only happens on the running screens, and it transmits the geographic area being displayed — not your identity, not your route. You can turn it off in the profile: the map then shows your route alone, drawn on the device.",
    watch: "The Apple Watch",
    watchBody: "Syncing between your iPhone and your watch goes through Apple's encrypted channel (WatchConnectivity), directly from one device to the other. No third-party server is involved, including for runs measured at the wrist.",
    health: "Health and heart rate",
    healthBody: "During an activity recorded at the wrist, the watch opens a HealthKit workout session: it reads your heart rate, your active energy and the distance it estimates itself, and nothing else. At the end, the workout is saved to Health so your rings close — that is the only thing the app writes there. The measurements join the activity's log, on your devices, and are used solely to show your effort and training load. They are never transmitted to any third party nor used for any other purpose.",
    files: "Import and export",
    filesBody: "Importing a GPX file reads it on your device; exporting an activity produces a file that you alone decide to share, and with whom. Neither gesture triggers any transmission: the file only moves by your hand.",
    purchases: "Purchases",
    purchasesBody: "Stride+ purchases are handled by Apple's App Store. We see neither your identity nor your payment method — only, locally, the fact that the plan is active.",
    site: "This site",
    siteBody1: "This site sets no cookie and embeds no tracker. It loads no external resource until you open the map in the running section yourself: at that point, and only then, MapLibre and the OpenStreetMap tiles are downloaded. The language you choose is kept in your browser's local storage, on your device.",
    siteBody2: "The simulator runs in your browser: the values you set there are transmitted nowhere.",
    siteBody3: "Like any host, Heroku produces technical connection logs (IP address, timestamp) required for the operation and security of the service. We do not exploit them.",
    rights: "Your rights",
    rightsBody: "The General Data Protection Regulation (GDPR) provides rights of access, rectification and erasure. Here they are exercised directly: your data is on your device, under your sole control. For any question:",
  },
  es: {
    eyebrow: "Legal",
    title: "Política de privacidad",
    ledeStart: "La política cabe en una frase:",
    ledeStrong: "no recogemos nada, porque nada sale de tu dispositivo.",
    ledeEnd: "El resto de esta página detalla qué significa eso, servicio por servicio.",
    app: "La aplicación",
    appBody1: "Tu perfil, tus sesiones, tus rodajes, tus pesajes y tu forma del día se guardan en un único archivo de tu dispositivo y nunca salen de él. La aplicación no tiene cuenta, ni servidor, ni analítica, ni SDK publicitario. El motor de entrenamiento se ejecuta enteramente en local: funciona en modo avión.",
    appBody2: "Puedes exportar todos tus datos (en JSON legible) o borrarlo todo, en cualquier momento, desde la pantalla de Perfil. El borrado es inmediato y definitivo: no existe ninguna copia en otro sitio.",
    location: "La ubicación y los mapas",
    locationBody1: "Cuando registras un rodaje, la aplicación lee tu posición con el GPS del dispositivo. Los puntos se quedan en el teléfono: distancia, ritmo, desnivel y parciales se calculan en local, sin que se transmita ni una sola coordenada.",
    locationBody2: "El fondo de mapa, en cambio, se carga desde un servidor de teselas de OpenStreetMap. Es la única petición de red que hace la aplicación, solo ocurre en las pantallas de carrera y transmite la zona geográfica mostrada, no tu identidad ni tu traza. Puedes desactivarlo en el perfil: el mapa muestra entonces solo tu recorrido, dibujado en el dispositivo.",
    watch: "El Apple Watch",
    watchBody: "La sincronización entre tu iPhone y tu reloj pasa por el canal cifrado de Apple (WatchConnectivity), directamente de un dispositivo a otro. No interviene ningún servidor de terceros, tampoco para los rodajes medidos en la muñeca.",
    health: "Salud y el pulso",
    healthBody: "Durante una actividad registrada en la muñeca, el reloj abre una sesión de entrenamiento de HealthKit: lee tu pulso, tu gasto activo y la distancia que estima por sí mismo, y nada más. Al final, el entrenamiento se guarda en Salud para que tus anillos se cierren; es lo único que la aplicación escribe ahí. Las medidas se unen al registro de la salida, en tus dispositivos, y sirven únicamente para mostrar tu esfuerzo y tu carga de entrenamiento. Nunca se transmiten a terceros ni se usan para otro fin.",
    files: "Importar y exportar",
    filesBody: "Importar un archivo GPX lo lee en tu dispositivo; exportar una salida produce un archivo que solo tú decides compartir, y con quién. Ninguno de esos gestos desencadena transmisión alguna: el archivo solo se mueve por tu mano.",
    purchases: "Las compras",
    purchasesBody: "Las compras de Stride+ las gestiona la App Store de Apple. No vemos ni tu identidad ni tu método de pago, solo, en local, que el plan está activo.",
    site: "Este sitio",
    siteBody1: "Este sitio no deja ninguna cookie ni incorpora rastreadores. No carga ningún recurso externo hasta que abres tú mismo el mapa de la sección de carrera: en ese momento, y solo entonces, se descargan MapLibre y las teselas de OpenStreetMap. El idioma que elijas se guarda en el almacenamiento local de tu navegador, en tu dispositivo.",
    siteBody2: "El simulador se ejecuta en tu navegador: los valores que ajustas no se transmiten a ninguna parte.",
    siteBody3: "Como todo alojamiento, Heroku produce registros técnicos de conexión (dirección IP, marca de tiempo) necesarios para el funcionamiento y la seguridad del servicio. No los explotamos.",
    rights: "Tus derechos",
    rightsBody: "El Reglamento General de Protección de Datos (RGPD) prevé derechos de acceso, rectificación y supresión. Aquí se ejercen directamente: tus datos están en tu dispositivo, bajo tu único control. Para cualquier duda:",
  },
} as const;

export function Confidentialite() {
  const t = useCopy(copy);

  return (
    <ContentPage eyebrow={t.eyebrow} title={t.title} updated="28.08.2026" legallyBinding>
      <p className="legal__lede">
        {t.ledeStart} <strong>{t.ledeStrong}</strong> {t.ledeEnd}
      </p>

      <h2>{t.app}</h2>
      <p>{t.appBody1}</p>
      <p>{t.appBody2}</p>

      <h2>{t.location}</h2>
      <p>{t.locationBody1}</p>
      <p>{t.locationBody2}</p>

      <h2>{t.watch}</h2>
      <p>{t.watchBody}</p>

      <h2>{t.health}</h2>
      <p>{t.healthBody}</p>

      <h2>{t.files}</h2>
      <p>{t.filesBody}</p>

      <h2>{t.purchases}</h2>
      <p>{t.purchasesBody}</p>

      <h2>{t.site}</h2>
      <p>{t.siteBody1}</p>
      <p>{t.siteBody2}</p>
      <p>{t.siteBody3}</p>

      <h2>{t.rights}</h2>
      <p>
        {t.rightsBody} <a href="mailto:maxlestage@icloud.com">maxlestage@icloud.com</a>.
      </p>
    </ContentPage>
  );
}
