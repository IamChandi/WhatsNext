import Foundation
import SwiftData
import UIKit
import os.log

/// Represents a rich text note associated with a goal.
/// Supports formatted text and bidirectional linking with goals.
@Model
final class Note {
    /// Unique identifier for the note.
    var id: UUID = UUID()
    
    /// The date when the note was created.
    var createdAt: Date = Date()
    
    /// The date when the note was last updated.
    var updatedAt: Date = Date()
    
    /// Rich text content stored as Data (NSAttributedString encoded).
    /// Maximum size: 1MB for CloudKit compatibility.
    var richTextData: Data?
    
    /// Plain text version for search and fallback display.
    var plainText: String = ""
    
    /// User-defined sort order for manual organization.
    var sortOrder: Int = 0
    
    /// Relationship to the parent goal.
    @Relationship(inverse: \Goal.notes)
    var goal: Goal?
    
    /// The rich text content as NSAttributedString.
    /// Automatically converts between Data and NSAttributedString.
    @Transient
    var attributedText: NSAttributedString {
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
                if data.count > 1_048_576 {
                    print("Warning: Note content exceeds 1MB limit, truncating...")
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
    
    /// Notes sorted by their updated date (most recent first).
    @Transient
    var isRecent: Bool {
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: updatedAt, to: Date()).day ?? 0
        return daysSinceUpdate < 7
    }
    
    /// CloudKit-compatible initializer (allows SwiftData to create instances).
    init() {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.plainText = ""
        self.sortOrder = 0
    }
    
    /// Convenience initializer for creating a new note.
    init(goal: Goal? = nil, attributedText: NSAttributedString = NSAttributedString(string: "")) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.goal = goal
        self.plainText = attributedText.string
        self.sortOrder = 0
        
        // Encode attributed text
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: attributedText, requiringSecureCoding: false)
            if data.count <= 1_048_576 {
                self.richTextData = data
            }
        } catch {
            Logger.data.error("❌ Failed to archive attributed text in init: \(error.localizedDescription)")
        }
    }
    
    /// Updates the note content.
    func updateContent(_ attributedText: NSAttributedString) {
        self.attributedText = attributedText
        updatedAt = Date()
    }
}
