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
}
