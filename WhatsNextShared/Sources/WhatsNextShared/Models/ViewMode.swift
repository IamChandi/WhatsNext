//
//  ViewMode.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

public enum ViewMode: String, Codable, CaseIterable {
    case checklist = "checklist"
    case kanban = "kanban"

    public var displayName: String {
        switch self {
        case .checklist: return "List"
        case .kanban: return "Board"
        }
    }

    public var icon: String {
        switch self {
        case .checklist: return "checklist"
        case .kanban: return "rectangle.split.3x1"
        }
    }
}
