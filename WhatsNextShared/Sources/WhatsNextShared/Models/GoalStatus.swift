//
//  GoalStatus.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

public enum GoalStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "inProgress"
    case completed = "completed"
    case archived = "archived"

    public var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .archived: return "Archived"
        }
    }
}
