/**
 * Construction du site statique.
 *
 * Bun sert ici de runtime, de bundler et de compilateur TypeScript : le point
 * d'entrée est le HTML lui-même, et Bun suit les `<script>` et `<link>` qu'il
 * contient. Il n'y a pas d'autre outil de build à maintenir.
 */

import { rm } from "node:fs/promises";

const OUT_DIR = "./dist";

await rm(OUT_DIR, { recursive: true, force: true });

const started = performance.now();

const result = await Bun.build({
  entrypoints: ["./src/index.html"],
  outdir: OUT_DIR,
  target: "browser",
  minify: true,
  sourcemap: "linked",
  // Le nom des fichiers porte un condensat : ils peuvent être mis en cache
  // indéfiniment, et une mise en production invalide ce qui a changé, rien de plus.
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

// Les fichiers servis tels quels, hors du graphe de modules : Bun ne suit
// que ce que le HTML référence, il faut donc les copier explicitement.
await Bun.write(`${OUT_DIR}/robots.txt`, Bun.file("./src/robots.txt"));

const elapsed = Math.round(performance.now() - started);
let total = 0;

console.log(`\nSite construit en ${elapsed} ms → ${OUT_DIR}\n`);
for (const artifact of result.outputs.sort((a, b) => a.path.localeCompare(b.path))) {
  const size = artifact.size;
  total += size;
  const name = artifact.path.replace(`${process.cwd()}/`, "");
  console.log(`  ${name.padEnd(46)} ${(size / 1024).toFixed(1).padStart(8)} ko`);
}
console.log(`  ${"total".padEnd(46)} ${(total / 1024).toFixed(1).padStart(8)} ko\n`);
