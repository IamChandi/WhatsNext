import SwiftUI
import SwiftData
import WhatsNextShared

struct GoalDetailInspector: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal
    var onClose: () -> Void = {}

    @State private var showingAlertSheet = false
    @State private var showingRecurrenceSheet = false
    @State private var newSubtaskTitle = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection

                Divider()

                // Details
                detailsSection

                Divider()

                // Subtasks
                subtasksSection

                Divider()

                // Notes
                notesSection

                Divider()

                // Alerts
                alertsSection

                if goal.recurrence != nil {
                    Divider()
                    recurrenceSection
                }

                Divider()

                // Actions
                actionsSection
            }
            .padding()
        }
        .frame(minWidth: 280, idealWidth: 320)
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingAlertSheet) {
            AlertSchedulerSheet(goal: goal)
        }
        .sheet(isPresented: $showingRecurrenceSheet) {
            RecurrencePickerSheet(goal: goal)
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundStyle(goal.category.color)
                Text(goal.category.shortName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if goal.isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            TextField("Title", text: $goal.title, axis: .vertical)
                .font(.title2.bold())
                .textFieldStyle(.plain)
                .onChange(of: goal.title) { _, _ in
                    goal.updatedAt = Date()
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalDetailInspector")
                    }
                }

            TextField("Add description...", text: Binding(
                get: { goal.goalDescription ?? "" },
                set: { goal.goalDescription = $0.isEmpty ? nil : $0 }
            ), axis: .vertical)
            .font(.body)
            .foregroundStyle(.secondary)
            .textFieldStyle(.plain)
            .onChange(of: goal.goalDescription) { _, _ in
                goal.updatedAt = Date()
                try? modelContext.save()
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)

            // Priority
            HStack {
                Label("Priority", systemImage: "flag")
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Priority", selection: $goal.priority) {
                    ForEach(Priority.allCases) { priority in
                        Text(priority.displayName).tag(priority)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: goal.priority) { _, _ in
                    goal.updatedAt = Date()
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalDetailInspector")
                    }
                }
            }

            // Category
            HStack {
                Label("Category", systemImage: "folder")
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Category", selection: $goal.category) {
                    ForEach(GoalCategory.allCases) { cat in
                        Label(cat.shortName, systemImage: cat.icon).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .onChange(of: goal.category) { _, _ in
                    goal.updatedAt = Date()
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalDetailInspector")
                    }
                }
            }

            // Due Date
            HStack {
                Label("Due Date", systemImage: "calendar")
                    .foregroundStyle(.secondary)
                Spacer()
                if let dueDate = goal.dueDate {
                    DatePicker("", selection: Binding(
                        get: { dueDate },
                        set: { goal.dueDate = $0 }
                    ), displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .onChange(of: goal.dueDate) { _, _ in
                        goal.updatedAt = Date()
                        if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalDetailInspector")
                    }
                    }

                    Button(action: { goal.dueDate = nil; try? modelContext.save() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button("Add Due Date") {
                        goal.dueDate = Date()
                        if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalDetailInspector")
                    }
                    }
                    .buttonStyle(.bordered)
                }
            }

            // Tags
            HStack(alignment: .top) {
                Label("Tags", systemImage: "tag")
                    .foregroundStyle(.secondary)
                Spacer()
                if let tags = goal.tags, !tags.isEmpty {
                    FlowLayout(spacing: 4) {
                        ForEach(tags) { tag in
                            TagChip(tag: tag) {
                                removeTag(tag)
                            }
                        }
                    }
                } else {
                    Text("No tags")
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Subtasks")
                    .font(.headline)
                Spacer()
                if let subtasks = goal.subtasks, !subtasks.isEmpty {
                    Text("\(subtasks.filter(\.isCompleted).count)/\(subtasks.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                ForEach(goal.sortedSubtasks) { subtask in
                    SubtaskRow(subtask: subtask) {
                        deleteSubtask(subtask)
                    }
                }

                HStack {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.secondary)
                    TextField("Add subtask...", text: $newSubtaskTitle)
                        .textFieldStyle(.plain)
                        .onSubmit(addSubtask)
                }
                .padding(.vertical, 4)
            }
        }
    }

    @State private var showingNoteEditor = false
    @State private var selectedNote: Note?
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Notes")
                    .font(.headline)
                Spacer()
                Button(action: { 
                    selectedNote = nil
                    showingNoteEditor = true 
                }) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.plain)
            }

            if goal.sortedNotes.isEmpty {
                Text("No notes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: 8) {
                    ForEach(goal.sortedNotes) { note in
                        NoteRowView(note: note)
                            .onTapGesture {
                                selectedNote = note
                                showingNoteEditor = true
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorSheet(note: selectedNote, goal: goal) { note in
                try? modelContext.save()
            }
        }
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Alerts")
                    .font(.headline)
                Spacer()
                Button(action: { showingAlertSheet = true }) {
                    Image(systemName: "plus.circle")
                }
                .buttonStyle(.plain)
            }

            if goal.sortedAlerts.isEmpty {
                Text("No alerts scheduled")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(goal.sortedAlerts) { alert in
                    AlertRow(alert: alert) {
                        deleteAlert(alert)
                    }
                }
            }
        }
    }

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recurrence")
                    .font(.headline)
                Spacer()
                Button(action: { showingRecurrenceSheet = true }) {
                    Image(systemName: "pencil.circle")
                }
                .buttonStyle(.plain)
            }

            if let recurrence = goal.recurrence {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundStyle(.secondary)
                    Text(recurrence.displayDescription)
                        .font(.callout)
                    Spacer()
                    Button(action: removeRecurrence) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 8) {
            if !goal.isCompleted {
                Button(action: { showingRecurrenceSheet = true }) {
                    Label("Set Recurrence", systemImage: "repeat")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            Button(action: toggleCompletion) {
                Label(
                    goal.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: goal.isCompleted ? "circle" : "checkmark.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(goal.isCompleted ? .secondary : .green)

            HStack {
                Button(action: archiveGoal) {
                    Label("Archive", systemImage: "archivebox")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive, action: deleteGoal) {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            // Metadata
            VStack(alignment: .leading, spacing: 4) {
                Text("Created: \(goal.createdAt.formatted())")
                Text("Updated: \(goal.updatedAt.formatted())")
                if let completedAt = goal.completedAt {
                    Text("Completed: \(completedAt.formatted())")
                }
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
        }
    }

    // MARK: - Actions

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }

        let subtask = Subtask(
            title: newSubtaskTitle,
            sortOrder: (goal.subtasks?.count ?? 0)
        )
        subtask.goal = goal

        if goal.subtasks == nil {
            goal.subtasks = []
        }
        goal.subtasks?.append(subtask)
        goal.updatedAt = Date()

        newSubtaskTitle = ""
        try? modelContext.save()
    }

    private func deleteSubtask(_ subtask: Subtask) {
        goal.subtasks?.removeAll { $0.id == subtask.id }
        modelContext.delete(subtask)
        goal.updatedAt = Date()
        try? modelContext.save()
    }

    private func deleteAlert(_ alert: GoalAlert) {
        goal.alerts?.removeAll { $0.id == alert.id }
        modelContext.delete(alert)
        goal.updatedAt = Date()
        try? modelContext.save()
    }

    private func removeTag(_ tag: Tag) {
        goal.tags?.removeAll { $0.id == tag.id }
        goal.updatedAt = Date()
        try? modelContext.save()
    }

    private func removeRecurrence() {
        if let recurrence = goal.recurrence {
            modelContext.delete(recurrence)
            goal.recurrence = nil
            goal.updatedAt = Date()
            try? modelContext.save()
        }
    }

    private func toggleCompletion() {
        withAnimation {
            goal.toggleCompletion()
            try? modelContext.save()
        }
    }

    private func archiveGoal() {
        goal.archive()
        try? modelContext.save()
    }

    private func deleteGoal() {
        modelContext.delete(goal)
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct SubtaskRow: View {
    @Bindable var subtask: Subtask
    let onDelete: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack {
            Button(action: { subtask.toggle() }) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(subtask.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .strikethrough(subtask.isCompleted)
                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)

            Spacer()

            if isHovering {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}

struct AlertRow: View {
    let alert: GoalAlert
    let onDelete: () -> Void

    var body: some View {
        HStack {
            Image(systemName: alert.isPast ? "bell.slash" : "bell.fill")
                .foregroundStyle(alert.isPast ? Color.secondary : Color.orange)

            VStack(alignment: .leading) {
                Text(alert.scheduledDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.callout)
                if let message = alert.message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
    }
}

struct TagChip: View {
    let tag: Tag
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.name)
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(tag.color.opacity(0.15))
        .foregroundStyle(tag.color)
        .clipShape(Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                x += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            }
            height = y + rowHeight
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Goal.self, Subtask.self, Tag.self, GoalAlert.self, RecurrenceRule.self, configurations: config)

    let goal = Goal(title: "Sample Goal", category: .daily, priority: .high)
    goal.dueDate = Date()
    goal.goalDescription = "This is a sample description"
    container.mainContext.insert(goal)

    return GoalDetailInspector(goal: goal)
        .modelContainer(container)
        .frame(width: 320)
}
