import { useEffect, useRef, useState } from "react";
import { demoRoute } from "../data/demo-run.ts";
import { useCopy } from "../i18n/language.tsx";

const copy = {
  fr: {
    placeholderTitle: "Charger la carte ?",
    placeholderBody:
      "Le fond de carte vient d'OpenStreetMap : ouvrir la carte est la seule action de cette page qui envoie une requête à un serveur tiers. Rien ne se charge tant que tu ne cliques pas.",
    load: "Afficher la carte OpenStreetMap",
    loading: "Chargement de la carte…",
    failed:
      "La carte n'a pas pu être chargée. Le tracé reste affiché : il est dessiné ici, à partir des coordonnées, sans rien demander à personne.",
    retry: "Réessayer",
    shapeAria: "Tracé de la sortie de démonstration",
    mapAria: "Carte OpenStreetMap de la sortie de démonstration",
  },
  en: {
    placeholderTitle: "Load the map?",
    placeholderBody:
      "The map background comes from OpenStreetMap: opening the map is the only action on this page that sends a request to a third-party server. Nothing loads until you click.",
    load: "Show the OpenStreetMap map",
    loading: "Loading the map…",
    failed:
      "The map could not be loaded. The route is still shown: it is drawn right here from the coordinates, without asking anyone for anything.",
    retry: "Try again",
    shapeAria: "Route of the demo run",
    mapAria: "OpenStreetMap map of the demo run",
  },
  es: {
    placeholderTitle: "¿Cargar el mapa?",
    placeholderBody:
      "El fondo de mapa viene de OpenStreetMap: abrir el mapa es la única acción de esta página que envía una petición a un servidor de terceros. No se carga nada hasta que haces clic.",
    load: "Mostrar el mapa de OpenStreetMap",
    loading: "Cargando el mapa…",
    failed:
      "No se ha podido cargar el mapa. La traza sigue visible: se dibuja aquí mismo a partir de las coordenadas, sin pedirle nada a nadie.",
    retry: "Reintentar",
    shapeAria: "Traza del rodaje de demostración",
    mapAria: "Mapa de OpenStreetMap del rodaje de demostración",
  },
} as const;

/**
 * Le tracé dessiné en SVG, à partir des coordonnées seules.
 *
 * C'est ce qui s'affiche avant que l'athlète demande la carte, et ce qui
 * reste si la carte ne se charge pas. La longitude est resserrée par le
 * cosinus de la latitude : sans ça, une boucle est-ouest à Lyon paraît une
 * fois et demie trop large et ne ressemble plus au parcours.
 */
function RouteShape({ label }: { label: string }) {
  const lons = demoRoute.map(([lon]) => lon);
  const lats = demoRoute.map(([, lat]) => lat);
  const minLon = Math.min(...lons);
  const maxLon = Math.max(...lons);
  const minLat = Math.min(...lats);
  const maxLat = Math.max(...lats);
  const midLat = ((minLat + maxLat) / 2) * (Math.PI / 180);
  const spanX = (maxLon - minLon) * Math.cos(midLat);
  const spanY = maxLat - minLat;
  const scale = Math.min(96 / spanX, 96 / spanY);

  const points = demoRoute
    .map(([lon, lat]) => {
      const x = 2 + (lon - minLon) * Math.cos(midLat) * scale;
      // L'axe des ordonnées est inversé : le nord doit être en haut.
      const y = 2 + (maxLat - lat) * scale;
      return `${x.toFixed(2)},${y.toFixed(2)}`;
    })
    .join(" ");

  return (
    <svg className="runmap__shape" viewBox="0 0 100 100" role="img" aria-label={label}>
      <polyline points={points} />
    </svg>
  );
}

/**
 * La carte de la sortie, chargée seulement sur demande.
 *
 * MapLibre GL JS pèse près d'un mégaoctet : il est importé dynamiquement,
 * donc il ne descend pas dans le paquet initial et n'est demandé qu'au clic.
 * Le style vectoriel et les tuiles viennent d'OpenStreetMap, et c'est la
 * seule requête externe de tout le site — d'où le clic, plutôt qu'un
 * chargement automatique qui contredirait la page confidentialité.
 */
