//
//  Goal.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData

/// Represents a user goal or task in the WhatsNext application.
@Model
public final class Goal {
    /// Unique identifier for the goal.
    public var id: UUID = UUID()
    
    /// The display title of the goal.
    public var title: String = ""
    
    /// Optional expanded description/notes for the goal.
    public var goalDescription: String?
    
    /// Underlying raw string for the category.
    public var categoryRaw: String = GoalCategory.daily.rawValue
    
    /// Underlying raw string for the priority.
    public var priorityRaw: String = Priority.medium.rawValue
    
    /// Underlying raw string for the status.
    public var statusRaw: String = GoalStatus.pending.rawValue
    
    /// The date when the goal was created.
    public var createdAt: Date = Date()
    
    /// The date when the goal or its status was last updated.
    public var updatedAt: Date = Date()
    
    /// Optional deadline for the goal.
    public var dueDate: Date?
    
    /// The date when the goal was marked as completed.
    public var completedAt: Date?
    
    /// User-defined sort order for manual organization.
    public var sortOrder: Int = 0
    
    /// Whether the goal is currently in "Focus" mode.
    public var isFocused: Bool = false

    /// Subtasks associated with this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \Subtask.goal)
    public var subtasks: [Subtask]?

    /// Tags associated with this goal.
    public var tags: [Tag]?

    /// Reminders and alerts scheduled for this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \GoalAlert.goal)
    public var alerts: [GoalAlert]?

    /// Optional recurrence rule for repeating goals. Cascades on deletion.
    @Relationship(deleteRule: .cascade, inverse: \RecurrenceRule.goal)
    public var recurrence: RecurrenceRule?

    /// Notes associated with this goal. Cascades on deletion.
    @Relationship(deleteRule: .cascade)
    public var notes: [Note]?

    /// The category this goal belongs to (e.g., Daily, Weekly).
    @Transient
    public var category: GoalCategory {
        get { GoalCategory(rawValue: categoryRaw) ?? .daily }
        set { categoryRaw = newValue.rawValue }
    }

    /// The priority level of the goal.
    @Transient
    public var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    /// The current lifecycle status of the goal.
    @Transient
    public var status: GoalStatus {
        get { GoalStatus(rawValue: statusRaw) ?? .pending }
        set { statusRaw = newValue.rawValue }
    }

    /// Whether the goal is in a completed state.
    @Transient
    public var isCompleted: Bool {
        status == .completed
    }

    /// Whether the goal's due date has passed without completion.
    @Transient
    public var isOverdue: Bool {
        guard let dueDate = dueDate, !isCompleted else { return false }
        return dueDate < Date()
    }

    /// The percentage of subtasks that have been completed.
    @Transient
    public var completionPercentage: Double {
        guard let subtasks = subtasks, !subtasks.isEmpty else {
            return isCompleted ? 1.0 : 0.0
        }
        let completed = subtasks.filter { $0.isCompleted }.count
        return Double(completed) / Double(subtasks.count)
    }

    /// Subtasks sorted by their defined sort order.
    @Transient
    public var sortedSubtasks: [Subtask] {
        (subtasks ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    /// Alerts sorted by their scheduled date.
    @Transient
    public var sortedAlerts: [GoalAlert] {
        (alerts ?? []).sorted { $0.scheduledDate < $1.scheduledDate }
    }

    /// Notes sorted by their updated date (most recent first).
    @Transient
    public var sortedNotes: [Note] {
        (notes ?? []).sorted { $0.updatedAt > $1.updatedAt }
    }

    public init(
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
    public init() {
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
    public func toggleCompletion() {
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
    public func move(to category: GoalCategory) {
        self.category = category
        updatedAt = Date()
    }

    /// Archives the goal, removing it from active lists.
    public func archive() {
        status = .archived
        updatedAt = Date()
    }

    /// Restores the goal from the archive based on its completion state.
    public func unarchive() {
        status = completedAt != nil ? .completed : .pending
        updatedAt = Date()
    }
}
