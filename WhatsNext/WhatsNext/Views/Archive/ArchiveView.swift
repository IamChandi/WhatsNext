import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedGoal: Goal?

    @Query(
        filter: #Predicate<Goal> { $0.statusRaw == "archived" },
        sort: \Goal.updatedAt,
        order: .reverse
    )
    private var archivedGoals: [Goal]

    @State private var searchText = ""

    private var filteredGoals: [Goal] {
        if searchText.isEmpty {
            return archivedGoals
        }
        return archivedGoals.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        Group {
            if archivedGoals.isEmpty {
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !archivedGoals.isEmpty {
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
    }

    private func unarchiveGoal(_ goal: Goal) {
        goal.unarchive()
        try? modelContext.save()
    }

    private func deleteGoal(_ goal: Goal) {
        modelContext.delete(goal)
        try? modelContext.save()
    }

    private func deleteGoals(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredGoals[index])
        }
        try? modelContext.save()
    }

    private func restoreAll() {
        for goal in archivedGoals {
            goal.unarchive()
        }
        try? modelContext.save()
    }

    private func deleteAll() {
        for goal in archivedGoals {
            modelContext.delete(goal)
        }
        try? modelContext.save()
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
