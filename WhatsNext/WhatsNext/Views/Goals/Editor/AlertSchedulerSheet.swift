import SwiftUI
import SwiftData
import WhatsNextShared

struct AlertSchedulerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var goal: Goal

    @State private var selectedDate = Date()
    @State private var message = ""
    @State private var selectedPreset: AlertPreset?

    enum AlertPreset: String, CaseIterable, Identifiable {
        case fiveMinutes = "5 minutes before"
        case fifteenMinutes = "15 minutes before"
        case thirtyMinutes = "30 minutes before"
        case oneHour = "1 hour before"
        case oneDay = "1 day before"
        case custom = "Custom time"

        var id: String { rawValue }

        var offset: TimeInterval? {
            switch self {
            case .fiveMinutes: return -5 * 60
            case .fifteenMinutes: return -15 * 60
            case .thirtyMinutes: return -30 * 60
            case .oneHour: return -60 * 60
            case .oneDay: return -24 * 60 * 60
            case .custom: return nil
            }
        }
    }

    private var presetOptions: [AlertPreset] {
        AlertPreset.allCases.filter { $0 != .custom }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text("Schedule Alert")
                    .font(.headline)

                Spacer()

                Button("Add") { addAlert() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 20) {
                // Goal info
                HStack {
                    Image(systemName: goal.category.icon)
                        .foregroundStyle(goal.category.color)
                    Text(goal.title)
                        .font(.headline)
                }

                if let dueDate = goal.dueDate {
                    // Presets based on due date
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Quick Options")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(presetOptions) { preset in
                            PresetButton(
                                preset: preset,
                                dueDate: dueDate,
                                selectedPreset: $selectedPreset,
                                selectedDate: $selectedDate
                            )
                        }
                    }

                    Divider()
                }

                // Custom date/time
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: { selectedPreset = .custom }) {
                        HStack {
                            Image(systemName: selectedPreset == .custom ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedPreset == .custom ? Color.accentColor : Color.secondary)
                            Text("Custom time")
                        }
                    }
                    .buttonStyle(.plain)

                    if selectedPreset == .custom || goal.dueDate == nil {
                        DatePicker(
                            "Alert time",
                            selection: $selectedDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .onChange(of: selectedDate) { _, _ in
                            selectedPreset = .custom
                        }
                    }
                }

                // Custom message
                VStack(alignment: .leading, spacing: 8) {
                    Text("Message (optional)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("Add a custom message...", text: $message)
                        .textFieldStyle(.roundedBorder)
                }

                // Existing alerts
                if let alerts = goal.alerts, !alerts.isEmpty {
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scheduled Alerts")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach(alerts.sorted { $0.scheduledDate < $1.scheduledDate }) { alert in
                            HStack {
                                Image(systemName: alert.isPast ? "bell.slash" : "bell.fill")
                                    .foregroundStyle(alert.isPast ? Color.secondary : Color.orange)

                                Text(alert.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.callout)

                                if let msg = alert.message, !msg.isEmpty {
                                    Text("- \(msg)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }

                                Spacer()

                                Button(action: { deleteAlert(alert) }) {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .onAppear {
            if let dueDate = goal.dueDate {
                // Default to 15 minutes before due date
                let defaultDate = dueDate.addingTimeInterval(-15 * 60)
                if defaultDate > Date() {
                    selectedDate = defaultDate
                    selectedPreset = .fifteenMinutes
                }
            }
        }
    }

    private func addAlert() {
        let alert = GoalAlert(
            scheduledDate: selectedDate,
            message: message.isEmpty ? nil : message
        )
        alert.goal = goal

        if goal.alerts == nil {
            goal.alerts = []
        }
        goal.alerts?.append(alert)
        goal.updatedAt = Date()

        // Schedule the notification
        Task {
            await NotificationService.shared.scheduleAlert(for: goal, alert: alert)
        }

        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "AlertSchedulerSheet.save")
        } else {
            dismiss()
        }
    }

    private func deleteAlert(_ alert: GoalAlert) {
        // Cancel the notification
        if let identifier = alert.notificationIdentifier {
            NotificationService.shared.cancelAlert(identifier: identifier)
        }

        goal.alerts?.removeAll { $0.id == alert.id }
        modelContext.delete(alert)
        goal.updatedAt = Date()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "AlertSchedulerSheet.delete")
            }
        }
}

struct PresetButton: View {
    let preset: AlertSchedulerSheet.AlertPreset
    let dueDate: Date
    @Binding var selectedPreset: AlertSchedulerSheet.AlertPreset?
    @Binding var selectedDate: Date

    private var alertDate: Date? {
        guard let offset = preset.offset else { return nil }
        let date = dueDate.addingTimeInterval(offset)
        return date > Date() ? date : nil
    }

    private var isSelected: Bool {
        selectedPreset == preset
    }

    var body: some View {
        Group {
            if let alertDate = alertDate {
                Button {
                    selectedPreset = preset
                    selectedDate = alertDate
                } label: {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isSelected ? Color.accentColor : Color.secondary)
                        Text(preset.rawValue)
                        Spacer()
                        Text(alertDate.formatted(date: .abbreviated, time: .shortened))
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, GoalAlert.self, configurations: config)

    let goal = Goal(title: "Sample Goal", category: .daily)
    goal.dueDate = Date().addingTimeInterval(3600)
    container.mainContext.insert(goal)

    return AlertSchedulerSheet(goal: goal)
        .modelContainer(container)
}
