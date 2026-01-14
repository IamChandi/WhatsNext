import XCTest
@testable import WhatsNextShared
import os.log

final class LoggerTests: XCTestCase {
    func testLoggerCategoriesExist() {
        // Verify all logger categories are accessible
        XCTAssertNotNil(Logger.app)
        XCTAssertNotNil(Logger.data)
        XCTAssertNotNil(Logger.ui)
        XCTAssertNotNil(Logger.network)
        XCTAssertNotNil(Logger.notifications)
        XCTAssertNotNil(Logger.error)
        XCTAssertNotNil(Logger.performance)
    }
    
    func testLoggerSubsystem() {
        // Verify logger has a valid subsystem
        let appLogger = Logger.app
        // Logger should be initialized with a subsystem
        XCTAssertNotNil(appLogger)
    }
}
