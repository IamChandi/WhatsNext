import XCTest
@testable import WhatsNext

final class NaturalLanguageParserTests: XCTestCase {
    
    func testParseBasicTitle() {
        let input = "Buy milk"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Buy milk")
        XCTAssertEqual(config.priority, .medium)
        XCTAssertNil(config.dueDate)
    }
    
    func testParseHighPriority() {
        let highInputs = ["!high Fix bug", "Fix bug !high", "Fix bug !h"]
        for input in highInputs {
            let config = NaturalLanguageParser.parse(input)
            XCTAssertEqual(config.title, "Fix bug")
            XCTAssertEqual(config.priority, .high)
        }
    }
    
    func testParseLowPriority() {
        let lowInputs = ["!low Clean desk", "Clean desk !l"]
        for input in lowInputs {
            let config = NaturalLanguageParser.parse(input)
            XCTAssertEqual(config.title, "Clean desk")
            XCTAssertEqual(config.priority, .low)
        }
    }
    
    func testParseTomorrow() {
        let input = "Meeting tomorrow"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Meeting")
        XCTAssertNotNil(config.dueDate)
        
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
        XCTAssertEqual(calendar.startOfDay(for: config.dueDate!), tomorrow)
    }
    
    func testParseCombined() {
        let input = "!high Important meeting tomorrow"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Important meeting")
        XCTAssertEqual(config.priority, .high)
        XCTAssertNotNil(config.dueDate)
    }
    
    func testCleanWhitespace() {
        let input = "  Buy   milk  !high  "
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Buy milk")
        XCTAssertEqual(config.priority, .high)
    }
    
    func testParseMultipleWhitespace() {
        let input = "Buy    milk    today"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Buy milk today")
    }
    
    func testParseEmptyString() {
        let input = ""
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "")
        XCTAssertEqual(config.priority, .medium)
        XCTAssertNil(config.dueDate)
    }
    
    func testParseOnlyPriority() {
        let input = "!high"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "")
        XCTAssertEqual(config.priority, .high)
    }
    
    func testParseOnlyTomorrow() {
        let input = "tomorrow"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "")
        XCTAssertNotNil(config.dueDate)
    }
    
    func testParseCaseInsensitivePriority() {
        let highInputs = ["!HIGH", "!High", "!HIGH Fix bug"]
        for input in highInputs {
            let config = NaturalLanguageParser.parse(input)
            XCTAssertEqual(config.priority, .high, "Failed for input: \(input)")
        }
    }
    
    func testParseCaseInsensitiveTomorrow() {
        let inputs = ["Meeting TOMORROW", "Meeting Tomorrow", "Meeting TOMORROW"]
        for input in inputs {
            let config = NaturalLanguageParser.parse(input)
            XCTAssertNotNil(config.dueDate, "Failed for input: \(input)")
            XCTAssertEqual(config.title, "Meeting")
        }
    }
    
    func testParsePriorityInMiddle() {
        let input = "Fix !high bug"
        let config = NaturalLanguageParser.parse(input)
        XCTAssertEqual(config.title, "Fix bug")
        XCTAssertEqual(config.priority, .high)
    }
    
    func testParseMultiplePriorityMarkers() {
        let input = "!high !high Important task"
        let config = NaturalLanguageParser.parse(input)
        // Should still parse correctly even with duplicates
        XCTAssertEqual(config.priority, .high)
    }
}
