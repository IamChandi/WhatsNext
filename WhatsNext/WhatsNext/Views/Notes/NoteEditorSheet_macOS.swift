import SwiftUI
import SwiftData
import os.log
import WhatsNextShared

/// Sheet for creating/editing notes on macOS with rich text editor.
struct NoteEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let note: Note?
    let goal: Goal?
    let onSave: (Note) -> Void
    
    @State private var attributedText: NSAttributedString
    @State private var textView: NSTextView?
    
    init(note: Note? = nil, goal: Goal? = nil, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.goal = goal
        self.onSave = onSave
        _attributedText = State(initialValue: note?.attributedText ?? NSAttributedString(string: ""))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Spacer()
                
                Text(note == nil ? "New Note" : "Edit Note")
                    .font(.headline)
                
                Spacer()
                
                Button("Save") {
                    saveNote()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Formatting Toolbar
            RichTextToolbar(textView: Binding(
                get: { textView },
                set: { textView = $0 }
            ))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Editor - takes remaining space
            RichTextEditor(
                attributedText: $attributedText,
                onTextChange: { _ in },
                textViewBinding: Binding(
                    get: { textView },
                    set: { textView = $0 }
                )
            )
            .frame(minHeight: 400)
        }
        .frame(width: 700, height: 650)
    }
    
    private func saveNote() {
        let newNote: Note
        if let existingNote = note {
            newNote = existingNote
            newNote.updateContent(attributedText)
        } else {
            newNote = Note(goal: goal, attributedText: attributedText)
            modelContext.insert(newNote)
        }
        
                do {
                    try modelContext.save()
                    onSave(newNote)
                    dismiss()
                } catch {
                    Logger.data.error("❌ Failed to save note: \(error.localizedDescription)")
                    ErrorHandler.shared.handle(.saveFailed(error), context: "NoteEditorSheet.saveNote")
                }
    }
}
