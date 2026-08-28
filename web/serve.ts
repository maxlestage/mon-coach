/**
 * Sert le site déjà construit — pour vérifier en local ce qui partira en
 * production. Le développement passe plutôt par `bun run dev`, qui recharge
 * à chaud sans passer par `dist/`.
 */

const DIST = new URL("./dist/", import.meta.url);

// L'hébergeur impose le port par la variable d'environnement.
const port = Number(Bun.env["PORT"] ?? 3000);
// Et il faut écouter sur toutes les interfaces : derrière un routeur comme
// celui de Heroku, un service qui n'écoute que sur localhost est injoignable.
const hostname = Bun.env["HOST"] ?? "0.0.0.0";

const server = Bun.serve({
  port,
  hostname,
  async fetch(request) {
    const url = new URL(request.url);

    // Derrière le routeur d'un hébergeur, la connexion arrive toujours en
    // clair jusqu'au conteneur : c'est l'en-tête posé par le routeur qui dit
    // ce que le visiteur utilisait vraiment. En local l'en-tête est absent,
    // et rien n'est redirigé.
    if (request.headers.get("x-forwarded-proto") === "http") {
      url.protocol = "https:";
      return Response.redirect(url.href, 301);
    }

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
