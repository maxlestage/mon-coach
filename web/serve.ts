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

    let path = url.pathname === "/" ? "/index.html" : url.pathname;
    let file = Bun.file(new URL(`.${path}`, DIST));

    // Les pages ont des adresses propres : /mentions-legales sert
    // mentions-legales.html, sans extension visible dans la barre d'adresse.
    if (!(await file.exists()) && !path.includes(".")) {
      const withExtension = `${path}.html`;
      const candidate = Bun.file(new URL(`.${withExtension}`, DIST));
      if (await candidate.exists()) {
        path = withExtension;
        file = candidate;
      }
    }

    if (await file.exists()) {
      const headers: Record<string, string> = {};
      if (path.startsWith("/assets/")) {
        // Nom haché : le contenu ne changera jamais sous cette adresse.
        headers["cache-control"] = "public, max-age=31536000, immutable";
      } else if (path === "/sw.js") {
        // Le service worker décide des mises à jour de tout le reste : lui
        // ne doit jamais être servi depuis un cache HTTP périmé.
        headers["cache-control"] = "no-cache";
      } else {
        headers["cache-control"] = "no-cache";
      }
      if (path.endsWith(".webmanifest")) {
        headers["content-type"] = "application/manifest+json; charset=utf-8";
      }
      return new Response(file, { headers });
    }

    // Un asset introuvable est une erreur franche, jamais la page d'accueil :
    // servir du HTML à la place d'un script fait échouer un worker en
    // silence, et ce silence a déjà coûté un vrai bug — le worker de la
    // carte recevait la page d'accueil et mourait sans un mot.
    if (path.startsWith("/assets/")) {
      return new Response("Asset introuvable.", { status: 404 });
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
