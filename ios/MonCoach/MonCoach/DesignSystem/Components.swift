import SwiftUI
import MonCoachKit

/// A titled card. Every screen is built out of these.
struct Card<Content: View>: View {
    var title: String?
    var subtitle: String?
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if title != nil || subtitle != nil {
                VStack(alignment: .leading, spacing: 3) {
                    if let title {
                        Text(title)
                            .font(Theme.headlineFont)
                            .foregroundStyle(Theme.primaryText)
                    }
                    if let subtitle {
                        Text(subtitle)
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.secondaryText)
                    }
                }
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.cardPadding)
        .background(Theme.surface, in: RoundedRectangle(cornerRadius: Theme.cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.separator, lineWidth: 1)
        )
    }
}

/// A single figure with its label — calories, sets, weeks left.
struct StatTile: View {
    var value: String
    var label: String
    var tint: Color = Theme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Theme.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Small rounded label used for muscle groups, tags and states.
struct Pill: View {
    var text: String
    var tint: Color = Theme.accent

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(tint.opacity(0.14), in: Capsule())
    }
}

/// The app's main call to action.
struct PrimaryButton: View {
    var title: String
    var systemImage: String?
    var tint: Color = Theme.accent
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(tint, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(Theme.background)
        }
        .buttonStyle(.plain)
    }
}

/// Secondary action: same shape, no fill.
struct GhostButton: View {
    var title: String
    var systemImage: String?
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Theme.surfaceRaised, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(Theme.primaryText)
        }
        .buttonStyle(.plain)
    }
}

/// One message from the coach.
struct InsightRow: View {
    var insight: CoachInsight

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(tint.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(insight.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.primaryText)
                Text(insight.message)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var tint: Color {
        switch insight.severity {
        case .info: Theme.accent
        case .suggestion: Theme.warning
        case .warning: Theme.danger
        }
    }

    private var icon: String {
        switch insight.kind {
        case .adherence: "calendar"
        case .volume: "chart.bar.fill"
        case .strength: "arrow.up.right"
        case .bodyWeight: "scalemass"
        case .recovery: "moon.zzz.fill"
        case .nutrition: "fork.knife"
        case .technique: "exclamationmark.triangle.fill"
        }
    }
}

/// Horizontal bar used for readiness and session progress.
struct ProgressBar: View {
    var value: Double
    var tint: Color = Theme.accent

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Theme.surfaceRaised)
                Capsule()
                    .fill(tint)
                    .frame(width: max(0, min(1, value)) * geometry.size.width)
            }
        }
        .frame(height: 8)
    }
}

/// Applies the app background to a whole screen.
struct ScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.background)
            .scrollContentBackground(.hidden)
    }
}

extension View {
    func screenBackground() -> some View { modifier(ScreenBackground()) }
}
