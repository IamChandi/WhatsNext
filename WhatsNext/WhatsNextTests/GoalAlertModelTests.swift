import XCTest
@testable import WhatsNext

final class GoalAlertModelTests: XCTestCase {
    
    func testGoalAlertInitialization() {
        let date = Date()
        let alert = GoalAlert(scheduledDate: date, message: "Test message")
        
        XCTAssertEqual(alert.scheduledDate, date)
        XCTAssertEqual(alert.message, "Test message")
        XCTAssertFalse(alert.isTriggered)
        XCTAssertNil(alert.notificationIdentifier)
        XCTAssertNil(alert.goal)
        XCTAssertNotNil(alert.id)
    }
    
    func testGoalAlertInitializationWithoutMessage() {
        let date = Date()
        let alert = GoalAlert(scheduledDate: date)
        
        XCTAssertEqual(alert.scheduledDate, date)
        XCTAssertNil(alert.message)
    }
    
    func testIsPast() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let alert = GoalAlert(scheduledDate: pastDate)
        
        XCTAssertTrue(alert.isPast)
    }
    
    func testIsNotPast() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let alert = GoalAlert(scheduledDate: futureDate)
        
        XCTAssertFalse(alert.isPast)
    }
    
    func testIsUpcoming() {
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let alert = GoalAlert(scheduledDate: futureDate)
        
        XCTAssertTrue(alert.isUpcoming)
        XCTAssertFalse(alert.isPast)
        XCTAssertFalse(alert.isTriggered)
    }
    
    func testIsNotUpcomingWhenPast() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let alert = GoalAlert(scheduledDate: pastDate)
        
        XCTAssertFalse(alert.isUpcoming)
    }
    
    func testIsNotUpcomingWhenTriggered() {
        let futureDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let alert = GoalAlert(scheduledDate: futureDate)
        alert.isTriggered = true
        
        XCTAssertFalse(alert.isUpcoming)
    }
}
