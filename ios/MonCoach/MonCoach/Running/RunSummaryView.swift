import PhotosUI
import SwiftUI
import MonCoachKit

/// Ce que l'athlète voit en franchissant la ligne.
struct RunSummaryView: View {
    var run: ActivityLog
    /// Appelé après l'enregistrement, pour que l'écran appelant se referme
    /// lui aussi. L'enregistrement lui-même se fait ici : deux endroits qui
    /// enregistrent la même sortie, c'est la sortie en double.
    var onSaved: () -> Void = {}

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var effort: Int = 5
    @State private var note: String = ""
    /// Les photos choisies avant l'enregistrement.
    ///
    /// La sortie n'existe pas encore dans le magasin quand cet écran
    /// s'ouvre : rien à quoi les attacher. Elles attendent ici, en mémoire,
    /// et rejoignent la sortie au moment où elle est enregistrée — c'est
    /// pourtant maintenant qu'on a envie de les mettre, pas trois jours plus
    /// tard en relisant le journal.
    @State private var pendingPhotos: [Data] = []
    @State private var picked: [PhotosPickerItem] = []

    private var unit: UnitSystem { store.profile?.unit ?? .metric }
    private var weightKg: Double { store.profile?.weightKg ?? 70 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if run.sport.tracksLocation {
                        RunMapView(points: run.points, loadsTiles: store.profile?.loadsMapTiles ?? true)
                            .frame(height: 220)
                    }

                    Card {
                        HStack(spacing: 12) {
                            // Une séance sans trace n'a ni distance ni
                            // allure : sa durée prend la première place,
                            // celle du chiffre qu'on regarde.
                            if run.sport.tracksLocation {
                                StatTile(
                                    value: Format.distance(meters: run.meters, unit: unit, language: language),
                                    label: UI.distance[language]
                                )
                            } else {
                                StatTile(
                                    value: run.sport.label[language],
                                    label: LocalizedText(fr: "Sport", en: "Sport", es: "Deporte")[language]
                                )
                            }
                            StatTile(
                                value: Format.stopwatch(seconds: run.duration),
                                label: UI.duration[language]
                            )
                            if run.sport.tracksLocation {
                                StatTile(
                                    value: Format.speedOrPace(
                                        sport: run.sport, meters: run.meters,
                                        seconds: run.duration, unit: unit, language: language
                                    ),
                                    label: UI.pace[language]
                                )
                            }
                        }
                        HStack(spacing: 12) {
                            if run.sport.tracksLocation {
                                StatTile(
                                    value: "\(Int(run.elevationGain)) m",
                                    label: UI.elevation[language],
                                    tint: Theme.warning
                                )
                            }
                            // La dépense passe par le modèle du sport : la
                            // formule de la course appliquée à un vélo
                            // donnait le triple, et n'avait rien à dire du
                            // tout d'une heure de yoga.
                            StatTile(
                                value: "\(Int(TraceMath.energyKcal(sport: run.sport, meters: run.meters, movingSeconds: run.duration, elevationGain: run.elevationGain, weightKg: weightKg)))",
                                label: UI.calories[language],
                                tint: Theme.warning
                            )
                            if run.sport.feedsRunningPlan {
                                StatTile(
                                    value: run.type.label[language],
                                    label: LocalizedText(fr: "Type", en: "Type", es: "Tipo")[language],
                                    tint: Theme.secondaryText
                                )
                            }
                        }
                    }

                    highlightsCard
                    photosCard

                    if !run.splits.isEmpty {
                        Card(title: UI.splits[language]) {
                            SplitList(splits: run.splits, unit: unit)
                        }
                    }

                    Card(
                        title: LocalizedText(
                            fr: "Effort ressenti",
                            en: "Perceived effort",
                            es: "Esfuerzo percibido"
                        )[language],
                        subtitle: LocalizedText(
                            fr: "1 = promenade, 10 = tout donné",
                            en: "1 = a stroll, 10 = everything you had",
                            es: "1 = un paseo, 10 = todo lo que tenías"
                        )[language]
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            Stepper(value: $effort, in: 1...10) {
                                Text("\(effort) / 10")
                                    .font(Theme.headlineFont)
                                    .foregroundStyle(Theme.accent)
                            }
                            TextField(
                                LocalizedText(
                                    fr: "Une note, si tu veux t'en souvenir",
                                    en: "A note, if you want to remember it",
                                    es: "Una nota, si quieres recordarlo"
                                )[language],
                                text: $note,
                                axis: .vertical
                            )
                            .textFieldStyle(.plain)
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                            .padding(10)
                            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    if let insight = qualityInsight {
                        Card { CoachText(insight, color: Theme.primaryText) }
                    }

                    PrimaryButton(title: UI.save[language], systemImage: "checkmark") {
                        var saved = run
                        saved.perceivedEffort = effort
                        saved.note = note.isEmpty ? nil : note
                        store.recordRun(saved)
                        // Les photos après la sortie, jamais avant : elles
                        // s'attachent à une sortie qui existe.
                        for photo in pendingPhotos {
                            _ = store.addPhoto(photo, to: saved.id)
                        }
                        dismiss()
                        onSaved()
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Sortie terminée", en: "Run finished", es: "Rodaje terminado")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Les photos de la sortie, choisies avant même qu'elle soit
    /// enregistrée.
    private var photosCard: some View {
        Card(
            title: LocalizedText(fr: "Photos", en: "Photos", es: "Fotos")[language],
            subtitle: LocalizedText(
                fr: "Elles restent sur ton téléphone : rien n'est téléversé, jamais.",
                en: "They stay on your phone: nothing is ever uploaded.",
                es: "Se quedan en tu teléfono: nunca se sube nada."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if !pendingPhotos.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(pendingPhotos.enumerated()), id: \.offset) { index, data in
                                PendingPhotoView(data: data)
                                    .overlay(alignment: .topTrailing) {
                                        Button {
                                            pendingPhotos.remove(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.system(size: 18))
                                                .foregroundStyle(Theme.primaryText, Theme.background)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(4)
                                    }
                            }
                        }
                    }
                }
                PhotosPicker(
                    selection: $picked,
                    maxSelectionCount: 6,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                        Text(
                            LocalizedText(
                                fr: "Ajouter des photos",
                                en: "Add photos",
                                es: "Añadir fotos"
                            )[language]
                        )
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(Theme.primaryText)
                }
            }
        }
        .onChange(of: picked) { _, items in
            guard !items.isEmpty else { return }
            picked = []
            Task {
                for item in items {
                    guard let raw = try? await item.loadTransferable(type: Data.self),
                          let prepared = PhotoEncoding.prepared(from: raw)
                    else { continue }
                    pendingPhotos.append(prepared)
                }
            }
        }
    }

