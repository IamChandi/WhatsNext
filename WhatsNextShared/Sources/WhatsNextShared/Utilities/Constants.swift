//
//  Constants.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

/// Application-wide constants.
public enum AppConstants {
    /// Animation durations
    public enum Animation {
        public static let quick: TimeInterval = 0.2
        public static let standard: TimeInterval = 0.3
        public static let slow: TimeInterval = 0.4
        public static let springResponse: Double = 0.3
        public static let springDamping: Double = 0.8
    }
    
    /// Search and input delays
    public enum Timing {
        public static let searchDebounce: TimeInterval = 0.3
        public static let focusDelay: TimeInterval = 0.3
        public static let editorFocusDelay: TimeInterval = 0.3
    }
    
    /// Data limits
    public enum Data {
        public static let maxNoteSize: Int = 1_048_576 // 1MB for CloudKit
        public static let maxStreakDays: Int = 365
        public static let defaultFontSize: CGFloat = 17
        public static let editorFontSize: CGFloat = 15
    }
    
    /// Notification settings
    public enum Notifications {
        public static let morningHour: Int = 9
        public static let eveningHour: Int = 20
        public static let snoozeMinutes: Int = 15
    }
    
    /// CloudKit configuration
    public enum CloudKit {
        public static let containerIdentifier = "iCloud.com.chandi.WhatsNext"
    }
    
    /// Note-related settings
    public enum Note {
        public static let recentThresholdDays: Int = 7
    }
    
    /// Pagination settings
    public enum Pagination {
        /// Default number of items per page
        public static let defaultPageSize: Int = 50
        /// Maximum number of items per page
        public static let maxPageSize: Int = 200
        /// Minimum number of items per page
        public static let minPageSize: Int = 10
    }
}
