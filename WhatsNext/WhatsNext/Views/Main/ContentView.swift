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

            if sidebarItem != .briefing {
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

    var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(Theme.forwardOrange)
                .font(.title2)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .font(.title3)
                .focused($isFocused)
                .onSubmit(submit)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
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

    private func submit() {
        guard !text.isEmpty else { return }

        let config = NaturalLanguageParser.parse(text)
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
            text = ""
        }
        
        // Haptic feedback or toast could be added here
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

            ToolbarItemGroup(placement: .primaryAction) {
                ViewModePicker(viewMode: $viewMode)
                
                Button(action: { showingNewGoalSheet = true }) {
                    Label("New Goal", systemImage: "plus")
                }
                .keyboardShortcut("n", modifiers: .command)
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


