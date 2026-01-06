#!/bin/bash

# Generate app icons from SVG
# Requires: brew install librsvg (for rsvg-convert)
# Or use any online SVG to PNG converter

SVG_PATH="WhatsNext/Resources/AppIcon.svg"
OUTPUT_DIR="WhatsNext/Resources/Assets.xcassets/AppIcon.appiconset"

# macOS icon sizes
SIZES=(16 32 64 128 256 512 1024)

echo "Generating app icons..."

for size in "${SIZES[@]}"; do
    # 1x
    if [ $size -le 512 ]; then
        rsvg-convert -w $size -h $size "$SVG_PATH" > "$OUTPUT_DIR/icon_${size}x${size}.png"
        echo "Created icon_${size}x${size}.png"
    fi

    # 2x
    double=$((size * 2))
    if [ $double -le 1024 ]; then
        rsvg-convert -w $double -h $double "$SVG_PATH" > "$OUTPUT_DIR/icon_${size}x${size}@2x.png"
        echo "Created icon_${size}x${size}@2x.png"
    fi
done

echo "Done! Icons generated in $OUTPUT_DIR"
echo ""
echo "If you don't have rsvg-convert, install it with:"
echo "  brew install librsvg"
echo ""
echo "Or use an online converter like:"
echo "  https://cloudconvert.com/svg-to-png"
