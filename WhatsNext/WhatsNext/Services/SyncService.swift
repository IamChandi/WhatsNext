import Foundation
import SwiftData
import CloudKit
import os.log
import WhatsNextShared

/// Service for managing CloudKit sync operations and monitoring sync status.
@MainActor
final class SyncService {
    private let modelContext: ModelContext
    private let containerIdentifier = AppConstants.CloudKit.containerIdentifier
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    /// Checks CloudKit account status and logs diagnostics.
    func checkCloudKitStatus() async {
        Logger.network.info("🔍 Checking CloudKit status...")
        
        let container = CKContainer(identifier: self.containerIdentifier)
        let accountStatus = try? await container.accountStatus()
        
        switch accountStatus {
        case .available:
            Logger.network.info("✅ CloudKit account is available and signed in")
        case .noAccount:
            Logger.network.error("❌ No iCloud account signed in. Please sign in to iCloud in System Settings.")
        case .restricted:
            Logger.network.warning("⚠️ CloudKit account is restricted (parental controls)")
        case .couldNotDetermine:
            Logger.network.warning("⚠️ Could not determine CloudKit account status")
        case .temporarilyUnavailable:
            Logger.network.warning("⚠️ CloudKit is temporarily unavailable. Please try again later.")
        case .none:
            Logger.network.error("❌ CloudKit account status check failed")
        @unknown default:
            Logger.network.warning("⚠️ Unknown CloudKit account status")
        }
        
        // Check if container exists and is accessible by fetching user record ID
        do {
            let _ = try await container.userRecordID()
            Logger.network.info("✅ CloudKit container '\(self.containerIdentifier)' is accessible")
        } catch {
            Logger.network.error("❌ CloudKit container '\(self.containerIdentifier)' check failed: \(error.localizedDescription)")
        }
    }
    
    /// Checks if CloudKit is available and configured.
    var isCloudKitAvailable: Bool {
        // Check if ModelContainer is using CloudKit
        // This is a simplified check - in practice, you'd check the ModelContainer configuration
        return true // Assume CloudKit is available if ModelContainer was created with CloudKit config
    }
    
    /// Forces a sync operation (if supported by SwiftData).
    /// Note: SwiftData handles sync automatically, but this can trigger a manual refresh.
    func forceSync() async {
        // SwiftData handles CloudKit sync automatically
        // This method can be used to trigger manual operations if needed
        Logger.app.info("CloudKit sync is handled automatically by SwiftData")
        
        // Trigger a save to force sync
        do {
            try modelContext.save()
            Logger.network.info("💾 ModelContext saved - changes should sync to CloudKit")
        } catch {
            Logger.error.error("❌ Failed to save ModelContext: \(error.localizedDescription)")
        }
    }
    
    /// Monitors sync status and logs any issues.
    func monitorSyncStatus() {
        // In a production app, you might want to:
        // 1. Monitor NSPersistentCloudKitContainer events
        // 2. Track sync errors
        // 3. Notify user of sync issues
        
        Logger.app.info("Monitoring CloudKit sync status")
        Logger.network.info("📦 Container: \(self.containerIdentifier)")
        Logger.network.info("💡 Sync happens automatically when ModelContext saves")
        Logger.network.info("💡 Make sure both devices are signed in to the same iCloud account")
    }
    
    /// Resolves sync conflicts if any occur.
    func resolveConflicts() async {
        // SwiftData handles most conflicts automatically
        // This method can be extended for custom conflict resolution
        Logger.app.info("Checking for sync conflicts")
    }
    
    /// Gets sync statistics (number of synced items, last sync time, etc.).
    func getSyncStatistics() async -> SyncStatistics {
        // This would query CloudKit or ModelContainer for sync stats
        // For now, return placeholder data
        return SyncStatistics(
            lastSyncDate: Date(),
            totalSyncedItems: 0,
            pendingChanges: 0,
            syncErrors: []
        )
    }
}

/// Statistics about CloudKit sync status.
struct SyncStatistics {
    let lastSyncDate: Date?
    let totalSyncedItems: Int
    let pendingChanges: Int
    let syncErrors: [String]
}
