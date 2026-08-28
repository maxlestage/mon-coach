/**
 * Vérifie la carte dans un vrai navigateur, sans dépendre du serveur de
 * tuiles : le style est intercepté et servi localement. C'est précisément le
 * chemin que le sandbox ne pouvait pas exercer — les tuiles y sont bloquées,
 * donc seul l'échec était observable, et le bug qui détruisait la carte au
 * moment où elle réussissait est resté invisible jusqu'au premier téléphone.
 *
 *   bun run build && node verify-map.mjs [chemin-chromium]
 */
import { spawn } from "node:child_process";

// Playwright local s'il est installé (CI), sinon l'installation globale de
// l'environnement de développement. Un import statique échouerait avant même
// de pouvoir essayer l'autre chemin.
const { chromium } = await import("playwright").catch(
  () => import("/opt/node22/lib/node_modules/playwright/index.mjs")
);
const { existsSync } = await import("node:fs");

const PORT = 8807;
const STYLE_URL = "https://tiles.openfreemap.org/**";

// Un style minimal, autosuffisant : un fond uni, aucune ressource externe.
const bareStyle = {
  version: 8,
  name: "test",
  sources: {},
  layers: [{ id: "bg", type: "background", paint: { "background-color": "#152218" } }],
};

// Le même, plus une source de tuiles raster qui échouera : c'est le cas
// « une tuile rate en 5G », qui ne doit PAS condamner la carte.
const styleWithDoomedTiles = {
  ...bareStyle,
  sources: {
    doomed: { type: "raster", tiles: ["https://tiles.openfreemap.org/dead/{z}/{x}/{y}.png"], tileSize: 256 },
  },
  layers: [...bareStyle.layers, { id: "doomed", type: "raster", source: "doomed" }],
};

const failures = [];
const check = (ok, label) => {
  console.log(`${ok ? "  ✓" : "  ✘"} ${label}`);
  if (!ok) failures.push(label);
};

const server = spawn("bun", ["run", "./serve.ts"], {
  env: { ...process.env, PORT: String(PORT) },
  stdio: "ignore",
});
await new Promise((resolve) => setTimeout(resolve, 1500));

// Le Chromium passé en argument, sinon celui préinstallé de l'environnement
// de développement, sinon celui que Playwright a installé lui-même (CI).
const preinstalled = "/opt/pw-browsers/chromium";
const browser = await chromium.launch({
  ...(process.argv[2]
    ? { executablePath: process.argv[2] }
    : existsSync(preinstalled)
      ? { executablePath: preinstalled }
      : {}),
  // WebGL logiciel : les machines de CI n'ont pas de GPU.
  args: ["--use-angle=swiftshader", "--enable-unsafe-swiftshader"],
});

