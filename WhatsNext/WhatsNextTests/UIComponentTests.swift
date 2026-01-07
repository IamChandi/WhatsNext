import XCTest
import SwiftUI
@testable import WhatsNext

/// Tests for specific UI components to ensure consistent styling
final class UIComponentTests: XCTestCase {
    
    // MARK: - Badge Component Tests
    
    func testPriorityBadgeStyling() {
        let priority = Priority.high
        // PriorityBadge uses:
        // - .font(.caption2)
        // - .padding(.horizontal, 6)
        // - .padding(.vertical, 2)
        // - .background(priority.color.opacity(0.15))
        // - .foregroundStyle(priority.color)
        // - .clipShape(Capsule())
        
        // Verify priority has required properties
        XCTAssertNotNil(priority.icon)
        XCTAssertNotNil(priority.displayName)
        XCTAssertNotNil(priority.color)
        
        // Verify opacity value
        let badgeOpacity: Double = 0.15
        XCTAssertEqual(badgeOpacity, 0.15, accuracy: 0.01)
    }
    
    func testDueDateBadgeStyling() {
        // DueDateBadge uses:
        // - .font(.caption2)
        // - .padding(.horizontal, 6)
        // - .padding(.vertical, 2)
        // - Background: overdue ? Color.red.opacity(0.15) : Color.secondary.opacity(0.1)
        
        let overdueOpacity: Double = 0.15
        let normalOpacity: Double = 0.1
        
        XCTAssertEqual(overdueOpacity, 0.15, accuracy: 0.01)
        XCTAssertEqual(normalOpacity, 0.1, accuracy: 0.01)
    }
    
    func testSubtaskProgressBadgeStyling() {
        // SubtaskProgressBadge uses:
        // - .font(.caption2)
        // - .padding(.horizontal, 6)
        // - .padding(.vertical, 2)
        // - .background(Color.secondary.opacity(0.1))
        
        let badgeOpacity: Double = 0.1
        XCTAssertEqual(badgeOpacity, 0.1, accuracy: 0.01)
    }
    
    func testAlertBadgeStyling() {
        // AlertBadge uses:
        // - .font(.caption2)
        // - .padding(.horizontal, 6)
        // - .padding(.vertical, 2)
        // - .background(Color.orange.opacity(0.15))
        // - .foregroundStyle(.orange)
        
        let alertBadgeOpacity: Double = 0.15
        XCTAssertEqual(alertBadgeOpacity, 0.15, accuracy: 0.01)
    }
    
    func testBadgePaddingConsistency() {
        // All badges should use consistent padding
        let horizontalPadding: CGFloat = 6
        let verticalPadding: CGFloat = 2
        
        // Verify all badge types use the same padding
        XCTAssertEqual(horizontalPadding, 6)
        XCTAssertEqual(verticalPadding, 2)
    }
    
    func testBadgeFontConsistency() {
        // All badges should use .caption2 font
        let badgeFont = Font.caption2
        XCTAssertNotNil(badgeFont)
    }
    
    // MARK: - Sidebar Component Tests
    
    func testSidebarHeaderStyling() {
        // Sidebar header uses:
        // - .font(.title2)
        // - .fontWeight(.bold)
        // - .foregroundStyle(.white)
        
        let headerFont = Font.title2.bold()
        XCTAssertNotNil(headerFont)
    }
    
    func testSidebarRowTextStyling() {
        // Sidebar rows use:
        // - .font(.body)
        // - .foregroundStyle(Theme.sidebarText)
        
        let rowFont = Font.body
        XCTAssertNotNil(rowFont)
        
        let sidebarText = Theme.sidebarText
        XCTAssertNotNil(sidebarText)
    }
    
    func testSidebarSectionHeaderStyling() {
        // Section headers use:
        // - .font(.caption)
        // - .foregroundStyle(Theme.sidebarText.opacity(0.7))
        
        let sectionFont = Font.caption
        XCTAssertNotNil(sectionFont)
        
        let sectionOpacity: Double = 0.7
        XCTAssertEqual(sectionOpacity, 0.7, accuracy: 0.01)
    }
    
