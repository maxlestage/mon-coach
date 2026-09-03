import Foundation
import CoreBluetooth
import Observation
import MonCoachKit

/// Les capteurs de sport branchés au téléphone.
///
/// Ce qui manquait
/// ---------------
/// Aucun `CoreBluetooth` dans le projet : ni ceinture cardio, ni capteur de
/// puissance, ni cadence. Pour la course cela se discute — la montre mesure
/// au poignet. Pour le vélo, non : la puissance *est* la mesure du sport,
/// et une application de vélo sans watts n'est pas une application de vélo.
///
/// Ce que ce type fait, et ne fait pas
/// -----------------------------------
/// Il ouvre les connexions et reçoit des octets. Ce que ces octets veulent
/// dire est écrit dans `BluetoothSensors`, testé trame par trame — une
/// erreur de décodage ne plante pas, elle donne un chiffre plausible et
/// faux qu'on ne découvre qu'au milieu d'une sortie.
///
/// Il ne cherche des capteurs **que sur demande**. Un scan Bluetooth permanent
/// vide la batterie et fait apparaître une autorisation que rien ne
/// justifie ; celui-ci s'arrête dès qu'on a trouvé, et se coupe seul au bout
/// d'une trentaine de secondes s'il ne trouve rien.
@MainActor
@Observable
final class SensorHub: NSObject {

    /// Les services que nous savons lire, dans l'ordre où ils comptent.
    ///
    /// Ce sont des **chaînes**, et le `CBUUID` n'est construit que là où
    /// CoreBluetooth en réclame un.
    ///
    /// `CBUUID` est une classe d'Objective-C que Swift 6 ne laisse ni
    /// ranger dans une constante statique, ni traverser une frontière de
    /// concurrence. Or les délégués Bluetooth arrivent hors du fil
    /// principal : tout identifiant qui doit remonter jusqu'à l'écran
    /// traverse forcément cette frontière. Le garder en texte règle les
    /// deux problèmes d'un coup, là où une propriété calculée n'en réglait
    /// que le premier.
    ///
    /// Pour un service à seize bits, ce texte est exactement celui de la
    /// spécification — « 180D », « 2A37 » — ce qui se relit mieux qu'un
    /// objet opaque.
    enum Service {
        static let heartRate = "180D"
        static let cyclingPower = "1818"
        static let cadence = "1816"

        static var all: [CBUUID] {
            [heartRate, cyclingPower, cadence].map { CBUUID(string: $0) }
        }
    }

    private enum Characteristic {
        static let heartRate = "2A37"
        static let cyclingPower = "2A63"
        static let cadence = "2A5B"

        static var all: [CBUUID] {
            [heartRate, cyclingPower, cadence].map { CBUUID(string: $0) }
        }
    }

    /// Un capteur trouvé, tel qu'on peut le montrer.
    struct Device: Identifiable, Equatable {
        let id: UUID
        var name: String
        /// Les services annoncés, en texte : « 180D » pour la fréquence
        /// cardiaque. Voir `Service` pour la raison.
        var services: [String]
    }

    // MARK: - Ce que l'écran lit

    private(set) var devices: [Device] = []
    private(set) var isScanning = false
    /// La dernière mesure de chaque grandeur, ou nil tant qu'aucune n'est
    /// arrivée. Nil et zéro ne sont pas la même chose : zéro watt est une
    /// descente, pas de watt est un capteur absent.
    private(set) var bpm: Int?
    private(set) var watts: Int?
    private(set) var rpm: Double?
    /// La ceinture touche-t-elle la peau ? Nil quand le capteur ne sait pas
    /// le dire — la plupart ne savent pas.
    private(set) var hasSkinContact: Bool?

    /// Tout ce qui a été mesuré, prêt à rejoindre la sortie.
    private(set) var powerSamples: [PowerSample] = []
    private(set) var cadenceSamples: [CadenceSample] = []
    private(set) var heartRateSamples: [HeartRateSample] = []

    private var central: CBCentralManager?
    private var connected: [UUID: CBPeripheral] = [:]
    /// La mesure de pédalier précédente. La cadence est une différence : une
    /// seule mesure ne dit rien, il en faut deux.
    private var lastCrank: (revolutions: Int, eventTime: Int)?
    private var scanStopper: Task<Void, Never>?

    // MARK: - Ouvrir et fermer

    /// Cherche des capteurs, et s'arrête tout seul.
    func startScanning() {
        if central == nil {
            central = CBCentralManager(delegate: self, queue: .main)
        }
        guard central?.state == .poweredOn else { return }
        devices = []
        isScanning = true
        central?.scanForPeripherals(withServices: Service.all)

        scanStopper?.cancel()
        scanStopper = Task { [weak self] in
            try? await Task.sleep(for: .seconds(30))
            self?.stopScanning()
        }
    }

