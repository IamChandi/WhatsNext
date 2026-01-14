//
//  SettingsView.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            List {
                GeneralSettingsSection()
                NotificationsSettingsSection()
                AboutSection()
            }
            .navigationTitle("Settings")
        }
    }
}

struct GeneralSettingsSection: View {
    @AppStorage("defaultCategory") private var defaultCategory = GoalCategory.daily.rawValue
    @AppStorage("defaultViewMode") private var defaultViewMode = ViewMode.checklist.rawValue
    @AppStorage("showCompletedGoals") private var showCompletedGoals = true

    var body: some View {
        Section("General") {
            Picker("Default category", selection: $defaultCategory) {
                ForEach(GoalCategory.allCases) { cat in
                    Text(cat.displayName).tag(cat.rawValue)
                }
            }

            Picker("Default view mode", selection: $defaultViewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode.rawValue)
                }
            }

            Toggle("Show completed goals", isOn: $showCompletedGoals)
        }
    }
}

struct NotificationsSettingsSection: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("dueDateReminders") private var dueDateReminders = true
    @AppStorage("reminderAdvanceTime") private var reminderAdvanceTime = 15
    @AppStorage("playSounds") private var playSounds = true

    @State private var notificationStatus = "Checking..."

    var body: some View {
        Section("Notifications") {
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

            HStack {
                Text("Status")
                Spacer()
                Text(notificationStatus)
                    .foregroundStyle(.secondary)
            }

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
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
            notificationStatus = "Denied"
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

struct AboutSection: View {
    var body: some View {
        Section("About") {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(.secondary)
            }

            Link("GitHub Repository", destination: URL(string: "https://github.com/IamChandi/WhatsNext")!)

            Button {
                AppState.shared.showHelpView()
            } label: {
                HStack {
                    Text("Help & Documentation")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }

        Section {
            Text("Built with ❤️ by Chandi Kodthiwada")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
