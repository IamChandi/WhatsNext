# Quick Start: iPhone Deployment & iCloud Sync

## Part 1: Run on iPhone (5 minutes)

### 1. Connect iPhone
- Plug iPhone into Mac with USB cable
- Unlock iPhone and trust computer

### 2. Configure in Xcode
1. Open **WhatsNextiOSApp** project
2. Select project → **WhatsNextiOSApp** target
3. **Signing & Capabilities** tab
4. Check **"Automatically manage signing"**
5. Select your **Team** (sign in with Apple ID if needed)

### 3. Select iPhone
- Click device selector in Xcode toolbar
- Choose your iPhone

### 4. Run
- Press **⌘ + R** or click Play button
- On iPhone: **Settings → General → VPN & Device Management → Trust**

Done! App is now on your iPhone.

---

## Part 2: Enable iCloud Sync (10 minutes)

### Step 1: Add CloudKit to iOS App

1. In Xcode (WhatsNextiOSApp project):
   - Select **WhatsNextiOSApp** target
   - **Signing & Capabilities** tab
   - Click **"+ Capability"**
   - Add **"iCloud"**
   - Check **"CloudKit"**
   - Click **"+ Add Container"**
   - Enter: `iCloud.com.chandi.WhatsNext` (or your bundle ID prefix)
   - Click **OK**

### Step 2: Add CloudKit to macOS App

1. In Xcode (WhatsNext project):
   - Select **WhatsNext** target
   - **Signing & Capabilities** tab
   - Click **"+ Capability"**
   - Add **"iCloud"**
   - Check **"CloudKit"**
   - In **Containers**, select the **SAME container** from Step 1
   - If not visible, add it manually: `iCloud.com.chandi.WhatsNext`

**⚠️ CRITICAL**: Both apps MUST use the **exact same container name**!

### Step 3: Verify Code is Updated

The code has been updated to use CloudKit. Both apps now:
- ✅ Use `.automatic` CloudKit database
- ✅ Share the same container
- ✅ Sync automatically

### Step 4: Test Sync

1. **On Mac**: Create a goal "Test Sync"
2. **Wait 30 seconds**
3. **On iPhone**: Open app → Should see "Test Sync"
4. **On iPhone**: Mark it complete
5. **On Mac**: Should update automatically

---

## Troubleshooting

### iPhone won't connect
- Unlock iPhone
- Trust computer
- Try different USB port
- Restart Xcode

### Code signing error
- Check Apple ID is signed in (Xcode → Settings → Accounts)
- Ensure "Automatically manage signing" is checked

### Data not syncing
1. **Check iCloud is ON**:
   - Mac: System Settings → Apple ID → iCloud → iCloud Drive
   - iPhone: Settings → [Your Name] → iCloud → iCloud Drive

2. **Same Apple ID**: Both devices must use same Apple ID

3. **Same Container**: Verify both apps use identical container name

4. **Wait**: First sync takes 30-60 seconds

5. **Internet**: Both devices need internet connection

---

## Container Identifier

The container identifier format is:
```
iCloud.com.[your-bundle-prefix].WhatsNext
```

Example:
- If bundle ID is `com.chandi.WhatsNextiOSApp`
- Container should be: `iCloud.com.chandi.WhatsNext`

**Important**: Use the same container for both macOS and iOS apps!

---

## What Gets Synced

✅ Goals
✅ Subtasks
✅ Tags
✅ Alerts
✅ Recurrence rules
✅ History

All data syncs automatically in the background!

---

## Privacy

- Data encrypted end-to-end
- Only synced to your iCloud account
- Not accessible by Apple
- Requires your Apple ID

---

## Need Help?

See detailed guides:
- `DEPLOY_TO_IPHONE.md` - Full iPhone deployment guide
- `ICLOUD_SYNC_SETUP.md` - Detailed CloudKit setup
