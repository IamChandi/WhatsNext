//
//  ErrorHandler.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
import os.log
#if canImport(Combine)
import Combine
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(SwiftData)
import SwiftData
#endif

/// Centralized error handling for the WhatsNext application.
public enum AppError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case dataFetchFailed(Error)
    case deleteFailed(Error)
    case cloudKitSyncFailed(Error)
    case notificationFailed(Error)
    case invalidData(String)
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save changes. Please try again."
        case .fetchFailed:
            return "Failed to load data. Please refresh the app."
        case .dataFetchFailed:
            return "Failed to fetch data. Please try again."
        case .deleteFailed:
            return "Failed to delete item. Please try again."
        case .cloudKitSyncFailed:
            return "Failed to sync with iCloud. Please check your internet connection."
        case .notificationFailed:
            return "Failed to schedule notification. Please check notification permissions."
        case .invalidData(let message):
            return "Invalid data: \(message)"
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .saveFailed, .deleteFailed:
            return "Make sure you have sufficient storage space and try again."
        case .fetchFailed:
            return "Try restarting the app or checking your internet connection."
        case .cloudKitSyncFailed:
            return "Ensure you're signed in to iCloud and have an active internet connection."
        case .notificationFailed:
            return "Go to Settings > Notifications and enable notifications for WhatsNext."
        default:
            return "If the problem persists, please contact support."
        }
    }
}

/// Error handler utility for consistent error management.
#if canImport(Combine)
@MainActor
public final class ErrorHandler: ObservableObject {
    @Published public var showError = false
    public static let shared = ErrorHandler()
    
    public var errorMessage: String?
    private var errorRecovery: String?
    
    private init() {}
    
    /// Handles an error and shows user-friendly message.
    public func handle(_ error: AppError, context: String = "") {
        Logger.error.error("Error in \(context): \(error.localizedDescription)")
        
        if let underlyingError = error.underlyingError {
            Logger.error.error("Underlying error: \(underlyingError.localizedDescription)")
        }
        
        errorMessage = error.errorDescription
        errorRecovery = error.recoverySuggestion
        showError = true
    }
    
    /// Handles a generic error.
    public func handle(_ error: Error, context: String = "") {
        handle(.unknown(error), context: context)
    }
}
#else
@MainActor
public final class ErrorHandler {
    public var showError = false
    public static let shared = ErrorHandler()
    
    public var errorMessage: String?
    private var errorRecovery: String?
    
    private init() {}
    
    /// Handles an error and shows user-friendly message.
    public func handle(_ error: AppError, context: String = "") {
        Logger.error.error("Error in \(context): \(error.localizedDescription)")
        
        if let underlyingError = error.underlyingError {
            Logger.error.error("Underlying error: \(underlyingError.localizedDescription)")
        }
        
        errorMessage = error.errorDescription
        errorRecovery = error.recoverySuggestion
        showError = true
    }
    
    /// Handles a generic error.
    public func handle(_ error: Error, context: String = "") {
        handle(.unknown(error), context: context)
    }
}
#endif

public extension AppError {
    var underlyingError: Error? {
        switch self {
        case .saveFailed(let error),
             .fetchFailed(let error),
             .dataFetchFailed(let error),
             .deleteFailed(let error),
             .cloudKitSyncFailed(let error),
             .notificationFailed(let error),
             .unknown(let error):
            return error
        case .invalidData:
            return nil
        }
    }
}

#if canImport(SwiftUI)
/// View modifier for displaying errors.
struct ErrorAlertModifier: ViewModifier {
    @StateObject private var errorHandler = ErrorHandler.shared
    
    func body(content: Content) -> some View {
        content
            .alert("Error", isPresented: $errorHandler.showError) {
                Button("OK") {
                    errorHandler.showError = false
                }
            } message: {
                if let message = errorHandler.errorMessage {
                    Text(message)
                }
            }
    }
}

public extension View {
    /// Adds error handling to a view.
    func withErrorHandling() -> some View {
        modifier(ErrorAlertModifier())
    }
}
#endif