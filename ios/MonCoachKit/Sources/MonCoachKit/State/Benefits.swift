import Foundation

/// Un avantage de l'application, avec ce qui le rend vrai.
///
/// Pourquoi la preuve est obligatoire
/// ----------------------------------
/// « Un coach qui s'adapte à toi » ne veut rien dire : toutes les
/// applications l'écrivent, et la moitié se contente de multiplier un chiffre
/// par ton poids. Une promesse sans le mécanisme derrière est une phrase de
/// publicité, et l'athlète qui l'a crue se sent trompé au premier écran qui
/// ne suit pas.
///
/// Chaque avantage porte donc son `proof` : la règle exacte, chiffrée quand
/// elle l'est, telle qu'elle est écrite dans le moteur. Si le moteur change,
/// c'est ici que ça se voit.
public struct Benefit: Sendable, Equatable, Identifiable {
    public var id: String
    public var symbol: String
    public var title: LocalizedText
    /// Ce que ça change pour l'athlète.
    public var promise: LocalizedText
    /// Ce qui rend la promesse vraie. Le mécanisme, pas l'adjectif.
    public var proof: LocalizedText
    /// La section où ça se voit, quand il y en a une.
    public var section: AppSection?

    public init(
        id: String,
        symbol: String,
        title: LocalizedText,
        promise: LocalizedText,
        proof: LocalizedText,
        section: AppSection? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.promise = promise
        self.proof = proof
        self.section = section
    }
}

/// Ce que l'application apporte, et ce qu'elle refuse de faire.
public enum Benefits {

