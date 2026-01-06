# App Icon Generation Instructions

## Icon Design: "What's Next?" - West Wing Inspired

The icon features:
- **Presidential Blue** background (#1a365d to #2c5282 gradient) - inspired by West Wing's Oval Office
- **White checkmark** with forward-pointing arrow - symbolizing task completion and "What's Next?"
- **Motion lines** - representing the show's famous "walk and talk" style
- **Orange accent** (#ed8936) - the forward arrow tip, signifying momentum
- **Progress dots** at bottom - suggesting ongoing progress

## Generate Icons from SVG

### Option 1: Online Converter (Easiest)
1. Go to https://cloudconvert.com/svg-to-png
2. Upload `WhatsNext/Resources/AppIcon.svg`
3. Set output size to 1024x1024
4. Download and save as `icon_512x512@2x.png`
5. Repeat for other sizes or use an icon generator

### Option 2: Install rsvg-convert
```bash
brew install librsvg
cd /Users/chandi/Documents/App1/WhatsNext
chmod +x generate_icons.sh
./generate_icons.sh
```

### Option 3: Use macOS App Icon Generator
1. Go to https://appicon.co/
2. Upload the 1024x1024 PNG
3. Download the macOS icon set
4. Copy files to `WhatsNext/Resources/Assets.xcassets/AppIcon.appiconset/`

### Option 4: Create in Figma/Sketch
Import the SVG and export at required sizes:
- 16x16, 16x16@2x (32px)
- 32x32, 32x32@2x (64px)
- 128x128, 128x128@2x (256px)
- 256x256, 256x256@2x (512px)
- 512x512, 512x512@2x (1024px)

## Required Files
Place these PNG files in `WhatsNext/Resources/Assets.xcassets/AppIcon.appiconset/`:
- icon_16x16.png
- icon_16x16@2x.png
- icon_32x32.png
- icon_32x32@2x.png
- icon_128x128.png
- icon_128x128@2x.png
- icon_256x256.png
- icon_256x256@2x.png
- icon_512x512.png
- icon_512x512@2x.png
