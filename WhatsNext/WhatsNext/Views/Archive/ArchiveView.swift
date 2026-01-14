import SwiftUI
import SwiftData
import os.log
import WhatsNextShared

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedGoal: Goal?

    @State private var searchText = ""
    @State private var dataService: GoalDataService?
    @State private var filteredGoals: [Goal] = []
    
    private func updateArchivedGoals() {
        guard let dataService = dataService else { return }
        do {
            filteredGoals = try dataService.fetchArchivedGoals(searchText: searchText)
        } catch {
            Logger.data.error("Failed to fetch archived goals: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.fetchFailed(error), context: "ArchiveView.updateArchivedGoals")
        }
    }

    var body: some View {
            Group {
            if filteredGoals.isEmpty && searchText.isEmpty {
                ContentUnavailableView {
                    Label("No Archived Goals", systemImage: "archivebox")
                } description: {
                    Text("Goals you archive will appear here")
                }
            } else {
                List(selection: $selectedGoal) {
                    ForEach(filteredGoals) { goal in
                        ArchivedGoalRow(goal: goal)
                            .tag(goal)
                            .contextMenu {
                                Button(action: { unarchiveGoal(goal) }) {
                                    Label("Restore", systemImage: "arrow.uturn.backward")
                                }

                                Button(role: .destructive, action: { deleteGoal(goal) }) {
                                    Label("Delete Permanently", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: deleteGoals)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .searchable(text: $searchText, placement: .toolbar, prompt: "Search archived goals...")
            }
        }
        .navigationTitle("Archive")
        .onAppear {
            dataService = GoalDataService(modelContext: modelContext)
            updateArchivedGoals()
        }
        .onChange(of: searchText) { _, _ in
            updateArchivedGoals()
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !filteredGoals.isEmpty {
                    Menu {
                        Button(action: restoreAll) {
                            Label("Restore All", systemImage: "arrow.uturn.backward")
                        }

                        Button(role: .destructive, action: deleteAll) {
                            Label("Delete All", systemImage: "trash")
                        }
                    } label: {
                        Label("Actions", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
        .withErrorHandling()
    }

    private func unarchiveGoal(_ goal: Goal) {
        goal.unarchive()
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveView.unarchiveGoal")
        } else {
            updateArchivedGoals()
        }
    }

    private func deleteGoal(_ goal: Goal) {
        modelContext.delete(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveView.deleteGoal")
        } else {
            updateArchivedGoals()
        }
    }

    private func deleteGoals(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredGoals[index])
        }
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveView.deleteGoals")
        } else {
            updateArchivedGoals()
        }
    }

    private func restoreAll() {
        for goal in filteredGoals {
            goal.unarchive()
        }
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveView.restoreAll")
        } else {
            updateArchivedGoals()
        }
    }

    private func deleteAll() {
        for goal in filteredGoals {
            modelContext.delete(goal)
        }
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveView.deleteAll")
        } else {
            updateArchivedGoals()
        }
    }
}

struct ArchivedGoalRow: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: goal.category.icon)
                .foregroundStyle(goal.category.color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(goal.title)
                        .strikethrough(goal.isCompleted)

                    if goal.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }

                HStack(spacing: 8) {
                    Text(goal.category.shortName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    if let completedAt = goal.completedAt {
                        Text("Completed \(completedAt.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Text(goal.updatedAt.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ArchiveView(selectedGoal: .constant(nil))
        .modelContainer(for: [Goal.self], inMemory: true)
}
