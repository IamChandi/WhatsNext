import Foundation
import SwiftData

@Model
final class Subtask {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var sortOrder: Int = 0
    var goal: Goal?

    init(title: String, sortOrder: Int = 0) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.sortOrder = sortOrder
    }
    
    // CloudKit-compatible initializer
    init() {
        self.id = UUID()
        self.title = ""
        self.isCompleted = false
        self.sortOrder = 0
    }

    func toggle() {
        isCompleted.toggle()
        goal?.updatedAt = Date()
    }
}
