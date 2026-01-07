import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: HelpSection = .gettingStarted
    
    enum HelpSection: String, CaseIterable, Identifiable {
        case gettingStarted = "Getting Started"
        case features = "Features"
        case keyboardShortcuts = "Keyboard Shortcuts"
        case naturalLanguage = "Natural Language"
        case tips = "Tips & Tricks"
        case troubleshooting = "Troubleshooting"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedSection) {
                ForEach(HelpSection.allCases) { section in
                    Label(section.rawValue, systemImage: iconForSection(section))
                        .tag(section)
                }
            }
            .listStyle(.sidebar)
            .frame(minWidth: 200)
            .navigationTitle("Help")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    contentForSection(selectedSection)
                }
                .padding()
                .frame(maxWidth: 700, alignment: .leading)
            }
            .navigationTitle(selectedSection.rawValue)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
    
    private func iconForSection(_ section: HelpSection) -> String {
        switch section {
        case .gettingStarted: return "book.fill"
        case .features: return "sparkles"
        case .keyboardShortcuts: return "keyboard"
        case .naturalLanguage: return "text.bubble"
        case .tips: return "lightbulb.fill"
        case .troubleshooting: return "wrench.and.screwdriver"
        }
    }
    
    @ViewBuilder
    private func contentForSection(_ section: HelpSection) -> some View {
        switch section {
        case .gettingStarted:
            GettingStartedHelp()
        case .features:
            FeaturesHelp()
        case .keyboardShortcuts:
            KeyboardShortcutsHelp()
        case .naturalLanguage:
            NaturalLanguageHelp()
        case .tips:
            TipsHelp()
        case .troubleshooting:
            TroubleshootingHelp()
        }
    }
}

// MARK: - Help Content Views

struct GettingStartedHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Welcome to What's Next?")
            
            Text("What's Next? is a powerful goal-tracking application designed to help you stay focused on what matters most. This guide will help you get started.")
                .font(.body)
            
            HelpSubsection("Quick Start")
            
            VStack(alignment: .leading, spacing: 12) {
                HelpStep(number: 1, text: "Create your first goal using the Quick Entry field at the bottom of the window")
                HelpStep(number: 2, text: "Organize goals into categories: Daily, Weekly, Monthly, or What's Next?")
                HelpStep(number: 3, text: "Use the Morning Briefing to review your day's priorities")
                HelpStep(number: 4, text: "Complete goals by clicking the checkbox or pressing ⌘ + Return")
            }
            
            HelpSubsection("Goal Categories")
            
            VStack(alignment: .leading, spacing: 8) {
                CategoryHelpRow(category: .daily, description: "Tasks to complete today")
                CategoryHelpRow(category: .weekly, description: "Goals for this week")
                CategoryHelpRow(category: .monthly, description: "Long-term monthly objectives")
                CategoryHelpRow(category: .whatsNext, description: "Backlog and future ideas")
            }
            
            HelpSubsection("View Modes")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• **List View**: Traditional checklist with sections for pending and completed goals")
                Text("• **Board View**: Kanban-style board organized by category columns")
            }
            .font(.body)
        }
    }
}

struct FeaturesHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Features")
            
            FeatureHelpItem(
                icon: "sun.max.fill",
                title: "Morning Briefing",
                description: "Start your day with a focused review of daily goals and high-priority weekly items. Use Walk Mode to review goals one at a time."
            )
            
            FeatureHelpItem(
                icon: "moon.stars.fill",
                title: "End of Day Protocol",
                description: "Review unfinished daily goals and decide what to do with them: move to tomorrow, backlog, or weekly."
            )
            
            FeatureHelpItem(
                icon: "bell.fill",
                title: "Smart Notifications",
                description: "Get daily reminders at 9 AM and 8 PM. Schedule custom alerts for specific goals with quick actions."
            )
            
            FeatureHelpItem(
                icon: "repeat",
                title: "Recurring Goals",
                description: "Set up goals that repeat daily, weekly, or monthly. Perfect for habits and routine tasks."
            )
            
            FeatureHelpItem(
                icon: "tag.fill",
                title: "Tags & Organization",
                description: "Organize goals with color-coded tags. Filter and search to find what you need quickly."
            )
            
            FeatureHelpItem(
                icon: "chart.bar.fill",
                title: "Analytics",
                description: "Track your progress with completion statistics, streaks, and category breakdowns."
            )
            
            FeatureHelpItem(
                icon: "scope",
                title: "Focus Mode",
                description: "Mark important goals with Focus Mode to highlight them across the app."
            )
            
            FeatureHelpItem(
                icon: "keyboard",
                title: "Global Hotkey",
                description: "Press ⌘ + Shift + Space from anywhere to quickly add a new goal."
            )
        }
    }
}

