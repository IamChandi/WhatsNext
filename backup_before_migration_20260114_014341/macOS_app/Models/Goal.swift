import Foundation
import SwiftData

/// Represents a user goal or task in the WhatsNext application.
@Model
final class Goal {
    /// Unique identifier for the goal.
    var id: UUID = UUID()
    
    /// The display title of the goal.
    var title: String = ""
    
    /// Optional expanded description/notes for the goal.
    var goalDescription: String?
    
    /// Underlying raw string for the category.
    var categoryRaw: String = GoalCategory.daily.rawValue
    
    /// Underlying raw string for the priority.
    var priorityRaw: String = Priority.medium.rawValue
    
    /// Underlying raw string for the status.
    var statusRaw: String = GoalStatus.pending.rawValue
    
    /// The date when the goal was created.
    var createdAt: Date = Date()
    
    /// The date when the goal or its status was last updated.
    var updatedAt: Date = Date()
    
    /// Optional deadline for the goal.
    var dueDate: Date?
    
    /// The date when the goal was marked as completed.
    var completedAt: Date?
    
    /// User-defined sort order for manual organization.
    var sortOrder: Int = 0
    
    /// Whether the goal is currently in "Focus" mode.
    var isFocused: Bool = false

    /// Subtasks associated with this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \Subtask.goal)
    var subtasks: [Subtask]?

    /// Tags associated with this goal.
    var tags: [Tag]?

    /// Reminders and alerts scheduled for this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \GoalAlert.goal)
    var alerts: [GoalAlert]?

    /// Optional recurrence rule for repeating goals. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \RecurrenceRule.goal)
    var recurrence: RecurrenceRule?

    /// Notes associated with this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade)
    var notes: [Note]?

    /// The category this goal belongs to (e.g., Daily, Weekly).
    @Transient
    var category: GoalCategory {
        get { GoalCategory(rawValue: categoryRaw) ?? .daily }
        set { categoryRaw = newValue.rawValue }
    }

    /// The priority level of the goal.
    @Transient
    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    /// The current lifecycle status of the goal.
    @Transient
    var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// Whether the goal is in a completed state.
    @Transient
    var isCompleted: Bool {
        status == .completed
    }

    /// Whether the goal's due date has passed without completion.
    @Transient
    var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    /// The percentage of subtasks that have been completed.
    @Transient
    var completionPercentage: Double {
        guard let subtasks = subtasks, !subtasks.isEmpty else {
            return isCompleted ? 1.0 : 0.0
        }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    /// Subtasks sorted by their defined sort order.
    @Transient
    var sortedSubtasks: [Subtask] {
        (subtasks ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Alerts sorted by their scheduled date.
    @Transient
    var sortedAlerts: [GoalAlert] {
        (alerts ?? []).sorted { $0.scheduledDate < $1.scheduledDate }
    }

    /// Notes sorted by their updated date (most recent first).
    @Transient
    var sortedNotes: [Note] {
        (notes ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }

    init(
        title: String,
        goalDescription: String? = nil,
        category: GoalCategory = .daily,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        sortOrder: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.categoryRaw = category.rawValue
        self.priorityRaw = priority.rawValue
        self.statusRaw = GoalStatus.pending.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.dueDate = dueDate
        self.completedAt = nil
        self.sortOrder = sortOrder
        self.isFocused = false
    }
    
    // CloudKit-compatible initializer (allows SwiftData to create instances)
    init() {
        self.id = UUID()
        self.title = ""
        self.categoryRaw = GoalCategory.daily.rawValue
        self.priorityRaw = Priority.medium.rawValue
        self.statusRaw = GoalStatus.pending.rawValue
        self.createdAt = Date()
        self.updatedAt = Date()
        self.sortOrder = 0
        self.isFocused = false
    }

    /// Toggles the completion status between pending and completed.
    func toggleCompletion() {
        if isCompleted {
            status = .pending
            completedAt = nil
        } else {
            status = .completed
            completedAt = Date()
        }
        updatedAt = Date()
    }

    /// Moves the goal to a different category.
    func move(to category: GoalCategory) {
        self.category = category
        updatedAt = Date()
    }

    /// Archives the goal, removing it from active lists.
    func archive() {
        status = .archived
        updatedAt = Date()
    }

    /// Restores the goal from the archive based on its completion state.
    func unarchive() {
        status = completedAt != nil ? .completed : .pending
        updatedAt = Date()
    }
}
