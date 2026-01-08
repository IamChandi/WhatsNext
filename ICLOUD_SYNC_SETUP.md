# iCloud Sync Setup - Share Data Between macOS and iOS

This guide will help you configure iCloud sync so your goals and tasks are shared between the macOS and iOS apps.

## Overview

We'll use **CloudKit** (Apple's cloud database) to sync SwiftData between:
- macOS app (WhatsNext)
- iOS app (WhatsNextiOSApp)

Both apps will share the same CloudKit container, so changes sync automatically.

## Prerequisites

1. **Apple Developer Account** (required for CloudKit)
2. Both apps configured in Xcode
3. Same Apple ID signed in on both devices

## Step 1: Create CloudKit Container

### In Xcode (for iOS app):

1. Open **WhatsNextiOSApp** project
2. Select project → **WhatsNextiOSApp** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Add **"iCloud"** capability
6. Check **"CloudKit"**
7. In **Containers**, click **"+ Add Container"**
8. Enter: `iCloud.com.yourname.WhatsNext` (use your bundle identifier prefix)
9. Click **OK**

### In Xcode (for macOS app):

1. Open **WhatsNext** project
2. Select project → **WhatsNext** target
3. Go to **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Add **"iCloud"** capability
6. Check **"CloudKit"**
7. In **Containers**, select the **SAME container** you created above:
   - `iCloud.com.yourname.WhatsNext`
8. If it doesn't appear, click **"+ Add Container"** and enter the same name

**Important**: Both apps MUST use the **exact same container identifier**!

## Step 2: Update ModelContainer Configuration

The code has been updated to use CloudKit. Both apps will now:
- Store data locally (for offline access)
- Sync to iCloud automatically
- Share data between devices

## Step 3: Verify Entitlements

Both apps should have in their `.entitlements` files:

```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.yourname.WhatsNext</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

## Step 4: Test Sync

1. **On macOS**: Create a goal "Test Sync"
2. **Wait a few seconds** for sync
3. **On iOS**: Open app - you should see "Test Sync"
4. **On iOS**: Mark it complete
5. **On macOS**: It should update automatically

## How It Works

- **Local First**: Data is stored locally for fast access
- **Background Sync**: CloudKit syncs in the background
- **Automatic**: No manual sync needed
- **Conflict Resolution**: CloudKit handles conflicts automatically
- **Offline Support**: Works offline, syncs when online

## Troubleshooting

### Data not syncing

1. **Check iCloud is enabled**:
   - macOS: System Settings → Apple ID → iCloud → iCloud Drive (ON)
   - iOS: Settings → [Your Name] → iCloud → iCloud Drive (ON)

2. **Check same Apple ID**:
   - Both devices must use the same Apple ID
   - Settings → [Your Name] → verify Apple ID

3. **Check CloudKit container**:
   - Both apps must use the SAME container identifier
   - Verify in Xcode → Signing & Capabilities

4. **Wait for sync**:
   - First sync can take 30-60 seconds
   - Subsequent syncs are faster (5-10 seconds)

5. **Check network**:
   - Both devices need internet connection
   - Wi-Fi or cellular data

### "CloudKit not available"

- Ensure you're signed in with Apple ID
- Check iCloud Drive is enabled
- Verify CloudKit capability is added in Xcode

### Data appears on one device but not the other

- Wait 30-60 seconds for sync
- Pull down to refresh (iOS)
- Restart both apps
- Check both devices are online

## Privacy & Security

- Data is encrypted in transit and at rest
- Only synced to your iCloud account
- Not accessible by Apple or third parties
- Requires your Apple ID password

## Next Steps

After setup:
1. Test creating goals on macOS
2. Verify they appear on iOS
3. Test editing on both platforms
4. Verify deletions sync

Your goals will now be available on all your devices! 🎉
