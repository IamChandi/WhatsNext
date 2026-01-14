import SwiftUI
import SwiftData
import WhatsNextShared

struct GoalRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    @State private var isHovering = false
    @State private var showingEditor = false
    @State private var isPressing = false

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Completion checkbox with animation
            Button(action: toggleCompletion) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(goal.isCompleted ? DesignTokens.Colors.success : DesignTokens.Colors.textSecondary)
                    .symbolEffect(.bounce, value: goal.isCompleted)
            }
            .buttonStyle(.plain)
            .scaleEffect(isPressing ? 0.9 : 1.0)
            .animation(DesignTokens.Animation.quick, value: isPressing)

            // Main content with progressive disclosure
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(goal.title)
                        .font(DesignTokens.Typography.bodyLarge)
                        .strikethrough(goal.isCompleted)
                        .foregroundStyle(goal.isCompleted ? DesignTokens.Colors.textSecondary : DesignTokens.Colors.textPrimary)
                        .animation(DesignTokens.Animation.gentle, value: goal.isCompleted)

                    if goal.isFocused {
                        Image(systemName: "scope")
                            .foregroundStyle(DesignTokens.Colors.warning)
                            .font(.caption)
                            .symbolEffect(.pulse)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                // Metadata badges - only show when hovering or always for mobile
                if isHovering || !goal.isCompleted {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        // Priority indicator
                        Badge(style: .priority(goal.priority), size: .small, animated: true)
                            .transition(.scale.combined(with: .opacity))

                        // Due date
                        if let dueDate = goal.dueDate {
                            Badge(style: .dueDate(dueDate, isOverdue: goal.isOverdue), size: .small, animated: true)
                                .transition(.scale.combined(with: .opacity))
                        }

                        // Subtask progress
                        if let subtasks = goal.subtasks, !subtasks.isEmpty {
                            Badge(
                                style: .subtaskProgress(completed: subtasks.filter(\.isCompleted).count, total: subtasks.count),
                                size: .small,
                                animated: true
                            )
                            .transition(.scale.combined(with: .opacity))
                        }

                        // Alert indicator
                        if let alerts = goal.alerts, !alerts.isEmpty {
                            let upcoming = alerts.filter(\.isUpcoming).count
                            if upcoming > 0 {
                                Badge(style: .alert(count: upcoming), size: .small, animated: true)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }

                        // Tags
                        if let tags = goal.tags, !tags.isEmpty {
                            TagsPreview(tags: Array(tags.prefix(2)))
                                .transition(.scale.combined(with: .opacity))
                        }

                        // Recurrence indicator
                        if goal.recurrence != nil {
                            Image(systemName: "repeat")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.Colors.textSecondary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(DesignTokens.Animation.quick, value: isHovering)
                }
            }

            Spacer()

            // Quick actions menu - appears on hover
            if isHovering {
                Menu {
                    ForEach(GoalCategory.allCases) { cat in
                        if cat != goal.category {
                            Button(action: { moveToCategory(cat) }) {
                                Label(cat.displayName, systemImage: cat.icon)
                            }
                        }
                    }

                    Divider()

                    Button(action: archiveGoal) {
                        Label("Archive", systemImage: "archivebox")
                    }

                    Button(role: .destructive, action: deleteGoal) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 24)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .padding(.horizontal, DesignTokens.Spacing.xs)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(isHovering ? DesignTokens.Colors.surfaceSecondary : Color.clear)
        )
        .scaleEffect(goal.isCompleted ? 0.98 : 1.0)
        .opacity(goal.isCompleted ? DesignTokens.Opacity.strong : DesignTokens.Opacity.opaque)
        .animation(DesignTokens.Animation.smooth, value: goal.isCompleted)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(DesignTokens.Animation.quick) {
                isHovering = hovering
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
        .accessibilityAddTraits(goal.isCompleted ? [.isSelected] : [])
        .accessibilityAction(named: goal.isCompleted ? "Mark Incomplete" : "Mark Complete") {
            toggleCompletion()
        }
        .accessibilityAction(named: "Archive") {
            archiveGoal()
        }
        .contextMenu {
            Button(action: toggleCompletion) {
                Label(
                    goal.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: goal.isCompleted ? "circle" : "checkmark.circle"
                )
            }
            .keyboardShortcut(.return, modifiers: .command)
            .help("Toggle completion (⌘↩)")

            Divider()

            Menu("Move to...") {
                ForEach(GoalCategory.allCases) { cat in
                    if cat != goal.category {
                        Button(action: { moveToCategory(cat) }) {
                            Label(cat.displayName, systemImage: cat.icon)
                        }
                    }
                }
            }

            Menu("Priority") {
                ForEach(Priority.allCases) { priority in
                    Button(action: { setPriority(priority) }) {
                        Label(priority.displayName, systemImage: priority.icon)
                    }
                }
            }

            Divider()

            Button(action: toggleFocus) {
                Label(
                    goal.isFocused ? "Remove Focus" : "Focus on This",
                    systemImage: goal.isFocused ? "scope" : "scope"
                )
            }

            Divider()

            Button(action: archiveGoal) {
                Label("Archive", systemImage: "archivebox")
            }

            Button(role: .destructive, action: deleteGoal) {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    private func toggleCompletion() {
        isPressing = true
        withAnimation(DesignTokens.Animation.bouncy) {
            goal.toggleCompletion()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.toggleCompletion")
            }
        }

        // Reset pressing state after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            isPressing = false
        }
    }

    private func moveToCategory(_ category: GoalCategory) {
        goal.move(to: category)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.moveToCategory")
        }
    }

    private func setPriority(_ priority: Priority) {
        goal.priority = priority
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.setPriority")
        }
    }

    private func toggleFocus() {
        goal.isFocused.toggle()
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.toggleFocus")
        }
    }

    private func archiveGoal() {
        goal.archive()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.archiveGoal")
        }
    }

    private func deleteGoal() {
        modelContext.delete(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.deleteGoal")
        }
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var label = goal.title

        if goal.isCompleted {
            label += ", completed"
        }

        label += ", \(goal.priority.displayName) priority"

        if let dueDate = goal.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            label += ", due \(formatter.string(from: dueDate))"
        }

        if let subtasks = goal.subtasks, !subtasks.isEmpty {
            let completed = subtasks.filter(\.isCompleted).count
            label += ", \(completed) of \(subtasks.count) subtasks completed"
        }

        return label
    }

    private var accessibilityHint: String {
        if goal.isCompleted {
            return "Double tap to mark as incomplete"
        } else {
            return "Double tap to mark as complete"
        }
    }
}



