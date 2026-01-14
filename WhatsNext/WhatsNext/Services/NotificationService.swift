import Foundation
import UserNotifications
import SwiftData
import os.log
import WhatsNextShared

/// Defines the configuration for a goal parsed from natural language.
struct GoalConfig {
    let title: String
    let priority: Priority
    let dueDate: Date?
}

/// A service that parses natural language strings to extract goal attributes.
struct NaturalLanguageParser {
    /// Parses the input text and returns a goal configuration.
    static func parse(_ text: String) -> GoalConfig {
        var title = text
        var priority: Priority = .medium
        var dueDate: Date? = nil
        
        // 1. Priority detection (case-insensitive)
        if title.localizedCaseInsensitiveContains("!high") || title.localizedCaseInsensitiveContains("!h") {
            priority = .high
            // Remove priority markers case-insensitively
            title = title.replacingOccurrences(of: "!high", with: "", options: .caseInsensitive)
            title = title.replacingOccurrences(of: "!h", with: "", options: .caseInsensitive)
        } else if title.localizedCaseInsensitiveContains("!low") || title.localizedCaseInsensitiveContains("!l") {
            priority = .low
            // Remove priority markers case-insensitively
            title = title.replacingOccurrences(of: "!low", with: "", options: .caseInsensitive)
            title = title.replacingOccurrences(of: "!l", with: "", options: .caseInsensitive)
        }
        
        // 2. Simple date detection (e.g., "tomorrow")
        if title.localizedCaseInsensitiveContains("tomorrow") {
            let calendar = Calendar.current
            dueDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
            title = title.replacingOccurrences(of: "tomorrow", with: "", options: .caseInsensitive)
        }
        
        // 3. Cleanup title
        title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        title = title.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        
        return GoalConfig(title: title, priority: priority, dueDate: dueDate)
    }
}

