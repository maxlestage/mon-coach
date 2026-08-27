import { useState } from "react";
import { faq } from "../data/content.ts";

export function FaqSection() {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  return (
    <section className="section" id="faq">
      <div className="shell">
        <span className="section__eyebrow">Questions</span>
        <h2 className="section__title">Ce qu'on nous demande le plus</h2>

        <div className="faq">
          {faq.map((entry, index) => {
            const isOpen = openIndex === index;
            const panelId = `faq-panel-${index}`;
            const buttonId = `faq-button-${index}`;
            return (
              <div className="faq__item" key={entry.question}>
                <h3>
                  <button
                    type="button"
                    className="faq__question"
                    id={buttonId}
                    aria-expanded={isOpen}
                    aria-controls={panelId}
                    onClick={() => setOpenIndex(isOpen ? null : index)}
                  >
                    {entry.question}
                    <span className="faq__sign" aria-hidden="true">
                      {isOpen ? "−" : "+"}
                    </span>
                  </button>
                </h3>
                <div
                  className="faq__answer"
                  id={panelId}
                  role="region"
                  aria-labelledby={buttonId}
                  hidden={!isOpen}
                >
                  {entry.answer}
                </div>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
}