// MARK: - Supporting Views

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: priority.icon)
            Text(priority.displayName)
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(priority.color.opacity(0.15))
        .foregroundStyle(priority.color)
        .clipShape(Capsule())
    }
}

struct DueDateBadge: View {
    let date: Date
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
            Text(formattedDate)
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(isOverdue ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1))
        .foregroundStyle(isOverdue ? .red : .secondary)
        .clipShape(Capsule())
    }

    private var formattedDate: String {
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

struct SubtaskProgressBadge: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "checklist")
            Text("\(completed)/\(total)")
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.secondary.opacity(0.1))
        .foregroundStyle(.secondary)
        .clipShape(Capsule())
    }
}

struct AlertBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: "bell.fill")
            if count > 1 {
                Text("\(count)")
            }
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color.orange.opacity(0.15))
        .foregroundStyle(.orange)
        .clipShape(Capsule())
    }
}

struct TagsPreview: View {
    let tags: [Tag]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tags) { tag in
                Text(tag.name)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(tag.color.opacity(0.15))
                    .foregroundStyle(tag.color)
                    .clipShape(Capsule())
            }
        }
    }
}

struct PriorityDot: View {
    let priority: Priority

    var body: some View {
        Circle()
            .fill(priority.color)
            .frame(width: 8, height: 8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, Subtask.self, Tag.self, configurations: config)

    let goal = Goal(title: "Sample Goal", category: .daily, priority: .high)
    goal.dueDate = Date()
    goal.subtasks = [
        Subtask(title: "Subtask 1"),
        Subtask(title: "Subtask 2")
    ]
    container.mainContext.insert(goal)

    return GoalRowView(goal: goal)
        .modelContainer(container)
        .padding()
}
