import Foundation
import SwiftData

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
    var id: UUID
    var timestamp: Date
    var actionRaw: String
    var goalId: UUID
    var goalTitle: String
    var previousCategoryRaw: String?
    var newCategoryRaw: String?
    var metadata: Data?

    var action: HistoryAction {
        get { HistoryAction(rawValue: actionRaw) ?? .updated }
        set { actionRaw = newValue.rawValue }
    }

    var previousCategory: GoalCategory? {
        get {
            guard let raw = previousCategoryRaw else { return nil }
            return GoalCategory(rawValue: raw)
        }
        set { previousCategoryRaw = newValue?.rawValue }
    }

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
}
