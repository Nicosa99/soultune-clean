# SoulTune Setup & Development Guide

## Prerequisites

- **Flutter SDK:** 3.24.0+
- **Dart SDK:** 3.5.0+
- **Android Studio:** 2023.3+ (for Android development)
- **Xcode:** 15+ (for iOS development)
- **VS Code** or **Android Studio** with Flutter plugins

---

## Initial Setup

### 1. Clone Repository

```bash
git clone <repository-url>
cd soultune-clean
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Code (Riverpod, Freezed)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Verify Setup

```bash
flutter doctor
flutter analyze
```

---

## Android Configuration

### Permissions (Already Configured)

`android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Storage -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />

<!-- Background Audio -->
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK" />
```

### MainActivity (CRITICAL)

`android/app/src/main/kotlin/com/example/soultune/MainActivity.kt`:

```kotlin
package com.example.soultune

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

**IMPORTANT:** Must use `FlutterFragmentActivity`, NOT `FlutterActivity`!

### Audio Service Configuration (Already in Manifest)

```xml
<service
    android:name="com.ryanheise.audioservice.AudioService"
    android:foregroundServiceType="mediaPlayback"
    android:exported="true">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>

<receiver
    android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>
```

### Min SDK Version

`android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 24  // Android 7.0+
        targetSdkVersion 34
    }
}
```

---

## iOS Configuration (Future)

### Info.plist Permissions

```xml
<key>NSAppleMusicUsageDescription</key>
<string>SoulTune needs access to your music library to play and transform audio.</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
    <string>fetch</string>
</array>
```

### Deployment Target

- Minimum iOS version: 12.0

---

## Running the App

### Debug Mode

```bash
flutter run
```

### Release Mode

```bash
flutter run --release
```

### Specific Device

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

---

## Common Development Tasks

### 1. Clean Build

When experiencing build issues:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

### 2. Android Gradle Clean

```bash
cd android
./gradlew clean  # Linux/Mac
gradlew.bat clean  # Windows
cd ..
flutter run
```

### 3. Code Generation

After modifying @riverpod or @freezed annotated classes:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Or watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 4. Format Code

```bash
dart format lib/
```

### 5. Analyze Code

```bash
flutter analyze
```

---

## Project Structure Explained

```
soultune-clean/
├── android/                    # Android native code
│   ├── app/
│   │   └── src/main/
│   │       ├── kotlin/.../MainActivity.kt
│   │       └── AndroidManifest.xml
│   └── build.gradle
├── ios/                        # iOS native code (future)
├── lib/                        # Flutter/Dart source
│   ├── main.dart              # Entry point
│   ├── app/                   # App-wide config
│   ├── features/              # Feature modules
│   └── shared/                # Shared code
├── docs/                       # Documentation
├── test/                       # Unit tests (empty)
├── integration_test/           # Integration tests (empty)
├── pubspec.yaml               # Dependencies
├── analysis_options.yaml      # Linting rules
└── CLAUDE.md                  # AI assistant instructions
```

---

## Environment Setup

### 1. VS Code Extensions (Recommended)

- Flutter
- Dart
- Flutter Riverpod Snippets
- Error Lens
- GitLens

### 2. VS Code Settings

`.vscode/settings.json`:

```json
{
  "dart.flutterSdkPath": "path/to/flutter",
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true,
    "source.organizeImports": true
  },
  "[dart]": {
    "editor.tabSize": 2,
    "editor.rulers": [80]
  }
}
```

### 3. Launch Configuration

`.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "SoulTune (debug)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "SoulTune (profile)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "SoulTune (release)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
```

---

## Debugging Tips

### 1. Logger Output

All services use the `logger` package. Watch for emoji indicators:

- 💡 Info
- ⚠️ Warning
- ⛔ Error
- ✓ Success
- 🐛 Debug

### 2. Riverpod DevTools

Add to `main.dart` for provider logging:

```dart
void main() async {
  // ...
  runApp(
    ProviderScope(
      observers: [ProviderLogger()],
      child: const SoulTuneApp(),
    ),
  );
}

class ProviderLogger extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint('Provider Updated: ${provider.name ?? provider.runtimeType}');
  }
}
```

### 3. Audio Debugging

Check audio session configuration:

```dart
final session = await AudioSession.instance;
debugPrint('Audio Session: ${session.configuration}');
```

### 4. Hive Database Inspection

```dart
final box = Hive.box<AudioFile>('audio_files');
debugPrint('Library size: ${box.length}');
debugPrint('All keys: ${box.keys.toList()}');
```

---

## Troubleshooting

### Issue: PlatformException (FlutterEngine not found)

**Cause:** MainActivity not using FlutterFragmentActivity

**Solution:**
1. Ensure `MainActivity.kt` extends `FlutterFragmentActivity`
2. Run `flutter clean && flutter run`
3. If still failing, clean Android build: `cd android && ./gradlew clean`

### Issue: Build Runner Conflicts

**Cause:** Generated files out of sync

**Solution:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Permission Denied (Android 13+)

**Cause:** New Android 13 media permissions

**Solution:** Ensure `READ_MEDIA_AUDIO` permission in manifest and runtime request

### Issue: Audio Won't Play in Background

**Cause:** Audio session not configured

**Solution:** AudioPlayerService.init() configures session automatically. Ensure it's called in main.dart.

### Issue: Hot Reload Not Working

**Cause:** Native code changes require full restart

**Solution:** Stop app and run `flutter run` again

---

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Future)

```bash
flutter build ios --release
```

Requires Xcode and Apple Developer account.

---

## Testing (Not Yet Implemented)

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

### Coverage Report

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## Continuous Integration (Future)

### GitHub Actions Example

```yaml
name: Flutter CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

---

## Code Style Guide

### Imports Order

1. Dart SDK
2. Flutter SDK
3. External packages
4. Local imports (relative)

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soultune/features/player/...';
import 'package:soultune/shared/...';
```

### Naming Conventions

- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Private: `_leadingUnderscore`
- Constants: `kConstantName`
- Providers: `featurePurposeProvider`

### Widget Structure

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch providers
    final data = ref.watch(someProvider);

    // 2. Get theme/colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 3. Build UI
    return Container(...);
  }
}
```

---

## Git Workflow

### Commit Convention

```
feat: Add 432Hz pitch shift feature
fix: Resolve audio playback crash on iOS
docs: Update README with setup instructions
refactor: Simplify player state management
test: Add unit tests for frequency calculations
chore: Update dependencies
```

### Branch Strategy

- `main` - Production-ready code
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes
- `claude/*` - AI-assisted development

---

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [just_audio Package](https://pub.dev/packages/just_audio)
- [audio_service Package](https://pub.dev/packages/audio_service)
- [Hive Documentation](https://docs.hivedb.dev/)

---

*Last updated: 2025-11-17*
