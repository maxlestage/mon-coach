import { useCopy } from "../i18n/language.tsx";

interface Tier {
  readonly label: string;
  readonly tone: "base" | "moderate" | "occasional";
  readonly foods: readonly string[];
  readonly why: string;
}

const copy = {
  fr: {
    eyebrow: "Alimentation",
    title: "Des macros, c'est bien. Une assiette, c'est mieux.",
    lede: "L'application ne se contente pas de donner des calories et des grammes : elle construit ta journée, repas par repas, avec des quantités pesables et des aliments qu'on trouve dans n'importe quel magasin. Chaque aliment du catalogue porte la raison de son rang — parce qu'une consigne sans raison ne tient pas six mois.",
    tiers: [
      {
        label: "À privilégier",
        tone: "base" as const,
        foods: ["Blanc de poulet", "Cabillaud", "Lentilles cuites", "Skyr 0 %", "Œufs entiers", "Pommes de terre", "Flocons d'avoine", "Brocoli", "Huile d'olive"],
        why: "Beaucoup de protéines, de fibres et de micronutriments pour peu de calories. Ils rassasient avant de faire dépasser le total.",
      },
      {
        label: "Avec modération",
        tone: "moderate" as const,
        foods: ["Riz blanc", "Pain blanc", "Fromage à pâte dure", "Purée de cacahuète", "Beurre", "Raisin", "Dattes"],
        why: "Utiles, mais denses en calories ou pauvres en fibres. Ils se pèsent au lieu de se servir à l'œil : c'est la seule différence avec le rang du dessus.",
      },
      {
        label: "Occasionnel",
        tone: "occasional" as const,
        foods: ["Soda", "Chips", "Viennoiserie", "Charcuterie", "Biscuits industriels", "Bière"],
        why: "Beaucoup de calories, peu de rassasiement. Rien n'est interdit : au-delà d'environ 10 % des calories de la semaine, ces aliments prennent simplement la place de ceux qui font le travail.",
      },
    ],
    swapsTitle: "Les échanges qui changent une journée",
    swaps: [
      { from: "Soda", to: "Eau", gain: "−139 kcal", why: "Des calories qui ne rassasient pas du tout : le corps ne les déduit pas au repas suivant." },
      { from: "Riz blanc", to: "Pommes de terre", gain: "−108 kcal", why: "À calories égales, la pomme de terre rassasie nettement plus longtemps. C'est l'aliment le mieux classé sur l'indice de satiété." },
      { from: "Charcuterie", to: "Blanc de poulet", gain: "+18 g de protéines", why: "Le double de protéines, le tiers des calories, et on sort de la seule catégorie d'aliments classée cancérogène avérée." },
      { from: "Jus de fruit", to: "Orange entière", gain: "+4 g de fibres", why: "Le fruit entier apporte les fibres que le jus laisse derrière lui, et il se mâche : le cerveau enregistre qu'on a mangé." },
    ],
    guidedEyebrow: "Pour qui débute",
    guidedTitle: "Apprendre un mouvement sans regarder une vidéo",
    guidedLede: "Une vidéo montre un mouvement réussi ; elle ne dit pas ce que tu es en train de rater, ni ce que tu devrais sentir. Le mode guidé déroule chaque mouvement étape par étape, avec des repères vérifiables sur toi-même — sans miroir, sans caméra, sans réseau.",
    guidedSteps: [
      { title: "Une étape à la fois", body: "Placement, gainage, descente, remontée. On avance quand l'étape est comprise, pas quand la vidéo est finie." },
      { title: "Un repère par étape", body: "« Tes talons restent au sol du début à la fin. » Une chose vérifiable seul, immédiatement, sans se filmer." },
      { title: "Les erreurs par la sensation", body: "« Tu bascules vers l'avant et tu finis sur les orteils » — puis la cause, puis la correction. Personne ne se voit de dos ; tout le monde sait où ça tire." },
      { title: "Cinq semaines pour démarrer", body: "Apprendre les gestes, trouver sa charge, tenir le rythme, apprendre à lire son effort. La progression commence en semaine 5, sur des bases qui tiennent." },
    ],
  },
  en: {
    eyebrow: "Food",
    title: "Macros are fine. A plate is better.",
    lede: "The app does not stop at calories and grams: it builds your day, meal by meal, with weighable amounts and food you can find in any shop. Every item in the catalogue carries the reason for its tier — because a rule without a reason does not survive six months.",
    tiers: [
      {
        label: "Build meals on these",
        tone: "base" as const,
        foods: ["Chicken breast", "Cod", "Cooked lentils", "0 % skyr", "Whole eggs", "Potatoes", "Rolled oats", "Broccoli", "Olive oil"],
        why: "Plenty of protein, fibre and micronutrients per calorie. They fill you up before they blow your total.",
      },
      {
        label: "In moderation",
        tone: "moderate" as const,
        foods: ["White rice", "White bread", "Hard cheese", "Peanut butter", "Butter", "Grapes", "Dates"],
        why: "Useful, but calorie-dense or short on fibre. Weigh them instead of eyeballing them — that is the only real difference from the tier above.",
      },
      {
        label: "Occasional",
        tone: "occasional" as const,
        foods: ["Soft drinks", "Crisps", "Pastries", "Deli meat", "Packaged biscuits", "Beer"],
        why: "Lots of calories, little fullness. Nothing is banned: past roughly 10 % of the week's calories, these simply crowd out the food doing the work.",
      },
    ],
    swapsTitle: "The swaps that change a day",
    swaps: [
      { from: "Soft drink", to: "Water", gain: "−139 kcal", why: "Calories that do not fill you up at all: the body fails to count them at the next meal." },
      { from: "White rice", to: "Potatoes", gain: "−108 kcal", why: "Calorie for calorie, potato keeps you full much longer. It tops the satiety index." },
      { from: "Deli meat", to: "Chicken breast", gain: "+18 g protein", why: "Twice the protein, a third of the calories, and out of the one food category rated a proven carcinogen." },
      { from: "Fruit juice", to: "Whole orange", gain: "+4 g fibre", why: "Whole fruit brings the fibre the juice leaves behind, and it has to be chewed: the brain registers that you ate." },
    ],
    guidedEyebrow: "For beginners",
    guidedTitle: "Learning a movement without watching a video",
    guidedLede: "A video shows a movement done right; it does not tell you what you are getting wrong, or what you should be feeling. Guided mode walks through every movement step by step, with checkpoints you can verify on yourself — no mirror, no camera, no connection.",
    guidedSteps: [
      { title: "One step at a time", body: "Setup, brace, descent, drive. You move on when the step makes sense, not when the video ends." },
      { title: "One checkpoint per step", body: "“Your heels stay down from start to finish.” One thing you can verify alone, immediately, without filming yourself." },
      { title: "Mistakes by sensation", body: "“You tip forward and end up on your toes” — then the cause, then the fix. Nobody sees their own back; everybody knows where it pulls." },
      { title: "Five weeks to start", body: "Learn the movements, find your load, hold the rhythm, learn to read your effort. Progression starts in week 5, on foundations that hold." },
    ],
  },
  es: {
    eyebrow: "Alimentación",
    title: "Los macros están bien. Un plato, mejor.",
    lede: "La aplicación no se queda en calorías y gramos: construye tu día, comida a comida, con cantidades pesables y alimentos que se encuentran en cualquier tienda. Cada alimento del catálogo lleva la razón de su nivel, porque una norma sin razón no aguanta seis meses.",
    tiers: [
      {
        label: "Para priorizar",
        tone: "base" as const,
        foods: ["Pechuga de pollo", "Bacalao", "Lentejas cocidas", "Skyr 0 %", "Huevos enteros", "Patatas", "Copos de avena", "Brócoli", "Aceite de oliva"],
        why: "Mucha proteína, fibra y micronutrientes por caloría. Sacian antes de disparar el total.",
      },
      {
        label: "Con moderación",
        tone: "moderate" as const,
        foods: ["Arroz blanco", "Pan blanco", "Queso curado", "Crema de cacahuete", "Mantequilla", "Uvas", "Dátiles"],
        why: "Útiles, pero densos en calorías o pobres en fibra. Se pesan en lugar de servirse a ojo: esa es la única diferencia con el nivel anterior.",
      },
      {
        label: "Ocasional",
        tone: "occasional" as const,
        foods: ["Refrescos", "Patatas de bolsa", "Bollería", "Embutidos", "Galletas industriales", "Cerveza"],
        why: "Muchas calorías, poca saciedad. Nada está prohibido: más allá de un 10 % de las calorías semanales, desplazan a los alimentos que hacen el trabajo.",
      },
    ],
    swapsTitle: "Los cambios que transforman un día",
    swaps: [
      { from: "Refresco", to: "Agua", gain: "−139 kcal", why: "Calorías que no sacian nada: el cuerpo no las descuenta en la comida siguiente." },
      { from: "Arroz blanco", to: "Patatas", gain: "−108 kcal", why: "A igualdad de calorías, la patata sacia mucho más. Encabeza el índice de saciedad." },
      { from: "Embutido", to: "Pechuga de pollo", gain: "+18 g de proteína", why: "El doble de proteína, un tercio de las calorías, y fuera de la única categoría de alimentos clasificada como cancerígeno probado." },
      { from: "Zumo de fruta", to: "Naranja entera", gain: "+4 g de fibra", why: "La fruta entera aporta la fibra que el zumo deja atrás, y se mastica: el cerebro registra que has comido." },
    ],
    guidedEyebrow: "Para quien empieza",
    guidedTitle: "Aprender un movimiento sin ver un vídeo",
    guidedLede: "Un vídeo muestra un movimiento bien hecho; no te dice qué estás fallando ni qué deberías sentir. El modo guiado desglosa cada movimiento paso a paso, con referencias que puedes comprobar en ti mismo, sin espejo, sin cámara y sin conexión.",
    guidedSteps: [
      { title: "Un paso cada vez", body: "Colocación, activación, bajada, subida. Avanzas cuando entiendes el paso, no cuando termina el vídeo." },
      { title: "Una referencia por paso", body: "«Los talones no se despegan en ningún momento.» Algo comprobable solo, al instante, sin grabarte." },
      { title: "Los errores por la sensación", body: "«Te vas hacia delante y acabas sobre los dedos», y luego la causa y la corrección. Nadie se ve la espalda; todo el mundo sabe dónde le tira." },
      { title: "Cinco semanas para arrancar", body: "Aprender los gestos, encontrar tu carga, mantener el ritmo, aprender a medir el esfuerzo. La progresión empieza en la semana 5, sobre bases que aguantan." },
    ],
  },
} as const;

