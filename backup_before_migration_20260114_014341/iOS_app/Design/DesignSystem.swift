import SwiftUI

/// Modern iOS design system following Apple's Human Interface Guidelines
/// Provides consistent spacing, typography, colors, and styling throughout the app.
struct DesignSystem {
    // MARK: - Spacing
    
    /// Standard spacing scale following iOS conventions
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    
    /// Consistent corner radius values
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xlarge: CGFloat = 20
    }
    
    // MARK: - Typography
    
    /// Typography scale for consistent text styling
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title1 = Font.title.weight(.bold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)
        static let headline = Font.headline
        static let body = Font.body
        static let bodyEmphasized = Font.body.weight(.medium)
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Shadows
    
    /// Elevation shadows for depth
    struct Shadow {
        static let small = ShadowStyle(
            color: .black.opacity(0.05),
            radius: 4,
            x: 0,
            y: 2
        )
        
        static let medium = ShadowStyle(
            color: .black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
        
        static let large = ShadowStyle(
            color: .black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animation
    
    /// Standard animation curves and durations
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.4)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
}

/// Shadow style configuration
struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension View {
    /// Apply a shadow style
    func shadow(_ style: ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
