import SwiftUI
import SwiftData

enum SidebarItem: Hashable {
    case briefing
    case category(GoalCategory)
    case tags
    case archive
    case analytics
}

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @Binding var searchText: String
    @Query private var goals: [Goal]
    @Query(filter: #Predicate<Tag> { _ in true }, sort: \Tag.name)
    private var tags: [Tag]

    @AppStorage("isSidebarPinned") private var isSidebarPinned = true
    @State private var showingShutDown = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Sidebar Header
            HStack {
                Text("What's Next?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button {
                    withAnimation {
                        isSidebarPinned.toggle()
                    }
                } label: {
                    Image(systemName: isSidebarPinned ? "pin.fill" : "pin.slash")
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
                .help(isSidebarPinned ? "Unpin Sidebar" : "Pin Sidebar")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.1))

            List(selection: $selection) {
                Section {
                    Label {
                        Text("Morning Briefing")
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.forwardOrange)
                    } icon: {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(Theme.forwardOrange)
                    }
                    .tag(SidebarItem.briefing)
                    
                    Button {
                        showingShutDown = true
                    } label: {
                        Label {
                            Text("End of Day")
                                .fontWeight(.semibold)
                                .foregroundStyle(Theme.forwardOrange)
                        } icon: {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(Theme.forwardOrange)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listRowBackground(Color.clear)

                Section("Goals") {
                    ForEach(GoalCategory.allCases) { category in
                        SidebarCategoryRow(
                            category: category,
                            count: countForCategory(category)
                        )
                        .tag(SidebarItem.category(category))
                    }
                }
                .listRowBackground(Color.clear)

                Section("Organize") {
                    Label {
                        Text("Tags").foregroundStyle(Theme.sidebarText)
                    } icon: {
                        Image(systemName: "tag").foregroundStyle(Theme.sidebarIcon)
                    }
                    .tag(SidebarItem.tags)
                    .badge(tags.count)

                    Label {
                        Text("Archive").foregroundStyle(Theme.sidebarText)
                    } icon: {
                        Image(systemName: "archivebox").foregroundStyle(Theme.sidebarIcon)
                    }
                    .tag(SidebarItem.archive)
                    .badge(archivedCount)
                }
                .listRowBackground(Color.clear)

                Section("Insights") {
                    Label {
                        Text("Analytics").foregroundStyle(Theme.sidebarText)
                    } icon: {
                        Image(systemName: "chart.bar").foregroundStyle(Theme.sidebarIcon)
                    }
                    .tag(SidebarItem.analytics)
                }
                .listRowBackground(Color.clear)
            }
        }
        .searchable(text: $searchText, placement: .sidebar, prompt: "Search goals...")
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Theme.ovalOfficeGradient)
        .frame(minWidth: 200)
        .sheet(isPresented: $showingShutDown) {
            ShutDownView()
        }
    }

    private func countForCategory(_ category: GoalCategory) -> Int {
        goals.filter { $0.category == category && $0.status != .archived }.count
    }

    private var archivedCount: Int {
        goals.filter { $0.status == .archived }.count
    }
}

struct SidebarCategoryRow: View {
    let category: GoalCategory
    let count: Int

    var body: some View {
        Label {
            Text(category.shortName)
                .foregroundStyle(Theme.sidebarText)
        } icon: {
            // Use Theme orange for accents if desired, or keep category color but ensure visibility
            Image(systemName: category.icon)
                .foregroundStyle(category.color) // Keeping category color for now, could switch to Theme.forwardOrange
        }
        .badge(count)
    }
}

#Preview {
    SidebarView(selection: .constant(.category(.daily)), searchText: .constant(""))
        .modelContainer(for: [Goal.self, Tag.self], inMemory: true)
}

