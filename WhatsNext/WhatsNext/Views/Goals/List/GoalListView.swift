import SwiftUI
import SwiftData

struct GoalListView: View {
    @Environment(\.modelContext) private var modelContext
    let category: GoalCategory
    let searchText: String
    @Binding var selectedGoal: Goal?

    @Query private var allGoals: [Goal]

    @State private var showingNewGoalSheet = false
    @State private var draggedGoal: Goal?

    private var goals: [Goal] {
        allGoals
            .filter { $0.category == category && $0.status != .archived }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
            .sorted { lhs, rhs in
                if lhs.isCompleted != rhs.isCompleted {
                    return !lhs.isCompleted
                }
                if lhs.priority.sortOrder != rhs.priority.sortOrder {
                    return lhs.priority.sortOrder < rhs.priority.sortOrder
                }
                return lhs.sortOrder < rhs.sortOrder
            }
    }

    private var pendingGoals: [Goal] {
        goals.filter { !$0.isCompleted }
    }

    private var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
    }

    var body: some View {
        ZStack {
            if goals.isEmpty {
                EmptyStateView(
                    icon: category.icon,
                    title: "No \(category.displayName) Goals",
                    description: "Add a goal to get started on your tasks for this \(category.displayName.lowercased().replacingOccurrences(of: "this ", with: "")).",
                    actionTitle: "Add Goal",
                    action: { showingNewGoalSheet = true }
                )
                .transition(.opacity)
            } else {
                List(selection: $selectedGoal) {
                    if !pendingGoals.isEmpty {
                        Section("To Do") {
                            ForEach(pendingGoals) { goal in
                                GoalRowView(goal: goal)
                                    .tag(goal)
                                    .draggable(goal.id.uuidString)
                            }
                            .onMove(perform: movePendingGoals)
                        }
                    }

                    if !completedGoals.isEmpty {
                        Section("Completed") {
                            ForEach(completedGoals) { goal in
                                GoalRowView(goal: goal)
                                    .tag(goal)
                            }
                        }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .transition(.opacity)
            }
        }
        .animation(.default, value: goals.isEmpty)
        .navigationTitle(category.displayName)
        .toolbar {
            // ToolbarItem(placement: .primaryAction) {
            //     Button(action: { showingNewGoalSheet = true }) {
            //         Label("Add Goal", systemImage: "plus")
            //     }
            // }
        }
        .sheet(isPresented: $showingNewGoalSheet) {
            GoalEditorSheet(category: category) { goal in
                modelContext.insert(goal)
                try? modelContext.save()
            }
        }
        .dropDestination(for: String.self) { items, location in
            handleDrop(items: items)
        }
    }

    private func movePendingGoals(from source: IndexSet, to destination: Int) {
        var reorderedGoals = pendingGoals
        reorderedGoals.move(fromOffsets: source, toOffset: destination)

        for (index, goal) in reorderedGoals.enumerated() {
            goal.sortOrder = index
        }
        try? modelContext.save()
    }

    private func handleDrop(items: [String]) -> Bool {
        guard let idString = items.first,
              let goalId = UUID(uuidString: idString),
              let goal = allGoals.first(where: { $0.id == goalId }) else {
            return false
        }

        goal.move(to: category)
        try? modelContext.save()
        return true
    }
}

#Preview {
    GoalListView(
        category: .daily,
        searchText: "",
        selectedGoal: .constant(nil)
    )
    .modelContainer(for: [Goal.self, Subtask.self, Tag.self], inMemory: true)
}
