import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { App } from "./App.tsx";

const container = document.getElementById("root");
if (!container) {
  throw new Error("Élément #root introuvable : le document est incomplet.");
}

createRoot(container).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