try {
  // ------------------------------------------------- 0. WebGL est-il là ?
  {
    const page = await browser.newPage();
    const webgl = await page.evaluate(() => {
      const canvas = document.createElement("canvas");
      return Boolean(canvas.getContext("webgl2") ?? canvas.getContext("webgl"));
    });
    await page.close();
    if (!webgl) {
      console.log("WebGL indisponible dans ce navigateur : vérification impossible ici.");
      process.exit(2);
    }
  }

  // --------------------------------------- 1. le chemin succès, intercepté
  {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, locale: "fr-FR" });
    await page.route(STYLE_URL, (route) => route.fulfill({ json: bareStyle }));
    await page.goto(`http://localhost:${PORT}/`, { waitUntil: "networkidle" });

    // Les deux fichiers du worker répondent en JavaScript, pas en HTML : le
    // 404 déguisé en page d'accueil est exactement ce qui a rendu le bug
    // muet — le worker mourait sans un mot et aucune couche ne se rendait.
    for (const piece of ["maplibre-gl-worker.mjs", "maplibre-gl-shared.mjs"]) {
      const response = await page.request.get(`http://localhost:${PORT}/assets/${piece}`);
      const type = response.headers()["content-type"] ?? "";
      check(
        response.status() === 200 && type.includes("javascript"),
        `${piece} est servi (${response.status()}, ${type || "sans type"})`
      );
      // Ces fichiers changent de contenu sans changer de nom à chaque
      // version de MapLibre : immuables, ils désynchroniseraient chunk et
      // worker pendant un an de cache navigateur.
      const cache = response.headers()["cache-control"] ?? "";
      check(!cache.includes("immutable"), `${piece} n'est pas marqué immuable (${cache})`);
    }

    await page.getByRole("button", { name: "Afficher la carte OpenStreetMap" }).click();
    // La carte doit apparaître…
    await page.waitForSelector(".maplibregl-canvas", { timeout: 20_000 });
    // …passer réellement « prête » — l'overlay de chargement disparaît…
    await page.waitForSelector(".runmap__ask--overlay", { state: "detached", timeout: 20_000 });
    // …et surtout survivre : le bug détruisait la carte à l'instant où elle
    // passait « prête ». On laisse le temps au nettoyage fautif de frapper.
    await page.waitForTimeout(2_500);
    const alive = await page.evaluate(() => document.querySelector(".maplibregl-canvas") !== null);
    check(alive, "la carte se charge et reste vivante après son chargement");
    const failed = await page.getByText("La carte n'a pas pu être chargée").count();
    check(failed === 0, "aucun message d'échec sur le chemin succès");

    // Le tracé se dessine, compté en pixels : une carte sans la sortie
    // qu'elle doit montrer était le second visage de ce bug, canvas vivant,
    // zéro couche rendue. On attend le premier rendu de la couche, puis on
    // relit la capture dans un canvas 2D de la page — le canvas WebGL ne se
    // relit pas directement.
    await page.waitForTimeout(2_000);
    const shot = await page.locator(".runmap").screenshot();
    const routePixels = await page.evaluate(async (base64) => {
      const image = new Image();
      image.src = `data:image/png;base64,${base64}`;
      await image.decode();
      const canvas = document.createElement("canvas");
      canvas.width = image.width;
      canvas.height = image.height;
      const context = canvas.getContext("2d");
      if (!context) return -1;
      context.drawImage(image, 0, 0);
      const { data } = context.getImageData(0, 0, canvas.width, canvas.height);
      let count = 0;
      for (let index = 0; index < data.length; index += 4) {
        const red = data[index] ?? 0;
        const green = data[index + 1] ?? 0;
        const blue = data[index + 2] ?? 0;
        // Le vert du tracé (#5ad98d), avec la marge de l'anticrénelage.
        if (green > 150 && red < 140 && blue > 100 && blue < 190) count += 1;
      }
      return count;
    }, shot.toString("base64"));
    check(routePixels > 200, `le tracé de la sortie est dessiné (${routePixels} pixels)`);
    await page.close();
  }

  // ------------------------- 2. une tuile qui rate ne condamne pas la carte
  {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, locale: "fr-FR" });
    await page.route(STYLE_URL, (route) => {
      if (route.request().url().includes("/dead/")) return route.abort();
      return route.fulfill({ json: styleWithDoomedTiles });
    });
    await page.goto(`http://localhost:${PORT}/`, { waitUntil: "networkidle" });
    await page.getByRole("button", { name: "Afficher la carte OpenStreetMap" }).click();
    await page.waitForSelector(".maplibregl-canvas", { timeout: 20_000 });
    await page.waitForTimeout(2_500);
    const failed = await page.getByText("La carte n'a pas pu être chargée").count();
    check(failed === 0, "des tuiles en échec laissent la carte affichée");
    await page.close();
  }

  // ---------------------------------- 3. l'échec est propre, et réessayable
  {
    const page = await browser.newPage({ viewport: { width: 1280, height: 900 }, locale: "fr-FR" });
    let blocked = true;
    await page.route(STYLE_URL, (route) =>
      blocked ? route.abort() : route.fulfill({ json: bareStyle })
    );
    await page.goto(`http://localhost:${PORT}/`, { waitUntil: "networkidle" });
    await page.getByRole("button", { name: "Afficher la carte OpenStreetMap" }).click();
    await page.waitForSelector("text=La carte n'a pas pu être chargée", { timeout: 25_000 });
    check(true, "sans réseau, le repli s'affiche au lieu d'un chargement infini");

    // Le réseau revient — un tunnel, ça se termine.
    blocked = false;
    await page.getByRole("button", { name: "Réessayer" }).click();
    await page.waitForSelector(".maplibregl-canvas", { timeout: 20_000 });
    check(true, "« Réessayer » recharge la carte quand le réseau revient");
    await page.close();
  }
} finally {
  await browser.close();
  server.kill();
}

if (failures.length > 0) {
  console.error(`\n${failures.length} vérification(s) en échec.`);
  process.exit(1);
}
console.log("\nCarte vérifiée dans un vrai navigateur, chemin succès compris.");
