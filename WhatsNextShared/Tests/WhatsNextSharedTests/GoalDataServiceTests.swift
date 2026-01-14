import XCTest
@testable import WhatsNextShared
import SwiftData

final class GoalDataServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var service: GoalDataService!
    
    override func setUp() {
        super.setUp()
        let schema = Schema([Goal.self, Subtask.self, Tag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = modelContainer.mainContext
        service = GoalDataService(modelContext: modelContext)
    }
    
    override func tearDown() {
        modelContainer = nil
        modelContext = nil
        service = nil
        super.tearDown()
    }
    
    func testFetchGoalsForCategory() throws {
        // Create test goals
        let dailyGoal = Goal(title: "Daily Task", category: .daily)
        let weeklyGoal = Goal(title: "Weekly Task", category: .weekly)
        modelContext.insert(dailyGoal)
        modelContext.insert(weeklyGoal)
        try modelContext.save()
        
        // Fetch daily goals
        let dailyGoals = try service.fetchGoals(category: .daily)
        XCTAssertEqual(dailyGoals.count, 1)
        XCTAssertEqual(dailyGoals.first?.title, "Daily Task")
        
        // Fetch weekly goals
        let weeklyGoals = try service.fetchGoals(category: .weekly)
        XCTAssertEqual(weeklyGoals.count, 1)
        XCTAssertEqual(weeklyGoals.first?.title, "Weekly Task")
    }
    
    func testFetchArchivedGoals() throws {
        let goal = Goal(title: "Test Goal", category: .daily)
        goal.status = .archived
        modelContext.insert(goal)
        try modelContext.save()
        
        let archivedGoals = try service.fetchArchivedGoals()
        XCTAssertEqual(archivedGoals.count, 1)
        XCTAssertEqual(archivedGoals.first?.title, "Test Goal")
    }
}
