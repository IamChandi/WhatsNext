//
//  PerformanceTests.swift
//  WhatsNextSharedTests
//
//  Performance tests for query operations and data processing.
//

import XCTest
import SwiftData
@testable import WhatsNextShared

@MainActor
final class PerformanceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var dataService: GoalDataService!
    
    override func setUp() async throws {
        let schema = Schema([
            Goal.self,
            Subtask.self,
            Tag.self,
            GoalAlert.self,
            RecurrenceRule.self,
            HistoryEntry.self,
            Note.self
        ])
        
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = modelContainer.mainContext
        dataService = GoalDataService(modelContext: modelContext)
    }
    
    override func tearDown() async throws {
        modelContainer = nil
        modelContext = nil
        dataService = nil
    }
    
    /// Performance test for fetching goals with pagination.
    func testFetchGoalsWithPaginationPerformance() throws {
        // Create test data
        let goalCount = 1000
        for i in 0..<goalCount {
            let goal = Goal()
            goal.title = "Test Goal \(i)"
            goal.category = i % 2 == 0 ? .daily : .weekly
            goal.priority = Priority.allCases[i % Priority.allCases.count]
            modelContext.insert(goal)
        }
        try modelContext.save()
        
        // Measure pagination performance
        measure {
            for page in 0..<10 {
                let limit = 50
                let offset = page * limit
                _ = try? dataService.fetchGoals(
                    category: .daily,
                    limit: limit,
                    offset: offset
                )
            }
        }
    }
    
    /// Performance test for database-level filtering vs in-memory filtering.
    func testDatabaseFilteringPerformance() throws {
        // Create test data
        let goalCount = 500
        for i in 0..<goalCount {
            let goal = Goal()
            goal.title = "Test Goal \(i)"
            goal.category = i % 4 == 0 ? .daily : (i % 4 == 1 ? .weekly : .monthly)
            goal.status = i % 3 == 0 ? .completed : .pending
            modelContext.insert(goal)
        }
        try modelContext.save()
        
        // Measure database-level filtering
        var dbTime: TimeInterval = 0
        measure {
            let start = Date()
            _ = try? dataService.fetchGoals(category: .daily, excludeArchived: true)
            dbTime = Date().timeIntervalSince(start)
        }
        
        // Verify it's reasonably fast (< 100ms for 500 items)
        XCTAssertLessThan(dbTime, 0.1, "Database filtering should be fast")
    }
    
    /// Performance test for counting goals.
    func testCountGoalsPerformance() throws {
        // Create test data
        let goalCount = 1000
        for i in 0..<goalCount {
            let goal = Goal()
            goal.title = "Test Goal \(i)"
            goal.category = .daily
            modelContext.insert(goal)
        }
        try modelContext.save()
        
        // Measure counting performance
        measure {
            _ = try? dataService.countGoals(category: .daily)
        }
    }
    
    /// Performance test for search operations.
    func testSearchPerformance() throws {
        // Create test data with varied titles
        let goalCount = 500
        for i in 0..<goalCount {
            let goal = Goal()
            goal.title = "Goal \(i) with searchable text \(i % 10)"
            goal.category = .daily
            modelContext.insert(goal)
        }
        try modelContext.save()
        
        // Measure search performance
        measure {
            _ = try? dataService.fetchGoals(category: .daily, searchText: "searchable")
        }
    }
    
    /// Performance test for large note content validation.
    func testNoteValidationPerformance() throws {
        // Create large attributed string
        let largeText = String(repeating: "Test content ", count: 100_000)
        let attributedString = NSAttributedString(string: largeText)
        
        // Measure validation performance
        measure {
            let data = try? NSKeyedArchiver.archivedData(
                withRootObject: attributedString,
                requiringSecureCoding: false
            )
            if let data = data {
                _ = InputValidator.validateNoteSize(data)
            }
        }
    }
    
    /// Performance test for title validation.
    func testTitleValidationPerformance() throws {
        let titles = (0..<1000).map { "Test Goal Title \($0)" }
        
        measure {
            for title in titles {
                _ = InputValidator.validateTitle(title)
            }
        }
    }
}
