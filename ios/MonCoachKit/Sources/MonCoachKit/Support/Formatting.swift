import Foundation

/// Display helpers. Storage and computation stay metric everywhere; this is
/// the only place that knows the athlete asked for pounds.
public enum Format {

    public static let kgPerLb = 0.45359237
    public static let cmPerInch = 2.54

    public static func weight(_ kg: Double, unit: UnitSystem, decimals: Int = 1) -> String {
        switch unit {
        case .metric:
            "\(number(kg, decimals: decimals)) kg"
        case .imperial:
            "\(number(kg / kgPerLb, decimals: decimals)) lb"
        }
    }

    public static func load(_ kg: Double?, unit: UnitSystem) -> String {
        guard let kg else { return "—" }
        return weight(kg, unit: unit, decimals: kg == kg.rounded() ? 0 : 1)
    }

    public static func height(_ cm: Double, unit: UnitSystem) -> String {
        switch unit {
        case .metric:
            return "\(number(cm, decimals: 0)) cm"
        case .imperial:
            let totalInches = cm / cmPerInch
            let feet = Int(totalInches / 12)
            let inches = Int((totalInches - Double(feet) * 12).rounded())
            return "\(feet)\u{2032}\(inches)\u{2033}"
        }
    }

    /// Decimal notation for the athlete's language: a comma in French and
    /// Spanish, a point in English. Formatting stays hand-rolled rather than
    /// going through NumberFormatter so the output is identical on Linux,
    /// where the ICU locale data available to the tests is not the one on the
    /// phone.
    public static func number(_ value: Double, decimals: Int, language: Language = .french) -> String {
        let raw = String(format: "%.\(decimals)f", value)
        return language == .english ? raw : raw.replacingOccurrences(of: ".", with: ",")
    }

    public static func signed(
        _ value: Double,
        decimals: Int = 1,
        suffix: String = "",
        language: Language = .french
    ) -> String {
        let sign = value > 0 ? "+" : ""
        return sign + number(value, decimals: decimals, language: language) + suffix
    }

    /// "1 h 15" rather than "75 min" once a session runs long.
    public static func duration(minutes: Int, language: Language = .french) -> String {
        guard minutes >= 60 else { return "\(minutes) min" }
        let hours = minutes / 60
        let rest = minutes % 60
        if language == .english {
            return rest == 0 ? "\(hours) h" : "\(hours) h \(rest) min"
        }
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest)"
    }

    /// A running duration, which needs seconds: "48:12", "1:07:40".
    public static func stopwatch(seconds: TimeInterval) -> String {
        let total = Int(max(0, seconds).rounded())
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        return hours > 0
            ? String(format: "%d:%02d:%02d", hours, minutes, secs)
            : String(format: "%d:%02d", minutes, secs)
    }

    /// A running pace, always per kilometre or per mile, never a speed:
    /// runners think in minutes per kilometre and nothing else.
    public static func pace(secondsPerKm: Double, unit: UnitSystem) -> String {
        guard secondsPerKm > 0, secondsPerKm.isFinite else { return "—" }
        let perUnit = unit == .metric ? secondsPerKm : secondsPerKm / 0.621371
        let total = Int(perUnit.rounded())
        return String(format: "%d:%02d", total / 60, total % 60) + (unit == .metric ? " /km" : " /mi")
    }

    /// A distance in kilometres or miles.
    public static func distance(meters: Double, unit: UnitSystem, language: Language = .french) -> String {
        switch unit {
        case .metric:
            return "\(number(meters / 1_000, decimals: meters < 10_000 ? 2 : 1, language: language)) km"
        case .imperial:
            return "\(number(meters / 1_609.344, decimals: 2, language: language)) mi"
        }
    }

    /// Rest timers read as "2:30", never as "150 s".
    public static func clock(seconds: Int) -> String {
        let safe = max(0, seconds)
        return String(format: "%d:%02d", safe / 60, safe % 60)
    }

    public static func rpe(_ value: Double) -> String {
        value == value.rounded() ? "RPE \(Int(value))" : "RPE \(number(value, decimals: 1))"
    }

    /// Converts a user-entered weight back to kilograms for storage.
    public static func kilograms(fromDisplayed value: Double, unit: UnitSystem) -> Double {
        unit == .metric ? value : value * kgPerLb
    }

    /// Converts a user-entered height back to centimetres for storage.
    public static func centimetres(fromDisplayed value: Double, unit: UnitSystem) -> Double {
        unit == .metric ? value : value * cmPerInch
    }
}
