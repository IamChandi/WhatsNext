//
//  Constants.swift
//  WhatsNextiOS
//
//  Application-wide constants and configuration values.
//

import Foundation

/// Application-wide constants.
enum AppConstants {
    /// Animation durations
    enum Animation {
        static let quick: TimeInterval = 0.2
        static let standard: TimeInterval = 0.3
        static let slow: TimeInterval = 0.4
        static let springResponse: Double = 0.3
        static let springDamping: Double = 0.8
    }
    
    /// Search and input delays
    enum Timing {
        static let searchDebounce: TimeInterval = 0.3
        static let focusDelay: TimeInterval = 0.3
        static let editorFocusDelay: TimeInterval = 0.3
    }
    
    /// Data limits
    enum Data {
        static let maxNoteSize: Int = 1_048_576 // 1MB for CloudKit
        static let maxStreakDays: Int = 365
        static let defaultFontSize: CGFloat = 17
        static let editorFontSize: CGFloat = 15
    }
    
    /// Notification settings
    enum Notifications {
        static let morningHour: Int = 9
        static let eveningHour: Int = 20
        static let snoozeMinutes: Int = 15
    }
    
    /// CloudKit configuration
    enum CloudKit {
        static let containerIdentifier = "iCloud.com.chandi.WhatsNext"
    }
}
