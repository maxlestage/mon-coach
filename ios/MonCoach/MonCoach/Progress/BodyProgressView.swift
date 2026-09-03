import SwiftUI
import PhotosUI
import MonCoachKit

/// Les photos de progression, et la comparaison qui leur donne un sens.
///
/// Pourquoi cet écran existe
/// -------------------------
/// Le journal corporel ne connaissait que des nombres. Or la balance bouge
/// de six cents grammes par semaine, ce qui ne se voit pas ; la même
/// personne à trois mois d'écart se voit tout de suite. Ce sont les photos
/// qui font tenir, pas la courbe.
///
/// C'est aussi la fonctionnalité qui tire le plus de la position de
/// l'application : ces images-là, personne ne les envoie sur un serveur.
/// Ici elles ne quittent pas le téléphone, et l'écran le dit.
struct BodyProgressView: View {
    @Environment(\.language) private var language
    @Environment(CoachStore.self) private var store

    @State private var picked: [PhotosPickerItem] = []
    @State private var confirmingDeletion: String?

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.stackSpacing) {
                comparisonCard.appears(0)
                addCard.appears(1)
                galleryCard.appears(2)
            }
            .padding(20)
        }
        .screenBackground()
        .navigationTitle(
            LocalizedText(fr: "Ta progression", en: "Your progress", es: "Tu progreso")[language]
        )
        .onChange(of: picked) { _, items in
            guard !items.isEmpty else { return }
            picked = []
            Task { await keep(items) }
        }
        .confirmationDialog(
            LocalizedText(fr: "Supprimer cette photo ?", en: "Delete this photo?", es: "¿Borrar esta foto?")[language],
            isPresented: Binding(
                get: { confirmingDeletion != nil },
                set: { if !$0 { confirmingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(UI.delete[language], role: .destructive) {
                if let id = confirmingDeletion { store.removeBodyPhoto(id) }
                confirmingDeletion = nil
            }
            Button(UI.cancel[language], role: .cancel) { confirmingDeletion = nil }
        } message: {
            Text(
                LocalizedText(
                    fr: "Une photo d'il y a six mois ne se reprend pas.",
                    en: "A photo from six months ago cannot be retaken.",
                    es: "Una foto de hace seis meses no se puede repetir."
                )[language]
            )
        }
    }

    // MARK: - La comparaison

    /// Deux photos côte à côte, ou l'explication de leur absence.
    @ViewBuilder
    private var comparisonCard: some View {
        if let pair = store.bodyComparison() {
            Card(title: LocalizedText(fr: "Avant, maintenant", en: "Then, now", es: "Antes, ahora")[language]) {
                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        photo(pair.earlierPhotoID, date: pair.earlier.date, weight: pair.earlier.weightKg)
                        photo(pair.laterPhotoID, date: pair.later.date, weight: pair.later.weightKg)
                    }
                    Text(BodyProgress.caption(pair)[language])
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Theme.accent)
                }
            }
        } else {
            Card(title: LocalizedText(fr: "Avant, maintenant", en: "Then, now", es: "Antes, ahora")[language]) {
                // On ne montre pas deux images identiques pour faire joli.
                // Six semaines : en dessous, la différence tient dans
                // l'éclairage et l'heure de la journée.
                CoachText(
                    LocalizedText(
                        fr: "La comparaison apparaîtra quand deux photos seront séparées d'au moins six semaines. En dessous, ce qu'on voit change avec l'éclairage et l'heure, pas avec le corps.",
                        en: "The comparison appears once two photos are at least six weeks apart. Below that, what you see changes with the light and the time of day, not with the body.",
                        es: "La comparación aparecerá cuando dos fotos estén separadas por al menos seis semanas. Por debajo, lo que se ve cambia con la luz y la hora, no con el cuerpo."
                    ),
                    font: Theme.bodyFont
                )
            }
        }
    }

    private func photo(_ id: String, date: Date, weight: Double) -> some View {
        VStack(spacing: 6) {
            StoredPhotoView(id: id)
                .frame(maxWidth: .infinity)
                .aspectRatio(3.0 / 4.0, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text(date.formatted(.dateTime.day().month(.abbreviated).year()))
                .font(.system(size: 11))
                .foregroundStyle(Theme.secondaryText)
            if weight > 0 {
                Text("\(Format.number(weight, decimals: 1, language: language)) kg")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
            }
        }
    }

    // MARK: - Ajouter

    private var addCard: some View {
        Card(
            subtitle: LocalizedText(
                fr: "Même endroit, même lumière, même heure : c'est ce qui rend deux photos comparables. Elles ne quittent pas ton téléphone.",
                en: "Same spot, same light, same time of day: that is what makes two photos comparable. They never leave your phone.",
                es: "Mismo sitio, misma luz, misma hora: eso hace que dos fotos sean comparables. No salen de tu teléfono."
            )[language]
        ) {
            PhotosPicker(selection: $picked, maxSelectionCount: 3, matching: .images, photoLibrary: .shared()) {
                HStack(spacing: 8) {
                    Image(systemName: "camera")
                    Text(LocalizedText(fr: "Ajouter une photo", en: "Add a photo", es: "Añadir una foto")[language])
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
                .foregroundStyle(Theme.primaryText)
            }
        }
    }

    // MARK: - Toutes les photos

    @ViewBuilder
    private var galleryCard: some View {
        let all = store.bodyPhotos
        if !all.isEmpty {
            Card(
                title: LocalizedText(fr: "Toutes tes photos", en: "All your photos", es: "Todas tus fotos")[language],
                subtitle: LocalizedText(
                    fr: "\(all.count) photo\(all.count > 1 ? "s" : "")",
                    en: "\(all.count) photo\(all.count > 1 ? "s" : "")",
                    es: "\(all.count) foto\(all.count > 1 ? "s" : "")"
                )[language]
            ) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                    ForEach(all, id: \.photoID) { entry in
                        VStack(spacing: 4) {
                            StoredPhotoView(id: entry.photoID, side: 96)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(entry.log.date.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.system(size: 10))
                                .foregroundStyle(Theme.secondaryText)
                        }
                        .onLongPressGesture { confirmingDeletion = entry.photoID }
                    }
                }
            }
        }
    }

    /// Range les images choisies, une par une.
    ///
    /// Nommée `keep` et non `store` : ce dernier est déjà le magasin, et une
    /// fonction du même nom le masquerait à l'intérieur d'elle-même.
    private func keep(_ items: [PhotosPickerItem]) async {
        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
            store.addBodyPhoto(data)
        }
    }
}