struct ShutDownView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Filter for Active Daily Goals
    @Query(filter: #Predicate<Goal> { goal in
        goal.categoryRaw == "daily" &&
        goal.statusRaw != "completed" &&
        goal.statusRaw != "archived"
    }) private var activeDailyGoals: [Goal]
    
    // Filter for Completed Goals
    @Query(filter: #Predicate<Goal> { goal in
        goal.statusRaw == "completed"
    }) private var allCompletedGoals: [Goal]
    
    @State private var step = 0
    @State private var notes = ""
    @State private var isFinished = false
    @State private var processedGoalIDs = Set<UUID>()
    
    private var pendingTriageGoals: [Goal] {
        activeDailyGoals.filter { !processedGoalIDs.contains($0.id) }
    }
    
    private var completedTodayCount: Int {
        let calendar = Calendar.current
        return allCompletedGoals.filter {
            if let date = $0.completedAt {
                return calendar.isDateInToday(date)
            }
            return false
        }.count
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("End of Day Protocol")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            if isFinished {
                finishView
            } else if step == 0 {
                overviewStep
            } else if step == 1 {
                if pendingTriageGoals.isEmpty {
                    VStack {
                        Text("All clear!")
                            .font(.title)
                        Text("No daily goals remaining.")
                            .foregroundStyle(.secondary)
                    }
                    .onAppear {
                        withAnimation { step = 2 }
                    } // Auto advance
                } else {
                    triageStep
                }
            } else {
                reflectionStep
            }
        }
        .padding(40)
        .frame(minWidth: 500, minHeight: 400)
        .background(Theme.offWhite)
    }
    
    // MARK: - Steps
    
    private var overviewStep: some View {
        VStack(spacing: 32) {
            HStack(spacing: 40) {
                VStack {
                    Text("\(completedTodayCount)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(.green)
                    Text("Completed Today")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    Text("\(activeDailyGoals.count)")
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Remaining")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button("Start Review") {
                withAnimation { step = 1 }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
    
    private var triageStep: some View {
        VStack(spacing: 16) {
            Text("Review Remaining Goals")
                .font(.headline)
            
            if let goal = pendingTriageGoals.first {
                VStack(spacing: 24) {
                    // Goal Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            PriorityDot(priority: goal.priority)
                            Spacer()
                            Text(goal.category.shortName)
                                .font(.caption)
                                .padding(4)
                                .background(goal.category.color.opacity(0.1))
                                .cornerRadius(4)
                        }
                        
                        Text(goal.title)
                            .font(.title2)
                            .fontWeight(.medium)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 2)
                    
                    // Actions
                    HStack(spacing: 20) {
                        Button("Tomorrow") {
                            moveGoal(goal, to: .daily) // Keep in daily implies tomorrow effectively
                        }
                        
                        Button("Backlog") {
                            moveGoal(goal, to: .whatsNext)
                        }
                        
                        Button("Move to Weekly") {
                            moveGoal(goal, to: .weekly)
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
    
    private var reflectionStep: some View {
        VStack(spacing: 24) {
            Text("Any reflections for today?")
                .font(.headline)
            
            TextEditor(text: $notes)
                .font(.body)
                .frame(height: 150)
                .padding(8)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.secondary.opacity(0.2)))
            
            Button("Shut Down") {
                finishDay()
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.presidentialBlue)
        }
    }
    
    private var finishView: some View {
        VStack(spacing: 24) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple)
            
            Text("Goodnight, Mr. President.")
                .font(.title)
            
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.defaultAction)
        }
    }
    
    // MARK: - Actions
    
    private func moveGoal(_ goal: Goal, to category: GoalCategory) {
        withAnimation {
            processedGoalIDs.insert(goal.id)
            goal.category = category
            
            // If moving to tomorrow (Daily), update due date
            if category == .daily {
                let calendar = Calendar.current
                if let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())) {
                    goal.dueDate = tomorrow
                }
            }
            
            goal.updatedAt = Date()
        }
    }
    
    private func finishDay() {
        withAnimation {
            isFinished = true
        }
    }
}

