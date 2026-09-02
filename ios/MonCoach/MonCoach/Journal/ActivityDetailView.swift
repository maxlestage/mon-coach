import SwiftUI
import MonCoachKit

/// La fiche d'une activité passée : la revoir, l'exporter, la supprimer.
struct ActivityDetailView: View {
    var activity: ActivityLog

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var showsDeleteConfirmation = false
    @State private var routeName = ""
    @State private var asksRouteName = false
    @State private var savedAsRoute = false

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var maximumBpm: Double {
        HeartRateAnalysis.estimatedMaximum(age: store.profile?.age() ?? 30)
    }
    /// La sortie telle qu'elle est dans le magasin en ce moment.
    ///
    /// La vue en reçoit une copie à sa création ; les photos ajoutées depuis
    /// n'y sont pas. Lire le magasin fait apparaître la photo dès qu'elle est
    /// rangée, sans refermer la fiche.
    private var current: ActivityLog {
        store.history.activities.first { $0.id == activity.id } ?? activity
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                if !activity.points.isEmpty {
                    RunMapView(points: activity.points, loadsTiles: store.profile?.loadsMapTiles ?? true)
                        .frame(height: 220)
                }

                Card {
                    HStack(spacing: 12) {
                        // Ce qui n'a pas de distance montre son sport à la
                        // place : une tuile « 0,00 km » n'apprend rien, et
                        // fait douter de tout le reste de la fiche.
                        if activity.sport.tracksLocation {
                            StatTile(
                                value: Format.distance(meters: activity.meters, unit: unit, language: language),
                                label: UI.distance[language]
                            )
                        } else {
                            StatTile(
                                value: activity.sport.label[language],
                                label: LocalizedText(fr: "Sport", en: "Sport", es: "Deporte")[language]
                            )
                        }
                        StatTile(
                            value: Format.stopwatch(seconds: activity.duration),
                            label: UI.duration[language]
                        )
                        if activity.sport.tracksLocation {
                            StatTile(
                                value: Format.speedOrPace(
                                    sport: activity.sport, meters: activity.meters,
                                    seconds: activity.duration, unit: unit, language: language
                                ),
                                label: UI.pace[language]
                            )
                        } else {
                            // La dépense mesurée au poignet, cardio compris, avant le
                            // modèle au kilomètre — quand la montre l'a mesurée.
                            StatTile(
                                value: "\(Int(activity.kilocalories ?? TraceMath.energyKcal(sport: activity.sport, meters: 0, movingSeconds: activity.duration, elevationGain: 0, weightKg: store.profile?.weightKg ?? 70)))",
                                label: UI.calories[language],
                                tint: Theme.warning
                            )
                        }
                    }
                }

                traceQualityCard
                effortAndGearCard
                photosCard
                highlightsCard
                segmentsCard
                heartCard

                if !activity.splits.isEmpty {
                    Card(title: UI.splits[language]) {
                        SplitList(splits: activity.splits, unit: unit)
                    }
                }

                reuseAsRouteCard

                // L'export : le fichier se fabrique à la demande, pas à
                // l'affichage — un GPX d'une longue sortie pèse des mégaoctets.
                ShareLink(
                    item: GPXFile(activity: activity),
                    preview: SharePreview(GPX.trackName(for: activity))
                ) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(LocalizedText(fr: "Exporter en GPX", en: "Export as GPX", es: "Exportar en GPX")[language])
                    }
                    .font(Theme.headlineFont)
                    .foregroundStyle(Theme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
                }

