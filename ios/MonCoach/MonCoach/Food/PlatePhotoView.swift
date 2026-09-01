import PhotosUI
import SwiftUI
import Vision
import MonCoachKit

/// Photographier son assiette pour savoir ce qu'on mange.
///
/// Pourquoi cet écran existe
/// -------------------------
/// Peser ses repas marche une semaine. Ensuite on arrête, et avec ça on
/// arrête de savoir où l'on en est de ses protéines. Une photo prend deux
/// secondes, et deux secondes, ça tient des mois.
///
/// Ce que fait vraiment cet écran, et ce qu'il ne fait pas
/// ------------------------------------------------------
/// La reconnaissance tourne sur l'appareil, avec le classificateur d'images
/// du système. Elle **propose** ce qu'elle croit voir ; c'est l'athlète qui
/// confirme, corrige et ajuste les portions. Aucune photo ne part nulle
/// part — il n'y a pas de serveur, et il n'y en aura pas.
///
/// L'estimation qui en sort est une estimation, et l'écran le dit : les
/// protéines sont annoncées en fourchette, pas au gramme. Une photo ne voit
/// pas ce qu'il y a sous la surface, ni l'huile de cuisson. Prétendre le
/// contraire donnerait à ce chiffre une autorité qu'aucune photo ne peut
/// lui donner — et un chiffre faux auquel on croit est pire qu'un chiffre
/// absent.
struct PlatePhotoView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var pick: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var items: [PlateItem] = []
    @State private var analysing = false
    @State private var recognisedNothing = false
    @State private var showsFoodPicker = false
    @State private var showsCamera = false
    /// Les rayons devinés quand aucun aliment précis n'a été reconnu.
    @State private var seenRoles: [FoodRole] = []
    /// Le rayon sur lequel ouvrir le catalogue, quand on y entre par une
    /// famille devinée.
    @State private var pickerRole: FoodRole?

    private var estimate: PlateEstimate {
        PlateEstimate(items: items)
    }

    private var excluded: Set<String> { store.profile?.excludedFoods ?? [] }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    photoCard
                    if !items.isEmpty {
                        totalCard
                        itemsCard
                        saveButton
                    } else if recognisedNothing && !analysing {
                        emptyResultCard
                    }
                    honestyCard
                }
                .padding(16)
            }
            .screenBackground()
            .navigationTitle(
                LocalizedText(fr: "Mon assiette", en: "My plate", es: "Mi plato")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
            .sheet(isPresented: $showsFoodPicker) {
                PlateFoodPicker(focus: pickerRole) { food in
                    guard !items.contains(where: { $0.foodID == food.id }) else { return }
                    items.append(PlateItem(foodID: food.id, portion: .medium))
                }
            }
            .onChange(of: pick) { _, item in
                Task { await load(item) }
            }
            .fullScreenCover(isPresented: $showsCamera) {
                CameraCapture { data in
                    Task { await use(data) }
                }
                .ignoresSafeArea()
            }
        }
    }

    // MARK: - La photo

    private var photoCard: some View {
        Card {
            VStack(spacing: 12) {
                if let imageData, let image = UIImage(data: imageData) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(alignment: .bottomTrailing) {
                            if analysing {
                                ProgressView()
                                    .padding(8)
                                    .background(.ultraThinMaterial, in: Circle())
                                    .padding(8)
                            }
                        }
                }
                // Deux portes : l'appareil photo, parce que l'assiette est
                // devant soi maintenant, et la photothèque pour celle qu'on
                // a prise au restaurant sans ouvrir l'application.
                HStack(spacing: 10) {
                    if CameraCapture.isAvailable {
                        Button {
                            showsCamera = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                Text(
                                    LocalizedText(
                                        fr: "Photographier",
                                        en: "Take a photo",
                                        es: "Hacer una foto"
                                    )[language]
                                )
                            }
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.background)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    PhotosPicker(selection: $pick, matching: .images, photoLibrary: .shared()) {
                        HStack(spacing: 8) {
                            Image(systemName: "photo.on.rectangle")
                            Text(
                                LocalizedText(fr: "Choisir", en: "Choose", es: "Elegir")[language]
                            )
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(CameraCapture.isAvailable ? Theme.primaryText : Theme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            CameraCapture.isAvailable ? Theme.surfaceRaised : Theme.accent,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Le total

    private var totalCard: some View {
        let plate = estimate
        let range = plate.proteinRangeG
        return Card(
            title: LocalizedText(fr: "Dans cette assiette", en: "On this plate", es: "En este plato")[language],
            // La fourchette, jamais le gramme : une photo ne voit ni le fond
            // de l'assiette ni l'huile de cuisson.
            subtitle: LocalizedText(
                fr: "Estimation à environ \(Int(plate.uncertaintyPercent)) % près — corrige les portions, c'est là que se joue l'écart.",
                en: "Estimate to within about \(Int(plate.uncertaintyPercent)) % — adjust the portions, that is where the gap sits.",
                es: "Estimación con un margen del \(Int(plate.uncertaintyPercent)) % — ajusta las raciones, ahí está la diferencia."
            )[language]
        ) {
            HStack(spacing: 12) {
                StatTile(
                    value: "\(range.lowerBound)–\(range.upperBound) g",
                    label: LocalizedText(fr: "Protéines", en: "Protein", es: "Proteína")[language]
                )
                StatTile(value: "\(Int(plate.calories))", label: "kcal")
                StatTile(
                    value: "\(Int(plate.macros.carbsG)) g",
                    label: LocalizedText(fr: "Glucides", en: "Carbs", es: "Hidratos")[language],
                    tint: Theme.secondaryText
                )
                StatTile(
                    value: "\(Int(plate.macros.fatG)) g",
                    label: LocalizedText(fr: "Lipides", en: "Fat", es: "Grasas")[language],
                    tint: Theme.secondaryText
                )
            }
            // Ce que ça pèse dans la journée : c'est la seule lecture qui
            // fait agir. « 38 g de protéines » ne dit rien ; « il t'en reste
            // 90 pour la journée » dit quoi faire au dîner.
            if let target = store.briefing()?.nutrition {
                let eatenSoFar = (store.eatenToday()?.proteinG ?? 0) + plate.proteinG
                let remaining = max(0, Double(target.proteinG) - eatenSoFar)
                CoachText(
                    remaining > 0
                        ? LocalizedText(
                            fr: "Avec ça, il te resterait \(Int(remaining)) g de protéines à prendre aujourd'hui, sur \(target.proteinG) g visés.",
                            en: "With this, you would have \(Int(remaining)) g of protein left today, out of \(target.proteinG) g targeted.",
                            es: "Con esto te quedarían \(Int(remaining)) g de proteína hoy, de los \(target.proteinG) g previstos."
                        )
                        : LocalizedText(
                            fr: "Avec ça, ta cible de \(target.proteinG) g de protéines est atteinte pour aujourd'hui.",
                            en: "With this, your \(target.proteinG) g protein target is met for today.",
                            es: "Con esto, tu objetivo de \(target.proteinG) g de proteína está cubierto hoy."
                        ),
                    font: .system(size: 13)
                )
            }
        }
    }

    // MARK: - Les aliments reconnus

    private var itemsCard: some View {
        Card(
            title: LocalizedText(fr: "Ce que j'y vois", en: "What I see", es: "Lo que veo")[language],
            subtitle: LocalizedText(
                fr: "Retire ce qui n'y est pas, ajoute ce qui manque, règle les portions à la main.",
                en: "Remove what isn't there, add what's missing, set the portions by hand.",
                es: "Quita lo que no está, añade lo que falta, ajusta las raciones a mano."
            )[language]
        ) {
            VStack(spacing: 14) {
                ForEach(items) { item in
                    itemRow(item)
                }
                Button {
                    pickerRole = nil
                    showsFoodPicker = true
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
                    // Ce qui vient de la reconnaissance est signalé comme
                    // tel : l'athlète doit savoir ce qu'il confirme.
                    if let confidence = item.confidence {
                        Pill(
                            text: confidence >= 0.6
                                ? LocalizedText(fr: "reconnu", en: "recognised", es: "reconocido")[language]
                                : LocalizedText(fr: "peut-être", en: "maybe", es: "quizá")[language],
                            tint: confidence >= 0.6 ? Theme.accent : Theme.warning
                        )
                    }
                    Button {
                        items.removeAll { $0.foodID == item.foodID }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.secondaryText)
                    }
                    .buttonStyle(.plain)
                }

                // Les repères visuels plutôt que des grammes : personne ne
                // sait voir 173 g, tout le monde sait voir une paume.
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

    private var emptyResultCard: some View {
        Card(
            title: seenRoles.isEmpty
                ? LocalizedText(
                    fr: "Je ne reconnais rien de sûr",
                    en: "Nothing I can name confidently",
                    es: "No reconozco nada con seguridad"
                )[language]
                : LocalizedText(
                    fr: "Je ne sais pas nommer précisément",
                    en: "I cannot name it precisely",
                    es: "No sé nombrarlo con precisión"
                )[language]
        ) {
            CoachText(
                seenRoles.isEmpty
                    ? LocalizedText(
                        fr: "Une assiette de face, à la lumière du jour, se reconnaît mieux. Tu peux aussi composer l'assiette à la main : c'est plus juste que ce que devinerait une photo floue.",
                        en: "A plate shot from above in daylight is easier to read. You can also build the plate by hand: it beats what a blurry photo would guess.",
                        es: "Un plato de frente y con luz de día se reconoce mejor. También puedes componerlo a mano: será más exacto que lo que adivinaría una foto borrosa."
                    )
                    : LocalizedText(
                        fr: "Je vois de quoi il s'agit sans pouvoir mettre un nom dessus. Ouvre le bon rayon et choisis : deux appuis, et le compte est juste.",
                        en: "I can see the kind of thing without putting a name on it. Open the right aisle and pick: two taps, and the count is right.",
                        es: "Veo de qué se trata sin poder ponerle nombre. Abre la sección correcta y elige: dos toques y la cuenta es exacta."
                    )
            )

            // Les rayons devinés, en gros : c'est le chemin le plus court
            // entre une photo illisible et une assiette juste.
            if !seenRoles.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(seenRoles, id: \.self) { role in
                        Button {
                            pickerRole = role
                            showsFoodPicker = true
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "plus")
                                    .font(.system(size: 11, weight: .bold))
                                Text(role.label[language])
                            }
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Theme.background)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Theme.accent, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                pickerRole = nil
                showsFoodPicker = true
            } label: {
                Text(
                    LocalizedText(
                        fr: "Composer à la main",
                        en: "Build it by hand",
                        es: "Componerlo a mano"
                    )[language]
                )
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Theme.accent)
            }
            .buttonStyle(.plain)
        }
    }

    private var honestyCard: some View {
        Card {
            CoachText(
                LocalizedText(
                    fr: "La reconnaissance tourne sur ton téléphone et la photo n'est envoyée nulle part. Elle propose, tu confirmes : une image ne voit ni le fond de l'assiette, ni l'huile de cuisson. Sers-t'en pour suivre une tendance, pas pour compter au gramme.",
                    en: "Recognition runs on your phone and the photo is sent nowhere. It proposes, you confirm: an image sees neither the bottom of the plate nor the cooking oil. Use it to follow a trend, not to count to the gram.",
                    es: "El reconocimiento se ejecuta en tu teléfono y la foto no se envía a ninguna parte. Propone, tú confirmas: una imagen no ve el fondo del plato ni el aceite de cocción. Úsalo para seguir una tendencia, no para contar al gramo."
                ),
                font: .system(size: 12)
            )
        }
    }

    private var saveButton: some View {
        PrimaryButton(
            title: LocalizedText(
                fr: "Enregistrer ce repas",
                en: "Log this meal",
                es: "Registrar esta comida"
            )[language],
            systemImage: "checkmark"
        ) {
            store.recordPlate(PlateEstimate(items: items), photo: imageData)
            dismiss()
        }
    }

    // MARK: - La reconnaissance

    private func load(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        analysing = true
        recognisedNothing = false
        defer { analysing = false }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await use(data)
    }

    /// Le chemin commun des deux portes : compresser, reconnaître, proposer.
    private func use(_ data: Data) async {
        analysing = true
        defer { analysing = false }
        // La photo est recompressée avant d'être gardée : une image d'appareil
        // photo pèse cinq mégaoctets, et l'estimation n'en a pas besoin.
        imageData = PhotoEncoding.prepared(from: data) ?? data
        let readings = await recognise(data)
        items = PlateVision.foods(from: readings, excluding: excluded)
        // Ce que le système a cru voir sans savoir le nommer : « de la
        // viande et un féculent » ouvre la bonne page du catalogue, là où
        // « je ne reconnais rien » était un cul-de-sac.
        seenRoles = items.isEmpty ? PlateVision.roles(from: readings) : []
        recognisedNothing = items.isEmpty
    }

    /// Ce que le classificateur du système croit voir, traduit en aliments.
    ///
    /// Hors du fil principal : la classification d'une image prend des
    /// centaines de millisecondes, et l'interface doit rester vivante — sans
    /// quoi l'écran se fige juste après le déclenchement, au moment précis
    /// où l'on croit que l'application a planté.
    private func recognise(_ data: Data) async -> [(identifier: String, confidence: Double)] {
        await Task.detached(priority: .userInitiated) { () -> [(identifier: String, confidence: Double)] in
            let request = VNClassifyImageRequest()
            let handler = VNImageRequestHandler(data: data, options: [:])
            guard (try? handler.perform([request])) != nil,
                  let observations = request.results
            else { return [] }

            // Le tri fiable est celui du système, pas un seuil écrit à la
            // main.
            //
            // Le classificateur note plus de mille catégories
            // indépendamment : ses confiances ne sont pas des probabilités,
            // et une reconnaissance franche sort couramment autour de 0,1.
            // Un seuil brut de trente pour cent ne laissait donc rien
            // passer — cinq assiettes parfaitement nettes n'ont rien donné.
            // `hasMinimumPrecision` répond à la vraie question : « à ce
            // niveau de rappel, cette étiquette est-elle assez sûre ? »,
            // et c'est le modèle lui-même qui la connaît.
            let trusted = observations.filter { $0.hasMinimumPrecision(0.4, forRecall: 0.5) }
            let kept = trusted.isEmpty ? Array(observations.prefix(40)) : trusted
            return kept.map { (identifier: $0.identifier, confidence: Double($0.confidence)) }
        }.value
    }
}

/// Le catalogue, pour ajouter à la main ce que la photo n'a pas vu.
private struct PlateFoodPicker: View {
    /// Le rayon sur lequel ouvrir, quand on sait déjà de quoi il s'agit.
    var focus: FoodRole?
    var onPick: (Food) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language
    @State private var search = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Theme.secondaryText)
                            TextField(
                                LocalizedText(fr: "Chercher", en: "Search", es: "Buscar")[language],
                                text: $search
                            )
                            .font(Theme.bodyFont)
                            .autocorrectionDisabled()
                        }
                    }
                    ForEach(FoodRole.allCases.filter { focus == nil || $0 == focus }, id: \.self) { role in
                        let foods = FoodCatalog.all
                            .filter { $0.role == role && matches($0) }
                            .sorted { $0.name[language] < $1.name[language] }
                        if !foods.isEmpty {
                            Card(title: role.label[language]) {
                                VStack(spacing: 2) {
                                    ForEach(foods) { food in
                                        Button {
                                            onPick(food)
                                            dismiss()
                                        } label: {
                                            HStack {
                                                Text(food.name[language])
                                                    .font(Theme.bodyFont)
                                                    .foregroundStyle(Theme.primaryText)
                                                Spacer()
                                                Text("\(Int(food.proteinG)) g P")
                                                    .font(.system(size: 11))
                                                    .foregroundStyle(Theme.secondaryText)
                                            }
                                            .padding(.vertical, 6)
                                            .contentShape(Rectangle())
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
                LocalizedText(fr: "Ajouter", en: "Add", es: "Añadir")[language]
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
            }
        }
    }

    private func matches(_ food: Food) -> Bool {
        guard !search.isEmpty else { return true }
        let normalise = { (text: String) in
            text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: language.locale)
        }
        return normalise(food.name[language]).contains(normalise(search))
    }
}
