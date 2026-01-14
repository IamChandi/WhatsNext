import SwiftUI
import SwiftData
import WhatsNextShared

struct GoalEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let existingGoal: Goal?
    let category: GoalCategory
    let onSave: (Goal) -> Void

    @State private var title = ""
    @State private var description = ""
    @State private var priority: Priority = .medium
    @State private var selectedCategory: GoalCategory
    @State private var dueDate: Date?
    @State private var hasDueDate = false
    @State private var subtasks: [SubtaskDraft] = []
    @State private var newSubtaskTitle = ""

    @Query private var allTags: [Tag]
    @State private var selectedTags: Set<UUID> = []

    init(goal: Goal? = nil, category: GoalCategory, onSave: @escaping (Goal) -> Void) {
        self.existingGoal = goal
        self.category = category
        self.onSave = onSave
        _selectedCategory = State(initialValue: goal?.category ?? category)

        if let goal = goal {
            _title = State(initialValue: goal.title)
            _description = State(initialValue: goal.goalDescription ?? "")
            _priority = State(initialValue: goal.priority)
            _dueDate = State(initialValue: goal.dueDate)
            _hasDueDate = State(initialValue: goal.dueDate != nil)
            _subtasks = State(initialValue: goal.sortedSubtasks.map { SubtaskDraft(title: $0.title, isCompleted: $0.isCompleted) })
            _selectedTags = State(initialValue: Set(goal.tags?.map(\.id) ?? []))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text(existingGoal == nil ? "New Goal" : "Edit Goal")
                    .font(.headline)

                Spacer()

                Button("Save") { saveGoal() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(title.isEmpty)
                    .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Title")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("What do you want to accomplish?", text: $title)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        TextField("Add more details...", text: $description, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                    }

                    // Category & Priority
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Category")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(GoalCategory.allCases) { cat in
                                    Label(cat.shortName, systemImage: cat.icon).tag(cat)
                                }
                            }
                            .labelsHidden()
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Priority")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Picker("Priority", selection: $priority) {
                                ForEach(Priority.allCases) { p in
                                    Text(p.displayName).tag(p)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    // Due Date
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Due Date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Toggle("", isOn: $hasDueDate)
                                .labelsHidden()
                                .onChange(of: hasDueDate) { _, newValue in
                                    if newValue && dueDate == nil {
                                        dueDate = Date()
                                    }
                                }
                        }

                        if hasDueDate {
                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { dueDate ?? Date() },
                                    set: { dueDate = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .labelsHidden()
                        }
                    }

                    // Subtasks
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Subtasks")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        ForEach($subtasks) { $subtask in
                            HStack {
                                Button(action: { subtask.isCompleted.toggle() }) {
                                    Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(subtask.isCompleted ? .green : .secondary)
                                }
                                .buttonStyle(.plain)

                                TextField("Subtask", text: $subtask.title)
                                    .textFieldStyle(.plain)

                                Button(action: { subtasks.removeAll { $0.id == subtask.id } }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 4)
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

                    // Tags
                    if !allTags.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            FlowLayout(spacing: 8) {
                                ForEach(allTags) { tag in
                                    TagToggleButton(
                                        tag: tag,
                                        isSelected: selectedTags.contains(tag.id)
                                    ) {
                                        if selectedTags.contains(tag.id) {
                                            selectedTags.remove(tag.id)
                                        } else {
                                            selectedTags.insert(tag.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
    }

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        subtasks.append(SubtaskDraft(title: newSubtaskTitle))
        newSubtaskTitle = ""
    }

    private func saveGoal() {
        if let existingGoal = existingGoal {
            // Update existing goal
            existingGoal.title = title
            existingGoal.goalDescription = description.isEmpty ? nil : description
            existingGoal.category = selectedCategory
            existingGoal.priority = priority
            existingGoal.dueDate = hasDueDate ? dueDate : nil
            existingGoal.updatedAt = Date()

            // Update subtasks
            existingGoal.subtasks?.forEach { modelContext.delete($0) }
            existingGoal.subtasks = subtasks.filter { !$0.title.isEmpty }.enumerated().map { index, draft in
                let subtask = Subtask(title: draft.title, sortOrder: index)
                subtask.isCompleted = draft.isCompleted
                return subtask
            }

            // Update tags
            existingGoal.tags = allTags.filter { selectedTags.contains($0.id) }

            if !modelContext.saveWithErrorHandling() {
                ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "GoalEditorSheet.save")
            } else {
                dismiss()
            }
        } else {
            // Create new goal
            let goal = Goal(
                title: title,
                goalDescription: description.isEmpty ? nil : description,
                category: selectedCategory,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil
            )

            goal.subtasks = subtasks.filter { !$0.title.isEmpty }.enumerated().map { index, draft in
                let subtask = Subtask(title: draft.title, sortOrder: index)
                subtask.isCompleted = draft.isCompleted
                return subtask
            }

            goal.tags = allTags.filter { selectedTags.contains($0.id) }

            onSave(goal)
            dismiss()
        }
    }
}

struct SubtaskDraft: Identifiable {
    let id = UUID()
    var title: String
    var isCompleted: Bool = false
}

struct TagToggleButton: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                }
                Text(tag.name)
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? tag.color.opacity(0.2) : Color.secondary.opacity(0.1))
            .foregroundStyle(isSelected ? tag.color : .secondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    GoalEditorSheet(category: .daily) { _ in }
        .modelContainer(for: [Goal.self, Subtask.self, Tag.self], inMemory: true)
}
