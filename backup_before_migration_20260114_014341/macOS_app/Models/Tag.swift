import Foundation
import SwiftUI
import SwiftData

@Model
final class Tag {
    var id: UUID = UUID()
    var name: String = ""
    var colorHex: String = "#007AFF"
    
    @Relationship(deleteRule: .nullify, inverse: \Goal.tags)
    var goals: [Goal]?

    @Transient
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
    
    // CloudKit-compatible initializer
    init() {
        self.id = UUID()
        self.name = ""
        self.colorHex = "#007AFF"
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return "#007AFF"
        }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
