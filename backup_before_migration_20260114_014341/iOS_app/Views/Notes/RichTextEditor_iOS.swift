import SwiftUI
import UIKit

/// Rich text editor for iOS using UITextView with formatting toolbar.
struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    var onTextChange: ((NSAttributedString) -> Void)?
    var textViewBinding: Binding<UITextView?>?
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        
        // Configure text view
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsEditingTextAttributes = true
        textView.dataDetectorTypes = [.link]
        textView.font = .systemFont(ofSize: 17)
        textView.textColor = .label
        textView.backgroundColor = .clear
        textView.autocorrectionType = .yes
        textView.autocapitalizationType = .sentences
        textView.keyboardType = .default
        textView.returnKeyType = .default
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        
        // Set up delegate
        textView.delegate = context.coordinator
        
        // Set initial content
        textView.attributedText = attributedText
        
        context.coordinator.textView = textView
        textViewBinding?.wrappedValue = textView
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Only update if content actually changed (avoid infinite loops)
        if !uiView.attributedText.isEqual(to: attributedText) {
            uiView.attributedText = attributedText
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var textView: UITextView?
        private var isUpdating = false
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            guard !isUpdating else { return }
            
            let attributedString = textView.attributedText ?? NSAttributedString()
            parent.attributedText = attributedString
            parent.onTextChange?(attributedString)
        }
    }
}

/// Toolbar for rich text formatting controls (floating toolbar for iOS).
struct RichTextToolbar: View {
    @Binding var textView: UITextView?
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Bold
            Button(action: { toggleFormatting(.traitBold) }) {
                Image(systemName: "bold")
                    .foregroundColor(isBold ? Theme.accent : Theme.secondaryText)
            }
            
            // Italic
            Button(action: { toggleFormatting(.traitItalic) }) {
                Image(systemName: "italic")
                    .foregroundColor(isItalic ? Theme.accent : Theme.secondaryText)
            }
            
            // Underline
            Button(action: { toggleUnderline() }) {
                Image(systemName: "underline")
                    .foregroundColor(isUnderline ? Theme.accent : Theme.secondaryText)
            }
            
            Divider()
                .frame(height: 20)
            
            // Bullet list
            Button(action: { insertList(type: .bullet) }) {
                Image(systemName: "list.bullet")
                    .foregroundColor(Theme.secondaryText)
            }
            
            // Numbered list
            Button(action: { insertList(type: .number) }) {
                Image(systemName: "list.number")
                    .foregroundColor(Theme.secondaryText)
            }
            
            Divider()
                .frame(height: 20)
            
            // Link
            Button(action: { insertLink() }) {
                Image(systemName: "link")
                    .foregroundColor(Theme.secondaryText)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(Theme.secondaryBackground)
        .cornerRadius(DesignSystem.CornerRadius.medium)
        .shadow(DesignSystem.Shadow.small)
        .onChange(of: textView?.selectedRange) {
            updateFormattingState()
        }
    }
    
    private func toggleFormatting(_ trait: UIFontDescriptor.SymbolicTraits) {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange
        let textStorage = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        // Get current font
        let currentFont: UIFont
        if range.length > 0 {
            currentFont = textStorage.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont ?? .systemFont(ofSize: 17)
        } else {
            currentFont = textView.typingAttributes[.font] as? UIFont ?? .systemFont(ofSize: 17)
        }
        
        // Toggle trait
        var traits = currentFont.fontDescriptor.symbolicTraits
        let hasTrait = traits.contains(trait)
        
        if hasTrait {
            traits.remove(trait)
        } else {
            traits.insert(trait)
        }
        
        if let newFontDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
            let newFont = UIFont(descriptor: newFontDescriptor, size: currentFont.pointSize)
            
            if range.length > 0 {
                // Apply to selected text
                textStorage.addAttribute(.font, value: newFont, range: range)
                textView.attributedText = textStorage
                textView.selectedRange = range
            } else {
                // Apply to typing attributes for next typed character
                var typingAttrs = textView.typingAttributes
                typingAttrs[.font] = newFont
                textView.typingAttributes = typingAttrs
            }
        }
        
