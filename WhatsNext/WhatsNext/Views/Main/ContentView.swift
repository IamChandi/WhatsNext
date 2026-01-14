//
//  ContentView.swift
//  WhatsNext
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import SwiftUI
import SwiftData
import WhatsNextShared

struct DetailLayout: View {
    let sidebarItem: SidebarItem?
    @Binding var viewMode: ViewMode
    @Binding var selectedGoal: Goal?
    @Binding var searchText: String

    var body: some View {
        ZStack(alignment: .bottom) {
            DetailView(
                sidebarItem: sidebarItem,
                viewMode: $viewMode,
                selectedGoal: $selectedGoal,
                searchText: $searchText
            )
            .padding(.bottom, sidebarItem == .briefing ? 0 : 80)

            if sidebarItem != .briefing && sidebarItem != .notes {
                QuickEntryField(currentSidebarItem: sidebarItem)
                    .frame(maxWidth: 600)
                    .padding(.bottom, 20)
            }
        }
    }
}

struct ViewModePicker: View {
    @Binding var viewMode: ViewMode

    var body: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("Checklist", systemImage: "list.bullet").tag(ViewMode.checklist)
            Label("Board", systemImage: "square.grid.3x2").tag(ViewMode.kanban)
        }
        .pickerStyle(.segmented)
        .frame(width: 150)
    }
}

struct QuickEntryField: View {
    let currentSidebarItem: SidebarItem?
    @Environment(\.modelContext) private var modelContext
    @State private var text = ""
    @FocusState private var isFocused: Bool
    @State private var parsedConfig: GoalConfig?

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(DesignTokens.Colors.accent)
                .font(.title2)
                .symbolEffect(.bounce, value: isFocused)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                TextField(prompt, text: $text)
                    .textFieldStyle(.plain)
                    .font(DesignTokens.Typography.h3)
                    .focused($isFocused)
                    .onSubmit(submit)
                    .onChange(of: text) { _, newValue in
                        // Parse as user types
                        if !newValue.isEmpty {
                            parsedConfig = NaturalLanguageParser.parse(newValue)
                        } else {
                            parsedConfig = nil
                        }
                    }

