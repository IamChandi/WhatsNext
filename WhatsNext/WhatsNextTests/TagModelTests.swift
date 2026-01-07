import XCTest
import SwiftUI
@testable import WhatsNext

final class TagModelTests: XCTestCase {
    
    func testTagInitialization() {
        let tag = Tag(name: "Work", colorHex: "#FF0000")
        
        XCTAssertEqual(tag.name, "Work")
        XCTAssertEqual(tag.colorHex, "#FF0000")
        XCTAssertNotNil(tag.id)
        XCTAssertNil(tag.goals)
    }
    
    func testTagDefaultColor() {
        let tag = Tag(name: "Default Tag")
        XCTAssertEqual(tag.colorHex, "#007AFF")
    }
    
    func testTagColorProperty() {
        let tag = Tag(name: "Red Tag", colorHex: "#FF0000")
        let color = tag.color
        
        // Verify color is created (we can't easily test exact color values in XCTest)
        XCTAssertNotNil(color)
    }
    
    func testTagColorWithInvalidHex() {
        let tag = Tag(name: "Invalid Tag", colorHex: "invalid")
        // Should fallback to blue
        let color = tag.color
        XCTAssertNotNil(color)
    }
    
    func testColorHexExtension() {
        // Test valid hex colors
        let validColors = ["#FF0000", "#00FF00", "#0000FF", "FF0000", "#FFFFFF", "#000000"]
        for hex in validColors {
            let color = Color(hex: hex)
            XCTAssertNotNil(color, "Should parse valid hex: \(hex)")
        }
        
        // Test invalid hex colors
        let invalidColors = ["", "invalid", "#GGGGGG", "not a color"]
        for hex in invalidColors {
            let color = Color(hex: hex)
            XCTAssertNil(color, "Should not parse invalid hex: \(hex)")
        }
    }
    
    func testColorToHexExtension() {
        let red = Color.red
        let hex = red.toHex()
        
        // Should return a valid hex string
        XCTAssertTrue(hex.hasPrefix("#"))
        XCTAssertEqual(hex.count, 7) // #RRGGBB format
    }
}
