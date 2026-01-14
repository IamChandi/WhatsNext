import Foundation
import SwiftData
import WhatsNextShared

/// Service for analytics calculations and data aggregation.
@MainActor
final class AnalyticsService {
    private let modelContext: ModelContext
    private let goalDataService: GoalDataService
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.goalDataService = GoalDataService(modelContext: modelContext)
    }
    
    /// Calculates completion rate for a given time range.
    func calculateCompletionRate(
        timeRange: AnalyticsTimeRange,
        allGoals: [Goal]
    ) -> Double {
        let rangeStart = timeRange.startDate
        let rangeEnd = timeRange.endDate
        
        let scopedCompleted = allGoals.filter { goal in
            guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
            return completedAt >= rangeStart && completedAt < rangeEnd
        }.count
        
        let totalActive = allGoals.filter { goal in
            goal.status != .archived && goal.status != .completed
        }.count
        
        let totalInScope = totalActive + scopedCompleted
        guard totalInScope > 0 else { return 0 }
        
        return Double(scopedCompleted) / Double(totalInScope)
    }
    
    /// Calculates the current completion streak.
    func calculateCurrentStreak(allGoals: [Goal]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        
        while true {
            let dayStart = date
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let completedOnDay = allGoals.contains { goal in
                if let completedAt = goal.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }
            
            if completedOnDay {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else if streak == 0 {
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }
            
            if streak > 365 { break }
        }
        
        return streak
    }
    
    /// Calculates completion data for a time range.
    func calculateCompletionData(
        timeRange: AnalyticsTimeRange,
        allGoals: [Goal]
    ) -> [DayCompletion] {
        let calendar = Calendar.current
        var data: [DayCompletion] = []
        
        let daysToShow = timeRange.daysToShow
        
        for i in (0..<daysToShow).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!
            
            let count = allGoals.filter { goal in
                if let completedAt = goal.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }.count
            
            data.append(DayCompletion(date: dayStart, count: count))
        }
        
        return data
    }
    
    /// Calculates category breakdown for completed goals in a time range.
    func calculateCategoryData(
        timeRange: AnalyticsTimeRange,
        allGoals: [Goal]
    ) -> [CategoryCount] {
        let rangeStart = timeRange.startDate
        let rangeEnd = timeRange.endDate
        
        let scopedGoals = allGoals.filter { goal in
            guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
            return completedAt >= rangeStart && completedAt < rangeEnd
        }
        
        return GoalCategory.allCases.map { category in
            CategoryCount(
                category: category,
                count: scopedGoals.filter { $0.category == category }.count
            )
        }
    }
    
    /// Fetches all goals for analytics calculations.
    func fetchAllGoalsForAnalytics() throws -> [Goal] {
        return try goalDataService.fetchAllGoals(excludeArchived: false)
    }
}

/// Time range options for analytics.
enum AnalyticsTimeRange {
    case day
    case week
    case month
    case quarter
    
    var startDate: Date {
        let calendar = Calendar.current
        let now = Date()
        switch self {
        case .day:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .quarter:
            let month = calendar.component(.month, from: now)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            return calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarterStartMonth, day: 1))!
        }
    }
    
    var endDate: Date {
        let calendar = Calendar.current
        switch self {
        case .day:
            return calendar.date(byAdding: .day, value: 1, to: startDate)!
        case .week:
            return calendar.date(byAdding: .weekOfYear, value: 1, to: startDate)!
        case .month:
            return calendar.date(byAdding: .month, value: 1, to: startDate)!
        case .quarter:
            return calendar.date(byAdding: .month, value: 3, to: startDate)!
        }
    }
    
    var daysToShow: Int {
        switch self {
        case .day: return 1
        case .week: return 7
        case .month: return 30
        case .quarter: return 90
        }
    }
}

/// Represents completion data for a single day.
struct DayCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

/// Represents count of goals by category.
struct CategoryCount: Identifiable {
    let id = UUID()
    let category: GoalCategory
    let count: Int
}
