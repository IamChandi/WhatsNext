#!/bin/bash

# Script to build a standalone release version of WhatsNext
# This creates a .app bundle that can run independently without Xcode

set -e  # Exit on error

echo "🚀 Building WhatsNext Release Version..."
echo "========================================"
echo ""

cd "$(dirname "$0")"

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: xcodebuild not found. Please install Xcode from the App Store."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
xcodebuild clean \
  -project WhatsNext.xcodeproj \
  -scheme WhatsNext \
  -configuration Release \
  -derivedDataPath ./build \
  -quiet || true  # Don't fail if there's nothing to clean

# Build Release version
echo ""
echo "🔨 Building Release version..."
echo "   This may take a few minutes..."
echo "   (Using automatic code signing for CloudKit compatibility)"
echo ""

xcodebuild build \
  -project WhatsNext.xcodeproj \
  -scheme WhatsNext \
  -configuration Release \
  -derivedDataPath ./build

# Check if build was successful
APP_PATH="./build/Build/Products/Release/WhatsNext.app"

if [ -d "$APP_PATH" ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "📦 Your app is located at:"
    echo "   $(pwd)/$APP_PATH"
    echo ""
    
    # Get app size
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    echo "   Size: $APP_SIZE"
    echo ""
    
    # Ask if user wants to install to Applications
    read -p "📥 Install to Applications folder? (y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "📦 Copying to Applications folder..."
        cp -R "$APP_PATH" ~/Applications/WhatsNext.app 2>/dev/null || \
        cp -R "$APP_PATH" /Applications/WhatsNext.app
        
        if [ $? -eq 0 ]; then
            echo "✅ Installed to Applications folder!"
            echo ""
            read -p "🚀 Launch the app now? (y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                open ~/Applications/WhatsNext.app 2>/dev/null || \
                open /Applications/WhatsNext.app
            fi
        else
            echo "⚠️  Could not install to Applications. You can manually drag the app there."
        fi
    else
        echo "💡 To run the app:"
        echo "   open $(pwd)/$APP_PATH"
        echo ""
        echo "   Or double-click the app in Finder"
        echo ""
        echo "💡 To install later, drag the app to your Applications folder"
    fi
    
    echo ""
    echo "✨ Done! The app runs independently without Xcode."
    echo ""
else
    echo ""
    echo "❌ Build failed. The app was not created."
    echo "   Check the errors above for details."
    exit 1
fi
