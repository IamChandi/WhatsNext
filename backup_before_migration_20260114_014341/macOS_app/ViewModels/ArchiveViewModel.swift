import Foundation
import SwiftData
import Combine

/// ViewModel for ArchiveView to manage archived goals.
@MainActor
final class ArchiveViewModel: ObservableObject {
    @Published var filteredGoals: [Goal] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let goalDataService: GoalDataService
    private var searchText: String = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.goalDataService = GoalDataService(modelContext: modelContext)
    }
    
    /// Updates the archived goals list based on search text.
    func updateArchivedGoals(searchText: String = "") {
        self.searchText = searchText
        isLoading = true
        
        do {
            filteredGoals = try goalDataService.fetchArchivedGoals(searchText: searchText)
        } catch {
            Logger.view.error("Failed to fetch archived goals: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.dataFetchFailed(error), context: "ArchiveViewModel.updateArchivedGoals")
            filteredGoals = []
        }
        
        isLoading = false
    }
    
    /// Unarchives a goal.
    func unarchiveGoal(_ goal: Goal) {
        goal.status = .pending
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveViewModel.unarchiveGoal")
        } else {
            updateArchivedGoals(searchText: searchText)
        }
    }
    
    /// Deletes a goal permanently.
    func deleteGoal(_ goal: Goal) {
        modelContext.delete(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveViewModel.deleteGoal")
        } else {
            updateArchivedGoals(searchText: searchText)
        }
    }
    
    /// Deletes multiple goals permanently.
    func deleteGoals(at indices: IndexSet) {
        for index in indices {
            let goal = filteredGoals[index]
            modelContext.delete(goal)
        }
        
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ArchiveViewModel.deleteGoals")
        } else {
            updateArchivedGoals(searchText: searchText)
        }
    }
}
