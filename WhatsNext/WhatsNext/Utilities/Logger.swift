//
//  Logger.swift
//  WhatsNext
//
//  Centralized logging system using os.log framework.
//

import Foundation
import os.log
import WhatsNextShared

/// Centralized logging system for the WhatsNext application.
/// Uses os.log for efficient, categorized logging.
extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier ?? "com.chandi.WhatsNext"
    
    /// Logs related to data persistence and SwiftData operations.
    static let data = Logger(subsystem: subsystem, category: "data")
    
    /// Logs related to UI and view updates.
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Logs related to network and CloudKit operations.
    static let network = Logger(subsystem: subsystem, category: "network")
    
    /// Logs related to notifications and alerts.
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
    
    /// Logs related to app lifecycle and initialization.
    static let app = Logger(subsystem: subsystem, category: "app")
    
    /// Logs related to errors and exceptions.
    static let error = Logger(subsystem: subsystem, category: "error")
    
    /// Logs related to performance and optimization.
    static let performance = Logger(subsystem: subsystem, category: "performance")
}
