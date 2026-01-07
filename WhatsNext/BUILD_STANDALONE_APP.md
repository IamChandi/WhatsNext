# Building a Standalone WhatsNext App

This guide explains how to create a standalone version of WhatsNext that runs independently without Xcode.

## Method 1: Quick Build (Recommended for Personal Use)

### Step 1: Build Release Version

**Option A: Using the Script**
```bash
cd /Users/chandi/Documents/App1/WhatsNext
./build_release.sh
```

**Option B: Using Xcode**
1. Open `WhatsNext.xcodeproj` in Xcode
2. Select **Product** → **Scheme** → **Edit Scheme...**
3. Under **Run**, set **Build Configuration** to **Release**
4. **Product** → **Build** (`⌘ + B`)
5. The app will be in: `~/Library/Developer/Xcode/DerivedData/WhatsNext-*/Build/Products/Release/WhatsNext.app`

### Step 2: Locate and Run the App

After building, the app is located at:
```
./build/Build/Products/Release/WhatsNext.app
```

**To run it:**
```bash
open ./build/Build/Products/Release/WhatsNext.app
```

Or navigate to the folder in Finder and double-click `WhatsNext.app`.

## Method 2: Create Distributable App (For Sharing)

### Using the Script
```bash
cd /Users/chandi/Documents/App1/WhatsNext
./create_standalone_app.sh
```

This will create a standalone app in `./WhatsNext_Standalone/WhatsNext.app`

### Using Xcode Archive

1. **Open Xcode** and select the project
2. **Product** → **Archive**
3. Wait for the archive to complete
4. The **Organizer** window will open
5. Select your archive and click **Distribute App**
6. Choose **Copy App** (for personal use) or **Developer ID** (for distribution)
7. Choose a location to save the app
8. Click **Export**

## Method 3: Manual Build and Copy

### Build in Xcode
1. **Product** → **Scheme** → **Edit Scheme...**
2. Set **Build Configuration** to **Release**
3. **Product** → **Build** (`⌘ + B`)

### Find the Built App
1. **Product** → **Show Build Folder in Finder** (or `⌘ + Shift + ⌥ + K`)
2. Navigate to: `Build/Products/Release/`
3. Copy `WhatsNext.app` to your desired location

## Installing the App

### Option 1: Applications Folder (Recommended)
1. Open **Finder**
2. Navigate to the built app
3. Drag `WhatsNext.app` to your **Applications** folder
4. You can now launch it from Launchpad or Applications

### Option 2: Desktop or Custom Location
1. Copy `WhatsNext.app` to any location
2. Double-click to run
3. You may need to right-click → **Open** the first time (macOS Gatekeeper)

## First Launch: Gatekeeper Warning

On first launch, macOS may show a security warning because the app isn't code-signed for distribution.

**To allow it:**
1. Right-click the app → **Open**
2. Click **Open** in the security dialog
3. Or go to **System Settings** → **Privacy & Security** → Allow the app

## Making It Permanent

### Add to Login Items (Optional)
If you want the app to launch automatically:
1. **System Settings** → **General** → **Login Items**
2. Click **+** and add `WhatsNext.app`

### Create an Alias/Shortcut
1. Right-click `WhatsNext.app` → **Make Alias**
2. Drag the alias to Desktop or Dock for quick access

## Troubleshooting

### "App is damaged" Error
- Right-click the app → **Open** (bypasses Gatekeeper)
- Or: `xattr -cr WhatsNext.app` in Terminal

### App Won't Launch
- Check Console.app for error messages
- Verify the app was built for the correct architecture (Apple Silicon vs Intel)
- Rebuild in Release configuration

### App Requires Xcode
- Make sure you built in **Release** configuration, not Debug
- Debug builds may have dependencies on Xcode

## Code Signing (For Distribution)

If you want to distribute the app to others:

1. **Get a Developer ID** from Apple Developer Program
2. In Xcode: **Signing & Capabilities** → Enable **Automatically manage signing**
3. Or manually sign: `codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" WhatsNext.app`

## Quick Reference

| Action | Command/Shortcut |
|--------|------------------|
| Build Release | `./build_release.sh` or `⌘ + B` (Release config) |
| Archive | **Product** → **Archive** |
| Show Build Folder | `⌘ + Shift + ⌥ + K` |
| Run Built App | `open path/to/WhatsNext.app` |

## Notes

- **Release builds** are optimized and don't require Xcode
- **Debug builds** may have debug symbols and slower performance
- The app will run from anywhere once built
- Menu bar functionality works independently
- All features work without Xcode running
