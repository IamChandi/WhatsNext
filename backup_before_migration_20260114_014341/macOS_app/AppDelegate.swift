import Foundation
import AppKit
import UserNotifications
import SwiftData
import Carbon
// TODO: After adding package dependency in Xcode, uncomment:
// import WhatsNextShared

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {

    private var endOfDayTimer: Timer?
    private var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        UNUserNotificationCenter.current().delegate = self
        requestNotificationPermissionAndSchedule()
        setupEndOfDayTimer()
        GlobalKeybindManager.shared.registerHotKey()
    }

    func applicationWillTerminate(_ notification: Notification) {
        endOfDayTimer?.invalidate()
        GlobalKeybindManager.shared.unregister()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in menu bar
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
        // Calculate time until 8 PM today (or tomorrow if past 8 PM)
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: Date())
        components.hour = 20
        components.minute = 0
        components.second = 0

        guard var targetDate = calendar.date(from: components) else { return }

        // If it's already past 8 PM, schedule for tomorrow
        if targetDate <= Date() {
            targetDate = calendar.date(byAdding: .day, value: 1, to: targetDate)!
        }

        let timeInterval = targetDate.timeIntervalSince(Date())

        // Schedule the first timer
        endOfDayTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.performEndOfDayTasks()
            }
            self?.scheduleRecurringEndOfDayTimer()
        }
    }

    private func scheduleRecurringEndOfDayTimer() {
        // Schedule to run every 24 hours
        endOfDayTimer = Timer.scheduledTimer(withTimeInterval: 24 * 60 * 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.performEndOfDayTasks()
            }
        }
    }

    @MainActor
    private func performEndOfDayTasks() {
        guard let container = modelContainer else { return }
        let context = container.mainContext
        NotificationService.shared.moveUnfinishedDailyGoalsToTomorrow(context: context)

        // Notify UI to refresh using AppState
        AppState.shared.notifyGoalsUpdated()
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        guard let goalIdString = userInfo["goalId"] as? String,
              let goalId = UUID(uuidString: goalIdString) else { return }

        await MainActor.run {
            switch response.actionIdentifier {
            case "COMPLETE_ACTION":
                AppState.shared.completeGoal(id: goalId)
            case "SNOOZE_ACTION":
                AppState.shared.snoozeGoal(id: goalId)
            default:
                AppState.shared.openGoal(id: goalId)
            }
        }
    }
}





class GlobalKeybindManager {
    static let shared = GlobalKeybindManager()
    
    // Carbon event reference
    private var eventHandler: EventHandlerRef?
    private var hotKeyRef: EventHotKeyRef?
    
    private init() {}
    
    func registerHotKey() {
        // defined keys: https://github.com/phracker/MacOSX-SDKs/blob/master/MacOSX10.6.sdk/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Versions/A/Headers/Events.h
        
        let hotKeyID = EventHotKeyID(signature: OSType(0x544F444F), id: 1) // Signature 'TODO', ID 1
        
        // Command + Shift + Space
        // kVK_Space = 0x31
        // cmdKey = 1 << 8
        // shiftKey = 1 << 9
        
        var gMyHotKeyRef: EventHotKeyRef? = nil
        
        let modifierFlags: UInt32 = UInt32(cmdKey | shiftKey)
        let keyCode: UInt32 = 0x31 // Space bar
        
        // RegisterEventHotKey requires a pointer to the hotkey ref, but let's be careful with Swift pointers.
        let status = RegisterEventHotKey(keyCode, modifierFlags, hotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef)
        
        if status != noErr {
            print("Failed to register hotkey: \(status)")
            return
        }
        
        hotKeyRef = gMyHotKeyRef
        
        // Install event handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        
        let handler: EventHandlerUPP = { (_: EventHandlerCallRef?, _: EventRef?, _: UnsafeMutableRawPointer?) -> OSStatus in
            DispatchQueue.main.async {
                GlobalKeybindManager.shared.handleHotKey()
            }
            return noErr
        }
        
        InstallEventHandler(GetApplicationEventTarget(), handler, 1, &eventType, nil, &eventHandler)
    }
    
    private func handleHotKey() {
        NSApp.activate(ignoringOtherApps: true)
        
        // Focus the quick entry field using AppState
        Task { @MainActor in
            AppState.shared.focusQuickEntryField()
        }
        
        // Also ensure the main window comes to front if closed/minimized
        if let window = NSApp.windows.first {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
        }
    }
}


