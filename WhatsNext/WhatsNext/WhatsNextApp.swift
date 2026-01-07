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
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
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