    public static let all: [Benefit] = [
        Benefit(
            id: "adaptive",
            symbol: "bolt.fill",
            title: LocalizedText(
                fr: "Une séance qui tient compte de ta nuit",
                en: "A session that accounts for your night",
                es: "Una sesión que tiene en cuenta tu noche"
            ),
            promise: LocalizedText(
                fr: "Le plan ne te sert pas la même chose que tu aies dormi neuf heures ou quatre.",
                en: "The plan does not serve you the same thing whether you slept nine hours or four.",
                es: "El plan no te sirve lo mismo si has dormido nueve horas o cuatro."
            ),
            proof: LocalizedText(
                fr: "Un score de forme combine sommeil, courbatures, énergie et charge des sept derniers jours. Sous le seuil, le volume du jour baisse — le nombre de séries, pas la technique ni l'amplitude.",
                en: "A readiness score combines sleep, soreness, energy and the last seven days of load. Below the threshold, today's volume drops — the number of sets, not the technique or the range.",
                es: "Una puntuación de forma combina sueño, agujetas, energía y la carga de los últimos siete días. Bajo el umbral, el volumen del día baja: el número de series, no la técnica ni el rango."
            ),
            section: .today
        ),
        Benefit(
            id: "teaches",
            symbol: "graduationcap.fill",
            title: LocalizedText(
                fr: "Apprendre les mouvements sans vidéo",
                en: "Learning the movements without video",
                es: "Aprender los movimientos sin vídeo"
            ),
            promise: LocalizedText(
                fr: "Tu sais quoi régler sur cette machine-là, et ce que tu es en train de rater.",
                en: "You know what to set on that machine, and what you are getting wrong.",
                es: "Sabes qué ajustar en esa máquina y qué estás haciendo mal."
            ),
            proof: LocalizedText(
                fr: "Quatre-vingt-douze fiches, une par mouvement : ce que c'est, les réglages précis, l'erreur propre à celui-là, la charge, le repos et les remplaçants quand l'appareil est pris. Plus onze fiches de technique par schéma moteur, avec un point de contrôle vérifiable sans miroir à chaque étape.",
                en: "Ninety-two cards, one per movement: what it is, the exact settings, the mistake that one invites, the load, the rest and the swaps when it is taken. Plus eleven technique cards by movement pattern, each step with a checkpoint you can verify without a mirror.",
                es: "Noventa y dos fichas, una por movimiento: qué es, los ajustes exactos, el error propio de ese, la carga, el descanso y los sustitutos cuando está ocupada. Más once fichas de técnica por patrón motor, cada paso con un punto de control verificable sin espejo."
            ),
            section: .plan
        ),
        Benefit(
            id: "eats",
            symbol: "fork.knife",
            title: LocalizedText(
                fr: "Manger sans tenir un journal",
                en: "Eating without keeping a diary",
                es: "Comer sin llevar un diario"
            ),
            promise: LocalizedText(
                fr: "Des repas prêts avec des quantités pesables, et une photo suffit pour savoir ce que tu as vraiment mangé.",
                en: "Ready meals with weighable amounts, and a photo is enough to know what you actually ate.",
                es: "Comidas listas con cantidades pesables, y una foto basta para saber qué has comido de verdad."
            ),
            proof: LocalizedText(
                fr: "Sept dîners différents par semaine, le déjeuner qui reprend le dîner de la veille, et une liste de courses qui tient sur une trentaine de lignes en quantités qu'un magasin vend. La reconnaissance d'assiette tourne sur le téléphone et rend une fourchette de protéines, jamais un chiffre au gramme.",
                en: "Seven different dinners a week, lunch reusing the previous night's dinner, and a shopping list of about thirty lines in amounts a shop actually sells. Plate recognition runs on the phone and returns a protein range, never a number to the gram.",
                es: "Siete cenas distintas por semana, la comida repitiendo la cena de la víspera, y una lista de la compra de unas treinta líneas en cantidades que una tienda vende. El reconocimiento de platos funciona en el teléfono y da una horquilla de proteína, nunca una cifra al gramo."
            ),
            section: .food
        ),
        Benefit(
            id: "outside",
            symbol: "figure.run",
            title: LocalizedText(
                fr: "Quarante-huit sports, mesurés chacun pour ce qu'il est",
                en: "Forty-eight sports, each measured for what it is",
                es: "Cuarenta y ocho deportes, cada uno medido por lo que es"
            ),
            promise: LocalizedText(
                fr: "Une sortie vélo n'est pas comptée comme une course, et une séance en salle n'invente pas de dénivelé.",
                en: "A ride is not counted as a run, and an indoor session does not invent elevation.",
                es: "Una salida en bici no cuenta como una carrera, y una sesión en interior no inventa desnivel."
            ),
            proof: LocalizedText(
                fr: "Chaque sport porte son coût énergétique du Compendium of Physical Activities, son mode de déplacement et son seuil de nettoyage GPS. Seules la course, le trail et le tapis nourrissent le plan de course.",
                en: "Each sport carries its energy cost from the Compendium of Physical Activities, its movement mode and its GPS cleaning threshold. Only running, trail and treadmill feed the running plan.",
                es: "Cada deporte lleva su coste energético del Compendium of Physical Activities, su modo de desplazamiento y su umbral de limpieza GPS. Solo correr, trail y cinta alimentan el plan de carrera."
            ),
            section: .running
        ),
        Benefit(
            id: "honest",
            symbol: "checkmark.seal.fill",
            title: LocalizedText(
                fr: "Des chiffres qui disent leur marge",
                en: "Numbers that state their margin",
                es: "Cifras que dicen su margen"
            ),
            promise: LocalizedText(
                fr: "Quand une mesure est approximative, elle est annoncée comme telle plutôt que présentée comme un fait.",
                en: "When a measure is approximate, it is announced as such rather than presented as a fact.",
                es: "Cuando una medida es aproximada, se anuncia como tal en vez de presentarse como un hecho."
            ),
            proof: LocalizedText(
                fr: "Les protéines d'une photo sont une fourchette. Sans capteur cardiaque, aucune zone n'est affichée. Sous trois semaines de données, aucune tendance n'est annoncée. Une trace GPS nettoyée dit combien de points ont été écartés.",
                en: "Protein from a photo is a range. With no heart-rate sensor, no zones are shown. Below three weeks of data, no trend is announced. A cleaned GPS trace says how many points were dropped.",
                es: "La proteína de una foto es una horquilla. Sin sensor cardíaco no se muestran zonas. Con menos de tres semanas de datos no se anuncia tendencia. Una traza GPS limpiada dice cuántos puntos se descartaron."
            ),
            section: .progress
        ),
        Benefit(
            id: "offline",
            symbol: "airplane",
            title: LocalizedText(
                fr: "Aucun serveur, aucun compte",
                en: "No server, no account",
                es: "Sin servidor, sin cuenta"
            ),
            promise: LocalizedText(
                fr: "Tout fonctionne en mode avion, au sous-sol d'une salle, dans un train.",
                en: "Everything works in airplane mode, in a basement gym, on a train.",
                es: "Todo funciona en modo avión, en el sótano de un gimnasio, en un tren."
            ),
            proof: LocalizedText(
                fr: "Le catalogue d'exercices, celui des aliments, les recettes et tout le moteur sont compilés dans l'application. Tes données vivent dans un fichier sur ce téléphone. Il n'y a rien à synchroniser parce qu'il n'y a nulle part où synchroniser.",
                en: "The exercise catalogue, the food catalogue, the recipes and the whole engine are compiled into the app. Your data lives in a file on this phone. There is nothing to sync because there is nowhere to sync to.",
                es: "El catálogo de ejercicios, el de alimentos, las recetas y todo el motor están compilados en la aplicación. Tus datos viven en un archivo de este teléfono. No hay nada que sincronizar porque no hay adónde."
            ),
            section: .profile
        ),
        Benefit(
            id: "yours",
            symbol: "square.and.arrow.up",
            title: LocalizedText(
                fr: "Tes données ne sont jamais un otage",
                en: "Your data is never a hostage",
                es: "Tus datos nunca son un rehén"
            ),
            promise: LocalizedText(
                fr: "Tu peux tout exporter et tout effacer, y compris le jour où tu arrêtes de payer.",
                en: "You can export everything and erase everything, including the day you stop paying.",
                es: "Puedes exportarlo todo y borrarlo todo, incluso el día que dejes de pagar."
            ),
            proof: LocalizedText(
                fr: "L'export JSON contient l'intégralité de ce que tu as entré, dans un format lisible. L'effacement est à côté, en un appui, sans avoir à écrire à personne. Les deux restent gratuits à vie.",
                en: "The JSON export contains everything you entered, in a readable format. Erasure sits next to it, one tap, with nobody to write to. Both stay free for life.",
                es: "La exportación JSON contiene todo lo que has introducido, en un formato legible. El borrado está al lado, a un toque, sin tener que escribir a nadie. Ambos siguen siendo gratis de por vida."
            ),
            section: .profile
        ),
    ]