    /// Les distinctions du jour : records battus, segments améliorés,
    /// allure corrigée quand le terrain la justifie.
    private var highlightsCard: some View {
        let highlights = store.highlights(for: run)
        let segmentEfforts = store.segmentEfforts(in: run)
        // L'allure corrigée ne s'affiche que quand elle change la lecture :
        // sur du plat, annoncer « corrigée : pareil » serait du bruit.
        let corrected: Double? = {
            guard run.sport.feedsRunningPlan, run.elevationGain > run.meters * 0.008 else { return nil }
            return GradeAdjustment.flatEquivalentPace(
                of: TraceAnalysis.clean(run.points, filter: run.sport.filter)
            )
        }()
        return Group {
            if !highlights.isEmpty || !segmentEfforts.isEmpty || corrected != nil {
                Card(title: LocalizedText(fr: "Ce que ça vaut", en: "What it's worth", es: "Lo que vale")[language]) {
                    VStack(alignment: .leading, spacing: 8) {
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
                        ForEach(segmentEfforts) { effort in
                            if let segment = store.segments.first(where: { $0.id == effort.segmentID }) {
                                HStack {
                                    Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")
                                        .foregroundStyle(Theme.accent)
                                    Text(segment.name)
                                        .font(Theme.bodyFont)
                                        .foregroundStyle(Theme.primaryText)
                                        .lineLimit(1)
                                    Spacer()
                                    Text(Format.stopwatch(seconds: effort.duration))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Theme.accent)
                                }
                            }
                        }
                        if let corrected {
                            CoachText(
                                LocalizedText(
                                    fr: "Allure corrigée du dénivelé : \(Format.pace(secondsPerKm: corrected, unit: unit)) — ce que la sortie vaut sur du plat.",
                                    en: "Grade-adjusted pace: \(Format.pace(secondsPerKm: corrected, unit: unit)) — what this effort is worth on the flat.",
                                    es: "Ritmo ajustado al desnivel: \(Format.pace(secondsPerKm: corrected, unit: unit)) — lo que vale este esfuerzo en llano."
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    /// Ce que la sortie apprend au coach, quand elle apprend quelque chose.
    private var qualityInsight: LocalizedText? {
        let trace = TraceAnalysis.clean(run.points)
        if !run.points.isEmpty && trace.retention < 0.85 {
            let dropped = Int((1 - trace.retention) * 100)
            return LocalizedText(
                fr: "\(dropped) % des points GPS ont été écartés — signal dégradé, sans doute sous les arbres ou entre des immeubles. La distance est donc une estimation basse.",
                en: "\(dropped) % of the GPS points were discarded — degraded signal, probably under trees or between buildings. The distance is therefore an underestimate.",
                es: "Se ha descartado el \(dropped) % de los puntos GPS: señal degradada, probablemente bajo árboles o entre edificios. La distancia es, por tanto, una estimación baja."
            )
        }
        guard [RunType.tempo, .intervals, .race].contains(run.type), run.meters >= 2_000,
              let threshold = TraceMath.thresholdPace(fromDistance: run.meters, time: run.duration)
        else { return nil }
        let known = store.profile?.running?.thresholdPaceSecondsPerKm
        guard known == nil || threshold < (known ?? .greatestFiniteMagnitude) else { return nil }
        let pace = Format.pace(secondsPerKm: threshold, unit: unit)
        return LocalizedText(
            fr: "Nouvelle référence : ton allure de seuil passe à \(pace). Les allures de tes prochaines séances sont recalculées dessus.",
            en: "New reference: your threshold pace moves to \(pace). The paces in your next sessions are recalculated from it.",
            es: "Nueva referencia: tu ritmo de umbral pasa a \(pace). Los ritmos de tus próximas sesiones se recalculan a partir de ahí."
        )
    }
}
