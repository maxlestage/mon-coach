import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { SiteChrome } from "./components/SiteChrome.tsx";
import { Confidentialite } from "./pages/Confidentialite.tsx";
import { registerServiceWorker } from "./pwa.ts";

const container = document.getElementById("root");
if (!container) throw new Error("Élément #root introuvable.");

registerServiceWorker();

createRoot(container).render(
  <StrictMode>
    <SiteChrome>
      <Confidentialite />
    </SiteChrome>
  </StrictMode>,
);