    func stopScanning() {
        scanStopper?.cancel()
        scanStopper = nil
        central?.stopScan()
        isScanning = false
    }

    func connect(_ device: Device) {
        guard let peripheral = central?.retrievePeripherals(withIdentifiers: [device.id]).first
        else { return }
        peripheral.delegate = self
        connected[device.id] = peripheral
        central?.connect(peripheral)
    }

    func disconnectAll() {
        stopScanning()
        for peripheral in connected.values { central?.cancelPeripheralConnection(peripheral) }
        connected = [:]
        bpm = nil
        watts = nil
        rpm = nil
        hasSkinContact = nil
        lastCrank = nil
    }

    /// Oublie les mesures accumulées, au départ d'une nouvelle sortie.
    func resetSamples() {
        powerSamples = []
        cadenceSamples = []
        heartRateSamples = []
        lastCrank = nil
    }
}

// MARK: - Le central

extension SensorHub: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // L'état est lu ici, pas dans la tâche : un `CBCentralManager` ne
        // traverse pas une frontière de concurrence, alors qu'un état — une
        // simple valeur — la traverse sans difficulté.
        let isOn = central.state == .poweredOn
        Task { @MainActor in
            // Le Bluetooth éteint pendant une sortie n'est pas une erreur à
            // signaler : c'est un capteur qui se tait, et la sortie continue
            // avec le GPS. On efface les mesures en cours pour ne pas
            // afficher un chiffre figé qui passerait pour vivant.
            guard !isOn else { return }
            self.bpm = nil
            self.watts = nil
            self.rpm = nil
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        let name = peripheral.name
            ?? (advertisementData[CBAdvertisementDataLocalNameKey] as? String)
            ?? "Capteur"
        // Traduits en texte avant de partir vers le fil principal : un
        // `CBUUID` ne traverse pas la frontière, une chaîne oui.
        let services = ((advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]) ?? [])
            .map(\.uuidString)
        let identifier = peripheral.identifier
        Task { @MainActor in
            guard !self.devices.contains(where: { $0.id == identifier }) else { return }
            self.devices.append(Device(id: identifier, name: name, services: services))
        }
    }

    nonisolated func centralManager(
        _ central: CBCentralManager, didConnect peripheral: CBPeripheral
    ) {
        peripheral.discoverServices(Service.all)
    }
}

// MARK: - Le capteur

extension SensorHub: CBPeripheralDelegate {
    nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service in peripheral.services ?? [] {
            peripheral.discoverCharacteristics(Characteristic.all, for: service)
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        // On s'abonne plutôt que d'interroger : ces capteurs émettent à leur
        // rythme — une fois par seconde, ou à chaque tour de pédalier — et
        // les interroger nous-mêmes donnerait la même valeur plusieurs fois
        // ou en manquerait.
        for characteristic in service.characteristics ?? []
        where characteristic.properties.contains(.notify) {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    nonisolated func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        guard let data = characteristic.value else { return }
        let bytes = [UInt8](data)
        let uuid = characteristic.uuid.uuidString
        Task { @MainActor in
            self.received(bytes, from: uuid)
        }
    }

    private func received(_ bytes: [UInt8], from characteristic: String) {
        let now = Date()
        // Comparaison en majuscules : `uuidString` rend « 2A37 » pour un
        // service à seize bits, mais rien ne garantit la casse, et une
        // comparaison qui échoue silencieusement donnerait un capteur
        // connecté qui n'affiche jamais rien.
        switch characteristic.uppercased() {
        case Characteristic.heartRate:
            guard let reading = BluetoothSensors.heartRate(bytes) else { return }
            bpm = reading.bpm
            hasSkinContact = reading.hasContact
            heartRateSamples.append(
                HeartRateSample(timestamp: now, bpm: Double(reading.bpm))
            )

        case Characteristic.cyclingPower:
            guard let reading = BluetoothSensors.cyclingPower(bytes) else { return }
            watts = reading.watts
            powerSamples.append(PowerSample(timestamp: now, watts: reading.watts))
            if let revolutions = reading.crankRevolutions, let time = reading.crankEventTime {
                update(crank: (revolutions, time), at: now)
            }

        case Characteristic.cadence:
            guard let crank = BluetoothSensors.crankData(bytes) else { return }
            update(crank: crank, at: now)

        default:
            break
        }
    }

    /// Deux mesures de pédalier font une cadence.
    private func update(crank: (revolutions: Int, eventTime: Int), at date: Date) {
        defer { lastCrank = crank }
        guard let previous = lastCrank,
              let value = BluetoothSensors.cadence(from: previous, to: crank)
        else { return }
        rpm = value
        cadenceSamples.append(CadenceSample(timestamp: date, rpm: value))
    }
}
