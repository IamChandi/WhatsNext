//
//  AnalyticsViewModel.swift
//  WhatsNext
//
//  ViewModel for AnalyticsView to cache expensive calculations and improve performance.
//

import Foundation
import SwiftData
import Combine
import WhatsNextShared

/// ViewModel for analytics calculations to improve performance.
@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var currentStreak: Int = 0
    @Published var completionData: [DayCompletion] = []
    @Published var scopedCompletedCount: Int = 0
    @Published var scopedCompletionRate: Double = 0.0
    @Published var scopedCategoryData: [CategoryCount] = []
    
    private var goals: [Goal] = []
    private var selectedTimeRange: TimeRange = .week
    private var lastGoalsHash: Int = 0
    private var calculationTask: Task<Void, Never>?
    
    enum TimeRange: String, CaseIterable {
        case day = "Today"
        case week = "This Week"
        case month = "This Month"
        case quarter = "This Quarter"
        
        var dateComponent: Calendar.Component {
            switch self {
            case .day: return .day
            case .week: return .weekOfYear
            case .month: return .month
            case .quarter: return .month // Use month as base for quarter calculations
            }
        }
    }
    
    struct DayCompletion: Identifiable {
        let id = UUID()
        let date: Date
        let count: Int
    }
    
    struct CategoryCount: Identifiable {
        let id = UUID()
        let category: GoalCategory
        let count: Int
    }
    
    /// Updates analytics with new goals and time range.
    func updateAnalytics(goals: [Goal], timeRange: TimeRange) {
        // Cancel previous calculation if still running
        calculationTask?.cancel()
        
        let currentHash = goals.hashValue
        guard currentHash != lastGoalsHash || selectedTimeRange != timeRange else {
            // No change, skip recalculation
            return
        }
        
        self.goals = goals
        self.selectedTimeRange = timeRange
        self.lastGoalsHash = currentHash
        
        // Perform calculations on background thread
        calculationTask = Task.detached { [weak self] in
            guard let self = self else { return }
            
            let streak = await self.calculateStreak(goals: goals)
            let completionData = await self.calculateCompletionData(goals: goals, timeRange: timeRange)
            let scopedCount = await self.calculateScopedCompletedCount(goals: goals, timeRange: timeRange)
            let completionRate = await self.calculateCompletionRate(goals: goals, scopedCount: scopedCount)
            let categoryData = await self.calculateCategoryData(goals: goals, timeRange: timeRange)
            
            await MainActor.run {
                self.currentStreak = streak
                self.completionData = completionData
                self.scopedCompletedCount = scopedCount
                self.scopedCompletionRate = completionRate
                self.scopedCategoryData = categoryData
            }
        }
    }
    
    private func calculateStreak(goals: [Goal]) -> Int {
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())
        
        while streak < AppConstants.Data.maxStreakDays {
            let dayStart = date
            guard let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else { break }
            
            let completedOnDay = goals.contains { goal in
                if let completedAt = goal.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }
            
            if completedOnDay {
                streak += 1
                guard let prevDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = prevDay
            } else if streak == 0 {
                // Check if anything completed yesterday (allow grace period)
                guard let prevDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
                date = prevDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateCompletionData(goals: [Goal], timeRange: TimeRange) -> [DayCompletion] {
        let calendar = Calendar.current
        var data: [DayCompletion] = []
        
        let daysToShow: Int
        switch timeRange {
        case .day: daysToShow = 1
        case .week: daysToShow = 7
        case .month: daysToShow = 30
        case .quarter: daysToShow = 90
        }
        
        for i in (0..<daysToShow).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -i, to: Date()),
                  let dayStart = calendar.dateInterval(of: .day, for: date)?.start,
                  let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) else {
                continue
            }
            
            let count = goals.filter { goal in
                if let completedAt = goal.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }.count
            
            data.append(DayCompletion(date: dayStart, count: count))
        }
        
        return data
    }
    
    private func calculateScopedCompletedCount(goals: [Goal], timeRange: TimeRange) -> Int {
        let calendar = Calendar.current
        let rangeStartDate: Date
        let rangeEndDate: Date
        
        switch timeRange {
        case .day:
            rangeStartDate = calendar.startOfDay(for: Date())
            rangeEndDate = calendar.date(byAdding: .day, value: 1, to: rangeStartDate) ?? Date()
        case .week:
            rangeStartDate = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            rangeEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: rangeStartDate) ?? Date()
        case .month:
            rangeStartDate = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
            rangeEndDate = calendar.date(byAdding: .month, value: 1, to: rangeStartDate) ?? Date()
        case .quarter:
            let month = calendar.component(.month, from: Date())
            let year = calendar.component(.year, from: Date())
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            rangeStartDate = calendar.date(from: DateComponents(year: year, month: quarterStartMonth, day: 1)) ?? Date()
            rangeEndDate = calendar.date(byAdding: .month, value: 3, to: rangeStartDate) ?? Date()
        }
        
        return goals.filter { goal in
            guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
            return completedAt >= rangeStartDate && completedAt < rangeEndDate
        }.count
    }
    
    private func calculateCompletionRate(goals: [Goal], scopedCount: Int) -> Double {
        let totalActive = goals.filter { $0.status != .archived && $0.status != .completed }.count
        let totalInScope = totalActive + scopedCount
        guard totalInScope > 0 else { return 0 }
        return Double(scopedCount) / Double(totalInScope)
    }
    
    private func calculateCategoryData(goals: [Goal], timeRange: TimeRange) -> [CategoryCount] {
        let calendar = Calendar.current
        let rangeStartDate: Date
        let rangeEndDate: Date
        
        switch timeRange {
        case .day:
            rangeStartDate = calendar.startOfDay(for: Date())
            rangeEndDate = calendar.date(byAdding: .day, value: 1, to: rangeStartDate) ?? Date()
        case .week:
            rangeStartDate = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? Date()
            rangeEndDate = calendar.date(byAdding: .weekOfYear, value: 1, to: rangeStartDate) ?? Date()
        case .month:
            rangeStartDate = calendar.dateInterval(of: .month, for: Date())?.start ?? Date()
            rangeEndDate = calendar.date(byAdding: .month, value: 1, to: rangeStartDate) ?? Date()
        case .quarter:
            let month = calendar.component(.month, from: Date())
            let year = calendar.component(.year, from: Date())
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            rangeStartDate = calendar.date(from: DateComponents(year: year, month: quarterStartMonth, day: 1)) ?? Date()
            rangeEndDate = calendar.date(byAdding: .month, value: 3, to: rangeStartDate) ?? Date()
        }
        
        return GoalCategory.allCases.map { category in
            let count = goals.filter { goal in
                guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
                return goal.category == category &&
                       completedAt >= rangeStartDate &&
                       completedAt < rangeEndDate
            }.count
            return CategoryCount(category: category, count: count)
        }
    }
}
