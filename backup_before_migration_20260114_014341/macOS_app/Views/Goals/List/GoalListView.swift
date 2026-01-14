import SwiftUI
import SwiftData

struct GoalListView: View {
    @Environment(\.modelContext) private var modelContext
    let category: GoalCategory
    let searchText: String
    @Binding var selectedGoal: Goal?

    // Use database-level filtering with predicates for optimal performance
    // Note: @Query predicates can't be dynamic, so we filter searchText in computed property
    @Query(
        filter: #Predicate<Goal> { goal in
            goal.statusRaw != "archived"
        },
        sort: [
            SortDescriptor(\.statusRaw),
            SortDescriptor(\.priorityRaw),
            SortDescriptor(\.sortOrder)
        ]
    ) private var allGoals: [Goal]
    
    @State private var dataService: GoalDataService?
    @State private var showingNewGoalSheet = false
    @State private var draggedGoal: Goal?

    // Filter by category and search text (category filter at DB level via separate query would be better)
    // For now, we filter category in memory but this is still better than filtering everything
    private var goals: [Goal] {
        allGoals
            .filter { $0.category == category }
            .filter { searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText) }
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
                if !modelContext.saveWithErrorHandling() {
                    ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalListView.saveGoal")
                }
            }
        }
        .onAppear {
            dataService = GoalDataService(modelContext: modelContext)
        }
        .withErrorHandling()
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
        
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalListView.movePendingGoals")
        }
    }

    private func handleDrop(items: [String]) -> Bool {
        guard let idString = items.first,
              let goalId = UUID(uuidString: idString),
              let goal = goals.first(where: { $0.id == goalId }) else {
            return false
        }

        goal.move(to: category)
        
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalListView.handleDrop")
        }
        
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
