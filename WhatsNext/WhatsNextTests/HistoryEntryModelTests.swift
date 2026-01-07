import XCTest
@testable import WhatsNext

final class HistoryEntryModelTests: XCTestCase {
    
    func testHistoryEntryInitialization() {
        let goalId = UUID()
        let entry = HistoryEntry(
            action: .created,
            goalId: goalId,
            goalTitle: "Test Goal",
            previousCategory: .daily,
            newCategory: .weekly,
            metadata: "test".data(using: .utf8)
        )
        
        XCTAssertEqual(entry.action, .created)
        XCTAssertEqual(entry.goalId, goalId)
        XCTAssertEqual(entry.goalTitle, "Test Goal")
        XCTAssertEqual(entry.previousCategory, .daily)
        XCTAssertEqual(entry.newCategory, .weekly)
        XCTAssertNotNil(entry.metadata)
        XCTAssertNotNil(entry.id)
        XCTAssertNotNil(entry.timestamp)
    }
    
    func testHistoryEntryDefaultValues() {
        let goalId = UUID()
        let entry = HistoryEntry(
            action: .updated,
            goalId: goalId,
            goalTitle: "Test Goal"
        )
        
        XCTAssertEqual(entry.action, .updated)
        XCTAssertNil(entry.previousCategory)
        XCTAssertNil(entry.newCategory)
        XCTAssertNil(entry.metadata)
    }
    
    func testHistoryEntryActionProperty() {
        let goalId = UUID()
        let entry = HistoryEntry(action: .completed, goalId: goalId, goalTitle: "Test")
        
        XCTAssertEqual(entry.action, .completed)
        XCTAssertEqual(entry.actionRaw, "completed")
        
        entry.action = .archived
        XCTAssertEqual(entry.action, .archived)
        XCTAssertEqual(entry.actionRaw, "archived")
    }
    
    func testHistoryEntryCategoryProperties() {
        let goalId = UUID()
        let entry = HistoryEntry(action: .moved, goalId: goalId, goalTitle: "Test")
        
        entry.previousCategory = .daily
        entry.newCategory = .weekly
        
        XCTAssertEqual(entry.previousCategory, .daily)
        XCTAssertEqual(entry.newCategory, .weekly)
        XCTAssertEqual(entry.previousCategoryRaw, "daily")
        XCTAssertEqual(entry.newCategoryRaw, "weekly")
    }
    
    func testHistoryEntryCategoryNil() {
        let goalId = UUID()
        let entry = HistoryEntry(action: .moved, goalId: goalId, goalTitle: "Test")
        
        entry.previousCategory = nil
        entry.newCategory = nil
        
        XCTAssertNil(entry.previousCategory)
        XCTAssertNil(entry.newCategory)
        XCTAssertNil(entry.previousCategoryRaw)
        XCTAssertNil(entry.newCategoryRaw)
    }
    
    func testHistoryActionAllCases() {
        let actions: [HistoryAction] = [.created, .updated, .completed, .moved, .deleted, .archived, .unarchived]
        XCTAssertEqual(actions.count, 7)
    }
    
    func testHistoryActionRawValues() {
        XCTAssertEqual(HistoryAction.created.rawValue, "created")
        XCTAssertEqual(HistoryAction.updated.rawValue, "updated")
        XCTAssertEqual(HistoryAction.completed.rawValue, "completed")
        XCTAssertEqual(HistoryAction.moved.rawValue, "moved")
        XCTAssertEqual(HistoryAction.deleted.rawValue, "deleted")
        XCTAssertEqual(HistoryAction.archived.rawValue, "archived")
        XCTAssertEqual(HistoryAction.unarchived.rawValue, "unarchived")
    }
    
    func testHistoryActionFromRawValue() {
        XCTAssertEqual(HistoryAction(rawValue: "created"), .created)
        XCTAssertEqual(HistoryAction(rawValue: "updated"), .updated)
        XCTAssertEqual(HistoryAction(rawValue: "completed"), .completed)
        XCTAssertNil(HistoryAction(rawValue: "invalid"))
    }
}
