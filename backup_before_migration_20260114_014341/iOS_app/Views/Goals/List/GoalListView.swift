import SwiftUI
import SwiftData

struct GoalListView: View {
    @Environment(\.modelContext) private var modelContext
    let category: GoalCategory
    let searchText: String
    @Binding var selectedGoal: Goal?

    @State private var viewModel: GoalListViewModel?
    @State private var showingNewGoalSheet = false
    @State private var draggedGoal: Goal?

    private var pendingGoals: [Goal] {
        viewModel?.pendingGoals ?? []
    }

    private var completedGoals: [Goal] {
        viewModel?.completedGoals ?? []
    }
    
    private var goals: [Goal] {
        viewModel?.goals ?? []
    }

    var body: some View {
        ZStack {
            if viewModel?.isLoading == true {
                ProgressView()
            } else if goals.isEmpty {
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
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
                .refreshable {
                    // Pull to refresh - reload goals to sync with CloudKit
                    viewModel?.loadGoals(category: category, searchText: searchText)
                }
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
                do {
                    try modelContext.save()
                    // Reload view model after adding goal
                    viewModel?.loadGoals(category: category, searchText: searchText)
                } catch {
                    print("Failed to save new goal: \(error.localizedDescription)")
                }
            }
        }
        .dropDestination(for: String.self) { items, location in
            _ = handleDrop(items: items)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = GoalListViewModel(dataService: GoalDataService(modelContext: modelContext))
            }
            viewModel?.loadGoals(category: category, searchText: searchText)
        }
        .onChange(of: category) { _, _ in
            viewModel?.loadGoals(category: category, searchText: searchText)
        }
        .onChange(of: searchText) { _, newValue in
            viewModel?.loadGoals(category: category, searchText: newValue)
        }
    }

    private func movePendingGoals(from source: IndexSet, to destination: Int) {
        do {
            try viewModel?.movePendingGoals(from: source, to: destination)
        } catch {
            print("Failed to reorder goals: \(error.localizedDescription)")
        }
    }

    private func handleDrop(items: [String]) -> Bool {
        guard let idString = items.first,
              let goalId = UUID(uuidString: idString) else {
            return false
        }

        do {
            try viewModel?.handleDrop(goalId: goalId, to: category)
            return true
        } catch {
            print("Failed to move goal: \(error.localizedDescription)")
            return false
        }
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
