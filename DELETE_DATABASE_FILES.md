# Delete Existing Database Files

## The Problem

The `loadIssueModelContainer` error might be caused by existing database files with an incompatible schema. SwiftData stores database files in the app's container directory.

## How to Delete Database Files

### Option 1: Delete via Terminal

1. **Open Terminal**
2. **Run this command** to find and delete WhatsNext database files:

```bash
# Find database files
find ~/Library/Containers -name "*WhatsNext*" -type f 2>/dev/null

# Delete them (be careful!)
find ~/Library/Containers -name "*WhatsNext*" -type f -delete 2>/dev/null
```

### Option 2: Delete via Finder

1. **Open Finder**
2. **Press ⌘ + Shift + G** (Go to Folder)
3. **Enter**: `~/Library/Containers`
4. **Search for**: `WhatsNext` or `com.whatsnext`
5. **Delete any folders/files** related to WhatsNext

### Option 3: Reset Simulator (if using simulator)

1. **Xcode** → **Window** → **Devices and Simulators**
2. **Select your simulator**
3. **Right-click** → **Erase All Content and Settings**

## After Deleting

1. **Clean Build Folder**: ⌘ + Shift + K
2. **Rebuild**: ⌘ + B
3. **Run**: ⌘ + R

This will force SwiftData to create a fresh database with the current schema.
