#!/bin/bash

# Script to build a standalone release version of WhatsNext
# This creates a .app bundle that can run independently

echo "Building WhatsNext Release Version..."
echo "======================================"
echo ""

cd "$(dirname "$0")"

# Clean previous builds
echo "Cleaning previous builds..."
xcodebuild clean -project WhatsNext.xcodeproj -scheme WhatsNext -configuration Release

# Build Release version
echo ""
echo "Building Release version..."
xcodebuild build \
  -project WhatsNext.xcodeproj \
  -scheme WhatsNext \
  -configuration Release \
  -derivedDataPath ./build

# Check if build was successful
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    echo "Your app is located at:"
    echo "  ./build/Build/Products/Release/WhatsNext.app"
    echo ""
    echo "To run the app:"
    echo "  open ./build/Build/Products/Release/WhatsNext.app"
    echo ""
    echo "Or double-click the app in Finder"
else
    echo ""
    echo "❌ Build failed. Check the errors above."
    exit 1
fi
