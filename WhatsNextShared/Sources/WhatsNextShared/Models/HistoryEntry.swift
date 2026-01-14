//
//  HistoryEntry.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData

public enum HistoryAction: String, Codable {
    case created
    case updated
    case completed
    case moved
    case deleted
    case archived
    case unarchived
}

@Model
public final class HistoryEntry {
    public var id: UUID = UUID()
    public var timestamp: Date = Date()
    public var actionRaw: String = HistoryAction.updated.rawValue
    public var goalId: UUID = UUID()
    public var goalTitle: String = ""
    public var previousCategoryRaw: String?
    public var newCategoryRaw: String?
    public var metadata: Data?

    @Transient
    public var action: HistoryAction {
        get { HistoryAction(rawValue: actionRaw) ?? .updated }
        set { actionRaw = newValue.rawValue }
    }

    @Transient
    public var previousCategory: GoalCategory? {
        get {
            guard let raw = previousCategoryRaw else { return nil }
            return GoalCategory(rawValue: raw)
        }
        set { previousCategoryRaw = newValue?.rawValue }
    }

    @Transient
    public var newCategory: GoalCategory? {
        get {
            guard let raw = newCategoryRaw else { return nil }
            return GoalCategory(rawValue: raw)
        }
        set { newCategoryRaw = newValue?.rawValue }
    }

    public init(
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
    public init() {
        self.id = UUID()
        self.timestamp = Date()
        self.actionRaw = HistoryAction.updated.rawValue
        self.goalId = UUID()
        self.goalTitle = ""
    }
}
