//
//  GoalCategory.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import SwiftUI

/// Defines the primary time-based categories for organizing goals.
public enum GoalCategory: String, Codable, CaseIterable, Identifiable {
    /// Goals to be completed within the current day.
    case daily = "daily"
    
    /// Goals targeted for the current week.
    case weekly = "weekly"
    
    /// Long-term goals for the current month.
    case monthly = "monthly"
    
    /// Backlog or future goals with no immediate deadline.
    case whatsNext = "whatsNext"

    public var id: String { rawValue }

    /// The localized display name for the category.
    public var displayName: String {
        switch self {
        case .daily: return "Daily Goals"
        case .weekly: return "Weekly Goals"
        case .monthly: return "Monthly Goals"
        case .whatsNext: return "What's Next?"
        }
    }

    /// A shorter version of the display name for compact UI elements.
    public var shortName: String {
        switch self {
        case .daily: return "Today"
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        case .whatsNext: return "Later"
        }
    }

    /// The SF Symbol name associated with the category.
    public var icon: String {
        switch self {
        case .daily: return "sun.max"
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .whatsNext: return "sparkles"
        }
    }

    /// The primary color theme for the category.
    public var color: Color {
        switch self {
        case .daily: return .orange
        case .weekly: return .blue
        case .monthly: return .purple
        case .whatsNext: return .pink
        }
    }
}
