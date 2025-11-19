@echo off
REM SoulTune - Generate App Icons & Splash Screens (Windows)
REM Run this script after pulling the branch to generate all assets

echo 🎨 SoulTune - Generating App Icons ^& Splash Screens...
echo.

REM Check if soultune-app-icon.png exists
if not exist "soultune-app-icon.png" (
    echo ❌ Error: soultune-app-icon.png not found in project root!
    echo Please ensure the icon file exists before running this script.
    exit /b 1
)

echo ✅ Found soultune-app-icon.png
echo.

REM Step 1: Install dependencies
echo 📦 Step 1/3: Installing Flutter dependencies...
call flutter pub get
echo.

REM Step 2: Generate app icons
echo 🖼️  Step 2/3: Generating app icons for Android ^& iOS...
call dart run flutter_launcher_icons
echo.

REM Step 3: Generate native splash screens
echo 🌊 Step 3/3: Generating native splash screens...
call dart run flutter_native_splash:create
echo.

REM Verify Android icons
if exist "android\app\src\main\res\mipmap-hdpi\ic_launcher.png" (
    echo ✅ Android icons generated successfully
) else (
    echo ⚠️  Warning: Android icons may not have been generated
)

REM Verify iOS icons
if exist "ios\Runner\Assets.xcassets\AppIcon.appiconset" (
    echo ✅ iOS icons generated successfully
) else (
    echo ⚠️  iOS icons directory not found (normal if iOS not configured)
)

echo.
echo 🎉 All done! Icon and splash screen generation complete.
echo.
echo Next steps:
echo   • Run 'flutter run' to see the new icon on your device/emulator
echo   • The splash screen will appear automatically when launching the app
echo.
echo Troubleshooting:
echo   • If icon doesn't update: Run 'flutter clean' then 'flutter run'
echo   • On iOS: Clean build folder in Xcode
echo   • On physical device: May need to uninstall/reinstall app

pause
