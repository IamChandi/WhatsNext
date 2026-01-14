//
//  WhatsNextApp.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData
// TODO: After adding package dependency in Xcode, uncomment:
// import WhatsNextShared
import os.log

/// Modern color palette and styling constants for the WhatsNext iOS application.
/// Follows iOS design guidelines with semantic colors and adaptive styling.
struct Theme {
    // MARK: - Brand Colors
    static let primary = Color(red: 26/255, green: 54/255, blue: 93/255) // Presidential Blue
    static let accent = Color(red: 237/255, green: 137/255, blue: 54/255) // Forward Orange
    
    // MARK: - Semantic Colors (Adaptive)
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    static let cardBackground = Color(uiColor: .secondarySystemBackground)
    
    // MARK: - Text Colors (Adaptive)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(uiColor: .tertiaryLabel)
    
    // MARK: - Legacy Support (Deprecated - use semantic colors instead)
    static let presidentialBlue = primary
    static let forwardOrange = accent
    static let offWhite = background
    static let sidebarText = Color.white.opacity(0.9)
    static let sidebarIcon = Color.white.opacity(0.7)
    
    // MARK: - Gradients
    static let primaryGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 26/255, green: 54/255, blue: 93/255),
            Color(red: 44/255, green: 82/255, blue: 130/255)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Material Effects
    static func cardMaterial() -> some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
            .fill(.regularMaterial)
    }
    
    static func thinMaterial() -> some View {
        Rectangle()
            .fill(.thinMaterial)
    }
}

extension Notification.Name {
    static let newGoal = Notification.Name("newGoal")
    static let openGoal = Notification.Name("openGoal")
    static let completeGoal = Notification.Name("completeGoal")
    static let snoozeGoal = Notification.Name("snoozeGoal")
    static let toggleCompletion = Notification.Name("toggleCompletion")
    static let toggleFocusMode = Notification.Name("toggleFocusMode")
    static let goalsUpdated = Notification.Name("goalsUpdated")
    static let moveToCategory = Notification.Name("moveToCategory")
    static let switchViewMode = Notification.Name("switchViewMode")
    static let focusQuickEntry = Notification.Name("focusQuickEntry")
    static let showHelp = Notification.Name("showHelp")
}

@main
struct WhatsNextApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Goal.self,
            Subtask.self,
            Tag.self,
            GoalAlert.self,
            RecurrenceRule.self,
            HistoryEntry.self,
            Note.self
        ])
        
        // Configure for CloudKit sync
        // Container identifier comes from entitlements file (iCloud.com.chandi.WhatsNext)
        Logger.app.info("🔍 Attempting to create ModelContainer with CloudKit...")
        Logger.network.info("📦 Using CloudKit container from entitlements: \(AppConstants.CloudKit.containerIdentifier)")
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            Logger.app.info("✅ ModelContainer created successfully with CloudKit")
            Logger.network.info("📱 CloudKit sync enabled - data will sync across devices")
            Logger.app.info("💡 Make sure both macOS and iOS apps use the same iCloud account")
            return container
        } catch {
            // Log detailed error for debugging
            Logger.error.error("❌ Failed to create ModelContainer with CloudKit: \(error.localizedDescription)")
            
            // Try fallback to local storage if CloudKit fails
            Logger.app.info("⚠️ Attempting fallback to local storage...")
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            do {
                let fallbackContainer = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfiguration]
                )
                Logger.app.info("✅ ModelContainer created with local storage (CloudKit unavailable)")
                return fallbackContainer
            } catch {
                // If fallback also fails, this is a critical error
                Logger.error.critical("❌ Critical: Failed to create ModelContainer even with local storage: \(error.localizedDescription)")
                fatalError("Could not create ModelContainer: \(error.localizedDescription)\n\nOriginal CloudKit error: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
