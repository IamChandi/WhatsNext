import XCTest
@testable import WhatsNext

final class RecurrenceRuleModelTests: XCTestCase {
    
    func testRecurrenceRuleInitialization() {
        let rule = RecurrenceRule(
            pattern: .daily,
            interval: 2,
            daysOfWeek: [1, 3, 5],
            dayOfMonth: 15,
            endDate: Date()
        )
        
        XCTAssertEqual(rule.pattern, .daily)
        XCTAssertEqual(rule.interval, 2)
        XCTAssertEqual(rule.daysOfWeek, [1, 3, 5])
        XCTAssertEqual(rule.dayOfMonth, 15)
        XCTAssertNotNil(rule.endDate)
        XCTAssertNotNil(rule.id)
    }
    
    func testRecurrenceRuleDefaultValues() {
        let rule = RecurrenceRule(pattern: .weekly)
        
        XCTAssertEqual(rule.pattern, .weekly)
        XCTAssertEqual(rule.interval, 1)
        XCTAssertNil(rule.daysOfWeek)
        XCTAssertNil(rule.dayOfMonth)
        XCTAssertNil(rule.endDate)
    }
    
    func testDailyNextOccurrence() {
        let rule = RecurrenceRule(pattern: .daily, interval: 1)
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
        XCTAssertEqual(Calendar.current.startOfDay(for: next!), Calendar.current.startOfDay(for: tomorrow))
    }
    
    func testDailyNextOccurrenceWithInterval() {
        let rule = RecurrenceRule(pattern: .daily, interval: 3)
        let today = Date()
        let threeDaysLater = Calendar.current.date(byAdding: .day, value: 3, to: today)!
        
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
        XCTAssertEqual(Calendar.current.startOfDay(for: next!), Calendar.current.startOfDay(for: threeDaysLater))
    }
    
    func testWeeklyNextOccurrence() {
        let rule = RecurrenceRule(pattern: .weekly, interval: 1)
        let today = Date()
        let nextWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: today)!
        
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
        // Allow some tolerance for time components
        let diff = abs(next!.timeIntervalSince(nextWeek))
        XCTAssertLessThan(diff, 3600) // Within 1 hour
    }
    
    func testWeeklyNextOccurrenceWithSpecificDays() {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekday = calendar.component(.weekday, from: today)
        
        // Set days to include today and future days
        let daysOfWeek = [currentWeekday, (currentWeekday % 7) + 1]
        let rule = RecurrenceRule(pattern: .weekly, interval: 1, daysOfWeek: daysOfWeek)
        
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
    }
    
    func testMonthlyNextOccurrence() {
        let rule = RecurrenceRule(pattern: .monthly, interval: 1, dayOfMonth: 15)
        let today = Date()
        
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
        
        let calendar = Calendar.current
        let day = calendar.component(.day, from: next!)
        XCTAssertEqual(day, 15)
    }
    
    func testNextOccurrenceWithEndDate() {
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let rule = RecurrenceRule(pattern: .daily, interval: 1, endDate: endDate)
        
        // Test before end date
        let today = Date()
        let next = rule.nextOccurrence(from: today)
        XCTAssertNotNil(next)
        
        // Test after end date
        let afterEndDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        let nextAfterEnd = rule.nextOccurrence(from: afterEndDate)
        XCTAssertNil(nextAfterEnd)
    }
    
    func testDisplayDescriptionDaily() {
        let rule1 = RecurrenceRule(pattern: .daily, interval: 1)
        XCTAssertEqual(rule1.displayDescription, "Every day")
        
        let rule2 = RecurrenceRule(pattern: .daily, interval: 3)
        XCTAssertEqual(rule2.displayDescription, "Every 3 days")
    }
    
    func testDisplayDescriptionWeekly() {
        let rule1 = RecurrenceRule(pattern: .weekly, interval: 1)
        XCTAssertEqual(rule1.displayDescription, "Every week")
        
        let rule2 = RecurrenceRule(pattern: .weekly, interval: 2)
        XCTAssertEqual(rule2.displayDescription, "Every 2 weeks")
    }
    
    func testDisplayDescriptionMonthly() {
        let rule1 = RecurrenceRule(pattern: .monthly, interval: 1, dayOfMonth: 15)
        XCTAssertEqual(rule1.displayDescription, "Monthly on day 15")
        
        let rule2 = RecurrenceRule(pattern: .monthly, interval: 2)
        XCTAssertEqual(rule2.displayDescription, "Every 2 months")
    }
    
    func testPatternProperty() {
        let rule = RecurrenceRule(pattern: .weekly)
        XCTAssertEqual(rule.pattern, .weekly)
        
        rule.pattern = .monthly
        XCTAssertEqual(rule.pattern, .monthly)
        XCTAssertEqual(rule.patternRaw, "monthly")
    }
}
