import SwiftUI

/// The app's visual vocabulary, in one place.
///
/// Dark by default: most people open this app in a gym, at night, with one
/// hand, and a bright screen between sets is genuinely unpleasant.
enum Theme {

    // MARK: Colours

    static let background = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let surface = Color(red: 0.09, green: 0.10, blue: 0.13)
    static let surfaceRaised = Color(red: 0.13, green: 0.14, blue: 0.18)
    static let accent = Color(red: 0.35, green: 0.85, blue: 0.55)
    static let accentMuted = Color(red: 0.35, green: 0.85, blue: 0.55).opacity(0.15)
    static let warning = Color(red: 0.98, green: 0.72, blue: 0.30)
    static let danger = Color(red: 0.95, green: 0.42, blue: 0.40)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.62)
    static let separator = Color.white.opacity(0.08)

    // MARK: Metrics

    static let cornerRadius: CGFloat = 18
    static let cardPadding: CGFloat = 16
    static let stackSpacing: CGFloat = 14

    // MARK: Type

    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 15, weight: .regular)
    static let captionFont = Font.system(size: 13, weight: .medium)
    static let numberFont = Font.system(size: 34, weight: .bold, design: .rounded)
}
