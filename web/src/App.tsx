import { useMemo } from "react";
import { AdaptationSection } from "./components/AdaptationSection.tsx";
import { FaqSection } from "./components/FaqSection.tsx";
import { Footer } from "./components/Footer.tsx";
import { Header } from "./components/Header.tsx";
import { Hero } from "./components/Hero.tsx";
import { InputsSection } from "./components/InputsSection.tsx";
import { PipelineSection } from "./components/PipelineSection.tsx";
import { PricingSection } from "./components/PricingSection.tsx";
import { PrivacySection } from "./components/PrivacySection.tsx";
import { Simulator, defaultInput } from "./components/Simulator.tsx";
import { WatchSection } from "./components/WatchSection.tsx";
import { RunningSection } from "./components/RunningSection.tsx";
import { FoodSection } from "./components/FoodSection.tsx";
import { TechniqueSection } from "./components/TechniqueSection.tsx";
import { GymSection } from "./components/GymSection.tsx";
import { simulate } from "./coach/engine.ts";
import { LanguageProvider } from "./i18n/language.tsx";

export function App() {
  // L'aperçu du téléphone en tête de page montre de vrais chiffres, produits
  // par le même moteur que le simulateur plus bas.
  const preview = useMemo(() => simulate(defaultInput), []);

  return (
    <LanguageProvider>
      <Header />
      <main>
        <Hero preview={preview} />
        <InputsSection />
        <PipelineSection />
        <Simulator />
        <RunningSection />
        <FoodSection />
        <TechniqueSection />
        <GymSection />
        <WatchSection />
        <AdaptationSection />
        <PricingSection />
        <PrivacySection />
        <FaqSection />
      </main>
      <Footer />
    </LanguageProvider>
  );
}
