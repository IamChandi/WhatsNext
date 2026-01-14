import Foundation
import SwiftData
import WhatsNextShared

/// Service for managing tags with efficient data access.
@MainActor
final class TagService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Fetches all tags, optionally filtered by search text.
    func fetchTags(searchText: String = "") throws -> [Tag] {
        var predicate: Predicate<Tag>?
        
        if !searchText.isEmpty {
            predicate = #Predicate<Tag> { tag in
                tag.name.localizedStandardContains(searchText)
            }
        }
        
        let descriptor = FetchDescriptor<Tag>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.name)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Creates a new tag.
    func createTag(name: String, colorHex: String? = nil) throws -> Tag {
        let tag = Tag(name: name, colorHex: colorHex ?? "#007AFF")
        modelContext.insert(tag)
        try modelContext.save()
        return tag
    }
    
    /// Updates an existing tag.
    func updateTag(_ tag: Tag, name: String? = nil, colorHex: String? = nil) throws {
        if let name = name {
            tag.name = name
        }
        if let colorHex = colorHex {
            tag.colorHex = colorHex
        }
        try modelContext.save()
    }
    
    /// Deletes a tag.
    func deleteTag(_ tag: Tag) throws {
        modelContext.delete(tag)
        try modelContext.save()
    }
    
    /// Adds a tag to a goal.
    func addTag(_ tag: Tag, to goal: Goal) throws {
        if goal.tags == nil {
            goal.tags = []
        }
        if let tags = goal.tags, !tags.contains(where: { $0.id == tag.id }) {
            goal.tags?.append(tag)
            try modelContext.save()
        }
    }
    
    /// Removes a tag from a goal.
    func removeTag(_ tag: Tag, from goal: Goal) throws {
        goal.tags?.removeAll { $0.id == tag.id }
        try modelContext.save()
    }
    
    /// Fetches tags for a specific goal.
    func fetchTags(for goal: Goal) -> [Tag] {
        return (goal.tags ?? []).sorted { $0.name < $1.name }
    }
    
    /// Fetches the most used tags (by goal count).
    func fetchMostUsedTags(limit: Int = 10) throws -> [Tag] {
        let allTags = try fetchTags()
        return Array(allTags.sorted { 
            ($0.goals?.count ?? 0) > ($1.goals?.count ?? 0) 
        }.prefix(limit))
    }
}
