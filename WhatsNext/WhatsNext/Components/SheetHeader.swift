//
//  SheetHeader.swift
//  WhatsNext
//
//  Standardized header for sheets and modals
//

import SwiftUI

// MARK: - Sheet Header Styles

enum SheetHeaderStyle {
    case standard
    case prominent
    case minimal

    var backgroundColor: Color {
        switch self {
        case .standard, .prominent:
            return Color(nsColor: .controlBackgroundColor)
        case .minimal:
            return .clear
        }
    }

    var titleFont: Font {
        switch self {
        case .standard:
            return DesignTokens.Typography.h3
        case .prominent:
            return DesignTokens.Typography.h2
        case .minimal:
            return DesignTokens.Typography.h3
        }
    }

    var height: CGFloat? {
        switch self {
        case .standard:
            return 60
        case .prominent:
            return 80
        case .minimal:
            return nil
        }
    }
}

// MARK: - Sheet Header

struct SheetHeader: View {
    let title: String
    let subtitle: String?
    let style: SheetHeaderStyle
    let showDismissButton: Bool
    let onDismiss: () -> Void

    init(
        title: String,
        subtitle: String? = nil,
        style: SheetHeaderStyle = .standard,
        showDismissButton: Bool = true,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.showDismissButton = showDismissButton
        self.onDismiss = onDismiss
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(style.titleFont)
                    .fontWeight(.semibold)
                    .foregroundStyle(DesignTokens.Colors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignTokens.Typography.bodySmall)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }

            Spacer()

            if showDismissButton {
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.cancelAction)
                .help("Close (Esc)")
                .accessibilityLabel("Close")
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .frame(height: style.height)
        .background(style.backgroundColor)
        .overlay(alignment: .bottom) {
            if style != .minimal {
                Divider()
            }
        }
    }
}

// MARK: - Sheet Container

struct SheetContainer<Content: View>: View {
    let title: String
    let subtitle: String?
    let style: SheetHeaderStyle
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        style: SheetHeaderStyle = .standard,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.onDismiss = onDismiss
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: title,
                subtitle: subtitle,
                style: style,
                onDismiss: onDismiss
            )

            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(DesignTokens.Colors.surfacePrimary)
    }
}

// MARK: - Sheet Footer

struct SheetFooter: View {
    let primaryAction: ActionButton?
    let secondaryAction: ActionButton?
    let cancelAction: (() -> Void)?

    struct ActionButton {
        let title: String
        let style: ButtonStyle
        let action: () -> Void

        enum ButtonStyle {
            case primary
            case secondary
            case destructive
        }
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            if let cancelAction = cancelAction {
                Button("Cancel", action: cancelAction)
                    .buttonStyle(.plain)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .keyboardShortcut(.cancelAction)
            }

            Spacer()

            if let secondaryAction = secondaryAction {
                Button(secondaryAction.title, action: secondaryAction.action)
                    .buttonStyle(.bordered)
            }

            if let primaryAction = primaryAction {
                Button(primaryAction.title, action: primaryAction.action)
                    .buttonStyle(.borderedProminent)
                    .tint(primaryAction.style == .destructive ? DesignTokens.Colors.error : DesignTokens.Colors.accent)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(Color(nsColor: .controlBackgroundColor))
        .overlay(alignment: .top) {
            Divider()
        }
    }
}

// MARK: - Full Sheet Template

struct FullSheetTemplate<Content: View>: View {
    let title: String
    let subtitle: String?
    let style: SheetHeaderStyle
    let primaryAction: SheetFooter.ActionButton?
    let secondaryAction: SheetFooter.ActionButton?
    let showCancel: Bool
    let onDismiss: () -> Void
    @ViewBuilder let content: Content

    init(
        title: String,
        subtitle: String? = nil,
        style: SheetHeaderStyle = .standard,
        primaryAction: SheetFooter.ActionButton? = nil,
        secondaryAction: SheetFooter.ActionButton? = nil,
        showCancel: Bool = true,
        onDismiss: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.showCancel = showCancel
        self.onDismiss = onDismiss
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(
                title: title,
                subtitle: subtitle,
                style: style,
                onDismiss: onDismiss
            )

            ScrollView {
                content
                    .padding(DesignTokens.Spacing.lg)
            }

            if primaryAction != nil || secondaryAction != nil || showCancel {
                SheetFooter(
                    primaryAction: primaryAction,
                    secondaryAction: secondaryAction,
                    cancelAction: showCancel ? onDismiss : nil
                )
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .background(DesignTokens.Colors.surfacePrimary)
    }
}

// MARK: - Previews

#Preview("Standard Header") {
    SheetHeader(
        title: "Edit Goal",
        subtitle: "Update your goal details",
        onDismiss: {}
    )
}

#Preview("Prominent Header") {
    SheetHeader(
        title: "Create New Goal",
        subtitle: "Add a new goal to your list",
        style: .prominent,
        onDismiss: {}
    )
}

#Preview("Minimal Header") {
    SheetHeader(
        title: "Quick Entry",
        style: .minimal,
        onDismiss: {}
    )
}

#Preview("Full Sheet Template") {
    FullSheetTemplate(
        title: "Edit Goal",
        subtitle: "Update your goal details",
        primaryAction: SheetFooter.ActionButton(
            title: "Save",
            style: .primary,
            action: {}
        ),
        secondaryAction: SheetFooter.ActionButton(
            title: "Delete",
            style: .destructive,
            action: {}
        ),
        onDismiss: {}
    ) {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sheet content goes here")
            TextField("Goal title", text: .constant(""))
            TextEditor(text: .constant("Description..."))
                .frame(height: 100)
        }
    }
}
