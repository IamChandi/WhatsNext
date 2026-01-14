import Foundation
import WhatsNextShared
import SwiftData
import WhatsNextShared

enum HistoryAction: String, Codable {
    case created
    case updated
    case completed
    case moved
    case deleted
    case archived
    case unarchived
}

@Model
final class HistoryEntry {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var actionRaw: String = HistoryAction.updated.rawValue
    var goalId: UUID = UUID()
    var goalTitle: String = ""
    var previousCategoryRaw: String?
    var newCategoryRaw: String?
    var metadata: Data?

    @Transient
    var action: HistoryAction {
        get { HistoryAction(rawValue: actionRaw) ?? .updated }
        set { actionRaw = newValue.rawValue }
    }

    @Transient
    var previousCategory: GoalCategory? {
        get {
            guard let raw = previousCategoryRaw else { return nil }
            return GoalCategory(rawValue: raw)
        }
        set { previousCategoryRaw = newValue?.rawValue }
    }

    @Transient
    var newCategory: GoalCategory? {
        get {
            guard let raw = newCategoryRaw else { return nil }
            return GoalCategory(rawValue: raw)
        }
        set { newCategoryRaw = newValue?.rawValue }
    }

    init(
        action: HistoryAction,
        goalId: UUID,
        goalTitle: String,
        previousCategory: GoalCategory? = nil,
        newCategory: GoalCategory? = nil,
        metadata: Data? = nil
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.actionRaw = action.rawValue
        self.goalId = goalId
        self.goalTitle = goalTitle
        self.previousCategoryRaw = previousCategory?.rawValue
        self.newCategoryRaw = newCategory?.rawValue
        self.metadata = metadata
    }
    
    // CloudKit-compatible initializer
    init() {
        self.id = UUID()
        self.timestamp = Date()
        self.actionRaw = HistoryAction.updated.rawValue
        self.goalId = UUID()
        self.goalTitle = ""
    }
}
