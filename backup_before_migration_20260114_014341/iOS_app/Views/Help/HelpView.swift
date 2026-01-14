//
//  HelpView.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: HelpSection = .gettingStarted
    
    enum HelpSection: String, CaseIterable, Identifiable {
        case gettingStarted = "Getting Started"
        case features = "Features"
        case naturalLanguage = "Natural Language"
        case tips = "Tips & Tricks"
        case troubleshooting = "Troubleshooting"
        
        var id: String { rawValue }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Section Picker
                    Picker("Section", selection: $selectedSection) {
                        ForEach(HelpSection.allCases) { section in
                            Label(section.rawValue, systemImage: iconForSection(section))
                                .tag(section)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Content
                    contentForSection(selectedSection)
                }
                .padding()
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func iconForSection(_ section: HelpSection) -> String {
        switch section {
        case .gettingStarted: return "book.fill"
        case .features: return "sparkles"
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
            Text("Welcome to What's Next?")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            Text("What's Next? is a powerful goal-tracking application designed to help you stay focused on what matters most.")
                .font(.body)
            
            Text("Quick Start")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                HelpStep(number: 1, text: "Create your first goal using the Quick Entry field at the bottom")
                HelpStep(number: 2, text: "Organize goals into categories: Today, This Week, This Month, or Later")
                HelpStep(number: 3, text: "Tap a goal to view details and add subtasks")
                HelpStep(number: 4, text: "Complete goals by tapping the checkbox")
            }
            
            Text("Goal Categories")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                CategoryHelpRow(category: .daily, description: "Tasks to complete today")
                CategoryHelpRow(category: .weekly, description: "Goals for this week")
                CategoryHelpRow(category: .monthly, description: "Long-term monthly objectives")
                CategoryHelpRow(category: .whatsNext, description: "Backlog and future ideas")
            }
        }
    }
}

struct FeaturesHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            VStack(alignment: .leading, spacing: 16) {
                FeatureHelpItem(
                    icon: "list.bullet",
                    title: "List & Board Views",
                    description: "Switch between checklist and kanban board views to organize your goals"
                )
                
                FeatureHelpItem(
                    icon: "bell",
                    title: "Smart Notifications",
                    description: "Get reminders for your goals and daily planning prompts"
                )
                
                FeatureHelpItem(
                    icon: "repeat",
                    title: "Recurring Goals",
                    description: "Set up goals that repeat daily, weekly, or monthly"
                )
                
                FeatureHelpItem(
                    icon: "tag",
                    title: "Tags & Organization",
                    description: "Organize goals with tags and filter by category"
                )
            }
        }
    }
}

struct NaturalLanguageHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Natural Language Parsing")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            Text("Create goals quickly using natural language. The app will automatically detect priority and dates.")
                .font(.body)
            
            Text("Examples")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 12) {
                ExampleRow(input: "!high Meeting tomorrow", output: "High priority goal due tomorrow")
                ExampleRow(input: "!low Review documents", output: "Low priority goal")
                ExampleRow(input: "Complete project tomorrow", output: "Goal with due date")
            }
        }
    }
}

struct TipsHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tips & Tricks")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            VStack(alignment: .leading, spacing: 12) {
                TipItem(
                    icon: "star.fill",
                    tip: "Use the Quick Entry field for fast goal creation"
                )
                TipItem(
                    icon: "checkmark.circle",
                    tip: "Break large goals into subtasks for better tracking"
                )
                TipItem(
                    icon: "bell.fill",
                    tip: "Set alerts to never miss important deadlines"
                )
                TipItem(
                    icon: "arrow.2.squarepath",
                    tip: "Use recurring goals for daily habits and routines"
                )
            }
        }
    }
}

struct TroubleshootingHelp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Troubleshooting")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Theme.presidentialBlue)
            
            VStack(alignment: .leading, spacing: 12) {
                TroubleshootingItem(
                    question: "Notifications not working?",
                    answer: "Go to Settings > Notifications and ensure notifications are enabled. You may need to grant permission in iOS Settings."
                )
                TroubleshootingItem(
                    question: "Goals not syncing?",
                    answer: "WhatsNext uses local storage. Make sure you're using the same device."
                )
                TroubleshootingItem(
                    question: "How do I delete a goal?",
                    answer: "Swipe left on a goal in the list view, or open the goal details and use the delete action."
                )
            }
        }
    }
}

// MARK: - Help Components

struct HelpStep: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Theme.presidentialBlue)
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
                .foregroundStyle(Theme.forwardOrange)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ExampleRow: View {
    let input: String
    let output: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(input)
                .font(.body.monospaced())
                .foregroundStyle(Theme.forwardOrange)
            Text("→ \(output)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(8)
    }
}

struct TipItem: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.forwardOrange)
            Text(tip)
                .font(.body)
        }
    }
}

struct TroubleshootingItem: View {
    let question: String
    let answer: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question)
                .font(.headline)
            Text(answer)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(8)
    }
}
