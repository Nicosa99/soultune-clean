# SoulTune App Icon Setup

## Icon Configuration

The app icon has been configured using `flutter_launcher_icons` package.

### Icon File
- **Location**: `soultune-app-icon.png` (root directory)
- **Size**: 808KB
- **Background Color** (Android Adaptive): `#1A1A2E` (dark blue-purple)

### Configuration (pubspec.yaml)

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "soultune-app-icon.png"
  adaptive_icon_background: "#1A1A2E"
  adaptive_icon_foreground: "soultune-app-icon.png"
```

## How to Generate Icons

Run the following commands to generate app icons for both Android and iOS:

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate icons
dart run flutter_launcher_icons

# Or use the shorthand:
flutter pub run flutter_launcher_icons
```

## What Gets Generated

### Android
- **Mipmap icons** (all densities):
  - `android/app/src/main/res/mipmap-mdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-hdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png`
  - `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`

- **Adaptive icons** (Android 8.0+):
  - `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml`
  - `android/app/src/main/res/drawable/ic_launcher_background.xml`
  - `android/app/src/main/res/drawable/ic_launcher_foreground.xml`

### iOS
- **AppIcon assets**:
  - `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Includes all required sizes (20x20 to 1024x1024)
  - Updates `Contents.json` automatically

## Verification

After generating, verify the icons:

1. **Android**: Check `android/app/src/main/res/mipmap-*` folders
2. **iOS**: Check `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
3. **Run the app**:
   ```bash
   flutter run
   ```
4. **Check launcher**: Icon should appear on device/emulator home screen

## Icon Design Specs

### Requirements
- **Minimum size**: 1024x1024px (recommended source)
- **Format**: PNG with transparency
- **Aspect ratio**: 1:1 (square)
- **Safe area**: Keep important content within 80% center area

### Platform-Specific
- **Android**: Supports transparent backgrounds (adaptive icons)
- **iOS**: Automatically masks to rounded square
- **Adaptive (Android 8.0+)**: Uses foreground + background layers

## Troubleshooting

### Icons not updating on device?
```bash
# Clean and rebuild
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter run
```

### Missing icons after generation?
- Verify `soultune-app-icon.png` exists in project root
- Check `pubspec.yaml` indentation (YAML is sensitive!)
- Ensure package version is up to date

### iOS icons not showing?
- Open `ios/Runner.xcworkspace` in Xcode
- Navigate to `Assets.xcassets/AppIcon.appiconset`
- Verify all sizes are present

## References

- **flutter_launcher_icons**: https://pub.dev/packages/flutter_launcher_icons
- **Android Icon Guidelines**: https://developer.android.com/google-play/resources/icon-design-specifications
- **iOS Icon Guidelines**: https://developer.apple.com/design/human-interface-guidelines/app-icons
