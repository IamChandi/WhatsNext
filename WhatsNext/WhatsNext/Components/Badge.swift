//
//  Badge.swift
//  WhatsNext
//
//  Unified badge component for consistent UI elements
//  Replaces individual badge implementations with a single, flexible component
//

import SwiftUI
import WhatsNextShared

// MARK: - Badge Styles

enum BadgeStyle {
    case priority(Priority)
    case dueDate(Date, isOverdue: Bool)
    case subtaskProgress(completed: Int, total: Int)
    case alert(count: Int)
    case tag(Tag)
    case category(GoalCategory)
    case status(String, color: Color)
    case count(Int, color: Color)
    case custom(text: String, icon: String?, backgroundColor: Color, foregroundColor: Color)

    var configuration: BadgeConfiguration {
        switch self {
        case .priority(let priority):
            return BadgeConfiguration(
                text: priority.displayName,
                icon: priority.icon,
                backgroundColor: priority.color.opacity(0.15),
                foregroundColor: priority.color
            )

        case .dueDate(let date, let isOverdue):
            return BadgeConfiguration(
                text: formattedDate(date),
                icon: "calendar",
                backgroundColor: isOverdue ? DesignTokens.Colors.error.opacity(0.15) : DesignTokens.Colors.neutral200,
                foregroundColor: isOverdue ? DesignTokens.Colors.error : DesignTokens.Colors.textSecondary
            )

        case .subtaskProgress(let completed, let total):
            return BadgeConfiguration(
                text: "\(completed)/\(total)",
                icon: "checklist",
                backgroundColor: DesignTokens.Colors.neutral200,
                foregroundColor: DesignTokens.Colors.textSecondary
            )

        case .alert(let count):
            return BadgeConfiguration(
                text: count > 1 ? "\(count)" : nil,
                icon: "bell.fill",
                backgroundColor: DesignTokens.Colors.warning.opacity(0.15),
                foregroundColor: DesignTokens.Colors.warning
            )

        case .tag(let tag):
            return BadgeConfiguration(
                text: tag.name,
                icon: nil,
                backgroundColor: tag.color.opacity(0.15),
                foregroundColor: tag.color
            )

        case .category(let category):
            return BadgeConfiguration(
                text: category.shortName,
                icon: category.icon,
                backgroundColor: category.color.opacity(0.15),
                foregroundColor: category.color
            )

        case .status(let text, let color):
            return BadgeConfiguration(
                text: text,
                icon: nil,
                backgroundColor: color.opacity(0.15),
                foregroundColor: color
            )

        case .count(let count, let color):
            return BadgeConfiguration(
                text: "\(count)",
                icon: nil,
                backgroundColor: color.opacity(0.2),
                foregroundColor: color
            )

        case .custom(let text, let icon, let backgroundColor, let foregroundColor):
            return BadgeConfiguration(
                text: text,
                icon: icon,
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor
            )
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
}

// MARK: - Badge Configuration

struct BadgeConfiguration {
    let text: String?
    let icon: String?
    let backgroundColor: Color
    let foregroundColor: Color
}

// MARK: - Badge Sizes

enum BadgeSize {
    case small
    case medium
    case large

    var font: Font {
        switch self {
        case .small:
            return DesignTokens.Typography.labelSmall
        case .medium:
            return DesignTokens.Typography.labelSecondary
        case .large:
            return DesignTokens.Typography.labelRegular
        }
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return DesignTokens.Spacing.xs
        case .medium:
            return DesignTokens.Spacing.sm
        case .large:
            return DesignTokens.Spacing.md
        }
    }

    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return DesignTokens.Spacing.xxs
        case .medium:
            return DesignTokens.Spacing.xs
        case .large:
            return DesignTokens.Spacing.sm
        }
    }

    var iconSize: CGFloat {
        switch self {
        case .small:
            return DesignTokens.IconSize.xs
        case .medium:
            return DesignTokens.IconSize.sm
        case .large:
            return DesignTokens.IconSize.md
        }
    }

    var spacing: CGFloat {
        switch self {
        case .small:
            return DesignTokens.Spacing.xxs
        case .medium:
            return DesignTokens.Spacing.xs
        case .large:
            return DesignTokens.Spacing.sm
        }
    }
}

// MARK: - Badge View

struct Badge: View {
    let style: BadgeStyle
    var size: BadgeSize = .medium
    var animated: Bool = false

    private var config: BadgeConfiguration {
        style.configuration
    }

    var body: some View {
        HStack(spacing: size.spacing) {
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: size.iconSize))
                    .symbolRenderingMode(.hierarchical)
            }

            if let text = config.text {
                Text(text)
                    .font(size.font)
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(config.backgroundColor)
        .foregroundStyle(config.foregroundColor)
        .clipShape(Capsule())
        .if(animated) { view in
            view
                .transition(.scale.combined(with: .opacity))
                .animation(DesignTokens.Animation.quick, value: config.text)
        }
    }
}

// MARK: - Conditional View Modifier Helper

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Previews

#Preview("Badge Styles") {
    VStack(spacing: 16) {
        // Priority badges
        HStack {
            Badge(style: .priority(.low), size: .small)
            Badge(style: .priority(.medium), size: .medium)
            Badge(style: .priority(.high), size: .large)
        }

        // Due date badges
        HStack {
            Badge(style: .dueDate(Date(), isOverdue: false))
            Badge(style: .dueDate(Date().addingTimeInterval(-86400), isOverdue: true))
        }

        // Progress badges
        HStack {
            Badge(style: .subtaskProgress(completed: 2, total: 5))
            Badge(style: .alert(count: 3))
        }

        // Status badges
        HStack {
            Badge(style: .status("Active", color: .green))
            Badge(style: .status("Pending", color: .orange))
            Badge(style: .count(42, color: .blue))
        }
    }
    .padding()
}