@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let morningHour = AppConstants.Notifications.morningHour
    private let eveningHour = AppConstants.Notifications.eveningHour

    private init() {
        setupNotificationCategories()
    }

    private func setupNotificationCategories() {
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "Mark Complete",
            options: [.foreground]
        )

        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "Snooze 15 min",
            options: []
        )

        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Goals",
            options: [.foreground]
        )

        let goalCategory = UNNotificationCategory(
            identifier: "GOAL_ALERT",
            actions: [completeAction, snoozeAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        let dailyReminderCategory = UNNotificationCategory(
            identifier: "DAILY_REMINDER",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        let endOfDayCategory = UNNotificationCategory(
            identifier: "END_OF_DAY",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            goalCategory,
            dailyReminderCategory,
            endOfDayCategory
        ])
    }

    // MARK: - Daily Scheduled Notifications

    func scheduleDailyReminders() async {
        let hasPermission = await requestPermission()
        guard hasPermission else { return }

        // Cancel existing daily reminders first
        cancelDailyReminders()

        // Schedule morning reminder at 9:00 AM
        await scheduleMorningReminder()

        // Schedule evening reminder at 8:00 PM
        await scheduleEveningReminder()
    }

    private func scheduleMorningReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "What's Next?"
        content.body = "How about we start with today's goals?"
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = morningHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-morning-reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            Logger.notifications.info("✅ Morning reminder scheduled successfully")
        } catch {
            Logger.notifications.error("❌ Failed to schedule morning reminder: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.notificationFailed(error), context: "scheduleMorningReminder")
        }
    }

    private func scheduleEveningReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "End of Day Review"
        content.body = "Unfinished daily goals have been moved to tomorrow. Great work today!"
        content.sound = .default
        content.categoryIdentifier = "END_OF_DAY"

        var dateComponents = DateComponents()
        dateComponents.hour = eveningHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "daily-evening-reminder",
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            Logger.notifications.info("✅ Evening reminder scheduled successfully")
        } catch {
            Logger.notifications.error("❌ Failed to schedule evening reminder: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.notificationFailed(error), context: "scheduleEveningReminder")
        }
    }

    func cancelDailyReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["daily-morning-reminder", "daily-evening-reminder"]
        )
    }

    // MARK: - End of Day Task Management

    func moveUnfinishedDailyGoalsToTomorrow(context: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Goal>(
            predicate: #Predicate<Goal> { goal in
                goal.categoryRaw == "daily" &&
                goal.statusRaw != "completed" &&
                goal.statusRaw != "archived"
            }
        )

        do {
            let unfinishedGoals = try context.fetch(fetchDescriptor)

            for goal in unfinishedGoals {
                // If the goal has a due date, move it to tomorrow
                if let dueDate = goal.dueDate {
                    let calendar = Calendar.current
                    if calendar.isDateInToday(dueDate) || dueDate < Date() {
                        goal.dueDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
                        goal.updatedAt = Date()
                    }
                }
            }

            try context.save()
            Logger.data.info("✅ Moved unfinished daily goals to tomorrow")
        } catch {
            Logger.data.error("❌ Failed to move unfinished goals: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.saveFailed(error), context: "moveUnfinishedDailyGoalsToTomorrow")
        }
    }

    // MARK: - Permissions

    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            Logger.notifications.info("Notification permission granted: \(granted)")
            return granted
        } catch {
            Logger.notifications.error("❌ Notification permission error: \(error.localizedDescription)")
            return false
        }
    }

    func scheduleAlert(for goal: Goal, alert: GoalAlert) async {
        let hasPermission = await requestPermission()
        guard hasPermission else { return }

        let content = UNMutableNotificationContent()
        content.title = goal.title
        content.body = alert.message ?? "Time for: \(goal.title)"
        content.sound = .default
        content.categoryIdentifier = "GOAL_ALERT"
        content.userInfo = [
            "goalId": goal.id.uuidString,
            "alertId": alert.id.uuidString
        ]

        // Add priority badge
        switch goal.priority {
        case .high:
            content.subtitle = "High Priority"
        case .medium:
            content.subtitle = goal.category.displayName
        case .low:
            content.subtitle = goal.category.displayName
        }

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: alert.scheduledDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let identifier = "goal-\(goal.id.uuidString)-alert-\(alert.id.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            alert.notificationIdentifier = identifier
            Logger.notifications.info("✅ Scheduled notification for goal: \(goal.title)")
        } catch {
            Logger.notifications.error("❌ Failed to schedule notification: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.notificationFailed(error), context: "scheduleAlert")
        }
    }

    func cancelAlert(identifier: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllAlerts(for goalId: UUID) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.content.userInfo["goalId"] as? String == goalId.uuidString }
                .map { $0.identifier }

            UNUserNotificationCenter.current()
                .removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }

    func rescheduleAlert(for goal: Goal, alert: GoalAlert, newDate: Date) async {
        // Cancel existing
        if let identifier = alert.notificationIdentifier {
            cancelAlert(identifier: identifier)
        }

        // Update and reschedule
        alert.scheduledDate = newDate
        alert.isTriggered = false
        await scheduleAlert(for: goal, alert: alert)
    }

    func snoozeAlert(for goal: Goal, alert: GoalAlert, minutes: Int = AppConstants.Notifications.snoozeMinutes) async {
        let newDate = Date().addingTimeInterval(Double(minutes * 60))
        await rescheduleAlert(for: goal, alert: alert, newDate: newDate)
    }

    func scheduleDueDateReminder(for goal: Goal) async {
        guard let dueDate = goal.dueDate, dueDate > Date() else { return }

        let hasPermission = await requestPermission()
        guard hasPermission else { return }

        let content = UNMutableNotificationContent()
        content.title = "Goal Due Now"
        content.body = goal.title
        content.sound = .default
        content.categoryIdentifier = "GOAL_ALERT"
        content.userInfo = ["goalId": goal.id.uuidString]

        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: dueDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let identifier = "goal-due-\(goal.id.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await UNUserNotificationCenter.current().add(request)
            Logger.notifications.info("✅ Scheduled due date reminder for goal: \(goal.title)")
        } catch {
            Logger.notifications.error("❌ Failed to schedule due date reminder: \(error.localizedDescription)")
            ErrorHandler.shared.handle(.notificationFailed(error), context: "scheduleDueDateReminder")
        }
    }

    func getPendingNotificationCount() async -> Int {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return requests.count
    }
}
