import Charts
import SwiftUI
import MonCoachKit

/// Un jour du journal : sa date, et ce qui y a été photographié.
///
/// Un type plutôt qu'un tuple parce qu'un `ForEach` a besoin d'une identité,
/// et qu'un key path ne traverse pas un tuple.
private struct PlateDay: Identifiable {
    var id: Date { day }
    var day: Date
    var plates: [PlateEstimate]

    var proteinG: Double { plates.map(\.proteinG).reduce(0, +) }
}

/// Un aliment et le nombre de fois qu'il est revenu.
private struct FoodTally: Identifiable {
    var id: String { food.id }
    var food: Food
    var count: Int
}

/// Un mot du système et l'aliment que l'athlète lui a associé.
private struct LearnedWord: Identifiable {
    var id: String { label }
    var label: String
    var food: Food

    var readable: String { label.replacingOccurrences(of: "_", with: " ") }
}

/// Le journal des assiettes : ce qu'on a réellement mangé, jour après jour.
///
/// Pourquoi cet écran existe
/// -------------------------
/// Les assiettes photographiées n'existaient que le jour même. Le lendemain
/// elles disparaissaient de l'écran, et avec elles la seule chose qu'elles
/// pouvaient apprendre : la tendance. Une journée à 90 g de protéines ne
/// dit rien — trois semaines à 90 quand on en vise 140 disent tout, et
/// expliquent une stagnation que personne n'aurait rattachée à
/// l'alimentation.
///
/// C'est aussi le seul endroit d'où l'on peut rouvrir une assiette et la
/// corriger : on se souvient à 22 h qu'il y avait aussi du fromage.
struct PlateJournalView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    /// La fenêtre regardée. Quatorze jours pour la semaine passée et celle
    /// d'avant — assez pour voir une habitude, assez court pour que chaque
    /// barre reste lisible au pouce.
    @State private var days = 14
    @State private var opened: PlateEstimate?

    private var plates: [PlateEstimate] { store.recentPlates(days: days) }

    /// Les jours de la fenêtre, du plus récent au plus ancien, avec ce
    /// qu'ils contiennent. Les jours sans photo restent dans la liste : un
    /// trou est une information, et le cacher donnerait une moyenne fausse.
    private var journal: [PlateDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<days).compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            return PlateDay(day: day, plates: plates.filter { calendar.isDate($0.date, inSameDayAs: day) })
        }
    }

    private var target: Int? { store.briefing()?.nutrition.proteinG }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if plates.isEmpty {
                        emptyCard
                    } else {
                        windowPicker
                        trendCard
                        habitsCard
                        ForEach(journal.filter { !$0.plates.isEmpty }) { entry in
                            dayCard(entry.day, entry.plates)
                        }
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Mes assiettes", en: "My plates", es: "Mis platos")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .sheet(item: $opened) { plate in
                PlateDetailView(plate: plate)
            }
        }
    }

    private var emptyCard: some View {
        Card(
            title: LocalizedText(
                fr: "Aucune assiette photographiée",
                en: "No plate photographed yet",
                es: "Ningún plato fotografiado"
            )[language]
        ) {
            CoachText(
                LocalizedText(
                    fr: "Prends ton repas en photo depuis l'onglet Alimentation. Deux secondes par repas, et au bout d'une semaine cet écran dira ce qu'aucune balance ne t'aurait fait tenir : la tendance.",
                    en: "Photograph your meal from the Food tab. Two seconds per meal, and after a week this screen will tell you what no scale would have made you keep up: the trend.",
                    es: "Fotografía tu comida desde la pestaña Alimentación. Dos segundos por comida, y en una semana esta pantalla dirá lo que ninguna báscula te habría hecho mantener: la tendencia."
                )
            )
        }
    }

    private var windowPicker: some View {
        Card {
            HStack(spacing: 8) {
                ForEach([7, 14, 30], id: \.self) { window in
                    Button {
                        days = window
                    } label: {
                        Text(
                            LocalizedText(
                                fr: "\(window) jours", en: "\(window) days", es: "\(window) días"
                            )[language]
                        )
                        .font(.system(size: 13, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .foregroundStyle(days == window ? Theme.background : Theme.primaryText)
                        .background(
                            days == window ? Theme.accent : Theme.surfaceRaised,
                            in: RoundedRectangle(cornerRadius: 10)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - La tendance

    /// Les protéines de chaque jour, contre la cible.
    ///
    /// Une barre par jour, la cible en trait plein : c'est la seule lecture
    /// qui fait agir. Les jours sans photo sont des barres vides, et pas des
    /// jours absents — sinon la courbe mentirait par omission.
    private var trendCard: some View {
        // Du plus ancien au plus récent : une courbe se lit dans ce sens.
        let entries: [PlateDay] = Array(journal.reversed())
        let measured = entries.filter { $0.proteinG > 0 }
        let average = measured.isEmpty ? 0 : measured.map(\.proteinG).reduce(0, +) / Double(measured.count)
        return Card(
            title: LocalizedText(fr: "Protéines par jour", en: "Protein per day", es: "Proteína por día")[language],
            subtitle: subtitleForTrend(measuredDays: measured.count, average: average)
        ) {
            Chart {
                ForEach(entries) { entry in
                    BarMark(
                        x: .value("Jour", entry.day, unit: .day),
                        y: .value("Protéines", entry.proteinG)
                    )
                    .foregroundStyle(
                        entry.proteinG >= Double(target ?? 0) ? Theme.accent : Theme.warning
                    )
                    .cornerRadius(3)
                }
                if let target {
                    RuleMark(y: .value("Cible", target))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(Theme.primaryText.opacity(0.5))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .frame(height: 150)

            HStack(spacing: 12) {
                StatTile(
                    value: "\(Int(average)) g",
                    label: LocalizedText(
                        fr: "Moyenne mesurée", en: "Measured average", es: "Media medida"
                    )[language]
                )
                if let target {
                    StatTile(
                        value: "\(target) g",
                        label: LocalizedText(fr: "Cible", en: "Target", es: "Objetivo")[language],
                        tint: Theme.secondaryText
                    )
                    StatTile(
                        value: "\(measured.filter { $0.proteinG >= Double(target) }.count)/\(measured.count)",
                        label: LocalizedText(
                            fr: "Jours à la cible", en: "Days on target", es: "Días en objetivo"
                        )[language],
                        tint: Theme.secondaryText
                    )
                }
            }
        }
    }

    /// Le sous-titre dit d'abord combien de jours ont été mesurés.
    ///
    /// Sans ça, une moyenne calculée sur deux jours photographiés aurait la
    /// même autorité qu'une moyenne sur quatorze — et c'est exactement le
    /// genre de chiffre sur lequel on change un programme à tort.
    private func subtitleForTrend(measuredDays: Int, average: Double) -> String {
        guard measuredDays > 0 else {
            return LocalizedText(
                fr: "Rien de mesuré sur cette période.",
                en: "Nothing measured over this window.",
                es: "Nada medido en este periodo."
            )[language]
        }
        if measuredDays < 4 {
            return LocalizedText(
                fr: "\(measuredDays) jour\(measuredDays > 1 ? "s" : "") photographié\(measuredDays > 1 ? "s" : "") sur \(days) : trop peu pour une tendance, mais c'est un début.",
                en: "\(measuredDays) day\(measuredDays > 1 ? "s" : "") photographed out of \(days): too few for a trend, but it is a start.",
                es: "\(measuredDays) día\(measuredDays > 1 ? "s" : "") fotografiado\(measuredDays > 1 ? "s" : "") de \(days): pocos para una tendencia, pero es un comienzo."
            )[language]
        }
        guard let target else {
            return LocalizedText(
                fr: "\(measuredDays) jours photographiés sur \(days).",
                en: "\(measuredDays) days photographed out of \(days).",
                es: "\(measuredDays) días fotografiados de \(days)."
            )[language]
        }
        let gap = Double(target) - average
        if gap > 15 {
            return LocalizedText(
                fr: "\(measuredDays) jours mesurés : il te manque environ \(Int(gap)) g de protéines par jour. C'est la cause la plus banale d'une stagnation.",
                en: "\(measuredDays) days measured: you are about \(Int(gap)) g of protein short per day. That is the most ordinary cause of a plateau.",
                es: "\(measuredDays) días medidos: te faltan unos \(Int(gap)) g de proteína al día. Es la causa más común de un estancamiento."
            )[language]
        }
        return LocalizedText(
            fr: "\(measuredDays) jours mesurés, et la moyenne tient la cible. C'est ce qui compte, pas la journée parfaite.",
            en: "\(measuredDays) days measured, and the average holds the target. That is what counts, not the perfect day.",
            es: "\(measuredDays) días medidos y la media aguanta el objetivo. Eso es lo que cuenta, no el día perfecto."
        )[language]
    }

    // MARK: - Les habitudes

    /// Ce qui revient le plus souvent dans les assiettes.
    ///
    /// Utile pour deux raisons opposées : voir qu'on mange du poulet six
    /// jours sur sept, et voir qu'on n'a pas mangé un légume depuis mardi.
    private var habitsCard: some View {
        var counts: [String: Int] = [:]
        for plate in plates {
            for item in plate.items { counts[item.foodID, default: 0] += 1 }
        }
        let top = counts
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(10)
            .compactMap { entry -> FoodTally? in
                guard let food = FoodCatalog.food(id: entry.key) else { return nil }
                return FoodTally(food: food, count: entry.value)
            }
        let missing = FoodRole.allCases.filter { role in
            role != .drink && role != .treat
                && !counts.keys.contains { FoodCatalog.food(id: $0)?.role == role }
        }
        return Card(
            title: LocalizedText(
                fr: "Ce qui revient", en: "What comes back", es: "Lo que vuelve"
            )[language],
            subtitle: LocalizedText(
                fr: "Sur \(plates.count) assiette\(plates.count > 1 ? "s" : "").",
                en: "Across \(plates.count) plate\(plates.count > 1 ? "s" : "").",
                es: "En \(plates.count) plato\(plates.count > 1 ? "s" : "")."
            )[language]
        ) {
            FlowLayout(spacing: 8) {
                ForEach(top) { tally in
                    HStack(spacing: 5) {
                        Text(tally.food.name[language])
                            .font(.system(size: 13, weight: .medium))
                        Text("×\(tally.count)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(Theme.accent)
                    }
                    .foregroundStyle(Theme.primaryText)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Theme.surfaceRaised, in: Capsule())
                }
            }
            if !missing.isEmpty {
                CoachText(
                    LocalizedText(
                        fr: "Rien de ces rayons sur la période : \(missing.map { $0.label[.french].lowercased() }.joined(separator: ", ")). Soit ils manquent vraiment, soit tu ne les photographies pas.",
                        en: "Nothing from these aisles over the window: \(missing.map { $0.label[.english].lowercased() }.joined(separator: ", ")). Either they are genuinely missing, or you do not photograph them.",
                        es: "Nada de estas secciones en el periodo: \(missing.map { $0.label[.spanish].lowercased() }.joined(separator: ", ")). O faltan de verdad, o no los fotografías."
                    ),
                    font: .system(size: 12)
                )
            }
        }
    }

    // MARK: - Un jour

    private func dayCard(_ day: Date, _ plates: [PlateEstimate]) -> some View {
        let eaten = plates.map(\.macros).reduce(Macros.zero, +)
        return Card(
            title: day.formatted(.dateTime.weekday(.wide).day().month(.wide)),
            subtitle: LocalizedText(
                fr: "\(Int(eaten.proteinG)) g de protéines · \(Int(eaten.kcal)) kcal",
                en: "\(Int(eaten.proteinG)) g protein · \(Int(eaten.kcal)) kcal",
                es: "\(Int(eaten.proteinG)) g de proteína · \(Int(eaten.kcal)) kcal"
            )[language]
        ) {
            VStack(spacing: 10) {
                ForEach(plates.sorted { $0.date < $1.date }, id: \.date) { plate in
                    Button {
                        opened = plate
                    } label: {
                        HStack(spacing: 10) {
                            PlateThumbnail(photoID: plate.photoID)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(plate.date.formatted(date: .omitted, time: .shortened))
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Theme.secondaryText)
                                Text(
                                    plate.items
                                        .compactMap { $0.food?.name[language] }
                                        .joined(separator: ", ")
                                )
                                .font(.system(size: 13))
                                .foregroundStyle(Theme.primaryText)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            Text("\(Int(plate.proteinG)) g")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.accent)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

/// La vignette d'une assiette, ou le couvert quand la photo manque.
struct PlateThumbnail: View {
    var photoID: String?
    var side: CGFloat = 46

    @Environment(CoachStore.self) private var store
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "fork.knife")
                    .font(.system(size: side * 0.4))
                    .foregroundStyle(Theme.secondaryText)
            }
        }
        .frame(width: side, height: side)
        .background(Theme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task(id: photoID) {
            guard let photoID, let data = store.photos.data(for: photoID) else {
                image = nil
                return
            }
            image = UIImage(data: data)
        }
    }
}

/// Une assiette déjà enregistrée, rouverte.
///
/// On se souvient à 22 h qu'il y avait aussi du fromage. Avant cet écran il
/// fallait supprimer l'assiette et la refaire — et la photo, elle, ne se
/// refait pas.
struct PlateDetailView: View {
    var plate: PlateEstimate

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var items: [PlateItem] = []
    @State private var showsPicker = false
    @State private var loaded: UIImage?

    private var estimate: PlateEstimate { PlateEstimate(items: items) }

    private var frequentFoods: [Food] {
        var counts: [String: Int] = [:]
        for past in store.recentPlates(days: 30) {
            for item in past.items { counts[item.foodID, default: 0] += 1 }
        }
        return counts
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(8)
            .compactMap { FoodCatalog.food(id: $0.key) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let loaded {
                        Image(uiImage: loaded)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }

                    Card(
                        title: plate.date.formatted(date: .abbreviated, time: .shortened),
                        subtitle: LocalizedText(
                            fr: "Estimation à environ \(Int(estimate.uncertaintyPercent)) % près.",
                            en: "Estimate to within about \(Int(estimate.uncertaintyPercent)) %.",
                            es: "Estimación con un margen del \(Int(estimate.uncertaintyPercent)) %."
                        )[language]
                    ) {
                        HStack(spacing: 12) {
                            StatTile(
                                value: "\(estimate.proteinRangeG.lowerBound)–\(estimate.proteinRangeG.upperBound) g",
                                label: LocalizedText(fr: "Protéines", en: "Protein", es: "Proteína")[language]
                            )
                            StatTile(value: "\(Int(estimate.calories))", label: "kcal")
                            StatTile(
                                value: "\(Int(estimate.macros.carbsG)) g",
                                label: LocalizedText(fr: "Glucides", en: "Carbs", es: "Hidratos")[language],
                                tint: Theme.secondaryText
                            )
                            StatTile(
                                value: "\(Int(estimate.macros.fatG)) g",
                                label: LocalizedText(fr: "Lipides", en: "Fat", es: "Grasas")[language],
                                tint: Theme.secondaryText
                            )
                        }
                    }

                    Card(
                        title: LocalizedText(
                            fr: "Ce qu'il y avait", en: "What was on it", es: "Lo que había"
                        )[language],
                        subtitle: LocalizedText(
                            fr: "Corrige librement : la journée se recalcule aussitôt.",
                            en: "Correct freely: the day recomputes at once.",
                            es: "Corrige libremente: el día se recalcula al instante."
                        )[language]
                    ) {
                        VStack(spacing: 14) {
                            ForEach(items) { item in
                                itemRow(item)
                            }
                            Button {
                                showsPicker = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(
                                        LocalizedText(
                                            fr: "Ajouter un aliment",
                                            en: "Add a food",
                                            es: "Añadir un alimento"
                                        )[language]
                                    )
                                    .font(.system(size: 13, weight: .medium))
                                }
                                .foregroundStyle(Theme.accent)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    PrimaryButton(
                        title: LocalizedText(
                            fr: "Enregistrer les corrections",
                            en: "Save the corrections",
                            es: "Guardar las correcciones"
                        )[language],
                        systemImage: "checkmark"
                    ) {
                        store.updatePlate(at: plate.date, items: items)
                        dismiss()
                    }

                    Button {
                        store.deletePlate(at: plate.date)
                        dismiss()
                    } label: {
                        Text(
                            LocalizedText(
                                fr: "Supprimer cette assiette",
                                en: "Delete this plate",
                                es: "Eliminar este plato"
                            )[language]
                        )
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.danger)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Assiette", en: "Plate", es: "Plato")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .sheet(isPresented: $showsPicker) {
                PlateFoodPicker(focus: nil, frequent: frequentFoods) { food in
                    guard !items.contains(where: { $0.foodID == food.id }) else { return }
                    items.append(PlateItem(foodID: food.id, portion: .medium))
                }
            }
            .task {
                items = plate.items
                guard let photoID = plate.photoID, let data = store.photos.data(for: photoID)
                else { return }
                loaded = UIImage(data: data)
            }
        }
    }

    @ViewBuilder
    private func itemRow(_ item: PlateItem) -> some View {
        if let food = item.food {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(food.name[language])
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.primaryText)
                        Text(
                            "\(Int(item.grams)) g · \(Int(item.macros.proteinG)) g "
                                + LocalizedText(fr: "de protéines", en: "protein", es: "de proteína")[language]
                        )
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.secondaryText)
                    }
                    Spacer()
                    Button {
                        items.removeAll { $0.foodID == item.foodID }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }
                HStack(spacing: 6) {
                    ForEach(PortionSize.allCases) { size in
                        Button {
                            if let index = items.firstIndex(where: { $0.foodID == item.foodID }) {
                                items[index].portion = size
                            }
                        } label: {
                            VStack(spacing: 1) {
                                Text(size.label[language])
                                    .font(.system(size: 11, weight: .medium))
                                Text(size.hint(for: food.role)[language])
                                    .font(.system(size: 9))
                                    .opacity(0.8)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                            .foregroundStyle(item.portion == size ? Theme.background : Theme.primaryText)
                            .background(
                                item.portion == size ? Theme.accent : Theme.surfaceRaised,
                                in: RoundedRectangle(cornerRadius: 8)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

/// Les mots que l'athlète a appris à l'application, et de quoi les défaire.
///
/// Une mémoire qu'on ne peut pas relire ni corriger n'est pas une mémoire :
/// c'est une boîte noire. Celle-ci se lit d'un coup d'œil et s'efface d'un
/// appui — d'autant qu'on se trompe aussi en apprenant.
struct PlateVocabularyView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    private var learned: [LearnedWord] {
        store.plateCorrections
            .compactMap { label, foodID -> LearnedWord? in
                guard let food = FoodCatalog.food(id: foodID) else { return nil }
                return LearnedWord(label: label, food: food)
            }
            .sorted { $0.label < $1.label }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card {
                        CoachText(
                            LocalizedText(
                                fr: "Le classificateur du téléphone parle anglais et nomme des milliers de choses. Chaque fois que tu lui traduis un mot, il le retient pour toutes les photos suivantes. Rien de tout cela ne quitte l'appareil.",
                                en: "The phone's classifier speaks English and names thousands of things. Each time you translate a word for it, it remembers for every photo afterwards. None of this leaves the device.",
                                es: "El clasificador del teléfono habla inglés y nombra miles de cosas. Cada vez que le traduces una palabra, la recuerda para todas las fotos siguientes. Nada de esto sale del dispositivo."
                            )
                        )
                    }

                    if learned.isEmpty {
                        Card {
                            CoachText(
                                LocalizedText(
                                    fr: "Tu ne m'as encore rien appris. Photographie une assiette, ouvre « Tout ce que j'ai vu », et traduis un mot que je n'ai pas su reconnaître.",
                                    en: "You have not taught me anything yet. Photograph a plate, open “Everything I saw”, and translate a word I could not recognise.",
                                    es: "Todavía no me has enseñado nada. Fotografía un plato, abre «Todo lo que he visto» y traduce una palabra que no supe reconocer."
                                )
                            )
                        }
                    } else {
                        Card(
                            title: LocalizedText(
                                fr: "\(learned.count) mot\(learned.count > 1 ? "s" : "") appris",
                                en: "\(learned.count) word\(learned.count > 1 ? "s" : "") learned",
                                es: "\(learned.count) palabra\(learned.count > 1 ? "s" : "") aprendida\(learned.count > 1 ? "s" : "")"
                            )[language]
                        ) {
                            VStack(spacing: 10) {
                                ForEach(learned) { entry in
                                    HStack(spacing: 8) {
                                        Text(entry.readable)
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Theme.secondaryText)
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 10))
                                            .foregroundStyle(Theme.secondaryText)
                                        Text(entry.food.name[language])
                                            .font(Theme.bodyFont)
                                            .foregroundStyle(Theme.primaryText)
                                        Spacer()
                                        Button {
                                            store.forgetPlateLabel(entry.label)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundStyle(Theme.secondaryText)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(
                    fr: "Ce que je sais de toi", en: "What I know from you", es: "Lo que sé de ti"
                )[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }
}
