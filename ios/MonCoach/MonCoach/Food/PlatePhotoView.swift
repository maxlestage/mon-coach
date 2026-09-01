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
///
/// Ce que l'écran montre maintenant, et qu'il cachait
/// -------------------------------------------------
/// Tout. Y compris les mots que le catalogue ne sait pas traduire. La
/// version précédente les jetait en silence, et devant une assiette non
/// reconnue on ne pouvait pas savoir si le système n'avait rien vu ou si
/// c'était le catalogue qui ne suivait pas. La différence change tout :
/// dans un cas on refait la photo, dans l'autre on apprend le mot une bonne
/// fois — et l'application le retient.
struct PlatePhotoView: View {
    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var pick: PhotosPickerItem?
    @State private var imageData: Data?
    /// Ce que l'assiette contient, tel que l'athlète l'a laissé.
    @State private var items: [PlateItem] = []
    /// Tout ce que la photo a donné, y compris l'intraduisible.
    @State private var analysis: PlateAnalysis = .empty
    /// Les lectures brutes, gardées telles quelles : apprendre un mot
    /// relance l'analyse, et la relancer sur un résumé perdrait les zones.
    @State private var readings: [PlateReading] = []
    @State private var analysing = false
    /// Vrai dès qu'une photo a été analysée : sans ça, l'écran vide et
    /// l'écran « rien reconnu » se confondraient.
    @State private var analysed = false
    @State private var showsFoodPicker = false
    @State private var showsCamera = false
    /// Le rayon sur lequel ouvrir le catalogue, quand on y entre par une
    /// famille devinée.
    @State private var pickerRole: FoodRole?
    /// Le mot du système qu'on est en train de traduire, s'il y en a un.
    @State private var teaching: PlateSighting?
    /// Le détail des mots vus, replié par défaut : c'est une information de
    /// second rideau, précieuse quand on la cherche et encombrante sinon.
    @State private var showsEverything = false

    private var estimate: PlateEstimate {
        PlateEstimate(items: items)
    }

