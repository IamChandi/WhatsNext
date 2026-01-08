# Diagnose macOS App Launch Issue

## Step-by-Step Diagnosis

### Step 1: Check if App is Running

1. **Open Activity Monitor** (Applications → Utilities → Activity Monitor)
2. **Search for "WhatsNext"**
3. **Check Status**:
   - ✅ If running: App launched but window might be hidden
   - ❌ If not running: App crashed or didn't launch

### Step 2: Check Console Output

1. **In Xcode**: Run the app (⌘ + R)
2. **Look at Console** (bottom panel)
3. **Check for**:
   - ✅ "ModelContainer created successfully" messages
   - ❌ Error messages or crash logs
   - Any red error text

### Step 3: Check Menu Bar

The app has a **MenuBarExtra**, so it should appear in the menu bar even if the window doesn't show:

1. **Look at the menu bar** (top of screen)
2. **Find the checkmark icon** (✓)
3. **Click it** to open the menu bar view

### Step 4: Check Window State

If the app is running but window isn't visible:

1. **Click the Dock icon** (if present)
2. **Try Window menu** → "Bring All to Front"
3. **Check multiple displays** - window might be on another screen
4. **Try Mission Control** - see if window is minimized or hidden

### Step 5: Check Build Settings in Xcode

1. **Open Xcode**
2. **Select WhatsNext project** (blue icon)
3. **Select WhatsNext target**
4. **Go to "Signing & Capabilities" tab**
5. **Verify**:
   - ✅ Team is selected (PAM98LWH2G)
   - ✅ Bundle Identifier: `com.whatsnext1.app`
   - ✅ CloudKit capability is added (if needed)

6. **Go to "Build Settings" tab**
7. **Search for "Info.plist"**
8. **Verify**: `GENERATE_INFOPLIST_FILE = YES` (should be auto-generated)

### Step 6: Check Scheme Settings

1. **Click scheme dropdown** (next to stop button)
2. **Select "Edit Scheme..."**
3. **Select "Run"** in left sidebar
4. **Check "Info" tab**:
   - ✅ Executable: WhatsNext
   - ✅ Build Configuration: Debug
5. **Check "Options" tab**:
   - ✅ "Allow debugging when using document Versions Browser" (optional)

### Step 7: Clean and Rebuild

1. **Product → Clean Build Folder** (⌘ + Shift + K)
2. **Delete Derived Data**:
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data
   - Delete WhatsNext folder
3. **Rebuild**: ⌘ + B
4. **Run**: ⌘ + R

### Step 8: Check Console.app for System Logs

1. **Open Console.app** (Applications → Utilities → Console)
2. **Filter for "WhatsNext"**
3. **Look for crash reports or errors**

## Common Issues and Fixes

### Issue 1: App Runs But Window Doesn't Show

**Fix**: The app has code to activate the window. If it's not showing:
- Check menu bar for the app icon
- Click the dock icon
- Try Window → Bring All to Front

### Issue 2: App Crashes on Launch

**Check Console** for:
- ModelContainer errors
- Missing entitlements
- Code signing issues

**Fix**: Share the console error message

### Issue 3: Build Succeeds But App Doesn't Launch

**Possible causes**:
- Scheme not set to run
- Wrong target selected
- Code signing issue

**Fix**: 
- Verify scheme is set to "WhatsNext" (not WhatsNextTests)
- Check Signing & Capabilities

### Issue 4: Silent Crash

**Check**:
- Console output in Xcode
- Console.app for system logs
- Activity Monitor for crash reports

## What to Share

If the app still doesn't launch, please share:

1. **Console output** from Xcode (all messages)
2. **Activity Monitor status** (is WhatsNext running?)
3. **Menu bar status** (do you see the checkmark icon?)
4. **Any error messages** you see

## Quick Test

Try this quick test:

1. **Run in Xcode** (⌘ + R)
2. **Immediately check**:
   - Console for messages
   - Menu bar for icon
   - Dock for app icon
3. **Share what you see**
