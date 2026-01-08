# CloudKit ModelContainer Error Troubleshooting

## The Error

The app is crashing when trying to create the ModelContainer with CloudKit. This usually means CloudKit isn't properly configured yet.

## What I've Done

I've improved error handling to:
1. **Show the actual error** (instead of just crashing)
2. **Fall back to local storage** if CloudKit fails
3. **Provide detailed error messages** in the console

## Next Steps

### Step 1: Check the Console

When you run the app, check the Xcode console (bottom panel) for error messages. You should see:
- The actual CloudKit error
- Whether it fell back to local storage
- Detailed error information

### Step 2: Add CloudKit Capability in Xcode

The error is likely because CloudKit capability isn't added yet:

1. **Open WhatsNext project** (macOS app)
2. Select **WhatsNext** target
3. **Signing & Capabilities** tab
4. Click **"+ Capability"**
5. Search for **"CloudKit"**
6. Add it
7. Click **"+ Add Container"**
8. Enter: `iCloud.com.chandi.WhatsNext`

### Step 3: Verify Entitlements

Check that `WhatsNext.entitlements` has:
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

### Step 4: Clean and Rebuild

1. **Clean Build Folder**: Product → Clean Build Folder (⌘ + Shift + K)
2. **Delete Derived Data** (optional but recommended):
   - Xcode → Settings → Locations
   - Click arrow next to Derived Data
   - Delete the folder for this project
3. **Rebuild**: ⌘ + B

## Common CloudKit Errors

### "CloudKit not available"
- CloudKit capability not added in Xcode
- Add it in Signing & Capabilities

### "Container not found"
- Container identifier doesn't match
- Verify both apps use: `iCloud.com.chandi.WhatsNext`

### "Permission denied"
- Not signed in with paid developer account
- Check Xcode → Settings → Accounts

### "Schema mismatch"
- Models changed but CloudKit schema not updated
- This is normal on first run - CloudKit will create the schema

## Fallback Behavior

The app now has a **fallback mechanism**:
- If CloudKit fails → Uses local storage
- App won't crash, but won't sync
- Check console to see which mode it's using

## Check Console Output

When you run the app, look for these messages in the console:

**Success with CloudKit:**
```
✅ ModelContainer created successfully with CloudKit
```

**Fallback to local storage:**
```
❌ Failed to create ModelContainer with CloudKit: [error]
⚠️ Attempting fallback to local storage...
✅ ModelContainer created with local storage (CloudKit unavailable)
```

**Critical failure:**
```
❌ Critical: Failed to create ModelContainer even with local storage: [error]
```

## Next Steps

1. **Run the app** and check the console
2. **Copy the error message** you see
3. **Add CloudKit capability** in Xcode if you haven't
4. **Clean and rebuild**

The app should now work even if CloudKit isn't configured yet (using local storage), but you'll see helpful error messages to guide you through fixing CloudKit.
