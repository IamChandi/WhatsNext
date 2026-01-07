import XCTest
@testable import WhatsNext

final class GoalModelTests: XCTestCase {
    
    func testGoalCompletionToggle() {
        let goal = Goal(title: "Test Goal")
        XCTAssertEqual(goal.status, .pending)
        XCTAssertNil(goal.completedAt)
        
        goal.toggleCompletion()
        XCTAssertEqual(goal.status, .completed)
        XCTAssertNotNil(goal.completedAt)
        
        goal.toggleCompletion()
        XCTAssertEqual(goal.status, .pending)
        XCTAssertNil(goal.completedAt)
    }
    
    func testCompletionPercentageWithSubtasks() {
        let goal = Goal(title: "Parent Goal")
        let sub1 = Subtask(title: "S1")
        let sub2 = Subtask(title: "S2")
        goal.subtasks = [sub1, sub2]
        
        XCTAssertEqual(goal.completionPercentage, 0.0)
        
        sub1.isCompleted = true
        XCTAssertEqual(goal.completionPercentage, 0.5)
        
        sub2.isCompleted = true
        XCTAssertEqual(goal.completionPercentage, 1.0)
    }
    
    func testCompletionPercentageWithoutSubtasks() {
        let goal = Goal(title: "Simple Goal")
        XCTAssertEqual(goal.completionPercentage, 0.0)
        
        goal.toggleCompletion()
        XCTAssertEqual(goal.completionPercentage, 1.0)
    }
    
    func testOverdueStatus() {
        let calendar = Calendar.current
        let pastDate = calendar.date(byAdding: .day, value: -1, to: Date())
        let futureDate = calendar.date(byAdding: .day, value: 1, to: Date())
        
        let overdueGoal = Goal(title: "Overdue", dueDate: pastDate)
        XCTAssertTrue(overdueGoal.isOverdue)
        
        let upcomingGoal = Goal(title: "Upcoming", dueDate: futureDate)
        XCTAssertFalse(upcomingGoal.isOverdue)
        
        overdueGoal.toggleCompletion()
        XCTAssertFalse(overdueGoal.isOverdue, "Completed goals should not be overdue")
    }
    
    func testArchiveUnarchive() {
        let goal = Goal(title: "Test Goal")
        goal.archive()
        XCTAssertEqual(goal.status, .archived)
        
        goal.unarchive()
        XCTAssertEqual(goal.status, .pending)
        
        goal.toggleCompletion()
        goal.archive()
        XCTAssertEqual(goal.status, .archived)
        
        goal.unarchive()
        XCTAssertEqual(goal.status, .completed)
    }
    
    func testMoveToCategory() {
        let goal = Goal(title: "Test Goal", category: .daily)
        XCTAssertEqual(goal.category, .daily)
        
        let originalUpdatedAt = goal.updatedAt
        Thread.sleep(forTimeInterval: 0.01) // Small delay to ensure updatedAt changes
        
        goal.move(to: .weekly)
        XCTAssertEqual(goal.category, .weekly)
        XCTAssertGreaterThan(goal.updatedAt, originalUpdatedAt)
    }
    
    func testSortedSubtasks() {
        let goal = Goal(title: "Test Goal")
        let sub1 = Subtask(title: "First", sortOrder: 1)
        let sub2 = Subtask(title: "Second", sortOrder: 2)
        let sub3 = Subtask(title: "Third", sortOrder: 0)
        
        goal.subtasks = [sub1, sub2, sub3]
        
        let sorted = goal.sortedSubtasks
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].title, "Third")
        XCTAssertEqual(sorted[1].title, "First")
        XCTAssertEqual(sorted[2].title, "Second")
    }
    
    func testSortedAlerts() {
        let goal = Goal(title: "Test Goal")
        let calendar = Calendar.current
        let now = Date()
        
        let alert1 = GoalAlert(scheduledDate: calendar.date(byAdding: .hour, value: 2, to: now)!)
        let alert2 = GoalAlert(scheduledDate: calendar.date(byAdding: .hour, value: 1, to: now)!)
        let alert3 = GoalAlert(scheduledDate: calendar.date(byAdding: .hour, value: 3, to: now)!)
        
        goal.alerts = [alert1, alert2, alert3]
        
        let sorted = goal.sortedAlerts
        XCTAssertEqual(sorted.count, 3)
        XCTAssertEqual(sorted[0].scheduledDate, alert2.scheduledDate)
        XCTAssertEqual(sorted[1].scheduledDate, alert1.scheduledDate)
        XCTAssertEqual(sorted[2].scheduledDate, alert3.scheduledDate)
    }
    
    func testIsCompleted() {
        let goal = Goal(title: "Test Goal")
        XCTAssertFalse(goal.isCompleted)
        XCTAssertEqual(goal.status, .pending)
        
        goal.toggleCompletion()
        XCTAssertTrue(goal.isCompleted)
        XCTAssertEqual(goal.status, .completed)
    }
    
    func testInitialization() {
        let goal = Goal(
            title: "Test Goal",
            goalDescription: "Test Description",
            category: .weekly,
            priority: .high,
            dueDate: Date(),
            sortOrder: 5
        )
        
        XCTAssertEqual(goal.title, "Test Goal")
        XCTAssertEqual(goal.goalDescription, "Test Description")
        XCTAssertEqual(goal.category, .weekly)
        XCTAssertEqual(goal.priority, .high)
        XCTAssertNotNil(goal.dueDate)
        XCTAssertEqual(goal.sortOrder, 5)
        XCTAssertEqual(goal.status, .pending)
        XCTAssertFalse(goal.isFocused)
        XCTAssertNotNil(goal.id)
    }
    
    func testUpdatedAtOnToggle() {
        let goal = Goal(title: "Test Goal")
        let originalUpdatedAt = goal.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        
        goal.toggleCompletion()
        XCTAssertGreaterThan(goal.updatedAt, originalUpdatedAt)
    }
    
    func testOverdueWithNoDueDate() {
        let goal = Goal(title: "Test Goal", dueDate: nil)
        XCTAssertFalse(goal.isOverdue)
    }
    
    func testOverdueWithFutureDueDate() {
        let calendar = Calendar.current
        let futureDate = calendar.date(byAdding: .day, value: 1, to: Date())!
        let goal = Goal(title: "Test Goal", dueDate: futureDate)
        XCTAssertFalse(goal.isOverdue)
    }
}
