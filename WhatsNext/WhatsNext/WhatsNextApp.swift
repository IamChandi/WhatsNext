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
            HistoryEntry.self
        ])
        
        // Try CloudKit first (since user has paid account)
        print("🔍 Attempting to create ModelContainer with CloudKit...")
        let cloudKitConfiguration = ModelConfiguration(
            schema: schema,
            cloudKitDatabase: .automatic
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [cloudKitConfiguration]
            )
            print("✅ ModelContainer created successfully with CloudKit")
            return container
        } catch let cloudKitError {
            print("❌ CloudKit failed: \(cloudKitError)")
            print("⚠️ Falling back to local storage...")
            
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
                print("✅ ModelContainer created successfully with local storage")
                return container
            } catch let localError {
            print("❌ Local storage failed: \(localError)")
            if let nsError = localError as NSError? {
                print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
                if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                    print("   Underlying error: \(underlyingError)")
                    print("   Underlying domain: \(underlyingError.domain), code: \(underlyingError.code)")
                    print("   Underlying userInfo: \(underlyingError.userInfo)")
                }
            }
            
            // Try in-memory as last resort
            print("⚠️ Attempting in-memory fallback...")
            do {
                let inMemoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                let inMemoryContainer = try ModelContainer(
                    for: schema,
                    configurations: [inMemoryConfiguration]
                )
                print("✅ ModelContainer created with in-memory storage (data will not persist)")
                return inMemoryContainer
            } catch let inMemoryError {
                print("❌ In-memory also failed: \(inMemoryError)")
                if let nsError = inMemoryError as NSError? {
                    print("   Domain: \(nsError.domain), Code: \(nsError.code)")
                    print("   UserInfo: \(nsError.userInfo)")
                }
                
                // Print all diagnostic information before crashing
                print("\n" + String(repeating: "=", count: 60))
                print("❌ CRITICAL: All storage options failed!")
                print(String(repeating: "=", count: 60))
                print("\nPlease check the console output above to see which model failed.")
                print("Look for lines starting with '❌' to identify the problematic model.")
                print("\nCommon fixes:")
                print("1. Delete any existing database files")
                print("2. Check for unsupported property types in models")
                print("3. Verify all relationships are properly configured")
                print(String(repeating: "=", count: 60) + "\n")
                
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
                NotificationCenter.default.post(name: .newGoal, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)

            Divider()
        }

        CommandMenu("Goals") {
            Button("Move to Daily") {
                NotificationCenter.default.post(name: .moveToCategory, object: GoalCategory.daily)
            }
            .keyboardShortcut("1", modifiers: [.command, .shift])

            Button("Move to Weekly") {
                NotificationCenter.default.post(name: .moveToCategory, object: GoalCategory.weekly)
            }
            .keyboardShortcut("2", modifiers: [.command, .shift])

            Button("Move to Monthly") {
                NotificationCenter.default.post(name: .moveToCategory, object: GoalCategory.monthly)
            }
            .keyboardShortcut("3", modifiers: [.command, .shift])

            Button("Move to What's Next?") {
                NotificationCenter.default.post(name: .moveToCategory, object: GoalCategory.whatsNext)
            }
            .keyboardShortcut("4", modifiers: [.command, .shift])

            Divider()

            Button("Toggle Completion") {
                NotificationCenter.default.post(name: .toggleCompletion, object: nil)
            }
            .keyboardShortcut(.return, modifiers: .command)

            Button("Focus Mode") {
                NotificationCenter.default.post(name: .toggleFocusMode, object: nil)
            }
            .keyboardShortcut("f", modifiers: [.command, .shift])
        }

        CommandMenu("View") {
            Button("List View") {
                NotificationCenter.default.post(name: .switchViewMode, object: ViewMode.checklist)
            }
            .keyboardShortcut("l", modifiers: [.command, .control])

            Button("Board View") {
                NotificationCenter.default.post(name: .switchViewMode, object: ViewMode.kanban)
            }
            .keyboardShortcut("b", modifiers: [.command, .control])
        }
        
        CommandGroup(replacing: .help) {
            Button("What's Next? Help") {
                NotificationCenter.default.post(name: .showHelp, object: nil)
            }
            .keyboardShortcut("?", modifiers: .command)
            
            Divider()
            
            Link("GitHub Repository", destination: URL(string: "https://github.com/IamChandi/WhatsNext")!)
            
            Link("Report an Issue", destination: URL(string: "https://github.com/IamChandi/WhatsNext/issues")!)
        }
    }
}


