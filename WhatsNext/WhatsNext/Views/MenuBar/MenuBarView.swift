import SwiftUI
import SwiftData

struct MenuBarView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow

    @Query(
        filter: #Predicate<Goal> { goal in
            goal.categoryRaw == "daily" && goal.statusRaw != "archived" && goal.statusRaw != "completed"
        },
        sort: \Goal.sortOrder
    )
    private var todayGoals: [Goal]

    @Query(
        filter: #Predicate<Goal> { goal in
            goal.statusRaw != "archived" && goal.statusRaw != "completed"
        }
    )
    private var allActiveGoals: [Goal]

    @State private var showingQuickAdd = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("What's Next?")
                    .font(.headline)

                Spacer()

                Button(action: { showingQuickAdd.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            if showingQuickAdd {
                QuickAddGoalForm { goal in
                    modelContext.insert(goal)
                    try? modelContext.save()
                    showingQuickAdd = false
                }

                Divider()
            }

            // Stats row
            HStack(spacing: 16) {
                StatBadge(
                    icon: "sun.max",
                    count: todayGoals.count,
                    label: "Today"
                )

                StatBadge(
                    icon: "target",
                    count: allActiveGoals.count,
                    label: "Active"
                )

                StatBadge(
                    icon: "exclamationmark.triangle",
                    count: overdueCount,
                    label: "Overdue"
                )
            }
            .padding()

            Divider()

            // Today's goals
            ScrollView {
                VStack(spacing: 0) {
                    if todayGoals.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "checkmark.circle")
                                .font(.title)
                                .foregroundStyle(.green)
                            Text("All done for today!")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        ForEach(todayGoals) { goal in
                            MenuBarGoalRow(goal: goal)
                        }
                    }
                }
            }
            .frame(maxHeight: 300)

            Divider()

            // Footer
            HStack {
                Button("Open App") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first(where: { $0.title.contains("What's Next") }) {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
                .buttonStyle(.bordered)

                Spacer()

                Button(action: { NSApplication.shared.terminate(nil) }) {
                    Image(systemName: "power")
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding()
        }
        .frame(width: 320)
    }

    private var overdueCount: Int {
        allActiveGoals.filter { $0.isOverdue }.count
    }
}

struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text("\(count)")
                    .font(.title3.bold())
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MenuBarGoalRow: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    var body: some View {
        HStack(spacing: 8) {
            Button(action: toggleCompletion) {
                Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(goal.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(goal.title)
                    .font(.callout)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    PriorityDot(priority: goal.priority)

                    if let dueDate = goal.dueDate {
                        Text(dueDateText(dueDate))
                            .font(.caption2)
                            .foregroundStyle(goal.isOverdue ? .red : .secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .background(goal.isOverdue ? Color.red.opacity(0.05) : .clear)
    }

    private func toggleCompletion() {
        withAnimation {
            goal.toggleCompletion()
            try? modelContext.save()
        }
    }

    private func dueDateText(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

struct QuickAddGoalForm: View {
    let onSave: (Goal) -> Void

    @State private var title = ""
    @State private var category: GoalCategory = .daily
    @State private var priority: Priority = .medium

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            TextField("What do you want to accomplish?", text: $title)
                .textFieldStyle(.roundedBorder)
                .focused($isFocused)
                .onSubmit(save)

            HStack {
                Picker("Category", selection: $category) {
                    ForEach(GoalCategory.allCases) { cat in
                        Label(cat.shortName, systemImage: cat.icon).tag(cat)
                    }
                }
                .labelsHidden()
                .frame(width: 120)

                Picker("Priority", selection: $priority) {
                    ForEach(Priority.allCases) { p in
                        Text(p.displayName).tag(p)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 150)

                Spacer()

                Button("Add") { save() }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty)
            }
        }
        .padding()
        .onAppear { isFocused = true }
    }

    private func save() {
        guard !title.isEmpty else { return }

        let goal = Goal(
            title: title,
            category: category,
            priority: priority
        )
        onSave(goal)

        title = ""
    }
}

#Preview {
    MenuBarView()
        .modelContainer(for: [Goal.self], inMemory: true)
}
