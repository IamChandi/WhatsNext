#!/bin/bash

# Script to create a standalone, distributable .app bundle
# This archives the app and exports it to a location you can use

echo "Creating Standalone WhatsNext App..."
echo "====================================="
echo ""

cd "$(dirname "$0")"

# Create output directory
OUTPUT_DIR="./WhatsNext_Standalone"
mkdir -p "$OUTPUT_DIR"

# Archive the app
echo "Archiving the app..."
xcodebuild archive \
  -project WhatsNext.xcodeproj \
  -scheme WhatsNext \
  -configuration Release \
  -archivePath "$OUTPUT_DIR/WhatsNext.xcarchive" \
  -derivedDataPath ./build

if [ $? -ne 0 ]; then
    echo "❌ Archive failed. Check the errors above."
    exit 1
fi

# Export the app from archive
echo ""
echo "Exporting app from archive..."
xcodebuild -exportArchive \
  -archivePath "$OUTPUT_DIR/WhatsNext.xcarchive" \
  -exportPath "$OUTPUT_DIR" \
  -exportOptionsPlist <(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF
)

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Standalone app created successfully!"
    echo ""
    echo "Your app is located at:"
    echo "  $OUTPUT_DIR/WhatsNext.app"
    echo ""
    echo "You can now:"
    echo "  1. Drag the app to your Applications folder"
    echo "  2. Double-click to run it"
    echo "  3. It will run independently without Xcode"
    echo ""
else
    echo ""
    echo "⚠️  Export failed. Trying simpler method..."
    echo ""
    echo "Copying app from build folder..."
    
    # Fallback: Copy from build folder
    if [ -d "./build/Build/Products/Release/WhatsNext.app" ]; then
        cp -R "./build/Build/Products/Release/WhatsNext.app" "$OUTPUT_DIR/"
        echo "✅ App copied to: $OUTPUT_DIR/WhatsNext.app"
    else
        echo "❌ App not found in build folder. Please build first using build_release.sh"
        exit 1
    fi
fi
