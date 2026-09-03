import Foundation

/// Ce que disent les capteurs de sport, une fois les octets lus.
///
/// Pourquoi le décodage vit ici et pas dans l'application
/// ------------------------------------------------------
/// Les profils Bluetooth du sport sont publics et fixes : une ceinture
/// cardio Polar, une Garmin et une Wahoo envoient exactement la même trame,
/// parce que la spécification l'impose. Ce sont donc des octets connus
/// d'avance, et un décodeur d'octets se teste — alors qu'un
/// `CBPeripheral` ne se teste nulle part.
///
/// La séparation a une deuxième vertu, moins évidente : les erreurs de
/// décodage sont muettes. Un bit de drapeau mal lu ne plante pas, il donne
/// 65 535 tours par minute ou une fréquence cardiaque de zéro, et on ne
/// s'en aperçoit qu'au milieu d'une sortie. Les seules erreurs qu'on trouve
/// sont celles qu'un test peut provoquer.
public enum BluetoothSensors {

    // MARK: - Fréquence cardiaque (service 0x180D)

    /// Une mesure de fréquence cardiaque telle que la ceinture l'envoie.
    public struct HeartRateReading: Sendable, Equatable, Hashable {
        /// Battements par minute.
        public var bpm: Int
        /// La ceinture touche-t-elle la peau ? Absent sur les capteurs qui ne
        /// savent pas le dire — et c'est une information, pas un détail : une
        /// ceinture décollée envoie des chiffres, ils ne valent rien.
        public var hasContact: Bool?
        /// L'énergie dépensée depuis la mise en marche, en kilojoules.
        public var kilojoules: Int?

        public init(bpm: Int, hasContact: Bool? = nil, kilojoules: Int? = nil) {
            self.bpm = bpm
            self.hasContact = hasContact
            self.kilojoules = kilojoules
        }
    }

    /// Décode une trame `Heart Rate Measurement` (0x2A37).
    ///
    /// Le premier octet est un jeu de drapeaux, et c'est lui qui décide de la
    /// **taille de tout le reste** : bit 0 à zéro, la fréquence tient sur un
    /// octet ; à un, elle en prend deux, en petit-boutiste. Lire le mauvais
    /// nombre d'octets ne produit pas d'erreur — cela produit une fréquence
    /// plausible et fausse, ce qui est bien pire.
    public static func heartRate(_ data: [UInt8]) -> HeartRateReading? {
        guard let flags = data.first else { return nil }
        let wide = flags & 0x01 != 0
        var index = 1

        let bpm: Int
        if wide {
            guard data.count >= 3 else { return nil }
            bpm = Int(data[1]) | Int(data[2]) << 8
            index = 3
        } else {
            guard data.count >= 2 else { return nil }
            bpm = Int(data[1])
            index = 2
        }

        // Bits 1 et 2 : le capteur sait-il détecter le contact, et le
        // détecte-t-il ? Les deux questions sont distinctes — un capteur qui
        // ne sait pas répondre ne doit pas être lu comme « décollé ».
        var contact: Bool?
        if flags & 0x04 != 0 { contact = flags & 0x02 != 0 }

        var kilojoules: Int?
        if flags & 0x08 != 0 {
            guard data.count >= index + 2 else { return nil }
            kilojoules = Int(data[index]) | Int(data[index + 1]) << 8
        }

        return HeartRateReading(bpm: bpm, hasContact: contact, kilojoules: kilojoules)
    }

    // MARK: - Puissance (service 0x1818)

    /// Ce qu'un capteur de puissance envoie.
    public struct PowerReading: Sendable, Equatable, Hashable {
        /// Watts instantanés.
        public var watts: Int
        /// Le compteur de tours de pédalier, quand le capteur le donne.
        /// Deux mesures successives donnent la cadence ; une seule ne donne
        /// rien, et c'est pour cela que le calcul est ailleurs.
        public var crankRevolutions: Int?
        /// L'horloge du capteur au dernier tour, en 1/1024 de seconde.
        public var crankEventTime: Int?

