//
//  Tag.swift
//  WhatsNextShared
//
//  Created by Chandi Kodthiwada
//  Copyright © 2026 Chandi Kodthiwada. All rights reserved.
//

import Foundation
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(SwiftData)
import SwiftData
#endif

@Model
public final class Tag {
    public var id: UUID = UUID()
    public var name: String = ""
    public var colorHex: String = "#007AFF"
    
    @Relationship(deleteRule: .nullify, inverse: \Goal.tags)
    public var goals: [Goal]?

    #if canImport(SwiftUI)
    @Transient
    public var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    #endif

    public init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
    }
    
    // CloudKit-compatible initializer
    public init() {
        self.id = UUID()
        self.name = ""
        self.colorHex = "#007AFF"
    }
}

#if canImport(SwiftUI)
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

    public func toHex() -> String {
        #if canImport(AppKit)
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else {
            return "#007AFF"
        }
        #elseif canImport(UIKit)
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return "#007AFF"
        }
        #else
        return "#007AFF"
        #endif
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
#endif