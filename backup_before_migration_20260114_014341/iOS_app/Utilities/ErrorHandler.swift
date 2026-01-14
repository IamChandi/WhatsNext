//
//  ErrorHandler.swift
//  WhatsNextiOS
//
//  Centralized error handling and user feedback.
//

import Foundation
import SwiftUI
import SwiftData
import os.log

/// Centralized error handling for the WhatsNext iOS application.
enum AppError: LocalizedError {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
    case cloudKitSyncFailed(Error)
    case notificationFailed(Error)
    case invalidData(String)
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "Failed to save changes. Please try again."
        case .fetchFailed:
            return "Failed to load data. Please refresh the app."
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
    
    var recoverySuggestion: String? {
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
@MainActor
final class ErrorHandler: ObservableObject {
    static let shared = ErrorHandler()
    
    @Published var errorMessage: String?
    @Published var errorRecovery: String?
    @Published var showError = false
    
    private init() {}
    
    /// Handles an error and shows user-friendly message.
    func handle(_ error: AppError, context: String = "") {
        Logger.error.error("Error in \(context): \(error.localizedDescription)")
        
        if let underlyingError = error.underlyingError {
            Logger.error.error("Underlying error: \(underlyingError.localizedDescription)")
        }
        
        errorMessage = error.errorDescription
        errorRecovery = error.recoverySuggestion
        showError = true
    }
    
    /// Handles a generic error.
    func handle(_ error: Error, context: String = "") {
        handle(.unknown(error), context: context)
    }
}

extension AppError {
    var underlyingError: Error? {
        switch self {
        case .saveFailed(let error),
             .fetchFailed(let error),
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

extension View {
    /// Adds error handling to a view.
    func withErrorHandling() -> some View {
        modifier(ErrorAlertModifier())
    }
}