        public init(watts: Int, crankRevolutions: Int? = nil, crankEventTime: Int? = nil) {
            self.watts = watts
            self.crankRevolutions = crankRevolutions
            self.crankEventTime = crankEventTime
        }
    }

    /// Décode une trame `Cycling Power Measurement` (0x2A63).
    ///
    /// Les drapeaux tiennent sur deux octets, et chaque champ optionnel
    /// présent décale tous les suivants. On avance donc pas à pas, en
    /// sautant exactement ce que chaque drapeau annonce — sauter de travers
    /// donnerait une cadence tirée des octets d'un couple de force.
    public static func cyclingPower(_ data: [UInt8]) -> PowerReading? {
        guard data.count >= 4 else { return nil }
        let flags = Int(data[0]) | Int(data[1]) << 8

        // La puissance instantanée est signée : un capteur peut annoncer des
        // watts négatifs en roue libre, et les lire comme un entier non
        // signé donnerait soixante-cinq mille watts.
        let watts = Int(Int16(bitPattern: UInt16(data[2]) | UInt16(data[3]) << 8))
        var index = 4

        if flags & 0x0001 != 0 { index += 1 }   // Pedal Power Balance
        if flags & 0x0004 != 0 { index += 2 }   // Accumulated Torque
        if flags & 0x0010 != 0 { index += 6 }   // Wheel Revolution Data

        var revolutions: Int?
        var eventTime: Int?
        if flags & 0x0020 != 0 {                // Crank Revolution Data
            guard data.count >= index + 4 else { return nil }
            revolutions = Int(data[index]) | Int(data[index + 1]) << 8
            eventTime = Int(data[index + 2]) | Int(data[index + 3]) << 8
        }

        return PowerReading(watts: watts, crankRevolutions: revolutions, crankEventTime: eventTime)
    }

    // MARK: - Cadence (service 0x1816)

    /// Décode une trame `CSC Measurement` (0x2A5B), pour la partie pédalier.
    public static func crankData(_ data: [UInt8]) -> (revolutions: Int, eventTime: Int)? {
        guard let flags = data.first else { return nil }
        // Bit 0 : données de roue présentes, six octets qui décalent tout.
        var index = 1
        if flags & 0x01 != 0 { index += 6 }
        guard flags & 0x02 != 0, data.count >= index + 4 else { return nil }
        return (
            Int(data[index]) | Int(data[index + 1]) << 8,
            Int(data[index + 2]) | Int(data[index + 3]) << 8
        )
    }

    /// La cadence, en tours par minute, entre deux mesures.
    ///
    /// Les deux compteurs débordent : les tours sur seize bits, l'horloge sur
    /// seize bits en 1/1024 de seconde — soit un tour complet toutes les
    /// soixante-quatre secondes. Un capteur qui tourne une heure déborde
    /// cinquante-six fois. Traiter le débordement comme un retour en arrière
    /// donnerait une cadence négative ou nulle à chaque fois, une fois par
    /// minute, pendant toute la sortie.
    public static func cadence(
        from previous: (revolutions: Int, eventTime: Int),
        to current: (revolutions: Int, eventTime: Int)
    ) -> Double? {
        let turns = wrapped(current.revolutions - previous.revolutions, modulo: 65536)
        let ticks = wrapped(current.eventTime - previous.eventTime, modulo: 65536)
        guard ticks > 0 else { return nil }

        // Une roue à l'arrêt n'envoie plus de nouvel événement : le compteur
        // de temps ne bouge plus non plus, et on tombe dans le cas ci-dessus.
        // Zéro tour sur un temps qui avance est en revanche une vraie
        // cadence : celle de quelqu'un qui a cessé de pédaler.
        let seconds = Double(ticks) / 1024
        return Double(turns) / seconds * 60
    }

    /// La différence entre deux compteurs qui débordent.
    static func wrapped(_ delta: Int, modulo: Int) -> Int {
        let value = delta % modulo
        return value < 0 ? value + modulo : value
    }
}
