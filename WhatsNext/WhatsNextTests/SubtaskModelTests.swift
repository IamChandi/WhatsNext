import XCTest
@testable import WhatsNext

final class SubtaskModelTests: XCTestCase {
    
    func testSubtaskInitialization() {
        let subtask = Subtask(title: "Test Subtask", sortOrder: 5)
        
        XCTAssertEqual(subtask.title, "Test Subtask")
        XCTAssertEqual(subtask.sortOrder, 5)
        XCTAssertFalse(subtask.isCompleted)
        XCTAssertNotNil(subtask.id)
        XCTAssertNil(subtask.goal)
    }
    
    func testSubtaskDefaultSortOrder() {
        let subtask = Subtask(title: "Test Subtask")
        XCTAssertEqual(subtask.sortOrder, 0)
    }
    
    func testSubtaskToggle() {
        let subtask = Subtask(title: "Test Subtask")
        XCTAssertFalse(subtask.isCompleted)
        
        subtask.toggle()
        XCTAssertTrue(subtask.isCompleted)
        
        subtask.toggle()
        XCTAssertFalse(subtask.isCompleted)
    }
    
    func testSubtaskToggleUpdatesGoal() {
        let goal = Goal(title: "Parent Goal")
        let subtask = Subtask(title: "Test Subtask")
        subtask.goal = goal
        
        let originalUpdatedAt = goal.updatedAt
        Thread.sleep(forTimeInterval: 0.01)
        
        subtask.toggle()
        
        XCTAssertGreaterThan(goal.updatedAt, originalUpdatedAt)
    }
    
    func testSubtaskToggleWithoutGoal() {
        let subtask = Subtask(title: "Test Subtask")
        // Should not crash when toggling without a goal
        subtask.toggle()
        XCTAssertTrue(subtask.isCompleted)
    }
}
