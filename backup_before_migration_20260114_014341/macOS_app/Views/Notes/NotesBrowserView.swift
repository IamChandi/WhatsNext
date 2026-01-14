import SwiftUI
import SwiftData

/// Browser view for all notes with search functionality (macOS).
struct NotesBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    
    @State private var searchText = ""
    @State private var showingNoteEditor = false
    @State private var selectedNote: Note?
    
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
                                selectedNote = note
                                showingNoteEditor = true
                            }
                    }
                }
            }
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        selectedNote = nil
                        showingNoteEditor = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNoteEditor) {
                NoteEditorSheet(note: selectedNote, goal: nil) { note in
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "NotesBrowserView.saveNote")
                    }
                }
            }
            .withErrorHandling()
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
                    .font(.body)
                    .lineLimit(3)
                    .foregroundColor(.primary)
                
                // Metadata
                HStack(spacing: 12) {
                    // Goal badge
                    if let goal = note.goal {
                        Label(goal.title, systemImage: goal.category.icon)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                    
                    // Last updated
                    Label(note.updatedAt.formatted(.relative(presentation: .named)), systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Recent indicator
            if note.isRecent {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