export function RunMap() {
  const t = useCopy(copy);
  const [state, setState] = useState<"idle" | "loading" | "ready" | "failed">("idle");
  // Le numéro de la tentative en cours. C'est lui, et non l'état
  // d'affichage, qui pilote la vie de la carte : un effet accroché à l'état
  // serait nettoyé à l'instant même où la carte passe de « chargement » à
  // « prête » — et son nettoyage exécutait `map.remove()`, détruisant la
  // carte au moment précis où elle venait de réussir. C'est le bug qui
  // rendait la carte impossible à charger en production, invisible dans un
  // environnement où les tuiles sont bloquées et où seul le chemin d'échec
  // s'exécute.
  const [attempt, setAttempt] = useState(0);
  const container = useRef<HTMLDivElement>(null);

  const begin = () => {
    setState("loading");
    setAttempt((current) => current + 1);
  };

  useEffect(() => {
    if (attempt === 0 || !container.current) return;
    let cancelled = false;
    // Vrai dès que le sort de cette tentative est scellé, dans un sens ou
    // dans l'autre : plus aucun événement tardif ne doit le renverser.
    let settled = false;
    let map: { remove: () => void } | null = null;

    const fail = () => {
      if (cancelled || settled) return;
      settled = true;
      // La carte à moitié née est retirée tout de suite : l'état « échec »
      // ne rend plus le conteneur, elle continuerait de vivre en arrière-plan.
      map?.remove();
      map = null;
      setState("failed");
    };

    // Un style qui ne répond pas, un pare-feu d'entreprise, un navigateur
    // sans WebGL : sans limite de temps, le visiteur resterait devant
    // « chargement… » indéfiniment. Au bout de quinze secondes on rend la
    // main au tracé local, qui n'a besoin de personne.
    const timer = setTimeout(fail, 15_000);

    (async () => {
      try {
        const maplibre = await import("maplibre-gl");
        if (cancelled || !container.current) return;

        const instance = new maplibre.Map({
          container: container.current,
          style: "https://tiles.openfreemap.org/styles/liberty",
          center: [4.852, 45.7772],
          zoom: 13.2,
          attributionControl: { compact: true },
        });
        map = instance;

        instance.on("error", (event) => {
          // MapLibre émet `error` pour chaque ressource qui échoue — une
          // tuile isolée comprise, ce qui est la routine d'un réseau mobile
          // et ne condamne rien : la carte vit très bien avec une tuile
          // manquante. Basculer sur l'échec à la première erreur, comme le
          // faisait ce composant, jetait une carte fonctionnelle dès qu'une
          // seule requête ratait en 5G. Seul l'échec du style lui-même,
          // avant le premier rendu, est fatal : sans style, il n'y aura
          // jamais de carte.
          const detail = event as { tile?: unknown; sourceId?: string; error?: unknown };
          if (detail.tile !== undefined || detail.sourceId) {
            // Non fatal, mais pas muet : une tuile qui rate se diagnostique
            // dans la console, pas en devinant.
            console.warn("carte :", detail.sourceId ?? "tuile", detail.error);
            return;
          }
          fail();
        });

        instance.on("load", () => {
          if (cancelled) return;
          settled = true;
          clearTimeout(timer);
          instance.addSource("route", {
            type: "geojson",
            data: {
              type: "Feature",
              properties: {},
              geometry: { type: "LineString", coordinates: demoRoute },
            },
          });
          instance.addLayer({
            id: "route",
            type: "line",
            source: "route",
            layout: { "line-cap": "round", "line-join": "round" },
            paint: { "line-color": "#5ad98d", "line-width": 4 },
          });
          setState("ready");
        });
      } catch {
        fail();
      }
    })();

    return () => {
      cancelled = true;
      clearTimeout(timer);
      map?.remove();
    };
  }, [attempt]);

  if (state === "idle") {
    return (
      <div className="runmap runmap--idle">
        <RouteShape label={t.shapeAria} />
        <div className="runmap__ask">
          <h3>{t.placeholderTitle}</h3>
          <p>{t.placeholderBody}</p>
          <button type="button" className="button button--primary button--small" onClick={begin}>
            {t.load}
          </button>
        </div>
      </div>
    );
  }

  if (state === "failed") {
    return (
      <div className="runmap runmap--idle">
        <RouteShape label={t.shapeAria} />
        <div className="runmap__ask">
          <p>{t.failed}</p>
          {/* Un tunnel, un ascenseur, une antenne saturée : l'échec d'une
              carte sur un téléphone est presque toujours passager. Le
              condamner jusqu'au rechargement de la page serait dire au
              visiteur que c'est sa faute. */}
          <button type="button" className="button button--primary button--small" onClick={begin}>
            {t.retry}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="runmap">
      <div className="runmap__canvas" ref={container} role="img" aria-label={t.mapAria} />
      {state === "loading" && <div className="runmap__ask runmap__ask--overlay">{t.loading}</div>}
    </div>
  );
}
