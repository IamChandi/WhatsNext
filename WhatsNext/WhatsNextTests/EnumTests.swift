import XCTest
import SwiftUI
@testable import WhatsNext

final class EnumTests: XCTestCase {
    
    // MARK: - GoalCategory Tests
    
    func testGoalCategoryAllCases() {
        let categories = GoalCategory.allCases
        XCTAssertEqual(categories.count, 4)
        XCTAssertTrue(categories.contains(.daily))
        XCTAssertTrue(categories.contains(.weekly))
        XCTAssertTrue(categories.contains(.monthly))
        XCTAssertTrue(categories.contains(.whatsNext))
    }
    
    func testGoalCategoryDisplayNames() {
        XCTAssertEqual(GoalCategory.daily.displayName, "Daily Goals")
        XCTAssertEqual(GoalCategory.weekly.displayName, "Weekly Goals")
        XCTAssertEqual(GoalCategory.monthly.displayName, "Monthly Goals")
        XCTAssertEqual(GoalCategory.whatsNext.displayName, "What's Next?")
    }
    
    func testGoalCategoryShortNames() {
        XCTAssertEqual(GoalCategory.daily.shortName, "Today")
        XCTAssertEqual(GoalCategory.weekly.shortName, "This Week")
        XCTAssertEqual(GoalCategory.monthly.shortName, "This Month")
        XCTAssertEqual(GoalCategory.whatsNext.shortName, "Later")
    }
    
    func testGoalCategoryIcons() {
        XCTAssertEqual(GoalCategory.daily.icon, "sun.max")
        XCTAssertEqual(GoalCategory.weekly.icon, "calendar.badge.clock")
        XCTAssertEqual(GoalCategory.monthly.icon, "calendar")
        XCTAssertEqual(GoalCategory.whatsNext.icon, "sparkles")
    }
    
    func testGoalCategoryColors() {
        XCTAssertEqual(GoalCategory.daily.color, .orange)
        XCTAssertEqual(GoalCategory.weekly.color, .blue)
        XCTAssertEqual(GoalCategory.monthly.color, .purple)
        XCTAssertEqual(GoalCategory.whatsNext.color, .pink)
    }
    
    func testGoalCategoryIdentifiable() {
        let category = GoalCategory.daily
        XCTAssertEqual(category.id, "daily")
    }
    
    // MARK: - Priority Tests
    
    func testPriorityAllCases() {
        let priorities = Priority.allCases
        XCTAssertEqual(priorities.count, 3)
        XCTAssertTrue(priorities.contains(.high))
        XCTAssertTrue(priorities.contains(.medium))
        XCTAssertTrue(priorities.contains(.low))
    }
    
    func testPriorityDisplayNames() {
        XCTAssertEqual(Priority.high.displayName, "High")
        XCTAssertEqual(Priority.medium.displayName, "Medium")
        XCTAssertEqual(Priority.low.displayName, "Low")
    }
    
    func testPriorityColors() {
        XCTAssertEqual(Priority.high.color, .red)
        XCTAssertEqual(Priority.medium.color, .orange)
        XCTAssertEqual(Priority.low.color, .blue)
    }
    
    func testPriorityIcons() {
        XCTAssertEqual(Priority.high.icon, "exclamationmark.3")
        XCTAssertEqual(Priority.medium.icon, "exclamationmark.2")
        XCTAssertEqual(Priority.low.icon, "exclamationmark")
    }
    
    func testPrioritySortOrder() {
        XCTAssertEqual(Priority.high.sortOrder, 0)
        XCTAssertEqual(Priority.medium.sortOrder, 1)
        XCTAssertEqual(Priority.low.sortOrder, 2)
        
        // Verify sorting works correctly
        let priorities = [Priority.low, Priority.high, Priority.medium]
        let sorted = priorities.sorted { $0.sortOrder < $1.sortOrder }
        XCTAssertEqual(sorted, [Priority.high, Priority.medium, Priority.low])
    }
    
    func testPriorityIdentifiable() {
        let priority = Priority.high
        XCTAssertEqual(priority.id, "high")
    }
    
    // MARK: - GoalStatus Tests
    
    func testGoalStatusAllCases() {
        let statuses = GoalStatus.allCases
        XCTAssertEqual(statuses.count, 4)
        XCTAssertTrue(statuses.contains(.pending))
        XCTAssertTrue(statuses.contains(.inProgress))
        XCTAssertTrue(statuses.contains(.completed))
        XCTAssertTrue(statuses.contains(.archived))
    }
    
    func testGoalStatusDisplayNames() {
        XCTAssertEqual(GoalStatus.pending.displayName, "Pending")
        XCTAssertEqual(GoalStatus.inProgress.displayName, "In Progress")
        XCTAssertEqual(GoalStatus.completed.displayName, "Completed")
        XCTAssertEqual(GoalStatus.archived.displayName, "Archived")
    }
    
    // MARK: - ViewMode Tests
    
    func testViewModeAllCases() {
        let modes = ViewMode.allCases
        XCTAssertEqual(modes.count, 2)
        XCTAssertTrue(modes.contains(.checklist))
        XCTAssertTrue(modes.contains(.kanban))
    }
    
    func testViewModeDisplayNames() {
        XCTAssertEqual(ViewMode.checklist.displayName, "List")
        XCTAssertEqual(ViewMode.kanban.displayName, "Board")
    }
    
    func testViewModeIcons() {
        XCTAssertEqual(ViewMode.checklist.icon, "checklist")
        XCTAssertEqual(ViewMode.kanban.icon, "rectangle.split.3x1")
    }
    
    // MARK: - RecurrencePattern Tests
    
    func testRecurrencePatternAllCases() {
        let patterns = RecurrencePattern.allCases
        XCTAssertEqual(patterns.count, 4)
        XCTAssertTrue(patterns.contains(.daily))
        XCTAssertTrue(patterns.contains(.weekly))
        XCTAssertTrue(patterns.contains(.monthly))
        XCTAssertTrue(patterns.contains(.custom))
    }
    
    func testRecurrencePatternDisplayNames() {
        XCTAssertEqual(RecurrencePattern.daily.displayName, "Daily")
        XCTAssertEqual(RecurrencePattern.weekly.displayName, "Weekly")
        XCTAssertEqual(RecurrencePattern.monthly.displayName, "Monthly")
        XCTAssertEqual(RecurrencePattern.custom.displayName, "Custom")
    }
}
