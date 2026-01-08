# Enable CloudKit Sync - Paid Account Setup

Congratulations on upgrading to a paid Apple Developer account! 🎉

## Quick Setup Steps

### Step 1: Add CloudKit Capability (macOS App)

1. Open **WhatsNext** project in Xcode
2. Select **WhatsNext** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"** button
5. Search for and add **"CloudKit"**
6. Click **"+ Add Container"**
7. Enter: `iCloud.com.chandi.WhatsNext`
8. Press Enter

### Step 2: Add CloudKit Capability (iOS App)

1. Open **WhatsNextiOSApp** project in Xcode
2. Select **WhatsNextiOSApp** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"** button
5. Search for and add **"CloudKit"**
6. Click **"+ Add Container"**
7. Enter the **SAME container**: `iCloud.com.chandi.WhatsNext`
8. Press Enter

**⚠️ CRITICAL**: Both apps MUST use the exact same container identifier!

### Step 3: Verify Code is Updated

✅ Code has been updated to use CloudKit
✅ Entitlements files have been updated
✅ Both apps configured for sync

### Step 4: Clean and Build

1. **Clean Build Folder**: Product → Clean Build Folder (⌘ + Shift + K)
2. **Build macOS app**: ⌘ + B
3. **Build iOS app**: ⌘ + B

### Step 5: Test Sync

1. **On macOS**: Create a goal "Test Sync"
2. **Wait 30-60 seconds** for CloudKit to sync
3. **On iOS**: Open app → Should see "Test Sync"
4. **On iOS**: Mark it complete
5. **On macOS**: Should update automatically

## Container Identifier

Both apps use: `iCloud.com.chandi.WhatsNext`

If you want to change this:
- Update in both entitlements files
- Update in both Xcode capabilities
- Must match exactly in both apps

## Troubleshooting

### "Cannot create provisioning profile"
- Make sure you're signed in with your paid account
- Xcode → Settings → Accounts → Verify your account
- Try cleaning build folder and rebuilding

### Data not syncing
1. **Check iCloud is enabled**:
   - macOS: System Settings → Apple ID → iCloud → iCloud Drive (ON)
   - iOS: Settings → [Your Name] → iCloud → iCloud Drive (ON)

2. **Same Apple ID**: Both devices must use the same Apple ID

3. **Wait for sync**: First sync takes 30-60 seconds

4. **Internet connection**: Both devices need internet

5. **Container match**: Verify both apps use the same container ID

### Build errors
- Clean build folder (⌘ + Shift + K)
- Delete Derived Data
- Restart Xcode
- Rebuild

## What Gets Synced

✅ Goals
✅ Subtasks  
✅ Tags
✅ Alerts
✅ Recurrence rules
✅ History entries

All changes sync automatically in the background!

## Next Steps

1. Add CloudKit capability in both Xcode projects
2. Clean and build
3. Test sync between devices
4. Enjoy seamless data sharing! 🎉
