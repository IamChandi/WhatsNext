import Foundation
import SwiftData
import SwiftUI

/// ViewModel for managing goal list state and business logic.
/// Separates data processing from view concerns.
@MainActor
@Observable
final class GoalListViewModel {
    private let dataService: GoalDataService
    
    var goals: [Goal] = []
    var isLoading = false
    var errorMessage: String?
    
    var pendingGoals: [Goal] {
        goals.filter { !$0.isCompleted }
            .sorted(by: sortGoals)
    }
    
    var completedGoals: [Goal] {
        goals.filter { $0.isCompleted }
            .sorted(by: sortGoals)
    }
    
    init(dataService: GoalDataService) {
        self.dataService = dataService
    }
    
    /// Loads goals for the specified category with optional search filtering.
    func loadGoals(category: GoalCategory, searchText: String = "") {
        isLoading = true
        errorMessage = nil
        
        do {
            goals = try dataService.fetchGoals(
                category: category,
                searchText: searchText,
                excludeArchived: true
            )
            // Apply in-memory sorting for completion status priority
            goals = goals.sorted(by: sortGoals)
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
            goals = []
        }
        
        isLoading = false
    }
    
    /// Sorts goals with completed goals at the bottom, then by priority and sort order.
    private func sortGoals(_ lhs: Goal, _ rhs: Goal) -> Bool {
        // Incomplete goals first
        if lhs.isCompleted != rhs.isCompleted {
            return !lhs.isCompleted
        }
        // Higher priority first
        if lhs.priority.sortOrder != rhs.priority.sortOrder {
            return lhs.priority.sortOrder < rhs.priority.sortOrder
        }
        // Custom sort order
        return lhs.sortOrder < rhs.sortOrder
    }
    
    /// Moves goals within the pending list (for drag and drop).
    func movePendingGoals(from source: IndexSet, to destination: Int) throws {
        var reorderedGoals = pendingGoals
        reorderedGoals.move(fromOffsets: source, toOffset: destination)
        
        for (index, goal) in reorderedGoals.enumerated() {
            goal.sortOrder = index
        }
        
        try dataService.save()
        // Reload to reflect changes
        loadGoals(category: reorderedGoals.first?.category ?? .daily)
    }
    
    /// Handles dropping a goal into a category.
    func handleDrop(goalId: UUID, to category: GoalCategory) throws {
        // Find the goal in current goals or fetch it
        guard let goal = goals.first(where: { $0.id == goalId }) else {
            throw GoalDataError.goalNotFound
        }
        
        goal.move(to: category)
        try dataService.save()
        
        // Reload goals
        loadGoals(category: category)
    }
}

/// Errors that can occur during goal data operations.
enum GoalDataError: LocalizedError {
    case goalNotFound
    case saveFailed(Error)
    case fetchFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .goalNotFound:
            return "Goal not found"
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch goals: \(error.localizedDescription)"
        }
    }
}
