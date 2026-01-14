import Foundation
import WhatsNextShared
import SwiftData
import WhatsNextShared

@Model
final class GoalAlert {
    var id: UUID = UUID()
    var scheduledDate: Date = Date()
    var message: String?
    var isTriggered: Bool = false
    var notificationIdentifier: String?
    var goal: Goal?

    init(scheduledDate: Date, message: String? = nil) {
        self.id = UUID()
        self.scheduledDate = scheduledDate
        self.message = message
        self.isTriggered = false
        self.notificationIdentifier = nil
    }
    
    // CloudKit-compatible initializer
    init() {
        self.id = UUID()
        self.scheduledDate = Date()
        self.isTriggered = false
    }

    @Transient
    var isPast: Bool {
        scheduledDate < Date()
    }

    @Transient
    var isUpcoming: Bool {
        !isPast && !isTriggered
    }
}
