import SwiftUI
import SwiftData

struct KanbanBoardView: View {
    @Environment(\.modelContext) private var modelContext
    let initialCategory: GoalCategory
    let searchText: String
    @Binding var selectedGoal: Goal?

    // Use database-level filtering - fetch all non-archived goals
    @Query(
        filter: #Predicate<Goal> { goal in
            goal.statusRaw != "archived"
        },
        sort: [
            SortDescriptor(\.categoryRaw),
            SortDescriptor(\.statusRaw),
            SortDescriptor(\.priorityRaw),
            SortDescriptor(\.sortOrder)
        ]
    ) private var allGoals: [Goal]

    @State private var draggedGoal: Goal?
    @State private var showingNewGoalSheet = false
    @State private var newGoalCategory: GoalCategory = .daily

    // Filter by category and search - category filtering happens in memory but goals are pre-sorted
    private func goalsFor(category: GoalCategory) -> [Goal] {
        allGoals
            .filter { $0.category == category }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(GoalCategory.allCases) { category in
                    KanbanColumnView(
                        category: category,
                        goals: goalsFor(category: category),
                        selectedGoal: $selectedGoal,
                        draggedGoal: $draggedGoal,
                        onAddGoal: {
                            newGoalCategory = category
                            showingNewGoalSheet = true
                        },
                        onDropGoal: { goal in
                            moveGoal(goal, to: category)
                        }
                    )
                }
            }
            .padding()
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Board View")
        .sheet(isPresented: $showingNewGoalSheet) {
            GoalEditorSheet(category: newGoalCategory) { goal in
                modelContext.insert(goal)
                if !modelContext.saveWithErrorHandling() {
                    ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanBoardView.saveGoal")
                }
            }
        }
        .withErrorHandling()
    }

    private func moveGoal(_ goal: Goal, to category: GoalCategory) {
        withAnimation(.easeInOut(duration: AppConstants.Animation.quick)) {
            goal.move(to: category)
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanBoardView.moveGoal")
            }
        }
    }
}

struct KanbanColumnView: View {
    let category: GoalCategory
    let goals: [Goal]
    @Binding var selectedGoal: Goal?
    @Binding var draggedGoal: Goal?
    let onAddGoal: () -> Void
    let onDropGoal: (Goal) -> Void

    @State private var isTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(category.shortName.uppercased())
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(category.color.opacity(0.1))
                    .cornerRadius(6)

                Spacer()
                
                Text("\(goals.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)

                Button(action: onAddGoal) {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            Divider()
                .padding(.horizontal)

            // Cards
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 8) {
                    ForEach(goals) { goal in
                        KanbanCardView(
                            goal: goal,
                            isSelected: selectedGoal?.id == goal.id,
                            onSelect: { selectedGoal = goal }
                        )
                        .draggable(goal.id.uuidString) {
                            KanbanCardView(goal: goal, isSelected: false, onSelect: {})
                                .frame(width: 260)
                                .opacity(0.8)
                        }
                        .onDrag {
                            draggedGoal = goal
                            return NSItemProvider(object: goal.id.uuidString as NSString)
                        }
                    }

                    if goals.isEmpty {
                        Text("No goals")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isTargeted ? category.color.opacity(0.1) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isTargeted ? category.color : .clear, lineWidth: 2)
        )
        .dropDestination(for: String.self) { items, location in
            guard let idString = items.first,
                  let goalId = UUID(uuidString: idString),
                  let goal = draggedGoal, goal.id == goalId else {
                return false
            }
            onDropGoal(goal)
            return true
        } isTargeted: { targeted in
            withAnimation(.easeInOut(duration: 0.15)) {
                isTargeted = targeted
            }
        }
    }
}

struct KanbanCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal
    let isSelected: Bool
    let onSelect: () -> Void

    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with priority and status
            HStack {
                PriorityDot(priority: goal.priority)

                Spacer()

                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                }

                if goal.isFocused {
                    Image(systemName: "scope")
                        .foregroundStyle(.orange)
                        .font(.caption)
                }
            }

            // Title
            Text(goal.title)
                .font(.body)
                .fontWeight(.medium)
                .strikethrough(goal.isCompleted)
                .foregroundStyle(goal.isCompleted ? .secondary : .primary)
                .lineLimit(2)

            // Description preview
            if let description = goal.goalDescription, !description.isEmpty {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Metadata row
            HStack(spacing: 8) {
                if let dueDate = goal.dueDate {
                    HStack(spacing: 2) {
                        Image(systemName: "calendar")
                        Text(dueDateText(dueDate))
                    }
                    .font(.caption2)
                    .foregroundStyle(goal.isOverdue ? .red : .secondary)
                }

                if let subtasks = goal.subtasks, !subtasks.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "checklist")
                        Text("\(subtasks.filter(\.isCompleted).count)/\(subtasks.count)")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }

                if let alerts = goal.alerts, alerts.contains(where: \.isUpcoming) {
                    Image(systemName: "bell.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }

                Spacer()

                if goal.recurrence != nil {
                    Image(systemName: "repeat")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Tags
            if let tags = goal.tags, !tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(Array(tags.prefix(3))) { tag in
                        Text(tag.name)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(tag.color.opacity(0.15))
                            .foregroundStyle(tag.color)
                            .clipShape(Capsule())
                    }
                    if tags.count > 3 {
                        Text("+\(tags.count - 3)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Theme.cardBackground)
                .shadow(color: .black.opacity(isHovering ? 0.15 : 0.1), radius: isHovering ? 6 : 3, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .onHover { isHovering = $0 }
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
                    systemImage: "scope"
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

    private func dueDateText(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func toggleCompletion() {
        withAnimation {
            goal.toggleCompletion()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.toggleCompletion")
            }
        }
    }

    private func moveToCategory(_ category: GoalCategory) {
        goal.move(to: category)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.moveToCategory")
        }
    }

    private func setPriority(_ priority: Priority) {
        goal.priority = priority
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.setPriority")
        }
    }

    private func toggleFocus() {
        goal.isFocused.toggle()
        goal.updatedAt = Date()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.toggleFocus")
        }
    }

    private func archiveGoal() {
        goal.archive()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.archiveGoal")
        }
    }

    private func deleteGoal() {
        modelContext.delete(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanCardView.deleteGoal")
        }
    }
}



#Preview {
    KanbanBoardView(
        initialCategory: .daily,
        searchText: "",
        selectedGoal: .constant(nil)
    )
    .modelContainer(for: [Goal.self, Subtask.self, Tag.self], inMemory: true)
    .frame(height: 600)
}
