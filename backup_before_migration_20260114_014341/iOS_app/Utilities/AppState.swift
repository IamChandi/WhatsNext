import Foundation
import Combine
import SwiftUI

/// Centralized application state management using Combine publishers.
/// Replaces NotificationCenter with type-safe, reactive state management.
@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()
    
    // MARK: - Publishers
    
    /// Publisher for when goals are updated (triggers UI refresh).
    @Published var goalsUpdated: Bool = false
    
    /// Publisher for when a new goal is created.
    @Published var newGoalCreated: Bool = false
    
    /// Publisher for showing help view.
    @Published var showHelp: Bool = false
    
    /// Publisher for focusing the quick entry field.
    @Published var focusQuickEntry: Bool = false
    
    /// Publisher for completing a goal from notification.
    @Published var completeGoalId: UUID? = nil
    
    /// Publisher for snoozing a goal from notification.
    @Published var snoozeGoalId: UUID? = nil
    
    /// Publisher for opening a goal from notification.
    @Published var openGoalId: UUID? = nil
    
    private init() {}
    
    // MARK: - Actions
    
    /// Notifies that goals have been updated.
    func notifyGoalsUpdated() {
        goalsUpdated.toggle()
    }
    
    /// Notifies that a new goal was created.
    func notifyNewGoalCreated() {
        newGoalCreated.toggle()
    }
    
    /// Shows the help view.
    func showHelpView() {
        showHelp = true
    }
    
    /// Hides the help view.
    func hideHelpView() {
        showHelp = false
    }
    
    /// Focuses the quick entry field.
    func focusQuickEntryField() {
        focusQuickEntry.toggle()
    }
    
    /// Completes a goal from notification.
    func completeGoal(id: UUID) {
        completeGoalId = id
    }
    
    /// Snoozes a goal from notification.
    func snoozeGoal(id: UUID) {
        snoozeGoalId = id
    }
    
    /// Opens a goal from notification.
    func openGoal(id: UUID) {
        openGoalId = id
    }
}
