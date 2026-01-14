import XCTest
@testable import WhatsNextShared
import Combine

final class SearchDebouncerTests: XCTestCase {
    func testDebouncing() {
        let expectation = XCTestExpectation(description: "Debounced action called")
        let debouncer = SearchDebouncer(delay: 0.1)
        var callCount = 0
        
        // Call debounce multiple times quickly
        debouncer.debounce {
            callCount += 1
            expectation.fulfill()
        }
        
        debouncer.debounce {
            callCount += 1
            expectation.fulfill()
        }
        
        debouncer.debounce {
            callCount += 1
            expectation.fulfill()
        }
        
        // Should only execute once after delay
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(callCount, 1, "Debouncer should only execute the last action once")
    }
    
    func testCancel() {
        let debouncer = SearchDebouncer(delay: 0.1)
        var wasCalled = false
        
        debouncer.debounce {
            wasCalled = true
        }
        
        debouncer.cancel()
        
        // Wait longer than delay
        Thread.sleep(forTimeInterval: 0.2)
        
        XCTAssertFalse(wasCalled, "Cancelled debouncer should not execute action")
    }
}
