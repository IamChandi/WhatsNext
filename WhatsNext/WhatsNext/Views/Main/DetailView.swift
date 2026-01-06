import SwiftUI
import SwiftData

struct DetailView: View {
    let sidebarItem: SidebarItem?
    @Binding var viewMode: ViewMode
    @Binding var selectedGoal: Goal?
    @Binding var searchText: String

    var body: some View {
        VStack(spacing: 0) {
            if sidebarItem != .briefing {
                DashboardHeaderView()
            }
            
            Group {
                switch sidebarItem {
                case .briefing:
                    BriefingView(selectedGoal: $selectedGoal)

                case .category(let category):
                    if viewMode == .checklist {
                        GoalListView(
                            category: category,
                            searchText: searchText,
                            selectedGoal: $selectedGoal
                        )
                    } else {
                        KanbanBoardView(
                            initialCategory: category,
                            searchText: searchText,
                            selectedGoal: $selectedGoal
                        )
                    }

                case .tags:
                    TagListView()

                case .archive:
                    ArchiveView(selectedGoal: $selectedGoal)

                case .analytics:
                    AnalyticsView()

                case nil:
                    ContentUnavailableView(
                        "Select a Category",
                        systemImage: "sidebar.left",
                        description: Text("Choose a category from the sidebar to view your goals")
                    )
                }
            }
        }
        .frame(minWidth: 400, maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.offWhite)
    }
}

