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
        .onReceive(NotificationCenter.default.publisher(for: .focusQuickEntry)) { _ in
            isFocused = true
        }
    }

    private var prompt: String {
        switch currentSidebarItem {
        case .category(let cat): return "Add to \(cat.displayName)..."
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
        try? modelContext.save()
        text = ""
        
        // Haptic feedback or toast could be added here
        NotificationCenter.default.post(name: .goalsUpdated, object: nil)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCategory: GoalCategory? = .daily
    @State private var selectedSidebarItem: SidebarItem? = .category(.daily)
    @State private var selectedGoal: Goal?
    @State private var viewMode: ViewMode = .checklist
    @State private var searchText = ""
    @State private var showingNewGoalSheet = false
    @AppStorage("isSidebarPinned") private var isSidebarPinned = true
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    @State private var showingInspector = false

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
            columnVisibility = isSidebarPinned ? .all : .detailOnly
        }
        .toolbar {

            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    withAnimation {
                        isSidebarPinned.toggle()
                    }
                } label: {
                    Label(isSidebarPinned ? "Unpin Sidebar" : "Pin Sidebar", systemImage: isSidebarPinned ? "pin.fill" : "pin.slash")
                }
                .help(isSidebarPinned ? "Unpin Sidebar" : "Pin Sidebar")
                
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
                    try? modelContext.save()
                }
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: .newGoal)) { _ in
            showingNewGoalSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchViewMode)) { notification in
            if let mode = notification.object as? ViewMode {
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
    }
}


