# How to Enable CloudKit Later (When You Get Paid Account)

## Current Status

CloudKit has been **temporarily disabled** because free Apple Developer accounts don't support it.

The app now uses **local storage only** - data is stored on each device separately.

## When You Get a Paid Apple Developer Account ($99/year)

### Step 1: Update Code

In both `WhatsNextApp.swift` files (macOS and iOS):

**Find this:**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    isStoredInMemoryOnly: false
    // cloudKitDatabase: .automatic  // Uncomment when you have paid developer account
)
```

**Change to:**
```swift
let modelConfiguration = ModelConfiguration(
    schema: schema,
    cloudKitDatabase: .automatic
)
```

### Step 2: Add CloudKit Capability (macOS)

1. Open **WhatsNext** project
2. Select **WhatsNext** target
3. **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Add **"CloudKit"**
6. Add container: `iCloud.com.chandi.WhatsNext`

### Step 3: Add CloudKit Capability (iOS)

1. Open **WhatsNextiOSApp** project
2. Select **WhatsNextiOSApp** target
3. **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Add **"CloudKit"**
6. Add **same container**: `iCloud.com.chandi.WhatsNext`

### Step 4: Update Entitlements

**macOS** (`WhatsNext.entitlements`):
```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.chandi.WhatsNext</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

**iOS** (`WhatsNextiOS.entitlements`):
```xml
<key>com.apple.developer.icloud-container-identifiers</key>
<array>
    <string>iCloud.com.chandi.WhatsNext</string>
</array>
<key>com.apple.developer.icloud-services</key>
<array>
    <string>CloudKit</string>
</array>
```

### Step 5: Build and Test

1. Clean build folder (⌘ + Shift + K)
2. Build (⌘ + B)
3. Run on both devices
4. Test sync by creating a goal on one device

## Benefits of Paid Account

- ✅ CloudKit/iCloud sync
- ✅ App Store distribution
- ✅ TestFlight for beta testing
- ✅ Advanced app capabilities
- ✅ Professional development tools

## For Now

The app works perfectly with local storage. Each device will have its own data. When you're ready to sync, follow the steps above!
