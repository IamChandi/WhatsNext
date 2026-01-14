import SwiftUI
import SwiftData
import WhatsNextShared

struct TagListView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Tag.name)
    private var tags: [Tag]

    @State private var showingNewTagSheet = false
    @State private var editingTag: Tag?
    @State private var searchText = ""

    private var filteredTags: [Tag] {
        if searchText.isEmpty {
            return tags
        }
        return tags.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        Group {
            if tags.isEmpty {
                ContentUnavailableView {
                    Label("No Tags", systemImage: "tag")
                } description: {
                    Text("Create tags to organize your goals")
                } actions: {
                    Button("Create Tag") {
                        showingNewTagSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List {
                    ForEach(filteredTags) { tag in
                        TagRow(tag: tag)
                            .contextMenu {
                                Button(action: { editingTag = tag }) {
                                    Label("Edit", systemImage: "pencil")
                                }

                                Button(role: .destructive, action: { deleteTag(tag) }) {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                    .onDelete(perform: deleteTags)
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
                .searchable(text: $searchText, placement: .toolbar, prompt: "Search tags...")
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingNewTagSheet = true }) {
                    Label("New Tag", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingNewTagSheet) {
            TagEditorSheet { tag in
                modelContext.insert(tag)
                if !modelContext.saveWithErrorHandling() {
                    ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "TagListView")
                }
            }
        }
        .sheet(item: $editingTag) { tag in
            TagEditorSheet(existingTag: tag) { _ in
                if !modelContext.saveWithErrorHandling() {
                    ErrorHandler.shared.handle(.saveFailed(NSError(domain: "WhatsNext", code: -1)), context: "TagListView")
                }
            }
        }
    }

    private func deleteTag(_ tag: Tag) {
        modelContext.delete(tag)
        try? modelContext.save()
    }

    private func deleteTags(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTags[index])
        }
        try? modelContext.save()
    }
}

struct TagRow: View {
    let tag: Tag

    @Query private var goals: [Goal]

    private var goalCount: Int {
        goals.filter { $0.tags?.contains(where: { $0.id == tag.id }) ?? false }.count
    }

    var body: some View {
        HStack {
            Circle()
                .fill(tag.color)
                .frame(width: 12, height: 12)

            Text(tag.name)
                .font(.body)

            Spacer()

            Text("\(goalCount) goals")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct TagEditorSheet: View {
    @Environment(\.dismiss) private var dismiss

    let existingTag: Tag?
    let onSave: (Tag) -> Void

    @State private var name = ""
    @State private var selectedColor: Color = .blue

    private let presetColors: [Color] = [
        .blue, .purple, .pink, .red, .orange,
        .yellow, .green, .teal, .cyan, .indigo
    ]

    init(existingTag: Tag? = nil, onSave: @escaping (Tag) -> Void) {
        self.existingTag = existingTag
        self.onSave = onSave

        if let tag = existingTag {
            _name = State(initialValue: tag.name)
            _selectedColor = State(initialValue: tag.color)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") { dismiss() }
                    .keyboardShortcut(.escape, modifiers: [])

                Spacer()

                Text(existingTag == nil ? "New Tag" : "Edit Tag")
                    .font(.headline)

                Spacer()

                Button("Save") { saveTag() }
                    .keyboardShortcut(.return, modifiers: .command)
                    .disabled(name.isEmpty)
                    .buttonStyle(.borderedProminent)
            }
            .padding()

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 20) {
                // Name
                VStack(alignment: .leading, spacing: 4) {
                    Text("Name")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    TextField("Tag name", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                // Color
                VStack(alignment: .leading, spacing: 8) {
                    Text("Color")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(presetColors, id: \.self) { color in
                            Button(action: { selectedColor = color }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.white, lineWidth: selectedColor == color ? 2 : 0)
                                    )
                                    .shadow(color: selectedColor == color ? color.opacity(0.5) : .clear, radius: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    ColorPicker("Custom color", selection: $selectedColor)
                        .labelsHidden()
                }

                // Preview
                VStack(alignment: .leading, spacing: 4) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(name.isEmpty ? "Tag Name" : name)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(selectedColor.opacity(0.15))
                        .foregroundStyle(selectedColor)
                        .clipShape(Capsule())
                }

                Spacer()
            }
            .padding()
        }
        .frame(width: 300, height: 350)
    }

    private func saveTag() {
        if let existingTag = existingTag {
            existingTag.name = name
            existingTag.colorHex = selectedColor.toHex()
            onSave(existingTag)
        } else {
            let tag = Tag(name: name, colorHex: selectedColor.toHex())
            onSave(tag)
        }
        dismiss()
    }
}

#Preview {
    TagListView()
        .modelContainer(for: [Tag.self, Goal.self], inMemory: true)
}
