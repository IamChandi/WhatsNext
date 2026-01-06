import Foundation

enum GoalStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "inProgress"
    case completed = "completed"
    case archived = "archived"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
}
