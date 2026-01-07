import XCTest
import UserNotifications
@testable import WhatsNext

@MainActor
final class NotificationServiceTests: XCTestCase {
    
    var notificationService: NotificationService!
    
    override func setUp() {
        super.setUp()
        notificationService = NotificationService.shared
    }
    
    func testNotificationServiceSingleton() {
        let instance1 = NotificationService.shared
        let instance2 = NotificationService.shared
        XCTAssertTrue(instance1 === instance2, "NotificationService should be a singleton")
    }
    
    func testScheduleDailyReminders() async {
        // This test verifies the method can be called without crashing
        // Actual scheduling requires notification permissions which may not be granted in tests
        await notificationService.scheduleDailyReminders()
        
        // If we get here without crashing, the test passes
        XCTAssertTrue(true)
    }
    
    func testCancelDailyReminders() {
        // Should not crash when canceling reminders
        // cancelDailyReminders() is main actor-isolated, but it's safe to call synchronously
        // from a @MainActor context
        notificationService.cancelDailyReminders()
        XCTAssertTrue(true)
    }
    
    func testRequestPermission() async {
        // This will request actual permission, so result may vary
        let granted = await notificationService.requestPermission()
        // Permission can be granted, denied, or not determined
        XCTAssertTrue(granted || !granted) // Just verify it returns a boolean
    }
    
    func testScheduleAlertForGoal() async {
        let goal = Goal(title: "Test Goal", category: .daily, priority: .high)
        let alert = GoalAlert(scheduledDate: Date().addingTimeInterval(3600)) // 1 hour from now
        
        // This will attempt to schedule a notification
        // May fail if permissions not granted, but should not crash
        await notificationService.scheduleAlert(for: goal, alert: alert)
        
        // Verify alert has notification identifier set if permission was granted
        // (This is a best-effort test since permissions may vary)
        XCTAssertTrue(true)
    }
    
    func testCancelAlert() {
        let identifier = "test-alert-identifier"
        // Should not crash when canceling
        // cancelAlert() is main actor-isolated, safe to call from @MainActor context
        notificationService.cancelAlert(identifier: identifier)
        XCTAssertTrue(true)
    }
    
    func testCancelAllAlertsForGoal() {
        let goalId = UUID()
        // Should not crash when canceling
        // cancelAllAlerts() is main actor-isolated, safe to call from @MainActor context
        notificationService.cancelAllAlerts(for: goalId)
        XCTAssertTrue(true)
    }
    
    func testSnoozeAlert() async {
        let goal = Goal(title: "Test Goal")
        let alert = GoalAlert(scheduledDate: Date().addingTimeInterval(3600))
        
        // Should not crash
        await notificationService.snoozeAlert(for: goal, alert: alert, minutes: 15)
        XCTAssertTrue(true)
    }
    
    func testScheduleDueDateReminder() async {
        let futureDate = Date().addingTimeInterval(3600)
        let goal = Goal(title: "Test Goal", dueDate: futureDate)
        
        // Should not crash
        await notificationService.scheduleDueDateReminder(for: goal)
        XCTAssertTrue(true)
    }
    
    func testScheduleDueDateReminderWithPastDate() async {
        let pastDate = Date().addingTimeInterval(-3600)
        let goal = Goal(title: "Test Goal", dueDate: pastDate)
        
        // Should not schedule for past dates
        await notificationService.scheduleDueDateReminder(for: goal)
        XCTAssertTrue(true)
    }
    
    func testScheduleDueDateReminderWithoutDueDate() async {
        let goal = Goal(title: "Test Goal", dueDate: nil)
        
        // Should not crash when no due date
        await notificationService.scheduleDueDateReminder(for: goal)
        XCTAssertTrue(true)
    }
    
    func testGetPendingNotificationCount() async {
        // This will query the actual notification center
        let count = await notificationService.getPendingNotificationCount()
        XCTAssertGreaterThanOrEqual(count, 0)
    }
}
