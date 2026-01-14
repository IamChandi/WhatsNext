//
//  AppDelegate.swift
//  WhatsNextiOS
//
//  Built with <3 by Chandi Kodthiwada
//  Linkedin: https://www.linkedin.com/in/chandikodthiwada/
//  Github: https://github.com/IamChandi
//

import Foundation
import UIKit
import UserNotifications
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    private var endOfDayTimer: Timer?
    private var modelContainer: ModelContainer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermissionAndSchedule()
        setupEndOfDayTimer()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        endOfDayTimer?.invalidate()
    }

    private func setupModelContainer() {
        do {
            let schema = Schema([
                Goal.self,
                Subtask.self,
                Tag.self,
                GoalAlert.self,
                RecurrenceRule.self,
                HistoryEntry.self
            ])
            modelContainer = try ModelContainer(for: schema)
        } catch {
            print("Failed to setup model container: \(error)")
        }
    }

    private func requestNotificationPermissionAndSchedule() {
        Task {
            await NotificationService.shared.scheduleDailyReminders()
        }
    }

    private func setupEndOfDayTimer() {
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate next 8:00 PM
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = 20
        components.minute = 0
        
        guard let nextEvening = calendar.date(from: components) else { return }
        var targetDate = nextEvening > now ? nextEvening : calendar.date(byAdding: .day, value: 1, to: nextEvening)!
        
        // Skip weekends - find next weekday
        targetDate = nextWeekday(from: targetDate, calendar: calendar)
        
        let timeInterval = targetDate.timeIntervalSince(now)
        
        endOfDayTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.handleEndOfDay()
            self?.setupEndOfDayTimer() // Reschedule for next weekday
        }
    }
    
    private func nextWeekday(from date: Date, calendar: Calendar) -> Date {
        var targetDate = date
        var weekday = calendar.component(.weekday, from: targetDate)
        
        // Skip weekends: Saturday=7, Sunday=1
        while weekday == 1 || weekday == 7 {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
            weekday = calendar.component(.weekday, from: targetDate)
        }
        
        return targetDate
    }

    private func handleEndOfDay() {
        // Notify UI to refresh using AppState
        Task { @MainActor in
            AppState.shared.notifyGoalsUpdated()
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        guard let goalIdString = userInfo["goalId"] as? String,
              let goalId = UUID(uuidString: goalIdString) else {
            completionHandler()
            return
        }
        
        Task { @MainActor in
            switch response.actionIdentifier {
            case "COMPLETE_ACTION":
                AppState.shared.completeGoal(id: goalId)
            case "SNOOZE_ACTION":
                AppState.shared.snoozeGoal(id: goalId)
            default:
                AppState.shared.openGoal(id: goalId)
            }
        }
        
        completionHandler()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notifications even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
