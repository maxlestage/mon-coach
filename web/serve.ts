/**
 * Sert le site déjà construit — pour vérifier en local ce qui partira en
 * production. Le développement passe plutôt par `bun run dev`, qui recharge
 * à chaud sans passer par `dist/`.
 */

const DIST = new URL("./dist/", import.meta.url);
const port = Number(Bun.env["PORT"] ?? 3000);

const server = Bun.serve({
  port,
  async fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname === "/" ? "/index.html" : url.pathname;
    const file = Bun.file(new URL(`.${path}`, DIST));

    if (await file.exists()) {
      // Les fichiers versionnés par condensat sont immuables ; le HTML, non.
      const immutable = path.startsWith("/assets/");
      return new Response(file, {
        headers: {
          "cache-control": immutable
            ? "public, max-age=31536000, immutable"
            : "no-cache",
        },
      });
    }

    // Site d'une seule page : tout le reste retombe sur le document racine.
    const index = Bun.file(new URL("./index.html", DIST));
    if (await index.exists()) {
      return new Response(index, {
        status: 404,
        headers: { "content-type": "text/html; charset=utf-8" },
      });
    }
    return new Response("Site non construit. Lance d'abord `bun run build`.", {
      status: 500,
    });
  },
});

console.log(`Site servi sur ${server.url}`);
