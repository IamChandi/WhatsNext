import Foundation
import SwiftData
import SwiftUI

/// ViewModel for managing Kanban board state and business logic.
/// Optimizes data loading by fetching all goals once and grouping by category.
@MainActor
@Observable
final class KanbanViewModel {
    private let dataService: GoalDataService
    
    var allGoals: [Goal] = []
    var isLoading = false
    var errorMessage: String?
    
    /// Goals grouped by category for efficient Kanban column rendering.
    var goalsByCategory: [GoalCategory: [Goal]] {
        Dictionary(grouping: allGoals) { $0.category }
            .mapValues { goals in
                goals.sorted(by: sortGoals)
            }
    }
    
    init(dataService: GoalDataService) {
        self.dataService = dataService
    }
    
    /// Loads all goals for the Kanban board with optional search filtering.
    func loadAllGoals(searchText: String = "") {
        isLoading = true
        errorMessage = nil
        
        do {
            allGoals = try dataService.fetchAllGoals(
                excludeArchived: true,
                searchText: searchText
            )
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
            allGoals = []
        }
        
        isLoading = false
    }
    
    /// Gets goals for a specific category.
    func goalsFor(category: GoalCategory) -> [Goal] {
        goalsByCategory[category] ?? []
    }
    
    /// Moves a goal to a different category.
    func moveGoal(_ goal: Goal, to category: GoalCategory) throws {
        goal.move(to: category)
        try dataService.save()
        
        // Reload to reflect changes
        loadAllGoals()
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
}