struct KeyboardShortcutsHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Keyboard Shortcuts")
            
            HelpShortcutCategory(title: "Navigation") {
                ShortcutRow(keys: "⌘⇧1", description: "Move selected goal to Daily")
                ShortcutRow(keys: "⌘⇧2", description: "Move selected goal to Weekly")
                ShortcutRow(keys: "⌘⇧3", description: "Move selected goal to Monthly")
                ShortcutRow(keys: "⌘⇧4", description: "Move selected goal to What's Next?")
            }
            
            HelpShortcutCategory(title: "Goals") {
                ShortcutRow(keys: "⌘N", description: "Create new goal")
                ShortcutRow(keys: "⌘⏎", description: "Toggle goal completion")
                ShortcutRow(keys: "⌘⇧F", description: "Toggle Focus Mode")
            }
            
            HelpShortcutCategory(title: "Views") {
                ShortcutRow(keys: "⌃⌘L", description: "Switch to List view")
                ShortcutRow(keys: "⌃⌘B", description: "Switch to Board view")
                ShortcutRow(keys: "⌘F", description: "Search goals")
            }
            
            HelpShortcutCategory(title: "Global") {
                ShortcutRow(keys: "⌘⇧Space", description: "Quick Entry (works from anywhere)")
            }
            
            HelpShortcutCategory(title: "Window") {
                ShortcutRow(keys: "⌘,", description: "Open Settings")
                ShortcutRow(keys: "⌘W", description: "Close window")
                ShortcutRow(keys: "⌘Q", description: "Quit app")
            }
        }
    }
}

struct NaturalLanguageHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Natural Language Parsing")
            
            Text("What's Next? can understand simple commands in the Quick Entry field to automatically set priority and due dates.")
                .font(.body)
            
            HelpSubsection("Priority Markers")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Add priority markers anywhere in your goal text:")
                    .font(.headline)
                
                ExampleRow(input: "!high Important meeting", output: "Priority: High, Title: 'Important meeting'")
                ExampleRow(input: "!h Fix bug", output: "Priority: High, Title: 'Fix bug'")
                ExampleRow(input: "!low Clean desk", output: "Priority: Low, Title: 'Clean desk'")
                ExampleRow(input: "!l Review notes", output: "Priority: Low, Title: 'Review notes'")
                
                Text("Priority markers are case-insensitive: !HIGH, !High, !high all work.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HelpSubsection("Date Keywords")
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Use 'tomorrow' to automatically set a due date:")
                    .font(.headline)
                
                ExampleRow(input: "Meeting tomorrow", output: "Title: 'Meeting', Due: Tomorrow")
                ExampleRow(input: "!high Important call tomorrow", output: "Priority: High, Title: 'Important call', Due: Tomorrow")
            }
            
            HelpSubsection("Examples")
            
            VStack(alignment: .leading, spacing: 8) {
                ExampleRow(input: "!high Team standup tomorrow", output: "High priority goal due tomorrow")
                ExampleRow(input: "Review PR !low", output: "Low priority goal")
                ExampleRow(input: "Buy groceries tomorrow", output: "Goal due tomorrow")
            }
        }
    }
}

