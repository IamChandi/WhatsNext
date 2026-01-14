import SwiftUI
import SwiftData
import WhatsNextShared

public struct KanbanBoardView: View {
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
            SortDescriptor<Goal>(\.categoryRaw),
            SortDescriptor<Goal>(\.statusRaw),
            SortDescriptor<Goal>(\.priorityRaw),
            SortDescriptor<Goal>(\.sortOrder)
        ]
    ) var allGoals: [Goal]

    @State private var draggedGoal: Goal?
    @State private var showingNewGoalSheet = false
    @State private var newGoalCategory: GoalCategory = .daily
    @State private var dragOffset: CGSize = .zero

    /// Public initializer - @Query properties are automatically injected by SwiftUI
    public init(initialCategory: GoalCategory, searchText: String, selectedGoal: Binding<Goal?>) {
        self.initialCategory = initialCategory
        self.searchText = searchText
        self._selectedGoal = selectedGoal
    }

    // Filter by category and search - category filtering happens in memory but goals are pre-sorted
    private func goalsFor(category: GoalCategory) -> [Goal] {
        allGoals
            .filter { $0.category == category }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.lg) {
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
            .padding(DesignTokens.Spacing.lg)
        }
        .background(DesignTokens.Colors.surfacePrimary)
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
        withAnimation(DesignTokens.Animation.smooth) {
            goal.move(to: category)
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "KanbanBoardView.moveGoal")
            }
        }

        // Reset drag state
        draggedGoal = nil
        dragOffset = .zero
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            // Header with enhanced styling
            HStack {
                Badge(style: .category(category), size: .medium)

                Spacer()

                Badge(style: .count(goals.count, color: DesignTokens.Colors.textSecondary), size: .small)

                Button(action: onAddGoal) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(category.color)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .help("Add goal to \(category.displayName)")
                .scaleEffect(isTargeted ? 1.1 : 1.0)
                .animation(DesignTokens.Animation.quick, value: isTargeted)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.md)

            Divider()
                .padding(.horizontal, DesignTokens.Spacing.lg)

            // Cards with enhanced drag preview
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(goals) { goal in
                        KanbanCardView(
                            goal: goal,
                            isSelected: selectedGoal?.id == goal.id,
                            onSelect: { selectedGoal = goal }
                        )
                        .draggable(goal.id.uuidString) {
                            // Enhanced drag preview
                            KanbanCardView(goal: goal, isSelected: false, onSelect: {})
                                .frame(width: 260)
                                .cardStyle(elevation: .large)
                                .opacity(DesignTokens.Opacity.intense)
                                .rotationEffect(.degrees(3))
                                .scaleEffect(1.05)
                        }
                        .onDrag {
                            draggedGoal = goal
                            return NSItemProvider(object: goal.id.uuidString as NSString)
                        }
                        .opacity(draggedGoal?.id == goal.id ? DesignTokens.Opacity.light : DesignTokens.Opacity.opaque)
                        .animation(DesignTokens.Animation.quick, value: draggedGoal?.id)
                    }

                    // Drop zone indicator when empty
                    if goals.isEmpty {
                        VStack(spacing: DesignTokens.Spacing.md) {
                            Image(systemName: isTargeted ? "arrow.down.circle.fill" : "tray")
                                .font(.system(size: DesignTokens.IconSize.xxl))
                                .foregroundStyle(isTargeted ? category.color : DesignTokens.Colors.textTertiary)
                                .symbolEffect(.bounce, value: isTargeted)

                            Text(isTargeted ? "Drop Here" : "No goals")
                                .font(DesignTokens.Typography.bodySmall)
                                .foregroundStyle(DesignTokens.Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.xxl)
                        .animation(DesignTokens.Animation.bouncy, value: isTargeted)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.md)
            }
        }
        .frame(width: 300)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .fill(DesignTokens.Colors.surfaceSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.xl)
                .strokeBorder(
                    isTargeted ? category.color.opacity(0.8) : DesignTokens.Colors.neutral200,
                    lineWidth: isTargeted ? DesignTokens.BorderWidth.thick : DesignTokens.BorderWidth.thin
                )
        )
        .shadow(
            color: isTargeted ? category.color.opacity(0.3) : DesignTokens.Shadow.sm.color,
            radius: isTargeted ? 12 : DesignTokens.Shadow.sm.radius,
            y: isTargeted ? 4 : DesignTokens.Shadow.sm.y
        )
        .scaleEffect(isTargeted ? 1.02 : 1.0)
        .animation(DesignTokens.Animation.smooth, value: isTargeted)
        .dropDestination(for: String.self) { items, location in
            guard let idString = items.first,
                  let goalId = UUID(uuidString: idString),
                  let goal = draggedGoal, goal.id == goalId else {
                return false
            }
            onDropGoal(goal)
            return true
        } isTargeted: { targeted in
            withAnimation(DesignTokens.Animation.quick) {
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
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            // Header with priority and status
            HStack {
                PriorityDot(priority: goal.priority)

                Spacer()

                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(DesignTokens.Colors.success)
                        .font(.caption)
                        .symbolEffect(.bounce, value: goal.isCompleted)
                }

                if goal.isFocused {
                    Image(systemName: "scope")
                        .foregroundStyle(DesignTokens.Colors.warning)
                        .font(.caption)
                        .symbolEffect(.pulse)
                }
            }

            // Title with improved typography
            Text(goal.title)
                .font(DesignTokens.Typography.bodyLarge)
                .fontWeight(.medium)
                .strikethrough(goal.isCompleted)
                .foregroundStyle(goal.isCompleted ? DesignTokens.Colors.textSecondary : DesignTokens.Colors.textPrimary)
                .lineLimit(2)
                .animation(DesignTokens.Animation.gentle, value: goal.isCompleted)

            // Description preview
            if let description = goal.goalDescription, !description.isEmpty {
                Text(description)
                    .font(DesignTokens.Typography.bodySmall)
                    .foregroundStyle(DesignTokens.Colors.textSecondary)
                    .lineLimit(2)
            }

            // Metadata badges using Badge component
            HStack(spacing: DesignTokens.Spacing.xs) {
                if let dueDate = goal.dueDate {
                    Badge(style: .dueDate(dueDate, isOverdue: goal.isOverdue), size: .small)
                }

                if let subtasks = goal.subtasks, !subtasks.isEmpty {
                    Badge(
                        style: .subtaskProgress(
                            completed: subtasks.filter(\.isCompleted).count,
                            total: subtasks.count
                        ),
                        size: .small
                    )
                }

                if let alerts = goal.alerts, alerts.contains(where: \.isUpcoming) {
                    Badge(style: .alert(count: 1), size: .small)
                }

                Spacer()

                if goal.recurrence != nil {
                    Image(systemName: "repeat")
                        .font(.caption2)
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                }
            }

            // Tags
            if let tags = goal.tags, !tags.isEmpty {
                TagsPreview(tags: Array(tags.prefix(3)))
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Colors.surfaceElevated)
        )
        .shadow(
            color: isHovering ? DesignTokens.Shadow.lg.color : DesignTokens.Shadow.md.color,
            radius: isHovering ? DesignTokens.Shadow.lg.radius : DesignTokens.Shadow.md.radius,
            y: isHovering ? DesignTokens.Shadow.lg.y : DesignTokens.Shadow.md.y
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .strokeBorder(
                    isSelected ? DesignTokens.Colors.accent : Color.clear,
                    lineWidth: DesignTokens.BorderWidth.regular
                )
        )
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .opacity(goal.isCompleted ? DesignTokens.Opacity.strong : DesignTokens.Opacity.opaque)
        .animation(DesignTokens.Animation.quick, value: isHovering)
        .animation(DesignTokens.Animation.smooth, value: goal.isCompleted)
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .onHover { hovering in
            withAnimation(DesignTokens.Animation.quick) {
                isHovering = hovering
            }
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
