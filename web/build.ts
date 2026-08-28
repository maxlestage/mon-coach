/**
 * Construction du site statique.
 *
 * Bun sert de runtime, de bundler et de compilateur TypeScript : les points
 * d'entrée sont les pages HTML elles-mêmes, et Bun suit les `<script>` et
 * `<link>` qu'elles contiennent. Le découpage en modules partagés évite
 * d'embarquer React une fois par page.
 *
 * Après le bundle, trois choses que le graphe de modules ne voit pas :
 * les fichiers servis tels quels (robots.txt, manifeste, icônes), et le
 * service worker, généré ici parce que sa liste de précache doit contenir
 * les noms hachés que seul le build connaît.
 */

import { mkdir, readdir, rm } from "node:fs/promises";

const OUT_DIR = "./dist";

await rm(OUT_DIR, { recursive: true, force: true });

const started = performance.now();

const result = await Bun.build({
  entrypoints: [
    "./src/index.html",
    "./src/mentions-legales.html",
    "./src/confidentialite.html",
    "./src/conditions.html",
  ],
  outdir: OUT_DIR,
  target: "browser",
  minify: true,
  splitting: true,
  sourcemap: "linked",
  naming: {
    entry: "[dir]/[name].[ext]",
    chunk: "assets/[name]-[hash].[ext]",
    asset: "assets/[name]-[hash].[ext]",
  },
  define: {
    "process.env.NODE_ENV": JSON.stringify("production"),
  },
});

if (!result.success) {
  for (const log of result.logs) {
    console.error(log);
  }
  process.exit(1);
}

// ------------------------------------------------------ fichiers hors graphe

await Bun.write(`${OUT_DIR}/robots.txt`, Bun.file("./src/robots.txt"));
await Bun.write(`${OUT_DIR}/manifest.webmanifest`, Bun.file("./src/manifest.webmanifest"));
await mkdir(`${OUT_DIR}/icons`, { recursive: true });
for (const icon of await readdir("./src/icons")) {
  await Bun.write(`${OUT_DIR}/icons/${icon}`, Bun.file(`./src/icons/${icon}`));
}
// Safari demande cette adresse par convention quand on ajoute le site à
// l'écran d'accueil : pas besoin de balise, juste du bon fichier au bon endroit.
await Bun.write(`${OUT_DIR}/apple-touch-icon.png`, Bun.file("./src/icons/icon-180.png"));

// ------------------------------------------------------------ service worker

const pages = ["/", "/mentions-legales", "/confidentialite", "/conditions"];
const hashedAssets = result.outputs
  .map((artifact) => artifact.path.replace(`${process.cwd()}/dist`, ""))
  .filter((path) => path.startsWith("/assets/") && !path.endsWith(".map"))
  // MapLibre pèse près d'un mégaoctet et n'est demandé que si le visiteur
  // ouvre lui-même la carte. Le précharger imposerait ce téléchargement à
  // tout le monde, ce qui reviendrait exactement à ce que le chargement au
  // clic cherche à éviter. Il sera mis en cache s'il est réellement utilisé :
  // la règle « cache-first » sur /assets/ s'en charge à la première visite.
  .filter((path) => !path.includes("maplibre"));
const staticFiles = [
  "/manifest.webmanifest",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
  "/icons/icon-512-maskable.png",
  "/icons/icon-180.png",
  "/apple-touch-icon.png",
];

const precache = [...pages, ...hashedAssets, ...staticFiles];
// La version du cache est le condensat de son contenu : un déploiement qui
// ne change rien ne réinstalle rien, un déploiement qui change quoi que ce
// soit invalide tout l'ancien cache.
const version = new Bun.CryptoHasher("sha256")
  .update(JSON.stringify(precache))
  .digest("hex")
  .slice(0, 12);

const serviceWorker = `// Généré par build.ts — ne pas éditer à la main.
const CACHE = "mon-coach-${version}";
const PRECACHE = ${JSON.stringify(precache, null, 2)};

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(CACHE).then((cache) => cache.addAll(PRECACHE)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== CACHE).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const request = event.request;
  if (request.method !== "GET") return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  // Pages : le réseau d'abord, pour que les visiteurs voient les mises à
  // jour ; le cache en secours, pour que le site s'ouvre en avion.
  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(CACHE).then((cache) => cache.put(url.pathname, copy));
          return response;
        })
        .catch(() =>
          caches.match(url.pathname).then((hit) => hit ?? caches.match("/"))
        )
    );
    return;
  }

  // Assets condensés et fichiers statiques : le cache d'abord — un nom haché
  // ne change jamais de contenu.
  event.respondWith(
    caches.match(request).then(
      (hit) =>
        hit ??
        fetch(request).then((response) => {
          if (response.ok && url.pathname.startsWith("/assets/")) {
            const copy = response.clone();
            caches.open(CACHE).then((cache) => cache.put(request, copy));
          }
          return response;
        })
    )
  );
});
`;
await Bun.write(`${OUT_DIR}/sw.js`, serviceWorker);

// ------------------------------------------------------------------- rapport

const elapsed = Math.round(performance.now() - started);
let total = 0;

console.log(`\nSite construit en ${elapsed} ms → ${OUT_DIR} (service worker ${version})\n`);
for (const artifact of result.outputs.sort((a, b) => a.path.localeCompare(b.path))) {
  total += artifact.size;
  const name = artifact.path.replace(`${process.cwd()}/`, "");
  console.log(`  ${name.padEnd(52)} ${(artifact.size / 1024).toFixed(1).padStart(8)} ko`);
}
console.log(`  ${"total (hors statiques)".padEnd(52)} ${(total / 1024).toFixed(1).padStart(8)} ko\n`);
