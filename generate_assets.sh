#!/bin/bash

# SoulTune - Generate App Icons & Splash Screens
# Run this script after pulling the branch to generate all assets

set -e  # Exit on error

echo "🎨 SoulTune - Generating App Icons & Splash Screens..."
echo ""

# Check if soultune-app-icon.png exists
if [ ! -f "soultune-app-icon.png" ]; then
    echo "❌ Error: soultune-app-icon.png not found in project root!"
    echo "Please ensure the icon file exists before running this script."
    exit 1
fi

echo "✅ Found soultune-app-icon.png ($(du -h soultune-app-icon.png | cut -f1))"
echo ""

# Step 1: Install dependencies
echo "📦 Step 1/3: Installing Flutter dependencies..."
flutter pub get
echo ""

# Step 2: Generate app icons
echo "🖼️  Step 2/3: Generating app icons for Android & iOS..."
dart run flutter_launcher_icons
echo ""

# Step 3: Generate native splash screens
echo "🌊 Step 3/3: Generating native splash screens..."
dart run flutter_native_splash:create
echo ""

# Verify Android icons
if [ -f "android/app/src/main/res/mipmap-hdpi/ic_launcher.png" ]; then
    echo "✅ Android icons generated successfully"
else
    echo "⚠️  Warning: Android icons may not have been generated"
fi

# Verify iOS icons (if iOS directory exists)
if [ -d "ios" ]; then
    if [ -d "ios/Runner/Assets.xcassets/AppIcon.appiconset" ]; then
        echo "✅ iOS icons generated successfully"
    else
        echo "⚠️  Warning: iOS icons may not have been generated"
    fi
fi

echo ""
echo "🎉 All done! Icon and splash screen generation complete."
echo ""
echo "Next steps:"
echo "  • Run 'flutter run' to see the new icon on your device/emulator"
echo "  • The splash screen will appear automatically when launching the app"
echo ""
echo "Troubleshooting:"
echo "  • If icon doesn't update: Run 'flutter clean' then 'flutter run'"
echo "  • On iOS: Clean build folder in Xcode"
echo "  • On physical device: May need to uninstall/reinstall app"
