import Foundation
import Testing
@testable import MonCoachKit

/// Les octets des capteurs, lus comme la spécification les écrit.
///
/// Ce qui se joue ici
/// ------------------
/// Une erreur de décodage Bluetooth ne plante pas : elle donne un chiffre
/// plausible et faux. Un bit de drapeau mal lu et la fréquence cardiaque
/// devient 65 535, ou la cadence se lit dans les octets d'un couple de
/// force. On ne s'en aperçoit qu'au milieu d'une sortie, quand il est trop
/// tard pour la refaire. Les trames ci-dessous sont écrites à la main
/// d'après les profils publics, parce que c'est le seul moyen de provoquer
/// l'erreur avant qu'elle n'arrive.
@Suite("Ce que disent les capteurs")
struct BluetoothSensorsTests {

    // MARK: - Fréquence cardiaque

    @Test("Une fréquence sur un octet se lit sur un octet")
    func narrowHeartRate() {
        // Drapeaux 0x00 : format court, pas de contact, pas d'énergie.
        let reading = BluetoothSensors.heartRate([0x00, 72])
        #expect(reading?.bpm == 72)
        #expect(reading?.hasContact == nil, "un capteur muet sur le contact n'est pas un capteur décollé")
    }

    @Test("Une fréquence sur deux octets se lit en petit-boutiste")
    func wideHeartRate() {
        // Drapeau bit 0 : la fréquence prend deux octets. Lire le premier
        // seul donnerait 44 au lieu de 300.
        let reading = BluetoothSensors.heartRate([0x01, 0x2C, 0x01])
        #expect(reading?.bpm == 300)
    }

    @Test("Le contact se distingue de l'absence d'information")
    func contactIsThreeStates() {
        // Bit 2 seul : le capteur sait détecter, et ne détecte pas.
        #expect(BluetoothSensors.heartRate([0x04, 60])?.hasContact == false)
        // Bits 1 et 2 : il sait détecter, et détecte.
        #expect(BluetoothSensors.heartRate([0x06, 60])?.hasContact == true)
        // Aucun des deux : il ne sait pas. Le lire comme « décollé » ferait
        // douter d'une mesure parfaitement bonne.
        #expect(BluetoothSensors.heartRate([0x00, 60])?.hasContact == nil)
    }

    @Test("L'énergie se lit après une fréquence de largeur variable")
    func energyFollowsAVariableField() {
        // Le piège : l'énergie n'est pas à un décalage fixe. Avec une
        // fréquence courte elle commence à l'octet 2, avec une longue à
        // l'octet 3. Un décalage figé lirait l'octet de poids fort de la
        // fréquence comme le premier octet de l'énergie.
        let short = BluetoothSensors.heartRate([0x08, 65, 0x10, 0x27])
        #expect(short?.bpm == 65)
        #expect(short?.kilojoules == 10000)

        let long = BluetoothSensors.heartRate([0x09, 65, 0x00, 0x10, 0x27])
        #expect(long?.bpm == 65)
        #expect(long?.kilojoules == 10000)
    }

    @Test("Une trame tronquée ne rend rien plutôt qu'un chiffre inventé")
    func truncatedFramesAreRefused() {
        #expect(BluetoothSensors.heartRate([]) == nil)
        #expect(BluetoothSensors.heartRate([0x00]) == nil)
        #expect(BluetoothSensors.heartRate([0x01, 0x2C]) == nil, "deux octets annoncés, un seul reçu")
        #expect(BluetoothSensors.heartRate([0x08, 65, 0x10]) == nil, "énergie annoncée, tronquée")
    }

    // MARK: - Puissance

    @Test("Les watts se lisent, et se lisent signés")
    func powerIsSigned() {
        // 200 W, aucun champ optionnel.
        #expect(BluetoothSensors.cyclingPower([0x00, 0x00, 0xC8, 0x00])?.watts == 200)
        // −5 W en roue libre. Lu comme non signé, cela ferait 65 531 watts —
        // un chiffre qui traverserait tous les calculs de la sortie.
        #expect(BluetoothSensors.cyclingPower([0x00, 0x00, 0xFB, 0xFF])?.watts == -5)
    }

