//
//  ContentView.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData
// TODO: After adding package dependency in Xcode, uncomment:
// import WhatsNextShared
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var selectedCategory: GoalCategory = .daily
    @State private var searchText = ""
    @State private var showingNewGoalSheet = false
    @State private var showingHelp = false

    var body: some View {
        TabView(selection: $selectedTab) {
            // Today Tab
            CategoryGoalsView(category: .daily, searchText: $searchText)
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            // This Week Tab
            CategoryGoalsView(category: .weekly, searchText: $searchText)
                .tabItem {
                    Label("This Week", systemImage: "calendar.badge.clock")
                }
                .tag(1)

            // This Month Tab
            CategoryGoalsView(category: .monthly, searchText: $searchText)
                .tabItem {
                    Label("This Month", systemImage: "calendar")
                }
                .tag(2)

            // What's Next Tab
            CategoryGoalsView(category: .whatsNext, searchText: $searchText)
                .tabItem {
                    Label("Later", systemImage: "sparkles")
                }
                .tag(3)

            // Notes Tab
            NotesBrowserView()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
                .tag(4)

            // Settings Tab
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewGoalSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Theme.accent)
                }
            }
        }
        .sheet(isPresented: $showingNewGoalSheet) {
            GoalEditorSheet(goal: nil, category: selectedCategory) { goal in
                modelContext.insert(goal)
                if !modelContext.saveWithErrorHandling() {
                    ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNextiOS", code: -1)), context: "ContentView.createGoal")
                }
            }
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
        .onChange(of: AppState.shared.newGoalCreated) { _, _ in
            showingNewGoalSheet = true
        }
        .onChange(of: AppState.shared.showHelp) { _, show in
            showingHelp = show
        }
        .onChange(of: selectedTab) { _, newValue in
            // Update selected category based on tab
            switch newValue {
            case 0: selectedCategory = .daily
            case 1: selectedCategory = .weekly
            case 2: selectedCategory = .monthly
            case 3: selectedCategory = .whatsNext
            default: break
            }
        }
    }
}

struct CategoryGoalsView: View {
    let category: GoalCategory
    @Binding var searchText: String
    @State private var viewMode: ViewMode = .checklist
    @State private var selectedGoal: Goal?
    @State private var showingGoalDetail = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                if viewMode == .checklist {
                    GoalListView(
                        category: category,
                        searchText: searchText,
                        selectedGoal: $selectedGoal
                    )
                } else {
                    KanbanBoardView(
                        category: category,
                        searchText: searchText,
                        selectedGoal: $selectedGoal
                    )
                }

                // Quick Entry Field
                VStack {
                    Spacer()
                    QuickEntryField(category: category)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.md)
                }
            }
            .navigationTitle(category.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search goals...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    ViewModePicker(viewMode: $viewMode)
                }
            }
            .sheet(item: $selectedGoal) { goal in
                GoalDetailView(goal: goal)
            }
        }
    }
}

struct ViewModePicker: View {
    @Binding var viewMode: ViewMode

    var body: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("List", systemImage: "list.bullet")
                .tag(ViewMode.checklist)
            Label("Board", systemImage: "square.grid.3x2")
                .tag(ViewMode.kanban)
        }
        .pickerStyle(.segmented)
        .controlSize(.small)
    }
}

struct QuickEntryField: View {
    let category: GoalCategory
    @Environment(\.modelContext) private var modelContext
    @State private var text = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Theme.accent)
                .font(.title3)
                .symbolRenderingMode(.hierarchical)

            TextField("What's next for \(category.displayName)?", text: $text)
                .font(DesignSystem.Typography.body)
                .focused($isFocused)
                .submitLabel(.done)
                .onSubmit(submit)

            if !text.isEmpty {
                Button(action: { 
                    withAnimation(DesignSystem.Animation.quick) {
                        text = ""
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.secondaryText)
                        .font(.callout)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.medium)
                .fill(.regularMaterial)
        }
        .shadow(DesignSystem.Shadow.medium)
        .onChange(of: AppState.shared.focusQuickEntry) { _, _ in
            isFocused = true
        }
    }

    private func submit() {
        guard !text.isEmpty else { return }

        let config = NaturalLanguageParser.parse(text)
        let goal = Goal(
            title: config.title,
            category: category,
            priority: config.priority,
            dueDate: config.dueDate
        )

        modelContext.insert(goal)
        try? modelContext.save()
        text = ""
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        AppState.shared.notifyGoalsUpdated()
    }
}
