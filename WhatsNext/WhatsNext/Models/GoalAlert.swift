import Foundation
import SwiftData

@Model
final class GoalAlert {
    var id: UUID
    var scheduledDate: Date
    var message: String?
    var isTriggered: Bool
    var notificationIdentifier: String?
    var goal: Goal?

    init(scheduledDate: Date, message: String? = nil) {
        self.id = UUID()
        self.scheduledDate = scheduledDate
        self.message = message
        self.isTriggered = false
        self.notificationIdentifier = nil
    }

    var isPast: Bool {
        scheduledDate < Date()
    }

    var isUpcoming: Bool {
        !isPast && !isTriggered
    }
}
