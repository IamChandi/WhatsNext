# Quick Start: Build Standalone macOS App

## 🚀 Fastest Method (Recommended)

Simply run the build script:

```bash
cd /Users/chandi/Documents/App1/WhatsNext
./build_release.sh
```

The script will:
1. ✅ Clean previous builds
2. ✅ Build a Release version of the app
3. ✅ Show you where the app is located
4. ✅ Optionally install it to Applications folder
5. ✅ Optionally launch it for you

**That's it!** The app will be ready to run independently without Xcode.

## 📍 Where is the App?

After building, your app is located at:
```
./build/Build/Products/Release/WhatsNext.app
```

## 🏃 Running the App

**Option 1: From Terminal**
```bash
open ./build/Build/Products/Release/WhatsNext.app
```

**Option 2: From Finder**
- Navigate to the folder in Finder
- Double-click `WhatsNext.app`

**Option 3: Install to Applications**
- Drag `WhatsNext.app` to your Applications folder
- Launch from Launchpad or Applications

## ⚠️ First Launch: Gatekeeper

On first launch, macOS may show a security warning. This is normal for apps not distributed through the App Store.

**To allow it:**
1. Right-click the app → **Open**
2. Click **Open** in the security dialog
3. Or: **System Settings** → **Privacy & Security** → Allow the app

## 🔧 Alternative: Build in Xcode

If you prefer using Xcode:

1. Open `WhatsNext.xcodeproj` in Xcode
2. **Product** → **Scheme** → **Edit Scheme...**
3. Under **Run**, set **Build Configuration** to **Release**
4. **Product** → **Build** (`⌘ + B`)
5. **Product** → **Show Build Folder in Finder** (`⌘ + Shift + ⌥ + K`)
6. Navigate to: `Build/Products/Release/WhatsNext.app`

## 📦 For Distribution (Advanced)

If you want to create a distributable app for others:

```bash
./create_standalone_app.sh
```

This creates an archived and exported version in `./WhatsNext_Standalone/WhatsNext.app`

## ✅ Verification

The app runs independently if:
- ✅ You can launch it without Xcode running
- ✅ It appears in Activity Monitor as a separate process
- ✅ Menu bar icon works (if applicable)
- ✅ All features function normally

## 🐛 Troubleshooting

**"App is damaged" Error**
```bash
xattr -cr WhatsNext.app
```

**Build Fails**
- Make sure Xcode is installed and up to date
- Check that you have a valid Apple Developer account (for CloudKit)
- Try cleaning: `xcodebuild clean -project WhatsNext.xcodeproj -scheme WhatsNext`

**App Won't Launch**
- Check Console.app for error messages
- Verify you built in **Release** configuration (not Debug)
- Rebuild the app

## 📝 Notes

- **Release builds** are optimized and don't require Xcode
- **Debug builds** may have dependencies on Xcode
- The app includes CloudKit sync (requires code signing)
- All features work independently once built

---

**Need more details?** See [BUILD_STANDALONE_APP.md](BUILD_STANDALONE_APP.md) for comprehensive instructions.
