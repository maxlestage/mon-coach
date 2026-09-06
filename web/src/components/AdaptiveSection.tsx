import { useCopy } from "../i18n/language.tsx";

interface Entry {
  readonly title: string;
  readonly body: string;
}

const copy = {
  fr: {
    eyebrow: "Handicap",
    title: "Le catalogue savait ce qu'un exercice charge. Pas ce qu'il faut pouvoir faire pour l'exécuter.",
    lede: "Une épaule douloureuse et un côté qui ne répond plus ne sont pas le même problème. Le premier est un exercice à remplacer, le second un mouvement impossible. Tant que le moteur ne distinguait pas les deux, il prescrivait des squats barre à quelqu'un qui ne se lève pas.",

    demandsTitle: "Ce que chaque mouvement déclare maintenant",
    demandsLede: "Les quatre-vingt-douze mouvements du catalogue disent ce qu'ils exigent du corps. « Un bras » et « les deux bras » sont deux exigences distinctes, et c'est la distinction qui porte tout le reste : sans elle, une presse à une jambe n'exigeait rien et se retrouvait proposée à quelqu'un dont aucune jambe ne répond.",
    demands: [
      "Tenir debout",
      "Une jambe",
      "Les deux jambes",
      "Un bras",
      "Les deux bras",
      "Une barre à deux mains",
      "Aller au sol et se relever",
      "L'équilibre en mouvement",
    ],

    situationsTitle: "Ce qui se déclare, et ce que ça change",
    situations: [
      { title: "Hémiplégie", body: "Le côté atteint se précise. Ne restent que les mouvements qu'un seul côté peut mener : haltère, poulie, machine à un bras, presse à une jambe. La barre disparaît, les charges sont proposées pour le côté qui travaille." },
      { title: "Paraplégie", body: "Tout le travail se fait assis. Le haut du corps garde son programme entier, les jambes sortent du calcul de volume, et les sports proposés roulent au lieu de courir." },
      { title: "Tétraplégie", body: "Rien qui exige une prise ferme à deux mains ni un transfert au sol. Les bras restent : les retirer aussi aurait vidé l'application au nom de la prudence, ce qui n'aide personne." },
      { title: "Amputation", body: "Membre supérieur : la barre et les mouvements à deux bras sortent, le reste est entier. Membre inférieur : une prothèse tient debout, elle ne fournit pas — le travail à une jambe reste." },
      { title: "Mobilité réduite", body: "Rien qui demande de tenir debout longtemps ni de descendre au sol. Assis, appuyé, guidé : le programme continue, il change de position." },
      { title: "Fauteuil", body: "Se déclare à part des situations, et ce n'est pas un détail : on peut rouler sans être paraplégique, et être paraplégique en marchant appareillé. Le fauteuil dit où se passe la séance, pas ce que valent les jambes." },
    ],

    holeTitle: "Filtrer ne suffisait pas",
    holeBody: "Un test écrit comme une vérification de routine a échoué sur cinq muscles à la fois. Pour quelqu'un dont un seul côté travaille, le catalogue commun n'avait plus rien du tout pour les pectoraux, les triceps, les deltoïdes postérieurs, les ischio-jambiers ni les mollets : chacun n'y était servi que par des mouvements à deux bras ou à deux jambes. Un programme amputé de cinq muscles n'est pas un programme adapté, c'est un programme cassé.",
    holeAnswer: "Soixante-deux mouvements existent pour ça et n'apparaissent nulle part ailleurs. Machine, poulie, haltère, kettlebell, barre de traction, élastique — et le poids du corps seul, avec une table, un mur, une chaise et une serviette. La garantie tient en une phrase : ce que ton corps peut encore travailler ne dépend pas de ce que tu possèdes. Elle est vérifiée sur le poids du corps seul puis sur le poids du corps plus chaque accessoire, et elle a coûté trois passages. Le premier ne mesurait qu'une salle complète : onze muscles restaient vides à qui n'a que des élastiques. Le deuxième ne mesurait que trois lots : quelqu'un en fauteuil s'entraînant chez lui n'avait ni dos, ni dorsaux, ni gainage, parce que tous les tirages au poids du corps passaient par le sol. Une garantie qui ne s'énonce pas sur toutes les entrées ne se vérifie sur aucune.",

    programTitle: "Le programme, pas seulement la liste",
    program: [
      { title: "Les journées vides disparaissent", body: "Une journée « jambes » sans un seul exercice de jambe disponible ne produit pas une séance légère : elle produit une séance vide. Les séances se répartissent sur ce qui reste — quatre séances de haut du corps valent mieux que deux séances et deux trous." },
      { title: "Ce que le catalogue ne sait pas faire est dit", body: "Les muscles sans un seul mouvement disponible sortent du budget au lieu d'y figurer à zéro, et l'écran le nomme. Le taire aurait laissé quelqu'un chercher pendant des semaines pourquoi ses ischio-jambiers n'apparaissent jamais." },
      { title: "Les séries retirées ne vont nulle part", body: "Le budget de chaque muscle est calé sur ce qu'il récupère. Lui verser les séries d'un autre le pousserait au-delà pour la seule raison qu'il restait de la place dans un tableau. Le volume hebdomadaire baisse, et c'est la réponse juste." },
    ],

    overrideTitle: "Le dernier mot te revient",
    overrideBody: "Tout ce qui est retiré peut être rendu, depuis le même écran. Un interrupteur « je m'entraîne quand même des deux côtés » ramène la barre, le développé à deux bras et les mouvements à deux jambes — en plus du travail à un seul côté, pas à sa place. Tenir debout, aller au sol, l'équilibre sous charge se réautorisent séparément, parce que ce sont des questions différentes. Deux hémiplégies ne se ressemblent pas : l'une ne lève pas le bras, l'autre le lève moins fort, et la seconde a de très bonnes raisons de travailler les deux côtés — c'est même souvent ce qu'on lui demande de faire. Une application qui déciderait seule que c'est impossible se tromperait de rôle. Une seule mise en garde accompagne le réglage : sur un mouvement à deux côtés, la charge se règle sur le côté le plus faible, c'est lui qui finit la série.",
    nothingTitle: "Ce qui ne retire aucun exercice",
    nothingBody: "Une déficience visuelle, auditive ou mentale ne fait disparaître aucun mouvement du programme. Aucune n'empêche un geste — elles changent la façon dont il est annoncé, pas la possibilité de le faire. En écarter « par prudence » aurait été une façon polie de décider à la place de quelqu'un. L'écran le dit explicitement, plutôt que de laisser croire à un filtrage silencieux.",

    sportsTitle: "Et les sports",
    sportsBody: "Onze sports adaptés vivent dans la même liste que les soixante-dix autres, pas dans une application à part : marche adaptée, fauteuil, fauteuil de course, handbike, tricycle adapté, natation adaptée, renforcement assis, mobilité assise, basket fauteuil, tennis fauteuil, boccia. La montre bascule en vrai mode fauteuil et compte les poussées au lieu des pas. Chaque situation déclarée met devant ceux qui lui correspondent, démarrables depuis l'écran.",

    reserve: "Une réserve, et elle compte. Stride mesure ce que tu fais et construit un programme d'entraînement. Elle n'encadre pas une rééducation, ne remplace ni un kinésithérapeute ni un médecin, et ne connaît pas ton dossier. Une douleur, une spasticité ou une fatigue inhabituelle se dit à eux, pas à un écran. Comme le reste du profil, ce qui est déclaré ici ne quitte pas le téléphone : aucun serveur, aucune statistique, aucun partage.",
  },

  en: {
    eyebrow: "Disability",
    title: "The catalogue knew what an exercise loads. Not what you must be able to do to perform it.",
    lede: "A painful shoulder and a side that no longer responds are not the same problem. The first is an exercise to replace, the second a movement that is impossible. As long as the engine could not tell them apart, it prescribed barbell squats to someone who does not stand.",

    demandsTitle: "What every movement now declares",
    demandsLede: "All ninety-two movements in the catalogue state what they demand of the body. “One arm” and “both arms” are two distinct demands, and that distinction carries everything else: without it a single-leg press demanded nothing and ended up offered to someone whose legs do not respond.",
    demands: [
      "Standing",
      "One leg",
      "Both legs",
      "One arm",
      "Both arms",
      "A bar in both hands",
      "Getting to the floor and up",
      "Balance under load",
    ],

    situationsTitle: "What you declare, and what it changes",
    situations: [
      { title: "Hemiplegia", body: "The affected side is named. Only movements one side can carry remain: dumbbell, cable, single-arm machine, single-leg press. The barbell goes, and loads are prescribed for the side that works." },
      { title: "Paraplegia", body: "Everything is done seated. The upper body keeps its full programme, the legs leave the volume budget, and the sports offered roll instead of run." },
      { title: "Tetraplegia", body: "Nothing that needs a firm two-handed grip or a transfer to the floor. The arms stay: removing them too would have emptied the app in the name of caution, which helps nobody." },
      { title: "Amputation", body: "Upper limb: the barbell and two-armed movements go, the rest is whole. Lower limb: a prosthesis stands, it does not drive — single-leg work stays." },
      { title: "Reduced mobility", body: "Nothing that needs long standing or getting down to the floor. Seated, supported, guided: the programme continues, it changes position." },
      { title: "Wheelchair", body: "Declared separately from the situations, and that is not a detail: you can roll without being paraplegic, and be paraplegic while walking with braces. The chair says where the session happens, not what the legs can do." },
    ],

    holeTitle: "Filtering was not enough",
    holeBody: "A test written as a routine check failed on five muscles at once. For someone with one working side, the common catalogue had nothing at all left for the chest, triceps, rear delts, hamstrings or calves: each was served only by two-armed or two-legged movements. A programme missing five muscles is not an adapted programme, it is a broken one.",
    holeAnswer: "Sixty-two movements exist for this and appear nowhere else. Machine, cable, dumbbell, kettlebell, pull-up bar, band — and bodyweight alone, with a table, a wall, a chair and a towel. The guarantee fits in one sentence: what your body can still train does not depend on what you own. It is verified on bodyweight alone, then on bodyweight plus each accessory, and it took three passes. The first measured only a full gym: eleven muscles stayed empty for anyone with just bands. The second measured only three kits: a wheelchair user training at home had no back, no lats and no core, because every bodyweight pull went through the floor. A guarantee that is not stated over every input is verified on none.",

    programTitle: "The programme, not just the list",
    program: [
      { title: "Empty days disappear", body: "A leg day with no leg exercise available does not produce a light session: it produces an empty one. Sessions spread over what remains — four upper-body sessions beat two sessions and two gaps." },
      { title: "What the catalogue cannot do is said", body: "Muscles with no available movement leave the budget rather than showing up at zero, and the screen names them. Staying silent would have left someone searching for weeks for why their hamstrings never appear." },
      { title: "Removed sets go nowhere", body: "Each muscle's budget is set by what it recovers from. Pouring another's sets into it would push it past that for the sole reason that a table had room. Weekly volume drops, and that is the right answer." },
    ],

    overrideTitle: "The last word is yours",
    overrideBody: "Everything that is removed can be given back, from the same screen. A single switch — “train both sides anyway” — brings back the barbell, two-armed presses and two-legged movements, on top of the single-side work rather than instead of it. Standing, getting to the floor and balance under load are re-enabled separately, because they are different questions. Two hemiplegias are not alike: one does not raise the arm, the other raises it less strongly, and the second has very good reasons to train both sides — it is often exactly what they are told to do. An app that decided alone that this is impossible would be overstepping. One caveat comes with the setting: on a two-sided movement the load is set by the weaker side, it is the one that finishes the set.",
    nothingTitle: "What removes no exercise at all",
    nothingBody: "A visual, hearing or intellectual disability removes no movement from the programme. None of them prevents a gesture — they change how it is announced, not whether it can be done. Removing some out of caution would have been a polite way of deciding for someone. The screen says so explicitly, rather than implying a silent filter.",

    sportsTitle: "And the sports",
    sportsBody: "Eleven adaptive sports live in the same list as the other seventy, not in a separate app: adaptive walking, wheelchair, wheelchair racing, handcycling, adaptive tricycle, adaptive swimming, seated strength, seated mobility, wheelchair basketball, wheelchair tennis, boccia. The watch switches to a real wheelchair mode and counts pushes instead of steps. Each declared situation puts the matching ones first, startable from the screen.",

    reserve: "One caveat, and it matters. Stride measures what you do and builds a training programme. It does not supervise rehabilitation, replaces neither a physiotherapist nor a doctor, and knows nothing of your medical file. Pain, spasticity or unusual fatigue belongs with them, not with a screen. Like the rest of your profile, what you declare here never leaves the phone: no server, no analytics, no sharing.",
  },

  es: {
    eyebrow: "Discapacidad",
    title: "El catálogo sabía lo que carga un ejercicio. No lo que hay que poder hacer para ejecutarlo.",
    lede: "Un hombro dolorido y un lado que ya no responde no son el mismo problema. El primero es un ejercicio que sustituir, el segundo un movimiento imposible. Mientras el motor no distinguió ambos, prescribía sentadillas con barra a quien no se levanta.",

    demandsTitle: "Lo que declara ahora cada movimiento",
    demandsLede: "Los noventa y dos movimientos del catálogo dicen lo que exigen del cuerpo. «Un brazo» y «ambos brazos» son dos exigencias distintas, y esa distinción sostiene todo lo demás: sin ella, una prensa a una pierna no exigía nada y acababa propuesta a alguien cuyas piernas no responden.",
    demands: [
      "Estar de pie",
      "Una pierna",
      "Ambas piernas",
      "Un brazo",
      "Ambos brazos",
      "Una barra con ambas manos",
      "Bajar al suelo y levantarse",
      "Equilibrio en movimiento",
    ],

    situationsTitle: "Lo que se declara, y lo que cambia",
    situations: [
      { title: "Hemiplejía", body: "Se precisa el lado afectado. Solo quedan los movimientos que un lado puede llevar: mancuerna, polea, máquina a un brazo, prensa a una pierna. La barra desaparece y las cargas se proponen para el lado que trabaja." },
      { title: "Paraplejía", body: "Todo el trabajo se hace sentado. El tren superior conserva su programa entero, las piernas salen del cálculo de volumen y los deportes propuestos ruedan en lugar de correr." },
      { title: "Tetraplejía", body: "Nada que exija un agarre firme a dos manos ni un traslado al suelo. Los brazos se quedan: retirarlos también habría vaciado la aplicación en nombre de la prudencia, lo que no ayuda a nadie." },
      { title: "Amputación", body: "Miembro superior: la barra y los movimientos a dos brazos salen, el resto queda entero. Miembro inferior: una prótesis sostiene, no impulsa — el trabajo a una pierna se mantiene." },
      { title: "Movilidad reducida", body: "Nada que exija estar de pie mucho tiempo ni bajar al suelo. Sentado, apoyado, guiado: el programa continúa, cambia de posición." },
      { title: "Silla de ruedas", body: "Se declara aparte de las situaciones, y no es un detalle: se puede rodar sin ser parapléjico, y ser parapléjico caminando con ortesis. La silla dice dónde ocurre la sesión, no lo que pueden las piernas." },
    ],

    holeTitle: "Filtrar no bastaba",
    holeBody: "Una prueba escrita como una verificación de rutina falló en cinco músculos a la vez. Para quien solo trabaja un lado, el catálogo común ya no tenía absolutamente nada para pectorales, tríceps, deltoides posteriores, isquiotibiales ni gemelos: cada uno estaba servido únicamente por movimientos a dos brazos o a dos piernas. Un programa sin cinco músculos no es un programa adaptado, es un programa roto.",
    holeAnswer: "Sesenta y dos movimientos existen para eso y no aparecen en ningún otro sitio. Máquina, polea, mancuerna, pesa rusa, barra de dominadas, banda — y el peso del cuerpo solo, con una mesa, una pared, una silla y una toalla. La garantía cabe en una frase: lo que tu cuerpo aún puede entrenar no depende de lo que poseas. Se verifica con el peso del cuerpo solo y luego con el peso del cuerpo más cada accesorio, y costó tres intentos. El primero solo medía un gimnasio completo: once músculos quedaban vacíos para quien solo tiene bandas. El segundo solo medía tres equipos: quien va en silla y entrena en casa no tenía ni espalda, ni dorsales, ni core, porque todos los tirones a peso corporal pasaban por el suelo. Una garantía que no se enuncia sobre todas las entradas no se verifica en ninguna.",

    programTitle: "El programa, no solo la lista",
    program: [
      { title: "Los días vacíos desaparecen", body: "Un día de piernas sin un solo ejercicio de pierna disponible no produce una sesión ligera: produce una sesión vacía. Las sesiones se reparten sobre lo que queda — cuatro sesiones de tren superior valen más que dos sesiones y dos huecos." },
      { title: "Lo que el catálogo no sabe hacer se dice", body: "Los músculos sin ningún movimiento disponible salen del cálculo en lugar de aparecer a cero, y la pantalla los nombra. Callarlo habría dejado a alguien buscando durante semanas por qué sus isquiotibiales no aparecen nunca." },
      { title: "Las series retiradas no van a ninguna parte", body: "El presupuesto de cada músculo está ajustado a lo que recupera. Verterle las series de otro lo empujaría más allá solo porque quedaba sitio en una tabla. El volumen semanal baja, y esa es la respuesta correcta." },
    ],

    overrideTitle: "La última palabra es tuya",
    overrideBody: "Todo lo que se retira puede devolverse, desde la misma pantalla. Un interruptor — «entrenar de todos modos los dos lados» — devuelve la barra, los press a dos brazos y los movimientos a dos piernas, además del trabajo a un solo lado, no en su lugar. Estar de pie, bajar al suelo y el equilibrio bajo carga se vuelven a permitir por separado, porque son preguntas distintas. Dos hemiplejías no se parecen: una no levanta el brazo, la otra lo levanta con menos fuerza, y la segunda tiene muy buenas razones para entrenar los dos lados — a menudo es justo lo que se le pide. Una aplicación que decidiera sola que eso es imposible se equivocaría de papel. Una sola advertencia acompaña el ajuste: en un movimiento a dos lados la carga la marca el lado más débil, es el que termina la serie.",
    nothingTitle: "Lo que no retira ningún ejercicio",
    nothingBody: "Una discapacidad visual, auditiva o intelectual no hace desaparecer ningún movimiento del programa. Ninguna impide un gesto: cambian cómo se anuncia, no la posibilidad de hacerlo. Quitarlos «por prudencia» habría sido una forma educada de decidir por alguien. La pantalla lo dice explícitamente, en vez de sugerir un filtrado silencioso.",

    sportsTitle: "Y los deportes",
    sportsBody: "Once deportes adaptados viven en la misma lista que los otros setenta, no en una aplicación aparte: marcha adaptada, silla de ruedas, silla de carreras, handbike, triciclo adaptado, natación adaptada, fuerza sentado, movilidad sentado, baloncesto en silla, tenis en silla, boccia. El reloj pasa a un modo silla de ruedas real y cuenta impulsos en vez de pasos. Cada situación declarada pone delante los que le corresponden, iniciables desde la pantalla.",

    reserve: "Una reserva, y cuenta. Stride mide lo que haces y construye un programa de entrenamiento. No dirige una rehabilitación, no sustituye ni a un fisioterapeuta ni a un médico, y no conoce tu historial. Un dolor, una espasticidad o un cansancio inhabitual se le dice a ellos, no a una pantalla. Como el resto del perfil, lo que se declara aquí no sale del teléfono: ningún servidor, ninguna estadística, ningún envío.",
  },
} as const;