    @Test("Les tours de pédalier se trouvent derrière les champs optionnels")
    func crankDataIsFoundAfterOptionalFields() {
        // Drapeaux 0x0020 : seulement les données de pédalier, à l'octet 4.
        let plain = BluetoothSensors.cyclingPower(
            [0x20, 0x00, 0xC8, 0x00, 0x0A, 0x00, 0x00, 0x04]
        )
        #expect(plain?.crankRevolutions == 10)
        #expect(plain?.crankEventTime == 1024)

        // Drapeaux 0x0035 : équilibre (1 octet), couple (2), roue (6), puis
        // pédalier. Les données de pédalier commencent maintenant à l'octet
        // 13. Un décalage figé lirait des octets de couple comme des tours.
        let crowded = BluetoothSensors.cyclingPower(
            [0x35, 0x00, 0xC8, 0x00,
             0x32,                                  // équilibre
             0x00, 0x00,                            // couple
             0x00, 0x00, 0x00, 0x00, 0x00, 0x00,    // roue
             0x0A, 0x00, 0x00, 0x04]                // pédalier
        )
        #expect(crowded?.crankRevolutions == 10)
        #expect(crowded?.crankEventTime == 1024)
    }

    // MARK: - Cadence

    @Test("Quatre-vingt-dix tours par minute se lisent comme tels")
    func cadenceIsComputed() {
        // Trois tours en deux secondes : 90 tr/min.
        let cadence = BluetoothSensors.cadence(
            from: (revolutions: 100, eventTime: 0),
            to: (revolutions: 103, eventTime: 2048)
        )
        #expect(cadence == 90)
    }

    @Test("Le débordement des compteurs ne casse pas la cadence")
    func countersWrapAround() {
        // L'horloge du capteur déborde toutes les soixante-quatre secondes :
        // sur une heure de vélo, cinquante-six fois. Traiter le
        // débordement comme un retour en arrière donnerait une cadence
        // absurde une fois par minute, pendant toute la sortie.
        let cadence = BluetoothSensors.cadence(
            from: (revolutions: 65534, eventTime: 65535),
            to: (revolutions: 1, eventTime: 1023)
        )
        // 3 tours, 1024 ticks — une seconde : 180 tr/min.
        #expect(cadence == 180)
    }

    @Test("Un capteur à l'arrêt ne rend pas une cadence")
    func aStoppedSensorSaysNothing() {
        // La roue arrêtée n'envoie plus de nouvel événement : le temps ne
        // bouge pas non plus. Diviser par ce zéro donnerait un infini.
        let cadence = BluetoothSensors.cadence(
            from: (revolutions: 100, eventTime: 5000),
            to: (revolutions: 100, eventTime: 5000)
        )
        #expect(cadence == nil)
    }

    @Test("Cesser de pédaler est une cadence de zéro, pas une absence")
    func coastingIsZeroNotNothing() {
        let cadence = BluetoothSensors.cadence(
            from: (revolutions: 100, eventTime: 0),
            to: (revolutions: 100, eventTime: 1024)
        )
        #expect(cadence == 0)
    }

    @Test("La trame de cadence saute les données de roue")
    func cscSkipsWheelData() {
        // Bit 0 seul : roue uniquement, rien pour le pédalier.
        #expect(BluetoothSensors.crankData([0x01, 0, 0, 0, 0, 0, 0]) == nil)

        // Bit 1 seul : pédalier à l'octet 1.
        let plain = BluetoothSensors.crankData([0x02, 0x0A, 0x00, 0x00, 0x04])
        #expect(plain?.revolutions == 10)
        #expect(plain?.eventTime == 1024)

        // Les deux : le pédalier vient après six octets de roue.
        let both = BluetoothSensors.crankData(
            [0x03, 0, 0, 0, 0, 0, 0, 0x0A, 0x00, 0x00, 0x04]
        )
        #expect(both?.revolutions == 10)
        #expect(both?.eventTime == 1024)
    }
}
