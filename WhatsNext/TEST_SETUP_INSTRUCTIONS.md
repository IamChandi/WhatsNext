# Test Setup Instructions

## Issue: No Test Target or TestPlan Found

Your test files exist, but they need to be added to an Xcode test target. Here's how to set it up:

## Step 1: Add Test Target in Xcode

1. **Open Xcode** and open `WhatsNext.xcodeproj`

2. **Add Test Target:**
   - Click on the project name in the Project Navigator (top item)
   - Select the **WhatsNext** target
   - Click the **+** button at the bottom of the targets list
   - Choose **macOS** → **Unit Testing Bundle**
   - Name it: `WhatsNextTests`
   - Make sure "Target to be Tested" is set to `WhatsNext`
   - Click **Finish**

3. **Add Test Files to Target:**
   - Select all test files in `WhatsNextTests/` folder
   - In the File Inspector (right panel), under "Target Membership"
   - Check the box next to **WhatsNextTests**

## Step 2: Verify Test Target Settings

1. Select the **WhatsNextTests** target
2. Go to **Build Settings**
3. Verify:
   - **Product Bundle Identifier**: `com.whatsnext.app.WhatsNextTests`
   - **Test Host**: Should be set to your app
   - **Bundle Loader**: Should reference your app

## Step 3: Create TestPlan (Optional but Recommended)

### Option A: Create in Xcode UI

1. **File** → **New** → **File...**
2. Choose **Test Plan** (under "Other")
3. Name it: `WhatsNextTests.xctestplan`
4. Save it in the project root
5. Select all test targets
6. Click **Finish**

### Option B: Use the Provided TestPlan

1. The file `WhatsNextTests.xctestplan` has been created
2. In Xcode, right-click the project → **Add Files to "WhatsNext"...**
3. Select `WhatsNextTests.xctestplan`
4. Make sure "Copy items if needed" is **unchecked**
5. Click **Add**

## Step 4: Configure Scheme to Use TestPlan

1. **Product** → **Scheme** → **Edit Scheme...**
2. Select **Test** in the left sidebar
3. Under **Test** → **Info** tab
4. Change "Test Plan" from "None" to `WhatsNextTests`
5. Click **Close**

## Step 5: Run Tests

Now you can run tests:
- Press `⌘ + U` to run all tests
- Or use Test Navigator (`⌘ + 6`) to run specific tests

## Alternative: Quick Setup Without TestPlan

If you don't want to use TestPlans:

1. Just complete **Step 1** and **Step 2** above
2. Skip TestPlan creation
3. Tests will run directly from the scheme

## Verify Setup

After setup, you should see:
- ✅ `WhatsNextTests` target in the targets list
- ✅ All test files showing in Test Navigator (`⌘ + 6`)
- ✅ Green play buttons next to test classes
- ✅ Ability to run tests with `⌘ + U`

## Troubleshooting

### "No tests found"
- Make sure test files are added to the `WhatsNextTests` target
- Check that test classes inherit from `XCTestCase`
- Verify test methods start with `test`

### "Scheme is not configured for testing"
- Go to **Product** → **Scheme** → **Edit Scheme...**
- Select **Test** → Check that test target is listed
- If not, click **+** and add `WhatsNextTests`

### Tests don't appear in Test Navigator
- Clean build folder: **Product** → **Clean Build Folder** (`⌘ + Shift + K`)
- Rebuild: **Product** → **Build** (`⌘ + B`)
- Restart Xcode if needed
