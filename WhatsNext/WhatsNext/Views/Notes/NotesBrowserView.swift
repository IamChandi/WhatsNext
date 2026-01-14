import SwiftUI
import SwiftData
import WhatsNextShared

/// Browser view for all notes with search functionality (macOS).
struct NotesBrowserView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.updatedAt, order: .reverse) private var allNotes: [Note]
    
    @State private var searchText = ""
    @State private var showingNoteEditor = false
    @State private var selectedNote: Note?
    @State private var showingArchived = false
    
    var activeNotes: [Note] {
        allNotes.filter { !$0.isArchived }
    }
    
    var archivedNotes: [Note] {
        allNotes.filter { $0.isArchived }
    }
    
    var filteredNotes: [Note] {
        let notesToFilter = showingArchived ? archivedNotes : activeNotes
        
        if searchText.isEmpty {
            return notesToFilter
        }
        return notesToFilter.filter { note in
            note.plainText.localizedCaseInsensitiveContains(searchText) ||
            (note.goal?.title.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if filteredNotes.isEmpty {
                    // Modern empty state using DesignTokens
                    if searchText.isEmpty {
                        ModernEmptyState(
                            config: .noNotes(onCreate: {
                                selectedNote = nil
                                showingNoteEditor = true
                            })
                        )
                    } else {
                        ModernEmptyState(
                            config: .noSearchResults(searchText: searchText, onClear: {
                                searchText = ""
                            })
                        )
                    }
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            NoteWithGoalRow(note: note)
                                .contextMenu {
                                    Button(note.isArchived ? "Unarchive" : "Archive") {
                                        if note.isArchived {
                                            note.unarchive()
                                        } else {
                                            note.archive()
                                        }
                                        if !modelContext.saveWithErrorHandling() {
                                            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "NotesBrowserView.archiveNote")
                                        }
                                    }
                                    
                                    Button("Delete", role: .destructive) {
                                        modelContext.delete(note)
                                        if !modelContext.saveWithErrorHandling() {
                                            ErrorHandler.shared.handle(.deleteFailed(NSError(domain: "WhatsNext", code: -1)), context: "NotesBrowserView.deleteNote")
                                        }
                                    }
                                }
                                .onTapGesture {
                                    selectedNote = note
                                    showingNoteEditor = true
                                }
                        }
                    }
                }
            }
            .navigationTitle(showingArchived ? "Archived Notes" : "Notes")
            .searchable(text: $searchText, prompt: "Search notes...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        // Archive toggle button - only show if there are archived notes or we're viewing archived
                        if !archivedNotes.isEmpty || showingArchived {
                            Button(action: {
                                withAnimation {
                                    showingArchived.toggle()
                                }
                            }) {
                                Image(systemName: showingArchived ? "tray" : "archivebox")
                                    .help(showingArchived ? "Show Active Notes" : "Show Archived Notes")
                            }
                            .buttonStyle(.borderless)
                        }
                        
                        // New note button - only show when viewing active notes
                        if !showingArchived {
                            Button(action: {
                                selectedNote = nil
                                showingNoteEditor = true
                            }) {
                                Image(systemName: "plus")
                                    .help("New Note")
                            }
                            .buttonStyle(.borderless)
                        }
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
