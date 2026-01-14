import SwiftUI
import SwiftData
import WhatsNextShared

enum SidebarItem: Hashable {
    case briefing
    case category(GoalCategory)
    case tags
    case notes
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
            
            // Custom Search Bar with better visibility
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Theme.sidebarText.opacity(0.7))
                    .font(.system(size: 13))
                
                ZStack(alignment: .leading) {
                    if searchText.isEmpty {
                        Text("Search goals...")
                            .foregroundStyle(Theme.sidebarText.opacity(0.6))
                            .font(.system(size: 13))
                    }
                    
                    TextField("", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundStyle(Theme.sidebarText)
                        .font(.system(size: 13))
                }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Theme.sidebarText.opacity(0.6))
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)

            List(selection: $selection) {
                Section {
                    Label {
                        Text("Morning Briefing")
                            .font(.body)
                            .foregroundStyle(Theme.sidebarText)
                    } icon: {
                        Image(systemName: "sun.max.fill")
                            .foregroundStyle(Theme.sidebarIcon)
                    }
                    .tag(SidebarItem.briefing)
                    .listRowBackground(sidebarRowBackground(for: .briefing))

                    Button {
                        showingShutDown = true
                    } label: {
                        Label {
                            Text("End of Day")
                                .font(.body)
                                .foregroundStyle(Theme.sidebarText)
                        } icon: {
                            Image(systemName: "moon.stars.fill")
                                .foregroundStyle(Theme.sidebarIcon)
                        }
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                }

                Section {
                    ForEach(GoalCategory.allCases) { category in
                        SidebarCategoryRow(
                            category: category,
                            count: countForCategory(category)
                        )
                        .tag(SidebarItem.category(category))
                        .listRowBackground(sidebarRowBackground(for: .category(category)))
                    }
                } header: {
                    Text("Goals")
                        .font(.caption)
                        .foregroundStyle(Theme.sidebarText.opacity(0.7))
                        .textCase(nil)
                }

                Section {
                    HStack {
                        Label {
                            Text("Tags")
                                .font(.body)
                                .foregroundStyle(Theme.sidebarText)
                        } icon: {
                            Image(systemName: "tag")
                                .foregroundStyle(Theme.sidebarIcon)
                        }
                        
                        Spacer()
                        
                        if tags.count > 0 {
                            Text("\(tags.count)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.sidebarText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.sidebarText.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .tag(SidebarItem.tags)
                    .listRowBackground(sidebarRowBackground(for: .tags))

                    HStack {
                        Label {
                            Text("Notes")
                                .font(.body)
                                .foregroundStyle(Theme.sidebarText)
                        } icon: {
                            Image(systemName: "note.text")
                                .foregroundStyle(Theme.sidebarIcon)
                        }
                    }
                    .tag(SidebarItem.notes)
                    .listRowBackground(sidebarRowBackground(for: .notes))

                    HStack {
                        Label {
                            Text("Archive")
                                .font(.body)
                                .foregroundStyle(Theme.sidebarText)
                        } icon: {
                            Image(systemName: "archivebox")
                                .foregroundStyle(Theme.sidebarIcon)
                        }
                        
                        Spacer()
                        
                        if archivedCount > 0 {
                            Text("\(archivedCount)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Theme.sidebarText)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Theme.sidebarText.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                    .tag(SidebarItem.archive)
                    .listRowBackground(sidebarRowBackground(for: .archive))
                } header: {
                    Text("Organize")
                        .font(.caption)
                        .foregroundStyle(Theme.sidebarText.opacity(0.7))
                        .textCase(nil)
                }

                Section {
                    Label {
                        Text("Analytics")
                            .font(.body)
                            .foregroundStyle(Theme.sidebarText)
                    } icon: {
                        Image(systemName: "chart.bar")
                            .foregroundStyle(Theme.sidebarIcon)
                    }
                    .tag(SidebarItem.analytics)
                    .listRowBackground(sidebarRowBackground(for: .analytics))
                } header: {
                    Text("Insights")
                        .font(.caption)
                        .foregroundStyle(Theme.sidebarText.opacity(0.7))
                        .textCase(nil)
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Theme.ovalOfficeGradient)
        .frame(minWidth: 200)
        .tint(Theme.sidebarText)
        .foregroundStyle(Theme.sidebarText)
        .environment(\.defaultMinListRowHeight, 28)
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

    @ViewBuilder
    private func sidebarRowBackground(for item: SidebarItem) -> some View {
        if selection == item {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(red: 60/255, green: 120/255, blue: 200/255))
        } else {
            Color.clear
        }
    }
}

struct SidebarCategoryRow: View {
    let category: GoalCategory
    let count: Int

    var body: some View {
        HStack {
            Label {
                Text(category.shortName)
                    .font(.body)
                    .foregroundStyle(Theme.sidebarText)
            } icon: {
                Image(systemName: category.icon)
                    .foregroundStyle(Theme.sidebarIcon)
            }
            
            Spacer()
            
            if count > 0 {
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.sidebarText)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.sidebarText.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
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
                .transition(AnyTransition.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
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