struct TipsHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Tips & Tricks")
            
            TipItem(
                icon: "1.circle.fill",
                title: "Use Quick Entry",
                description: "The Quick Entry field at the bottom is the fastest way to add goals. It supports natural language parsing and focuses automatically when you open the app."
            )
            
            TipItem(
                icon: "2.circle.fill",
                title: "Morning Routine",
                description: "Start each day with the Morning Briefing. It shows your daily goals and high-priority weekly items. Use Walk Mode for a focused review."
            )
            
            TipItem(
                icon: "3.circle.fill",
                title: "End of Day Review",
                description: "Use the End of Day protocol to review unfinished goals. Decide what to do with each one: move to tomorrow, backlog, or weekly."
            )
            
            TipItem(
                icon: "4.circle.fill",
                title: "Drag and Drop",
                description: "In Board view, drag goals between category columns to reorganize. In List view, drag to reorder goals within a category."
            )
            
            TipItem(
                icon: "5.circle.fill",
                title: "Focus Mode",
                description: "Mark critical goals with Focus Mode (⌘⇧F) to highlight them. Perfect for important deadlines or key objectives."
            )
            
            TipItem(
                icon: "6.circle.fill",
                title: "Subtasks",
                description: "Break down complex goals into subtasks. Track progress with the completion percentage shown in goal rows."
            )
            
            TipItem(
                icon: "7.circle.fill",
                title: "Recurring Goals",
                description: "Set up recurring goals for daily habits, weekly reviews, or monthly reports. The app will help you track patterns."
            )
            
            TipItem(
                icon: "8.circle.fill",
                title: "Tags for Organization",
                description: "Create tags to organize goals by project, context, or any system that works for you. Use colors to make them visually distinct."
            )
            
            TipItem(
                icon: "9.circle.fill",
                title: "Analytics Insights",
                description: "Check the Analytics view regularly to see your completion rates, streaks, and category breakdowns. Export summaries for reports."
            )
            
            TipItem(
                icon: "10.circle.fill",
                title: "Menu Bar Access",
                description: "The app stays in your menu bar. Click the icon to see today's goals and quick stats without opening the main window."
            )
        }
    }
}

struct TroubleshootingHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HelpSectionTitle("Troubleshooting")
            
            TroubleshootingItem(
                question: "Notifications aren't working",
                answer: "Go to System Settings → Notifications → What's Next? and ensure notifications are enabled. The app will request permission on first launch."
            )
            
            TroubleshootingItem(
                question: "Global hotkey (⌘⇧Space) doesn't work",
                answer: "Make sure the app has Accessibility permissions. Go to System Settings → Privacy & Security → Accessibility and add What's Next?"
            )
            
            TroubleshootingItem(
                question: "Goals disappeared",
                answer: "Check the Archive view - completed goals may have been archived. You can restore them from there."
            )
            
            TroubleshootingItem(
                question: "App won't launch",
                answer: "If you see a security warning, right-click the app → Open. For persistent issues, check Console.app for error messages."
            )
            
            TroubleshootingItem(
                question: "Data not syncing",
                answer: "What's Next? stores data locally on your Mac. There's no cloud sync currently. To back up, copy the app's data folder from ~/Library/Containers/com.whatsnext.app/"
            )
            
            TroubleshootingItem(
                question: "Can't find the menu bar icon",
                answer: "The menu bar icon appears in the top-right of your screen. If hidden, click the arrow to reveal hidden menu bar items."
            )
            
            HelpSubsection("Getting More Help")
            
            VStack(alignment: .leading, spacing: 8) {
                Link("GitHub Repository", destination: URL(string: "https://github.com/IamChandi/WhatsNext")!)
                    .font(.body)
                Link("Report an Issue", destination: URL(string: "https://github.com/IamChandi/WhatsNext/issues")!)
                    .font(.body)
            }
        }
    }
}

// MARK: - Supporting Views

struct HelpSectionTitle: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.largeTitle)
            .fontWeight(.bold)
            .foregroundStyle(Theme.presidentialBlue)
    }
}

struct HelpSubsection: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top, 8)
    }
}

struct HelpStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Theme.forwardOrange)
                .clipShape(Circle())
            
            Text(text)
                .font(.body)
        }
    }
}

struct CategoryHelpRow: View {
    let category: GoalCategory
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundStyle(category.color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct FeatureHelpItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Theme.forwardOrange)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct HelpShortcutCategory<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 4) {
                content
            }
            .padding()
            .background(Theme.cardBackground)
            .cornerRadius(8)
        }
    }
}

struct ExampleRow: View {
    let input: String
    let output: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Input:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(input)
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Theme.cardBackground)
                    .cornerRadius(4)
            }
            
            HStack {
                Text("Result:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(output)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TipItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.presidentialBlue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TroubleshootingItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(Theme.forwardOrange)
                Text(question)
                    .font(.headline)
            }
            
            Text(answer)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding(.leading, 28)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(8)
    }
}

#Preview {
    HelpView()
}
