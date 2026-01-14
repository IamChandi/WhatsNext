import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?

    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(Theme.secondaryText)
                .symbolRenderingMode(.hierarchical)

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text(title)
                    .font(DesignSystem.Typography.title2)
                    .foregroundStyle(Theme.primaryText)

                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(Theme.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
            }

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Label(actionTitle, systemImage: "plus.circle.fill")
                        .font(DesignSystem.Typography.bodyEmphasized)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "target",
        title: "No Goals Yet",
        description: "Add your first goal to get started on your productivity journey",
        actionTitle: "Add Goal"
    ) {
        print("Action tapped")
    }
}