        updateFormattingState()
    }
    
    private func toggleUnderline() {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange
        let textStorage = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        
        // Get current underline state
        let currentUnderline: Int
        if range.length > 0 {
            currentUnderline = textStorage.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int ?? 0
        } else {
            currentUnderline = textView.typingAttributes[.underlineStyle] as? Int ?? 0
        }
        
        let underlineValue = currentUnderline == 0 ? NSUnderlineStyle.single.rawValue : 0
        
        if range.length > 0 {
            // Apply to selected text
            textStorage.addAttribute(.underlineStyle, value: underlineValue, range: range)
            textView.attributedText = textStorage
            textView.selectedRange = range
        } else {
            // Apply to typing attributes for next typed character
            var typingAttrs = textView.typingAttributes
            typingAttrs[.underlineStyle] = underlineValue
            textView.typingAttributes = typingAttrs
        }
        
        updateFormattingState()
    }
    
    private func insertList(type: ListType) {
        guard let textView = textView else { return }
        
        let range = textView.selectedRange
        let textStorage = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let fullText = textStorage.string as NSString
        let selectedText = fullText.substring(with: range)
        
        // If no selection, get current line
        let textToFormat: String
        let rangeToReplace: NSRange
        
        if range.length == 0 {
            // Get current line
            let lineRange = fullText.lineRange(for: range)
            textToFormat = fullText.substring(with: lineRange)
            rangeToReplace = lineRange
        } else {
            textToFormat = selectedText
            rangeToReplace = range
        }
        
        // Split into lines and add list markers
        let lines = textToFormat.components(separatedBy: .newlines)
        let marker = type == .bullet ? "• " : "1. "
        let newText = lines.map { marker + $0 }.joined(separator: "\n")
        
        // Preserve attributes from start of range
        let attributes = textStorage.attributes(at: rangeToReplace.location, effectiveRange: nil)
        let replacement = NSAttributedString(string: newText, attributes: attributes)
        textStorage.replaceCharacters(in: rangeToReplace, with: replacement)
        
        textView.attributedText = textStorage
        textView.selectedRange = NSRange(location: rangeToReplace.location, length: newText.count)
    }
    
    private func insertLink() {
        guard let textView = textView else { return }
        
        // Show alert for URL input
        let alert = UIAlertController(title: "Insert Link", message: "Enter URL:", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "https://example.com"
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Insert", style: .default) { _ in
            guard let urlString = alert.textFields?.first?.text, !urlString.isEmpty,
                  let url = URL(string: urlString) else { return }
            
            let range = textView.selectedRange
            let textStorage = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            let fullText = textStorage.string as NSString
            let linkText = range.length == 0 ? urlString : fullText.substring(with: range)
            
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: url,
                .foregroundColor: UIColor.systemBlue
            ]
            
            let linkString = NSAttributedString(string: linkText, attributes: linkAttributes)
            textStorage.replaceCharacters(in: range, with: linkString)
            
            textView.attributedText = textStorage
            textView.selectedRange = NSRange(location: range.location, length: linkText.count)
        })
        
        // Present alert - need to get the root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
    
    private func updateFormattingState() {
        guard let textView = textView, textView.selectedRange.length > 0 else {
            isBold = false
            isItalic = false
            isUnderline = false
            return
        }
        
        let range = textView.selectedRange
        let font = textView.attributedText.attribute(.font, at: range.location, effectiveRange: nil) as? UIFont
        
        if let font = font {
            let traits = font.fontDescriptor.symbolicTraits
            isBold = traits.contains(UIFontDescriptor.SymbolicTraits.traitBold)
            isItalic = traits.contains(UIFontDescriptor.SymbolicTraits.traitItalic)
        }
        
        // Check underline
        let underline = textView.attributedText.attribute(.underlineStyle, at: range.location, effectiveRange: nil) as? Int
        isUnderline = underline != nil && underline != 0
    }
    
    enum ListType {
        case bullet
        case number
    }
}
