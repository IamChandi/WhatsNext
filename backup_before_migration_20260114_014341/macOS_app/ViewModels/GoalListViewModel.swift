import Foundation
import SwiftData
import Combine

/// ViewModel for GoalListView to manage data and business logic.
@MainActor
final class GoalListViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var pendingGoals: [Goal] = []
    @Published var completedGoals: [Goal] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let goalDataService: GoalDataService
    private let category: GoalCategory
    private var searchText: String = ""
    
    init(modelContext: ModelContext, category: GoalCategory) {
        self.modelContext = modelContext
        self.goalDataService = GoalDataService(modelContext: modelContext)
        self.category = category
    }
    
    /// Updates the goals list based on current category and search text.
    func updateGoals(searchText: String = "") {
        self.searchText = searchText
        isLoading = true
        
        do {
            let fetchedGoals = try goalDataService.fetchGoals(
                category: category,
                searchText: searchText,
                excludeArchived: true
            )
            
            self.goals = fetchedGoals
            self.pendingGoals = fetchedGoals.filter { !$0.isCompleted }
            self.completedGoals = fetchedGoals.filter { $0.isCompleted }
        } catch {
            Logger.view.error("Failed to fetch goals: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.dataFetchFailed(error), context: "GoalListViewModel.updateGoals")
            self.goals = []
            self.pendingGoals = []
            self.completedGoals = []
        }
        
        isLoading = false
    }
    
    /// Moves goals within the pending section.
    func movePendingGoals(from source: IndexSet, to destination: Int) {
        var reordered = pendingGoals
        reordered.move(fromOffsets: source, toOffset: destination)
        
        // Update sortOrder for moved goals
        for (index, goal) in reordered.enumerated() {
            goal.sortOrder = index
        }
        
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalListViewModel.movePendingGoals")
        } else {
            updateGoals(searchText: searchText)
        }
    }
}
