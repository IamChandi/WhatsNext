# Fix Duplicate Build Files Warnings

## Issue
Test files are showing as duplicates in the "Compile Sources" build phase.

## Solution: Remove Duplicates in Xcode

### Method 1: Using Build Phases (Recommended)

1. **Open Xcode** and select your project (blue icon) in Project Navigator
2. **Select the `WhatsNextTests` target** (not the app target)
3. Click on **"Build Phases"** tab
4. Expand **"Compile Sources"**
5. You'll see duplicate entries for each test file
6. **Remove duplicates:**
   - Select a duplicate file (you'll see the same file listed twice)
   - Press `Delete` or click the `-` button
   - Keep only ONE instance of each test file
7. Repeat for all duplicate files

### Method 2: Quick Fix - Remove All and Re-add

1. In **Build Phases** → **Compile Sources**
2. Select ALL test files (⌘ + A)
3. Click `-` to remove all
4. Click `+` to add files back
5. Navigate to `WhatsNextTests/` folder
6. Select all test files and click **Add**
7. Make sure each file appears only ONCE

### Method 3: Check Target Membership

1. Select a test file in Project Navigator
2. Open **File Inspector** (⌘ + Option + 1)
3. Under **"Target Membership"**
4. Make sure **WhatsNextTests** is checked ONCE
5. If checked multiple times, uncheck and re-check once
6. Repeat for all test files

## Files to Check

Make sure these files appear only ONCE in Compile Sources:
- EnumTests.swift
- GoalAlertModelTests.swift
- GoalModelTests.swift
- HistoryEntryModelTests.swift
- LayoutConsistencyTests.swift
- NaturalLanguageParserTests.swift
- NotificationServiceTests.swift
- RecurrenceRuleModelTests.swift
- SubtaskModelTests.swift
- TagModelTests.swift
- UIComponentTests.swift
- UIConsistencyTests.swift

## Verify Fix

After removing duplicates:
1. Clean build folder: **Product** → **Clean Build Folder** (⌘ + Shift + K)
2. Build: **Product** → **Build** (⌘ + B)
3. Warnings should be gone

## Prevention

To avoid this in the future:
- When adding files, use "Add Files to..." dialog
- Don't manually drag files into Compile Sources
- Check Target Membership in File Inspector instead