export function FoodSection() {
  const t = useCopy(copy);

  return (
    <>
      <section className="section" id="alimentation">
        <div className="shell">
          <span className="section__eyebrow">{t.eyebrow}</span>
          <h2 className="section__title">{t.title}</h2>
          <p className="section__lede">{t.lede}</p>

          <div className="grid grid--3">
            {(t.tiers as readonly Tier[]).map((tier) => (
              <article className={`card card--tier card--tier-${tier.tone}`} key={tier.label}>
                <h3 className="card__title">{tier.label}</h3>
                <ul className="card__list">
                  {tier.foods.map((food) => (
                    <li className="chip" key={food}>
                      {food}
                    </li>
                  ))}
                </ul>
                <p className="card__body">{tier.why}</p>
              </article>
            ))}
          </div>

          <h3 className="section__subtitle">{t.swapsTitle}</h3>
          <div className="swaps">
            {t.swaps.map((swap) => (
              <article className="swap" key={swap.from}>
                <div className="swap__head">
                  <span className="swap__from">{swap.from}</span>
                  <span className="swap__arrow" aria-hidden="true">→</span>
                  <span className="swap__to">{swap.to}</span>
                </div>
                <span className="swap__gain">{swap.gain}</span>
                <p className="swap__why">{swap.why}</p>
              </article>
            ))}
          </div>
        </div>
      </section>

      <section className="section" id="mode-guide">
        <div className="shell">
          <span className="section__eyebrow">{t.guidedEyebrow}</span>
          <h2 className="section__title">{t.guidedTitle}</h2>
          <p className="section__lede">{t.guidedLede}</p>

          <div className="grid grid--4">
            {t.guidedSteps.map((step) => (
              <article className="card" key={step.title}>
                <h3 className="card__title">{step.title}</h3>
                <p className="card__body">{step.body}</p>
              </article>
            ))}
          </div>
        </div>
      </section>
    </>
  );
}
