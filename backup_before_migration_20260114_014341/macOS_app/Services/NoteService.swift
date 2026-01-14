import Foundation
import SwiftData
import AppKit

/// Service for managing notes with efficient data access and querying.
@MainActor
final class NoteService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Fetches all notes, optionally filtered by goal and search text.
    func fetchNotes(
        goal: Goal? = nil,
        searchText: String = "",
        sortBy: NoteSortOption = .updatedAtDescending
    ) throws -> [Note] {
        var predicate: Predicate<Note>?
        
        if let goal = goal {
            if searchText.isEmpty {
                predicate = #Predicate<Note> { note in
                    note.goal?.id == goal.id
                }
            } else {
                predicate = #Predicate<Note> { note in
                    note.goal?.id == goal.id &&
                    note.plainText.localizedStandardContains(searchText)
                }
            }
        } else {
            if !searchText.isEmpty {
                predicate = #Predicate<Note> { note in
                    note.plainText.localizedStandardContains(searchText) ||
                    note.goal?.title.localizedStandardContains(searchText) ?? false
                }
            }
        }
        
        let sortDescriptors: [SortDescriptor<Note>]
        switch sortBy {
        case .updatedAtDescending:
            sortDescriptors = [SortDescriptor(\.updatedAt, order: .reverse)]
        case .updatedAtAscending:
            sortDescriptors = [SortDescriptor(\.updatedAt)]
        case .createdAtDescending:
            sortDescriptors = [SortDescriptor(\.createdAt, order: .reverse)]
        case .createdAtAscending:
            sortDescriptors = [SortDescriptor(\.createdAt)]
        case .sortOrder:
            sortDescriptors = [SortDescriptor(\.sortOrder)]
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: predicate,
            sortBy: sortDescriptors
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Creates a new note.
    func createNote(goal: Goal? = nil, attributedText: NSAttributedString) throws -> Note {
        let note = Note(goal: goal, attributedText: attributedText)
        modelContext.insert(note)
        try modelContext.save()
        return note
    }
    
    /// Updates an existing note's content.
    func updateNote(_ note: Note, attributedText: NSAttributedString) throws {
        note.updateContent(attributedText)
        try modelContext.save()
    }
    
    /// Deletes a note.
    func deleteNote(_ note: Note) throws {
        modelContext.delete(note)
        try modelContext.save()
    }
    
    /// Links a note to a goal.
    func linkNote(_ note: Note, to goal: Goal) throws {
        note.goal = goal
        try modelContext.save()
    }
    
    /// Unlinks a note from its goal.
    func unlinkNote(_ note: Note) throws {
        note.goal = nil
        try modelContext.save()
    }
    
    /// Fetches recent notes (updated within threshold days).
    func fetchRecentNotes(thresholdDays: Int = AppConstants.Note.recentThresholdDays) throws -> [Note] {
        let calendar = Calendar.current
        let thresholdDate = calendar.date(byAdding: .day, value: -thresholdDays, to: Date()) ?? Date()
        
        let predicate = #Predicate<Note> { note in
            note.updatedAt >= thresholdDate
        }
        
        let descriptor = FetchDescriptor<Note>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
}

/// Options for sorting notes.
enum NoteSortOption {
    case updatedAtDescending
    case updatedAtAscending
    case createdAtDescending
    case createdAtAscending
    case sortOrder
}