struct BriefingView: View {
    @Query(filter: #Predicate<Goal> { goal in
        goal.statusRaw != "archived" && goal.statusRaw != "completed"
    }, sort: \Goal.createdAt)
    private var allActiveItems: [Goal]
    
    @Binding var selectedGoal: Goal?
    @State private var isWalking = false
    
    // Sort items: Daily first, then High Priority Weekly
    var sortedItems: [Goal] {
        let briefingItems = allActiveItems.filter { goal in
            goal.categoryRaw == "daily" || (goal.categoryRaw == "weekly" && goal.priorityRaw == "high")
        }
        
        return briefingItems.sorted {
            if $0.category == .daily && $1.category != .daily {
                return true
            }
            if $0.category != .daily && $1.category == .daily {
                return false
            }
            return $0.createdAt < $1.createdAt
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Morning Briefing")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Theme.presidentialBlue)
                    
                    Text(Date(), format: .dateTime.weekday(.wide).month().day())
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                Button(action: { isWalking = true }) {
                    Label("Start Walk", systemImage: "figure.walk")
                        .font(.headline)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.forwardOrange)
                .disabled(sortedItems.isEmpty)
            }
            .padding()
            .background(Theme.cardBackground)
            .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            // Content
            if sortedItems.isEmpty {
                ContentUnavailableView(
                    "All Clear",
                    systemImage: "checkmark.seal",
                    description: Text("No immediate items for your briefing.")
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(sortedItems) { goal in
                            BriefingCard(goal: goal)
                                .onTapGesture {
                                    selectedGoal = goal
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Theme.offWhite)
        .sheet(isPresented: $isWalking) {
            WalkModeView(items: sortedItems)
        }
    }
}

struct BriefingCard: View {
    let goal: Goal
    
    var body: some View {
        HStack {
            Image(systemName: goal.category.icon)
                .foregroundStyle(goal.category.color)
                .font(.title2)
                .padding(.trailing, 8)
            
            VStack(alignment: .leading) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                if let description = goal.goalDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if goal.priority == .high {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct WalkModeView: View {
    let items: [Goal]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var currentIndex = 0
    
    var currentItem: Goal? {
        if items.indices.contains(currentIndex) {
            return items[currentIndex]
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            Theme.presidentialBlue.ignoresSafeArea()
            
            VStack {
                // Top Bar
                HStack {
                    Button("End Briefing") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(currentIndex + 1) of \(items.count)")
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding()
                
                Spacer()
                
                if let item = currentItem {
                    VStack(spacing: 32) {
                        Text(item.category.shortName.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(8)
                            .background(Theme.cardBackground)
                            .foregroundStyle(item.category.color)
                            .cornerRadius(4)
                        
                        Text(item.title)
                            .font(.system(size: 48, weight: .bold, design: .serif))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        
                        if let description = item.goalDescription, !description.isEmpty {
                            Text(description)
                                .font(.title3)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding()
                    .transition(.opacity.combined(with: .scale))
                    .id(item.id) // Force transition
                } else {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Theme.forwardOrange)
                        Text("Briefing Complete")
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding(.top)
                    }
                }
                
                Spacer()
                
                // Controls
                if currentItem != nil {
                    HStack(spacing: 40) {
                        Button(action: skipItem) {
                            VStack {
                                Image(systemName: "arrow.right.circle")
                                    .font(.system(size: 44))
                                Text("Next")
                                    .font(.caption)
                            }
                            .foregroundStyle(.white.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                        
                        Button(action: completeItem) {
                            VStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 64))
                                    .foregroundStyle(Theme.forwardOrange)
                                Text("Complete")
                                    .font(.caption)
                                    .foregroundStyle(Theme.forwardOrange)
                            }
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut(.return, modifiers: [])
                    }
                    .padding(.bottom, 50)
                } else {
                    Button("Finish") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.forwardOrange)
                    .padding(.bottom, 50)
                }
            }
        }
    }
    
    private func skipItem() {
        withAnimation {
            currentIndex += 1
        }
    }
    
    private func completeItem() {
        if let item = currentItem {
            item.status = .completed
            item.completedAt = Date()
            try? modelContext.save()
            
            withAnimation {
                currentIndex += 1
            }
        }
    }
}

struct DashboardHeaderView: View {
    @AppStorage("userLocation") private var userLocation: String = "Washington, D.C."
    @State private var currentDate = Date()
    @State private var currentWeather: WeatherCondition = .init(description: "Partly Cloudy", temp: 72, icon: "cloud.sun.fill")
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Live Date
                Label(
                    currentDate.formatted(date: .complete, time: .shortened),
                    systemImage: "clock"
                )
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                // Location & Weather
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        TextField("Location", text: $userLocation)
                            .textFieldStyle(.plain)
                            .frame(width: 150)
                            .multilineTextAlignment(.trailing)
                            .onSubmit {
                                updateWeather()
                            }
                    }
                    
                    Label("\(currentWeather.description) \(currentWeather.temp)°F", systemImage: currentWeather.icon)
                }
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
        .background(Theme.cardBackground)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.secondary.opacity(0.1)),
            alignment: .bottom
        )
        .frame(height: 64)
        .onReceive(timer) { input in
            currentDate = input
        }
        .onAppear {
            updateWeather()
        }
        .onChange(of: userLocation) { _, _ in
            updateWeather()
        }
    }
    
    private func updateWeather() {
        let location = userLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard location.count > 1 && location != "-" else {
            currentWeather = .init(description: "--", temp: 0, icon: "questionmark")
            return
        }
        
        let urlString = "https://wttr.in/\(location.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")?format=j1"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let currentCondition = (json["current_condition"] as? [[String: Any]])?.first,
                   let tempFStr = currentCondition["temp_F"] as? String,
                   let tempF = Int(tempFStr),
                   let descArr = currentCondition["weatherDesc"] as? [[String: Any]],
                   let desc = descArr.first?["value"] as? String {
                    
                    let weatherCode = currentCondition["weatherCode"] as? String ?? ""
                    let icon = mapWeatherCodeToIcon(weatherCode)
                    
                    DispatchQueue.main.async {
                        currentWeather = .init(description: desc, temp: tempF, icon: icon)
                    }
                }
            } catch {
                print("Weather fetch error: \(error)")
            }
        }.resume()
    }
    
    private func mapWeatherCodeToIcon(_ code: String) -> String {
        switch code {
        case "113": return "sun.max.fill"
        case "116": return "cloud.sun.fill"
        case "119", "122": return "cloud.fill"
        case "266", "296", "302": return "cloud.rain.fill"
        case "323", "326", "332", "338": return "snowflake"
        case "389": return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
    
    struct WeatherCondition {
        let description: String
        let temp: Int
        let icon: String
    }
}



