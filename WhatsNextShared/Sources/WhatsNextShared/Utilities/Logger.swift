//
//  Logger.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import os.log

/// Centralized logging system for the WhatsNext application.
/// Uses os.log for efficient, categorized logging.
extension Logger {
    private static nonisolated(unsafe) let subsystem: String = {
        #if canImport(Foundation)
        if let bundleId = Bundle.main.bundleIdentifier {
            return bundleId
        }
        #endif
        return "com.chandi.WhatsNext"
    }()
    
    /// Logs related to data persistence and SwiftData operations.
    public static let data = Logger(subsystem: subsystem, category: "data")
    
    /// Logs related to UI and view updates.
    public static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Logs related to network and CloudKit operations.
    public static let network = Logger(subsystem: subsystem, category: "network")
    
    /// Logs related to notifications and alerts.
    public static let notifications = Logger(subsystem: subsystem, category: "notifications")
    
    /// Logs related to app lifecycle and initialization.
    public static let app = Logger(subsystem: subsystem, category: "app")
    
    /// Logs related to errors and exceptions.
    public static let error = Logger(subsystem: subsystem, category: "error")
    
    /// Logs related to performance and optimization.
    public static let performance = Logger(subsystem: subsystem, category: "performance")
}
