import SwiftUI
import SwiftData
import WhatsNextShared

struct RecurrencePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var goal: Goal

    @State private var pattern: RecurrencePattern = .daily
    @State private var interval: Int = 1
    @State private var selectedDays: Set<Int> = []
    @State private var dayOfMonth: Int = 1
    @State private var hasEndDate = false
    @State private var endDate = Date().addingTimeInterval(30 * 24 * 60 * 60)

    private let weekdays = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text("Set Recurrence")
                    .font(.headline)

                Spacer()

                Button("Save") { saveRecurrence() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Goal info
                    HStack {
                        Image(systemName: goal.category.icon)
                            .foregroundStyle(goal.category.color)
                        Text(goal.title)
                            .font(.headline)
                    }

                    Divider()

                    // Pattern selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Picker("Pattern", selection: $pattern) {
                            ForEach(RecurrencePattern.allCases, id: \.self) { p in
                                Text(p.displayName).tag(p)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Interval
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Every")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Stepper(value: $interval, in: 1...99) {
                                Text("\(interval)")
                                    .frame(width: 40)
                            }

                            Text(intervalLabel)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Weekly options
                    if pattern == .weekly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("On days")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                ForEach(weekdays, id: \.0) { day in
                                    DayButton(
                                        label: day.1,
                                        isSelected: selectedDays.contains(day.0)
                                    ) {
                                        if selectedDays.contains(day.0) {
                                            selectedDays.remove(day.0)
                                        } else {
                                            selectedDays.insert(day.0)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Monthly options
                    if pattern == .monthly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("On day")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Stepper(value: $dayOfMonth, in: 1...31) {
                                Text("Day \(dayOfMonth)")
                            }
                        }
                    }

                    Divider()

                    // End date
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("End date", isOn: $hasEndDate)

                        if hasEndDate {
                            DatePicker(
                                "Ends on",
                                selection: $endDate,
                                in: Date()...,
                                displayedComponents: .date
                            )
                        }
                    }

                    // Preview
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Summary")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        HStack {
                            Image(systemName: "repeat")
                                .foregroundStyle(.secondary)
                            Text(previewText)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Remove recurrence
                    if goal.recurrence != nil {
                        Divider()

                        Button(role: .destructive, action: removeRecurrence) {
                            Label("Remove Recurrence", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
        .onAppear(perform: loadExisting)
    }

    private var intervalLabel: String {
        switch pattern {
        case .daily: return interval == 1 ? "day" : "days"
        case .weekly: return interval == 1 ? "week" : "weeks"
        case .monthly: return interval == 1 ? "month" : "months"
        case .custom: return interval == 1 ? "day" : "days"
        }
    }

    private var previewText: String {
        var text = ""

        switch pattern {
        case .daily:
            text = interval == 1 ? "Every day" : "Every \(interval) days"
        case .weekly:
            if interval == 1 {
                if selectedDays.isEmpty {
                    text = "Every week"
                } else {
                    let dayNames = selectedDays.sorted().compactMap { day in
                        weekdays.first { $0.0 == day }?.1
                    }
                    text = "Every \(dayNames.joined(separator: ", "))"
                }
            } else {
                text = "Every \(interval) weeks"
            }
        case .monthly:
            text = interval == 1 ? "Monthly on day \(dayOfMonth)" : "Every \(interval) months on day \(dayOfMonth)"
        case .custom:
            text = "Every \(interval) days"
        }

        if hasEndDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            text += " until \(formatter.string(from: endDate))"
        }

        return text
    }

    private func loadExisting() {
        guard let recurrence = goal.recurrence else { return }

        pattern = recurrence.pattern
        interval = recurrence.interval
        if let days = recurrence.daysOfWeek {
            selectedDays = Set(days)
        }
        if let day = recurrence.dayOfMonth {
            dayOfMonth = day
        }
        if let end = recurrence.endDate {
            hasEndDate = true
            endDate = end
        }
    }

    private func saveRecurrence() {
        // Remove existing recurrence if any
        if let existing = goal.recurrence {
            modelContext.delete(existing)
        }

        let recurrence = RecurrenceRule(
            pattern: pattern,
            interval: interval,
            daysOfWeek: pattern == .weekly && !selectedDays.isEmpty ? Array(selectedDays) : nil,
            dayOfMonth: pattern == .monthly ? dayOfMonth : nil,
            endDate: hasEndDate ? endDate : nil
        )
        recurrence.goal = goal
        goal.recurrence = recurrence
        goal.updatedAt = Date()

        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "RecurrencePickerSheet.save")
        } else {
            dismiss()
        }
    }

    private func removeRecurrence() {
        if let recurrence = goal.recurrence {
            modelContext.delete(recurrence)
            goal.recurrence = nil
            goal.updatedAt = Date()
            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "RecurrencePickerSheet.removeRecurrence")
            }
        }
        dismiss()
    }
}

struct DayButton: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .frame(width: 36, height: 36)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.1))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, RecurrenceRule.self, configurations: config)

    let goal = Goal(title: "Sample Goal", category: .daily)
    container.mainContext.insert(goal)

    return RecurrencePickerSheet(goal: goal)
        .modelContainer(container)
}
