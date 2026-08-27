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

    /// French decimal notation: a comma, and no trailing zeros beyond what
    /// was asked for.
    public static func number(_ value: Double, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value).replacingOccurrences(of: ".", with: ",")
    }

    public static func signed(_ value: Double, decimals: Int = 1, suffix: String = "") -> String {
        let sign = value > 0 ? "+" : ""
        return sign + number(value, decimals: decimals) + suffix
    }

    /// "1 h 15" rather than "75 min" once a session runs long.
    public static func duration(minutes: Int) -> String {
        guard minutes >= 60 else { return "\(minutes) min" }
        let hours = minutes / 60
        let rest = minutes % 60
        return rest == 0 ? "\(hours) h" : "\(hours) h \(rest)"
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
