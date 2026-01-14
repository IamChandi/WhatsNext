//
//  RecurrencePattern.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

public enum RecurrencePattern: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case custom = "custom"

    public var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .custom: return "Custom"
        }
    }
}
