import SwiftUI
import MonCoachKit

/// Chercher un capteur, et s'y connecter.
///
/// Le scan ne part qu'ici, à l'ouverture de cette fiche, et s'arrête à la
/// fermeture : chercher en permanence viderait la batterie pendant que
/// l'athlète court, pour trouver un capteur qu'il n'a pas branché.
struct SensorSheet: View {
    @Environment(\.language) private var language
    @Environment(\.dismiss) private var dismiss
    var hub: SensorHub

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.stackSpacing) {
                    Card(
                        title: LocalizedText(fr: "Capteurs", en: "Sensors", es: "Sensores")[language],
                        subtitle: LocalizedText(
                            fr: "Ceinture cardio, capteur de puissance, capteur de cadence. La connexion se fait directement, sans passer par les réglages d'iOS.",
                            en: "Heart rate strap, power meter, cadence sensor. They connect directly, without going through iOS settings.",
                            es: "Banda de frecuencia cardíaca, potenciómetro, sensor de cadencia. Se conectan directamente, sin pasar por los ajustes de iOS."
                        )[language]
                    ) {
                        if hub.isScanning {
                            HStack(spacing: 8) {
                                ProgressView().tint(Theme.accent)
                                Text(LocalizedText(fr: "Recherche…", en: "Searching…", es: "Buscando…")[language])
                                    .font(Theme.captionFont)
                                    .foregroundStyle(Theme.secondaryText)
                            }
                        } else {
                            GhostButton(
                                title: LocalizedText(fr: "Chercher", en: "Search", es: "Buscar")[language],
                                systemImage: "antenna.radiowaves.left.and.right"
                            ) {
                                hub.startScanning()
                            }
                        }
                    }

                    if hub.devices.isEmpty {
                        Card {
                            CoachText(
                                LocalizedText(
                                    fr: "Rien pour l'instant. Un capteur ne se montre qu'allumé et non connecté ailleurs : une ceinture déjà prise par une montre reste invisible ici.",
                                    en: "Nothing yet. A sensor only shows up if it is on and not connected elsewhere: a strap already paired to a watch stays invisible here.",
                                    es: "Nada por ahora. Un sensor solo aparece si está encendido y no conectado en otro sitio: una banda ya emparejada con un reloj no se ve aquí."
                                ),
                                font: Theme.captionFont
                            )
                        }
                    } else {
                        Card(title: LocalizedText(fr: "Trouvés", en: "Found", es: "Encontrados")[language]) {
                            VStack(spacing: 10) {
                                ForEach(hub.devices) { device in
                                    Button {
                                        hub.connect(device)
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: symbol(for: device))
                                                .font(.system(size: 14))
                                                .foregroundStyle(Theme.accent)
                                                .frame(width: 24)
                                            Text(device.name)
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundStyle(Theme.primaryText)
                                            Spacer()
                                            Text(LocalizedText(fr: "Connecter", en: "Connect", es: "Conectar")[language])
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundStyle(Theme.accent)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    liveCard
                }
                .padding(20)
            }
            .screenBackground()
            .navigationTitle(LocalizedText(fr: "Capteurs", en: "Sensors", es: "Sensores")[language])
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(UI.close[language]) { dismiss() }.tint(Theme.accent)
                }
            }
        }
        .task { hub.startScanning() }
        .onDisappear { hub.stopScanning() }
        .tint(Theme.accent)
    }

    /// Ce qui arrive en ce moment. Nil et zéro ne s'affichent pas pareil :
    /// zéro watt est une descente, pas de watt est un capteur absent.
    @ViewBuilder
    private var liveCard: some View {
        if hub.bpm != nil || hub.watts != nil || hub.rpm != nil {
            Card(title: LocalizedText(fr: "En direct", en: "Live", es: "En directo")[language]) {
                HStack(spacing: 12) {
                    if let bpm = hub.bpm {
                        StatTile(value: "\(bpm)", label: LocalizedText(fr: "bpm", en: "bpm", es: "ppm")[language],
                                 tint: Theme.danger, amount: Double(bpm))
                    }
                    if let watts = hub.watts {
                        StatTile(value: "\(watts) W", label: LocalizedText(fr: "puissance", en: "power", es: "potencia")[language],
                                 amount: Double(watts))
                    }
                    if let rpm = hub.rpm {
                        StatTile(value: "\(Int(rpm.rounded()))", label: LocalizedText(fr: "tr/min", en: "rpm", es: "rpm")[language],
                                 tint: Theme.warning, amount: rpm)
                    }
                }
                if hub.hasSkinContact == false {
                    Text(
                        LocalizedText(
                            fr: "La ceinture ne touche pas la peau. Les chiffres arrivent, ils ne valent rien.",
                            en: "The strap is not touching skin. The numbers keep coming, they mean nothing.",
                            es: "La banda no toca la piel. Los números llegan, pero no valen nada."
                        )[language]
                    )
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.warning)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func symbol(for device: SensorHub.Device) -> String {
        if device.services.contains(SensorHub.Service.cyclingPower) { return "bolt.fill" }
        if device.services.contains(SensorHub.Service.cadence) { return "arrow.triangle.2.circlepath" }
        return "heart.fill"
    }
}
