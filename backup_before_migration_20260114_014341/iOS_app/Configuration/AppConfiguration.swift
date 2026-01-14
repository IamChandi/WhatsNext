import Foundation

/// Centralized configuration constants for the application.
/// Marked as nonisolated to allow access from any context.
nonisolated enum AppConfiguration {
    /// Notification scheduling configuration.
    enum Notifications {
        /// Morning reminder hour (24-hour format).
        nonisolated static let morningHour = 9
        
        /// Evening reminder hour (24-hour format).
        nonisolated static let eveningHour = 20
        
        /// Default snooze duration in minutes.
        nonisolated static let defaultSnoozeMinutes = 15
    }
    
    /// UI configuration constants.
    enum UI {
        /// Toast auto-dismiss duration in seconds.
        nonisolated static let toastDismissDuration: TimeInterval = 4.0
        
        /// Animation duration for UI transitions.
        nonisolated static let animationDuration: TimeInterval = 0.3
    }
    
    /// Data configuration.
    enum Data {
        /// Maximum number of goals to fetch in a single query (for future pagination).
        nonisolated static let maxGoalsPerQuery = 1000
    }
}
