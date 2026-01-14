import XCTest
@testable import WhatsNextShared

final class ConstantsTests: XCTestCase {
    func testAnimationConstants() {
        XCTAssertGreaterThan(AppConstants.Animation.quick, 0)
        XCTAssertGreaterThan(AppConstants.Animation.standard, 0)
        XCTAssertGreaterThan(AppConstants.Animation.slow, 0)
        XCTAssertLessThan(AppConstants.Animation.quick, AppConstants.Animation.standard)
        XCTAssertLessThan(AppConstants.Animation.standard, AppConstants.Animation.slow)
    }
    
    func testNotificationConstants() {
        XCTAssertGreaterThanOrEqual(AppConstants.Notifications.morningHour, 0)
        XCTAssertLessThanOrEqual(AppConstants.Notifications.morningHour, 23)
        XCTAssertGreaterThanOrEqual(AppConstants.Notifications.eveningHour, 0)
        XCTAssertLessThanOrEqual(AppConstants.Notifications.eveningHour, 23)
        XCTAssertGreaterThan(AppConstants.Notifications.snoozeMinutes, 0)
    }
    
    func testDataConstants() {
        XCTAssertGreaterThan(AppConstants.Data.maxNoteSize, 0)
        XCTAssertGreaterThan(AppConstants.Data.maxStreakDays, 0)
    }
}
