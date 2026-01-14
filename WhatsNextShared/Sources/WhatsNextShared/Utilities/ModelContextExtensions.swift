//
//  ModelContextExtensions.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData
import os.log

/// Extension to ModelContext for improved error handling and logging.
public extension ModelContext {
    /// Saves the context with error logging.
    /// Returns true if successful, false otherwise.
    @discardableResult
    func saveWithErrorHandling() -> Bool {
        do {
            try save()
            Logger.data.info("💾 ModelContext saved successfully - changes will sync to CloudKit")
            return true
        } catch {
            Logger.data.error("❌ ModelContext save failed: \(error.localizedDescription)")
            #if DEBUG
            Logger.data.error("Error details: \(error)")
            #endif
            return false
        }
    }
    
    /// Saves the context and throws if it fails.
    /// Use this when you need to handle errors at the call site.
    func saveOrThrow() throws {
        try save()
    }
    
    /// Saves the context with error handling and user feedback.
    /// Shows error alert if save fails.
    @MainActor
    func saveWithUserFeedback() -> Bool {
        do {
            try save()
            return true
        } catch {
            Logger.data.error("❌ ModelContext save failed: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.saveFailed(error), context: "ModelContext.save")
            return false
        }
    }
}
