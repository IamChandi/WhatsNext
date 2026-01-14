import SwiftUI
import SwiftData
import UIKit

struct GoalRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    @State private var showingEditor = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            // Completion checkbox
            Button(action: toggleCompletion) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(goal.isCompleted ? .green : Theme.secondaryText)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)

            // Main content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(goal.title)
                        .font(DesignSystem.Typography.bodyEmphasized)
                        .strikethrough(goal.isCompleted)
                        .foregroundStyle(goal.isCompleted ? Theme.secondaryText : Theme.primaryText)
                        .lineLimit(2)

                    if goal.isFocused {
                        Image(systemName: "scope")
                            .foregroundStyle(Theme.accent)
                            .font(DesignSystem.Typography.caption)
                            .symbolRenderingMode(.hierarchical)
                    }
                }

                // Metadata badges - consistent sizing and layout
                HStack(spacing: DesignSystem.Spacing.sm) {
                    // Priority indicator
                    PriorityBadge(priority: goal.priority)

                    // Due date
                    if let dueDate = goal.dueDate {
                        DueDateBadge(date: dueDate, isOverdue: goal.isOverdue)
                    }

                    // Subtask progress
                    if let subtasks = goal.subtasks, !subtasks.isEmpty {
                        SubtaskProgressBadge(
                            completed: subtasks.filter(\.isCompleted).count,
                            total: subtasks.count
                        )
                    }

                    // Alert indicator
                    if let alerts = goal.alerts, !alerts.isEmpty {
                        let upcoming = alerts.filter(\.isUpcoming).count
                        if upcoming > 0 {
                            AlertBadge(count: upcoming)
                        }
                    }

                    // Tags
                    if let tags = goal.tags, !tags.isEmpty {
                        TagsPreview(tags: Array(tags.prefix(2)))
                    }

                    // Recurrence indicator
                    if goal.recurrence != nil {
                        Image(systemName: "repeat")
                            .font(DesignSystem.Typography.caption2)
                            .foregroundStyle(Theme.secondaryText)
                            .symbolRenderingMode(.hierarchical)
                            .frame(width: 20, height: 20)
                            .background(Theme.tertiaryBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer(minLength: 0)
                }
            }

            Spacer()

            // Menu button
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
                    .foregroundStyle(Theme.secondaryText)
                    .font(.callout)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, DesignSystem.Spacing.sm)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: toggleCompletion) {
                Label(
                    goal.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: goal.isCompleted ? "circle" : "checkmark.circle"
                )
            }

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
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        withAnimation(DesignSystem.Animation.spring) {
            goal.toggleCompletion()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.toggleCompletion")
            }
        }
    }

    private func moveToCategory(_ category: GoalCategory) {
        goal.move(to: category)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.moveToCategory")
        }
    }

    private func setPriority(_ priority: Priority) {
        goal.priority = priority
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.setPriority")
        }
    }

    private func toggleFocus() {
        goal.isFocused.toggle()
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.toggleFocus")
        }
    }

    private func archiveGoal() {
        goal.archive()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.archiveGoal")
        }
    }

    private func deleteGoal() {
        modelContext.delete(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalRowView.deleteGoal")
        }
    }
}



// MARK: - Supporting Views
// Note: PriorityBadge and DueDateBadge are defined in GoalDetailView.swift

struct SubtaskProgressBadge: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "checklist")
                .font(DesignSystem.Typography.caption2)
                .symbolRenderingMode(.hierarchical)
            Text("\(completed)/\(total)")
                .font(DesignSystem.Typography.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .frame(height: 20)
        .background(Theme.tertiaryBackground)
        .foregroundStyle(Theme.secondaryText)
        .clipShape(Capsule())
    }
}

struct AlertBadge: View {
    let count: Int

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "bell.fill")
                .font(DesignSystem.Typography.caption2)
                .symbolRenderingMode(.hierarchical)
            if count > 1 {
                Text("\(count)")
                    .font(DesignSystem.Typography.caption2)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .frame(height: 20)
        .background(Theme.accent.opacity(0.15))
        .foregroundStyle(Theme.accent)
        .clipShape(Capsule())
    }
}

struct TagsPreview: View {
    let tags: [Tag]

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            ForEach(tags) { tag in
                Text(tag.name)
                    .font(DesignSystem.Typography.caption2)
                    .lineLimit(1)
                    .padding(.horizontal, DesignSystem.Spacing.sm)
                    .padding(.vertical, DesignSystem.Spacing.xs)
                    .frame(height: 20)
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
