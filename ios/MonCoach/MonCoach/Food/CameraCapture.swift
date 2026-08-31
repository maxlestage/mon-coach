import SwiftUI
import UIKit

/// L'appareil photo, le temps d'une assiette.
///
/// `PhotosPicker` ne sait qu'ouvrir la photothèque. Or l'assiette est là,
/// maintenant, et personne ne va la photographier dans l'appareil photo
/// pour revenir la chercher dans une liste. Ces quarante lignes sont le
/// prix d'un geste en moins.
///
/// Aucune configuration au-delà du strict nécessaire : pas de retouche, pas
/// de filtre, une seule photo. L'écran d'estimation fait le reste.
struct CameraCapture: UIViewControllerRepresentable {
    /// Appelé avec les octets de la photo prise.
    var onCapture: (Data) -> Void

    @Environment(\.dismiss) private var dismiss

    /// Vrai quand l'appareil a une caméra utilisable. Faux sur un simulateur
    /// — et l'écran propose alors la photothèque seule, plutôt qu'un bouton
    /// qui n'ouvre rien.
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = .camera
        controller.cameraCaptureMode = .photo
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, onFinish: { dismiss() })
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let onCapture: (Data) -> Void
        private let onFinish: () -> Void

        init(onCapture: @escaping (Data) -> Void, onFinish: @escaping () -> Void) {
            self.onCapture = onCapture
            self.onFinish = onFinish
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            // La qualité est réduite ici même : une photo d'appareil pèse
            // cinq mégaoctets, et rien en aval n'en a besoin.
            if let image = info[.originalImage] as? UIImage,
               let data = PhotoEncoding.jpeg(from: PhotoEncoding.resized(image)) {
                onCapture(data)
            }
            onFinish()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinish()
        }
    }
}
