//
//  GoalDetailView.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData

struct GoalDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var goal: Goal

    @State private var showingEditor = false
    @State private var showingAlertSheet = false
    @State private var showingRecurrenceSheet = false
    @State private var newSubtaskTitle = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
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

                    if goal.recurrence != nil {
                        Divider()
                        recurrenceSection
                    }

                    Divider()

                    // Actions
                    actionsSection
                }
                .padding(DesignSystem.Spacing.md)
            }
            .navigationTitle("Goal Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEditor = true
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEditor) {
                GoalEditorSheet(goal: goal, category: goal.category) { updatedGoal in
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "GoalDetailView")
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
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
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

            Text(goal.title)
                .font(DesignSystem.Typography.title2)

            if let description = goal.goalDescription, !description.isEmpty {
                Text(description)
                    .font(DesignSystem.Typography.body)
                    .foregroundStyle(Theme.secondaryText)
            }
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Details")
                .font(DesignSystem.Typography.headline)

            HStack {
                Label("Priority", systemImage: "exclamationmark.circle")
                Spacer()
                PriorityBadge(priority: goal.priority)
            }

            if let dueDate = goal.dueDate {
                HStack {
                    Label("Due Date", systemImage: "calendar")
                    Spacer()
                    DueDateBadge(date: dueDate, isOverdue: goal.isOverdue)
                }
            }

            if let tags = goal.tags, !tags.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    FlowLayout(spacing: 8) {
                        ForEach(tags) { tag in
                            TagBadge(tag: tag)
                        }
                    }
                }
            }
        }
    }

    private var subtasksSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Subtasks")
                    .font(DesignSystem.Typography.headline)
                Spacer()
                if let subtasks = goal.subtasks, !subtasks.isEmpty {
                    Text("\(subtasks.filter(\.isCompleted).count)/\(subtasks.count)")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(Theme.secondaryText)
                }
            }

            if !goal.sortedSubtasks.isEmpty {
                ForEach(goal.sortedSubtasks) { subtask in
                    SubtaskRow(subtask: subtask)
                }
            }

            HStack {
                TextField("Add subtask...", text: $newSubtaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit(addSubtask)

                Button {
                    addSubtask()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Theme.forwardOrange)
                }
                .disabled(newSubtaskTitle.isEmpty)
            }
        }
    }

    @State private var showingNoteEditor = false
    @State private var selectedNote: Note?
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text("Notes")
                    .font(DesignSystem.Typography.headline)
                Spacer()
                Button(action: { 
                    selectedNote = nil
                    showingNoteEditor = true 
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Theme.accent)
                }
            }

            if goal.sortedNotes.isEmpty {
                Text("No notes")
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(Theme.secondaryText)
            } else {
                VStack(spacing: DesignSystem.Spacing.sm) {
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

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Recurrence", systemImage: "repeat")
                    .font(.headline)
                Spacer()
                if let recurrence = goal.recurrence {
                    Text(recurrence.displayDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var actionsSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Button {
                goal.toggleCompletion()
                try? modelContext.save()
            } label: {
                Label(
                    goal.isCompleted ? "Mark Incomplete" : "Mark Complete",
                    systemImage: goal.isCompleted ? "arrow.uturn.backward" : "checkmark.circle.fill"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(goal.isCompleted ? .orange : .green)

            HStack(spacing: 12) {
                Button {
                    showingAlertSheet = true
                } label: {
                    Label("Alert", systemImage: "bell")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    showingRecurrenceSheet = true
                } label: {
                    Label("Repeat", systemImage: "repeat")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func addSubtask() {
        guard !newSubtaskTitle.isEmpty else { return }
        let subtask = Subtask(title: newSubtaskTitle, sortOrder: goal.sortedSubtasks.count)
        goal.subtasks?.append(subtask) ?? {
            goal.subtasks = [subtask]
        }()
        try? modelContext.save()
        newSubtaskTitle = ""
    }
}

struct SubtaskRow: View {
    @Bindable var subtask: Subtask

    var body: some View {
        HStack {
            Button {
                subtask.toggle()
            } label: {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(subtask.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .strikethrough(subtask.isCompleted)
                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
        }
    }
}

struct PriorityBadge: View {
    let priority: Priority

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: priority.icon)
                .font(DesignSystem.Typography.caption2)
                .symbolRenderingMode(.hierarchical)
            Text(priority.displayName)
                .font(DesignSystem.Typography.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .frame(height: 20)
        .background(priority.color.opacity(0.15))
        .foregroundStyle(priority.color)
        .clipShape(Capsule())
    }
}

struct DueDateBadge: View {
    let date: Date
    let isOverdue: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "calendar")
                .font(DesignSystem.Typography.caption2)
                .symbolRenderingMode(.hierarchical)
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .font(DesignSystem.Typography.caption2)
                .lineLimit(1)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .frame(height: 20)
        .background(isOverdue ? Color.red.opacity(0.15) : Color.blue.opacity(0.15))
        .foregroundStyle(isOverdue ? .red : .blue)
        .clipShape(Capsule())
    }
}

struct TagBadge: View {
    let tag: Tag

    var body: some View {
        Text(tag.name)
            .font(DesignSystem.Typography.caption2)
            .lineLimit(1)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .frame(height: 20)
            .background(tag.color.opacity(0.15))
            .foregroundStyle(tag.color)
            .clipShape(Capsule())
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX,
                                     y: bounds.minY + result.frames[index].minY),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var frames: [CGRect] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
