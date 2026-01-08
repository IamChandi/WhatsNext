# Fix: Duplicate Info.plist Error

## The Problem

You're getting duplicate `Info.plist` errors because:
- Xcode automatically generates an `Info.plist` for modern SwiftUI projects (iOS 14+)
- AND there's a manual `Info.plist` file in the project

## Solution: Remove Manual Info.plist (Recommended)

Modern Xcode projects don't need a separate `Info.plist` file. Configure app settings in Build Settings instead.

### Step 1: Remove the Manual Info.plist

1. In Xcode Project Navigator, find `Info.plist`
2. Right-click → **Delete** → **Move to Trash**
3. If asked, choose **Remove Reference** (not Move to Trash, since we want to keep it in the file system but not in the project)

### Step 2: Verify Build Settings

1. Select the **WhatsNextiOSApp** project (blue icon)
2. Select the **WhatsNextiOSApp** target
3. Go to **Build Settings** tab
4. Search for "Info.plist" and verify:
   - **Generate Info.plist File**: Should be **YES** ✅
   - **Info.plist File**: Should be **EMPTY** (no path)

### Step 3: Configure App Display Name

1. Still in **Build Settings**, search for "Product Name" or "Display Name"
2. Or go to **General** tab → **Display Name**: `What's Next?`
3. Or in Build Settings, add:
   - **INFOPLIST_KEY_CFBundleDisplayName** = `What's Next?`

### Step 4: Add Notification Permission Description

1. In **Build Settings**, search for "User-Defined" or scroll to that section
2. Click the **+** button to add a new setting
3. Add:
   - **Key**: `INFOPLIST_KEY_NSUserNotificationsUsageDescription`
   - **Value**: `We'll send you reminders about your goals and daily planning prompts.`

OR use the Info tab:
1. Go to **Info** tab (in target settings)
2. Click **+** under "Custom iOS Target Properties"
3. Add:
   - **Key**: `Privacy - User Notifications Usage Description`
   - **Type**: String
   - **Value**: `We'll send you reminders about your goals and daily planning prompts.`

### Step 5: Clean and Rebuild

1. **Product** → **Clean Build Folder** (⌘ + Shift + K)
2. **Product** → **Build** (⌘ + B)

The build should now succeed!

## Alternative: Use Manual Info.plist (Not Recommended)

If you prefer to keep the manual Info.plist:

1. In **Build Settings**, search for "Info.plist File"
2. Set the path to: `WhatsNextiOS/Info.plist` (relative to project root)
3. Set **Generate Info.plist File** to **NO**

But the first method (auto-generated) is recommended for modern iOS projects.

---

**After fixing, the build should succeed!**
