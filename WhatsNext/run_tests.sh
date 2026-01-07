#!/bin/bash

# Script to run WhatsNext tests from command line

echo "Running WhatsNext Tests..."
echo "=========================="
echo ""

cd "$(dirname "$0")"

# Run all tests
xcodebuild test \
  -project WhatsNext.xcodeproj \
  -scheme WhatsNext \
  -destination 'platform=macOS' \
  2>&1 | xcpretty --test --color

echo ""
echo "Tests completed!"
