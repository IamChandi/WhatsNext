//
//  InputValidator.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation

/// Validation errors for user input.
public enum ValidationError: LocalizedError {
    case noteTooLarge(actual: Int, max: Int)
    case titleTooLong(actual: Int, max: Int)
    case titleEmpty
    case invalidDateRange(start: Date, end: Date)
    case dateInPast
    case invalidPriority
    case invalidCategory
    
    public var errorDescription: String? {
        switch self {
        case .noteTooLarge(let actual, let max):
            let actualMB = Double(actual) / 1_048_576.0
            let maxMB = Double(max) / 1_048_576.0
            return "Note content is too large (\(String(format: "%.2f", actualMB))MB). Maximum size is \(String(format: "%.2f", maxMB))MB."
        case .titleTooLong(let actual, let max):
            return "Title is too long (\(actual) characters). Maximum length is \(max) characters."
        case .titleEmpty:
            return "Title cannot be empty."
        case .invalidDateRange(let start, let end):
            return "Invalid date range: end date (\(end)) must be after start date (\(start))."
        case .dateInPast:
            return "Date cannot be in the past."
        case .invalidPriority:
            return "Invalid priority value."
        case .invalidCategory:
            return "Invalid category value."
        }
    }
}

/// Centralized input validation utilities.
public struct InputValidator {
    /// Maximum length for goal titles
    public static let maxTitleLength: Int = 200
    
    /// Minimum length for goal titles
    public static let minTitleLength: Int = 1
    
    /// Maximum length for goal descriptions
    public static let maxDescriptionLength: Int = 5000
    
    /// Validates a goal title.
    /// - Parameter title: The title to validate
    /// - Returns: Validation error if invalid, nil if valid
    public static func validateTitle(_ title: String) -> ValidationError? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            return .titleEmpty
        }
        
        if trimmed.count > maxTitleLength {
            return .titleTooLong(actual: trimmed.count, max: maxTitleLength)
        }
        
        return nil
    }
    
    /// Validates a goal description.
    /// - Parameter description: The description to validate
    /// - Returns: Validation error if invalid, nil if valid
    public static func validateDescription(_ description: String?) -> ValidationError? {
        guard let description = description else { return nil }
        
        if description.count > maxDescriptionLength {
            return .titleTooLong(actual: description.count, max: maxDescriptionLength)
        }
        
        return nil
    }
    
    /// Validates note content size.
    /// - Parameter data: The data to validate
    /// - Returns: Validation error if invalid, nil if valid
    public static func validateNoteSize(_ data: Data) -> ValidationError? {
        if data.count > AppConstants.Data.maxNoteSize {
            return .noteTooLarge(actual: data.count, max: AppConstants.Data.maxNoteSize)
        }
        return nil
    }
    
    /// Validates a date range.
    /// - Parameters:
    ///   - start: Start date
    ///   - end: End date
    /// - Returns: Validation error if invalid, nil if valid
    public static func validateDateRange(start: Date, end: Date) -> ValidationError? {
        if end < start {
            return .invalidDateRange(start: start, end: end)
        }
        return nil
    }
    
    /// Validates that a date is not in the past (for due dates).
    /// - Parameter date: The date to validate
    /// - Returns: Validation error if invalid, nil if valid
    public static func validateDateNotInPast(_ date: Date) -> ValidationError? {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dateToCheck = calendar.startOfDay(for: date)
        
        if dateToCheck < today {
            return .dateInPast
        }
        return nil
    }
    
    /// Sanitizes a string by removing potentially dangerous characters.
    /// - Parameter input: The string to sanitize
    /// - Returns: Sanitized string
    public static func sanitize(_ input: String) -> String {
        // Remove control characters except newlines and tabs
        let allowed = CharacterSet.whitespacesAndNewlines.union(.alphanumerics).union(.punctuationCharacters)
        return String(input.unicodeScalars.filter { allowed.contains($0) || $0 == "\n" || $0 == "\t" })
    }
    
    /// Truncates a string to a maximum length.
    /// - Parameters:
    ///   - input: The string to truncate
    ///   - maxLength: Maximum length
    /// - Returns: Truncated string
    public static func truncate(_ input: String, to maxLength: Int) -> String {
        guard input.count > maxLength else { return input }
        let index = input.index(input.startIndex, offsetBy: maxLength)
        return String(input[..<index]) + "..."
    }
}