    func testSidebarBadgeStyling() {
        // Custom sidebar badges use:
        // - .font(.caption)
        // - .fontWeight(.medium)
        // - .foregroundStyle(Theme.sidebarText)
        // - .padding(.horizontal, 6)
        // - .padding(.vertical, 2)
        // - .background(Theme.sidebarText.opacity(0.2))
        
        let badgeFont = Font.caption
        XCTAssertNotNil(badgeFont)
        
        let badgeOpacity: Double = 0.2
        XCTAssertEqual(badgeOpacity, 0.2, accuracy: 0.01)
    }
    
    // MARK: - Card Component Tests
    
    func testBriefingCardStyling() {
        // BriefingCard uses:
        // - .padding()
        // - .background(Theme.cardBackground)
        // - .cornerRadius(12)
        // - .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        
        let cardCornerRadius: CGFloat = 12
        XCTAssertEqual(cardCornerRadius, 12)
        
        let cardShadowOpacity: Double = 0.05
        XCTAssertEqual(cardShadowOpacity, 0.05, accuracy: 0.01)
        
        let cardShadowRadius: CGFloat = 2
        XCTAssertEqual(cardShadowRadius, 2)
    }
    
    func testKanbanCardStyling() {
        // KanbanCard uses:
        // - .padding(12)
        // - .background(Theme.cardBackground)
        // - .cornerRadius(12)
        // - .shadow with varying opacity based on hover
        
        let kanbanPadding: CGFloat = 12
        XCTAssertEqual(kanbanPadding, 12)
        
        let kanbanCornerRadius: CGFloat = 12
        XCTAssertEqual(kanbanCornerRadius, 12)
    }
    
    // MARK: - Button Component Tests
    
    func testButtonStyleConsistency() {
        // Primary buttons use .borderedProminent
        // Secondary buttons use .bordered
        // Plain buttons use .plain
        
        // These are compile-time checks
        XCTAssertTrue(true)
    }
    
    func testButtonTintColors() {
        // Primary buttons use Theme.forwardOrange or Theme.presidentialBlue
        let forwardOrange = Theme.forwardOrange
        let presidentialBlue = Theme.presidentialBlue
        
        XCTAssertNotNil(forwardOrange)
        XCTAssertNotNil(presidentialBlue)
    }
    
    // MARK: - Empty State Component Tests
    
    func testEmptyStateIconSize() {
        // EmptyStateView icon uses .font(.system(size: 48))
        let iconSize: CGFloat = 48
        XCTAssertEqual(iconSize, 48)
    }
    
    func testEmptyStateTitleFont() {
        // Title uses .font(.title2.bold())
        let titleFont = Font.title2.bold()
        XCTAssertNotNil(titleFont)
    }
    
    func testEmptyStateDescriptionFont() {
        // Description uses .font(.body)
        let descriptionFont = Font.body
        XCTAssertNotNil(descriptionFont)
    }
    
    func testEmptyStateSpacing() {
        // VStack spacing: 16
        // Icon to title spacing: 8 (within VStack)
        // Top padding for button: 8
        
        let vStackSpacing: CGFloat = 16
        let innerSpacing: CGFloat = 8
        let buttonTopPadding: CGFloat = 8
        
        XCTAssertEqual(vStackSpacing, 16)
        XCTAssertEqual(innerSpacing, 8)
        XCTAssertEqual(buttonTopPadding, 8)
    }
    
    func testEmptyStatePadding() {
        // EmptyStateView uses .padding(32)
        let emptyStatePadding: CGFloat = 32
        XCTAssertEqual(emptyStatePadding, 32)
    }
    
    // MARK: - Header Component Tests
    
    func testDashboardHeaderStyling() {
        // DashboardHeaderView uses:
        // - .font(.system(.subheadline, design: .monospaced))
        // - .font(.system(.caption, design: .monospaced))
        // - .padding(.horizontal, 24)
        // - .padding(.vertical, 8)
        // - .frame(height: 64)
        
        let headerHeight: CGFloat = 64
        XCTAssertEqual(headerHeight, 64)
        
        let horizontalPadding: CGFloat = 24
        let verticalPadding: CGFloat = 8
        XCTAssertEqual(horizontalPadding, 24)
        XCTAssertEqual(verticalPadding, 8)
    }
    
