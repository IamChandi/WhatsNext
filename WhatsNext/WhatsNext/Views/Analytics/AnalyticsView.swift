import SwiftUI
import SwiftData
import Charts
import WhatsNextShared

struct AnalyticsView: View {
    @Query private var goals: [Goal]
    @Query private var historyEntries: [HistoryEntry]

    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var selectedTimeRange: AnalyticsViewModel.TimeRange = .week

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(AnalyticsViewModel.TimeRange.allCases, id: \.self) { range in
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
                        value: "\(viewModel.scopedCompletedCount)",
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
                        value: "\(Int(viewModel.scopedCompletionRate * 100))%",
                        icon: "chart.pie.fill",
                        color: .purple
                    )

                    StatCard(
                        title: "Current Streak",
                        value: "\(viewModel.currentStreak) days",
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
                        Chart(viewModel.completionData) { item in
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
                    if viewModel.scopedCategoryData.isEmpty || viewModel.scopedCategoryData.allSatisfy({ $0.count == 0 }) {
                        Text("No data for this period")
                            .foregroundStyle(.secondary)
                            .padding()
                    } else {
                        HStack(spacing: 20) {
                            Chart(viewModel.scopedCategoryData, id: \.category) { item in
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
                                ForEach(viewModel.scopedCategoryData, id: \.category) { item in
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
        .onAppear {
            viewModel.updateAnalytics(goals: goals, timeRange: selectedTimeRange)
        }
        .onChange(of: selectedTimeRange) { _, newRange in
            viewModel.updateAnalytics(goals: goals, timeRange: newRange)
        }
        .onChange(of: goals) { _, _ in
            viewModel.updateAnalytics(goals: goals, timeRange: selectedTimeRange)
        }
    }

    // MARK: - Computed Properties (for summary text only)
    
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

    private var summaryText: String {
        if viewModel.scopedCompletedCount == 0 {
            return "No activity recorded for \(selectedTimeRange.rawValue.lowercased())."
        }
        
        // Get scoped goals for summary
        let scopedGoals = goals.filter { goal in
            guard let completedAt = goal.completedAt, goal.status == .completed else { return false }
            return completedAt >= rangeStartDate && completedAt < rangeEndDate
        }
        
        let lines = scopedGoals.map { "- \($0.title) (\($0.category.shortName))" }
        return """
        ACTIVITY REPORT: \(selectedTimeRange.rawValue.uppercased())
        ----------------------------------------
        Total Completed: \(viewModel.scopedCompletedCount)
        
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

// DayCompletion and CategoryCount are now in AnalyticsViewModel

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
