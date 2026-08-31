import Charts
import SwiftUI
import MonCoachKit
import UniformTypeIdentifiers

/// Le journal : la mémoire de l'athlète, sport par sport, semaine par
/// semaine — et la porte d'entrée et de sortie des données (GPX).
struct JournalView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.language) private var language

    @State private var showsImporter = false
    @State private var importError = false
    @State private var importedCount = 0
    /// Les fichiers dont la sortie était déjà dans le journal.
    @State private var alreadyKnownCount = 0

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var maximumBpm: Double {
        HeartRateAnalysis.estimatedMaximum(age: store.profile?.age() ?? 30)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if store.history.activities.isEmpty {
                    emptyCard
                } else {
                    streakCard
                    yearReviewLink
                    fitnessCard
                    heatmapCard
                    recordsCard
                    weeksCard
                }
                importCard
            }
            .padding(16)
        }
        .screenBackground()
        .fileImporter(
            isPresented: $showsImporter,
            allowedContentTypes: [UTType(filenameExtension: "gpx") ?? .xml, .xml],
            allowsMultipleSelection: true
        ) { result in
            importedCount = 0
            alreadyKnownCount = 0
            guard case .success(let urls) = result else { return }
            for url in urls {
                // L'accès sécurisé est requis pour un fichier venu des
                // Fichiers ou d'AirDrop ; sans lui, la lecture échoue en
                // silence sur un vrai appareil.
                let secured = url.startAccessingSecurityScopedResource()
                defer { if secured { url.stopAccessingSecurityScopedResource() } }
                guard let text = try? String(contentsOf: url, encoding: .utf8),
                      let outcome = try? store.importGPX(text)
                else {
                    importError = true
                    continue
                }
                // Un fichier déjà rentré n'est pas une erreur, et n'est pas
                // non plus une sortie de plus : il se compte à part.
                switch outcome {
                case .imported: importedCount += 1
                case .alreadyKnown: alreadyKnownCount += 1
                }
            }
        }
        .alert(
            LocalizedText(
                fr: "Ce fichier n'a pas pu être lu",
                en: "This file could not be read",
                es: "No se ha podido leer este archivo"
            )[language],
            isPresented: $importError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            CoachText(
                LocalizedText(
                    fr: "Le fichier doit être un GPX avec des points horodatés.",
                    en: "The file must be a GPX with timestamped points.",
                    es: "El archivo debe ser un GPX con puntos con marca de tiempo."
                )
            )
        }
    }

    private var emptyCard: some View {
        Card(
            title: LocalizedText(fr: "Aucune activité", en: "No activities yet", es: "Aún sin actividades")[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Enregistre une sortie, ou importe ton historique en GPX : tout compte, d'où qu'il vienne.",
                    en: "Record an activity, or import your history as GPX: everything counts, wherever it comes from.",
                    es: "Registra una salida o importa tu historial en GPX: todo cuenta, venga de donde venga."
                )
            )
        }
    }

    // MARK: - Série et totaux

    private var streakCard: some View {
        let streak = ActivityJournal.weeklyStreak(of: store.history.activities)
        let year = Calendar.current.component(.year, from: Date())
        let byS = ActivityJournal.yearBySport(of: store.history.activities, year: year, maximumBpm: maximumBpm)
        return Card(
            title: LocalizedText(fr: "Cette année", en: "This year", es: "Este año")[language],
            subtitle: streak >= 2
                ? LocalizedText(
                    fr: "\(streak) semaines d'affilée avec au moins une sortie",
                    en: "\(streak) weeks in a row with at least one activity",
                    es: "\(streak) semanas seguidas con al menos una salida"
                )[language]
                : nil
        ) {
            VStack(spacing: 10) {
                ForEach(Sport.allCases.filter { byS[$0] != nil }) { sport in
                    let totals = byS[sport]!
                    HStack(spacing: 10) {
                        Image(systemName: sport.symbolName)
                            .foregroundStyle(Theme.accent)
                            .frame(width: 24)
                        Text(sport.label[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                        Spacer()
                        Text(
                            Format.distance(meters: totals.meters, unit: unit, language: language)
                            + " · " + Format.stopwatch(seconds: totals.movingSeconds)
                            + " · \(Int(totals.elevationGain)) m D+"
                        )
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
        }
    }

    /// La porte du bilan annuel.
    ///
    /// Le journal montre la semaine, et le total de l'année juste au-dessus ;
    /// ce que ni l'un ni l'autre ne donne, c'est la forme de l'année — les
    /// mois creux, le mois record, la plus longue sortie. Un écran à part
    /// plutôt qu'une carte de plus : on ne lit pas son année en passant.
    private var yearReviewLink: some View {
        NavigationLink {
            YearReviewView()
        } label: {
            Card {
                HStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Theme.accent)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(
                            LocalizedText(
                                fr: "Ton année sportive",
                                en: "Your year in sport",
                                es: "Tu año deportivo"
                            )[language]
                        )
                        .font(Theme.headlineFont)
                        .foregroundStyle(Theme.primaryText)
                        Text(
                            LocalizedText(
                                fr: "Mois par mois, tes records, ta plus longue sortie.",
                                en: "Month by month, your records, your longest activity.",
                                es: "Mes a mes, tus récords, tu salida más larga."
                            )[language]
                        )
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.secondaryText)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Carte de chaleur

    private var heatmapCard: some View {
        let traced = store.history.activities.filter { !$0.points.isEmpty }
        let frequent = FrequentRoutes.find(in: store.history.activities)
        return Group {
            if !traced.isEmpty {
                Card(
                    title: LocalizedText(fr: "Tes parcours", en: "Your routes", es: "Tus recorridos")[language],
                    subtitle: frequent.isEmpty
                        ? LocalizedText(
                            fr: "Dessinée sur l'appareil — cette image ne part nulle part.",
                            en: "Drawn on the device — this image goes nowhere.",
                            es: "Dibujada en el dispositivo: esta imagen no va a ninguna parte."
                        )[language]
                        : LocalizedText(
                            fr: "En vert, le trajet que tu prends le plus ; en orange, les suivants. Tout est calculé sur l'appareil : la liste des chemins que tu répètes, ce sont tes horaires et ton adresse.",
                            en: "In green, the route you take most; in orange, the next ones. All computed on the device: the list of paths you repeat is your schedule and your address.",
                            es: "En verde, la ruta que más tomas; en naranja, las siguientes. Todo se calcula en el dispositivo: la lista de caminos que repites son tus horarios y tu dirección."
                        )[language]
                ) {
                    RoutesCanvas(
                        activities: traced,
                        highlights: frequent.prefix(3).map(\.points)
                    )
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                if !frequent.isEmpty {
                    FrequentRoutesCard(routes: frequent)
                }
            }
        }
    }

    // MARK: - Records

    private var recordsCard: some View {
        let records = BestEfforts.records(in: store.history.activities)
        return Group {
            if !records.isEmpty {
                Card(title: LocalizedText(fr: "Tes records", en: "Your records", es: "Tus récords")[language]) {
                    VStack(spacing: 8) {
                        ForEach(records) { record in
                            HStack {
                                Text(record.distance.label[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                Spacer()
                                Text(Format.stopwatch(seconds: record.duration))
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                                Text(Format.pace(secondsPerKm: record.paceSecondsPerKm, unit: unit))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(width: 76, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Semaines

    private var weeksCard: some View {
        let weeks = ActivityJournal.weeks(of: store.history.activities, maximumBpm: maximumBpm).prefix(8)
        return Card(
            title: LocalizedText(fr: "Semaine par semaine", en: "Week by week", es: "Semana a semana")[language]
        ) {
            VStack(spacing: 10) {
                let maxMeters = max(1, weeks.map(\.totals.meters).max() ?? 1)
                ForEach(Array(weeks)) { week in
                    HStack(spacing: 10) {
                        Text(week.start.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(size: 12))
                            .foregroundStyle(Theme.secondaryText)
                            .frame(width: 52, alignment: .leading)
                        ProgressBar(value: week.totals.meters / maxMeters)
                        Text(week.totals.activityCount == 0
                             ? "—"
                             : Format.distance(meters: week.totals.meters, unit: unit, language: language))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(week.totals.activityCount == 0 ? Theme.secondaryText : Theme.primaryText)
                            .frame(width: 64, alignment: .trailing)
                    }
                }
                // La liste des sorties récentes, ouvrables une à une.
                Divider().overlay(Theme.surfaceRaised)
                ForEach(store.history.activities.suffix(5).reversed()) { activity in
                    NavigationLink {
                        ActivityDetailView(activity: activity)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: activity.sport.symbolName)
                                .foregroundStyle(Theme.accent)
                                .frame(width: 22)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.startedAt.formatted(.dateTime.day().month().hour().minute()))
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.primaryText)
                                Text(Format.distance(meters: activity.meters, unit: unit, language: language)
                                     + " · " + Format.speedOrPace(
                                        sport: activity.sport, meters: activity.meters,
                                        seconds: activity.duration, unit: unit, language: language))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.secondaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Forme et fatigue

    /// La courbe de charge : la condition qui se construit sur six semaines,
    /// la fatigue qui monte et retombe en une, et leur solde — la forme.
    @ViewBuilder
    private var fitnessCard: some View {
        let series = TrainingLoadEngine.series(
            activities: store.history.activities,
            maximumBpm: maximumBpm
        )
        if let today = series.last, series.count >= 7 {
            Card(
                title: LocalizedText(fr: "Forme et fatigue", en: "Fitness and fatigue", es: "Forma y fatiga")[language],
                subtitle: LocalizedText(
                    fr: "Ce que tes sorties font ensemble : la condition se construit en six semaines, la fatigue s'efface en une.",
                    en: "What your activities do together: fitness builds over six weeks, fatigue clears in one.",
                    es: "Lo que tus salidas hacen juntas: la condición se construye en seis semanas, la fatiga se disipa en una."
                )[language]
            ) {
                let conditionLabel = LocalizedText(fr: "Condition", en: "Fitness", es: "Condición")[language]
                let fatigueLabel = LocalizedText(fr: "Fatigue", en: "Fatigue", es: "Fatiga")[language]
                Chart(series) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Charge", point.fitness),
                        series: .value("Courbe", conditionLabel)
                    )
                    .foregroundStyle(by: .value("Courbe", conditionLabel))

                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Charge", point.fatigue),
                        series: .value("Courbe", fatigueLabel)
                    )
                    .foregroundStyle(by: .value("Courbe", fatigueLabel))
                }
                .chartForegroundStyleScale([
                    conditionLabel: Theme.accent,
                    fatigueLabel: Theme.warning
                ])
                .frame(height: 170)

                HStack {
                    Text(LocalizedText(fr: "Forme aujourd'hui", en: "Form today", es: "Forma hoy")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    Spacer()
                    Text(Format.signed(today.form, decimals: 0))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(today.form >= 0 ? Theme.accent : Theme.warning)
                }
                if let verdict = TrainingLoadEngine.verdict(for: today) {
                    CoachText(verdict)
                }
            }
        }
    }

    // MARK: - Import

    private var importCard: some View {
        Card(
            title: LocalizedText(fr: "Ton historique t'appartient", en: "Your history is yours", es: "Tu historial es tuyo")[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                CoachText(
                    LocalizedText(
                        fr: "Importe des fichiers GPX — d'une montre, d'une autre application, d'ailleurs. Ils entrent dans l'historique et comptent pour tes records. Et chaque sortie s'exporte en GPX depuis sa fiche.",
                        en: "Import GPX files — from a watch, another app, anywhere. They join your history and count towards your records. And every activity exports as GPX from its page.",
                        es: "Importa archivos GPX: de un reloj, de otra aplicación, de donde sea. Entran en tu historial y cuentan para tus récords. Y cada salida se exporta en GPX desde su ficha."
                    )
                )
                if importedCount > 0 || alreadyKnownCount > 0 {
                    FlowLayout(spacing: 6) {
                        if importedCount > 0 {
                            Pill(text: LocalizedText(
                                fr: "\(importedCount) importée(s)",
                                en: "\(importedCount) imported",
                                es: "\(importedCount) importada(s)"
                            )[language])
                        }
                        // Dit plutôt que tu : réimporter le même fichier est
                        // naturel quand on ne se souvient plus de ce qu'on a
                        // déjà rentré, et le silence laisserait croire à une
                        // sortie perdue.
                        if alreadyKnownCount > 0 {
                            Pill(
                                text: LocalizedText(
                                    fr: "\(alreadyKnownCount) déjà dans ton journal",
                                    en: "\(alreadyKnownCount) already in your journal",
                                    es: "\(alreadyKnownCount) ya en tu diario"
                                )[language],
                                tint: Theme.warning
                            )
                        }
                    }
                }
                PrimaryButton(
                    title: LocalizedText(fr: "Importer un GPX", en: "Import a GPX", es: "Importar un GPX")[language],
                    systemImage: "square.and.arrow.down"
                ) {
                    showsImporter = true
                }
            }
        }
    }
}

/// La carte de chaleur dessinée, case par case.
/// Tous les parcours, dessinés comme des tracés — pas comme des cases.
///
/// La première version agrégeait les traces en grille de cases de 75 m :
/// honnête sur la fréquentation, mais illisible comme carte — des marches
/// d'escalier là où la route est droite, et des morceaux avalés quand un
/// bout de parcours tombait entre deux cases. Ici chaque sortie est un
/// trait continu, du premier point au dernier, projeté à l'échelle. Les
/// endroits parcourus souvent ressortent tout seuls : les traits
/// s'empilent, et l'empilement éclaircit.
struct RoutesCanvas: View {
    var activities: [ActivityLog]
    /// Les trajets à faire ressortir, dessinés par-dessus les autres.
    ///
    /// Sans eux, toutes les traces se valent et la carte ne répond pas à la
    /// question qu'on lui pose : « lequel je prends le plus ? ». Le fond
    /// reste visible — c'est lui qui donne le relief de l'ensemble — mais
    /// il passe derrière, en sourdine.
    var highlights: [[GPSPoint]] = []

    /// Assez de points pour que chaque virage existe, assez peu pour que
    /// vingt sorties se dessinent sans faire chauffer l'écran. Le dernier
    /// point est toujours gardé : un parcours qui s'arrête avant la fin
    /// est exactement ce qu'on répare ici.
    private static let maxPointsPerRoute = 400

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Theme.surfaceRaised))

            let routes = activities.map { Self.thinned($0.points) }
            let featured = highlights.map { Self.thinned($0) }
            let all = routes.flatMap { $0 } + featured.flatMap { $0 }
            guard let minLat = all.map(\.latitude).min(),
                  let maxLat = all.map(\.latitude).max(),
                  let minLon = all.map(\.longitude).min(),
                  let maxLon = all.map(\.longitude).max()
            else { return }

            // La longitude est resserrée par le cosinus de la latitude,
            // comme sur toutes les cartes de l'application : sans ça, un
            // aller-retour est-ouest paraît 1,5 fois trop long.
            let midLatRadians = (minLat + maxLat) / 2 * .pi / 180
            let spanX = max(0.000001, (maxLon - minLon) * cos(midLatRadians))
            let spanY = max(0.000001, maxLat - minLat)
            let inset: CGFloat = 14
            let scale = min((size.width - inset * 2) / spanX, (size.height - inset * 2) / spanY)
            let offsetX = (size.width - spanX * scale) / 2
            let offsetY = (size.height - spanY * scale) / 2

            func project(_ point: GPSPoint) -> CGPoint {
                CGPoint(
                    x: offsetX + (point.longitude - minLon) * cos(midLatRadians) * scale,
                    y: offsetY + (maxLat - point.latitude) * scale
                )
            }

            // Chaque trait est translucide : là où les sorties repassent,
            // ils s'empilent et brillent — la carte de chaleur sans les cases.
            let style = StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            let dimmed = highlights.isEmpty ? 0.5 : 0.18
            for route in routes where route.count >= 2 {
                context.stroke(
                    Self.smoothPath(route.map(project)),
                    with: .color(Theme.accent.opacity(dimmed)),
                    style: style
                )
            }

            // Les trajets habituels par-dessus, dans l'ordre inverse : le
            // plus fréquent est dessiné en dernier, donc au-dessus de tous
            // les autres. C'est celui qu'on cherche du regard.
            let featuredStyle = StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
            for (index, route) in featured.enumerated().reversed() where route.count >= 2 {
                let path = Self.smoothPath(route.map(project))
                // Un liseré sombre sous le trait : sur un fond de traces, un
                // trait clair seul se confond avec l'empilement.
                context.stroke(
                    path,
                    with: .color(Theme.background.opacity(0.85)),
                    style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
                )
                context.stroke(
                    path,
                    with: .color(index == 0 ? Theme.accent : Theme.warning.opacity(0.9)),
                    style: featuredStyle
                )
            }
        }
    }

    /// Réduit une trace sans jamais perdre ses extrémités.
    static func thinned(_ points: [GPSPoint]) -> [GPSPoint] {
        guard points.count > maxPointsPerRoute else { return points }
        let stride = points.count / maxPointsPerRoute + 1
        var kept = points.indices.filter { $0 % stride == 0 }.map { points[$0] }
        if let last = points.last, kept.last != last {
            kept.append(last)
        }
        return kept
    }

    /// Un chemin qui passe par les points en arrondissant les angles.
    ///
    /// Chaque segment est tiré vers le milieu du suivant par une courbe
    /// quadratique : les lignes droites restent droites — trois points
    /// alignés donnent une courbe plate — et les virages s'arrondissent au
    /// lieu de casser. C'est ce qu'un trait de GPS mérite : la route était
    /// lisse, c'est l'échantillonnage qui ne l'était pas.
    static func smoothPath(_ points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        guard points.count > 2 else {
            for point in points.dropFirst() { path.addLine(to: point) }
            return path
        }
        for index in 1..<(points.count - 1) {
            let current = points[index]
            let next = points[index + 1]
            let middle = CGPoint(x: (current.x + next.x) / 2, y: (current.y + next.y) / 2)
            path.addQuadCurve(to: middle, control: current)
        }
        path.addLine(to: points[points.count - 1])
        return path
    }
}
