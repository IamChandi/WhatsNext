import SwiftUI
import SwiftData

/// Browser view for all notes with search functionality (iOS).
struct NotesBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    
    @State private var searchText = ""
    @State private var editingNote: Note?
    @State private var isCreatingNew = false
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return allNotes
        }
        return allNotes.filter { note in
            note.plainText.localizedCaseInsensitiveContains(searchText) ||
            (note.goal?.title.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            if editingNote != nil || isCreatingNew {
                // Inline Editor View
                InlineNoteEditor(
                    note: editingNote,
                    onSave: { savedNote in
                        if !modelContext.saveWithErrorHandling() {
                            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "NotesBrowserView.saveNote")
                        } else {
                            editingNote = nil
                            isCreatingNew = false
                        }
                    },
                    onCancel: {
                        editingNote = nil
                        isCreatingNew = false
                    }
                )
            } else {
                // Notes List View
                List {
                    if filteredNotes.isEmpty {
                        ContentUnavailableView(
                            "No Notes",
                            systemImage: "note.text",
                            description: Text(searchText.isEmpty ? "Create your first note to get started" : "No notes match your search")
                        )
                    } else {
                        ForEach(filteredNotes) { note in
                            NoteWithGoalRow(note: note)
                                .onTapGesture {
                                    editingNote = note
                                }
                        }
                        .onDelete(perform: deleteNotes)
                    }
                }
                .navigationTitle("Notes")
                .searchable(text: $searchText, prompt: "Search notes...")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            isCreatingNew = true
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }
            }
        }
    }
    
    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            let note = filteredNotes[index]
            modelContext.delete(note)
        }
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "NotesBrowserView.deleteNotes")
        }
    }
}

/// Row view showing a note with its parent goal badge.
struct NoteWithGoalRow: View {
    let note: Note
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Note preview
                Text(note.plainText)
                    .font(DesignSystem.Typography.body)
                    .lineLimit(3)
                    .foregroundColor(Theme.primaryText)
                
                // Metadata
                HStack(spacing: 12) {
                    // Goal badge
                    if let goal = note.goal {
                        Label(goal.title, systemImage: goal.category.icon)
                            .font(.caption2)
                            .foregroundColor(Theme.secondaryText)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Theme.secondaryBackground)
                            .cornerRadius(DesignSystem.CornerRadius.small)
                    }
                    
                    // Last updated
                    Label(note.updatedAt.formatted(.relative(presentation: .named)), systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            
            Spacer()
            
            // Recent indicator
            if note.isRecent {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
