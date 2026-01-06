import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query private var goals: [Goal]
    @Query private var historyEntries: [HistoryEntry]

    @State private var selectedTimeRange: TimeRange = .week

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
            case .quarter: return .quarter
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Stats cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Completed",
                        value: "\(scopedCompletedCount)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    StatCard(
                        title: "Focus Time",
                        value: "2h 15m", // Placeholder for V2
                        icon: "hourglass",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Completion Rate",
                        value: "\(Int(scopedCompletionRate * 100))%",
                        icon: "chart.pie.fill",
                        color: .purple
                    )

                    StatCard(
                        title: "Current Streak",
                        value: "\(currentStreak) days",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Summary Report Card
                GroupBox("Briefing Report") {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(summaryText)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Theme.offWhite)
                            .cornerRadius(8)
                            .textSelection(.enabled)
                        
                        Divider()
                        
                        HStack {
                            Spacer()
                            Button(action: copyToClipboard) {
                                Label("Copy Summary to Clipboard", systemImage: "doc.on.doc")
                            }
                            .buttonStyle(.bordered)
                            .tint(Theme.presidentialBlue)
                        }
                    }
                    .padding(8)
                }
                .padding(.horizontal)

                // Completion chart (Hide for Day view as it's less useful)
                if selectedTimeRange != .day {
                    GroupBox("Completions Over Time") {
                        Chart(completionData) { item in
                            BarMark(
                                x: .value("Date", item.date, unit: .day),
                                y: .value("Completed", item.count)
                            )
                            .foregroundStyle(Theme.presidentialBlue.gradient)
                        }
                        .frame(height: 200)
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day)) { _ in
                                AxisGridLine()
                                AxisTick()
                                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Category breakdown
                GroupBox("Goals by Category (\(selectedTimeRange.rawValue))") {
                    if scopedCategoryData.isEmpty || scopedCategoryData.allSatisfy({ $0.count == 0 }) {
                        Text("No data for this period")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        HStack(spacing: 20) {
                            Chart(scopedCategoryData, id: \.category) { item in
                                SectorMark(
                                    angle: .value("Count", item.count),
                                    innerRadius: .ratio(0.5),
                                    angularInset: 2
                                )
                                .foregroundStyle(item.category.color)
                                .cornerRadius(4)
                            }
                            .frame(width: 150, height: 150)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(scopedCategoryData, id: \.category) { item in
                                    if item.count > 0 {
                                        HStack {
                                            Circle()
                                                .fill(item.category.color)
                                                .frame(width: 8, height: 8)
                                            Text(item.category.shortName)
                                                .font(.caption)
                                            Spacer()
                                            Text("\(item.count)")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("Analytics")
        .background(Theme.offWhite)
    }

    // MARK: - Computed Properties
    
    // START DATE for the selected range
    private var rangeStartDate: Date {
        let calendar = Calendar.current
        let now = Date()
        switch selectedTimeRange {
        case .day:
            return calendar.startOfDay(for: now)
        case .week:
            return calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        case .month:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        case .quarter:
            // Approximate quarter start
            let month = calendar.component(.month, from: now)
            let quarterStartMonth = ((month - 1) / 3) * 3 + 1
            return calendar.date(from: DateComponents(year: calendar.component(.year, from: now), month: quarterStartMonth, day: 1))!
        }
    }
    
    // END DATE for the selected range (exclusive)
    private var rangeEndDate: Date {
         let calendar = Calendar.current
         switch selectedTimeRange {
         case .day:
             return calendar.date(byAdding: .day, value: 1, to: rangeStartDate)!
         case .week:
             return calendar.date(byAdding: .weekOfYear, value: 1, to: rangeStartDate)!
         case .month:
             return calendar.date(byAdding: .month, value: 1, to: rangeStartDate)!
         case .quarter:
             return calendar.date(byAdding: .month, value: 3, to: rangeStartDate)!
         }
    }
    
    // Goals COMPLETED within the range
    private var scopedGoals: [Goal] {
        goals.filter { goal in
            guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
            return completedAt >= rangeStartDate && completedAt < rangeEndDate
        }
    }

    private var scopedCompletedCount: Int {
        scopedGoals.count
    }

    private var scopedCompletionRate: Double {
        // Rate = Completed in range / (Completed in range + Active created in range?)
        // Simplified: Just shows completion count relative to total active + completed currently
        // Better metric: % of goals DUE in this period that were completed?
        // Let's stick to a simple proxy for now: Activity Rate
        let totalActive = goals.filter { $0.status != .archived && $0.status != .completed }.count
        let totalInScope = totalActive + scopedCompletedCount
        guard totalInScope > 0 else { return 0 }
        return Double(scopedCompletedCount) / Double(totalInScope)
    }

    private var currentStreak: Int {
        // Global streak logic
        let calendar = Calendar.current
        var streak = 0
        var date = calendar.startOfDay(for: Date())

        while true {
            let dayStart = date
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let completedOnDay = goals.contains { goal in
                if let completedAt = goal.completedAt {
                    return completedAt >= dayStart && completedAt < dayEnd
                }
                return false
            }

            if completedOnDay {
                streak += 1
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else if streak == 0 {
                // Check if anything completed yesterday (allow grace period)
                date = calendar.date(byAdding: .day, value: -1, to: date)!
            } else {
                break
            }

            // Prevent infinite loop
            if streak > 365 { break }
        }

        return streak
    }

    private var completionData: [DayCompletion] {
        let calendar = Calendar.current
        var data: [DayCompletion] = []
        
        // Populate based on range
        let daysToShow: Int
        switch selectedTimeRange {
        case .day: daysToShow = 1
        case .week: daysToShow = 7
        case .month: daysToShow = 30
        case .quarter: daysToShow = 90
        }

        for i in (0..<daysToShow).reversed() {
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

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
    
    private var scopedCategoryData: [CategoryCount] {
        GoalCategory.allCases.map { category in
            CategoryCount(
                category: category,
                count: scopedGoals.filter { $0.category == category }.count
            )
        }
    }
    
    private var summaryText: String {
        if scopedGoals.isEmpty {
            return "No activity recorded for \(selectedTimeRange.rawValue.lowercased())."
        }
        
        let lines = scopedGoals.map { "- \($0.title) (\($0.category.shortName))" }
        return """
        ACTIVITY REPORT: \(selectedTimeRange.rawValue.uppercased())
        ----------------------------------------
        Total Completed: \(scopedCompletedCount)
        
        COMPLETED ITEMS:
        \(lines.joined(separator: "\n"))
        """
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(summaryText, forType: .string)
    }
}

// MARK: - Supporting Types

struct DayCompletion: Identifiable {
    let id = UUID()
    let date: Date
    let count: Int
}

struct CategoryCount {
    let category: GoalCategory
    let count: Int
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title3.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

struct ActivityRow: View {
    let entry: HistoryEntry

    var body: some View {
        HStack {
            Image(systemName: iconForAction)
                .foregroundStyle(colorForAction)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(entry.goalTitle)
                    .font(.callout)

                Text(actionDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(entry.timestamp.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
    }

    private var iconForAction: String {
        switch entry.action {
        case .created: return "plus.circle"
        case .updated: return "pencil.circle"
        case .completed: return "checkmark.circle.fill"
        case .moved: return "arrow.right.circle"
        case .deleted: return "trash.circle"
        case .archived: return "archivebox"
        case .unarchived: return "arrow.uturn.backward.circle"
        }
    }

    private var colorForAction: Color {
        switch entry.action {
        case .created: return .blue
        case .updated: return .orange
        case .completed: return .green
        case .moved: return .purple
        case .deleted: return .red
        case .archived: return .gray
        case .unarchived: return .blue
        }
    }

    private var actionDescription: String {
        switch entry.action {
        case .created: return "Created"
        case .updated: return "Updated"
        case .completed: return "Completed"
        case .moved:
            if let from = entry.previousCategory, let to = entry.newCategory {
                return "Moved from \(from.shortName) to \(to.shortName)"
            }
            return "Moved"
        case .deleted: return "Deleted"
        case .archived: return "Archived"
        case .unarchived: return "Restored from archive"
        }
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: [Goal.self, HistoryEntry.self], inMemory: true)
}
