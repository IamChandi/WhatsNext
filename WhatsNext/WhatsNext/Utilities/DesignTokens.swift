//
//  DesignTokens.swift
//  WhatsNext
//
//  Design System Foundation
//  Centralized design tokens for colors, typography, spacing, and more
//

import SwiftUI

/// Centralized design token system for WhatsNext
/// Provides consistent theming across the application
struct DesignTokens {

    // MARK: - Colors

    struct Colors {
        // MARK: Brand Colors
        static let primary = Color(red: 26/255, green: 54/255, blue: 93/255) // Presidential Blue
        static let accent = Color(red: 237/255, green: 137/255, blue: 54/255) // Forward Orange

        // MARK: Semantic Colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // MARK: Neutral Scale (for subtle UI elements)
        static let neutral50 = Color(white: 0.98)
        static let neutral100 = Color(white: 0.96)
        static let neutral200 = Color(white: 0.90)
        static let neutral300 = Color(white: 0.83)
        static let neutral400 = Color(white: 0.68)
        static let neutral500 = Color(white: 0.50)
        static let neutral600 = Color(white: 0.38)
        static let neutral700 = Color(white: 0.28)
        static let neutral800 = Color(white: 0.18)
        static let neutral900 = Color(white: 0.10)

        // MARK: Surface Colors (adapts to system appearance)
        static let surfacePrimary = Color(nsColor: .windowBackgroundColor)
        static let surfaceSecondary = Color(nsColor: .controlBackgroundColor)
        static let surfaceElevated = Color(nsColor: .textBackgroundColor)

        // MARK: Text Colors (hierarchical)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(nsColor: .tertiaryLabelColor)
        static let textInverse = Color.white

        // MARK: Overlay Colors
        static let overlay = Color.black.opacity(0.5)
        static let overlayLight = Color.black.opacity(0.3)
    }

    // MARK: - Typography

    struct Typography {
        // MARK: Display (Extra large, for major headings)
        static let displayLarge = Font.system(.largeTitle, design: .rounded, weight: .bold)
        static let displayMedium = Font.system(.title, design: .rounded, weight: .semibold)
        static let displaySmall = Font.system(.title2, design: .rounded, weight: .medium)

        // MARK: Headings
        static let h1 = Font.system(.title, design: .default, weight: .bold)
        static let h2 = Font.system(.title2, design: .default, weight: .semibold)
        static let h3 = Font.system(.title3, design: .default, weight: .medium)

        // MARK: Body
        static let bodyLarge = Font.system(.body, design: .default, weight: .regular)
        static let bodyMedium = Font.system(.callout, design: .default, weight: .regular)
        static let bodySmall = Font.system(.caption, design: .default, weight: .regular)

        // MARK: Labels (for UI elements)
        static let labelProminent = Font.system(.body, design: .default, weight: .semibold)
        static let labelRegular = Font.system(.body, design: .default, weight: .regular)
        static let labelSecondary = Font.system(.caption, design: .default, weight: .medium)
        static let labelSmall = Font.system(.caption2, design: .default, weight: .regular)

        // MARK: Monospaced (for dates, numbers)
        static let monoMedium = Font.system(.body, design: .monospaced, weight: .medium)
        static let monoSmall = Font.system(.caption, design: .monospaced, weight: .regular)

        // MARK: Serif (for immersive experiences)
        static let serifLarge = Font.system(size: 48, weight: .bold, design: .serif)
        static let serifMedium = Font.system(size: 24, weight: .medium, design: .serif)
    }

    // MARK: - Spacing

    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
        static let huge: CGFloat = 64
    }

    // MARK: - Corner Radius

    struct CornerRadius {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 24
        static let round: CGFloat = 9999 // For circular shapes
    }

    // MARK: - Shadows

    struct Shadow {
        static let none = Color.clear.opacity(0)
        static let sm = (color: Color.black.opacity(0.05), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let md = (color: Color.black.opacity(0.1), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let lg = (color: Color.black.opacity(0.15), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let xl = (color: Color.black.opacity(0.2), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
    }

    // MARK: - Animation

    struct Animation {
        static let quick = SwiftUI.Animation.spring(duration: 0.2, bounce: 0.3)
        static let standard = SwiftUI.Animation.spring(duration: 0.3, bounce: 0.4)
        static let smooth = SwiftUI.Animation.spring(duration: 0.4, bounce: 0.3)
        static let bouncy = SwiftUI.Animation.spring(duration: 0.5, bounce: 0.5)
        static let gentle = SwiftUI.Animation.easeInOut(duration: 0.25)
    }

    // MARK: - Opacity

    struct Opacity {
        static let invisible: Double = 0.0
        static let subtle: Double = 0.1
        static let light: Double = 0.3
        static let medium: Double = 0.5
        static let strong: Double = 0.7
        static let intense: Double = 0.9
        static let opaque: Double = 1.0
    }

    // MARK: - Icon Sizes

    struct IconSize {
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 20
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: - Border Width

    struct BorderWidth {
        static let thin: CGFloat = 1
        static let regular: CGFloat = 2
        static let thick: CGFloat = 3
    }

    // MARK: - Minimum Touch Targets (iOS compatibility)

    struct TouchTarget {
        static let minimum: CGFloat = 44 // iOS minimum
        static let comfortable: CGFloat = 48
        static let large: CGFloat = 56
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Apply a standard card style with design tokens
    func cardStyle(elevation: CardElevation = .medium) -> some View {
        self
            .background(DesignTokens.Colors.surfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg))
            .shadow(
                color: elevation.shadow.color,
                radius: elevation.shadow.radius,
                x: elevation.shadow.x,
                y: elevation.shadow.y
            )
    }

    /// Apply a standard badge style
    func badgeStyle(backgroundColor: Color, foregroundColor: Color = .white) -> some View {
        self
            .font(DesignTokens.Typography.labelSmall)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xxs)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .clipShape(Capsule())
    }
}

enum CardElevation {
    case none
    case small
    case medium
    case large

    var shadow: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        switch self {
        case .none:
            return (DesignTokens.Shadow.none, 0, 0, 0)
        case .small:
            return DesignTokens.Shadow.sm
        case .medium:
            return DesignTokens.Shadow.md
        case .large:
            return DesignTokens.Shadow.lg
        }
    }
}

// MARK: - Gradient Presets

extension DesignTokens {
    struct Gradients {
        static let primary = LinearGradient(
            gradient: Gradient(colors: [
                DesignTokens.Colors.primary,
                DesignTokens.Colors.primary.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accent = LinearGradient(
            gradient: Gradient(colors: [
                DesignTokens.Colors.accent,
                DesignTokens.Colors.accent.opacity(0.8)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let ovalOffice = LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 26/255, green: 54/255, blue: 93/255),
                Color(red: 44/255, green: 82/255, blue: 130/255)
            ]),
            startPoint: .top,
            endPoint: .bottom
        )

        static let subtle = LinearGradient(
            gradient: Gradient(colors: [
                DesignTokens.Colors.neutral100,
                DesignTokens.Colors.neutral50
            ]),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
