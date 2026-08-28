/**
 * Enregistrement du service worker — importé par chaque page du site.
 *
 * L'enregistrement attend la fin du chargement : le service worker ne doit
 * jamais concourir avec le premier rendu pour la bande passante.
 */
export function registerServiceWorker(): void {
  // Le lien vers le manifeste est posé ici plutôt que dans le HTML : le
  // bundler tente de résoudre les href statiques, alors que le manifeste est
  // un fichier copié tel quel, à une adresse stable que le service worker
  // précache. Chrome lit le lien au moment où il en a besoin — l'injection
  // au chargement suffit à rendre le site installable.
  const link = document.createElement("link");
  link.rel = "manifest";
  link.href = "/manifest.webmanifest";
  document.head.appendChild(link);

  if (!("serviceWorker" in navigator)) return;
  window.addEventListener("load", () => {
    navigator.serviceWorker.register("/sw.js").catch(() => {
      // Un site sans service worker reste un site qui marche : on ne casse
      // rien et on n'affiche rien — la visite suivante retentera.
    });
  });
}
