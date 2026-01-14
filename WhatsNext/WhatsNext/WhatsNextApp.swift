//
//  WhatsNextApp.swift
//  WhatsNext
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData
import os.log
import WhatsNextShared

/// Defines the color palette and styling constants for the WhatsNext application.
struct Theme {
    static let presidentialBlue = Color(red: 26/255, green: 54/255, blue: 93/255)
    static let forwardOrange = Color(red: 237/255, green: 137/255, blue: 54/255)
    static let offWhite = Color(nsColor: .windowBackgroundColor)
    static let cardBackground = Color(nsColor: .textBackgroundColor)
    static let sidebarText = Color.white.opacity(0.9)
    static let sidebarIcon = Color.white.opacity(0.7)
    
    static let ovalOfficeGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 26/255, green: 54/255, blue: 93/255),
            Color(red: 44/255, green: 82/255, blue: 130/255)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
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
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
        
        // Try CloudKit first (since user has paid account)
        Logger.app.info("🔍 Attempting to create ModelContainer with CloudKit...")
        let cloudKitConfiguration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [cloudKitConfiguration]
            )
            Logger.app.info("✅ ModelContainer created successfully with CloudKit")
            Logger.network.info("📱 CloudKit sync enabled - data will sync across devices")
            return container
        } catch let cloudKitError {
            Logger.error.error("❌ CloudKit failed: \(cloudKitError.localizedDescription)")
            Logger.app.info("⚠️ Falling back to local storage...")
            
            // Fallback to local storage if CloudKit fails
            let fallbackConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            do {
                let container = try ModelContainer(
                    for: schema,
                    configurations: [fallbackConfiguration]
                )
                Logger.app.info("✅ ModelContainer created successfully with local storage")
                return container
            } catch let localError {
            Logger.error.error("❌ Local storage failed: \(localError.localizedDescription)")
            if let nsError = localError as NSError? {
                Logger.error.error("   Domain: \(nsError.domain), Code: \(nsError.code)")
                Logger.error.error("   UserInfo: \(nsError.userInfo)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                    Logger.error.error("   Underlying error: \(underlyingError.localizedDescription)")
                    Logger.error.error("   Underlying domain: \(underlyingError.domain), code: \(underlyingError.code)")
                }
            }
            
            // Try in-memory as last resort
            Logger.app.info("⚠️ Attempting in-memory fallback...")
            do {
                let inMemoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                let inMemoryContainer = try ModelContainer(
                    for: schema,
                    configurations: [inMemoryConfiguration]
                )
                Logger.app.warning("✅ ModelContainer created with in-memory storage (data will not persist)")
                return inMemoryContainer
            } catch let inMemoryError {
                Logger.error.error("❌ In-memory also failed: \(inMemoryError.localizedDescription)")
                if let nsError = inMemoryError as NSError? {
                    Logger.error.error("   Domain: \(nsError.domain), Code: \(nsError.code)")
                    Logger.error.error("   UserInfo: \(nsError.userInfo)")
                }
                
                // Log all diagnostic information before crashing
                Logger.error.critical("❌ CRITICAL: All storage options failed!")
                Logger.error.critical("Please check the console output above to see which model failed.")
                Logger.error.critical("Common fixes:")
                Logger.error.critical("1. Delete any existing database files")
                Logger.error.critical("2. Check for unsupported property types in models")
                Logger.error.critical("3. Verify all relationships are properly configured")
                
                fatalError("Could not create ModelContainer. See console output above for details.")
            }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .commands {
            AppCommands()
        }

        MenuBarExtra("What's Next?", systemImage: "checkmark.circle.fill") {
            MenuBarView()
                .modelContainer(sharedModelContainer)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}

struct AppCommands: Commands {
    @Environment(\.openWindow) private var openWindow

    var body: some Commands {
        CommandGroup(after: .newItem) {
            Button("New Goal") {
                AppState.shared.notifyNewGoalCreated()
            }
            .keyboardShortcut("n", modifiers: .command)

            Divider()
        }

        CommandMenu("Goals") {
            Button("Move to Daily") {
                AppState.shared.moveToCategory(.daily)
            }
            .keyboardShortcut("1", modifiers: [.command, .shift])

            Button("Move to Weekly") {
                AppState.shared.moveToCategory(.weekly)
            }
            .keyboardShortcut("2", modifiers: [.command, .shift])

            Button("Move to Monthly") {
                AppState.shared.moveToCategory(.monthly)
            }
            .keyboardShortcut("3", modifiers: [.command, .shift])

            Button("Move to What's Next?") {
                AppState.shared.moveToCategory(.whatsNext)
            }
            .keyboardShortcut("4", modifiers: [.command, .shift])

            Divider()

            Button("Toggle Completion") {
                AppState.shared.toggleGoalCompletion()
            }
            .keyboardShortcut(.return, modifiers: .command)

            Button("Focus Mode") {
                AppState.shared.toggleFocusModeAction()
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("List View") {
                AppState.shared.switchToViewMode(.checklist)
            }
            .keyboardShortcut("l", modifiers: [.command, .control])

            Button("Board View") {
                AppState.shared.switchToViewMode(.kanban)
            }
            .keyboardShortcut("b", modifiers: [.command, .control])
        }
        
        CommandGroup(replacing: .help) {
            Button("What's Next? Help") {
                AppState.shared.showHelpView()
            }
            .keyboardShortcut("?", modifiers: .command)
            
            Divider()
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/IamChandi/WhatsNext")!)
            
            Link("Report an Issue", destination: URL(string: "https://github.com/IamChandi/WhatsNext/issues")!)
        }
    }
}


