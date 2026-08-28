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
  const container = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (state !== "loading" || !container.current) return;
    let cancelled = false;
    let map: { remove: () => void } | null = null;
    // Un style qui ne répond pas, un pare-feu d'entreprise, un navigateur
    // sans WebGL : sans limite de temps, le visiteur resterait devant
    // « chargement… » indéfiniment. Au bout de quinze secondes on rend la
    // main au tracé local, qui n'a besoin de personne.
    const timeout = setTimeout(() => {
      if (!cancelled) setState((current) => (current === "loading" ? "failed" : current));
    }, 15_000);

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

        instance.on("error", () => {
          if (!cancelled) setState("failed");
        });

        instance.on("load", () => {
          if (cancelled) return;
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
        if (!cancelled) setState("failed");
      }
    })();

    return () => {
      cancelled = true;
      clearTimeout(timeout);
      map?.remove();
    };
  }, [state]);

  if (state === "idle") {
    return (
      <div className="runmap runmap--idle">
        <RouteShape label={t.shapeAria} />
        <div className="runmap__ask">
          <h3>{t.placeholderTitle}</h3>
          <p>{t.placeholderBody}</p>
          <button type="button" className="button button--primary button--small" onClick={() => setState("loading")}>
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
