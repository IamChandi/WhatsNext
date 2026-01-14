import Foundation
import SwiftData

/// Service for efficient data access and querying of goals.
/// Provides optimized queries with predicates to filter at the database level.
@MainActor
final class GoalDataService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Fetches goals for a specific category with optional search text.
    /// Uses database-level filtering for optimal performance.
    func fetchGoals(
        category: GoalCategory,
        searchText: String = "",
        excludeArchived: Bool = true
    ) throws -> [Goal] {
        var predicate: Predicate<Goal>?
        
        if excludeArchived {
            if searchText.isEmpty {
                predicate = #Predicate<Goal> { goal in
                    goal.categoryRaw == category.rawValue &&
                    goal.statusRaw != "archived"
                }
            } else {
                predicate = #Predicate<Goal> { goal in
                    goal.categoryRaw == category.rawValue &&
                    goal.statusRaw != "archived" &&
                    goal.title.localizedStandardContains(searchText)
                }
            }
        } else {
            if searchText.isEmpty {
                predicate = #Predicate<Goal> { goal in
                    goal.categoryRaw == category.rawValue
                }
            } else {
                predicate = #Predicate<Goal> { goal in
                    goal.categoryRaw == category.rawValue &&
                    goal.title.localizedStandardContains(searchText)
                }
            }
        }
        
        let descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.statusRaw),
                SortDescriptor(\.priorityRaw),
                SortDescriptor(\.sortOrder)
            ]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches all goals across all categories (for Kanban board).
    /// More efficient than multiple category queries when displaying all categories.
    func fetchAllGoals(
        excludeArchived: Bool = true,
        searchText: String = ""
    ) throws -> [Goal] {
        var predicate: Predicate<Goal>?
        
        if excludeArchived {
            if searchText.isEmpty {
                predicate = #Predicate<Goal> { goal in
                    goal.statusRaw != "archived"
                }
            } else {
                predicate = #Predicate<Goal> { goal in
                    goal.statusRaw != "archived" &&
                    goal.title.localizedStandardContains(searchText)
                }
            }
        } else {
            if searchText.isEmpty {
                // No predicate needed - fetch all
                predicate = nil
            } else {
                predicate = #Predicate<Goal> { goal in
                    goal.title.localizedStandardContains(searchText)
                }
            }
        }
        
        let descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.categoryRaw),
                SortDescriptor(\.statusRaw),
                SortDescriptor(\.priorityRaw),
                SortDescriptor(\.sortOrder)
            ]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Saves changes to the model context with proper error handling.
    func save() throws {
        try modelContext.save()
    }
    
    /// Deletes a goal from the context.
    func delete(_ goal: Goal) throws {
        modelContext.delete(goal)
        try modelContext.save()
    }
    
    /// Inserts a new goal into the context.
    func insert(_ goal: Goal) throws {
        modelContext.insert(goal)
        try modelContext.save()
    }
}
