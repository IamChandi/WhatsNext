import Foundation
import SwiftData
import Combine

/// ViewModel for BriefingView to manage briefing goals and data.
@MainActor
final class BriefingViewModel: ObservableObject {
    @Published var sortedItems: [Goal] = []
    @Published var isLoading = false
    
    private let modelContext: ModelContext
    private let goalDataService: GoalDataService
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.goalDataService = GoalDataService(modelContext: modelContext)
    }
    
    /// Updates the briefing goals list.
    func updateBriefingGoals() {
        isLoading = true
        
        do {
            let briefingGoals = try goalDataService.fetchBriefingGoals()
            
            // Sort: Daily first, then High Priority Weekly
            sortedItems = briefingGoals.sorted {
                if $0.category == .daily && $1.category != .daily {
                    return true
                }
                if $0.category != .daily && $1.category == .daily {
                    return false
                }
                return $0.createdAt < $1.createdAt
            }
        } catch {
            Logger.view.error("Failed to fetch briefing goals: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.dataFetchFailed(error), context: "BriefingViewModel.updateBriefingGoals")
            sortedItems = []
        }
        
        isLoading = false
    }
}
