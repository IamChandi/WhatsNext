import SwiftUI
import AppKit
import WhatsNextShared

/// Rich text editor for macOS using NSTextView with formatting toolbar.
struct RichTextEditor: NSViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var onTextChange: ((NSAttributedString) -> Void)?
    var textViewBinding: Binding<NSTextView?>?
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        // Configure text view
        textView.isRichText = true
        textView.isAutomaticQuoteSubstitutionEnabled = true
        textView.isAutomaticLinkDetectionEnabled = true
        textView.isAutomaticDataDetectionEnabled = true
        textView.isAutomaticTextReplacementEnabled = true
        textView.allowsUndo = true
        textView.font = .systemFont(ofSize: 15)
        textView.textColor = .labelColor
        textView.backgroundColor = .textBackgroundColor
        textView.textContainerInset = NSSize(width: 12, height: 12)
        
        // Set up delegate
        textView.delegate = context.coordinator
        
        // Configure scroll view
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .bezelBorder
        
        // Set initial content
        textView.textStorage?.setAttributedString(attributedText)
        
        context.coordinator.textView = textView
        textViewBinding?.wrappedValue = textView
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        
        // Only update if content actually changed (avoid infinite loops)
        let currentText = textView.attributedString()
        if !currentText.isEqual(to: attributedText) {
            textView.textStorage?.setAttributedString(attributedText)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: RichTextEditor
        var textView: NSTextView?
        private var isUpdating = false
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = textView, !isUpdating else { return }
            
            let attributedString = textView.attributedString()
            parent.attributedText = attributedString
            parent.onTextChange?(attributedString)
        }
    }
}

/// Toolbar for rich text formatting controls.
struct RichTextToolbar: View {
    @Binding var textView: NSTextView?
    
    var body: some View {
        HStack(spacing: 8) {
            // Bold
            Button(action: { applyFormatting(.boldFontMask) }) {
                Image(systemName: "bold")
                    .frame(width: 20, height: 20)
            }
            .help("Bold")
            .keyboardShortcut("b", modifiers: .command)
            
            // Italic
            Button(action: { applyFormatting(.italicFontMask) }) {
                Image(systemName: "italic")
                    .frame(width: 20, height: 20)
            }
            .help("Italic")
            .keyboardShortcut("i", modifiers: .command)
            
            // Underline
            Button(action: { applyUnderline() }) {
                Image(systemName: "underline")
                    .frame(width: 20, height: 20)
            }
            .help("Underline")
            .keyboardShortcut("u", modifiers: .command)
            
            Divider()
                .frame(height: 20)
            
            // Bullet list
            Button(action: { insertList(type: .bullet) }) {
                Image(systemName: "list.bullet")
                    .frame(width: 20, height: 20)
            }
            .help("Bullet List")
            
            // Numbered list
            Button(action: { insertList(type: .number) }) {
                Image(systemName: "list.number")
                    .frame(width: 20, height: 20)
            }
            .help("Numbered List")
            
            Divider()
                .frame(height: 20)
            
            // Link
            Button(action: { insertLink() }) {
                Image(systemName: "link")
                    .frame(width: 20, height: 20)
            }
            .help("Insert Link")
            .keyboardShortcut("k", modifiers: .command)
        }
        .buttonStyle(.borderless)
        .frame(height: 28)
        .padding(.horizontal, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func applyFormatting(_ trait: NSFontTraitMask) {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange()
        guard range.length > 0 else { return }
        
        let textStorage = textView.textStorage!
        let fontManager = NSFontManager.shared
        
        textStorage.beginEditing()
        textStorage.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let font = (value as? NSFont) ?? NSFont.systemFont(ofSize: 15)
            
            // Check if font already has the trait
            let currentTraits = fontManager.traits(of: font)
            let hasTrait = currentTraits.contains(trait)
            
            // Toggle: if has trait, remove it; if not, add it
            let newFont: NSFont
            if hasTrait {
                // Remove trait by converting to regular, then applying other traits
                let otherTraits = currentTraits.subtracting(trait)
                if otherTraits.isEmpty {
                    // No other traits, use system font
                    newFont = NSFont.systemFont(ofSize: font.pointSize)
                } else {
                    // Keep other traits
                    // Note: fontManager.font returns NSFont? but compiler may infer non-optional in some contexts
                    let convertedFont = fontManager.font(withFamily: font.familyName ?? "System", traits: otherTraits, weight: 5, size: font.pointSize)
                    newFont = convertedFont ?? font
                }
            } else {
                // Add trait
                // Note: fontManager.convert returns NSFont (non-optional)
                newFont = fontManager.convert(font, toHaveTrait: trait)
            }
            
            textStorage.addAttribute(.font, value: newFont, range: subRange)
        }
        textStorage.endEditing()
    }
    
    private func applyUnderline() {
        guard let textView = textView, textView.selectedRange().length > 0 else { return }
        
        let range = textView.selectedRange()
        let textStorage = textView.textStorage!
        
        // Check if already underlined
        let currentUnderline = textStorage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int ?? 0
        let underlineValue = currentUnderline == 0 ? NSUnderlineStyle.single.rawValue : 0
        
        textStorage.addAttribute(.underlineStyle, value: underlineValue, range: range)
    }
    
    private func insertList(type: ListType) {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange()
        let textStorage = textView.textStorage!
        let fullText = textStorage.string as NSString
        
        // If no selection, get current line
        let textToFormat: String
        let rangeToReplace: NSRange
        
        if range.length == 0 {
            let lineRange = fullText.lineRange(for: range)
            textToFormat = fullText.substring(with: lineRange)
            rangeToReplace = lineRange
        } else {
            textToFormat = fullText.substring(with: range)
            rangeToReplace = range
        }
        
        // Split into lines and add list markers
        let lines = textToFormat.components(separatedBy: .newlines)
        let marker = type == .bullet ? "• " : "1. "
        let newText = lines.map { marker + $0 }.joined(separator: "\n")
        
        // Preserve attributes
        let attributes = textStorage.attributes(at: rangeToReplace.location, effectiveRange: nil)
        let replacement = NSAttributedString(string: newText, attributes: attributes)
        textStorage.replaceCharacters(in: rangeToReplace, with: replacement)
    }
    
    private func insertLink() {
        guard let textView = textView else { return }
        
        // Simple implementation: prompt for URL
        let alert = NSAlert()
        alert.messageText = "Insert Link"
        alert.informativeText = "Enter URL:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        input.placeholderString = "https://example.com"
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        
        if alert.runModal() == .alertFirstButtonReturn {
            let urlString = input.stringValue
            if !urlString.isEmpty, let url = URL(string: urlString) {
                let range = textView.selectedRange()
                let textStorage = textView.textStorage!
                let linkText = range.length == 0 ? urlString : (textStorage.string as NSString).substring(with: range)
                
                let attributedString = NSMutableAttributedString(string: linkText)
                attributedString.addAttribute(.link, value: url, range: NSRange(location: 0, length: linkText.count))
                
                textView.textStorage?.replaceCharacters(in: range, with: attributedString)
            }
        }
    }
    
    enum ListType {
        case bullet
        case number
    }
}