                Button(role: .destructive) {
                    showsDeleteConfirmation = true
                } label: {
                    Text(UI.delete[language])
                        .font(Theme.bodyFont)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 4)
            }
            .padding(16)
        }
        .screenBackground()
        .navigationTitle(activity.sport.label[language])
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            LocalizedText(
                fr: "Supprimer cette activité ?",
                en: "Delete this activity?",
                es: "¿Eliminar esta actividad?"
            )[language],
            isPresented: $showsDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button(UI.delete[language], role: .destructive) {
                store.deleteRun(activity.id)
                dismiss()
            }
            Button(UI.cancel[language], role: .cancel) {}
        }
        .alert(
            LocalizedText(
                fr: "Le nom de ce parcours",
                en: "The name of this route",
                es: "El nombre de este recorrido"
            )[language],
            isPresented: $asksRouteName
        ) {
            TextField("", text: $routeName)
            Button(UI.save[language]) {
                guard let route = RoutePlanner.route(from: activity, named: routeName) else { return }
                savedAsRoute = store.saveRoute(route)
            }
            Button(UI.cancel[language], role: .cancel) {}
        }
    }

    /// Les photos de la sortie.
    private var photosCard: some View {
        PhotoStripView(
            photoIDs: current.photoIDs,
            onAdd: { _ = store.addPhoto($0, to: activity.id) },
            onDelete: { store.removePhoto($0, from: activity.id) }
        )
    }

    /// Refaire ce parcours : le geste le plus courant devant une sortie
    /// qu'on a aimée.
    ///
    /// La trace devient un parcours à suivre, amincie au passage — un
    /// parcours n'a pas besoin des dix mille points d'une heure de course.
    @ViewBuilder
    private var reuseAsRouteCard: some View {
        if !activity.points.isEmpty {
            Card {
                VStack(alignment: .leading, spacing: 10) {
                    if savedAsRoute {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Theme.accent)
                            CoachText(
                                LocalizedText(
                                    fr: "Parcours enregistré. Tu le retrouveras avant de partir, sur l'écran Course.",
                                    en: "Route saved. You will find it before you set off, on the Running screen.",
                                    es: "Recorrido guardado. Lo encontrarás antes de salir, en la pantalla Carrera."
                                ),
                                color: Theme.primaryText
                            )
                        }
                    } else {
                        GhostButton(
                            title: LocalizedText(
                                fr: "En faire un parcours à refaire",
                                en: "Turn this into a route",
                                es: "Convertirlo en un recorrido"
                            )[language],
                            systemImage: "map"
                        ) {
                            routeName = activity.note?.isEmpty == false
                                ? activity.note!
                                : activity.startedAt.formatted(.dateTime.day().month())
                            asksRouteName = true
                        }
                    }
                }
            }
        }
    }

    /// Ce que cette sortie a valu dans l'histoire de l'athlète.
    /// L'effort de la sortie, et le matériel qui l'a portée.
    ///
    /// L'effort est le chiffre qui alimente la courbe de forme du Journal :
    /// le montrer ici relie chaque sortie à la courbe qu'elle nourrit. Le
    /// matériel se corrige d'un menu — la sortie a pris les chaussures du
    /// moment toute seule, mais « ce jour-là j'avais les autres » arrive.

    /// Ce que la trace a jeté, et pourquoi.
    ///
    /// Le site le promet, et jusqu'ici l'application se taisait : elle
    /// comptait les points écartés sans jamais les dire. Une sortie courte
    /// laissait alors croire à un coup de moins bien, ou à une application
    /// qui compte mal — alors que la vraie raison était connue.
    @ViewBuilder
    private var traceQualityCard: some View {
        if let note = TraceAnalysis.quality(of: activity) {
            Card(
                title: LocalizedText(
                    fr: "Ce que la trace a jeté",
                    en: "What the trace discarded",
                    es: "Lo que la traza descartó"
                )[language],
                subtitle: LocalizedText(
                    fr: "\(note.rejectedTotal) point\(note.rejectedTotal > 1 ? "s" : "") sur la sortie",
                    en: "\(note.rejectedTotal) point\(note.rejectedTotal > 1 ? "s" : "") on this activity",
                    es: "\(note.rejectedTotal) punto\(note.rejectedTotal > 1 ? "s" : "") en esta salida"
                )[language]
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    CoachText(note.headline, color: note.isSevere ? Theme.warning : Theme.primaryText)
                    ForEach(note.reasons, id: \.self) { reason in
                        CoachText(reason, font: .system(size: 12))
                    }
                }
            }
        }
    }

    private var effortAndGearCard: some View {
        let effort = TrainingLoadEngine.effort(for: activity, maximumBpm: maximumBpm)
        let currentGearID = store.history.activities.first { $0.id == activity.id }?.gearID
        let currentGear = store.history.gear.first { $0.id == currentGearID }
        let choices = store.history.gear.filter { !$0.isRetired && $0.suits(activity.sport) }

        return Card {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(LocalizedText(fr: "Effort", en: "Effort", es: "Esfuerzo")[language])
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.secondaryText)
                    Text("\(Int(effort.rounded())) pts")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.accent)
                }
                Spacer()
                if !choices.isEmpty || currentGear != nil {
                    Menu {
                        ForEach(choices) { gear in
                            Button(gear.name) {
                                store.assignGear(gear.id, toActivity: activity.id)
                            }
                        }
                        Button(LocalizedText(fr: "Aucun", en: "None", es: "Ninguno")[language]) {
                            store.assignGear(nil, toActivity: activity.id)
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: activity.sport.family == .wheels ? "bicycle" : "shoe.2")
                                .font(.system(size: 13))
                            Text(
                                currentGear?.name
                                    ?? LocalizedText(fr: "Matériel", en: "Gear", es: "Material")[language]
                            )
                            .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(Theme.primaryText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Theme.surfaceRaised, in: Capsule())
                    }
                }
            }
        }
    }

    private var highlightsCard: some View {
        let highlights = store.highlights(for: activity)
        return Group {
            if !highlights.isEmpty {
                Card(title: LocalizedText(fr: "Ce jour-là", en: "That day", es: "Ese día")[language]) {
                    VStack(spacing: 8) {
                        ForEach(highlights) { rank in
                            HStack {
                                Image(systemName: rank.isRecord ? "trophy.fill" : "medal")
                                    .foregroundStyle(rank.isRecord ? Theme.warning : Theme.secondaryText)
                                Text(rank.headline[language])
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                Spacer()
                                Text(Format.stopwatch(seconds: rank.effort.duration))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                            }
                        }
                    }
                }
            }
        }
    }

    /// Les passages sur les segments de l'athlète.
    private var segmentsCard: some View {
        let efforts = store.segmentEfforts(in: activity)
        return Group {
            if !efforts.isEmpty {
                Card(title: LocalizedText(fr: "Tes segments", en: "Your segments", es: "Tus segmentos")[language]) {
                    VStack(spacing: 8) {
                        ForEach(efforts) { effort in
                            let segment = store.segments.first { $0.id == effort.segmentID }
                            let best = segment.map { store.leaderboard(for: $0).first?.duration }
                            HStack {
                                Text(segment?.name ?? "—")
                                    .font(Theme.bodyFont)
                                    .foregroundStyle(Theme.primaryText)
                                    .lineLimit(1)
                                Spacer()
                                Text(Format.stopwatch(seconds: effort.duration))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.accent)
                                if let best = best ?? nil, effort.duration <= best {
                                    Pill(text: LocalizedText(fr: "Record", en: "Best", es: "Récord")[language], tint: Theme.warning)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    /// Les zones cardiaques, quand un capteur était là.
    private var heartCard: some View {
        Group {
            if !activity.heartRate.isEmpty {
                let perZone = HeartRateAnalysis.secondsPerZone(samples: activity.heartRate, maximumBpm: maximumBpm)
                let total = max(1, perZone.values.reduce(0, +))
                Card(
                    title: LocalizedText(fr: "Cardio", en: "Heart rate", es: "Pulso")[language],
                    subtitle: LocalizedText(
                        fr: "moyenne \(Int(HeartRateAnalysis.average(samples: activity.heartRate) ?? 0)) bpm — max estimée \(Int(maximumBpm)) bpm",
                        en: "average \(Int(HeartRateAnalysis.average(samples: activity.heartRate) ?? 0)) bpm — estimated max \(Int(maximumBpm)) bpm",
                        es: "media \(Int(HeartRateAnalysis.average(samples: activity.heartRate) ?? 0)) ppm — máx. estimada \(Int(maximumBpm)) ppm"
                    )[language]
                ) {
                    VStack(spacing: 8) {
                        ForEach(HeartRateAnalysis.zones(maximumBpm: maximumBpm)) { zone in
                            let seconds = perZone[zone.index] ?? 0
                            HStack(spacing: 10) {
                                Text("Z\(zone.index)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(width: 26, alignment: .leading)
                                Text(zone.label[language])
                                    .font(.system(size: 13))
                                    .foregroundStyle(Theme.primaryText)
                                    .frame(width: 90, alignment: .leading)
                                    .lineLimit(1)
                                ProgressBar(value: seconds / total)
                                Text(Format.stopwatch(seconds: seconds))
                                    .font(.system(size: 12))
                                    .foregroundStyle(Theme.secondaryText)
                                    .frame(width: 48, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }
}

/// Le fichier GPX, fabriqué au moment du partage seulement.
struct GPXFile: Transferable {
    var activity: ActivityLog

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .xml) { file in
            Data(GPX.document(for: file.activity).utf8)
        }
        .suggestedFileName { file in "\(GPX.trackName(for: file.activity)).gpx" }
    }
}
