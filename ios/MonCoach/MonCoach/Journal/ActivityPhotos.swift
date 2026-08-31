import PhotosUI
import SwiftUI
import MonCoachKit

/// Ce qu'on met dans un fichier quand l'athlète choisit une photo.
///
/// Une photo d'iPhone pèse entre trois et huit mégaoctets. Quinze photos sur
/// une sortie de montagne, vingt sorties dans l'année, et l'application
/// occupe deux gigaoctets pour des images qu'on regarde sur un écran de six
/// pouces. Le côté le plus long est donc ramené à 2 048 pixels — plus que ce
/// qu'un téléphone affiche, assez pour zoomer — et le JPEG est réencodé.
enum PhotoEncoding {

    static let maximumSide: CGFloat = 2_048
    static let quality: CGFloat = 0.8

    /// Réduit et réencode une image. Rend nil quand les octets ne sont pas
    /// une image : mieux vaut ne rien attacher qu'un fichier illisible.
    static func prepared(from data: Data) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        return jpeg(from: resized(image))
    }

    static func resized(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maximumSide else { return image }
        let ratio = maximumSide / longest
        let target = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        // `UIGraphicsImageRenderer` respecte l'orientation EXIF : redessiner
        // sans lui coucherait les photos prises en portrait.
        return UIGraphicsImageRenderer(size: target).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }

    static func jpeg(from image: UIImage) -> Data? {
        image.jpegData(compressionQuality: quality)
    }
}

/// La bande de photos d'une sortie, et le bouton pour en ajouter.
///
/// Une sortie n'est pas qu'une série de chiffres : c'est le sommet, le lever
/// de soleil, le chien croisé au kilomètre huit. C'est ce qui fait qu'on
/// rouvre une sortie de l'an dernier — aucune allure moyenne n'a jamais
/// donné envie de faire ça.
struct PhotoStripView: View {
    var photoIDs: [String]
    var onAdd: (Data) -> Void
    var onDelete: (String) -> Void

    @Environment(\.language) private var language

    @State private var picked: [PhotosPickerItem] = []
    @State private var opened: OpenedPhoto?

    var body: some View {
        Card(
            title: LocalizedText(fr: "Photos", en: "Photos", es: "Fotos")[language],
            subtitle: photoIDs.isEmpty
                ? LocalizedText(
                    fr: "Elles restent sur ton téléphone : rien n'est téléversé, jamais.",
                    en: "They stay on your phone: nothing is ever uploaded.",
                    es: "Se quedan en tu teléfono: nunca se sube nada."
                )[language]
                : nil
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if !photoIDs.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(photoIDs, id: \.self) { id in
                                Button {
                                    opened = OpenedPhoto(id: id)
                                } label: {
                                    StoredPhotoView(id: id, side: 92)
                                }
                                .buttonStyle(.plain)
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
                    onAdd(prepared)
                }
            }
        }
        .sheet(item: $opened) { photo in
            PhotoDetailView(id: photo.id) {
                opened = nil
                onDelete(photo.id)
            }
        }
    }
}

/// Une photo rangée sur le disque, chargée à l'affichage.
///
/// Le chargement est fait dans une tâche plutôt qu'au calcul du corps de la
/// vue : SwiftUI recalcule un corps des dizaines de fois, et relire un
/// fichier de deux mégaoctets à chaque fois ferait ramer la page.
struct StoredPhotoView: View {
    var id: String
    var side: CGFloat?

    @Environment(CoachStore.self) private var store
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Theme.surfaceRaised
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundStyle(Theme.secondaryText)
                    )
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .task(id: id) {
            guard let data = store.photos.data(for: id) else { return }
            image = UIImage(data: data)
        }
    }
}

/// Une photo en grand, avec de quoi la retirer.
struct PhotoDetailView: View {
    var id: String
    var onDelete: () -> Void

    @Environment(CoachStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @Environment(\.language) private var language

    @State private var image: UIImage?
    @State private var confirmsDeletion = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else {
                    ProgressView().tint(Theme.accent)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(UI.close[language]) { dismiss() }
                }
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        confirmsDeletion = true
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
            .confirmationDialog(
                LocalizedText(
                    fr: "Retirer cette photo ?",
                    en: "Remove this photo?",
                    es: "¿Quitar esta foto?"
                )[language],
                isPresented: $confirmsDeletion,
                titleVisibility: .visible
            ) {
                Button(UI.delete[language], role: .destructive) { onDelete() }
                Button(UI.cancel[language], role: .cancel) {}
            } message: {
                // La photothèque du téléphone n'est pas touchée : l'image
                // affichée ici en est une copie réduite.
                CoachText(
                    LocalizedText(
                        fr: "Elle est retirée de la sortie. L'original reste dans ta photothèque.",
                        en: "It is removed from the activity. The original stays in your photo library.",
                        es: "Se quita de la salida. El original permanece en tu fototeca."
                    )
                )
            }
            .task(id: id) {
                guard let data = store.photos.data(for: id) else { return }
                image = UIImage(data: data)
            }
        }
    }
}

/// Une photo choisie mais pas encore attachée — le temps d'un écran de fin
/// de sortie, où la sortie elle-même n'est pas encore enregistrée.
struct PendingPhotoView: View {
    var data: Data
    var side: CGFloat = 92

    var body: some View {
        Group {
            if let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Theme.surfaceRaised
            }
        }
        .frame(width: side, height: side)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

/// La photo ouverte en grand.
///
/// Une enveloppe plutôt qu'un `String?` : `sheet(item:)` réclame un
/// `Identifiable`, et rendre toutes les chaînes de l'application
/// identifiables pour un écran serait un effet de bord démesuré.
private struct OpenedPhoto: Identifiable {
    var id: String
}
