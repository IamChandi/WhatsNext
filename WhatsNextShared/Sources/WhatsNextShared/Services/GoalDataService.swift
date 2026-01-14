//
//  GoalDataService.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData

/// Service for efficient data access and querying of goals.
/// Provides optimized queries with predicates to filter at the database level.
@MainActor
public final class GoalDataService {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Fetches goals for a specific category with optional search text.
    /// Uses database-level filtering for optimal performance.
    /// - Parameters:
    ///   - category: The category to filter by
    ///   - searchText: Optional search text to filter by title
    ///   - excludeArchived: Whether to exclude archived goals
    ///   - limit: Maximum number of goals to fetch (nil for no limit)
    ///   - offset: Number of goals to skip (for pagination)
    /// - Returns: Array of goals matching the criteria
    public func fetchGoals(
        category: GoalCategory,
        searchText: String = "",
        excludeArchived: Bool = true,
        limit: Int? = nil,
        offset: Int = 0
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
        
        var descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.statusRaw),
                SortDescriptor(\.priorityRaw),
                SortDescriptor(\.sortOrder)
            ]
        )
        
        // Apply pagination if specified
        if let limit = limit {
            descriptor.fetchLimit = limit
            descriptor.fetchOffset = offset
        }
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches all goals across all categories (for Kanban board).
    /// More efficient than multiple category queries when displaying all categories.
    /// - Parameters:
    ///   - excludeArchived: Whether to exclude archived goals
    ///   - searchText: Optional search text to filter by title
    ///   - limit: Maximum number of goals to fetch (nil for no limit)
    ///   - offset: Number of goals to skip (for pagination)
    /// - Returns: Array of goals matching the criteria
    public func fetchAllGoals(
        excludeArchived: Bool = true,
        searchText: String = "",
        limit: Int? = nil,
        offset: Int = 0
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
        
        var descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.categoryRaw),
                SortDescriptor(\.statusRaw),
                SortDescriptor(\.priorityRaw),
                SortDescriptor(\.sortOrder)
            ]
        )
        
        // Apply pagination if specified
        if let limit = limit {
            descriptor.fetchLimit = limit
            descriptor.fetchOffset = offset
        }
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches goals for briefing view (Daily + High Priority Weekly).
    public func fetchBriefingGoals() throws -> [Goal] {
        let predicate = #Predicate<Goal> { goal in
            goal.statusRaw != "archived" &&
            goal.statusRaw != "completed" &&
            (goal.categoryRaw == "daily" || (goal.categoryRaw == "weekly" && goal.priorityRaw == "high"))
        }
        
        let descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [
                SortDescriptor(\.categoryRaw),
                SortDescriptor(\.createdAt)
            ]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetches archived goals.
    /// - Parameters:
    ///   - searchText: Optional search text to filter by title
    ///   - limit: Maximum number of goals to fetch (nil for no limit)
    ///   - offset: Number of goals to skip (for pagination)
    /// - Returns: Array of archived goals matching the criteria
    public func fetchArchivedGoals(
        searchText: String = "",
        limit: Int? = nil,
        offset: Int = 0
    ) throws -> [Goal] {
        var predicate: Predicate<Goal>?
        
        if searchText.isEmpty {
            predicate = #Predicate<Goal> { goal in
                goal.statusRaw == "archived"
            }
        } else {
            predicate = #Predicate<Goal> { goal in
                goal.statusRaw == "archived" &&
                goal.title.localizedStandardContains(searchText)
            }
        }
        
        var descriptor = FetchDescriptor<Goal>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        // Apply pagination if specified
        if let limit = limit {
            descriptor.fetchLimit = limit
            descriptor.fetchOffset = offset
        }
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Counts the total number of goals matching the criteria (for pagination).
    /// - Parameters:
    ///   - category: The category to filter by (nil for all categories)
    ///   - searchText: Optional search text to filter by title
    ///   - excludeArchived: Whether to exclude archived goals
    /// - Returns: Total count of matching goals
    public func countGoals(
        category: GoalCategory? = nil,
        searchText: String = "",
        excludeArchived: Bool = true
    ) throws -> Int {
        var predicate: Predicate<Goal>?
        
        var conditions: [String] = []
        if let category = category {
            conditions.append("categoryRaw == '\(category.rawValue)'")
        }
        if excludeArchived {
            conditions.append("statusRaw != 'archived'")
        }
        if !searchText.isEmpty {
            // Note: Count queries with text search are approximate
            // For exact counts with search, fetch all and count
            if conditions.isEmpty {
                predicate = #Predicate<Goal> { goal in
                    goal.title.localizedStandardContains(searchText)
                }
            } else {
                // Build predicate based on conditions
                if let category = category {
                    if excludeArchived {
                        predicate = #Predicate<Goal> { goal in
                            goal.categoryRaw == category.rawValue &&
                            goal.statusRaw != "archived" &&
                            goal.title.localizedStandardContains(searchText)
                        }
                    } else {
                        predicate = #Predicate<Goal> { goal in
                            goal.categoryRaw == category.rawValue &&
                            goal.title.localizedStandardContains(searchText)
                        }
                    }
                } else if excludeArchived {
                    predicate = #Predicate<Goal> { goal in
                        goal.statusRaw != "archived" &&
                        goal.title.localizedStandardContains(searchText)
                    }
                }
            }
        } else {
            if let category = category {
                if excludeArchived {
                    predicate = #Predicate<Goal> { goal in
                        goal.categoryRaw == category.rawValue &&
                        goal.statusRaw != "archived"
                    }
                } else {
                    predicate = #Predicate<Goal> { goal in
                        goal.categoryRaw == category.rawValue
                    }
                }
            } else if excludeArchived {
                predicate = #Predicate<Goal> { goal in
                    goal.statusRaw != "archived"
                }
            }
        }
        
        let descriptor = FetchDescriptor<Goal>(predicate: predicate)
        return try modelContext.fetchCount(descriptor)
    }
    
    /// Saves changes to the model context with proper error handling.
    public func save() throws {
        try modelContext.save()
    }
    
    /// Deletes a goal from the context.
    public func delete(_ goal: Goal) throws {
        modelContext.delete(goal)
        try modelContext.save()
    }
    
    /// Inserts a new goal into the context.
    public func insert(_ goal: Goal) throws {
        modelContext.insert(goal)
        try modelContext.save()
    }
}
