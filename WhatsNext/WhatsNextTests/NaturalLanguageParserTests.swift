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
}
