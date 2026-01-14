//
//  Priority.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import SwiftUI

public enum Priority: String, Codable, CaseIterable, Identifiable {
    case high = "high"
    case medium = "medium"
    case low = "low"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .high: return "High"
        case .medium: return "Medium"
        case .low: return "Low"
        }
    }

    public var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }

    public var icon: String {
        switch self {
        case .high: return "exclamationmark.3"
        case .medium: return "exclamationmark.2"
        case .low: return "exclamationmark"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}