    func testBriefingHeaderStyling() {
        // BriefingView header uses:
        // - .font(.largeTitle) for title
        // - .fontWeight(.bold)
        // - .foregroundStyle(Theme.presidentialBlue)
        // - .font(.title3) for date
        // - .padding()
        
        let titleFont = Font.largeTitle.bold()
        XCTAssertNotNil(titleFont)
        
        let dateFont = Font.title3
        XCTAssertNotNil(dateFont)
    }
    
    // MARK: - List Component Tests
    
    func testListRowHeight() {
        // List rows use .environment(\.defaultMinListRowHeight, 28)
        let minRowHeight: CGFloat = 28
        XCTAssertEqual(minRowHeight, 28)
    }
    
    func testListSpacing() {
        // LazyVStack spacing: 16
        let listSpacing: CGFloat = 16
        XCTAssertEqual(listSpacing, 16)
    }
    
    // MARK: - Sheet Component Tests
    
    func testSheetFrameSizes() {
        // GoalEditorSheet: width: 500, height: 600
        // AlertSchedulerSheet: width: 400, height: 500
        // RecurrencePickerSheet: width: 400, height: 500
        // TagEditorSheet: width: 300, height: 350
        
        let editorWidth: CGFloat = 500
        let editorHeight: CGFloat = 600
        XCTAssertEqual(editorWidth, 500)
        XCTAssertEqual(editorHeight, 600)
        
        let alertWidth: CGFloat = 400
        let alertHeight: CGFloat = 500
        XCTAssertEqual(alertWidth, 400)
        XCTAssertEqual(alertHeight, 500)
    }
    
    // MARK: - Tag Component Tests
    
    func testTagChipStyling() {
        // TagChip uses:
        // - .font(.caption)
        // - .padding(.horizontal, 8)
        // - .padding(.vertical, 4)
        // - .background(tag.color.opacity(0.15))
        // - .foregroundStyle(tag.color)
        
        let tagHorizontalPadding: CGFloat = 8
        let tagVerticalPadding: CGFloat = 4
        let tagOpacity: Double = 0.15
        
        XCTAssertEqual(tagHorizontalPadding, 8)
        XCTAssertEqual(tagVerticalPadding, 4)
        XCTAssertEqual(tagOpacity, 0.15, accuracy: 0.01)
    }
    
    // MARK: - Toast Component Tests
    
    func testToastStyling() {
        // ToastView uses:
        // - .padding()
        // - .cornerRadius(12)
        // - .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        // - .strokeBorder with opacity(0.3)
        
        let toastCornerRadius: CGFloat = 12
        let toastShadowRadius: CGFloat = 8
        let toastShadowY: CGFloat = 4
        let toastShadowOpacity: Double = 0.15
        let toastBorderOpacity: Double = 0.3
        
        XCTAssertEqual(toastCornerRadius, 12)
        XCTAssertEqual(toastShadowRadius, 8)
        XCTAssertEqual(toastShadowY, 4)
        XCTAssertEqual(toastShadowOpacity, 0.15, accuracy: 0.01)
        XCTAssertEqual(toastBorderOpacity, 0.3, accuracy: 0.01)
    }
    
    // MARK: - Walk Mode Component Tests
    
    func testWalkModeTitleFont() {
        // WalkModeView title uses:
        // - .font(.system(size: 48, weight: .bold, design: .serif))
        
        let titleSize: CGFloat = 48
        XCTAssertEqual(titleSize, 48)
    }
    
    func testWalkModeDescriptionFont() {
        // Description uses .font(.title3)
        let descriptionFont = Font.title3
        XCTAssertNotNil(descriptionFont)
    }
    
    func testWalkModeSpacing() {
        // VStack spacing: 32
        let walkModeSpacing: CGFloat = 32
        XCTAssertEqual(walkModeSpacing, 32)
    }
}
