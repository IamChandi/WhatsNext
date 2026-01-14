import SwiftUI

/// Compact note display for lists showing preview, last updated, and link count.
struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                // Preview text (3 lines max)
                Text(note.plainText)
                    .font(DesignSystem.Typography.body)
                    .lineLimit(3)
                    .foregroundColor(Theme.primaryText)
                
                // Metadata row
                HStack(spacing: 12) {
                    // Last updated
                    Label(note.updatedAt.formatted(.relative(presentation: .named)), systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(Theme.secondaryText)
                }
            }
            
            Spacer()
            
            // Recent indicator
            if note.isRecent {
                Circle()
                    .fill(Theme.accent)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 4)
    }
}