    /// Les aliments qui reviennent le plus souvent dans les assiettes du
    /// mois. Composer à la main devient deux appuis au lieu de vingt.
    private var frequentFoods: [Food] {
        var counts: [String: Int] = [:]
        for plate in store.recentPlates(days: 30) {
            for item in plate.items { counts[item.foodID, default: 0] += 1 }
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
                    photoCard
                    if !items.isEmpty {
                        totalCard
                        itemsCard
                    }
                    if analysed && !analysing {
                        if items.isEmpty { emptyResultCard }
                        if !analysis.refused.isEmpty { refusedCard }
                        everythingCard
                    }
                    if !items.isEmpty { saveButton }
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
                PlateFoodPicker(focus: pickerRole, frequent: frequentFoods) { food in
                    add(food)
                }
            }
            .sheet(item: $teaching) { sighting in
                PlateFoodPicker(
                    focus: nil,
                    frequent: frequentFoods,
                    teaching: sighting.readable
                ) { food in
                    learn(sighting, as: food)
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
                if analysing {
                    Text(
                        LocalizedText(
                            fr: "Je regarde l'assiette entière, puis chacun de ses quartiers.",
                            en: "Looking at the whole plate, then at each of its quarters.",
                            es: "Miro el plato entero y luego cada uno de sus cuartos."
                        )[language]
                    )
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

    // MARK: - Les aliments retenus

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
                    // tel : l'athlète doit savoir ce qu'il confirme. La
                    // force se lit par rapport au reste de la photo, jamais
                    // en pourcentage — les notes du classificateur ne sont
                    // pas des probabilités, et « 12 % » se lirait comme
                    // « improbable » alors que c'est une belle note.
                    if let confidence = item.confidence {
                        let strength = Strength(of: confidence, best: bestConfidence)
                        Pill(text: strength.label[language], tint: strength.tint)
                    } else {
                        Pill(
                            text: LocalizedText(fr: "ajouté", en: "added", es: "añadido")[language],
                            tint: Theme.secondaryText
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

    // MARK: - Ce qui a été écarté du plan

    /// Un aliment reconnu mais refusé par le profil — allergie, dégoût.
    ///
    /// Il ne rentre pas dans l'assiette, et il ne disparaît pas non plus :
    /// un allergique doit savoir que la photo a vu l'arachide. Le taire
    /// serait le pire des silences.
    private var refusedCard: some View {
        Card(
            title: LocalizedText(
                fr: "Vu, mais écarté de ton plan",
                en: "Seen, but ruled out of your plan",
                es: "Visto, pero descartado de tu plan"
            )[language],
            subtitle: LocalizedText(
                fr: "Tu as demandé à ne jamais voir ces aliments. Ils ne sont pas comptés — mais s'ils sont vraiment dans l'assiette, il faut le savoir.",
                en: "You asked never to see these foods. They are not counted — but if they really are on the plate, you need to know.",
                es: "Pediste no ver nunca estos alimentos. No se cuentan, pero si de verdad están en el plato, hay que saberlo."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(analysis.refused) { sighting in
                    if case .refused(let foodID) = sighting.outcome,
                       let food = FoodCatalog.food(id: foodID) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Theme.danger)
                            Text(food.name[language])
                                .font(Theme.bodyFont)
                                .foregroundStyle(Theme.primaryText)
                            Text("· \(sighting.readable)")
                                .font(.system(size: 11))
                                .foregroundStyle(Theme.secondaryText)
                            Spacer()
                            Button {
                                add(food)
                            } label: {
                                Text(
                                    LocalizedText(
                                        fr: "Compter quand même",
                                        en: "Count it anyway",
                                        es: "Contarlo igualmente"
                                    )[language]
                                )
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Theme.accent)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Tout ce que la photo a donné

    /// La liste complète, mot par mot.
    ///
    /// C'est la carte qui répond à « pourquoi il n'a pas vu mon poulet ? ».
    /// Les mots inconnus s'y traduisent une bonne fois : l'application les
    /// retient, et la photo suivante les reconnaît toute seule.
    private var everythingCard: some View {
        Card(
            title: LocalizedText(
                fr: "Tout ce que j'ai vu",
                en: "Everything I saw",
                es: "Todo lo que he visto"
            )[language],
            subtitle: LocalizedText(
                fr: "\(analysis.sightings.count) mots, du plus sûr au moins sûr. Ceux que le catalogue ne connaît pas, tu peux me les apprendre : je les reconnaîtrai ensuite tout seul.",
                en: "\(analysis.sightings.count) words, from surest to least sure. The ones the catalogue does not know, you can teach me: I will recognise them on my own afterwards.",
                es: "\(analysis.sightings.count) palabras, de la más segura a la menos. Las que el catálogo no conoce, puedes enseñármelas: luego las reconoceré solo."
            )[language]
        ) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(showsEverything ? analysis.sightings : Array(analysis.sightings.prefix(6))) { sighting in
                    sightingRow(sighting)
                }
                if analysis.sightings.count > 6 {
                    Button {
                        showsEverything.toggle()
                    } label: {
                        Text(
                            showsEverything
                                ? LocalizedText(fr: "Replier", en: "Collapse", es: "Plegar")[language]
                                : LocalizedText(
                                    fr: "Voir les \(analysis.sightings.count - 6) autres",
                                    en: "See the other \(analysis.sightings.count - 6)",
                                    es: "Ver los otros \(analysis.sightings.count - 6)"
                                )[language]
                        )
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.accent)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func sightingRow(_ sighting: PlateSighting) -> some View {
        let strength = Strength(of: sighting.confidence, best: bestSightingConfidence)
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                ConfidenceBar(fraction: strength.fraction, tint: strength.tint)
                Text(sighting.readable)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Theme.primaryText)
                    .lineLimit(1)
                Spacer()
                outcomeLabel(sighting)
            }
            HStack(spacing: 6) {
                Text(strength.label[language])
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.secondaryText)
                // Où le mot est apparu : c'est ce qui explique qu'un aliment
                // du coin de l'assiette soit passé devant celui du milieu.
                Text(sighting.regions.map { $0.label[language] }.joined(separator: ", "))
                    .font(.system(size: 10))
                    .foregroundStyle(Theme.secondaryText)
                    .lineLimit(1)
            }
        }
    }

    @ViewBuilder
    private func outcomeLabel(_ sighting: PlateSighting) -> some View {
        switch sighting.outcome {
        case .food(let foodID):
            Text(FoodCatalog.food(id: foodID)?.name[language] ?? foodID)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
        case .refused:
            Text(LocalizedText(fr: "écarté", en: "ruled out", es: "descartado")[language])
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.danger)
        case .aisle(let role):
            Button {
                pickerRole = role
                showsFoodPicker = true
            } label: {
                Text(role.label[language])
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.warning)
            }
            .buttonStyle(.plain)
        case .unknown:
            Button {
                teaching = sighting
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "graduationcap")
                        .font(.system(size: 10, weight: .semibold))
                    Text(LocalizedText(fr: "m'apprendre", en: "teach me", es: "enséñame")[language])
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundStyle(Theme.secondaryText)
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyResultCard: some View {
        Card(
            title: analysis.roles.isEmpty
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
                analysis.roles.isEmpty
                    ? LocalizedText(
                        fr: "Une assiette de face, à la lumière du jour, se reconnaît mieux. La liste plus bas dit quand même tout ce que j'ai vu : si un mot y ressemble à ton plat, apprends-le-moi et je le reconnaîtrai la prochaine fois.",
                        en: "A plate shot from above in daylight is easier to read. The list below still shows everything I saw: if a word looks like your dish, teach it to me and I will know it next time.",
                        es: "Un plato de frente y con luz de día se reconoce mejor. La lista de abajo muestra igualmente todo lo que he visto: si una palabra se parece a tu plato, enséñamela y la reconoceré la próxima vez."
                    )
                    : LocalizedText(
                        fr: "Je vois de quoi il s'agit sans pouvoir mettre un nom dessus. Ouvre le bon rayon et choisis : deux appuis, et le compte est juste.",
                        en: "I can see the kind of thing without putting a name on it. Open the right aisle and pick: two taps, and the count is right.",
                        es: "Veo de qué se trata sin poder ponerle nombre. Abre la sección correcta y elige: dos toques y la cuenta es exacta."
                    )
            )

            // Les rayons devinés, en gros : c'est le chemin le plus court
            // entre une photo illisible et une assiette juste.
            if !analysis.roles.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(analysis.roles, id: \.self) { role in
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
            if !store.plateCorrections.isEmpty {
                CoachText(
                    LocalizedText(
                        fr: "Tu m'as appris \(store.plateCorrections.count) mot\(store.plateCorrections.count > 1 ? "s" : "") : je m'en sers sur chaque photo, et ça ne quitte pas ce téléphone.",
                        en: "You have taught me \(store.plateCorrections.count) word\(store.plateCorrections.count > 1 ? "s" : ""): I use them on every photo, and they never leave this phone.",
                        es: "Me has enseñado \(store.plateCorrections.count) palabra\(store.plateCorrections.count > 1 ? "s" : ""): las uso en cada foto y no salen de este teléfono."
                    ),
                    font: .system(size: 12)
                )
            }
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

    // MARK: - Les gestes

    private func add(_ food: Food) {
        guard !items.contains(where: { $0.foodID == food.id }) else { return }
        items.append(
            PlateItem(
                foodID: food.id,
                portion: PlateVision.preferredPortion(for: food.id, in: store.recentPlates(days: 90)) ?? .medium
            )
        )
    }

    /// Apprendre un mot, et l'appliquer tout de suite à la photo en cours.
    ///
    /// Sans la seconde moitié, l'athlète aurait appris quelque chose sans
    /// rien voir se produire — et n'aurait jamais recommencé.
    private func learn(_ sighting: PlateSighting, as food: Food) {
        store.learnPlateLabel(sighting.label, as: food.id)
        add(food)
        analysis = store.analysePlate(readings)
    }

    /// La meilleure note parmi les aliments retenus, pour lire les autres
    /// par rapport à elle.
    private var bestConfidence: Double {
        items.compactMap(\.confidence).max() ?? 1
    }

    private var bestSightingConfidence: Double {
        analysis.sightings.map(\.confidence).max() ?? 1
    }

    // MARK: - La reconnaissance

    private func load(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        analysing = true
        defer { analysing = false }
        guard let data = try? await item.loadTransferable(type: Data.self) else { return }
        await use(data)
    }

    /// Le chemin commun des deux portes : préparer, regarder, proposer.
    private func use(_ data: Data) async {
        analysing = true
        defer { analysing = false }
        // La photo est recompressée avant d'être gardée : une image d'appareil
        // photo pèse cinq mégaoctets, et l'estimation n'en a pas besoin. Le
        // réencodage redresse aussi l'orientation, ce dont le découpage en
        // quartiers a absolument besoin — sinon le « haut à droite » est en
        // bas à gauche.
        let prepared = PhotoEncoding.prepared(from: data) ?? data
        imageData = prepared
        readings = await recognise(prepared)
        analysis = store.analysePlate(readings)
        items = analysis.items
        analysed = true
        showsEverything = false
    }

    /// Ce que le classificateur du système croit voir, zone par zone.
    ///
    /// Hors du fil principal : six classifications prennent près d'une
    /// seconde, et l'interface doit rester vivante — sans quoi l'écran se
    /// fige juste après le déclenchement, au moment précis où l'on croit que
    /// l'application a planté.
    private func recognise(_ data: Data) async -> [PlateReading] {
        await Task.detached(priority: .userInitiated) { () -> [PlateReading] in
            guard let image = UIImage(data: data), let full = image.cgImage else { return [] }
            var readings: [PlateReading] = []
            for (region, rect) in Self.crops(of: full) {
                guard let piece = region == .whole ? full : full.cropping(to: rect) else { continue }
                readings.append(contentsOf: Self.classify(piece, region: region))
            }
            return readings
        }.value
    }

    /// Le découpage : l'assiette entière, son centre, et ses quatre quarts.
    ///
    /// Les quarts se chevauchent d'un dixième : un aliment posé pile sur la
    /// ligne de partage se retrouverait sinon coupé en deux moitiés que le
    /// classificateur ne reconnaîtrait ni l'une ni l'autre.
    nonisolated static func crops(of image: CGImage) -> [(PlateRegion, CGRect)] {
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)
        let halfWidth = width * 0.6
        let halfHeight = height * 0.6
        return [
            (.whole, CGRect(x: 0, y: 0, width: width, height: height)),
            (.centre, CGRect(
                x: width * 0.2, y: height * 0.2,
                width: width * 0.6, height: height * 0.6
            )),
            (.topLeft, CGRect(x: 0, y: 0, width: halfWidth, height: halfHeight)),
            (.topRight, CGRect(x: width - halfWidth, y: 0, width: halfWidth, height: halfHeight)),
            (.bottomLeft, CGRect(x: 0, y: height - halfHeight, width: halfWidth, height: halfHeight)),
            (.bottomRight, CGRect(
                x: width - halfWidth, y: height - halfHeight,
                width: halfWidth, height: halfHeight
            )),
        ]
    }

    /// Le tri fiable est celui du système, pas un seuil écrit à la main.
    ///
    /// Le classificateur note plus de mille catégories indépendamment : ses
    /// confiances ne sont pas des probabilités, et une reconnaissance
    /// franche sort couramment autour de 0,1. Un seuil brut de trente pour
    /// cent ne laissait donc rien passer — cinq assiettes parfaitement
    /// nettes n'ont rien donné. `hasMinimumPrecision` répond à la vraie
    /// question : « à ce niveau de rappel, cette étiquette est-elle assez
    /// sûre ? », et c'est le modèle lui-même qui la connaît.
    nonisolated static func classify(_ image: CGImage, region: PlateRegion) -> [PlateReading] {
        let request = VNClassifyImageRequest()
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        guard (try? handler.perform([request])) != nil,
              let observations = request.results
        else { return [] }
        let trusted = observations.filter { $0.hasMinimumPrecision(0.4, forRecall: 0.5) }
        // Un quartier est une image plus pauvre que l'assiette entière : on
        // y descend moins bas dans la liste, faute de quoi chaque coin
        // apporterait vingt mots de bruit.
        let fallback = Array(observations.prefix(region == .whole ? 40 : 15))
        let kept = trusted.isEmpty ? fallback : trusted
        return kept.map {
            PlateReading(identifier: $0.identifier, confidence: Double($0.confidence), region: region)
        }
    }
}

/// La force d'une reconnaissance, dite en mots plutôt qu'en pourcentage.
///
/// Les notes du classificateur ne sont pas des probabilités : afficher
/// « 12 % » se lirait comme « improbable » alors que c'est une belle note
/// sur mille catégories notées indépendamment. On les lit donc les unes par
/// rapport aux autres, sur la même photo — la seule comparaison qui ait un
/// sens.
struct Strength {
    var fraction: Double
    var label: LocalizedText
    var tint: Color

    init(of confidence: Double, best: Double) {
        let ratio = best > 0 ? confidence / best : 0
        fraction = min(1, max(0.05, ratio))
        if ratio >= 0.66 {
            label = LocalizedText(fr: "le plus sûr ici", en: "surest here", es: "lo más seguro aquí")
            tint = Theme.accent
        } else if ratio >= 0.33 {
            label = LocalizedText(fr: "probable", en: "likely", es: "probable")
            tint = Theme.warning
        } else {
            label = LocalizedText(fr: "au cas où", en: "just in case", es: "por si acaso")
            tint = Theme.secondaryText
        }
    }
}

/// Une jauge de vingt-huit points : assez pour comparer d'un coup d'œil,
/// trop courte pour se lire comme un chiffre.
struct ConfidenceBar: View {
    var fraction: Double
    var tint: Color

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Theme.surfaceRaised)
            Capsule().fill(tint).frame(width: 28 * fraction)
        }
        .frame(width: 28, height: 4)
    }
}

/// Le catalogue, pour ajouter à la main ce que la photo n'a pas vu — ou
/// pour apprendre à l'application un mot qu'elle ne connaissait pas.
struct PlateFoodPicker: View {
    /// Le rayon sur lequel ouvrir, quand on sait déjà de quoi il s'agit.
    var focus: FoodRole?
    /// Ce que l'athlète met le plus souvent dans son assiette.
    var frequent: [Food] = []
    /// Le mot du système qu'on est en train de traduire, s'il y en a un.
    var teaching: String?
    var onPick: (Food) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language
    @State private var search = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    if let teaching {
                        Card(
                            title: LocalizedText(
                                fr: "« \(teaching) », c'est quoi chez toi ?",
                                en: "“\(teaching)” — what is that for you?",
                                es: "«\(teaching)» ¿qué es para ti?"
                            )[language]
                        ) {
                            CoachText(
                                LocalizedText(
                                    fr: "Choisis l'aliment que ce mot désigne. Je le retiendrai pour toutes les photos suivantes, et ça ne quitte pas ce téléphone.",
                                    en: "Pick the food this word means. I will remember it for every photo from now on, and it never leaves this phone.",
                                    es: "Elige el alimento que significa esta palabra. Lo recordaré para todas las fotos siguientes, y no sale de este teléfono."
                                ),
                                font: .system(size: 13)
                            )
                        }
                    }

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

                    // Ce qui revient le plus souvent, d'abord. Composer une
                    // assiette à la main devient deux appuis au lieu de
                    // vingt — et c'est ce qui décide si on le refait demain.
                    if !frequent.isEmpty && search.isEmpty && focus == nil {
                        Card(
                            title: LocalizedText(
                                fr: "Souvent dans ton assiette",
                                en: "Often on your plate",
                                es: "A menudo en tu plato"
                            )[language]
                        ) {
                            FlowLayout(spacing: 8) {
                                ForEach(frequent) { food in
                                    Button {
                                        onPick(food)
                                        dismiss()
                                    } label: {
                                        Text(food.name[language])
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Theme.primaryText)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Theme.surfaceRaised, in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
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
                teaching == nil
                    ? LocalizedText(fr: "Ajouter", en: "Add", es: "Añadir")[language]
                    : LocalizedText(fr: "M'apprendre un mot", en: "Teach me a word", es: "Enséñame una palabra")[language]
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
