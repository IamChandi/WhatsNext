//
//  Note.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import SwiftData
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import os.log

/// Represents a rich text note associated with a goal.
/// Supports formatted text and bidirectional linking with goals.
@Model
public final class Note {
    /// Unique identifier for the note.
    public var id: UUID = UUID()
    
    /// The date when the note was created.
    public var createdAt: Date = Date()
    
    /// The date when the note was last updated.
    public var updatedAt: Date = Date()
    
    /// Rich text content stored as Data (NSAttributedString encoded).
    /// Maximum size: 1MB for CloudKit compatibility.
    public var richTextData: Data?
    
    /// Plain text version for search and fallback display.
    public var plainText: String = ""
    
    /// User-defined sort order for manual organization.
    public var sortOrder: Int = 0
    
    /// Relationship to the parent goal. Cascade delete when goal is deleted.
    @Relationship(inverse: \Goal.notes)
    public var goal: Goal?
    
    /// The rich text content as NSAttributedString.
    /// Automatically converts between Data and NSAttributedString.
    #if canImport(AppKit) || canImport(UIKit)
    @Transient
    public var attributedText: NSAttributedString {
        get {
            guard let data = richTextData else {
                return NSAttributedString(string: plainText)
            }
            
            do {
                if let unarchived = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) {
                    return unarchived
                }
            } catch {
                Logger.data.error("❌ Failed to unarchive attributed text: \(error.localizedDescription)")
            }
            
            // Fallback to plain text if decoding fails
            return NSAttributedString(string: plainText)
        }
        set {
            let text = newValue.string
            plainText = text
            
            // Encode NSAttributedString to Data
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: newValue, requiringSecureCoding: false)
                
                // Check size limit (1MB for CloudKit)
                if let error = InputValidator.validateNoteSize(data) {
                    Logger.data.warning("⚠️ \(error.localizedDescription)")
                    // Store plain text only if too large
                    richTextData = nil
                } else {
                    richTextData = data
                }
            } catch {
                Logger.data.error("❌ Failed to archive attributed text: \(error.localizedDescription)")
                richTextData = nil
            }
            
            updatedAt = Date()
        }
    }
    #endif
    
    /// Notes sorted by their updated date (most recent first).
    @Transient
    public var isRecent: Bool {
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: updatedAt, to: Date()).day ?? 0
        return daysSinceUpdate < 7
    }
    
    /// CloudKit-compatible initializer (allows SwiftData to create instances).
    public init() {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.plainText = ""
        self.sortOrder = 0
    }
    
    /// Convenience initializer for creating a new note.
    #if canImport(AppKit) || canImport(UIKit)
    public init(goal: Goal? = nil, attributedText: NSAttributedString? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.goal = goal
        self.plainText = attributedText?.string ?? ""
        self.sortOrder = 0
        
        // Encode attributed text
        if let attributedText = attributedText {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
                if InputValidator.validateNoteSize(data) == nil {
                    self.richTextData = data
                } else {
                    Logger.data.warning("⚠️ Note content exceeds size limit in init, storing plain text only")
                }
            } catch {
                Logger.data.error("❌ Failed to archive attributed text in init: \(error.localizedDescription)")
            }
        }
    }
    #else
    public init(goal: Goal? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.goal = goal
        self.plainText = ""
        self.sortOrder = 0
    }
    #endif
    
    /// Updates the note content.
    #if canImport(AppKit) || canImport(UIKit)
    public func updateContent(_ attributedText: NSAttributedString) {
        self.attributedText = attributedText
        updatedAt = Date()
    }
    #endif
}