export function AdaptiveSection() {
  const t = useCopy(copy);

  return (
    <section className="section" id="handicap">
      <div className="shell">
        <span className="section__eyebrow">{t.eyebrow}</span>
        <h2 className="section__title">{t.title}</h2>
        <p className="section__lede">{t.lede}</p>

        <h3 className="section__subtitle">{t.demandsTitle}</h3>
        <article className="card">
          <p className="card__body">{t.demandsLede}</p>
          <ul className="card__list">
            {(t.demands as readonly string[]).map((demand) => (
              <li className="chip" key={demand}>
                {demand}
              </li>
            ))}
          </ul>
        </article>

        <h3 className="section__subtitle">{t.situationsTitle}</h3>
        <div className="grid grid--3">
          {(t.situations as readonly Entry[]).map((situation) => (
            <article className="card" key={situation.title}>
              <h4 className="card__title">{situation.title}</h4>
              <p className="card__body">{situation.body}</p>
            </article>
          ))}
        </div>

        <h3 className="section__subtitle">{t.holeTitle}</h3>
        <div className="grid grid--2">
          <article className="card">
            <p className="card__body">{t.holeBody}</p>
          </article>
          <article className="card">
            <p className="card__body">{t.holeAnswer}</p>
          </article>
        </div>

        <h3 className="section__subtitle">{t.programTitle}</h3>
        <div className="grid grid--3">
          {(t.program as readonly Entry[]).map((entry) => (
            <article className="card" key={entry.title}>
              <h4 className="card__title">{entry.title}</h4>
              <p className="card__body">{entry.body}</p>
            </article>
          ))}
        </div>

        <h3 className="section__subtitle">{t.overrideTitle}</h3>
        <article className="card">
          <p className="card__body">{t.overrideBody}</p>
        </article>

        <h3 className="section__subtitle">{t.nothingTitle}</h3>
        <div className="grid grid--2">
          <article className="card">
            <p className="card__body">{t.nothingBody}</p>
          </article>
          <article className="card">
            <h4 className="card__title">{t.sportsTitle}</h4>
            <p className="card__body">{t.sportsBody}</p>
          </article>
        </div>

        <p className="disclaimer">{t.reserve}</p>
      </div>
    </section>
  );
}
