//
//  ModernEmptyState.swift
//  WhatsNext
//
//  Enhanced empty state component with actions and modern design
//

import SwiftUI

// MARK: - Empty State Configuration

struct EmptyStateConfig {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let primaryAction: ActionConfig?
    let secondaryAction: ActionConfig?

    struct ActionConfig {
        let title: String
        let action: () -> Void
    }
}

// MARK: - Predefined Empty States

extension EmptyStateConfig {
    static func noGoals(onCreate: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "checkmark.seal",
            title: "No Goals Yet",
            subtitle: "Create your first goal to get started with your productivity journey",
            iconColor: DesignTokens.Colors.accent,
            primaryAction: ActionConfig(title: "Create Goal", action: onCreate),
            secondaryAction: nil
        )
    }

    static func noSearchResults(searchText: String, onClear: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "magnifyingglass",
            title: "No Results Found",
            subtitle: "No goals match \"\(searchText)\". Try a different search term.",
            iconColor: DesignTokens.Colors.neutral500,
            primaryAction: ActionConfig(title: "Clear Search", action: onClear),
            secondaryAction: nil
        )
    }

    static func allClear(icon: String = "checkmark.seal", title: String = "All Clear") -> EmptyStateConfig {
        EmptyStateConfig(
            icon: icon,
            title: title,
            subtitle: "You're all caught up! Great work.",
            iconColor: DesignTokens.Colors.success,
            primaryAction: nil,
            secondaryAction: nil
        )
    }

    static func noTags(onCreate: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "tag",
            title: "No Tags",
            subtitle: "Create tags to organize your goals",
            iconColor: DesignTokens.Colors.info,
            primaryAction: ActionConfig(title: "Create Tag", action: onCreate),
            secondaryAction: nil
        )
    }

    static func noNotes(onCreate: @escaping () -> Void) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "note.text",
            title: "No Notes",
            subtitle: "Add notes to capture important details",
            iconColor: DesignTokens.Colors.warning,
            primaryAction: ActionConfig(title: "Create Note", action: onCreate),
            secondaryAction: nil
        )
    }

    static func archived(onRestore: (() -> Void)? = nil) -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "archivebox",
            title: "No Archived Goals",
            subtitle: "Completed goals you archive will appear here",
            iconColor: DesignTokens.Colors.neutral500,
            primaryAction: onRestore.map { ActionConfig(title: "View Active Goals", action: $0) },
            secondaryAction: nil
        )
    }

    static func noBriefing() -> EmptyStateConfig {
        EmptyStateConfig(
            icon: "sun.max.fill",
            title: "All Clear",
            subtitle: "No immediate items for your briefing",
            iconColor: DesignTokens.Colors.warning,
            primaryAction: nil,
            secondaryAction: nil
        )
    }
}

// MARK: - Modern Empty State View

struct ModernEmptyState: View {
    let config: EmptyStateConfig
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            // Icon with animation
            Image(systemName: config.icon)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(config.iconColor)
                .symbolEffect(.pulse, options: .repeating, value: isAnimating)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(DesignTokens.Animation.bouncy, value: isAnimating)

            // Text content
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(config.title)
                    .font(DesignTokens.Typography.h2)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)

                Text(config.subtitle)
                    .font(DesignTokens.Typography.bodyMedium)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: 400)

            // Actions
            if let primaryAction = config.primaryAction {
                VStack(spacing: DesignTokens.Spacing.md) {
                    Button(action: primaryAction.action) {
                        Text(primaryAction.title)
                            .font(DesignTokens.Typography.labelProminent)
                            .padding(.horizontal, DesignTokens.Spacing.xl)
                            .padding(.vertical, DesignTokens.Spacing.md)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(DesignTokens.Colors.accent)
                    .controlSize(.large)

                    if let secondaryAction = config.secondaryAction {
                        Button(action: secondaryAction.action) {
                            Text(secondaryAction.title)
                                .font(DesignTokens.Typography.labelRegular)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Colors.surfacePrimary)
        .onAppear {
            withAnimation(DesignTokens.Animation.bouncy.delay(0.1)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Previews

#Preview("No Goals") {
    ModernEmptyState(
        config: .noGoals(onCreate: {})
    )
}

#Preview("No Search Results") {
    ModernEmptyState(
        config: .noSearchResults(searchText: "test", onClear: {})
    )
}

#Preview("All Clear") {
    ModernEmptyState(
        config: .allClear()
    )
}

#Preview("No Tags") {
    ModernEmptyState(
        config: .noTags(onCreate: {})
    )
}
