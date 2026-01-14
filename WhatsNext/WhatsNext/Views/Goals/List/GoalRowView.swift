import SwiftUI
import SwiftData
import WhatsNextShared

struct GoalRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    @State private var isHovering = false
    @State private var showingEditor = false

    var body: some View {
        HStack(spacing: 12) {
            // Completion checkbox
            Button(action: toggleCompletion) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(goal.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            // Main content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(goal.title)
                        .font(.body)
                        .strikethrough(goal.isCompleted)
                        .foregroundStyle(goal.isCompleted ? .secondary : .primary)

                    if goal.isFocused {
                        Image(systemName: "scope")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }

                HStack(spacing: 8) {
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
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            // Category indicator (for context)
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
                        .foregroundStyle(.secondary)
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .frame(width: 24)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
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
        withAnimation(.easeInOut(duration: AppConstants.Animation.quick)) {
            goal.toggleCompletion()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalRowView.toggleCompletion")
            }
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