    /// Ce que l'application ne fera pas, écrit une bonne fois.
    ///
    /// C'est la moitié qu'aucune page de vente ne met, et c'est celle qui
    /// évite qu'on reproche plus tard une promesse qui n'a jamais été faite.
    public static let refusals: [LocalizedText] = [
        LocalizedText(
            fr: "Aucun journal alimentaire à remplir. La seule donnée nutritionnelle demandée est ton poids sur la balance.",
            en: "No food diary to fill in. The only nutrition data asked of you is your weight on the scale.",
            es: "Ningún diario alimentario que rellenar. El único dato nutricional que se te pide es tu peso en la báscula."
        ),
        LocalizedText(
            fr: "Aucune vidéo. Une vidéo montre un mouvement réussi ; elle ne dit pas ce que tu es en train de rater.",
            en: "No video. A video shows a movement done right; it does not tell you what you are getting wrong.",
            es: "Ningún vídeo. Un vídeo muestra un movimiento bien hecho; no te dice qué estás haciendo mal."
        ),
        LocalizedText(
            fr: "Aucun classement, aucun fil d'actualité, aucune comparaison avec qui que ce soit d'autre que toi.",
            en: "No leaderboard, no feed, no comparison with anyone other than yourself.",
            es: "Ninguna clasificación, ningún muro, ninguna comparación con nadie más que contigo."
        ),
        LocalizedText(
            fr: "Aucun conseil médical. Une douleur qui dure se règle avec un médecin, pas avec une application.",
            en: "No medical advice. Pain that lasts is settled with a doctor, not with an app.",
            es: "Ningún consejo médico. Un dolor que dura se resuelve con un médico, no con una aplicación."
        ),
        LocalizedText(
            fr: "Aucune notification pour te faire revenir. Celles qui existent servent une séance en cours, jamais l'engagement.",
            en: "No notifications to lure you back. The ones that exist serve a session in progress, never engagement.",
            es: "Ninguna notificación para hacerte volver. Las que existen sirven a una sesión en curso, nunca al enganche."
        ),
    ]
}
