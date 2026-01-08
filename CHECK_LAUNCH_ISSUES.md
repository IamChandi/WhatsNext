# macOS App Launch Troubleshooting

## The Problem
Build succeeds but app doesn't launch or appear.

## Common Causes

### 1. App Launches But Window Doesn't Show
The app might be running but the window isn't visible. Check:
- **Dock**: Look for the app icon in the dock
- **Menu Bar**: Check if there's a menu bar icon (the app has a MenuBarExtra)
- **Activity Monitor**: Check if "WhatsNext" process is running

### 2. App Crashes Silently on Launch
Check the console for errors:
- **Xcode Console**: Look at the bottom panel when running
- **Console.app**: Open Console.app and filter for "WhatsNext"
- **System Logs**: Check for crash reports

### 3. Build Settings Issues
Check these in Xcode:
- **Info.plist**: Make sure it exists and is included
- **Entitlements**: Verify WhatsNext.entitlements is included
- **Code Signing**: Check signing settings

## Quick Checks

### Check 1: Is the App Running?
1. Open **Activity Monitor**
2. Search for "WhatsNext"
3. If it's running, the window might be hidden

### Check 2: Console Output
1. Run the app in Xcode (⌘ + R)
2. Check the **Console** (bottom panel)
3. Look for:
   - ✅ ModelContainer success messages
   - ❌ Error messages
   - Any crash logs

### Check 3: Window Activation
The app has code to activate the window on launch. If it's not showing:
- Check if there are multiple displays
- Check if window is off-screen
- Try clicking the dock icon

### Check 4: Menu Bar Icon
The app has a MenuBarExtra, so it should appear in the menu bar even if the window doesn't show. Look for:
- A checkmark icon in the menu bar
- Click it to open the menu bar view

## Build Settings to Verify

In Xcode, check:

1. **Target**: WhatsNext (not WhatsNextTests)
2. **Scheme**: WhatsNext (Debug)
3. **Run Destination**: My Mac
4. **Info.plist**: Should be auto-generated or present
5. **Entitlements**: WhatsNext.entitlements should be included

## Next Steps

1. **Run in Xcode** and check console
2. **Check Activity Monitor** for running process
3. **Check menu bar** for the app icon
4. **Share console output** if you see errors