                // Show parsed metadata chips
                if let config = parsedConfig, !text.isEmpty {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        // Priority chip
                        if config.priority != .medium {
                            Badge(style: .priority(config.priority), size: .small, animated: true)
                        }

                        // Due date chip
                        if let dueDate = config.dueDate {
                            Badge(
                                style: .custom(
                                    text: formattedDate(dueDate),
                                    icon: "calendar",
                                    backgroundColor: DesignTokens.Colors.info.opacity(0.15),
                                    foregroundColor: DesignTokens.Colors.info
                                ),
                                size: .small,
                                animated: true
                            )
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }

            if !text.isEmpty {
                Button(action: {
                    withAnimation(DesignTokens.Animation.quick) {
                        text = ""
                        parsedConfig = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(DesignTokens.Colors.textSecondary)
                        .symbolRenderingMode(.hierarchical)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(DesignTokens.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .fill(DesignTokens.Colors.surfaceElevated)
                .shadow(
                    color: isFocused ? DesignTokens.Colors.accent.opacity(0.3) : DesignTokens.Shadow.lg.color,
                    radius: isFocused ? 12 : DesignTokens.Shadow.lg.radius,
                    x: DesignTokens.Shadow.lg.x,
                    y: DesignTokens.Shadow.lg.y
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.lg)
                .strokeBorder(
                    isFocused ? DesignTokens.Colors.accent.opacity(0.5) : Color.clear,
                    lineWidth: DesignTokens.BorderWidth.regular
                )
        )
        .animation(DesignTokens.Animation.smooth, value: isFocused)
        .padding(.horizontal)
        .onChange(of: AppState.shared.focusQuickEntry) { _, _ in
            isFocused = true
        }
    }

    private var prompt: String {
        switch currentSidebarItem {
        case .category(let cat): return "What's Next for \(cat.displayName)?"
        default: return "What's next?"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }

    private func submit() {
        guard !text.isEmpty else { return }

        let config = parsedConfig ?? NaturalLanguageParser.parse(text)
        let category: GoalCategory = {
            if case .category(let cat) = currentSidebarItem { return cat }
            return .daily
        }()

        let goal = Goal(
            title: config.title,
            category: category,
            priority: config.priority,
            dueDate: config.dueDate
        )

        modelContext.insert(goal)
        if !modelContext.saveWithErrorHandling() {
            ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "QuickEntryField.createGoal")
        } else {
            withAnimation(DesignTokens.Animation.quick) {
                text = ""
                parsedConfig = nil
            }
        }

        // Notify goals updated
        AppState.shared.notifyGoalsUpdated()
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var appState = AppState.shared
    @State private var selectedCategory: GoalCategory? = .daily
    @State private var selectedSidebarItem: SidebarItem? = .category(.daily)
    @State private var selectedGoal: Goal?
    @State private var viewMode: ViewMode = .checklist
    @State private var searchText = ""
    @State private var showingNewGoalSheet = false
    @AppStorage("isSidebarPinned") private var isSidebarPinned = true
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector = false
    @State private var showingHelp = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(selection: $selectedSidebarItem, searchText: $searchText)
        } detail: {
            DetailLayout(
                sidebarItem: selectedSidebarItem,
                viewMode: $viewMode,
                selectedGoal: $selectedGoal,
                searchText: $searchText
            )
        }
        .inspector(isPresented: $showingInspector) {
            if let goal = selectedGoal {
                GoalDetailInspector(
                    goal: goal,
                    onClose: {
                        selectedGoal = nil
                    }
                )
                .inspectorColumnWidth(min: 250, ideal: 300, max: 400)
            } else {
                Text("Select a goal to view details")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onChange(of: selectedGoal) { _, newGoal in
            withAnimation {
                showingInspector = (newGoal != nil)
            }
        }
        .onChange(of: isSidebarPinned) { _, newValue in
            withAnimation {
                columnVisibility = newValue ? .all : .detailOnly
            }
        }
        .onAppear {
            // Defer state modification to avoid "Modifying state during view update" warning
            Task { @MainActor in
                columnVisibility = isSidebarPinned ? .all : .detailOnly
            }
            // Activate window to show blue selection highlight immediately
            DispatchQueue.main.async {
                NSApp.activate(ignoringOtherApps: true)
                NSApp.mainWindow?.makeKeyAndOrderFront(nil)
            }
            // Ensure focus is on the entry field on launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                AppState.shared.focusQuickEntryField()
            }
        }
        .toolbar {
            // Only show toolbar items for goal categories, not for Notes, Archive, Analytics, etc.
            if case .category = selectedSidebarItem {
                ToolbarItemGroup(placement: .primaryAction) {
                    ViewModePicker(viewMode: $viewMode)
                    
                    Button(action: { showingNewGoalSheet = true }) {
                        Label("New Goal", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
        }
        .sheet(isPresented: $showingNewGoalSheet) {
            GoalEditorSheet(
                category: selectedCategory ?? .daily,
                onSave: { goal in
                    modelContext.insert(goal)
                    if !modelContext.saveWithErrorHandling() {
                        ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "ContentView.createGoal")
                    }
                }
            )
        }
        .onChange(of: appState.newGoalCreated) { _, _ in
            showingNewGoalSheet = true
        }
        .onChange(of: appState.viewMode) { _, mode in
            if let mode = mode {
                viewMode = mode
            }
        }
        .onChange(of: selectedSidebarItem) { _, newValue in
            // Clear selection and close inspector when switching major contexts
            selectedGoal = nil
            showingInspector = false
            
            if case .category(let cat) = newValue {
                selectedCategory = cat
            }
        }
        .onChange(of: appState.showHelp) { _, show in
            showingHelp = show
        }
        .sheet(isPresented: $showingHelp) {
            HelpView()
        }
    }
}


