import SwiftUI
import SwiftData
import os.log

/// Inline note editor that replaces the list view when editing.
struct InlineNoteEditor: View {
    @Environment(\.modelContext) private var modelContext
    
    let note: Note?
    let onSave: (Note) -> Void
    let onCancel: () -> Void
    
    @State private var attributedText: NSAttributedString
    @State private var textView: UITextView?
    @FocusState private var isEditorFocused: Bool
    
    init(note: Note? = nil, onSave: @escaping (Note) -> Void, onCancel: @escaping () -> Void) {
        self.note = note
        self.onSave = onSave
        self.onCancel = onCancel
        _attributedText = State(initialValue: note?.attributedText ?? NSAttributedString(string: ""))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Formatting Toolbar at top
            RichTextToolbar(textView: Binding(
                get: { textView },
                set: { textView = $0 }
            ))
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .background(Theme.secondaryBackground)
            
            Divider()
            
            // Rich Text Editor - takes remaining space
            RichTextEditor(
                attributedText: $attributedText,
                onTextChange: { _ in },
                textViewBinding: Binding(
                    get: { textView },
                    set: { textView = $0 }
                )
            )
            .padding(DesignSystem.Spacing.md)
            .focused($isEditorFocused)
        }
        .navigationTitle(note == nil ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    onCancel()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveNote()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            // Focus editor after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isEditorFocused = true
            }
        }
    }
    
    private func saveNote() {
        let newNote: Note
        if let existingNote = note {
            newNote = existingNote
            newNote.updateContent(attributedText)
        } else {
            newNote = Note(goal: nil, attributedText: attributedText)
            modelContext.insert(newNote)
        }
        
                do {
                    try modelContext.save()
                    onSave(newNote)
                } catch {
                    Logger.data.error("❌ Failed to save note: \(error.localizedDescription)")
                    ErrorHandler.shared.handle(.saveFailed(error), context: "InlineNoteEditor.saveNote")
                }
    }
}
