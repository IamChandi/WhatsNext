import SwiftUI
import SwiftData
import CoreLocation

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
    @AppStorage("userLocation") private var storedLocation: String = "Washington, D.C."
    @State private var userLocation: String = ""
    @State private var currentDate = Date()
    @State private var currentWeather: WeatherCondition = .init(description: "Partly Cloudy", temp: 72, icon: "cloud.sun.fill")
    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                // Section 1: Live Date (Left)
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                    Text(currentDate.formatted(date: .complete, time: .shortened))
                }
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Section 2: Location & Weather (Right)
                VStack(alignment: .trailing, spacing: 2) {
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                        ZStack(alignment: .trailing) {
                            Text(userLocation.isEmpty ? "Location" : userLocation)
                                .font(.system(.subheadline, design: .monospaced))
                                .fontWeight(.medium)
                                .opacity(0)
                                .padding(.horizontal, 4)
                            
                            TextField("Location", text: $userLocation)
                                .textFieldStyle(.plain)
                                .multilineTextAlignment(.trailing)
                                .onSubmit {
                                    storedLocation = userLocation
                                    updateWeather()
                                }
                        }
                        .frame(minWidth: 60)
                    }
                    
                    // Weather
                    HStack(spacing: 4) {
                        Image(systemName: currentWeather.icon)
                        Text("\(currentWeather.description) \(currentWeather.temp)°F")
                    }
                }
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 24)
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
            userLocation = storedLocation
            updateWeather()
        }
    }
    
    private func updateWeather() {
        let location = storedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        guard location.count > 1 && location != "-" else {
            currentWeather = .init(description: "--", temp: 0, icon: "questionmark")
            return
        }
        
        // Step 1: Geocode the location string to lat/long
        CLGeocoder().geocodeAddressString(location) { placemarks, error in
            guard let location = placemarks?.first?.location else {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                }
                DispatchQueue.main.async {
                    currentWeather = .init(description: "Not Found", temp: 0, icon: "location.slash")
                }
                return
            }
            
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            // Step 2: Fetch weather from Open-Meteo
            let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weather_code&temperature_unit=fahrenheit"
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Weather fetch error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else { return }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let current = json["current"] as? [String: Any],
                       let tempF = current["temperature_2m"] as? Double,
                       let weatherCode = current["weather_code"] as? Int {
                        
                        let (desc, icon) = mapWMOToReadable(weatherCode)
                        
                        DispatchQueue.main.async {
                            currentWeather = .init(description: desc, temp: Int(tempF), icon: icon)
                        }
                    }
                } catch {
                    print("Weather parsing error: \(error)")
                }
            }.resume()
        }
    }
    
    private func mapWMOToReadable(_ code: Int) -> (String, String) {
        switch code {
        case 0: return ("Clear", "sun.max.fill")
        case 1, 2, 3: return ("Partly Cloudy", "cloud.sun.fill")
        case 45, 48: return ("Foggy", "cloud.fog.fill")
        case 51, 53, 55: return ("Drizzle", "cloud.drizzle.fill")
        case 61, 63, 65: return ("Rainy", "cloud.rain.fill")
        case 71, 73, 75: return ("Snowy", "snowflake")
        case 80, 81, 82: return ("Showers", "cloud.heavyrain.fill")
        case 95, 96, 99: return ("Stormy", "cloud.bolt.rain.fill")
        default: return ("Cloudy", "cloud.fill")
        }
    }
    
    struct WeatherCondition {
        let description: String
        let temp: Int
        let icon: String
    }
}



