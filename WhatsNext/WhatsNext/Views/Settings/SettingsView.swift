import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            NotificationsSettingsTab()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }

            KeyboardShortcutsTab()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }

            AppearanceTab()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }

            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsTab: View {
    @AppStorage("defaultCategory") private var defaultCategory = GoalCategory.daily.rawValue
    @AppStorage("defaultViewMode") private var defaultViewMode = ViewMode.checklist.rawValue
    @AppStorage("showCompletedGoals") private var showCompletedGoals = true
    @AppStorage("menuBarEnabled") private var menuBarEnabled = true
    @AppStorage("launchAtLogin") private var launchAtLogin = false

    var body: some View {
        Form {
            Section {
                Picker("Default category for new goals", selection: $defaultCategory) {
                    ForEach(GoalCategory.allCases) { cat in
                        Text(cat.displayName).tag(cat.rawValue)
                    }
                }

                Picker("Default view mode", selection: $defaultViewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Text(mode.displayName).tag(mode.rawValue)
                    }
                }
            }

            Section {
                Toggle("Show completed goals in lists", isOn: $showCompletedGoals)
                Toggle("Show in menu bar", isOn: $menuBarEnabled)
                Toggle("Launch at login", isOn: $launchAtLogin)
            }

            Section {
                Button("Reset All Settings") {
                    resetSettings()
                }
                .foregroundStyle(.red)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func resetSettings() {
        defaultCategory = GoalCategory.daily.rawValue
        defaultViewMode = ViewMode.checklist.rawValue
        showCompletedGoals = true
        menuBarEnabled = true
        launchAtLogin = false
    }
}

struct NotificationsSettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dueDateReminders") private var dueDateReminders = true
    @AppStorage("reminderAdvanceTime") private var reminderAdvanceTime = 15
    @AppStorage("playSounds") private var playSounds = true

    @State private var notificationStatus = "Checking..."

    var body: some View {
        Form {
            Section {
                Toggle("Enable notifications", isOn: $notificationsEnabled)

                if notificationsEnabled {
                    Toggle("Due date reminders", isOn: $dueDateReminders)

                    if dueDateReminders {
                        Picker("Remind me", selection: $reminderAdvanceTime) {
                            Text("5 minutes before").tag(5)
                            Text("15 minutes before").tag(15)
                            Text("30 minutes before").tag(30)
                            Text("1 hour before").tag(60)
                            Text("1 day before").tag(1440)
                        }
                    }

                    Toggle("Play sounds", isOn: $playSounds)
                }
            }

            Section {
                HStack {
                    Text("Notification Status")
                    Spacer()
                    Text(notificationStatus)
                        .foregroundStyle(.secondary)
                }

                Button("Open System Notifications Settings") {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .task {
            await checkNotificationStatus()
        }
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .authorized:
            notificationStatus = "Enabled"
        case .denied:
            notificationStatus = "Denied - Enable in System Settings"
        case .notDetermined:
            notificationStatus = "Not configured"
        case .provisional:
            notificationStatus = "Provisional"
        case .ephemeral:
            notificationStatus = "Ephemeral"
        @unknown default:
            notificationStatus = "Unknown"
        }
    }
}

struct KeyboardShortcutsTab: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                ShortcutSection(title: "Navigation") {
                    ShortcutRow(keys: "⌘1", description: "Move to Daily")
                    ShortcutRow(keys: "⌘2", description: "Move to Weekly")
                    ShortcutRow(keys: "⌘3", description: "Move to Monthly")
                    ShortcutRow(keys: "⌘4", description: "Move to What's Next?")
                }

                ShortcutSection(title: "Goals") {
                    ShortcutRow(keys: "⌘N", description: "New goal")
                    ShortcutRow(keys: "⌘⏎", description: "Toggle completion")
                    ShortcutRow(keys: "⌘⌫", description: "Delete goal")
                    ShortcutRow(keys: "⇧⌘F", description: "Focus mode")
                }

                ShortcutSection(title: "Views") {
                    ShortcutRow(keys: "⌃⌘L", description: "List view")
                    ShortcutRow(keys: "⌃⌘B", description: "Board view")
                    ShortcutRow(keys: "⌘F", description: "Search")
                }

                ShortcutSection(title: "Window") {
                    ShortcutRow(keys: "⌘,", description: "Preferences")
                    ShortcutRow(keys: "⌘W", description: "Close window")
                    ShortcutRow(keys: "⌘Q", description: "Quit")
                }
            }
            .padding()
        }
    }
}

struct ShortcutSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            VStack(spacing: 4) {
                content
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ShortcutRow: View {
    let keys: String
    let description: String

    var body: some View {
        HStack {
            Text(keys)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 4))

            Text(description)
                .foregroundStyle(.secondary)

            Spacer()
        }
    }
}

struct AppearanceTab: View {
    @AppStorage("accentColorChoice") private var accentColorChoice = "system"

    private let accentOptions = [
        ("system", "System"),
        ("blue", "Blue"),
        ("purple", "Purple"),
        ("pink", "Pink"),
        ("red", "Red"),
        ("orange", "Orange"),
        ("green", "Green")
    ]

    var body: some View {
        Form {
            Section {
                Picker("Accent Color", selection: $accentColorChoice) {
                    ForEach(accentOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }

                Text("Note: Appearance follows your system settings. To change light/dark mode, use System Settings > Appearance.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct AboutTab: View {
    @State private var showingHelp = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("What's Next?")
                .font(.title.bold())

            Text("Version 1.0.0")
                .foregroundStyle(.secondary)

            Text("A goal tracking app to help you stay focused on what matters most.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 8) {
                Text("Built with <3 by Chandi Kodthiwada")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Link(destination: URL(string: "https://www.linkedin.com/in/chandikodthiwada/")!) {
                        Label("LinkedIn", systemImage: "link")
                    }
                    
                    Link(destination: URL(string: "https://github.com/IamChandi")!) {
                        Label("GitHub", systemImage: "network")
                    }
                }
                .font(.caption)
            }
            .padding(.top, 8)
            
            Divider()
                .padding(.vertical, 8)
            
            Button(action: { showingHelp = true }) {
                Label("View Help Documentation", systemImage: "questionmark.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.presidentialBlue)

            Spacer()

            Text("Made with SwiftUI")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
}

#Preview {
    SettingsView()
}
